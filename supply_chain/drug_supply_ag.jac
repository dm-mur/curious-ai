"""Supply Chain Game – Scale Agnostic"""

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
# Implementations
# -----------------------------
impl Warehouse.init {
    self.name = name;
    self.inventory = {};
}

impl Warehouse.stock_drugs(drug: str, qty: int) {
    self.inventory[drug] = self.inventory.get(drug, 0) + qty;
    print("📦 Warehouse stocked:", self.inventory);
}

impl Hospital.init {
    self.name = name;
    self.inventory = {};
}

impl Hospital.receive_shipment(drug: str, qty: int) {
    self.inventory[drug] = self.inventory.get(drug, 0) + qty;
    print("🏥 Hospital received shipment:", {drug: qty});
}

impl Pharmacy.init {
    self.name = name;
    self.inventory = {};
}

impl Pharmacy.dispense(drug: str, qty: int) {
    available = self.inventory.get(drug, 0);
    if qty > available {
        print("⚠️ Not enough stock, dispensing max available:", available);
        qty = available;
    }
    self.inventory[drug] -= qty;
    print("💊 Dispensed to patient:", {drug: qty});
}

# -----------------------------
# Nodes
# -----------------------------
node warehouse_turn {
    has drug: str;
    has qty: int;
}

node hospital_turn {
    has drug: str;
    has qty: int;
}

node pharmacy_turn {
    has drug: str;
    has qty: int;
}

# -----------------------------
# Walker
# -----------------------------
walker SupplyChainGame {
    has drug: str;
    has quantity: int;

    has warehouse: Warehouse;
    has hospital: Hospital;
    has pharmacy: Pharmacy;

    can start with `root entry;          # API + CLI start
    can process_warehouse with warehouse_turn entry;
    can process_hospital with hospital_turn entry;
    can process_pharmacy with pharmacy_turn entry;
}

# -----------------------------
# Walker Logic
# -----------------------------
impl SupplyChainGame.start {
    # Spawn nodes if missing
    if not [root --> (`?warehouse_turn)] {
        wnode = root ++> warehouse_turn(drug=self.drug, qty=self.quantity);
    } else {
        wnode = [root --> (`?warehouse_turn)];
    }
    visit wnode;
}

impl SupplyChainGame.process_warehouse {
    # stock + ship to hospital
    self.warehouse.stock_drugs(here.drug, here.qty);
    self.warehouse.inventory[here.drug] -= here.qty;
    self.hospital.receive_shipment(here.drug, here.qty);

    # move to hospital_turn
    hnode = root ++> hospital_turn(drug=here.drug, qty=here.qty);
    visit hnode;
}

impl SupplyChainGame.process_hospital {
    # ship hospital stock to pharmacy
    self.hospital.inventory[here.drug] -= here.qty;
    self.pharmacy.inventory[here.drug] = self.pharmacy.inventory.get(here.drug, 0) + here.qty;

    # move to pharmacy_turn
    pnode = root ++> pharmacy_turn(drug=here.drug, qty=here.qty);
    visit pnode;
}

impl SupplyChainGame.process_pharmacy {
    # dispense half of stock
    self.pharmacy.dispense(here.drug, int(here.qty / 2));

    print("✅ Supply chain complete!");
    disengage;
}

# -----------------------------
# CLI Mode
# -----------------------------
with entry:__main__ {
    w = Warehouse("Main Warehouse");
    h = Hospital("City Hospital");
    p = Pharmacy("Main Pharmacy");

    # run multiple walkers for demo
    root spawn SupplyChainGame("amox", 200, w, h, p);
    root spawn SupplyChainGame("paracetamol", 300, w, h, p);
}
