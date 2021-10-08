add_executable(listing2binsource listing2binsource.c utils.c)
add_executable(oct2bin oct2bin.c utils.c)

add_executable(checkdec checkdec.c)
target_link_libraries(checkdec PRIVATE m)

add_executable(bdiffhead bdiffhead.c)
add_executable(webb2burkey-rope webb2burkey-rope.c)
add_executable(split-interp split-interp.c)

set(_targs listing2binsource oct2bin checkdec bdiffhead webb2burkey-rope split-interp)

foreach(t ${_targs})
  target_compile_definitions(${t} PRIVATE NVER="${NVER}" MAIN_PROGRAM)
endforeach()

install(TARGETS ${_targs})
