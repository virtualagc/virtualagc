cmake_minimum_required(VERSION 3.27...4.2)
project(virtualAGC
LANGUAGES C CXX
HOMEPAGE_URL "https://github.com/virtualagc/virtualagc")

enable_testing()

set(CMAKE_EXPORT_COMPILE_COMMANDS on)

if(MSVC)
  set(NVER "2020-12-24")
else()
  set(NVER \\\"2020-12-24\\\")
endif()

set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 17)
# this avoids issues with compilers defaulting to newer standards with stricter rules

include(CheckSymbolExists)

if(MSVC)
  add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
endif()

find_package(Threads)

find_package(Curses)
if(WIN32 AND CURSES_FOUND AND NOT CURSES_LIBRARIES MATCHES "ncursesw")
  cmake_path(GET CURSES_INCLUDE_DIRS PARENT_PATH _curses_dir)
  find_library(_ncurses_win NAMES ncursesw cursesw HINT ${_curses_dir})
  if(_ncurses_win)
    list(PREPEND CURSES_LIBRARIES ${_ncurses_win})
    message(STATUS "CURSES_LIBRARIES: ${CURSES_LIBRARIES}")
  endif()
endif()

find_package(wxWidgets COMPONENTS gl core base)

if(WIN32)
  set(WINSOCK_LIBRARIES wsock32 ws2_32 Iphlpapi winmm)
endif()

add_subdirectory(Tools)
add_subdirectory(Luminary099)
add_subdirectory(enet)

add_subdirectory(yaASM)
add_subdirectory(yaLEMAP)
add_subdirectory(yaLVDC)

if(NOT MSVC)
  add_subdirectory(yaYUL)
endif()

add_subdirectory(yaAGC)
add_subdirectory(yaUniverse)

if(Threads_FOUND AND CMAKE_USE_PTHREADS_INIT)
  add_subdirectory(yaAGS)
  add_subdirectory(yaOBC)
endif()

if(CURSES_FOUND)
  add_subdirectory(yaUplinkBlock1)
endif()

if(wxWidgets_FOUND)
  add_subdirectory(yaPanel)
  add_subdirectory(yaDSKY2)
  add_subdirectory(yaTelemetry)
  add_subdirectory(jWiz)
endif()


if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  if(WIN32)
    set(HOME $ENV{USERPROFILE})
  else()
    set(HOME $ENV{HOME})
  endif()

  set(CMAKE_INSTALL_PREFIX "${HOME}/VirtualAGC" CACHE PATH "install prefix" FORCE)
endif()

if(NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  file(GENERATE OUTPUT .gitignore CONTENT "*")
endif()
