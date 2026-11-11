#include "Address.h"

#include <QJsonValue>

namespace pharmacy {

namespace {

bool readString(const QJsonObject& json, const QString& key, QString& out)
{
    const QJsonValue value = json.value(key);
    if (value.isUndefined() || value.isNull()) {
        return true;
    }
    if (!value.isString()) {
        return false;
    }
    out = value.toString();
    return true;
}

}

Address::Address() = default;

Address::Address(const QString& city,
                 const QString& street,
                 const QString& buildingNumber,
                 const QString& apartmentNumber,
                 const QString& postalCode)
    : city(city.trimmed()),
      street(street.trimmed()),
      buildingNumber(buildingNumber.trimmed()),
      apartmentNumber(apartmentNumber.trimmed()),
      postalCode(postalCode.trimmed())
{
}

QString Address::getCity() const
{
    return city;
}

QString Address::getStreet() const
{
    return street;
}

QString Address::getBuildingNumber() const
{
    return buildingNumber;
}

QString Address::getApartmentNumber() const
{
    return apartmentNumber;
}

QString Address::getPostalCode() const
{
    return postalCode;
}

void Address::setCity(const QString& city)
{
    this->city = city.trimmed();
}

void Address::setStreet(const QString& street)
{
    this->street = street.trimmed();
}

void Address::setBuildingNumber(const QString& buildingNumber)
{
    this->buildingNumber = buildingNumber.trimmed();
}

void Address::setApartmentNumber(const QString& apartmentNumber)
{
    this->apartmentNumber = apartmentNumber.trimmed();
}

void Address::setPostalCode(const QString& postalCode)
{
    this->postalCode = postalCode.trimmed();
}

bool Address::isValid() const
{
    return !city.trimmed().isEmpty()
        && !street.trimmed().isEmpty()
        && !buildingNumber.trimmed().isEmpty();
}

QJsonObject Address::toJson() const
{
    QJsonObject json;
    json.insert(QStringLiteral("city"), city);
    json.insert(QStringLiteral("street"), street);
    json.insert(QStringLiteral("buildingNumber"), buildingNumber);
    json.insert(QStringLiteral("apartmentNumber"), apartmentNumber);
    json.insert(QStringLiteral("postalCode"), postalCode);
    return json;
}

Address Address::fromJson(const QJsonObject& json, bool* ok)
{
    QString city;
    QString street;
    QString buildingNumber;
    QString apartmentNumber;
    QString postalCode;

    bool valid = true;
    valid = readString(json, QStringLiteral("city"), city) && valid;
    valid = readString(json, QStringLiteral("street"), street) && valid;
    valid = readString(json, QStringLiteral("buildingNumber"), buildingNumber) && valid;
    valid = readString(json, QStringLiteral("apartmentNumber"), apartmentNumber) && valid;
    valid = readString(json, QStringLiteral("postalCode"), postalCode) && valid;

    if (ok) {
        *ok = valid;
    }
    return Address(city, street, buildingNumber, apartmentNumber, postalCode);
}

}
