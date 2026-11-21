#pragma once

#include <QList>
#include <QString>

#include "Models/CartItem.h"
#include "Inventory/InventoryManagerheba.h"
#include "Repositories/ProductRepositoryheba.h"

namespace pharmacy {

enum class CartResult
{
    Success,
    InvalidQuantity,
    ProductNotFound,
    ItemNotInCart,
    InsufficientStock
};

class CartManager
{
public:
    CartManager(ProductRepository& productRepository, InventoryManager& inventory);

    CartResult addItem(const QString& productId, int quantity);
    CartResult removeItem(const QString& productId);
    CartResult changeQuantity(const QString& productId, int newQuantity);

    QList<CartItem> getItems() const;
    qint64 getSubtotalMinor() const;
    int getItemCount() const;
    bool isEmpty() const;
    void clear();

private:
    int indexOf(const QString& productId) const;

    ProductRepository& productRepository;
    InventoryManager& inventory;
    QList<CartItem> items;
};

}
