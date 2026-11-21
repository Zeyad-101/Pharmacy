#pragma once

#include <QList>
#include <QString>
#include <optional>

#include "Models/PromoCode.h"

namespace pharmacy {

class PromoCodeRepository
{
public:
    explicit PromoCodeRepository(const QString& filePath);

    bool load();
    QString lastError() const;

    QList<PromoCode> getAllPromoCodes() const;
    std::optional<PromoCode> getPromoCodeByCode(const QString& code) const;
    bool existsByCode(const QString& code) const;

    bool savePromoCode(const PromoCode& promo);
    bool updatePromoCode(const PromoCode& promo);
    bool deletePromoCode(const QString& code);

private:
    bool writeToFile(const QList<PromoCode>& list);
    int indexOf(const QString& code) const;

    QString filePath;
    QList<PromoCode> promoCodes;
    bool loaded = false;
    QString error;
};

}
