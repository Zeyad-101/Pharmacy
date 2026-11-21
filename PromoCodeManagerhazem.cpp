#include "Shopping/PromoCodeManagerhazem.h"

#include <QDate>

namespace pharmacy {

PromoCodeManager::PromoCodeManager(PromoCodeRepository& repository)
    : repository(repository)
{
}

PromoResult PromoCodeManager::checkState(const PromoCode& promo) const
{
    if (!promo.isActive()) {
        return PromoResult::Inactive;
    }
    const QDate expiration = promo.getExpirationDate();
    if (!expiration.isValid() || expiration < QDate::currentDate()) {
        return PromoResult::Expired;
    }
    return PromoResult::Success;
}

PromoResult PromoCodeManager::validatePromoCode(const QString& code) const
{
    if (code.trimmed().isEmpty()) {
        return PromoResult::InvalidCode;
    }
    const std::optional<PromoCode> promo = repository.getPromoCodeByCode(code);
    if (!promo) {
        return PromoResult::NotFound;
    }
    return checkState(*promo);
}

PromoApplication PromoCodeManager::applyPromoCode(const QString& code, qint64 subtotalMinor) const
{
    PromoApplication application;
    application.finalMinor = subtotalMinor;

    if (subtotalMinor <= 0) {
        application.result = PromoResult::InvalidSubtotal;
        return application;
    }
    if (code.trimmed().isEmpty()) {
        application.result = PromoResult::InvalidCode;
        return application;
    }

    const std::optional<PromoCode> promo = repository.getPromoCodeByCode(code);
    if (!promo) {
        application.result = PromoResult::NotFound;
        return application;
    }

    const PromoResult state = checkState(*promo);
    if (state != PromoResult::Success) {
        application.result = state;
        return application;
    }

    qint64 discount = promo->calculateDiscountMinor(subtotalMinor);
    if (discount > subtotalMinor) {
        discount = subtotalMinor;
    }
    if (discount <= 0) {
        application.result = PromoResult::NotApplicable;
        return application;
    }

    application.result = PromoResult::Success;
    application.code = promo->getCode();
    application.discountPercentage = promo->getDiscountPercentage();
    application.discountMinor = discount;
    application.finalMinor = subtotalMinor - discount;
    return application;
}

std::optional<PromoCode> PromoCodeManager::findPromoCode(const QString& code) const
{
    return repository.getPromoCodeByCode(code);
}

QList<PromoCode> PromoCodeManager::getAllPromoCodes() const
{
    return repository.getAllPromoCodes();
}

}
