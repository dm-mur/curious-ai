

import from byllm {Model}

glob llm = Model(
    model_name="gemini/gemini-2.5-flash",
    api_key="MY_API_KEY" # Replace with your actual API key
);

node Warehouse {}

node Drug(Warehouse) {
    has available: bool = True;

    can check with StoreManager entry{
        visitor.gear["drugs_available"] = self.available;

    }
}

node BinCard(Warehouse) {
    has drugs: str = "aspirin, ibuprofen, paracetamol";
    
    can check with StoreManager entry{
        visitor.gear["bin_card_list"] = self.drugs;
    }
}

node Pharmacist{
    can plan with StoreManager entry{
        visitor.gear["dispense_plan"] = visitor.create_dispense_plan(visitor.gear);
    }
}

walker StoreManager {
    has gear: dict = {};

    can start with `root entry {
        visit [-->(`?Warehouse)];
    }
    """Create a drug dispensing plan based on availan=ble drugs and stock levels."""
    def create_dispense_plan(gear: dict) -> str by llm();
}

walker ClinicianWalker(StoreManager) {
    can get_plan with `root entry {
        visit [-->(`?Pharmacist)];
        self.start;
        self.get_plan;
    }
}

with entry {
    root ++> Drug();
    root ++> BinCard();
    root ++> Pharmacist();

    agent = ClinicianWalker() spawn root;

     # Run the walker abilities
    agent.start;      # collect info from Warehouse nodes
    agent.get_plan;   # visit Pharmacist and create plan

    print("My Dispense Plan:");
    print (agent.gear['dispense_plan']);
}