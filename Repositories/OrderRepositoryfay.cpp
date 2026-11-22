#include "Repositories/OrderRepositoryfay.h"

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QSaveFile>

namespace pharmacy {

OrderRepository::OrderRepository(const QString& filePath)
    : filePath(filePath)
{
}

bool OrderRepository::load()
{
    orders.clear();
    loaded = false;
    error.clear();

    QFile file(filePath);
    if (!file.exists()) {
        loaded = true;
        return true;
    }
    if (!file.open(QIODevice::ReadOnly)) {
        error = QStringLiteral("Cannot open orders file");
        return false;
    }

    QJsonParseError parseError;
    const QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        error = QStringLiteral("orders.json is invalid: ") + parseError.errorString();
        return false;
    }
    if (!doc.isArray()) {
        error = QStringLiteral("orders.json must contain a JSON array");
        return false;
    }

    QList<Order> loadedList;
    const QJsonArray array = doc.array();
    for (int i = 0; i < array.size(); ++i) {
        if (!array[i].isObject()) {
            error = QStringLiteral("orders.json: item %1 is not an object").arg(i);
            return false;
        }

        bool ok = false;
        const Order order = Order::fromJson(array[i].toObject(), &ok);
        if (!ok) {
            error = QStringLiteral("orders.json: item %1 is not a valid order").arg(i);
            return false;
        }

        for (const Order& existing : loadedList) {
            if (existing.getOrderId() == order.getOrderId()) {
                error = QStringLiteral("orders.json: duplicate id ") + order.getOrderId();
                return false;
            }
        }
        loadedList.append(order);
    }

    orders = loadedList;
    loaded = true;
    return true;
}

QString OrderRepository::lastError() const
{
    return error;
}

int OrderRepository::indexOf(const QString& id) const
{
    for (int i = 0; i < orders.size(); ++i) {
        if (orders[i].getOrderId() == id) {
            return i;
        }
    }
    return -1;
}

QList<Order> OrderRepository::getAllOrders() const
{
    return orders;
}

std::optional<Order> OrderRepository::getOrderById(const QString& id) const
{
    if (id.isEmpty()) {
        return std::nullopt;
    }
    const int i = indexOf(id);
    if (i == -1) {
        return std::nullopt;
    }
    return orders[i];
}

QList<Order> OrderRepository::getOrdersByCustomer(const QString& customerId) const
{
    QList<Order> result;
    if (customerId.isEmpty()) {
        return result;
    }
    for (const Order& order : orders) {
        if (order.getCustomerId() == customerId) {
            result.append(order);
        }
    }
    return result;
}

bool OrderRepository::existsById(const QString& id) const
{
    return !id.isEmpty() && indexOf(id) != -1;
}

bool OrderRepository::writeToFile(const QList<Order>& list)
{
    QJsonArray array;
    for (const Order& order : list) {
        array.append(order.toJson());
    }

    QSaveFile file(filePath);
    if (!file.open(QIODevice::WriteOnly)) {
        error = QStringLiteral("Cannot write orders file");
        return false;
    }

    const QByteArray data = QJsonDocument(array).toJson(QJsonDocument::Indented);
    if (file.write(data) != data.size()) {
        error = QStringLiteral("Failed to write orders file");
        return false;
    }
    if (!file.commit()) {
        error = QStringLiteral("Failed to save orders file");
        return false;
    }
    return true;
}

bool OrderRepository::saveOrder(const Order& order)
{
    if (!loaded) {
        error = QStringLiteral("Orders file was not loaded");
        return false;
    }
    if (order.getOrderId().isEmpty()) {
        error = QStringLiteral("Order id is empty");
        return false;
    }
    if (indexOf(order.getOrderId()) != -1) {
        error = QStringLiteral("Order id already exists");
        return false;
    }

    QList<Order> copy = orders;
    copy.append(order);
    if (!writeToFile(copy)) {
        return false;
    }
    orders = copy;
    return true;
}

bool OrderRepository::updateOrder(const Order& order)
{
    if (!loaded) {
        error = QStringLiteral("Orders file was not loaded");
        return false;
    }
    const int i = indexOf(order.getOrderId());
    if (order.getOrderId().isEmpty() || i == -1) {
        error = QStringLiteral("Order not found");
        return false;
    }

    QList<Order> copy = orders;
    copy[i] = order;
    if (!writeToFile(copy)) {
        return false;
    }
    orders = copy;
    return true;
}

}