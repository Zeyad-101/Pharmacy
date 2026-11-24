cmake_minimum_required(VERSION 3.16)

project(SmartPharmacy LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Qt 6.5 or newer (the team uses Qt 6.8 on Windows and Qt 6.11 on macOS)
find_package(Qt6 6.5 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Svg)
qt_standard_project_setup(REQUIRES 6.5)

set(MODEL_FILES
    Models/Address.h
    Models/Address.cpp
    Models/Product.h
    Models/Product.cpp
    Models/User.h
    Models/User.cpp
    Models/CartItem.h
    Models/CartItem.cpp
    Models/PromoCode.h
    Models/PromoCode.cpp
    Models/Order.h
    Models/Order.cpp
)

set(MEDICINE_FILES
    Medicine/MedicineManagerjudy.h
    Medicine/MedicineManagerjudy.cpp
    Medicine/CategoryManagerjudy.h
    Medicine/CategoryManagerjudy.cpp
)

set(INVENTORY_FILES
    Inventory/InventoryManagerheba.h
    Inventory/InventoryManagerheba.cpp
)

set(SHOPPING_FILES
    Shopping/CartManagerhazem.h
    Shopping/CartManagerhazem.cpp
    Shopping/PromoCodeManagerhazem.h
    Shopping/PromoCodeManagerhazem.cpp
    Shopping/CheckoutManagerabdel.h
    Shopping/CheckoutManagerabdel.cpp
    Shopping/OrderManagerabdel.h
    Shopping/OrderManagerabdel.cpp
)

set(ACCOUNT_FILES
    Accounts/UserManagerrod.h
    Accounts/UserManagerrod.cpp
    Accounts/Authenticationrod.h
    Accounts/Authenticationrod.cpp
    Accounts/AdminManagerfay.h
    Accounts/AdminManagerfay.cpp
)

set(REPOSITORY_FILES
    Repositories/ProductRepositoryheba.h
    Repositories/ProductRepositoryheba.cpp
    Repositories/UserRepositoryrod.h
    Repositories/UserRepositoryrod.cpp
    Repositories/OrderRepositoryfay.h
    Repositories/OrderRepositoryfay.cpp
    Repositories/PromoCodeRepositoryhazem.h
    Repositories/PromoCodeRepositoryhazem.cpp
)

set(UTILS_FILES
    Utils/Validationfay.h
    Utils/Validationfay.cpp
)

qt_add_executable(SmartPharmacy
  main.cpp
  ${MODEL_FILES}
  ${MEDICINE_FILES}
  ${INVENTORY_FILES}
  ${SHOPPING_FILES}
  ${ACCOUNT_FILES}
  ${REPOSITORY_FILES}
  ${UTILS_FILES}
)

target_include_directories(SmartPharmacy PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/Models
)

target_compile_definitions(SmartPharmacy PRIVATE DATA_DIR="${CMAKE_CURRENT_SOURCE_DIR}/Data")

# GUI (QML): the C++ bridge, the QML files and the images / icons / fonts
set_source_files_properties(qml/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
# Put every QML file at the root of the module, so they see each other and the App singleton.
# The list components (Repeater/ListView/...) live in their own files, because Qt 6.8/6.9 crash
# when such an inline component is instantiated from another file (fine again on Qt >= 6.10.3).
set(GUI_QML_NAMES
    Main Theme Controls ShopPages CheckoutPages AccountPages AdminPages
    HomePage ShopPage ProductPage SearchSuggestions
    CartPage CartDrawer CheckoutPage ConfirmationPage
    OrdersList OrderDetailsPage
    Dashboard OrderRow ProductsAdmin OrdersAdmin InventoryAdmin
    Breadcrumb SpecTable CheckoutStepper StatusTracker SelectField HeaderDesktop FooterDesktop
    PageHead ProductForm StockRow
)
foreach(qml_file ${GUI_QML_NAMES})
    set_source_files_properties(qml/${qml_file}.qml PROPERTIES QT_RESOURCE_ALIAS ${qml_file}.qml)
endforeach()
set(GUI_QML_FILES "")
foreach(qml_file ${GUI_QML_NAMES})
    list(APPEND GUI_QML_FILES qml/${qml_file}.qml)
endforeach()

file(GLOB GUI_IMAGES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS Resources/images/*.png)
file(GLOB GUI_ICONS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS Resources/icons/*.svg)
file(GLOB GUI_FONTS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS Resources/fonts/*.ttf)

qt_add_qml_module(SmartPharmacy
    URI PharmaCare
    VERSION 1.0
    QML_FILES
        ${GUI_QML_FILES}
    SOURCES
        AppController.h
        AppController.cpp
    RESOURCES
        ${GUI_IMAGES}
        ${GUI_ICONS}
        ${GUI_FONTS}
)

# Windows: a normal GUI app (no console window). macOS: a plain executable, so DATA_DIR keeps working.
set_target_properties(SmartPharmacy PROPERTIES
    WIN32_EXECUTABLE ON
    MACOSX_BUNDLE OFF
)

target_link_libraries(SmartPharmacy PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Svg
)

include(GNUInstallDirs)
install(TARGETS SmartPharmacy
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
