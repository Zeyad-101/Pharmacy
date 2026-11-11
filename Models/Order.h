#pragma once

#include <QDateTime>
#include <QJsonObject>
#include <QLatin1String>
#include <QList>
#include <QString>
#include <QStringList>

#include "Address.h"
#include "CartItem.h"
#include "PromoCode.h"

namespace pharmacy {

class Order
{
public:
    static constexpr char STATUS_PENDING[] = "pending";
    static constexpr char STATUS_CONFIRMED[] = "confirmed";
    static constexpr char STATUS_PROCESSING[] = "processing";
    static constexpr char STATUS_SHIPPED[] = "shipped";
    static constexpr char STATUS_DELIVERED[] = "delivered";
    static constexpr char STATUS_CANCELLED[] = "cancelled";

    static QStringList supportedStatuses();
    static QString normalizeStatus(const QString& status);
    static bool isSupportedStatus(const QString& status);
    static QStringList nextStatusesFor(const QString& status);
    static bool canTransition(const QString& from, const QString& to);

    Order();
    Order(const QString& orderId,
          const QString& customerId,
          const QList<CartItem>& items,
          const Address& deliveryAddress,
          qint64 discountMinor = 0,
          const QString& promoCode = QString(),
          const QString& status = QLatin1String(STATUS_PENDING),
          const QDateTime& createdAt = QDateTime());

    QString getOrderId() const;
    QString getCustomerId() const;
    QList<CartItem> getItems() const;
    Address getDeliveryAddress() const;
    qint64 getTotalPriceMinor() const;
    qint64 getDiscountMinor() const;
    qint64 getFinalPriceMinor() const;
    QString getPromoCode() const;
    QString getStatus() const;
    QDateTime getCreatedAt() const;

    void setDiscountMinor(qint64 discountMinor);
    void setDeliveryAddress(const Address& address);
    bool applyPromoCode(const PromoCode& promo);
    void clearPromoCode();

    bool updateStatus(const QString& status);
    bool canTransitionTo(const QString& status) const;
    QStringList allowedNextStatuses() const;
    bool isFinalStatus() const;

    qint64 calculateTotalMinor();
    qint64 calculateFinalPriceMinor();

    QJsonObject toJson() const;
    static Order fromJson(const QJsonObject& json, bool* ok = nullptr);

private:
    QString orderId;
    QString customerId;
    QList<CartItem> items;
    Address deliveryAddress;
    qint64 totalPriceMinor;
    qint64 discountMinor;
    qint64 finalPriceMinor;
    QString promoCode;
    QString status;
    QDateTime createdAt;
};

}
