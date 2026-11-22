// El file da fih safa7at el shira2: el cart drawer (phase 1), w ba3d keda el cart, el checkout, el confirmation, wel prescription modal.
// Owner: Abdelrhman (GUI)
import QtQuick

QtObject {

    // ===================== CART DRAWER (overlay on the right) =====================
    component CartDrawer: Item {
        id: drawer
        property bool justAdded: false
        property var cart: App.cartItems()
        signal closeRequested()

        function refresh() {
            cart = App.cartItems()
        }

        width: 460

        Connections {
            target: App
            function onCartChanged() {
                drawer.refresh()
            }
        }

        // Panel: white, radius 24 on the top-left corner only, lg shadow
        Controls.ShadowRect {
            anchors.fill: parent
            radius: Theme.rSidebar
            color: Theme.white
            elevation: "lg"
        }
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            width: Theme.rSidebar
            height: Theme.rSidebar
            color: Theme.white
        }
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: Theme.rSidebar
            color: Theme.surfaceTint
        }

        // Head
        Item {
            id: drawerHead
            width: parent.width
            height: 88
            Row {
                x: 28
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Controls.PText {
                    ts: Theme.drawerTitle
                    text: "Your bag"
                }
                Controls.PText {
                    anchors.bottom: parent.bottom
                    ts: Theme.body
                    color: Theme.textSecondary
                    text: drawer.cart.count + (drawer.cart.count === 1 ? " item" : " items")
                }
            }
            Controls.IconButton {
                anchors.right: parent.right
                anchors.rightMargin: 28
                anchors.verticalCenter: parent.verticalCenter
                iconName: "x"
                onClicked: drawer.closeRequested()
            }
        }

        // "Item added" banner
        Rectangle {
            id: addedBanner
            anchors.top: drawerHead.bottom
            width: parent.width
            height: drawer.justAdded ? 41 : 0
            visible: drawer.justAdded
            color: Theme.successBg
            Row {
                x: 28
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Controls.Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "check"
                    size: 16
                    color: Theme.success
                }
                Controls.PText {
                    anchors.verticalCenter: parent.verticalCenter
                    ts: Theme.linkBold
                    color: Theme.success
                    text: "Item added to your bag"
                }
            }
        }

        // Items
        ListView {
            id: itemList
            anchors.top: addedBanner.bottom
            anchors.bottom: drawerFooter.top
            x: 28
            width: parent.width - 56
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            visible: !drawer.cart.empty
            model: drawer.cart.items
            delegate: Item {
                id: row
                required property var modelData
                width: ListView.view.width
                height: 104
                Controls.RoundedImage {
                    id: rowThumb
                    y: 16
                    width: 72
                    height: 72
                    radius: Theme.rThumb
                    source: row.modelData.image
                }
                Column {
                    anchors.left: rowThumb.right
                    anchors.leftMargin: 14
                    anchors.right: rowPrice.left
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    Controls.PText {
                        width: parent.width
                        ts: Theme.link
                        elide: Text.ElideRight
                        text: row.modelData.name
                    }
                    Controls.PText {
                        ts: Theme.meta12
                        color: Theme.textSecondary
                        text: "Qty " + row.modelData.quantity + "  ·  " + row.modelData.unitPriceText + " each"
                    }
                    Row {
                        visible: row.modelData.requiresPrescription === true
                        spacing: 6
                        Controls.Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: "rx"
                            size: 12
                            color: Theme.royal600
                        }
                        Controls.PText {
                            ts: Theme.caption
                            color: Theme.royal600
                            text: "Prescription required"
                        }
                    }
                }
                Controls.PText {
                    id: rowPrice
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    ts: Theme.linkBold
                    text: row.modelData.lineTotalText
                }
                Controls.Divider {
                    anchors.bottom: parent.bottom
                    width: parent.width
                }
            }
        }

        // Empty bag
        Column {
            visible: drawer.cart.empty
            anchors.top: addedBanner.bottom
            anchors.topMargin: 48
            x: 28
            width: parent.width - 56
            spacing: 12
            Controls.PText {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                ts: Theme.cardTitle
                text: "Your bag is empty"
            }
            Controls.PText {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                ts: Theme.bodyS
                color: Theme.textSecondary
                wrapMode: Text.WordWrap
                text: "Browse the shop and add products to see them here."
            }
        }

        // Footer
        Rectangle {
            id: drawerFooter
            anchors.bottom: parent.bottom
            width: parent.width
            height: footerColumn.height + 48
            color: Theme.surfaceTint
            Column {
                id: footerColumn
                x: 28
                y: 20
                width: parent.width - 56
                spacing: 14
                Item {
                    visible: !drawer.cart.empty
                    width: parent.width
                    height: 25
                    Controls.PText {
                        anchors.verticalCenter: parent.verticalCenter
                        ts: Theme.cardLine
                        text: "Subtotal"
                    }
                    Controls.PText {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        ts: Theme.subtotal
                        text: drawer.cart.subtotalText
                    }
                }
                Controls.PText {
                    visible: !drawer.cart.empty
                    ts: Theme.meta12
                    color: Theme.textSecondary
                    text: "Promo codes are applied at checkout"
                }
                Controls.PcButton {
                    width: parent.width
                    variant: "secondary"
                    text: "Continue shopping"
                    onClicked: drawer.closeRequested()
                }
            }
        }
    }
}
