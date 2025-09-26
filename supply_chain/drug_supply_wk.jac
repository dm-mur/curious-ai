# -----------------------------
# Supply Chain Graph (Step 4)
# -----------------------------

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
# Nodes
# -----------------------------
node root {}

node warehouse_turn { can ship with SupplyChainGame entry; }
node hospital_turn  { can ship with SupplyChainGame entry; }
node pharmacy_turn  { can dispense with SupplyChainGame entry; }

# -----------------------------
# Walker
# -----------------------------
walker SupplyChainGame {
    has drug: str;
    has warehouse: Warehouse;
    has hospital: Hospital;
    has pharmacy: Pharmacy;

    has w_turn: warehouse_turn;
    has h_turn: hospital_turn;
    has p_turn: pharmacy_turn;

    can start_game with `root entry;
}

# -----------------------------
# Implementations
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
    self.inventory[drug] -= qty;
    print("💊 Dispensed to patient:", {drug: qty});
}

# -----------------------------
# Walker abilities
# -----------------------------
impl SupplyChainGame.start_game {
    visit [--> self.w_turn.ship];
}

impl warehouse_turn.ship {
    qty = int(input("Warehouse: Enter quantity of " + visitor.drug + " to ship: "));
    visitor.warehouse.inventory[visitor.drug] -= qty;
    visitor.hospital.receive_shipment(visitor.drug, qty);
    #visit [--> visitor.h_turn];
     # Visit hospital_turn AND call the 'ship' ability immediately
    visit [--> visitor.h_turn.ship];
}

impl hospital_turn.ship {
    qty = int(input("Hospital: Enter quantity of " + visitor.drug + " to send to Pharmacy: "));
    visitor.hospital.inventory[visitor.drug] -= qty;
    visitor.pharmacy.inventory[visitor.drug] = visitor.pharmacy.inventory.get(visitor.drug, 0) + qty;
    #visit [--> visitor.p_turn];
     # Visit pharmacy_turn AND call 'dispense'
    visit [--> visitor.p_turn.dispense];
}

impl pharmacy_turn.dispense {
    qty = int(input("Pharmacy: Enter quantity of " + visitor.drug + " to dispense to patient: "));
    visitor.pharmacy.dispense(visitor.drug, qty);
    disengage;
}

# -----------------------------
# Entry
# -----------------------------
with entry {
    # Create objects
    w = Warehouse("Main Warehouse");
    h = Hospital("City Hospital");
    p = Pharmacy("Main Pharmacy");

    drug_name = input("Enter drug name: ");
    qty = int(input("Enter initial quantity in warehouse: "));
    w.stock_drugs(drug_name, qty);

    # Spawn nodes
    w_turn = warehouse_turn();
    h_turn = hospital_turn();
    p_turn = pharmacy_turn();

    # Spawn walker with node references
    SupplyChainGame(
    drug=drug_name,
    warehouse=w,
    hospital=h,
    pharmacy=p,
    w_turn=warehouse_turn(),
    h_turn=hospital_turn(),
    p_turn=pharmacy_turn()
    ) spawn root; 


    # Connect nodes
    root ++> w_turn;
    w_turn ++> h_turn;
    h_turn ++> p_turn;
}
