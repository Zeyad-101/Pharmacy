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
├── Core/                 Empty placeholders, not used by the build
└── Data/                 JSON data files (products, users, orders, promo codes)
```

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

## 7. Using Git

### Every time before you start working

```bash
git pull
```

### After you finish a piece of work

```bash
git status
git add Shopping/CartManagerhazem.h Shopping/CartManagerhazem.cpp
git commit -m "Add cart item management"
git pull --rebase
git push
```

Tips:

- Replace the file names with **your own files**. Avoid `git add .` because it can add files you did not mean to share.
- Never commit the `build/` folder or `.qtcreator/` settings. They are already ignored.
- Never use `git push --force`. It can delete your teammates' work.
- If `git pull --rebase` reports a conflict, stop and ask the team before continuing.
- Build the project before you push, so nobody pulls code that does not compile.
