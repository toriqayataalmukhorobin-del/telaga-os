QT += core gui qml quick quickcontrols2

CONFIG += c++17

TARGET = telaga-panel
TEMPLATE = app

SOURCES += \
    src/main.cpp \
    src/appmodel.cpp \
    src/systeminfo.cpp

HEADERS += \
    src/appmodel.h \
    src/systeminfo.h \
    src/themeiconprovider.h

RESOURCES += \
    resources.qrc

# Install rules
target.path = /usr/bin
INSTALLS += target
