#include "Product.h"

#include <QJsonValue>
#include <cmath>
#include <limits>

namespace pharmacy {

namespace {

const qint64 MAX_JSON_INTEGER = 9007199254740991LL;

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

bool readInteger(const QJsonObject& json, const QString& key, bool required,
                 qint64 minimum, qint64 maximum, qint64& out)
{
    const QJsonValue value = json.value(key);
    if (value.isUndefined() || value.isNull()) {
        return !required;
    }
    if (!value.isDouble()) {
        return false;
    }
    const double number = value.toDouble();
    if (number != std::floor(number)
        || number < static_cast<double>(minimum)
        || number > static_cast<double>(maximum)) {
        return false;
    }
    out = static_cast<qint64>(number);
    return true;
}

bool readBool(const QJsonObject& json, const QString& key, bool& out)
{
    const QJsonValue value = json.value(key);
    if (value.isUndefined() || value.isNull()) {
        return true;
    }
    if (!value.isBool()) {
        return false;
    }
    out = value.toBool();
    return true;
}

bool readOptionalDate(const QJsonObject& json, const QString& key, QDate& out)
{
    const QJsonValue value = json.value(key);
    if (value.isUndefined() || value.isNull()) {
        return true;
    }
    if (!value.isString()) {
        return false;
    }
    const QString text = value.toString().trimmed();
    if (text.isEmpty()) {
        return true;
    }
    out = QDate::fromString(text, Qt::ISODate);
    return out.isValid();
}

}

Product::Product()
    : priceMinor(0),
      stockQuantity(0),
      requiresPrescription(false)
{
}

Product::Product(const QString& id,
                 const QString& name,
                 const QString& code,
                 const QString& category,
                 const QString& description,
                 qint64 priceMinor,
                 int stockQuantity,
                 const QString& imagePath,
                 const QDate& expiryDate,
                 bool requiresPrescription)
    : id(id),
      name(name),
      code(code),
      category(category),
      description(description),
      priceMinor(priceMinor < 0 ? 0 : priceMinor),
      stockQuantity(stockQuantity < 0 ? 0 : stockQuantity),
      imagePath(imagePath),
      expiryDate(expiryDate),
      requiresPrescription(requiresPrescription)
{
}

QString Product::getId() const
{
    return id;
}

QString Product::getName() const
{
    return name;
}

QString Product::getCode() const
{
    return code;
}

QString Product::getCategory() const
{
    return category;
}

QString Product::getDescription() const
{
    return description;
}

qint64 Product::getPriceMinor() const
{
    return priceMinor;
}

int Product::getStockQuantity() const
{
    return stockQuantity;
}

QString Product::getImagePath() const
{
    return imagePath;
}

QDate Product::getExpiryDate() const
{
    return expiryDate;
}

bool Product::getRequiresPrescription() const
{
    return requiresPrescription;
}

void Product::setName(const QString& name)
{
    this->name = name;
}

void Product::setCode(const QString& code)
{
    this->code = code;
}

void Product::setCategory(const QString& category)
{
    this->category = category;
}

void Product::setDescription(const QString& description)
{
    this->description = description;
}

bool Product::setPriceMinor(qint64 priceMinor)
{
    if (priceMinor < 0) {
        return false;
    }
    this->priceMinor = priceMinor;
    return true;
}

bool Product::setStockQuantity(int stockQuantity)
{
    if (stockQuantity < 0) {
        return false;
    }
    this->stockQuantity = stockQuantity;
    return true;
}

void Product::setImagePath(const QString& imagePath)
{
    this->imagePath = imagePath;
}

void Product::setExpiryDate(const QDate& expiryDate)
{
    this->expiryDate = expiryDate;
}

void Product::setRequiresPrescription(bool requiresPrescription)
{
    this->requiresPrescription = requiresPrescription;
}

bool Product::hasExpiryDate() const
{
    return expiryDate.isValid();
}

bool Product::isExpired() const
{
    return hasExpiryDate() && expiryDate < QDate::currentDate();
}

bool Product::isAvailable() const
{
    return stockQuantity > 0 && !isExpired();
}

bool Product::hasSufficientStock(int quantity) const
{
    return quantity > 0 && isAvailable() && stockQuantity >= quantity;
}

QJsonObject Product::toJson() const
{
    QJsonObject json;
    json.insert(QStringLiteral("id"), id);
    json.insert(QStringLiteral("name"), name);
    json.insert(QStringLiteral("code"), code);
    json.insert(QStringLiteral("category"), category);
    json.insert(QStringLiteral("description"), description);
    json.insert(QStringLiteral("priceMinor"), priceMinor);
    json.insert(QStringLiteral("stockQuantity"), stockQuantity);
    json.insert(QStringLiteral("imagePath"), imagePath);
    json.insert(QStringLiteral("expiryDate"),
                hasExpiryDate() ? expiryDate.toString(Qt::ISODate) : QString());
    json.insert(QStringLiteral("requiresPrescription"), requiresPrescription);
    return json;
}

Product Product::fromJson(const QJsonObject& json, bool* ok)
{
    QString id;
    QString name;
    QString code;
    QString category;
    QString description;
    qint64 priceMinor = 0;
    qint64 stockQuantity = 0;
    QString imagePath;
    QDate expiryDate;
    bool requiresPrescription = false;

    bool valid = true;
    valid = readString(json, QStringLiteral("id"), true, id) && valid;
    valid = readString(json, QStringLiteral("name"), true, name) && valid;
    valid = readString(json, QStringLiteral("code"), false, code) && valid;
    valid = readString(json, QStringLiteral("category"), false, category) && valid;
    valid = readString(json, QStringLiteral("description"), false, description) && valid;
    valid = readInteger(json, QStringLiteral("priceMinor"), true,
                        0, MAX_JSON_INTEGER, priceMinor) && valid;
    valid = readInteger(json, QStringLiteral("stockQuantity"), true,
                        0, std::numeric_limits<int>::max(), stockQuantity) && valid;
    valid = readString(json, QStringLiteral("imagePath"), false, imagePath) && valid;
    valid = readOptionalDate(json, QStringLiteral("expiryDate"), expiryDate) && valid;
    valid = readBool(json, QStringLiteral("requiresPrescription"), requiresPrescription) && valid;

    if (ok) {
        *ok = valid;
    }
    return Product(id, name, code, category, description, priceMinor,
                   static_cast<int>(stockQuantity), imagePath, expiryDate,
                   requiresPrescription);
}

}
