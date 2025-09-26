"""Simple pharmacy/drug supply chain demo"""

import datetime
from typing import Dict, List


class Drug:
    def __init__(self, sku: str, name: str):
        self.sku = sku
        self.name = name

    def __repr__(self):
        return f"{self.name} ({self.sku})"


class Batch:
    def __init__(self, drug: Drug, batch_id: str, qty: int, expiry: datetime.date):
        self.drug = drug
        self.batch_id = batch_id
        self.qty = qty
        self.expiry = expiry

    def __repr__(self):
        return f"Batch {self.batch_id} of {self.drug} (qty={self.qty}, exp={self.expiry})"


class Location:
    def __init__(self, name: str):
        self.name = name
        self.inventory: Dict[str, List[Batch]] = {}  # drug.sku -> list of batches

    def add_batch(self, batch: Batch):
        if batch.drug.sku not in self.inventory:
            self.inventory[batch.drug.sku] = []
        self.inventory[batch.drug.sku].append(batch)

    def remove_stock(self, sku: str, qty: int) -> List[Batch]:
        """Dispense or ship from earliest expiry batches first."""
        if sku not in self.inventory:
            return []

        dispensed_batches = []
        remaining = qty

        # Sort by earliest expiry
        self.inventory[sku].sort(key=lambda b: b.expiry)

        for batch in self.inventory[sku]:
            if remaining <= 0:
                break
            taken = min(batch.qty, remaining)
            batch.qty -= taken
            remaining -= taken
            if taken > 0:
                dispensed_batches.append(Batch(batch.drug, batch.batch_id, taken, batch.expiry))

        # Remove empty batches
        self.inventory[sku] = [b for b in self.inventory[sku] if b.qty > 0]
        return dispensed_batches

    def show_inventory(self):
        print(f"\n📦 Inventory at {self.name}:")
        for batches in self.inventory.values():
            for batch in batches:
                print(f"  - {batch}")
                
                
class Warehouse(Location):
    def __init__(self, name: str):
        super().__init__(name)  # keep batch-aware inventory!

    def stock_batch(self, batch: Batch):
        self.add_batch(batch)   # use Location’s method
        print(f"Stocked {batch} at {self.name}")

    def create_shipment(self, hospital, sku: str, qty: int):
        shipment = self.remove_stock(sku, qty)
        print(f"🚚 Shipment prepared from {self.name}: {shipment}")
        hospital.receive_shipment(shipment)


class Hospital(Location):
    def __init__(self, name: str):
        super().__init__(name)

    def receive_shipment(self, shipment: List[Batch]):
        for batch in shipment:
            self.add_batch(batch)
        print(f"🏥 {self.name} inventory updated with shipment.")
        self.show_inventory()

    def create_shipment(self, pharmacy, sku: str, qty: int):
        shipment = self.remove_stock(sku, qty)
        print(f"📦 Shipment sent from {self.name} to {pharmacy.name}: {shipment}")
        pharmacy.receive_shipment(shipment)
        

class Pharmacy(Location):
    def __init__(self, name: str):
        super().__init__(name)

    def dispense(self, patient: str, sku: str, qty: int):
        dispensed_batches = self.remove_stock(sku, qty)
        if not dispensed_batches:
            print(f"❌ Not enough stock to dispense {qty} of {sku} to {patient}")
            return
        total_dispensed = sum(b.qty for b in dispensed_batches)
        print(f"💊 Dispensed {total_dispensed} of {sku} to {patient}:")
        for b in dispensed_batches:
            print(f"   - {b}")


# 🔹 Step 1 Demo
amox = Drug("AMOX500", 
"Amoxicillin 500mg")

warehouse = Warehouse("Central Warehouse")
hospital = Hospital("City Hospital")
pharmacy = Pharmacy("Main Pharmacy")

# Stock warehouse with 2 batches
warehouse.add_batch(Batch(amox, "B001", 100, datetime.date(2026, 1, 1)))
warehouse.add_batch(Batch(amox, "B002", 50, datetime.date(2025, 6, 1)))
warehouse.show_inventory()

# Ship 80 to hospital
shipment = warehouse.remove_stock("AMOX500", 80)
for b in shipment:
    hospital.add_batch(b)
warehouse.show_inventory()
hospital.show_inventory()

# Hospital ships 30 to pharmacy
shipment2 = hospital.remove_stock("AMOX500", 30)
for b in shipment2:
    pharmacy.add_batch(b)
hospital.show_inventory()
pharmacy.show_inventory()

# Pharmacy dispenses 10 to patient
pharmacy.dispense("Patient A", "AMOX500", 10)
pharmacy.show_inventory()

