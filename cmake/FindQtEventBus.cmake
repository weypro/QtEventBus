# - Try to find the QtEventBus library
# Once done this will define
#
#  QtEventBus_FOUND - system has QtEventBus
#  QtEventBus_INCLUDE_DIR - QtEventBus include directory
#  QtEventBus_LIB - QtEventBus library directory
#  QtEventBus_LIBRARIES - QtEventBus libraries to link

if(QtEventBus_FOUND)
    return()
endif()

# We prioritize libraries installed in /usr/local with the prefix .../QtEventBus-*, 
# so we make a list of them here
file(GLOB lib_glob "/usr/local/lib/QtEventBus-*")
file(GLOB inc_glob "/usr/local/include/QtEventBus-*")

# Find the library with the name "QtEventBus" on the system. Store the final path
# in the variable QtEventBus_LIB
find_library(QtEventBus_LIB 
    # The library is named "QtEventBus", but can have various library forms, like
    # libQtEventBus.a, libQtEventBus.so, libQtEventBus.so.1.x, etc. This should
    # search for any of these.
    NAMES QtEventBus
    # Provide a list of places to look based on prior knowledge about the system.
    # We want the user to override /usr/local with environment variables, so
    # this is included here.
    HINTS
        ${QtEventBus_DIR}
        ${CMAKEDEMO_DIR}
        $ENV{QtEventBus_DIR}
        $ENV{CMAKEDEMO_DIR}
        ENV CMAKEDEMO_DIR
    # Provide a list of places to look as defaults. /usr/local shows up because
    # that's the default install location for most libs. The globbed paths also
    # are placed here as well.
    PATHS
        /usr
        /usr/local
        /usr/local/lib
        ${lib_glob}
    # Constrain the end of the full path to the detected library, not including
    # the name of library itself.
    PATH_SUFFIXES 
        lib
)

# Find the path to the file "source_file.hpp" on the system. Store the final
# path in the variables QtEventBus_INCLUDE_DIR. The HINTS, PATHS, and
# PATH_SUFFIXES, arguments have the same meaning as in find_library().
find_path(QtEventBus_INCLUDE_DIR source_file.hpp
    HINTS
        ${QtEventBus_DIR}
        ${CMAKEDEMO_DIR}
        $ENV{QtEventBus_DIR}
        $ENV{CMAKEDEMO_DIR}
        ENV CMAKEDEMO_DIR
    PATHS
        /usr
        /usr/local
        /usr/local/include
        ${inc_glob}
    PATH_SUFFIXES 
        include
)


# Check that both the paths to the include and library directory were found.
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(QtEventBus
    "\nQtEventBus not found --- You can download it using:\n\tgit clone 
    https://github.com/mmorse1217/cmake-project-template\n and setting the CMAKEDEMO_DIR environment variable accordingly"
    QtEventBus_LIB QtEventBus_INCLUDE_DIR)

# These variables don't show up in the GUI version of CMake. Not required but
# people seem to do this...
mark_as_advanced(QtEventBus_INCLUDE_DIR QtEventBus_LIB)

# Finish defining the variables specified above. Variables names here follow
# CMake convention.
set(QtEventBus_INCLUDE_DIRS ${QtEventBus_INCLUDE_DIR})
set(QtEventBus_LIBRARIES ${QtEventBus_LIB})

# If the above CMake code was successful and we found the library, and there is
# no target defined, lets make one.
if(QtEventBus_FOUND AND NOT TARGET QtEventBus::QtEventBus)
    add_library(QtEventBus::QtEventBus UNKNOWN IMPORTED)
    # Set location of interface include directory, i.e., the directory
    # containing the header files for the installed library
    set_target_properties(QtEventBus::QtEventBus PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${QtEventBus_INCLUDE_DIRS}"
        )

    # Set location of the installed library
    set_target_properties(QtEventBus::QtEventBus PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
        IMPORTED_LOCATION "${\QtEventBus_LIBRARIES}"
        )
endif()
