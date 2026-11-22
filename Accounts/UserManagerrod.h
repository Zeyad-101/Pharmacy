// El file da mas2ool 3an tasgeel el users w ta3deel bayanathom.
// Owner: Rodina
#pragma once

#include <QString>
#include <optional>

#include "Models/Address.h"
#include "Models/User.h"
#include "Repositories/UserRepositoryrod.h"

namespace pharmacy {

enum class UserResult
{
    Success,
    InvalidData,
    InvalidEmail,
    InvalidPhone,
    WeakPassword,
    DuplicateEmail,
    DuplicateUsername,
    WrongPassword,
    NotFound,
    StorageError
};

class UserManager
{
public:
    explicit UserManager(UserRepository& repository);

    UserResult registerCustomer(const QString& username, const QString& email,
                                const QString& password, const QString& phone,
                                const Address& address, QString* newUserId = nullptr);

    UserResult updateProfile(const QString& userId, const QString& username,
                             const QString& email, const QString& phone,
                             const Address& address);

    UserResult changePassword(const QString& userId, const QString& oldPassword,
                              const QString& newPassword);

    std::optional<User> getUserById(const QString& userId) const;

private:
    QString generateUserId() const;
    bool isAddressAcceptable(const Address& address) const;

    UserRepository& repository;
};

}
