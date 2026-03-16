cmake_minimum_required(VERSION 3.16)

project(Task04_Weather VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appTask04_Weather
    main.cpp
)

qt_add_qml_module(appTask04_Weather
    URI Task04_Weather
    VERSION 1.0
    QML_FILES
        Main.qml
        Components/WindowBar.qml
        Components/WindowResize.qml
        API/WeatherAPI.qml
    RESOURCES
        resources.qrc
)

set_target_properties(appTask04_Weather PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appTask04_Weather
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appTask04_Weather
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
