// El file da mas2ool 3an tasgeel el users w ta3deel bayanathom.
// Owner: Rodina
#include "Accounts/UserManagerrod.h"

#include "Accounts/Authenticationrod.h"
#include "Utils/Validationfay.h"

namespace pharmacy {

UserManager::UserManager(UserRepository& repository)
    : repository(repository)
{
}

QString UserManager::generateUserId() const
{
    int maxNum = 0;
    for (const User& u : repository.getAllUsers()) {
        bool ok = false;
        const int n = u.getId().mid(1).toInt(&ok);
        if (ok && n > maxNum)
            maxNum = n;
    }
    return QString("U%1").arg(maxNum + 1, 3, 10, QChar('0'));
}

bool UserManager::isAddressAcceptable(const Address& address) const
{
    const bool empty = address.getCity().isEmpty() && address.getStreet().isEmpty()
                       && address.getBuildingNumber().isEmpty()
                       && address.getApartmentNumber().isEmpty()
                       && address.getPostalCode().isEmpty();
    return empty || address.isValid();
}

UserResult UserManager::registerCustomer(const QString& username, const QString& email,
                                         const QString& password, const QString& phone,
                                         const Address& address, QString* newUserId)
{
    if (!Validation::isNonEmptyText(username)) return UserResult::InvalidData;
    if (!Validation::isValidEmail(email))      return UserResult::InvalidEmail;
    if (!Validation::isValidPhone(phone))      return UserResult::InvalidPhone;
    if (!Validation::isValidPassword(password)) return UserResult::WeakPassword;
    if (!isAddressAcceptable(address))         return UserResult::InvalidData;
    if (repository.existsByEmail(email))       return UserResult::DuplicateEmail;
    if (repository.existsByUsername(username)) return UserResult::DuplicateUsername;

    const QString id = generateUserId();
    const User user(id, username, email.trimmed().toLower(),
                    Authentication::hashPassword(password),
                    phone, address, QLatin1String(User::ROLE_CUSTOMER));

    if (!repository.saveUser(user))
        return UserResult::StorageError;
    if (newUserId)
        *newUserId = id;
    return UserResult::Success;
}

UserResult UserManager::updateProfile(const QString& userId, const QString& username,
                                      const QString& email, const QString& phone,
                                      const Address& address)
{
    auto user = repository.getUserById(userId);
    if (!user) return UserResult::NotFound;

    if (!Validation::isNonEmptyText(username)) return UserResult::InvalidData;
    if (!Validation::isValidEmail(email))      return UserResult::InvalidEmail;
    if (!Validation::isValidPhone(phone))      return UserResult::InvalidPhone;
    if (!isAddressAcceptable(address))         return UserResult::InvalidData;

    const auto byEmail = repository.getUserByEmail(email);
    if (byEmail && byEmail->getId() != userId) return UserResult::DuplicateEmail;
    const auto byName = repository.getUserByUsername(username);
    if (byName && byName->getId() != userId) return UserResult::DuplicateUsername;

    user->setUsername(username);
    user->setEmail(email.trimmed().toLower());
    user->setPhone(phone);
    user->setAddress(address);

    return repository.updateUser(*user) ? UserResult::Success : UserResult::StorageError;
}

UserResult UserManager::changePassword(const QString& userId, const QString& oldPassword,
                                       const QString& newPassword)
{
    auto user = repository.getUserById(userId);
    if (!user)
        return UserResult::NotFound;
    if (!Authentication::verifyPassword(oldPassword, user->getPasswordHash()))
        return UserResult::WrongPassword;
    if (!Validation::isValidPassword(newPassword))
        return UserResult::WeakPassword;

    user->setPasswordHash(Authentication::hashPassword(newPassword));
    return repository.updateUser(*user) ? UserResult::Success : UserResult::StorageError;
}

std::optional<User> UserManager::getUserById(const QString& userId) const
{
    return repository.getUserById(userId);
}

}