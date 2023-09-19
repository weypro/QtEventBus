
# Make an explicit list of all source files in `QtEventBus_SRC`. This is important
# because CMake is not a build system: it is a build system generator. Suppose
# you add a file foo.cpp to src/ after running cmake .. . If you set
# `QtEventBus_SRC` with `file(GLOB ... )`, this is not passed to the makefile;
# the makefile doesn't know that foo.cpp exists and will not re-run cmake. Your
# collaborator's builds will fail and it will be unclear why. Whether you use
# file(GLOB ...) or not, you will need to re-run cmake, but with an explicit
# file list, you know beforehand why your code isn't compiling. 
set(QtEventBus_SRC
        source_file.cpp
        qeventbus.cpp
        qeventbusqml.cpp
        qmessage.cpp
        qproperty.cpp
        qsubscriber.cpp
)

# Form the full path to the source files...
PREPEND(QtEventBus_SRC)
# ... and pass the variable to the parent scope.
set(QtEventBus_SRC ${QtEventBus_SRC} PARENT_SCOPE)
