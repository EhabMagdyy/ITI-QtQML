cmake_minimum_required(VERSION 3.16)

project(Task03_NetworkManager VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS Quick DBus)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appTask03_NetworkManager
    main.cpp
    Backend/NetworkManager.cpp
)

qt_add_qml_module(appTask03_NetworkManager
    URI Task03_NetworkManager
    VERSION 1.0
    QML_FILES
        Main.qml
        Widgets/NetworkCard.qml
        Pages/WiFiPage.qml
        Pages/BluetoothPage.qml
    RESOURCES 
        resources.qrc
)
set_target_properties(appTask03_NetworkManager PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appTask03_NetworkManager
    PRIVATE Qt6::Quick Qt6::DBus
)

include(GNUInstallDirs)
install(TARGETS appTask03_NetworkManager
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
