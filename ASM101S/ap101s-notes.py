#!/usr/bin/env python3
'''
License:    Public Domain, no restrictions believed to exist.
Filename:   ap101s-notes.py
Purpose:    A record of what we have learned about the AP-101S assembly
            language, especially the parts the POO does not document or
            documents in a way nobody can find.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).

WHY THIS EXISTS.  "Shuttle GPC Software Model AP-101S" -- the POO -- is 532
OCR'd pages and is the authority on the instruction set, but it does not cover
everything the sources actually use, and some of what it does cover is
effectively unfindable by text search.  Working on ASM101S turns up such
things one at a time:  the '$' mnemonic suffix appears in no manual at all,
CNOP is an assembler directive and so is outside the POO entirely, and the
no-op each processor pads with had to be read off the original build.

Each of those cost real effort to establish and would cost it again if the
reasoning were not written down.  This is where it goes, so that it can
eventually be turned into human-readable documentation of the undocumented
parts of the language.

THE `evidence` FIELD IS THE POINT.  A mnemonic and an encoding without the
reasoning behind them is something the next person has to re-derive before
they dare rely on it.  Record how it was established -- which document, which
listing, which comparison -- and say plainly when something is inferred rather
than documented.

There is no obligation to fill this in systematically.  Put in what you
DISCOVER, when you discover it.

Usage:
    ap101s-notes.py list [--kind=K] [--processor=P]
    ap101s-notes.py show MNEMONIC [...]
    ap101s-notes.py search TEXT
    ap101s-notes.py add --mnemonic=M --kind=K [--processor=P]
                        [--encoding=E] [--description=D] [--evidence=V]
                        [--poo=REF] [--confidence=C]
    ap101s-notes.py set MNEMONIC --field=VALUE ...
    ap101s-notes.py render [> AP-101S-language-notes.md]

    kind        instruction | pseudo-op | suffix | convention
    processor   CPU | MSC | BCE | assembler
    confidence  documented | derived | inferred | unknown
    uncertainty verified | derived | inferred | analogous | guess
                -- grades the ENCODING alone.  See UNCERTAINTY below.
'''

import sys, os, sqlite3, datetime

HERE = os.path.dirname(os.path.abspath(__file__))
DB = os.path.join(HERE, 'ap101s-notes.db')

SCHEMA = '''
CREATE TABLE IF NOT EXISTS entries (
    id          INTEGER PRIMARY KEY,
    mnemonic    TEXT NOT NULL UNIQUE,
    kind        TEXT NOT NULL,
    processor   TEXT,
    encoding    TEXT,
    description TEXT,
    evidence    TEXT,
    poo         TEXT,
    confidence  TEXT,
    uncertainty TEXT,
    updated     TEXT
);
'''

FIELDS = ('mnemonic', 'kind', 'processor', 'encoding', 'description',
          'evidence', 'poo', 'confidence', 'uncertainty')

# `uncertainty` grades the ENCODING specifically, and separately from
# `confidence`, which is about the entry as a whole.  An encoding that is
# merely plausible must never be presented as though it were checked, because
# a wrong encoding is silently wrong object code -- the one outcome worse than
# generating nothing at all.
#
#   verified    matched byte for byte against the original build
#   derived     a consistent pattern over many observed instances
#   inferred    read from the POO but not seen in any listing
#   analogous   assumed from the regularity of its family; NOT observed
#   guess       no evidence either way
#
# Anything below `derived` should be treated as a lead, not as fact, and
# ASM101S should say so when it acts on one.
UNCERTAINTY = ('verified', 'derived', 'inferred', 'analogous', 'guess')

def connect():
    db = sqlite3.connect(DB)
    db.row_factory = sqlite3.Row
    db.executescript(SCHEMA)
    return db

def today():
    return datetime.date.today().isoformat()

def parseOptions(args):
    opts, rest = {}, []
    for a in args:
        if a.startswith('--') and '=' in a:
            k, v = a[2:].split('=', 1)
            opts[k] = v
        else:
            rest.append(a)
    return opts, rest

def wrap(text, width, indent):
    if not text:
        return []
    out = []
    for paragraph in text.split('\n'):
        if not paragraph.strip():
            out.append('')
            continue
        line = ''
        for word in paragraph.split():
            if line and len(line) + 1 + len(word) > width:
                out.append(indent + line)
                line = word
            else:
                line = (line + ' ' + word).strip()
        if line:
            out.append(indent + line)
    return out

def showEntry(row):
    print('%s   [%s%s]  %s%s' % (
        row['mnemonic'], row['kind'],
        '/' + row['processor'] if row['processor'] else '',
        row['confidence'] or '',
        '   encoding: ' + row['uncertainty'] if row['uncertainty'] else ''))
    for label in ('encoding', 'description', 'evidence', 'poo'):
        if row[label]:
            print('  %-12s' % (label + ':'), end='')
            lines = wrap(row[label], 62, ' ' * 14)
            print(lines[0].strip() if lines else '')
            for extra in lines[1:]:
                print(extra)
    print('  %-12s%s' % ('updated:', row['updated'] or ''))
    print()

def main():
    opts, rest = parseOptions(sys.argv[1:])
    command = rest[0] if rest else None
    db = connect()

    if command == 'list':
        where, params = [], []
        for k in ('kind', 'processor'):
            if k in opts:
                where.append('%s = ?' % k); params.append(opts[k])
        sql = 'SELECT * FROM entries'
        if where: sql += ' WHERE ' + ' AND '.join(where)
        rows = db.execute(sql + ' ORDER BY kind, mnemonic', params).fetchall()
        for r in rows:
            print('  %-10s %-12s %-6s %-11s %-10s %s' % (
                r['mnemonic'], r['kind'], r['processor'] or '',
                r['confidence'] or '', r['uncertainty'] or '',
                (r['description'] or '').split('\n')[0][:34]))
        print('\n  %d entries' % len(rows))

    elif command == 'show':
        for m in rest[1:]:
            row = db.execute('SELECT * FROM entries WHERE mnemonic = ?', (m,)).fetchone()
            if row: showEntry(row)
            else: print('%s: not recorded\n' % m)

    elif command == 'search':
        text = '%' + ' '.join(rest[1:]) + '%'
        rows = db.execute(
            'SELECT * FROM entries WHERE mnemonic LIKE ? OR description LIKE ?'
            ' OR evidence LIKE ? OR encoding LIKE ? ORDER BY mnemonic',
            (text, text, text, text)).fetchall()
        for r in rows: showEntry(r)
        print('  %d matches' % len(rows))

    elif command == 'add':
        if 'mnemonic' not in opts or 'kind' not in opts:
            print('add needs at least --mnemonic= and --kind='); return 1
        cols = [f for f in FIELDS if f in opts]
        db.execute('INSERT INTO entries (%s, updated) VALUES (%s, ?)' % (
            ', '.join(cols), ', '.join('?' * len(cols))),
            [opts[c] for c in cols] + [today()])
        db.commit()
        print('added %s' % opts['mnemonic'])

    elif command == 'set':
        if len(rest) < 2:
            print('set needs a mnemonic'); return 1
        m = rest[1]
        cols = [f for f in FIELDS if f in opts]
        if not cols:
            print('nothing to set'); return 1
        db.execute('UPDATE entries SET %s, updated = ? WHERE mnemonic = ?' % (
            ', '.join('%s = ?' % c for c in cols)),
            [opts[c] for c in cols] + [today(), m])
        db.commit()
        print('updated %s' % m)

    elif command == 'render':
        rows = db.execute('SELECT * FROM entries ORDER BY kind, processor, mnemonic').fetchall()
        print('# AP-101S assembly language: notes on the undocumented parts')
        print()
        print('Generated from `ASM101S/ap101s-notes.db` by `ap101s-notes.py'
              ' render`.  Do not edit this file; edit the database.')
        print()
        print('The POO -- *Shuttle GPC Software Model AP-101S* -- is the'
              ' authority on the instruction set.  What follows is what it'
              ' does not say, or does not say findably.  Every entry records'
              ' how it was established, because an encoding without its'
              ' reasoning has to be re-derived before it can be trusted.')
        print()
        kind = None
        for r in rows:
            if r['kind'] != kind:
                kind = r['kind']
                print('\n## %s\n' % kind.capitalize())
            print('### `%s`' % r['mnemonic'])
            print()
            bits = []
            if r['processor']: bits.append('**Processor:** %s' % r['processor'])
            if r['confidence']: bits.append('**Confidence:** %s' % r['confidence'])
            if r['uncertainty']:
                bits.append('**Encoding certainty:** %s' % r['uncertainty'])
            if r['poo']: bits.append('**POO:** %s' % r['poo'])
            if bits: print('  \n'.join(bits)); print()
            for label, title in (('description', 'What it does'),
                                 ('encoding', 'Encoding'),
                                 ('evidence', 'How this was established')):
                if r[label]:
                    print('**%s.** %s' % (title, r[label]))
                    print()
        print('\n---\n%d entries.' % len(rows))

    else:
        print(__doc__)
        return 1
    return 0

if __name__ == '__main__':
    sys.exit(main())
