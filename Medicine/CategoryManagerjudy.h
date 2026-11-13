#include<iostream>
using namespace std;
void CategoryManager::runSystem() {
    int choice;
    string query;

    do {
        cout << "\n** SMART PHARMACY SYSTEM **\n";
        cout << "1. Display All Inventory (Medicines & Vitamins)\n";
        cout << "2. Search Medicine or Vitamin (with Auto-Add if missing)\n";
        cout << "3. Exit\n";
        cout << "Enter your choice: ";
        cin >> choice;

        switch (choice) {
        case 1:
            medManager.displayAll();
            break;
        case 2:
            cout << "Enter medicine or vitamin name to search: ";
            cin.ignore();
            getline(cin, query);
            medManager.searchItem(query);
            break;
        case 3:
            cout << "Exiting system. Goodbye!\n";
            break;
        default:
            cout << "Invalid choice. Please try again.\n";
        }
    } while (choice != 3);
}

