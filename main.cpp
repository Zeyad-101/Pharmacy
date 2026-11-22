// El file da mas2ool 3an tashgheel el program: y3mel load lel data, w ywasal kol el managers ba3d, w y3mel el admin awel mara.
// Owner: Abdelrahman
#include <QCoreApplication>
#include <QList>
#include <QString>
#include <QTextStream>

#include "Models/Address.h"
#include "Models/User.h"
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

using namespace pharmacy;

int main(int argc, char* argv[])
{
    QCoreApplication app(argc, argv);
    QTextStream out(stdout);
    QTextStream err(stderr);

    // The Data folder path comes from CMake (DATA_DIR)
    const QString dataDir = QStringLiteral(DATA_DIR);

    // One shared instance of every repository
    ProductRepository productRepository(dataDir + "/products.json");
    UserRepository userRepository(dataDir + "/users.json");
    OrderRepository orderRepository(dataDir + "/orders.json");
    PromoCodeRepository promoCodeRepository(dataDir + "/promo_codes.json");

    // Load every file, and stop if one of them is broken
    if (!productRepository.load()) {
        err << "Error: " << productRepository.lastError() << Qt::endl;
        return 1;
    }
    if (!userRepository.load()) {
        err << "Error: " << userRepository.lastError() << Qt::endl;
        return 1;
    }
    if (!orderRepository.load()) {
        err << "Error: " << orderRepository.lastError() << Qt::endl;
        return 1;
    }
    if (!promoCodeRepository.load()) {
        err << "Error: " << promoCodeRepository.lastError() << Qt::endl;
        return 1;
    }

    // Create the managers, all using the same repositories
    InventoryManager inventoryManager(productRepository);
    MedicineManager medicineManager(productRepository);
    Authentication authentication(userRepository);
    UserManager userManager(userRepository);
    AdminManager adminManager(authentication, medicineManager, orderRepository);
    CartManager cartManager(productRepository, inventoryManager);
    PromoCodeManager promoCodeManager(promoCodeRepository);
    OrderManager orderManager(orderRepository, inventoryManager);
    CheckoutManager checkoutManager(cartManager, promoCodeManager, inventoryManager,
                                    productRepository, userRepository, orderManager);

    // First run: create the admin account if there is no admin yet
    bool adminExists = false;
    const QList<User> allUsers = userRepository.getAllUsers();
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
        if (userRepository.saveUser(admin)) {
            out << "Admin account created (username: admin)" << Qt::endl;
        } else {
            err << "Error: could not create the admin account: " << userRepository.lastError() << Qt::endl;
            return 1;
        }
    }

    // Short startup summary (the GUI comes next)
    out << "SmartPharmacy backend is ready" << Qt::endl;
    out << "Data folder: " << dataDir << Qt::endl;
    out << "Products: " << productRepository.getAllProducts().size() << Qt::endl;
    out << "Users: " << userRepository.getAllUsers().size() << Qt::endl;
    out << "Promo codes: " << promoCodeRepository.getAllPromoCodes().size() << Qt::endl;
    out << "Orders: " << orderRepository.getAllOrders().size() << Qt::endl;

    return 0;
}
