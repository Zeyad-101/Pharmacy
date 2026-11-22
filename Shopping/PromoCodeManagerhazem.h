#pragma once

#include <QList>
#include <QString>
#include <optional>

#include "Models/PromoCode.h"
#include "Repositories/PromoCodeRepositoryhazem.h"

namespace pharmacy {

enum class PromoResult
{
    Success,
    InvalidCode,
    NotFound,
    Inactive,
    Expired,
    InvalidSubtotal,
    NotApplicable
};

struct PromoApplication
{
    PromoResult result = PromoResult::InvalidCode;
    QString code;
    int discountPercentage = 0;
    qint64 discountMinor = 0;
    qint64 finalMinor = 0;
};

class PromoCodeManager
{
public:
    explicit PromoCodeManager(PromoCodeRepository& repository);

    PromoResult validatePromoCode(const QString& code) const;
    PromoApplication applyPromoCode(const QString& code, qint64 subtotalMinor) const;
    std::optional<PromoCode> findPromoCode(const QString& code) const;
    std::optional<PromoCode> findValidPromo(const QString& code) const;
    QList<PromoCode> getAllPromoCodes() const;

private:
    PromoResult checkState(const PromoCode& promo) const;

    PromoCodeRepository& repository;
};

}
