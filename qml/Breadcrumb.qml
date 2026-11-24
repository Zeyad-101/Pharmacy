// Component mancool men Controls.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick

Row {
        id: breadcrumb
        property var crumbs: []
        property string current: ""
        spacing: 8

        Repeater {
            model: breadcrumb.crumbs
            delegate: Row {
                id: crumbRow
                required property var modelData
                spacing: 8
                Controls.PText {
                    ts: Theme.small13
                    text: crumbRow.modelData.label
                    color: crumbHover.hovered ? Theme.royal600 : Theme.textSecondary
                    HoverHandler {
                        id: crumbHover
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: App.go(crumbRow.modelData.page, crumbRow.modelData.params)
                    }
                }
                Controls.PText {
                    ts: Theme.small13
                    text: "/"
                    color: Theme.midnight300
                }
            }
        }
        Controls.PText {
            ts: Theme.link
            text: breadcrumb.current
        }
    }
