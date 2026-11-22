#pragma once

#include <QJsonObject>
#include <QString>
// El file da mas2ool 3an ta3reef bayanat el address, zay el city wel street wel building number wel apartment number wel postal code.
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
