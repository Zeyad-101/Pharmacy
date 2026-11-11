#pragma once

#include <QJsonObject>
#include <QString>

namespace pharmacy {

class Address
{
public:
    Address();
    Address(const QString& city,
            const QString& street,
            const QString& buildingNumber,
            const QString& apartmentNumber = QString(),
            const QString& postalCode = QString());

    QString getCity() const;
    QString getStreet() const;
    QString getBuildingNumber() const;
    QString getApartmentNumber() const;
    QString getPostalCode() const;

    void setCity(const QString& city);
    void setStreet(const QString& street);
    void setBuildingNumber(const QString& buildingNumber);
    void setApartmentNumber(const QString& apartmentNumber);
    void setPostalCode(const QString& postalCode);

    bool isValid() const;

    QJsonObject toJson() const;
    static Address fromJson(const QJsonObject& json, bool* ok = nullptr);

private:
    QString city;
    QString street;
    QString buildingNumber;
    QString apartmentNumber;
    QString postalCode;
};

}
