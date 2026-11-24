// El file da fih safa7at el admin: el dashboard, el products (add / edit / remove), el orders (taghyeer el status), wel inventory.
// Owner: Abdelrhman (GUI)
import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Dialogs

QtObject {

    // ===================== ADMIN AREA =====================
    // Not in the Penpot file: page head + side navigation + panels from the design system.
    // Only reachable when Authentication::isCurrentUserAdmin() (App.go sends everyone else away).
    component AdminPage: Item {
        id: admin
        width: parent ? parent.width : Theme.designWidth
        implicitHeight: adminColumn.height + 96

        readonly property string tab: App.pageParams.tab !== undefined ? App.pageParams.tab : "dashboard"
        readonly property string editId: App.pageParams.edit !== undefined ? App.pageParams.edit : ""
        readonly property var tabTitles: ({ dashboard: "Dashboard", products: "Products", orders: "Orders", inventory: "Inventory" })
        readonly property var tabSubtitles: ({
            dashboard: "Today's numbers from the backend: orders, revenue and stock that needs attention.",
            products: "Add, edit or remove products. Changes are saved straight to the catalogue.",
            orders: "Move each order to its next status. Only the steps the order allows are offered.",
            inventory: "Products running low or past their expiry date. Add stock when a delivery arrives."
        })

        Column {
            id: adminColumn
            y: 36
            x: (parent.width - Theme.contentWidth) / 2
            width: Theme.contentWidth
            spacing: 40
            PageHead {
                crumbs: [{ label: "Home", page: "home", params: {} }, { label: "Admin", page: "admin", params: {} }]
                current: admin.tabTitles[admin.tab] !== undefined ? admin.tabTitles[admin.tab] : "Dashboard"
                title: admin.tabTitles[admin.tab] !== undefined ? admin.tabTitles[admin.tab] : "Dashboard"
                subtitle: admin.tabSubtitles[admin.tab] !== undefined ? admin.tabSubtitles[admin.tab] : ""
            }
            Row {
                spacing: 48
                Controls.Panel {
                    width: 280
                    height: navColumn.height + 32
                    Column {
                        id: navColumn
                        x: 16
                        y: 16
                        width: parent.width - 32
                        spacing: 4
                        Controls.PText {
                            leftPadding: 14
                            bottomPadding: 8
                            topPadding: 4
                            ts: Theme.tinyOverline
                            color: Theme.textMuted
                            text: "Manage"
                        }
                        Controls.NavItem {
                            text: "Dashboard"
                            iconName: "grid"
                            selected: admin.tab === "dashboard"
                            onClicked: App.go("admin", { tab: "dashboard" })
                        }
                        Controls.NavItem {
                            text: "Products"
                            iconName: "pill"
                            selected: admin.tab === "products"
                            onClicked: App.go("admin", { tab: "products" })
                        }
                        Controls.NavItem {
                            text: "Orders"
                            iconName: "bag"
                            selected: admin.tab === "orders"
                            onClicked: App.go("admin", { tab: "orders" })
                        }
                        Controls.NavItem {
                            text: "Inventory"
                            iconName: "sliders"
                            selected: admin.tab === "inventory"
                            onClicked: App.go("admin", { tab: "inventory" })
                        }
                        Controls.Divider {
                            width: parent.width
                        }
                        Controls.NavItem {
                            text: "View the shop"
                            iconName: "home"
                            onClicked: App.go("shop")
                        }
                    }
                }
                // ---------- Content (the selected tab) ----------
                Column {
                    width: Theme.contentWidth - 280 - 48
                    Dashboard {
                        visible: admin.tab !== "products" && admin.tab !== "orders" && admin.tab !== "inventory"
                        width: parent.width
                    }
                    ProductsAdmin {
                        visible: admin.tab === "products"
                        width: parent.width
                        openEditId: admin.tab === "products" ? admin.editId : ""
                    }
                    OrdersAdmin {
                        visible: admin.tab === "orders"
                        width: parent.width
                    }
                    InventoryAdmin {
                        visible: admin.tab === "inventory"
                        width: parent.width
                    }
                }
            }
        }
    }

    // ===================== DASHBOARD =====================
    // One order line (dashboard + orders tab): id, customer, date, items, total, status, next-status actions
    // ===================== PRODUCTS =====================
    // Add / edit product (AdminManager::addProduct / updateProduct); the C++ side parses the price into piastres
    // ===================== ORDERS =====================
    // ===================== INVENTORY =====================
    // Low-stock line with "Add stock" (InventoryManager::increaseStock)
}
