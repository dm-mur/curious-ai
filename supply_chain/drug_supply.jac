# -------------------------
# Declarations (interfaces)
# -------------------------
obj Warehouse {
    has name: str;
    has inventory: dict;
    def init(name: str);
    def stock_drugs(drug: str, quantity: int);
    def create_shipment(hospital: Hospital, drugs: dict);
}

obj Hospital {
    has name: str;
    has inventory: dict;
    has shipments_received: list;
    def init(name: str);
    def receive_shipment(shipment: dict);
    def create_shipment(pharmacy: Pharmacy, drugs: dict);
}

obj Pharmacy {
    has name: str;
    has inventory: dict;
    has shipments_received: list;
    def init(name: str);
    def receive_shipment(shipment: dict);
    def dispense(drugs: dict);
}

# -------------------------
# Implementations (impl)
# -------------------------
impl Warehouse.init {
    self.name = name;
    self.inventory = {};
}

impl Warehouse.stock_drugs(drug: str, quantity: int) {
    self.inventory[drug] = self.inventory.get(drug, 0) + quantity;
    print("📦 Warehouse stocked:", self.inventory);
}

impl Warehouse.create_shipment(hospital: str, drugs: dict) {
    for (drug, qty) in drugs.items() {
        if self.inventory.get(drug, 0) < qty {
            print("❌ Insufficient stock for " + drug);
            return;
        }
    }
    for (drug, qty) in drugs.items() {
        self.inventory[drug] -= qty;
    }
    hospital.receive_shipment(drugs);
    print("✅ Shipment sent to " + hospital.name);
    print("🏭 Warehouse balance:", self.inventory);
}

impl Hospital.init {
    self.name = name;
    self.inventory = {};
    self.shipments_received = [];
}

impl Hospital.receive_shipment(shipment: dict) {
    for (drug, qty) in shipment.items() {
        self.inventory[drug] = self.inventory.get(drug, 0) + qty;
    }
    self.shipments_received.append(shipment);
    print("📦 Shipment received at " + self.name);
    print("🏥 Hospital balance:", self.inventory);
}

impl Hospital.create_shipment(pharmacy: Pharmacy, drugs: dict) {
    for (drug, qty) in drugs.items() {
        if self.inventory.get(drug, 0) < qty {
            print("❌ Insufficient stock for " + drug);
            return;
        }
    }
    for (drug, qty) in drugs.items() {
        self.inventory[drug] -= qty;
    }
    pharmacy.receive_shipment(drugs);
    print("✅ Shipment sent to " + pharmacy.name);
    print("🏥 Hospital balance:", self.inventory);
}

impl Pharmacy.init {
    self.name = name;
    self.inventory = {};
    self.shipments_received = [];
}

impl Pharmacy.receive_shipment(shipment: dict) {
    for (drug, qty) in shipment.items() {
        self.inventory[drug] = self.inventory.get(drug, 0) + qty;
    }
    self.shipments_received.append(shipment);
    print("📦 Shipment received at " + self.name);
    print("💊 Pharmacy balance:", self.inventory);
}

impl Pharmacy.dispense(drugs: dict) {
    for (drug, qty) in drugs.items() {
        if self.inventory.get(drug, 0) < qty {
            print("❌ Insufficient stock for " + drug);
            return;
        }
    }
    for (drug, qty) in drugs.items() {
        self.inventory[drug] -= qty;
    }
    print("💊 Dispensed drugs:", drugs, "from " + self.name);
    print("💊 Pharmacy balance:", self.inventory);
}

# -----------------------------
# Flow Simulation (entry)
# -----------------------------
with entry {
    warehouse = Warehouse("Main Warehouse");
    hospital  = Hospital("City Hospital");
    pharmacy  = Pharmacy("Main Pharmacy");

    # Step 1: Stock warehouse
    warehouse.stock_drugs("AMOX500", 100);

    # Step 2: Warehouse ships to Hospital
    warehouse.create_shipment(hospital, {"AMOX500": 50});

    # Step 3: Hospital ships to Pharmacy
    hospital.create_shipment(pharmacy, {"AMOX500": 30});

    # Step 4: Pharmacy dispenses to patient
    pharmacy.dispense({"AMOX500": 10});
}
