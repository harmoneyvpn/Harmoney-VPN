cmake_minimum_required(VERSION 3.14)
project(harmoney_per_app_relay LANGUAGES CXX)

if(NOT WIN32)
  message(FATAL_ERROR "Harmoney per-app relay is Windows-only")
endif()

add_executable(harmoney-per-app-relay per_app_relay.cpp)
target_compile_features(harmoney-per-app-relay PRIVATE cxx_std_17)
target_compile_definitions(harmoney-per-app-relay PRIVATE UNICODE _UNICODE WIN32_LEAN_AND_MEAN)
target_link_libraries(harmoney-per-app-relay PRIVATE ws2_32)
if(MSVC)
  target_compile_options(harmoney-per-app-relay PRIVATE /W4 /WX /guard:cf)
endif()
