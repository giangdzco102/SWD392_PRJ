-- MSSV: HE191633
-- Ho ten: Nguyen Truong Giang

-- =====================================================================
-- AutoCare – Vehicle Repair, Maintenance Booking & Garage Service Management
-- Physical database schema – PostgreSQL 16
-- Naming convention: snake_case, plural table names, <table>_id surrogate keys,
--   fk columns named after referenced key, idx_<table>_<cols>, chk_/uq_ prefixes
-- =====================================================================

-- BRANCHES — Garage branches of the AutoCare network (UC60).
CREATE TABLE branches (
    branch_id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_code            VARCHAR(20) NOT NULL UNIQUE,
    branch_name            VARCHAR(150) NOT NULL,
    address                VARCHAR(255) NOT NULL,
    phone                  VARCHAR(20),
    email                  VARCHAR(150),
    status                 VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_branches_1 CHECK (status IN ('ACTIVE','INACTIVE'))
);

-- ROLES — System roles used for role-based access control (BR4).
CREATE TABLE roles (
    role_id                SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_code              VARCHAR(30) NOT NULL UNIQUE,
    role_name              VARCHAR(100) NOT NULL,
    description            VARCHAR(255)
);

-- USERS — Login accounts of customers and staff (UC01–UC04).
CREATE TABLE users (
    user_id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_id                SMALLINT NOT NULL
        REFERENCES roles(role_id) ON DELETE RESTRICT,
    email                  VARCHAR(150) NOT NULL UNIQUE,
    phone                  VARCHAR(20) UNIQUE,
    password_hash          VARCHAR(255) NOT NULL,
    full_name              VARCHAR(150) NOT NULL,
    status                 VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    failed_login_count     SMALLINT NOT NULL DEFAULT 0,
    locked_until           TIMESTAMPTZ,
    last_login_at          TIMESTAMPTZ,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_users_1 CHECK (status IN ('ACTIVE','LOCKED','INACTIVE')),
    CONSTRAINT chk_users_2 CHECK (failed_login_count >= 0)
);
CREATE INDEX idx_users_role_id ON users(role_id);

-- CUSTOMERS — Customer profile linked 1–1 to a user account.
CREATE TABLE customers (
    customer_id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id                BIGINT NOT NULL UNIQUE
        REFERENCES users(user_id) ON DELETE RESTRICT,
    date_of_birth          DATE,
    gender                 VARCHAR(10),
    address                VARCHAR(255),
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_customers_1 CHECK (gender IN ('MALE','FEMALE','OTHER'))
);

-- STAFF — Internal staff profile with branch assignment (UC61, BR5, BR48).
CREATE TABLE staff (
    staff_id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id                BIGINT NOT NULL UNIQUE
        REFERENCES users(user_id) ON DELETE RESTRICT,
    branch_id              BIGINT
        REFERENCES branches(branch_id) ON DELETE RESTRICT,
    staff_code             VARCHAR(20) NOT NULL UNIQUE,
    position               VARCHAR(30) NOT NULL,
    hired_date             DATE,
    status                 VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_staff_1 CHECK (position IN ('RECEPTIONIST','MECHANIC','CASHIER','BRANCH_MANAGER','SYS_ADMIN'))
);
CREATE INDEX idx_staff_branch_id_position ON staff(branch_id, position);

-- BILLING_INFORMATION — Reusable buyer information for e-invoices (UC09, BR40).
CREATE TABLE billing_information (
    billing_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id            BIGINT NOT NULL
        REFERENCES customers(customer_id) ON DELETE RESTRICT,
    buyer_type             VARCHAR(20) NOT NULL DEFAULT 'INDIVIDUAL',
    buyer_name             VARCHAR(150) NOT NULL,
    company_name           VARCHAR(255),
    tax_code               VARCHAR(14),
    billing_address        VARCHAR(255) NOT NULL,
    invoice_email          VARCHAR(150) NOT NULL,
    is_default             BOOLEAN NOT NULL DEFAULT FALSE,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_billing_information_1 CHECK (buyer_type IN ('INDIVIDUAL','COMPANY')),
    CONSTRAINT chk_billing_information_2 CHECK (buyer_type = 'INDIVIDUAL' OR tax_code IS NOT NULL)
);
CREATE INDEX idx_billing_information_customer_id ON billing_information(customer_id);

-- NOTIFICATIONS — E-mail / in-app notifications sent by the Notification component (UC24).
CREATE TABLE notifications (
    notification_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id                BIGINT NOT NULL
        REFERENCES users(user_id) ON DELETE RESTRICT,
    channel                VARCHAR(20) NOT NULL DEFAULT 'EMAIL',
    title                  VARCHAR(200) NOT NULL,
    content                TEXT NOT NULL,
    reference_type         VARCHAR(50),
    reference_id           BIGINT,
    status                 VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    sent_at                TIMESTAMPTZ,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_notifications_1 CHECK (channel IN ('EMAIL','IN_APP')),
    CONSTRAINT chk_notifications_2 CHECK (status IN ('PENDING','SENT','FAILED','READ'))
);
CREATE INDEX idx_notifications_user_id_status ON notifications(user_id, status);

-- AUDIT_LOGS — Append-only audit trail of important transactions (BR50).
CREATE TABLE audit_logs (
    audit_id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id                BIGINT
        REFERENCES users(user_id) ON DELETE RESTRICT,
    action                 VARCHAR(50) NOT NULL,
    entity_name            VARCHAR(50) NOT NULL,
    entity_id              BIGINT NOT NULL,
    old_value              JSONB,
    new_value              JSONB,
    ip_address             VARCHAR(45),
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_audit_logs_entity_name_entity_id ON audit_logs(entity_name, entity_id);

-- VEHICLES — Vehicles registered by customers (UC05–UC08).
CREATE TABLE vehicles (
    vehicle_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id            BIGINT NOT NULL
        REFERENCES customers(customer_id) ON DELETE RESTRICT,
    license_plate          VARCHAR(15) NOT NULL UNIQUE,
    vehicle_type           VARCHAR(20) NOT NULL,
    brand                  VARCHAR(50) NOT NULL,
    model                  VARCHAR(50) NOT NULL,
    manufacture_year       SMALLINT,
    vin                    VARCHAR(17) UNIQUE,
    color                  VARCHAR(30),
    current_odometer       INTEGER NOT NULL DEFAULT 0,
    status                 VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_vehicles_1 CHECK (vehicle_type IN ('MOTORCYCLE','CAR')),
    CONSTRAINT chk_vehicles_2 CHECK (current_odometer >= 0),
    CONSTRAINT chk_vehicles_3 CHECK (status IN ('ACTIVE','INACTIVE'))
);
CREATE INDEX idx_vehicles_customer_id ON vehicles(customer_id);

-- SERVICES — Shared catalog of repair / maintenance services (UC10–UC11, UC62).
CREATE TABLE services (
    service_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    service_code           VARCHAR(20) NOT NULL UNIQUE,
    service_name           VARCHAR(150) NOT NULL,
    description            TEXT,
    vehicle_type           VARCHAR(20) NOT NULL DEFAULT 'ALL',
    base_price             NUMERIC(14,2) NOT NULL,
    estimated_minutes      INTEGER NOT NULL,
    status                 VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_services_1 CHECK (base_price >= 0),
    CONSTRAINT chk_services_2 CHECK (estimated_minutes > 0)
);

-- BRANCH_SERVICES — Services enabled per branch, with optional branch price.
CREATE TABLE branch_services (
    branch_id              BIGINT NOT NULL
        REFERENCES branches(branch_id) ON DELETE RESTRICT,
    service_id             BIGINT NOT NULL
        REFERENCES services(service_id) ON DELETE RESTRICT,
    is_enabled             BOOLEAN NOT NULL DEFAULT TRUE,
    branch_price           NUMERIC(14,2),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_branch_services PRIMARY KEY (branch_id, service_id)
);

-- TIME_SLOTS — Bookable reception slots with capacity per branch (UC12, UC63).
CREATE TABLE time_slots (
    slot_id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_id              BIGINT NOT NULL
        REFERENCES branches(branch_id) ON DELETE RESTRICT,
    slot_date              DATE NOT NULL,
    start_time             TIME NOT NULL,
    end_time               TIME NOT NULL,
    capacity               SMALLINT NOT NULL,
    booked_count           SMALLINT NOT NULL DEFAULT 0,
    status                 VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    CONSTRAINT uq_time_slots_branch_id_slot_date_start_time UNIQUE (branch_id, slot_date, start_time),
    CONSTRAINT chk_time_slots_1 CHECK (end_time > start_time),
    CONSTRAINT chk_time_slots_2 CHECK (capacity > 0),
    CONSTRAINT chk_time_slots_3 CHECK (booked_count BETWEEN 0 AND capacity),
    CONSTRAINT chk_time_slots_4 CHECK (status IN ('OPEN','CLOSED'))
);
CREATE INDEX idx_time_slots_branch_id_slot_date ON time_slots(branch_id, slot_date);

-- APPOINTMENTS — Service appointments booked by customers (UC13–UC19).
CREATE TABLE appointments (
    appointment_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointment_code       VARCHAR(20) NOT NULL UNIQUE,
    customer_id            BIGINT NOT NULL
        REFERENCES customers(customer_id) ON DELETE RESTRICT,
    vehicle_id             BIGINT NOT NULL
        REFERENCES vehicles(vehicle_id) ON DELETE RESTRICT,
    branch_id              BIGINT NOT NULL
        REFERENCES branches(branch_id) ON DELETE RESTRICT,
    slot_id                BIGINT NOT NULL
        REFERENCES time_slots(slot_id) ON DELETE RESTRICT,
    status                 VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    customer_note          VARCHAR(500),
    reject_reason          VARCHAR(255),
    cancel_reason          VARCHAR(255),
    confirmed_by           BIGINT
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_appointments_1 CHECK (status IN ('PENDING','CONFIRMED','REJECTED','CHECKED_IN','IN_SERVICE','WAITING_PAYMENT','COMPLETED','CANCELLED'))
);
CREATE INDEX idx_appointments_branch_id_status ON appointments(branch_id, status);
CREATE INDEX idx_appointments_customer_id ON appointments(customer_id);
CREATE INDEX idx_appointments_slot_id ON appointments(slot_id);

-- APPOINTMENT_SERVICES — Services requested in an appointment (M–N).
CREATE TABLE appointment_services (
    appointment_id         BIGINT NOT NULL
        REFERENCES appointments(appointment_id) ON DELETE RESTRICT,
    service_id             BIGINT NOT NULL
        REFERENCES services(service_id) ON DELETE RESTRICT,
    estimated_price        NUMERIC(14,2) NOT NULL,
    CONSTRAINT pk_appointment_services PRIMARY KEY (appointment_id, service_id)
);

-- SERVICE_RATINGS — One customer rating per completed appointment (UC64, BR46–BR47).
CREATE TABLE service_ratings (
    rating_id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointment_id         BIGINT NOT NULL UNIQUE
        REFERENCES appointments(appointment_id) ON DELETE RESTRICT,
    customer_id            BIGINT NOT NULL
        REFERENCES customers(customer_id) ON DELETE RESTRICT,
    score                  SMALLINT NOT NULL,
    comment                VARCHAR(1000),
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_service_ratings_1 CHECK (score BETWEEN 1 AND 5)
);

-- VEHICLE_RECEPTIONS — Check-in record with odometer and condition (UC20, BR15).
CREATE TABLE vehicle_receptions (
    reception_id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointment_id         BIGINT NOT NULL UNIQUE
        REFERENCES appointments(appointment_id) ON DELETE RESTRICT,
    received_by            BIGINT NOT NULL
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    odometer_reading       INTEGER NOT NULL,
    vehicle_condition      VARCHAR(1000) NOT NULL,
    checked_in_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_vehicle_receptions_1 CHECK (odometer_reading >= 0)
);

-- INSPECTIONS — Technical inspection assigned to a mechanic (UC21–UC22).
CREATE TABLE inspections (
    inspection_id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reception_id           BIGINT NOT NULL UNIQUE
        REFERENCES vehicle_receptions(reception_id) ON DELETE RESTRICT,
    mechanic_id            BIGINT NOT NULL
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    assigned_by            BIGINT NOT NULL
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    status                 VARCHAR(20) NOT NULL DEFAULT 'ASSIGNED',
    result_summary         TEXT,
    assigned_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at           TIMESTAMPTZ,
    CONSTRAINT chk_inspections_1 CHECK (status IN ('ASSIGNED','IN_PROGRESS','COMPLETED'))
);
CREATE INDEX idx_inspections_mechanic_id_status ON inspections(mechanic_id, status);

-- PARTS — Shared spare-parts catalog (UC33).
CREATE TABLE parts (
    part_id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku                    VARCHAR(30) NOT NULL UNIQUE,
    part_name              VARCHAR(150) NOT NULL,
    category               VARCHAR(50),
    unit                   VARCHAR(20) NOT NULL DEFAULT 'pcs',
    unit_price             NUMERIC(14,2) NOT NULL,
    status                 VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_parts_1 CHECK (unit_price >= 0)
);

-- INSPECTION_ITEMS — Work and parts recommended by the mechanic, without prices (UC22, 22.E1).
CREATE TABLE inspection_items (
    inspection_item_id     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    inspection_id          BIGINT NOT NULL
        REFERENCES inspections(inspection_id) ON DELETE RESTRICT,
    item_type              VARCHAR(10) NOT NULL,
    service_id             BIGINT
        REFERENCES services(service_id) ON DELETE RESTRICT,
    part_id                BIGINT
        REFERENCES parts(part_id) ON DELETE RESTRICT,
    description            VARCHAR(255) NOT NULL,
    quantity               NUMERIC(10,2) NOT NULL DEFAULT 1,
    priority               VARCHAR(10) NOT NULL DEFAULT 'MEDIUM',
    note                   VARCHAR(500),
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_inspection_items_1 CHECK (item_type IN ('SERVICE','PART','LABOR')),
    CONSTRAINT chk_inspection_items_2 CHECK (quantity > 0),
    CONSTRAINT chk_inspection_items_3 CHECK (priority IN ('HIGH','MEDIUM','LOW'))
);
CREATE INDEX idx_inspection_items_inspection_id ON inspection_items(inspection_id);

-- QUOTATIONS — Priced quotation produced from an inspection (UC23–UC25, BR18).
CREATE TABLE quotations (
    quotation_id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    quotation_code         VARCHAR(20) NOT NULL UNIQUE,
    inspection_id          BIGINT NOT NULL
        REFERENCES inspections(inspection_id) ON DELETE RESTRICT,
    prepared_by            BIGINT NOT NULL
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    parent_quotation_id    BIGINT
        REFERENCES quotations(quotation_id) ON DELETE RESTRICT,
    subtotal               NUMERIC(14,2) NOT NULL DEFAULT 0,
    vat_amount             NUMERIC(14,2) NOT NULL DEFAULT 0,
    total_amount           NUMERIC(14,2) NOT NULL DEFAULT 0,
    status                 VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    valid_until            TIMESTAMPTZ,
    sent_at                TIMESTAMPTZ,
    responded_at           TIMESTAMPTZ,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_quotations_1 CHECK (total_amount >= 0),
    CONSTRAINT chk_quotations_2 CHECK (status IN ('DRAFT','SENT','PARTIALLY_APPROVED','APPROVED','REJECTED','EXPIRED'))
);
CREATE INDEX idx_quotations_inspection_id ON quotations(inspection_id);

-- QUOTATION_ITEMS — Line items with item-level customer decision (BR19–BR20).
CREATE TABLE quotation_items (
    item_id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    quotation_id           BIGINT NOT NULL
        REFERENCES quotations(quotation_id) ON DELETE RESTRICT,
    item_type              VARCHAR(10) NOT NULL,
    service_id             BIGINT
        REFERENCES services(service_id) ON DELETE RESTRICT,
    part_id                BIGINT
        REFERENCES parts(part_id) ON DELETE RESTRICT,
    description            VARCHAR(255) NOT NULL,
    quantity               NUMERIC(10,2) NOT NULL DEFAULT 1,
    unit_price             NUMERIC(14,2) NOT NULL,
    line_total             NUMERIC(14,2) NOT NULL,
    is_warranty            BOOLEAN NOT NULL DEFAULT FALSE,
    expected_wait_days     SMALLINT,
    decision               VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    decided_at             TIMESTAMPTZ,
    CONSTRAINT chk_quotation_items_1 CHECK (item_type IN ('SERVICE','PART','LABOR')),
    CONSTRAINT chk_quotation_items_2 CHECK (quantity > 0),
    CONSTRAINT chk_quotation_items_3 CHECK (unit_price >= 0),
    CONSTRAINT chk_quotation_items_4 CHECK (decision IN ('PENDING','APPROVED','REJECTED'))
);
CREATE INDEX idx_quotation_items_quotation_id ON quotation_items(quotation_id);

-- REPAIR_ORDER_TYPES — Repair order categories with SLA.
CREATE TABLE repair_order_types (
    type_id                SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type_code              VARCHAR(20) NOT NULL UNIQUE,
    type_name              VARCHAR(100) NOT NULL,
    sla_hours              SMALLINT,
    description            VARCHAR(255)
);

-- REPAIR_ORDERS — Workshop repair order created from approved items (UC26–UC32, BR21).
CREATE TABLE repair_orders (
    repair_order_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ro_code                VARCHAR(20) NOT NULL UNIQUE,
    quotation_id           BIGINT NOT NULL UNIQUE
        REFERENCES quotations(quotation_id) ON DELETE RESTRICT,
    branch_id              BIGINT NOT NULL
        REFERENCES branches(branch_id) ON DELETE RESTRICT,
    type_id                SMALLINT NOT NULL
        REFERENCES repair_order_types(type_id) ON DELETE RESTRICT,
    created_by             BIGINT NOT NULL
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    status                 VARCHAR(20) NOT NULL DEFAULT 'NEW',
    total_cost             NUMERIC(14,2) NOT NULL DEFAULT 0,
    started_at             TIMESTAMPTZ,
    completed_at           TIMESTAMPTZ,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_repair_orders_1 CHECK (status IN ('NEW','ASSIGNED','IN_PROGRESS','WAITING_PARTS','COMPLETED','CLOSED')),
    CONSTRAINT chk_repair_orders_2 CHECK (total_cost >= 0)
);
CREATE INDEX idx_repair_orders_branch_id_status ON repair_orders(branch_id, status);

-- REPAIR_TASKS — Tasks of a repair order assigned to mechanics (BR22).
CREATE TABLE repair_tasks (
    task_id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    repair_order_id        BIGINT NOT NULL
        REFERENCES repair_orders(repair_order_id) ON DELETE RESTRICT,
    quotation_item_id      BIGINT
        REFERENCES quotation_items(item_id) ON DELETE RESTRICT,
    mechanic_id            BIGINT
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    task_name              VARCHAR(200) NOT NULL,
    status                 VARCHAR(20) NOT NULL DEFAULT 'TODO',
    progress_percent       SMALLINT NOT NULL DEFAULT 0,
    labor_hours            NUMERIC(5,2) NOT NULL DEFAULT 0,
    started_at             TIMESTAMPTZ,
    finished_at            TIMESTAMPTZ,
    CONSTRAINT chk_repair_tasks_1 CHECK (status IN ('TODO','DOING','BLOCKED','DONE')),
    CONSTRAINT chk_repair_tasks_2 CHECK (progress_percent BETWEEN 0 AND 100),
    CONSTRAINT chk_repair_tasks_3 CHECK (labor_hours >= 0)
);
CREATE INDEX idx_repair_tasks_repair_order_id ON repair_tasks(repair_order_id);
CREATE INDEX idx_repair_tasks_mechanic_id_status ON repair_tasks(mechanic_id, status);

-- REPAIR_NOTES — Technical notes recorded during repair (UC30).
CREATE TABLE repair_notes (
    note_id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    repair_order_id        BIGINT NOT NULL
        REFERENCES repair_orders(repair_order_id) ON DELETE RESTRICT,
    task_id                BIGINT
        REFERENCES repair_tasks(task_id) ON DELETE RESTRICT,
    author_id              BIGINT NOT NULL
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    content                TEXT NOT NULL,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_repair_notes_repair_order_id ON repair_notes(repair_order_id);

-- WAREHOUSES — Spare-part storage of each branch.
CREATE TABLE warehouses (
    warehouse_id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_id              BIGINT NOT NULL
        REFERENCES branches(branch_id) ON DELETE RESTRICT,
    warehouse_name         VARCHAR(100) NOT NULL,
    location               VARCHAR(255),
    status                 VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
);
CREATE INDEX idx_warehouses_branch_id ON warehouses(branch_id);

-- INVENTORIES — On-hand and reserved stock per warehouse and part (UC35, BR25–BR26).
CREATE TABLE inventories (
    inventory_id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    warehouse_id           BIGINT NOT NULL
        REFERENCES warehouses(warehouse_id) ON DELETE RESTRICT,
    part_id                BIGINT NOT NULL
        REFERENCES parts(part_id) ON DELETE RESTRICT,
    quantity_on_hand       INTEGER NOT NULL DEFAULT 0,
    quantity_reserved      INTEGER NOT NULL DEFAULT 0,
    reorder_level          INTEGER NOT NULL DEFAULT 0,
    version                INTEGER NOT NULL DEFAULT 0,
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_inventories_warehouse_id_part_id UNIQUE (warehouse_id, part_id),
    CONSTRAINT chk_inventories_1 CHECK (quantity_on_hand >= 0),
    CONSTRAINT chk_inventories_2 CHECK (quantity_reserved BETWEEN 0 AND quantity_on_hand),
    CONSTRAINT chk_inventories_3 CHECK (reorder_level >= 0)
);

-- INVENTORY_RECEIPTS — Stock receiving documents (UC34).
CREATE TABLE inventory_receipts (
    receipt_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    receipt_code           VARCHAR(20) NOT NULL UNIQUE,
    warehouse_id           BIGINT NOT NULL
        REFERENCES warehouses(warehouse_id) ON DELETE RESTRICT,
    supplier_name          VARCHAR(150) NOT NULL,
    received_by            BIGINT NOT NULL
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    receipt_date           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    note                   VARCHAR(500)
);

-- INVENTORY_RECEIPT_ITEMS — Parts, quantities and costs in a receipt.
CREATE TABLE inventory_receipt_items (
    receipt_item_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    receipt_id             BIGINT NOT NULL
        REFERENCES inventory_receipts(receipt_id) ON DELETE RESTRICT,
    part_id                BIGINT NOT NULL
        REFERENCES parts(part_id) ON DELETE RESTRICT,
    quantity               INTEGER NOT NULL,
    unit_cost              NUMERIC(14,2) NOT NULL,
    CONSTRAINT chk_inventory_receipt_items_1 CHECK (quantity > 0),
    CONSTRAINT chk_inventory_receipt_items_2 CHECK (unit_cost >= 0)
);
CREATE INDEX idx_inventory_receipt_items_receipt_id ON inventory_receipt_items(receipt_id);

-- PART_RESERVATIONS — Parts reserved for a repair order (UC36, BR26).
CREATE TABLE part_reservations (
    reservation_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    repair_order_id        BIGINT NOT NULL
        REFERENCES repair_orders(repair_order_id) ON DELETE RESTRICT,
    quotation_item_id      BIGINT
        REFERENCES quotation_items(item_id) ON DELETE RESTRICT,
    inventory_id           BIGINT NOT NULL
        REFERENCES inventories(inventory_id) ON DELETE RESTRICT,
    quantity               INTEGER NOT NULL,
    status                 VARCHAR(20) NOT NULL DEFAULT 'RESERVED',
    reserved_by            BIGINT NOT NULL
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_part_reservations_1 CHECK (quantity > 0),
    CONSTRAINT chk_part_reservations_2 CHECK (status IN ('RESERVED','ISSUED','RELEASED'))
);
CREATE INDEX idx_part_reservations_repair_order_id ON part_reservations(repair_order_id);

-- PART_REQUESTS — Internal parts request from a mechanic to the receptionist (UC37).
CREATE TABLE part_requests (
    request_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    request_code           VARCHAR(20) NOT NULL UNIQUE,
    repair_order_id        BIGINT NOT NULL
        REFERENCES repair_orders(repair_order_id) ON DELETE RESTRICT,
    task_id                BIGINT
        REFERENCES repair_tasks(task_id) ON DELETE RESTRICT,
    requested_by           BIGINT NOT NULL
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    status                 VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    note                   VARCHAR(500),
    processed_by           BIGINT
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    processed_at           TIMESTAMPTZ,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_part_requests_1 CHECK (status IN ('PENDING','PARTIALLY_ISSUED','ISSUED','REJECTED'))
);
CREATE INDEX idx_part_requests_repair_order_id ON part_requests(repair_order_id);
CREATE INDEX idx_part_requests_status ON part_requests(status);

-- PART_REQUEST_ITEMS — Parts and quantities in a parts request (UC37–UC38).
CREATE TABLE part_request_items (
    request_item_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    request_id             BIGINT NOT NULL
        REFERENCES part_requests(request_id) ON DELETE RESTRICT,
    quotation_item_id      BIGINT NOT NULL
        REFERENCES quotation_items(item_id) ON DELETE RESTRICT,
    part_id                BIGINT NOT NULL
        REFERENCES parts(part_id) ON DELETE RESTRICT,
    quantity_requested     INTEGER NOT NULL,
    quantity_issued        INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT chk_part_request_items_1 CHECK (quantity_requested > 0),
    CONSTRAINT chk_part_request_items_2 CHECK (quantity_issued BETWEEN 0 AND quantity_requested)
);
CREATE INDEX idx_part_request_items_request_id ON part_request_items(request_id);

-- REPAIR_TASK_PARTS — Parts actually issued to / returned from a repair task (UC38–UC39, BR28).
CREATE TABLE repair_task_parts (
    task_part_id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id                BIGINT NOT NULL
        REFERENCES repair_tasks(task_id) ON DELETE RESTRICT,
    inventory_id           BIGINT NOT NULL
        REFERENCES inventories(inventory_id) ON DELETE RESTRICT,
    reservation_id         BIGINT
        REFERENCES part_reservations(reservation_id) ON DELETE RESTRICT,
    request_item_id        BIGINT
        REFERENCES part_request_items(request_item_id) ON DELETE RESTRICT,
    quantity_issued        INTEGER NOT NULL,
    quantity_returned      INTEGER NOT NULL DEFAULT 0,
    unit_price             NUMERIC(14,2) NOT NULL,
    issued_by              BIGINT NOT NULL
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    issued_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_repair_task_parts_1 CHECK (quantity_issued > 0),
    CONSTRAINT chk_repair_task_parts_2 CHECK (quantity_returned BETWEEN 0 AND quantity_issued)
);
CREATE INDEX idx_repair_task_parts_task_id ON repair_task_parts(task_id);

-- INVENTORY_TRANSACTIONS — Immutable stock movement ledger (UC40, BR27).
CREATE TABLE inventory_transactions (
    transaction_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    inventory_id           BIGINT NOT NULL
        REFERENCES inventories(inventory_id) ON DELETE RESTRICT,
    transaction_type       VARCHAR(20) NOT NULL,
    quantity               INTEGER NOT NULL,
    balance_after          INTEGER NOT NULL,
    reference_type         VARCHAR(30) NOT NULL,
    reference_id           BIGINT NOT NULL,
    performed_by           BIGINT NOT NULL
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_inventory_transactions_1 CHECK (transaction_type IN ('RECEIPT','RESERVE','RELEASE','ISSUE','RETURN','ADJUST')),
    CONSTRAINT chk_inventory_transactions_2 CHECK (quantity <> 0)
);
CREATE INDEX idx_inventory_transactions_inventory_id_created_at ON inventory_transactions(inventory_id, created_at);

-- WARRANTY_POLICIES — Warranty terms for services or parts (UC43).
CREATE TABLE warranty_policies (
    policy_id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    policy_code            VARCHAR(20) NOT NULL UNIQUE,
    policy_name            VARCHAR(150) NOT NULL,
    applies_to             VARCHAR(10) NOT NULL,
    service_id             BIGINT
        REFERENCES services(service_id) ON DELETE RESTRICT,
    part_id                BIGINT
        REFERENCES parts(part_id) ON DELETE RESTRICT,
    duration_months        SMALLINT NOT NULL,
    max_odometer_km        INTEGER,
    terms                  TEXT NOT NULL,
    status                 VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_warranty_policies_1 CHECK (applies_to IN ('SERVICE','PART')),
    CONSTRAINT chk_warranty_policies_2 CHECK (duration_months > 0),
    CONSTRAINT chk_warranty_policies_3 CHECK ((applies_to='SERVICE' AND service_id IS NOT NULL) OR (applies_to='PART' AND part_id IS NOT NULL))
);

-- WARRANTIES — Warranty records auto-created after settlement (UC44, BR35).
CREATE TABLE warranties (
    warranty_id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    warranty_code          VARCHAR(20) NOT NULL UNIQUE,
    policy_id              BIGINT NOT NULL
        REFERENCES warranty_policies(policy_id) ON DELETE RESTRICT,
    vehicle_id             BIGINT NOT NULL
        REFERENCES vehicles(vehicle_id) ON DELETE RESTRICT,
    repair_order_id        BIGINT NOT NULL
        REFERENCES repair_orders(repair_order_id) ON DELETE RESTRICT,
    quotation_item_id      BIGINT
        REFERENCES quotation_items(item_id) ON DELETE RESTRICT,
    start_date             DATE NOT NULL,
    end_date               DATE NOT NULL,
    start_odometer         INTEGER NOT NULL,
    max_odometer           INTEGER,
    status                 VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_warranties_1 CHECK (end_date > start_date),
    CONSTRAINT chk_warranties_2 CHECK (status IN ('ACTIVE','EXPIRED','VOID'))
);
CREATE INDEX idx_warranties_vehicle_id_status ON warranties(vehicle_id, status);

-- WARRANTY_REQUESTS — Customer warranty claims and their assessment/approval (UC45–UC47, UC49).
CREATE TABLE warranty_requests (
    request_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    request_code           VARCHAR(20) NOT NULL UNIQUE,
    warranty_id            BIGINT NOT NULL
        REFERENCES warranties(warranty_id) ON DELETE RESTRICT,
    customer_id            BIGINT NOT NULL
        REFERENCES customers(customer_id) ON DELETE RESTRICT,
    branch_id              BIGINT NOT NULL
        REFERENCES branches(branch_id) ON DELETE RESTRICT,
    issue_description      TEXT NOT NULL,
    current_odometer       INTEGER NOT NULL,
    status                 VARCHAR(20) NOT NULL DEFAULT 'SUBMITTED',
    is_eligible            BOOLEAN,
    assessed_by            BIGINT
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    assessment_note        TEXT,
    approved_by            BIGINT
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    decided_at             TIMESTAMPTZ,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_warranty_requests_1 CHECK (status IN ('SUBMITTED','ASSESSED','APPROVED','REJECTED','IN_REPAIR','COMPLETED'))
);
CREATE INDEX idx_warranty_requests_branch_id_status ON warranty_requests(branch_id, status);

-- WARRANTY_REPAIRS — Repair performed for an approved claim with internal cost (UC48, UC50, BR34, BR36).
CREATE TABLE warranty_repairs (
    warranty_repair_id     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    request_id             BIGINT NOT NULL UNIQUE
        REFERENCES warranty_requests(request_id) ON DELETE RESTRICT,
    repair_order_id        BIGINT NOT NULL
        REFERENCES repair_orders(repair_order_id) ON DELETE RESTRICT,
    internal_cost          NUMERIC(14,2) NOT NULL DEFAULT 0,
    customer_charge        NUMERIC(14,2) NOT NULL DEFAULT 0,
    repair_date            DATE NOT NULL,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_warranty_repairs_1 CHECK (internal_cost >= 0),
    CONSTRAINT chk_warranty_repairs_2 CHECK (customer_charge >= 0)
);

-- TAX_RULES — Effective-dated VAT rules (UC51, BR38).
CREATE TABLE tax_rules (
    tax_rule_id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    item_type              VARCHAR(10) NOT NULL,
    vat_rate               NUMERIC(5,2) NOT NULL,
    effective_from         DATE NOT NULL,
    effective_to           DATE,
    created_by             BIGINT NOT NULL
        REFERENCES users(user_id) ON DELETE RESTRICT,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_tax_rules_1 CHECK (vat_rate BETWEEN 0 AND 100),
    CONSTRAINT chk_tax_rules_2 CHECK (effective_to IS NULL OR effective_to > effective_from)
);
CREATE INDEX idx_tax_rules_item_type_effective_from ON tax_rules(item_type, effective_from);

-- EINVOICE_CONFIGS — Seller and MISA meInvoice integration settings (UC51).
CREATE TABLE einvoice_configs (
    config_id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    provider               VARCHAR(30) NOT NULL DEFAULT 'MISA_MEINVOICE',
    seller_name            VARCHAR(255) NOT NULL,
    seller_tax_code        VARCHAR(14) NOT NULL,
    seller_address         VARCHAR(255) NOT NULL,
    api_base_url           VARCHAR(255) NOT NULL,
    invoice_template       VARCHAR(20) NOT NULL,
    invoice_series         VARCHAR(10) NOT NULL,
    credential_ref         VARCHAR(255) NOT NULL,
    is_active              BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- INVOICES — Finalized charges of a repair order (UC52, BR37, BR39).
CREATE TABLE invoices (
    invoice_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_code           VARCHAR(20) NOT NULL UNIQUE,
    repair_order_id        BIGINT NOT NULL UNIQUE
        REFERENCES repair_orders(repair_order_id) ON DELETE RESTRICT,
    billing_id             BIGINT
        REFERENCES billing_information(billing_id) ON DELETE RESTRICT,
    subtotal               NUMERIC(14,2) NOT NULL DEFAULT 0,
    discount_amount        NUMERIC(14,2) NOT NULL DEFAULT 0,
    vat_amount             NUMERIC(14,2) NOT NULL DEFAULT 0,
    total_amount           NUMERIC(14,2) NOT NULL DEFAULT 0,
    payment_status         VARCHAR(20) NOT NULL DEFAULT 'UNPAID',
    status                 VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    finalized_by           BIGINT
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    finalized_at           TIMESTAMPTZ,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_invoices_1 CHECK (total_amount >= 0),
    CONSTRAINT chk_invoices_2 CHECK (payment_status IN ('UNPAID','PAID')),
    CONSTRAINT chk_invoices_3 CHECK (status IN ('DRAFT','FINALIZED','VOID'))
);
CREATE INDEX idx_invoices_payment_status_created_at ON invoices(payment_status, created_at);

-- INVOICE_LINES — Charge lines from performed services, labour and issued parts.
CREATE TABLE invoice_lines (
    line_id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id             BIGINT NOT NULL
        REFERENCES invoices(invoice_id) ON DELETE RESTRICT,
    quotation_item_id      BIGINT
        REFERENCES quotation_items(item_id) ON DELETE RESTRICT,
    item_type              VARCHAR(10) NOT NULL,
    description            VARCHAR(255) NOT NULL,
    quantity               NUMERIC(10,2) NOT NULL,
    unit_price             NUMERIC(14,2) NOT NULL,
    vat_rate               NUMERIC(5,2) NOT NULL,
    vat_amount             NUMERIC(14,2) NOT NULL,
    line_total             NUMERIC(14,2) NOT NULL,
    is_warranty_covered    BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT chk_invoice_lines_1 CHECK (quantity > 0),
    CONSTRAINT chk_invoice_lines_2 CHECK (unit_price >= 0)
);
CREATE INDEX idx_invoice_lines_invoice_id ON invoice_lines(invoice_id);

-- PAYMENTS — Payment transactions recorded by the cashier (UC53).
CREATE TABLE payments (
    payment_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id             BIGINT NOT NULL
        REFERENCES invoices(invoice_id) ON DELETE RESTRICT,
    amount                 NUMERIC(14,2) NOT NULL,
    method                 VARCHAR(20) NOT NULL,
    status                 VARCHAR(20) NOT NULL DEFAULT 'SUCCESS',
    transaction_ref        VARCHAR(100),
    received_by            BIGINT NOT NULL
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    paid_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_payments_1 CHECK (amount > 0),
    CONSTRAINT chk_payments_2 CHECK (method IN ('CASH','CARD','BANK_TRANSFER','E_WALLET')),
    CONSTRAINT chk_payments_3 CHECK (status IN ('SUCCESS','FAILED','REFUNDED'))
);
CREATE INDEX idx_payments_invoice_id ON payments(invoice_id);

-- E_INVOICES — Electronic invoices issued via MISA meInvoice incl. corrections (UC54–UC57, BR40–BR43).
CREATE TABLE e_invoices (
    e_invoice_id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id             BIGINT NOT NULL
        REFERENCES invoices(invoice_id) ON DELETE RESTRICT,
    config_id              BIGINT NOT NULL
        REFERENCES einvoice_configs(config_id) ON DELETE RESTRICT,
    original_e_invoice_id  BIGINT
        REFERENCES e_invoices(e_invoice_id) ON DELETE RESTRICT,
    buyer_name             VARCHAR(255) NOT NULL,
    buyer_tax_code         VARCHAR(14),
    buyer_address          VARCHAR(255) NOT NULL,
    buyer_email            VARCHAR(150) NOT NULL,
    external_invoice_no    VARCHAR(20),
    invoice_series         VARCHAR(10) NOT NULL,
    lookup_code            VARCHAR(50),
    external_status        VARCHAR(30),
    attempt_count          SMALLINT NOT NULL DEFAULT 0,
    status                 VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    correction_type        VARCHAR(20),
    correction_reason      VARCHAR(500),
    response_payload       JSONB,
    issued_at              TIMESTAMPTZ,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_e_invoices_1 CHECK (status IN ('PENDING','ISSUED','FAILED','ADJUSTED','REPLACED','CANCELLED')),
    CONSTRAINT chk_e_invoices_2 CHECK (correction_type IS NULL OR correction_type IN ('ADJUSTMENT','REPLACEMENT'))
);
CREATE INDEX idx_e_invoices_invoice_id ON e_invoices(invoice_id);
CREATE INDEX idx_e_invoices_status ON e_invoices(status);

-- VEHICLE_HANDOVERS — Vehicle handover after payment (UC59, BR44–BR45).
CREATE TABLE vehicle_handovers (
    handover_id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointment_id         BIGINT NOT NULL UNIQUE
        REFERENCES appointments(appointment_id) ON DELETE RESTRICT,
    invoice_id             BIGINT NOT NULL
        REFERENCES invoices(invoice_id) ON DELETE RESTRICT,
    handed_by              BIGINT NOT NULL
        REFERENCES staff(staff_id) ON DELETE RESTRICT,
    odometer_out           INTEGER NOT NULL,
    customer_confirmed     BOOLEAN NOT NULL DEFAULT FALSE,
    note                   VARCHAR(500),
    handed_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Partial unique indexes for business rules
CREATE UNIQUE INDEX uq_billing_default ON billing_information(customer_id) WHERE is_default;
CREATE UNIQUE INDEX uq_einvoice_config_active ON einvoice_configs(is_active) WHERE is_active;

-- Immutable inventory ledger (BR27): forbid UPDATE / DELETE
CREATE OR REPLACE FUNCTION fn_block_modify() RETURNS trigger AS $$
BEGIN RAISE EXCEPTION 'inventory_transactions is append-only'; END; $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_inventory_tx_immutable BEFORE UPDATE OR DELETE ON inventory_transactions
    FOR EACH ROW EXECUTE FUNCTION fn_block_modify();

-- Seed roles
INSERT INTO roles(role_code, role_name) VALUES
  ('CUSTOMER','Customer'),('RECEPTIONIST','Receptionist'),('MECHANIC','Mechanic'),
  ('CASHIER','Cashier'),('BRANCH_MANAGER','Branch Manager'),('SYS_ADMIN','System Administrator');

-- Capacity-safe booking (NFR-4) – executed inside one transaction:
--   SELECT * FROM time_slots WHERE slot_id = $1 FOR UPDATE;
--   UPDATE time_slots SET booked_count = booked_count + 1
--     WHERE slot_id = $1 AND booked_count < capacity;   -- 0 rows => slot full
