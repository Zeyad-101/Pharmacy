// El file da mas2ool 3an el login wel logout, we hashing el passwords, we me3rafet meen el user el 3amel login.
// Owner: Rodina
#include "Accounts/Authenticationrod.h"

#include <QByteArray>
#include <QCryptographicHash>
#include <QRandomGenerator>
#include <QStringList>

namespace pharmacy {

Authentication::Authentication(UserRepository& repository)
    : repository(repository)
{}

QString Authentication::hashPassword(const QString& password)
{
    QByteArray salt(16, 0);
    for (char& b : salt)
        b = char(QRandomGenerator::system()->bounded(256));
    const QByteArray hash = QCryptographicHash::hash(salt + password.toUtf8(),
                                                     QCryptographicHash::Sha256);
    return QString::fromLatin1(salt.toHex() + ":" + hash.toHex());
}

bool Authentication::verifyPassword(const QString& password, const QString& storedHash)
{
    const QStringList parts = storedHash.split(':');
    if (parts.size() != 2)
        return false;
    const QByteArray salt = QByteArray::fromHex(parts[0].toLatin1());
    const QByteArray hash = QCryptographicHash::hash(salt + password.toUtf8(),
                                                     QCryptographicHash::Sha256);
    return hash.toHex() == parts[1].toLatin1();
}

LoginResult Authentication::login(const QString& emailOrUsername, const QString& password)
{
    if (emailOrUsername.trimmed().isEmpty() || password.isEmpty())
        return LoginResult::InvalidInput;

    auto user = repository.getUserByEmail(emailOrUsername);
    if (!user)
        user = repository.getUserByUsername(emailOrUsername);

    if (!user || !verifyPassword(password, user->getPasswordHash()))
        return LoginResult::InvalidCredentials;

    currentUserId = user->getId();
    return LoginResult::Success;
}

void Authentication::logout() { currentUserId.clear(); }

bool Authentication::isLoggedIn() const { return !currentUserId.isEmpty(); }

std::optional<User> Authentication::currentUser() const
{
    if (currentUserId.isEmpty())
        return std::nullopt;
    return repository.getUserById(currentUserId);
}

bool Authentication::isCurrentUserAdmin() const
{
    const auto u = currentUser();
    return u && u->isAdmin();
}

}
