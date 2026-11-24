// Component mancool men Controls.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick

Item {
        id: tracker
        property string status: "pending"
        property string placedText: ""
        // Backend statuses on the 4 design steps (horizontal tracker, as in the Order Confirmation board):
        // pending -> pharmacist check in progress; confirmed / processing -> packing; shipped -> on the way; delivered -> all done
        readonly property bool cancelled: status === "cancelled"
        readonly property int done: status === "delivered" ? 4
                                  : status === "shipped" ? 3
                                  : status === "confirmed" || status === "processing" ? 2 : 1
        readonly property int current: cancelled || status === "delivered" ? -1 : done
        readonly property string currentText: status === "confirmed" ? "Up next"
                                            : status === "shipped" ? "On the way" : "In progress"
        readonly property var stepsModel: {
            const labels = ["Order placed", "Pharmacist check", "Packed & dispatched", "Delivered"]
            const icons = ["bag", "shield", "bag", "home"]   // as in the Order Confirmation board
            const list = []
            for (let i = 0; i < 4; ++i) {
                const finished = i < done
                const isCurrent = i === current
                list.push({
                    index: i,
                    label: labels[i],
                    icon: finished ? "check" : icons[i],
                    finished: finished,
                    current: isCurrent,
                    detail: i === 0 ? placedText : isCurrent ? currentText : (finished ? "Done" : ""),
                    // the connector after this step is blue when it leads to a finished or the current step
                    lineDone: i < done && (i + 1 < done || i + 1 === current),
                    last: i === 3
                })
            }
            return list
        }
        implicitHeight: stepsRow.height + (cancelled ? cancelNote.height + 20 : 0)

        Row {
            id: stepsRow
            width: parent.width
            Repeater {
                model: tracker.stepsModel
                delegate: Item {
                    id: trackStep
                    required property var modelData
                    width: parent ? parent.width / 4 : 0
                    height: 100
                    // connector to the next step, through the dot centres
                    Rectangle {
                        visible: !trackStep.modelData.last
                        x: 44 + 8
                        y: 21
                        width: trackStep.width - 44 - 16
                        height: 2
                        radius: 1
                        color: trackStep.modelData.lineDone ? Theme.royal600 : Theme.borderControl
                    }
                    // focus halo around the current step
                    Rectangle {
                        visible: trackStep.modelData.current
                        x: -Theme.focusRingWidth
                        y: -Theme.focusRingWidth
                        width: 44 + 2 * Theme.focusRingWidth
                        height: width
                        radius: width / 2
                        color: Theme.focusRing
                    }
                    Rectangle {
                        width: 44
                        height: 44
                        radius: height / 2
                        color: trackStep.modelData.finished ? Theme.royal600
                             : trackStep.modelData.current ? Theme.midnight900 : Theme.surfaceTint
                        border.width: trackStep.modelData.finished || trackStep.modelData.current ? 0 : Theme.borderThin
                        border.color: Theme.sky200
                        Controls.Icon {
                            anchors.centerIn: parent
                            name: trackStep.modelData.icon
                            size: 18
                            color: trackStep.modelData.finished || trackStep.modelData.current ? Theme.white : Theme.textMuted
                        }
                    }
                    Column {
                        y: 56
                        width: parent.width - 12
                        spacing: 4
                        Controls.PText {
                            width: parent.width
                            ts: Theme.cardLine
                            color: trackStep.modelData.finished || trackStep.modelData.current ? Theme.textPrimary : Theme.textMuted
                            elide: Text.ElideRight
                            text: trackStep.modelData.label
                        }
                        Controls.PText {
                            visible: text !== ""
                            ts: trackStep.modelData.current ? Theme.chip : Theme.meta12
                            color: trackStep.modelData.current ? Theme.royal600 : Theme.textSecondary
                            text: trackStep.modelData.detail
                        }
                    }
                }
            }
        }
        // Cancelled orders keep "Order placed" and say so underneath
        Rectangle {
            id: cancelNote
            visible: tracker.cancelled
            y: stepsRow.height + 20
            width: parent.width
            height: 48
            radius: Theme.rOption
            color: Theme.errorBg
            Row {
                x: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Controls.Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "x"
                    size: 16
                    color: Theme.error
                }
                Controls.PText {
                    anchors.verticalCenter: parent.verticalCenter
                    ts: Theme.link
                    color: Theme.error
                    text: "This order was cancelled. The items went back into stock."
                }
            }
        }
    }
