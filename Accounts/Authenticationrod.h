#pragma once

#include <QString>
#include <optional>

#include "Models/User.h"
#include "Repositories/UserRepositoryrod.h"

namespace pharmacy {

enum class LoginResult { Success, InvalidInput, InvalidCredentials };

class Authentication
{
public:
    explicit Authentication(UserRepository& repository);

    LoginResult login(const QString& emailOrUsername, const QString& password);
    void logout();
    bool isLoggedIn() const;
    std::optional<User> currentUser() const;
    bool isCurrentUserAdmin() const;

    static QString hashPassword(const QString& password);
    static bool verifyPassword(const QString& password, const QString& storedHash);

private:
    UserRepository& repository;
    QString currentUserId;
};

}