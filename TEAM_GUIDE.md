# SmartPharmacy Team Guide

This guide explains how the project is organised, who owns which files, and how to build and share your work.

## 1. Folder structure

```
SmartPharmacy/
├── main.cpp              Application entry point (shared)
├── CMakeLists.txt        Build configuration (shared)
├── TEAM_GUIDE.md         This guide (shared)
├── Models/               Shared data classes used by everyone
├── Medicine/             Medicine and category management
├── Inventory/            Stock management
├── Shopping/             Cart, promo codes, checkout and orders
├── Accounts/             Users, login and admin tools
├── Repositories/         Loading and saving data to the JSON files
├── Utils/                Shared validation helpers
└── Data/                 JSON data files (products, users, orders, promo codes)
```

`main.cpp` creates one shared instance of every repository, calls `load()` on each, creates all the managers and, on the first run, the default admin account (`admin` / `Admin@1234`). The path of the `Data/` folder comes from the `DATA_DIR` definition in `CMakeLists.txt`.

All files are already listed in `CMakeLists.txt`, so you do **not** need to edit it when you start writing code in your files.

## 2. Who owns which files

The short name at the end of each file name shows its owner.

| Member | Files |
|---|---|
| **Judy** | `Medicine/MedicineManagerjudy.h/.cpp`, `Medicine/CategoryManagerjudy.h/.cpp` |
| **Heba** | `Inventory/InventoryManagerheba.h/.cpp`, `Repositories/ProductRepositoryheba.h/.cpp` |
| **Hazem** | `Shopping/CartManagerhazem.h/.cpp`, `Shopping/PromoCodeManagerhazem.h/.cpp`, `Repositories/PromoCodeRepositoryhazem.h/.cpp` |
| **Abdelrahman** | `Shopping/CheckoutManagerabdel.h/.cpp`, `Shopping/OrderManagerabdel.h/.cpp` |
| **Rodina** | `Accounts/UserManagerrod.h/.cpp`, `Accounts/Authenticationrod.h/.cpp`, `Repositories/UserRepositoryrod.h/.cpp` |
| **Fayad** | `Accounts/AdminManagerfay.h/.cpp`, `Repositories/OrderRepositoryfay.h/.cpp`, `Utils/Validationfay.h/.cpp` |

## 3. Shared files

These files are used by everyone. **Do not change them on your own.** Ask the team first and agree on the change.

- `Models/` (all 12 files)
- `Data/` (the 4 JSON files)
- `main.cpp`
- `CMakeLists.txt`
- `TEAM_GUIDE.md`

## 4. The golden rule

**Only edit your own files.** If you need something changed in someone else's file or in a shared file, message the owner or the team. This keeps Git conflicts away and makes it clear who to ask about each part.

## 5. What each module is responsible for

| Module | Responsibility |
|---|---|
| **Models** | Plain data classes: `Product`, `User`, `Address`, `CartItem`, `Order`, `PromoCode`. They hold data, check simple rules and convert to and from JSON. |
| **Medicine** | Adding, editing, searching and categorising medicines. |
| **Inventory** | Tracking stock quantities and expiry dates. |
| **Shopping** | The customer's cart, applying promo codes, checking out and managing orders. |
| **Accounts** | Registering users, logging in, and admin features. |
| **Repositories** | Reading and writing the JSON files in `Data/`. Use each Model's `toJson()` and `fromJson()` so every file uses the same format. |
| **Utils** | Shared input checks (email, phone, passwords and so on). |

### Model rules everyone must follow

- **Namespace:** every Model is inside `namespace pharmacy`.
- **Including Models:** write `#include "Models/Product.h"` (or just `"Product.h"`).
- **Money:** prices are whole numbers of piastres stored as `qint64` (1 EGP = 100). For example, 25.50 EGP is `2550`. Money functions end in `Minor`, such as `getPriceMinor()`, `getSubtotalMinor()` and `getFinalPriceMinor()`. Never use `double` for money.
- **Roles:** `"admin"` and `"customer"` (lowercase). Use `User::ROLE_ADMIN` and `User::ROLE_CUSTOMER`.
- **Order statuses:** `pending → confirmed → processing → shipped → delivered`. An order can be `cancelled` from pending, confirmed or processing. `delivered` and `cancelled` are final. Use the `Order::STATUS_...` constants and `updateStatus()`, which refuses invalid moves.
- **Promo codes:** a whole-number percentage from 0 to 100. Apply one with `order.applyPromoCode(promo)`.
- **Expiry dates:** optional. A product without an expiry date is never treated as expired.
- **Prices in carts and orders:** a `CartItem` keeps the price from the moment it was added. At checkout, use `matchesProduct()`, `hasPriceChanged()`, `isStockSufficient()` and `refreshFromProduct()` against the latest product before creating the `Order`.
- **Loading JSON:** `fromJson(json, &ok)` sets `ok` to `false` if the data is broken. Always check it.

## 6. Building and running in Qt Creator

1. Open Qt Creator.
2. Choose **File → Open File or Project…** and select `CMakeLists.txt` in the project root.
3. Pick your Qt 6 kit (for example *Desktop Qt 6.x MinGW 64-bit* on Windows) and click **Configure Project**.
4. Press **Ctrl+B** (**Cmd+B** on macOS) to build.
5. Press **Ctrl+R** (**Cmd+R** on macOS) to run. The program is a console app, so output appears in the *Application Output* panel or a terminal window.

If the build seems stuck on old settings, use **Build → Clear CMake Configuration**, then **Build → Run CMake**.

Messages like `AutoGen warning: "...h" is empty` are normal while files are still empty. They disappear once the files contain code.

## How to run the app

The project is a Qt Quick (QML) desktop app on top of the C++ backend.

**Requirements**
- **Qt 6.8.3 or newer** (the GUI needs ≥ 6.8.3; it also runs on 6.10/6.11). On **Windows use the MinGW kit** (the team's reference kit is Qt 6.8.3 MinGW 64-bit).
- Qt modules: **Qt Quick**, **Qt Quick Controls**, **Qt Svg**, **Qt Shader Tools** (install them in the Qt Maintenance Tool if a module is missing). A C++17 compiler.

**Build and run**
1. In Qt Creator: **File → Open File or Project…** → select `CMakeLists.txt` in the project root.
2. Pick your Qt 6 kit (on Windows the **MinGW** kit) and **Configure Project**.
3. **Build** (Ctrl/Cmd+B), then **Run** (Ctrl/Cmd+R). The window opens on the Home page.

**Default admin login:** `admin` / `Admin@1234` (created automatically on first run). **Change it before any real use.** Admins manage products, orders and inventory; they cannot shop. Customers can check out signed in or as a guest.

**Do not commit your local data.** Running the app writes to `Data/` (it creates the admin account, and placing orders adds to `Data/orders.json`; uploading product images writes `Data/images/`). Before committing, keep `Data/users.json` and `Data/orders.json` as the committed empty `[]`, and never commit `Data/users.json`, `Data/orders.json` or `Data/images/` after running. `Data/images/` is already git-ignored; if you changed `users.json`/`orders.json` by running, restore them with `git checkout -- Data/`.

**Command-line build (optional):** build into a separate folder such as `build-cli/` (git-ignored). Do **not** run a command-line build into `build/` — that is Qt Creator's own folder and a stray CLI cache there causes a generator-mismatch build error.

## 7. Using Git (feature branches)

Nobody pushes directly to `main`. Everyone works on their own feature branch, and the **leader merges** finished branches into `main`.

### Start a new piece of work

```bash
git checkout main
git pull
git checkout -b feature/<your-name>-<topic>      # for example feature/hazem-cart
```

### After you finish a piece of work

```bash
git status
git add Shopping/CartManagerhazem.h Shopping/CartManagerhazem.cpp
git commit -m "Add cart item management"
git push -u origin feature/<your-name>-<topic>
```

Then tell the leader that your branch is ready. The leader merges it into `main` with a normal merge commit, builds the project, and pushes `main`.

### Keep your branch up to date

```bash
git checkout feature/<your-name>-<topic>
git fetch origin
git merge origin/main
```

Tips:

- Replace the file names with **your own files**. Avoid `git add .` because it can add files you did not mean to share.
- Never commit the `build/` folder or `.qtcreator/` settings. They are already ignored.
- Never use `git push --force`. It can delete your teammates' work.
- If a merge reports a conflict, stop and ask the team before continuing.
- Build the project before you push, so nobody pulls code that does not compile.
- Running the program creates the admin in `Data/users.json` and saves orders in `Data/orders.json`. Do not commit those test changes: undo them with `git checkout -- Data/users.json Data/orders.json`.

### Merge order used for the backend integration

The backend branches were merged into `main` in this order, because each one uses the one before it:

1. `feature/heba-inventory-products` (ProductRepository, InventoryManager — used by almost everyone)
2. `feature/judy-medicine-categories` (MedicineManager, CategoryManager — needs Heba)
3. `feature/rodina-accounts` and then `fayad-admin-validation-orders` (Rodina needs Fayad's Validation, Fayad needs Rodina's Authentication and Judy's MedicineManager)
4. `feature/abdel-checkout-orders` (CheckoutManager, OrderManager — needs everyone)

Hazem's cart and promo code files were already on `main`.

## 8. Code rules

- **Header comment:** every member file starts with a Franco comment line that says what the file does, then an Owner line on its own line:
  ```cpp
  // El file da mas2ool 3an el shopping cart: add w remove lel products, ta3deel el kameya, we 7esab el subtotal.
  // Owner: Hazem
  ```
- **Namespace and headers:** everything is inside `namespace pharmacy`, every header starts with `#pragma once`.
- **Classes:** use `class`. A `struct` is allowed **only** for plain request/result data with no functions, for example `CheckoutRequest`, `CheckoutResult`, `CheckoutTotals`, `PriceChange` and `PromoApplication`.
- **Qt types only:** `QString`, `QList`, `QStringList`, `std::optional` for "maybe not found". No `std::string`, no `std::vector`, no `double` for money.
- **No console I/O in the backend:** no `cout`, `cin`, `printf` or `qDebug` in the manager or repository files. Only `main.cpp` prints, using `QTextStream`.
- **JSON only in repositories:** only the files in `Repositories/` read or write files and use `QJson...`. Managers talk to repositories.
- **Results:** functions that can fail return an `enum class` result (`MedicineResult`, `StockResult`, `CartResult`, `PromoResult`, `UserResult`, `LoginResult`, `AdminResult`, `OrderResult`, `CheckoutStatus`).

## 9. Cross-member interfaces (as they exist in the code)

These are the functions one member's code calls in another member's code. Do not rename or change them without telling the team.

| Provider | Class / function | Used by |
|---|---|---|
| Heba | `ProductRepository::load()`, `lastError()`, `getAllProducts()`, `std::optional<Product> getProductById(const QString&) const`, `existsById(const QString&) const`, `existsByCode(const QString&) const`, `saveProduct(const Product&)`, `updateProduct(const Product&)`, `deleteProduct(const QString&)` | Judy, Hazem, Abdelrahman, main.cpp |
| Heba | `enum class StockResult { Success, InvalidQuantity, ProductNotFound, InsufficientStock, Expired, StorageError }` | Abdelrahman |
| Heba | `InventoryManager::getStock(const QString&) const` → `std::optional<int>`, `isAvailable(const QString&) const`, `hasSufficientStock(const QString&, int) const`, `increaseStock(const QString&, int)` → `StockResult`, `decreaseStock(const QString&, int)` → `StockResult`, `getLowStockProducts(int) const`, `getExpiredProducts() const` | Hazem, Abdelrahman |
| Judy | `MedicineManager::addMedicine(const Product&)`, `updateMedicine(const Product&)`, `deleteMedicine(const QString&)` → `MedicineResult`; `findMedicineById(const QString&) const` → `std::optional<Product>`; `searchMedicines(const QString&) const`, `getAllMedicines() const`, `getMedicinesByCategory(const QString&) const` → `QList<Product>` | Fayad |
| Judy | `CategoryManager::getAllCategories()`, `isValidCategory(const QString&)`, `normalizeCategory(const QString&)` (all static). Categories: `Medicines`, `Skincare`, `Vitamins & Supplements`, `First Aid & Medical Supplies` | Judy, GUI |
| Hazem | `CartManager::getItems() const` → `QList<CartItem>`, `isEmpty() const`, `clear()` | Abdelrahman |
| Hazem | `PromoCodeManager::findValidPromo(const QString&) const` → `std::optional<PromoCode>` | Abdelrahman |
| Rodina | `UserRepository::getUserById(const QString&) const` → `std::optional<User>` | Abdelrahman |
| Rodina | `Authentication::currentUser() const` → `std::optional<User>`, `isCurrentUserAdmin() const`, static `hashPassword(const QString&)` | Fayad, main.cpp |
| Fayad | `Validation::isNonEmptyText`, `isValidEmail`, `isValidPhone`, `isValidPassword` (all static, `const QString&` → `bool`) | Rodina |
| Fayad | `OrderRepository::saveOrder(const Order&)`, `updateOrder(const Order&)`, `getOrderById(const QString&) const` → `std::optional<Order>`, `getAllOrders() const`, `getOrdersByCustomer(const QString&) const` → `QList<Order>` | Abdelrahman |
| Abdelrahman | `OrderManager::generateOrderId() const`, `createOrder(const Order&)`, `cancelOrder(const QString&)`, `updateOrderStatus(const QString&, const QString&)` → `OrderResult` | Abdelrahman, GUI |
| Abdelrahman | `CheckoutManager::previewTotals(const QString&) const` → `CheckoutTotals`, `placeOrder(const CheckoutRequest&)` → `CheckoutResult` (statuses include `PriceChanged` and `PrescriptionRequired`) | GUI |
