// El file da fih safa7at el tasawok: el Home, el Shop (categories / search / sort), safhet el product, el Quick View, wel search suggestions.
// Owner: Abdelrhman (GUI)
import QtQuick

QtObject {

    // ===================== HOME =====================
    // ===================== SHOP (all / category / search) =====================
    // ===================== PRODUCT DETAILS =====================
    // ===================== QUICK VIEW (overlay) =====================
    component QuickView: Item {
        id: quickView
        property string productId: ""
        readonly property var product: App.product(productId)
        readonly property bool found: product.ok === true
        readonly property bool rx: found && product.requiresPrescription === true
        property int quantity: 1
        signal closeRequested()

        implicitWidth: 960
        implicitHeight: 560
        onProductIdChanged: quantity = 1

        Controls.ModalFrame {
            anchors.fill: parent
        }
        Controls.RoundedImage {
            width: 460
            height: 560
            radius: Theme.rModal
            leftOnly: true
            source: quickView.found ? quickView.product.image : ""
        }
        Controls.ProductBadge {
            x: 20
            y: 20
            product: quickView.product
        }
        Item {
            x: 460
            width: 500
            height: 560
            Item {
                id: qvTop
                x: 40
                y: 40
                width: 420
                height: 40
                Controls.PText {
                    anchors.verticalCenter: parent.verticalCenter
                    ts: Theme.overline
                    color: Theme.accent
                    text: quickView.found ? quickView.product.brand : ""
                }
                Controls.IconButton {
                    anchors.right: parent.right
                    iconName: "x"
                    onClicked: quickView.closeRequested()
                }
            }
            Column {
                anchors.top: qvTop.bottom
                anchors.topMargin: 16
                x: 40
                width: 420
                spacing: 16
                Controls.PText {
                    width: parent.width
                    ts: Theme.quickViewTitle
                    wrapMode: Text.WordWrap
                    text: quickView.found ? quickView.product.name : ""
                }
                Controls.PText {
                    ts: Theme.quickViewPrice
                    text: quickView.found ? quickView.product.priceText : ""
                }
                Controls.PText {
                    width: parent.width
                    ts: Theme.bodyS
                    color: Theme.textBody
                    wrapMode: Text.WordWrap
                    text: quickView.found ? quickView.product.description : ""
                }
                Row {
                    visible: quickView.rx || (quickView.found && quickView.product.inStock !== true)
                    spacing: 8
                    Controls.Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: quickView.rx ? "rx" : "info"
                        size: 16
                        color: quickView.rx ? Theme.royal600 : Theme.error
                    }
                    Controls.PText {
                        ts: Theme.link
                        color: quickView.rx ? Theme.textPrimary : Theme.error
                        text: quickView.rx ? "Prescription required at checkout"
                                           : (quickView.product.expired === true ? "Expired · not available to order" : "Out of stock")
                    }
                }
            }
            Column {
                x: 40
                width: 420
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 36
                spacing: 16
                Row {
                    visible: !App.isAdmin      // admins do not shop
                    spacing: 12
                    Controls.QuantitySelector {
                        value: quickView.quantity
                        maximum: quickView.found ? Math.max(1, quickView.product.stock) : 1
                        enabled: quickView.found && quickView.product.inStock === true
                        onStepped: (newValue) => quickView.quantity = newValue
                    }
                    Controls.PcButton {
                        width: 420 - 136 - 12
                        text: "Add to Cart"
                        iconName: "bag"
                        iconFirst: true
                        enabled: quickView.found && quickView.product.inStock === true
                        onClicked: {
                            const result = App.addToCart(quickView.productId, quickView.quantity)
                            if (result.ok) {
                                quickView.closeRequested()
                                App.openCartDrawer()
                            } else {
                                App.showToast("error", "Could not add to bag", result.message)
                            }
                        }
                    }
                }
                Controls.TextLink {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.textPrimary
                    iconName: "arrowR"
                    iconAfter: true
                    iconSize: 15
                    spacing: 8
                    text: "View full product details"
                    onClicked: {
                        quickView.closeRequested()
                        App.go("product", { id: quickView.productId })
                    }
                }
            }
        }
    }

    // ===================== SEARCH SUGGESTIONS (overlay under the header search) =====================
}
