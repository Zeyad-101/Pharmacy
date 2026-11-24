// Component mancool men AdminPages.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick

Column {
        id: inventory
        property int threshold: 30
        property var lowStock: App.lowStockProducts(threshold)
        property var expired: App.expiredProducts()
        width: parent ? parent.width : 952
        spacing: 24

        function refresh() {
            lowStock = App.lowStockProducts(threshold)
            expired = App.expiredProducts()
        }
        onThresholdChanged: refresh()
        Connections {
            target: App
            function onDataChanged() {
                inventory.refresh()
            }
        }

        Controls.Panel {
            width: parent.width
            height: lowColumn.height + 56
            Column {
                id: lowColumn
                x: 28
                y: 28
                width: parent.width - 56
                spacing: 16
                Item {
                    width: parent.width
                    height: 77
                    Column {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 12
                        spacing: 4
                        Controls.PText {
                            ts: Theme.h4
                            text: "Low stock"
                        }
                        Controls.PText {
                            ts: Theme.small13Regular
                            color: Theme.textSecondary
                            text: inventory.lowStock.length + (inventory.lowStock.length === 1 ? " product" : " products")
                                  + " at or below " + inventory.threshold + " units"
                        }
                    }
                    Controls.FormInput {
                        id: thresholdField
                        anchors.right: parent.right
                        width: 200
                        label: "Low stock at or below"
                        placeholder: "30"
                        maximumLength: 5
                        text: "30"
                        helper: ""
                        onAccepted: {
                            const value = parseInt(text, 10)
                            if (!isNaN(value) && value >= 0)
                                inventory.threshold = value
                        }
                        onTextChanged: {
                            const value = parseInt(text, 10)
                            if (!isNaN(value) && value >= 0 && String(value) === text.trim())
                                inventory.threshold = value
                        }
                    }
                }
                Controls.PText {
                    visible: inventory.lowStock.length === 0
                    ts: Theme.bodyS
                    color: Theme.success
                    text: "Every product has more than " + inventory.threshold + " units in stock."
                }
                Repeater {
                    model: inventory.lowStock
                    delegate: StockRow {
                        width: parent ? parent.width : 0
                    }
                }
            }
        }

        Controls.Panel {
            width: parent.width
            height: expiredColumn.height + 56
            Column {
                id: expiredColumn
                x: 28
                y: 28
                width: parent.width - 56
                spacing: 16
                Column {
                    spacing: 4
                    Controls.PText {
                        ts: Theme.h4
                        text: "Expired products"
                    }
                    Controls.PText {
                        ts: Theme.small13Regular
                        color: Theme.textSecondary
                        text: "Past their expiry date: customers cannot buy them. Edit the product with a new batch date or remove it."
                    }
                }
                Controls.PText {
                    visible: inventory.expired.length === 0
                    ts: Theme.bodyS
                    color: Theme.success
                    text: "No expired products."
                }
                Repeater {
                    model: inventory.expired
                    delegate: Rectangle {
                        id: expiredRow
                        required property var modelData
                        width: parent ? parent.width : 0
                        height: 64
                        radius: Theme.rInput
                        color: Theme.errorBg
                        Controls.RoundedImage {
                            x: 12
                            anchors.verticalCenter: parent.verticalCenter
                            width: 40
                            height: 40
                            radius: Theme.rInput
                            source: expiredRow.modelData.image
                        }
                        Controls.PText {
                            x: 64
                            anchors.verticalCenter: parent.verticalCenter
                            ts: Theme.labelStrong
                            text: expiredRow.modelData.name
                        }
                        Row {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 16
                            Controls.PText {
                                anchors.verticalCenter: parent.verticalCenter
                                ts: Theme.link
                                color: Theme.error
                                text: "Expired " + expiredRow.modelData.expiryText
                            }
                            Controls.TextLink {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Edit"
                                onClicked: App.go("admin", { tab: "products", edit: expiredRow.modelData.id })
                            }
                        }
                    }
                }
            }
        }
    }
