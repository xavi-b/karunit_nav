import QtQuick 2.5
import QtQuick.Controls 2.14
import QtLocation 5.14

Page {
    property var position;

    onPositionChanged: {
        map.center = src.position.coordinate;
        poiCurrent.coordinate = src.position.coordinate;
    }

    header: ToolBar {
        contentHeight: goBackButton.implicitHeight

        ToolButton {
            anchors.left: parent.left
            id: goBackButton
            text: "\u25C0"
            visible: mainStackView.depth > 1
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                if (mainStackView.depth > 1) {
                    mainStackView.pop()
                }
            }
        }
    }

    Map {
        id: map
        anchors.fill: parent
        plugin: mapPlugin
        zoomLevel: 20

        Plugin {
            id: mapPlugin
            name: "osm"
        }

        MapQuickItem {
            id: poiCurrent
            sourceItem: Rectangle { width: 14; height: 14; color: "#1e25e4"; border.width: 2; border.color: "white"; smooth: true; radius: 7 }
            opacity: 1.0
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
        }
    }
}
