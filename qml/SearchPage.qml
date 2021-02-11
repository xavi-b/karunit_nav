import QtQuick 2.15
import QtLocation 5.15
import QtPositioning 5.15
import QtQuick.FreeVirtualKeyboard 1.0
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.15 as Controls

Kirigami.PageRow {
    id: pageRow

    property alias model: placeSearchModel

    PlaceSearchModel {
        id: placeSearchModel
        plugin: geoPlugin

        relevanceHint: PlaceSearchModel.DistanceHint

        onStatusChanged: {
            switch (status) {
            case PlaceSearchModel.Ready:
                //                poiCurrent.visible = false;
                //                map.fitViewportToVisibleMapItems();
                //                poiCurrent.visible = true;
                break;
            case PlaceSearchModel.Error:
                console.log(errorString());
                break;
            }
        }

    }

    initialPage: Kirigami.ScrollablePage {
        titleDelegate: Kirigami.SearchField {
            id: searchField
            Layout.topMargin: Kirigami.Units.smallSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
            Layout.fillHeight: true
            Layout.fillWidth: true
            onTextChanged: {
                if(searchField.text == "") {
                    placeSearchModel.reset();
                    return;
                }

                placeSearchModel.searchTerm = searchField.text;
                placeSearchModel.searchArea = QtPositioning.circle(positionSource.position.coordinate);
                //placeSearchModel.searchArea = map.visibleArea;
                placeSearchModel.update();
            }
            KeyNavigation.tab: listView
            rightActions: [
                Kirigami.Action {
                    icon.name: "edit-clear"
                    visible: searchField.text !== ""
                    onTriggered: {
                        searchField.text = ""
                        searchField.accepted()
                    }
                }
            ]

        }

        supportsRefreshing: true
        onRefreshingChanged: {
            if (refreshing) {
                myModel.refresh();
            }
        }

        ListView {
            id: addressesListView
            Kirigami.PlaceholderMessage {
                anchors.centerIn: parent
                width: parent.width - (Kirigami.Units.largeSpacing * 4)
                visible: addressesListView.count === 0
                text: "No data found"
                helpfulAction: Kirigami.Action {
                    text: "Load data"
                }
            }

            section {
                property: "sec"
                delegate: Kirigami.ListSectionHeader {
                    text: "Section " + (parseInt(section) + 1)
                }
            }

            delegate: Kirigami.SwipeListItem {
                id: listItem
                contentItem: RowLayout {
                    Controls.Label {
                        Layout.fillWidth: true
                        height: Math.max(implicitHeight, Kirigami.Units.iconSizes.smallMedium)
                        text: title + "<br>" + place.location.address.text
                        color: listItem.checked || (listItem.pressed && !listItem.checked && !listItem.sectionDelegate) ? listItem.activeTextColor : listItem.textColor
                    }

                    Controls.Label {
                        Layout.fillWidth: true
                        height: Math.max(implicitHeight, Kirigami.Units.iconSizes.smallMedium)
                        text: "Phone: " + (place.primaryPhone ? place.primaryPhone : "NONE")
                        color: listItem.checked || (listItem.pressed && !listItem.checked && !listItem.sectionDelegate) ? listItem.activeTextColor : listItem.textColor
                    }
                }
                actions: [
                    Kirigami.Action {
                        iconName: "call"
                        id: callButton
                        visible: place.primaryPhone ? true : false
                        //font.family: "Font Awesome 5 Free"
                        text: "\uf192"
                        onTriggered: {
                            if(place.primaryPhone) {
                                call(place.primaryPhone);
                            }
                        }
                    },
                    Kirigami.Action {
                        iconName: "go"
                        id: goButton
                        //font.family: "Font Awesome 5 Free"
                        text: "Go"
                        onTriggered: {
                            //TODO driver.goTo(place.location.coordinate.latitude, place.location.coordinate.longitude);
                        }
                    },
                    Kirigami.Action {
                        iconName: "focus"
                        text: "Action 2"
                        onTriggered: {
                            map.focusOnPlace(place);
                        }
                    }]
            }

            model: placeSearchModel // TODO section + recents + saved
        }
    }
}
