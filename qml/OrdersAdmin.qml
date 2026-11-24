// Component mancool men AdminPages.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick

Column {
        id: ordersAdmin
        property string filter: ""
        property var allOrders: App.adminOrders("")
        readonly property var visibleOrders: (filter === "" ? allOrders : allOrders.filter((order) => order.status === filter))
                                             .map((order) => Object.assign({ owner: ordersAdmin }, order))
        property string pendingId: ""
        property string pendingStatus: ""
        width: parent ? parent.width : 952
        spacing: 20

        function refresh() {
            allOrders = App.adminOrders("")
        }
        function countOf(status: string): int {
            return status === "" ? allOrders.length : allOrders.filter((order) => order.status === status).length
        }
        function apply(orderId: string, status: string) {
            const result = App.updateOrderStatus(orderId, status)
            App.showToast(result.ok ? "success" : "error", result.ok ? "Order updated" : "Could not update the order", result.message)
            refresh()
        }
        function request(orderId: string, status: string) {
            if (status === "cancelled") {
                pendingId = orderId
                pendingStatus = status
                cancelDialog.open()
            } else {
                apply(orderId, status)
            }
        }
        Connections {
            target: App
            function onDataChanged() {
                ordersAdmin.refresh()
            }
        }

        Flow {
            width: parent.width
            spacing: 10
            Repeater {
                model: [{ value: "", label: "All" }, { value: "pending", label: "Pending" }, { value: "confirmed", label: "Confirmed" },
                        { value: "processing", label: "Processing" }, { value: "shipped", label: "Shipped" },
                        { value: "delivered", label: "Delivered" }, { value: "cancelled", label: "Cancelled" }]
                        .map((tab) => Object.assign({ owner: ordersAdmin, count: ordersAdmin.countOf(tab.value),
                                                      selected: ordersAdmin.filter === tab.value }, tab))
                delegate: Controls.CategoryTab {
                    required property var modelData
                    text: modelData.label
                    count: modelData.count
                    selected: modelData.selected
                    onClicked: modelData.owner.filter = modelData.value
                }
            }
        }
        Controls.EmptyState {
            visible: ordersAdmin.visibleOrders.length === 0
            width: parent.width
            iconName: "bag"
            title: ordersAdmin.filter === "" ? "No orders yet" : "No " + ordersAdmin.filter + " orders"
            message: "Orders appear here as soon as a customer checks out."
        }
        Controls.Panel {
            visible: ordersAdmin.visibleOrders.length > 0
            width: parent.width
            height: listColumn.height + 24
            Column {
                id: listColumn
                x: 12
                y: 12
                width: parent.width - 24
                Repeater {
                    model: ordersAdmin.visibleOrders
                    delegate: Column {
                        id: orderLine
                        required property var modelData
                        required property int index
                        width: parent ? parent.width : 0
                        Controls.Divider {
                            visible: orderLine.index > 0
                            width: parent.width
                        }
                        OrderRow {
                            width: parent.width
                            modelData: orderLine.modelData
                            onStatusRequested: (orderId, status) => orderLine.modelData.owner.request(orderId, status)
                        }
                    }
                }
            }
        }
        Controls.ConfirmDialog {
            id: cancelDialog
            title: "Cancel order #" + ordersAdmin.pendingId + "?"
            message: "The customer sees the order as cancelled and the items go back into stock. This cannot be undone."
            confirmText: "Cancel order"
            cancelText: "Keep order"
            onConfirmed: ordersAdmin.apply(ordersAdmin.pendingId, ordersAdmin.pendingStatus)
        }
    }
