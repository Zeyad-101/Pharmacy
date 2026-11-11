#pragma once

#include <QDate>
#include <QJsonObject>
#include <QString>

namespace pharmacy {

class PromoCode
{
public:
    PromoCode();
    PromoCode(const QString& code,
              int discountPercentage,
              const QDate& expirationDate,
              bool active = true);

    QString getCode() const;
    int getDiscountPercentage() const;
    QDate getExpirationDate() const;
    bool isActive() const;

    bool setDiscountPercentage(int discountPercentage);
    void setExpirationDate(const QDate& expirationDate);
    void setActive(bool active);

    bool isValid() const;
    qint64 calculateDiscountMinor(qint64 totalPriceMinor) const;

    QJsonObject toJson() const;
    static PromoCode fromJson(const QJsonObject& json, bool* ok = nullptr);

private:
    QString code;
    int discountPercentage;
    QDate expirationDate;
    bool active;
};

}
