// Component mancool men ShopPages.qml 3ashan Qt 6.8/6.9 beyecrash law el list component inline w etnada men file tany.
// Owner: Abdelrhman (GUI)
import QtQuick
import QtQuick.Controls.Basic as Basic

Item {
        id: shop
        width: parent ? parent.width : Theme.designWidth
        implicitHeight: shopColumn.height

        readonly property string category: App.pageParams.category !== undefined ? App.pageParams.category : ""
        readonly property string search: App.pageParams.search !== undefined ? App.pageParams.search : ""
        property string sort: "featured"
        property var selectedBrands: []
        property bool inStockOnly: false

        readonly property var result: App.products(category, search, sort, selectedBrands, inStockOnly)
        readonly property var brandList: App.brands(category, search)
        readonly property var categoryList: App.categories()

        readonly property var subtitles: ({
            "": "Pharmacist-curated medicines, clinical skincare, supplements and medical essentials — all authentic.",
            "Medicines": "Trusted pain relief, allergy, cold & flu care and prescription medicines — dispensed by licensed pharmacists.",
            "Skincare": "Dermatologist-backed serums, cleansers and barrier creams for calm, healthy, luminous skin.",
            "Vitamins & Supplements": "Clinically dosed daily essentials for immunity, energy, beauty and long-term wellbeing.",
            "First Aid & Medical Supplies": "Professional kits, home-care devices and soothing essentials for every household."
        })
        readonly property var sortLabels: ({ "featured": "Featured", "priceAsc": "Price: Low to High", "priceDesc": "Price: High to Low" })

        // Delegate models: each row carries what it shows, plus "owner" for its action
        readonly property var tabModel: categoryList.map((c) => ({
            name: c.name,
            count: c.count,
            selected: search === "" && category === c.name
        }))
        readonly property var brandModel: brandList.map((b) => ({
            name: b.name,
            count: b.count,
            checked: selectedBrands.indexOf(b.name) !== -1,
            owner: shop
        }))
        readonly property var sortModel: ["featured", "priceAsc", "priceDesc"].map((key) => ({
            key: key,
            label: sortLabels[key],
            selected: sort === key,
            owner: shop
        }))

        function selectSort(key: string) {
            sort = key
            sortMenu.close()
        }

        Connections {
            target: App
            function onPageChanged() {
                shop.clearFilters()
            }
        }

        function toggleBrand(name: string) {
            const list = selectedBrands.slice()
            const index = list.indexOf(name)
            if (index === -1)
                list.push(name)
            else
                list.splice(index, 1)
            selectedBrands = list
        }
        function clearFilters() {
            selectedBrands = []
            inStockOnly = false
            sort = "featured"
        }

        Column {
            id: shopColumn
            width: parent.width

            // ---------- Page head ----------
            Item {
                width: parent.width
                height: 40 + headTitles.height + 36
                Controls.GradientFill {
                    anchors.fill: parent
                    direction: "vertical"
                    colors: Theme.gradPageHead
                }
                Item {
                    y: 40
                    width: Theme.contentWidth
                    height: headTitles.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    Column {
                        id: headTitles
                        width: 560
                        spacing: 12
                        Breadcrumb {
                            crumbs: [{ label: "Home", page: "home", params: {} }, { label: "Shop", page: "shop", params: {} }]
                            current: shop.search !== "" ? "Search: “" + shop.search + "”"
                                   : shop.category !== "" ? shop.category : "All Products"
                        }
                        Controls.PText {
                            width: parent.width
                            ts: Theme.pageTitle
                            wrapMode: Text.WordWrap
                            text: shop.search !== "" ? "Results for “" + shop.search + "”"
                                : shop.category !== "" ? shop.category : "Shop all products"
                        }
                        Controls.PText {
                            width: parent.width
                            ts: Theme.body
                            color: Theme.textSecondary
                            wrapMode: Text.WordWrap
                            text: shop.search !== ""
                                  ? shop.result.total + (shop.result.total === 1 ? " product found." : " products found.")
                                  : (shop.subtitles[shop.category] !== undefined ? shop.subtitles[shop.category] : "")
                        }
                    }
                    Controls.SearchBar {
                        id: withinSearch
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        width: 380
                        height: 52
                        placeholder: "Search within products…"
                        onSubmitted: (value) => {
                            if (value.trim() !== "")
                                App.go("shop", { search: value.trim() })
                        }
                    }
                }
            }

            // ---------- Category tabs ----------
            Item {
                width: parent.width
                height: 41 + 28
                Row {
                    width: Theme.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    Controls.CategoryTab {
                        text: "All Products"
                        count: App.allProductsCount()
                        selected: shop.category === "" && shop.search === ""
                        onClicked: App.go("shop")
                    }
                    Repeater {
                        model: shop.tabModel
                        delegate: Controls.CategoryTab {
                            id: tabDelegate
                            required property var modelData
                            text: modelData.name
                            count: modelData.count
                            selected: modelData.selected
                            onClicked: App.go("shop", { category: tabDelegate.modelData.name })
                        }
                    }
                }
            }

            // ---------- Body: sidebar + results ----------
            Item {
                width: parent.width
                height: 8 + Math.max(sidebar.height, results.height) + 80
                Row {
                    y: 8
                    width: Theme.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 40

                    // Sidebar filters
                    Rectangle {
                        id: sidebar
                        width: 280
                        height: sidebarColumn.height + 48
                        radius: Theme.rSidebar
                        color: Theme.white
                        border.width: Theme.borderThin
                        border.color: Theme.borderHairline
                        Column {
                            id: sidebarColumn
                            x: 24
                            y: 24
                            width: parent.width - 48
                            Item {
                                width: parent.width
                                height: 25 + 18
                                Row {
                                    spacing: 8
                                    Controls.Icon {
                                        anchors.verticalCenter: parent.verticalCenter
                                        name: "sliders"
                                        size: 18
                                    }
                                    Controls.PText {
                                        ts: Theme.h4
                                        text: "Filters"
                                    }
                                }
                                Controls.TextLink {
                                    anchors.right: parent.right
                                    y: 4
                                    text: "Clear all"
                                    onClicked: shop.clearFilters()
                                }
                            }
                            // Brand
                            Controls.FilterGroup {
                                visible: shop.brandList.length > 0
                                width: parent.width
                                title: "Brand"
                                Repeater {
                                    model: shop.brandModel
                                    delegate: Controls.FilterCheckbox {
                                        id: brandBox
                                        required property var modelData
                                        width: 232
                                        text: modelData.name
                                        countText: modelData.count
                                        checked: modelData.checked
                                        onToggled: brandBox.modelData.owner.toggleBrand(brandBox.modelData.name)
                                    }
                                }
                            }
                            // Availability
                            Controls.FilterGroup {
                                width: parent.width
                                title: "Availability"
                                Controls.FilterCheckbox {
                                    width: 232
                                    text: "In stock"
                                    countText: shop.result.inStockCount
                                    checked: shop.inStockOnly
                                    onToggled: shop.inStockOnly = !shop.inStockOnly
                                }
                            }
                        }
                    }

                    // Results
                    Column {
                        id: results
                        width: 960
                        spacing: 24
                        Item {
                            width: parent.width
                            height: 44
                            Controls.PText {
                                anchors.verticalCenter: parent.verticalCenter
                                ts: Theme.label
                                color: Theme.textBody
                                text: "Showing " + shop.result.count + " of " + shop.result.total
                                      + (shop.result.total === 1 ? " product" : " products")
                            }
                            Controls.SortTrigger {
                                id: sortTrigger
                                anchors.right: parent.right
                                value: shop.sortLabels[shop.sort]
                                open: sortMenu.opened
                                onClicked: sortMenu.opened ? sortMenu.close() : sortMenu.open()
                            }
                            // Sort menu (overlay under the trigger)
                            Basic.Popup {
                                id: sortMenu
                                x: sortTrigger.x
                                y: sortTrigger.y + sortTrigger.height + 6
                                width: 240
                                padding: 8
                                closePolicy: Basic.Popup.CloseOnEscape | Basic.Popup.CloseOnPressOutsideParent
                                background: Controls.ShadowRect {
                                    radius: Theme.rMenu
                                    color: Theme.white
                                    border.width: Theme.borderThin
                                    border.color: Theme.borderHairline
                                    elevation: "md"
                                }
                                contentItem: Column {
                                    spacing: 2
                                    Repeater {
                                        model: shop.sortModel
                                        delegate: Controls.MenuOption {
                                            id: sortOption
                                            required property var modelData
                                            text: modelData.label
                                            selected: modelData.selected
                                            onClicked: sortOption.modelData.owner.selectSort(sortOption.modelData.key)
                                        }
                                    }
                                }
                            }
                        }
                        Grid {
                            visible: shop.result.count > 0
                            columns: 3
                            columnSpacing: 27
                            rowSpacing: 28
                            Repeater {
                                model: shop.result.items
                                delegate: Controls.ProductCard {
                                    required property var modelData
                                    product: modelData
                                }
                            }
                        }
                        Controls.EmptyState {
                            visible: shop.result.count === 0
                            width: parent.width
                            iconName: "search"
                            title: "No products found"
                            message: shop.search !== ""
                                     ? "Nothing matches “" + shop.search + "”. Try another name or product code."
                                     : "No products match these filters."
                            actionText: shop.search !== "" ? "Show all products" : "Clear filters"
                            onAction: {
                                if (shop.search !== "")
                                    App.go("shop")
                                else
                                    shop.clearFilters()
                            }
                        }
                    }
                }
            }
        }
    }
