add_executable(yaUniverse yaUniverse.c FetchEphemerisPlanet.c TimeStep.c)
target_compile_definitions(yaUniverse PRIVATE NVER="${NVER}")
target_link_libraries(yaUniverse PRIVATE libyaAGC m)

add_test(NAME yaUniverse
COMMAND $<TARGET_FILE:yaUniverse> --ephem-read --mission=Test
WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

install(TARGETS yaUniverse)
