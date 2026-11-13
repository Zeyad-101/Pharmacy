#include <iostream>
#include <string>
#include <vector>

using namespace std;

// Structure for Medicines
struct Medicine {
    int id;
    string name;
    string price;
    string alternative;
    string altPrice;
    string activeIngredient;
    string uses;
};

// Structure for Vitamins
struct Vitamin {
    int id;
    string name;
    string price;
    string keyIngredients;
    string uses;
};

class MedicineManager {
private:
    vector<Medicine> medicines;
    vector<Vitamin> vitamins;

public:
    MedicineManager();
    void displayAll() const;
    void searchItem(const string& query);
    void addMedicineInteractive(const string& name);
};
