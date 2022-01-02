import QtQuick 2.15
import QtLocation 5.15
import QtPositioning 5.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.15 as Controls
import Qt.labs.settings 1.0

Kirigami.PageRow {
    id: pageRow

    property alias model: placeModel

    PlaceSearchModel {
        id: placeSearchModel
        plugin: geoPlugin

        relevanceHint: PlaceSearchModel.DistanceHint

        onStatusChanged: {
            switch (status) {
            case PlaceSearchModel.Ready:
                console.log("onStatusChanged Ready")
                //poiCurrent.visible = false;
                //map.fitViewportToVisibleMapItems();
                //poiCurrent.visible = true;
                for (var j = 0; j < count; j++) {
                    var place = data(j, "place")
                    placeModel.append({
                                          "title": data(j, "title"),
                                          "place": {
                                              "location": {
                                                  "coordinate": QtPositioning.coordinate(
                                                                    place.location.coordinate.latitude, place.location.coordinate.longitude),
                                                  "address": {
                                                      "text": place.location.address.text
                                                  }
                                              },
                                              "primaryPhone": place.primaryPhone
                                          },
                                          "distance": data(j, "distance"),
                                          "category": "Search"
                                      })
                }
                break
            case PlaceSearchModel.Error:
                console.log(errorString())
                break
            }
        }
    }

    ListModel {
        id: placeModel

        function update() {
            for (var i = placeModel.count - 1; i >= 0; --i) {
                var object = placeModel.get(i)
                if (object.category === "Search") {
                    placeModel.remove(i)
                }
            }
            placeSearchModel.update()
        }

        function appendIfNotExist(objectToAppend) {
            for (var i = 0; i < placeModel.count; i++) {
                var object = placeModel.get(i)
                if (object.place == objectToAppend.place) {
                    if (object.category === "Favorites"
                            && objectToAppend.category === "Favorites") {
                        return
                    }
                    if (object.category === "Recents"
                            && objectToAppend.category === "Recents") {
                        placeModel.remove(i)
                        break
                    }
                }
            }
            placeModel.append(objectToAppend)
        }

        function loadPlaces() {
            if (placeSettings.datastore) {
                var datamodel = JSON.parse(placeSettings.datastore)
                for (var i = datamodel.length; i >= 0; --i)
                    placeModel.append(datamodel[i])
            }
        }

        function savePlaces() {
            var datamodel = []
            var recentsCount = 10
            console.log("placeModel.count: " + placeModel.count)
            for (var i = placeModel.count - 1; i >= 0; --i) {
                var object = placeModel.get(i)
                // console.log(JSON.stringify(object));
                if (object.category === "Favorites") {
                    datamodel.push(object)
                } else if (object.category === "Recents" && recentsCount > 0) {
                    datamodel.push(object)
                    --recentsCount
                }
            }
            placeSettings.datastore = JSON.stringify(datamodel)
            console.log("placeSettings.datastore: " + placeSettings.datastore)
            placeSettings.sync()
        }
    }

    Settings {
        id: placeSettings
        property string datastore
    }

    initialPage: Kirigami.ScrollablePage {
        titleDelegate: Kirigami.ActionTextField {
            id: searchField
            placeholderText: qsTr("Search...")
            Accessible.name: qsTr("Search")
            Accessible.searchEdit: true
            focusSequence: "Ctrl+F"
            Layout.topMargin: Kirigami.Units.smallSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
            Layout.fillHeight: true
            Layout.fillWidth: true
            onTextChanged: {
                if (searchField.text == "") {
                    placeSearchModel.reset()
                    return
                }

                placeSearchModel.searchTerm = searchField.text
                placeSearchModel.searchArea = map.visibleArea
                placeModel.update()
            }
            KeyNavigation.tab: listView
            rightActions: [
                Kirigami.Action {
                    icon.name: "fa-backspace"
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
                placeModel.update()
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
                    text: "Refresh"
                    onTriggered: {
                        placeModel.update()
                    }
                }
            }

            section {
                property: "category"
                delegate: Kirigami.ListSectionHeader {
                    text: section
                }
            }

            delegate: Kirigami.SwipeListItem {
                id: listItem
                contentItem: ColumnLayout {
                    Controls.Label {
                        Layout.fillWidth: true
                        height: Math.max(implicitHeight,
                                         Kirigami.Units.iconSizes.smallMedium)
                        text: title + "<br>" + place.location.address.text
                        color: listItem.checked
                               || (listItem.pressed && !listItem.checked
                                   && !listItem.sectionDelegate) ? listItem.activeTextColor : listItem.textColor
                    }

                    Controls.Label {
                        Layout.fillWidth: true
                        height: Math.max(implicitHeight,
                                         Kirigami.Units.iconSizes.smallMedium)
                        text: "Phone: " + (place.primaryPhone ? place.primaryPhone : "NONE")
                        color: listItem.checked
                               || (listItem.pressed && !listItem.checked
                                   && !listItem.sectionDelegate) ? listItem.activeTextColor : listItem.textColor
                    }
                }
                actions: [
                    Kirigami.Action {
                        iconName: "fa-phone"
                        id: callButton
                        visible: place.primaryPhone ? true : false
                        onTriggered: {
                            if (place.primaryPhone) {
                                call(place.primaryPhone)
                            }
                        }
                    },
                    Kirigami.Action {
                        iconName: category === "Favorites" ? "fa-trash" : "fa-star"
                        id: favoriteButton
                        onTriggered: {
                            if (category === "Favorites") {
                                placeModel.remove(index)
                            } else {
                                placeModel.appendIfNotExist({
                                                                "title": title,
                                                                "place": place,
                                                                "distance": distance,
                                                                "category": "Favorites"
                                                            })
                            }
                        }
                    },
                    Kirigami.Action {
                        iconName: "fa-play-circle"
                        id: goButton
                        onTriggered: {
                            placeModel.appendIfNotExist({
                                                            "title": title,
                                                            "place": place,
                                                            "distance": distance,
                                                            "category": "Recents"
                                                        })
                            driver.start(
                                QtPositioning.coordinate(
                                    place.location.coordinate.latitude,
                                    place.location.coordinate.longitude))
                        }
                    },
                    Kirigami.Action {
                        iconName: "fa-dot-circle"
                        id: focusButton
                        onTriggered: {
                            savePlaces()
                            map.focusOnPlace(place)
                        }
                    }
                ]
            }

            model: placeModel
        }
    }
}
