import sqlite3, os, sys, pathlib, importlib.util, datetime
spec=importlib.util.spec_from_file_location("dfgmap", os.path.expanduser("~/git/virtualagc/modules/sdfpkg/dfgmap.py"))
m=importlib.util.module_from_spec(spec)
sys.argv=["dfgmap"]
src=open(spec.origin).read().split("def main()")[0]
exec(src, m.__dict__)

DB=os.path.expanduser("~/git/virtualagc/modules/sdfpkg/dass-compare.db")
HAL=os.path.expanduser("~/ipl-demo/dfg2/hal")
CLC=os.path.expanduser("~/ForClaude/OI340600-clc")
c=sqlite3.connect(DB); c.row_factory=sqlite3.Row
rows=c.execute("""select r.config, s.stem, sec.name, sec.address, sec.halfwords,
    sec.expected, sec.n_diffs from section sec
  join run r on r.id=sec.run_id join source s on s.id=r.source_id
  where s.ext='dfg' and sec.verdict!='ok'
  order by r.config, s.stem""").fetchall()

def grid_lines(g):
    out=["     "+"".join(str(((i+1)//10)%10) if (i+1)>=10 else " " for i in range(m.SCREEN_COLS)),
         "     "+"".join(str((i+1)%10) for i in range(m.SCREEN_COLS)),
         "    +"+"-"*m.SCREEN_COLS+"+"]
    for i,row in enumerate(g,1): out.append(f" {i:2d} |"+"".join(row)+"|")
    out.append("    +"+"-"*m.SCREEN_COLS+"+")
    return out

def hwimg(p): return m.hw_image(p)

out=[]
out.append("Display decompilations: the 15 .dfg sections that differ from the DASS dump")
out.append("="*78)
out.append("")
out.append("Generated %s by modules/sdfpkg/dfgmap.py." % datetime.date.today().isoformat())
out.append("")
out.append("For each differing section: the display as OUR OI340600 source defines it,")
out.append("and the display as the dumped build actually holds it, both laid out on the")
out.append("DEU's 51x26 character screen.")
out.append("")
out.append("WHAT IS AND IS NOT HERE.  Only static text is drawn.  Fields written at run")
out.append("time from variables -- CHARR, SBC, VPARM -- are blank, so a display whose")
out.append("content is mostly dynamic looks emptier here than on the flight deck.  None")
out.append("of these 13 decks has an X background twin, and that is not an omission:")
out.append("X decks exist only in the XD and XG families, in both OI340600 and OI301700,")
out.append("so the S and V families never used the background/foreground split at all.")
out.append("")
out.append("The dump side is rendered by decoding cursor FCWs out of the memory image,")
out.append("with no source of any kind.  Where our section and the dump differ in size,")
out.append("both are drawn in full rather than only their overlap.")
out.append("")
out.append("CHARACTERS ARE THE REAL DEU SET, all 128 codes from USA-003090 p.104 --")
out.append("not ASCII.  0x22 is a tilde, 0x24 a radical, 0x40 gamma, 0x5C theta, 0x5E pi,")
out.append("0x7B/0x7E/0x7F sigma/lambda/delta.  Deck statement text uses ASCII stand-ins")
out.append("for several of these, so a rendering can legitimately differ from the text of")
out.append("the statement that produced it.")
out.append("")
out.append("THE DUMP IS SHOWN BOUNDED, and that is LOSSY.  Only [background, DDT) from")
out.append("the DFT header is drawn.  Decoding the whole section instead shows more text")
out.append("but buries it in the DDT and the item and limits tables, which have no")
out.append("annotations to mark them as anything else; the two were shown side by side")
out.append("here and were too confusing to read.")
out.append("")
out.append("MEASURED on the 126 sections that match the dump byte for byte, where every")
out.append("rendering difference is therefore pure artifact:")
out.append("")
out.append("    whole section   identical  25/126   cells lost   173   invented 6909")
out.append("    bounded         identical  30/126   cells lost  1290   invented  353")
out.append("")
out.append("So a blank region below is not evidence of absence: CS2110 keeps only 35 of")
out.append("its 144 halfwords here and its five data-entry fields vanish, and CG0500 --")
out.append("not one of these, but the worst case in the corpus -- bounds to nothing at")
out.append("all against 79 cells of real text.  The line of characters printed under")
out.append("each display is decoded from the WHOLE section and drops nothing, so what")
out.append("the bounded picture omits can always be read there.")
out.append("")
out.append("SOME STRAY CHARACTERS REMAIN ON THE DUMP SIDE.  Our side is drawn from DFG's")
out.append("annotations, so only halfwords belonging to a text statement are painted.  The")
out.append("dump has no annotations, so its whole section goes through the decoder and")
out.append("table data -- the DDT, the item and limits tables -- sometimes decodes as")
out.append("characters.  Halfwords our own parse knows to be relocated addresses are")
out.append("blanked, which removes most of it; bounding the render by the DFT header")
out.append("would remove the rest but also removes real text, since CS0620's ORB C&W ISS")
out.append("lies beyond the DDT displacement, so the full section is drawn.")
out.append("")
out.append("WHAT THE RENDERINGS SHOW, in one table.  Four of the fifteen are not")
out.append("revisions of the same display at all -- the slot holds a DIFFERENT display,")
out.append("and in every case ours is Spacelab/IUS/TDRS-era and the dump's is ISS-era:")
out.append("")
out.append("    CS2000   ours IUS                 dump APCU STATUS")
out.append("    CS2050   ours TDRS                dump ISS MCS MODING")
out.append("    CS2110   ours S/L DPA PERIPHERAL  dump ISS C&W")
out.append("    CS2120   ours S/L LINK MGMT       dump OIU")
out.append("")
out.append("Those four are also four of the five sections whose sizes disagree, which is")
out.append("why the sizes disagree by so much and in both directions.")
out.append("")
out.append("SHARING A TITLE DOES NOT MEAN A SMALL REVISION.  These are mission-dependent")
out.append("displays: the payloads and experiments differ between missions, so there is no")
out.append("reason for a redefinition to be incremental, and mostly it is not.  Comparing")
out.append("the two rendered screens cell by cell, as a percentage of the non-blank cells")
out.append("they occupy between them:")
out.append("")
out.append("    CS2110   0%    CS2120   0%    CS2050  0.2%   CS2000  0.8%")
out.append("    CS0780  40%    CS0620  52% (G9) 68% (S2)     CS0790  58%")
out.append("    CS2021  68%    CV1000  67% (G9) 98% (P9)     CS0940  74%")
out.append("    CS2011  79%    CV1130  97%")
out.append("")
out.append("So SM SYS SUMM 1 shares only two fifths of its characters with the dumped")
out.append("version, which has 416 characters to our 215.  Only CV1130 and CV1000-in-P9")
out.append("are near-identical.  CV1000 is worth noting on its own: our side is the same")
out.append("deck in both configurations, but G9's dump holds 490 characters of it and")
out.append("P9's 352, so the dumped build carries two different builds of that display.")
out.append("")
out.append("CDAP15 renders empty on our side because it is not a display at all -- it is")
out.append("an AMT moding table, the one deck here with a PMF= card -- so its 0% is not")
out.append("comparable with the others.")
out.append("")
seen=set()
for r in rows:
    key=(r['config'], r['stem'])
    out.append("")
    out.append("-"*78)
    out.append(f"{r['stem']}   configuration {r['config']}   section {r['name']} @ {r['address']:X}")
    dn = r['expected'] if r['expected'] is not None else r['halfwords']
    same = "" if r['expected'] is None else "   (SIZE MISMATCH)"
    out.append(f"   ours {r['halfwords']} halfwords, dump {dn} halfwords, "
               f"{r['n_diffs']} differing{same}")
    out.append("-"*78)
    hal=os.path.join(HAL, r['stem']+".hal")
    amt=m.amt_of(hal) if os.path.exists(hal) else None
    if amt:
        out.append("")
        out.append(f"  NOT A DISPLAY.  This deck is the moding table {amt} -- a")
        out.append("  PMF=/AMTx= deck telling FCOS which memory configuration a SPEC is")
        out.append("  valid in.  It carries no CHAR, XC or YC statement, so there is no")
        out.append("  screen to draw on either side; rendering one decodes table entries")
        out.append("  as text and produces nonsense.  The halfword differences above are")
        out.append("  real, they are simply differences in a table rather than a picture.")
        continue
    out.append("")
    out.append("  AS OUR OI340600 SOURCE DEFINES IT")
    if os.path.exists(hal):
        g=m.render_annotated(m.parse(hal))
        out += ["  "+l for l in grid_lines(g)]
    else:
        out.append("    (no generated .hal)")
    img=os.path.join(CLC, f"{r['config']}.literals.fcm")
    out.append("")
    out.append("  AS THE DUMPED BUILD HOLDS IT")
    if os.path.exists(img):
        d=hwimg(img); n=r['expected'] or r['halfwords']
        w=list(d[r['address']:r['address']+n])
        # Blank the halfwords our own parse knows to be relocated addresses:
        # they are linker output, they legitimately differ between
        # configurations, and decoded as text they paint junk over the screen.
        # ONLY when the two sections are the same length.  The mask is by
        # offset, so on a size-mismatched section it would blank whatever
        # happens to sit at our address offsets -- arbitrary halfwords of a
        # different display, which is worse than the noise it removes.
        if os.path.exists(hal):
            ours=[x[1] for x in m.parse(hal)]
            if len(ours)==len(w):
                for i in range(len(ours)):
                    if ours[i] is None: w[i]=None
            else:
                out.append("  (address slots not blanked: the sections differ "
                           "in size, so our offsets do not correspond)")
        b=m.display_list([x for x in w])
        if len(b)!=len(w):
            out.append(f"  bounded to [background, DDT), {len(b)} of "
                       f"{len(w)} halfwords")
        else:
            out.append("  the DFT header delimits no smaller region, so this "
                       "is the whole section")
        out += ["  "+l for l in grid_lines(m.render(b))]
        out.append("")
        out.append("  characters in the dumped section, in order:")
        out.append("    "+m.decode_text(w))
    else:
        out.append("    (no memory image for this configuration)")
dst=os.path.expanduser("~/ipl-demo/dfg2/differing-displays.txt")
open(dst,"w",encoding="utf-8").write("\n".join(out)+"\n")
print(f"wrote {dst}: {len(rows)} sections, {len(out)} lines")
