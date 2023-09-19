cmake_minimum_required(VERSION 3.14)

project(QtEventBus LANGUAGES CXX)

option(ENABLE_LIBCXX "Enable build with libc++" OFF)

# Read the version information from the VERSION file
file(STRINGS "${PROJECT_SOURCE_DIR}/VERSION" PACKAGE_VERSION)
string(REGEX REPLACE "([0-9]+)\\.[0-9]+\\.[0-9]+.*" "\\1" CPACK_PACKAGE_VERSION_MAJOR ${PACKAGE_VERSION})
string(REGEX REPLACE "[0-9]+\\.([0-9]+)\\.[0-9]+.*" "\\1" CPACK_PACKAGE_VERSION_MINOR ${PACKAGE_VERSION})
string(REGEX REPLACE "[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" CPACK_PACKAGE_VERSION_PATCH ${PACKAGE_VERSION})

set(PROJECT_VERSION ${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH})

# Put the libaries and binaries that get built into directories at the
# top of the build tree rather than in hard-to-find leaf
# directories. This simplifies manual testing and the use of the build
# tree rather than installed Boost libraries.
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
# Windows DLLs are "runtime" for CMake. Output them to "bin" like the Visual Studio projects do.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Reset output dirs for multi-config builds
foreach (OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES})
    string(TOUPPER ${OUTPUTCONFIG} OUTPUTCONFIG)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/bin)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/lib)
endforeach (OUTPUTCONFIG)

# Append our module directory to CMake
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)


set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Quick)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Quick)

add_subdirectory(3rdparty/qtpromise)


# Function to prepend the subdirectory to source files in subdirectories
FUNCTION(PREPEND var)
    SET(listVar "")
    FOREACH (f ${${var}})
        LIST(APPEND listVar "${CMAKE_CURRENT_SOURCE_DIR}/${f}")
    ENDFOREACH (f)
    SET(${var} "${listVar}" PARENT_SCOPE)
ENDFUNCTION(PREPEND)

include(GNUInstallDirs)

set(INCLUDES "${CMAKE_CURRENT_SOURCE_DIR}/include")
set(EXPORT_NAMESPACE "${PROJECT_NAME}::")


add_subdirectory(src)

set(QtEventBus_INC
        include/source_file.hpp
        include/qeventbus.h
        include/qeventbusqml.h
        include/qeventqueue.h
        include/qmessage.h
        include/qmessageresult.h
        include/qproperty.h
        include/qsubscriber.h
        include/QtEventBus_global.h
)


#if (BUILD_TESTING)
    add_subdirectory(tests)
#endif ()


add_library(QtEventBus STATIC ${QtEventBus_SRC} ${QtEventBus_INC})

target_link_libraries(QtEventBus PRIVATE
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Quick
        qtpromise
)

# These variables slightly modify the install location to allow for version
# specific installations.
#set(QtEventBus_INCLUDE_DEST "include/QtEventBus-${QtEventBus_VERSION}")
#set(QtEventBus_LIB_DEST "lib/QtEventBus-${QtEventBus_VERSION}")


# generator expressions are needed for the include directories, since installing headers changes the include path
# Specify that QtEventBus requires the files located in the include/ directory at
# compile time. This would normally look like
#   target_include_directories(QtEventBus PUBLIC include/)
# PUBLIC means that other libraries including QtEventBus should also include the
# directory include/.
# However, there is a catch. If we are installing the project in
# CMAKE_INSTALL_PREFIX, we can't specify include/ in the build directory: we have
# copied the contents of include to CMAKE_INSTALL_PREFIX/include and we would
# like  other projects to include this directory instead of include/. The follow
# CMake command handles this. $<BUILD_INTERFACE:...> and
# $<INSTALL_INTERFACE:...> are macros whose values change depending on if we are
# simply building the code or if we are installing it.
target_include_directories(QtEventBus PUBLIC
        # headers to include when building from source
        $<BUILD_INTERFACE:${QtEventBus_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${QtEventBus_BINARY_DIR}/include>

        # headers to include when installing  (implicitly prefixes with ${CMAKE_INSTALL_PREFIX}).
        $<INSTALL_INTERFACE:include>
)
target_include_directories(QtEventBus INTERFACE
        3rdparty/qtpromise/include
)


#############################################################
# cmake config files

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}ConfigVersion.cmake"
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY AnyNewerVersion
)

# Set config script install location in a location that find_package() will
# look for, which is different on MS Windows than for UNIX
# Note: also set in POCO_GENERATE_PACKAGE macro in cmake/PocoMacros.cmake
if (WIN32)
    set(PocoConfigPackageLocation "cmake")
else ()
    set(PocoConfigPackageLocation "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
endif ()

configure_file(cmake/${PROJECT_NAME}Config.cmake.in "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}Config.cmake" @ONLY)
install(
        FILES
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}Config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}ConfigVersion.cmake
        DESTINATION
        "${PocoConfigPackageLocation}"
        COMPONENT
        Devel
)


message(STATUS "CMake ${CMAKE_VERSION} successfully configured ${PROJECT_NAME} using ${CMAKE_GENERATOR} generator")
message(STATUS "${PROJECT_NAME} package version: ${PROJECT_VERSION}")
if (BUILD_SHARED_LIBS)
    message(STATUS "Building dynamic libraries")
else ()
    message(STATUS "Building static libraries")
endif ()
message(STATUS "[cmake] Installation target path: ${CMAKE_INSTALL_PREFIX}")
if (CMAKE_TOOLCHAIN_FILE)
    message(STATUS "[cmake] Use toolchain file:		${CMAKE_TOOLCHAIN_FILE}")
endif ()
message(STATUS "[cmake] Build for OS type:      ${CMAKE_SYSTEM_NAME}")
message(STATUS "[cmake] Build for OS version:   ${CMAKE_SYSTEM_VERSION}")
message(STATUS "[cmake] Build for CPU type:     ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "[cmake] Build type:             ${CMAKE_BUILD_TYPE}")
string(TOUPPER "${CMAKE_BUILD_TYPE}" BUILD_TYPE)
message(STATUS "[cmake] Build with cxx flags:   ${CMAKE_CXX_FLAGS_${BUILD_TYPE}} ${CMAKE_CXX_FLAGS}")
message(STATUS "[cmake] Build with c flags:     ${CMAKE_C_FLAGS_${BUILD_TYPE}} ${CMAKE_C_FLAGS}")

foreach (component ${Poco_COMPONENTS})
    message(STATUS "Building: ${component}")
endforeach ()
