#pragma once

#include <QList>
#include <QString>
#include <optional>

#include "Models/Order.h"

namespace pharmacy {

class OrderRepository
{
public:
    explicit OrderRepository(const QString& filePath);

    bool load();
    QString lastError() const;

    QList<Order> getAllOrders() const;
    std::optional<Order> getOrderById(const QString& id) const;
    QList<Order> getOrdersByCustomer(const QString& customerId) const;
    bool existsById(const QString& id) const;

    bool saveOrder(const Order& order);
    bool updateOrder(const Order& order);

private:
    bool writeToFile(const QList<Order>& list);
    int indexOf(const QString& id) const;

    QString filePath;
    QList<Order> orders;
    bool loaded = false;
    QString error;
};

}