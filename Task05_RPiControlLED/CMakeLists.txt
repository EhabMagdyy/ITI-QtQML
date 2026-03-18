cmake_minimum_required(VERSION 3.16)

project(Task05_RPiControlLED VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appTask05_RPiControlLED
    main.cpp
    LedControl/led.cpp
    LedControl/led.hpp
)

qt_add_qml_module(appTask05_RPiControlLED
    URI Task05_RPiControlLED
    VERSION 1.0
    QML_FILES
        Main.qml
)

set_target_properties(appTask05_RPiControlLED PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appTask05_RPiControlLED
    PRIVATE Qt6::Quick
    gpiod
)

include(GNUInstallDirs)
install(TARGETS appTask05_RPiControlLED
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
