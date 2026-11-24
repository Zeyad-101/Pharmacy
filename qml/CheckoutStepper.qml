// Component mancool men Controls.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick
import QtQuick.Layouts

RowLayout {
        id: stepper
        property var steps: []
        property int current: 0
        // One entry per dot and per connector, so the delegates only read their own data
        readonly property var cells: {
            const list = []
            for (let i = 0; i < steps.length; ++i) {
                if (i > 0)
                    list.push({ connector: true, done: i <= current, label: "", number: 0, active: false })
                list.push({ connector: false, done: i < current, active: i === current, label: steps[i], number: i + 1 })
            }
            return list
        }
        spacing: 10
        height: 32

        Repeater {
            model: stepper.cells
            delegate: Item {
                id: stepCell
                required property var modelData
                Layout.fillWidth: modelData.connector
                Layout.preferredWidth: modelData.connector ? 40 : stepRow.implicitWidth
                Layout.preferredHeight: 32
                Rectangle {
                    visible: stepCell.modelData.connector
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 2
                    radius: height / 2
                    color: stepCell.modelData.done ? Theme.royal600 : Theme.borderControl
                }
                Row {
                    id: stepRow
                    visible: !stepCell.modelData.connector
                    spacing: 10
                    Rectangle {
                        width: 32
                        height: 32
                        radius: height / 2
                        color: stepCell.modelData.done ? Theme.royal600 : stepCell.modelData.active ? Theme.midnight900 : Theme.white
                        border.width: stepCell.modelData.done || stepCell.modelData.active ? 0 : Theme.borderThin
                        border.color: Theme.borderControl
                        Controls.Icon {
                            visible: stepCell.modelData.done
                            anchors.centerIn: parent
                            name: "check"
                            size: 16
                            color: Theme.white
                        }
                        Controls.PText {
                            visible: !stepCell.modelData.done
                            anchors.centerIn: parent
                            ts: Theme.linkBold
                            color: stepCell.modelData.active ? Theme.white : Theme.textMuted
                            text: stepCell.modelData.number
                        }
                    }
                    Controls.PText {
                        anchors.verticalCenter: parent.verticalCenter
                        ts: stepCell.modelData.active ? Theme.linkBold : Theme.small13
                        color: stepCell.modelData.active ? Theme.textPrimary
                             : stepCell.modelData.done ? Theme.textLabel : Theme.textMuted
                        text: stepCell.modelData.label
                    }
                }
            }
        }
    }
