// El file da mas2ool 3an edaret el orders: create, get, change status, cancel.   // Owner: Abdelrahman
#pragma once

#include <QList>
#include <QString>
#include <optional>

#include "Models/Order.h"

namespace pharmacy {

class OrderRepository;
class InventoryManager;

enum class OrderResult {
    Success,
    InvalidOrder,
    DuplicateOrder,
    NotFound,
    InvalidTransition,
    StorageError
};

class OrderManager
{
public:
    OrderManager(OrderRepository& orderRepository, InventoryManager& inventory);

    QString generateOrderId() const;

    OrderResult createOrder(const Order& order);

    std::optional<Order> getOrderById(const QString& orderId) const;
    QList<Order> getOrdersByCustomer(const QString& customerId) const;
    QList<Order> getAllOrders() const;

    OrderResult updateOrderStatus(const QString& orderId, const QString& newStatus);
    OrderResult cancelOrder(const QString& orderId);

private:
    OrderRepository& orderRepository;
    InventoryManager& inventory;
};

}
