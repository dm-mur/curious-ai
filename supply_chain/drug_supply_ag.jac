# supply_chain_graph.jac

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
# Node Archetypes
# -----------------------------
node root {}
node warehouse_turn { can ship with SupplyChain entry; }
node hospital_turn  { can ship with SupplyChain entry; }
node pharmacy_turn  { can dispense with SupplyChain entry; }

# -----------------------------
# Walker
# -----------------------------
walker SupplyChain {
    has drug: str;
    has warehouse: Warehouse;
    has hospital: Hospital;
    has pharmacy: Pharmacy;

    can start_game with `root entry;
}

# -----------------------------
# Implementations - Objects
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
# Walker abilities
# -----------------------------
impl SupplyChain.start_game {
    # walker starts at root
    visit [-->];   # moves to warehouse_turn
}

# -----------------------------
# Node abilities (graph traversal)
# -----------------------------
impl warehouse_turn.ship {
    qty = int(input("Warehouse: Enter quantity of " + walker.drug + " to ship: "));
    walker.warehouse.inventory[walker.drug] -= qty;
    walker.hospital.receive_shipment(walker.drug, qty);
    visit [-->];   # move to hospital_turn
}

impl hospital_turn.ship {
    qty = int(input("Hospital: Enter quantity of " + walker.drug + " to send to Pharmacy: "));
    walker.hospital.inventory[walker.drug] -= qty;
    walker.pharmacy.inventory[walker.drug] += qty;
    print("➡️ Sent to pharmacy:", {walker.drug: qty});
    visit [-->];   # move to pharmacy_turn
}

impl pharmacy_turn.dispense {
    qty = int(input("Pharmacy: Enter quantity of " + walker.drug + " to dispense: "));
    walker.pharmacy.dispense(walker.drug, qty);
    disengage;     # end of journey
}

# -----------------------------
# Entry
# -----------------------------
with entry {
    # create objects
    w = Warehouse("Main Warehouse");
    h = Hospital("City Hospital");
    p = Pharmacy("Main Pharmacy");

    drug_name = input("Enter drug name: ");
    qty_init = int(input("Enter initial quantity in warehouse: "));
    w.stock_drugs(drug_name, qty_init);

    # create graph nodes
    w_turn = warehouse_turn();
    h_turn = hospital_turn();
    p_turn = pharmacy_turn();

    root ++> w_turn;
    w_turn ++> h_turn;
    h_turn ++> p_turn;

    # launch walker
    SupplyChain(
        drug = drug_name,
        warehouse = w,
        hospital = h,
        pharmacy = p
    ) spawn root;
}
