#include "User.h"

#include <QJsonValue>

namespace pharmacy {

namespace {

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

}

QString User::normalizeRole(const QString& role)
{
    const QString normalized = role.trimmed().toLower();
    if (normalized == QLatin1String(ROLE_ADMIN) || normalized == QLatin1String(ROLE_CUSTOMER)) {
        return normalized;
    }
    return QString();
}

bool User::isSupportedRole(const QString& role)
{
    return !normalizeRole(role).isEmpty();
}

User::User()
    : role(QLatin1String(ROLE_CUSTOMER))
{
}

User::User(const QString& id,
           const QString& username,
           const QString& email,
           const QString& passwordHash,
           const QString& phone,
           const Address& address,
           const QString& role)
    : id(id),
      username(username.trimmed()),
      email(email.trimmed()),
      passwordHash(passwordHash),
      phone(phone.trimmed()),
      address(address),
      role(QLatin1String(ROLE_CUSTOMER))
{
    setRole(role);
}

QString User::getId() const
{
    return id;
}

QString User::getUsername() const
{
    return username;
}

QString User::getEmail() const
{
    return email;
}

QString User::getPasswordHash() const
{
    return passwordHash;
}

QString User::getPhone() const
{
    return phone;
}

Address User::getAddress() const
{
    return address;
}

QString User::getRole() const
{
    return role;
}

void User::setUsername(const QString& username)
{
    this->username = username.trimmed();
}

void User::setEmail(const QString& email)
{
    this->email = email.trimmed();
}

void User::setPasswordHash(const QString& passwordHash)
{
    this->passwordHash = passwordHash;
}

void User::setPhone(const QString& phone)
{
    this->phone = phone.trimmed();
}

void User::setAddress(const Address& address)
{
    this->address = address;
}

bool User::setRole(const QString& role)
{
    const QString normalized = normalizeRole(role);
    if (normalized.isEmpty()) {
        return false;
    }
    this->role = normalized;
    return true;
}

bool User::isAdmin() const
{
    return role == QLatin1String(ROLE_ADMIN);
}

bool User::isCustomer() const
{
    return role == QLatin1String(ROLE_CUSTOMER);
}

QJsonObject User::toJson() const
{
    QJsonObject json;
    json.insert(QStringLiteral("id"), id);
    json.insert(QStringLiteral("username"), username);
    json.insert(QStringLiteral("email"), email);
    json.insert(QStringLiteral("passwordHash"), passwordHash);
    json.insert(QStringLiteral("phone"), phone);
    json.insert(QStringLiteral("address"), address.toJson());
    json.insert(QStringLiteral("role"), role);
    return json;
}

User User::fromJson(const QJsonObject& json, bool* ok)
{
    QString id;
    QString username;
    QString email;
    QString passwordHash;
    QString phone;
    QString role;
    Address address;

    bool valid = true;
    valid = readString(json, QStringLiteral("id"), true, id) && valid;
    valid = readString(json, QStringLiteral("username"), true, username) && valid;
    valid = readString(json, QStringLiteral("email"), false, email) && valid;
    valid = readString(json, QStringLiteral("passwordHash"), false, passwordHash) && valid;
    valid = readString(json, QStringLiteral("phone"), false, phone) && valid;
    valid = readString(json, QStringLiteral("role"), true, role) && valid;
    valid = isSupportedRole(role) && valid;

    const QJsonValue addressValue = json.value(QStringLiteral("address"));
    if (addressValue.isObject()) {
        bool addressOk = false;
        address = Address::fromJson(addressValue.toObject(), &addressOk);
        valid = addressOk && valid;
    } else if (!addressValue.isUndefined() && !addressValue.isNull()) {
        valid = false;
    }

    if (ok) {
        *ok = valid;
    }
    return User(id, username, email, passwordHash, phone, address, role);
}

}
