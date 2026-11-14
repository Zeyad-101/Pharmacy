// El file da mas2ool 3an el makhzoon: check el kameya el mawgooda, w ziyadet aw na2s el stock.
// Owner: Heba
#pragma once

#include <QList>
#include <QString>
#include <optional>

#include "Models/Product.h"

namespace pharmacy {

class ProductRepository;

enum class StockResult {
    Success,
    InvalidQuantity,
    ProductNotFound,
    InsufficientStock,
    Expired,
    StorageError
};

class InventoryManager
{
public:
    explicit InventoryManager(ProductRepository& repository);

    std::optional<int> getStock(const QString& productId) const;
    bool isAvailable(const QString& productId) const;
    bool hasSufficientStock(const QString& productId, int quantity) const;

    StockResult increaseStock(const QString& productId, int quantity);
    StockResult decreaseStock(const QString& productId, int quantity);

    QList<Product> getLowStockProducts(int threshold) const;
    QList<Product> getExpiredProducts() const;

private:
    ProductRepository& repository;
};

}
