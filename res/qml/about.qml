import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

ScrollView {
    contentWidth: width

    Column {
        width: parent.width

        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            leftPadding: 10
            rightPadding: leftPadding
            text: "karunit_nav"
        }

        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            leftPadding: 10
            rightPadding: leftPadding
            text: "<p>xavi-b/karunit_nav</p>" + "LGPL 3.0 License"
        }

        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            leftPadding: 10
            rightPadding: leftPadding
            text: "KDE Kirigami2"
        }

        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            leftPadding: 10
            rightPadding: leftPadding
            text: "LGPL v2.1+"
        }

        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            leftPadding: 10
            rightPadding: leftPadding
            text: "FontAwesome"
        }

        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            leftPadding: 10
            rightPadding: leftPadding
            text: "Icons — CC BY 4.0 License"
        }

        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            leftPadding: 10
            rightPadding: leftPadding
            text: "Automotive Grade Linux - On Demand Navigation"
        }

        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            leftPadding: 10
            rightPadding: leftPadding
            text: "Apache 2.0 License"
        }
    }
}
