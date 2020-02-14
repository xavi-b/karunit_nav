import QtQuick 2.5
import QtQuick.Controls 2.14
import QtLocation 5.14

Page {
    property var position;

    onPositionChanged: {
        //TODO
    }

    header: ToolBar {
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            text: "\u2630"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                drawer.width = mainItem.width * 0.33;
                drawer.height = mainItem.height;
                drawer.open();
            }
        }

        TextInput {
            id: searchTextInput
            anchors.left: toolButton.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            verticalAlignment: Qt.AlignVCenter

            Text {
                id: searchPlaceHolderText
                anchors.fill: parent
                verticalAlignment: Qt.AlignVCenter

                text: qsTr("Search for an address...")
                color: "#aaa"
                visible: !searchTextInput.text
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottomMargin: 5

                height: 1
                color: searchPlaceHolderText.color
            }
        }
    }

    Drawer {
        id: drawer

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: qsTr("Page 1")
                width: parent.width
                onClicked: {
                    drawer.close();
                }
            }
            ItemDelegate {
                text: qsTr("Page 2")
                width: parent.width
                onClicked: {
                    drawer.close();
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

    RoundButton {
        id: compassButton
        width: 40
        height: 40
        anchors.right: parent.right
        anchors.bottom: centerOnPositionButton.top
        anchors.rightMargin: 20
        anchors.bottomMargin: 20

        text: "C"
        font.pixelSize: Qt.application.font.pixelSize * 1.6
        onClicked: {
            //TODO
        }
    }

    RoundButton {
        id: centerOnPositionButton
        width: 40
        height: 40
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 20
        anchors.bottomMargin: 20

        text: "X"
        font.pixelSize: Qt.application.font.pixelSize * 1.6
        onClicked: {
            map.center = position;
        }
    }
}