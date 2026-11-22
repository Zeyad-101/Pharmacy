// El file da fih safa7at el account: login, register (phase 2), wel profile wel orders (phase 3).
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
            if (next === "checkout")
                App.go("checkout")
            else
                App.go("home")
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
                        text: loginPage.next === "checkout"
                              ? "Sign in to continue to checkout."
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
            if (next === "checkout")
                App.go("checkout")
            else
                App.go("home")
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
}
