// El file da mas2ool 3an edaret el adweya wel products: add, update, delete, search, we list by category.
// Owner: Judy
#pragma once

#include <QList>
#include <QString>
#include <optional>

#include "Models/Product.h"

namespace pharmacy {

class ProductRepository;

enum class MedicineResult {
    Success,
    InvalidData,
    InvalidCategory,
    DuplicateId,
    DuplicateCode,
    NotFound,
    StorageError
};

class MedicineManager
{
public:
    explicit MedicineManager(ProductRepository& repository);

    MedicineResult addMedicine(const Product& product);
    MedicineResult updateMedicine(const Product& product);
    MedicineResult deleteMedicine(const QString& productId);

    std::optional<Product> findMedicineById(const QString& productId) const;
    QList<Product> searchMedicines(const QString& term) const;
    QList<Product> getAllMedicines() const;
    QList<Product> getMedicinesByCategory(const QString& category) const;

private:
    MedicineResult validateProduct(const Product& product) const;

    ProductRepository& repository;
};

}
