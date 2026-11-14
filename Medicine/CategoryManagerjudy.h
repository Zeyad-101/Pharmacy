// El file da mas2ool 3an el categories bta3t el pharmacy: list el categories wel check en el category sa7.
// Owner: Judy
#pragma once

#include <QString>
#include <QStringList>

namespace pharmacy {

class CategoryManager
{
public:
    static constexpr char CATEGORY_MEDICINES[] = "Medicines";
    static constexpr char CATEGORY_SKINCARE[]  = "Skincare";
    static constexpr char CATEGORY_VITAMINS[]  = "Vitamins & Supplements";
    static constexpr char CATEGORY_FIRST_AID[] = "First Aid & Medical Supplies";

    static QStringList getAllCategories();
    static bool isValidCategory(const QString& category);
    static QString normalizeCategory(const QString& category);
};

}
