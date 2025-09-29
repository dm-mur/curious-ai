import from byllm { Model }

glob llm = Model(model_name="gemini/gemini-2.0-flash", verbose=True);

# -----------------------------
# Facility Object
# -----------------------------
obj Facility {
    has name:str;
    has inventory:str = {};
}

impl Facility.init(name) {
    self.name = name;
    self.inventory = {};
}

impl Facility.add(drug, qty) {
    self.inventory[drug] = self.inventory.get(drug, 0) + qty;
}

impl Facility.remove(drug, qty) {
    available = self.inventory.get(drug, 0);
    if qty > available {
        qty = available;
    }
    self.inventory[drug] = available - qty;
    return qty;
}

# -----------------------------
# Specialized Facility Objects
# -----------------------------
obj Warehouse(Facility) {}
obj Hospital(Facility) {}
obj Pharmacy(Facility) {}

# -----------------------------
# Interactive App Walker
# -----------------------------
walker SupplyChainApp {
    has warehouse:str;
    has hospital:str;
    has pharmacy:str;

    impl start() {
        print("Welcome to the Jac Supply Chain App (AI-powered)!");
        print("Type 'quit' to exit.");

        while True {
            print("\nChoose an action: (1) Stock Warehouse  (2) Ship to Hospital  (3) Ship to Pharmacy  (4) Dispense  (5) Show Inventories");
            action = input("> ");

            if action == "quit" {
                print("Goodbye!");
                break;
            }

            if action == "1" {
                print("Enter drug name:");
                drug = input("> ");
                print("Enter quantity:");
                qty = int(input("> "));
                self.warehouse.add(drug, qty);
                self.narrate("Added " + str(qty) + " units of " + drug + " to Warehouse.");
            }

            elif action == "2" {
                print("Enter drug name:");
                drug = input("> ");
                print("Enter quantity to ship to Hospital:");
                qty = int(input("> "));
                shipped = self.warehouse.remove(drug, qty);
                self.hospital.add(drug, shipped);
                self.narrate("Shipped " + str(shipped) + " units of " + drug + " to Hospital.");
            }

            elif action == "3" {
                print("Enter drug name:");
                drug = input("> ");
                print("Enter quantity to ship to Pharmacy:");
                qty = int(input("> "));
                shipped = self.hospital.remove(drug, qty);
                self.pharmacy.add(drug, shipped);
                self.narrate("Hospital shipped " + str(shipped) + " units of " + drug + " to Pharmacy.");
            }

            elif action == "4" {
                print("Enter drug name:");
                drug = input("> ");
                print("Enter quantity to dispense:");
                qty = int(input("> "));
                dispensed = self.pharmacy.remove(drug, qty);
                self.narrate("Pharmacy dispensed " + str(dispensed) + " units of " + drug + " to patients.");
            }

            elif action == "5" {
                inventories = (
                    "\n📦 Warehouse: " + str(self.warehouse.inventory) +
                    "\n🏥 Hospital: " + str(self.hospital.inventory) +
                    "\n💊 Pharmacy: " + str(self.pharmacy.inventory)
                );
                print(inventories);
            }

            else {
                print("Invalid choice, try again!");
            }
        }
    }

     impl narrate(msg) {
        prompt = "Provide a brief, professional narration for this supply chain event: " + msg;
        response = llm.generate(prompt);
        print("\n🤖 AI says: " + response);
    }
}

# -----------------------------
# Entry Point
# -----------------------------
with entry {
    print("🚀 Script starting...");
    
    w = Warehouse("Main Warehouse");
    h = Hospital("City Hospital");
    p = Pharmacy("Main Pharmacy");

    print("📦 Facilities created, spawning walker...");
    root spawn SupplyChainApp(warehouse=w, hospital=h, pharmacy=p);
    
    print("✅ Walker spawned");
}
# Intermediate version with basic interaction
walker interactive_test {
    with entry {
        print("Welcome to Supply Chain App!");
        print("Testing basic input...");
        
        name = input("Enter your name: ");
        print("Hello, " + name + "!");
        
        # Test AI narration
        prompt = "Say hello to " + name;
        response = llm.generate(prompt);
        print("AI: " + response);
    }
}

with entry {
    root spawn walker interactive_test();
}