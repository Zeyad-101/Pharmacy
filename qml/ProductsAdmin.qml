// Component mancool men AdminPages.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick

Column {
        id: productsAdmin
        property string openEditId: ""
        property string term: ""
        property var rows: App.adminProducts(term)
        // each row carries this page ("owner") so the row buttons need no outer ids
        readonly property var lineModel: rows.map((row) => Object.assign({ owner: productsAdmin }, row))
        property string removeId: ""
        property string removeName: ""
        width: parent ? parent.width : 952
        spacing: 20

        function refresh() {
            rows = App.adminProducts(term)
        }
        function openForm(productId: string) {
            productForm.load(productId)
            productForm.open()
        }
        function askRemove(productId: string, name: string) {
            removeId = productId
            removeName = name
            removeDialog.open()
        }
        onTermChanged: refresh()
        Component.onCompleted: {
            if (openEditId !== "")
                openForm(openEditId)
        }
        // Also when the admin page is already open (Inventory "Edit", "Manage in admin"): the page is not re-created
        onOpenEditIdChanged: {
            if (openEditId !== "")
                openForm(openEditId)
        }
        Connections {
            target: App
            function onDataChanged() {
                productsAdmin.refresh()
            }
        }

        Item {
            width: parent.width
            height: 52
            Controls.FormInput {
                id: searchField
                width: 440
                placeholder: "Search by name, brand or code"
                onTextChanged: productsAdmin.term = text
            }
            Controls.PcButton {
                anchors.right: parent.right
                text: "Add product"
                iconName: "plus"
                iconFirst: true
                onClicked: productsAdmin.openForm("")
            }
        }

        Controls.Panel {
            width: parent.width
            height: tableColumn.height + 32
            Column {
                id: tableColumn
                x: 16
                y: 16
                width: parent.width - 32
                Item {
                    width: parent.width
                    height: 40
                    Repeater {
                        model: [{ x: 12, text: "Product" }, { x: 340, text: "Category" }, { x: 516, text: "Price" },
                                { x: 626, text: "Stock" }, { x: 690, text: "Expiry" }]
                        delegate: Controls.PText {
                            required property var modelData
                            x: modelData.x
                            anchors.verticalCenter: parent.verticalCenter
                            ts: Theme.brandLine
                            color: Theme.textMuted
                            text: modelData.text
                        }
                    }
                }
                Controls.Divider {
                    width: parent.width
                }
                Controls.EmptyState {
                    visible: productsAdmin.rows.length === 0
                    width: parent.width
                    iconName: "search"
                    title: "No products found"
                    message: "No product matches “" + productsAdmin.term + "”. Try a name, a brand or a code."
                }
                Repeater {
                    model: productsAdmin.lineModel
                    delegate: Rectangle {
                        id: productRow
                        required property var modelData
                        width: parent ? parent.width : 0
                        height: 72
                        radius: Theme.rInput
                        color: productHover.hovered ? Theme.sky50 : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.hoverDuration } }
                        Controls.RoundedImage {
                            x: 12
                            anchors.verticalCenter: parent.verticalCenter
                            width: 48
                            height: 48
                            radius: Theme.rInput
                            source: productRow.modelData.image
                        }
                        Column {
                            x: 72
                            anchors.verticalCenter: parent.verticalCenter
                            width: 256
                            spacing: 2
                            Row {
                                spacing: 8
                                Controls.PText {
                                    width: Math.min(implicitWidth, productRow.modelData.requiresPrescription ? 190 : 256)
                                    ts: Theme.labelStrong
                                    elide: Text.ElideRight
                                    text: productRow.modelData.name
                                }
                                Controls.Badge {
                                    visible: productRow.modelData.requiresPrescription
                                    height: 20
                                    text: "Rx"
                                }
                            }
                            Controls.PText {
                                ts: Theme.meta12
                                color: Theme.textSecondary
                                text: productRow.modelData.id + "  ·  " + productRow.modelData.code
                                      + (productRow.modelData.brand !== "" ? "  ·  " + productRow.modelData.brand : "")
                            }
                        }
                        Controls.PText {
                            x: 340
                            width: 166
                            anchors.verticalCenter: parent.verticalCenter
                            ts: Theme.small13Regular
                            elide: Text.ElideRight
                            text: productRow.modelData.category
                        }
                        Controls.PText {
                            x: 516
                            anchors.verticalCenter: parent.verticalCenter
                            ts: Theme.valueStrong
                            text: productRow.modelData.priceText
                        }
                        Controls.PText {
                            x: 626
                            anchors.verticalCenter: parent.verticalCenter
                            ts: Theme.valueStrong
                            color: productRow.modelData.stock === 0 ? Theme.error : Theme.textPrimary
                            text: productRow.modelData.stock
                        }
                        Controls.PText {
                            x: 690
                            anchors.verticalCenter: parent.verticalCenter
                            ts: Theme.small13Regular
                            color: productRow.modelData.expired ? Theme.error : Theme.textSecondary
                            text: productRow.modelData.expiryText !== "" ? productRow.modelData.expiryText : "—"
                        }
                        Row {
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            Controls.PcButton {
                                height: 40
                                horizontalPadding: 16
                                variant: "secondary"
                                textStyle: Theme.link
                                text: "Edit"
                                onClicked: productRow.modelData.owner.openForm(productRow.modelData.id)
                            }
                            Controls.IconButton {
                                iconName: "trash"
                                iconSize: 16
                                iconColor: Theme.error
                                onClicked: productRow.modelData.owner.askRemove(productRow.modelData.id, productRow.modelData.name)
                            }
                        }
                        HoverHandler {
                            id: productHover
                        }
                    }
                }
            }
        }

        ProductForm {
            id: productForm
            onSaved: (message) => {
                App.showToast("success", "Product saved", message)
                productsAdmin.refresh()
            }
        }
        Controls.ConfirmDialog {
            id: removeDialog
            title: "Remove " + productsAdmin.removeName + "?"
            message: "It disappears from the shop straight away. Orders that already contain it keep their copy."
            confirmText: "Remove product"
            onConfirmed: {
                const result = App.removeProduct(productsAdmin.removeId)
                App.showToast(result.ok ? "success" : "error", result.ok ? "Product removed" : "Could not remove the product", result.message)
                productsAdmin.refresh()
            }
        }
    }
