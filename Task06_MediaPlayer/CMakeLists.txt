cmake_minimum_required(VERSION 3.16)

project(Task06_MediaPlayer VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS Quick DBus Concurrent)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appTask06_MediaPlayer
    main.cpp
    Backend/BluetoothManager.cpp
    Backend/USBManager.cpp
)

qt_add_qml_module(appTask06_MediaPlayer
    URI Task06_MediaPlayer
    VERSION 1.0
    QML_FILES
        Main.qml
        components/MediaCard.qml
        components/WindowBar.qml
        components/WindowResize.qml
        pages/Radio.qml
        pages/Audio.qml
        pages/Video.qml
    RESOURCES
        resources.qrc
)

set_target_properties(appTask06_MediaPlayer PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appTask06_MediaPlayer
    PRIVATE Qt6::Quick
    PRIVATE Qt6::DBus
    PRIVATE Qt6::Concurrent
)

include(GNUInstallDirs)
install(TARGETS appTask06_MediaPlayer
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
