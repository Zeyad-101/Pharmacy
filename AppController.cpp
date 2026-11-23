// El file da fih tanfeez el AppController: by3mel load lel data, w by7awel natayej el backend le maps w resayel wad7a lel QML.
// Owner: Abdelrhman (GUI)
#include "AppController.h"

#include <QByteArray>
#include <QDate>
#include <QFile>
#include <QDateTime>
#include <QUrl>
#include <QImageReader>
#include <QImage>
#include <QFileInfo>
#include <QDir>
#include <QJSEngine>
#include <QLocale>
#include <QQmlEngine>
#include <algorithm>
#include <optional>

#include "Models/Address.h"
#include "Models/CartItem.h"
#include "Models/Order.h"
#include "Models/User.h"
#include "Medicine/CategoryManagerjudy.h"
#include "Utils/Validationfay.h"

namespace pharmacy {

namespace {

// Where qt_add_qml_module puts the Resources folder inside the qrc
const char kResourceRoot[] = ":/qt/qml/PharmaCare/Resources/";
const char kResourceUrl[] = "qrc:/qt/qml/PharmaCare/Resources/";

// A product with this many items or fewer shows the "Only N left" badge
const int kLowStockThreshold = 5;

// The colour used inside the exported SVG icons (Midnight 900)
const char kIconColor[] = "rgb(10, 22, 51)";

QString categoryImageKey(const QString& category)
{
    if (category == QLatin1String(CategoryManager::CATEGORY_MEDICINES)) {
        return QStringLiteral("medicines");
    }
    if (category == QLatin1String(CategoryManager::CATEGORY_SKINCARE)) {
        return QStringLiteral("skincare");
    }
    if (category == QLatin1String(CategoryManager::CATEGORY_VITAMINS)) {
        return QStringLiteral("vitamins");
    }
    if (category == QLatin1String(CategoryManager::CATEGORY_FIRST_AID)) {
        return QStringLiteral("first_aid");
    }
    return QString();
}

}

AppController* AppController::s_instance = nullptr;

AppController::AppController(const QString& dataDir, QObject* parent)
    : QObject(parent),
      m_dataDir(dataDir),
      m_productRepository(dataDir + QStringLiteral("/products.json")),
      m_userRepository(dataDir + QStringLiteral("/users.json")),
      m_orderRepository(dataDir + QStringLiteral("/orders.json")),
      m_promoCodeRepository(dataDir + QStringLiteral("/promo_codes.json")),
      m_inventoryManager(m_productRepository),
      m_medicineManager(m_productRepository),
      m_authentication(m_userRepository),
      m_userManager(m_userRepository),
      m_adminManager(m_authentication, m_medicineManager, m_orderRepository),
      m_cartManager(m_productRepository, m_inventoryManager),
      m_promoCodeManager(m_promoCodeRepository),
      m_orderManager(m_orderRepository, m_inventoryManager),
      m_checkoutManager(m_cartManager, m_promoCodeManager, m_inventoryManager,
                        m_productRepository, m_userRepository, m_orderManager),
      m_currentPage(QStringLiteral("home"))
{
}

bool AppController::initialize(QString* errorMessage, bool* adminCreated)
{
    if (adminCreated) {
        *adminCreated = false;
    }

    // Load every file, and stop if one of them is broken (same order as before)
    if (!m_productRepository.load()) {
        if (errorMessage) {
            *errorMessage = m_productRepository.lastError();
        }
        return false;
    }
    if (!m_userRepository.load()) {
        if (errorMessage) {
            *errorMessage = m_userRepository.lastError();
        }
        return false;
    }
    if (!m_orderRepository.load()) {
        if (errorMessage) {
            *errorMessage = m_orderRepository.lastError();
        }
        return false;
    }
    if (!m_promoCodeRepository.load()) {
        if (errorMessage) {
            *errorMessage = m_promoCodeRepository.lastError();
        }
        return false;
    }

    // First run: create the admin account if there is no admin yet
    bool adminExists = false;
    const QList<User> allUsers = m_userRepository.getAllUsers();
    for (const User& user : allUsers) {
        if (user.isAdmin()) {
            adminExists = true;
        }
    }
    if (!adminExists) {
        User admin(QStringLiteral("A001"),
                   QStringLiteral("admin"),
                   QStringLiteral("admin@pharmacare.eg"),
                   Authentication::hashPassword(QStringLiteral("Admin@1234")),
                   QStringLiteral("01000000000"),
                   Address(),
                   QLatin1String(User::ROLE_ADMIN));
        if (!m_userRepository.saveUser(admin)) {
            if (errorMessage) {
                *errorMessage = QStringLiteral("could not create the admin account: ")
                                + m_userRepository.lastError();
            }
            return false;
        }
        if (adminCreated) {
            *adminCreated = true;
        }
    }
    return true;
}

QString AppController::dataDir() const
{
    return m_dataDir;
}

int AppController::productCount() const
{
    return m_productRepository.getAllProducts().size();
}

int AppController::userCount() const
{
    return m_userRepository.getAllUsers().size();
}

int AppController::promoCodeCount() const
{
    return m_promoCodeRepository.getAllPromoCodes().size();
}

int AppController::orderCount() const
{
    return m_orderRepository.getAllOrders().size();
}

void AppController::setInstance(AppController* controller)
{
    s_instance = controller;
}

AppController* AppController::create(QQmlEngine* qmlEngine, QJSEngine* jsEngine)
{
    Q_UNUSED(qmlEngine)
    Q_UNUSED(jsEngine)
    // main.cpp owns the controller, so QML must never delete it
    QJSEngine::setObjectOwnership(s_instance, QJSEngine::CppOwnership);
    return s_instance;
}

QString AppController::formatEgp(qint64 amountMinor)
{
    const bool negative = amountMinor < 0;
    const qint64 absolute = negative ? -amountMinor : amountMinor;
    const qint64 pounds = absolute / 100;
    const qint64 piastres = absolute % 100;

    // Thousand separators, added by hand so every platform shows the same text
    QString digits = QString::number(pounds);
    for (int i = digits.size() - 3; i > 0; i -= 3) {
        digits.insert(i, QLatin1Char(','));
    }

    QString text;
    if (negative) {
        text.append(QChar(0x2212)); // the real minus sign used by the design
    }
    text.append(digits);
    text.append(QLatin1Char('.'));
    text.append(QStringLiteral("%1").arg(piastres, 2, 10, QLatin1Char('0')));
    text.append(QStringLiteral(" EGP"));
    return text;
}

bool AppController::isLoggedIn() const
{
    return m_authentication.isLoggedIn();
}

bool AppController::isAdmin() const
{
    return m_authentication.isCurrentUserAdmin();
}

QString AppController::currentUserName() const
{
    const std::optional<User> user = m_authentication.currentUser();
    if (!user) {
        return QString();
    }
    return user->getUsername();
}

int AppController::cartCount() const
{
    // The design counts units (2 x Omega-3 = 2 items), so add up the quantities of the cart lines
    int units = 0;
    const QList<CartItem> items = m_cartManager.getItems();
    for (const CartItem& item : items) {
        units += item.getQuantity();
    }
    return units;
}

QString AppController::cartSubtotalText() const
{
    return formatEgp(m_cartManager.getSubtotalMinor());
}

QString AppController::promoCode() const
{
    return m_promoCode;
}

QString AppController::currentPage() const
{
    return m_currentPage;
}

QVariantMap AppController::pageParams() const
{
    return m_pageParams;
}

// UI route rules: admins never see the bag or the checkout, the admin area needs an admin, the account needs a session
void AppController::resolveRoute(QString* page, QVariantMap* params) const
{
    const bool accountPage = *page == QLatin1String("account") || *page == QLatin1String("orderDetails");
    if (isAdmin() && (*page == QLatin1String("cart") || *page == QLatin1String("checkout"))) {
        *page = QStringLiteral("admin");
        *params = QVariantMap();
    } else if (*page == QLatin1String("admin") && !isAdmin()) {
        *params = QVariantMap();
        if (isLoggedIn()) {
            *page = QStringLiteral("home");
        } else {
            *page = QStringLiteral("login");
            params->insert(QStringLiteral("next"), QStringLiteral("admin"));
        }
    } else if (accountPage && !isLoggedIn()) {
        *page = QStringLiteral("login");
        *params = QVariantMap();
        params->insert(QStringLiteral("next"), QStringLiteral("account"));
    }
}

void AppController::go(const QString& page, const QVariantMap& params)
{
    if (page.isEmpty()) {
        return;
    }
    QString target = page;
    QVariantMap targetParams = params;
    resolveRoute(&target, &targetParams);
    m_history.append(qMakePair(m_currentPage, m_pageParams));
    m_currentPage = target;
    m_pageParams = targetParams;

    // Remember the products the customer opened ("Recently viewed")
    if (target == QLatin1String("product")) {
        const QString id = targetParams.value(QStringLiteral("id")).toString();
        if (!id.isEmpty()) {
            m_recentlyViewed.removeAll(id);
            m_recentlyViewed.prepend(id);
        }
    }
    emit pageChanged();
}

void AppController::back()
{
    if (m_history.isEmpty()) {
        m_currentPage = QStringLiteral("home");
        m_pageParams = QVariantMap();
    } else {
        const QPair<QString, QVariantMap> previous = m_history.takeLast();
        m_currentPage = previous.first;
        m_pageParams = previous.second;
    }
    resolveRoute(&m_currentPage, &m_pageParams);
    emit pageChanged();
}

void AppController::showToast(const QString& kind, const QString& title, const QString& message)
{
    emit toastRequested(kind, title, message);
}

void AppController::openCartDrawer()
{
    emit cartDrawerRequested();
}

void AppController::openQuickView(const QString& productId)
{
    emit quickViewRequested(productId);
}

QVariantList AppController::categories() const
{
    QVariantList list;
    const QStringList names = CategoryManager::getAllCategories();
    for (const QString& name : names) {
        QVariantMap item;
        item.insert(QStringLiteral("name"), name);
        item.insert(QStringLiteral("count"), m_medicineManager.getMedicinesByCategory(name).size());
        const QString key = categoryImageKey(name);
        item.insert(QStringLiteral("key"), key);
        item.insert(QStringLiteral("image"),
                    key.isEmpty() ? QString() : imageUrlFor(QStringLiteral("images/category_") + key + QStringLiteral(".png")));
        list.append(item);
    }
    return list;
}

int AppController::allProductsCount() const
{
    return m_medicineManager.getAllMedicines().size();
}

QVariantMap AppController::products(const QString& category, const QString& search,
                                    const QString& sort, const QStringList& brands,
                                    bool inStockOnly) const
{
    // 1) The base list comes straight from MedicineManager
    const QList<Product> base = baseProducts(category, search);

    // 2) Optional filters chosen in the sidebar
    QList<Product> shown;
    for (const Product& product : base) {
        if (!brands.isEmpty() && !brands.contains(brandOf(product))) {
            continue;
        }
        if (inStockOnly && !product.isAvailable()) {
            continue;
        }
        shown.append(product);
    }

    // 3) Sorting: "featured" keeps the backend order
    if (sort == QLatin1String("priceAsc")) {
        std::stable_sort(shown.begin(), shown.end(), [](const Product& a, const Product& b) {
            return a.getPriceMinor() < b.getPriceMinor();
        });
    } else if (sort == QLatin1String("priceDesc")) {
        std::stable_sort(shown.begin(), shown.end(), [](const Product& a, const Product& b) {
            return a.getPriceMinor() > b.getPriceMinor();
        });
    }

    // How many products of the base list are available (the "In stock" filter count)
    int inStockCount = 0;
    for (const Product& product : base) {
        if (product.isAvailable()) {
            ++inStockCount;
        }
    }

    QVariantMap result;
    result.insert(QStringLiteral("ok"), true);
    result.insert(QStringLiteral("items"), productList(shown));
    result.insert(QStringLiteral("count"), shown.size());
    result.insert(QStringLiteral("total"), base.size());
    result.insert(QStringLiteral("inStockCount"), inStockCount);
    return result;
}

QList<Product> AppController::baseProducts(const QString& category, const QString& search) const
{
    // Search (MedicineManager::searchMedicines), optionally inside a category; otherwise the category or everything
    const QString term = search.trimmed();
    if (!term.isEmpty()) {
        const QList<Product> found = m_medicineManager.searchMedicines(term);
        if (category.isEmpty()) {
            return found;
        }
        const QString wanted = CategoryManager::normalizeCategory(category);
        QList<Product> inCategory;
        for (const Product& product : found) {
            if (product.getCategory() == wanted) {
                inCategory.append(product);
            }
        }
        return inCategory;
    }
    if (!category.isEmpty()) {
        return m_medicineManager.getMedicinesByCategory(category);
    }
    return m_medicineManager.getAllMedicines();
}

QVariantList AppController::featuredProducts(int count) const
{
    // The backend has no "featured" flag, so the first products in the catalogue are shown
    const QList<Product> all = m_medicineManager.getAllMedicines();
    return productList(all.mid(0, qMax(0, count)));
}

QVariantMap AppController::product(const QString& productId) const
{
    const std::optional<Product> found = m_medicineManager.findMedicineById(productId);
    if (!found) {
        QVariantMap result;
        result.insert(QStringLiteral("ok"), false);
        result.insert(QStringLiteral("message"), QStringLiteral("This product could not be found."));
        return result;
    }
    QVariantMap result = productToMap(*found);
    result.insert(QStringLiteral("ok"), true);
    return result;
}

QVariantList AppController::relatedProducts(const QString& productId, int count) const
{
    QList<Product> related;
    const std::optional<Product> found = m_medicineManager.findMedicineById(productId);
    if (!found) {
        return QVariantList();
    }
    const QList<Product> sameCategory = m_medicineManager.getMedicinesByCategory(found->getCategory());
    for (const Product& product : sameCategory) {
        if (product.getId() != found->getId() && related.size() < count) {
            related.append(product);
        }
    }
    return productList(related);
}

QVariantList AppController::brands(const QString& category, const QString& search) const
{
    // The brands of the products the shop page is showing (same base list as products())
    const QList<Product> list = baseProducts(category, search);
    QStringList names;
    QHash<QString, int> counts;
    for (const Product& product : list) {
        const QString brand = brandOf(product);
        if (brand.isEmpty()) {
            continue;
        }
        if (!counts.contains(brand)) {
            names.append(brand);
        }
        counts[brand] += 1;
    }
    names.sort(Qt::CaseInsensitive);

    QVariantList result;
    for (const QString& name : names) {
        QVariantMap item;
        item.insert(QStringLiteral("name"), name);
        item.insert(QStringLiteral("count"), counts.value(name));
        result.append(item);
    }
    return result;
}

QVariantMap AppController::searchSuggestions(const QString& term, int count) const
{
    const QList<Product> found = m_medicineManager.searchMedicines(term);
    QVariantMap result;
    result.insert(QStringLiteral("term"), term.trimmed());
    result.insert(QStringLiteral("total"), found.size());
    result.insert(QStringLiteral("items"), productList(found.mid(0, qMax(0, count))));
    return result;
}

QVariantList AppController::recentlyViewed(const QString& excludeId, int count) const
{
    QList<Product> list;
    for (const QString& id : m_recentlyViewed) {
        if (id == excludeId || list.size() >= count) {
            continue;
        }
        const std::optional<Product> found = m_medicineManager.findMedicineById(id);
        if (found) {
            list.append(*found);
        }
    }
    return productList(list);
}

QVariantMap AppController::addToCart(const QString& productId, int quantity)
{
    if (isAdmin()) {
        // UI rule: admins manage the shop, they do not buy (the buttons are hidden; this is the safety net)
        QVariantMap refused;
        refused.insert(QStringLiteral("ok"), false);
        refused.insert(QStringLiteral("message"), QStringLiteral("Admin accounts cannot shop. Sign in as a customer to buy."));
        refused.insert(QStringLiteral("count"), cartCount());
        refused.insert(QStringLiteral("productName"), productName(productId));
        return refused;
    }
    const CartResult status = m_cartManager.addItem(productId, quantity);
    QVariantMap result;
    result.insert(QStringLiteral("ok"), status == CartResult::Success);
    result.insert(QStringLiteral("message"), cartMessage(status));
    result.insert(QStringLiteral("count"), cartCount());
    const std::optional<Product> found = m_medicineManager.findMedicineById(productId);
    result.insert(QStringLiteral("productName"), found ? found->getName() : QString());
    if (status == CartResult::Success) {
        emit cartChanged();
    }
    return result;
}

QVariantMap AppController::cartItems() const
{
    QVariantList rows;
    const QList<CartItem> items = m_cartManager.getItems();
    for (const CartItem& item : items) {
        const Product product = item.getProduct();
        QVariantMap row;
        row.insert(QStringLiteral("id"), item.getProductId());
        row.insert(QStringLiteral("name"), product.getName());
        row.insert(QStringLiteral("brand"), brandOf(product));
        row.insert(QStringLiteral("image"), productImageUrl(product));
        row.insert(QStringLiteral("quantity"), item.getQuantity());
        row.insert(QStringLiteral("unitPriceText"), formatEgp(item.getUnitPriceMinor()));
        row.insert(QStringLiteral("lineTotalText"), formatEgp(item.getSubtotalMinor()));
        row.insert(QStringLiteral("requiresPrescription"), product.getRequiresPrescription());
        // The latest stock decides how far "+" can go
        const std::optional<int> stock = m_inventoryManager.getStock(item.getProductId());
        row.insert(QStringLiteral("maxQuantity"), stock ? qMax(1, *stock) : item.getQuantity());
        row.insert(QStringLiteral("inStock"), m_inventoryManager.isAvailable(item.getProductId()));
        rows.append(row);
    }
    QVariantMap result;
    result.insert(QStringLiteral("items"), rows);
    result.insert(QStringLiteral("count"), cartCount());
    result.insert(QStringLiteral("empty"), m_cartManager.isEmpty());
    result.insert(QStringLiteral("subtotalText"), formatEgp(m_cartManager.getSubtotalMinor()));
    return result;
}

QVariantMap AppController::changeCartQuantity(const QString& productId, int quantity)
{
    const CartResult status = m_cartManager.changeQuantity(productId, quantity);
    QVariantMap result;
    result.insert(QStringLiteral("ok"), status == CartResult::Success);
    result.insert(QStringLiteral("message"), status == CartResult::Success
                                                 ? productName(productId) + QStringLiteral(" quantity updated to ")
                                                       + QString::number(quantity) + QLatin1Char('.')
                                                 : cartMessage(status));
    if (status == CartResult::Success) {
        emit cartChanged();
    }
    return result;
}

QVariantMap AppController::removeFromCart(const QString& productId)
{
    // Remember the quantity, so the page can offer "Undo" (addToCart with the same quantity)
    int quantity = 0;
    const QList<CartItem> items = m_cartManager.getItems();
    for (const CartItem& item : items) {
        if (item.getProductId() == productId) {
            quantity = item.getQuantity();
        }
    }
    const QString name = productName(productId);
    const CartResult status = m_cartManager.removeItem(productId);
    QVariantMap result;
    result.insert(QStringLiteral("ok"), status == CartResult::Success);
    result.insert(QStringLiteral("quantity"), quantity);
    result.insert(QStringLiteral("message"), status == CartResult::Success
                                                 ? name + QStringLiteral(" was removed from your bag.")
                                                 : cartMessage(status));
    if (status == CartResult::Success) {
        if (m_cartManager.isEmpty()) {
            m_promoCode.clear();
        }
        emit cartChanged();
    }
    return result;
}

QVariantMap AppController::applyPromo(const QString& code)
{
    const PromoApplication application = m_promoCodeManager.applyPromoCode(code.trimmed(), m_cartManager.getSubtotalMinor());
    const bool ok = application.result == PromoResult::Success;
    if (ok) {
        m_promoCode = code.trimmed();
        emit cartChanged();
    }
    QVariantMap result;
    result.insert(QStringLiteral("ok"), ok);
    result.insert(QStringLiteral("message"), promoMessage(application.result, application.discountPercentage));
    result.insert(QStringLiteral("code"), code.trimmed());
    result.insert(QStringLiteral("percentage"), application.discountPercentage);
    result.insert(QStringLiteral("discountText"), formatEgp(-application.discountMinor));
    result.insert(QStringLiteral("finalText"), formatEgp(application.finalMinor));
    return result;
}

void AppController::clearPromo()
{
    m_promoCode.clear();
    emit cartChanged();
}

QVariantMap AppController::cartTotals() const
{
    // CheckoutManager::previewTotals gives the same numbers the order will use
    const CheckoutTotals totals = m_checkoutManager.previewTotals(m_promoCode);
    int percentage = 0;
    if (!m_promoCode.isEmpty()) {
        const std::optional<PromoCode> promo = m_promoCodeManager.findValidPromo(m_promoCode);
        if (promo) {
            percentage = promo->getDiscountPercentage();
        }
    }
    QVariantMap result;
    result.insert(QStringLiteral("count"), cartCount());
    result.insert(QStringLiteral("empty"), m_cartManager.isEmpty());
    result.insert(QStringLiteral("subtotalText"), formatEgp(totals.subtotalMinor));
    result.insert(QStringLiteral("hasDiscount"), totals.discountMinor > 0);
    result.insert(QStringLiteral("discountText"), formatEgp(-totals.discountMinor));
    result.insert(QStringLiteral("totalText"), formatEgp(totals.finalMinor));
    result.insert(QStringLiteral("promoCode"), m_promoCode);
    result.insert(QStringLiteral("percentage"), percentage);
    return result;
}

bool AppController::cartNeedsPrescription() const
{
    return !prescriptionProductNames().isEmpty();
}

QStringList AppController::prescriptionProductNames() const
{
    QStringList names;
    const QList<CartItem> items = m_cartManager.getItems();
    for (const CartItem& item : items) {
        if (item.getProduct().getRequiresPrescription()) {
            names.append(item.getProduct().getName());
        }
    }
    return names;
}

QVariantMap AppController::login(const QString& emailOrUsername, const QString& password)
{
    const LoginResult status = m_authentication.login(emailOrUsername.trimmed(), password);
    QVariantMap result;
    result.insert(QStringLiteral("ok"), status == LoginResult::Success);
    switch (status) {
    case LoginResult::Success:
        result.insert(QStringLiteral("message"), QStringLiteral("Welcome back, ") + currentUserName() + QLatin1Char('.'));
        break;
    case LoginResult::InvalidInput:
        result.insert(QStringLiteral("message"), QStringLiteral("Please enter your email or username and your password."));
        break;
    case LoginResult::InvalidCredentials:
        result.insert(QStringLiteral("message"), QStringLiteral("The email, username or password is not correct."));
        break;
    }
    if (status == LoginResult::Success) {
        emit sessionChanged();
    }
    return result;
}

void AppController::logout()
{
    m_guestCheckout = false;
    m_lastGuestOrderId.clear();
    m_authentication.logout();
    emit sessionChanged();
}

QVariantMap AppController::registerCustomer(const QVariantMap& form)
{
    const QString username = form.value(QStringLiteral("username")).toString().trimmed();
    const QString email = form.value(QStringLiteral("email")).toString().trimmed();
    const QString password = form.value(QStringLiteral("password")).toString();
    const QString phone = form.value(QStringLiteral("phone")).toString().trimmed();
    const Address address = addressFrom(form);

    QString newUserId;
    const UserResult status = m_userManager.registerCustomer(username, email, password, phone, address, &newUserId);
    QVariantMap result;
    result.insert(QStringLiteral("ok"), status == UserResult::Success);
    QString message = userMessage(status);
    QString field;
    switch (status) {
    case UserResult::InvalidData:
        // UserManager returns InvalidData for an empty username or a half-filled address
        if (!Validation::isNonEmptyText(username)) {
            message = QStringLiteral("Please enter a username.");
            field = QStringLiteral("username");
        } else {
            message = QStringLiteral("Complete the address (city, street and building) or leave it empty.");
            field = QStringLiteral("address");
        }
        break;
    case UserResult::InvalidEmail:
    case UserResult::DuplicateEmail:
        field = QStringLiteral("email");
        break;
    case UserResult::InvalidPhone:
        field = QStringLiteral("phone");
        break;
    case UserResult::WeakPassword:
        field = QStringLiteral("password");
        break;
    case UserResult::DuplicateUsername:
        field = QStringLiteral("username");
        break;
    default:
        break;
    }
    result.insert(QStringLiteral("message"), message);
    result.insert(QStringLiteral("field"), field);

    // A new customer is signed in straight away
    if (status == UserResult::Success && m_authentication.login(username, password) == LoginResult::Success) {
        emit sessionChanged();
    }
    return result;
}

QVariantMap AppController::currentUserProfile() const
{
    QVariantMap result;
    const std::optional<User> user = m_authentication.currentUser();
    result.insert(QStringLiteral("ok"), user.has_value());
    if (!user) {
        return result;
    }
    result.insert(QStringLiteral("id"), user->getId());
    result.insert(QStringLiteral("username"), user->getUsername());
    result.insert(QStringLiteral("email"), user->getEmail());
    result.insert(QStringLiteral("phone"), user->getPhone());
    result.insert(QStringLiteral("address"), addressToMap(user->getAddress()));
    return result;
}

bool AppController::isValidField(const QString& kind, const QString& value) const
{
    // The same rules the backend uses (Validationfay)
    if (kind == QLatin1String("email")) {
        return Validation::isValidEmail(value.trimmed());
    }
    if (kind == QLatin1String("phone")) {
        return Validation::isValidPhone(value.trimmed());
    }
    if (kind == QLatin1String("password")) {
        return Validation::isValidPassword(value);
    }
    return Validation::isNonEmptyText(value);
}

bool AppController::isGuestCheckout() const
{
    return m_guestCheckout && !m_authentication.isLoggedIn();
}

void AppController::continueAsGuest()
{
    // Guest checkout: registration is optional; admins still cannot shop (go() sends them to the dashboard)
    if (!m_authentication.isLoggedIn()) {
        m_guestCheckout = true;
        emit sessionChanged();
    }
    go(QStringLiteral("checkout"));
}

void AppController::goToCheckout()
{
    // Checkout needs a customer or a guest: otherwise sign in first (or continue as guest), then come back
    if (m_authentication.isLoggedIn() || isGuestCheckout()) {
        go(QStringLiteral("checkout"));
    } else {
        QVariantMap params;
        params.insert(QStringLiteral("next"), QStringLiteral("checkout"));
        go(QStringLiteral("login"), params);
    }
}

QVariantMap AppController::checkAddress(const QVariantMap& address) const
{
    // Address::isValid() needs city, street and building number; each one is checked with Validation
    QStringList missing;
    if (!Validation::isNonEmptyText(address.value(QStringLiteral("city")).toString())) {
        missing.append(QStringLiteral("city"));
    }
    if (!Validation::isNonEmptyText(address.value(QStringLiteral("street")).toString())) {
        missing.append(QStringLiteral("street"));
    }
    if (!Validation::isNonEmptyText(address.value(QStringLiteral("building")).toString())) {
        missing.append(QStringLiteral("building"));
    }
    // Guest checkout: the phone (kept in the guest customer id) uses the backend rule (11 digits, starts with 01)
    const bool guestPhoneOk = !isGuestCheckout()
                              || Validation::isValidPhone(address.value(QStringLiteral("phone")).toString().trimmed());
    if (!guestPhoneOk) {
        missing.append(QStringLiteral("phone"));
    }
    QVariantMap result;
    result.insert(QStringLiteral("ok"), addressFrom(address).isValid() && guestPhoneOk);
    result.insert(QStringLiteral("phoneMessage"), userMessage(UserResult::InvalidPhone));
    result.insert(QStringLiteral("missing"), missing);
    result.insert(QStringLiteral("message"), missing.isEmpty()
                                                 ? QString()
                                                 : QStringLiteral("Please fix %1 %2 before continuing.")
                                                       .arg(missing.size())
                                                       .arg(missing.size() == 1 ? QStringLiteral("field") : QStringLiteral("fields")));
    return result;
}

QVariantMap AppController::placeOrder(const QVariantMap& address, bool saveAddress,
                                      bool prescriptionConfirmed, bool acceptPriceChanges)
{
    QVariantMap result;
    const std::optional<User> user = m_authentication.currentUser();

    CheckoutRequest request;
    request.customerId = user ? user->getId() : QString();
    if (!user && isGuestCheckout()) {
        // Guest checkout: "GUEST-<phone>" (CheckoutManager does not look a guest up in the users)
        const QString phone = address.value(QStringLiteral("phone")).toString().trimmed();
        if (!Validation::isValidPhone(phone)) {
            result.insert(QStringLiteral("ok"), false);
            result.insert(QStringLiteral("status"), QStringLiteral("invalidPhone"));
            result.insert(QStringLiteral("message"), userMessage(UserResult::InvalidPhone));
            result.insert(QStringLiteral("orderId"), QString());
            result.insert(QStringLiteral("priceChanges"), QVariantList());
            return result;
        }
        request.customerId = QLatin1String(CheckoutManager::GUEST_CUSTOMER_PREFIX) + QLatin1Char('-') + phone;
    }
    request.deliveryAddress = addressFrom(address);
    request.promoCode = m_promoCode;
    request.prescriptionConfirmed = prescriptionConfirmed;
    request.acceptPriceChanges = acceptPriceChanges;

    const CheckoutResult checkout = m_checkoutManager.placeOrder(request);
    const QString failedName = productName(checkout.failedProductId);

    QString status;
    QString message;
    switch (checkout.status) {
    case CheckoutStatus::Success:
        status = QStringLiteral("success");
        message = QStringLiteral("Your order has been placed.");
        break;
    case CheckoutStatus::EmptyCart:
        status = QStringLiteral("emptyCart");
        message = QStringLiteral("Your bag is empty.");
        break;
    case CheckoutStatus::CustomerNotFound:
        status = QStringLiteral("customerNotFound");
        message = QStringLiteral("Please sign in again to place your order.");
        break;
    case CheckoutStatus::InvalidAddress:
        status = QStringLiteral("invalidAddress");
        message = QStringLiteral("Please enter the city, street and building number.");
        break;
    case CheckoutStatus::ProductNotFound:
        status = QStringLiteral("productNotFound");
        message = failedName.isEmpty() ? QStringLiteral("A product in your bag is no longer available. Please remove it.")
                                       : failedName + QStringLiteral(" is no longer available. Please remove it from your bag.");
        break;
    case CheckoutStatus::OutOfStock:
        status = QStringLiteral("outOfStock");
        message = QStringLiteral("There is not enough stock of ") + failedName + QStringLiteral(". Please change the quantity.");
        break;
    case CheckoutStatus::PriceChanged:
        status = QStringLiteral("priceChanged");
        message = QStringLiteral("Some prices changed since you added them to your bag.");
        break;
    case CheckoutStatus::InvalidPromoCode:
        status = QStringLiteral("invalidPromoCode");
        message = QStringLiteral("The promo code is no longer valid. Remove it to continue.");
        break;
    case CheckoutStatus::StorageError:
        status = QStringLiteral("storageError");
        message = QStringLiteral("We could not save your order. Please try again.");
        break;
    case CheckoutStatus::AlreadyInProgress:
        status = QStringLiteral("alreadyInProgress");
        message = QStringLiteral("Your order is already being placed. Please wait.");
        break;
    case CheckoutStatus::PrescriptionRequired:
        status = QStringLiteral("prescriptionRequired");
        message = failedName + QStringLiteral(" needs a prescription. Please confirm that you have a valid prescription.");
        break;
    }

    QVariantList changes;
    for (const PriceChange& change : checkout.priceChanges) {
        QVariantMap row;
        row.insert(QStringLiteral("name"), change.productName);
        row.insert(QStringLiteral("oldText"), formatEgp(change.oldPriceMinor));
        row.insert(QStringLiteral("newText"), formatEgp(change.newPriceMinor));
        changes.append(row);
    }

    result.insert(QStringLiteral("ok"), checkout.status == CheckoutStatus::Success);
    result.insert(QStringLiteral("status"), status);
    result.insert(QStringLiteral("message"), message);
    result.insert(QStringLiteral("orderId"), checkout.orderId);
    result.insert(QStringLiteral("failedProductId"), checkout.failedProductId);
    result.insert(QStringLiteral("failedProductName"), failedName);
    result.insert(QStringLiteral("priceChanges"), changes);

    if (checkout.status == CheckoutStatus::Success) {
        // "Save this address for future orders" -> UserManager::updateProfile with the same details
        if (saveAddress && user) {
            m_userManager.updateProfile(user->getId(), user->getUsername(), user->getEmail(),
                                        user->getPhone(), request.deliveryAddress);
        }
        m_promoCode.clear();
        if (!user) {
            // Guest checkout: only this order can be shown to the guest (confirmation page); no My orders
            m_lastGuestOrderId = checkout.orderId;
            m_guestCheckout = false;
            emit sessionChanged();
        }
        emit cartChanged();
        emit dataChanged();   // stock went down, a new order exists
    }
    return result;
}

QVariantMap AppController::order(const QString& orderId) const
{
    QVariantMap result;
    std::optional<Order> found = m_orderManager.getOrderById(orderId);
    if (found && !ownsOrder(*found)) {
        found.reset();   // customers only see their own orders
    }
    result.insert(QStringLiteral("ok"), found.has_value());
    if (!found) {
        result.insert(QStringLiteral("message"), QStringLiteral("This order could not be found."));
        return result;
    }
    QVariantList rows;
    int units = 0;
    const QList<CartItem> items = found->getItems();
    for (const CartItem& item : items) {
        const Product product = item.getProduct();
        QVariantMap row;
        row.insert(QStringLiteral("id"), item.getProductId());
        row.insert(QStringLiteral("name"), product.getName());
        row.insert(QStringLiteral("brand"), brandOf(product));
        row.insert(QStringLiteral("image"), productImageUrl(product));
        row.insert(QStringLiteral("quantity"), item.getQuantity());
        row.insert(QStringLiteral("unitPriceText"), formatEgp(item.getUnitPriceMinor()));
        row.insert(QStringLiteral("lineTotalText"), formatEgp(item.getSubtotalMinor()));
        rows.append(row);
        units += item.getQuantity();
    }
    const QString status = found->getStatus();
    result.insert(QStringLiteral("orderId"), found->getOrderId());
    result.insert(QStringLiteral("customerId"), found->getCustomerId());
    result.insert(QStringLiteral("status"), status);
    result.insert(QStringLiteral("statusLabel"), statusLabel(status));
    result.insert(QStringLiteral("statusIndex"), Order::supportedStatuses().indexOf(status));
    result.insert(QStringLiteral("createdText"),
                  QLocale(QLocale::English).toString(found->getCreatedAt(), QStringLiteral("ddd, d MMM yyyy, HH:mm")));
    result.insert(QStringLiteral("items"), rows);
    result.insert(QStringLiteral("count"), units);
    result.insert(QStringLiteral("promoCode"), found->getPromoCode());
    result.insert(QStringLiteral("hasDiscount"), found->getDiscountMinor() > 0);
    result.insert(QStringLiteral("subtotalText"), formatEgp(found->getTotalPriceMinor()));
    result.insert(QStringLiteral("discountText"), formatEgp(-found->getDiscountMinor()));
    result.insert(QStringLiteral("totalText"), formatEgp(found->getFinalPriceMinor()));
    result.insert(QStringLiteral("address"), addressToMap(found->getDeliveryAddress()));
    const QVariantMap summary = orderSummaryMap(*found);
    result.insert(QStringLiteral("canCancel"), summary.value(QStringLiteral("canCancel")));
    result.insert(QStringLiteral("nextStatuses"), summary.value(QStringLiteral("nextStatuses")));
    result.insert(QStringLiteral("customerName"), summary.value(QStringLiteral("customerName")));
    result.insert(QStringLiteral("isGuest"), summary.value(QStringLiteral("isGuest")));
    result.insert(QStringLiteral("guestPhone"), summary.value(QStringLiteral("guestPhone")));
    result.insert(QStringLiteral("dateShortText"),
                  QLocale(QLocale::English).toString(found->getCreatedAt(), QStringLiteral("d MMM, HH:mm")));
    return result;
}

QString AppController::iconSource(const QString& name, const QColor& color)
{
    const QString colorName = color.name(QColor::HexRgb);
    const QString key = name + QLatin1Char('|') + colorName;
    if (m_iconCache.contains(key)) {
        return m_iconCache.value(key);
    }

    QFile file(QLatin1String(kResourceRoot) + QStringLiteral("icons/") + name + QStringLiteral(".svg"));
    if (!file.open(QIODevice::ReadOnly)) {
        return QString();
    }
    QByteArray svg = file.readAll();
    svg.replace(QByteArray(kIconColor), colorName.toLatin1());

    const QString url = QStringLiteral("data:image/svg+xml;base64,") + QString::fromLatin1(svg.toBase64());
    m_iconCache.insert(key, url);
    return url;
}

QVariantMap AppController::productToMap(const Product& product) const
{
    QVariantMap map;
    map.insert(QStringLiteral("id"), product.getId());
    map.insert(QStringLiteral("name"), product.getName());
    map.insert(QStringLiteral("code"), product.getCode());
    map.insert(QStringLiteral("category"), product.getCategory());
    map.insert(QStringLiteral("brand"), brandOf(product));
    map.insert(QStringLiteral("description"), descriptionOf(product));
    map.insert(QStringLiteral("priceText"), formatEgp(product.getPriceMinor()));
    map.insert(QStringLiteral("stock"), product.getStockQuantity());
    map.insert(QStringLiteral("inStock"), product.isAvailable());
    map.insert(QStringLiteral("expired"), product.isExpired());
    map.insert(QStringLiteral("lowStock"),
               product.isAvailable() && product.getStockQuantity() <= kLowStockThreshold);
    map.insert(QStringLiteral("requiresPrescription"), product.getRequiresPrescription());
    map.insert(QStringLiteral("expiryText"),
               product.hasExpiryDate()
                   ? QLocale(QLocale::English).toString(product.getExpiryDate(), QStringLiteral("d MMM yyyy"))
                   : QString());
    map.insert(QStringLiteral("image"), productImageUrl(product));
    return map;
}

QVariantList AppController::productList(const QList<Product>& list) const
{
    QVariantList result;
    for (const Product& product : list) {
        result.append(productToMap(product));
    }
    return result;
}

QString AppController::brandOf(const Product& product)
{
    // The seed data writes the brand before " - " in the description ("Medix - Fast relief ...")
    const QString description = product.getDescription();
    const int dash = description.indexOf(QStringLiteral(" - "));
    if (dash <= 0) {
        return QString();
    }
    return description.left(dash).trimmed();
}

QString AppController::descriptionOf(const Product& product)
{
    const QString description = product.getDescription();
    const int dash = description.indexOf(QStringLiteral(" - "));
    if (dash <= 0) {
        return description.trimmed();
    }
    return description.mid(dash + 3).trimmed();
}

QString AppController::imageUrlFor(const QString& imagePath)
{
    // imagePath looks like "images/P001.png"; a missing file gives "" and QML shows the placeholder
    const QString clean = imagePath.trimmed();
    if (clean.isEmpty() || !QFile::exists(QLatin1String(kResourceRoot) + clean)) {
        return QString();
    }
    return QLatin1String(kResourceUrl) + clean;
}

QString AppController::uploadedImagePath(const QString& productId) const
{
    // Only plain ids ("P004") become file names
    if (!Validation::isValidId(productId) || productId.contains(QLatin1Char('/')) || productId.contains(QLatin1Char('\\'))
        || productId.contains(QLatin1String(".."))) {
        return QString();
    }
    return m_dataDir + QStringLiteral("/images/") + productId + QStringLiteral(".png");
}

QString AppController::productImageUrl(const Product& product) const
{
    // 1. an image uploaded by the admin; the file time is added so a replaced image is not taken from QML's cache
    const QString uploaded = uploadedImagePath(product.getId());
    if (!uploaded.isEmpty()) {
        const QFileInfo info(uploaded);
        if (info.exists()) {
            QUrl url = QUrl::fromLocalFile(info.absoluteFilePath());
            url.setQuery(QStringLiteral("v=") + QString::number(info.lastModified().toMSecsSinceEpoch()));
            return url.toString();
        }
    }
    // 2. the image bundled with the app, 3. "" = the design placeholder
    return imageUrlFor(product.getImagePath());
}

QString AppController::productName(const QString& productId) const
{
    if (productId.isEmpty()) {
        return QString();
    }
    const std::optional<Product> found = m_medicineManager.findMedicineById(productId);
    return found ? found->getName() : productId;
}

Address AppController::addressFrom(const QVariantMap& map)
{
    return Address(map.value(QStringLiteral("city")).toString().trimmed(),
                   map.value(QStringLiteral("street")).toString().trimmed(),
                   map.value(QStringLiteral("building")).toString().trimmed(),
                   map.value(QStringLiteral("apartment")).toString().trimmed(),
                   map.value(QStringLiteral("postalCode")).toString().trimmed());
}

QVariantMap AppController::addressToMap(const Address& address)
{
    QVariantMap map;
    map.insert(QStringLiteral("city"), address.getCity());
    map.insert(QStringLiteral("street"), address.getStreet());
    map.insert(QStringLiteral("building"), address.getBuildingNumber());
    map.insert(QStringLiteral("apartment"), address.getApartmentNumber());
    map.insert(QStringLiteral("postalCode"), address.getPostalCode());
    map.insert(QStringLiteral("valid"), address.isValid());

    // Two display lines: "Building 4, Apt 12, Street" and "City, postal code"
    QStringList first;
    if (!address.getBuildingNumber().isEmpty()) {
        first.append(QStringLiteral("Building ") + address.getBuildingNumber());
    }
    if (!address.getApartmentNumber().isEmpty()) {
        first.append(QStringLiteral("Apt ") + address.getApartmentNumber());
    }
    if (!address.getStreet().isEmpty()) {
        first.append(address.getStreet());
    }
    QStringList second;
    if (!address.getCity().isEmpty()) {
        second.append(address.getCity());
    }
    if (!address.getPostalCode().isEmpty()) {
        second.append(address.getPostalCode());
    }
    map.insert(QStringLiteral("line1"), first.join(QStringLiteral(", ")));
    map.insert(QStringLiteral("line2"), second.join(QStringLiteral(", ")));
    return map;
}

QString AppController::statusLabel(const QString& status)
{
    if (status.isEmpty()) {
        return QString();
    }
    return status.at(0).toUpper() + status.mid(1);
}

QString AppController::promoMessage(PromoResult result, int percentage)
{
    switch (result) {
    case PromoResult::Success:
        return QStringLiteral("Code applied ") + QChar(0x2014) + QStringLiteral(" you saved %1% on this order").arg(percentage);
    case PromoResult::InvalidCode:
        return QStringLiteral("Please enter a promo code.");
    case PromoResult::NotFound:
        return QStringLiteral("This promo code does not exist. Check the code and try again.");
    case PromoResult::Inactive:
        return QStringLiteral("This promo code is no longer active.");
    case PromoResult::Expired:
        return QStringLiteral("This promo code has expired.");
    case PromoResult::InvalidSubtotal:
        return QStringLiteral("Add products to your bag before using a promo code.");
    case PromoResult::NotApplicable:
        return QStringLiteral("This promo code cannot be used on this order.");
    }
    return QStringLiteral("This promo code cannot be used.");
}

QString AppController::userMessage(UserResult result)
{
    switch (result) {
    case UserResult::Success:
        return QStringLiteral("Your account has been created.");
    case UserResult::InvalidData:
        return QStringLiteral("Please check the form.");
    case UserResult::InvalidEmail:
        return QStringLiteral("Please enter a valid email address.");
    case UserResult::InvalidPhone:
        return QStringLiteral("Phone number must be 11 digits and start with 01.");
    case UserResult::WeakPassword:
        return QStringLiteral("Password must be at least 8 characters.");
    case UserResult::DuplicateEmail:
        return QStringLiteral("An account with this email already exists.");
    case UserResult::DuplicateUsername:
        return QStringLiteral("This username is already taken.");
    case UserResult::WrongPassword:
        return QStringLiteral("The current password is not correct.");
    case UserResult::NotFound:
        return QStringLiteral("This account could not be found.");
    case UserResult::StorageError:
        return QStringLiteral("We could not save your details. Please try again.");
    }
    return QStringLiteral("Something went wrong. Please try again.");
}

QString AppController::cartMessage(CartResult result)
{
    switch (result) {
    case CartResult::Success:
        return QStringLiteral("Added to your bag");
    case CartResult::InvalidQuantity:
        return QStringLiteral("Please choose a quantity of at least 1.");
    case CartResult::ProductNotFound:
        return QStringLiteral("This product is no longer available.");
    case CartResult::ItemNotInCart:
        return QStringLiteral("This item is not in your bag.");
    case CartResult::InsufficientStock:
        return QStringLiteral("There is not enough stock for this quantity.");
    }
    return QStringLiteral("Something went wrong. Please try again.");
}

// ===================== My account =====================

QString AppController::userField(UserResult result)
{
    switch (result) {
    case UserResult::InvalidEmail:
    case UserResult::DuplicateEmail:
        return QStringLiteral("email");
    case UserResult::InvalidPhone:
        return QStringLiteral("phone");
    case UserResult::WeakPassword:
        return QStringLiteral("newPassword");
    case UserResult::WrongPassword:
        return QStringLiteral("currentPassword");
    case UserResult::DuplicateUsername:
        return QStringLiteral("username");
    default:
        return QString();
    }
}

QVariantMap AppController::updateProfile(const QVariantMap& form)
{
    QVariantMap result;
    const std::optional<User> user = m_authentication.currentUser();
    if (!user) {
        result.insert(QStringLiteral("ok"), false);
        result.insert(QStringLiteral("message"), QStringLiteral("Please sign in again."));
        result.insert(QStringLiteral("field"), QString());
        return result;
    }
    const QString username = form.value(QStringLiteral("username")).toString().trimmed();
    const QString email = form.value(QStringLiteral("email")).toString().trimmed();
    const QString phone = form.value(QStringLiteral("phone")).toString().trimmed();
    const UserResult status = m_userManager.updateProfile(user->getId(), username, email, phone, addressFrom(form));

    QString message = status == UserResult::Success ? QStringLiteral("Your details have been saved.") : userMessage(status);
    QString field = userField(status);
    if (status == UserResult::InvalidData) {
        // UserManager returns InvalidData for an empty username or a half-filled address
        if (!Validation::isNonEmptyText(username)) {
            message = QStringLiteral("Please enter a username.");
            field = QStringLiteral("username");
        } else {
            message = QStringLiteral("Complete the address (city, street and building) or leave it empty.");
            field = QStringLiteral("address");
        }
    }
    result.insert(QStringLiteral("ok"), status == UserResult::Success);
    result.insert(QStringLiteral("message"), message);
    result.insert(QStringLiteral("field"), field);
    if (status == UserResult::Success) {
        emit sessionChanged();   // the header shows the (new) username
    }
    return result;
}

QVariantMap AppController::changePassword(const QString& currentPassword, const QString& newPassword,
                                          const QString& confirmPassword)
{
    QVariantMap result;
    const std::optional<User> user = m_authentication.currentUser();
    QString message;
    QString field;
    bool ok = false;
    if (!user) {
        message = QStringLiteral("Please sign in again.");
    } else if (currentPassword.isEmpty()) {
        message = QStringLiteral("Please enter your current password.");
        field = QStringLiteral("currentPassword");
    } else if (newPassword != confirmPassword) {
        // Checked here so the backend only receives a password the customer typed twice
        message = QStringLiteral("The new passwords do not match.");
        field = QStringLiteral("confirmPassword");
    } else {
        const UserResult status = m_userManager.changePassword(user->getId(), currentPassword, newPassword);
        ok = status == UserResult::Success;
        message = ok ? QStringLiteral("Your password has been changed.") : userMessage(status);
        field = userField(status);
    }
    result.insert(QStringLiteral("ok"), ok);
    result.insert(QStringLiteral("message"), message);
    result.insert(QStringLiteral("field"), field);
    return result;
}

bool AppController::ownsOrder(const Order& order) const
{
    const std::optional<User> user = m_authentication.currentUser();
    if (!user) {
        // Guest checkout: a guest sees only the order just placed in this session
        return !m_lastGuestOrderId.isEmpty() && order.getOrderId() == m_lastGuestOrderId;
    }
    return user->isAdmin() || order.getCustomerId() == user->getId();
}

QVariantMap AppController::orderSummaryMap(const Order& order) const
{
    int units = 0;
    QVariantList images;
    const QList<CartItem> items = order.getItems();
    for (const CartItem& item : items) {
        units += item.getQuantity();
        if (images.size() < 3) {
            images.append(productImageUrl(item.getProduct()));
        }
    }
    const QString status = order.getStatus();
    QString customerName = order.getCustomerId();
    const QString guestPrefix = QLatin1String(CheckoutManager::GUEST_CUSTOMER_PREFIX) + QLatin1Char('-');
    const bool guest = order.getCustomerId().startsWith(QLatin1String(CheckoutManager::GUEST_CUSTOMER_PREFIX));
    const std::optional<User> customer = guest ? std::nullopt : m_userManager.getUserById(order.getCustomerId());
    if (customer) {
        customerName = customer->getUsername();
    } else if (guest) {
        customerName = QStringLiteral("Guest · ") + order.getCustomerId().mid(guestPrefix.size());
    }
    QVariantList next;
    const QStringList nextStatuses = Order::nextStatusesFor(status);
    for (const QString& value : nextStatuses) {
        QVariantMap option;
        option.insert(QStringLiteral("value"), value);
        option.insert(QStringLiteral("label"), statusLabel(value));
        next.append(option);
    }

    QVariantMap map;
    map.insert(QStringLiteral("orderId"), order.getOrderId());
    map.insert(QStringLiteral("customerId"), order.getCustomerId());
    map.insert(QStringLiteral("customerName"), customerName);
    map.insert(QStringLiteral("isGuest"), guest);
    map.insert(QStringLiteral("guestPhone"), guest ? order.getCustomerId().mid(guestPrefix.size()) : QString());
    map.insert(QStringLiteral("status"), status);
    map.insert(QStringLiteral("statusLabel"), statusLabel(status));
    map.insert(QStringLiteral("createdText"),
               QLocale(QLocale::English).toString(order.getCreatedAt(), QStringLiteral("d MMM yyyy, HH:mm")));
    map.insert(QStringLiteral("count"), units);
    map.insert(QStringLiteral("lineCount"), items.size());
    map.insert(QStringLiteral("images"), images);
    map.insert(QStringLiteral("totalText"), formatEgp(order.getFinalPriceMinor()));
    map.insert(QStringLiteral("canCancel"), Order::canTransition(status, QLatin1String(Order::STATUS_CANCELLED)));
    map.insert(QStringLiteral("nextStatuses"), next);
    return map;
}

QVariantList AppController::myOrders() const
{
    QVariantList result;
    const std::optional<User> user = m_authentication.currentUser();
    if (!user) {
        return result;
    }
    QList<Order> orders = m_orderManager.getOrdersByCustomer(user->getId());
    std::sort(orders.begin(), orders.end(), [](const Order& a, const Order& b) {
        return a.getCreatedAt() > b.getCreatedAt();
    });
    for (const Order& order : orders) {
        result.append(orderSummaryMap(order));
    }
    return result;
}

QVariantMap AppController::cancelMyOrder(const QString& orderId)
{
    QVariantMap result;
    const std::optional<Order> order = m_orderManager.getOrderById(orderId);
    if (!order || !ownsOrder(*order)) {
        result.insert(QStringLiteral("ok"), false);
        result.insert(QStringLiteral("message"), QStringLiteral("This order could not be found."));
        return result;
    }
    // OrderManager::cancelOrder decides: only pending, confirmed or processing orders, and it returns the stock
    const OrderResult status = m_orderManager.cancelOrder(orderId);
    result.insert(QStringLiteral("ok"), status == OrderResult::Success);
    result.insert(QStringLiteral("message"), status == OrderResult::Success
                                                 ? QStringLiteral("Order #") + orderId + QStringLiteral(" has been cancelled.")
                                                 : orderMessage(status));
    if (status == OrderResult::Success) {
        emit dataChanged();
    }
    return result;
}

QString AppController::orderMessage(OrderResult result)
{
    switch (result) {
    case OrderResult::Success:
        return QStringLiteral("The order has been updated.");
    case OrderResult::InvalidOrder:
        return QStringLiteral("This order is not valid.");
    case OrderResult::DuplicateOrder:
        return QStringLiteral("This order already exists.");
    case OrderResult::NotFound:
        return QStringLiteral("This order could not be found.");
    case OrderResult::InvalidTransition:
        return QStringLiteral("This order can no longer be changed to that status.");
    case OrderResult::StorageError:
        return QStringLiteral("We could not save the order. Please try again.");
    }
    return QStringLiteral("Something went wrong. Please try again.");
}

// ===================== Admin area =====================

QString AppController::adminMessage(AdminResult result)
{
    switch (result) {
    case AdminResult::Success:
        return QStringLiteral("Saved.");
    case AdminResult::NotAuthorized:
        return QStringLiteral("Only an admin can do this. Please sign in as an admin.");
    case AdminResult::InvalidData:
        return QStringLiteral("Please check the product details (name, a price above 0, stock 0 or more, a date that has not passed).");
    case AdminResult::InvalidCategory:
        return QStringLiteral("Please choose one of the four categories.");
    case AdminResult::DuplicateId:
        return QStringLiteral("A product with this id already exists.");
    case AdminResult::DuplicateCode:
        return QStringLiteral("Another product already uses this code.");
    case AdminResult::NotFound:
        return QStringLiteral("This product could not be found.");
    case AdminResult::StorageError:
        return QStringLiteral("We could not save the change. Please try again.");
    }
    return QStringLiteral("Something went wrong. Please try again.");
}

QString AppController::stockMessage(StockResult result)
{
    switch (result) {
    case StockResult::Success:
        return QStringLiteral("Stock updated.");
    case StockResult::InvalidQuantity:
        return QStringLiteral("Please enter a whole number of at least 1.");
    case StockResult::ProductNotFound:
        return QStringLiteral("This product could not be found.");
    case StockResult::InsufficientStock:
        return QStringLiteral("There is not enough stock.");
    case StockResult::Expired:
        return QStringLiteral("This product has expired.");
    case StockResult::StorageError:
        return QStringLiteral("We could not save the stock. Please try again.");
    }
    return QStringLiteral("Something went wrong. Please try again.");
}

bool AppController::parseMoney(const QString& text, qint64* amountMinor)
{
    // "325", "325.5", "1,900.00" -> piastres, without going through double
    QString value = text.trimmed();
    value.remove(QLatin1Char(','));
    if (value.endsWith(QStringLiteral("EGP"), Qt::CaseInsensitive)) {
        value.chop(3);
        value = value.trimmed();
    }
    if (value.isEmpty()) {
        return false;
    }
    const int dot = value.indexOf(QLatin1Char('.'));
    const QString whole = dot == -1 ? value : value.left(dot);
    QString fraction = dot == -1 ? QString() : value.mid(dot + 1);
    if (whole.isEmpty() || fraction.size() > 2) {
        return false;
    }
    for (const QChar ch : whole + fraction) {
        if (!ch.isDigit()) {
            return false;
        }
    }
    if (whole.size() > 12) {
        return false;
    }
    while (fraction.size() < 2) {
        fraction.append(QLatin1Char('0'));
    }
    *amountMinor = whole.toLongLong() * 100 + fraction.toLongLong();
    return true;
}

QVariantMap AppController::checkImageFile(const QUrl& file) const
{
    QVariantMap result;
    const QString path = file.isLocalFile() ? file.toLocalFile() : file.toString();
    const QString suffix = QFileInfo(path).suffix().toLower();
    QString message;
    if (suffix != QLatin1String("png") && suffix != QLatin1String("jpg") && suffix != QLatin1String("jpeg")) {
        message = QStringLiteral("Choose a PNG or JPG image.");
    } else {
        QImageReader reader(path);
        if (!reader.canRead()) {
            message = QStringLiteral("This image cannot be read. Choose another PNG or JPG file.");
        }
    }
    result.insert(QStringLiteral("ok"), message.isEmpty());
    result.insert(QStringLiteral("message"), message);
    result.insert(QStringLiteral("url"), message.isEmpty() ? QUrl::fromLocalFile(path).toString() : QString());
    return result;
}

QStringList AppController::productCategories() const
{
    return CategoryManager::getAllCategories();
}

QVariantMap AppController::adminProductRow(const Product& product) const
{
    QVariantMap row = productToMap(product);
    row.insert(QStringLiteral("expiryIso"),
               product.hasExpiryDate() ? product.getExpiryDate().toString(Qt::ISODate) : QString());
    return row;
}

QVariantMap AppController::adminSummary(int lowStockThreshold) const
{
    QVariantMap result;
    result.insert(QStringLiteral("ok"), isAdmin());
    if (!isAdmin()) {
        return result;
    }
    QList<Order> orders;
    m_adminManager.getAllOrders(orders);
    qint64 revenue = 0;
    int open = 0;
    int pending = 0;
    for (const Order& order : orders) {
        const QString status = order.getStatus();
        if (status != QLatin1String(Order::STATUS_CANCELLED)) {
            revenue += order.getFinalPriceMinor();
        }
        if (status == QLatin1String(Order::STATUS_PENDING)) {
            ++pending;
        }
        if (!Order::nextStatusesFor(status).isEmpty()) {
            ++open;
        }
    }
    int customers = 0;
    const QList<User> users = m_userRepository.getAllUsers();
    for (const User& user : users) {
        if (!user.isAdmin()) {
            ++customers;
        }
    }
    std::sort(orders.begin(), orders.end(), [](const Order& a, const Order& b) {
        return a.getCreatedAt() > b.getCreatedAt();
    });
    QVariantList recent;
    for (int i = 0; i < orders.size() && i < 5; ++i) {
        recent.append(orderSummaryMap(orders.at(i)));
    }
    result.insert(QStringLiteral("productCount"), m_productRepository.getAllProducts().size());
    result.insert(QStringLiteral("orderCount"), orders.size());
    result.insert(QStringLiteral("openOrders"), open);
    result.insert(QStringLiteral("pendingOrders"), pending);
    result.insert(QStringLiteral("customerCount"), customers);
    result.insert(QStringLiteral("revenueText"), formatEgp(revenue));
    result.insert(QStringLiteral("lowStockCount"), m_inventoryManager.getLowStockProducts(lowStockThreshold).size());
    result.insert(QStringLiteral("expiredCount"), m_inventoryManager.getExpiredProducts().size());
    result.insert(QStringLiteral("recentOrders"), recent);
    return result;
}

QVariantList AppController::adminProducts(const QString& search) const
{
    QVariantList result;
    if (!isAdmin()) {
        return result;
    }
    const QString term = search.trimmed();
    const QList<Product> list = term.isEmpty() ? m_medicineManager.getAllMedicines()
                                               : m_medicineManager.searchMedicines(term);
    for (const Product& product : list) {
        result.append(adminProductRow(product));
    }
    return result;
}

QString AppController::nextProductId() const
{
    // The backend has no id generator for products. New id = (highest numeric P-id ever seen) + 1, never the
    // product count, and the highest id is taken from the current products, from every order line (orders keep
    // the product id) and from the ids issued in this session, so a removed product's id is never handed out again.
    auto numberOf = [](const QString& id) {
        if (!id.startsWith(QLatin1Char('P'))) {
            return 0;
        }
        bool ok = false;
        const int number = id.mid(1).toInt(&ok);
        return ok ? number : 0;
    };
    int biggest = m_highestIssuedProductNumber;
    const QList<Product> products = m_productRepository.getAllProducts();
    for (const Product& product : products) {
        biggest = std::max(biggest, numberOf(product.getId()));
    }
    const QList<Order> orders = m_orderManager.getAllOrders();
    for (const Order& order : orders) {
        const QList<CartItem> items = order.getItems();
        for (const CartItem& item : items) {
            biggest = std::max(biggest, numberOf(item.getProductId()));
        }
    }
    return QStringLiteral("P%1").arg(biggest + 1, 3, 10, QLatin1Char('0'));
}

QVariantMap AppController::adminProductForm(const QString& productId) const
{
    QVariantMap form;
    const std::optional<Product> product = productId.isEmpty() ? std::nullopt
                                                               : m_medicineManager.findMedicineById(productId);
    form.insert(QStringLiteral("ok"), productId.isEmpty() || product.has_value());
    form.insert(QStringLiteral("isNew"), !product.has_value());
    if (!product) {
        form.insert(QStringLiteral("id"), nextProductId());
        form.insert(QStringLiteral("name"), QString());
        form.insert(QStringLiteral("code"), QString());
        form.insert(QStringLiteral("category"), QString());
        form.insert(QStringLiteral("brand"), QString());
        form.insert(QStringLiteral("description"), QString());
        form.insert(QStringLiteral("price"), QString());
        form.insert(QStringLiteral("stock"), QStringLiteral("0"));
        form.insert(QStringLiteral("expiry"), QString());
        form.insert(QStringLiteral("requiresPrescription"), false);
        form.insert(QStringLiteral("image"), QString());
        return form;
    }
    form.insert(QStringLiteral("image"), productImageUrl(*product));
    const qint64 price = product->getPriceMinor();
    form.insert(QStringLiteral("id"), product->getId());
    form.insert(QStringLiteral("name"), product->getName());
    form.insert(QStringLiteral("code"), product->getCode());
    form.insert(QStringLiteral("category"), product->getCategory());
    form.insert(QStringLiteral("brand"), brandOf(*product));
    form.insert(QStringLiteral("description"), descriptionOf(*product));
    form.insert(QStringLiteral("price"), QStringLiteral("%1.%2").arg(price / 100).arg(price % 100, 2, 10, QLatin1Char('0')));
    form.insert(QStringLiteral("stock"), QString::number(product->getStockQuantity()));
    form.insert(QStringLiteral("expiry"), product->hasExpiryDate() ? product->getExpiryDate().toString(Qt::ISODate) : QString());
    form.insert(QStringLiteral("requiresPrescription"), product->getRequiresPrescription());
    return form;
}

QVariantMap AppController::saveProduct(const QVariantMap& form)
{
    QVariantMap result;
    auto fail = [&result](const QString& message, const QString& field) {
        result.insert(QStringLiteral("ok"), false);
        result.insert(QStringLiteral("message"), message);
        result.insert(QStringLiteral("field"), field);
        return result;
    };
    if (!isAdmin()) {
        return fail(adminMessage(AdminResult::NotAuthorized), QString());
    }
    const bool isNew = form.value(QStringLiteral("isNew")).toBool();
    const QString id = form.value(QStringLiteral("id")).toString().trimmed();
    const QString name = form.value(QStringLiteral("name")).toString().trimmed();
    const QString code = form.value(QStringLiteral("code")).toString().trimmed();
    const QString category = form.value(QStringLiteral("category")).toString();
    const QString brand = form.value(QStringLiteral("brand")).toString().trimmed();
    const QString description = form.value(QStringLiteral("description")).toString().trimmed();
    const QString expiryText = form.value(QStringLiteral("expiry")).toString().trimmed();

    // Form checks that need parsing (the rest is decided by AdminManager / MedicineManager)
    if (!Validation::isNonEmptyText(name)) {
        return fail(QStringLiteral("Please enter the product name."), QStringLiteral("name"));
    }
    qint64 priceMinor = 0;
    if (!parseMoney(form.value(QStringLiteral("price")).toString(), &priceMinor) || !Validation::isPositivePrice(priceMinor)) {
        return fail(QStringLiteral("Enter a price above 0, like 325 or 325.50."), QStringLiteral("price"));
    }
    bool stockOk = false;
    const int stock = form.value(QStringLiteral("stock")).toString().trimmed().toInt(&stockOk);
    if (!stockOk || stock < 0) {
        return fail(QStringLiteral("Stock must be a whole number, 0 or more."), QStringLiteral("stock"));
    }
    QDate expiry;
    if (!expiryText.isEmpty()) {
        // The Date field sends "YYYY-MM-DD"; an empty field is allowed (the expiry date is optional)
        const QStringList parts = expiryText.split(QLatin1Char('-'));
        bool digitsOnly = parts.size() == 3 && parts.at(0).size() == 4 && parts.at(1).size() == 2 && parts.at(2).size() == 2;
        for (const QString& part : parts) {
            for (const QChar ch : part) {
                digitsOnly = digitsOnly && ch.isDigit();
            }
        }
        if (!digitsOnly) {
            return fail(QStringLiteral("Enter the full date: 8 digits, like 20271231."), QStringLiteral("expiry"));
        }
        expiry = QDate(parts.at(0).toInt(), parts.at(1).toInt(), parts.at(2).toInt());
        if (!expiry.isValid()) {
            // Month 1-12 and a day that exists in that month (2027-02-30 is rejected)
            return fail(QStringLiteral("This date doesn't exist."), QStringLiteral("expiry"));
        }
    }
    if (!CategoryManager::isValidCategory(category)) {
        return fail(adminMessage(AdminResult::InvalidCategory), QStringLiteral("category"));
    }

    // Keep the seed format "Brand - description" so the shop can show the brand
    const QString fullDescription = brand.isEmpty() ? description : brand + QStringLiteral(" - ") + description;
    QString imagePath;
    if (!isNew) {
        const std::optional<Product> existing = m_medicineManager.findMedicineById(id);
        if (existing) {
            imagePath = existing->getImagePath();
        }
    }
    // Product image (optional): read it now, write it only after the product is saved
    QImage uploadedImage;
    const QString imageFile = form.value(QStringLiteral("imageFile")).toString();
    if (!imageFile.isEmpty()) {
        const QVariantMap check = checkImageFile(QUrl(imageFile));
        if (!check.value(QStringLiteral("ok")).toBool()) {
            return fail(check.value(QStringLiteral("message")).toString(), QStringLiteral("image"));
        }
        const QUrl url(imageFile);
        uploadedImage = QImage(url.isLocalFile() ? url.toLocalFile() : imageFile);
        if (uploadedImage.isNull() || uploadedImagePath(id).isEmpty()) {
            return fail(QStringLiteral("This image cannot be read. Choose another PNG or JPG file."), QStringLiteral("image"));
        }
        // The existing imagePath field points at the uploaded file (the Product model is unchanged)
        imagePath = QStringLiteral("images/") + id + QStringLiteral(".png");
    }
    const Product product(id, name, code, CategoryManager::normalizeCategory(category), fullDescription,
                          priceMinor, stock, imagePath, expiry,
                          form.value(QStringLiteral("requiresPrescription")).toBool());
    const AdminResult status = isNew ? m_adminManager.addProduct(product) : m_adminManager.updateProduct(product);
    if (status != AdminResult::Success) {
        QString field;
        if (status == AdminResult::DuplicateCode) {
            field = QStringLiteral("code");
        } else if (status == AdminResult::InvalidCategory) {
            field = QStringLiteral("category");
        } else if (status == AdminResult::InvalidData && expiry.isValid() && expiry < QDate::currentDate()) {
            return fail(QStringLiteral("The expiry date has already passed."), QStringLiteral("expiry"));
        }
        return fail(adminMessage(status), field);
    }
    if (isNew && id.startsWith(QLatin1Char('P'))) {
        // Remember the id so it is not issued again in this session, even if the product is removed
        bool numeric = false;
        const int number = id.mid(1).toInt(&numeric);
        if (numeric) {
            m_highestIssuedProductNumber = std::max(m_highestIssuedProductNumber, number);
        }
    }
    QString imageNote;
    if (!uploadedImage.isNull()) {
        // Max 600 px on the long side (aspect ratio kept, smooth), saved as PNG in DATA_DIR/images/<id>.png
        const QString target = uploadedImagePath(id);
        QDir().mkpath(QFileInfo(target).absolutePath());
        const QImage scaled = qMax(uploadedImage.width(), uploadedImage.height()) > 600
                                  ? uploadedImage.scaled(600, 600, Qt::KeepAspectRatio, Qt::SmoothTransformation)
                                  : uploadedImage;
        if (!scaled.save(target, "PNG")) {
            imageNote = QStringLiteral(" The image could not be saved; try uploading it again.");
        }
    }
    result.insert(QStringLiteral("ok"), true);
    result.insert(QStringLiteral("message"), (isNew ? QStringLiteral("Product added: ") : QStringLiteral("Product saved: ")) + name + imageNote);
    result.insert(QStringLiteral("field"), QString());
    result.insert(QStringLiteral("id"), id);
    emit dataChanged();
    return result;
}

QVariantMap AppController::removeProduct(const QString& productId)
{
    QVariantMap result;
    const QString name = productName(productId);
    const AdminResult status = m_adminManager.removeProduct(productId);
    result.insert(QStringLiteral("ok"), status == AdminResult::Success);
    result.insert(QStringLiteral("message"), status == AdminResult::Success
                                                 ? QStringLiteral("Product removed: ") + name
                                                 : adminMessage(status));
    if (status == AdminResult::Success) {
        emit dataChanged();
    }
    return result;
}

QVariantList AppController::adminOrders(const QString& status) const
{
    QVariantList result;
    QList<Order> orders;
    if (m_adminManager.getAllOrders(orders) != AdminResult::Success) {
        return result;
    }
    std::sort(orders.begin(), orders.end(), [](const Order& a, const Order& b) {
        return a.getCreatedAt() > b.getCreatedAt();
    });
    for (const Order& order : orders) {
        if (status.isEmpty() || order.getStatus() == status) {
            result.append(orderSummaryMap(order));
        }
    }
    return result;
}

QVariantMap AppController::updateOrderStatus(const QString& orderId, const QString& newStatus)
{
    QVariantMap result;
    QString message;
    bool ok = false;
    Order order;
    if (!isAdmin()) {
        message = adminMessage(AdminResult::NotAuthorized);
    } else if (m_adminManager.getOrderById(orderId, order) != AdminResult::Success) {
        message = orderMessage(OrderResult::NotFound);
    } else if (!Order::canTransition(order.getStatus(), newStatus)) {
        // Only the transitions the Order model allows are offered and accepted
        message = orderMessage(OrderResult::InvalidTransition);
    } else {
        const OrderResult status = m_orderManager.updateOrderStatus(orderId, newStatus);
        ok = status == OrderResult::Success;
        message = ok ? QStringLiteral("Order #") + orderId + QStringLiteral(" is now ") + statusLabel(newStatus).toLower() + QLatin1Char('.')
                     : orderMessage(status);
    }
    result.insert(QStringLiteral("ok"), ok);
    result.insert(QStringLiteral("message"), message);
    if (ok) {
        emit dataChanged();
    }
    return result;
}

QVariantList AppController::lowStockProducts(int threshold) const
{
    QVariantList result;
    if (!isAdmin()) {
        return result;
    }
    QList<Product> list = m_inventoryManager.getLowStockProducts(threshold);
    std::sort(list.begin(), list.end(), [](const Product& a, const Product& b) {
        return a.getStockQuantity() < b.getStockQuantity();
    });
    for (const Product& product : list) {
        result.append(adminProductRow(product));
    }
    return result;
}

QVariantList AppController::expiredProducts() const
{
    QVariantList result;
    if (!isAdmin()) {
        return result;
    }
    const QList<Product> list = m_inventoryManager.getExpiredProducts();
    for (const Product& product : list) {
        result.append(adminProductRow(product));
    }
    return result;
}

QVariantMap AppController::increaseStock(const QString& productId, const QString& quantityText)
{
    QVariantMap result;
    if (!isAdmin()) {
        result.insert(QStringLiteral("ok"), false);
        result.insert(QStringLiteral("message"), adminMessage(AdminResult::NotAuthorized));
        return result;
    }
    bool parsed = false;
    const int quantity = quantityText.trimmed().toInt(&parsed);
    const StockResult status = parsed ? m_inventoryManager.increaseStock(productId, quantity) : StockResult::InvalidQuantity;
    result.insert(QStringLiteral("ok"), status == StockResult::Success);
    if (status == StockResult::Success) {
        const std::optional<int> stock = m_inventoryManager.getStock(productId);
        result.insert(QStringLiteral("message"), productName(productId) + QStringLiteral(": stock is now ")
                                                     + QString::number(stock.value_or(0)) + QLatin1Char('.'));
        emit dataChanged();
    } else {
        result.insert(QStringLiteral("message"), stockMessage(status));
    }
    return result;
}


}
