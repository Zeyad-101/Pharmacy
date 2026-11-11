#pragma once

#include <QJsonObject>
#include <QLatin1String>
#include <QString>

#include "Address.h"

namespace pharmacy {

class User
{
public:
    static constexpr char ROLE_ADMIN[] = "admin";
    static constexpr char ROLE_CUSTOMER[] = "customer";

    static QString normalizeRole(const QString& role);
    static bool isSupportedRole(const QString& role);

    User();
    User(const QString& id,
         const QString& username,
         const QString& email,
         const QString& passwordHash,
         const QString& phone,
         const Address& address,
         const QString& role = QLatin1String(ROLE_CUSTOMER));

    QString getId() const;
    QString getUsername() const;
    QString getEmail() const;
    QString getPasswordHash() const;
    QString getPhone() const;
    Address getAddress() const;
    QString getRole() const;

    void setUsername(const QString& username);
    void setEmail(const QString& email);
    void setPasswordHash(const QString& passwordHash);
    void setPhone(const QString& phone);
    void setAddress(const Address& address);
    bool setRole(const QString& role);

    bool isAdmin() const;
    bool isCustomer() const;

    QJsonObject toJson() const;
    static User fromJson(const QJsonObject& json, bool* ok = nullptr);

private:
    QString id;
    QString username;
    QString email;
    QString passwordHash;
    QString phone;
    Address address;
    QString role;
};

}
