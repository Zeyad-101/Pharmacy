// El file da mas2ool 3an el shopping cart: add w remove lel products, ta3deel el kameya, we 7esab el subtotal.
// Owner: Hazem
#include "Shopping/CartManagerhazem.h"

#include <climits>
#include <optional>

namespace pharmacy {

CartManager::CartManager(ProductRepository& productRepository, InventoryManager& inventory)
    : productRepository(productRepository),
      inventory(inventory)
{
}

int CartManager::indexOf(const QString& productId) const
{
    for (int i = 0; i < items.size(); ++i) {
        if (items[i].getProductId() == productId) {
            return i;
        }
    }
    return -1;
}

CartResult CartManager::addItem(const QString& productId, int quantity)
{
    if (quantity <= 0) {
        return CartResult::InvalidQuantity;
    }

    const QString id = productId.trimmed();
    const std::optional<Product> product = productRepository.getProductById(id);
    if (!product) {
        return CartResult::ProductNotFound;
    }

    const int index = indexOf(id);
    const int existingQuantity = index == -1 ? 0 : items[index].getQuantity();
    if (existingQuantity > INT_MAX - quantity) {
        return CartResult::InvalidQuantity;
    }

    const int totalQuantity = existingQuantity + quantity;
    if (!inventory.hasSufficientStock(id, totalQuantity)) {
        return CartResult::InsufficientStock;
    }

    if (index == -1) {
        items.append(CartItem(*product, quantity));
    } else {
        items[index].setQuantity(totalQuantity);
    }
    return CartResult::Success;
}

CartResult CartManager::removeItem(const QString& productId)
{
    const int index = indexOf(productId.trimmed());
    if (index == -1) {
        return CartResult::ItemNotInCart;
    }
    items.removeAt(index);
    return CartResult::Success;
}

CartResult CartManager::changeQuantity(const QString& productId, int newQuantity)
{
    if (newQuantity <= 0) {
        return CartResult::InvalidQuantity;
    }

    const QString id = productId.trimmed();
    const int index = indexOf(id);
    if (index == -1) {
        return CartResult::ItemNotInCart;
    }
    if (!productRepository.existsById(id)) {
        return CartResult::ProductNotFound;
    }
    if (!inventory.hasSufficientStock(id, newQuantity)) {
        return CartResult::InsufficientStock;
    }

    items[index].setQuantity(newQuantity);
    return CartResult::Success;
}

QList<CartItem> CartManager::getItems() const
{
    return items;
}

qint64 CartManager::getSubtotalMinor() const
{
    qint64 subtotal = 0;
    for (const CartItem& item : items) {
        subtotal += item.getSubtotalMinor();
    }
    return subtotal;
}

int CartManager::getItemCount() const
{
    return items.size();
}

bool CartManager::isEmpty() const
{
    return items.isEmpty();
}

void CartManager::clear()
{
    items.clear();
}

}
