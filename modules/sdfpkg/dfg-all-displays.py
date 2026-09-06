import os,sys,importlib.util,pathlib,datetime,re
spec=importlib.util.spec_from_file_location("d","/home/rburkey/git/virtualagc/modules/sdfpkg/dfgmap.py")
m=importlib.util.module_from_spec(spec); sys.argv=["x"]
exec(open(spec.origin).read().split("def main()")[0], m.__dict__)
HAL=pathlib.Path.home()/"ipl-demo/dfg2/hal"
def grid_lines(g):
    out=["     "+"".join(str(((i+1)//10)%10) if (i+1)>=10 else " " for i in range(m.SCREEN_COLS)),
         "     "+"".join(str((i+1)%10) for i in range(m.SCREEN_COLS)),
         "    +"+"-"*m.SCREEN_COLS+"+"]
    for i,row in enumerate(g,1): out.append(f" {i:2d} |"+"".join(row)+"|")
    out.append("    +"+"-"*m.SCREEN_COLS+"+")
    return out
def title(g):
    for row in g:
        s="".join(row).strip()
        if s: return s[:44]
    return "(no static text)"
decks=sorted(HAL.glob("*.hal"))
ent=[]
for f in decks:
    amt=m.amt_of(f)
    if amt:
        ent.append((f.stem, None, None, amt)); continue
    tw=m.twin(f)
    grid=m.render_annotated(m.parse(tw)) if tw else None
    grid=m.render_annotated(m.parse(f), grid)
    ent.append((f.stem, tw.stem if tw else None, grid, None))
out=[]
out.append("Every OI340600 display, rendered on the DEU's 51x26 character screen")
out.append("="*76)
out.append("")
out.append(f"Generated {datetime.date.today().isoformat()} by modules/sdfpkg/dfgmap.py from the")
out.append(f".hal DFG produced for each of the {len(decks)} .dfg decks in OI340600.")
out.append("")
out.append("Rendered from DFG's own annotations, which is the accurate route: the")
out.append("statement says XC = 18 outright, and only halfwords belonging to a")
out.append("CHAR/XC/YC/CARRTN statement are drawn, so tables cannot paint noise.  Where a")
out.append("display has an X background twin it is composited underneath, since X holds")
out.append("the fixed labels and item numbers and C paints over it.")
out.append("")
out.append("ONLY STATIC TEXT APPEARS.  Fields filled at run time from variables --")
out.append("CHARR, SBC, VPARM -- are blank here, so a mostly-dynamic display looks")
out.append("emptier than it does on the flight deck.  CD0001 is the extreme case: it has")
out.append("no literal CHAR statement at all, and everything you see under it comes from")
out.append("its background XD0001.")
out.append("")
out.append("INDEX")
out.append("-"*76)
for stem,tw,g,amt in ent:
    what = f"moding table {amt}, not a display" if amt else title(g)
    out.append(f"  {stem:<8} {('over '+tw) if tw else '':<14} {what}")
out.append("")
for stem,tw,g,amt in ent:
    out.append("")
    out.append("="*76)
    out.append(f"{stem}" + (f"   composited over background {tw}" if tw else ""))
    out.append("="*76)
    if amt:
        out.append(f"  Not a display: the moding table {amt}, a PMF=/AMTx= deck")
        out.append("  telling FCOS which memory configuration a SPEC is valid in.  It has")
        out.append("  no CHAR, XC or YC statement, so there is no screen to draw.")
        continue
    out += grid_lines(g)
dst=pathlib.Path.home()/"ipl-demo/dfg2/all-displays.txt"
dst.write_text("\n".join(out)+"\n", encoding="utf-8")
print(f"wrote {dst}: {len(decks)} displays, {len(out)} lines")
