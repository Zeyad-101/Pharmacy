// Component mancool men AdminPages.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick

Column {
        id: dashboard
        // Products at or below this stock count are "low" (InventoryManager::getLowStockProducts threshold)
        readonly property int lowStockThreshold: 30
        property var summary: App.adminSummary(lowStockThreshold)
        width: parent ? parent.width : 952
        spacing: 24

        Connections {
            target: App
            function onDataChanged() {
                dashboard.summary = App.adminSummary(dashboard.lowStockThreshold)
            }
        }

        Grid {
            width: parent.width
            columns: 4
            spacing: 16
            Repeater {
                model: [
                    { icon: "wallet", label: "Revenue", value: dashboard.summary.revenueText, note: "excl. cancelled", warn: false, tab: "orders" },
                    { icon: "bag", label: "Orders", value: String(dashboard.summary.orderCount), note: "", warn: false, tab: "orders" },
                    { icon: "clock", label: "Open orders", value: String(dashboard.summary.openOrders), note: dashboard.summary.pendingOrders + " pending", warn: false, tab: "orders" },
                    { icon: "user", label: "Customers", value: String(dashboard.summary.customerCount), note: "", warn: false, tab: "dashboard" },
                    { icon: "pill", label: "Products", value: String(dashboard.summary.productCount), note: "", warn: false, tab: "products" },
                    { icon: "sliders", label: "Low stock", value: String(dashboard.summary.lowStockCount), note: "≤ " + dashboard.lowStockThreshold + " in stock", warn: dashboard.summary.lowStockCount > 0, tab: "inventory" },
                    { icon: "calendar", label: "Expired", value: String(dashboard.summary.expiredCount), note: "", warn: dashboard.summary.expiredCount > 0, tab: "inventory" },
                    { icon: "rx", label: "Pending checks", value: String(dashboard.summary.pendingOrders), note: "to review", warn: false, tab: "orders" }
                ]
                delegate: Controls.StatCard {
                    required property var modelData
                    width: parent ? (parent.width - 3 * 16) / 4 : 0
                    iconName: modelData.icon
                    label: modelData.label
                    value: modelData.value !== undefined ? modelData.value : ""
                    note: modelData.note
                    warning: modelData.warn
                    onClicked: App.go("admin", { tab: modelData.tab })
                }
            }
        }

        Controls.Panel {
            width: parent.width
            height: recentColumn.height + 56
            Column {
                id: recentColumn
                x: 28
                y: 28
                width: parent.width - 56
                spacing: 12
                Item {
                    width: parent.width
                    height: 32
                    Controls.PText {
                        anchors.verticalCenter: parent.verticalCenter
                        ts: Theme.h4
                        text: "Recent orders"
                    }
                    Controls.TextLink {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: "All orders"
                        iconName: "arrowR"
                        iconAfter: true
                        onClicked: App.go("admin", { tab: "orders" })
                    }
                }
                Controls.PText {
                    visible: (dashboard.summary.recentOrders || []).length === 0
                    ts: Theme.bodyS
                    color: Theme.textSecondary
                    text: "No orders yet. They appear here as soon as a customer checks out."
                }
                Repeater {
                    model: dashboard.summary.recentOrders || []
                    delegate: OrderRow {
                        width: parent ? parent.width : 0
                        compact: true
                    }
                }
            }
        }
    }
