import QtQuick 2.5
import QtQuick.Controls 2.14
import QtLocation 5.14

Page {
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

    Rectangle {
        anchors.fill: parent
        color: "red"
    }
}

