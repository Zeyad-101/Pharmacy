// El file da mas2ool 3an 7efz w esterga3 bayanat el products men file products.json.
// Owner: Heba
#include "Repositories/ProductRepositoryheba.h"

#include <QByteArray>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonValue>
#include <QSaveFile>

namespace pharmacy {

ProductRepository::ProductRepository(const QString& filePath)
    : filePath(filePath)
{
}

bool ProductRepository::load()
{
    // Start from a clean state
    products.clear();
    loaded = false;
    error.clear();

    // If the file does not exist yet, start with an empty list
    if (!QFile::exists(filePath)) {
        loaded = true;
        return true;
    }

    // Read the whole file
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        error = QString("Cannot open products file: %1").arg(file.errorString());
        return false;
    }
    QByteArray data = file.readAll();
    file.close();

    // Check the text is valid JSON
    QJsonParseError parseError;
    QJsonDocument document = QJsonDocument::fromJson(data, &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        error = QString("Products file is not valid JSON: %1").arg(parseError.errorString());
        return false;
    }

    // The file must contain a list of products
    if (!document.isArray()) {
        error = QString("Products file must contain a JSON array");
        return false;
    }

    // Read each product into a temporary list
    QList<Product> list;
    QJsonArray array = document.array();
    int index = 0;
    for (const QJsonValue& value : array) {
        // Every item must be an object
        if (!value.isObject()) {
            error = QString("Product at index %1 is not a JSON object").arg(index);
            return false;
        }

        // Let the Product model read and check its own data
        bool ok = false;
        Product product = Product::fromJson(value.toObject(), &ok);
        if (!ok) {
            error = QString("Product at index %1 has invalid data").arg(index);
            return false;
        }

        // Two products cannot share the same id
        for (const Product& other : list) {
            if (other.getId() == product.getId()) {
                error = QString("Product at index %1 repeats the id %2").arg(index).arg(product.getId());
                return false;
            }
        }

        list.append(product);
        index = index + 1;
    }

    // Everything is fine, keep the products
    products = list;
    loaded = true;
    return true;
}

QString ProductRepository::lastError() const
{
    return error;
}

QList<Product> ProductRepository::getAllProducts() const
{
    return products;
}

std::optional<Product> ProductRepository::getProductById(const QString& id) const
{
    // Find the product position in the list
    int index = indexOf(id);
    if (index == -1) {
        return std::nullopt;
    }
    return products.at(index);
}

bool ProductRepository::existsById(const QString& id) const
{
    return indexOf(id) != -1;
}

bool ProductRepository::existsByCode(const QString& code) const
{
    // Empty code never matches
    QString cleanCode = code.trimmed();
    if (cleanCode.isEmpty()) {
        return false;
    }

    // Compare codes ignoring spaces and upper / lower case
    for (const Product& product : products) {
        if (product.getCode().trimmed().compare(cleanCode, Qt::CaseInsensitive) == 0) {
            return true;
        }
    }
    return false;
}

bool ProductRepository::saveProduct(const Product& product)
{
    // Never write if the file was not loaded correctly
    if (!loaded) {
        error = QString("Products were not loaded, nothing was saved");
        return false;
    }

    // The id must be filled in
    if (product.getId().trimmed().isEmpty()) {
        error = QString("Product id is empty");
        return false;
    }

    // The id must be new
    if (existsById(product.getId())) {
        error = QString("A product with id %1 already exists").arg(product.getId());
        return false;
    }

    // Add to a copy, write it, then keep the copy
    QList<Product> copy = products;
    copy.append(product);
    if (!writeToFile(copy)) {
        return false;
    }
    products = copy;
    return true;
}

bool ProductRepository::updateProduct(const Product& product)
{
    // Never write if the file was not loaded correctly
    if (!loaded) {
        error = QString("Products were not loaded, nothing was updated");
        return false;
    }

    // The product must already exist
    int index = indexOf(product.getId());
    if (index == -1) {
        error = QString("No product with id %1").arg(product.getId());
        return false;
    }

    // Replace it in a copy, write it, then keep the copy
    QList<Product> copy = products;
    copy[index] = product;
    if (!writeToFile(copy)) {
        return false;
    }
    products = copy;
    return true;
}

bool ProductRepository::deleteProduct(const QString& id)
{
    // Never write if the file was not loaded correctly
    if (!loaded) {
        error = QString("Products were not loaded, nothing was deleted");
        return false;
    }

    // The product must already exist
    int index = indexOf(id);
    if (index == -1) {
        error = QString("No product with id %1").arg(id);
        return false;
    }

    // Remove it from a copy, write it, then keep the copy
    QList<Product> copy = products;
    copy.removeAt(index);
    if (!writeToFile(copy)) {
        return false;
    }
    products = copy;
    return true;
}

bool ProductRepository::writeToFile(const QList<Product>& list)
{
    // Turn every product into JSON using the Product model
    QJsonArray array;
    for (const Product& product : list) {
        array.append(product.toJson());
    }
    QByteArray data = QJsonDocument(array).toJson(QJsonDocument::Indented);

    // QSaveFile writes to a temporary file first, so the old file is safe if something fails
    QSaveFile file(filePath);
    if (!file.open(QIODevice::WriteOnly)) {
        error = QString("Cannot open products file for writing: %1").arg(file.errorString());
        return false;
    }

    // Write the data
    qint64 written = file.write(data);
    if (written == -1) {
        error = QString("Cannot write products file: %1").arg(file.errorString());
        file.cancelWriting();
        return false;
    }
    if (written != data.size()) {
        error = QString("Products file was only partly written");
        file.cancelWriting();
        return false;
    }

    // Replace the real file only now
    if (!file.commit()) {
        error = QString("Cannot save products file: %1").arg(file.errorString());
        return false;
    }

    error.clear();
    return true;
}

int ProductRepository::indexOf(const QString& id) const
{
    // Empty id is never found
    if (id.isEmpty()) {
        return -1;
    }

    // Look for the exact id
    int index = 0;
    for (const Product& product : products) {
        if (product.getId() == id) {
            return index;
        }
        index = index + 1;
    }
    return -1;
}

}
