#!/usr/bin/awk
# First, you need to dump a TIM file (or sequence of TIM files) from gtkwave.
# cat them into to this script on stdin, and just the instructions come out
# on stdout.  Use like so:
#	cat LIST OF TIM FILES ... | awk -f extractInstructionsFromTIM.awk [noRupts=1] [ruptsOnly=1] >INSTRUCTIONS.txt

BEGIN { 
  inInst = 0 
  ruptsOnly = 0
  noRupts = 0
  inRupt = 0
  print ARGV[1]
  if (ARGC > 1 && ARGV[1] == "ruptsOnly=1")
  	ruptsOnly = 1
  else if (ARGC > 1 && ARGV[1] == "noRupts=1")
  	noRupts = 1
} 

{ 
  if ($1 == "Name:") 
    inInst = ($2 == "Instruction")
  else if (inInst && $1 == "Edge:" && $3 != "") {
    if ($3 == "RUPT")
    	inRupt = 1
    PINC = ($3 == "PINC" || $3 == "MINC" || $3 == "DINC" || $3 == "PCDU" || $3 == "MCDU" || $3 == "SHINC" || $3 == "SHANC" || $3 == "GOJAM")
    if (!((noRupts && (inRupt || PINC )) || (ruptsOnly && !inRupt && !PINC)))
    	print $3, $4 
    if ($3 == "RESUME")
    	inRupt = 0
  }
  
}
