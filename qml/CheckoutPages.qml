// El file da fih safa7at el shira2: el cart, el cart drawer, el checkout (el 3enwan w el review), el confirmation, wel prescription modal.
// Owner: Abdelrhman (GUI)
import QtQuick

QtObject {

    // ===================== CART PAGE =====================
    // ===================== CART DRAWER (overlay on the right) =====================
    // ===================== CHECKOUT (shipping address -> review -> place order) =====================
    // ===================== PRESCRIPTION MODAL =====================
    // Design: "Prescription required". The backend has no file upload, so the customer confirms instead.
    component PrescriptionModal: Item {
        id: rxModal
        property var productNames: []
        signal confirmed()
        signal cancelled()

        implicitWidth: 560
        implicitHeight: rxColumn.height + 72

        Controls.ModalFrame {
            anchors.fill: parent
        }
        Column {
            id: rxColumn
            x: 36
            y: 36
            width: parent.width - 72
            spacing: 22
            Item {
                width: parent.width
                height: rxTitles.height
                Column {
                    id: rxTitles
                    width: 440
                    spacing: 8
                    Rectangle {
                        width: 52
                        height: 52
                        radius: Theme.rMenu
                        color: Theme.sky100
                        Controls.Icon {
                            anchors.centerIn: parent
                            name: "rx"
                            size: 24
                            color: Theme.royal600
                        }
                    }
                    Controls.PText {
                        ts: Theme.cardTitle
                        text: "Prescription required"
                    }
                    Controls.PText {
                        width: parent.width
                        ts: Theme.body
                        color: Theme.textSecondary
                        wrapMode: Text.WordWrap
                        text: rxModal.productNames.join(", ")
                              + (rxModal.productNames.length === 1 ? " is a prescription-only medicine." : " are prescription-only medicines.")
                              + " Please confirm that you have a valid prescription before placing your order."
                    }
                }
                Controls.IconButton {
                    anchors.right: parent.right
                    iconName: "x"
                    onClicked: rxModal.cancelled()
                }
            }
            Rectangle {
                width: parent.width
                height: 76
                radius: Theme.rPanel
                color: Theme.surfaceTint
                border.width: Theme.borderFocus
                border.color: Theme.royal400
                Controls.FilterCheckbox {
                    id: rxConfirm
                    x: 20
                    width: parent.width - 40
                    anchors.verticalCenter: parent.verticalCenter
                    text: "I confirm I have a valid prescription for these medicines"
                    onToggled: checked = !checked
                }
            }
            Row {
                anchors.right: parent.right
                spacing: 12
                Controls.PcButton {
                    variant: "secondary"
                    text: "Cancel"
                    onClicked: rxModal.cancelled()
                }
                Controls.PcButton {
                    text: "Confirm and place order"
                    iconName: "arrowR"
                    enabled: rxConfirm.checked
                    onClicked: rxModal.confirmed()
                }
            }
        }
    }

    // ===================== ORDER CONFIRMATION =====================
}
