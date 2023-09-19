cmake_minimum_required(VERSION 3.1)
set(CMAKE_CXX_STANDARD 17)

# Explicitly list the test source code and headers. The Catch header-only unit
# test framework is stored in with the test source.
set(QtEventBus_TEST_SRC
#    test_cmake_demo.cpp
        main.cpp
        qtestmessage.h
        sample.cpp
)

PREPEND(QtEventBus_TEST_SRC)

# Make an executable target that depends on the test source code we specified
# above.
add_executable(TestQtEventBus ${QtEventBus_TEST_SRC})

# Enable testing via CTest
#enable_testing()
## Add our test as runnable via CTest
#add_test(NAME TestQtEventBus  COMMAND TestQtEventBus)

# Link our unit tests against the library we compiled
target_link_libraries(TestQtEventBus QtEventBus
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Quick
)
