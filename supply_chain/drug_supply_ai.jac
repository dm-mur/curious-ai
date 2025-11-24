import from byllm { Model }

glob llm = Model(model_name="gemini/gemini-2.0-flash", verbose=True);

# helper function to call LLM
def byllm(msg: str) -> str {
    return llm.call(msg);
}

# -----------------------------
# Objects
# -----------------------------
obj Warehouse {
    has name: str;
    has inventory: dict;

    def init(name: str) {
        self.name = name;
        self.inventory = {};
    }

    def stock_drugs(drug: str, qty: int) {
        self.inventory[drug] = self.inventory.get(drug, 0) + qty;
        print("📦 Warehouse stocked:", self.inventory);
    }

    def ship_to_hospital(drug: str, qty: int, hospital: Hospital) {
        available = self.inventory.get(drug, 0);
        if qty > available {
            print("⚠️ Warehouse has only", available, " — shipping available amount.");
            qty = available;
        }
        self.inventory[drug] = self.inventory.get(drug, 0) - qty;
        hospital.receive_shipment(drug, qty);
        print("🚚 Warehouse shipped:", {drug: qty});
    }
}

obj Hospital {
    has name: str;
    has inventory: dict;

    def init(name: str) {
        self.name = name;
        self.inventory = {};
    }

    def receive_shipment(drug: str, qty: int) {
        self.inventory[drug] = self.inventory.get(drug, 0) + qty;
        print("🏥 Hospital received shipment:", {drug: qty});
    }

    def send_to_pharmacy(drug: str, qty: int, pharmacy: Pharmacy) {
        available = self.inventory.get(drug, 0);
        if qty > available {
            print("⚠️ Hospital has only", available, " — sending available amount.");
            qty = available;
        }
        self.inventory[drug] = self.inventory.get(drug, 0) - qty;
        pharmacy.inventory[drug] = pharmacy.inventory.get(drug, 0) + qty;
        print("➡️ Hospital sent to pharmacy:", {drug: qty});
    }
}

obj Pharmacy {
    has name: str;
    has inventory: dict;

    def init(name: str) {
        self.name = name;
        self.inventory = {};
    }

    def dispense(drug: str, qty: int) {
        available = self.inventory.get(drug, 0);
        if qty > available {
            print("⚠️ Not enough stock, dispensing max available:", available);
            qty = available;
        }
        self.inventory[drug] = self.inventory.get(drug, 0) - qty;
        print("💊 Dispensed to patient:", {drug: qty});
    }
}

# -----------------------------
# Nodes
# -----------------------------
node root {}

node warehouse_turn {}
node hospital_turn {}
node pharmacy_turn {}

# -----------------------------
# Walker
# -----------------------------
# -----------------------------
# Walker
# -----------------------------
walker SupplyChain {
    has drug: str;
    has warehouse: Warehouse;
    has hospital: Hospital;
    has pharmacy: Pharmacy;

    can start_dispense;
    can warehouse_action;
    can hospital_action;
    can pharmacy_action;
}

# -----------------------------
# Walker abilities (impl)
# -----------------------------
impl SupplyChain.start_dispense {
    visit [-->];   # root -> warehouse_turn
}

impl SupplyChain.warehouse_action {
    msg = "The warehouse has " + str(self.warehouse.inventory.get(self.drug, 0)) +
          " units of " + self.drug + ". How many should be shipped to the hospital?";
    suggestion = byllm(msg);
    qty = int(suggestion) if suggestion.isdigit() else 0;
    self.warehouse.ship_to_hospital(self.drug, qty, self.hospital);
    visit [-->];   # go to hospital_turn
}

impl SupplyChain.hospital_action {
    msg = "The hospital has " + str(self.hospital.inventory.get(self.drug, 0)) +
          " units of " + self.drug + ". How many should be sent to the pharmacy?";
    suggestion = byllm(msg);
    qty = int(suggestion) if suggestion.isdigit() else 0;
    self.hospital.send_to_pharmacy(self.drug, qty, self.pharmacy);
    visit [-->];   # go to pharmacy_turn
}

impl SupplyChain.pharmacy_action {
    msg = "The pharmacy has " + str(self.pharmacy.inventory.get(self.drug, 0)) +
          " units of " + self.drug + ". How many should be dispensed to patients?";
    suggestion = byllm(msg);
    qty = int(suggestion) if suggestion.isdigit() else 0;
    self.pharmacy.dispense(self.drug, qty);
    disengage;
}

# -----------------------------
# Entry
# -----------------------------
with entry {
    w = Warehouse("Main Warehouse");
    h = Hospital("City Hospital");
    p = Pharmacy("Main Pharmacy");

    drug_name = input("Enter drug name: ");
    qty_init = int(input("Enter initial quantity in warehouse: "));
    w.stock_drugs(drug_name, qty_init);

    w_turn = warehouse_turn();
    h_turn = hospital_turn();
    p_turn = pharmacy_turn();

    root ++> w_turn;
    w_turn ++> h_turn;
    h_turn ++> p_turn;

    SupplyChain(
        drug = drug_name,
        warehouse = w,
        hospital = h,
        pharmacy = p
    ) spawn root;
}
