// El file da mas2ool 3an edaret el orders: create, get, change status, cancel.   // Owner: Abdelrahman
#include "Shopping/OrderManagerabdel.h"

#include <QLatin1Char>
#include <QLatin1String>

#include "Inventory/InventoryManagerheba.h"
#include "Repositories/OrderRepositoryfay.h"

namespace pharmacy {

namespace {

// Returns the numeric part of an id like "O007" (7), or -1 if the id is not in that format.
qint64 parseOrderNumber(const QString& orderId)
{
    const QString id = orderId.trimmed();
    if (id.size() < 2 || id.at(0) != QLatin1Char('O')) {
        return -1;
    }
    const QString digits = id.mid(1);
    for (const QChar ch : digits) {
        if (ch < QLatin1Char('0') || ch > QLatin1Char('9')) {
            return -1;
        }
    }
    bool ok = false;
    const qint64 number = digits.toLongLong(&ok);
    return ok ? number : -1;
}

}

OrderManager::OrderManager(OrderRepository& orderRepository, InventoryManager& inventory)
    : orderRepository(orderRepository),
      inventory(inventory)
{
}

QString OrderManager::generateOrderId() const
{
    qint64 maxNumber = 0;
    const QList<Order> allOrders = orderRepository.getAllOrders();
    for (const Order& order : allOrders) {
        const qint64 number = parseOrderNumber(order.getOrderId());
        if (number > maxNumber) {
            maxNumber = number;
        }
    }
    return QStringLiteral("O%1").arg(maxNumber + 1, 3, 10, QLatin1Char('0'));
}

OrderResult OrderManager::createOrder(const Order& order)
{
    if (order.getOrderId().trimmed().isEmpty()
        || order.getCustomerId().trimmed().isEmpty()
        || order.getItems().isEmpty()
        || !order.getDeliveryAddress().isValid()) {
        return OrderResult::InvalidOrder;
    }
    if (orderRepository.getOrderById(order.getOrderId()).has_value()) {
        return OrderResult::DuplicateOrder;
    }
    if (!orderRepository.saveOrder(order)) {
        return OrderResult::StorageError;
    }
    return OrderResult::Success;
}

std::optional<Order> OrderManager::getOrderById(const QString& orderId) const
{
    if (orderId.trimmed().isEmpty()) {
        return std::nullopt;
    }
    return orderRepository.getOrderById(orderId.trimmed());
}

QList<Order> OrderManager::getOrdersByCustomer(const QString& customerId) const
{
    if (customerId.trimmed().isEmpty()) {
        return {};
    }
    return orderRepository.getOrdersByCustomer(customerId.trimmed());
}

QList<Order> OrderManager::getAllOrders() const
{
    return orderRepository.getAllOrders();
}

OrderResult OrderManager::updateOrderStatus(const QString& orderId, const QString& newStatus)
{
    std::optional<Order> order = getOrderById(orderId);
    if (!order) {
        return OrderResult::NotFound;
    }

    // Cancelling must also give the stock back, so it goes through cancelOrder().
    if (Order::normalizeStatus(newStatus) == QLatin1String(Order::STATUS_CANCELLED)) {
        return cancelOrder(orderId);
    }

    if (!order->updateStatus(newStatus)) {
        return OrderResult::InvalidTransition;
    }
    if (!orderRepository.updateOrder(*order)) {
        return OrderResult::StorageError;
    }
    return OrderResult::Success;
}

OrderResult OrderManager::cancelOrder(const QString& orderId)
{
    std::optional<Order> order = getOrderById(orderId);
    if (!order) {
        return OrderResult::NotFound;
    }

    // Allowed only from pending, confirmed or processing.
    if (!order->updateStatus(QLatin1String(Order::STATUS_CANCELLED))) {
        return OrderResult::InvalidTransition;
    }
    if (!orderRepository.updateOrder(*order)) {
        return OrderResult::StorageError;
    }

    // The order is cancelled and saved; now give every item's quantity back to stock.
    const QList<CartItem> items = order->getItems();
    for (const CartItem& item : items) {
        inventory.increaseStock(item.getProductId(), item.getQuantity());
    }
    return OrderResult::Success;
}

}
