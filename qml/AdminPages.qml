// El file da fih safa7at el admin: el dashboard, el products (add / edit / remove), el orders (taghyeer el status), wel inventory.
// Owner: Abdelrhman (GUI)
import QtQuick
import QtQuick.Controls.Basic as Basic

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
            Controls.PageHead {
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
    component Dashboard: Column {
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

    // One order line (dashboard + orders tab): id, customer, date, items, total, status, next-status actions
    component OrderRow: Rectangle {
        id: orderRow
        required property var modelData
        property bool compact: false
        signal statusRequested(string orderId, string status, string label)
        height: 76
        radius: Theme.rInput
        color: rowHover.hovered ? Theme.sky50 : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.hoverDuration } }
        Column {
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 220
            spacing: 2
            Controls.PText {
                ts: Theme.labelStrong
                text: "#" + orderRow.modelData.orderId + "  ·  " + orderRow.modelData.customerName
            }
            Controls.PText {
                ts: Theme.meta12
                color: Theme.textSecondary
                text: orderRow.modelData.createdText + "  ·  " + orderRow.modelData.count
                      + (orderRow.modelData.count === 1 ? " item" : " items")
            }
        }
        Controls.PText {
            x: 250
            width: 140
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignRight
            ts: Theme.valueStrong
            text: orderRow.modelData.totalText
        }
        Controls.StatusChip {
            x: 414
            anchors.verticalCenter: parent.verticalCenter
            status: orderRow.modelData.status
            text: orderRow.modelData.statusLabel
        }
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            // Only Order::nextStatusesFor(status): pending -> confirmed / cancelled, … shipped -> delivered
            Repeater {
                model: orderRow.compact ? [] : orderRow.modelData.nextStatuses.map((option) => Object.assign({ owner: orderRow }, option))
                delegate: Controls.PcButton {
                    required property var modelData
                    height: 40
                    horizontalPadding: 16
                    textStyle: Theme.link
                    variant: modelData.value === "cancelled" ? "secondary" : "primary"
                    text: modelData.value === "cancelled" ? "Cancel" : "Mark " + modelData.label.toLowerCase()
                    onClicked: modelData.owner.statusRequested(modelData.owner.modelData.orderId, modelData.value, modelData.label)
                }
            }
            Controls.IconButton {
                iconName: "arrowR"
                iconSize: 16
                onClicked: App.go("orderDetails", { orderId: orderRow.modelData.orderId })
            }
        }
        HoverHandler {
            id: rowHover
        }
    }

    // ===================== PRODUCTS =====================
    component ProductsAdmin: Column {
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

    // Add / edit product (AdminManager::addProduct / updateProduct); the C++ side parses the price into piastres
    component ProductForm: Basic.Popup {
        id: productForm
        property var form: ({})
        property string category: ""
        property bool prescription: false
        property string errorText: ""
        property string errorField: ""
        signal saved(string message)

        function load(productId: string) {
            form = App.adminProductForm(productId)
            nameField.text = form.name
            codeField.text = form.code
            brandField.text = form.brand
            priceField.text = form.price
            stockField.text = form.stock
            expiryField.text = form.expiry
            descriptionField.text = form.description
            category = form.category
            prescription = form.requiresPrescription
            errorText = ""
            errorField = ""
        }
        function save() {
            const result = App.saveProduct({
                isNew: form.isNew,
                id: form.id,
                name: nameField.text,
                code: codeField.text,
                brand: brandField.text,
                category: category,
                price: priceField.text,
                stock: stockField.text,
                expiry: expiryField.text,
                description: descriptionField.text,
                requiresPrescription: prescription
            })
            if (!result.ok) {
                errorText = result.message
                errorField = result.field
                return
            }
            close()
            saved(result.message)
        }
        function status(field: string): string {
            return errorField === field ? "error" : ""
        }

        parent: Basic.Overlay.overlay
        anchors.centerIn: parent
        width: 760
        padding: 0
        modal: true
        focus: true
        closePolicy: Basic.Popup.CloseOnEscape
        Basic.Overlay.modal: Rectangle {
            color: Theme.alpha(Theme.midnight900, 0.45)
        }
        background: Controls.ModalFrame {}
        onOpened: nameField.focusField()
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.overlayDuration }
            NumberAnimation { property: "scale"; from: 0.96; to: 1; duration: Theme.overlayDuration; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.overlayDuration }
        }

        contentItem: Column {
            padding: 36
            spacing: 18
            Item {
                width: 760 - 72
                height: 48
                Column {
                    Controls.PText {
                        ts: Theme.cardTitle
                        text: productForm.form.isNew === true ? "Add product" : "Edit product"
                    }
                    Controls.PText {
                        ts: Theme.meta12
                        color: Theme.textSecondary
                        text: "Product id " + (productForm.form.id !== undefined ? productForm.form.id : "")
                    }
                }
                Controls.IconButton {
                    anchors.right: parent.right
                    iconName: "x"
                    onClicked: productForm.close()
                }
            }
            Controls.ErrorBanner {
                visible: productForm.errorText !== ""
                width: 760 - 72
                text: productForm.errorText
            }
            Grid {
                columns: 2
                columnSpacing: 24
                rowSpacing: 16
                Controls.FormInput {
                    id: nameField
                    width: 332
                    label: "Name"
                    placeholder: "Paracetamol 500 mg Tablets"
                    status: productForm.status("name")
                    onAccepted: productForm.save()
                }
                Controls.FormInput {
                    id: codeField
                    width: 332
                    label: "Code"
                    placeholder: "PAR-500"
                    status: productForm.status("code")
                    onAccepted: productForm.save()
                }
                Controls.FormInput {
                    id: brandField
                    width: 332
                    label: "Brand (optional)"
                    placeholder: "Medix"
                    onAccepted: productForm.save()
                }
                Controls.SelectField {
                    width: 332
                    label: "Category"
                    options: App.productCategories()
                    value: productForm.category
                    status: productForm.status("category")
                    onPicked: (value) => productForm.category = value
                }
                Controls.FormInput {
                    id: priceField
                    width: 332
                    label: "Price (EGP)"
                    placeholder: "325.00"
                    status: productForm.status("price")
                    onAccepted: productForm.save()
                }
                Controls.FormInput {
                    id: stockField
                    width: 332
                    label: "Stock"
                    placeholder: "0"
                    status: productForm.status("stock")
                    onAccepted: productForm.save()
                }
                Controls.FormInput {
                    id: expiryField
                    width: 332
                    label: "Expiry date (optional)"
                    placeholder: "YYYY-MM-DD"
                    maximumLength: 10
                    status: productForm.status("expiry")
                    onAccepted: productForm.save()
                }
                Item {
                    width: 332
                    height: 77
                    Controls.FilterCheckbox {
                        y: 40
                        width: 332
                        text: "Requires a prescription (Rx)"
                        checked: productForm.prescription
                        onToggled: productForm.prescription = !productForm.prescription
                    }
                }
            }
            Controls.FormInput {
                id: descriptionField
                width: 760 - 72
                label: "Description"
                placeholder: "Fast relief from headache and fever"
                maximumLength: 300
                onAccepted: productForm.save()
            }
            Row {
                spacing: 12
                Controls.PcButton {
                    text: productForm.form.isNew === true ? "Add product" : "Save changes"
                    iconName: "check"
                    iconFirst: true
                    onClicked: productForm.save()
                }
                Controls.PcButton {
                    variant: "secondary"
                    text: "Cancel"
                    onClicked: productForm.close()
                }
            }
        }
    }

    // ===================== ORDERS =====================
    component OrdersAdmin: Column {
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

    // ===================== INVENTORY =====================
    component InventoryAdmin: Column {
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

    // Low-stock line with "Add stock" (InventoryManager::increaseStock)
    component StockRow: Rectangle {
        id: stockRow
        required property var modelData
        property string messageText: ""
        height: 72
        radius: Theme.rInput
        color: stockHover.hovered ? Theme.sky50 : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.hoverDuration } }

        function add() {
            const result = App.increaseStock(stockRow.modelData.id, qtyField.text)
            if (result.ok) {
                App.showToast("success", "Stock updated", result.message)
                qtyField.text = ""
            } else {
                messageText = result.message
            }
        }

        Controls.RoundedImage {
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 48
            height: 48
            radius: Theme.rInput
            source: stockRow.modelData.image
        }
        Column {
            x: 72
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Controls.PText {
                ts: Theme.labelStrong
                text: stockRow.modelData.name
            }
            Controls.PText {
                ts: Theme.meta12
                color: stockRow.messageText !== "" ? Theme.error : Theme.textSecondary
                text: stockRow.messageText !== "" ? stockRow.messageText : stockRow.modelData.id + "  ·  " + stockRow.modelData.code
            }
        }
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: stockLabel.implicitWidth + 24
                height: 28
                radius: height / 2
                color: stockRow.modelData.stock === 0 ? Theme.errorBg : Theme.sky100
                Controls.PText {
                    id: stockLabel
                    anchors.centerIn: parent
                    ts: Theme.chip
                    color: stockRow.modelData.stock === 0 ? Theme.error : Theme.royal700
                    text: stockRow.modelData.stock + " in stock"
                }
            }
            Controls.FormInput {
                id: qtyField
                width: 110
                placeholder: "Qty"
                maximumLength: 6
                status: stockRow.messageText !== "" ? "error" : ""
                onTextChanged: stockRow.messageText = ""
                onAccepted: stockRow.add()
            }
            Controls.PcButton {
                anchors.verticalCenter: parent.verticalCenter
                height: 44
                horizontalPadding: 18
                textStyle: Theme.link
                text: "Add stock"
                iconName: "plus"
                iconFirst: true
                onClicked: stockRow.add()
            }
        }
        HoverHandler {
            id: stockHover
        }
    }
}
