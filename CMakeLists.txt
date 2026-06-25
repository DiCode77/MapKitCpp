cmake_minimum_required(VERSION 3.25)
project(MapKitCpp LANGUAGES CXX OBJCXX)

set(SRC "${CMAKE_CURRENT_SOURCE_DIR}/src")
set(PROJ_LIB_NAME "${PROJECT_NAME}")

file(GLOB_RECURSE SRC_FILES_LIB "${SRC}/*.hpp" "${SRC}/*.h" "${SRC}/*.mm")
file(GLOB_RECURSE PUBLIC_HEADERS "${SRC}/*.hpp")

find_library(APPKIT_FRAMEWORK AppKit REQUIRED)
find_library(MAPKIT_FRAMEWORK MapKit REQUIRED)
find_library(CORE_LOCATION_FRAMEWORK CoreLocation REQUIRED)
find_library(FOUNDATION_FRAMEWORK Foundation REQUIRED)

add_library(${PROJ_LIB_NAME} SHARED ${SRC_FILES_LIB})

target_include_directories(${PROJ_LIB_NAME} PUBLIC ${SRC} ${CMAKE_CURRENT_SOURCE_DIR}/libs/json/include)

target_link_libraries(${PROJ_LIB_NAME} PUBLIC 
                                            ${APPKIT_FRAMEWORK} 
                                            ${MAPKIT_FRAMEWORK} 
                                            ${CORE_LOCATION_FRAMEWORK} 
                                            ${FOUNDATION_FRAMEWORK})

set_target_properties(${PROJ_LIB_NAME} PROPERTIES 
                                                CXX_STANDARD 23 
                                                CXX_STANDARD_REQUIRED ON 
                                                FRAMEWORK TRUE 
                                                FRAMEWORK_VERSION A 
                                                MACOSX_FRAMEWORK_IDENTIFIER com.ua.dicode77.MapKitCpp
                                                PUBLIC_HEADER ${PUBLIC_HEADERS})

source_group("src" FILES ${SRC_FILES_LIB})
