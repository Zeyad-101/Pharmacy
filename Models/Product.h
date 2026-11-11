#pragma once

#include <QDate>
#include <QJsonObject>
#include <QString>

namespace pharmacy {

class Product
{
public:
    Product();
    Product(const QString& id,
            const QString& name,
            const QString& code,
            const QString& category,
            const QString& description,
            qint64 priceMinor,
            int stockQuantity,
            const QString& imagePath,
            const QDate& expiryDate,
            bool requiresPrescription);

    QString getId() const;
    QString getName() const;
    QString getCode() const;
    QString getCategory() const;
    QString getDescription() const;
    qint64 getPriceMinor() const;
    int getStockQuantity() const;
    QString getImagePath() const;
    QDate getExpiryDate() const;
    bool getRequiresPrescription() const;

    void setName(const QString& name);
    void setCode(const QString& code);
    void setCategory(const QString& category);
    void setDescription(const QString& description);
    bool setPriceMinor(qint64 priceMinor);
    bool setStockQuantity(int stockQuantity);
    void setImagePath(const QString& imagePath);
    void setExpiryDate(const QDate& expiryDate);
    void setRequiresPrescription(bool requiresPrescription);

    bool hasExpiryDate() const;
    bool isExpired() const;
    bool isAvailable() const;
    bool hasSufficientStock(int quantity) const;

    QJsonObject toJson() const;
    static Product fromJson(const QJsonObject& json, bool* ok = nullptr);

private:
    QString id;
    QString name;
    QString code;
    QString category;
    QString description;
    qint64 priceMinor;
    int stockQuantity;
    QString imagePath;
    QDate expiryDate;
    bool requiresPrescription;
};

}
