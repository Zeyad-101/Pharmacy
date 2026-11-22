// El file da fih safa7at el account: login, register, el profile, taghyeer el password, talabaty (My orders) w tafaseel el talab.
// Owner: Abdelrhman (GUI)
import QtQuick

QtObject {

    // ===================== SIGN IN =====================
    // Not in the Penpot file: built from the design system (step card, form inputs, error banner, primary button)
    component LoginPage: Item {
        id: loginPage
        width: parent ? parent.width : Theme.designWidth
        implicitHeight: loginCard.height + 72 + 96

        readonly property string next: App.pageParams.next !== undefined ? App.pageParams.next : ""
        property string errorText: ""
        property bool tried: false

        function submit() {
            tried = true
            const result = App.login(identityField.text, passwordField.text)
            if (!result.ok) {
                errorText = result.message
                return
            }
            errorText = ""
            App.showToast("success", "Signed in", result.message)
            // Back to where the user was going (an admin sent to checkout ends on the dashboard: App.go decides)
            if (next !== "")
                App.go(next)
            else
                App.go(App.isAdmin ? "admin" : "home")
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.surfaceTint
        }
        Controls.ShadowRect {
            id: loginCard
            y: 72
            anchors.horizontalCenter: parent.horizontalCenter
            width: 520
            height: loginColumn.height + 80
            radius: Theme.rModal
            color: Theme.white
            border.width: Theme.borderThin
            border.color: Theme.borderHairline
            elevation: "sm"
            Column {
                id: loginColumn
                x: 40
                y: 40
                width: parent.width - 80
                spacing: 24
                Column {
                    width: parent.width
                    spacing: 6
                    Controls.PText {
                        ts: Theme.overline
                        color: Theme.accent
                        text: "Your account"
                    }
                    Controls.PText {
                        ts: Theme.cardTitle
                        text: "Sign in"
                    }
                    Controls.PText {
                        width: parent.width
                        ts: Theme.body
                        color: Theme.textSecondary
                        wrapMode: Text.WordWrap
                        text: loginPage.next === "checkout" ? "Sign in to continue to checkout."
                            : loginPage.next === "admin" ? "Sign in with an admin account to manage the shop."
                            : loginPage.next === "account" ? "Sign in to see your account and your orders."
                            : "Sign in to check out and follow your orders."
                    }
                }
                Controls.ErrorBanner {
                    visible: loginPage.errorText !== ""
                    width: parent.width
                    text: loginPage.errorText
                }
                Controls.FormInput {
                    id: identityField
                    width: parent.width
                    label: "Email or username"
                    placeholder: "you@example.com"
                    status: loginPage.tried && loginPage.errorText !== "" && text.trim() === "" ? "error" : ""
                    onAccepted: passwordField.focusField()
                    Component.onCompleted: focusField()
                }
                Controls.FormInput {
                    id: passwordField
                    width: parent.width
                    label: "Password"
                    placeholder: "Your password"
                    password: true
                    status: loginPage.tried && loginPage.errorText !== "" && text === "" ? "error" : ""
                    onAccepted: loginPage.submit()
                }
                Controls.PcButton {
                    width: parent.width
                    height: 56
                    text: "Sign in"
                    iconName: "arrowR"
                    onClicked: loginPage.submit()
                }
                Controls.Divider {
                    width: parent.width
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6
                    Controls.PText {
                        ts: Theme.small13
                        color: Theme.textBody
                        text: "New to PharmaCare?"
                    }
                    Controls.TextLink {
                        textStyle: Theme.linkBold
                        text: "Create an account"
                        onClicked: App.go("register", { next: loginPage.next })
                    }
                }
            }
        }
    }

    // ===================== CREATE ACCOUNT =====================
    component RegisterPage: Item {
        id: registerPage
        width: parent ? parent.width : Theme.designWidth
        implicitHeight: registerCard.height + 72 + 96

        readonly property string next: App.pageParams.next !== undefined ? App.pageParams.next : ""
        property string errorText: ""
        property string errorField: ""
        property bool tried: false

        // Live field states use the backend rules (Validation via App.isValidField)
        function fieldStatus(kind: string, value: string): string {
            if (!tried)
                return ""
            if (errorField === kind)
                return "error"
            return App.isValidField(kind, value) ? "success" : "error"
        }
        function submit() {
            tried = true
            const result = App.registerCustomer({
                username: usernameField.text,
                email: emailField.text,
                phone: phoneField.text,
                password: passwordField.text,
                city: cityField.text,
                street: streetField.text,
                building: buildingField.text,
                apartment: apartmentField.text,
                postalCode: postalField.text
            })
            if (!result.ok) {
                errorText = result.message
                errorField = result.field
                return
            }
            errorText = ""
            errorField = ""
            App.showToast("success", "Account created", "Welcome to PharmaCare, " + App.currentUserName + ".")
            App.go(next !== "" ? next : "home")
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.surfaceTint
        }
        Controls.ShadowRect {
            id: registerCard
            y: 72
            anchors.horizontalCenter: parent.horizontalCenter
            width: 792
            height: registerColumn.height + 80
            radius: Theme.rModal
            color: Theme.white
            border.width: Theme.borderThin
            border.color: Theme.borderHairline
            elevation: "sm"
            Column {
                id: registerColumn
                x: 40
                y: 40
                width: parent.width - 80
                spacing: 28
                Column {
                    width: parent.width
                    spacing: 6
                    Controls.PText {
                        ts: Theme.overline
                        color: Theme.accent
                        text: "Your account"
                    }
                    Controls.PText {
                        ts: Theme.cardTitle
                        text: "Create your account"
                    }
                    Controls.PText {
                        width: parent.width
                        ts: Theme.body
                        color: Theme.textSecondary
                        wrapMode: Text.WordWrap
                        text: "Check out faster and follow every order from placed to delivered."
                    }
                }
                Controls.ErrorBanner {
                    visible: registerPage.errorText !== ""
                    width: parent.width
                    text: registerPage.errorText
                }
                Row {
                    spacing: 24
                    Controls.FormInput {
                        id: usernameField
                        width: 344
                        label: "Username"
                        placeholder: "Choose a username"
                        status: registerPage.fieldStatus("username", text)
                        onAccepted: emailField.focusField()
                        Component.onCompleted: focusField()
                    }
                    Controls.FormInput {
                        id: phoneField
                        width: 344
                        label: "Phone number"
                        placeholder: "01XXXXXXXXX"
                        maximumLength: 11
                        status: registerPage.fieldStatus("phone", text)
                        helper: status === "error" ? "11 digits, starting with 01" : ""
                        onAccepted: emailField.focusField()
                    }
                }
                Row {
                    spacing: 24
                    Controls.FormInput {
                        id: emailField
                        width: 344
                        label: "Email address"
                        placeholder: "you@example.com"
                        status: registerPage.fieldStatus("email", text)
                        helper: status === "error" ? "Please enter a valid email address" : ""
                        onAccepted: passwordField.focusField()
                    }
                    Controls.FormInput {
                        id: passwordField
                        width: 344
                        label: "Password"
                        placeholder: "At least 8 characters"
                        password: true
                        status: registerPage.fieldStatus("password", text)
                        helper: status === "error" ? "At least 8 characters" : ""
                        onAccepted: registerPage.submit()
                    }
                }
                Column {
                    width: parent.width
                    spacing: 6
                    Controls.PText {
                        ts: Theme.h4
                        text: "Delivery address (optional)"
                    }
                    Controls.PText {
                        width: parent.width
                        ts: Theme.bodyS
                        color: Theme.textSecondary
                        wrapMode: Text.WordWrap
                        text: "Save it now to fill in the checkout for you. City, street and building are needed if you add one."
                    }
                }
                Row {
                    spacing: 24
                    Controls.FormInput {
                        id: cityField
                        width: 344
                        label: "City"
                        placeholder: "Cairo"
                        status: registerPage.errorField === "address" ? "error" : ""
                    }
                    Controls.FormInput {
                        id: postalField
                        width: 344
                        label: "Postal code"
                        placeholder: "11511"
                        maximumLength: 10
                    }
                }
                Controls.FormInput {
                    id: streetField
                    width: parent.width
                    label: "Street address"
                    placeholder: "Street name and area"
                    status: registerPage.errorField === "address" ? "error" : ""
                }
                Row {
                    spacing: 24
                    Controls.FormInput {
                        id: buildingField
                        width: 344
                        label: "Building number"
                        placeholder: "12"
                        status: registerPage.errorField === "address" ? "error" : ""
                    }
                    Controls.FormInput {
                        id: apartmentField
                        width: 344
                        label: "Apartment / Unit"
                        placeholder: "Apt 4"
                        onAccepted: registerPage.submit()
                    }
                }
                Item {
                    width: parent.width
                    height: 56
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6
                        Controls.PText {
                            ts: Theme.small13
                            color: Theme.textBody
                            text: "Already have an account?"
                        }
                        Controls.TextLink {
                            textStyle: Theme.linkBold
                            text: "Sign in"
                            onClicked: App.go("login", { next: registerPage.next })
                        }
                    }
                    Controls.PcButton {
                        anchors.right: parent.right
                        height: 56
                        horizontalPadding: 32
                        text: "Create account"
                        iconName: "arrowR"
                        onClicked: registerPage.submit()
                    }
                }
            }
        }
    }

    // ===================== MY ACCOUNT (profile · my orders · change password) =====================
    // Not in the Penpot file: page head + side navigation + panels, all from the design system
    component AccountPage: Item {
        id: account
        width: parent ? parent.width : Theme.designWidth
        implicitHeight: accountColumn.height + 96

        readonly property string tab: App.pageParams.tab !== undefined ? App.pageParams.tab : "profile"
        property var profile: App.currentUserProfile()
        property var orders: App.myOrders()

        function refresh() {
            profile = App.currentUserProfile()
            orders = App.myOrders()
        }
        Connections {
            target: App
            function onDataChanged() {
                account.refresh()
            }
            function onSessionChanged() {
                account.refresh()
            }
        }

        Column {
            id: accountColumn
            y: 36
            x: (parent.width - Theme.contentWidth) / 2
            width: Theme.contentWidth
            spacing: 40
            Controls.PageHead {
                current: "My account"
                title: "My account"
                subtitle: account.profile.ok === true ? "Hello, " + account.profile.username + ". Manage your details and follow your orders." : ""
            }
            Row {
                spacing: 48
                // ---------- Side navigation ----------
                Controls.Panel {
                    width: 280
                    height: sideColumn.height + 32
                    Column {
                        id: sideColumn
                        x: 16
                        y: 16
                        width: parent.width - 32
                        spacing: 4
                        Row {
                            leftPadding: 8
                            bottomPadding: 12
                            spacing: 12
                            Rectangle {
                                width: 48
                                height: 48
                                radius: height / 2
                                color: Theme.surfaceTint
                                Controls.Icon {
                                    anchors.centerIn: parent
                                    name: "user"
                                    size: 22
                                    color: Theme.royal600
                                }
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Controls.PText {
                                    width: 180
                                    ts: Theme.labelStrong
                                    elide: Text.ElideRight
                                    text: account.profile.ok === true ? account.profile.username : ""
                                }
                                Controls.PText {
                                    width: 180
                                    ts: Theme.meta12
                                    color: Theme.textSecondary
                                    elide: Text.ElideRight
                                    text: account.profile.ok === true ? account.profile.email : ""
                                }
                            }
                        }
                        Controls.NavItem {
                            text: "Profile"
                            iconName: "user"
                            selected: account.tab === "profile"
                            onClicked: App.go("account", { tab: "profile" })
                        }
                        Controls.NavItem {
                            visible: !App.isAdmin
                            text: "My orders"
                            iconName: "bag"
                            selected: account.tab === "orders"
                            onClicked: App.go("account", { tab: "orders" })
                        }
                        Controls.NavItem {
                            text: "Change password"
                            iconName: "lock"
                            selected: account.tab === "password"
                            onClicked: App.go("account", { tab: "password" })
                        }
                        Controls.NavItem {
                            visible: App.isAdmin
                            text: "Admin dashboard"
                            iconName: "grid"
                            onClicked: App.go("admin")
                        }
                        Controls.Divider {
                            width: parent.width
                        }
                        Controls.NavItem {
                            text: "Sign out"
                            iconName: "arrowL"
                            danger: true
                            onClicked: {
                                App.logout()
                                App.showToast("info", "Signed out", "See you soon.")
                                App.go("home")
                            }
                        }
                    }
                }
                // ---------- Content (the selected tab) ----------
                Column {
                    width: Theme.contentWidth - 280 - 48
                    ProfileForm {
                        visible: account.tab !== "orders" && account.tab !== "password"
                        width: parent.width
                        profile: account.profile
                    }
                    PasswordForm {
                        visible: account.tab === "password"
                        width: parent.width
                    }
                    OrdersList {
                        visible: account.tab === "orders"
                        width: parent.width
                        orders: account.orders
                    }
                }
            }
        }
    }

    // Profile: username, phone, email and the saved delivery address (UserManager::updateProfile)
    component ProfileForm: Controls.Panel {
        id: profileForm
        property var profile: ({})
        property string messageText: ""
        property bool success: false
        property string errorField: ""
        width: parent ? parent.width : 952
        height: profileColumn.height + 80

        function load() {
            if (profile.ok !== true)
                return
            usernameField.text = profile.username
            phoneField.text = profile.phone
            emailField.text = profile.email
            cityField.text = profile.address.city
            postalField.text = profile.address.postalCode
            streetField.text = profile.address.street
            buildingField.text = profile.address.building
            apartmentField.text = profile.address.apartment
        }
        function save() {
            const result = App.updateProfile({
                username: usernameField.text,
                phone: phoneField.text,
                email: emailField.text,
                city: cityField.text,
                postalCode: postalField.text,
                street: streetField.text,
                building: buildingField.text,
                apartment: apartmentField.text
            })
            success = result.ok
            messageText = result.message
            errorField = result.ok ? "" : result.field
            if (result.ok)
                App.showToast("success", "Profile saved", result.message)
        }
        function fieldStatus(kind: string): string {
            return errorField === kind ? "error" : ""
        }
        Component.onCompleted: load()

        Column {
            id: profileColumn
            x: 40
            y: 40
            width: parent.width - 80
            spacing: 24
            Column {
                width: parent.width
                spacing: 6
                Controls.PText {
                    ts: Theme.h3
                    text: "Profile details"
                }
                Controls.PText {
                    width: parent.width
                    ts: Theme.bodyS
                    color: Theme.textSecondary
                    wrapMode: Text.WordWrap
                    text: "These details are used for your orders. The address fills in the checkout for you."
                }
            }
            Controls.ErrorBanner {
                visible: profileForm.messageText !== ""
                width: parent.width
                success: profileForm.success
                text: profileForm.messageText
            }
            Row {
                spacing: 24
                Controls.FormInput {
                    id: usernameField
                    width: (profileColumn.width - 24) / 2
                    label: "Username"
                    placeholder: "Your username"
                    status: profileForm.fieldStatus("username")
                    onAccepted: profileForm.save()
                }
                Controls.FormInput {
                    id: phoneField
                    width: (profileColumn.width - 24) / 2
                    label: "Phone number"
                    placeholder: "01XXXXXXXXX"
                    maximumLength: 11
                    status: profileForm.fieldStatus("phone")
                    helper: status === "error" ? "11 digits, starting with 01" : ""
                    onAccepted: profileForm.save()
                }
            }
            Controls.FormInput {
                id: emailField
                width: parent.width
                label: "Email address"
                placeholder: "you@example.com"
                status: profileForm.fieldStatus("email")
                onAccepted: profileForm.save()
            }
            Controls.Divider {
                width: parent.width
            }
            Column {
                width: parent.width
                spacing: 6
                Controls.PText {
                    ts: Theme.h4
                    text: "Delivery address"
                }
                Controls.PText {
                    width: parent.width
                    ts: Theme.bodyS
                    color: Theme.textSecondary
                    wrapMode: Text.WordWrap
                    text: "City, street and building are needed if you add one. Leave all of them empty to remove it."
                }
            }
            Row {
                spacing: 24
                Controls.FormInput {
                    id: cityField
                    width: (profileColumn.width - 24) / 2
                    label: "City"
                    placeholder: "Cairo"
                    status: profileForm.fieldStatus("address")
                    onAccepted: profileForm.save()
                }
                Controls.FormInput {
                    id: postalField
                    width: (profileColumn.width - 24) / 2
                    label: "Postal code (optional)"
                    placeholder: "11511"
                    maximumLength: 10
                    onAccepted: profileForm.save()
                }
            }
            Controls.FormInput {
                id: streetField
                width: parent.width
                label: "Street address"
                placeholder: "Street name and area"
                status: profileForm.fieldStatus("address")
                onAccepted: profileForm.save()
            }
            Row {
                spacing: 24
                Controls.FormInput {
                    id: buildingField
                    width: (profileColumn.width - 24) / 2
                    label: "Building number"
                    placeholder: "12"
                    status: profileForm.fieldStatus("address")
                    onAccepted: profileForm.save()
                }
                Controls.FormInput {
                    id: apartmentField
                    width: (profileColumn.width - 24) / 2
                    label: "Apartment / Unit (optional)"
                    placeholder: "Apt 4"
                    onAccepted: profileForm.save()
                }
            }
            Row {
                spacing: 12
                Controls.PcButton {
                    height: 56
                    horizontalPadding: 32
                    text: "Save changes"
                    iconName: "check"
                    iconFirst: true
                    onClicked: profileForm.save()
                }
                Controls.PcButton {
                    height: 56
                    variant: "secondary"
                    text: "Undo changes"
                    onClicked: {
                        profileForm.messageText = ""
                        profileForm.errorField = ""
                        profileForm.load()
                    }
                }
            }
        }
    }

    // Change password (UserManager::changePassword: the current password must match, the new one 8+ characters)
    component PasswordForm: Controls.Panel {
        id: passwordForm
        property string messageText: ""
        property bool success: false
        property string errorField: ""
        width: parent ? parent.width : 952
        height: passwordColumn.height + 80

        function submit() {
            const result = App.changePassword(currentField.text, newField.text, confirmField.text)
            success = result.ok
            messageText = result.message
            errorField = result.ok ? "" : result.field
            if (result.ok) {
                currentField.text = ""
                newField.text = ""
                confirmField.text = ""
                App.showToast("success", "Password changed", result.message)
            }
        }

        Column {
            id: passwordColumn
            x: 40
            y: 40
            width: parent.width - 80
            spacing: 24
            Column {
                width: parent.width
                spacing: 6
                Controls.PText {
                    ts: Theme.h3
                    text: "Change password"
                }
                Controls.PText {
                    width: parent.width
                    ts: Theme.bodyS
                    color: Theme.textSecondary
                    text: "Use at least 8 characters."
                }
            }
            Controls.ErrorBanner {
                visible: passwordForm.messageText !== ""
                width: parent.width
                success: passwordForm.success
                text: passwordForm.messageText
            }
            Controls.FormInput {
                id: currentField
                width: 440
                label: "Current password"
                placeholder: "Your current password"
                password: true
                status: passwordForm.errorField === "currentPassword" ? "error" : ""
                onAccepted: newField.focusField()
                Component.onCompleted: if (passwordForm.visible) focusField()
            }
            Controls.FormInput {
                id: newField
                width: 440
                label: "New password"
                placeholder: "At least 8 characters"
                password: true
                status: passwordForm.errorField === "newPassword" ? "error" : ""
                onAccepted: confirmField.focusField()
            }
            Controls.FormInput {
                id: confirmField
                width: 440
                label: "Confirm new password"
                placeholder: "Type the new password again"
                password: true
                status: passwordForm.errorField === "confirmPassword" ? "error" : ""
                onAccepted: passwordForm.submit()
            }
            Controls.PcButton {
                height: 56
                horizontalPadding: 32
                text: "Change password"
                iconName: "lock"
                iconFirst: true
                onClicked: passwordForm.submit()
            }
        }
    }

    // My orders: newest first, status chip, total, link to the details
    component OrdersList: Column {
        id: ordersList
        property var orders: []
        width: parent ? parent.width : 952
        spacing: 16

        Controls.EmptyState {
            visible: ordersList.orders.length === 0
            width: parent.width
            iconName: "bag"
            title: App.isAdmin ? "Admins do not place orders" : "No orders yet"
            message: App.isAdmin ? "Customer orders are in the admin area." : "When you place an order it appears here, with its status from placed to delivered."
            actionText: App.isAdmin ? "Open admin orders" : "Start shopping"
            onAction: App.isAdmin ? App.go("admin", { tab: "orders" }) : App.go("shop")
        }
        Repeater {
            model: ordersList.orders
            delegate: Rectangle {
                id: orderRow
                required property var modelData
                width: parent ? parent.width : 0
                height: 112
                radius: Theme.rPanel
                color: rowHover.hovered ? Theme.sky50 : Theme.white
                border.width: Theme.borderThin
                border.color: rowHover.hovered ? Theme.sky200 : Theme.borderHairline
                Behavior on color { ColorAnimation { duration: Theme.hoverDuration } }
                // Up to three product thumbnails, overlapping
                Item {
                    x: 24
                    anchors.verticalCenter: parent.verticalCenter
                    width: 64 + 28 * 2
                    height: 64
                    Repeater {
                        model: orderRow.modelData.images
                        delegate: Rectangle {
                            id: thumbFrame
                            required property string modelData
                            required property int index
                            x: index * 28
                            width: 64
                            height: 64
                            radius: Theme.rInput
                            color: Theme.white
                            border.width: 2
                            border.color: Theme.white
                            Controls.RoundedImage {
                                anchors.fill: parent
                                anchors.margins: 2
                                radius: Theme.rInput - 2
                                source: thumbFrame.modelData
                            }
                        }
                    }
                }
                Column {
                    x: 24 + 120 + 20
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    Row {
                        spacing: 12
                        Controls.PText {
                            anchors.verticalCenter: parent.verticalCenter
                            ts: Theme.cardLine
                            text: "Order #" + orderRow.modelData.orderId
                        }
                        Controls.StatusChip {
                            anchors.verticalCenter: parent.verticalCenter
                            status: orderRow.modelData.status
                            text: orderRow.modelData.statusLabel
                        }
                    }
                    Controls.PText {
                        ts: Theme.small13Regular
                        color: Theme.textSecondary
                        text: orderRow.modelData.createdText + "  ·  " + orderRow.modelData.count
                              + (orderRow.modelData.count === 1 ? " item" : " items")
                    }
                }
                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 24
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 24
                    Controls.PText {
                        anchors.verticalCenter: parent.verticalCenter
                        ts: Theme.price
                        text: orderRow.modelData.totalText
                    }
                    Controls.TextLink {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "View details"
                        iconName: "arrowR"
                        iconAfter: true
                        onClicked: App.go("orderDetails", { orderId: orderRow.modelData.orderId })
                    }
                }
                HoverHandler {
                    id: rowHover
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: App.go("orderDetails", { orderId: orderRow.modelData.orderId })
                }
            }
        }
    }

    // ===================== ORDER DETAILS =====================
    // Same blocks as the Order Confirmation board (tracker, shipping, summary) + Cancel when OrderManager allows it
    component OrderDetailsPage: Item {
        id: details
        width: parent ? parent.width : Theme.designWidth
        implicitHeight: detailsColumn.height + 96

        readonly property string orderId: App.pageParams.orderId !== undefined ? App.pageParams.orderId : ""
        property var orderData: App.order(orderId)
        readonly property bool found: orderData.ok === true

        function refresh() {
            orderData = App.order(orderId)
        }
        function cancelOrder() {
            const result = App.cancelMyOrder(orderId)
            App.showToast(result.ok ? "success" : "error", result.ok ? "Order cancelled" : "Could not cancel the order", result.message)
            refresh()
        }
        Connections {
            target: App
            function onDataChanged() {
                details.refresh()
            }
        }

        Column {
            id: detailsColumn
            y: 36
            x: (parent.width - Theme.contentWidth) / 2
            width: Theme.contentWidth
            spacing: 32
            Controls.PageHead {
                crumbs: [{ label: "Home", page: "home", params: {} },
                         { label: App.isAdmin ? "Admin orders" : "My orders", page: App.isAdmin ? "admin" : "account",
                           params: App.isAdmin ? { tab: "orders" } : { tab: "orders" } }]
                current: details.found ? "Order #" + details.orderId : "Order"
                title: details.found ? "Order #" + details.orderId : "Order not found"
                subtitle: details.found ? "Placed " + details.orderData.createdText + "  ·  " + details.orderData.count
                                          + (details.orderData.count === 1 ? " item" : " items") : ""
            }
            Controls.EmptyState {
                visible: !details.found
                width: parent.width
                iconName: "bag"
                title: "We could not find this order"
                message: details.orderData.message !== undefined ? details.orderData.message : ""
                actionText: "Back to my orders"
                onAction: App.go("account", { tab: "orders" })
            }
            Row {
                visible: details.found
                spacing: 40
                Column {
                    width: 780
                    spacing: 24
                    Controls.Panel {
                        width: parent.width
                        height: trackColumn.height + 64
                        Column {
                            id: trackColumn
                            x: 32
                            y: 32
                            width: parent.width - 64
                            spacing: 24
                            Item {
                                width: parent.width
                                height: 32
                                Controls.PText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    ts: Theme.h3
                                    text: "Order status"
                                }
                                Controls.StatusChip {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    status: details.found ? details.orderData.status : "pending"
                                    text: details.found ? details.orderData.statusLabel : ""
                                }
                            }
                            Controls.StatusTracker {
                                width: parent.width
                                status: details.found ? details.orderData.status : "pending"
                                placedText: details.found ? details.orderData.dateShortText : ""
                            }
                        }
                    }
                    Rectangle {
                        width: parent.width
                        height: shipCol.height + 40
                        radius: Theme.rOption
                        color: Theme.surfaceTint
                        Column {
                            id: shipCol
                            x: 20
                            y: 20
                            width: parent.width - 40
                            spacing: 10
                            Row {
                                spacing: 8
                                Controls.Icon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    name: "pin"
                                    size: 16
                                    color: Theme.royal600
                                }
                                Controls.PText {
                                    ts: Theme.linkBold
                                    text: "Shipping to"
                                }
                            }
                            Controls.PText {
                                width: parent.width
                                ts: Theme.bodyS
                                color: Theme.textBody
                                wrapMode: Text.WordWrap
                                text: details.found ? details.orderData.address.line1 + "\n" + details.orderData.address.line2 : ""
                            }
                        }
                    }
                    // Cancel: only offered while OrderManager allows it (pending, confirmed, processing)
                    Controls.Panel {
                        visible: details.found && !App.isAdmin
                        width: parent.width
                        height: 96
                        Column {
                            x: 28
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 28 - cancelButton.width - 56
                            spacing: 4
                            Controls.PText {
                                ts: Theme.labelStrong
                                text: details.orderData.canCancel === true ? "Need to change something?" : "This order can no longer be cancelled"
                            }
                            Controls.PText {
                                width: parent.width
                                ts: Theme.small13Regular
                                color: Theme.textSecondary
                                elide: Text.ElideRight
                                text: details.orderData.canCancel === true
                                      ? "You can cancel until the order is shipped. The items go back into stock."
                                      : details.orderData.status === "cancelled" ? "It has already been cancelled."
                                      : "It has already been shipped."
                            }
                        }
                        Controls.PcButton {
                            id: cancelButton
                            anchors.right: parent.right
                            anchors.rightMargin: 28
                            anchors.verticalCenter: parent.verticalCenter
                            variant: "secondary"
                            text: "Cancel order"
                            iconName: "x"
                            iconFirst: true
                            enabled: details.orderData.canCancel === true
                            onClicked: cancelDialog.open()
                        }
                    }
                }
                Controls.ShadowRect {
                    width: 460
                    height: summaryColumn.height + 56
                    radius: Theme.rModal
                    color: Theme.white
                    border.width: Theme.borderThin
                    border.color: Theme.borderHairline
                    elevation: "sm"
                    Column {
                        id: summaryColumn
                        x: 28
                        y: 28
                        width: parent.width - 56
                        spacing: 16
                        Controls.PText {
                            ts: Theme.h4
                            text: "Order summary"
                        }
                        Repeater {
                            model: details.found ? details.orderData.items : []
                            delegate: Item {
                                id: itemRow
                                required property var modelData
                                width: parent ? parent.width : 0
                                height: 56
                                Controls.RoundedImage {
                                    width: 56
                                    height: 56
                                    radius: Theme.rInput
                                    source: itemRow.modelData.image
                                }
                                Column {
                                    x: 70
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 70 - 110
                                    spacing: 2
                                    Controls.PText {
                                        width: parent.width
                                        ts: Theme.labelStrong
                                        elide: Text.ElideRight
                                        text: itemRow.modelData.name
                                    }
                                    Controls.PText {
                                        ts: Theme.meta12
                                        color: Theme.textSecondary
                                        text: "Qty " + itemRow.modelData.quantity + " · " + itemRow.modelData.unitPriceText + " each"
                                    }
                                }
                                Controls.PText {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    ts: Theme.valueStrong
                                    text: itemRow.modelData.lineTotalText
                                }
                            }
                        }
                        Controls.Divider {
                            width: parent.width
                        }
                        Controls.SummaryRow {
                            width: parent.width
                            compact: true
                            label: "Subtotal"
                            value: details.found ? details.orderData.subtotalText : ""
                        }
                        Controls.SummaryRow {
                            visible: details.found && details.orderData.hasDiscount
                            width: parent.width
                            compact: true
                            label: "Discount · " + (details.found ? details.orderData.promoCode : "")
                            value: details.found ? details.orderData.discountText : ""
                            valueColor: Theme.royal600
                        }
                        Controls.Divider {
                            width: parent.width
                        }
                        Item {
                            width: parent.width
                            height: 36
                            Controls.PText {
                                anchors.verticalCenter: parent.verticalCenter
                                ts: Theme.totalLabel
                                text: "Total"
                            }
                            Controls.PText {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                ts: Theme.totalPrice
                                text: details.found ? details.orderData.totalText : ""
                            }
                        }
                    }
                }
            }
        }

        Controls.ConfirmDialog {
            id: cancelDialog
            title: "Cancel order #" + details.orderId + "?"
            message: "The order will be cancelled and the items go back into stock. This cannot be undone."
            confirmText: "Cancel order"
            cancelText: "Keep order"
            onConfirmed: details.cancelOrder()
        }
    }
}
