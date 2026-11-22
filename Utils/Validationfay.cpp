// El file da mas2ool 3an el check 3ala el input: el email wel phone wel password wel se3r wel kameya wel id.
// Owner: Fayad
#include "Utils/Validationfay.h"

namespace pharmacy {

bool Validation::isNonEmptyText(const QString& text)
{
    return !text.trimmed().isEmpty();
}

bool Validation::isValidEmail(const QString& email)
{
    const QString value = email.trimmed();
    if (value.isEmpty()) {
        return false;
    }

    for (int i = 0; i < value.size(); ++i) {
        if (value.at(i).isSpace()) {
            return false;
        }
    }

    if (value.count(QLatin1Char('@')) != 1) {
        return false;
    }

    const int atIndex = value.indexOf(QLatin1Char('@'));
    if (atIndex < 1) {
        return false;
    }

    const QString domain = value.mid(atIndex + 1);
    for (int i = 1; i < domain.size() - 1; ++i) {
        if (domain.at(i) == QLatin1Char('.')) {
            return true;
        }
    }
    return false;
}

bool Validation::isValidPhone(const QString& phone)
{
    const QString value = phone.trimmed();
    if (value.size() != 11) {
        return false;
    }

    for (int i = 0; i < value.size(); ++i) {
        const QChar c = value.at(i);
        if (c < QLatin1Char('0') || c > QLatin1Char('9')) {
            return false;
        }
    }

    return value.startsWith(QLatin1String("01"));
}

bool Validation::isValidPassword(const QString& password)
{
    return password.size() >= 8;
}

bool Validation::isPositivePrice(qint64 priceMinor)
{
    return priceMinor > 0;
}

bool Validation::isValidQuantity(int quantity)
{
    return quantity > 0;
}

bool Validation::isValidId(const QString& id)
{
    const QString value = id.trimmed();
    if (value.isEmpty()) {
        return false;
    }

    for (int i = 0; i < value.size(); ++i) {
        if (value.at(i).isSpace()) {
            return false;
        }
    }
    return true;
}

}
