// Component mancool men ShopPages.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick

Item {
        id: suggestions
        property string term: ""
        readonly property var result: App.searchSuggestions(term, 3)
        readonly property var allMatches: App.searchSuggestions(term, 100)
        signal closeRequested()

        // The categories that contain matches become the suggestion rows ("vitamin — in Skincare")
        readonly property var categoryRows: {
            const names = []
            const items = allMatches.items
            for (let i = 0; i < items.length && names.length < 3; ++i) {
                if (names.indexOf(items[i].category) === -1)
                    names.push(items[i].category)
            }
            return names.map((name) => ({ category: name, term: term }))
        }

        implicitWidth: 560
        implicitHeight: content.height + 48

        Controls.ShadowRect {
            anchors.fill: parent
            radius: Theme.rSidebar
            color: Theme.white
            border.width: Theme.borderThin
            border.color: Theme.borderHairline
            elevation: "lg"
        }
        Column {
            id: content
            x: 24
            y: 24
            width: parent.width - 48
            spacing: 18

            Controls.PText {
                visible: suggestions.result.total === 0
                width: parent.width
                ts: Theme.bodyS
                color: Theme.textSecondary
                wrapMode: Text.WordWrap
                text: "No products match “" + suggestions.term + "”. Try a product name or code."
            }

            Controls.PText {
                visible: suggestions.categoryRows.length > 0
                ts: Theme.tinyOverline
                color: Theme.textMuted
                text: "Suggestions"
            }
            Column {
                visible: suggestions.categoryRows.length > 0
                width: parent.width
                spacing: 2
                Repeater {
                    model: suggestions.categoryRows
                    delegate: Rectangle {
                        id: suggestionRow
                        required property var modelData
                        required property int index
                        width: parent ? parent.width : 0
                        height: 39
                        radius: Theme.rTile
                        color: index === 0 || rowHover.hovered ? Theme.surfaceTint : "transparent"
                        Controls.Icon {
                            id: rowIcon
                            x: 12
                            anchors.verticalCenter: parent.verticalCenter
                            name: "search"
                            size: 16
                            color: Theme.textMuted
                        }
                        Row {
                            anchors.left: rowIcon.right
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 12
                            Controls.PText {
                                anchors.verticalCenter: parent.verticalCenter
                                ts: Theme.label
                                text: suggestionRow.modelData.term
                            }
                            Controls.PText {
                                anchors.verticalCenter: parent.verticalCenter
                                ts: Theme.meta12
                                color: Theme.textMuted
                                text: "in " + suggestionRow.modelData.category
                            }
                        }
                        Controls.Icon {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            name: "arrowUR"
                            size: 14
                            color: Theme.midnight300
                        }
                        HoverHandler {
                            id: rowHover
                            cursorShape: Qt.PointingHandCursor
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: App.go("shop", { search: suggestionRow.modelData.term, category: suggestionRow.modelData.category })
                        }
                    }
                }
            }

            Controls.PText {
                visible: suggestions.result.total > 0
                ts: Theme.tinyOverline
                color: Theme.textMuted
                text: "Products"
            }
            Row {
                visible: suggestions.result.total > 0
                spacing: 12
                Repeater {
                    model: suggestions.result.items
                    delegate: Rectangle {
                        id: match
                        required property var modelData
                        width: 162
                        height: 183
                        radius: Theme.rMenu
                        color: matchHover.hovered ? Theme.surfaceTint : Theme.white
                        border.width: Theme.borderThin
                        border.color: Theme.borderHairline
                        Column {
                            x: 10
                            y: 10
                            width: parent.width - 20
                            spacing: 8
                            Controls.RoundedImage {
                                width: parent.width
                                height: 96
                                radius: Theme.rMenuItem
                                source: match.modelData.image
                            }
                            Controls.PText {
                                width: parent.width
                                height: 34
                                ts: Theme.chip
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignTop
                                text: match.modelData.name
                            }
                            Controls.PText {
                                ts: Theme.countBadge
                                color: Theme.textPrimary
                                text: match.modelData.priceText
                            }
                        }
                        HoverHandler {
                            id: matchHover
                            cursorShape: Qt.PointingHandCursor
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: App.go("product", { id: match.modelData.id })
                        }
                    }
                }
            }

            Rectangle {
                visible: suggestions.result.total > 0
                width: parent.width
                height: 48
                radius: Theme.rInput
                color: seeAllHover.hovered ? Theme.royal600 : Theme.midnight900
                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Controls.PText {
                        anchors.verticalCenter: parent.verticalCenter
                        ts: Theme.link
                        color: Theme.white
                        text: "See all " + suggestions.result.total + (suggestions.result.total === 1 ? " result" : " results")
                              + " for “" + suggestions.term + "”"
                    }
                    Controls.Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "arrowR"
                        size: 15
                        color: Theme.white
                    }
                }
                HoverHandler {
                    id: seeAllHover
                    cursorShape: Qt.PointingHandCursor
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        suggestions.closeRequested()
                        App.go("shop", { search: suggestions.term })
                    }
                }
            }
        }
    }
