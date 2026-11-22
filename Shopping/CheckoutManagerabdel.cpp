// El file da mas2ool 3an el checkout: check el customer wel address wel stock wel prices, we create el order.   // Owner: Abdelrahman
#include "Shopping/CheckoutManagerabdel.h"

#include <QPair>
#include <optional>

#include "Inventory/InventoryManagerheba.h"
#include "Models/Order.h"
#include "Models/Product.h"
#include "Models/PromoCode.h"
#include "Repositories/ProductRepositoryheba.h"
#include "Repositories/UserRepositoryrod.h"
#include "Shopping/CartManagerhazem.h"
#include "Shopping/PromoCodeManagerhazem.h"

namespace pharmacy {

namespace {

// Sets the flag on creation and always clears it when placeOrder() returns.
class InProgressGuard
{
public:
    explicit InProgressGuard(bool& flag) : flag(flag) { flag = true; }
    ~InProgressGuard() { flag = false; }
    InProgressGuard(const InProgressGuard&) = delete;
    InProgressGuard& operator=(const InProgressGuard&) = delete;

private:
    bool& flag;
};

using StockChange = QPair<QString, int>; // productId, quantity

void restoreStock(InventoryManager& inventory, const QList<StockChange>& changes)
{
    for (const StockChange& change : changes) {
        inventory.increaseStock(change.first, change.second);
    }
}

CheckoutResult makeResult(CheckoutStatus status, const QString& failedProductId = QString())
{
    CheckoutResult result;
    result.status = status;
    result.failedProductId = failedProductId;
    return result;
}

}

CheckoutManager::CheckoutManager(CartManager& cart,
                                 PromoCodeManager& promos,
                                 InventoryManager& inventory,
                                 ProductRepository& products,
                                 UserRepository& users,
                                 OrderManager& orders)
    : cart(cart),
      promos(promos),
      inventory(inventory),
      products(products),
      users(users),
      orders(orders)
{
}

CheckoutTotals CheckoutManager::previewTotals(const QString& promoCode) const
{
    CheckoutTotals totals;
    const QList<CartItem> items = cart.getItems();
    for (const CartItem& item : items) {
        totals.subtotalMinor += item.getSubtotalMinor();
    }

    const QString code = promoCode.trimmed();
    if (!code.isEmpty()) {
        const std::optional<PromoCode> promo = promos.findValidPromo(code);
        if (promo) {
            totals.discountMinor = promo->calculateDiscountMinor(totals.subtotalMinor);
        }
    }
    if (totals.discountMinor > totals.subtotalMinor) {
        totals.discountMinor = totals.subtotalMinor;
    }

    const qint64 finalMinor = totals.subtotalMinor - totals.discountMinor;
    totals.finalMinor = finalMinor < 0 ? 0 : finalMinor;
    return totals;
}

QList<PriceChange> CheckoutManager::findPriceChanges(const QList<CartItem>& items) const
{
    QList<PriceChange> changes;
    for (const CartItem& item : items) {
        const std::optional<Product> current = products.getProductById(item.getProductId());
        if (current && item.hasPriceChanged(*current)) {
            PriceChange change;
            change.productId = current->getId();
            change.productName = current->getName();
            change.oldPriceMinor = item.getUnitPriceMinor();
            change.newPriceMinor = current->getPriceMinor();
            changes.append(change);
        }
    }
    return changes;
}

CheckoutResult CheckoutManager::placeOrder(const CheckoutRequest& request)
{
    // 0. Block a second checkout while one is still running.
    if (inProgress) {
        return makeResult(CheckoutStatus::AlreadyInProgress);
    }
    InProgressGuard guard(inProgress);

    // 1. Cart.
    if (cart.isEmpty()) {
        return makeResult(CheckoutStatus::EmptyCart);
    }
    QList<CartItem> items = cart.getItems();
    if (items.isEmpty()) {
        return makeResult(CheckoutStatus::EmptyCart);
    }

    // 2. Customer and delivery address.
    if (!users.getUserById(request.customerId)) {
        return makeResult(CheckoutStatus::CustomerNotFound);
    }
    if (!request.deliveryAddress.isValid()) {
        return makeResult(CheckoutStatus::InvalidAddress);
    }

    // 3. Every product must still exist and have enough (non-expired) stock.
    // TODO(leader decision): requiresPrescription is not enforced at checkout yet.
    QList<Product> currentProducts;
    for (const CartItem& item : items) {
        const std::optional<Product> current = products.getProductById(item.getProductId());
        if (!current) {
            return makeResult(CheckoutStatus::ProductNotFound, item.getProductId());
        }
        if (!item.isStockSufficient(*current)) {
            return makeResult(CheckoutStatus::OutOfStock, item.getProductId());
        }
        currentProducts.append(*current);
    }

    // 4. Prices that changed since the items were added to the cart.
    const QList<PriceChange> priceChanges = findPriceChanges(items);
    if (!priceChanges.isEmpty()) {
        if (!request.acceptPriceChanges) {
            CheckoutResult result = makeResult(CheckoutStatus::PriceChanged);
            result.priceChanges = priceChanges;
            return result;
        }
        for (int i = 0; i < items.size(); ++i) {
            items[i].refreshFromProduct(currentProducts.at(i));
        }
    }

    // 5. Promo code (optional).
    const QString code = request.promoCode.trimmed();
    std::optional<PromoCode> promo;
    if (!code.isEmpty()) {
        promo = promos.findValidPromo(code);
        if (!promo) {
            return makeResult(CheckoutStatus::InvalidPromoCode);
        }
    }

    // 6. Build the order. No delivery fee: Order has no field for one.
    Order order(orders.generateOrderId(), request.customerId, items, request.deliveryAddress);
    if (promo && !order.applyPromoCode(*promo)) {
        return makeResult(CheckoutStatus::InvalidPromoCode);
    }

    // 7. Take the stock; undo everything already taken if one item fails.
    QList<StockChange> decreased;
    for (const CartItem& item : items) {
        const StockResult stockResult = inventory.decreaseStock(item.getProductId(), item.getQuantity());
        if (stockResult != StockResult::Success) {
            restoreStock(inventory, decreased);
            const CheckoutStatus status = stockResult == StockResult::StorageError
                                              ? CheckoutStatus::StorageError
                                              : CheckoutStatus::OutOfStock;
            return makeResult(status, item.getProductId());
        }
        decreased.append(StockChange(item.getProductId(), item.getQuantity()));
    }

    // 8. Save the order; give all the stock back if saving fails.
    if (orders.createOrder(order) != OrderResult::Success) {
        restoreStock(inventory, decreased);
        return makeResult(CheckoutStatus::StorageError);
    }

    // 9. Done.
    cart.clear();

    CheckoutResult result = makeResult(CheckoutStatus::Success);
    result.orderId = order.getOrderId();
    result.priceChanges = priceChanges;
    result.totals.subtotalMinor = order.getTotalPriceMinor();
    result.totals.discountMinor = order.getDiscountMinor();
    result.totals.finalMinor = order.getFinalPriceMinor();
    return result;
}

}
