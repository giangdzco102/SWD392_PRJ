-- MSSV: HE191633
-- Ho ten: Nguyen Truong Giang

--
-- PostgreSQL database dump
--

\restrict q4eJKuXfk4Uf0yV5v5avHJ0SileyhEC6XW4ht1d12TABugYV6S2jDwmrfMHZxDF

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fn_block_modify(); Type: FUNCTION; Schema: public; Owner: autocare
--

CREATE FUNCTION public.fn_block_modify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN RAISE EXCEPTION 'inventory_transactions is append-only'; END; $$;


ALTER FUNCTION public.fn_block_modify() OWNER TO autocare;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: appointment_services; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.appointment_services (
    appointment_id bigint NOT NULL,
    service_id bigint NOT NULL,
    estimated_price numeric(14,2) NOT NULL
);


ALTER TABLE public.appointment_services OWNER TO autocare;

--
-- Name: appointments; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.appointments (
    appointment_id bigint NOT NULL,
    appointment_code character varying(20) NOT NULL,
    customer_id bigint NOT NULL,
    vehicle_id bigint NOT NULL,
    branch_id bigint NOT NULL,
    slot_id bigint NOT NULL,
    status character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    customer_note character varying(500),
    reject_reason character varying(255),
    cancel_reason character varying(255),
    confirmed_by bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_appointments_1 CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'CONFIRMED'::character varying, 'REJECTED'::character varying, 'CHECKED_IN'::character varying, 'IN_SERVICE'::character varying, 'WAITING_PAYMENT'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[])))
);


ALTER TABLE public.appointments OWNER TO autocare;

--
-- Name: appointments_appointment_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.appointments ALTER COLUMN appointment_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.appointments_appointment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.audit_logs (
    audit_id bigint NOT NULL,
    user_id bigint,
    action character varying(50) NOT NULL,
    entity_name character varying(50) NOT NULL,
    entity_id bigint NOT NULL,
    old_value jsonb,
    new_value jsonb,
    ip_address character varying(45),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.audit_logs OWNER TO autocare;

--
-- Name: audit_logs_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.audit_logs ALTER COLUMN audit_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.audit_logs_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: billing_information; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.billing_information (
    billing_id bigint NOT NULL,
    customer_id bigint NOT NULL,
    buyer_type character varying(20) DEFAULT 'INDIVIDUAL'::character varying NOT NULL,
    buyer_name character varying(150) NOT NULL,
    company_name character varying(255),
    tax_code character varying(14),
    billing_address character varying(255) NOT NULL,
    invoice_email character varying(150) NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_billing_information_1 CHECK (((buyer_type)::text = ANY ((ARRAY['INDIVIDUAL'::character varying, 'COMPANY'::character varying])::text[]))),
    CONSTRAINT chk_billing_information_2 CHECK ((((buyer_type)::text = 'INDIVIDUAL'::text) OR (tax_code IS NOT NULL)))
);


ALTER TABLE public.billing_information OWNER TO autocare;

--
-- Name: billing_information_billing_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.billing_information ALTER COLUMN billing_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.billing_information_billing_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: branch_services; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.branch_services (
    branch_id bigint NOT NULL,
    service_id bigint NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    branch_price numeric(14,2),
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.branch_services OWNER TO autocare;

--
-- Name: branches; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.branches (
    branch_id bigint NOT NULL,
    branch_code character varying(20) NOT NULL,
    branch_name character varying(150) NOT NULL,
    address character varying(255) NOT NULL,
    phone character varying(20),
    email character varying(150),
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_branches_1 CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying])::text[])))
);


ALTER TABLE public.branches OWNER TO autocare;

--
-- Name: branches_branch_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.branches ALTER COLUMN branch_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.branches_branch_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: customers; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.customers (
    customer_id bigint NOT NULL,
    user_id bigint NOT NULL,
    date_of_birth date,
    gender character varying(10),
    address character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_customers_1 CHECK (((gender)::text = ANY ((ARRAY['MALE'::character varying, 'FEMALE'::character varying, 'OTHER'::character varying])::text[])))
);


ALTER TABLE public.customers OWNER TO autocare;

--
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.customers ALTER COLUMN customer_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.customers_customer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: e_invoices; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.e_invoices (
    e_invoice_id bigint NOT NULL,
    invoice_id bigint NOT NULL,
    config_id bigint NOT NULL,
    original_e_invoice_id bigint,
    buyer_name character varying(255) NOT NULL,
    buyer_tax_code character varying(14),
    buyer_address character varying(255) NOT NULL,
    buyer_email character varying(150) NOT NULL,
    external_invoice_no character varying(20),
    invoice_series character varying(10) NOT NULL,
    lookup_code character varying(50),
    external_status character varying(30),
    attempt_count smallint DEFAULT 0 NOT NULL,
    status character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    correction_type character varying(20),
    correction_reason character varying(500),
    response_payload jsonb,
    issued_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_e_invoices_1 CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'ISSUED'::character varying, 'FAILED'::character varying, 'ADJUSTED'::character varying, 'REPLACED'::character varying, 'CANCELLED'::character varying])::text[]))),
    CONSTRAINT chk_e_invoices_2 CHECK (((correction_type IS NULL) OR ((correction_type)::text = ANY ((ARRAY['ADJUSTMENT'::character varying, 'REPLACEMENT'::character varying])::text[]))))
);


ALTER TABLE public.e_invoices OWNER TO autocare;

--
-- Name: e_invoices_e_invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.e_invoices ALTER COLUMN e_invoice_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.e_invoices_e_invoice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: einvoice_configs; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.einvoice_configs (
    config_id bigint NOT NULL,
    provider character varying(30) DEFAULT 'MISA_MEINVOICE'::character varying NOT NULL,
    seller_name character varying(255) NOT NULL,
    seller_tax_code character varying(14) NOT NULL,
    seller_address character varying(255) NOT NULL,
    api_base_url character varying(255) NOT NULL,
    invoice_template character varying(20) NOT NULL,
    invoice_series character varying(10) NOT NULL,
    credential_ref character varying(255) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.einvoice_configs OWNER TO autocare;

--
-- Name: einvoice_configs_config_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.einvoice_configs ALTER COLUMN config_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.einvoice_configs_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: inspection_items; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.inspection_items (
    inspection_item_id bigint NOT NULL,
    inspection_id bigint NOT NULL,
    item_type character varying(10) NOT NULL,
    service_id bigint,
    part_id bigint,
    description character varying(255) NOT NULL,
    quantity numeric(10,2) DEFAULT 1 NOT NULL,
    priority character varying(10) DEFAULT 'MEDIUM'::character varying NOT NULL,
    note character varying(500),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_inspection_items_1 CHECK (((item_type)::text = ANY ((ARRAY['SERVICE'::character varying, 'PART'::character varying, 'LABOR'::character varying])::text[]))),
    CONSTRAINT chk_inspection_items_2 CHECK ((quantity > (0)::numeric)),
    CONSTRAINT chk_inspection_items_3 CHECK (((priority)::text = ANY ((ARRAY['HIGH'::character varying, 'MEDIUM'::character varying, 'LOW'::character varying])::text[])))
);


ALTER TABLE public.inspection_items OWNER TO autocare;

--
-- Name: inspection_items_inspection_item_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.inspection_items ALTER COLUMN inspection_item_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.inspection_items_inspection_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: inspections; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.inspections (
    inspection_id bigint NOT NULL,
    reception_id bigint NOT NULL,
    mechanic_id bigint NOT NULL,
    assigned_by bigint NOT NULL,
    status character varying(20) DEFAULT 'ASSIGNED'::character varying NOT NULL,
    result_summary text,
    assigned_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    CONSTRAINT chk_inspections_1 CHECK (((status)::text = ANY ((ARRAY['ASSIGNED'::character varying, 'IN_PROGRESS'::character varying, 'COMPLETED'::character varying])::text[])))
);


ALTER TABLE public.inspections OWNER TO autocare;

--
-- Name: inspections_inspection_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.inspections ALTER COLUMN inspection_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.inspections_inspection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: inventories; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.inventories (
    inventory_id bigint NOT NULL,
    warehouse_id bigint NOT NULL,
    part_id bigint NOT NULL,
    quantity_on_hand integer DEFAULT 0 NOT NULL,
    quantity_reserved integer DEFAULT 0 NOT NULL,
    reorder_level integer DEFAULT 0 NOT NULL,
    version integer DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_inventories_1 CHECK ((quantity_on_hand >= 0)),
    CONSTRAINT chk_inventories_2 CHECK (((quantity_reserved >= 0) AND (quantity_reserved <= quantity_on_hand))),
    CONSTRAINT chk_inventories_3 CHECK ((reorder_level >= 0))
);


ALTER TABLE public.inventories OWNER TO autocare;

--
-- Name: inventories_inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.inventories ALTER COLUMN inventory_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.inventories_inventory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: inventory_receipt_items; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.inventory_receipt_items (
    receipt_item_id bigint NOT NULL,
    receipt_id bigint NOT NULL,
    part_id bigint NOT NULL,
    quantity integer NOT NULL,
    unit_cost numeric(14,2) NOT NULL,
    CONSTRAINT chk_inventory_receipt_items_1 CHECK ((quantity > 0)),
    CONSTRAINT chk_inventory_receipt_items_2 CHECK ((unit_cost >= (0)::numeric))
);


ALTER TABLE public.inventory_receipt_items OWNER TO autocare;

--
-- Name: inventory_receipt_items_receipt_item_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.inventory_receipt_items ALTER COLUMN receipt_item_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.inventory_receipt_items_receipt_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: inventory_receipts; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.inventory_receipts (
    receipt_id bigint NOT NULL,
    receipt_code character varying(20) NOT NULL,
    warehouse_id bigint NOT NULL,
    supplier_name character varying(150) NOT NULL,
    received_by bigint NOT NULL,
    receipt_date timestamp with time zone DEFAULT now() NOT NULL,
    note character varying(500)
);


ALTER TABLE public.inventory_receipts OWNER TO autocare;

--
-- Name: inventory_receipts_receipt_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.inventory_receipts ALTER COLUMN receipt_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.inventory_receipts_receipt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: inventory_transactions; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.inventory_transactions (
    transaction_id bigint NOT NULL,
    inventory_id bigint NOT NULL,
    transaction_type character varying(20) NOT NULL,
    quantity integer NOT NULL,
    balance_after integer NOT NULL,
    reference_type character varying(30) NOT NULL,
    reference_id bigint NOT NULL,
    performed_by bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_inventory_transactions_1 CHECK (((transaction_type)::text = ANY ((ARRAY['RECEIPT'::character varying, 'RESERVE'::character varying, 'RELEASE'::character varying, 'ISSUE'::character varying, 'RETURN'::character varying, 'ADJUST'::character varying])::text[]))),
    CONSTRAINT chk_inventory_transactions_2 CHECK ((quantity <> 0))
);


ALTER TABLE public.inventory_transactions OWNER TO autocare;

--
-- Name: inventory_transactions_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.inventory_transactions ALTER COLUMN transaction_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.inventory_transactions_transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: invoice_lines; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.invoice_lines (
    line_id bigint NOT NULL,
    invoice_id bigint NOT NULL,
    quotation_item_id bigint,
    item_type character varying(10) NOT NULL,
    description character varying(255) NOT NULL,
    quantity numeric(10,2) NOT NULL,
    unit_price numeric(14,2) NOT NULL,
    vat_rate numeric(5,2) NOT NULL,
    vat_amount numeric(14,2) NOT NULL,
    line_total numeric(14,2) NOT NULL,
    is_warranty_covered boolean DEFAULT false NOT NULL,
    CONSTRAINT chk_invoice_lines_1 CHECK ((quantity > (0)::numeric)),
    CONSTRAINT chk_invoice_lines_2 CHECK ((unit_price >= (0)::numeric))
);


ALTER TABLE public.invoice_lines OWNER TO autocare;

--
-- Name: invoice_lines_line_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.invoice_lines ALTER COLUMN line_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.invoice_lines_line_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.invoices (
    invoice_id bigint NOT NULL,
    invoice_code character varying(20) NOT NULL,
    repair_order_id bigint NOT NULL,
    billing_id bigint,
    subtotal numeric(14,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(14,2) DEFAULT 0 NOT NULL,
    vat_amount numeric(14,2) DEFAULT 0 NOT NULL,
    total_amount numeric(14,2) DEFAULT 0 NOT NULL,
    payment_status character varying(20) DEFAULT 'UNPAID'::character varying NOT NULL,
    status character varying(20) DEFAULT 'DRAFT'::character varying NOT NULL,
    finalized_by bigint,
    finalized_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_invoices_1 CHECK ((total_amount >= (0)::numeric)),
    CONSTRAINT chk_invoices_2 CHECK (((payment_status)::text = ANY ((ARRAY['UNPAID'::character varying, 'PAID'::character varying])::text[]))),
    CONSTRAINT chk_invoices_3 CHECK (((status)::text = ANY ((ARRAY['DRAFT'::character varying, 'FINALIZED'::character varying, 'VOID'::character varying])::text[])))
);


ALTER TABLE public.invoices OWNER TO autocare;

--
-- Name: invoices_invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.invoices ALTER COLUMN invoice_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.invoices_invoice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.notifications (
    notification_id bigint NOT NULL,
    user_id bigint NOT NULL,
    channel character varying(20) DEFAULT 'EMAIL'::character varying NOT NULL,
    title character varying(200) NOT NULL,
    content text NOT NULL,
    reference_type character varying(50),
    reference_id bigint,
    status character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    sent_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_notifications_1 CHECK (((channel)::text = ANY ((ARRAY['EMAIL'::character varying, 'IN_APP'::character varying])::text[]))),
    CONSTRAINT chk_notifications_2 CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'SENT'::character varying, 'FAILED'::character varying, 'READ'::character varying])::text[])))
);


ALTER TABLE public.notifications OWNER TO autocare;

--
-- Name: notifications_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.notifications ALTER COLUMN notification_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.notifications_notification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: part_request_items; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.part_request_items (
    request_item_id bigint NOT NULL,
    request_id bigint NOT NULL,
    quotation_item_id bigint NOT NULL,
    part_id bigint NOT NULL,
    quantity_requested integer NOT NULL,
    quantity_issued integer DEFAULT 0 NOT NULL,
    CONSTRAINT chk_part_request_items_1 CHECK ((quantity_requested > 0)),
    CONSTRAINT chk_part_request_items_2 CHECK (((quantity_issued >= 0) AND (quantity_issued <= quantity_requested)))
);


ALTER TABLE public.part_request_items OWNER TO autocare;

--
-- Name: part_request_items_request_item_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.part_request_items ALTER COLUMN request_item_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.part_request_items_request_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: part_requests; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.part_requests (
    request_id bigint NOT NULL,
    request_code character varying(20) NOT NULL,
    repair_order_id bigint NOT NULL,
    task_id bigint,
    requested_by bigint NOT NULL,
    status character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    note character varying(500),
    processed_by bigint,
    processed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_part_requests_1 CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'PARTIALLY_ISSUED'::character varying, 'ISSUED'::character varying, 'REJECTED'::character varying])::text[])))
);


ALTER TABLE public.part_requests OWNER TO autocare;

--
-- Name: part_requests_request_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.part_requests ALTER COLUMN request_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.part_requests_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: part_reservations; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.part_reservations (
    reservation_id bigint NOT NULL,
    repair_order_id bigint NOT NULL,
    quotation_item_id bigint,
    inventory_id bigint NOT NULL,
    quantity integer NOT NULL,
    status character varying(20) DEFAULT 'RESERVED'::character varying NOT NULL,
    reserved_by bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_part_reservations_1 CHECK ((quantity > 0)),
    CONSTRAINT chk_part_reservations_2 CHECK (((status)::text = ANY ((ARRAY['RESERVED'::character varying, 'ISSUED'::character varying, 'RELEASED'::character varying])::text[])))
);


ALTER TABLE public.part_reservations OWNER TO autocare;

--
-- Name: part_reservations_reservation_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.part_reservations ALTER COLUMN reservation_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.part_reservations_reservation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: parts; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.parts (
    part_id bigint NOT NULL,
    sku character varying(30) NOT NULL,
    part_name character varying(150) NOT NULL,
    category character varying(50),
    unit character varying(20) DEFAULT 'pcs'::character varying NOT NULL,
    unit_price numeric(14,2) NOT NULL,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_parts_1 CHECK ((unit_price >= (0)::numeric))
);


ALTER TABLE public.parts OWNER TO autocare;

--
-- Name: parts_part_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.parts ALTER COLUMN part_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.parts_part_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: payments; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.payments (
    payment_id bigint NOT NULL,
    invoice_id bigint NOT NULL,
    amount numeric(14,2) NOT NULL,
    method character varying(20) NOT NULL,
    status character varying(20) DEFAULT 'SUCCESS'::character varying NOT NULL,
    transaction_ref character varying(100),
    received_by bigint NOT NULL,
    paid_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_payments_1 CHECK ((amount > (0)::numeric)),
    CONSTRAINT chk_payments_2 CHECK (((method)::text = ANY ((ARRAY['CASH'::character varying, 'CARD'::character varying, 'BANK_TRANSFER'::character varying, 'E_WALLET'::character varying])::text[]))),
    CONSTRAINT chk_payments_3 CHECK (((status)::text = ANY ((ARRAY['SUCCESS'::character varying, 'FAILED'::character varying, 'REFUNDED'::character varying])::text[])))
);


ALTER TABLE public.payments OWNER TO autocare;

--
-- Name: payments_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.payments ALTER COLUMN payment_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.payments_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: quotation_items; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.quotation_items (
    item_id bigint NOT NULL,
    quotation_id bigint NOT NULL,
    item_type character varying(10) NOT NULL,
    service_id bigint,
    part_id bigint,
    description character varying(255) NOT NULL,
    quantity numeric(10,2) DEFAULT 1 NOT NULL,
    unit_price numeric(14,2) NOT NULL,
    line_total numeric(14,2) NOT NULL,
    is_warranty boolean DEFAULT false NOT NULL,
    expected_wait_days smallint,
    decision character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    decided_at timestamp with time zone,
    CONSTRAINT chk_quotation_items_1 CHECK (((item_type)::text = ANY ((ARRAY['SERVICE'::character varying, 'PART'::character varying, 'LABOR'::character varying])::text[]))),
    CONSTRAINT chk_quotation_items_2 CHECK ((quantity > (0)::numeric)),
    CONSTRAINT chk_quotation_items_3 CHECK ((unit_price >= (0)::numeric)),
    CONSTRAINT chk_quotation_items_4 CHECK (((decision)::text = ANY ((ARRAY['PENDING'::character varying, 'APPROVED'::character varying, 'REJECTED'::character varying])::text[])))
);


ALTER TABLE public.quotation_items OWNER TO autocare;

--
-- Name: quotation_items_item_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.quotation_items ALTER COLUMN item_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.quotation_items_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: quotations; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.quotations (
    quotation_id bigint NOT NULL,
    quotation_code character varying(20) NOT NULL,
    inspection_id bigint NOT NULL,
    prepared_by bigint NOT NULL,
    parent_quotation_id bigint,
    subtotal numeric(14,2) DEFAULT 0 NOT NULL,
    vat_amount numeric(14,2) DEFAULT 0 NOT NULL,
    total_amount numeric(14,2) DEFAULT 0 NOT NULL,
    status character varying(20) DEFAULT 'DRAFT'::character varying NOT NULL,
    valid_until timestamp with time zone,
    sent_at timestamp with time zone,
    responded_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_quotations_1 CHECK ((total_amount >= (0)::numeric)),
    CONSTRAINT chk_quotations_2 CHECK (((status)::text = ANY ((ARRAY['DRAFT'::character varying, 'SENT'::character varying, 'PARTIALLY_APPROVED'::character varying, 'APPROVED'::character varying, 'REJECTED'::character varying, 'EXPIRED'::character varying])::text[])))
);


ALTER TABLE public.quotations OWNER TO autocare;

--
-- Name: quotations_quotation_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.quotations ALTER COLUMN quotation_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.quotations_quotation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: repair_notes; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.repair_notes (
    note_id bigint NOT NULL,
    repair_order_id bigint NOT NULL,
    task_id bigint,
    author_id bigint NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.repair_notes OWNER TO autocare;

--
-- Name: repair_notes_note_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.repair_notes ALTER COLUMN note_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.repair_notes_note_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: repair_order_types; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.repair_order_types (
    type_id smallint NOT NULL,
    type_code character varying(20) NOT NULL,
    type_name character varying(100) NOT NULL,
    sla_hours smallint,
    description character varying(255)
);


ALTER TABLE public.repair_order_types OWNER TO autocare;

--
-- Name: repair_order_types_type_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.repair_order_types ALTER COLUMN type_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.repair_order_types_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: repair_orders; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.repair_orders (
    repair_order_id bigint NOT NULL,
    ro_code character varying(20) NOT NULL,
    quotation_id bigint NOT NULL,
    branch_id bigint NOT NULL,
    type_id smallint NOT NULL,
    created_by bigint NOT NULL,
    status character varying(20) DEFAULT 'NEW'::character varying NOT NULL,
    total_cost numeric(14,2) DEFAULT 0 NOT NULL,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_repair_orders_1 CHECK (((status)::text = ANY ((ARRAY['NEW'::character varying, 'ASSIGNED'::character varying, 'IN_PROGRESS'::character varying, 'WAITING_PARTS'::character varying, 'COMPLETED'::character varying, 'CLOSED'::character varying])::text[]))),
    CONSTRAINT chk_repair_orders_2 CHECK ((total_cost >= (0)::numeric))
);


ALTER TABLE public.repair_orders OWNER TO autocare;

--
-- Name: repair_orders_repair_order_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.repair_orders ALTER COLUMN repair_order_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.repair_orders_repair_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: repair_task_parts; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.repair_task_parts (
    task_part_id bigint NOT NULL,
    task_id bigint NOT NULL,
    inventory_id bigint NOT NULL,
    reservation_id bigint,
    request_item_id bigint,
    quantity_issued integer NOT NULL,
    quantity_returned integer DEFAULT 0 NOT NULL,
    unit_price numeric(14,2) NOT NULL,
    issued_by bigint NOT NULL,
    issued_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_repair_task_parts_1 CHECK ((quantity_issued > 0)),
    CONSTRAINT chk_repair_task_parts_2 CHECK (((quantity_returned >= 0) AND (quantity_returned <= quantity_issued)))
);


ALTER TABLE public.repair_task_parts OWNER TO autocare;

--
-- Name: repair_task_parts_task_part_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.repair_task_parts ALTER COLUMN task_part_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.repair_task_parts_task_part_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: repair_tasks; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.repair_tasks (
    task_id bigint NOT NULL,
    repair_order_id bigint NOT NULL,
    quotation_item_id bigint,
    mechanic_id bigint,
    task_name character varying(200) NOT NULL,
    status character varying(20) DEFAULT 'TODO'::character varying NOT NULL,
    progress_percent smallint DEFAULT 0 NOT NULL,
    labor_hours numeric(5,2) DEFAULT 0 NOT NULL,
    started_at timestamp with time zone,
    finished_at timestamp with time zone,
    CONSTRAINT chk_repair_tasks_1 CHECK (((status)::text = ANY ((ARRAY['TODO'::character varying, 'DOING'::character varying, 'BLOCKED'::character varying, 'DONE'::character varying])::text[]))),
    CONSTRAINT chk_repair_tasks_2 CHECK (((progress_percent >= 0) AND (progress_percent <= 100))),
    CONSTRAINT chk_repair_tasks_3 CHECK ((labor_hours >= (0)::numeric))
);


ALTER TABLE public.repair_tasks OWNER TO autocare;

--
-- Name: repair_tasks_task_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.repair_tasks ALTER COLUMN task_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.repair_tasks_task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.roles (
    role_id smallint NOT NULL,
    role_code character varying(30) NOT NULL,
    role_name character varying(100) NOT NULL,
    description character varying(255)
);


ALTER TABLE public.roles OWNER TO autocare;

--
-- Name: roles_role_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.roles ALTER COLUMN role_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.roles_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: service_ratings; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.service_ratings (
    rating_id bigint NOT NULL,
    appointment_id bigint NOT NULL,
    customer_id bigint NOT NULL,
    score smallint NOT NULL,
    comment character varying(1000),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_service_ratings_1 CHECK (((score >= 1) AND (score <= 5)))
);


ALTER TABLE public.service_ratings OWNER TO autocare;

--
-- Name: service_ratings_rating_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.service_ratings ALTER COLUMN rating_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.service_ratings_rating_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: services; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.services (
    service_id bigint NOT NULL,
    service_code character varying(20) NOT NULL,
    service_name character varying(150) NOT NULL,
    description text,
    vehicle_type character varying(20) DEFAULT 'ALL'::character varying NOT NULL,
    base_price numeric(14,2) NOT NULL,
    estimated_minutes integer NOT NULL,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_services_1 CHECK ((base_price >= (0)::numeric)),
    CONSTRAINT chk_services_2 CHECK ((estimated_minutes > 0))
);


ALTER TABLE public.services OWNER TO autocare;

--
-- Name: services_service_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.services ALTER COLUMN service_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.services_service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: staff; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.staff (
    staff_id bigint NOT NULL,
    user_id bigint NOT NULL,
    branch_id bigint,
    staff_code character varying(20) NOT NULL,
    "position" character varying(30) NOT NULL,
    hired_date date,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_staff_1 CHECK ((("position")::text = ANY ((ARRAY['RECEPTIONIST'::character varying, 'MECHANIC'::character varying, 'CASHIER'::character varying, 'BRANCH_MANAGER'::character varying, 'SYS_ADMIN'::character varying])::text[])))
);


ALTER TABLE public.staff OWNER TO autocare;

--
-- Name: staff_staff_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.staff ALTER COLUMN staff_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.staff_staff_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tax_rules; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.tax_rules (
    tax_rule_id bigint NOT NULL,
    item_type character varying(10) NOT NULL,
    vat_rate numeric(5,2) NOT NULL,
    effective_from date NOT NULL,
    effective_to date,
    created_by bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_tax_rules_1 CHECK (((vat_rate >= (0)::numeric) AND (vat_rate <= (100)::numeric))),
    CONSTRAINT chk_tax_rules_2 CHECK (((effective_to IS NULL) OR (effective_to > effective_from)))
);


ALTER TABLE public.tax_rules OWNER TO autocare;

--
-- Name: tax_rules_tax_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.tax_rules ALTER COLUMN tax_rule_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tax_rules_tax_rule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: time_slots; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.time_slots (
    slot_id bigint NOT NULL,
    branch_id bigint NOT NULL,
    slot_date date NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    capacity smallint NOT NULL,
    booked_count smallint DEFAULT 0 NOT NULL,
    status character varying(20) DEFAULT 'OPEN'::character varying NOT NULL,
    CONSTRAINT chk_time_slots_1 CHECK ((end_time > start_time)),
    CONSTRAINT chk_time_slots_2 CHECK ((capacity > 0)),
    CONSTRAINT chk_time_slots_3 CHECK (((booked_count >= 0) AND (booked_count <= capacity))),
    CONSTRAINT chk_time_slots_4 CHECK (((status)::text = ANY ((ARRAY['OPEN'::character varying, 'CLOSED'::character varying])::text[])))
);


ALTER TABLE public.time_slots OWNER TO autocare;

--
-- Name: time_slots_slot_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.time_slots ALTER COLUMN slot_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.time_slots_slot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.users (
    user_id bigint NOT NULL,
    role_id smallint NOT NULL,
    email character varying(150) NOT NULL,
    phone character varying(20),
    password_hash character varying(255) NOT NULL,
    full_name character varying(150) NOT NULL,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    failed_login_count smallint DEFAULT 0 NOT NULL,
    locked_until timestamp with time zone,
    last_login_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_users_1 CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'LOCKED'::character varying, 'INACTIVE'::character varying])::text[]))),
    CONSTRAINT chk_users_2 CHECK ((failed_login_count >= 0))
);


ALTER TABLE public.users OWNER TO autocare;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.users ALTER COLUMN user_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vehicle_handovers; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.vehicle_handovers (
    handover_id bigint NOT NULL,
    appointment_id bigint NOT NULL,
    invoice_id bigint NOT NULL,
    handed_by bigint NOT NULL,
    odometer_out integer NOT NULL,
    customer_confirmed boolean DEFAULT false NOT NULL,
    note character varying(500),
    handed_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.vehicle_handovers OWNER TO autocare;

--
-- Name: vehicle_handovers_handover_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.vehicle_handovers ALTER COLUMN handover_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.vehicle_handovers_handover_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vehicle_receptions; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.vehicle_receptions (
    reception_id bigint NOT NULL,
    appointment_id bigint NOT NULL,
    received_by bigint NOT NULL,
    odometer_reading integer NOT NULL,
    vehicle_condition character varying(1000) NOT NULL,
    checked_in_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_vehicle_receptions_1 CHECK ((odometer_reading >= 0))
);


ALTER TABLE public.vehicle_receptions OWNER TO autocare;

--
-- Name: vehicle_receptions_reception_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.vehicle_receptions ALTER COLUMN reception_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.vehicle_receptions_reception_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.vehicles (
    vehicle_id bigint NOT NULL,
    customer_id bigint NOT NULL,
    license_plate character varying(15) NOT NULL,
    vehicle_type character varying(20) NOT NULL,
    brand character varying(50) NOT NULL,
    model character varying(50) NOT NULL,
    manufacture_year smallint,
    vin character varying(17),
    color character varying(30),
    current_odometer integer DEFAULT 0 NOT NULL,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_vehicles_1 CHECK (((vehicle_type)::text = ANY ((ARRAY['MOTORCYCLE'::character varying, 'CAR'::character varying])::text[]))),
    CONSTRAINT chk_vehicles_2 CHECK ((current_odometer >= 0)),
    CONSTRAINT chk_vehicles_3 CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying])::text[])))
);


ALTER TABLE public.vehicles OWNER TO autocare;

--
-- Name: vehicles_vehicle_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.vehicles ALTER COLUMN vehicle_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.vehicles_vehicle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: warehouses; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.warehouses (
    warehouse_id bigint NOT NULL,
    branch_id bigint NOT NULL,
    warehouse_name character varying(100) NOT NULL,
    location character varying(255),
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL
);


ALTER TABLE public.warehouses OWNER TO autocare;

--
-- Name: warehouses_warehouse_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.warehouses ALTER COLUMN warehouse_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.warehouses_warehouse_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: warranties; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.warranties (
    warranty_id bigint NOT NULL,
    warranty_code character varying(20) NOT NULL,
    policy_id bigint NOT NULL,
    vehicle_id bigint NOT NULL,
    repair_order_id bigint NOT NULL,
    quotation_item_id bigint,
    start_date date NOT NULL,
    end_date date NOT NULL,
    start_odometer integer NOT NULL,
    max_odometer integer,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_warranties_1 CHECK ((end_date > start_date)),
    CONSTRAINT chk_warranties_2 CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'EXPIRED'::character varying, 'VOID'::character varying])::text[])))
);


ALTER TABLE public.warranties OWNER TO autocare;

--
-- Name: warranties_warranty_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.warranties ALTER COLUMN warranty_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.warranties_warranty_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: warranty_policies; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.warranty_policies (
    policy_id bigint NOT NULL,
    policy_code character varying(20) NOT NULL,
    policy_name character varying(150) NOT NULL,
    applies_to character varying(10) NOT NULL,
    service_id bigint,
    part_id bigint,
    duration_months smallint NOT NULL,
    max_odometer_km integer,
    terms text NOT NULL,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_warranty_policies_1 CHECK (((applies_to)::text = ANY ((ARRAY['SERVICE'::character varying, 'PART'::character varying])::text[]))),
    CONSTRAINT chk_warranty_policies_2 CHECK ((duration_months > 0)),
    CONSTRAINT chk_warranty_policies_3 CHECK (((((applies_to)::text = 'SERVICE'::text) AND (service_id IS NOT NULL)) OR (((applies_to)::text = 'PART'::text) AND (part_id IS NOT NULL))))
);


ALTER TABLE public.warranty_policies OWNER TO autocare;

--
-- Name: warranty_policies_policy_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.warranty_policies ALTER COLUMN policy_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.warranty_policies_policy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: warranty_repairs; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.warranty_repairs (
    warranty_repair_id bigint NOT NULL,
    request_id bigint NOT NULL,
    repair_order_id bigint NOT NULL,
    internal_cost numeric(14,2) DEFAULT 0 NOT NULL,
    customer_charge numeric(14,2) DEFAULT 0 NOT NULL,
    repair_date date NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_warranty_repairs_1 CHECK ((internal_cost >= (0)::numeric)),
    CONSTRAINT chk_warranty_repairs_2 CHECK ((customer_charge >= (0)::numeric))
);


ALTER TABLE public.warranty_repairs OWNER TO autocare;

--
-- Name: warranty_repairs_warranty_repair_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.warranty_repairs ALTER COLUMN warranty_repair_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.warranty_repairs_warranty_repair_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: warranty_requests; Type: TABLE; Schema: public; Owner: autocare
--

CREATE TABLE public.warranty_requests (
    request_id bigint NOT NULL,
    request_code character varying(20) NOT NULL,
    warranty_id bigint NOT NULL,
    customer_id bigint NOT NULL,
    branch_id bigint NOT NULL,
    issue_description text NOT NULL,
    current_odometer integer NOT NULL,
    status character varying(20) DEFAULT 'SUBMITTED'::character varying NOT NULL,
    is_eligible boolean,
    assessed_by bigint,
    assessment_note text,
    approved_by bigint,
    decided_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_warranty_requests_1 CHECK (((status)::text = ANY ((ARRAY['SUBMITTED'::character varying, 'ASSESSED'::character varying, 'APPROVED'::character varying, 'REJECTED'::character varying, 'IN_REPAIR'::character varying, 'COMPLETED'::character varying])::text[])))
);


ALTER TABLE public.warranty_requests OWNER TO autocare;

--
-- Name: warranty_requests_request_id_seq; Type: SEQUENCE; Schema: public; Owner: autocare
--

ALTER TABLE public.warranty_requests ALTER COLUMN request_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.warranty_requests_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: appointments appointments_appointment_code_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_appointment_code_key UNIQUE (appointment_code);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (appointment_id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (audit_id);


--
-- Name: billing_information billing_information_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.billing_information
    ADD CONSTRAINT billing_information_pkey PRIMARY KEY (billing_id);


--
-- Name: branches branches_branch_code_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_branch_code_key UNIQUE (branch_code);


--
-- Name: branches branches_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (branch_id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: customers customers_user_id_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_user_id_key UNIQUE (user_id);


--
-- Name: e_invoices e_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.e_invoices
    ADD CONSTRAINT e_invoices_pkey PRIMARY KEY (e_invoice_id);


--
-- Name: einvoice_configs einvoice_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.einvoice_configs
    ADD CONSTRAINT einvoice_configs_pkey PRIMARY KEY (config_id);


--
-- Name: inspection_items inspection_items_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inspection_items
    ADD CONSTRAINT inspection_items_pkey PRIMARY KEY (inspection_item_id);


--
-- Name: inspections inspections_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inspections
    ADD CONSTRAINT inspections_pkey PRIMARY KEY (inspection_id);


--
-- Name: inspections inspections_reception_id_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inspections
    ADD CONSTRAINT inspections_reception_id_key UNIQUE (reception_id);


--
-- Name: inventories inventories_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inventories
    ADD CONSTRAINT inventories_pkey PRIMARY KEY (inventory_id);


--
-- Name: inventory_receipt_items inventory_receipt_items_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inventory_receipt_items
    ADD CONSTRAINT inventory_receipt_items_pkey PRIMARY KEY (receipt_item_id);


--
-- Name: inventory_receipts inventory_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inventory_receipts
    ADD CONSTRAINT inventory_receipts_pkey PRIMARY KEY (receipt_id);


--
-- Name: inventory_receipts inventory_receipts_receipt_code_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inventory_receipts
    ADD CONSTRAINT inventory_receipts_receipt_code_key UNIQUE (receipt_code);


--
-- Name: inventory_transactions inventory_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_pkey PRIMARY KEY (transaction_id);


--
-- Name: invoice_lines invoice_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.invoice_lines
    ADD CONSTRAINT invoice_lines_pkey PRIMARY KEY (line_id);


--
-- Name: invoices invoices_invoice_code_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_code_key UNIQUE (invoice_code);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (invoice_id);


--
-- Name: invoices invoices_repair_order_id_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_repair_order_id_key UNIQUE (repair_order_id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (notification_id);


--
-- Name: part_request_items part_request_items_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.part_request_items
    ADD CONSTRAINT part_request_items_pkey PRIMARY KEY (request_item_id);


--
-- Name: part_requests part_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.part_requests
    ADD CONSTRAINT part_requests_pkey PRIMARY KEY (request_id);


--
-- Name: part_requests part_requests_request_code_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.part_requests
    ADD CONSTRAINT part_requests_request_code_key UNIQUE (request_code);


--
-- Name: part_reservations part_reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.part_reservations
    ADD CONSTRAINT part_reservations_pkey PRIMARY KEY (reservation_id);


--
-- Name: parts parts_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.parts
    ADD CONSTRAINT parts_pkey PRIMARY KEY (part_id);


--
-- Name: parts parts_sku_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.parts
    ADD CONSTRAINT parts_sku_key UNIQUE (sku);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- Name: appointment_services pk_appointment_services; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.appointment_services
    ADD CONSTRAINT pk_appointment_services PRIMARY KEY (appointment_id, service_id);


--
-- Name: branch_services pk_branch_services; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.branch_services
    ADD CONSTRAINT pk_branch_services PRIMARY KEY (branch_id, service_id);


--
-- Name: quotation_items quotation_items_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.quotation_items
    ADD CONSTRAINT quotation_items_pkey PRIMARY KEY (item_id);


--
-- Name: quotations quotations_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_pkey PRIMARY KEY (quotation_id);


--
-- Name: quotations quotations_quotation_code_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_quotation_code_key UNIQUE (quotation_code);


--
-- Name: repair_notes repair_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_notes
    ADD CONSTRAINT repair_notes_pkey PRIMARY KEY (note_id);


--
-- Name: repair_order_types repair_order_types_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_order_types
    ADD CONSTRAINT repair_order_types_pkey PRIMARY KEY (type_id);


--
-- Name: repair_order_types repair_order_types_type_code_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_order_types
    ADD CONSTRAINT repair_order_types_type_code_key UNIQUE (type_code);


--
-- Name: repair_orders repair_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_orders
    ADD CONSTRAINT repair_orders_pkey PRIMARY KEY (repair_order_id);


--
-- Name: repair_orders repair_orders_quotation_id_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_orders
    ADD CONSTRAINT repair_orders_quotation_id_key UNIQUE (quotation_id);


--
-- Name: repair_orders repair_orders_ro_code_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_orders
    ADD CONSTRAINT repair_orders_ro_code_key UNIQUE (ro_code);


--
-- Name: repair_task_parts repair_task_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_task_parts
    ADD CONSTRAINT repair_task_parts_pkey PRIMARY KEY (task_part_id);


--
-- Name: repair_tasks repair_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_tasks
    ADD CONSTRAINT repair_tasks_pkey PRIMARY KEY (task_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);


--
-- Name: roles roles_role_code_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_role_code_key UNIQUE (role_code);


--
-- Name: service_ratings service_ratings_appointment_id_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.service_ratings
    ADD CONSTRAINT service_ratings_appointment_id_key UNIQUE (appointment_id);


--
-- Name: service_ratings service_ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.service_ratings
    ADD CONSTRAINT service_ratings_pkey PRIMARY KEY (rating_id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (service_id);


--
-- Name: services services_service_code_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_service_code_key UNIQUE (service_code);


--
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (staff_id);


--
-- Name: staff staff_staff_code_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_staff_code_key UNIQUE (staff_code);


--
-- Name: staff staff_user_id_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_user_id_key UNIQUE (user_id);


--
-- Name: tax_rules tax_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.tax_rules
    ADD CONSTRAINT tax_rules_pkey PRIMARY KEY (tax_rule_id);


--
-- Name: time_slots time_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.time_slots
    ADD CONSTRAINT time_slots_pkey PRIMARY KEY (slot_id);


--
-- Name: inventories uq_inventories_warehouse_id_part_id; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inventories
    ADD CONSTRAINT uq_inventories_warehouse_id_part_id UNIQUE (warehouse_id, part_id);


--
-- Name: time_slots uq_time_slots_branch_id_slot_date_start_time; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.time_slots
    ADD CONSTRAINT uq_time_slots_branch_id_slot_date_start_time UNIQUE (branch_id, slot_date, start_time);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: vehicle_handovers vehicle_handovers_appointment_id_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.vehicle_handovers
    ADD CONSTRAINT vehicle_handovers_appointment_id_key UNIQUE (appointment_id);


--
-- Name: vehicle_handovers vehicle_handovers_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.vehicle_handovers
    ADD CONSTRAINT vehicle_handovers_pkey PRIMARY KEY (handover_id);


--
-- Name: vehicle_receptions vehicle_receptions_appointment_id_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.vehicle_receptions
    ADD CONSTRAINT vehicle_receptions_appointment_id_key UNIQUE (appointment_id);


--
-- Name: vehicle_receptions vehicle_receptions_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.vehicle_receptions
    ADD CONSTRAINT vehicle_receptions_pkey PRIMARY KEY (reception_id);


--
-- Name: vehicles vehicles_license_plate_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_license_plate_key UNIQUE (license_plate);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (vehicle_id);


--
-- Name: vehicles vehicles_vin_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_vin_key UNIQUE (vin);


--
-- Name: warehouses warehouses_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_pkey PRIMARY KEY (warehouse_id);


--
-- Name: warranties warranties_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranties
    ADD CONSTRAINT warranties_pkey PRIMARY KEY (warranty_id);


--
-- Name: warranties warranties_warranty_code_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranties
    ADD CONSTRAINT warranties_warranty_code_key UNIQUE (warranty_code);


--
-- Name: warranty_policies warranty_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranty_policies
    ADD CONSTRAINT warranty_policies_pkey PRIMARY KEY (policy_id);


--
-- Name: warranty_policies warranty_policies_policy_code_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranty_policies
    ADD CONSTRAINT warranty_policies_policy_code_key UNIQUE (policy_code);


--
-- Name: warranty_repairs warranty_repairs_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranty_repairs
    ADD CONSTRAINT warranty_repairs_pkey PRIMARY KEY (warranty_repair_id);


--
-- Name: warranty_repairs warranty_repairs_request_id_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranty_repairs
    ADD CONSTRAINT warranty_repairs_request_id_key UNIQUE (request_id);


--
-- Name: warranty_requests warranty_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranty_requests
    ADD CONSTRAINT warranty_requests_pkey PRIMARY KEY (request_id);


--
-- Name: warranty_requests warranty_requests_request_code_key; Type: CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranty_requests
    ADD CONSTRAINT warranty_requests_request_code_key UNIQUE (request_code);


--
-- Name: idx_appointments_branch_id_status; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_appointments_branch_id_status ON public.appointments USING btree (branch_id, status);


--
-- Name: idx_appointments_customer_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_appointments_customer_id ON public.appointments USING btree (customer_id);


--
-- Name: idx_appointments_slot_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_appointments_slot_id ON public.appointments USING btree (slot_id);


--
-- Name: idx_audit_logs_entity_name_entity_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_audit_logs_entity_name_entity_id ON public.audit_logs USING btree (entity_name, entity_id);


--
-- Name: idx_billing_information_customer_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_billing_information_customer_id ON public.billing_information USING btree (customer_id);


--
-- Name: idx_e_invoices_invoice_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_e_invoices_invoice_id ON public.e_invoices USING btree (invoice_id);


--
-- Name: idx_e_invoices_status; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_e_invoices_status ON public.e_invoices USING btree (status);


--
-- Name: idx_inspection_items_inspection_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_inspection_items_inspection_id ON public.inspection_items USING btree (inspection_id);


--
-- Name: idx_inspections_mechanic_id_status; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_inspections_mechanic_id_status ON public.inspections USING btree (mechanic_id, status);


--
-- Name: idx_inventory_receipt_items_receipt_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_inventory_receipt_items_receipt_id ON public.inventory_receipt_items USING btree (receipt_id);


--
-- Name: idx_inventory_transactions_inventory_id_created_at; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_inventory_transactions_inventory_id_created_at ON public.inventory_transactions USING btree (inventory_id, created_at);


--
-- Name: idx_invoice_lines_invoice_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_invoice_lines_invoice_id ON public.invoice_lines USING btree (invoice_id);


--
-- Name: idx_invoices_payment_status_created_at; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_invoices_payment_status_created_at ON public.invoices USING btree (payment_status, created_at);


--
-- Name: idx_notifications_user_id_status; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_notifications_user_id_status ON public.notifications USING btree (user_id, status);


--
-- Name: idx_part_request_items_request_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_part_request_items_request_id ON public.part_request_items USING btree (request_id);


--
-- Name: idx_part_requests_repair_order_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_part_requests_repair_order_id ON public.part_requests USING btree (repair_order_id);


--
-- Name: idx_part_requests_status; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_part_requests_status ON public.part_requests USING btree (status);


--
-- Name: idx_part_reservations_repair_order_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_part_reservations_repair_order_id ON public.part_reservations USING btree (repair_order_id);


--
-- Name: idx_payments_invoice_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_payments_invoice_id ON public.payments USING btree (invoice_id);


--
-- Name: idx_quotation_items_quotation_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_quotation_items_quotation_id ON public.quotation_items USING btree (quotation_id);


--
-- Name: idx_quotations_inspection_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_quotations_inspection_id ON public.quotations USING btree (inspection_id);


--
-- Name: idx_repair_notes_repair_order_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_repair_notes_repair_order_id ON public.repair_notes USING btree (repair_order_id);


--
-- Name: idx_repair_orders_branch_id_status; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_repair_orders_branch_id_status ON public.repair_orders USING btree (branch_id, status);


--
-- Name: idx_repair_task_parts_task_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_repair_task_parts_task_id ON public.repair_task_parts USING btree (task_id);


--
-- Name: idx_repair_tasks_mechanic_id_status; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_repair_tasks_mechanic_id_status ON public.repair_tasks USING btree (mechanic_id, status);


--
-- Name: idx_repair_tasks_repair_order_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_repair_tasks_repair_order_id ON public.repair_tasks USING btree (repair_order_id);


--
-- Name: idx_staff_branch_id_position; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_staff_branch_id_position ON public.staff USING btree (branch_id, "position");


--
-- Name: idx_tax_rules_item_type_effective_from; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_tax_rules_item_type_effective_from ON public.tax_rules USING btree (item_type, effective_from);


--
-- Name: idx_time_slots_branch_id_slot_date; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_time_slots_branch_id_slot_date ON public.time_slots USING btree (branch_id, slot_date);


--
-- Name: idx_users_role_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_users_role_id ON public.users USING btree (role_id);


--
-- Name: idx_vehicles_customer_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_vehicles_customer_id ON public.vehicles USING btree (customer_id);


--
-- Name: idx_warehouses_branch_id; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_warehouses_branch_id ON public.warehouses USING btree (branch_id);


--
-- Name: idx_warranties_vehicle_id_status; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_warranties_vehicle_id_status ON public.warranties USING btree (vehicle_id, status);


--
-- Name: idx_warranty_requests_branch_id_status; Type: INDEX; Schema: public; Owner: autocare
--

CREATE INDEX idx_warranty_requests_branch_id_status ON public.warranty_requests USING btree (branch_id, status);


--
-- Name: uq_billing_default; Type: INDEX; Schema: public; Owner: autocare
--

CREATE UNIQUE INDEX uq_billing_default ON public.billing_information USING btree (customer_id) WHERE is_default;


--
-- Name: uq_einvoice_config_active; Type: INDEX; Schema: public; Owner: autocare
--

CREATE UNIQUE INDEX uq_einvoice_config_active ON public.einvoice_configs USING btree (is_active) WHERE is_active;


--
-- Name: inventory_transactions trg_inventory_tx_immutable; Type: TRIGGER; Schema: public; Owner: autocare
--

CREATE TRIGGER trg_inventory_tx_immutable BEFORE DELETE OR UPDATE ON public.inventory_transactions FOR EACH ROW EXECUTE FUNCTION public.fn_block_modify();


--
-- Name: appointment_services appointment_services_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.appointment_services
    ADD CONSTRAINT appointment_services_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(appointment_id) ON DELETE RESTRICT;


--
-- Name: appointment_services appointment_services_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.appointment_services
    ADD CONSTRAINT appointment_services_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(service_id) ON DELETE RESTRICT;


--
-- Name: appointments appointments_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id) ON DELETE RESTRICT;


--
-- Name: appointments appointments_confirmed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_confirmed_by_fkey FOREIGN KEY (confirmed_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: appointments appointments_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON DELETE RESTRICT;


--
-- Name: appointments appointments_slot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_slot_id_fkey FOREIGN KEY (slot_id) REFERENCES public.time_slots(slot_id) ON DELETE RESTRICT;


--
-- Name: appointments appointments_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id) ON DELETE RESTRICT;


--
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: billing_information billing_information_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.billing_information
    ADD CONSTRAINT billing_information_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON DELETE RESTRICT;


--
-- Name: branch_services branch_services_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.branch_services
    ADD CONSTRAINT branch_services_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id) ON DELETE RESTRICT;


--
-- Name: branch_services branch_services_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.branch_services
    ADD CONSTRAINT branch_services_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(service_id) ON DELETE RESTRICT;


--
-- Name: customers customers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: e_invoices e_invoices_config_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.e_invoices
    ADD CONSTRAINT e_invoices_config_id_fkey FOREIGN KEY (config_id) REFERENCES public.einvoice_configs(config_id) ON DELETE RESTRICT;


--
-- Name: e_invoices e_invoices_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.e_invoices
    ADD CONSTRAINT e_invoices_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(invoice_id) ON DELETE RESTRICT;


--
-- Name: e_invoices e_invoices_original_e_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.e_invoices
    ADD CONSTRAINT e_invoices_original_e_invoice_id_fkey FOREIGN KEY (original_e_invoice_id) REFERENCES public.e_invoices(e_invoice_id) ON DELETE RESTRICT;


--
-- Name: inspection_items inspection_items_inspection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inspection_items
    ADD CONSTRAINT inspection_items_inspection_id_fkey FOREIGN KEY (inspection_id) REFERENCES public.inspections(inspection_id) ON DELETE RESTRICT;


--
-- Name: inspection_items inspection_items_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inspection_items
    ADD CONSTRAINT inspection_items_part_id_fkey FOREIGN KEY (part_id) REFERENCES public.parts(part_id) ON DELETE RESTRICT;


--
-- Name: inspection_items inspection_items_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inspection_items
    ADD CONSTRAINT inspection_items_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(service_id) ON DELETE RESTRICT;


--
-- Name: inspections inspections_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inspections
    ADD CONSTRAINT inspections_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: inspections inspections_mechanic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inspections
    ADD CONSTRAINT inspections_mechanic_id_fkey FOREIGN KEY (mechanic_id) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: inspections inspections_reception_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inspections
    ADD CONSTRAINT inspections_reception_id_fkey FOREIGN KEY (reception_id) REFERENCES public.vehicle_receptions(reception_id) ON DELETE RESTRICT;


--
-- Name: inventories inventories_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inventories
    ADD CONSTRAINT inventories_part_id_fkey FOREIGN KEY (part_id) REFERENCES public.parts(part_id) ON DELETE RESTRICT;


--
-- Name: inventories inventories_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inventories
    ADD CONSTRAINT inventories_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(warehouse_id) ON DELETE RESTRICT;


--
-- Name: inventory_receipt_items inventory_receipt_items_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inventory_receipt_items
    ADD CONSTRAINT inventory_receipt_items_part_id_fkey FOREIGN KEY (part_id) REFERENCES public.parts(part_id) ON DELETE RESTRICT;


--
-- Name: inventory_receipt_items inventory_receipt_items_receipt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inventory_receipt_items
    ADD CONSTRAINT inventory_receipt_items_receipt_id_fkey FOREIGN KEY (receipt_id) REFERENCES public.inventory_receipts(receipt_id) ON DELETE RESTRICT;


--
-- Name: inventory_receipts inventory_receipts_received_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inventory_receipts
    ADD CONSTRAINT inventory_receipts_received_by_fkey FOREIGN KEY (received_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: inventory_receipts inventory_receipts_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inventory_receipts
    ADD CONSTRAINT inventory_receipts_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(warehouse_id) ON DELETE RESTRICT;


--
-- Name: inventory_transactions inventory_transactions_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_inventory_id_fkey FOREIGN KEY (inventory_id) REFERENCES public.inventories(inventory_id) ON DELETE RESTRICT;


--
-- Name: inventory_transactions inventory_transactions_performed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_performed_by_fkey FOREIGN KEY (performed_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: invoice_lines invoice_lines_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.invoice_lines
    ADD CONSTRAINT invoice_lines_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(invoice_id) ON DELETE RESTRICT;


--
-- Name: invoice_lines invoice_lines_quotation_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.invoice_lines
    ADD CONSTRAINT invoice_lines_quotation_item_id_fkey FOREIGN KEY (quotation_item_id) REFERENCES public.quotation_items(item_id) ON DELETE RESTRICT;


--
-- Name: invoices invoices_billing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_billing_id_fkey FOREIGN KEY (billing_id) REFERENCES public.billing_information(billing_id) ON DELETE RESTRICT;


--
-- Name: invoices invoices_finalized_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_finalized_by_fkey FOREIGN KEY (finalized_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: invoices invoices_repair_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_repair_order_id_fkey FOREIGN KEY (repair_order_id) REFERENCES public.repair_orders(repair_order_id) ON DELETE RESTRICT;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: part_request_items part_request_items_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.part_request_items
    ADD CONSTRAINT part_request_items_part_id_fkey FOREIGN KEY (part_id) REFERENCES public.parts(part_id) ON DELETE RESTRICT;


--
-- Name: part_request_items part_request_items_quotation_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.part_request_items
    ADD CONSTRAINT part_request_items_quotation_item_id_fkey FOREIGN KEY (quotation_item_id) REFERENCES public.quotation_items(item_id) ON DELETE RESTRICT;


--
-- Name: part_request_items part_request_items_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.part_request_items
    ADD CONSTRAINT part_request_items_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.part_requests(request_id) ON DELETE RESTRICT;


--
-- Name: part_requests part_requests_processed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.part_requests
    ADD CONSTRAINT part_requests_processed_by_fkey FOREIGN KEY (processed_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: part_requests part_requests_repair_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.part_requests
    ADD CONSTRAINT part_requests_repair_order_id_fkey FOREIGN KEY (repair_order_id) REFERENCES public.repair_orders(repair_order_id) ON DELETE RESTRICT;


--
-- Name: part_requests part_requests_requested_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.part_requests
    ADD CONSTRAINT part_requests_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: part_requests part_requests_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.part_requests
    ADD CONSTRAINT part_requests_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.repair_tasks(task_id) ON DELETE RESTRICT;


--
-- Name: part_reservations part_reservations_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.part_reservations
    ADD CONSTRAINT part_reservations_inventory_id_fkey FOREIGN KEY (inventory_id) REFERENCES public.inventories(inventory_id) ON DELETE RESTRICT;


--
-- Name: part_reservations part_reservations_quotation_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.part_reservations
    ADD CONSTRAINT part_reservations_quotation_item_id_fkey FOREIGN KEY (quotation_item_id) REFERENCES public.quotation_items(item_id) ON DELETE RESTRICT;


--
-- Name: part_reservations part_reservations_repair_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.part_reservations
    ADD CONSTRAINT part_reservations_repair_order_id_fkey FOREIGN KEY (repair_order_id) REFERENCES public.repair_orders(repair_order_id) ON DELETE RESTRICT;


--
-- Name: part_reservations part_reservations_reserved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.part_reservations
    ADD CONSTRAINT part_reservations_reserved_by_fkey FOREIGN KEY (reserved_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: payments payments_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(invoice_id) ON DELETE RESTRICT;


--
-- Name: payments payments_received_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_received_by_fkey FOREIGN KEY (received_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: quotation_items quotation_items_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.quotation_items
    ADD CONSTRAINT quotation_items_part_id_fkey FOREIGN KEY (part_id) REFERENCES public.parts(part_id) ON DELETE RESTRICT;


--
-- Name: quotation_items quotation_items_quotation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.quotation_items
    ADD CONSTRAINT quotation_items_quotation_id_fkey FOREIGN KEY (quotation_id) REFERENCES public.quotations(quotation_id) ON DELETE RESTRICT;


--
-- Name: quotation_items quotation_items_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.quotation_items
    ADD CONSTRAINT quotation_items_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(service_id) ON DELETE RESTRICT;


--
-- Name: quotations quotations_inspection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_inspection_id_fkey FOREIGN KEY (inspection_id) REFERENCES public.inspections(inspection_id) ON DELETE RESTRICT;


--
-- Name: quotations quotations_parent_quotation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_parent_quotation_id_fkey FOREIGN KEY (parent_quotation_id) REFERENCES public.quotations(quotation_id) ON DELETE RESTRICT;


--
-- Name: quotations quotations_prepared_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_prepared_by_fkey FOREIGN KEY (prepared_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: repair_notes repair_notes_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_notes
    ADD CONSTRAINT repair_notes_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: repair_notes repair_notes_repair_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_notes
    ADD CONSTRAINT repair_notes_repair_order_id_fkey FOREIGN KEY (repair_order_id) REFERENCES public.repair_orders(repair_order_id) ON DELETE RESTRICT;


--
-- Name: repair_notes repair_notes_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_notes
    ADD CONSTRAINT repair_notes_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.repair_tasks(task_id) ON DELETE RESTRICT;


--
-- Name: repair_orders repair_orders_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_orders
    ADD CONSTRAINT repair_orders_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id) ON DELETE RESTRICT;


--
-- Name: repair_orders repair_orders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_orders
    ADD CONSTRAINT repair_orders_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: repair_orders repair_orders_quotation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_orders
    ADD CONSTRAINT repair_orders_quotation_id_fkey FOREIGN KEY (quotation_id) REFERENCES public.quotations(quotation_id) ON DELETE RESTRICT;


--
-- Name: repair_orders repair_orders_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_orders
    ADD CONSTRAINT repair_orders_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.repair_order_types(type_id) ON DELETE RESTRICT;


--
-- Name: repair_task_parts repair_task_parts_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_task_parts
    ADD CONSTRAINT repair_task_parts_inventory_id_fkey FOREIGN KEY (inventory_id) REFERENCES public.inventories(inventory_id) ON DELETE RESTRICT;


--
-- Name: repair_task_parts repair_task_parts_issued_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_task_parts
    ADD CONSTRAINT repair_task_parts_issued_by_fkey FOREIGN KEY (issued_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: repair_task_parts repair_task_parts_request_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_task_parts
    ADD CONSTRAINT repair_task_parts_request_item_id_fkey FOREIGN KEY (request_item_id) REFERENCES public.part_request_items(request_item_id) ON DELETE RESTRICT;


--
-- Name: repair_task_parts repair_task_parts_reservation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_task_parts
    ADD CONSTRAINT repair_task_parts_reservation_id_fkey FOREIGN KEY (reservation_id) REFERENCES public.part_reservations(reservation_id) ON DELETE RESTRICT;


--
-- Name: repair_task_parts repair_task_parts_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_task_parts
    ADD CONSTRAINT repair_task_parts_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.repair_tasks(task_id) ON DELETE RESTRICT;


--
-- Name: repair_tasks repair_tasks_mechanic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_tasks
    ADD CONSTRAINT repair_tasks_mechanic_id_fkey FOREIGN KEY (mechanic_id) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: repair_tasks repair_tasks_quotation_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_tasks
    ADD CONSTRAINT repair_tasks_quotation_item_id_fkey FOREIGN KEY (quotation_item_id) REFERENCES public.quotation_items(item_id) ON DELETE RESTRICT;


--
-- Name: repair_tasks repair_tasks_repair_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.repair_tasks
    ADD CONSTRAINT repair_tasks_repair_order_id_fkey FOREIGN KEY (repair_order_id) REFERENCES public.repair_orders(repair_order_id) ON DELETE RESTRICT;


--
-- Name: service_ratings service_ratings_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.service_ratings
    ADD CONSTRAINT service_ratings_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(appointment_id) ON DELETE RESTRICT;


--
-- Name: service_ratings service_ratings_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.service_ratings
    ADD CONSTRAINT service_ratings_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON DELETE RESTRICT;


--
-- Name: staff staff_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id) ON DELETE RESTRICT;


--
-- Name: staff staff_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: tax_rules tax_rules_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.tax_rules
    ADD CONSTRAINT tax_rules_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: time_slots time_slots_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.time_slots
    ADD CONSTRAINT time_slots_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id) ON DELETE RESTRICT;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(role_id) ON DELETE RESTRICT;


--
-- Name: vehicle_handovers vehicle_handovers_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.vehicle_handovers
    ADD CONSTRAINT vehicle_handovers_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(appointment_id) ON DELETE RESTRICT;


--
-- Name: vehicle_handovers vehicle_handovers_handed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.vehicle_handovers
    ADD CONSTRAINT vehicle_handovers_handed_by_fkey FOREIGN KEY (handed_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: vehicle_handovers vehicle_handovers_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.vehicle_handovers
    ADD CONSTRAINT vehicle_handovers_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(invoice_id) ON DELETE RESTRICT;


--
-- Name: vehicle_receptions vehicle_receptions_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.vehicle_receptions
    ADD CONSTRAINT vehicle_receptions_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(appointment_id) ON DELETE RESTRICT;


--
-- Name: vehicle_receptions vehicle_receptions_received_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.vehicle_receptions
    ADD CONSTRAINT vehicle_receptions_received_by_fkey FOREIGN KEY (received_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: vehicles vehicles_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON DELETE RESTRICT;


--
-- Name: warehouses warehouses_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id) ON DELETE RESTRICT;


--
-- Name: warranties warranties_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranties
    ADD CONSTRAINT warranties_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.warranty_policies(policy_id) ON DELETE RESTRICT;


--
-- Name: warranties warranties_quotation_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranties
    ADD CONSTRAINT warranties_quotation_item_id_fkey FOREIGN KEY (quotation_item_id) REFERENCES public.quotation_items(item_id) ON DELETE RESTRICT;


--
-- Name: warranties warranties_repair_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranties
    ADD CONSTRAINT warranties_repair_order_id_fkey FOREIGN KEY (repair_order_id) REFERENCES public.repair_orders(repair_order_id) ON DELETE RESTRICT;


--
-- Name: warranties warranties_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranties
    ADD CONSTRAINT warranties_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id) ON DELETE RESTRICT;


--
-- Name: warranty_policies warranty_policies_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranty_policies
    ADD CONSTRAINT warranty_policies_part_id_fkey FOREIGN KEY (part_id) REFERENCES public.parts(part_id) ON DELETE RESTRICT;


--
-- Name: warranty_policies warranty_policies_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranty_policies
    ADD CONSTRAINT warranty_policies_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(service_id) ON DELETE RESTRICT;


--
-- Name: warranty_repairs warranty_repairs_repair_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranty_repairs
    ADD CONSTRAINT warranty_repairs_repair_order_id_fkey FOREIGN KEY (repair_order_id) REFERENCES public.repair_orders(repair_order_id) ON DELETE RESTRICT;


--
-- Name: warranty_repairs warranty_repairs_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranty_repairs
    ADD CONSTRAINT warranty_repairs_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.warranty_requests(request_id) ON DELETE RESTRICT;


--
-- Name: warranty_requests warranty_requests_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranty_requests
    ADD CONSTRAINT warranty_requests_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: warranty_requests warranty_requests_assessed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranty_requests
    ADD CONSTRAINT warranty_requests_assessed_by_fkey FOREIGN KEY (assessed_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: warranty_requests warranty_requests_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranty_requests
    ADD CONSTRAINT warranty_requests_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id) ON DELETE RESTRICT;


--
-- Name: warranty_requests warranty_requests_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranty_requests
    ADD CONSTRAINT warranty_requests_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON DELETE RESTRICT;


--
-- Name: warranty_requests warranty_requests_warranty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: autocare
--

ALTER TABLE ONLY public.warranty_requests
    ADD CONSTRAINT warranty_requests_warranty_id_fkey FOREIGN KEY (warranty_id) REFERENCES public.warranties(warranty_id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict q4eJKuXfk4Uf0yV5v5avHJ0SileyhEC6XW4ht1d12TABugYV6S2jDwmrfMHZxDF
