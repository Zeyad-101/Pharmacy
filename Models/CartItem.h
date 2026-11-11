#pragma once

#include <QJsonObject>
#include <QString>

#include "Product.h"

namespace pharmacy {

class CartItem
{
public:
    CartItem();
    CartItem(const Product& product, int quantity);
    CartItem(const Product& product, int quantity, qint64 unitPriceMinor);

    Product getProduct() const;
    QString getProductId() const;
    int getQuantity() const;
    qint64 getUnitPriceMinor() const;

    bool setQuantity(int quantity);
    bool updateQuantity(int quantity);

    qint64 getSubtotalMinor() const;

    bool matchesProduct(const Product& current) const;
    bool hasPriceChanged(const Product& current) const;
    bool isStockSufficient(const Product& current) const;
    bool refreshFromProduct(const Product& current);

    QJsonObject toJson() const;
    static CartItem fromJson(const QJsonObject& json, bool* ok = nullptr);

private:
    Product product;
    int quantity;
    qint64 unitPriceMinor;
};

}
