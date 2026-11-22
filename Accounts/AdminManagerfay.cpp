// El file da mas2ool 3an sala7eyat el admin: add w update w delete lel products, we 3ard el orders.
// Owner: Fayad
#include "Accounts/AdminManagerfay.h"

#include <optional>

#include "Utils/Validationfay.h"

namespace pharmacy {

AdminManager::AdminManager(Authentication& authentication,
                           MedicineManager& medicineManager,
                           OrderRepository& orderRepository)
    : authentication(authentication),
    medicineManager(medicineManager),
    orderRepository(orderRepository)
{
}

bool AdminManager::isAdmin() const
{
    return authentication.isCurrentUserAdmin();
}

AdminResult AdminManager::fromMedicineResult(MedicineResult result)
{
    switch (result) {
    case MedicineResult::Success:
        return AdminResult::Success;
    case MedicineResult::InvalidData:
        return AdminResult::InvalidData;
    case MedicineResult::InvalidCategory:
        return AdminResult::InvalidCategory;
    case MedicineResult::DuplicateId:
        return AdminResult::DuplicateId;
    case MedicineResult::DuplicateCode:
        return AdminResult::DuplicateCode;
    case MedicineResult::NotFound:
        return AdminResult::NotFound;
    case MedicineResult::StorageError:
        return AdminResult::StorageError;
    }
    return AdminResult::StorageError;
}

AdminResult AdminManager::addProduct(const Product& product)
{
    if (!isAdmin()) {
        return AdminResult::NotAuthorized;
    }
    if (!Validation::isValidId(product.getId())) {
        return AdminResult::InvalidData;
    }
    return fromMedicineResult(medicineManager.addMedicine(product));
}

AdminResult AdminManager::updateProduct(const Product& product)
{
    if (!isAdmin()) {
        return AdminResult::NotAuthorized;
    }
    if (!Validation::isValidId(product.getId())) {
        return AdminResult::InvalidData;
    }
    return fromMedicineResult(medicineManager.updateMedicine(product));
}

AdminResult AdminManager::removeProduct(const QString& productId)
{
    if (!isAdmin()) {
        return AdminResult::NotAuthorized;
    }
    if (!Validation::isValidId(productId)) {
        return AdminResult::InvalidData;
    }
    return fromMedicineResult(medicineManager.deleteMedicine(productId));
}

AdminResult AdminManager::getAllOrders(QList<Order>& out) const
{
    out.clear();
    if (!isAdmin()) {
        return AdminResult::NotAuthorized;
    }
    out = orderRepository.getAllOrders();
    return AdminResult::Success;
}

AdminResult AdminManager::getOrderById(const QString& orderId, Order& out) const
{
    if (!isAdmin()) {
        return AdminResult::NotAuthorized;
    }
    if (!Validation::isValidId(orderId)) {
        return AdminResult::InvalidData;
    }
    const std::optional<Order> found = orderRepository.getOrderById(orderId);
    if (!found) {
        return AdminResult::NotFound;
    }
    out = *found;
    return AdminResult::Success;
}

AdminResult AdminManager::getOrdersByCustomerId(const QString& customerId, QList<Order>& out) const
{
    out.clear();
    if (!isAdmin()) {
        return AdminResult::NotAuthorized;
    }
    if (!Validation::isValidId(customerId)) {
        return AdminResult::InvalidData;
    }
    out = orderRepository.getOrdersByCustomer(customerId);
    return AdminResult::Success;
}

}
