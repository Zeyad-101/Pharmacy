// El file da mas2ool 3an el categories bta3t el pharmacy: list el categories wel check en el category sa7.
// Owner: Judy
#include "Medicine/CategoryManagerjudy.h"

namespace pharmacy {

QStringList CategoryManager::getAllCategories()
{
    // The 4 pharmacy categories, always in this order
    QStringList categories;
    categories.append(QString(CATEGORY_MEDICINES));
    categories.append(QString(CATEGORY_SKINCARE));
    categories.append(QString(CATEGORY_VITAMINS));
    categories.append(QString(CATEGORY_FIRST_AID));
    return categories;
}

QString CategoryManager::normalizeCategory(const QString& category)
{
    // Remove spaces from the start and the end
    QString cleanCategory = category.trimmed();

    // Compare with each category, ignoring upper / lower case
    const QStringList categories = getAllCategories();
    for (const QString& official : categories) {
        if (cleanCategory.compare(official, Qt::CaseInsensitive) == 0) {
            return official;
        }
    }

    // If not found, return nothing
    return QString();
}

bool CategoryManager::isValidCategory(const QString& category)
{
    // A category is valid if we found its official name
    QString result = normalizeCategory(category);
    return !result.isEmpty();
}

}
