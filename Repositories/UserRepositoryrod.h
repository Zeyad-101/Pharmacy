// El file da mas2ool 3an 7efz w esterga3 bayanat el users men file users.json.
// Owner: Rodina
#pragma once

#include <QList>
#include <QString>
#include <optional>

#include "Models/User.h"

namespace pharmacy {

class UserRepository
{
public:
    explicit UserRepository(const QString& filePath);

    bool load();
    QString lastError() const;

    QList<User> getAllUsers() const;
    std::optional<User> getUserById(const QString& id) const;
    std::optional<User> getUserByEmail(const QString& email) const;
    std::optional<User> getUserByUsername(const QString& username) const;
    bool existsByEmail(const QString& email) const;
    bool existsByUsername(const QString& username) const;

    bool saveUser(const User& user);
    bool updateUser(const User& user);

private:
    bool writeToFile(const QList<User>& list);
    int indexOf(const QString& id) const;

    QString filePath;
    QList<User> users;
    bool loaded = false;
    QString error;
};

}
