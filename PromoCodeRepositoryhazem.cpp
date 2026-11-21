#include "Repositories/PromoCodeRepositoryhazem.h"

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QSaveFile>

namespace pharmacy {

PromoCodeRepository::PromoCodeRepository(const QString& filePath)
    : filePath(filePath)
{
}

bool PromoCodeRepository::load()
{
    promoCodes.clear();
    loaded = false;
    error.clear();

    QFile file(filePath);
    if (!file.exists()) {
        loaded = true;
        return true;
    }
    if (!file.open(QIODevice::ReadOnly)) {
        error = QStringLiteral("Cannot open promo codes file");
        return false;
    }

    QJsonParseError parseError;
    const QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        error = QStringLiteral("promo_codes.json is invalid: ") + parseError.errorString();
        return false;
    }
    if (!doc.isArray()) {
        error = QStringLiteral("promo_codes.json must contain a JSON array");
        return false;
    }

    QList<PromoCode> loadedList;
    const QJsonArray array = doc.array();
    for (int i = 0; i < array.size(); ++i) {
        if (!array[i].isObject()) {
            error = QStringLiteral("promo_codes.json: item %1 is not an object").arg(i);
            return false;
        }
        bool ok = false;
        const PromoCode promo = PromoCode::fromJson(array[i].toObject(), &ok);
        if (!ok) {
            error = QStringLiteral("promo_codes.json: item %1 is not a valid promo code").arg(i);
            return false;
        }
        for (const PromoCode& existing : loadedList) {
            if (existing.getCode().compare(promo.getCode(), Qt::CaseInsensitive) == 0) {
                error = QStringLiteral("promo_codes.json: duplicate code ") + promo.getCode();
                return false;
            }
        }
        loadedList.append(promo);
    }

    promoCodes = loadedList;
    loaded = true;
    return true;
}

QString PromoCodeRepository::lastError() const
{
    return error;
}

int PromoCodeRepository::indexOf(const QString& code) const
{
    const QString trimmed = code.trimmed();
    if (trimmed.isEmpty()) {
        return -1;
    }
    for (int i = 0; i < promoCodes.size(); ++i) {
        if (promoCodes[i].getCode().compare(trimmed, Qt::CaseInsensitive) == 0) {
            return i;
        }
    }
    return -1;
}

QList<PromoCode> PromoCodeRepository::getAllPromoCodes() const
{
    return promoCodes;
}

std::optional<PromoCode> PromoCodeRepository::getPromoCodeByCode(const QString& code) const
{
    const int i = indexOf(code);
    if (i == -1) {
        return std::nullopt;
    }
    return promoCodes[i];
}

bool PromoCodeRepository::existsByCode(const QString& code) const
{
    return indexOf(code) != -1;
}

bool PromoCodeRepository::writeToFile(const QList<PromoCode>& list)
{
    QJsonArray array;
    for (const PromoCode& promo : list) {
        array.append(promo.toJson());
    }

    QSaveFile file(filePath);
    if (!file.open(QIODevice::WriteOnly)) {
        error = QStringLiteral("Cannot write promo codes file");
        return false;
    }
    if (file.write(QJsonDocument(array).toJson(QJsonDocument::Indented)) == -1) {
        file.cancelWriting();
        error = QStringLiteral("Failed to write promo codes file");
        return false;
    }
    if (!file.commit()) {
        error = QStringLiteral("Failed to save promo codes file");
        return false;
    }
    return true;
}

bool PromoCodeRepository::savePromoCode(const PromoCode& promo)
{
    if (!loaded || promo.getCode().trimmed().isEmpty() || existsByCode(promo.getCode())) {
        return false;
    }
    QList<PromoCode> copy = promoCodes;
    copy.append(promo);
    if (!writeToFile(copy)) {
        return false;
    }
    promoCodes = copy;
    return true;
}

bool PromoCodeRepository::updatePromoCode(const PromoCode& promo)
{
    const int i = indexOf(promo.getCode());
    if (!loaded || i == -1) {
        return false;
    }
    QList<PromoCode> copy = promoCodes;
    copy[i] = promo;
    if (!writeToFile(copy)) {
        return false;
    }
    promoCodes = copy;
    return true;
}

bool PromoCodeRepository::deletePromoCode(const QString& code)
{
    const int i = indexOf(code);
    if (!loaded || i == -1) {
        return false;
    }
    QList<PromoCode> copy = promoCodes;
    copy.removeAt(i);
    if (!writeToFile(copy)) {
        return false;
    }
    promoCodes = copy;
    return true;
}

}
