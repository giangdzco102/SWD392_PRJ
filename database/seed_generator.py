"""
AutoCare – sample data generator (whole project).
Produces 02_seed.sql that fills all 44 tables with consistent, realistic data.
Run:  python seed_generator.py   (standard library only)

All demo accounts use password:  Password@123
"""
from datetime import datetime, timedelta, date
from collections import defaultdict
import os

HASH = "$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76"  # bcrypt('Password@123')
TZ = "+07"
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "02_seed.sql")

rows = defaultdict(list)          # table -> list of dict
IDENTITY = set()                  # tables whose PK is an identity column
seq = defaultdict(int)

def nid(table):
    seq[table] += 1
    return seq[table]

def add(table, identity=True, **kw):
    if identity:
        IDENTITY.add(table)
    rows[table].append(kw)
    return kw

def ts(d, h=8, m=0):
    if isinstance(d, str):
        d = datetime.strptime(d, "%Y-%m-%d")
    return f"{d.strftime('%Y-%m-%d')} {h:02d}:{m:02d}:00{TZ}"

def tsx(dt):
    return dt.strftime("%Y-%m-%d %H:%M:00") + TZ

# ------------------------------------------------------------------ roles (seeded by 01_schema.sql)
ROLE = dict(CUSTOMER=1, RECEPTIONIST=2, MECHANIC=3, CASHIER=4, BRANCH_MANAGER=5, SYS_ADMIN=6)

# ------------------------------------------------------------------ branches
BRANCHES = [
    (1, "HN-CG01", "AutoCare Cầu Giấy", "123 Trần Duy Hưng, Cầu Giấy, Hà Nội", "024 3999 1111", "caugiay@autocare.vn", "cg"),
    (2, "HN-HD01", "AutoCare Hà Đông", "45 Quang Trung, Hà Đông, Hà Nội", "024 3999 2222", "hadong@autocare.vn", "hd"),
    (3, "HCM-Q701", "AutoCare Quận 7", "88 Nguyễn Thị Thập, Quận 7, TP.HCM", "028 3999 3333", "quan7@autocare.vn", "q7"),
]
for bid, code, name, addr, phone, email, _ in BRANCHES:
    add("branches", branch_id=nid("branches"), branch_code=code, branch_name=name, address=addr, phone=phone, email=email,
        status="ACTIVE", created_at=ts("2026-01-05"), updated_at=ts("2026-01-05"))

# ------------------------------------------------------------------ staff users
STAFF_NAMES = {
    1: ["Phạm Minh Quân", "Lê Thu Hà", "Nguyễn Hoàng Nam", "Trần Bảo Ngọc", "Đỗ Văn Hùng", "Vũ Đức Thắng", "Bùi Quốc Khánh"],
    2: ["Hoàng Thị Lan", "Ngô Quang Huy", "Đặng Mai Anh", "Phan Thanh Tùng", "Trịnh Văn Long", "Lý Minh Tuấn", "Mai Xuân Phúc"],
    3: ["Võ Thị Hồng", "Huỳnh Gia Bảo", "Châu Ngọc Trâm", "Dương Minh Khoa", "Tạ Văn Lộc", "La Hoàng Sơn", "Kiều Anh Dũng"],
}
POSITIONS = [("BRANCH_MANAGER", "manager"), ("RECEPTIONIST", "reception1"), ("RECEPTIONIST", "reception2"),
             ("CASHIER", "cashier"), ("MECHANIC", "mechanic1"), ("MECHANIC", "mechanic2"), ("MECHANIC", "mechanic3")]
STAFF = {}   # (branch, key) -> staff_id

def add_user(email, phone, name, role, created="2026-01-06"):
    uid = nid("users")
    add("users", user_id=uid, role_id=ROLE[role], email=email, phone=phone, password_hash=HASH, full_name=name, status="ACTIVE",
        failed_login_count=0, locked_until=None, last_login_at=ts("2026-11-07", 17, 30), created_at=ts(created), updated_at=ts(created))
    return uid

uid = add_user("admin@autocare.vn", "0900000001", "Nguyễn Trường Giang", "SYS_ADMIN")
sid = nid("staff")
add("staff", staff_id=sid, user_id=uid, branch_id=None, staff_code="NV0001", position="SYS_ADMIN", hired_date="2026-01-01", status="ACTIVE", created_at=ts("2026-01-06"))
STAFF[(0, "admin")] = sid
for bid, code, name, addr, phone, email, short in BRANCHES:
    for i, (pos, key) in enumerate(POSITIONS):
        uid = add_user(f"{key}.{short}@autocare.vn", f"09{bid}{i:02d}0000{bid}"[:10], STAFF_NAMES[bid][i], pos)
        sid = nid("staff")
        add("staff", staff_id=sid, user_id=uid, branch_id=bid, staff_code=f"NV{sid:04d}", position=pos, hired_date="2026-01-01",
            status="ACTIVE", created_at=ts("2026-01-06"))
        STAFF[(bid, key)] = sid
def S(b, k): return STAFF[(b, k)]

# ------------------------------------------------------------------ customers
CUSTOMERS = [
    ("Nguyễn Văn An", "0912000001", "MALE", "12 Láng Hạ, Đống Đa, Hà Nội"),
    ("Trần Thị Bình", "0912000002", "FEMALE", "56 Kim Mã, Ba Đình, Hà Nội"),
    ("Lê Hoàng Cường", "0912000003", "MALE", "8 Xuân Thủy, Cầu Giấy, Hà Nội"),
    ("Phạm Thu Dung", "0912000004", "FEMALE", "102 Nguyễn Trãi, Thanh Xuân, Hà Nội"),
    ("Hoàng Minh Đức", "0912000005", "MALE", "21 Hoàng Quốc Việt, Cầu Giấy, Hà Nội"),
    ("Vũ Thị Giang", "0912000006", "FEMALE", "77 Lê Văn Lương, Thanh Xuân, Hà Nội"),
    ("Đặng Quốc Huy", "0912000007", "MALE", "15 Quang Trung, Hà Đông, Hà Nội"),
    ("Bùi Thanh Hương", "0912000008", "FEMALE", "40 Trần Phú, Hà Đông, Hà Nội"),
    ("Ngô Đức Khải", "0912000009", "MALE", "9 Duy Tân, Cầu Giấy, Hà Nội"),
    ("Đỗ Thị Lan", "0912000010", "FEMALE", "200 Nguyễn Văn Linh, Quận 7, TP.HCM"),
    ("Phan Văn Minh", "0912000011", "MALE", "31 Phạm Hùng, Nam Từ Liêm, Hà Nội"),
    ("Trịnh Ngọc Oanh", "0912000012", "FEMALE", "66 Mễ Trì, Nam Từ Liêm, Hà Nội"),
]
CUST = {}
for i, (name, phone, gender, addr) in enumerate(CUSTOMERS, 1):
    uid = add_user(f"customer{i}@gmail.com", phone, name, "CUSTOMER", created="2026-02-01")
    cid = nid("customers")
    add("customers", customer_id=cid, user_id=uid, date_of_birth=f"19{85 + i % 12}-0{1 + i % 9}-1{i % 9}", gender=gender, address=addr, created_at=ts("2026-02-01"))
    CUST[i] = cid

BILL = {}
for c, btype, bname, comp, tax, addr in [
    (1, "INDIVIDUAL", "Nguyễn Văn An", None, None, "12 Láng Hạ, Đống Đa, Hà Nội"),
    (2, "COMPANY", "Trần Thị Bình", "Công ty TNHH Bình An", "0101234567", "56 Kim Mã, Ba Đình, Hà Nội"),
    (3, "INDIVIDUAL", "Lê Hoàng Cường", None, None, "8 Xuân Thủy, Cầu Giấy, Hà Nội"),
    (6, "COMPANY", "Vũ Thị Giang", "Công ty CP Vận tải Giang Sơn", "0109876543", "77 Lê Văn Lương, Thanh Xuân, Hà Nội"),
    (7, "INDIVIDUAL", "Đặng Quốc Huy", None, None, "15 Quang Trung, Hà Đông, Hà Nội"),
    (10, "INDIVIDUAL", "Đỗ Thị Lan", None, None, "200 Nguyễn Văn Linh, Quận 7, TP.HCM"),
]:
    bid_ = nid("billing_information")
    add("billing_information", billing_id=bid_, customer_id=CUST[c], buyer_type=btype, buyer_name=bname, company_name=comp, tax_code=tax,
        billing_address=addr, invoice_email=f"customer{c}@gmail.com", is_default=True, created_at=ts("2026-02-02"), updated_at=ts("2026-02-02"))
    BILL[c] = bid_

# ------------------------------------------------------------------ vehicles
VEH = [  # (customer, plate, type, brand, model, year, odo)
    (1, "30A-123.45", "CAR", "Toyota", "Vios 1.5G", 2020, 45200), (2, "30G-456.78", "CAR", "Honda", "City RS", 2022, 21800),
    (1, "29B1-234.56", "MOTORCYCLE", "Honda", "Wave Alpha", 2019, 30500), (3, "30E-987.65", "CAR", "Mazda", "Mazda3 1.5", 2021, 38700),
    (4, "30F-111.22", "CAR", "Kia", "Morning", 2018, 72100), (5, "30H-222.33", "CAR", "Hyundai", "Accent 1.4AT", 2021, 40100),
    (6, "29C-345.67", "CAR", "Ford", "Ranger XLS", 2020, 88400), (6, "29C-345.68", "CAR", "Ford", "Transit", 2019, 120300),
    (7, "29D-456.12", "CAR", "Toyota", "Innova 2.0E", 2019, 95000), (8, "30K-567.89", "CAR", "Mitsubishi", "Xpander AT", 2022, 26500),
    (9, "30L-678.90", "CAR", "VinFast", "Fadil", 2021, 33300), (10, "51G-789.01", "CAR", "Toyota", "Corolla Cross", 2023, 15800),
    (10, "59X1-890.12", "MOTORCYCLE", "Yamaha", "Exciter 155", 2022, 18200), (11, "30M-901.23", "CAR", "Toyota", "Innova Cross", 2023, 12400),
    (12, "30N-012.34", "CAR", "Honda", "CR-V L", 2022, 30900), (12, "29E1-135.79", "MOTORCYCLE", "Honda", "Air Blade", 2021, 22000),
    (8, "29F-246.80", "CAR", "Kia", "Seltos", 2023, 9800), (3, "29G-112.23", "CAR", "Suzuki", "XL7", 2022, 41000),
    (2, "30G-789.12", "CAR", "Toyota", "Camry 2.5Q", 2021, 52000), (5, "30H-345.21", "CAR", "Honda", "Civic RS", 2022, 28000),
    (9, "29A-654.32", "CAR", "Mazda", "CX-5 2.0", 2020, 61000), (11, "29H1-777.88", "MOTORCYCLE", "Honda", "SH 150i", 2023, 8000),
    (4, "30E-246.13", "CAR", "Hyundai", "Tucson 2.0", 2022, 35500),
    (6, "30K-135.79", "CAR", "Toyota", "Fortuner 2.7", 2021, 58000), (12, "30L-864.20", "CAR", "Kia", "Carnival", 2022, 31000),
    (3, "30M-555.66", "CAR", "Ford", "Everest", 2020, 76000), (8, "30A-246.80", "CAR", "Honda", "HR-V", 2023, 12000),
    (11, "30F-777.12", "CAR", "Mazda", "CX-3", 2022, 20000),
]
VEHICLE = {}
for i, (c, plate, vt, brand, model, year, odo) in enumerate(VEH, 1):
    vid = nid("vehicles")
    add("vehicles", vehicle_id=vid, customer_id=CUST[c], license_plate=plate, vehicle_type=vt, brand=brand, model=model, manufacture_year=year,
        vin=None, color=["Trắng", "Đen", "Bạc", "Đỏ", "Xanh"][i % 5], current_odometer=odo, status="ACTIVE",
        created_at=ts("2026-02-03"), updated_at=ts("2026-02-03"))
    VEHICLE[i] = dict(id=vid, cust=c, odo=odo)

# ------------------------------------------------------------------ services & catalog
SERVICES = [
    ("SV-OIL", "Thay dầu động cơ", "Xả dầu cũ, thay dầu mới và lọc dầu", "ALL", 350000, 30),
    ("SV-BRAKE", "Kiểm tra & thay má phanh", "Kiểm tra hệ thống phanh, thay má phanh, xả gió dầu phanh", "CAR", 250000, 60),
    ("SV-MAINT10", "Bảo dưỡng định kỳ 10.000 km", "Gói bảo dưỡng tổng quát theo khuyến cáo hãng", "CAR", 900000, 120),
    ("SV-AC", "Vệ sinh & nạp gas điều hòa", "Vệ sinh dàn lạnh, kiểm tra rò rỉ và nạp gas", "CAR", 600000, 90),
    ("SV-TIRE", "Đảo lốp & cân bằng động", "Đảo lốp, cân bằng động và kiểm tra áp suất", "CAR", 300000, 45),
    ("SV-BATT", "Kiểm tra & thay ắc quy", "Đo điện áp, kiểm tra máy phát và thay ắc quy", "ALL", 150000, 30),
    ("SV-ENGINE", "Chẩn đoán động cơ", "Đọc lỗi OBD, kiểm tra bugi, kim phun", "CAR", 400000, 60),
    ("SV-SUSP", "Kiểm tra hệ thống treo", "Kiểm tra giảm xóc, rotuyn, cao su chân máy", "CAR", 350000, 60),
    ("SV-MOTO-MAINT", "Bảo dưỡng xe máy", "Thay nhớt, vệ sinh nồi, kiểm tra xích và bugi", "MOTORCYCLE", 200000, 45),
    ("SV-WASH", "Rửa xe & vệ sinh nội thất", "Rửa bọt tuyết, hút bụi, lau nội thất", "ALL", 150000, 40),
]
SV = {}
for code, name, desc, vt, price, mins in SERVICES:
    sid_ = nid("services")
    add("services", service_id=sid_, service_code=code, service_name=name, description=desc, vehicle_type=vt, base_price=price,
        estimated_minutes=mins, status="ACTIVE", created_at=ts("2026-01-05"), updated_at=ts("2026-01-05"))
    SV[code] = dict(id=sid_, name=name, price=price)
for b in (1, 2, 3):
    for code in SV:
        add("branch_services", identity=False, branch_id=b, service_id=SV[code]["id"], is_enabled=True, branch_price=None, updated_at=ts("2026-01-05"))

PARTS = [
    ("OIL-5W30-1L", "Dầu động cơ 5W-30 (1L)", "Dầu nhớt", "liter", 180000),
    ("FLT-OIL", "Lọc dầu động cơ", "Lọc", "pcs", 120000),
    ("FLT-AIR", "Lọc gió động cơ", "Lọc", "pcs", 250000),
    ("FLT-CABIN", "Lọc gió điều hòa", "Lọc", "pcs", 220000),
    ("BRK-PAD-FR", "Má phanh trước (bộ)", "Phanh", "set", 850000),
    ("BRK-DISC-FR", "Đĩa phanh trước", "Phanh", "pcs", 1200000),
    ("BRK-FLUID-DOT4", "Dầu phanh DOT4 (0.5L)", "Phanh", "pcs", 150000),
    ("BAT-12V-45AH", "Ắc quy 12V 45Ah", "Điện", "pcs", 1650000),
    ("AC-GAS-R134A", "Gas điều hòa R134a (bình)", "Điều hòa", "pcs", 450000),
    ("SPK-PLUG-IR", "Bugi Iridium", "Đánh lửa", "pcs", 280000),
    ("SHOCK-FR", "Giảm xóc trước", "Treo", "pcs", 1900000),
    ("TIRE-185-60R15", "Lốp 185/60R15", "Lốp", "pcs", 1450000),
    ("WIPER-24", "Gạt mưa 24 inch", "Phụ kiện", "pcs", 180000),
    ("COOLANT-1L", "Nước làm mát (1L)", "Dung dịch", "liter", 120000),
    ("BELT-ALT", "Dây curoa máy phát", "Động cơ", "pcs", 520000),
    ("MOTO-OIL-08L", "Dầu nhớt xe máy 0.8L", "Dầu nhớt", "pcs", 110000),
    ("MOTO-SPK", "Bugi xe máy", "Đánh lửa", "pcs", 60000),
    ("MOTO-CHAIN", "Bộ nhông xích xe máy", "Truyền động", "set", 650000),
    ("BULB-H4", "Bóng đèn pha H4", "Điện", "pcs", 160000),
    ("TRANS-OIL-1L", "Dầu hộp số (1L)", "Dầu nhớt", "liter", 230000),
]
PT = {}
for sku, name, cat, unit, price in PARTS:
    pid = nid("parts")
    add("parts", part_id=pid, sku=sku, part_name=name, category=cat, unit=unit, unit_price=price, status="ACTIVE",
        created_at=ts("2026-01-05"), updated_at=ts("2026-01-05"))
    PT[sku] = dict(id=pid, name=name, price=price)

for t, code, name, sla, desc in [(1, "MAINTENANCE", "Bảo dưỡng", 4, "Bảo dưỡng định kỳ"), (2, "REPAIR", "Sửa chữa", 24, "Sửa chữa thông thường"),
                                 (3, "BREAKDOWN", "Cứu hộ / hỏng hóc", 48, "Xe hỏng phải kéo về xưởng"), (4, "WARRANTY", "Bảo hành", 24, "Sửa chữa bảo hành")]:
    add("repair_order_types", type_id=nid("repair_order_types"), type_code=code, type_name=name, sla_hours=sla, description=desc)

# ------------------------------------------------------------------ inventory: warehouses, receipts, ledger events
INV = {}            # (branch, sku) -> inventory_id
EVENTS = []         # (datetime, branch, sku, type, qty, ref_type, ref_id, staff)
for b in (1, 2, 3):
    wid = nid("warehouses")
    add("warehouses", warehouse_id=wid, branch_id=b, warehouse_name="Kho phụ tùng chính", location="Tầng 1, khu B", status="ACTIVE")
    for sku in PT:
        iid = nid("inventories")
        INV[(b, sku)] = iid
        add("inventories", inventory_id=iid, warehouse_id=wid, part_id=PT[sku]["id"], quantity_on_hand=0, quantity_reserved=0,
            reorder_level=5, version=0, updated_at=None)
INITIAL = defaultdict(lambda: 30, {"BRK-DISC-FR": 6, "SHOCK-FR": 4, "TIRE-185-60R15": 12, "BAT-12V-45AH": 8, "WIPER-24": 4, "OIL-5W30-1L": 80})
for b in (1, 2, 3):
    rid = nid("inventory_receipts")
    dt = datetime(2026, 10, 1, 9, 0)
    add("inventory_receipts", receipt_id=rid, receipt_code=f"GR-261001-{b:03d}", warehouse_id=b, supplier_name="Công ty CP Phụ tùng Ô tô Việt",
        received_by=S(b, "reception1"), receipt_date=tsx(dt), note="Nhập kho đầu kỳ")
    for sku in PT:
        q = INITIAL[sku]
        add("inventory_receipt_items", receipt_item_id=nid("inventory_receipt_items"), receipt_id=rid, part_id=PT[sku]["id"], quantity=q,
            unit_cost=round(PT[sku]["price"] * 0.7, -3))
        EVENTS.append((dt, b, sku, "RECEIPT", q, "INVENTORY_RECEIPT", rid, S(b, "reception1")))
rid = nid("inventory_receipts")
dt = datetime(2026, 11, 2, 14, 0)
add("inventory_receipts", receipt_id=rid, receipt_code="GR-261102-001", warehouse_id=1, supplier_name="Công ty TNHH Dầu nhớt Sài Gòn",
    received_by=S(1, "reception2"), receipt_date=tsx(dt), note="Bổ sung dầu nhớt và lọc")
for sku, q in [("OIL-5W30-1L", 40), ("FLT-OIL", 20), ("FLT-AIR", 10)]:
    add("inventory_receipt_items", receipt_item_id=nid("inventory_receipt_items"), receipt_id=rid, part_id=PT[sku]["id"], quantity=q, unit_cost=round(PT[sku]["price"] * 0.7, -3))
    EVENTS.append((dt, 1, sku, "RECEIPT", q, "INVENTORY_RECEIPT", rid, S(1, "reception2")))

# ------------------------------------------------------------------ policies, tax, e-invoice config
POL = {}
for code, name, applies, sv, part, months, km, terms in [
    ("WP-BRAKE-6M", "Bảo hành dịch vụ phanh 6 tháng", "SERVICE", "SV-BRAKE", None, 6, 10000, "Bảo hành tay nghề thay má phanh trong 6 tháng hoặc 10.000 km."),
    ("WP-MAINT-3M", "Bảo hành bảo dưỡng 3 tháng", "SERVICE", "SV-MAINT10", None, 3, 5000, "Bảo hành lỗi do quá trình bảo dưỡng."),
    ("WP-PAD-6M", "Bảo hành má phanh 6 tháng", "PART", None, "BRK-PAD-FR", 6, 10000, "Bảo hành lỗi vật liệu má phanh."),
    ("WP-BATT-12M", "Bảo hành ắc quy 12 tháng", "PART", None, "BAT-12V-45AH", 12, None, "Bảo hành 1 đổi 1 khi ắc quy lỗi nhà sản xuất."),
]:
    pid = nid("warranty_policies")
    add("warranty_policies", policy_id=pid, policy_code=code, policy_name=name, applies_to=applies, service_id=SV[sv]["id"] if sv else None,
        part_id=PT[part]["id"] if part else None, duration_months=months, max_odometer_km=km, terms=terms, status="ACTIVE", created_at=ts("2026-01-05"))
    POL[sv or part] = dict(id=pid, months=months, km=km)

for item, rate, f, t in [("SERVICE", 10, "2025-01-01", "2025-12-31"), ("PART", 10, "2025-01-01", "2025-12-31"), ("LABOR", 10, "2025-01-01", "2025-12-31"),
                         ("SERVICE", 8, "2026-01-01", None), ("PART", 8, "2026-01-01", None), ("LABOR", 8, "2026-01-01", None)]:
    add("tax_rules", tax_rule_id=nid("tax_rules"), item_type=item, vat_rate=rate, effective_from=f, effective_to=t, created_by=1, created_at=ts("2025-12-20"))
VAT = 8
add("einvoice_configs", config_id=nid("einvoice_configs"), provider="MISA_MEINVOICE", seller_name="Công ty CP Dịch vụ Ô tô AutoCare",
    seller_tax_code="0108888888", seller_address="123 Trần Duy Hưng, Cầu Giấy, Hà Nội", api_base_url="https://testapi.meinvoice.vn/api/integration",
    invoice_template="1", invoice_series="C26TAC", credential_ref="secret://autocare/misa-meinvoice", is_active=True, updated_at=ts("2026-01-05"))

# ------------------------------------------------------------------ workflow cases
CODE_N = defaultdict(int)
def code(prefix, d):
    CODE_N[(prefix, d)] += 1
    return f"{prefix}-{d.strftime('%y%m%d')}-{CODE_N[(prefix, d)]:04d}"

def notify(user_id, title, content, ref_type, ref_id, when, status="SENT", channel="IN_APP"):
    add("notifications", notification_id=nid("notifications"), user_id=user_id, channel=channel, title=title, content=content,
        reference_type=ref_type, reference_id=ref_id, status=status, sent_at=tsx(when) if status != "PENDING" else None, created_at=tsx(when))

def audit(user_id, action, entity, eid, when, new=None):
    add("audit_logs", audit_id=nid("audit_logs"), user_id=user_id, action=action, entity_name=entity, entity_id=eid, old_value=None,
        new_value=new, ip_address="127.0.0.1", created_at=tsx(when))

USER_OF_STAFF = {r["staff_id"]: r["user_id"] for r in rows["staff"]}
USER_OF_CUST = {r["customer_id"]: r["user_id"] for r in rows["customers"]}

# stage order
STAGES = ["PENDING", "CONFIRMED", "CANCELLED", "REJECTED", "ARRIVED", "CHECKED_IN", "INSPECTED", "QUOTED", "QUOTE_APPROVED", "RO_NEW", "RO_ASSIGNED", "RO_IN_PROGRESS",
          "RO_IN_PROGRESS_REQ", "RO_WAITING_PARTS", "RO_ALL_DONE", "RO_COMPLETED", "WAITING_PAYMENT", "INVOICED", "PAID", "CLOSED"]
def at_least(stage, s): return STAGES.index(stage) >= STAGES.index(s)

APPTS_FOR_SLOTS = []

def case(branch, cust, veh, day, hour, services, parts, stage, mech="mechanic1", rejected=(), task_states=None, rating=None,
         note=None, reserve_skip=(), request=None, ro_type=1, einvoice_replace=False, zero_due=False, einvoice_fail=False):
    d = datetime.strptime(day, "%Y-%m-%d")
    base = d.replace(hour=hour)
    rec, rec2, cashier, mgr = S(branch, "reception1"), S(branch, "reception2"), S(branch, "cashier"), S(branch, "manager")
    mech_id = S(branch, mech)
    v = VEHICLE[veh]
    a_status = {"PENDING": "PENDING", "CONFIRMED": "CONFIRMED", "CANCELLED": "CANCELLED", "REJECTED": "REJECTED", "CHECKED_IN": "CHECKED_IN",
                "QUOTED": "CHECKED_IN", "ARRIVED": "CHECKED_IN", "INSPECTED": "CHECKED_IN", "QUOTE_APPROVED": "CHECKED_IN", "WAITING_PAYMENT": "WAITING_PAYMENT", "INVOICED": "WAITING_PAYMENT", "PAID": "WAITING_PAYMENT", "CLOSED": "COMPLETED"}.get(stage, "IN_SERVICE")
    aid = nid("appointments")
    add("appointments", appointment_id=aid, appointment_code=code("APT", d), customer_id=CUST[cust], vehicle_id=v["id"], branch_id=branch,
        slot_id=f"(SELECT slot_id FROM time_slots WHERE branch_id={branch} AND slot_date='{day}' AND start_time='{hour:02d}:00')",
        status=a_status, customer_note=note or "Xe cần kiểm tra theo lịch hẹn", reject_reason="Xưởng quá tải trong khung giờ này" if stage == "REJECTED" else None,
        cancel_reason="Khách bận đột xuất" if stage == "CANCELLED" else None,
        confirmed_by=rec if at_least(stage, "CHECKED_IN") or stage == "CONFIRMED" else None,
        created_at=tsx(base - timedelta(days=3)), updated_at=tsx(base))
    for sv in services:
        add("appointment_services", identity=False, appointment_id=aid, service_id=SV[sv]["id"], estimated_price=SV[sv]["price"])
    if stage in ("PENDING", "CONFIRMED", "CANCELLED", "REJECTED"):
        if stage == "CONFIRMED":
            notify(USER_OF_CUST[CUST[cust]], "Lịch hẹn đã được xác nhận", f"Lịch hẹn ngày {day} {hour:02d}:00 đã được xác nhận.", "APPOINTMENT", aid, base - timedelta(days=2))
        return aid
    # ---- check-in & inspection
    odo = v["odo"] + 120
    rcp = nid("vehicle_receptions")
    add("vehicle_receptions", reception_id=rcp, appointment_id=aid, received_by=rec, odometer_reading=odo,
        vehicle_condition="Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị", checked_in_at=tsx(base))
    if stage == "ARRIVED":                       # checked in, inspection not assigned yet (UC21 demo)
        return aid
    insp = nid("inspections")
    done_insp = at_least(stage, "INSPECTED")
    add("inspections", inspection_id=insp, reception_id=rcp, mechanic_id=mech_id, assigned_by=rec, status="COMPLETED" if done_insp else "ASSIGNED",
        result_summary="Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới." if done_insp else None,
        assigned_at=tsx(base + timedelta(minutes=10)), completed_at=tsx(base + timedelta(minutes=50)) if done_insp else None)
    if not done_insp:
        notify(USER_OF_STAFF[mech_id], "Bạn được phân công kiểm tra xe", f"Lịch hẹn {rows['appointments'][-1]['appointment_code']} – xe {VEH[veh-1][1]}",
               "INSPECTION", insp, base + timedelta(minutes=10))
        return aid
    # mechanic recommendations without prices (UC22)
    for k, sv in enumerate(services):
        add("inspection_items", inspection_item_id=nid("inspection_items"), inspection_id=insp, item_type="SERVICE", service_id=SV[sv]["id"], part_id=None,
            description=SV[sv]["name"], quantity=1, priority="HIGH" if k == 0 else "MEDIUM", note=None, created_at=tsx(base + timedelta(minutes=50)))
    for sku, q in parts:
        add("inspection_items", inspection_item_id=nid("inspection_items"), inspection_id=insp, item_type="PART", service_id=None, part_id=PT[sku]["id"],
            description=f"Cần thay {PT[sku]['name'].lower()}", quantity=q, priority="MEDIUM", note=None, created_at=tsx(base + timedelta(minutes=50)))
    if not at_least(stage, "QUOTED"):
        notify(USER_OF_STAFF[rec], "Kết quả kiểm tra mới", f"Xe {VEH[veh-1][1]} đã kiểm tra xong, mời lập báo giá.", "INSPECTION", insp, base + timedelta(minutes=50))
        return aid
    # ---- quotation
    qid = nid("quotations")
    items = []
    approved_stage = at_least(stage, "QUOTE_APPROVED")
    for sv in services:
        items.append(dict(type="SERVICE", sv=sv, qty=1, price=SV[sv]["price"], desc=SV[sv]["name"]))
    for sku, q in parts:
        items.append(dict(type="PART", sku=sku, qty=q, price=PT[sku]["price"], desc=PT[sku]["name"]))
    subtotal = 0
    qdate = base + timedelta(hours=1)
    for it in items:
        it["id"] = nid("quotation_items")
        rej = (it.get("sv") in rejected) or (it.get("sku") in rejected)
        dec = "PENDING" if not approved_stage else ("REJECTED" if rej else "APPROVED")
        it["decision"] = dec
        line = it["qty"] * it["price"]
        if dec != "REJECTED":
            subtotal += line
        add("quotation_items", item_id=it["id"], quotation_id=qid, item_type=it["type"], service_id=SV[it["sv"]]["id"] if it["type"] == "SERVICE" else None,
            part_id=PT[it["sku"]]["id"] if it["type"] == "PART" else None, description=it["desc"], quantity=it["qty"], unit_price=it["price"],
            line_total=line, is_warranty=False, decision=dec, decided_at=tsx(qdate + timedelta(hours=1)) if approved_stage else None)
    vat = round(subtotal * VAT / 100)
    add("quotations", quotation_id=qid, quotation_code=code("QT", d), inspection_id=insp, prepared_by=rec, parent_quotation_id=None,
        subtotal=subtotal, vat_amount=vat, total_amount=subtotal + vat,
        status=("PARTIALLY_APPROVED" if rejected else "APPROVED") if approved_stage else "SENT",
        valid_until=tsx(base + timedelta(days=3)), sent_at=tsx(qdate), responded_at=tsx(qdate + timedelta(hours=1)) if approved_stage else None, created_at=tsx(qdate))
    notify(USER_OF_CUST[CUST[cust]], "Báo giá sửa chữa mới", "Vui lòng xem và phê duyệt báo giá cho xe của bạn.", "QUOTATION", qid, qdate)
    if not approved_stage:
        return aid
    audit(USER_OF_CUST[CUST[cust]], "QUOTATION_APPROVED", "quotations", qid, qdate + timedelta(hours=1))
    if stage == "QUOTE_APPROVED":                # approved, repair order not created yet (UC26 demo)
        notify(USER_OF_STAFF[rec], "Khách đã duyệt báo giá", f"Báo giá {rows['quotations'][-1]['quotation_code']} đã được duyệt, mời tạo lệnh sửa chữa.",
               "QUOTATION", qid, qdate + timedelta(hours=1))
        return aid
    # ---- repair order
    ro_time = qdate + timedelta(hours=1, minutes=20)
    ro = nid("repair_orders")
    appr = [it for it in items if it["decision"] == "APPROVED"]
    total = sum(it["qty"] * it["price"] for it in appr)
    ro_status = {"RO_NEW": "NEW", "RO_ASSIGNED": "ASSIGNED", "RO_IN_PROGRESS": "IN_PROGRESS", "RO_IN_PROGRESS_REQ": "IN_PROGRESS",
                 "RO_WAITING_PARTS": "WAITING_PARTS", "RO_ALL_DONE": "IN_PROGRESS", "RO_COMPLETED": "COMPLETED"}.get(stage, "COMPLETED")
    if stage == "CLOSED":
        ro_status = "CLOSED"
    started = at_least(stage, "RO_IN_PROGRESS")
    finished = at_least(stage, "RO_COMPLETED")
    t_start = ro_time + timedelta(minutes=30)
    t_end = ro_time + timedelta(hours=4)
    ro_row = add("repair_orders", repair_order_id=ro, ro_code=code("RO", d), quotation_id=qid, branch_id=branch, type_id=ro_type, created_by=rec,
                 status=ro_status, total_cost=total, started_at=tsx(t_start) if started else None, completed_at=tsx(t_end) if finished else None,
                 created_at=tsx(ro_time), updated_at=tsx(t_end if finished else ro_time))
    # tasks
    tasks = []
    for k, it in enumerate([i for i in appr if i["type"] == "SERVICE"]):
        tid = nid("repair_tasks")
        st, pct = "TODO", 0
        if task_states:
            st, pct = task_states[k]
        elif at_least(stage, "RO_ALL_DONE"):
            st, pct = "DONE", 100
        assigned = at_least(stage, "RO_ASSIGNED")
        add("repair_tasks", task_id=tid, repair_order_id=ro, quotation_item_id=it["id"], mechanic_id=mech_id if assigned else None, task_name=it["desc"],
            status=st, progress_percent=pct, labor_hours=round(pct / 100 * 1.5, 2),
            started_at=tsx(t_start + timedelta(minutes=10 * k)) if st != "TODO" else None,
            finished_at=tsx(t_end - timedelta(minutes=20 * k)) if st == "DONE" else None)
        tasks.append(dict(id=tid, item=it, state=st))
    if at_least(stage, "RO_ASSIGNED"):
        notify(USER_OF_STAFF[mech_id], "Bạn được phân công lệnh sửa chữa", f"Lệnh {ro_row['ro_code']} đã được giao cho bạn.", "REPAIR_ORDER", ro, ro_time + timedelta(minutes=15))
        audit(USER_OF_STAFF[rec], "MECHANIC_ASSIGNED", "repair_orders", ro, ro_time + timedelta(minutes=15))
    if started:
        add("repair_notes", note_id=nid("repair_notes"), repair_order_id=ro, task_id=tasks[0]["id"], author_id=mech_id,
            content="Đã kiểm tra lại các hạng mục, bắt đầu thực hiện.", created_at=tsx(t_start + timedelta(minutes=5)))
    # parts: reservation at RO creation, issue via request when work done
    part_items = [it for it in appr if it["type"] == "PART"]
    first_task = tasks[0]["id"] if tasks else None
    res_of = {}
    for it in part_items:
        if it["sku"] in reserve_skip:
            continue
        rsv = nid("part_reservations")
        res_of[it["id"]] = rsv
        it["res"] = rsv
        EVENTS.append((ro_time + timedelta(minutes=5), branch, it["sku"], "RESERVE", it["qty"], "REPAIR_ORDER", ro, rec))
        add("part_reservations", reservation_id=rsv, repair_order_id=ro, quotation_item_id=it["id"], inventory_id=INV[(branch, it["sku"])],
            quantity=it["qty"], status="RESERVED", reserved_by=rec, created_at=tsx(ro_time + timedelta(minutes=5)), updated_at=tsx(ro_time + timedelta(minutes=5)))
    issued_all = at_least(stage, "RO_ALL_DONE")
    if issued_all and part_items:
        rq_time = t_start + timedelta(minutes=20)
        prq = nid("part_requests")
        add("part_requests", request_id=prq, request_code=code("PR", d), repair_order_id=ro, task_id=first_task, requested_by=mech_id, status="ISSUED",
            note="Lấy phụ tùng theo báo giá", processed_by=rec, processed_at=tsx(rq_time + timedelta(minutes=15)), created_at=tsx(rq_time))
        for it in part_items:
            pri = nid("part_request_items")
            add("part_request_items", request_item_id=pri, request_id=prq, quotation_item_id=it["id"], part_id=PT[it["sku"]]["id"],
                quantity_requested=it["qty"], quantity_issued=it["qty"])
            add("repair_task_parts", task_part_id=nid("repair_task_parts"), task_id=first_task, inventory_id=INV[(branch, it["sku"])],
                reservation_id=it.get("res"), request_item_id=pri, quantity_issued=it["qty"], quantity_returned=0, unit_price=it["price"],
                issued_by=rec, issued_at=tsx(rq_time + timedelta(minutes=15)))
            EVENTS.append((rq_time + timedelta(minutes=15), branch, it["sku"], "ISSUE", it["qty"], "PART_REQUEST", prq, rec))
            if it.get("res"):
                for r in rows["part_reservations"]:
                    if r["reservation_id"] == it["res"]:
                        r["status"] = "ISSUED"; r["updated_at"] = tsx(rq_time + timedelta(minutes=15))
    if request:   # pending request (UC38 demo): list of (sku, qty)
        rq_time = t_start + timedelta(minutes=40)
        prq = nid("part_requests")
        add("part_requests", request_id=prq, request_code=code("PR", d), repair_order_id=ro, task_id=first_task, requested_by=mech_id, status="PENDING",
            note="Cần phụ tùng để tiếp tục công việc", processed_by=None, processed_at=None, created_at=tsx(rq_time))
        for sku, q in request:
            it = next(i for i in part_items if i["sku"] == sku)
            add("part_request_items", request_item_id=nid("part_request_items"), request_id=prq, quotation_item_id=it["id"], part_id=PT[sku]["id"],
                quantity_requested=q, quantity_issued=0)
        notify(USER_OF_STAFF[rec], "Yêu cầu xuất phụ tùng mới", f"Lệnh {ro_row['ro_code']} yêu cầu phụ tùng.", "PART_REQUEST", prq, rq_time)
    if stage == "RO_COMPLETED":
        notify(USER_OF_STAFF[rec], "Lệnh sửa chữa đã hoàn thành", f"Lệnh {ro_row['ro_code']} chờ lễ tân xác nhận.", "REPAIR_ORDER", ro, t_end)
    if stage in ("WAITING_PAYMENT", "INVOICED", "PAID"):
        notify(USER_OF_STAFF[cashier], "Hồ sơ chờ thanh toán", f"Lệnh {ro_row['ro_code']} đã hoàn tất kỹ thuật, chờ thu ngân.", "REPAIR_ORDER", ro, t_end + timedelta(minutes=20))
        audit(USER_OF_STAFF[rec], "REPAIR_VERIFIED", "repair_orders", ro, t_end + timedelta(minutes=20))
    if not at_least(stage, "INVOICED"):
        return aid
    # ---- settlement: finalized charges (UC52 data), payment (UC53), e-invoice (UC55), handover (UC59)
    inv_time = t_end + timedelta(minutes=40)
    inv = nid("invoices")
    sub = 0 if zero_due else total
    vat_amt = round(sub * VAT / 100)
    paid = at_least(stage, "PAID")
    add("invoices", invoice_id=inv, invoice_code=code("INV", d), repair_order_id=ro, billing_id=BILL.get(cust), subtotal=sub, discount_amount=0,
        vat_amount=vat_amt, total_amount=sub + vat_amt, payment_status="PAID" if paid else "UNPAID", status="FINALIZED", finalized_by=cashier,
        finalized_at=tsx(inv_time), created_at=tsx(inv_time))
    for it in appr:
        lv = 0 if zero_due else round(it["qty"] * it["price"] * VAT / 100)
        add("invoice_lines", line_id=nid("invoice_lines"), invoice_id=inv, quotation_item_id=it["id"], item_type=it["type"], description=it["desc"],
            quantity=it["qty"], unit_price=it["price"], vat_rate=VAT, vat_amount=lv, line_total=0 if zero_due else it["qty"] * it["price"] + lv,
            is_warranty_covered=zero_due)
    audit(USER_OF_STAFF[cashier], "CHARGES_FINALIZED", "invoices", inv, inv_time)
    if not paid:
        return aid
    pay_time = inv_time + timedelta(minutes=10)
    pid = nid("payments")
    add("payments", payment_id=pid, invoice_id=inv, amount=sub + vat_amt, method="BANK_TRANSFER" if cust % 2 == 0 else "CASH", status="SUCCESS",
        transaction_ref=f"FT26{inv:06d}" if cust % 2 == 0 else None, received_by=cashier, paid_at=tsx(pay_time))
    audit(USER_OF_STAFF[cashier], "PAYMENT_RECORDED", "payments", pid, pay_time)
    if stage == "PAID":
        if einvoice_fail:                         # provider rejected the buyer tax code (55.E1) – needs correction & retry
            add("e_invoices", e_invoice_id=nid("e_invoices"), invoice_id=inv, config_id=1, original_e_invoice_id=None,
                buyer_name="Công ty TNHH Thương mại Hưng Phát", buyer_tax_code="9990001234", buyer_address="25 Tô Hiệu, Hà Đông, Hà Nội",
                buyer_email=f"customer{cust}@gmail.com", external_invoice_no=None, invoice_series="C26TAC", lookup_code=None, external_status="REJECTED",
                attempt_count=1, status="FAILED", correction_type=None, correction_reason=None,
                response_payload='{"success": false, "errorCode": "InvalidTaxCode", "message": "Mã số thuế người mua không tồn tại"}',
                issued_at=None, created_at=tsx(pay_time + timedelta(minutes=5)))
        return aid
    bill = next((r for r in rows["billing_information"] if r["customer_id"] == CUST[cust]), None)
    cust_name = CUSTOMERS[cust - 1][0]
    ei = nid("e_invoices")
    add("e_invoices", e_invoice_id=ei, invoice_id=inv, config_id=1, original_e_invoice_id=None,
        buyer_name=(bill["company_name"] or bill["buyer_name"]) if bill else cust_name, buyer_tax_code=bill["tax_code"] if bill else None,
        buyer_address=bill["billing_address"] if bill else CUSTOMERS[cust - 1][3], buyer_email=f"customer{cust}@gmail.com",
        external_invoice_no=f"{inv:08d}", invoice_series="C26TAC", lookup_code=f"MISA-{inv:06d}A", external_status="REPLACED" if einvoice_replace else "ISSUED", attempt_count=1,
        status="REPLACED" if einvoice_replace else "ISSUED",
        correction_type=None, correction_reason=None, response_payload='{"success": true}', issued_at=tsx(pay_time + timedelta(minutes=5)), created_at=tsx(pay_time + timedelta(minutes=5)))
    if einvoice_replace:
        add("e_invoices", e_invoice_id=nid("e_invoices"), invoice_id=inv, config_id=1, original_e_invoice_id=ei, buyer_name="Công ty TNHH Bình An",
            buyer_tax_code="0101234567", buyer_address="56 Kim Mã, Ba Đình, Hà Nội", buyer_email=f"customer{cust}@gmail.com",
            external_invoice_no=f"{inv + 500:08d}", invoice_series="C26TAC", lookup_code=f"MISA-{inv:06d}B", external_status="ISSUED", attempt_count=1, status="ISSUED", correction_type="REPLACEMENT",
            correction_reason="Sai tên đơn vị mua hàng", response_payload='{"success": true}', issued_at=tsx(pay_time + timedelta(days=1)), created_at=tsx(pay_time + timedelta(days=1)))
    hv = pay_time + timedelta(minutes=20)
    add("vehicle_handovers", handover_id=nid("vehicle_handovers"), appointment_id=aid, invoice_id=inv, handed_by=rec, odometer_out=odo + 2,
        customer_confirmed=True, note="Khách đã kiểm tra và nhận xe", handed_at=tsx(hv))
    if rating:
        add("service_ratings", rating_id=nid("service_ratings"), appointment_id=aid, customer_id=CUST[cust], score=rating,
            comment={5: "Dịch vụ rất tốt, nhân viên nhiệt tình", 4: "Hài lòng, thời gian chờ hơi lâu"}.get(rating, "Ổn"), created_at=tsx(hv + timedelta(hours=3)))
    for it in appr:
        key = it.get("sv") or it.get("sku")
        if key in POL:
            p = POL[key]
            wid = nid("warranties")
            start = hv.date()
            end = date(start.year + (start.month - 1 + p["months"]) // 12, (start.month - 1 + p["months"]) % 12 + 1, min(start.day, 28))
            add("warranties", warranty_id=wid, warranty_code=code("WR", d), policy_id=p["id"], vehicle_id=v["id"], repair_order_id=ro,
                quotation_item_id=it["id"], start_date=start.isoformat(), end_date=end.isoformat(), start_odometer=odo + 2,
                max_odometer=(odo + 2 + p["km"]) if p["km"] else None, status="ACTIVE", created_at=tsx(hv))
            it["warranty"] = wid
    return dict(aid=aid, items=appr, ro=ro)

# ---- branch 1 (demo branch: Cầu Giấy)
c1 = case(1, 1, 1, "2026-10-12", 8, ["SV-MAINT10", "SV-BRAKE"], [("OIL-5W30-1L", 4), ("FLT-OIL", 1), ("BRK-PAD-FR", 1)], "CLOSED", rating=5)
c2 = case(1, 2, 2, "2026-10-20", 9, ["SV-AC", "SV-BATT", "SV-TIRE"], [("FLT-CABIN", 1), ("BAT-12V-45AH", 1), ("AC-GAS-R134A", 1)], "CLOSED",
          mech="mechanic2", rejected=("SV-TIRE",), rating=4, einvoice_replace=True)
case(1, 3, 4, "2026-11-05", 8, ["SV-OIL", "SV-TIRE"], [("OIL-5W30-1L", 4), ("FLT-OIL", 1)], "WAITING_PAYMENT", mech="mechanic2")
case(1, 4, 5, "2026-11-06", 10, ["SV-BRAKE"], [("BRK-PAD-FR", 1), ("BRK-FLUID-DOT4", 1)], "RO_COMPLETED", mech="mechanic1", ro_type=2)
case(1, 5, 6, "2026-11-07", 8, ["SV-ENGINE", "SV-OIL"], [("SPK-PLUG-IR", 4), ("OIL-5W30-1L", 4), ("FLT-OIL", 1)], "RO_ALL_DONE", mech="mechanic1", ro_type=2)
case(1, 6, 7, "2026-11-07", 9, ["SV-MAINT10", "SV-SUSP"], [("OIL-5W30-1L", 6), ("FLT-OIL", 1), ("FLT-AIR", 1), ("SHOCK-FR", 2)], "RO_IN_PROGRESS_REQ",
     mech="mechanic1", task_states=[("DOING", 40), ("TODO", 0)], request=[("OIL-5W30-1L", 6), ("FLT-OIL", 1)])
case(1, 8, 10, "2026-11-07", 13, ["SV-BRAKE", "SV-TIRE"], [("BRK-DISC-FR", 2), ("BRK-PAD-FR", 1)], "RO_WAITING_PARTS", mech="mechanic2", ro_type=2,
     task_states=[("BLOCKED", 30), ("DONE", 100)], reserve_skip=("BRK-DISC-FR",), request=[("BRK-DISC-FR", 2)])
case(1, 9, 11, "2026-11-08", 8, ["SV-AC", "SV-BATT"], [("FLT-CABIN", 1), ("AC-GAS-R134A", 1), ("BAT-12V-45AH", 1)], "RO_IN_PROGRESS",
     mech="mechanic1", task_states=[("DOING", 50), ("TODO", 0)])
case(1, 11, 14, "2026-11-08", 9, ["SV-OIL", "SV-WASH"], [("OIL-5W30-1L", 5), ("FLT-OIL", 1)], "RO_ASSIGNED", mech="mechanic1")
case(1, 12, 15, "2026-11-08", 10, ["SV-MAINT10"], [("OIL-5W30-1L", 5), ("FLT-OIL", 1), ("FLT-AIR", 1), ("FLT-CABIN", 1)], "RO_NEW")
case(1, 1, 3, "2026-11-08", 10, ["SV-MOTO-MAINT"], [("MOTO-OIL-08L", 1), ("MOTO-SPK", 1)], "RO_NEW")
case(1, 10, 12, "2026-11-08", 11, ["SV-OIL", "SV-ENGINE"], [("OIL-5W30-1L", 4), ("FLT-OIL", 1)], "QUOTED", mech="mechanic3")
case(1, 12, 16, "2026-11-08", 13, ["SV-MOTO-MAINT"], [], "CHECKED_IN", mech="mechanic3")
case(1, 1, 1, "2026-11-10", 8, ["SV-WASH"], [], "CONFIRMED")
case(1, 2, 2, "2026-11-11", 9, ["SV-ENGINE"], [], "PENDING", note="Đèn check engine sáng")
case(1, 3, 18, "2026-11-12", 14, ["SV-OIL"], [], "PENDING")
case(1, 3, 4, "2026-11-03", 9, ["SV-OIL"], [], "CANCELLED")
case(1, 6, 8, "2026-11-04", 15, ["SV-MAINT10"], [], "REJECTED")
# ---- branch 2 (Hà Đông)
case(2, 7, 9, "2026-10-15", 9, ["SV-OIL"], [("OIL-5W30-1L", 4), ("FLT-OIL", 1)], "CLOSED", rating=5)
case(2, 8, 17, "2026-11-07", 10, ["SV-BRAKE"], [("BRK-PAD-FR", 1)], "RO_IN_PROGRESS", task_states=[("DOING", 60)])
case(2, 7, 9, "2026-11-08", 14, ["SV-TIRE"], [], "RO_NEW")
case(2, 7, 9, "2026-11-12", 10, ["SV-AC"], [], "PENDING")
# ---- branch 3 (Quận 7)
case(3, 10, 13, "2026-10-25", 8, ["SV-MOTO-MAINT"], [("MOTO-OIL-08L", 1), ("MOTO-SPK", 1)], "CLOSED", rating=4)
case(3, 10, 12, "2026-11-08", 9, ["SV-MAINT10"], [("OIL-5W30-1L", 5), ("FLT-OIL", 1)], "RO_ASSIGNED")
case(3, 10, 12, "2026-11-13", 9, ["SV-WASH"], [], "CONFIRMED")
# ---- intake demo data (UC17–UC26), 09/11/2026 – appended last so earlier ids stay stable
case(1, 2, 19, "2026-11-09", 9, ["SV-MAINT10"], [], "CONFIRMED", note="Xe đến hạn bảo dưỡng 50.000 km")
case(1, 5, 20, "2026-11-09", 10, ["SV-BRAKE", "SV-TIRE"], [], "CONFIRMED", note="Phanh hơi kêu, lốp mòn không đều")
case(1, 11, 22, "2026-11-09", 14, ["SV-MOTO-MAINT"], [], "PENDING")
case(1, 6, 8, "2026-11-09", 8, ["SV-ENGINE"], [], "ARRIVED", note="Đèn check engine sáng, máy rung khi chạy không tải")
case(1, 4, 23, "2026-11-09", 9, ["SV-AC"], [], "CHECKED_IN", mech="mechanic1", note="Điều hòa không mát")
case(1, 9, 21, "2026-11-08", 15, ["SV-SUSP", "SV-OIL"], [("SHOCK-FR", 4), ("OIL-5W30-1L", 4), ("FLT-OIL", 1)], "INSPECTED", mech="mechanic2")
case(1, 2, 2, "2026-11-08", 16, ["SV-BRAKE", "SV-SUSP", "SV-BATT"], [("BRK-PAD-FR", 1), ("SHOCK-FR", 4)], "QUOTE_APPROVED",
     mech="mechanic3", rejected=("SV-BATT",))
# ---- settlement demo data (UC53–UC59) – appended last so earlier ids stay stable
case(1, 6, 24, "2026-11-08", 8, ["SV-OIL", "SV-TIRE"], [("OIL-5W30-1L", 4), ("FLT-OIL", 1)], "INVOICED", mech="mechanic2")
case(1, 12, 25, "2026-11-08", 11, ["SV-MAINT10"], [("OIL-5W30-1L", 5), ("FLT-OIL", 1), ("FLT-AIR", 1)], "INVOICED", mech="mechanic3")
case(1, 3, 26, "2026-11-07", 14, ["SV-BRAKE"], [("BRK-PAD-FR", 1)], "PAID", mech="mechanic1")
case(1, 8, 27, "2026-11-06", 15, ["SV-AC"], [("AC-GAS-R134A", 1)], "PAID", mech="mechanic2", einvoice_fail=True)
case(1, 11, 28, "2026-11-07", 10, ["SV-BRAKE"], [("BRK-PAD-FR", 1)], "INVOICED", mech="mechanic3", ro_type=4, zero_due=True,
     note="Bảo hành má phanh – không thu phí")

# ---- warranty requests on closed jobs (for UC45–UC49 teammates)
w_batt = next(it["warranty"] for it in c2["items"] if it.get("sku") == "BAT-12V-45AH")
w_brake = next(it["warranty"] for it in c1["items"] if it.get("sv") == "SV-BRAKE")
add("warranty_requests", request_id=nid("warranty_requests"), request_code="WQ-261107-0001", warranty_id=w_batt, customer_id=CUST[2], branch_id=1,
    issue_description="Ắc quy yếu, sáng ra khó đề nổ", current_odometer=VEHICLE[2]["odo"] + 900, status="SUBMITTED", is_eligible=None, assessed_by=None,
    assessment_note=None, approved_by=None, decided_at=None, created_at=ts("2026-11-07", 8, 30))
add("warranty_requests", request_id=nid("warranty_requests"), request_code="WQ-261106-0001", warranty_id=w_brake, customer_id=CUST[1], branch_id=1,
    issue_description="Phanh kêu rít khi đạp nhẹ", current_odometer=VEHICLE[1]["odo"] + 1500, status="ASSESSED", is_eligible=True, assessed_by=S(1, "mechanic3"),
    assessment_note="Má phanh lắp lệch, thuộc phạm vi bảo hành tay nghề", approved_by=None, decided_at=None, created_at=ts("2026-11-06", 14, 0))

# ------------------------------------------------------------------ apply inventory ledger
state = defaultdict(lambda: [0, 0])     # on_hand, reserved
for (when, b, sku, typ, q, rtype, rid_, staff) in sorted(EVENTS, key=lambda e: e[0]):
    st = state[(b, sku)]
    if typ == "RECEIPT":
        st[0] += q; delta = q
    elif typ == "RESERVE":
        st[1] += q; delta = q
    elif typ == "ISSUE":
        st[0] -= q
        st[1] = max(0, st[1] - q)
        delta = -q
    assert st[0] >= 0 and 0 <= st[1] <= st[0], (b, sku, st)
    add("inventory_transactions", transaction_id=nid("inventory_transactions"), inventory_id=INV[(b, sku)], transaction_type=typ, quantity=delta,
        balance_after=st[0], reference_type=rtype, reference_id=rid_, performed_by=staff, created_at=tsx(when))
for r in rows["inventories"]:
    key = next(k for k, v in INV.items() if v == r["inventory_id"])
    r["quantity_on_hand"], r["quantity_reserved"] = state[key]
    r["updated_at"] = ts("2026-11-08", 7, 0)
# make one low-stock item visible on the dashboard
for r in rows["inventories"]:
    pass

# ------------------------------------------------------------------ emit SQL
ORDER = ["branches", "users", "customers", "staff", "billing_information", "vehicles", "services", "branch_services", "parts",
         "repair_order_types", "warehouses", "inventories", "inventory_receipts", "inventory_receipt_items", "warranty_policies", "tax_rules",
         "einvoice_configs", "TIME_SLOTS", "appointments", "appointment_services", "vehicle_receptions", "inspections", "inspection_items", "quotations",
         "quotation_items", "repair_orders", "repair_tasks", "repair_notes", "part_reservations", "part_requests", "part_request_items",
         "repair_task_parts", "inventory_transactions", "invoices", "invoice_lines", "payments", "e_invoices", "vehicle_handovers",
         "service_ratings", "warranties", "warranty_requests", "notifications", "audit_logs"]
PK = {"branches": "branch_id", "users": "user_id", "customers": "customer_id", "staff": "staff_id", "billing_information": "billing_id",
      "vehicles": "vehicle_id", "services": "service_id", "parts": "part_id", "repair_order_types": "type_id", "warehouses": "warehouse_id",
      "inventories": "inventory_id", "inventory_receipts": "receipt_id", "inventory_receipt_items": "receipt_item_id", "warranty_policies": "policy_id",
      "tax_rules": "tax_rule_id", "einvoice_configs": "config_id", "appointments": "appointment_id", "vehicle_receptions": "reception_id",
      "inspections": "inspection_id", "inspection_items": "inspection_item_id", "quotations": "quotation_id", "quotation_items": "item_id", "repair_orders": "repair_order_id",
      "repair_tasks": "task_id", "repair_notes": "note_id", "part_reservations": "reservation_id", "part_requests": "request_id",
      "part_request_items": "request_item_id", "repair_task_parts": "task_part_id", "inventory_transactions": "transaction_id",
      "invoices": "invoice_id", "invoice_lines": "line_id", "payments": "payment_id", "e_invoices": "e_invoice_id", "vehicle_handovers": "handover_id",
      "service_ratings": "rating_id", "warranties": "warranty_id", "warranty_requests": "request_id", "notifications": "notification_id",
      "audit_logs": "audit_id"}

def lit(v):
    if v is None: return "NULL"
    if isinstance(v, bool): return "TRUE" if v else "FALSE"
    if isinstance(v, (int, float)): return str(v)
    if isinstance(v, str) and v.startswith("(SELECT"): return v
    return "'" + str(v).replace("'", "''") + "'"

out = ["-- =====================================================================",
       "-- AutoCare – sample data for the whole project (generated by seed_generator.py)",
       "-- Run AFTER 01_schema.sql.  All demo accounts: password = Password@123",
       "-- =====================================================================",
       "BEGIN;", ""]
for t in ORDER:
    if t == "TIME_SLOTS":
        out.append("-- time_slots: 08:00–16:00 hourly, 01/10/2026 – 30/11/2026, capacity 4, all branches")
        out.append("INSERT INTO time_slots(branch_id, slot_date, start_time, end_time, capacity, booked_count, status)\n"
                   "SELECT b.branch_id, d::date, make_time(h,0,0), make_time(h+1,0,0), 4, 0, 'OPEN'\n"
                   "FROM branches b, generate_series(DATE '2026-10-01', DATE '2026-11-30', INTERVAL '1 day') d, generate_series(8,16) h;\n")
        continue
    rs = rows[t]
    if not rs:
        continue
    cols = list(rs[0].keys())
    ov = " OVERRIDING SYSTEM VALUE" if t in IDENTITY else ""
    out.append(f"-- {t} ({len(rs)} rows)")
    out.append(f"INSERT INTO {t} ({', '.join(cols)}){ov} VALUES")
    out.append(",\n".join("  (" + ", ".join(lit(r[c]) for c in cols) + ")" for r in rs) + ";")
    out.append("")
out.append("-- booked_count = active appointments per slot")
out.append("UPDATE time_slots s SET booked_count = x.n FROM (SELECT slot_id, COUNT(*) n FROM appointments "
           "WHERE status NOT IN ('CANCELLED','REJECTED') GROUP BY slot_id) x WHERE x.slot_id = s.slot_id;")
out.append("")
out.append("-- move identity sequences past the seeded ids")
for t, pk in PK.items():
    if rows[t]:
        out.append(f"SELECT setval(pg_get_serial_sequence('{t}', '{pk}'), (SELECT MAX({pk}) FROM {t}));")
out.append("SELECT setval(pg_get_serial_sequence('roles', 'role_id'), (SELECT MAX(role_id) FROM roles));")
out.append("\nCOMMIT;")
open(OUT, "w", encoding="utf8").write("\n".join(out) + "\n")
print("written", OUT, {t: len(r) for t, r in rows.items()})
