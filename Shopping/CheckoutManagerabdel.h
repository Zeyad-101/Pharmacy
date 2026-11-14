// El file da mas2ool 3an el checkout: check el customer wel address wel stock wel prices, we create el order.   // Owner: Abdelrahman
#pragma once

#include <QList>
#include <QString>

#include "Models/Address.h"
#include "Models/CartItem.h"
#include "Shopping/OrderManagerabdel.h"

namespace pharmacy {

class CartManager;
class PromoCodeManager;
class InventoryManager;
class ProductRepository;
class UserRepository;

struct CheckoutRequest {
    QString customerId;
    Address deliveryAddress;
    QString promoCode;
    bool acceptPriceChanges = false;
};

struct PriceChange {
    QString productId;
    QString productName;
    qint64 oldPriceMinor = 0;
    qint64 newPriceMinor = 0;
};

struct CheckoutTotals {
    qint64 subtotalMinor = 0;
    qint64 discountMinor = 0;
    qint64 finalMinor = 0;
};

enum class CheckoutStatus {
    Success,
    EmptyCart,
    CustomerNotFound,
    InvalidAddress,
    ProductNotFound,
    OutOfStock,
    PriceChanged,
    InvalidPromoCode,
    StorageError,
    AlreadyInProgress
};

struct CheckoutResult {
    CheckoutStatus status = CheckoutStatus::StorageError;
    QString orderId;
    QString failedProductId;
    QList<PriceChange> priceChanges;
    CheckoutTotals totals;
};

class CheckoutManager
{
public:
    CheckoutManager(CartManager& cart,
                    PromoCodeManager& promos,
                    InventoryManager& inventory,
                    ProductRepository& products,
                    UserRepository& users,
                    OrderManager& orders);

    CheckoutTotals previewTotals(const QString& promoCode) const;
    CheckoutResult placeOrder(const CheckoutRequest& request);

private:
    QList<PriceChange> findPriceChanges(const QList<CartItem>& items) const;

    CartManager& cart;
    PromoCodeManager& promos;
    InventoryManager& inventory;
    ProductRepository& products;
    UserRepository& users;
    OrderManager& orders;
    bool inProgress = false;
};

}
