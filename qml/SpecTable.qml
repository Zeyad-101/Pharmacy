// Component mancool men Controls.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick

Rectangle {
        id: specTable
        property var rows: []
        width: 736
        height: rowsColumn.height + 2
        radius: Theme.rPanel
        color: Theme.white
        border.width: Theme.borderThin
        border.color: Theme.borderHairline

        Controls.Rounded {
            anchors.fill: parent
            anchors.margins: 1
            radius: Theme.rPanel - 1
            Column {
                id: rowsColumn
                width: parent.width
                Repeater {
                    model: specTable.rows
                    delegate: Rectangle {
                        id: specRow
                        required property var modelData
                        required property int index
                        width: parent ? parent.width : 0
                        height: 49
                        color: index % 2 === 0 ? Theme.surfaceTint : Theme.white
                        Controls.PText {
                            x: 22
                            width: 220
                            anchors.verticalCenter: parent.verticalCenter
                            ts: Theme.small13
                            color: Theme.textSecondary
                            text: specRow.modelData.label
                        }
                        Controls.PText {
                            x: 242
                            anchors.verticalCenter: parent.verticalCenter
                            ts: Theme.link
                            text: specRow.modelData.value
                        }
                    }
                }
            }
        }
    }
