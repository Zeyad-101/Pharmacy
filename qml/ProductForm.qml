// Component mancool le file lewa7do 3ashan ne-kasar el cyclic dependency (QML maby2balsh file ye3temed 3ala file beye3temed 3aleh).
// Owner: Abdelrhman (GUI)
import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Dialogs

Basic.Popup {
        id: productForm
        property var form: ({})
        property string category: ""
        property bool prescription: false
        // Product image: what the preview shows, and the newly chosen file (saved with the product)
        property string imageUrl: ""
        property string imageFile: ""
        property string imageError: ""
        property string errorText: ""
        property string errorField: ""
        signal saved(string message)

        FileDialog {
            id: imageDialog
            title: "Choose a product image"
            fileMode: FileDialog.OpenFile
            nameFilters: ["Images (*.png *.jpg *.jpeg)"]
            onAccepted: productForm.chooseImage(selectedFile)
        }

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
            imageUrl = form.image
            imageFile = ""
            imageError = ""
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
                requiresPrescription: prescription,
                imageFile: imageFile
            })
            if (!result.ok) {
                errorText = result.message
                errorField = result.field
                return
            }
            close()
            saved(result.message)
        }
        function chooseImage(file: url) {
            const check = App.checkImageFile(file)
            imageError = check.ok ? "" : check.message
            if (check.ok) {
                imageFile = check.url
                imageUrl = check.url       // the preview updates straight away; choosing again is allowed
            }
        }
        function status(field: string): string {
            return errorField === field ? "error" : ""
        }

        parent: Basic.Overlay.overlay
        anchors.centerIn: parent
        width: 1000
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
                width: 1000 - 72
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
                width: 1000 - 72
                text: productForm.errorText
            }
            Row {
                spacing: 32
                // Product image: preview + native file dialog (PNG / JPG); saved as DATA_DIR/images/<id>.png
                Column {
                    width: 220
                    spacing: 12
                    Controls.PText {
                        ts: Theme.link
                        color: Theme.textLabel
                        text: "Product image"
                    }
                    Rectangle {
                        width: 220
                        height: 220
                        radius: Theme.rOption
                        color: Theme.surfaceTint
                        border.width: productForm.imageError !== "" ? Theme.borderThin : 0
                        border.color: Theme.error
                        Controls.RoundedImage {
                            anchors.fill: parent
                            radius: Theme.rOption
                            source: productForm.imageUrl
                        }
                    }
                    Controls.PcButton {
                        width: 220
                        height: 44
                        variant: "secondary"
                        textStyle: Theme.link
                        text: productForm.imageUrl === "" ? "Upload image" : "Choose another image"
                        iconName: "plus"
                        iconFirst: true
                        onClicked: imageDialog.open()
                    }
                    Controls.PText {
                        width: 220
                        ts: Theme.caption
                        color: productForm.imageError !== "" ? Theme.error : Theme.textSecondary
                        wrapMode: Text.WordWrap
                        text: productForm.imageError !== "" ? productForm.imageError
                            : productForm.imageFile !== "" ? "New image: saved with the product."
                            : "PNG or JPG. Optional; resized to 600 px."
                    }
                }
                Column {
                    width: 676
                    spacing: 18
                    Grid {
                        columns: 2
                        columnSpacing: 24
                        rowSpacing: 16
                        Controls.FormInput {
                            id: nameField
                            width: 326
                            label: "Name"
                            placeholder: "Paracetamol 500 mg Tablets"
                            status: productForm.status("name")
                            onAccepted: productForm.save()
                        }
                        Controls.FormInput {
                            id: codeField
                            width: 326
                            label: "Code"
                            placeholder: "PAR-500"
                            status: productForm.status("code")
                            onAccepted: productForm.save()
                        }
                        Controls.FormInput {
                            id: brandField
                            width: 326
                            label: "Brand (optional)"
                            placeholder: "Medix"
                            onAccepted: productForm.save()
                        }
                        SelectField {
                            width: 326
                            label: "Category"
                            options: App.productCategories()
                            value: productForm.category
                            status: productForm.status("category")
                            onPicked: (value) => productForm.category = value
                        }
                        Controls.FormInput {
                            id: priceField
                            width: 326
                            label: "Price (EGP)"
                            placeholder: "325.00"
                            status: productForm.status("price")
                            onAccepted: productForm.save()
                        }
                        Controls.FormInput {
                            id: stockField
                            width: 326
                            label: "Stock"
                            placeholder: "0"
                            status: productForm.status("stock")
                            onAccepted: productForm.save()
                        }
                        Controls.DateField {
                            id: expiryField
                            width: 326
                            label: "Expiry date (optional)"
                            status: productForm.status("expiry")
                            onAccepted: productForm.save()
                        }
                        Item {
                            width: 326
                            height: 77
                            Controls.FilterCheckbox {
                                y: 40
                                width: 326
                                text: "Requires a prescription (Rx)"
                                checked: productForm.prescription
                                onToggled: productForm.prescription = !productForm.prescription
                            }
                        }
                    }
                    Controls.FormInput {
                        id: descriptionField
                        width: 676
                        label: "Description"
                        placeholder: "Fast relief from headache and fever"
                        maximumLength: 300
                        onAccepted: productForm.save()
                    }
                }
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
