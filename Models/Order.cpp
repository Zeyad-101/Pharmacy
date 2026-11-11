#include "Order.h"

#include <QJsonArray>
#include <QJsonValue>
#include <cmath>

namespace pharmacy {

namespace {

const qint64 MAX_JSON_INTEGER = 9007199254740991LL;

bool readString(const QJsonObject& json, const QString& key, bool required, QString& out)
{
    const QJsonValue value = json.value(key);
    if (value.isUndefined() || value.isNull()) {
        return !required;
    }
    if (!value.isString()) {
        return false;
    }
    out = value.toString();
    return !required || !out.trimmed().isEmpty();
}

bool readMoney(const QJsonObject& json, const QString& key, qint64& out)
{
    const QJsonValue value = json.value(key);
    if (value.isUndefined() || value.isNull()) {
        return true;
    }
    if (!value.isDouble()) {
        return false;
    }
    const double number = value.toDouble();
    if (number != std::floor(number)
        || number < 0.0
        || number > static_cast<double>(MAX_JSON_INTEGER)) {
        return false;
    }
    out = static_cast<qint64>(number);
    return true;
}

bool readDateTime(const QJsonObject& json, const QString& key, QDateTime& out)
{
    const QJsonValue value = json.value(key);
    if (!value.isString()) {
        return false;
    }
    out = QDateTime::fromString(value.toString().trimmed(), Qt::ISODateWithMs);
    return out.isValid();
}

}

QStringList Order::supportedStatuses()
{
    return {QLatin1String(STATUS_PENDING),
            QLatin1String(STATUS_CONFIRMED),
            QLatin1String(STATUS_PROCESSING),
            QLatin1String(STATUS_SHIPPED),
            QLatin1String(STATUS_DELIVERED),
            QLatin1String(STATUS_CANCELLED)};
}

QString Order::normalizeStatus(const QString& status)
{
    const QString normalized = status.trimmed().toLower();
    if (supportedStatuses().contains(normalized)) {
        return normalized;
    }
    return QString();
}

bool Order::isSupportedStatus(const QString& status)
{
    return !normalizeStatus(status).isEmpty();
}

QStringList Order::nextStatusesFor(const QString& status)
{
    const QString current = normalizeStatus(status);
    if (current == QLatin1String(STATUS_PENDING)) {
        return {QLatin1String(STATUS_CONFIRMED), QLatin1String(STATUS_CANCELLED)};
    }
    if (current == QLatin1String(STATUS_CONFIRMED)) {
        return {QLatin1String(STATUS_PROCESSING), QLatin1String(STATUS_CANCELLED)};
    }
    if (current == QLatin1String(STATUS_PROCESSING)) {
        return {QLatin1String(STATUS_SHIPPED), QLatin1String(STATUS_CANCELLED)};
    }
    if (current == QLatin1String(STATUS_SHIPPED)) {
        return {QLatin1String(STATUS_DELIVERED)};
    }
    return {};
}

bool Order::canTransition(const QString& from, const QString& to)
{
    const QString target = normalizeStatus(to);
    return !target.isEmpty() && nextStatusesFor(from).contains(target);
}

Order::Order()
    : totalPriceMinor(0),
      discountMinor(0),
      finalPriceMinor(0),
      status(QLatin1String(STATUS_PENDING)),
      createdAt(QDateTime::currentDateTime())
{
}

Order::Order(const QString& orderId,
             const QString& customerId,
             const QList<CartItem>& items,
             const Address& deliveryAddress,
             qint64 discountMinor,
             const QString& promoCode,
             const QString& status,
             const QDateTime& createdAt)
    : orderId(orderId),
      customerId(customerId),
      items(items),
      deliveryAddress(deliveryAddress),
      totalPriceMinor(0),
      discountMinor(0),
      finalPriceMinor(0),
      promoCode(promoCode.trimmed()),
      status(QLatin1String(STATUS_PENDING)),
      createdAt(createdAt.isValid() ? createdAt : QDateTime::currentDateTime())
{
    calculateTotalMinor();
    setDiscountMinor(discountMinor);
    const QString normalized = normalizeStatus(status);
    if (!normalized.isEmpty()) {
        this->status = normalized;
    }
}

QString Order::getOrderId() const
{
    return orderId;
}

QString Order::getCustomerId() const
{
    return customerId;
}

QList<CartItem> Order::getItems() const
{
    return items;
}

Address Order::getDeliveryAddress() const
{
    return deliveryAddress;
}

qint64 Order::getTotalPriceMinor() const
{
    return totalPriceMinor;
}

qint64 Order::getDiscountMinor() const
{
    return discountMinor;
}

qint64 Order::getFinalPriceMinor() const
{
    return finalPriceMinor;
}

QString Order::getPromoCode() const
{
    return promoCode;
}

QString Order::getStatus() const
{
    return status;
}

QDateTime Order::getCreatedAt() const
{
    return createdAt;
}

void Order::setDiscountMinor(qint64 discountMinor)
{
    if (discountMinor < 0) {
        this->discountMinor = 0;
    } else if (discountMinor > totalPriceMinor) {
        this->discountMinor = totalPriceMinor;
    } else {
        this->discountMinor = discountMinor;
    }
    calculateFinalPriceMinor();
}

void Order::setDeliveryAddress(const Address& address)
{
    deliveryAddress = address;
}

bool Order::applyPromoCode(const PromoCode& promo)
{
    if (!promo.isValid()) {
        return false;
    }
    promoCode = promo.getCode();
    setDiscountMinor(promo.calculateDiscountMinor(totalPriceMinor));
    return true;
}

void Order::clearPromoCode()
{
    promoCode.clear();
    setDiscountMinor(0);
}

bool Order::updateStatus(const QString& status)
{
    if (!canTransition(this->status, status)) {
        return false;
    }
    this->status = normalizeStatus(status);
    return true;
}

bool Order::canTransitionTo(const QString& status) const
{
    return canTransition(this->status, status);
}

QStringList Order::allowedNextStatuses() const
{
    return nextStatusesFor(status);
}

bool Order::isFinalStatus() const
{
    return nextStatusesFor(status).isEmpty();
}

qint64 Order::calculateTotalMinor()
{
    qint64 total = 0;
    for (const CartItem& item : items) {
        total += item.getSubtotalMinor();
    }
    totalPriceMinor = total;
    if (discountMinor > totalPriceMinor) {
        discountMinor = totalPriceMinor;
    }
    calculateFinalPriceMinor();
    return totalPriceMinor;
}

qint64 Order::calculateFinalPriceMinor()
{
    const qint64 result = totalPriceMinor - discountMinor;
    finalPriceMinor = result < 0 ? 0 : result;
    return finalPriceMinor;
}

QJsonObject Order::toJson() const
{
    QJsonArray itemsArray;
    for (const CartItem& item : items) {
        itemsArray.append(item.toJson());
    }

    QJsonObject json;
    json.insert(QStringLiteral("orderId"), orderId);
    json.insert(QStringLiteral("customerId"), customerId);
    json.insert(QStringLiteral("items"), itemsArray);
    json.insert(QStringLiteral("deliveryAddress"), deliveryAddress.toJson());
    json.insert(QStringLiteral("promoCode"), promoCode);
    json.insert(QStringLiteral("discountMinor"), discountMinor);
    json.insert(QStringLiteral("status"), status);
    json.insert(QStringLiteral("createdAt"), createdAt.toString(Qt::ISODateWithMs));
    return json;
}

Order Order::fromJson(const QJsonObject& json, bool* ok)
{
    QString orderId;
    QString customerId;
    QList<CartItem> items;
    Address deliveryAddress;
    QString promoCode;
    qint64 discountMinor = 0;
    QString status;
    QDateTime createdAt;

    bool valid = true;
    valid = readString(json, QStringLiteral("orderId"), true, orderId) && valid;
    valid = readString(json, QStringLiteral("customerId"), true, customerId) && valid;
    valid = readString(json, QStringLiteral("promoCode"), false, promoCode) && valid;
    valid = readMoney(json, QStringLiteral("discountMinor"), discountMinor) && valid;
    valid = readString(json, QStringLiteral("status"), true, status) && valid;
    valid = isSupportedStatus(status) && valid;
    valid = readDateTime(json, QStringLiteral("createdAt"), createdAt) && valid;

    const QJsonValue itemsValue = json.value(QStringLiteral("items"));
    if (itemsValue.isArray() && !itemsValue.toArray().isEmpty()) {
        const QJsonArray itemsArray = itemsValue.toArray();
        for (const QJsonValue& itemValue : itemsArray) {
            bool itemOk = itemValue.isObject();
            if (itemOk) {
                items.append(CartItem::fromJson(itemValue.toObject(), &itemOk));
            }
            valid = itemOk && valid;
        }
    } else {
        valid = false;
    }

    const QJsonValue addressValue = json.value(QStringLiteral("deliveryAddress"));
    if (addressValue.isObject()) {
        bool addressOk = false;
        deliveryAddress = Address::fromJson(addressValue.toObject(), &addressOk);
        valid = addressOk && deliveryAddress.isValid() && valid;
    } else {
        valid = false;
    }

    Order order(orderId, customerId, items, deliveryAddress,
                discountMinor, promoCode, status, createdAt);
    valid = order.getDiscountMinor() == discountMinor && valid;

    if (ok) {
        *ok = valid;
    }
    return order;
}

}
