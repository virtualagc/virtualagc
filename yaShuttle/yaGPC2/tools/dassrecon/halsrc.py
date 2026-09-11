"""A HAL/S source file as cards, with the statement text of its M lines tokenized
and mapped back to (card, column), so spans can be replaced in place."""
import re
TOK = re.compile(r"""\s+|/\*.*?\*/|(?:HEX|BIN|OCT|DEC)?'(?:[^']|'')*'|[A-Z0-9_@#$]+(?:\.\d*)?(?:E[+-]?\d+)?|\S""", re.S)
class Src:
    def __init__(self, path):
        self.path = path
        self.cards = open(path, errors="strict").read().split("\n")
        if self.cards and self.cards[-1] == "": self.cards.pop(); self.trailing_nl = True
        else: self.trailing_nl = False
        text, pos = [], []
        for i, c in enumerate(self.cards):
            kind = c[:1]
            if kind in (" ", "") and len(c) >= 1:
                body = c[1:72]
                for j, ch in enumerate(body): text.append(ch); pos.append((i, j + 1))
                text.append(" "); pos.append((i, 72))
            elif kind in ("E", "S"):
                raise SystemExit("%s card %d: E/S line -- not handled" % (path, i + 1))
        self.text = "".join(text); self.pos = pos
        self.toks = [(m.start(), m.end(), m.group()) for m in TOK.finditer(self.text)
                     if not m.group().isspace() and not m.group().startswith("/*")]
    def declares(self):
        """[(stmt_first_tok, stmt_last_tok, [entity dicts])]"""
        T = self.toks; out = []; i = 0
        while i < len(T):
            if T[i][2] == "DECLARE":
                j = i + 1; depth = 0; ents = []; cur = [j]
                while j < len(T):
                    t = T[j][2]
                    if t == "(": depth += 1
                    elif t == ")": depth -= 1
                    elif t == "," and depth == 0: cur.append(j); cur = [j + 1]; ents.append(cur); 
                    elif t == ";" and depth == 0: break
                    j += 1
                # entity token ranges
                bounds = [i + 1] + [k + 1 for k in range(i + 1, j) if T[k][2] == "," and self._depth(i + 1, k) == 0]
                ends = [b - 1 for b in bounds[1:]] + [j]
                ents = [self._entity(b, e) for b, e in zip(bounds, ends)]
                out.append((i, j, ents)); i = j + 1
            else:
                i += 1
        return out
    def _depth(self, a, b):
        d = 0
        for k in range(a, b):
            if self.toks[k][2] == "(": d += 1
            elif self.toks[k][2] == ")": d -= 1
        return d
    def _close(self, k):
        d = 0
        for m in range(k, len(self.toks)):
            t = self.toks[m][2]
            if t == "(": d += 1
            elif t == ")":
                d -= 1
                if d == 0: return m
        raise SystemExit("unbalanced")
    def _entity(self, b, e):
        T = self.toks; ent = dict(first=b, last=e, name=T[b][2], init=None, dim=None, attrs=[])
        k = b + 1
        while k < e:
            t = T[k][2]
            if t == "INITIAL" and T[k + 1][2] == "(":
                c = self._close(k + 1); ent["init"] = (k + 1, c); k = c + 1; continue
            if t == "CONSTANT" and T[k + 1][2] == "(":
                c = self._close(k + 1); ent["const"] = (k + 1, c); k = c + 1; continue
            if t == "(" :
                c = self._close(k)
                prev = T[k - 1][2]
                if prev in ("ARRAY", "STRUCTURE") and ent["dim"] is None: ent["dim"] = (k, c)
                ent["attrs"].append((prev, self.text[T[k][1]:T[c][0]].strip()))
                k = c + 1; continue
            ent["attrs"].append((t, None)); k += 1
        return ent
    def structures(self):
        """[(first_tok, last_tok, template_name)] for STRUCTURE statements"""
        T = self.toks; out = []
        for i, t in enumerate(T):
            if t[2] == "STRUCTURE" and (i == 0 or T[i - 1][2] in (";", ":")) and i + 1 < len(T):
                j = i
                while j < len(T) and T[j][2] != ";": j += 1
                out.append((i, j, T[i + 1][2]))
        return out
    def span_text(self, a, b):
        """source text strictly between tokens a and b (exclusive)"""
        return self.text[self.toks[a][1]:self.toks[b][0]]
    # ------------------------------------------------------------ editing
    def replace_between(self, a, b, new):
        """replace the text strictly between tokens a and b with `new`"""
        self.ops = getattr(self, "ops", [])
        self.ops.append(("edit", self.toks[a][1], self.toks[b][0], new))
    def remove_statement(self, first_tok, last_tok, with_comments_before=True):
        """delete the cards of a whole statement (it must own them)"""
        self.ops = getattr(self, "ops", [])
        l1 = self.pos[self.toks[first_tok][0]][0]; l2 = self.pos[self.toks[last_tok][0]][0]
        if with_comments_before:
            while l1 > 0 and self.cards[l1 - 1][:1] == "C" and not self.cards[l1 - 1].startswith("C/"): l1 -= 1
        self.ops.append(("del", self.toks[first_tok][0], l1, l2))
        return l1
    def insert_at_card(self, key_char, card, text):
        """insert new statement cards before `card` (index in the original cards)"""
        self.ops = getattr(self, "ops", [])
        self.ops.append(("insb", key_char - 0.5, card, text))
    def insert_after_statement(self, last_tok, text):
        self.ops = getattr(self, "ops", [])
        l = self.pos[self.toks[last_tok][0]][0]
        self.ops.append(("ins", self.toks[last_tok][0], l, text))
    def render(self, width=71):
        cards = list(self.cards)
        for op in sorted(getattr(self, "ops", []), key=lambda o: -o[1]):
            if op[0] == "del":
                del cards[op[2]:op[3] + 1]; continue
            if op[0] == "insb":
                l = op[2]; ref = cards[l] if l < len(cards) else cards[-1]; srn = ref[72:80]
                new = []
                for stmt in op[3]:
                    words = self._wrap(" ", stmt, "", width)
                    new += [w.ljust(72)[:72] for w in words]
                srns = self._srns(srn, len(new), 0)
                try:
                    b = int(srn[:6]); srns = ["%06d%s" % (b - len(new) + k, srn[6:8]) for k in range(len(new))]
                except ValueError: pass
                cards[l:l] = [w + x for w, x in zip(new, srns)]
                continue
            if op[0] == "ins":
                l = op[2]; srn = cards[l][72:80]
                words = self._wrap(" ", op[3], "", width)
                cards[l + 1:l + 1] = [w.ljust(72)[:72] + x for w, x in zip(words, self._srns(srn, len(words), 1))]
                continue
            _, s, e, new = op
            l1, c1 = self.pos[s]
            if e > s: l2, c2 = self.pos[e - 1]; c2 += 1
            else: l2, c2 = l1, c1
            head = cards[l1][:c1]; tail = cards[l2][c2:72].rstrip()
            srn = cards[l1][72:80]
            inner = [cards[k] for k in range(l1 + 1, l2) if cards[k][:1] in ("F", "D")]
            pre = [x for x in inner if "END" not in x[1:9]]; post = [x for x in inner if "END" in x[1:9]]
            if pre:
                body = self._wrap("   ", new, tail, width)
                out = [head.rstrip().ljust(72)[:72] + srn] + pre + \
                      [w.ljust(72)[:72] + x for w, x in zip(body, self._srns(srn, len(body), 1))] + post
            else:
                body = self._wrap(head, new, tail, width)
                out = [w.ljust(72)[:72] + x for w, x in zip(body, self._srns(srn, len(body), 0))] + post
            cards[l1:l2 + 1] = out
        return "\n".join(cards) + ("\n" if self.trailing_nl else "")
    @staticmethod
    def _srns(srn, n, start):
        try: base = int(srn[:6]); code = srn[6:8]
        except ValueError: return [srn] * n
        return ["%06d%s" % (base + start + k, code) for k in range(n)]
    @staticmethod
    def _wrap(head, new, tail, width):
        """head + new + tail, broken after commas so every card body ends by col 72"""
        lines = []; cur = head
        pieces = re.findall(r"\x00|[^,\x00]+,?|,", new) + ([tail] if tail else [])
        for p in pieces:
            if p == "\x00":
                if cur.strip(): lines.append(cur.rstrip()); cur = "      "
                continue
            if len(cur) + len(p) > width + 1 and cur.strip():
                lines.append(cur.rstrip()); cur = "      " + p.lstrip()
            else:
                cur += p
        lines.append(cur.rstrip())
        for l in lines:
            if len(l) > 72: raise SystemExit("card overflows column 72: %r" % l)
        return lines
