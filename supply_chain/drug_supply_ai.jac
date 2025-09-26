

# -----------------------------
# Objects
# -----------------------------
obj Warehouse { has name: str; has inventory: dict; }
obj Hospital  { has name: str; has inventory: dict; }
obj Pharmacy  { has name: str; has inventory: dict; }

impl Warehouse.init {
    self.name = name;
    self.inventory = {};
}

impl Warehouse.stock_drugs(drug: str, qty: int) {
    self.inventory[drug] = self.inventory.get(drug, 0) + qty;
}

impl Hospital.init {
    self.name = name;
    self.inventory = {};
}

impl Hospital.receive_shipment(drug: str, qty: int) {
    self.inventory[drug] = self.inventory.get(drug, 0) + qty;
}

impl Pharmacy.init {
    self.name = name;
    self.inventory = {};
}

impl Pharmacy.dispense(drug: str, qty: int) {
    available = self.inventory.get(drug, 0);
    if qty > available {
        qty = available;
    }
    self.inventory[drug] -= qty;
}

# -----------------------------
# Nodes
# -----------------------------
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

    has w_qty: int;   # quantity to ship from warehouse
    has h_qty: int;   # quantity to ship from hospital
    has p_qty: int;   # quantity to dispense at pharmacy

    has narrations: list = [];

    can start_game with `root entry;
    can narrate with byllm;
}

impl SupplyChainGame.start_game {
    visit [--> self.w_turn];
}

# -----------------------------
# Node Logic
# -----------------------------
impl warehouse_turn.ship {
    visitor.warehouse.inventory[visitor.drug] -= visitor.w_qty;
    visitor.hospital.receive_shipment(visitor.drug, visitor.w_qty);

    visitor.narrate("The warehouse shipped " + str(visitor.w_qty) +
                    " units of " + visitor.drug +
                    ". Give resupply strategies if stock runs low.");

    visit [--> visitor.h_turn];
}

impl hospital_turn.ship {
    visitor.hospital.inventory[visitor.drug] -= visitor.h_qty;
    visitor.pharmacy.inventory[visitor.drug] = visitor.pharmacy.inventory.get(visitor.drug, 0) + visitor.h_qty;

    visitor.narrate("The hospital sent " + str(visitor.h_qty) +
                    " units to the pharmacy. Advise on balancing ward stock vs patient demand.");

    visit [--> visitor.p_turn];
}

impl pharmacy_turn.dispense {
    visitor.pharmacy.dispense(visitor.drug, visitor.p_qty);

    visitor.narrate("The pharmacy dispensed " + str(visitor.p_qty) +
                    " doses of " + visitor.drug +
                    " to patients. Suggest monitoring and replenishment strategies.");

    # Respond with inventories + narrations
    report = {
        "warehouse_stock": visitor.warehouse.inventory,
        "hospital_stock": visitor.hospital.inventory,
        "pharmacy_stock": visitor.pharmacy.inventory,
        "narrations": visitor.narrations,
    };
    return report;
    disengage;
}

# -----------------------------
# AI Narration
# -----------------------------
impl SupplyChainGame.narrate(msg: str) {
    response = llm_response(msg);   # byLLM hook
    self.narrations.append(response);
}

# -----------------------------
# Entry
# -----------------------------
with entry {
    w = Warehouse("Main Warehouse");
    h = Hospital("City Hospital");
    p = Pharmacy("Main Pharmacy");

    drug_name = "amox";
    w.stock_drugs(drug_name, 200);

    w_turn = warehouse_turn();
    h_turn = hospital_turn();
    p_turn = pharmacy_turn();

    SupplyChainGame(
        drug=drug_name,
        warehouse=w,
        hospital=h,
        pharmacy=p,
        w_turn=w_turn,
        h_turn=h_turn,
        p_turn=p_turn,
        w_qty=0,
        h_qty=0,
        p_qty=0
    ) spawn root;

    root ++> w_turn;
    w_turn ++> h_turn;
    h_turn ++> p_turn;
}
