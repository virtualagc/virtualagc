cmake_minimum_required(VERSION 3.12)
project(virtualYUL LANGUAGES C)

set(CFILES GetOctOrDec.c ParseBBCON.c ParseEQUALS.c ParseINDEX.c ParseXCADR.c yaYUL.c
IncPc.c ParseBLOCK.c ParseERASE.c ParseInterpretiveOperand.c Pass.c yul2agc.c
Parse2CADR.c ParseCADR.c ParseEqMinus.c ParseOCT.c PseudoToSegmented.c
Parse2DEC.c ParseCHECKequals.c ParseEqualsECADR.c ParseSBANKEquals.c SymbolPass.c
Parse2FCADR.c ParseEBANKEquals.c ParseGENADR.c ParseSETLOC.c SymbolTable.c
ParseBANK.c ParseECADR.c ParseGeneral.c ParseST.c Utilities.c)

add_compile_options(-Wall)

# deferring cross-compile for now

add_executable(yaYUL ${CFILES})
target_compile_options(yaYUL PRIVATE ${CFLAGS})
target_link_libraries(yaYUL PRIVATE m)
target_compile_definitions(yaYUL PRIVATE NVER="${NVER}")
