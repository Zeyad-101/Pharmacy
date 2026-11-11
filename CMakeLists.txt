cmake_minimum_required(VERSION 3.16)

project(SmartPharmacy LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core)

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

add_executable(SmartPharmacy
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

target_link_libraries(SmartPharmacy PRIVATE Qt${QT_VERSION_MAJOR}::Core)

include(GNUInstallDirs)
install(TARGETS SmartPharmacy
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
