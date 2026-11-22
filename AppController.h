// El file da howa el bridge el wa7eed ben el QML w el backend: byshayel kol el managers w by7awel el data le maps basita lel GUI.
// Owner: Abdelrhman (GUI)
#pragma once

#include <QColor>
#include <QHash>
#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>

#include "Models/Product.h"
#include "Repositories/ProductRepositoryheba.h"
#include "Repositories/UserRepositoryrod.h"
#include "Repositories/OrderRepositoryfay.h"
#include "Repositories/PromoCodeRepositoryhazem.h"
#include "Inventory/InventoryManagerheba.h"
#include "Medicine/MedicineManagerjudy.h"
#include "Accounts/Authenticationrod.h"
#include "Accounts/UserManagerrod.h"
#include "Accounts/AdminManagerfay.h"
#include "Shopping/CartManagerhazem.h"
#include "Shopping/PromoCodeManagerhazem.h"
#include "Shopping/OrderManagerabdel.h"
#include "Shopping/CheckoutManagerabdel.h"

class QQmlEngine;
class QJSEngine;

namespace pharmacy {

class AppController : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(App)
    QML_SINGLETON

    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY sessionChanged)
    Q_PROPERTY(bool isAdmin READ isAdmin NOTIFY sessionChanged)
    Q_PROPERTY(QString currentUserName READ currentUserName NOTIFY sessionChanged)
    Q_PROPERTY(int cartCount READ cartCount NOTIFY cartChanged)
    Q_PROPERTY(QString cartSubtotalText READ cartSubtotalText NOTIFY cartChanged)
    Q_PROPERTY(QString promoCode READ promoCode NOTIFY cartChanged)
    Q_PROPERTY(QString currentPage READ currentPage NOTIFY pageChanged)
    Q_PROPERTY(QVariantMap pageParams READ pageParams NOTIFY pageChanged)

public:
    explicit AppController(const QString& dataDir, QObject* parent = nullptr);

    // Startup: load every JSON file and create the admin on the first run (same as the old main.cpp)
    bool initialize(QString* errorMessage, bool* adminCreated);

    // Used by main.cpp for the --selftest summary
    QString dataDir() const;
    int productCount() const;
    int userCount() const;
    int promoCodeCount() const;
    int orderCount() const;

    // QML singleton: always return the instance created in main.cpp
    static void setInstance(AppController* controller);
    static AppController* create(QQmlEngine* qmlEngine, QJSEngine* jsEngine);

    // Money is piastres (qint64); this is the only place that formats it
    static QString formatEgp(qint64 amountMinor);

    bool isLoggedIn() const;
    bool isAdmin() const;
    QString currentUserName() const;
    int cartCount() const;
    QString cartSubtotalText() const;
    QString promoCode() const;
    QString currentPage() const;
    QVariantMap pageParams() const;

    // Navigation (UI state only)
    Q_INVOKABLE void go(const QString& page, const QVariantMap& params = QVariantMap());
    Q_INVOKABLE void back();

    // UI events that pages ask the main window to show
    Q_INVOKABLE void showToast(const QString& kind, const QString& title, const QString& message);
    Q_INVOKABLE void openCartDrawer();
    Q_INVOKABLE void openQuickView(const QString& productId);

    // Catalog
    Q_INVOKABLE QVariantList categories() const;
    Q_INVOKABLE int allProductsCount() const;
    Q_INVOKABLE QVariantMap products(const QString& category, const QString& search,
                                     const QString& sort, const QStringList& brands,
                                     bool inStockOnly) const;
    Q_INVOKABLE QVariantList featuredProducts(int count) const;
    Q_INVOKABLE QVariantMap product(const QString& productId) const;
    Q_INVOKABLE QVariantList relatedProducts(const QString& productId, int count) const;
    Q_INVOKABLE QVariantList brands(const QString& category, const QString& search) const;
    Q_INVOKABLE QVariantMap searchSuggestions(const QString& term, int count) const;
    Q_INVOKABLE QVariantList recentlyViewed(const QString& excludeId, int count) const;

    // Cart
    Q_INVOKABLE QVariantMap addToCart(const QString& productId, int quantity);
    Q_INVOKABLE QVariantMap cartItems() const;
    Q_INVOKABLE QVariantMap changeCartQuantity(const QString& productId, int quantity);
    Q_INVOKABLE QVariantMap removeFromCart(const QString& productId);
    Q_INVOKABLE QVariantMap applyPromo(const QString& code);
    Q_INVOKABLE void clearPromo();
    Q_INVOKABLE QVariantMap cartTotals() const;
    Q_INVOKABLE bool cartNeedsPrescription() const;
    Q_INVOKABLE QStringList prescriptionProductNames() const;

    // Accounts
    Q_INVOKABLE QVariantMap login(const QString& emailOrUsername, const QString& password);
    Q_INVOKABLE void logout();
    Q_INVOKABLE QVariantMap registerCustomer(const QVariantMap& form);
    Q_INVOKABLE QVariantMap currentUserProfile() const;
    Q_INVOKABLE bool isValidField(const QString& kind, const QString& value) const;

    // Checkout and orders
    Q_INVOKABLE void goToCheckout();
    Q_INVOKABLE QVariantMap checkAddress(const QVariantMap& address) const;
    Q_INVOKABLE QVariantMap placeOrder(const QVariantMap& address, bool saveAddress,
                                       bool prescriptionConfirmed, bool acceptPriceChanges);
    Q_INVOKABLE QVariantMap order(const QString& orderId) const;

    // My account: profile, password, own orders (OrderManager decides what can be cancelled)
    Q_INVOKABLE QVariantMap updateProfile(const QVariantMap& form);
    Q_INVOKABLE QVariantMap changePassword(const QString& currentPassword, const QString& newPassword,
                                           const QString& confirmPassword);
    Q_INVOKABLE QVariantList myOrders() const;
    Q_INVOKABLE QVariantMap cancelMyOrder(const QString& orderId);

    // Admin area (every call checks Authentication::isCurrentUserAdmin)
    Q_INVOKABLE QVariantMap adminSummary(int lowStockThreshold) const;
    Q_INVOKABLE QVariantList adminProducts(const QString& search) const;
    Q_INVOKABLE QVariantMap adminProductForm(const QString& productId) const;
    Q_INVOKABLE QVariantMap saveProduct(const QVariantMap& form);
    Q_INVOKABLE QVariantMap removeProduct(const QString& productId);
    Q_INVOKABLE QVariantList adminOrders(const QString& status) const;
    Q_INVOKABLE QVariantMap updateOrderStatus(const QString& orderId, const QString& newStatus);
    Q_INVOKABLE QVariantList lowStockProducts(int threshold) const;
    Q_INVOKABLE QVariantList expiredProducts() const;
    Q_INVOKABLE QVariantMap increaseStock(const QString& productId, const QString& quantityText);
    Q_INVOKABLE QStringList productCategories() const;

    // Icons: the SVG with its colour replaced, as a data URL
    Q_INVOKABLE QString iconSource(const QString& name, const QColor& color);

signals:
    void sessionChanged();
    void cartChanged();
    void pageChanged();
    void toastRequested(const QString& kind, const QString& title, const QString& message);
    void cartDrawerRequested();
    void quickViewRequested(const QString& productId);
    // Products, stock or orders changed (admin actions, cancellations, new orders): pages re-read
    void dataChanged();

private:
    QList<Product> baseProducts(const QString& category, const QString& search) const;
    QVariantMap productToMap(const Product& product) const;
    QVariantList productList(const QList<Product>& list) const;
    static QString brandOf(const Product& product);
    static QString descriptionOf(const Product& product);
    static QString imageUrlFor(const QString& imagePath);
    static QString cartMessage(CartResult result);
    static QString promoMessage(PromoResult result, int percentage);
    static QString userMessage(UserResult result);
    static Address addressFrom(const QVariantMap& map);
    static QVariantMap addressToMap(const Address& address);
    static QString statusLabel(const QString& status);
    void resolveRoute(QString* page, QVariantMap* params) const;
    static QString adminMessage(AdminResult result);
    static QString stockMessage(StockResult result);
    static QString orderMessage(OrderResult result);
    static bool parseMoney(const QString& text, qint64* amountMinor);
    static QString userField(UserResult result);
    QVariantMap orderSummaryMap(const Order& order) const;
    QVariantMap adminProductRow(const Product& product) const;
    QString nextProductId() const;
    bool ownsOrder(const Order& order) const;
    QString productName(const QString& productId) const;

    QString m_dataDir;
    // Highest product number added in this session (new product ids are never reused, see nextProductId)
    int m_highestIssuedProductNumber = 0;

    ProductRepository m_productRepository;
    UserRepository m_userRepository;
    OrderRepository m_orderRepository;
    PromoCodeRepository m_promoCodeRepository;

    InventoryManager m_inventoryManager;
    MedicineManager m_medicineManager;
    Authentication m_authentication;
    UserManager m_userManager;
    AdminManager m_adminManager;
    CartManager m_cartManager;
    PromoCodeManager m_promoCodeManager;
    OrderManager m_orderManager;
    CheckoutManager m_checkoutManager;

    QString m_currentPage;
    QVariantMap m_pageParams;
    QList<QPair<QString, QVariantMap>> m_history;
    QStringList m_recentlyViewed;
    QString m_promoCode;
    QHash<QString, QString> m_iconCache;

    static AppController* s_instance;
};

}
