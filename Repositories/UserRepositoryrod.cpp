// El file da mas2ool 3an 7efz w esterga3 bayanat el users men file users.json.
// Owner: Rodina
#include "Repositories/UserRepositoryrod.h"

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QSaveFile>

namespace pharmacy {

UserRepository::UserRepository(const QString& filePath)
    : filePath(filePath)
{
}

bool UserRepository::load()
{
    users.clear();
    loaded = false;
    error.clear();

    QFile file(filePath);
    if (!file.exists()) {
        loaded = true;
        return true;
    }
    if (!file.open(QIODevice::ReadOnly)) {
        error = "Cannot open users file";
        return false;
    }

    QJsonParseError parseError;
    const QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        error = "users.json is invalid: " + parseError.errorString();
        return false;
    }
    if (!doc.isArray()) {
        error = "users.json must contain a JSON array";
        return false;
    }

    QList<User> loadedList;
    const QJsonArray array = doc.array();
    for (int i = 0; i < array.size(); ++i) {
        if (!array[i].isObject()) {
            error = QString("users.json: item %1 is not an object").arg(i);
            return false;
        }
        bool ok = false;
        const User u = User::fromJson(array[i].toObject(), &ok);
        if (!ok) {
            error = QString("users.json: item %1 is not a valid user").arg(i);
            return false;
        }
        for (const User& existing : loadedList) {
            if (existing.getId() == u.getId()
                || (!u.getEmail().isEmpty()
                    && existing.getEmail().compare(u.getEmail(), Qt::CaseInsensitive) == 0)) {
                error = "users.json: duplicate id or email for " + u.getId();
                return false;
            }
        }
        loadedList.append(u);
    }

    users = loadedList;
    loaded = true;
    return true;
}

QString UserRepository::lastError() const { return error; }

int UserRepository::indexOf(const QString& id) const
{
    for (int i = 0; i < users.size(); ++i)
        if (users[i].getId() == id)
            return i;
    return -1;
}

QList<User> UserRepository::getAllUsers() const { return users; }

std::optional<User> UserRepository::getUserById(const QString& id) const
{
    const int i = indexOf(id);
    if (id.isEmpty() || i == -1)
        return std::nullopt;
    return users[i];
}

std::optional<User> UserRepository::getUserByEmail(const QString& email) const
{
    const QString e = email.trimmed();
    if (e.isEmpty())
        return std::nullopt;
    for (const User& u : users)
        if (u.getEmail().compare(e, Qt::CaseInsensitive) == 0)
            return u;
    return std::nullopt;
}

std::optional<User> UserRepository::getUserByUsername(const QString& username) const
{
    const QString n = username.trimmed();
    if (n.isEmpty())
        return std::nullopt;
    for (const User& u : users)
        if (u.getUsername().compare(n, Qt::CaseInsensitive) == 0)
            return u;
    return std::nullopt;
}

bool UserRepository::existsByEmail(const QString& email) const
{
    return getUserByEmail(email).has_value();
}

bool UserRepository::existsByUsername(const QString& username) const
{
    return getUserByUsername(username).has_value();
}

bool UserRepository::writeToFile(const QList<User>& list)
{
    QJsonArray array;
    for (const User& u : list)
        array.append(u.toJson());

    QSaveFile file(filePath);
    if (!file.open(QIODevice::WriteOnly)) {
        error = "Cannot write users file";
        return false;
    }
    // Stop if the data could not be written, and keep the old file
    const QByteArray data = QJsonDocument(array).toJson(QJsonDocument::Indented);
    if (file.write(data) != data.size()) {
        error = "Failed to write users file";
        file.cancelWriting();
        return false;
    }
    if (!file.commit()) {
        error = "Failed to save users file";
        return false;
    }
    return true;
}

bool UserRepository::saveUser(const User& user)
{
    if (!loaded || user.getId().isEmpty() || indexOf(user.getId()) != -1)
        return false;
    if (existsByEmail(user.getEmail()) || existsByUsername(user.getUsername()))
        return false;

    QList<User> copy = users;
    copy.append(user);
    if (!writeToFile(copy))
        return false;
    users = copy;
    return true;
}

bool UserRepository::updateUser(const User& user)
{
    const int i = indexOf(user.getId());
    if (!loaded || i == -1)
        return false;

    const auto byEmail = getUserByEmail(user.getEmail());
    if (byEmail && byEmail->getId() != user.getId())
        return false;
    const auto byName = getUserByUsername(user.getUsername());
    if (byName && byName->getId() != user.getId())
        return false;

    QList<User> copy = users;
    copy[i] = user;
    if (!writeToFile(copy))
        return false;
    users = copy;
    return true;
}

}
