#include "CartItem.h"

#include <QJsonValue>
#include <cmath>
#include <limits>

namespace pharmacy {

namespace {

const qint64 MAX_JSON_INTEGER = 9007199254740991LL;

bool readInteger(const QJsonObject& json, const QString& key,
                 qint64 minimum, qint64 maximum, qint64& out)
{
    const QJsonValue value = json.value(key);
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

}

CartItem::CartItem()
    : quantity(1),
      unitPriceMinor(0)
{
}

CartItem::CartItem(const Product& product, int quantity)
    : CartItem(product, quantity, product.getPriceMinor())
{
}

CartItem::CartItem(const Product& product, int quantity, qint64 unitPriceMinor)
    : product(product),
      quantity(quantity > 0 ? quantity : 1),
      unitPriceMinor(unitPriceMinor < 0 ? 0 : unitPriceMinor)
{
}

Product CartItem::getProduct() const
{
    return product;
}

QString CartItem::getProductId() const
{
    return product.getId();
}

int CartItem::getQuantity() const
{
    return quantity;
}

qint64 CartItem::getUnitPriceMinor() const
{
    return unitPriceMinor;
}

bool CartItem::setQuantity(int quantity)
{
    if (quantity <= 0) {
        return false;
    }
    this->quantity = quantity;
    return true;
}

bool CartItem::updateQuantity(int quantity)
{
    const qint64 newQuantity = static_cast<qint64>(this->quantity) + quantity;
    if (newQuantity <= 0 || newQuantity > std::numeric_limits<int>::max()) {
        return false;
    }
    this->quantity = static_cast<int>(newQuantity);
    return true;
}

qint64 CartItem::getSubtotalMinor() const
{
    return unitPriceMinor * quantity;
}

bool CartItem::matchesProduct(const Product& current) const
{
    return !product.getId().isEmpty() && product.getId() == current.getId();
}

bool CartItem::hasPriceChanged(const Product& current) const
{
    return !matchesProduct(current) || current.getPriceMinor() != unitPriceMinor;
}

bool CartItem::isStockSufficient(const Product& current) const
{
    return matchesProduct(current) && current.hasSufficientStock(quantity);
}

bool CartItem::refreshFromProduct(const Product& current)
{
    if (!matchesProduct(current)) {
        return false;
    }
    product = current;
    unitPriceMinor = current.getPriceMinor();
    return true;
}

QJsonObject CartItem::toJson() const
{
    QJsonObject json;
    json.insert(QStringLiteral("product"), product.toJson());
    json.insert(QStringLiteral("quantity"), quantity);
    json.insert(QStringLiteral("unitPriceMinor"), unitPriceMinor);
    return json;
}

CartItem CartItem::fromJson(const QJsonObject& json, bool* ok)
{
    Product product;
    qint64 quantity = 1;
    qint64 unitPriceMinor = 0;

    bool valid = true;
    const QJsonValue productValue = json.value(QStringLiteral("product"));
    if (productValue.isObject()) {
        bool productOk = false;
        product = Product::fromJson(productValue.toObject(), &productOk);
        valid = productOk && valid;
    } else {
        valid = false;
    }
    valid = readInteger(json, QStringLiteral("quantity"),
                        1, std::numeric_limits<int>::max(), quantity) && valid;
    valid = readInteger(json, QStringLiteral("unitPriceMinor"),
                        0, MAX_JSON_INTEGER, unitPriceMinor) && valid;

    if (ok) {
        *ok = valid;
    }
    return CartItem(product, static_cast<int>(quantity), unitPriceMinor);
}

}
