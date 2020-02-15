import QtQuick 2.5
import QtQuick.Controls 2.14
import QtLocation 5.14
import QtPositioning 5.14

Item {
    id: mainItem

    property var portname: "/dev/pts/2"

    PositionSource {
        id: src
        updateInterval: 500
        active: false
        name: "fake"

        PluginParameter { name: "portname"; value: portname }

        Component.onCompleted: {
            console.log("PositionSource ready");
            src.start();
        }

        onPositionChanged: {
            mainPage.position = src.position.coordinate;
            searchPage.position = src.position.coordinate;
        }

        onSourceErrorChanged: {
            console.log("Error: " + sourceError);
        }

        onUpdateTimeout: {
            console.log("Update timeout");
        }
    }

    MainPage {
        id: mainPage
    }

    SearchPage {
        id: searchPage
    }

    DrivePage {
        id: drivePage
    }

    StackView {
        id: mainStackView
        initialItem: mainPage
        anchors.fill: parent
    }
}
