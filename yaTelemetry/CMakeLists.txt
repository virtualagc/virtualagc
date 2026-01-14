set(_s ${PROJECT_SOURCE_DIR}/yaAGC)
set(SOURCESc ${_s}/agc_utilities.c ${_s}/DecodeDigitalDownlink.c ${_s}/agc_engine.c ${_s}/Backtrace.c ${_s}/random.c ${_s}/SocketAPI.c)

add_executable(yaTelemetry yaTelemetry.cpp ${SOURCESc})
target_link_libraries(yaTelemetry PRIVATE wxWidgets::wxWidgets ${WINSOCK_LIBRARIES})
