#include "PromoCode.h"

#include <QJsonValue>
#include <cmath>

namespace pharmacy {

namespace {

bool readString(const QJsonObject& json, const QString& key, QString& out)
{
    const QJsonValue value = json.value(key);
    if (!value.isString()) {
        return false;
    }
    out = value.toString();
    return !out.trimmed().isEmpty();
}

bool readPercentage(const QJsonObject& json, const QString& key, int& out)
{
    const QJsonValue value = json.value(key);
    if (!value.isDouble()) {
        return false;
    }
    const double number = value.toDouble();
    if (number != std::floor(number) || number < 0.0 || number > 100.0) {
        return false;
    }
    out = static_cast<int>(number);
    return true;
}

bool readDate(const QJsonObject& json, const QString& key, QDate& out)
{
    const QJsonValue value = json.value(key);
    if (!value.isString()) {
        return false;
    }
    out = QDate::fromString(value.toString().trimmed(), Qt::ISODate);
    return out.isValid();
}

bool readBool(const QJsonObject& json, const QString& key, bool& out)
{
    const QJsonValue value = json.value(key);
    if (value.isUndefined() || value.isNull()) {
        return true;
    }
    if (!value.isBool()) {
        return false;
    }
    out = value.toBool();
    return true;
}

}

PromoCode::PromoCode()
    : discountPercentage(0),
      active(false)
{
}

PromoCode::PromoCode(const QString& code,
                     int discountPercentage,
                     const QDate& expirationDate,
                     bool active)
    : code(code.trimmed()),
      discountPercentage(0),
      expirationDate(expirationDate),
      active(active)
{
    setDiscountPercentage(discountPercentage);
}

QString PromoCode::getCode() const
{
    return code;
}

int PromoCode::getDiscountPercentage() const
{
    return discountPercentage;
}

QDate PromoCode::getExpirationDate() const
{
    return expirationDate;
}

bool PromoCode::isActive() const
{
    return active;
}

bool PromoCode::setDiscountPercentage(int discountPercentage)
{
    if (discountPercentage < 0 || discountPercentage > 100) {
        return false;
    }
    this->discountPercentage = discountPercentage;
    return true;
}

void PromoCode::setExpirationDate(const QDate& expirationDate)
{
    this->expirationDate = expirationDate;
}

void PromoCode::setActive(bool active)
{
    this->active = active;
}

bool PromoCode::isValid() const
{
    return active
        && !code.isEmpty()
        && expirationDate.isValid()
        && expirationDate >= QDate::currentDate();
}

qint64 PromoCode::calculateDiscountMinor(qint64 totalPriceMinor) const
{
    if (totalPriceMinor < 0 || !isValid()) {
        return 0;
    }
    return (totalPriceMinor * discountPercentage + 50) / 100;
}

QJsonObject PromoCode::toJson() const
{
    QJsonObject json;
    json.insert(QStringLiteral("code"), code);
    json.insert(QStringLiteral("discountPercentage"), discountPercentage);
    json.insert(QStringLiteral("expirationDate"), expirationDate.toString(Qt::ISODate));
    json.insert(QStringLiteral("active"), active);
    return json;
}

PromoCode PromoCode::fromJson(const QJsonObject& json, bool* ok)
{
    QString code;
    int discountPercentage = 0;
    QDate expirationDate;
    bool active = true;

    bool valid = true;
    valid = readString(json, QStringLiteral("code"), code) && valid;
    valid = readPercentage(json, QStringLiteral("discountPercentage"), discountPercentage) && valid;
    valid = readDate(json, QStringLiteral("expirationDate"), expirationDate) && valid;
    valid = readBool(json, QStringLiteral("active"), active) && valid;

    if (ok) {
        *ok = valid;
    }
    return PromoCode(code, discountPercentage, expirationDate, active);
}

}
