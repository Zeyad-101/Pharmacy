// El file da mas2ool 3an sala7eyat el admin: add w update w delete lel products, we 3ard el orders.
// Owner: Fayad
#pragma once

#include <QList>
#include <QString>

#include "Models/Order.h"
#include "Models/Product.h"
#include "Accounts/Authenticationrod.h"
#include "Medicine/MedicineManagerjudy.h"
#include "Repositories/OrderRepositoryfay.h"

namespace pharmacy {

enum class AdminResult
{
    Success,
    NotAuthorized,
    InvalidData,
    InvalidCategory,
    DuplicateId,
    DuplicateCode,
    NotFound,
    StorageError
};

class AdminManager
{
public:
    AdminManager(Authentication& authentication,
                 MedicineManager& medicineManager,
                 OrderRepository& orderRepository);

    AdminResult addProduct(const Product& product);
    AdminResult updateProduct(const Product& product);
    AdminResult removeProduct(const QString& productId);

    AdminResult getAllOrders(QList<Order>& out) const;
    AdminResult getOrderById(const QString& orderId, Order& out) const;
    AdminResult getOrdersByCustomerId(const QString& customerId, QList<Order>& out) const;

private:
    bool isAdmin() const;
    static AdminResult fromMedicineResult(MedicineResult result);

    Authentication& authentication;
    MedicineManager& medicineManager;
    OrderRepository& orderRepository;
};

}
