// El file da mas2ool 3an 7efz w esterga3 bayanat el products men file products.json.
// Owner: Heba
#pragma once

#include <QList>
#include <QString>
#include <optional>

#include "Models/Product.h"

namespace pharmacy {

class ProductRepository
{
public:
    explicit ProductRepository(const QString& filePath);

    bool load();
    QString lastError() const;

    QList<Product> getAllProducts() const;
    std::optional<Product> getProductById(const QString& id) const;
    bool existsById(const QString& id) const;
    bool existsByCode(const QString& code) const;

    bool saveProduct(const Product& product);
    bool updateProduct(const Product& product);
    bool deleteProduct(const QString& id);

private:
    bool writeToFile(const QList<Product>& list);
    int indexOf(const QString& id) const;

    QString filePath;
    QList<Product> products;
    bool loaded = false;
    QString error;
};

}
