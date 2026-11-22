// El file da mas2ool 3an el makhzoon: check el kameya el mawgooda, w ziyadet aw na2s el stock.
// Owner: Heba
#include "Inventory/InventoryManagerheba.h"

#include <climits>

#include "Repositories/ProductRepositoryheba.h"

namespace pharmacy {

InventoryManager::InventoryManager(ProductRepository& repository)
    : repository(repository)
{
}

std::optional<int> InventoryManager::getStock(const QString& productId) const
{
    // If the product does not exist, there is no stock to show
    std::optional<Product> product = repository.getProductById(productId);
    if (!product) {
        return std::nullopt;
    }
    return product->getStockQuantity();
}

bool InventoryManager::isAvailable(const QString& productId) const
{
    // Unknown product is never available
    std::optional<Product> product = repository.getProductById(productId);
    if (!product) {
        return false;
    }

    // In stock and not expired
    return product->isAvailable();
}

bool InventoryManager::hasSufficientStock(const QString& productId, int quantity) const
{
    // Quantity must be at least 1
    if (quantity <= 0) {
        return false;
    }

    // Unknown product has no stock
    std::optional<Product> product = repository.getProductById(productId);
    if (!product) {
        return false;
    }

    return product->hasSufficientStock(quantity);
}

StockResult InventoryManager::increaseStock(const QString& productId, int quantity)
{
    // Quantity must be at least 1
    if (quantity <= 0) {
        return StockResult::InvalidQuantity;
    }

    // The product must exist
    std::optional<Product> product = repository.getProductById(productId);
    if (!product) {
        return StockResult::ProductNotFound;
    }

    // Do not go past the biggest int value
    int stock = product->getStockQuantity();
    if (stock > INT_MAX - quantity) {
        return StockResult::InvalidQuantity;
    }

    // Save the new stock (restocking expired products is allowed)
    Product copy = *product;
    copy.setStockQuantity(stock + quantity);
    if (!repository.updateProduct(copy)) {
        return StockResult::StorageError;
    }
    return StockResult::Success;
}

StockResult InventoryManager::decreaseStock(const QString& productId, int quantity)
{
    // Quantity must be at least 1
    if (quantity <= 0) {
        return StockResult::InvalidQuantity;
    }

    // The product must exist
    std::optional<Product> product = repository.getProductById(productId);
    if (!product) {
        return StockResult::ProductNotFound;
    }

    // Expired products cannot be sold
    if (product->isExpired()) {
        return StockResult::Expired;
    }

    // There must be enough stock
    int stock = product->getStockQuantity();
    if (stock < quantity) {
        return StockResult::InsufficientStock;
    }

    // Save the new stock (it can reach 0, never below)
    Product copy = *product;
    copy.setStockQuantity(stock - quantity);
    if (!repository.updateProduct(copy)) {
        return StockResult::StorageError;
    }
    return StockResult::Success;
}

QList<Product> InventoryManager::getLowStockProducts(int threshold) const
{
    QList<Product> result;

    // A negative threshold makes no sense
    if (threshold < 0) {
        return result;
    }

    // Keep products with stock at or below the threshold
    const QList<Product> allProducts = repository.getAllProducts();
    for (const Product& product : allProducts) {
        if (product.getStockQuantity() <= threshold) {
            result.append(product);
        }
    }
    return result;
}

QList<Product> InventoryManager::getExpiredProducts() const
{
    QList<Product> result;

    // Keep only the expired products
    const QList<Product> allProducts = repository.getAllProducts();
    for (const Product& product : allProducts) {
        if (product.isExpired()) {
            result.append(product);
        }
    }
    return result;
}

}
