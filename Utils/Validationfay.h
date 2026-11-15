#pragma once

#include <QString>

namespace pharmacy {

class Validation
{
public:
    static bool isNonEmptyText(const QString& text);
    static bool isValidEmail(const QString& email);
    static bool isValidPhone(const QString& phone);
    static bool isValidPassword(const QString& password);
    static bool isPositivePrice(qint64 priceMinor);
    static bool isValidQuantity(int quantity);
    static bool isValidId(const QString& id);
};

}