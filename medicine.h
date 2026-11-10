#include <iostream>
#include <vector>
#include <string>
#include <limits>

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

class Pharmacy {
private:
    vector<Medicine> medicines;
    vector<Vitamin> vitamins;

public:
    Pharmacy() {
        // Initial Egyptian Medicines
        medicines = {
            {1, "Cataflam", "~65 - 85 EGP", "Diclofen (or Voltaren)", "~35 - 50 EGP", "Diclofenac Potassium / Sodium", "Fast-acting pain reliever & anti-inflammatory"},
            {2, "Antinal", "~30 - 45 EGP", "Diax", "~20 - 30 EGP", "Nifuroxazide", "Intestinal antiseptic for diarrhea"},
            {3, "Hibiotic", "~110 - 140 EGP", "Clavimox", "~75 - 100 EGP", "Amoxicillin + Clavulanic Acid", "Broad-spectrum antibiotic"},
            {4, "Concor (5mg)", "~80 - 110 EGP", "Bisocard (5mg)", "~45 - 65 EGP", "Bisoprolol", "High blood pressure & heart rate regulation"},
            {5, "Cidophage (500mg)", "~30 - 45 EGP", "Metformin El-Nasr", "~20 - 35 EGP", "Metformin", "Blood sugar regulation (Type 2 diabetes) & PCOS"},
            {6, "Omez (20mg)", "~45 - 65 EGP", "Omeprazole", "~30 - 40 EGP", "Omeprazole", "Heartburn, GERD, and stomach ulcer treatment"},
            {7, "Myofen", "~35 - 50 EGP", "Norgesic", "~25 - 35 EGP", "Chlorzoxazone + Paracetamol", "Muscle relaxant & pain reliever"}
        };

        // Initial Egyptian Vitamins
        vitamins = {
            {1, "Methyltechno", "~100 - 130 EGP (Oral Strips)", "Vitamin B12 (Methylcobalamin)", "Nerve support, numbness/tingling relief"},
            {2, "Vitacid C", "~20 - 35 EGP (Effervescent)", "Vitamin C (1000mg)", "Immune booster & cold/flu prevention"},
            {3, "Sanso Magnesium", "~70 - 100 EGP", "Magnesium", "Muscle cramp relief & sleep quality improvement"}
        };
    }

    void displayAll() const {
        cout << "\n=================== EGYPTIAN MEDICINES ===================\n";

        for (const auto& med : medicines) {
            cout << "ID: " << med.id
                 << " | Brand: " << med.name
                 << " (" << med.price << ")\n";

            cout << "   -> Alternative: "
                 << med.alternative
                 << " (" << med.altPrice << ")\n";

            cout << "   -> Uses: " << med.uses << "\n";
        }

        cout << "\n=================== EGYPTIAN VITAMINS ====================\n";

        for (const auto& vit : vitamins) {
            cout << "ID: " << vit.id
                 << " | Vitamin: " << vit.name
                 << " (" << vit.price << ")\n";

            cout << "   -> Ingredients: "
                 << vit.keyIngredients << "\n";

            cout << "   -> Uses: "
                 << vit.uses << "\n";
        }
    }

    void searchItem(const string& searchItem) {
        bool found = false;

        cout << "\n--- Searching Medicines for \""
             << searchItem << "\" ---\n";

        for (const auto& med : medicines) {
            if (med.name.find(searchItem) != string::npos ||
                med.alternative.find(searchItem) != string::npos) {

                cout << "\n[FOUND IN MEDICINES]\n";
                cout << "Brand Medicine: "
                     << med.name
                     << " | Price: "
                     << med.price << "\n";

                cout << "Alternative: "
                     << med.alternative
                     << " | Alt Price: "
                     << med.altPrice << "\n";

                cout << "Active Ingredient: "
                     << med.activeIngredient << "\n";

                cout << "Main Uses: "
                     << med.uses << "\n";

                found = true;
            }
        }

        cout << "\n--- Searching Vitamins for \""
             << searchItem << "\" ---\n";

        for (const auto& vit : vitamins) {
            if (vit.name.find(searchItem) != string::npos) {

                cout << "\n[FOUND IN VITAMINS]\n";
                cout << "Vitamin Name: "
                     << vit.name
                     << " | Price: "
                     << vit.price << "\n";

                cout << "Ingredients: "
                     << vit.keyIngredients << "\n";

                cout << "Main Uses: "
                     << vit.uses << "\n";

                found = true;
            }
        }

        if (!found) {
            cout << "\nItem \"" << searchItem
                 << "\" was not found in the pharmacy database.\n";

            char choice;
            cout << "Would you like to add this medicine/vitamin to the system? (y/n): ";
            cin >> choice;

            if (choice == 'y' || choice == 'Y') {
                addMedicineInteractive(searchItem);
            }
        }
    }

    void addMedicineInteractive(const string& name) {
        Medicine newMed;

        newMed.id = medicines.size() + 1;
        newMed.name = name;

        cin.ignore(numeric_limits<streamsize>::max(), '\n');

        cout << "Enter Brand Price: ";
        getline(cin, newMed.price);

        cout << "Enter Alternative Medicine Name: ";
        getline(cin, newMed.alternative);

        cout << "Enter Alternative Price: ";
        getline(cin, newMed.altPrice);

        cout << "Enter Active Ingredient: ";
        getline(cin, newMed.activeIngredient);

        cout << "Enter Main Uses: ";
        getline(cin, newMed.uses);

        medicines.push_back(newMed);

        cout << "\n[SUCCESS] New medicine added to the database!\n";
    }
};

int main() {
    Pharmacy myPharmacy;
    int choice;
    string query;

    do {
        cout << "\n===== SMART PHARMACY SYSTEM =====\n";
        cout << "1. Display All Inventory\n";
        cout << "2. Search Medicine or Vitamin\n";
        cout << "3. Exit\n";
        cout << "Enter your choice: ";

        cin >> choice;

        switch (choice) {
        case 1:
            myPharmacy.displayAll();
            break;

        case 2:
            cin.ignore(numeric_limits<streamsize>::max(), '\n');

            cout << "Enter medicine or vitamin name to search: ";
            getline(cin, query);

            myPharmacy.searchItem(query);
            break;

        case 3:
            cout << "Exiting system. Goodbye!\n";
            break;

        default:
            cout << "Invalid choice. Please try again.\n";
        }

    } while (choice != 3);

    return 0;
}