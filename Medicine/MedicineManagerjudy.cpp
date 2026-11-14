// El file da mas2ool 3an edaret el adweya wel products: add, update, delete, search, we list by category.
// Owner: Judy
#include "Medicine/MedicineManagerjudy.h"

#include "Medicine/CategoryManagerjudy.h"
#include "Repositories/ProductRepositoryheba.h"

namespace pharmacy {

MedicineManager::MedicineManager(ProductRepository& repository)
    : repository(repository)
{
}

MedicineResult MedicineManager::validateProduct(const Product& product) const
{
    // Later we can use Fayad's Validation functions here

    // Check the id is not empty
    if (product.getId().trimmed().isEmpty()) {
        return MedicineResult::InvalidData;
    }

    // Check the name is not empty
    if (product.getName().trimmed().isEmpty()) {
        return MedicineResult::InvalidData;
    }

    // Check the price is more than zero
    if (product.getPriceMinor() <= 0) {
        return MedicineResult::InvalidData;
    }

    // Check the stock is not negative
    if (product.getStockQuantity() < 0) {
        return MedicineResult::InvalidData;
    }

    // Check the category is one of the 4 categories
    if (!CategoryManager::isValidCategory(product.getCategory())) {
        return MedicineResult::InvalidCategory;
    }

    return MedicineResult::Success;
}

MedicineResult MedicineManager::addMedicine(const Product& product)
{
    // Check the product data first
    MedicineResult result = validateProduct(product);
    if (result != MedicineResult::Success) {
        return result;
    }

    // Do not add an expired product
    if (product.isExpired()) {
        return MedicineResult::InvalidData;
    }

    // Check no other product has the same id
    if (repository.existsById(product.getId())) {
        return MedicineResult::DuplicateId;
    }

    // Check no other product has the same code
    if (!product.getCode().isEmpty()) {
        if (repository.existsByCode(product.getCode())) {
            return MedicineResult::DuplicateCode;
        }
    }

    // Save the category with its official spelling
    Product cleanProduct = product;
    cleanProduct.setCategory(CategoryManager::normalizeCategory(product.getCategory()));

    // Ask the repository to save it
    if (!repository.saveProduct(cleanProduct)) {
        return MedicineResult::StorageError;
    }

    return MedicineResult::Success;
}

MedicineResult MedicineManager::updateMedicine(const Product& product)
{
    // Check the product data first
    MedicineResult result = validateProduct(product);
    if (result != MedicineResult::Success) {
        return result;
    }

    // Find the old product
    std::optional<Product> oldProduct = repository.getProductById(product.getId());
    if (!oldProduct) {
        return MedicineResult::NotFound;
    }

    // If the code changed, check no other product uses the new code
    if (product.getCode() != oldProduct->getCode()) {
        if (!product.getCode().isEmpty()) {
            const QList<Product> allProducts = repository.getAllProducts();
            for (const Product& other : allProducts) {
                if (other.getId() == product.getId()) {
                    continue;
                }
                if (other.getCode() == product.getCode()) {
                    return MedicineResult::DuplicateCode;
                }
            }
        }
    }

    // Save the category with its official spelling
    Product cleanProduct = product;
    cleanProduct.setCategory(CategoryManager::normalizeCategory(product.getCategory()));

    // Ask the repository to update it
    if (!repository.updateProduct(cleanProduct)) {
        return MedicineResult::StorageError;
    }

    return MedicineResult::Success;
}

MedicineResult MedicineManager::deleteMedicine(const QString& productId)
{
    // Check the id is not empty
    QString id = productId.trimmed();
    if (id.isEmpty()) {
        return MedicineResult::InvalidData;
    }

    // Check the product exists
    if (!repository.existsById(id)) {
        return MedicineResult::NotFound;
    }

    // Ask the repository to delete it
    if (!repository.deleteProduct(id)) {
        return MedicineResult::StorageError;
    }

    return MedicineResult::Success;
}

std::optional<Product> MedicineManager::findMedicineById(const QString& productId) const
{
    // Empty id means nothing to find
    QString id = productId.trimmed();
    if (id.isEmpty()) {
        return std::nullopt;
    }

    // If not found, the repository returns nothing
    return repository.getProductById(id);
}

QList<Product> MedicineManager::searchMedicines(const QString& term) const
{
    QList<Product> result;

    // Empty search term gives an empty list
    QString cleanTerm = term.trimmed();
    if (cleanTerm.isEmpty()) {
        return result;
    }

    // Search names and codes, ignoring upper / lower case
    const QList<Product> allProducts = repository.getAllProducts();
    for (const Product& product : allProducts) {
        bool found = false;
        if (product.getName().contains(cleanTerm, Qt::CaseInsensitive)) {
            found = true;
        }
        if (product.getCode().contains(cleanTerm, Qt::CaseInsensitive)) {
            found = true;
        }
        if (found) {
            result.append(product);
        }
    }

    return result;
}

QList<Product> MedicineManager::getAllMedicines() const
{
    return repository.getAllProducts();
}

QList<Product> MedicineManager::getMedicinesByCategory(const QString& category) const
{
    QList<Product> result;

    // Get the official category name
    QString cleanCategory = CategoryManager::normalizeCategory(category);
    if (cleanCategory.isEmpty()) {
        return result;
    }

    // Keep only the products in this category
    const QList<Product> allProducts = repository.getAllProducts();
    for (const Product& product : allProducts) {
        if (product.getCategory() == cleanCategory) {
            result.append(product);
        }
    }

    return result;
}

}
