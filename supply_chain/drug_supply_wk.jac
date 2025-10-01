# supply_chain_simple.jac
# -----------------------------
# Objects
# -----------------------------
obj Warehouse {
    has name: str;
    has inventory: dict;
    def init(name: str);
    def stock_drugs(drug: str, qty: int);
}

obj Hospital {
    has name: str;
    has inventory: dict;
    def init(name: str);
    def receive_shipment(drug: str, qty: int);
}

obj Pharmacy {
    has name: str;
    has inventory: dict;
    def init(name: str);
    def dispense(drug: str, qty: int);
}

# -----------------------------
# Implementations - objects
# -----------------------------
impl Warehouse.init {
    self.name = name;
    self.inventory = {};
}

impl Warehouse.stock_drugs {
    self.inventory[drug] = self.inventory.get(drug, 0) + qty;
    print("📦 Warehouse stocked:", self.inventory);
}

impl Hospital.init {
    self.name = name;
    self.inventory = {};
}

impl Hospital.receive_shipment {
    self.inventory[drug] = self.inventory.get(drug, 0) + qty;
    print("🏥 Hospital received shipment:", {drug: qty});
}

impl Pharmacy.init {
    self.name = name;
    self.inventory = {};
}

impl Pharmacy.dispense {
    available = self.inventory.get(drug, 0);
    if qty > available {
        print("⚠️ Not enough stock, dispensing max available:", available);
        qty = available;
    }
    self.inventory[drug] = self.inventory.get(drug, 0) - qty;
    print("💊 Dispensed to patient:", {drug: qty});
}

# -----------------------------
# Simple interactive flow in entry (no walkers/nodes)
# -----------------------------
with entry {
    # Create objects
    w = Warehouse("Main Warehouse");
    h = Hospital("City Hospital");
    p = Pharmacy("Main Pharmacy");

    # Setup initial stock
    drug_name = input("Enter drug name: ");
    qty_init = int(input("Enter initial quantity in warehouse: "));
    w.stock_drugs(drug_name, qty_init);

    # Warehouse -> Hospital
    qty_ship = int(input("Warehouse: Enter quantity of " + drug_name + " to ship to hospital: "));
    available_w = w.inventory.get(drug_name, 0);
    if qty_ship > available_w {
        print("⚠️ Warehouse has only", available_w, " — shipping available amount.");
        qty_ship = available_w;
    }
    w.inventory[drug_name] = w.inventory.get(drug_name, 0) - qty_ship;
    h.receive_shipment(drug_name, qty_ship);

    # Hospital -> Pharmacy
    qty_to_pharmacy = int(input("Hospital: Enter quantity of " + drug_name + " to send to Pharmacy: "));
    available_h = h.inventory.get(drug_name, 0);
    if qty_to_pharmacy > available_h {
        print("⚠️ Hospital has only", available_h, " — sending available amount.");
        qty_to_pharmacy = available_h;
    }
    h.inventory[drug_name] = h.inventory.get(drug_name, 0) - qty_to_pharmacy;
    p.inventory[drug_name] = p.inventory.get(drug_name, 0) + qty_to_pharmacy;
    print("➡️ Sent to pharmacy:", {drug_name: qty_to_pharmacy});

    # Pharmacy -> Patient
    qty_dispense = int(input("Pharmacy: Enter quantity of " + drug_name + " to dispense to patient: "));
    p.dispense(drug_name, qty_dispense);

    print("Final inventories:");
    print("Warehouse:", w.inventory);
    print("Hospital:", h.inventory);
    print("Pharmacy:", p.inventory);
}
