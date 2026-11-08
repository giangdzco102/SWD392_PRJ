--
-- PostgreSQL database dump
--

\restrict jnpyC95pGam6o65WsJ1ChXTvhIW5kQ3EbPBysn9axmMDZ1CuTqEadZzM9ZUY8Aw

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


--
-- Name: fn_block_modify(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_block_modify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN RAISE EXCEPTION 'inventory_transactions is append-only'; END; $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: appointment_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.appointment_services (
    appointment_id bigint NOT NULL,
    service_id bigint NOT NULL,
    estimated_price numeric(14,2) NOT NULL
);


--
-- Name: appointments; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: appointments_appointment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: audit_logs_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: billing_information; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: billing_information_billing_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: branch_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.branch_services (
    branch_id bigint NOT NULL,
    service_id bigint NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    branch_price numeric(14,2),
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: branches; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: branches_branch_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: customers; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: e_invoices; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: e_invoices_e_invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: einvoice_configs; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: einvoice_configs_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: inspection_items; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: inspection_items_inspection_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: inspections; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: inspections_inspection_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: inventories; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: inventories_inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: inventory_receipt_items; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: inventory_receipt_items_receipt_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: inventory_receipts; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: inventory_receipts_receipt_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: inventory_transactions; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: inventory_transactions_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: invoice_lines; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: invoice_lines_line_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: invoices; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: invoices_invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: notifications_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: part_request_items; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: part_request_items_request_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: part_requests; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: part_requests_request_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: part_reservations; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: part_reservations_reservation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: parts; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: parts_part_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: payments; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: payments_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: quotation_items; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: quotation_items_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: quotations; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: quotations_quotation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: repair_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repair_notes (
    note_id bigint NOT NULL,
    repair_order_id bigint NOT NULL,
    task_id bigint,
    author_id bigint NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: repair_notes_note_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: repair_order_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repair_order_types (
    type_id smallint NOT NULL,
    type_code character varying(20) NOT NULL,
    type_name character varying(100) NOT NULL,
    sla_hours smallint,
    description character varying(255)
);


--
-- Name: repair_order_types_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: repair_orders; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: repair_orders_repair_order_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: repair_task_parts; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: repair_task_parts_task_part_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: repair_tasks; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: repair_tasks_task_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    role_id smallint NOT NULL,
    role_code character varying(30) NOT NULL,
    role_name character varying(100) NOT NULL,
    description character varying(255)
);


--
-- Name: roles_role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: service_ratings; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: service_ratings_rating_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: services; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: services_service_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: staff; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: staff_staff_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: tax_rules; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: tax_rules_tax_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: time_slots; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: time_slots_slot_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: users; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: vehicle_handovers; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: vehicle_handovers_handover_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: vehicle_receptions; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: vehicle_receptions_reception_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: vehicles; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: vehicles_vehicle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: warehouses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.warehouses (
    warehouse_id bigint NOT NULL,
    branch_id bigint NOT NULL,
    warehouse_name character varying(100) NOT NULL,
    location character varying(255),
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL
);


--
-- Name: warehouses_warehouse_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: warranties; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: warranties_warranty_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: warranty_policies; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: warranty_policies_policy_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: warranty_repairs; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: warranty_repairs_warranty_repair_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: warranty_requests; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: warranty_requests_request_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Data for Name: appointment_services; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.appointment_services (appointment_id, service_id, estimated_price) FROM stdin;
1	3	900000.00
1	2	250000.00
2	4	600000.00
2	6	150000.00
2	5	300000.00
3	1	350000.00
3	5	300000.00
4	2	250000.00
5	7	400000.00
5	1	350000.00
6	3	900000.00
6	8	350000.00
7	2	250000.00
7	5	300000.00
8	4	600000.00
8	6	150000.00
9	1	350000.00
9	10	150000.00
10	3	900000.00
11	9	200000.00
12	1	350000.00
12	7	400000.00
13	9	200000.00
14	10	150000.00
15	7	400000.00
16	1	350000.00
17	1	350000.00
18	3	900000.00
19	1	350000.00
20	2	250000.00
21	5	300000.00
22	4	600000.00
23	9	200000.00
24	3	900000.00
25	10	150000.00
26	3	900000.00
27	2	250000.00
27	5	300000.00
28	9	200000.00
29	7	400000.00
30	4	600000.00
31	8	350000.00
31	1	350000.00
32	2	250000.00
32	8	350000.00
32	6	150000.00
33	1	350000.00
33	5	300000.00
34	3	900000.00
35	2	250000.00
36	4	600000.00
37	2	250000.00
\.


--
-- Data for Name: appointments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.appointments (appointment_id, appointment_code, customer_id, vehicle_id, branch_id, slot_id, status, customer_note, reject_reason, cancel_reason, confirmed_by, created_at, updated_at) FROM stdin;
1	APT-261012-0001	1	1	1	298	COMPLETED	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-10-09 08:00:00+07	2026-10-12 08:00:00+07
2	APT-261020-0001	2	2	1	517	COMPLETED	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-10-17 09:00:00+07	2026-10-20 09:00:00+07
3	APT-261105-0001	3	4	1	946	WAITING_PAYMENT	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-02 08:00:00+07	2026-11-05 08:00:00+07
4	APT-261106-0001	4	5	1	979	IN_SERVICE	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-03 10:00:00+07	2026-11-06 10:00:00+07
5	APT-261107-0001	5	6	1	1000	IN_SERVICE	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-04 08:00:00+07	2026-11-07 08:00:00+07
6	APT-261107-0002	6	7	1	1003	IN_SERVICE	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-04 09:00:00+07	2026-11-07 09:00:00+07
7	APT-261107-0003	8	10	1	1015	IN_SERVICE	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-04 13:00:00+07	2026-11-07 13:00:00+07
8	APT-261108-0001	9	11	1	1027	IN_SERVICE	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-05 08:00:00+07	2026-11-08 08:00:00+07
9	APT-261108-0002	11	14	1	1030	IN_SERVICE	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-05 09:00:00+07	2026-11-08 09:00:00+07
10	APT-261108-0003	12	15	1	1033	IN_SERVICE	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-05 10:00:00+07	2026-11-08 10:00:00+07
11	APT-261108-0004	1	3	1	1033	IN_SERVICE	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-05 10:00:00+07	2026-11-08 10:00:00+07
12	APT-261108-0005	10	12	1	1036	CHECKED_IN	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-05 11:00:00+07	2026-11-08 11:00:00+07
13	APT-261108-0006	12	16	1	1042	CHECKED_IN	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-05 13:00:00+07	2026-11-08 13:00:00+07
14	APT-261110-0001	1	1	1	1081	CONFIRMED	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-07 08:00:00+07	2026-11-10 08:00:00+07
15	APT-261111-0001	2	2	1	1111	PENDING	Đèn check engine sáng	\N	\N	\N	2026-11-08 09:00:00+07	2026-11-11 09:00:00+07
16	APT-261112-0001	3	18	1	1153	PENDING	Xe cần kiểm tra theo lịch hẹn	\N	\N	\N	2026-11-09 14:00:00+07	2026-11-12 14:00:00+07
17	APT-261103-0001	3	4	1	895	CANCELLED	Xe cần kiểm tra theo lịch hẹn	\N	Khách bận đột xuất	\N	2026-10-31 09:00:00+07	2026-11-03 09:00:00+07
18	APT-261104-0001	6	8	1	940	REJECTED	Xe cần kiểm tra theo lịch hẹn	Xưởng quá tải trong khung giờ này	\N	\N	2026-11-01 15:00:00+07	2026-11-04 15:00:00+07
19	APT-261015-0001	7	9	2	383	COMPLETED	Xe cần kiểm tra theo lịch hẹn	\N	\N	10	2026-10-12 09:00:00+07	2026-10-15 09:00:00+07
20	APT-261107-0004	8	17	2	1007	IN_SERVICE	Xe cần kiểm tra theo lịch hẹn	\N	\N	10	2026-11-04 10:00:00+07	2026-11-07 10:00:00+07
21	APT-261108-0007	7	9	2	1046	IN_SERVICE	Xe cần kiểm tra theo lịch hẹn	\N	\N	10	2026-11-05 14:00:00+07	2026-11-08 14:00:00+07
22	APT-261112-0002	7	9	2	1142	PENDING	Xe cần kiểm tra theo lịch hẹn	\N	\N	\N	2026-11-09 10:00:00+07	2026-11-12 10:00:00+07
23	APT-261025-0001	10	13	3	651	COMPLETED	Xe cần kiểm tra theo lịch hẹn	\N	\N	17	2026-10-22 08:00:00+07	2026-10-25 08:00:00+07
24	APT-261108-0008	10	12	3	1032	IN_SERVICE	Xe cần kiểm tra theo lịch hẹn	\N	\N	17	2026-11-05 09:00:00+07	2026-11-08 09:00:00+07
25	APT-261113-0001	10	12	3	1167	CONFIRMED	Xe cần kiểm tra theo lịch hẹn	\N	\N	17	2026-11-10 09:00:00+07	2026-11-13 09:00:00+07
26	APT-261109-0001	2	19	1	1057	CONFIRMED	Xe đến hạn bảo dưỡng 50.000 km	\N	\N	3	2026-11-06 09:00:00+07	2026-11-09 09:00:00+07
27	APT-261109-0002	5	20	1	1060	CONFIRMED	Phanh hơi kêu, lốp mòn không đều	\N	\N	3	2026-11-06 10:00:00+07	2026-11-09 10:00:00+07
28	APT-261109-0003	11	22	1	1072	PENDING	Xe cần kiểm tra theo lịch hẹn	\N	\N	\N	2026-11-06 14:00:00+07	2026-11-09 14:00:00+07
29	APT-261109-0004	6	8	1	1054	CHECKED_IN	Đèn check engine sáng, máy rung khi chạy không tải	\N	\N	\N	2026-11-06 08:00:00+07	2026-11-09 08:00:00+07
30	APT-261109-0005	4	23	1	1057	CHECKED_IN	Điều hòa không mát	\N	\N	3	2026-11-06 09:00:00+07	2026-11-09 09:00:00+07
31	APT-261108-0009	9	21	1	1048	CHECKED_IN	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-05 15:00:00+07	2026-11-08 15:00:00+07
32	APT-261108-0010	2	2	1	1051	CHECKED_IN	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-05 16:00:00+07	2026-11-08 16:00:00+07
33	APT-261108-0011	6	24	1	1027	WAITING_PAYMENT	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-05 08:00:00+07	2026-11-08 08:00:00+07
34	APT-261108-0012	12	25	1	1036	WAITING_PAYMENT	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-05 11:00:00+07	2026-11-08 11:00:00+07
35	APT-261107-0005	3	26	1	1018	WAITING_PAYMENT	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-04 14:00:00+07	2026-11-07 14:00:00+07
36	APT-261106-0002	8	27	1	994	WAITING_PAYMENT	Xe cần kiểm tra theo lịch hẹn	\N	\N	3	2026-11-03 15:00:00+07	2026-11-06 15:00:00+07
37	APT-261107-0006	11	28	1	1006	WAITING_PAYMENT	Bảo hành má phanh – không thu phí	\N	\N	3	2026-11-04 10:00:00+07	2026-11-07 10:00:00+07
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (audit_id, user_id, action, entity_name, entity_id, old_value, new_value, ip_address, created_at) FROM stdin;
1	23	QUOTATION_APPROVED	quotations	1	\N	\N	127.0.0.1	2026-10-12 10:00:00+07
2	3	MECHANIC_ASSIGNED	repair_orders	1	\N	\N	127.0.0.1	2026-10-12 10:35:00+07
3	5	CHARGES_FINALIZED	invoices	1	\N	\N	127.0.0.1	2026-10-12 15:00:00+07
4	5	PAYMENT_RECORDED	payments	1	\N	\N	127.0.0.1	2026-10-12 15:10:00+07
5	24	QUOTATION_APPROVED	quotations	2	\N	\N	127.0.0.1	2026-10-20 11:00:00+07
6	3	MECHANIC_ASSIGNED	repair_orders	2	\N	\N	127.0.0.1	2026-10-20 11:35:00+07
7	5	CHARGES_FINALIZED	invoices	2	\N	\N	127.0.0.1	2026-10-20 16:00:00+07
8	5	PAYMENT_RECORDED	payments	2	\N	\N	127.0.0.1	2026-10-20 16:10:00+07
9	25	QUOTATION_APPROVED	quotations	3	\N	\N	127.0.0.1	2026-11-05 10:00:00+07
10	3	MECHANIC_ASSIGNED	repair_orders	3	\N	\N	127.0.0.1	2026-11-05 10:35:00+07
11	3	REPAIR_VERIFIED	repair_orders	3	\N	\N	127.0.0.1	2026-11-05 14:40:00+07
12	26	QUOTATION_APPROVED	quotations	4	\N	\N	127.0.0.1	2026-11-06 12:00:00+07
13	3	MECHANIC_ASSIGNED	repair_orders	4	\N	\N	127.0.0.1	2026-11-06 12:35:00+07
14	27	QUOTATION_APPROVED	quotations	5	\N	\N	127.0.0.1	2026-11-07 10:00:00+07
15	3	MECHANIC_ASSIGNED	repair_orders	5	\N	\N	127.0.0.1	2026-11-07 10:35:00+07
16	28	QUOTATION_APPROVED	quotations	6	\N	\N	127.0.0.1	2026-11-07 11:00:00+07
17	3	MECHANIC_ASSIGNED	repair_orders	6	\N	\N	127.0.0.1	2026-11-07 11:35:00+07
18	30	QUOTATION_APPROVED	quotations	7	\N	\N	127.0.0.1	2026-11-07 15:00:00+07
19	3	MECHANIC_ASSIGNED	repair_orders	7	\N	\N	127.0.0.1	2026-11-07 15:35:00+07
20	31	QUOTATION_APPROVED	quotations	8	\N	\N	127.0.0.1	2026-11-08 10:00:00+07
21	3	MECHANIC_ASSIGNED	repair_orders	8	\N	\N	127.0.0.1	2026-11-08 10:35:00+07
22	33	QUOTATION_APPROVED	quotations	9	\N	\N	127.0.0.1	2026-11-08 11:00:00+07
23	3	MECHANIC_ASSIGNED	repair_orders	9	\N	\N	127.0.0.1	2026-11-08 11:35:00+07
24	34	QUOTATION_APPROVED	quotations	10	\N	\N	127.0.0.1	2026-11-08 12:00:00+07
25	23	QUOTATION_APPROVED	quotations	11	\N	\N	127.0.0.1	2026-11-08 12:00:00+07
26	29	QUOTATION_APPROVED	quotations	13	\N	\N	127.0.0.1	2026-10-15 11:00:00+07
27	10	MECHANIC_ASSIGNED	repair_orders	12	\N	\N	127.0.0.1	2026-10-15 11:35:00+07
28	12	CHARGES_FINALIZED	invoices	3	\N	\N	127.0.0.1	2026-10-15 16:00:00+07
29	12	PAYMENT_RECORDED	payments	3	\N	\N	127.0.0.1	2026-10-15 16:10:00+07
30	30	QUOTATION_APPROVED	quotations	14	\N	\N	127.0.0.1	2026-11-07 12:00:00+07
31	10	MECHANIC_ASSIGNED	repair_orders	13	\N	\N	127.0.0.1	2026-11-07 12:35:00+07
32	29	QUOTATION_APPROVED	quotations	15	\N	\N	127.0.0.1	2026-11-08 16:00:00+07
33	32	QUOTATION_APPROVED	quotations	16	\N	\N	127.0.0.1	2026-10-25 10:00:00+07
34	17	MECHANIC_ASSIGNED	repair_orders	15	\N	\N	127.0.0.1	2026-10-25 10:35:00+07
35	19	CHARGES_FINALIZED	invoices	4	\N	\N	127.0.0.1	2026-10-25 15:00:00+07
36	19	PAYMENT_RECORDED	payments	4	\N	\N	127.0.0.1	2026-10-25 15:10:00+07
37	32	QUOTATION_APPROVED	quotations	17	\N	\N	127.0.0.1	2026-11-08 11:00:00+07
38	17	MECHANIC_ASSIGNED	repair_orders	16	\N	\N	127.0.0.1	2026-11-08 11:35:00+07
39	24	QUOTATION_APPROVED	quotations	18	\N	\N	127.0.0.1	2026-11-08 18:00:00+07
40	28	QUOTATION_APPROVED	quotations	19	\N	\N	127.0.0.1	2026-11-08 10:00:00+07
41	3	MECHANIC_ASSIGNED	repair_orders	17	\N	\N	127.0.0.1	2026-11-08 10:35:00+07
42	3	REPAIR_VERIFIED	repair_orders	17	\N	\N	127.0.0.1	2026-11-08 14:40:00+07
43	5	CHARGES_FINALIZED	invoices	5	\N	\N	127.0.0.1	2026-11-08 15:00:00+07
44	34	QUOTATION_APPROVED	quotations	20	\N	\N	127.0.0.1	2026-11-08 13:00:00+07
45	3	MECHANIC_ASSIGNED	repair_orders	18	\N	\N	127.0.0.1	2026-11-08 13:35:00+07
46	3	REPAIR_VERIFIED	repair_orders	18	\N	\N	127.0.0.1	2026-11-08 17:40:00+07
47	5	CHARGES_FINALIZED	invoices	6	\N	\N	127.0.0.1	2026-11-08 18:00:00+07
48	25	QUOTATION_APPROVED	quotations	21	\N	\N	127.0.0.1	2026-11-07 16:00:00+07
49	3	MECHANIC_ASSIGNED	repair_orders	19	\N	\N	127.0.0.1	2026-11-07 16:35:00+07
50	3	REPAIR_VERIFIED	repair_orders	19	\N	\N	127.0.0.1	2026-11-07 20:40:00+07
51	5	CHARGES_FINALIZED	invoices	7	\N	\N	127.0.0.1	2026-11-07 21:00:00+07
52	5	PAYMENT_RECORDED	payments	5	\N	\N	127.0.0.1	2026-11-07 21:10:00+07
53	30	QUOTATION_APPROVED	quotations	22	\N	\N	127.0.0.1	2026-11-06 17:00:00+07
54	3	MECHANIC_ASSIGNED	repair_orders	20	\N	\N	127.0.0.1	2026-11-06 17:35:00+07
55	3	REPAIR_VERIFIED	repair_orders	20	\N	\N	127.0.0.1	2026-11-06 21:40:00+07
56	5	CHARGES_FINALIZED	invoices	8	\N	\N	127.0.0.1	2026-11-06 22:00:00+07
57	5	PAYMENT_RECORDED	payments	6	\N	\N	127.0.0.1	2026-11-06 22:10:00+07
58	33	QUOTATION_APPROVED	quotations	23	\N	\N	127.0.0.1	2026-11-07 12:00:00+07
59	3	MECHANIC_ASSIGNED	repair_orders	21	\N	\N	127.0.0.1	2026-11-07 12:35:00+07
60	3	REPAIR_VERIFIED	repair_orders	21	\N	\N	127.0.0.1	2026-11-07 16:40:00+07
61	5	CHARGES_FINALIZED	invoices	9	\N	\N	127.0.0.1	2026-11-07 17:00:00+07
\.


--
-- Data for Name: billing_information; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.billing_information (billing_id, customer_id, buyer_type, buyer_name, company_name, tax_code, billing_address, invoice_email, is_default, created_at, updated_at) FROM stdin;
1	1	INDIVIDUAL	Nguyễn Văn An	\N	\N	12 Láng Hạ, Đống Đa, Hà Nội	customer1@gmail.com	t	2026-02-02 08:00:00+07	2026-02-02 08:00:00+07
2	2	COMPANY	Trần Thị Bình	Công ty TNHH Bình An	0101234567	56 Kim Mã, Ba Đình, Hà Nội	customer2@gmail.com	t	2026-02-02 08:00:00+07	2026-02-02 08:00:00+07
3	3	INDIVIDUAL	Lê Hoàng Cường	\N	\N	8 Xuân Thủy, Cầu Giấy, Hà Nội	customer3@gmail.com	t	2026-02-02 08:00:00+07	2026-02-02 08:00:00+07
4	6	COMPANY	Vũ Thị Giang	Công ty CP Vận tải Giang Sơn	0109876543	77 Lê Văn Lương, Thanh Xuân, Hà Nội	customer6@gmail.com	t	2026-02-02 08:00:00+07	2026-02-02 08:00:00+07
5	7	INDIVIDUAL	Đặng Quốc Huy	\N	\N	15 Quang Trung, Hà Đông, Hà Nội	customer7@gmail.com	t	2026-02-02 08:00:00+07	2026-02-02 08:00:00+07
6	10	INDIVIDUAL	Đỗ Thị Lan	\N	\N	200 Nguyễn Văn Linh, Quận 7, TP.HCM	customer10@gmail.com	t	2026-02-02 08:00:00+07	2026-02-02 08:00:00+07
\.


--
-- Data for Name: branch_services; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.branch_services (branch_id, service_id, is_enabled, branch_price, updated_at) FROM stdin;
1	1	t	\N	2026-01-05 08:00:00+07
1	2	t	\N	2026-01-05 08:00:00+07
1	3	t	\N	2026-01-05 08:00:00+07
1	4	t	\N	2026-01-05 08:00:00+07
1	5	t	\N	2026-01-05 08:00:00+07
1	6	t	\N	2026-01-05 08:00:00+07
1	7	t	\N	2026-01-05 08:00:00+07
1	8	t	\N	2026-01-05 08:00:00+07
1	9	t	\N	2026-01-05 08:00:00+07
1	10	t	\N	2026-01-05 08:00:00+07
2	1	t	\N	2026-01-05 08:00:00+07
2	2	t	\N	2026-01-05 08:00:00+07
2	3	t	\N	2026-01-05 08:00:00+07
2	4	t	\N	2026-01-05 08:00:00+07
2	5	t	\N	2026-01-05 08:00:00+07
2	6	t	\N	2026-01-05 08:00:00+07
2	7	t	\N	2026-01-05 08:00:00+07
2	8	t	\N	2026-01-05 08:00:00+07
2	9	t	\N	2026-01-05 08:00:00+07
2	10	t	\N	2026-01-05 08:00:00+07
3	1	t	\N	2026-01-05 08:00:00+07
3	2	t	\N	2026-01-05 08:00:00+07
3	3	t	\N	2026-01-05 08:00:00+07
3	4	t	\N	2026-01-05 08:00:00+07
3	5	t	\N	2026-01-05 08:00:00+07
3	6	t	\N	2026-01-05 08:00:00+07
3	7	t	\N	2026-01-05 08:00:00+07
3	8	t	\N	2026-01-05 08:00:00+07
3	9	t	\N	2026-01-05 08:00:00+07
3	10	t	\N	2026-01-05 08:00:00+07
\.


--
-- Data for Name: branches; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.branches (branch_id, branch_code, branch_name, address, phone, email, status, created_at, updated_at) FROM stdin;
1	HN-CG01	AutoCare Cầu Giấy	123 Trần Duy Hưng, Cầu Giấy, Hà Nội	024 3999 1111	caugiay@autocare.vn	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
2	HN-HD01	AutoCare Hà Đông	45 Quang Trung, Hà Đông, Hà Nội	024 3999 2222	hadong@autocare.vn	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
3	HCM-Q701	AutoCare Quận 7	88 Nguyễn Thị Thập, Quận 7, TP.HCM	028 3999 3333	quan7@autocare.vn	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customers (customer_id, user_id, date_of_birth, gender, address, created_at) FROM stdin;
1	23	1986-02-11	MALE	12 Láng Hạ, Đống Đa, Hà Nội	2026-02-01 08:00:00+07
2	24	1987-03-12	FEMALE	56 Kim Mã, Ba Đình, Hà Nội	2026-02-01 08:00:00+07
3	25	1988-04-13	MALE	8 Xuân Thủy, Cầu Giấy, Hà Nội	2026-02-01 08:00:00+07
4	26	1989-05-14	FEMALE	102 Nguyễn Trãi, Thanh Xuân, Hà Nội	2026-02-01 08:00:00+07
5	27	1990-06-15	MALE	21 Hoàng Quốc Việt, Cầu Giấy, Hà Nội	2026-02-01 08:00:00+07
6	28	1991-07-16	FEMALE	77 Lê Văn Lương, Thanh Xuân, Hà Nội	2026-02-01 08:00:00+07
7	29	1992-08-17	MALE	15 Quang Trung, Hà Đông, Hà Nội	2026-02-01 08:00:00+07
8	30	1993-09-18	FEMALE	40 Trần Phú, Hà Đông, Hà Nội	2026-02-01 08:00:00+07
9	31	1994-01-10	MALE	9 Duy Tân, Cầu Giấy, Hà Nội	2026-02-01 08:00:00+07
10	32	1995-02-11	FEMALE	200 Nguyễn Văn Linh, Quận 7, TP.HCM	2026-02-01 08:00:00+07
11	33	1996-03-12	MALE	31 Phạm Hùng, Nam Từ Liêm, Hà Nội	2026-02-01 08:00:00+07
12	34	1985-04-13	FEMALE	66 Mễ Trì, Nam Từ Liêm, Hà Nội	2026-02-01 08:00:00+07
\.


--
-- Data for Name: e_invoices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.e_invoices (e_invoice_id, invoice_id, config_id, original_e_invoice_id, buyer_name, buyer_tax_code, buyer_address, buyer_email, external_invoice_no, invoice_series, lookup_code, external_status, attempt_count, status, correction_type, correction_reason, response_payload, issued_at, created_at) FROM stdin;
1	1	1	\N	Nguyễn Văn An	\N	12 Láng Hạ, Đống Đa, Hà Nội	customer1@gmail.com	00000001	C26TAC	MISA-000001A	ISSUED	1	ISSUED	\N	\N	{"success": true}	2026-10-12 15:15:00+07	2026-10-12 15:15:00+07
2	2	1	\N	Công ty TNHH Bình An	0101234567	56 Kim Mã, Ba Đình, Hà Nội	customer2@gmail.com	00000002	C26TAC	MISA-000002A	REPLACED	1	REPLACED	\N	\N	{"success": true}	2026-10-20 16:15:00+07	2026-10-20 16:15:00+07
3	2	1	2	Công ty TNHH Bình An	0101234567	56 Kim Mã, Ba Đình, Hà Nội	customer2@gmail.com	00000502	C26TAC	MISA-000002B	ISSUED	1	ISSUED	REPLACEMENT	Sai tên đơn vị mua hàng	{"success": true}	2026-10-21 16:10:00+07	2026-10-21 16:10:00+07
4	3	1	\N	Đặng Quốc Huy	\N	15 Quang Trung, Hà Đông, Hà Nội	customer7@gmail.com	00000003	C26TAC	MISA-000003A	ISSUED	1	ISSUED	\N	\N	{"success": true}	2026-10-15 16:15:00+07	2026-10-15 16:15:00+07
5	4	1	\N	Đỗ Thị Lan	\N	200 Nguyễn Văn Linh, Quận 7, TP.HCM	customer10@gmail.com	00000004	C26TAC	MISA-000004A	ISSUED	1	ISSUED	\N	\N	{"success": true}	2026-10-25 15:15:00+07	2026-10-25 15:15:00+07
6	8	1	\N	Công ty TNHH Thương mại Hưng Phát	9990001234	25 Tô Hiệu, Hà Đông, Hà Nội	customer8@gmail.com	\N	C26TAC	\N	REJECTED	1	FAILED	\N	\N	{"message": "Mã số thuế người mua không tồn tại", "success": false, "errorCode": "InvalidTaxCode"}	\N	2026-11-06 22:15:00+07
\.


--
-- Data for Name: einvoice_configs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.einvoice_configs (config_id, provider, seller_name, seller_tax_code, seller_address, api_base_url, invoice_template, invoice_series, credential_ref, is_active, updated_at) FROM stdin;
1	MISA_MEINVOICE	Công ty CP Dịch vụ Ô tô AutoCare	0108888888	123 Trần Duy Hưng, Cầu Giấy, Hà Nội	https://testapi.meinvoice.vn/api/integration	1	C26TAC	secret://autocare/misa-meinvoice	t	2026-01-05 08:00:00+07
\.


--
-- Data for Name: inspection_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inspection_items (inspection_item_id, inspection_id, item_type, service_id, part_id, description, quantity, priority, note, created_at) FROM stdin;
1	1	SERVICE	3	\N	Bảo dưỡng định kỳ 10.000 km	1.00	HIGH	\N	2026-10-12 08:50:00+07
2	1	SERVICE	2	\N	Kiểm tra & thay má phanh	1.00	MEDIUM	\N	2026-10-12 08:50:00+07
3	1	PART	\N	1	Cần thay dầu động cơ 5w-30 (1l)	4.00	MEDIUM	\N	2026-10-12 08:50:00+07
4	1	PART	\N	2	Cần thay lọc dầu động cơ	1.00	MEDIUM	\N	2026-10-12 08:50:00+07
5	1	PART	\N	5	Cần thay má phanh trước (bộ)	1.00	MEDIUM	\N	2026-10-12 08:50:00+07
6	2	SERVICE	4	\N	Vệ sinh & nạp gas điều hòa	1.00	HIGH	\N	2026-10-20 09:50:00+07
7	2	SERVICE	6	\N	Kiểm tra & thay ắc quy	1.00	MEDIUM	\N	2026-10-20 09:50:00+07
8	2	SERVICE	5	\N	Đảo lốp & cân bằng động	1.00	MEDIUM	\N	2026-10-20 09:50:00+07
9	2	PART	\N	4	Cần thay lọc gió điều hòa	1.00	MEDIUM	\N	2026-10-20 09:50:00+07
10	2	PART	\N	8	Cần thay ắc quy 12v 45ah	1.00	MEDIUM	\N	2026-10-20 09:50:00+07
11	2	PART	\N	9	Cần thay gas điều hòa r134a (bình)	1.00	MEDIUM	\N	2026-10-20 09:50:00+07
12	3	SERVICE	1	\N	Thay dầu động cơ	1.00	HIGH	\N	2026-11-05 08:50:00+07
13	3	SERVICE	5	\N	Đảo lốp & cân bằng động	1.00	MEDIUM	\N	2026-11-05 08:50:00+07
14	3	PART	\N	1	Cần thay dầu động cơ 5w-30 (1l)	4.00	MEDIUM	\N	2026-11-05 08:50:00+07
15	3	PART	\N	2	Cần thay lọc dầu động cơ	1.00	MEDIUM	\N	2026-11-05 08:50:00+07
16	4	SERVICE	2	\N	Kiểm tra & thay má phanh	1.00	HIGH	\N	2026-11-06 10:50:00+07
17	4	PART	\N	5	Cần thay má phanh trước (bộ)	1.00	MEDIUM	\N	2026-11-06 10:50:00+07
18	4	PART	\N	7	Cần thay dầu phanh dot4 (0.5l)	1.00	MEDIUM	\N	2026-11-06 10:50:00+07
19	5	SERVICE	7	\N	Chẩn đoán động cơ	1.00	HIGH	\N	2026-11-07 08:50:00+07
20	5	SERVICE	1	\N	Thay dầu động cơ	1.00	MEDIUM	\N	2026-11-07 08:50:00+07
21	5	PART	\N	10	Cần thay bugi iridium	4.00	MEDIUM	\N	2026-11-07 08:50:00+07
22	5	PART	\N	1	Cần thay dầu động cơ 5w-30 (1l)	4.00	MEDIUM	\N	2026-11-07 08:50:00+07
23	5	PART	\N	2	Cần thay lọc dầu động cơ	1.00	MEDIUM	\N	2026-11-07 08:50:00+07
24	6	SERVICE	3	\N	Bảo dưỡng định kỳ 10.000 km	1.00	HIGH	\N	2026-11-07 09:50:00+07
25	6	SERVICE	8	\N	Kiểm tra hệ thống treo	1.00	MEDIUM	\N	2026-11-07 09:50:00+07
26	6	PART	\N	1	Cần thay dầu động cơ 5w-30 (1l)	6.00	MEDIUM	\N	2026-11-07 09:50:00+07
27	6	PART	\N	2	Cần thay lọc dầu động cơ	1.00	MEDIUM	\N	2026-11-07 09:50:00+07
28	6	PART	\N	3	Cần thay lọc gió động cơ	1.00	MEDIUM	\N	2026-11-07 09:50:00+07
29	6	PART	\N	11	Cần thay giảm xóc trước	2.00	MEDIUM	\N	2026-11-07 09:50:00+07
30	7	SERVICE	2	\N	Kiểm tra & thay má phanh	1.00	HIGH	\N	2026-11-07 13:50:00+07
31	7	SERVICE	5	\N	Đảo lốp & cân bằng động	1.00	MEDIUM	\N	2026-11-07 13:50:00+07
32	7	PART	\N	6	Cần thay đĩa phanh trước	2.00	MEDIUM	\N	2026-11-07 13:50:00+07
33	7	PART	\N	5	Cần thay má phanh trước (bộ)	1.00	MEDIUM	\N	2026-11-07 13:50:00+07
34	8	SERVICE	4	\N	Vệ sinh & nạp gas điều hòa	1.00	HIGH	\N	2026-11-08 08:50:00+07
35	8	SERVICE	6	\N	Kiểm tra & thay ắc quy	1.00	MEDIUM	\N	2026-11-08 08:50:00+07
36	8	PART	\N	4	Cần thay lọc gió điều hòa	1.00	MEDIUM	\N	2026-11-08 08:50:00+07
37	8	PART	\N	9	Cần thay gas điều hòa r134a (bình)	1.00	MEDIUM	\N	2026-11-08 08:50:00+07
38	8	PART	\N	8	Cần thay ắc quy 12v 45ah	1.00	MEDIUM	\N	2026-11-08 08:50:00+07
39	9	SERVICE	1	\N	Thay dầu động cơ	1.00	HIGH	\N	2026-11-08 09:50:00+07
40	9	SERVICE	10	\N	Rửa xe & vệ sinh nội thất	1.00	MEDIUM	\N	2026-11-08 09:50:00+07
41	9	PART	\N	1	Cần thay dầu động cơ 5w-30 (1l)	5.00	MEDIUM	\N	2026-11-08 09:50:00+07
42	9	PART	\N	2	Cần thay lọc dầu động cơ	1.00	MEDIUM	\N	2026-11-08 09:50:00+07
43	10	SERVICE	3	\N	Bảo dưỡng định kỳ 10.000 km	1.00	HIGH	\N	2026-11-08 10:50:00+07
44	10	PART	\N	1	Cần thay dầu động cơ 5w-30 (1l)	5.00	MEDIUM	\N	2026-11-08 10:50:00+07
45	10	PART	\N	2	Cần thay lọc dầu động cơ	1.00	MEDIUM	\N	2026-11-08 10:50:00+07
46	10	PART	\N	3	Cần thay lọc gió động cơ	1.00	MEDIUM	\N	2026-11-08 10:50:00+07
47	10	PART	\N	4	Cần thay lọc gió điều hòa	1.00	MEDIUM	\N	2026-11-08 10:50:00+07
48	11	SERVICE	9	\N	Bảo dưỡng xe máy	1.00	HIGH	\N	2026-11-08 10:50:00+07
49	11	PART	\N	16	Cần thay dầu nhớt xe máy 0.8l	1.00	MEDIUM	\N	2026-11-08 10:50:00+07
50	11	PART	\N	17	Cần thay bugi xe máy	1.00	MEDIUM	\N	2026-11-08 10:50:00+07
51	12	SERVICE	1	\N	Thay dầu động cơ	1.00	HIGH	\N	2026-11-08 11:50:00+07
52	12	SERVICE	7	\N	Chẩn đoán động cơ	1.00	MEDIUM	\N	2026-11-08 11:50:00+07
53	12	PART	\N	1	Cần thay dầu động cơ 5w-30 (1l)	4.00	MEDIUM	\N	2026-11-08 11:50:00+07
54	12	PART	\N	2	Cần thay lọc dầu động cơ	1.00	MEDIUM	\N	2026-11-08 11:50:00+07
55	14	SERVICE	1	\N	Thay dầu động cơ	1.00	HIGH	\N	2026-10-15 09:50:00+07
56	14	PART	\N	1	Cần thay dầu động cơ 5w-30 (1l)	4.00	MEDIUM	\N	2026-10-15 09:50:00+07
57	14	PART	\N	2	Cần thay lọc dầu động cơ	1.00	MEDIUM	\N	2026-10-15 09:50:00+07
58	15	SERVICE	2	\N	Kiểm tra & thay má phanh	1.00	HIGH	\N	2026-11-07 10:50:00+07
59	15	PART	\N	5	Cần thay má phanh trước (bộ)	1.00	MEDIUM	\N	2026-11-07 10:50:00+07
60	16	SERVICE	5	\N	Đảo lốp & cân bằng động	1.00	HIGH	\N	2026-11-08 14:50:00+07
61	17	SERVICE	9	\N	Bảo dưỡng xe máy	1.00	HIGH	\N	2026-10-25 08:50:00+07
62	17	PART	\N	16	Cần thay dầu nhớt xe máy 0.8l	1.00	MEDIUM	\N	2026-10-25 08:50:00+07
63	17	PART	\N	17	Cần thay bugi xe máy	1.00	MEDIUM	\N	2026-10-25 08:50:00+07
64	18	SERVICE	3	\N	Bảo dưỡng định kỳ 10.000 km	1.00	HIGH	\N	2026-11-08 09:50:00+07
65	18	PART	\N	1	Cần thay dầu động cơ 5w-30 (1l)	5.00	MEDIUM	\N	2026-11-08 09:50:00+07
66	18	PART	\N	2	Cần thay lọc dầu động cơ	1.00	MEDIUM	\N	2026-11-08 09:50:00+07
67	20	SERVICE	8	\N	Kiểm tra hệ thống treo	1.00	HIGH	\N	2026-11-08 15:50:00+07
68	20	SERVICE	1	\N	Thay dầu động cơ	1.00	MEDIUM	\N	2026-11-08 15:50:00+07
69	20	PART	\N	11	Cần thay giảm xóc trước	4.00	MEDIUM	\N	2026-11-08 15:50:00+07
70	20	PART	\N	1	Cần thay dầu động cơ 5w-30 (1l)	4.00	MEDIUM	\N	2026-11-08 15:50:00+07
71	20	PART	\N	2	Cần thay lọc dầu động cơ	1.00	MEDIUM	\N	2026-11-08 15:50:00+07
72	21	SERVICE	2	\N	Kiểm tra & thay má phanh	1.00	HIGH	\N	2026-11-08 16:50:00+07
73	21	SERVICE	8	\N	Kiểm tra hệ thống treo	1.00	MEDIUM	\N	2026-11-08 16:50:00+07
74	21	SERVICE	6	\N	Kiểm tra & thay ắc quy	1.00	MEDIUM	\N	2026-11-08 16:50:00+07
75	21	PART	\N	5	Cần thay má phanh trước (bộ)	1.00	MEDIUM	\N	2026-11-08 16:50:00+07
76	21	PART	\N	11	Cần thay giảm xóc trước	4.00	MEDIUM	\N	2026-11-08 16:50:00+07
77	22	SERVICE	1	\N	Thay dầu động cơ	1.00	HIGH	\N	2026-11-08 08:50:00+07
78	22	SERVICE	5	\N	Đảo lốp & cân bằng động	1.00	MEDIUM	\N	2026-11-08 08:50:00+07
79	22	PART	\N	1	Cần thay dầu động cơ 5w-30 (1l)	4.00	MEDIUM	\N	2026-11-08 08:50:00+07
80	22	PART	\N	2	Cần thay lọc dầu động cơ	1.00	MEDIUM	\N	2026-11-08 08:50:00+07
81	23	SERVICE	3	\N	Bảo dưỡng định kỳ 10.000 km	1.00	HIGH	\N	2026-11-08 11:50:00+07
82	23	PART	\N	1	Cần thay dầu động cơ 5w-30 (1l)	5.00	MEDIUM	\N	2026-11-08 11:50:00+07
83	23	PART	\N	2	Cần thay lọc dầu động cơ	1.00	MEDIUM	\N	2026-11-08 11:50:00+07
84	23	PART	\N	3	Cần thay lọc gió động cơ	1.00	MEDIUM	\N	2026-11-08 11:50:00+07
85	24	SERVICE	2	\N	Kiểm tra & thay má phanh	1.00	HIGH	\N	2026-11-07 14:50:00+07
86	24	PART	\N	5	Cần thay má phanh trước (bộ)	1.00	MEDIUM	\N	2026-11-07 14:50:00+07
87	25	SERVICE	4	\N	Vệ sinh & nạp gas điều hòa	1.00	HIGH	\N	2026-11-06 15:50:00+07
88	25	PART	\N	9	Cần thay gas điều hòa r134a (bình)	1.00	MEDIUM	\N	2026-11-06 15:50:00+07
89	26	SERVICE	2	\N	Kiểm tra & thay má phanh	1.00	HIGH	\N	2026-11-07 10:50:00+07
90	26	PART	\N	5	Cần thay má phanh trước (bộ)	1.00	MEDIUM	\N	2026-11-07 10:50:00+07
\.


--
-- Data for Name: inspections; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inspections (inspection_id, reception_id, mechanic_id, assigned_by, status, result_summary, assigned_at, completed_at) FROM stdin;
1	1	6	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-10-12 08:10:00+07	2026-10-12 08:50:00+07
2	2	7	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-10-20 09:10:00+07	2026-10-20 09:50:00+07
3	3	7	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-05 08:10:00+07	2026-11-05 08:50:00+07
4	4	6	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-06 10:10:00+07	2026-11-06 10:50:00+07
5	5	6	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-07 08:10:00+07	2026-11-07 08:50:00+07
6	6	6	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-07 09:10:00+07	2026-11-07 09:50:00+07
7	7	7	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-07 13:10:00+07	2026-11-07 13:50:00+07
8	8	6	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-08 08:10:00+07	2026-11-08 08:50:00+07
9	9	6	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-08 09:10:00+07	2026-11-08 09:50:00+07
10	10	6	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-08 10:10:00+07	2026-11-08 10:50:00+07
11	11	6	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-08 10:10:00+07	2026-11-08 10:50:00+07
12	12	8	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-08 11:10:00+07	2026-11-08 11:50:00+07
13	13	8	3	ASSIGNED	\N	2026-11-08 13:10:00+07	\N
14	14	13	10	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-10-15 09:10:00+07	2026-10-15 09:50:00+07
15	15	13	10	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-07 10:10:00+07	2026-11-07 10:50:00+07
16	16	13	10	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-08 14:10:00+07	2026-11-08 14:50:00+07
17	17	20	17	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-10-25 08:10:00+07	2026-10-25 08:50:00+07
18	18	20	17	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-08 09:10:00+07	2026-11-08 09:50:00+07
19	20	6	3	ASSIGNED	\N	2026-11-09 09:10:00+07	\N
20	21	7	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-08 15:10:00+07	2026-11-08 15:50:00+07
21	22	8	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-08 16:10:00+07	2026-11-08 16:50:00+07
22	23	7	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-08 08:10:00+07	2026-11-08 08:50:00+07
23	24	8	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-08 11:10:00+07	2026-11-08 11:50:00+07
24	25	6	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-07 14:10:00+07	2026-11-07 14:50:00+07
25	26	7	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-06 15:10:00+07	2026-11-06 15:50:00+07
26	27	8	3	COMPLETED	Đã kiểm tra tổng quát; đề xuất các hạng mục bên dưới.	2026-11-07 10:10:00+07	2026-11-07 10:50:00+07
\.


--
-- Data for Name: inventories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventories (inventory_id, warehouse_id, part_id, quantity_on_hand, quantity_reserved, reorder_level, version, updated_at) FROM stdin;
1	1	1	99	16	5	0	2026-11-08 07:00:00+07
2	1	2	45	3	5	0	2026-11-08 07:00:00+07
3	1	3	39	2	5	0	2026-11-08 07:00:00+07
4	1	4	29	2	5	0	2026-11-08 07:00:00+07
5	1	5	26	1	5	0	2026-11-08 07:00:00+07
6	1	6	6	0	5	0	2026-11-08 07:00:00+07
7	1	7	29	0	5	0	2026-11-08 07:00:00+07
8	1	8	7	1	5	0	2026-11-08 07:00:00+07
9	1	9	28	1	5	0	2026-11-08 07:00:00+07
10	1	10	26	0	5	0	2026-11-08 07:00:00+07
11	1	11	4	2	5	0	2026-11-08 07:00:00+07
12	1	12	12	0	5	0	2026-11-08 07:00:00+07
13	1	13	4	0	5	0	2026-11-08 07:00:00+07
14	1	14	30	0	5	0	2026-11-08 07:00:00+07
15	1	15	30	0	5	0	2026-11-08 07:00:00+07
16	1	16	30	1	5	0	2026-11-08 07:00:00+07
17	1	17	30	1	5	0	2026-11-08 07:00:00+07
18	1	18	30	0	5	0	2026-11-08 07:00:00+07
19	1	19	30	0	5	0	2026-11-08 07:00:00+07
20	1	20	30	0	5	0	2026-11-08 07:00:00+07
21	2	1	76	0	5	0	2026-11-08 07:00:00+07
22	2	2	29	0	5	0	2026-11-08 07:00:00+07
23	2	3	30	0	5	0	2026-11-08 07:00:00+07
24	2	4	30	0	5	0	2026-11-08 07:00:00+07
25	2	5	30	1	5	0	2026-11-08 07:00:00+07
26	2	6	6	0	5	0	2026-11-08 07:00:00+07
27	2	7	30	0	5	0	2026-11-08 07:00:00+07
28	2	8	8	0	5	0	2026-11-08 07:00:00+07
29	2	9	30	0	5	0	2026-11-08 07:00:00+07
30	2	10	30	0	5	0	2026-11-08 07:00:00+07
31	2	11	4	0	5	0	2026-11-08 07:00:00+07
32	2	12	12	0	5	0	2026-11-08 07:00:00+07
33	2	13	4	0	5	0	2026-11-08 07:00:00+07
34	2	14	30	0	5	0	2026-11-08 07:00:00+07
35	2	15	30	0	5	0	2026-11-08 07:00:00+07
36	2	16	30	0	5	0	2026-11-08 07:00:00+07
37	2	17	30	0	5	0	2026-11-08 07:00:00+07
38	2	18	30	0	5	0	2026-11-08 07:00:00+07
39	2	19	30	0	5	0	2026-11-08 07:00:00+07
40	2	20	30	0	5	0	2026-11-08 07:00:00+07
41	3	1	80	5	5	0	2026-11-08 07:00:00+07
42	3	2	30	1	5	0	2026-11-08 07:00:00+07
43	3	3	30	0	5	0	2026-11-08 07:00:00+07
44	3	4	30	0	5	0	2026-11-08 07:00:00+07
45	3	5	30	0	5	0	2026-11-08 07:00:00+07
46	3	6	6	0	5	0	2026-11-08 07:00:00+07
47	3	7	30	0	5	0	2026-11-08 07:00:00+07
48	3	8	8	0	5	0	2026-11-08 07:00:00+07
49	3	9	30	0	5	0	2026-11-08 07:00:00+07
50	3	10	30	0	5	0	2026-11-08 07:00:00+07
51	3	11	4	0	5	0	2026-11-08 07:00:00+07
52	3	12	12	0	5	0	2026-11-08 07:00:00+07
53	3	13	4	0	5	0	2026-11-08 07:00:00+07
54	3	14	30	0	5	0	2026-11-08 07:00:00+07
55	3	15	30	0	5	0	2026-11-08 07:00:00+07
56	3	16	29	0	5	0	2026-11-08 07:00:00+07
57	3	17	29	0	5	0	2026-11-08 07:00:00+07
58	3	18	30	0	5	0	2026-11-08 07:00:00+07
59	3	19	30	0	5	0	2026-11-08 07:00:00+07
60	3	20	30	0	5	0	2026-11-08 07:00:00+07
\.


--
-- Data for Name: inventory_receipt_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory_receipt_items (receipt_item_id, receipt_id, part_id, quantity, unit_cost) FROM stdin;
1	1	1	80	126000.00
2	1	2	30	84000.00
3	1	3	30	175000.00
4	1	4	30	154000.00
5	1	5	30	595000.00
6	1	6	6	840000.00
7	1	7	30	105000.00
8	1	8	8	1155000.00
9	1	9	30	315000.00
10	1	10	30	196000.00
11	1	11	4	1330000.00
12	1	12	12	1015000.00
13	1	13	4	126000.00
14	1	14	30	84000.00
15	1	15	30	364000.00
16	1	16	30	77000.00
17	1	17	30	42000.00
18	1	18	30	455000.00
19	1	19	30	112000.00
20	1	20	30	161000.00
21	2	1	80	126000.00
22	2	2	30	84000.00
23	2	3	30	175000.00
24	2	4	30	154000.00
25	2	5	30	595000.00
26	2	6	6	840000.00
27	2	7	30	105000.00
28	2	8	8	1155000.00
29	2	9	30	315000.00
30	2	10	30	196000.00
31	2	11	4	1330000.00
32	2	12	12	1015000.00
33	2	13	4	126000.00
34	2	14	30	84000.00
35	2	15	30	364000.00
36	2	16	30	77000.00
37	2	17	30	42000.00
38	2	18	30	455000.00
39	2	19	30	112000.00
40	2	20	30	161000.00
41	3	1	80	126000.00
42	3	2	30	84000.00
43	3	3	30	175000.00
44	3	4	30	154000.00
45	3	5	30	595000.00
46	3	6	6	840000.00
47	3	7	30	105000.00
48	3	8	8	1155000.00
49	3	9	30	315000.00
50	3	10	30	196000.00
51	3	11	4	1330000.00
52	3	12	12	1015000.00
53	3	13	4	126000.00
54	3	14	30	84000.00
55	3	15	30	364000.00
56	3	16	30	77000.00
57	3	17	30	42000.00
58	3	18	30	455000.00
59	3	19	30	112000.00
60	3	20	30	161000.00
61	4	1	40	126000.00
62	4	2	20	84000.00
63	4	3	10	175000.00
\.


--
-- Data for Name: inventory_receipts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory_receipts (receipt_id, receipt_code, warehouse_id, supplier_name, received_by, receipt_date, note) FROM stdin;
1	GR-261001-001	1	Công ty CP Phụ tùng Ô tô Việt	3	2026-10-01 09:00:00+07	Nhập kho đầu kỳ
2	GR-261001-002	2	Công ty CP Phụ tùng Ô tô Việt	10	2026-10-01 09:00:00+07	Nhập kho đầu kỳ
3	GR-261001-003	3	Công ty CP Phụ tùng Ô tô Việt	17	2026-10-01 09:00:00+07	Nhập kho đầu kỳ
4	GR-261102-001	1	Công ty TNHH Dầu nhớt Sài Gòn	4	2026-11-02 14:00:00+07	Bổ sung dầu nhớt và lọc
\.


--
-- Data for Name: inventory_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory_transactions (transaction_id, inventory_id, transaction_type, quantity, balance_after, reference_type, reference_id, performed_by, created_at) FROM stdin;
1	1	RECEIPT	80	80	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
2	2	RECEIPT	30	30	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
3	3	RECEIPT	30	30	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
4	4	RECEIPT	30	30	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
5	5	RECEIPT	30	30	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
6	6	RECEIPT	6	6	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
7	7	RECEIPT	30	30	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
8	8	RECEIPT	8	8	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
9	9	RECEIPT	30	30	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
10	10	RECEIPT	30	30	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
11	11	RECEIPT	4	4	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
12	12	RECEIPT	12	12	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
13	13	RECEIPT	4	4	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
14	14	RECEIPT	30	30	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
15	15	RECEIPT	30	30	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
16	16	RECEIPT	30	30	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
17	17	RECEIPT	30	30	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
18	18	RECEIPT	30	30	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
19	19	RECEIPT	30	30	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
20	20	RECEIPT	30	30	INVENTORY_RECEIPT	1	3	2026-10-01 09:00:00+07
21	21	RECEIPT	80	80	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
22	22	RECEIPT	30	30	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
23	23	RECEIPT	30	30	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
24	24	RECEIPT	30	30	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
25	25	RECEIPT	30	30	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
26	26	RECEIPT	6	6	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
27	27	RECEIPT	30	30	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
28	28	RECEIPT	8	8	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
29	29	RECEIPT	30	30	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
30	30	RECEIPT	30	30	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
31	31	RECEIPT	4	4	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
32	32	RECEIPT	12	12	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
33	33	RECEIPT	4	4	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
34	34	RECEIPT	30	30	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
35	35	RECEIPT	30	30	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
36	36	RECEIPT	30	30	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
37	37	RECEIPT	30	30	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
38	38	RECEIPT	30	30	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
39	39	RECEIPT	30	30	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
40	40	RECEIPT	30	30	INVENTORY_RECEIPT	2	10	2026-10-01 09:00:00+07
41	41	RECEIPT	80	80	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
42	42	RECEIPT	30	30	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
43	43	RECEIPT	30	30	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
44	44	RECEIPT	30	30	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
45	45	RECEIPT	30	30	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
46	46	RECEIPT	6	6	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
47	47	RECEIPT	30	30	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
48	48	RECEIPT	8	8	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
49	49	RECEIPT	30	30	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
50	50	RECEIPT	30	30	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
51	51	RECEIPT	4	4	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
52	52	RECEIPT	12	12	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
53	53	RECEIPT	4	4	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
54	54	RECEIPT	30	30	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
55	55	RECEIPT	30	30	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
56	56	RECEIPT	30	30	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
57	57	RECEIPT	30	30	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
58	58	RECEIPT	30	30	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
59	59	RECEIPT	30	30	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
60	60	RECEIPT	30	30	INVENTORY_RECEIPT	3	17	2026-10-01 09:00:00+07
61	1	RESERVE	4	80	REPAIR_ORDER	1	3	2026-10-12 10:25:00+07
62	2	RESERVE	1	30	REPAIR_ORDER	1	3	2026-10-12 10:25:00+07
63	5	RESERVE	1	30	REPAIR_ORDER	1	3	2026-10-12 10:25:00+07
64	1	ISSUE	-4	76	PART_REQUEST	1	3	2026-10-12 11:25:00+07
65	2	ISSUE	-1	29	PART_REQUEST	1	3	2026-10-12 11:25:00+07
66	5	ISSUE	-1	29	PART_REQUEST	1	3	2026-10-12 11:25:00+07
67	21	RESERVE	4	80	REPAIR_ORDER	12	10	2026-10-15 11:25:00+07
68	22	RESERVE	1	30	REPAIR_ORDER	12	10	2026-10-15 11:25:00+07
69	21	ISSUE	-4	76	PART_REQUEST	8	10	2026-10-15 12:25:00+07
70	22	ISSUE	-1	29	PART_REQUEST	8	10	2026-10-15 12:25:00+07
71	4	RESERVE	1	30	REPAIR_ORDER	2	3	2026-10-20 11:25:00+07
72	8	RESERVE	1	8	REPAIR_ORDER	2	3	2026-10-20 11:25:00+07
73	9	RESERVE	1	30	REPAIR_ORDER	2	3	2026-10-20 11:25:00+07
74	4	ISSUE	-1	29	PART_REQUEST	2	3	2026-10-20 12:25:00+07
75	8	ISSUE	-1	7	PART_REQUEST	2	3	2026-10-20 12:25:00+07
76	9	ISSUE	-1	29	PART_REQUEST	2	3	2026-10-20 12:25:00+07
77	56	RESERVE	1	30	REPAIR_ORDER	15	17	2026-10-25 10:25:00+07
78	57	RESERVE	1	30	REPAIR_ORDER	15	17	2026-10-25 10:25:00+07
79	56	ISSUE	-1	29	PART_REQUEST	9	17	2026-10-25 11:25:00+07
80	57	ISSUE	-1	29	PART_REQUEST	9	17	2026-10-25 11:25:00+07
81	1	RECEIPT	40	116	INVENTORY_RECEIPT	4	4	2026-11-02 14:00:00+07
82	2	RECEIPT	20	49	INVENTORY_RECEIPT	4	4	2026-11-02 14:00:00+07
83	3	RECEIPT	10	40	INVENTORY_RECEIPT	4	4	2026-11-02 14:00:00+07
84	1	RESERVE	4	116	REPAIR_ORDER	3	3	2026-11-05 10:25:00+07
85	2	RESERVE	1	49	REPAIR_ORDER	3	3	2026-11-05 10:25:00+07
86	1	ISSUE	-4	112	PART_REQUEST	3	3	2026-11-05 11:25:00+07
87	2	ISSUE	-1	48	PART_REQUEST	3	3	2026-11-05 11:25:00+07
88	5	RESERVE	1	29	REPAIR_ORDER	4	3	2026-11-06 12:25:00+07
89	7	RESERVE	1	30	REPAIR_ORDER	4	3	2026-11-06 12:25:00+07
90	5	ISSUE	-1	28	PART_REQUEST	4	3	2026-11-06 13:25:00+07
91	7	ISSUE	-1	29	PART_REQUEST	4	3	2026-11-06 13:25:00+07
92	9	RESERVE	1	29	REPAIR_ORDER	20	3	2026-11-06 17:25:00+07
93	9	ISSUE	-1	28	PART_REQUEST	13	3	2026-11-06 18:25:00+07
94	10	RESERVE	4	30	REPAIR_ORDER	5	3	2026-11-07 10:25:00+07
95	1	RESERVE	4	112	REPAIR_ORDER	5	3	2026-11-07 10:25:00+07
96	2	RESERVE	1	48	REPAIR_ORDER	5	3	2026-11-07 10:25:00+07
97	10	ISSUE	-4	26	PART_REQUEST	5	3	2026-11-07 11:25:00+07
98	1	ISSUE	-4	108	PART_REQUEST	5	3	2026-11-07 11:25:00+07
99	2	ISSUE	-1	47	PART_REQUEST	5	3	2026-11-07 11:25:00+07
100	1	RESERVE	6	108	REPAIR_ORDER	6	3	2026-11-07 11:25:00+07
101	2	RESERVE	1	47	REPAIR_ORDER	6	3	2026-11-07 11:25:00+07
102	3	RESERVE	1	40	REPAIR_ORDER	6	3	2026-11-07 11:25:00+07
103	11	RESERVE	2	4	REPAIR_ORDER	6	3	2026-11-07 11:25:00+07
104	25	RESERVE	1	30	REPAIR_ORDER	13	10	2026-11-07 12:25:00+07
105	5	RESERVE	1	28	REPAIR_ORDER	21	3	2026-11-07 12:25:00+07
106	5	ISSUE	-1	27	PART_REQUEST	14	3	2026-11-07 13:25:00+07
107	5	RESERVE	1	27	REPAIR_ORDER	7	3	2026-11-07 15:25:00+07
108	5	RESERVE	1	27	REPAIR_ORDER	19	3	2026-11-07 16:25:00+07
109	5	ISSUE	-1	26	PART_REQUEST	12	3	2026-11-07 17:25:00+07
110	4	RESERVE	1	29	REPAIR_ORDER	8	3	2026-11-08 10:25:00+07
111	9	RESERVE	1	28	REPAIR_ORDER	8	3	2026-11-08 10:25:00+07
112	8	RESERVE	1	7	REPAIR_ORDER	8	3	2026-11-08 10:25:00+07
113	1	RESERVE	4	108	REPAIR_ORDER	17	3	2026-11-08 10:25:00+07
114	2	RESERVE	1	47	REPAIR_ORDER	17	3	2026-11-08 10:25:00+07
115	1	RESERVE	5	108	REPAIR_ORDER	9	3	2026-11-08 11:25:00+07
116	2	RESERVE	1	47	REPAIR_ORDER	9	3	2026-11-08 11:25:00+07
117	41	RESERVE	5	80	REPAIR_ORDER	16	17	2026-11-08 11:25:00+07
118	42	RESERVE	1	30	REPAIR_ORDER	16	17	2026-11-08 11:25:00+07
119	1	ISSUE	-4	104	PART_REQUEST	10	3	2026-11-08 11:25:00+07
120	2	ISSUE	-1	46	PART_REQUEST	10	3	2026-11-08 11:25:00+07
121	1	RESERVE	5	104	REPAIR_ORDER	10	3	2026-11-08 12:25:00+07
122	2	RESERVE	1	46	REPAIR_ORDER	10	3	2026-11-08 12:25:00+07
123	3	RESERVE	1	40	REPAIR_ORDER	10	3	2026-11-08 12:25:00+07
124	4	RESERVE	1	29	REPAIR_ORDER	10	3	2026-11-08 12:25:00+07
125	16	RESERVE	1	30	REPAIR_ORDER	11	3	2026-11-08 12:25:00+07
126	17	RESERVE	1	30	REPAIR_ORDER	11	3	2026-11-08 12:25:00+07
127	1	RESERVE	5	104	REPAIR_ORDER	18	3	2026-11-08 13:25:00+07
128	2	RESERVE	1	46	REPAIR_ORDER	18	3	2026-11-08 13:25:00+07
129	3	RESERVE	1	40	REPAIR_ORDER	18	3	2026-11-08 13:25:00+07
130	1	ISSUE	-5	99	PART_REQUEST	11	3	2026-11-08 14:25:00+07
131	2	ISSUE	-1	45	PART_REQUEST	11	3	2026-11-08 14:25:00+07
132	3	ISSUE	-1	39	PART_REQUEST	11	3	2026-11-08 14:25:00+07
\.


--
-- Data for Name: invoice_lines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.invoice_lines (line_id, invoice_id, quotation_item_id, item_type, description, quantity, unit_price, vat_rate, vat_amount, line_total, is_warranty_covered) FROM stdin;
1	1	1	SERVICE	Bảo dưỡng định kỳ 10.000 km	1.00	900000.00	8.00	72000.00	972000.00	f
2	1	2	SERVICE	Kiểm tra & thay má phanh	1.00	250000.00	8.00	20000.00	270000.00	f
3	1	3	PART	Dầu động cơ 5W-30 (1L)	4.00	180000.00	8.00	57600.00	777600.00	f
4	1	4	PART	Lọc dầu động cơ	1.00	120000.00	8.00	9600.00	129600.00	f
5	1	5	PART	Má phanh trước (bộ)	1.00	850000.00	8.00	68000.00	918000.00	f
6	2	6	SERVICE	Vệ sinh & nạp gas điều hòa	1.00	600000.00	8.00	48000.00	648000.00	f
7	2	7	SERVICE	Kiểm tra & thay ắc quy	1.00	150000.00	8.00	12000.00	162000.00	f
8	2	9	PART	Lọc gió điều hòa	1.00	220000.00	8.00	17600.00	237600.00	f
9	2	10	PART	Ắc quy 12V 45Ah	1.00	1650000.00	8.00	132000.00	1782000.00	f
10	2	11	PART	Gas điều hòa R134a (bình)	1.00	450000.00	8.00	36000.00	486000.00	f
11	3	55	SERVICE	Thay dầu động cơ	1.00	350000.00	8.00	28000.00	378000.00	f
12	3	56	PART	Dầu động cơ 5W-30 (1L)	4.00	180000.00	8.00	57600.00	777600.00	f
13	3	57	PART	Lọc dầu động cơ	1.00	120000.00	8.00	9600.00	129600.00	f
14	4	61	SERVICE	Bảo dưỡng xe máy	1.00	200000.00	8.00	16000.00	216000.00	f
15	4	62	PART	Dầu nhớt xe máy 0.8L	1.00	110000.00	8.00	8800.00	118800.00	f
16	4	63	PART	Bugi xe máy	1.00	60000.00	8.00	4800.00	64800.00	f
17	5	72	SERVICE	Thay dầu động cơ	1.00	350000.00	8.00	28000.00	378000.00	f
18	5	73	SERVICE	Đảo lốp & cân bằng động	1.00	300000.00	8.00	24000.00	324000.00	f
19	5	74	PART	Dầu động cơ 5W-30 (1L)	4.00	180000.00	8.00	57600.00	777600.00	f
20	5	75	PART	Lọc dầu động cơ	1.00	120000.00	8.00	9600.00	129600.00	f
21	6	76	SERVICE	Bảo dưỡng định kỳ 10.000 km	1.00	900000.00	8.00	72000.00	972000.00	f
22	6	77	PART	Dầu động cơ 5W-30 (1L)	5.00	180000.00	8.00	72000.00	972000.00	f
23	6	78	PART	Lọc dầu động cơ	1.00	120000.00	8.00	9600.00	129600.00	f
24	6	79	PART	Lọc gió động cơ	1.00	250000.00	8.00	20000.00	270000.00	f
25	7	80	SERVICE	Kiểm tra & thay má phanh	1.00	250000.00	8.00	20000.00	270000.00	f
26	7	81	PART	Má phanh trước (bộ)	1.00	850000.00	8.00	68000.00	918000.00	f
27	8	82	SERVICE	Vệ sinh & nạp gas điều hòa	1.00	600000.00	8.00	48000.00	648000.00	f
28	8	83	PART	Gas điều hòa R134a (bình)	1.00	450000.00	8.00	36000.00	486000.00	f
29	9	84	SERVICE	Kiểm tra & thay má phanh	1.00	250000.00	8.00	0.00	0.00	t
30	9	85	PART	Má phanh trước (bộ)	1.00	850000.00	8.00	0.00	0.00	t
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.invoices (invoice_id, invoice_code, repair_order_id, billing_id, subtotal, discount_amount, vat_amount, total_amount, payment_status, status, finalized_by, finalized_at, created_at) FROM stdin;
1	INV-261012-0001	1	1	2840000.00	0.00	227200.00	3067200.00	PAID	FINALIZED	5	2026-10-12 15:00:00+07	2026-10-12 15:00:00+07
2	INV-261020-0001	2	2	3070000.00	0.00	245600.00	3315600.00	PAID	FINALIZED	5	2026-10-20 16:00:00+07	2026-10-20 16:00:00+07
3	INV-261015-0001	12	5	1190000.00	0.00	95200.00	1285200.00	PAID	FINALIZED	12	2026-10-15 16:00:00+07	2026-10-15 16:00:00+07
4	INV-261025-0001	15	6	370000.00	0.00	29600.00	399600.00	PAID	FINALIZED	19	2026-10-25 15:00:00+07	2026-10-25 15:00:00+07
5	INV-261108-0001	17	4	1490000.00	0.00	119200.00	1609200.00	UNPAID	FINALIZED	5	2026-11-08 15:00:00+07	2026-11-08 15:00:00+07
6	INV-261108-0002	18	\N	2170000.00	0.00	173600.00	2343600.00	UNPAID	FINALIZED	5	2026-11-08 18:00:00+07	2026-11-08 18:00:00+07
7	INV-261107-0001	19	3	1100000.00	0.00	88000.00	1188000.00	PAID	FINALIZED	5	2026-11-07 21:00:00+07	2026-11-07 21:00:00+07
8	INV-261106-0001	20	\N	1050000.00	0.00	84000.00	1134000.00	PAID	FINALIZED	5	2026-11-06 22:00:00+07	2026-11-06 22:00:00+07
9	INV-261107-0002	21	\N	0.00	0.00	0.00	0.00	UNPAID	FINALIZED	5	2026-11-07 17:00:00+07	2026-11-07 17:00:00+07
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (notification_id, user_id, channel, title, content, reference_type, reference_id, status, sent_at, created_at) FROM stdin;
1	23	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	1	SENT	2026-10-12 09:00:00+07	2026-10-12 09:00:00+07
2	6	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261012-0001 đã được giao cho bạn.	REPAIR_ORDER	1	SENT	2026-10-12 10:35:00+07	2026-10-12 10:35:00+07
3	24	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	2	SENT	2026-10-20 10:00:00+07	2026-10-20 10:00:00+07
4	7	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261020-0001 đã được giao cho bạn.	REPAIR_ORDER	2	SENT	2026-10-20 11:35:00+07	2026-10-20 11:35:00+07
5	25	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	3	SENT	2026-11-05 09:00:00+07	2026-11-05 09:00:00+07
6	7	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261105-0001 đã được giao cho bạn.	REPAIR_ORDER	3	SENT	2026-11-05 10:35:00+07	2026-11-05 10:35:00+07
7	5	IN_APP	Hồ sơ chờ thanh toán	Lệnh RO-261105-0001 đã hoàn tất kỹ thuật, chờ thu ngân.	REPAIR_ORDER	3	SENT	2026-11-05 14:40:00+07	2026-11-05 14:40:00+07
8	26	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	4	SENT	2026-11-06 11:00:00+07	2026-11-06 11:00:00+07
9	6	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261106-0001 đã được giao cho bạn.	REPAIR_ORDER	4	SENT	2026-11-06 12:35:00+07	2026-11-06 12:35:00+07
10	3	IN_APP	Lệnh sửa chữa đã hoàn thành	Lệnh RO-261106-0001 chờ lễ tân xác nhận.	REPAIR_ORDER	4	SENT	2026-11-06 16:20:00+07	2026-11-06 16:20:00+07
11	27	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	5	SENT	2026-11-07 09:00:00+07	2026-11-07 09:00:00+07
12	6	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261107-0001 đã được giao cho bạn.	REPAIR_ORDER	5	SENT	2026-11-07 10:35:00+07	2026-11-07 10:35:00+07
13	28	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	6	SENT	2026-11-07 10:00:00+07	2026-11-07 10:00:00+07
14	6	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261107-0002 đã được giao cho bạn.	REPAIR_ORDER	6	SENT	2026-11-07 11:35:00+07	2026-11-07 11:35:00+07
15	3	IN_APP	Yêu cầu xuất phụ tùng mới	Lệnh RO-261107-0002 yêu cầu phụ tùng.	PART_REQUEST	6	SENT	2026-11-07 12:30:00+07	2026-11-07 12:30:00+07
16	30	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	7	SENT	2026-11-07 14:00:00+07	2026-11-07 14:00:00+07
17	7	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261107-0003 đã được giao cho bạn.	REPAIR_ORDER	7	SENT	2026-11-07 15:35:00+07	2026-11-07 15:35:00+07
18	3	IN_APP	Yêu cầu xuất phụ tùng mới	Lệnh RO-261107-0003 yêu cầu phụ tùng.	PART_REQUEST	7	SENT	2026-11-07 16:30:00+07	2026-11-07 16:30:00+07
19	31	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	8	SENT	2026-11-08 09:00:00+07	2026-11-08 09:00:00+07
20	6	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261108-0001 đã được giao cho bạn.	REPAIR_ORDER	8	SENT	2026-11-08 10:35:00+07	2026-11-08 10:35:00+07
21	33	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	9	SENT	2026-11-08 10:00:00+07	2026-11-08 10:00:00+07
22	6	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261108-0002 đã được giao cho bạn.	REPAIR_ORDER	9	SENT	2026-11-08 11:35:00+07	2026-11-08 11:35:00+07
23	34	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	10	SENT	2026-11-08 11:00:00+07	2026-11-08 11:00:00+07
24	23	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	11	SENT	2026-11-08 11:00:00+07	2026-11-08 11:00:00+07
25	32	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	12	SENT	2026-11-08 12:00:00+07	2026-11-08 12:00:00+07
26	8	IN_APP	Bạn được phân công kiểm tra xe	Lịch hẹn APT-261108-0006 – xe 29E1-135.79	INSPECTION	13	SENT	2026-11-08 13:10:00+07	2026-11-08 13:10:00+07
27	23	IN_APP	Lịch hẹn đã được xác nhận	Lịch hẹn ngày 2026-11-10 08:00 đã được xác nhận.	APPOINTMENT	14	SENT	2026-11-08 08:00:00+07	2026-11-08 08:00:00+07
28	29	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	13	SENT	2026-10-15 10:00:00+07	2026-10-15 10:00:00+07
29	13	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261015-0001 đã được giao cho bạn.	REPAIR_ORDER	12	SENT	2026-10-15 11:35:00+07	2026-10-15 11:35:00+07
30	30	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	14	SENT	2026-11-07 11:00:00+07	2026-11-07 11:00:00+07
31	13	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261107-0004 đã được giao cho bạn.	REPAIR_ORDER	13	SENT	2026-11-07 12:35:00+07	2026-11-07 12:35:00+07
32	29	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	15	SENT	2026-11-08 15:00:00+07	2026-11-08 15:00:00+07
33	32	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	16	SENT	2026-10-25 09:00:00+07	2026-10-25 09:00:00+07
34	20	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261025-0001 đã được giao cho bạn.	REPAIR_ORDER	15	SENT	2026-10-25 10:35:00+07	2026-10-25 10:35:00+07
35	32	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	17	SENT	2026-11-08 10:00:00+07	2026-11-08 10:00:00+07
36	20	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261108-0006 đã được giao cho bạn.	REPAIR_ORDER	16	SENT	2026-11-08 11:35:00+07	2026-11-08 11:35:00+07
37	32	IN_APP	Lịch hẹn đã được xác nhận	Lịch hẹn ngày 2026-11-13 09:00 đã được xác nhận.	APPOINTMENT	25	SENT	2026-11-11 09:00:00+07	2026-11-11 09:00:00+07
38	24	IN_APP	Lịch hẹn đã được xác nhận	Lịch hẹn ngày 2026-11-09 09:00 đã được xác nhận.	APPOINTMENT	26	SENT	2026-11-07 09:00:00+07	2026-11-07 09:00:00+07
39	27	IN_APP	Lịch hẹn đã được xác nhận	Lịch hẹn ngày 2026-11-09 10:00 đã được xác nhận.	APPOINTMENT	27	SENT	2026-11-07 10:00:00+07	2026-11-07 10:00:00+07
40	6	IN_APP	Bạn được phân công kiểm tra xe	Lịch hẹn APT-261109-0005 – xe 30E-246.13	INSPECTION	19	SENT	2026-11-09 09:10:00+07	2026-11-09 09:10:00+07
41	3	IN_APP	Kết quả kiểm tra mới	Xe 29A-654.32 đã kiểm tra xong, mời lập báo giá.	INSPECTION	20	SENT	2026-11-08 15:50:00+07	2026-11-08 15:50:00+07
42	24	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	18	SENT	2026-11-08 17:00:00+07	2026-11-08 17:00:00+07
43	3	IN_APP	Khách đã duyệt báo giá	Báo giá QT-261108-0008 đã được duyệt, mời tạo lệnh sửa chữa.	QUOTATION	18	SENT	2026-11-08 18:00:00+07	2026-11-08 18:00:00+07
44	28	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	19	SENT	2026-11-08 09:00:00+07	2026-11-08 09:00:00+07
45	7	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261108-0007 đã được giao cho bạn.	REPAIR_ORDER	17	SENT	2026-11-08 10:35:00+07	2026-11-08 10:35:00+07
46	5	IN_APP	Hồ sơ chờ thanh toán	Lệnh RO-261108-0007 đã hoàn tất kỹ thuật, chờ thu ngân.	REPAIR_ORDER	17	SENT	2026-11-08 14:40:00+07	2026-11-08 14:40:00+07
47	34	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	20	SENT	2026-11-08 12:00:00+07	2026-11-08 12:00:00+07
48	8	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261108-0008 đã được giao cho bạn.	REPAIR_ORDER	18	SENT	2026-11-08 13:35:00+07	2026-11-08 13:35:00+07
49	5	IN_APP	Hồ sơ chờ thanh toán	Lệnh RO-261108-0008 đã hoàn tất kỹ thuật, chờ thu ngân.	REPAIR_ORDER	18	SENT	2026-11-08 17:40:00+07	2026-11-08 17:40:00+07
50	25	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	21	SENT	2026-11-07 15:00:00+07	2026-11-07 15:00:00+07
51	6	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261107-0005 đã được giao cho bạn.	REPAIR_ORDER	19	SENT	2026-11-07 16:35:00+07	2026-11-07 16:35:00+07
52	5	IN_APP	Hồ sơ chờ thanh toán	Lệnh RO-261107-0005 đã hoàn tất kỹ thuật, chờ thu ngân.	REPAIR_ORDER	19	SENT	2026-11-07 20:40:00+07	2026-11-07 20:40:00+07
53	30	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	22	SENT	2026-11-06 16:00:00+07	2026-11-06 16:00:00+07
54	7	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261106-0002 đã được giao cho bạn.	REPAIR_ORDER	20	SENT	2026-11-06 17:35:00+07	2026-11-06 17:35:00+07
55	5	IN_APP	Hồ sơ chờ thanh toán	Lệnh RO-261106-0002 đã hoàn tất kỹ thuật, chờ thu ngân.	REPAIR_ORDER	20	SENT	2026-11-06 21:40:00+07	2026-11-06 21:40:00+07
56	33	IN_APP	Báo giá sửa chữa mới	Vui lòng xem và phê duyệt báo giá cho xe của bạn.	QUOTATION	23	SENT	2026-11-07 11:00:00+07	2026-11-07 11:00:00+07
57	8	IN_APP	Bạn được phân công lệnh sửa chữa	Lệnh RO-261107-0006 đã được giao cho bạn.	REPAIR_ORDER	21	SENT	2026-11-07 12:35:00+07	2026-11-07 12:35:00+07
58	5	IN_APP	Hồ sơ chờ thanh toán	Lệnh RO-261107-0006 đã hoàn tất kỹ thuật, chờ thu ngân.	REPAIR_ORDER	21	SENT	2026-11-07 16:40:00+07	2026-11-07 16:40:00+07
\.


--
-- Data for Name: part_request_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.part_request_items (request_item_id, request_id, quotation_item_id, part_id, quantity_requested, quantity_issued) FROM stdin;
1	1	3	1	4	4
2	1	4	2	1	1
3	1	5	5	1	1
4	2	9	4	1	1
5	2	10	8	1	1
6	2	11	9	1	1
7	3	14	1	4	4
8	3	15	2	1	1
9	4	17	5	1	1
10	4	18	7	1	1
11	5	21	10	4	4
12	5	22	1	4	4
13	5	23	2	1	1
14	6	26	1	6	0
15	6	27	2	1	0
16	7	32	6	2	0
17	8	56	1	4	4
18	8	57	2	1	1
19	9	62	16	1	1
20	9	63	17	1	1
21	10	74	1	4	4
22	10	75	2	1	1
23	11	77	1	5	5
24	11	78	2	1	1
25	11	79	3	1	1
26	12	81	5	1	1
27	13	83	9	1	1
28	14	85	5	1	1
\.


--
-- Data for Name: part_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.part_requests (request_id, request_code, repair_order_id, task_id, requested_by, status, note, processed_by, processed_at, created_at) FROM stdin;
1	PR-261012-0001	1	1	6	ISSUED	Lấy phụ tùng theo báo giá	3	2026-10-12 11:25:00+07	2026-10-12 11:10:00+07
2	PR-261020-0001	2	3	7	ISSUED	Lấy phụ tùng theo báo giá	3	2026-10-20 12:25:00+07	2026-10-20 12:10:00+07
3	PR-261105-0001	3	5	7	ISSUED	Lấy phụ tùng theo báo giá	3	2026-11-05 11:25:00+07	2026-11-05 11:10:00+07
4	PR-261106-0001	4	7	6	ISSUED	Lấy phụ tùng theo báo giá	3	2026-11-06 13:25:00+07	2026-11-06 13:10:00+07
5	PR-261107-0001	5	8	6	ISSUED	Lấy phụ tùng theo báo giá	3	2026-11-07 11:25:00+07	2026-11-07 11:10:00+07
6	PR-261107-0002	6	10	6	PENDING	Cần phụ tùng để tiếp tục công việc	\N	\N	2026-11-07 12:30:00+07
7	PR-261107-0003	7	12	7	PENDING	Cần phụ tùng để tiếp tục công việc	\N	\N	2026-11-07 16:30:00+07
8	PR-261015-0001	12	20	13	ISSUED	Lấy phụ tùng theo báo giá	10	2026-10-15 12:25:00+07	2026-10-15 12:10:00+07
9	PR-261025-0001	15	23	20	ISSUED	Lấy phụ tùng theo báo giá	17	2026-10-25 11:25:00+07	2026-10-25 11:10:00+07
10	PR-261108-0001	17	25	7	ISSUED	Lấy phụ tùng theo báo giá	3	2026-11-08 11:25:00+07	2026-11-08 11:10:00+07
11	PR-261108-0002	18	27	8	ISSUED	Lấy phụ tùng theo báo giá	3	2026-11-08 14:25:00+07	2026-11-08 14:10:00+07
12	PR-261107-0004	19	28	6	ISSUED	Lấy phụ tùng theo báo giá	3	2026-11-07 17:25:00+07	2026-11-07 17:10:00+07
13	PR-261106-0002	20	29	7	ISSUED	Lấy phụ tùng theo báo giá	3	2026-11-06 18:25:00+07	2026-11-06 18:10:00+07
14	PR-261107-0005	21	30	8	ISSUED	Lấy phụ tùng theo báo giá	3	2026-11-07 13:25:00+07	2026-11-07 13:10:00+07
\.


--
-- Data for Name: part_reservations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.part_reservations (reservation_id, repair_order_id, quotation_item_id, inventory_id, quantity, status, reserved_by, created_at, updated_at) FROM stdin;
1	1	3	1	4	ISSUED	3	2026-10-12 10:25:00+07	2026-10-12 11:25:00+07
2	1	4	2	1	ISSUED	3	2026-10-12 10:25:00+07	2026-10-12 11:25:00+07
3	1	5	5	1	ISSUED	3	2026-10-12 10:25:00+07	2026-10-12 11:25:00+07
4	2	9	4	1	ISSUED	3	2026-10-20 11:25:00+07	2026-10-20 12:25:00+07
5	2	10	8	1	ISSUED	3	2026-10-20 11:25:00+07	2026-10-20 12:25:00+07
6	2	11	9	1	ISSUED	3	2026-10-20 11:25:00+07	2026-10-20 12:25:00+07
7	3	14	1	4	ISSUED	3	2026-11-05 10:25:00+07	2026-11-05 11:25:00+07
8	3	15	2	1	ISSUED	3	2026-11-05 10:25:00+07	2026-11-05 11:25:00+07
9	4	17	5	1	ISSUED	3	2026-11-06 12:25:00+07	2026-11-06 13:25:00+07
10	4	18	7	1	ISSUED	3	2026-11-06 12:25:00+07	2026-11-06 13:25:00+07
11	5	21	10	4	ISSUED	3	2026-11-07 10:25:00+07	2026-11-07 11:25:00+07
12	5	22	1	4	ISSUED	3	2026-11-07 10:25:00+07	2026-11-07 11:25:00+07
13	5	23	2	1	ISSUED	3	2026-11-07 10:25:00+07	2026-11-07 11:25:00+07
14	6	26	1	6	RESERVED	3	2026-11-07 11:25:00+07	2026-11-07 11:25:00+07
15	6	27	2	1	RESERVED	3	2026-11-07 11:25:00+07	2026-11-07 11:25:00+07
16	6	28	3	1	RESERVED	3	2026-11-07 11:25:00+07	2026-11-07 11:25:00+07
17	6	29	11	2	RESERVED	3	2026-11-07 11:25:00+07	2026-11-07 11:25:00+07
18	7	33	5	1	RESERVED	3	2026-11-07 15:25:00+07	2026-11-07 15:25:00+07
19	8	36	4	1	RESERVED	3	2026-11-08 10:25:00+07	2026-11-08 10:25:00+07
20	8	37	9	1	RESERVED	3	2026-11-08 10:25:00+07	2026-11-08 10:25:00+07
21	8	38	8	1	RESERVED	3	2026-11-08 10:25:00+07	2026-11-08 10:25:00+07
22	9	41	1	5	RESERVED	3	2026-11-08 11:25:00+07	2026-11-08 11:25:00+07
23	9	42	2	1	RESERVED	3	2026-11-08 11:25:00+07	2026-11-08 11:25:00+07
24	10	44	1	5	RESERVED	3	2026-11-08 12:25:00+07	2026-11-08 12:25:00+07
25	10	45	2	1	RESERVED	3	2026-11-08 12:25:00+07	2026-11-08 12:25:00+07
26	10	46	3	1	RESERVED	3	2026-11-08 12:25:00+07	2026-11-08 12:25:00+07
27	10	47	4	1	RESERVED	3	2026-11-08 12:25:00+07	2026-11-08 12:25:00+07
28	11	49	16	1	RESERVED	3	2026-11-08 12:25:00+07	2026-11-08 12:25:00+07
29	11	50	17	1	RESERVED	3	2026-11-08 12:25:00+07	2026-11-08 12:25:00+07
30	12	56	21	4	ISSUED	10	2026-10-15 11:25:00+07	2026-10-15 12:25:00+07
31	12	57	22	1	ISSUED	10	2026-10-15 11:25:00+07	2026-10-15 12:25:00+07
32	13	59	25	1	RESERVED	10	2026-11-07 12:25:00+07	2026-11-07 12:25:00+07
33	15	62	56	1	ISSUED	17	2026-10-25 10:25:00+07	2026-10-25 11:25:00+07
34	15	63	57	1	ISSUED	17	2026-10-25 10:25:00+07	2026-10-25 11:25:00+07
35	16	65	41	5	RESERVED	17	2026-11-08 11:25:00+07	2026-11-08 11:25:00+07
36	16	66	42	1	RESERVED	17	2026-11-08 11:25:00+07	2026-11-08 11:25:00+07
37	17	74	1	4	ISSUED	3	2026-11-08 10:25:00+07	2026-11-08 11:25:00+07
38	17	75	2	1	ISSUED	3	2026-11-08 10:25:00+07	2026-11-08 11:25:00+07
39	18	77	1	5	ISSUED	3	2026-11-08 13:25:00+07	2026-11-08 14:25:00+07
40	18	78	2	1	ISSUED	3	2026-11-08 13:25:00+07	2026-11-08 14:25:00+07
41	18	79	3	1	ISSUED	3	2026-11-08 13:25:00+07	2026-11-08 14:25:00+07
42	19	81	5	1	ISSUED	3	2026-11-07 16:25:00+07	2026-11-07 17:25:00+07
43	20	83	9	1	ISSUED	3	2026-11-06 17:25:00+07	2026-11-06 18:25:00+07
44	21	85	5	1	ISSUED	3	2026-11-07 12:25:00+07	2026-11-07 13:25:00+07
\.


--
-- Data for Name: parts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.parts (part_id, sku, part_name, category, unit, unit_price, status, created_at, updated_at) FROM stdin;
1	OIL-5W30-1L	Dầu động cơ 5W-30 (1L)	Dầu nhớt	liter	180000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
2	FLT-OIL	Lọc dầu động cơ	Lọc	pcs	120000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
3	FLT-AIR	Lọc gió động cơ	Lọc	pcs	250000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
4	FLT-CABIN	Lọc gió điều hòa	Lọc	pcs	220000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
5	BRK-PAD-FR	Má phanh trước (bộ)	Phanh	set	850000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
6	BRK-DISC-FR	Đĩa phanh trước	Phanh	pcs	1200000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
7	BRK-FLUID-DOT4	Dầu phanh DOT4 (0.5L)	Phanh	pcs	150000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
8	BAT-12V-45AH	Ắc quy 12V 45Ah	Điện	pcs	1650000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
9	AC-GAS-R134A	Gas điều hòa R134a (bình)	Điều hòa	pcs	450000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
10	SPK-PLUG-IR	Bugi Iridium	Đánh lửa	pcs	280000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
11	SHOCK-FR	Giảm xóc trước	Treo	pcs	1900000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
12	TIRE-185-60R15	Lốp 185/60R15	Lốp	pcs	1450000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
13	WIPER-24	Gạt mưa 24 inch	Phụ kiện	pcs	180000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
14	COOLANT-1L	Nước làm mát (1L)	Dung dịch	liter	120000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
15	BELT-ALT	Dây curoa máy phát	Động cơ	pcs	520000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
16	MOTO-OIL-08L	Dầu nhớt xe máy 0.8L	Dầu nhớt	pcs	110000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
17	MOTO-SPK	Bugi xe máy	Đánh lửa	pcs	60000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
18	MOTO-CHAIN	Bộ nhông xích xe máy	Truyền động	set	650000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
19	BULB-H4	Bóng đèn pha H4	Điện	pcs	160000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
20	TRANS-OIL-1L	Dầu hộp số (1L)	Dầu nhớt	liter	230000.00	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (payment_id, invoice_id, amount, method, status, transaction_ref, received_by, paid_at) FROM stdin;
1	1	3067200.00	CASH	SUCCESS	\N	5	2026-10-12 15:10:00+07
2	2	3315600.00	BANK_TRANSFER	SUCCESS	FT26000002	5	2026-10-20 16:10:00+07
3	3	1285200.00	CASH	SUCCESS	\N	12	2026-10-15 16:10:00+07
4	4	399600.00	BANK_TRANSFER	SUCCESS	FT26000004	19	2026-10-25 15:10:00+07
5	7	1188000.00	CASH	SUCCESS	\N	5	2026-11-07 21:10:00+07
6	8	1134000.00	BANK_TRANSFER	SUCCESS	FT26000008	5	2026-11-06 22:10:00+07
\.


--
-- Data for Name: quotation_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.quotation_items (item_id, quotation_id, item_type, service_id, part_id, description, quantity, unit_price, line_total, is_warranty, expected_wait_days, decision, decided_at) FROM stdin;
1	1	SERVICE	3	\N	Bảo dưỡng định kỳ 10.000 km	1.00	900000.00	900000.00	f	\N	APPROVED	2026-10-12 10:00:00+07
2	1	SERVICE	2	\N	Kiểm tra & thay má phanh	1.00	250000.00	250000.00	f	\N	APPROVED	2026-10-12 10:00:00+07
3	1	PART	\N	1	Dầu động cơ 5W-30 (1L)	4.00	180000.00	720000.00	f	\N	APPROVED	2026-10-12 10:00:00+07
4	1	PART	\N	2	Lọc dầu động cơ	1.00	120000.00	120000.00	f	\N	APPROVED	2026-10-12 10:00:00+07
5	1	PART	\N	5	Má phanh trước (bộ)	1.00	850000.00	850000.00	f	\N	APPROVED	2026-10-12 10:00:00+07
6	2	SERVICE	4	\N	Vệ sinh & nạp gas điều hòa	1.00	600000.00	600000.00	f	\N	APPROVED	2026-10-20 11:00:00+07
7	2	SERVICE	6	\N	Kiểm tra & thay ắc quy	1.00	150000.00	150000.00	f	\N	APPROVED	2026-10-20 11:00:00+07
8	2	SERVICE	5	\N	Đảo lốp & cân bằng động	1.00	300000.00	300000.00	f	\N	REJECTED	2026-10-20 11:00:00+07
9	2	PART	\N	4	Lọc gió điều hòa	1.00	220000.00	220000.00	f	\N	APPROVED	2026-10-20 11:00:00+07
10	2	PART	\N	8	Ắc quy 12V 45Ah	1.00	1650000.00	1650000.00	f	\N	APPROVED	2026-10-20 11:00:00+07
11	2	PART	\N	9	Gas điều hòa R134a (bình)	1.00	450000.00	450000.00	f	\N	APPROVED	2026-10-20 11:00:00+07
12	3	SERVICE	1	\N	Thay dầu động cơ	1.00	350000.00	350000.00	f	\N	APPROVED	2026-11-05 10:00:00+07
13	3	SERVICE	5	\N	Đảo lốp & cân bằng động	1.00	300000.00	300000.00	f	\N	APPROVED	2026-11-05 10:00:00+07
14	3	PART	\N	1	Dầu động cơ 5W-30 (1L)	4.00	180000.00	720000.00	f	\N	APPROVED	2026-11-05 10:00:00+07
15	3	PART	\N	2	Lọc dầu động cơ	1.00	120000.00	120000.00	f	\N	APPROVED	2026-11-05 10:00:00+07
16	4	SERVICE	2	\N	Kiểm tra & thay má phanh	1.00	250000.00	250000.00	f	\N	APPROVED	2026-11-06 12:00:00+07
17	4	PART	\N	5	Má phanh trước (bộ)	1.00	850000.00	850000.00	f	\N	APPROVED	2026-11-06 12:00:00+07
18	4	PART	\N	7	Dầu phanh DOT4 (0.5L)	1.00	150000.00	150000.00	f	\N	APPROVED	2026-11-06 12:00:00+07
19	5	SERVICE	7	\N	Chẩn đoán động cơ	1.00	400000.00	400000.00	f	\N	APPROVED	2026-11-07 10:00:00+07
20	5	SERVICE	1	\N	Thay dầu động cơ	1.00	350000.00	350000.00	f	\N	APPROVED	2026-11-07 10:00:00+07
21	5	PART	\N	10	Bugi Iridium	4.00	280000.00	1120000.00	f	\N	APPROVED	2026-11-07 10:00:00+07
22	5	PART	\N	1	Dầu động cơ 5W-30 (1L)	4.00	180000.00	720000.00	f	\N	APPROVED	2026-11-07 10:00:00+07
23	5	PART	\N	2	Lọc dầu động cơ	1.00	120000.00	120000.00	f	\N	APPROVED	2026-11-07 10:00:00+07
24	6	SERVICE	3	\N	Bảo dưỡng định kỳ 10.000 km	1.00	900000.00	900000.00	f	\N	APPROVED	2026-11-07 11:00:00+07
25	6	SERVICE	8	\N	Kiểm tra hệ thống treo	1.00	350000.00	350000.00	f	\N	APPROVED	2026-11-07 11:00:00+07
26	6	PART	\N	1	Dầu động cơ 5W-30 (1L)	6.00	180000.00	1080000.00	f	\N	APPROVED	2026-11-07 11:00:00+07
27	6	PART	\N	2	Lọc dầu động cơ	1.00	120000.00	120000.00	f	\N	APPROVED	2026-11-07 11:00:00+07
28	6	PART	\N	3	Lọc gió động cơ	1.00	250000.00	250000.00	f	\N	APPROVED	2026-11-07 11:00:00+07
29	6	PART	\N	11	Giảm xóc trước	2.00	1900000.00	3800000.00	f	\N	APPROVED	2026-11-07 11:00:00+07
30	7	SERVICE	2	\N	Kiểm tra & thay má phanh	1.00	250000.00	250000.00	f	\N	APPROVED	2026-11-07 15:00:00+07
31	7	SERVICE	5	\N	Đảo lốp & cân bằng động	1.00	300000.00	300000.00	f	\N	APPROVED	2026-11-07 15:00:00+07
32	7	PART	\N	6	Đĩa phanh trước	2.00	1200000.00	2400000.00	f	\N	APPROVED	2026-11-07 15:00:00+07
33	7	PART	\N	5	Má phanh trước (bộ)	1.00	850000.00	850000.00	f	\N	APPROVED	2026-11-07 15:00:00+07
34	8	SERVICE	4	\N	Vệ sinh & nạp gas điều hòa	1.00	600000.00	600000.00	f	\N	APPROVED	2026-11-08 10:00:00+07
35	8	SERVICE	6	\N	Kiểm tra & thay ắc quy	1.00	150000.00	150000.00	f	\N	APPROVED	2026-11-08 10:00:00+07
36	8	PART	\N	4	Lọc gió điều hòa	1.00	220000.00	220000.00	f	\N	APPROVED	2026-11-08 10:00:00+07
37	8	PART	\N	9	Gas điều hòa R134a (bình)	1.00	450000.00	450000.00	f	\N	APPROVED	2026-11-08 10:00:00+07
38	8	PART	\N	8	Ắc quy 12V 45Ah	1.00	1650000.00	1650000.00	f	\N	APPROVED	2026-11-08 10:00:00+07
39	9	SERVICE	1	\N	Thay dầu động cơ	1.00	350000.00	350000.00	f	\N	APPROVED	2026-11-08 11:00:00+07
40	9	SERVICE	10	\N	Rửa xe & vệ sinh nội thất	1.00	150000.00	150000.00	f	\N	APPROVED	2026-11-08 11:00:00+07
41	9	PART	\N	1	Dầu động cơ 5W-30 (1L)	5.00	180000.00	900000.00	f	\N	APPROVED	2026-11-08 11:00:00+07
42	9	PART	\N	2	Lọc dầu động cơ	1.00	120000.00	120000.00	f	\N	APPROVED	2026-11-08 11:00:00+07
43	10	SERVICE	3	\N	Bảo dưỡng định kỳ 10.000 km	1.00	900000.00	900000.00	f	\N	APPROVED	2026-11-08 12:00:00+07
44	10	PART	\N	1	Dầu động cơ 5W-30 (1L)	5.00	180000.00	900000.00	f	\N	APPROVED	2026-11-08 12:00:00+07
45	10	PART	\N	2	Lọc dầu động cơ	1.00	120000.00	120000.00	f	\N	APPROVED	2026-11-08 12:00:00+07
46	10	PART	\N	3	Lọc gió động cơ	1.00	250000.00	250000.00	f	\N	APPROVED	2026-11-08 12:00:00+07
47	10	PART	\N	4	Lọc gió điều hòa	1.00	220000.00	220000.00	f	\N	APPROVED	2026-11-08 12:00:00+07
48	11	SERVICE	9	\N	Bảo dưỡng xe máy	1.00	200000.00	200000.00	f	\N	APPROVED	2026-11-08 12:00:00+07
49	11	PART	\N	16	Dầu nhớt xe máy 0.8L	1.00	110000.00	110000.00	f	\N	APPROVED	2026-11-08 12:00:00+07
50	11	PART	\N	17	Bugi xe máy	1.00	60000.00	60000.00	f	\N	APPROVED	2026-11-08 12:00:00+07
51	12	SERVICE	1	\N	Thay dầu động cơ	1.00	350000.00	350000.00	f	\N	PENDING	\N
52	12	SERVICE	7	\N	Chẩn đoán động cơ	1.00	400000.00	400000.00	f	\N	PENDING	\N
53	12	PART	\N	1	Dầu động cơ 5W-30 (1L)	4.00	180000.00	720000.00	f	\N	PENDING	\N
54	12	PART	\N	2	Lọc dầu động cơ	1.00	120000.00	120000.00	f	\N	PENDING	\N
55	13	SERVICE	1	\N	Thay dầu động cơ	1.00	350000.00	350000.00	f	\N	APPROVED	2026-10-15 11:00:00+07
56	13	PART	\N	1	Dầu động cơ 5W-30 (1L)	4.00	180000.00	720000.00	f	\N	APPROVED	2026-10-15 11:00:00+07
57	13	PART	\N	2	Lọc dầu động cơ	1.00	120000.00	120000.00	f	\N	APPROVED	2026-10-15 11:00:00+07
58	14	SERVICE	2	\N	Kiểm tra & thay má phanh	1.00	250000.00	250000.00	f	\N	APPROVED	2026-11-07 12:00:00+07
59	14	PART	\N	5	Má phanh trước (bộ)	1.00	850000.00	850000.00	f	\N	APPROVED	2026-11-07 12:00:00+07
60	15	SERVICE	5	\N	Đảo lốp & cân bằng động	1.00	300000.00	300000.00	f	\N	APPROVED	2026-11-08 16:00:00+07
61	16	SERVICE	9	\N	Bảo dưỡng xe máy	1.00	200000.00	200000.00	f	\N	APPROVED	2026-10-25 10:00:00+07
62	16	PART	\N	16	Dầu nhớt xe máy 0.8L	1.00	110000.00	110000.00	f	\N	APPROVED	2026-10-25 10:00:00+07
63	16	PART	\N	17	Bugi xe máy	1.00	60000.00	60000.00	f	\N	APPROVED	2026-10-25 10:00:00+07
64	17	SERVICE	3	\N	Bảo dưỡng định kỳ 10.000 km	1.00	900000.00	900000.00	f	\N	APPROVED	2026-11-08 11:00:00+07
65	17	PART	\N	1	Dầu động cơ 5W-30 (1L)	5.00	180000.00	900000.00	f	\N	APPROVED	2026-11-08 11:00:00+07
66	17	PART	\N	2	Lọc dầu động cơ	1.00	120000.00	120000.00	f	\N	APPROVED	2026-11-08 11:00:00+07
67	18	SERVICE	2	\N	Kiểm tra & thay má phanh	1.00	250000.00	250000.00	f	\N	APPROVED	2026-11-08 18:00:00+07
68	18	SERVICE	8	\N	Kiểm tra hệ thống treo	1.00	350000.00	350000.00	f	\N	APPROVED	2026-11-08 18:00:00+07
69	18	SERVICE	6	\N	Kiểm tra & thay ắc quy	1.00	150000.00	150000.00	f	\N	REJECTED	2026-11-08 18:00:00+07
70	18	PART	\N	5	Má phanh trước (bộ)	1.00	850000.00	850000.00	f	\N	APPROVED	2026-11-08 18:00:00+07
71	18	PART	\N	11	Giảm xóc trước	4.00	1900000.00	7600000.00	f	\N	APPROVED	2026-11-08 18:00:00+07
72	19	SERVICE	1	\N	Thay dầu động cơ	1.00	350000.00	350000.00	f	\N	APPROVED	2026-11-08 10:00:00+07
73	19	SERVICE	5	\N	Đảo lốp & cân bằng động	1.00	300000.00	300000.00	f	\N	APPROVED	2026-11-08 10:00:00+07
74	19	PART	\N	1	Dầu động cơ 5W-30 (1L)	4.00	180000.00	720000.00	f	\N	APPROVED	2026-11-08 10:00:00+07
75	19	PART	\N	2	Lọc dầu động cơ	1.00	120000.00	120000.00	f	\N	APPROVED	2026-11-08 10:00:00+07
76	20	SERVICE	3	\N	Bảo dưỡng định kỳ 10.000 km	1.00	900000.00	900000.00	f	\N	APPROVED	2026-11-08 13:00:00+07
77	20	PART	\N	1	Dầu động cơ 5W-30 (1L)	5.00	180000.00	900000.00	f	\N	APPROVED	2026-11-08 13:00:00+07
78	20	PART	\N	2	Lọc dầu động cơ	1.00	120000.00	120000.00	f	\N	APPROVED	2026-11-08 13:00:00+07
79	20	PART	\N	3	Lọc gió động cơ	1.00	250000.00	250000.00	f	\N	APPROVED	2026-11-08 13:00:00+07
80	21	SERVICE	2	\N	Kiểm tra & thay má phanh	1.00	250000.00	250000.00	f	\N	APPROVED	2026-11-07 16:00:00+07
81	21	PART	\N	5	Má phanh trước (bộ)	1.00	850000.00	850000.00	f	\N	APPROVED	2026-11-07 16:00:00+07
82	22	SERVICE	4	\N	Vệ sinh & nạp gas điều hòa	1.00	600000.00	600000.00	f	\N	APPROVED	2026-11-06 17:00:00+07
83	22	PART	\N	9	Gas điều hòa R134a (bình)	1.00	450000.00	450000.00	f	\N	APPROVED	2026-11-06 17:00:00+07
84	23	SERVICE	2	\N	Kiểm tra & thay má phanh	1.00	250000.00	250000.00	f	\N	APPROVED	2026-11-07 12:00:00+07
85	23	PART	\N	5	Má phanh trước (bộ)	1.00	850000.00	850000.00	f	\N	APPROVED	2026-11-07 12:00:00+07
\.


--
-- Data for Name: quotations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.quotations (quotation_id, quotation_code, inspection_id, prepared_by, parent_quotation_id, subtotal, vat_amount, total_amount, status, valid_until, sent_at, responded_at, created_at) FROM stdin;
1	QT-261012-0001	1	3	\N	2840000.00	227200.00	3067200.00	APPROVED	2026-10-15 08:00:00+07	2026-10-12 09:00:00+07	2026-10-12 10:00:00+07	2026-10-12 09:00:00+07
2	QT-261020-0001	2	3	\N	3070000.00	245600.00	3315600.00	PARTIALLY_APPROVED	2026-10-23 09:00:00+07	2026-10-20 10:00:00+07	2026-10-20 11:00:00+07	2026-10-20 10:00:00+07
3	QT-261105-0001	3	3	\N	1490000.00	119200.00	1609200.00	APPROVED	2026-11-08 08:00:00+07	2026-11-05 09:00:00+07	2026-11-05 10:00:00+07	2026-11-05 09:00:00+07
4	QT-261106-0001	4	3	\N	1250000.00	100000.00	1350000.00	APPROVED	2026-11-09 10:00:00+07	2026-11-06 11:00:00+07	2026-11-06 12:00:00+07	2026-11-06 11:00:00+07
5	QT-261107-0001	5	3	\N	2710000.00	216800.00	2926800.00	APPROVED	2026-11-10 08:00:00+07	2026-11-07 09:00:00+07	2026-11-07 10:00:00+07	2026-11-07 09:00:00+07
6	QT-261107-0002	6	3	\N	6500000.00	520000.00	7020000.00	APPROVED	2026-11-10 09:00:00+07	2026-11-07 10:00:00+07	2026-11-07 11:00:00+07	2026-11-07 10:00:00+07
7	QT-261107-0003	7	3	\N	3800000.00	304000.00	4104000.00	APPROVED	2026-11-10 13:00:00+07	2026-11-07 14:00:00+07	2026-11-07 15:00:00+07	2026-11-07 14:00:00+07
8	QT-261108-0001	8	3	\N	3070000.00	245600.00	3315600.00	APPROVED	2026-11-11 08:00:00+07	2026-11-08 09:00:00+07	2026-11-08 10:00:00+07	2026-11-08 09:00:00+07
9	QT-261108-0002	9	3	\N	1520000.00	121600.00	1641600.00	APPROVED	2026-11-11 09:00:00+07	2026-11-08 10:00:00+07	2026-11-08 11:00:00+07	2026-11-08 10:00:00+07
10	QT-261108-0003	10	3	\N	2390000.00	191200.00	2581200.00	APPROVED	2026-11-11 10:00:00+07	2026-11-08 11:00:00+07	2026-11-08 12:00:00+07	2026-11-08 11:00:00+07
11	QT-261108-0004	11	3	\N	370000.00	29600.00	399600.00	APPROVED	2026-11-11 10:00:00+07	2026-11-08 11:00:00+07	2026-11-08 12:00:00+07	2026-11-08 11:00:00+07
12	QT-261108-0005	12	3	\N	1590000.00	127200.00	1717200.00	SENT	2026-11-11 11:00:00+07	2026-11-08 12:00:00+07	\N	2026-11-08 12:00:00+07
13	QT-261015-0001	14	10	\N	1190000.00	95200.00	1285200.00	APPROVED	2026-10-18 09:00:00+07	2026-10-15 10:00:00+07	2026-10-15 11:00:00+07	2026-10-15 10:00:00+07
14	QT-261107-0004	15	10	\N	1100000.00	88000.00	1188000.00	APPROVED	2026-11-10 10:00:00+07	2026-11-07 11:00:00+07	2026-11-07 12:00:00+07	2026-11-07 11:00:00+07
15	QT-261108-0006	16	10	\N	300000.00	24000.00	324000.00	APPROVED	2026-11-11 14:00:00+07	2026-11-08 15:00:00+07	2026-11-08 16:00:00+07	2026-11-08 15:00:00+07
16	QT-261025-0001	17	17	\N	370000.00	29600.00	399600.00	APPROVED	2026-10-28 08:00:00+07	2026-10-25 09:00:00+07	2026-10-25 10:00:00+07	2026-10-25 09:00:00+07
17	QT-261108-0007	18	17	\N	1920000.00	153600.00	2073600.00	APPROVED	2026-11-11 09:00:00+07	2026-11-08 10:00:00+07	2026-11-08 11:00:00+07	2026-11-08 10:00:00+07
18	QT-261108-0008	21	3	\N	9050000.00	724000.00	9774000.00	PARTIALLY_APPROVED	2026-11-11 16:00:00+07	2026-11-08 17:00:00+07	2026-11-08 18:00:00+07	2026-11-08 17:00:00+07
19	QT-261108-0009	22	3	\N	1490000.00	119200.00	1609200.00	APPROVED	2026-11-11 08:00:00+07	2026-11-08 09:00:00+07	2026-11-08 10:00:00+07	2026-11-08 09:00:00+07
20	QT-261108-0010	23	3	\N	2170000.00	173600.00	2343600.00	APPROVED	2026-11-11 11:00:00+07	2026-11-08 12:00:00+07	2026-11-08 13:00:00+07	2026-11-08 12:00:00+07
21	QT-261107-0005	24	3	\N	1100000.00	88000.00	1188000.00	APPROVED	2026-11-10 14:00:00+07	2026-11-07 15:00:00+07	2026-11-07 16:00:00+07	2026-11-07 15:00:00+07
22	QT-261106-0002	25	3	\N	1050000.00	84000.00	1134000.00	APPROVED	2026-11-09 15:00:00+07	2026-11-06 16:00:00+07	2026-11-06 17:00:00+07	2026-11-06 16:00:00+07
23	QT-261107-0006	26	3	\N	1100000.00	88000.00	1188000.00	APPROVED	2026-11-10 10:00:00+07	2026-11-07 11:00:00+07	2026-11-07 12:00:00+07	2026-11-07 11:00:00+07
\.


--
-- Data for Name: repair_notes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repair_notes (note_id, repair_order_id, task_id, author_id, content, created_at) FROM stdin;
1	1	1	6	Đã kiểm tra lại các hạng mục, bắt đầu thực hiện.	2026-10-12 10:55:00+07
2	2	3	7	Đã kiểm tra lại các hạng mục, bắt đầu thực hiện.	2026-10-20 11:55:00+07
3	3	5	7	Đã kiểm tra lại các hạng mục, bắt đầu thực hiện.	2026-11-05 10:55:00+07
4	4	7	6	Đã kiểm tra lại các hạng mục, bắt đầu thực hiện.	2026-11-06 12:55:00+07
5	5	8	6	Đã kiểm tra lại các hạng mục, bắt đầu thực hiện.	2026-11-07 10:55:00+07
6	6	10	6	Đã kiểm tra lại các hạng mục, bắt đầu thực hiện.	2026-11-07 11:55:00+07
7	7	12	7	Đã kiểm tra lại các hạng mục, bắt đầu thực hiện.	2026-11-07 15:55:00+07
8	8	14	6	Đã kiểm tra lại các hạng mục, bắt đầu thực hiện.	2026-11-08 10:55:00+07
9	12	20	13	Đã kiểm tra lại các hạng mục, bắt đầu thực hiện.	2026-10-15 11:55:00+07
10	13	21	13	Đã kiểm tra lại các hạng mục, bắt đầu thực hiện.	2026-11-07 12:55:00+07
11	15	23	20	Đã kiểm tra lại các hạng mục, bắt đầu thực hiện.	2026-10-25 10:55:00+07
12	17	25	7	Đã kiểm tra lại các hạng mục, bắt đầu thực hiện.	2026-11-08 10:55:00+07
13	18	27	8	Đã kiểm tra lại các hạng mục, bắt đầu thực hiện.	2026-11-08 13:55:00+07
14	19	28	6	Đã kiểm tra lại các hạng mục, bắt đầu thực hiện.	2026-11-07 16:55:00+07
15	20	29	7	Đã kiểm tra lại các hạng mục, bắt đầu thực hiện.	2026-11-06 17:55:00+07
16	21	30	8	Đã kiểm tra lại các hạng mục, bắt đầu thực hiện.	2026-11-07 12:55:00+07
\.


--
-- Data for Name: repair_order_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repair_order_types (type_id, type_code, type_name, sla_hours, description) FROM stdin;
1	MAINTENANCE	Bảo dưỡng	4	Bảo dưỡng định kỳ
2	REPAIR	Sửa chữa	24	Sửa chữa thông thường
3	BREAKDOWN	Cứu hộ / hỏng hóc	48	Xe hỏng phải kéo về xưởng
4	WARRANTY	Bảo hành	24	Sửa chữa bảo hành
\.


--
-- Data for Name: repair_orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repair_orders (repair_order_id, ro_code, quotation_id, branch_id, type_id, created_by, status, total_cost, started_at, completed_at, created_at, updated_at) FROM stdin;
1	RO-261012-0001	1	1	1	3	CLOSED	2840000.00	2026-10-12 10:50:00+07	2026-10-12 14:20:00+07	2026-10-12 10:20:00+07	2026-10-12 14:20:00+07
2	RO-261020-0001	2	1	1	3	CLOSED	3070000.00	2026-10-20 11:50:00+07	2026-10-20 15:20:00+07	2026-10-20 11:20:00+07	2026-10-20 15:20:00+07
3	RO-261105-0001	3	1	1	3	COMPLETED	1490000.00	2026-11-05 10:50:00+07	2026-11-05 14:20:00+07	2026-11-05 10:20:00+07	2026-11-05 14:20:00+07
4	RO-261106-0001	4	1	2	3	COMPLETED	1250000.00	2026-11-06 12:50:00+07	2026-11-06 16:20:00+07	2026-11-06 12:20:00+07	2026-11-06 16:20:00+07
5	RO-261107-0001	5	1	2	3	IN_PROGRESS	2710000.00	2026-11-07 10:50:00+07	\N	2026-11-07 10:20:00+07	2026-11-07 10:20:00+07
6	RO-261107-0002	6	1	1	3	IN_PROGRESS	6500000.00	2026-11-07 11:50:00+07	\N	2026-11-07 11:20:00+07	2026-11-07 11:20:00+07
7	RO-261107-0003	7	1	2	3	WAITING_PARTS	3800000.00	2026-11-07 15:50:00+07	\N	2026-11-07 15:20:00+07	2026-11-07 15:20:00+07
8	RO-261108-0001	8	1	1	3	IN_PROGRESS	3070000.00	2026-11-08 10:50:00+07	\N	2026-11-08 10:20:00+07	2026-11-08 10:20:00+07
9	RO-261108-0002	9	1	1	3	ASSIGNED	1520000.00	\N	\N	2026-11-08 11:20:00+07	2026-11-08 11:20:00+07
10	RO-261108-0003	10	1	1	3	NEW	2390000.00	\N	\N	2026-11-08 12:20:00+07	2026-11-08 12:20:00+07
11	RO-261108-0004	11	1	1	3	NEW	370000.00	\N	\N	2026-11-08 12:20:00+07	2026-11-08 12:20:00+07
12	RO-261015-0001	13	2	1	10	CLOSED	1190000.00	2026-10-15 11:50:00+07	2026-10-15 15:20:00+07	2026-10-15 11:20:00+07	2026-10-15 15:20:00+07
13	RO-261107-0004	14	2	1	10	IN_PROGRESS	1100000.00	2026-11-07 12:50:00+07	\N	2026-11-07 12:20:00+07	2026-11-07 12:20:00+07
14	RO-261108-0005	15	2	1	10	NEW	300000.00	\N	\N	2026-11-08 16:20:00+07	2026-11-08 16:20:00+07
15	RO-261025-0001	16	3	1	17	CLOSED	370000.00	2026-10-25 10:50:00+07	2026-10-25 14:20:00+07	2026-10-25 10:20:00+07	2026-10-25 14:20:00+07
16	RO-261108-0006	17	3	1	17	ASSIGNED	1920000.00	\N	\N	2026-11-08 11:20:00+07	2026-11-08 11:20:00+07
17	RO-261108-0007	19	1	1	3	COMPLETED	1490000.00	2026-11-08 10:50:00+07	2026-11-08 14:20:00+07	2026-11-08 10:20:00+07	2026-11-08 14:20:00+07
18	RO-261108-0008	20	1	1	3	COMPLETED	2170000.00	2026-11-08 13:50:00+07	2026-11-08 17:20:00+07	2026-11-08 13:20:00+07	2026-11-08 17:20:00+07
19	RO-261107-0005	21	1	1	3	COMPLETED	1100000.00	2026-11-07 16:50:00+07	2026-11-07 20:20:00+07	2026-11-07 16:20:00+07	2026-11-07 20:20:00+07
20	RO-261106-0002	22	1	1	3	COMPLETED	1050000.00	2026-11-06 17:50:00+07	2026-11-06 21:20:00+07	2026-11-06 17:20:00+07	2026-11-06 21:20:00+07
21	RO-261107-0006	23	1	4	3	COMPLETED	1100000.00	2026-11-07 12:50:00+07	2026-11-07 16:20:00+07	2026-11-07 12:20:00+07	2026-11-07 16:20:00+07
\.


--
-- Data for Name: repair_task_parts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repair_task_parts (task_part_id, task_id, inventory_id, reservation_id, request_item_id, quantity_issued, quantity_returned, unit_price, issued_by, issued_at) FROM stdin;
1	1	1	1	1	4	0	180000.00	3	2026-10-12 11:25:00+07
2	1	2	2	2	1	0	120000.00	3	2026-10-12 11:25:00+07
3	1	5	3	3	1	0	850000.00	3	2026-10-12 11:25:00+07
4	3	4	4	4	1	0	220000.00	3	2026-10-20 12:25:00+07
5	3	8	5	5	1	0	1650000.00	3	2026-10-20 12:25:00+07
6	3	9	6	6	1	0	450000.00	3	2026-10-20 12:25:00+07
7	5	1	7	7	4	0	180000.00	3	2026-11-05 11:25:00+07
8	5	2	8	8	1	0	120000.00	3	2026-11-05 11:25:00+07
9	7	5	9	9	1	0	850000.00	3	2026-11-06 13:25:00+07
10	7	7	10	10	1	0	150000.00	3	2026-11-06 13:25:00+07
11	8	10	11	11	4	0	280000.00	3	2026-11-07 11:25:00+07
12	8	1	12	12	4	0	180000.00	3	2026-11-07 11:25:00+07
13	8	2	13	13	1	0	120000.00	3	2026-11-07 11:25:00+07
14	20	21	30	17	4	0	180000.00	10	2026-10-15 12:25:00+07
15	20	22	31	18	1	0	120000.00	10	2026-10-15 12:25:00+07
16	23	56	33	19	1	0	110000.00	17	2026-10-25 11:25:00+07
17	23	57	34	20	1	0	60000.00	17	2026-10-25 11:25:00+07
18	25	1	37	21	4	0	180000.00	3	2026-11-08 11:25:00+07
19	25	2	38	22	1	0	120000.00	3	2026-11-08 11:25:00+07
20	27	1	39	23	5	0	180000.00	3	2026-11-08 14:25:00+07
21	27	2	40	24	1	0	120000.00	3	2026-11-08 14:25:00+07
22	27	3	41	25	1	0	250000.00	3	2026-11-08 14:25:00+07
23	28	5	42	26	1	0	850000.00	3	2026-11-07 17:25:00+07
24	29	9	43	27	1	0	450000.00	3	2026-11-06 18:25:00+07
25	30	5	44	28	1	0	850000.00	3	2026-11-07 13:25:00+07
\.


--
-- Data for Name: repair_tasks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repair_tasks (task_id, repair_order_id, quotation_item_id, mechanic_id, task_name, status, progress_percent, labor_hours, started_at, finished_at) FROM stdin;
1	1	1	6	Bảo dưỡng định kỳ 10.000 km	DONE	100	1.50	2026-10-12 10:50:00+07	2026-10-12 14:20:00+07
2	1	2	6	Kiểm tra & thay má phanh	DONE	100	1.50	2026-10-12 11:00:00+07	2026-10-12 14:00:00+07
3	2	6	7	Vệ sinh & nạp gas điều hòa	DONE	100	1.50	2026-10-20 11:50:00+07	2026-10-20 15:20:00+07
4	2	7	7	Kiểm tra & thay ắc quy	DONE	100	1.50	2026-10-20 12:00:00+07	2026-10-20 15:00:00+07
5	3	12	7	Thay dầu động cơ	DONE	100	1.50	2026-11-05 10:50:00+07	2026-11-05 14:20:00+07
6	3	13	7	Đảo lốp & cân bằng động	DONE	100	1.50	2026-11-05 11:00:00+07	2026-11-05 14:00:00+07
7	4	16	6	Kiểm tra & thay má phanh	DONE	100	1.50	2026-11-06 12:50:00+07	2026-11-06 16:20:00+07
8	5	19	6	Chẩn đoán động cơ	DONE	100	1.50	2026-11-07 10:50:00+07	2026-11-07 14:20:00+07
9	5	20	6	Thay dầu động cơ	DONE	100	1.50	2026-11-07 11:00:00+07	2026-11-07 14:00:00+07
10	6	24	6	Bảo dưỡng định kỳ 10.000 km	DOING	40	0.60	2026-11-07 11:50:00+07	\N
11	6	25	6	Kiểm tra hệ thống treo	TODO	0	0.00	\N	\N
12	7	30	7	Kiểm tra & thay má phanh	BLOCKED	30	0.45	2026-11-07 15:50:00+07	\N
13	7	31	7	Đảo lốp & cân bằng động	DONE	100	1.50	2026-11-07 16:00:00+07	2026-11-07 19:00:00+07
14	8	34	6	Vệ sinh & nạp gas điều hòa	DOING	50	0.75	2026-11-08 10:50:00+07	\N
15	8	35	6	Kiểm tra & thay ắc quy	TODO	0	0.00	\N	\N
16	9	39	6	Thay dầu động cơ	TODO	0	0.00	\N	\N
17	9	40	6	Rửa xe & vệ sinh nội thất	TODO	0	0.00	\N	\N
18	10	43	\N	Bảo dưỡng định kỳ 10.000 km	TODO	0	0.00	\N	\N
19	11	48	\N	Bảo dưỡng xe máy	TODO	0	0.00	\N	\N
20	12	55	13	Thay dầu động cơ	DONE	100	1.50	2026-10-15 11:50:00+07	2026-10-15 15:20:00+07
21	13	58	13	Kiểm tra & thay má phanh	DOING	60	0.90	2026-11-07 12:50:00+07	\N
22	14	60	\N	Đảo lốp & cân bằng động	TODO	0	0.00	\N	\N
23	15	61	20	Bảo dưỡng xe máy	DONE	100	1.50	2026-10-25 10:50:00+07	2026-10-25 14:20:00+07
24	16	64	20	Bảo dưỡng định kỳ 10.000 km	TODO	0	0.00	\N	\N
25	17	72	7	Thay dầu động cơ	DONE	100	1.50	2026-11-08 10:50:00+07	2026-11-08 14:20:00+07
26	17	73	7	Đảo lốp & cân bằng động	DONE	100	1.50	2026-11-08 11:00:00+07	2026-11-08 14:00:00+07
27	18	76	8	Bảo dưỡng định kỳ 10.000 km	DONE	100	1.50	2026-11-08 13:50:00+07	2026-11-08 17:20:00+07
28	19	80	6	Kiểm tra & thay má phanh	DONE	100	1.50	2026-11-07 16:50:00+07	2026-11-07 20:20:00+07
29	20	82	7	Vệ sinh & nạp gas điều hòa	DONE	100	1.50	2026-11-06 17:50:00+07	2026-11-06 21:20:00+07
30	21	84	8	Kiểm tra & thay má phanh	DONE	100	1.50	2026-11-07 12:50:00+07	2026-11-07 16:20:00+07
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (role_id, role_code, role_name, description) FROM stdin;
1	CUSTOMER	Customer	\N
2	RECEPTIONIST	Receptionist	\N
3	MECHANIC	Mechanic	\N
4	CASHIER	Cashier	\N
5	BRANCH_MANAGER	Branch Manager	\N
6	SYS_ADMIN	System Administrator	\N
\.


--
-- Data for Name: service_ratings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.service_ratings (rating_id, appointment_id, customer_id, score, comment, created_at) FROM stdin;
1	1	1	5	Dịch vụ rất tốt, nhân viên nhiệt tình	2026-10-12 18:30:00+07
2	2	2	4	Hài lòng, thời gian chờ hơi lâu	2026-10-20 19:30:00+07
3	19	7	5	Dịch vụ rất tốt, nhân viên nhiệt tình	2026-10-15 19:30:00+07
4	23	10	4	Hài lòng, thời gian chờ hơi lâu	2026-10-25 18:30:00+07
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.services (service_id, service_code, service_name, description, vehicle_type, base_price, estimated_minutes, status, created_at, updated_at) FROM stdin;
1	SV-OIL	Thay dầu động cơ	Xả dầu cũ, thay dầu mới và lọc dầu	ALL	350000.00	30	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
2	SV-BRAKE	Kiểm tra & thay má phanh	Kiểm tra hệ thống phanh, thay má phanh, xả gió dầu phanh	CAR	250000.00	60	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
3	SV-MAINT10	Bảo dưỡng định kỳ 10.000 km	Gói bảo dưỡng tổng quát theo khuyến cáo hãng	CAR	900000.00	120	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
4	SV-AC	Vệ sinh & nạp gas điều hòa	Vệ sinh dàn lạnh, kiểm tra rò rỉ và nạp gas	CAR	600000.00	90	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
5	SV-TIRE	Đảo lốp & cân bằng động	Đảo lốp, cân bằng động và kiểm tra áp suất	CAR	300000.00	45	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
6	SV-BATT	Kiểm tra & thay ắc quy	Đo điện áp, kiểm tra máy phát và thay ắc quy	ALL	150000.00	30	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
7	SV-ENGINE	Chẩn đoán động cơ	Đọc lỗi OBD, kiểm tra bugi, kim phun	CAR	400000.00	60	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
8	SV-SUSP	Kiểm tra hệ thống treo	Kiểm tra giảm xóc, rotuyn, cao su chân máy	CAR	350000.00	60	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
9	SV-MOTO-MAINT	Bảo dưỡng xe máy	Thay nhớt, vệ sinh nồi, kiểm tra xích và bugi	MOTORCYCLE	200000.00	45	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
10	SV-WASH	Rửa xe & vệ sinh nội thất	Rửa bọt tuyết, hút bụi, lau nội thất	ALL	150000.00	40	ACTIVE	2026-01-05 08:00:00+07	2026-01-05 08:00:00+07
\.


--
-- Data for Name: staff; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.staff (staff_id, user_id, branch_id, staff_code, "position", hired_date, status, created_at) FROM stdin;
1	1	\N	NV0001	SYS_ADMIN	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
2	2	1	NV0002	BRANCH_MANAGER	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
3	3	1	NV0003	RECEPTIONIST	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
4	4	1	NV0004	RECEPTIONIST	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
5	5	1	NV0005	CASHIER	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
6	6	1	NV0006	MECHANIC	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
7	7	1	NV0007	MECHANIC	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
8	8	1	NV0008	MECHANIC	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
9	9	2	NV0009	BRANCH_MANAGER	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
10	10	2	NV0010	RECEPTIONIST	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
11	11	2	NV0011	RECEPTIONIST	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
12	12	2	NV0012	CASHIER	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
13	13	2	NV0013	MECHANIC	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
14	14	2	NV0014	MECHANIC	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
15	15	2	NV0015	MECHANIC	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
16	16	3	NV0016	BRANCH_MANAGER	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
17	17	3	NV0017	RECEPTIONIST	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
18	18	3	NV0018	RECEPTIONIST	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
19	19	3	NV0019	CASHIER	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
20	20	3	NV0020	MECHANIC	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
21	21	3	NV0021	MECHANIC	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
22	22	3	NV0022	MECHANIC	2026-01-01	ACTIVE	2026-01-06 08:00:00+07
\.


--
-- Data for Name: tax_rules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tax_rules (tax_rule_id, item_type, vat_rate, effective_from, effective_to, created_by, created_at) FROM stdin;
1	SERVICE	10.00	2025-01-01	2025-12-31	1	2025-12-20 08:00:00+07
2	PART	10.00	2025-01-01	2025-12-31	1	2025-12-20 08:00:00+07
3	LABOR	10.00	2025-01-01	2025-12-31	1	2025-12-20 08:00:00+07
4	SERVICE	8.00	2026-01-01	\N	1	2025-12-20 08:00:00+07
5	PART	8.00	2026-01-01	\N	1	2025-12-20 08:00:00+07
6	LABOR	8.00	2026-01-01	\N	1	2025-12-20 08:00:00+07
\.


--
-- Data for Name: time_slots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.time_slots (slot_id, branch_id, slot_date, start_time, end_time, capacity, booked_count, status) FROM stdin;
1	1	2026-10-01	08:00:00	09:00:00	4	0	OPEN
2	2	2026-10-01	08:00:00	09:00:00	4	0	OPEN
3	3	2026-10-01	08:00:00	09:00:00	4	0	OPEN
4	1	2026-10-01	09:00:00	10:00:00	4	0	OPEN
5	2	2026-10-01	09:00:00	10:00:00	4	0	OPEN
6	3	2026-10-01	09:00:00	10:00:00	4	0	OPEN
7	1	2026-10-01	10:00:00	11:00:00	4	0	OPEN
8	2	2026-10-01	10:00:00	11:00:00	4	0	OPEN
9	3	2026-10-01	10:00:00	11:00:00	4	0	OPEN
10	1	2026-10-01	11:00:00	12:00:00	4	0	OPEN
11	2	2026-10-01	11:00:00	12:00:00	4	0	OPEN
12	3	2026-10-01	11:00:00	12:00:00	4	0	OPEN
13	1	2026-10-01	12:00:00	13:00:00	4	0	OPEN
14	2	2026-10-01	12:00:00	13:00:00	4	0	OPEN
15	3	2026-10-01	12:00:00	13:00:00	4	0	OPEN
16	1	2026-10-01	13:00:00	14:00:00	4	0	OPEN
17	2	2026-10-01	13:00:00	14:00:00	4	0	OPEN
18	3	2026-10-01	13:00:00	14:00:00	4	0	OPEN
19	1	2026-10-01	14:00:00	15:00:00	4	0	OPEN
20	2	2026-10-01	14:00:00	15:00:00	4	0	OPEN
21	3	2026-10-01	14:00:00	15:00:00	4	0	OPEN
22	1	2026-10-01	15:00:00	16:00:00	4	0	OPEN
23	2	2026-10-01	15:00:00	16:00:00	4	0	OPEN
24	3	2026-10-01	15:00:00	16:00:00	4	0	OPEN
25	1	2026-10-01	16:00:00	17:00:00	4	0	OPEN
26	2	2026-10-01	16:00:00	17:00:00	4	0	OPEN
27	3	2026-10-01	16:00:00	17:00:00	4	0	OPEN
28	1	2026-10-02	08:00:00	09:00:00	4	0	OPEN
29	2	2026-10-02	08:00:00	09:00:00	4	0	OPEN
30	3	2026-10-02	08:00:00	09:00:00	4	0	OPEN
31	1	2026-10-02	09:00:00	10:00:00	4	0	OPEN
32	2	2026-10-02	09:00:00	10:00:00	4	0	OPEN
33	3	2026-10-02	09:00:00	10:00:00	4	0	OPEN
34	1	2026-10-02	10:00:00	11:00:00	4	0	OPEN
35	2	2026-10-02	10:00:00	11:00:00	4	0	OPEN
36	3	2026-10-02	10:00:00	11:00:00	4	0	OPEN
37	1	2026-10-02	11:00:00	12:00:00	4	0	OPEN
38	2	2026-10-02	11:00:00	12:00:00	4	0	OPEN
39	3	2026-10-02	11:00:00	12:00:00	4	0	OPEN
40	1	2026-10-02	12:00:00	13:00:00	4	0	OPEN
41	2	2026-10-02	12:00:00	13:00:00	4	0	OPEN
42	3	2026-10-02	12:00:00	13:00:00	4	0	OPEN
43	1	2026-10-02	13:00:00	14:00:00	4	0	OPEN
44	2	2026-10-02	13:00:00	14:00:00	4	0	OPEN
45	3	2026-10-02	13:00:00	14:00:00	4	0	OPEN
46	1	2026-10-02	14:00:00	15:00:00	4	0	OPEN
47	2	2026-10-02	14:00:00	15:00:00	4	0	OPEN
48	3	2026-10-02	14:00:00	15:00:00	4	0	OPEN
49	1	2026-10-02	15:00:00	16:00:00	4	0	OPEN
50	2	2026-10-02	15:00:00	16:00:00	4	0	OPEN
51	3	2026-10-02	15:00:00	16:00:00	4	0	OPEN
52	1	2026-10-02	16:00:00	17:00:00	4	0	OPEN
53	2	2026-10-02	16:00:00	17:00:00	4	0	OPEN
54	3	2026-10-02	16:00:00	17:00:00	4	0	OPEN
55	1	2026-10-03	08:00:00	09:00:00	4	0	OPEN
56	2	2026-10-03	08:00:00	09:00:00	4	0	OPEN
57	3	2026-10-03	08:00:00	09:00:00	4	0	OPEN
58	1	2026-10-03	09:00:00	10:00:00	4	0	OPEN
59	2	2026-10-03	09:00:00	10:00:00	4	0	OPEN
60	3	2026-10-03	09:00:00	10:00:00	4	0	OPEN
61	1	2026-10-03	10:00:00	11:00:00	4	0	OPEN
62	2	2026-10-03	10:00:00	11:00:00	4	0	OPEN
63	3	2026-10-03	10:00:00	11:00:00	4	0	OPEN
64	1	2026-10-03	11:00:00	12:00:00	4	0	OPEN
65	2	2026-10-03	11:00:00	12:00:00	4	0	OPEN
66	3	2026-10-03	11:00:00	12:00:00	4	0	OPEN
67	1	2026-10-03	12:00:00	13:00:00	4	0	OPEN
68	2	2026-10-03	12:00:00	13:00:00	4	0	OPEN
69	3	2026-10-03	12:00:00	13:00:00	4	0	OPEN
70	1	2026-10-03	13:00:00	14:00:00	4	0	OPEN
71	2	2026-10-03	13:00:00	14:00:00	4	0	OPEN
72	3	2026-10-03	13:00:00	14:00:00	4	0	OPEN
73	1	2026-10-03	14:00:00	15:00:00	4	0	OPEN
74	2	2026-10-03	14:00:00	15:00:00	4	0	OPEN
75	3	2026-10-03	14:00:00	15:00:00	4	0	OPEN
76	1	2026-10-03	15:00:00	16:00:00	4	0	OPEN
77	2	2026-10-03	15:00:00	16:00:00	4	0	OPEN
78	3	2026-10-03	15:00:00	16:00:00	4	0	OPEN
79	1	2026-10-03	16:00:00	17:00:00	4	0	OPEN
80	2	2026-10-03	16:00:00	17:00:00	4	0	OPEN
81	3	2026-10-03	16:00:00	17:00:00	4	0	OPEN
82	1	2026-10-04	08:00:00	09:00:00	4	0	OPEN
83	2	2026-10-04	08:00:00	09:00:00	4	0	OPEN
84	3	2026-10-04	08:00:00	09:00:00	4	0	OPEN
85	1	2026-10-04	09:00:00	10:00:00	4	0	OPEN
86	2	2026-10-04	09:00:00	10:00:00	4	0	OPEN
87	3	2026-10-04	09:00:00	10:00:00	4	0	OPEN
88	1	2026-10-04	10:00:00	11:00:00	4	0	OPEN
89	2	2026-10-04	10:00:00	11:00:00	4	0	OPEN
90	3	2026-10-04	10:00:00	11:00:00	4	0	OPEN
91	1	2026-10-04	11:00:00	12:00:00	4	0	OPEN
92	2	2026-10-04	11:00:00	12:00:00	4	0	OPEN
93	3	2026-10-04	11:00:00	12:00:00	4	0	OPEN
94	1	2026-10-04	12:00:00	13:00:00	4	0	OPEN
95	2	2026-10-04	12:00:00	13:00:00	4	0	OPEN
96	3	2026-10-04	12:00:00	13:00:00	4	0	OPEN
97	1	2026-10-04	13:00:00	14:00:00	4	0	OPEN
98	2	2026-10-04	13:00:00	14:00:00	4	0	OPEN
99	3	2026-10-04	13:00:00	14:00:00	4	0	OPEN
100	1	2026-10-04	14:00:00	15:00:00	4	0	OPEN
101	2	2026-10-04	14:00:00	15:00:00	4	0	OPEN
102	3	2026-10-04	14:00:00	15:00:00	4	0	OPEN
103	1	2026-10-04	15:00:00	16:00:00	4	0	OPEN
104	2	2026-10-04	15:00:00	16:00:00	4	0	OPEN
105	3	2026-10-04	15:00:00	16:00:00	4	0	OPEN
106	1	2026-10-04	16:00:00	17:00:00	4	0	OPEN
107	2	2026-10-04	16:00:00	17:00:00	4	0	OPEN
108	3	2026-10-04	16:00:00	17:00:00	4	0	OPEN
109	1	2026-10-05	08:00:00	09:00:00	4	0	OPEN
110	2	2026-10-05	08:00:00	09:00:00	4	0	OPEN
111	3	2026-10-05	08:00:00	09:00:00	4	0	OPEN
112	1	2026-10-05	09:00:00	10:00:00	4	0	OPEN
113	2	2026-10-05	09:00:00	10:00:00	4	0	OPEN
114	3	2026-10-05	09:00:00	10:00:00	4	0	OPEN
115	1	2026-10-05	10:00:00	11:00:00	4	0	OPEN
116	2	2026-10-05	10:00:00	11:00:00	4	0	OPEN
117	3	2026-10-05	10:00:00	11:00:00	4	0	OPEN
118	1	2026-10-05	11:00:00	12:00:00	4	0	OPEN
119	2	2026-10-05	11:00:00	12:00:00	4	0	OPEN
120	3	2026-10-05	11:00:00	12:00:00	4	0	OPEN
121	1	2026-10-05	12:00:00	13:00:00	4	0	OPEN
122	2	2026-10-05	12:00:00	13:00:00	4	0	OPEN
123	3	2026-10-05	12:00:00	13:00:00	4	0	OPEN
124	1	2026-10-05	13:00:00	14:00:00	4	0	OPEN
125	2	2026-10-05	13:00:00	14:00:00	4	0	OPEN
126	3	2026-10-05	13:00:00	14:00:00	4	0	OPEN
127	1	2026-10-05	14:00:00	15:00:00	4	0	OPEN
128	2	2026-10-05	14:00:00	15:00:00	4	0	OPEN
129	3	2026-10-05	14:00:00	15:00:00	4	0	OPEN
130	1	2026-10-05	15:00:00	16:00:00	4	0	OPEN
131	2	2026-10-05	15:00:00	16:00:00	4	0	OPEN
132	3	2026-10-05	15:00:00	16:00:00	4	0	OPEN
133	1	2026-10-05	16:00:00	17:00:00	4	0	OPEN
134	2	2026-10-05	16:00:00	17:00:00	4	0	OPEN
135	3	2026-10-05	16:00:00	17:00:00	4	0	OPEN
136	1	2026-10-06	08:00:00	09:00:00	4	0	OPEN
137	2	2026-10-06	08:00:00	09:00:00	4	0	OPEN
138	3	2026-10-06	08:00:00	09:00:00	4	0	OPEN
139	1	2026-10-06	09:00:00	10:00:00	4	0	OPEN
140	2	2026-10-06	09:00:00	10:00:00	4	0	OPEN
141	3	2026-10-06	09:00:00	10:00:00	4	0	OPEN
142	1	2026-10-06	10:00:00	11:00:00	4	0	OPEN
143	2	2026-10-06	10:00:00	11:00:00	4	0	OPEN
144	3	2026-10-06	10:00:00	11:00:00	4	0	OPEN
145	1	2026-10-06	11:00:00	12:00:00	4	0	OPEN
146	2	2026-10-06	11:00:00	12:00:00	4	0	OPEN
147	3	2026-10-06	11:00:00	12:00:00	4	0	OPEN
148	1	2026-10-06	12:00:00	13:00:00	4	0	OPEN
149	2	2026-10-06	12:00:00	13:00:00	4	0	OPEN
150	3	2026-10-06	12:00:00	13:00:00	4	0	OPEN
151	1	2026-10-06	13:00:00	14:00:00	4	0	OPEN
152	2	2026-10-06	13:00:00	14:00:00	4	0	OPEN
153	3	2026-10-06	13:00:00	14:00:00	4	0	OPEN
154	1	2026-10-06	14:00:00	15:00:00	4	0	OPEN
155	2	2026-10-06	14:00:00	15:00:00	4	0	OPEN
156	3	2026-10-06	14:00:00	15:00:00	4	0	OPEN
157	1	2026-10-06	15:00:00	16:00:00	4	0	OPEN
158	2	2026-10-06	15:00:00	16:00:00	4	0	OPEN
159	3	2026-10-06	15:00:00	16:00:00	4	0	OPEN
160	1	2026-10-06	16:00:00	17:00:00	4	0	OPEN
161	2	2026-10-06	16:00:00	17:00:00	4	0	OPEN
162	3	2026-10-06	16:00:00	17:00:00	4	0	OPEN
163	1	2026-10-07	08:00:00	09:00:00	4	0	OPEN
164	2	2026-10-07	08:00:00	09:00:00	4	0	OPEN
165	3	2026-10-07	08:00:00	09:00:00	4	0	OPEN
166	1	2026-10-07	09:00:00	10:00:00	4	0	OPEN
167	2	2026-10-07	09:00:00	10:00:00	4	0	OPEN
168	3	2026-10-07	09:00:00	10:00:00	4	0	OPEN
169	1	2026-10-07	10:00:00	11:00:00	4	0	OPEN
170	2	2026-10-07	10:00:00	11:00:00	4	0	OPEN
171	3	2026-10-07	10:00:00	11:00:00	4	0	OPEN
172	1	2026-10-07	11:00:00	12:00:00	4	0	OPEN
173	2	2026-10-07	11:00:00	12:00:00	4	0	OPEN
174	3	2026-10-07	11:00:00	12:00:00	4	0	OPEN
175	1	2026-10-07	12:00:00	13:00:00	4	0	OPEN
176	2	2026-10-07	12:00:00	13:00:00	4	0	OPEN
177	3	2026-10-07	12:00:00	13:00:00	4	0	OPEN
178	1	2026-10-07	13:00:00	14:00:00	4	0	OPEN
179	2	2026-10-07	13:00:00	14:00:00	4	0	OPEN
180	3	2026-10-07	13:00:00	14:00:00	4	0	OPEN
181	1	2026-10-07	14:00:00	15:00:00	4	0	OPEN
182	2	2026-10-07	14:00:00	15:00:00	4	0	OPEN
183	3	2026-10-07	14:00:00	15:00:00	4	0	OPEN
184	1	2026-10-07	15:00:00	16:00:00	4	0	OPEN
185	2	2026-10-07	15:00:00	16:00:00	4	0	OPEN
186	3	2026-10-07	15:00:00	16:00:00	4	0	OPEN
187	1	2026-10-07	16:00:00	17:00:00	4	0	OPEN
188	2	2026-10-07	16:00:00	17:00:00	4	0	OPEN
189	3	2026-10-07	16:00:00	17:00:00	4	0	OPEN
190	1	2026-10-08	08:00:00	09:00:00	4	0	OPEN
191	2	2026-10-08	08:00:00	09:00:00	4	0	OPEN
192	3	2026-10-08	08:00:00	09:00:00	4	0	OPEN
193	1	2026-10-08	09:00:00	10:00:00	4	0	OPEN
194	2	2026-10-08	09:00:00	10:00:00	4	0	OPEN
195	3	2026-10-08	09:00:00	10:00:00	4	0	OPEN
196	1	2026-10-08	10:00:00	11:00:00	4	0	OPEN
197	2	2026-10-08	10:00:00	11:00:00	4	0	OPEN
198	3	2026-10-08	10:00:00	11:00:00	4	0	OPEN
199	1	2026-10-08	11:00:00	12:00:00	4	0	OPEN
200	2	2026-10-08	11:00:00	12:00:00	4	0	OPEN
201	3	2026-10-08	11:00:00	12:00:00	4	0	OPEN
202	1	2026-10-08	12:00:00	13:00:00	4	0	OPEN
203	2	2026-10-08	12:00:00	13:00:00	4	0	OPEN
204	3	2026-10-08	12:00:00	13:00:00	4	0	OPEN
205	1	2026-10-08	13:00:00	14:00:00	4	0	OPEN
206	2	2026-10-08	13:00:00	14:00:00	4	0	OPEN
207	3	2026-10-08	13:00:00	14:00:00	4	0	OPEN
208	1	2026-10-08	14:00:00	15:00:00	4	0	OPEN
209	2	2026-10-08	14:00:00	15:00:00	4	0	OPEN
210	3	2026-10-08	14:00:00	15:00:00	4	0	OPEN
211	1	2026-10-08	15:00:00	16:00:00	4	0	OPEN
212	2	2026-10-08	15:00:00	16:00:00	4	0	OPEN
213	3	2026-10-08	15:00:00	16:00:00	4	0	OPEN
214	1	2026-10-08	16:00:00	17:00:00	4	0	OPEN
215	2	2026-10-08	16:00:00	17:00:00	4	0	OPEN
216	3	2026-10-08	16:00:00	17:00:00	4	0	OPEN
217	1	2026-10-09	08:00:00	09:00:00	4	0	OPEN
218	2	2026-10-09	08:00:00	09:00:00	4	0	OPEN
219	3	2026-10-09	08:00:00	09:00:00	4	0	OPEN
220	1	2026-10-09	09:00:00	10:00:00	4	0	OPEN
221	2	2026-10-09	09:00:00	10:00:00	4	0	OPEN
222	3	2026-10-09	09:00:00	10:00:00	4	0	OPEN
223	1	2026-10-09	10:00:00	11:00:00	4	0	OPEN
224	2	2026-10-09	10:00:00	11:00:00	4	0	OPEN
225	3	2026-10-09	10:00:00	11:00:00	4	0	OPEN
226	1	2026-10-09	11:00:00	12:00:00	4	0	OPEN
227	2	2026-10-09	11:00:00	12:00:00	4	0	OPEN
228	3	2026-10-09	11:00:00	12:00:00	4	0	OPEN
229	1	2026-10-09	12:00:00	13:00:00	4	0	OPEN
230	2	2026-10-09	12:00:00	13:00:00	4	0	OPEN
231	3	2026-10-09	12:00:00	13:00:00	4	0	OPEN
232	1	2026-10-09	13:00:00	14:00:00	4	0	OPEN
233	2	2026-10-09	13:00:00	14:00:00	4	0	OPEN
234	3	2026-10-09	13:00:00	14:00:00	4	0	OPEN
235	1	2026-10-09	14:00:00	15:00:00	4	0	OPEN
236	2	2026-10-09	14:00:00	15:00:00	4	0	OPEN
237	3	2026-10-09	14:00:00	15:00:00	4	0	OPEN
238	1	2026-10-09	15:00:00	16:00:00	4	0	OPEN
239	2	2026-10-09	15:00:00	16:00:00	4	0	OPEN
240	3	2026-10-09	15:00:00	16:00:00	4	0	OPEN
241	1	2026-10-09	16:00:00	17:00:00	4	0	OPEN
242	2	2026-10-09	16:00:00	17:00:00	4	0	OPEN
243	3	2026-10-09	16:00:00	17:00:00	4	0	OPEN
244	1	2026-10-10	08:00:00	09:00:00	4	0	OPEN
245	2	2026-10-10	08:00:00	09:00:00	4	0	OPEN
246	3	2026-10-10	08:00:00	09:00:00	4	0	OPEN
247	1	2026-10-10	09:00:00	10:00:00	4	0	OPEN
248	2	2026-10-10	09:00:00	10:00:00	4	0	OPEN
249	3	2026-10-10	09:00:00	10:00:00	4	0	OPEN
250	1	2026-10-10	10:00:00	11:00:00	4	0	OPEN
251	2	2026-10-10	10:00:00	11:00:00	4	0	OPEN
252	3	2026-10-10	10:00:00	11:00:00	4	0	OPEN
253	1	2026-10-10	11:00:00	12:00:00	4	0	OPEN
254	2	2026-10-10	11:00:00	12:00:00	4	0	OPEN
255	3	2026-10-10	11:00:00	12:00:00	4	0	OPEN
256	1	2026-10-10	12:00:00	13:00:00	4	0	OPEN
257	2	2026-10-10	12:00:00	13:00:00	4	0	OPEN
258	3	2026-10-10	12:00:00	13:00:00	4	0	OPEN
259	1	2026-10-10	13:00:00	14:00:00	4	0	OPEN
260	2	2026-10-10	13:00:00	14:00:00	4	0	OPEN
261	3	2026-10-10	13:00:00	14:00:00	4	0	OPEN
262	1	2026-10-10	14:00:00	15:00:00	4	0	OPEN
263	2	2026-10-10	14:00:00	15:00:00	4	0	OPEN
264	3	2026-10-10	14:00:00	15:00:00	4	0	OPEN
265	1	2026-10-10	15:00:00	16:00:00	4	0	OPEN
266	2	2026-10-10	15:00:00	16:00:00	4	0	OPEN
267	3	2026-10-10	15:00:00	16:00:00	4	0	OPEN
268	1	2026-10-10	16:00:00	17:00:00	4	0	OPEN
269	2	2026-10-10	16:00:00	17:00:00	4	0	OPEN
270	3	2026-10-10	16:00:00	17:00:00	4	0	OPEN
271	1	2026-10-11	08:00:00	09:00:00	4	0	OPEN
272	2	2026-10-11	08:00:00	09:00:00	4	0	OPEN
273	3	2026-10-11	08:00:00	09:00:00	4	0	OPEN
274	1	2026-10-11	09:00:00	10:00:00	4	0	OPEN
275	2	2026-10-11	09:00:00	10:00:00	4	0	OPEN
276	3	2026-10-11	09:00:00	10:00:00	4	0	OPEN
277	1	2026-10-11	10:00:00	11:00:00	4	0	OPEN
278	2	2026-10-11	10:00:00	11:00:00	4	0	OPEN
279	3	2026-10-11	10:00:00	11:00:00	4	0	OPEN
280	1	2026-10-11	11:00:00	12:00:00	4	0	OPEN
281	2	2026-10-11	11:00:00	12:00:00	4	0	OPEN
282	3	2026-10-11	11:00:00	12:00:00	4	0	OPEN
283	1	2026-10-11	12:00:00	13:00:00	4	0	OPEN
284	2	2026-10-11	12:00:00	13:00:00	4	0	OPEN
285	3	2026-10-11	12:00:00	13:00:00	4	0	OPEN
286	1	2026-10-11	13:00:00	14:00:00	4	0	OPEN
287	2	2026-10-11	13:00:00	14:00:00	4	0	OPEN
288	3	2026-10-11	13:00:00	14:00:00	4	0	OPEN
289	1	2026-10-11	14:00:00	15:00:00	4	0	OPEN
290	2	2026-10-11	14:00:00	15:00:00	4	0	OPEN
291	3	2026-10-11	14:00:00	15:00:00	4	0	OPEN
292	1	2026-10-11	15:00:00	16:00:00	4	0	OPEN
293	2	2026-10-11	15:00:00	16:00:00	4	0	OPEN
294	3	2026-10-11	15:00:00	16:00:00	4	0	OPEN
295	1	2026-10-11	16:00:00	17:00:00	4	0	OPEN
296	2	2026-10-11	16:00:00	17:00:00	4	0	OPEN
297	3	2026-10-11	16:00:00	17:00:00	4	0	OPEN
299	2	2026-10-12	08:00:00	09:00:00	4	0	OPEN
300	3	2026-10-12	08:00:00	09:00:00	4	0	OPEN
301	1	2026-10-12	09:00:00	10:00:00	4	0	OPEN
302	2	2026-10-12	09:00:00	10:00:00	4	0	OPEN
303	3	2026-10-12	09:00:00	10:00:00	4	0	OPEN
304	1	2026-10-12	10:00:00	11:00:00	4	0	OPEN
305	2	2026-10-12	10:00:00	11:00:00	4	0	OPEN
306	3	2026-10-12	10:00:00	11:00:00	4	0	OPEN
307	1	2026-10-12	11:00:00	12:00:00	4	0	OPEN
308	2	2026-10-12	11:00:00	12:00:00	4	0	OPEN
309	3	2026-10-12	11:00:00	12:00:00	4	0	OPEN
310	1	2026-10-12	12:00:00	13:00:00	4	0	OPEN
311	2	2026-10-12	12:00:00	13:00:00	4	0	OPEN
312	3	2026-10-12	12:00:00	13:00:00	4	0	OPEN
313	1	2026-10-12	13:00:00	14:00:00	4	0	OPEN
314	2	2026-10-12	13:00:00	14:00:00	4	0	OPEN
315	3	2026-10-12	13:00:00	14:00:00	4	0	OPEN
316	1	2026-10-12	14:00:00	15:00:00	4	0	OPEN
317	2	2026-10-12	14:00:00	15:00:00	4	0	OPEN
318	3	2026-10-12	14:00:00	15:00:00	4	0	OPEN
319	1	2026-10-12	15:00:00	16:00:00	4	0	OPEN
320	2	2026-10-12	15:00:00	16:00:00	4	0	OPEN
321	3	2026-10-12	15:00:00	16:00:00	4	0	OPEN
322	1	2026-10-12	16:00:00	17:00:00	4	0	OPEN
323	2	2026-10-12	16:00:00	17:00:00	4	0	OPEN
324	3	2026-10-12	16:00:00	17:00:00	4	0	OPEN
325	1	2026-10-13	08:00:00	09:00:00	4	0	OPEN
326	2	2026-10-13	08:00:00	09:00:00	4	0	OPEN
327	3	2026-10-13	08:00:00	09:00:00	4	0	OPEN
328	1	2026-10-13	09:00:00	10:00:00	4	0	OPEN
329	2	2026-10-13	09:00:00	10:00:00	4	0	OPEN
330	3	2026-10-13	09:00:00	10:00:00	4	0	OPEN
331	1	2026-10-13	10:00:00	11:00:00	4	0	OPEN
332	2	2026-10-13	10:00:00	11:00:00	4	0	OPEN
333	3	2026-10-13	10:00:00	11:00:00	4	0	OPEN
334	1	2026-10-13	11:00:00	12:00:00	4	0	OPEN
335	2	2026-10-13	11:00:00	12:00:00	4	0	OPEN
336	3	2026-10-13	11:00:00	12:00:00	4	0	OPEN
337	1	2026-10-13	12:00:00	13:00:00	4	0	OPEN
338	2	2026-10-13	12:00:00	13:00:00	4	0	OPEN
339	3	2026-10-13	12:00:00	13:00:00	4	0	OPEN
340	1	2026-10-13	13:00:00	14:00:00	4	0	OPEN
341	2	2026-10-13	13:00:00	14:00:00	4	0	OPEN
342	3	2026-10-13	13:00:00	14:00:00	4	0	OPEN
343	1	2026-10-13	14:00:00	15:00:00	4	0	OPEN
344	2	2026-10-13	14:00:00	15:00:00	4	0	OPEN
345	3	2026-10-13	14:00:00	15:00:00	4	0	OPEN
346	1	2026-10-13	15:00:00	16:00:00	4	0	OPEN
347	2	2026-10-13	15:00:00	16:00:00	4	0	OPEN
348	3	2026-10-13	15:00:00	16:00:00	4	0	OPEN
349	1	2026-10-13	16:00:00	17:00:00	4	0	OPEN
350	2	2026-10-13	16:00:00	17:00:00	4	0	OPEN
351	3	2026-10-13	16:00:00	17:00:00	4	0	OPEN
352	1	2026-10-14	08:00:00	09:00:00	4	0	OPEN
353	2	2026-10-14	08:00:00	09:00:00	4	0	OPEN
354	3	2026-10-14	08:00:00	09:00:00	4	0	OPEN
355	1	2026-10-14	09:00:00	10:00:00	4	0	OPEN
356	2	2026-10-14	09:00:00	10:00:00	4	0	OPEN
357	3	2026-10-14	09:00:00	10:00:00	4	0	OPEN
358	1	2026-10-14	10:00:00	11:00:00	4	0	OPEN
359	2	2026-10-14	10:00:00	11:00:00	4	0	OPEN
360	3	2026-10-14	10:00:00	11:00:00	4	0	OPEN
361	1	2026-10-14	11:00:00	12:00:00	4	0	OPEN
362	2	2026-10-14	11:00:00	12:00:00	4	0	OPEN
363	3	2026-10-14	11:00:00	12:00:00	4	0	OPEN
364	1	2026-10-14	12:00:00	13:00:00	4	0	OPEN
365	2	2026-10-14	12:00:00	13:00:00	4	0	OPEN
366	3	2026-10-14	12:00:00	13:00:00	4	0	OPEN
367	1	2026-10-14	13:00:00	14:00:00	4	0	OPEN
368	2	2026-10-14	13:00:00	14:00:00	4	0	OPEN
369	3	2026-10-14	13:00:00	14:00:00	4	0	OPEN
370	1	2026-10-14	14:00:00	15:00:00	4	0	OPEN
371	2	2026-10-14	14:00:00	15:00:00	4	0	OPEN
372	3	2026-10-14	14:00:00	15:00:00	4	0	OPEN
373	1	2026-10-14	15:00:00	16:00:00	4	0	OPEN
374	2	2026-10-14	15:00:00	16:00:00	4	0	OPEN
375	3	2026-10-14	15:00:00	16:00:00	4	0	OPEN
376	1	2026-10-14	16:00:00	17:00:00	4	0	OPEN
377	2	2026-10-14	16:00:00	17:00:00	4	0	OPEN
378	3	2026-10-14	16:00:00	17:00:00	4	0	OPEN
379	1	2026-10-15	08:00:00	09:00:00	4	0	OPEN
380	2	2026-10-15	08:00:00	09:00:00	4	0	OPEN
381	3	2026-10-15	08:00:00	09:00:00	4	0	OPEN
382	1	2026-10-15	09:00:00	10:00:00	4	0	OPEN
384	3	2026-10-15	09:00:00	10:00:00	4	0	OPEN
385	1	2026-10-15	10:00:00	11:00:00	4	0	OPEN
386	2	2026-10-15	10:00:00	11:00:00	4	0	OPEN
387	3	2026-10-15	10:00:00	11:00:00	4	0	OPEN
388	1	2026-10-15	11:00:00	12:00:00	4	0	OPEN
389	2	2026-10-15	11:00:00	12:00:00	4	0	OPEN
390	3	2026-10-15	11:00:00	12:00:00	4	0	OPEN
391	1	2026-10-15	12:00:00	13:00:00	4	0	OPEN
392	2	2026-10-15	12:00:00	13:00:00	4	0	OPEN
393	3	2026-10-15	12:00:00	13:00:00	4	0	OPEN
394	1	2026-10-15	13:00:00	14:00:00	4	0	OPEN
395	2	2026-10-15	13:00:00	14:00:00	4	0	OPEN
396	3	2026-10-15	13:00:00	14:00:00	4	0	OPEN
397	1	2026-10-15	14:00:00	15:00:00	4	0	OPEN
398	2	2026-10-15	14:00:00	15:00:00	4	0	OPEN
399	3	2026-10-15	14:00:00	15:00:00	4	0	OPEN
400	1	2026-10-15	15:00:00	16:00:00	4	0	OPEN
401	2	2026-10-15	15:00:00	16:00:00	4	0	OPEN
402	3	2026-10-15	15:00:00	16:00:00	4	0	OPEN
403	1	2026-10-15	16:00:00	17:00:00	4	0	OPEN
404	2	2026-10-15	16:00:00	17:00:00	4	0	OPEN
405	3	2026-10-15	16:00:00	17:00:00	4	0	OPEN
406	1	2026-10-16	08:00:00	09:00:00	4	0	OPEN
407	2	2026-10-16	08:00:00	09:00:00	4	0	OPEN
408	3	2026-10-16	08:00:00	09:00:00	4	0	OPEN
409	1	2026-10-16	09:00:00	10:00:00	4	0	OPEN
410	2	2026-10-16	09:00:00	10:00:00	4	0	OPEN
411	3	2026-10-16	09:00:00	10:00:00	4	0	OPEN
412	1	2026-10-16	10:00:00	11:00:00	4	0	OPEN
413	2	2026-10-16	10:00:00	11:00:00	4	0	OPEN
414	3	2026-10-16	10:00:00	11:00:00	4	0	OPEN
415	1	2026-10-16	11:00:00	12:00:00	4	0	OPEN
416	2	2026-10-16	11:00:00	12:00:00	4	0	OPEN
417	3	2026-10-16	11:00:00	12:00:00	4	0	OPEN
418	1	2026-10-16	12:00:00	13:00:00	4	0	OPEN
419	2	2026-10-16	12:00:00	13:00:00	4	0	OPEN
420	3	2026-10-16	12:00:00	13:00:00	4	0	OPEN
421	1	2026-10-16	13:00:00	14:00:00	4	0	OPEN
422	2	2026-10-16	13:00:00	14:00:00	4	0	OPEN
423	3	2026-10-16	13:00:00	14:00:00	4	0	OPEN
424	1	2026-10-16	14:00:00	15:00:00	4	0	OPEN
425	2	2026-10-16	14:00:00	15:00:00	4	0	OPEN
426	3	2026-10-16	14:00:00	15:00:00	4	0	OPEN
427	1	2026-10-16	15:00:00	16:00:00	4	0	OPEN
428	2	2026-10-16	15:00:00	16:00:00	4	0	OPEN
429	3	2026-10-16	15:00:00	16:00:00	4	0	OPEN
430	1	2026-10-16	16:00:00	17:00:00	4	0	OPEN
431	2	2026-10-16	16:00:00	17:00:00	4	0	OPEN
432	3	2026-10-16	16:00:00	17:00:00	4	0	OPEN
433	1	2026-10-17	08:00:00	09:00:00	4	0	OPEN
434	2	2026-10-17	08:00:00	09:00:00	4	0	OPEN
435	3	2026-10-17	08:00:00	09:00:00	4	0	OPEN
436	1	2026-10-17	09:00:00	10:00:00	4	0	OPEN
437	2	2026-10-17	09:00:00	10:00:00	4	0	OPEN
438	3	2026-10-17	09:00:00	10:00:00	4	0	OPEN
439	1	2026-10-17	10:00:00	11:00:00	4	0	OPEN
440	2	2026-10-17	10:00:00	11:00:00	4	0	OPEN
441	3	2026-10-17	10:00:00	11:00:00	4	0	OPEN
442	1	2026-10-17	11:00:00	12:00:00	4	0	OPEN
443	2	2026-10-17	11:00:00	12:00:00	4	0	OPEN
444	3	2026-10-17	11:00:00	12:00:00	4	0	OPEN
445	1	2026-10-17	12:00:00	13:00:00	4	0	OPEN
446	2	2026-10-17	12:00:00	13:00:00	4	0	OPEN
447	3	2026-10-17	12:00:00	13:00:00	4	0	OPEN
448	1	2026-10-17	13:00:00	14:00:00	4	0	OPEN
449	2	2026-10-17	13:00:00	14:00:00	4	0	OPEN
450	3	2026-10-17	13:00:00	14:00:00	4	0	OPEN
451	1	2026-10-17	14:00:00	15:00:00	4	0	OPEN
452	2	2026-10-17	14:00:00	15:00:00	4	0	OPEN
453	3	2026-10-17	14:00:00	15:00:00	4	0	OPEN
454	1	2026-10-17	15:00:00	16:00:00	4	0	OPEN
455	2	2026-10-17	15:00:00	16:00:00	4	0	OPEN
456	3	2026-10-17	15:00:00	16:00:00	4	0	OPEN
457	1	2026-10-17	16:00:00	17:00:00	4	0	OPEN
458	2	2026-10-17	16:00:00	17:00:00	4	0	OPEN
459	3	2026-10-17	16:00:00	17:00:00	4	0	OPEN
460	1	2026-10-18	08:00:00	09:00:00	4	0	OPEN
461	2	2026-10-18	08:00:00	09:00:00	4	0	OPEN
462	3	2026-10-18	08:00:00	09:00:00	4	0	OPEN
463	1	2026-10-18	09:00:00	10:00:00	4	0	OPEN
464	2	2026-10-18	09:00:00	10:00:00	4	0	OPEN
465	3	2026-10-18	09:00:00	10:00:00	4	0	OPEN
466	1	2026-10-18	10:00:00	11:00:00	4	0	OPEN
467	2	2026-10-18	10:00:00	11:00:00	4	0	OPEN
468	3	2026-10-18	10:00:00	11:00:00	4	0	OPEN
469	1	2026-10-18	11:00:00	12:00:00	4	0	OPEN
470	2	2026-10-18	11:00:00	12:00:00	4	0	OPEN
471	3	2026-10-18	11:00:00	12:00:00	4	0	OPEN
472	1	2026-10-18	12:00:00	13:00:00	4	0	OPEN
473	2	2026-10-18	12:00:00	13:00:00	4	0	OPEN
474	3	2026-10-18	12:00:00	13:00:00	4	0	OPEN
475	1	2026-10-18	13:00:00	14:00:00	4	0	OPEN
476	2	2026-10-18	13:00:00	14:00:00	4	0	OPEN
477	3	2026-10-18	13:00:00	14:00:00	4	0	OPEN
478	1	2026-10-18	14:00:00	15:00:00	4	0	OPEN
479	2	2026-10-18	14:00:00	15:00:00	4	0	OPEN
480	3	2026-10-18	14:00:00	15:00:00	4	0	OPEN
481	1	2026-10-18	15:00:00	16:00:00	4	0	OPEN
482	2	2026-10-18	15:00:00	16:00:00	4	0	OPEN
483	3	2026-10-18	15:00:00	16:00:00	4	0	OPEN
484	1	2026-10-18	16:00:00	17:00:00	4	0	OPEN
485	2	2026-10-18	16:00:00	17:00:00	4	0	OPEN
486	3	2026-10-18	16:00:00	17:00:00	4	0	OPEN
487	1	2026-10-19	08:00:00	09:00:00	4	0	OPEN
488	2	2026-10-19	08:00:00	09:00:00	4	0	OPEN
489	3	2026-10-19	08:00:00	09:00:00	4	0	OPEN
490	1	2026-10-19	09:00:00	10:00:00	4	0	OPEN
491	2	2026-10-19	09:00:00	10:00:00	4	0	OPEN
492	3	2026-10-19	09:00:00	10:00:00	4	0	OPEN
493	1	2026-10-19	10:00:00	11:00:00	4	0	OPEN
494	2	2026-10-19	10:00:00	11:00:00	4	0	OPEN
495	3	2026-10-19	10:00:00	11:00:00	4	0	OPEN
496	1	2026-10-19	11:00:00	12:00:00	4	0	OPEN
497	2	2026-10-19	11:00:00	12:00:00	4	0	OPEN
498	3	2026-10-19	11:00:00	12:00:00	4	0	OPEN
499	1	2026-10-19	12:00:00	13:00:00	4	0	OPEN
500	2	2026-10-19	12:00:00	13:00:00	4	0	OPEN
501	3	2026-10-19	12:00:00	13:00:00	4	0	OPEN
502	1	2026-10-19	13:00:00	14:00:00	4	0	OPEN
503	2	2026-10-19	13:00:00	14:00:00	4	0	OPEN
504	3	2026-10-19	13:00:00	14:00:00	4	0	OPEN
505	1	2026-10-19	14:00:00	15:00:00	4	0	OPEN
506	2	2026-10-19	14:00:00	15:00:00	4	0	OPEN
507	3	2026-10-19	14:00:00	15:00:00	4	0	OPEN
508	1	2026-10-19	15:00:00	16:00:00	4	0	OPEN
509	2	2026-10-19	15:00:00	16:00:00	4	0	OPEN
510	3	2026-10-19	15:00:00	16:00:00	4	0	OPEN
511	1	2026-10-19	16:00:00	17:00:00	4	0	OPEN
512	2	2026-10-19	16:00:00	17:00:00	4	0	OPEN
513	3	2026-10-19	16:00:00	17:00:00	4	0	OPEN
514	1	2026-10-20	08:00:00	09:00:00	4	0	OPEN
515	2	2026-10-20	08:00:00	09:00:00	4	0	OPEN
516	3	2026-10-20	08:00:00	09:00:00	4	0	OPEN
518	2	2026-10-20	09:00:00	10:00:00	4	0	OPEN
519	3	2026-10-20	09:00:00	10:00:00	4	0	OPEN
520	1	2026-10-20	10:00:00	11:00:00	4	0	OPEN
521	2	2026-10-20	10:00:00	11:00:00	4	0	OPEN
522	3	2026-10-20	10:00:00	11:00:00	4	0	OPEN
523	1	2026-10-20	11:00:00	12:00:00	4	0	OPEN
524	2	2026-10-20	11:00:00	12:00:00	4	0	OPEN
525	3	2026-10-20	11:00:00	12:00:00	4	0	OPEN
526	1	2026-10-20	12:00:00	13:00:00	4	0	OPEN
527	2	2026-10-20	12:00:00	13:00:00	4	0	OPEN
528	3	2026-10-20	12:00:00	13:00:00	4	0	OPEN
529	1	2026-10-20	13:00:00	14:00:00	4	0	OPEN
530	2	2026-10-20	13:00:00	14:00:00	4	0	OPEN
531	3	2026-10-20	13:00:00	14:00:00	4	0	OPEN
532	1	2026-10-20	14:00:00	15:00:00	4	0	OPEN
533	2	2026-10-20	14:00:00	15:00:00	4	0	OPEN
534	3	2026-10-20	14:00:00	15:00:00	4	0	OPEN
535	1	2026-10-20	15:00:00	16:00:00	4	0	OPEN
536	2	2026-10-20	15:00:00	16:00:00	4	0	OPEN
537	3	2026-10-20	15:00:00	16:00:00	4	0	OPEN
538	1	2026-10-20	16:00:00	17:00:00	4	0	OPEN
539	2	2026-10-20	16:00:00	17:00:00	4	0	OPEN
540	3	2026-10-20	16:00:00	17:00:00	4	0	OPEN
541	1	2026-10-21	08:00:00	09:00:00	4	0	OPEN
542	2	2026-10-21	08:00:00	09:00:00	4	0	OPEN
543	3	2026-10-21	08:00:00	09:00:00	4	0	OPEN
544	1	2026-10-21	09:00:00	10:00:00	4	0	OPEN
545	2	2026-10-21	09:00:00	10:00:00	4	0	OPEN
546	3	2026-10-21	09:00:00	10:00:00	4	0	OPEN
547	1	2026-10-21	10:00:00	11:00:00	4	0	OPEN
548	2	2026-10-21	10:00:00	11:00:00	4	0	OPEN
549	3	2026-10-21	10:00:00	11:00:00	4	0	OPEN
550	1	2026-10-21	11:00:00	12:00:00	4	0	OPEN
551	2	2026-10-21	11:00:00	12:00:00	4	0	OPEN
552	3	2026-10-21	11:00:00	12:00:00	4	0	OPEN
553	1	2026-10-21	12:00:00	13:00:00	4	0	OPEN
554	2	2026-10-21	12:00:00	13:00:00	4	0	OPEN
555	3	2026-10-21	12:00:00	13:00:00	4	0	OPEN
556	1	2026-10-21	13:00:00	14:00:00	4	0	OPEN
557	2	2026-10-21	13:00:00	14:00:00	4	0	OPEN
558	3	2026-10-21	13:00:00	14:00:00	4	0	OPEN
559	1	2026-10-21	14:00:00	15:00:00	4	0	OPEN
560	2	2026-10-21	14:00:00	15:00:00	4	0	OPEN
561	3	2026-10-21	14:00:00	15:00:00	4	0	OPEN
562	1	2026-10-21	15:00:00	16:00:00	4	0	OPEN
563	2	2026-10-21	15:00:00	16:00:00	4	0	OPEN
564	3	2026-10-21	15:00:00	16:00:00	4	0	OPEN
565	1	2026-10-21	16:00:00	17:00:00	4	0	OPEN
566	2	2026-10-21	16:00:00	17:00:00	4	0	OPEN
567	3	2026-10-21	16:00:00	17:00:00	4	0	OPEN
568	1	2026-10-22	08:00:00	09:00:00	4	0	OPEN
569	2	2026-10-22	08:00:00	09:00:00	4	0	OPEN
570	3	2026-10-22	08:00:00	09:00:00	4	0	OPEN
571	1	2026-10-22	09:00:00	10:00:00	4	0	OPEN
572	2	2026-10-22	09:00:00	10:00:00	4	0	OPEN
573	3	2026-10-22	09:00:00	10:00:00	4	0	OPEN
574	1	2026-10-22	10:00:00	11:00:00	4	0	OPEN
575	2	2026-10-22	10:00:00	11:00:00	4	0	OPEN
576	3	2026-10-22	10:00:00	11:00:00	4	0	OPEN
577	1	2026-10-22	11:00:00	12:00:00	4	0	OPEN
578	2	2026-10-22	11:00:00	12:00:00	4	0	OPEN
579	3	2026-10-22	11:00:00	12:00:00	4	0	OPEN
580	1	2026-10-22	12:00:00	13:00:00	4	0	OPEN
581	2	2026-10-22	12:00:00	13:00:00	4	0	OPEN
582	3	2026-10-22	12:00:00	13:00:00	4	0	OPEN
583	1	2026-10-22	13:00:00	14:00:00	4	0	OPEN
584	2	2026-10-22	13:00:00	14:00:00	4	0	OPEN
585	3	2026-10-22	13:00:00	14:00:00	4	0	OPEN
586	1	2026-10-22	14:00:00	15:00:00	4	0	OPEN
587	2	2026-10-22	14:00:00	15:00:00	4	0	OPEN
588	3	2026-10-22	14:00:00	15:00:00	4	0	OPEN
589	1	2026-10-22	15:00:00	16:00:00	4	0	OPEN
590	2	2026-10-22	15:00:00	16:00:00	4	0	OPEN
591	3	2026-10-22	15:00:00	16:00:00	4	0	OPEN
592	1	2026-10-22	16:00:00	17:00:00	4	0	OPEN
593	2	2026-10-22	16:00:00	17:00:00	4	0	OPEN
594	3	2026-10-22	16:00:00	17:00:00	4	0	OPEN
595	1	2026-10-23	08:00:00	09:00:00	4	0	OPEN
596	2	2026-10-23	08:00:00	09:00:00	4	0	OPEN
597	3	2026-10-23	08:00:00	09:00:00	4	0	OPEN
598	1	2026-10-23	09:00:00	10:00:00	4	0	OPEN
599	2	2026-10-23	09:00:00	10:00:00	4	0	OPEN
600	3	2026-10-23	09:00:00	10:00:00	4	0	OPEN
601	1	2026-10-23	10:00:00	11:00:00	4	0	OPEN
602	2	2026-10-23	10:00:00	11:00:00	4	0	OPEN
603	3	2026-10-23	10:00:00	11:00:00	4	0	OPEN
604	1	2026-10-23	11:00:00	12:00:00	4	0	OPEN
605	2	2026-10-23	11:00:00	12:00:00	4	0	OPEN
606	3	2026-10-23	11:00:00	12:00:00	4	0	OPEN
607	1	2026-10-23	12:00:00	13:00:00	4	0	OPEN
608	2	2026-10-23	12:00:00	13:00:00	4	0	OPEN
609	3	2026-10-23	12:00:00	13:00:00	4	0	OPEN
610	1	2026-10-23	13:00:00	14:00:00	4	0	OPEN
611	2	2026-10-23	13:00:00	14:00:00	4	0	OPEN
612	3	2026-10-23	13:00:00	14:00:00	4	0	OPEN
613	1	2026-10-23	14:00:00	15:00:00	4	0	OPEN
614	2	2026-10-23	14:00:00	15:00:00	4	0	OPEN
615	3	2026-10-23	14:00:00	15:00:00	4	0	OPEN
616	1	2026-10-23	15:00:00	16:00:00	4	0	OPEN
617	2	2026-10-23	15:00:00	16:00:00	4	0	OPEN
618	3	2026-10-23	15:00:00	16:00:00	4	0	OPEN
619	1	2026-10-23	16:00:00	17:00:00	4	0	OPEN
620	2	2026-10-23	16:00:00	17:00:00	4	0	OPEN
621	3	2026-10-23	16:00:00	17:00:00	4	0	OPEN
622	1	2026-10-24	08:00:00	09:00:00	4	0	OPEN
623	2	2026-10-24	08:00:00	09:00:00	4	0	OPEN
624	3	2026-10-24	08:00:00	09:00:00	4	0	OPEN
625	1	2026-10-24	09:00:00	10:00:00	4	0	OPEN
626	2	2026-10-24	09:00:00	10:00:00	4	0	OPEN
627	3	2026-10-24	09:00:00	10:00:00	4	0	OPEN
628	1	2026-10-24	10:00:00	11:00:00	4	0	OPEN
629	2	2026-10-24	10:00:00	11:00:00	4	0	OPEN
630	3	2026-10-24	10:00:00	11:00:00	4	0	OPEN
631	1	2026-10-24	11:00:00	12:00:00	4	0	OPEN
632	2	2026-10-24	11:00:00	12:00:00	4	0	OPEN
633	3	2026-10-24	11:00:00	12:00:00	4	0	OPEN
634	1	2026-10-24	12:00:00	13:00:00	4	0	OPEN
635	2	2026-10-24	12:00:00	13:00:00	4	0	OPEN
636	3	2026-10-24	12:00:00	13:00:00	4	0	OPEN
637	1	2026-10-24	13:00:00	14:00:00	4	0	OPEN
638	2	2026-10-24	13:00:00	14:00:00	4	0	OPEN
639	3	2026-10-24	13:00:00	14:00:00	4	0	OPEN
640	1	2026-10-24	14:00:00	15:00:00	4	0	OPEN
641	2	2026-10-24	14:00:00	15:00:00	4	0	OPEN
642	3	2026-10-24	14:00:00	15:00:00	4	0	OPEN
643	1	2026-10-24	15:00:00	16:00:00	4	0	OPEN
644	2	2026-10-24	15:00:00	16:00:00	4	0	OPEN
645	3	2026-10-24	15:00:00	16:00:00	4	0	OPEN
646	1	2026-10-24	16:00:00	17:00:00	4	0	OPEN
647	2	2026-10-24	16:00:00	17:00:00	4	0	OPEN
648	3	2026-10-24	16:00:00	17:00:00	4	0	OPEN
649	1	2026-10-25	08:00:00	09:00:00	4	0	OPEN
650	2	2026-10-25	08:00:00	09:00:00	4	0	OPEN
652	1	2026-10-25	09:00:00	10:00:00	4	0	OPEN
653	2	2026-10-25	09:00:00	10:00:00	4	0	OPEN
654	3	2026-10-25	09:00:00	10:00:00	4	0	OPEN
655	1	2026-10-25	10:00:00	11:00:00	4	0	OPEN
656	2	2026-10-25	10:00:00	11:00:00	4	0	OPEN
657	3	2026-10-25	10:00:00	11:00:00	4	0	OPEN
658	1	2026-10-25	11:00:00	12:00:00	4	0	OPEN
659	2	2026-10-25	11:00:00	12:00:00	4	0	OPEN
660	3	2026-10-25	11:00:00	12:00:00	4	0	OPEN
661	1	2026-10-25	12:00:00	13:00:00	4	0	OPEN
662	2	2026-10-25	12:00:00	13:00:00	4	0	OPEN
663	3	2026-10-25	12:00:00	13:00:00	4	0	OPEN
664	1	2026-10-25	13:00:00	14:00:00	4	0	OPEN
665	2	2026-10-25	13:00:00	14:00:00	4	0	OPEN
666	3	2026-10-25	13:00:00	14:00:00	4	0	OPEN
667	1	2026-10-25	14:00:00	15:00:00	4	0	OPEN
668	2	2026-10-25	14:00:00	15:00:00	4	0	OPEN
669	3	2026-10-25	14:00:00	15:00:00	4	0	OPEN
670	1	2026-10-25	15:00:00	16:00:00	4	0	OPEN
671	2	2026-10-25	15:00:00	16:00:00	4	0	OPEN
672	3	2026-10-25	15:00:00	16:00:00	4	0	OPEN
673	1	2026-10-25	16:00:00	17:00:00	4	0	OPEN
674	2	2026-10-25	16:00:00	17:00:00	4	0	OPEN
675	3	2026-10-25	16:00:00	17:00:00	4	0	OPEN
676	1	2026-10-26	08:00:00	09:00:00	4	0	OPEN
677	2	2026-10-26	08:00:00	09:00:00	4	0	OPEN
678	3	2026-10-26	08:00:00	09:00:00	4	0	OPEN
679	1	2026-10-26	09:00:00	10:00:00	4	0	OPEN
680	2	2026-10-26	09:00:00	10:00:00	4	0	OPEN
681	3	2026-10-26	09:00:00	10:00:00	4	0	OPEN
682	1	2026-10-26	10:00:00	11:00:00	4	0	OPEN
683	2	2026-10-26	10:00:00	11:00:00	4	0	OPEN
684	3	2026-10-26	10:00:00	11:00:00	4	0	OPEN
685	1	2026-10-26	11:00:00	12:00:00	4	0	OPEN
686	2	2026-10-26	11:00:00	12:00:00	4	0	OPEN
687	3	2026-10-26	11:00:00	12:00:00	4	0	OPEN
688	1	2026-10-26	12:00:00	13:00:00	4	0	OPEN
689	2	2026-10-26	12:00:00	13:00:00	4	0	OPEN
690	3	2026-10-26	12:00:00	13:00:00	4	0	OPEN
691	1	2026-10-26	13:00:00	14:00:00	4	0	OPEN
692	2	2026-10-26	13:00:00	14:00:00	4	0	OPEN
693	3	2026-10-26	13:00:00	14:00:00	4	0	OPEN
694	1	2026-10-26	14:00:00	15:00:00	4	0	OPEN
695	2	2026-10-26	14:00:00	15:00:00	4	0	OPEN
696	3	2026-10-26	14:00:00	15:00:00	4	0	OPEN
697	1	2026-10-26	15:00:00	16:00:00	4	0	OPEN
698	2	2026-10-26	15:00:00	16:00:00	4	0	OPEN
699	3	2026-10-26	15:00:00	16:00:00	4	0	OPEN
700	1	2026-10-26	16:00:00	17:00:00	4	0	OPEN
701	2	2026-10-26	16:00:00	17:00:00	4	0	OPEN
702	3	2026-10-26	16:00:00	17:00:00	4	0	OPEN
703	1	2026-10-27	08:00:00	09:00:00	4	0	OPEN
704	2	2026-10-27	08:00:00	09:00:00	4	0	OPEN
705	3	2026-10-27	08:00:00	09:00:00	4	0	OPEN
706	1	2026-10-27	09:00:00	10:00:00	4	0	OPEN
707	2	2026-10-27	09:00:00	10:00:00	4	0	OPEN
708	3	2026-10-27	09:00:00	10:00:00	4	0	OPEN
709	1	2026-10-27	10:00:00	11:00:00	4	0	OPEN
710	2	2026-10-27	10:00:00	11:00:00	4	0	OPEN
711	3	2026-10-27	10:00:00	11:00:00	4	0	OPEN
712	1	2026-10-27	11:00:00	12:00:00	4	0	OPEN
713	2	2026-10-27	11:00:00	12:00:00	4	0	OPEN
714	3	2026-10-27	11:00:00	12:00:00	4	0	OPEN
715	1	2026-10-27	12:00:00	13:00:00	4	0	OPEN
716	2	2026-10-27	12:00:00	13:00:00	4	0	OPEN
717	3	2026-10-27	12:00:00	13:00:00	4	0	OPEN
718	1	2026-10-27	13:00:00	14:00:00	4	0	OPEN
719	2	2026-10-27	13:00:00	14:00:00	4	0	OPEN
720	3	2026-10-27	13:00:00	14:00:00	4	0	OPEN
721	1	2026-10-27	14:00:00	15:00:00	4	0	OPEN
722	2	2026-10-27	14:00:00	15:00:00	4	0	OPEN
723	3	2026-10-27	14:00:00	15:00:00	4	0	OPEN
724	1	2026-10-27	15:00:00	16:00:00	4	0	OPEN
725	2	2026-10-27	15:00:00	16:00:00	4	0	OPEN
726	3	2026-10-27	15:00:00	16:00:00	4	0	OPEN
727	1	2026-10-27	16:00:00	17:00:00	4	0	OPEN
728	2	2026-10-27	16:00:00	17:00:00	4	0	OPEN
729	3	2026-10-27	16:00:00	17:00:00	4	0	OPEN
730	1	2026-10-28	08:00:00	09:00:00	4	0	OPEN
731	2	2026-10-28	08:00:00	09:00:00	4	0	OPEN
732	3	2026-10-28	08:00:00	09:00:00	4	0	OPEN
733	1	2026-10-28	09:00:00	10:00:00	4	0	OPEN
734	2	2026-10-28	09:00:00	10:00:00	4	0	OPEN
735	3	2026-10-28	09:00:00	10:00:00	4	0	OPEN
736	1	2026-10-28	10:00:00	11:00:00	4	0	OPEN
737	2	2026-10-28	10:00:00	11:00:00	4	0	OPEN
738	3	2026-10-28	10:00:00	11:00:00	4	0	OPEN
739	1	2026-10-28	11:00:00	12:00:00	4	0	OPEN
740	2	2026-10-28	11:00:00	12:00:00	4	0	OPEN
741	3	2026-10-28	11:00:00	12:00:00	4	0	OPEN
742	1	2026-10-28	12:00:00	13:00:00	4	0	OPEN
743	2	2026-10-28	12:00:00	13:00:00	4	0	OPEN
744	3	2026-10-28	12:00:00	13:00:00	4	0	OPEN
745	1	2026-10-28	13:00:00	14:00:00	4	0	OPEN
746	2	2026-10-28	13:00:00	14:00:00	4	0	OPEN
747	3	2026-10-28	13:00:00	14:00:00	4	0	OPEN
748	1	2026-10-28	14:00:00	15:00:00	4	0	OPEN
749	2	2026-10-28	14:00:00	15:00:00	4	0	OPEN
750	3	2026-10-28	14:00:00	15:00:00	4	0	OPEN
751	1	2026-10-28	15:00:00	16:00:00	4	0	OPEN
752	2	2026-10-28	15:00:00	16:00:00	4	0	OPEN
753	3	2026-10-28	15:00:00	16:00:00	4	0	OPEN
754	1	2026-10-28	16:00:00	17:00:00	4	0	OPEN
755	2	2026-10-28	16:00:00	17:00:00	4	0	OPEN
756	3	2026-10-28	16:00:00	17:00:00	4	0	OPEN
757	1	2026-10-29	08:00:00	09:00:00	4	0	OPEN
758	2	2026-10-29	08:00:00	09:00:00	4	0	OPEN
759	3	2026-10-29	08:00:00	09:00:00	4	0	OPEN
760	1	2026-10-29	09:00:00	10:00:00	4	0	OPEN
761	2	2026-10-29	09:00:00	10:00:00	4	0	OPEN
762	3	2026-10-29	09:00:00	10:00:00	4	0	OPEN
763	1	2026-10-29	10:00:00	11:00:00	4	0	OPEN
764	2	2026-10-29	10:00:00	11:00:00	4	0	OPEN
765	3	2026-10-29	10:00:00	11:00:00	4	0	OPEN
766	1	2026-10-29	11:00:00	12:00:00	4	0	OPEN
767	2	2026-10-29	11:00:00	12:00:00	4	0	OPEN
768	3	2026-10-29	11:00:00	12:00:00	4	0	OPEN
769	1	2026-10-29	12:00:00	13:00:00	4	0	OPEN
770	2	2026-10-29	12:00:00	13:00:00	4	0	OPEN
771	3	2026-10-29	12:00:00	13:00:00	4	0	OPEN
772	1	2026-10-29	13:00:00	14:00:00	4	0	OPEN
773	2	2026-10-29	13:00:00	14:00:00	4	0	OPEN
774	3	2026-10-29	13:00:00	14:00:00	4	0	OPEN
775	1	2026-10-29	14:00:00	15:00:00	4	0	OPEN
776	2	2026-10-29	14:00:00	15:00:00	4	0	OPEN
777	3	2026-10-29	14:00:00	15:00:00	4	0	OPEN
778	1	2026-10-29	15:00:00	16:00:00	4	0	OPEN
779	2	2026-10-29	15:00:00	16:00:00	4	0	OPEN
780	3	2026-10-29	15:00:00	16:00:00	4	0	OPEN
781	1	2026-10-29	16:00:00	17:00:00	4	0	OPEN
782	2	2026-10-29	16:00:00	17:00:00	4	0	OPEN
783	3	2026-10-29	16:00:00	17:00:00	4	0	OPEN
784	1	2026-10-30	08:00:00	09:00:00	4	0	OPEN
785	2	2026-10-30	08:00:00	09:00:00	4	0	OPEN
786	3	2026-10-30	08:00:00	09:00:00	4	0	OPEN
787	1	2026-10-30	09:00:00	10:00:00	4	0	OPEN
788	2	2026-10-30	09:00:00	10:00:00	4	0	OPEN
789	3	2026-10-30	09:00:00	10:00:00	4	0	OPEN
790	1	2026-10-30	10:00:00	11:00:00	4	0	OPEN
791	2	2026-10-30	10:00:00	11:00:00	4	0	OPEN
792	3	2026-10-30	10:00:00	11:00:00	4	0	OPEN
793	1	2026-10-30	11:00:00	12:00:00	4	0	OPEN
794	2	2026-10-30	11:00:00	12:00:00	4	0	OPEN
795	3	2026-10-30	11:00:00	12:00:00	4	0	OPEN
796	1	2026-10-30	12:00:00	13:00:00	4	0	OPEN
797	2	2026-10-30	12:00:00	13:00:00	4	0	OPEN
798	3	2026-10-30	12:00:00	13:00:00	4	0	OPEN
799	1	2026-10-30	13:00:00	14:00:00	4	0	OPEN
800	2	2026-10-30	13:00:00	14:00:00	4	0	OPEN
801	3	2026-10-30	13:00:00	14:00:00	4	0	OPEN
802	1	2026-10-30	14:00:00	15:00:00	4	0	OPEN
803	2	2026-10-30	14:00:00	15:00:00	4	0	OPEN
804	3	2026-10-30	14:00:00	15:00:00	4	0	OPEN
805	1	2026-10-30	15:00:00	16:00:00	4	0	OPEN
806	2	2026-10-30	15:00:00	16:00:00	4	0	OPEN
807	3	2026-10-30	15:00:00	16:00:00	4	0	OPEN
808	1	2026-10-30	16:00:00	17:00:00	4	0	OPEN
809	2	2026-10-30	16:00:00	17:00:00	4	0	OPEN
810	3	2026-10-30	16:00:00	17:00:00	4	0	OPEN
811	1	2026-10-31	08:00:00	09:00:00	4	0	OPEN
812	2	2026-10-31	08:00:00	09:00:00	4	0	OPEN
813	3	2026-10-31	08:00:00	09:00:00	4	0	OPEN
814	1	2026-10-31	09:00:00	10:00:00	4	0	OPEN
815	2	2026-10-31	09:00:00	10:00:00	4	0	OPEN
816	3	2026-10-31	09:00:00	10:00:00	4	0	OPEN
817	1	2026-10-31	10:00:00	11:00:00	4	0	OPEN
818	2	2026-10-31	10:00:00	11:00:00	4	0	OPEN
819	3	2026-10-31	10:00:00	11:00:00	4	0	OPEN
820	1	2026-10-31	11:00:00	12:00:00	4	0	OPEN
821	2	2026-10-31	11:00:00	12:00:00	4	0	OPEN
822	3	2026-10-31	11:00:00	12:00:00	4	0	OPEN
823	1	2026-10-31	12:00:00	13:00:00	4	0	OPEN
824	2	2026-10-31	12:00:00	13:00:00	4	0	OPEN
825	3	2026-10-31	12:00:00	13:00:00	4	0	OPEN
826	1	2026-10-31	13:00:00	14:00:00	4	0	OPEN
827	2	2026-10-31	13:00:00	14:00:00	4	0	OPEN
828	3	2026-10-31	13:00:00	14:00:00	4	0	OPEN
829	1	2026-10-31	14:00:00	15:00:00	4	0	OPEN
830	2	2026-10-31	14:00:00	15:00:00	4	0	OPEN
831	3	2026-10-31	14:00:00	15:00:00	4	0	OPEN
832	1	2026-10-31	15:00:00	16:00:00	4	0	OPEN
833	2	2026-10-31	15:00:00	16:00:00	4	0	OPEN
834	3	2026-10-31	15:00:00	16:00:00	4	0	OPEN
835	1	2026-10-31	16:00:00	17:00:00	4	0	OPEN
836	2	2026-10-31	16:00:00	17:00:00	4	0	OPEN
837	3	2026-10-31	16:00:00	17:00:00	4	0	OPEN
838	1	2026-11-01	08:00:00	09:00:00	4	0	OPEN
839	2	2026-11-01	08:00:00	09:00:00	4	0	OPEN
840	3	2026-11-01	08:00:00	09:00:00	4	0	OPEN
841	1	2026-11-01	09:00:00	10:00:00	4	0	OPEN
842	2	2026-11-01	09:00:00	10:00:00	4	0	OPEN
843	3	2026-11-01	09:00:00	10:00:00	4	0	OPEN
844	1	2026-11-01	10:00:00	11:00:00	4	0	OPEN
845	2	2026-11-01	10:00:00	11:00:00	4	0	OPEN
846	3	2026-11-01	10:00:00	11:00:00	4	0	OPEN
847	1	2026-11-01	11:00:00	12:00:00	4	0	OPEN
848	2	2026-11-01	11:00:00	12:00:00	4	0	OPEN
849	3	2026-11-01	11:00:00	12:00:00	4	0	OPEN
850	1	2026-11-01	12:00:00	13:00:00	4	0	OPEN
851	2	2026-11-01	12:00:00	13:00:00	4	0	OPEN
852	3	2026-11-01	12:00:00	13:00:00	4	0	OPEN
853	1	2026-11-01	13:00:00	14:00:00	4	0	OPEN
854	2	2026-11-01	13:00:00	14:00:00	4	0	OPEN
855	3	2026-11-01	13:00:00	14:00:00	4	0	OPEN
856	1	2026-11-01	14:00:00	15:00:00	4	0	OPEN
857	2	2026-11-01	14:00:00	15:00:00	4	0	OPEN
858	3	2026-11-01	14:00:00	15:00:00	4	0	OPEN
859	1	2026-11-01	15:00:00	16:00:00	4	0	OPEN
860	2	2026-11-01	15:00:00	16:00:00	4	0	OPEN
861	3	2026-11-01	15:00:00	16:00:00	4	0	OPEN
862	1	2026-11-01	16:00:00	17:00:00	4	0	OPEN
863	2	2026-11-01	16:00:00	17:00:00	4	0	OPEN
864	3	2026-11-01	16:00:00	17:00:00	4	0	OPEN
865	1	2026-11-02	08:00:00	09:00:00	4	0	OPEN
866	2	2026-11-02	08:00:00	09:00:00	4	0	OPEN
867	3	2026-11-02	08:00:00	09:00:00	4	0	OPEN
868	1	2026-11-02	09:00:00	10:00:00	4	0	OPEN
869	2	2026-11-02	09:00:00	10:00:00	4	0	OPEN
870	3	2026-11-02	09:00:00	10:00:00	4	0	OPEN
871	1	2026-11-02	10:00:00	11:00:00	4	0	OPEN
872	2	2026-11-02	10:00:00	11:00:00	4	0	OPEN
873	3	2026-11-02	10:00:00	11:00:00	4	0	OPEN
874	1	2026-11-02	11:00:00	12:00:00	4	0	OPEN
875	2	2026-11-02	11:00:00	12:00:00	4	0	OPEN
876	3	2026-11-02	11:00:00	12:00:00	4	0	OPEN
877	1	2026-11-02	12:00:00	13:00:00	4	0	OPEN
878	2	2026-11-02	12:00:00	13:00:00	4	0	OPEN
879	3	2026-11-02	12:00:00	13:00:00	4	0	OPEN
880	1	2026-11-02	13:00:00	14:00:00	4	0	OPEN
881	2	2026-11-02	13:00:00	14:00:00	4	0	OPEN
882	3	2026-11-02	13:00:00	14:00:00	4	0	OPEN
883	1	2026-11-02	14:00:00	15:00:00	4	0	OPEN
884	2	2026-11-02	14:00:00	15:00:00	4	0	OPEN
885	3	2026-11-02	14:00:00	15:00:00	4	0	OPEN
886	1	2026-11-02	15:00:00	16:00:00	4	0	OPEN
887	2	2026-11-02	15:00:00	16:00:00	4	0	OPEN
888	3	2026-11-02	15:00:00	16:00:00	4	0	OPEN
889	1	2026-11-02	16:00:00	17:00:00	4	0	OPEN
890	2	2026-11-02	16:00:00	17:00:00	4	0	OPEN
891	3	2026-11-02	16:00:00	17:00:00	4	0	OPEN
892	1	2026-11-03	08:00:00	09:00:00	4	0	OPEN
893	2	2026-11-03	08:00:00	09:00:00	4	0	OPEN
894	3	2026-11-03	08:00:00	09:00:00	4	0	OPEN
895	1	2026-11-03	09:00:00	10:00:00	4	0	OPEN
896	2	2026-11-03	09:00:00	10:00:00	4	0	OPEN
897	3	2026-11-03	09:00:00	10:00:00	4	0	OPEN
898	1	2026-11-03	10:00:00	11:00:00	4	0	OPEN
899	2	2026-11-03	10:00:00	11:00:00	4	0	OPEN
900	3	2026-11-03	10:00:00	11:00:00	4	0	OPEN
901	1	2026-11-03	11:00:00	12:00:00	4	0	OPEN
902	2	2026-11-03	11:00:00	12:00:00	4	0	OPEN
903	3	2026-11-03	11:00:00	12:00:00	4	0	OPEN
904	1	2026-11-03	12:00:00	13:00:00	4	0	OPEN
905	2	2026-11-03	12:00:00	13:00:00	4	0	OPEN
906	3	2026-11-03	12:00:00	13:00:00	4	0	OPEN
907	1	2026-11-03	13:00:00	14:00:00	4	0	OPEN
908	2	2026-11-03	13:00:00	14:00:00	4	0	OPEN
909	3	2026-11-03	13:00:00	14:00:00	4	0	OPEN
910	1	2026-11-03	14:00:00	15:00:00	4	0	OPEN
911	2	2026-11-03	14:00:00	15:00:00	4	0	OPEN
912	3	2026-11-03	14:00:00	15:00:00	4	0	OPEN
913	1	2026-11-03	15:00:00	16:00:00	4	0	OPEN
914	2	2026-11-03	15:00:00	16:00:00	4	0	OPEN
915	3	2026-11-03	15:00:00	16:00:00	4	0	OPEN
916	1	2026-11-03	16:00:00	17:00:00	4	0	OPEN
917	2	2026-11-03	16:00:00	17:00:00	4	0	OPEN
918	3	2026-11-03	16:00:00	17:00:00	4	0	OPEN
919	1	2026-11-04	08:00:00	09:00:00	4	0	OPEN
920	2	2026-11-04	08:00:00	09:00:00	4	0	OPEN
921	3	2026-11-04	08:00:00	09:00:00	4	0	OPEN
922	1	2026-11-04	09:00:00	10:00:00	4	0	OPEN
923	2	2026-11-04	09:00:00	10:00:00	4	0	OPEN
924	3	2026-11-04	09:00:00	10:00:00	4	0	OPEN
925	1	2026-11-04	10:00:00	11:00:00	4	0	OPEN
926	2	2026-11-04	10:00:00	11:00:00	4	0	OPEN
927	3	2026-11-04	10:00:00	11:00:00	4	0	OPEN
928	1	2026-11-04	11:00:00	12:00:00	4	0	OPEN
929	2	2026-11-04	11:00:00	12:00:00	4	0	OPEN
930	3	2026-11-04	11:00:00	12:00:00	4	0	OPEN
931	1	2026-11-04	12:00:00	13:00:00	4	0	OPEN
932	2	2026-11-04	12:00:00	13:00:00	4	0	OPEN
933	3	2026-11-04	12:00:00	13:00:00	4	0	OPEN
934	1	2026-11-04	13:00:00	14:00:00	4	0	OPEN
935	2	2026-11-04	13:00:00	14:00:00	4	0	OPEN
936	3	2026-11-04	13:00:00	14:00:00	4	0	OPEN
937	1	2026-11-04	14:00:00	15:00:00	4	0	OPEN
938	2	2026-11-04	14:00:00	15:00:00	4	0	OPEN
939	3	2026-11-04	14:00:00	15:00:00	4	0	OPEN
940	1	2026-11-04	15:00:00	16:00:00	4	0	OPEN
941	2	2026-11-04	15:00:00	16:00:00	4	0	OPEN
942	3	2026-11-04	15:00:00	16:00:00	4	0	OPEN
943	1	2026-11-04	16:00:00	17:00:00	4	0	OPEN
944	2	2026-11-04	16:00:00	17:00:00	4	0	OPEN
945	3	2026-11-04	16:00:00	17:00:00	4	0	OPEN
947	2	2026-11-05	08:00:00	09:00:00	4	0	OPEN
948	3	2026-11-05	08:00:00	09:00:00	4	0	OPEN
949	1	2026-11-05	09:00:00	10:00:00	4	0	OPEN
950	2	2026-11-05	09:00:00	10:00:00	4	0	OPEN
951	3	2026-11-05	09:00:00	10:00:00	4	0	OPEN
952	1	2026-11-05	10:00:00	11:00:00	4	0	OPEN
953	2	2026-11-05	10:00:00	11:00:00	4	0	OPEN
954	3	2026-11-05	10:00:00	11:00:00	4	0	OPEN
955	1	2026-11-05	11:00:00	12:00:00	4	0	OPEN
956	2	2026-11-05	11:00:00	12:00:00	4	0	OPEN
957	3	2026-11-05	11:00:00	12:00:00	4	0	OPEN
958	1	2026-11-05	12:00:00	13:00:00	4	0	OPEN
959	2	2026-11-05	12:00:00	13:00:00	4	0	OPEN
960	3	2026-11-05	12:00:00	13:00:00	4	0	OPEN
961	1	2026-11-05	13:00:00	14:00:00	4	0	OPEN
962	2	2026-11-05	13:00:00	14:00:00	4	0	OPEN
963	3	2026-11-05	13:00:00	14:00:00	4	0	OPEN
964	1	2026-11-05	14:00:00	15:00:00	4	0	OPEN
965	2	2026-11-05	14:00:00	15:00:00	4	0	OPEN
966	3	2026-11-05	14:00:00	15:00:00	4	0	OPEN
967	1	2026-11-05	15:00:00	16:00:00	4	0	OPEN
968	2	2026-11-05	15:00:00	16:00:00	4	0	OPEN
969	3	2026-11-05	15:00:00	16:00:00	4	0	OPEN
970	1	2026-11-05	16:00:00	17:00:00	4	0	OPEN
971	2	2026-11-05	16:00:00	17:00:00	4	0	OPEN
972	3	2026-11-05	16:00:00	17:00:00	4	0	OPEN
973	1	2026-11-06	08:00:00	09:00:00	4	0	OPEN
974	2	2026-11-06	08:00:00	09:00:00	4	0	OPEN
975	3	2026-11-06	08:00:00	09:00:00	4	0	OPEN
976	1	2026-11-06	09:00:00	10:00:00	4	0	OPEN
977	2	2026-11-06	09:00:00	10:00:00	4	0	OPEN
978	3	2026-11-06	09:00:00	10:00:00	4	0	OPEN
980	2	2026-11-06	10:00:00	11:00:00	4	0	OPEN
981	3	2026-11-06	10:00:00	11:00:00	4	0	OPEN
982	1	2026-11-06	11:00:00	12:00:00	4	0	OPEN
983	2	2026-11-06	11:00:00	12:00:00	4	0	OPEN
984	3	2026-11-06	11:00:00	12:00:00	4	0	OPEN
985	1	2026-11-06	12:00:00	13:00:00	4	0	OPEN
986	2	2026-11-06	12:00:00	13:00:00	4	0	OPEN
987	3	2026-11-06	12:00:00	13:00:00	4	0	OPEN
988	1	2026-11-06	13:00:00	14:00:00	4	0	OPEN
989	2	2026-11-06	13:00:00	14:00:00	4	0	OPEN
990	3	2026-11-06	13:00:00	14:00:00	4	0	OPEN
991	1	2026-11-06	14:00:00	15:00:00	4	0	OPEN
992	2	2026-11-06	14:00:00	15:00:00	4	0	OPEN
993	3	2026-11-06	14:00:00	15:00:00	4	0	OPEN
995	2	2026-11-06	15:00:00	16:00:00	4	0	OPEN
996	3	2026-11-06	15:00:00	16:00:00	4	0	OPEN
997	1	2026-11-06	16:00:00	17:00:00	4	0	OPEN
998	2	2026-11-06	16:00:00	17:00:00	4	0	OPEN
999	3	2026-11-06	16:00:00	17:00:00	4	0	OPEN
1001	2	2026-11-07	08:00:00	09:00:00	4	0	OPEN
1002	3	2026-11-07	08:00:00	09:00:00	4	0	OPEN
1004	2	2026-11-07	09:00:00	10:00:00	4	0	OPEN
1005	3	2026-11-07	09:00:00	10:00:00	4	0	OPEN
1008	3	2026-11-07	10:00:00	11:00:00	4	0	OPEN
1009	1	2026-11-07	11:00:00	12:00:00	4	0	OPEN
1010	2	2026-11-07	11:00:00	12:00:00	4	0	OPEN
1011	3	2026-11-07	11:00:00	12:00:00	4	0	OPEN
1012	1	2026-11-07	12:00:00	13:00:00	4	0	OPEN
1013	2	2026-11-07	12:00:00	13:00:00	4	0	OPEN
1014	3	2026-11-07	12:00:00	13:00:00	4	0	OPEN
1016	2	2026-11-07	13:00:00	14:00:00	4	0	OPEN
1017	3	2026-11-07	13:00:00	14:00:00	4	0	OPEN
1019	2	2026-11-07	14:00:00	15:00:00	4	0	OPEN
1020	3	2026-11-07	14:00:00	15:00:00	4	0	OPEN
1021	1	2026-11-07	15:00:00	16:00:00	4	0	OPEN
1022	2	2026-11-07	15:00:00	16:00:00	4	0	OPEN
1023	3	2026-11-07	15:00:00	16:00:00	4	0	OPEN
1024	1	2026-11-07	16:00:00	17:00:00	4	0	OPEN
1025	2	2026-11-07	16:00:00	17:00:00	4	0	OPEN
1026	3	2026-11-07	16:00:00	17:00:00	4	0	OPEN
1028	2	2026-11-08	08:00:00	09:00:00	4	0	OPEN
1029	3	2026-11-08	08:00:00	09:00:00	4	0	OPEN
1031	2	2026-11-08	09:00:00	10:00:00	4	0	OPEN
1034	2	2026-11-08	10:00:00	11:00:00	4	0	OPEN
1035	3	2026-11-08	10:00:00	11:00:00	4	0	OPEN
1037	2	2026-11-08	11:00:00	12:00:00	4	0	OPEN
1038	3	2026-11-08	11:00:00	12:00:00	4	0	OPEN
1039	1	2026-11-08	12:00:00	13:00:00	4	0	OPEN
1040	2	2026-11-08	12:00:00	13:00:00	4	0	OPEN
1041	3	2026-11-08	12:00:00	13:00:00	4	0	OPEN
1043	2	2026-11-08	13:00:00	14:00:00	4	0	OPEN
1044	3	2026-11-08	13:00:00	14:00:00	4	0	OPEN
1045	1	2026-11-08	14:00:00	15:00:00	4	0	OPEN
1047	3	2026-11-08	14:00:00	15:00:00	4	0	OPEN
1049	2	2026-11-08	15:00:00	16:00:00	4	0	OPEN
1050	3	2026-11-08	15:00:00	16:00:00	4	0	OPEN
1052	2	2026-11-08	16:00:00	17:00:00	4	0	OPEN
1053	3	2026-11-08	16:00:00	17:00:00	4	0	OPEN
1055	2	2026-11-09	08:00:00	09:00:00	4	0	OPEN
1056	3	2026-11-09	08:00:00	09:00:00	4	0	OPEN
1058	2	2026-11-09	09:00:00	10:00:00	4	0	OPEN
1059	3	2026-11-09	09:00:00	10:00:00	4	0	OPEN
1061	2	2026-11-09	10:00:00	11:00:00	4	0	OPEN
1062	3	2026-11-09	10:00:00	11:00:00	4	0	OPEN
1063	1	2026-11-09	11:00:00	12:00:00	4	0	OPEN
1064	2	2026-11-09	11:00:00	12:00:00	4	0	OPEN
1065	3	2026-11-09	11:00:00	12:00:00	4	0	OPEN
1066	1	2026-11-09	12:00:00	13:00:00	4	0	OPEN
1067	2	2026-11-09	12:00:00	13:00:00	4	0	OPEN
1068	3	2026-11-09	12:00:00	13:00:00	4	0	OPEN
1069	1	2026-11-09	13:00:00	14:00:00	4	0	OPEN
1070	2	2026-11-09	13:00:00	14:00:00	4	0	OPEN
1071	3	2026-11-09	13:00:00	14:00:00	4	0	OPEN
1073	2	2026-11-09	14:00:00	15:00:00	4	0	OPEN
1074	3	2026-11-09	14:00:00	15:00:00	4	0	OPEN
1075	1	2026-11-09	15:00:00	16:00:00	4	0	OPEN
1076	2	2026-11-09	15:00:00	16:00:00	4	0	OPEN
1077	3	2026-11-09	15:00:00	16:00:00	4	0	OPEN
1078	1	2026-11-09	16:00:00	17:00:00	4	0	OPEN
1079	2	2026-11-09	16:00:00	17:00:00	4	0	OPEN
1080	3	2026-11-09	16:00:00	17:00:00	4	0	OPEN
1082	2	2026-11-10	08:00:00	09:00:00	4	0	OPEN
1083	3	2026-11-10	08:00:00	09:00:00	4	0	OPEN
1084	1	2026-11-10	09:00:00	10:00:00	4	0	OPEN
1085	2	2026-11-10	09:00:00	10:00:00	4	0	OPEN
1086	3	2026-11-10	09:00:00	10:00:00	4	0	OPEN
1087	1	2026-11-10	10:00:00	11:00:00	4	0	OPEN
1088	2	2026-11-10	10:00:00	11:00:00	4	0	OPEN
1089	3	2026-11-10	10:00:00	11:00:00	4	0	OPEN
1090	1	2026-11-10	11:00:00	12:00:00	4	0	OPEN
1091	2	2026-11-10	11:00:00	12:00:00	4	0	OPEN
1092	3	2026-11-10	11:00:00	12:00:00	4	0	OPEN
1093	1	2026-11-10	12:00:00	13:00:00	4	0	OPEN
1094	2	2026-11-10	12:00:00	13:00:00	4	0	OPEN
1095	3	2026-11-10	12:00:00	13:00:00	4	0	OPEN
1096	1	2026-11-10	13:00:00	14:00:00	4	0	OPEN
1097	2	2026-11-10	13:00:00	14:00:00	4	0	OPEN
1098	3	2026-11-10	13:00:00	14:00:00	4	0	OPEN
1099	1	2026-11-10	14:00:00	15:00:00	4	0	OPEN
1100	2	2026-11-10	14:00:00	15:00:00	4	0	OPEN
1101	3	2026-11-10	14:00:00	15:00:00	4	0	OPEN
1102	1	2026-11-10	15:00:00	16:00:00	4	0	OPEN
1103	2	2026-11-10	15:00:00	16:00:00	4	0	OPEN
1104	3	2026-11-10	15:00:00	16:00:00	4	0	OPEN
1105	1	2026-11-10	16:00:00	17:00:00	4	0	OPEN
1106	2	2026-11-10	16:00:00	17:00:00	4	0	OPEN
1107	3	2026-11-10	16:00:00	17:00:00	4	0	OPEN
1108	1	2026-11-11	08:00:00	09:00:00	4	0	OPEN
1109	2	2026-11-11	08:00:00	09:00:00	4	0	OPEN
1110	3	2026-11-11	08:00:00	09:00:00	4	0	OPEN
1112	2	2026-11-11	09:00:00	10:00:00	4	0	OPEN
1113	3	2026-11-11	09:00:00	10:00:00	4	0	OPEN
1114	1	2026-11-11	10:00:00	11:00:00	4	0	OPEN
1115	2	2026-11-11	10:00:00	11:00:00	4	0	OPEN
1116	3	2026-11-11	10:00:00	11:00:00	4	0	OPEN
1117	1	2026-11-11	11:00:00	12:00:00	4	0	OPEN
1118	2	2026-11-11	11:00:00	12:00:00	4	0	OPEN
1119	3	2026-11-11	11:00:00	12:00:00	4	0	OPEN
1120	1	2026-11-11	12:00:00	13:00:00	4	0	OPEN
1121	2	2026-11-11	12:00:00	13:00:00	4	0	OPEN
1122	3	2026-11-11	12:00:00	13:00:00	4	0	OPEN
1123	1	2026-11-11	13:00:00	14:00:00	4	0	OPEN
1124	2	2026-11-11	13:00:00	14:00:00	4	0	OPEN
1125	3	2026-11-11	13:00:00	14:00:00	4	0	OPEN
1126	1	2026-11-11	14:00:00	15:00:00	4	0	OPEN
1127	2	2026-11-11	14:00:00	15:00:00	4	0	OPEN
1128	3	2026-11-11	14:00:00	15:00:00	4	0	OPEN
1129	1	2026-11-11	15:00:00	16:00:00	4	0	OPEN
1130	2	2026-11-11	15:00:00	16:00:00	4	0	OPEN
1131	3	2026-11-11	15:00:00	16:00:00	4	0	OPEN
1132	1	2026-11-11	16:00:00	17:00:00	4	0	OPEN
1133	2	2026-11-11	16:00:00	17:00:00	4	0	OPEN
1134	3	2026-11-11	16:00:00	17:00:00	4	0	OPEN
1135	1	2026-11-12	08:00:00	09:00:00	4	0	OPEN
1136	2	2026-11-12	08:00:00	09:00:00	4	0	OPEN
1137	3	2026-11-12	08:00:00	09:00:00	4	0	OPEN
1138	1	2026-11-12	09:00:00	10:00:00	4	0	OPEN
1139	2	2026-11-12	09:00:00	10:00:00	4	0	OPEN
1140	3	2026-11-12	09:00:00	10:00:00	4	0	OPEN
1141	1	2026-11-12	10:00:00	11:00:00	4	0	OPEN
1143	3	2026-11-12	10:00:00	11:00:00	4	0	OPEN
1144	1	2026-11-12	11:00:00	12:00:00	4	0	OPEN
1145	2	2026-11-12	11:00:00	12:00:00	4	0	OPEN
1146	3	2026-11-12	11:00:00	12:00:00	4	0	OPEN
1147	1	2026-11-12	12:00:00	13:00:00	4	0	OPEN
1148	2	2026-11-12	12:00:00	13:00:00	4	0	OPEN
1149	3	2026-11-12	12:00:00	13:00:00	4	0	OPEN
1150	1	2026-11-12	13:00:00	14:00:00	4	0	OPEN
1151	2	2026-11-12	13:00:00	14:00:00	4	0	OPEN
1152	3	2026-11-12	13:00:00	14:00:00	4	0	OPEN
1154	2	2026-11-12	14:00:00	15:00:00	4	0	OPEN
1155	3	2026-11-12	14:00:00	15:00:00	4	0	OPEN
1156	1	2026-11-12	15:00:00	16:00:00	4	0	OPEN
1157	2	2026-11-12	15:00:00	16:00:00	4	0	OPEN
1158	3	2026-11-12	15:00:00	16:00:00	4	0	OPEN
1159	1	2026-11-12	16:00:00	17:00:00	4	0	OPEN
1160	2	2026-11-12	16:00:00	17:00:00	4	0	OPEN
1161	3	2026-11-12	16:00:00	17:00:00	4	0	OPEN
1162	1	2026-11-13	08:00:00	09:00:00	4	0	OPEN
1163	2	2026-11-13	08:00:00	09:00:00	4	0	OPEN
1164	3	2026-11-13	08:00:00	09:00:00	4	0	OPEN
1165	1	2026-11-13	09:00:00	10:00:00	4	0	OPEN
1166	2	2026-11-13	09:00:00	10:00:00	4	0	OPEN
1168	1	2026-11-13	10:00:00	11:00:00	4	0	OPEN
1169	2	2026-11-13	10:00:00	11:00:00	4	0	OPEN
1170	3	2026-11-13	10:00:00	11:00:00	4	0	OPEN
1171	1	2026-11-13	11:00:00	12:00:00	4	0	OPEN
1172	2	2026-11-13	11:00:00	12:00:00	4	0	OPEN
1173	3	2026-11-13	11:00:00	12:00:00	4	0	OPEN
1174	1	2026-11-13	12:00:00	13:00:00	4	0	OPEN
1175	2	2026-11-13	12:00:00	13:00:00	4	0	OPEN
1176	3	2026-11-13	12:00:00	13:00:00	4	0	OPEN
1177	1	2026-11-13	13:00:00	14:00:00	4	0	OPEN
1178	2	2026-11-13	13:00:00	14:00:00	4	0	OPEN
1179	3	2026-11-13	13:00:00	14:00:00	4	0	OPEN
1180	1	2026-11-13	14:00:00	15:00:00	4	0	OPEN
1181	2	2026-11-13	14:00:00	15:00:00	4	0	OPEN
1182	3	2026-11-13	14:00:00	15:00:00	4	0	OPEN
1183	1	2026-11-13	15:00:00	16:00:00	4	0	OPEN
1184	2	2026-11-13	15:00:00	16:00:00	4	0	OPEN
1185	3	2026-11-13	15:00:00	16:00:00	4	0	OPEN
1186	1	2026-11-13	16:00:00	17:00:00	4	0	OPEN
1187	2	2026-11-13	16:00:00	17:00:00	4	0	OPEN
1188	3	2026-11-13	16:00:00	17:00:00	4	0	OPEN
1189	1	2026-11-14	08:00:00	09:00:00	4	0	OPEN
1190	2	2026-11-14	08:00:00	09:00:00	4	0	OPEN
1191	3	2026-11-14	08:00:00	09:00:00	4	0	OPEN
1192	1	2026-11-14	09:00:00	10:00:00	4	0	OPEN
1193	2	2026-11-14	09:00:00	10:00:00	4	0	OPEN
1194	3	2026-11-14	09:00:00	10:00:00	4	0	OPEN
1195	1	2026-11-14	10:00:00	11:00:00	4	0	OPEN
1196	2	2026-11-14	10:00:00	11:00:00	4	0	OPEN
1197	3	2026-11-14	10:00:00	11:00:00	4	0	OPEN
1198	1	2026-11-14	11:00:00	12:00:00	4	0	OPEN
1199	2	2026-11-14	11:00:00	12:00:00	4	0	OPEN
1200	3	2026-11-14	11:00:00	12:00:00	4	0	OPEN
1201	1	2026-11-14	12:00:00	13:00:00	4	0	OPEN
1202	2	2026-11-14	12:00:00	13:00:00	4	0	OPEN
1203	3	2026-11-14	12:00:00	13:00:00	4	0	OPEN
1204	1	2026-11-14	13:00:00	14:00:00	4	0	OPEN
1205	2	2026-11-14	13:00:00	14:00:00	4	0	OPEN
1206	3	2026-11-14	13:00:00	14:00:00	4	0	OPEN
1207	1	2026-11-14	14:00:00	15:00:00	4	0	OPEN
1208	2	2026-11-14	14:00:00	15:00:00	4	0	OPEN
1209	3	2026-11-14	14:00:00	15:00:00	4	0	OPEN
1210	1	2026-11-14	15:00:00	16:00:00	4	0	OPEN
1211	2	2026-11-14	15:00:00	16:00:00	4	0	OPEN
1212	3	2026-11-14	15:00:00	16:00:00	4	0	OPEN
1213	1	2026-11-14	16:00:00	17:00:00	4	0	OPEN
1214	2	2026-11-14	16:00:00	17:00:00	4	0	OPEN
1215	3	2026-11-14	16:00:00	17:00:00	4	0	OPEN
1216	1	2026-11-15	08:00:00	09:00:00	4	0	OPEN
1217	2	2026-11-15	08:00:00	09:00:00	4	0	OPEN
1218	3	2026-11-15	08:00:00	09:00:00	4	0	OPEN
1219	1	2026-11-15	09:00:00	10:00:00	4	0	OPEN
1220	2	2026-11-15	09:00:00	10:00:00	4	0	OPEN
1221	3	2026-11-15	09:00:00	10:00:00	4	0	OPEN
1222	1	2026-11-15	10:00:00	11:00:00	4	0	OPEN
1223	2	2026-11-15	10:00:00	11:00:00	4	0	OPEN
1224	3	2026-11-15	10:00:00	11:00:00	4	0	OPEN
1225	1	2026-11-15	11:00:00	12:00:00	4	0	OPEN
1226	2	2026-11-15	11:00:00	12:00:00	4	0	OPEN
1227	3	2026-11-15	11:00:00	12:00:00	4	0	OPEN
1228	1	2026-11-15	12:00:00	13:00:00	4	0	OPEN
1229	2	2026-11-15	12:00:00	13:00:00	4	0	OPEN
1230	3	2026-11-15	12:00:00	13:00:00	4	0	OPEN
1231	1	2026-11-15	13:00:00	14:00:00	4	0	OPEN
1232	2	2026-11-15	13:00:00	14:00:00	4	0	OPEN
1233	3	2026-11-15	13:00:00	14:00:00	4	0	OPEN
1234	1	2026-11-15	14:00:00	15:00:00	4	0	OPEN
1235	2	2026-11-15	14:00:00	15:00:00	4	0	OPEN
1236	3	2026-11-15	14:00:00	15:00:00	4	0	OPEN
1237	1	2026-11-15	15:00:00	16:00:00	4	0	OPEN
1238	2	2026-11-15	15:00:00	16:00:00	4	0	OPEN
1239	3	2026-11-15	15:00:00	16:00:00	4	0	OPEN
1240	1	2026-11-15	16:00:00	17:00:00	4	0	OPEN
1241	2	2026-11-15	16:00:00	17:00:00	4	0	OPEN
1242	3	2026-11-15	16:00:00	17:00:00	4	0	OPEN
1243	1	2026-11-16	08:00:00	09:00:00	4	0	OPEN
1244	2	2026-11-16	08:00:00	09:00:00	4	0	OPEN
1245	3	2026-11-16	08:00:00	09:00:00	4	0	OPEN
1246	1	2026-11-16	09:00:00	10:00:00	4	0	OPEN
1247	2	2026-11-16	09:00:00	10:00:00	4	0	OPEN
1248	3	2026-11-16	09:00:00	10:00:00	4	0	OPEN
1249	1	2026-11-16	10:00:00	11:00:00	4	0	OPEN
1250	2	2026-11-16	10:00:00	11:00:00	4	0	OPEN
1251	3	2026-11-16	10:00:00	11:00:00	4	0	OPEN
1252	1	2026-11-16	11:00:00	12:00:00	4	0	OPEN
1253	2	2026-11-16	11:00:00	12:00:00	4	0	OPEN
1254	3	2026-11-16	11:00:00	12:00:00	4	0	OPEN
1255	1	2026-11-16	12:00:00	13:00:00	4	0	OPEN
1256	2	2026-11-16	12:00:00	13:00:00	4	0	OPEN
1257	3	2026-11-16	12:00:00	13:00:00	4	0	OPEN
1258	1	2026-11-16	13:00:00	14:00:00	4	0	OPEN
1259	2	2026-11-16	13:00:00	14:00:00	4	0	OPEN
1260	3	2026-11-16	13:00:00	14:00:00	4	0	OPEN
1261	1	2026-11-16	14:00:00	15:00:00	4	0	OPEN
1262	2	2026-11-16	14:00:00	15:00:00	4	0	OPEN
1263	3	2026-11-16	14:00:00	15:00:00	4	0	OPEN
1264	1	2026-11-16	15:00:00	16:00:00	4	0	OPEN
1265	2	2026-11-16	15:00:00	16:00:00	4	0	OPEN
1266	3	2026-11-16	15:00:00	16:00:00	4	0	OPEN
1267	1	2026-11-16	16:00:00	17:00:00	4	0	OPEN
1268	2	2026-11-16	16:00:00	17:00:00	4	0	OPEN
1269	3	2026-11-16	16:00:00	17:00:00	4	0	OPEN
1270	1	2026-11-17	08:00:00	09:00:00	4	0	OPEN
1271	2	2026-11-17	08:00:00	09:00:00	4	0	OPEN
1272	3	2026-11-17	08:00:00	09:00:00	4	0	OPEN
1273	1	2026-11-17	09:00:00	10:00:00	4	0	OPEN
1274	2	2026-11-17	09:00:00	10:00:00	4	0	OPEN
1275	3	2026-11-17	09:00:00	10:00:00	4	0	OPEN
1276	1	2026-11-17	10:00:00	11:00:00	4	0	OPEN
1277	2	2026-11-17	10:00:00	11:00:00	4	0	OPEN
1278	3	2026-11-17	10:00:00	11:00:00	4	0	OPEN
1279	1	2026-11-17	11:00:00	12:00:00	4	0	OPEN
1280	2	2026-11-17	11:00:00	12:00:00	4	0	OPEN
1281	3	2026-11-17	11:00:00	12:00:00	4	0	OPEN
1282	1	2026-11-17	12:00:00	13:00:00	4	0	OPEN
1283	2	2026-11-17	12:00:00	13:00:00	4	0	OPEN
1284	3	2026-11-17	12:00:00	13:00:00	4	0	OPEN
1285	1	2026-11-17	13:00:00	14:00:00	4	0	OPEN
1286	2	2026-11-17	13:00:00	14:00:00	4	0	OPEN
1287	3	2026-11-17	13:00:00	14:00:00	4	0	OPEN
1288	1	2026-11-17	14:00:00	15:00:00	4	0	OPEN
1289	2	2026-11-17	14:00:00	15:00:00	4	0	OPEN
1290	3	2026-11-17	14:00:00	15:00:00	4	0	OPEN
1291	1	2026-11-17	15:00:00	16:00:00	4	0	OPEN
1292	2	2026-11-17	15:00:00	16:00:00	4	0	OPEN
1293	3	2026-11-17	15:00:00	16:00:00	4	0	OPEN
1294	1	2026-11-17	16:00:00	17:00:00	4	0	OPEN
1295	2	2026-11-17	16:00:00	17:00:00	4	0	OPEN
1296	3	2026-11-17	16:00:00	17:00:00	4	0	OPEN
1297	1	2026-11-18	08:00:00	09:00:00	4	0	OPEN
1298	2	2026-11-18	08:00:00	09:00:00	4	0	OPEN
1299	3	2026-11-18	08:00:00	09:00:00	4	0	OPEN
1300	1	2026-11-18	09:00:00	10:00:00	4	0	OPEN
1301	2	2026-11-18	09:00:00	10:00:00	4	0	OPEN
1302	3	2026-11-18	09:00:00	10:00:00	4	0	OPEN
1303	1	2026-11-18	10:00:00	11:00:00	4	0	OPEN
1304	2	2026-11-18	10:00:00	11:00:00	4	0	OPEN
1305	3	2026-11-18	10:00:00	11:00:00	4	0	OPEN
1306	1	2026-11-18	11:00:00	12:00:00	4	0	OPEN
1307	2	2026-11-18	11:00:00	12:00:00	4	0	OPEN
1308	3	2026-11-18	11:00:00	12:00:00	4	0	OPEN
1309	1	2026-11-18	12:00:00	13:00:00	4	0	OPEN
1310	2	2026-11-18	12:00:00	13:00:00	4	0	OPEN
1311	3	2026-11-18	12:00:00	13:00:00	4	0	OPEN
1312	1	2026-11-18	13:00:00	14:00:00	4	0	OPEN
1313	2	2026-11-18	13:00:00	14:00:00	4	0	OPEN
1314	3	2026-11-18	13:00:00	14:00:00	4	0	OPEN
1315	1	2026-11-18	14:00:00	15:00:00	4	0	OPEN
1316	2	2026-11-18	14:00:00	15:00:00	4	0	OPEN
1317	3	2026-11-18	14:00:00	15:00:00	4	0	OPEN
1318	1	2026-11-18	15:00:00	16:00:00	4	0	OPEN
1319	2	2026-11-18	15:00:00	16:00:00	4	0	OPEN
1320	3	2026-11-18	15:00:00	16:00:00	4	0	OPEN
1321	1	2026-11-18	16:00:00	17:00:00	4	0	OPEN
1322	2	2026-11-18	16:00:00	17:00:00	4	0	OPEN
1323	3	2026-11-18	16:00:00	17:00:00	4	0	OPEN
1324	1	2026-11-19	08:00:00	09:00:00	4	0	OPEN
1325	2	2026-11-19	08:00:00	09:00:00	4	0	OPEN
1326	3	2026-11-19	08:00:00	09:00:00	4	0	OPEN
1327	1	2026-11-19	09:00:00	10:00:00	4	0	OPEN
1328	2	2026-11-19	09:00:00	10:00:00	4	0	OPEN
1329	3	2026-11-19	09:00:00	10:00:00	4	0	OPEN
1330	1	2026-11-19	10:00:00	11:00:00	4	0	OPEN
1331	2	2026-11-19	10:00:00	11:00:00	4	0	OPEN
1332	3	2026-11-19	10:00:00	11:00:00	4	0	OPEN
1333	1	2026-11-19	11:00:00	12:00:00	4	0	OPEN
1334	2	2026-11-19	11:00:00	12:00:00	4	0	OPEN
1335	3	2026-11-19	11:00:00	12:00:00	4	0	OPEN
1336	1	2026-11-19	12:00:00	13:00:00	4	0	OPEN
1337	2	2026-11-19	12:00:00	13:00:00	4	0	OPEN
1338	3	2026-11-19	12:00:00	13:00:00	4	0	OPEN
1339	1	2026-11-19	13:00:00	14:00:00	4	0	OPEN
1340	2	2026-11-19	13:00:00	14:00:00	4	0	OPEN
1341	3	2026-11-19	13:00:00	14:00:00	4	0	OPEN
1342	1	2026-11-19	14:00:00	15:00:00	4	0	OPEN
1343	2	2026-11-19	14:00:00	15:00:00	4	0	OPEN
1344	3	2026-11-19	14:00:00	15:00:00	4	0	OPEN
1345	1	2026-11-19	15:00:00	16:00:00	4	0	OPEN
1346	2	2026-11-19	15:00:00	16:00:00	4	0	OPEN
1347	3	2026-11-19	15:00:00	16:00:00	4	0	OPEN
1348	1	2026-11-19	16:00:00	17:00:00	4	0	OPEN
1349	2	2026-11-19	16:00:00	17:00:00	4	0	OPEN
1350	3	2026-11-19	16:00:00	17:00:00	4	0	OPEN
1351	1	2026-11-20	08:00:00	09:00:00	4	0	OPEN
1352	2	2026-11-20	08:00:00	09:00:00	4	0	OPEN
1353	3	2026-11-20	08:00:00	09:00:00	4	0	OPEN
1354	1	2026-11-20	09:00:00	10:00:00	4	0	OPEN
1355	2	2026-11-20	09:00:00	10:00:00	4	0	OPEN
1356	3	2026-11-20	09:00:00	10:00:00	4	0	OPEN
1357	1	2026-11-20	10:00:00	11:00:00	4	0	OPEN
1358	2	2026-11-20	10:00:00	11:00:00	4	0	OPEN
1359	3	2026-11-20	10:00:00	11:00:00	4	0	OPEN
1360	1	2026-11-20	11:00:00	12:00:00	4	0	OPEN
1361	2	2026-11-20	11:00:00	12:00:00	4	0	OPEN
1362	3	2026-11-20	11:00:00	12:00:00	4	0	OPEN
1363	1	2026-11-20	12:00:00	13:00:00	4	0	OPEN
1364	2	2026-11-20	12:00:00	13:00:00	4	0	OPEN
1365	3	2026-11-20	12:00:00	13:00:00	4	0	OPEN
1366	1	2026-11-20	13:00:00	14:00:00	4	0	OPEN
1367	2	2026-11-20	13:00:00	14:00:00	4	0	OPEN
1368	3	2026-11-20	13:00:00	14:00:00	4	0	OPEN
1369	1	2026-11-20	14:00:00	15:00:00	4	0	OPEN
1370	2	2026-11-20	14:00:00	15:00:00	4	0	OPEN
1371	3	2026-11-20	14:00:00	15:00:00	4	0	OPEN
1372	1	2026-11-20	15:00:00	16:00:00	4	0	OPEN
1373	2	2026-11-20	15:00:00	16:00:00	4	0	OPEN
1374	3	2026-11-20	15:00:00	16:00:00	4	0	OPEN
1375	1	2026-11-20	16:00:00	17:00:00	4	0	OPEN
1376	2	2026-11-20	16:00:00	17:00:00	4	0	OPEN
1377	3	2026-11-20	16:00:00	17:00:00	4	0	OPEN
1378	1	2026-11-21	08:00:00	09:00:00	4	0	OPEN
1379	2	2026-11-21	08:00:00	09:00:00	4	0	OPEN
1380	3	2026-11-21	08:00:00	09:00:00	4	0	OPEN
1381	1	2026-11-21	09:00:00	10:00:00	4	0	OPEN
1382	2	2026-11-21	09:00:00	10:00:00	4	0	OPEN
1383	3	2026-11-21	09:00:00	10:00:00	4	0	OPEN
1384	1	2026-11-21	10:00:00	11:00:00	4	0	OPEN
1385	2	2026-11-21	10:00:00	11:00:00	4	0	OPEN
1386	3	2026-11-21	10:00:00	11:00:00	4	0	OPEN
1387	1	2026-11-21	11:00:00	12:00:00	4	0	OPEN
1388	2	2026-11-21	11:00:00	12:00:00	4	0	OPEN
1389	3	2026-11-21	11:00:00	12:00:00	4	0	OPEN
1390	1	2026-11-21	12:00:00	13:00:00	4	0	OPEN
1391	2	2026-11-21	12:00:00	13:00:00	4	0	OPEN
1392	3	2026-11-21	12:00:00	13:00:00	4	0	OPEN
1393	1	2026-11-21	13:00:00	14:00:00	4	0	OPEN
1394	2	2026-11-21	13:00:00	14:00:00	4	0	OPEN
1395	3	2026-11-21	13:00:00	14:00:00	4	0	OPEN
1396	1	2026-11-21	14:00:00	15:00:00	4	0	OPEN
1397	2	2026-11-21	14:00:00	15:00:00	4	0	OPEN
1398	3	2026-11-21	14:00:00	15:00:00	4	0	OPEN
1399	1	2026-11-21	15:00:00	16:00:00	4	0	OPEN
1400	2	2026-11-21	15:00:00	16:00:00	4	0	OPEN
1401	3	2026-11-21	15:00:00	16:00:00	4	0	OPEN
1402	1	2026-11-21	16:00:00	17:00:00	4	0	OPEN
1403	2	2026-11-21	16:00:00	17:00:00	4	0	OPEN
1404	3	2026-11-21	16:00:00	17:00:00	4	0	OPEN
1405	1	2026-11-22	08:00:00	09:00:00	4	0	OPEN
1406	2	2026-11-22	08:00:00	09:00:00	4	0	OPEN
1407	3	2026-11-22	08:00:00	09:00:00	4	0	OPEN
1408	1	2026-11-22	09:00:00	10:00:00	4	0	OPEN
1409	2	2026-11-22	09:00:00	10:00:00	4	0	OPEN
1410	3	2026-11-22	09:00:00	10:00:00	4	0	OPEN
1411	1	2026-11-22	10:00:00	11:00:00	4	0	OPEN
1412	2	2026-11-22	10:00:00	11:00:00	4	0	OPEN
1413	3	2026-11-22	10:00:00	11:00:00	4	0	OPEN
1414	1	2026-11-22	11:00:00	12:00:00	4	0	OPEN
1415	2	2026-11-22	11:00:00	12:00:00	4	0	OPEN
1416	3	2026-11-22	11:00:00	12:00:00	4	0	OPEN
1417	1	2026-11-22	12:00:00	13:00:00	4	0	OPEN
1418	2	2026-11-22	12:00:00	13:00:00	4	0	OPEN
1419	3	2026-11-22	12:00:00	13:00:00	4	0	OPEN
1420	1	2026-11-22	13:00:00	14:00:00	4	0	OPEN
1421	2	2026-11-22	13:00:00	14:00:00	4	0	OPEN
1422	3	2026-11-22	13:00:00	14:00:00	4	0	OPEN
1423	1	2026-11-22	14:00:00	15:00:00	4	0	OPEN
1424	2	2026-11-22	14:00:00	15:00:00	4	0	OPEN
1425	3	2026-11-22	14:00:00	15:00:00	4	0	OPEN
1426	1	2026-11-22	15:00:00	16:00:00	4	0	OPEN
1427	2	2026-11-22	15:00:00	16:00:00	4	0	OPEN
1428	3	2026-11-22	15:00:00	16:00:00	4	0	OPEN
1429	1	2026-11-22	16:00:00	17:00:00	4	0	OPEN
1430	2	2026-11-22	16:00:00	17:00:00	4	0	OPEN
1431	3	2026-11-22	16:00:00	17:00:00	4	0	OPEN
1432	1	2026-11-23	08:00:00	09:00:00	4	0	OPEN
1433	2	2026-11-23	08:00:00	09:00:00	4	0	OPEN
1434	3	2026-11-23	08:00:00	09:00:00	4	0	OPEN
1435	1	2026-11-23	09:00:00	10:00:00	4	0	OPEN
1436	2	2026-11-23	09:00:00	10:00:00	4	0	OPEN
1437	3	2026-11-23	09:00:00	10:00:00	4	0	OPEN
1438	1	2026-11-23	10:00:00	11:00:00	4	0	OPEN
1439	2	2026-11-23	10:00:00	11:00:00	4	0	OPEN
1440	3	2026-11-23	10:00:00	11:00:00	4	0	OPEN
1441	1	2026-11-23	11:00:00	12:00:00	4	0	OPEN
1442	2	2026-11-23	11:00:00	12:00:00	4	0	OPEN
1443	3	2026-11-23	11:00:00	12:00:00	4	0	OPEN
1444	1	2026-11-23	12:00:00	13:00:00	4	0	OPEN
1445	2	2026-11-23	12:00:00	13:00:00	4	0	OPEN
1446	3	2026-11-23	12:00:00	13:00:00	4	0	OPEN
1447	1	2026-11-23	13:00:00	14:00:00	4	0	OPEN
1448	2	2026-11-23	13:00:00	14:00:00	4	0	OPEN
1449	3	2026-11-23	13:00:00	14:00:00	4	0	OPEN
1450	1	2026-11-23	14:00:00	15:00:00	4	0	OPEN
1451	2	2026-11-23	14:00:00	15:00:00	4	0	OPEN
1452	3	2026-11-23	14:00:00	15:00:00	4	0	OPEN
1453	1	2026-11-23	15:00:00	16:00:00	4	0	OPEN
1454	2	2026-11-23	15:00:00	16:00:00	4	0	OPEN
1455	3	2026-11-23	15:00:00	16:00:00	4	0	OPEN
1456	1	2026-11-23	16:00:00	17:00:00	4	0	OPEN
1457	2	2026-11-23	16:00:00	17:00:00	4	0	OPEN
1458	3	2026-11-23	16:00:00	17:00:00	4	0	OPEN
1459	1	2026-11-24	08:00:00	09:00:00	4	0	OPEN
1460	2	2026-11-24	08:00:00	09:00:00	4	0	OPEN
1461	3	2026-11-24	08:00:00	09:00:00	4	0	OPEN
1462	1	2026-11-24	09:00:00	10:00:00	4	0	OPEN
1463	2	2026-11-24	09:00:00	10:00:00	4	0	OPEN
1464	3	2026-11-24	09:00:00	10:00:00	4	0	OPEN
1465	1	2026-11-24	10:00:00	11:00:00	4	0	OPEN
1466	2	2026-11-24	10:00:00	11:00:00	4	0	OPEN
1467	3	2026-11-24	10:00:00	11:00:00	4	0	OPEN
1468	1	2026-11-24	11:00:00	12:00:00	4	0	OPEN
1469	2	2026-11-24	11:00:00	12:00:00	4	0	OPEN
1470	3	2026-11-24	11:00:00	12:00:00	4	0	OPEN
1471	1	2026-11-24	12:00:00	13:00:00	4	0	OPEN
1472	2	2026-11-24	12:00:00	13:00:00	4	0	OPEN
1473	3	2026-11-24	12:00:00	13:00:00	4	0	OPEN
1474	1	2026-11-24	13:00:00	14:00:00	4	0	OPEN
1475	2	2026-11-24	13:00:00	14:00:00	4	0	OPEN
1476	3	2026-11-24	13:00:00	14:00:00	4	0	OPEN
1477	1	2026-11-24	14:00:00	15:00:00	4	0	OPEN
1478	2	2026-11-24	14:00:00	15:00:00	4	0	OPEN
1479	3	2026-11-24	14:00:00	15:00:00	4	0	OPEN
1480	1	2026-11-24	15:00:00	16:00:00	4	0	OPEN
1481	2	2026-11-24	15:00:00	16:00:00	4	0	OPEN
1482	3	2026-11-24	15:00:00	16:00:00	4	0	OPEN
1483	1	2026-11-24	16:00:00	17:00:00	4	0	OPEN
1484	2	2026-11-24	16:00:00	17:00:00	4	0	OPEN
1485	3	2026-11-24	16:00:00	17:00:00	4	0	OPEN
1486	1	2026-11-25	08:00:00	09:00:00	4	0	OPEN
1487	2	2026-11-25	08:00:00	09:00:00	4	0	OPEN
1488	3	2026-11-25	08:00:00	09:00:00	4	0	OPEN
1489	1	2026-11-25	09:00:00	10:00:00	4	0	OPEN
1490	2	2026-11-25	09:00:00	10:00:00	4	0	OPEN
1491	3	2026-11-25	09:00:00	10:00:00	4	0	OPEN
1492	1	2026-11-25	10:00:00	11:00:00	4	0	OPEN
1493	2	2026-11-25	10:00:00	11:00:00	4	0	OPEN
1494	3	2026-11-25	10:00:00	11:00:00	4	0	OPEN
1495	1	2026-11-25	11:00:00	12:00:00	4	0	OPEN
1496	2	2026-11-25	11:00:00	12:00:00	4	0	OPEN
1497	3	2026-11-25	11:00:00	12:00:00	4	0	OPEN
1498	1	2026-11-25	12:00:00	13:00:00	4	0	OPEN
1499	2	2026-11-25	12:00:00	13:00:00	4	0	OPEN
1500	3	2026-11-25	12:00:00	13:00:00	4	0	OPEN
1501	1	2026-11-25	13:00:00	14:00:00	4	0	OPEN
1502	2	2026-11-25	13:00:00	14:00:00	4	0	OPEN
1503	3	2026-11-25	13:00:00	14:00:00	4	0	OPEN
1504	1	2026-11-25	14:00:00	15:00:00	4	0	OPEN
1505	2	2026-11-25	14:00:00	15:00:00	4	0	OPEN
1506	3	2026-11-25	14:00:00	15:00:00	4	0	OPEN
1507	1	2026-11-25	15:00:00	16:00:00	4	0	OPEN
1508	2	2026-11-25	15:00:00	16:00:00	4	0	OPEN
1509	3	2026-11-25	15:00:00	16:00:00	4	0	OPEN
1510	1	2026-11-25	16:00:00	17:00:00	4	0	OPEN
1511	2	2026-11-25	16:00:00	17:00:00	4	0	OPEN
1512	3	2026-11-25	16:00:00	17:00:00	4	0	OPEN
1513	1	2026-11-26	08:00:00	09:00:00	4	0	OPEN
1514	2	2026-11-26	08:00:00	09:00:00	4	0	OPEN
1515	3	2026-11-26	08:00:00	09:00:00	4	0	OPEN
1516	1	2026-11-26	09:00:00	10:00:00	4	0	OPEN
1517	2	2026-11-26	09:00:00	10:00:00	4	0	OPEN
1518	3	2026-11-26	09:00:00	10:00:00	4	0	OPEN
1519	1	2026-11-26	10:00:00	11:00:00	4	0	OPEN
1520	2	2026-11-26	10:00:00	11:00:00	4	0	OPEN
1521	3	2026-11-26	10:00:00	11:00:00	4	0	OPEN
1522	1	2026-11-26	11:00:00	12:00:00	4	0	OPEN
1523	2	2026-11-26	11:00:00	12:00:00	4	0	OPEN
1524	3	2026-11-26	11:00:00	12:00:00	4	0	OPEN
1525	1	2026-11-26	12:00:00	13:00:00	4	0	OPEN
1526	2	2026-11-26	12:00:00	13:00:00	4	0	OPEN
1527	3	2026-11-26	12:00:00	13:00:00	4	0	OPEN
1528	1	2026-11-26	13:00:00	14:00:00	4	0	OPEN
1529	2	2026-11-26	13:00:00	14:00:00	4	0	OPEN
1530	3	2026-11-26	13:00:00	14:00:00	4	0	OPEN
1531	1	2026-11-26	14:00:00	15:00:00	4	0	OPEN
1532	2	2026-11-26	14:00:00	15:00:00	4	0	OPEN
1533	3	2026-11-26	14:00:00	15:00:00	4	0	OPEN
1534	1	2026-11-26	15:00:00	16:00:00	4	0	OPEN
1535	2	2026-11-26	15:00:00	16:00:00	4	0	OPEN
1536	3	2026-11-26	15:00:00	16:00:00	4	0	OPEN
1537	1	2026-11-26	16:00:00	17:00:00	4	0	OPEN
1538	2	2026-11-26	16:00:00	17:00:00	4	0	OPEN
1539	3	2026-11-26	16:00:00	17:00:00	4	0	OPEN
1540	1	2026-11-27	08:00:00	09:00:00	4	0	OPEN
1541	2	2026-11-27	08:00:00	09:00:00	4	0	OPEN
1542	3	2026-11-27	08:00:00	09:00:00	4	0	OPEN
1543	1	2026-11-27	09:00:00	10:00:00	4	0	OPEN
1544	2	2026-11-27	09:00:00	10:00:00	4	0	OPEN
1545	3	2026-11-27	09:00:00	10:00:00	4	0	OPEN
1546	1	2026-11-27	10:00:00	11:00:00	4	0	OPEN
1547	2	2026-11-27	10:00:00	11:00:00	4	0	OPEN
1548	3	2026-11-27	10:00:00	11:00:00	4	0	OPEN
1549	1	2026-11-27	11:00:00	12:00:00	4	0	OPEN
1550	2	2026-11-27	11:00:00	12:00:00	4	0	OPEN
1551	3	2026-11-27	11:00:00	12:00:00	4	0	OPEN
1552	1	2026-11-27	12:00:00	13:00:00	4	0	OPEN
1553	2	2026-11-27	12:00:00	13:00:00	4	0	OPEN
1554	3	2026-11-27	12:00:00	13:00:00	4	0	OPEN
1555	1	2026-11-27	13:00:00	14:00:00	4	0	OPEN
1556	2	2026-11-27	13:00:00	14:00:00	4	0	OPEN
1557	3	2026-11-27	13:00:00	14:00:00	4	0	OPEN
1558	1	2026-11-27	14:00:00	15:00:00	4	0	OPEN
1559	2	2026-11-27	14:00:00	15:00:00	4	0	OPEN
1560	3	2026-11-27	14:00:00	15:00:00	4	0	OPEN
1561	1	2026-11-27	15:00:00	16:00:00	4	0	OPEN
1562	2	2026-11-27	15:00:00	16:00:00	4	0	OPEN
1563	3	2026-11-27	15:00:00	16:00:00	4	0	OPEN
1564	1	2026-11-27	16:00:00	17:00:00	4	0	OPEN
1565	2	2026-11-27	16:00:00	17:00:00	4	0	OPEN
1566	3	2026-11-27	16:00:00	17:00:00	4	0	OPEN
1567	1	2026-11-28	08:00:00	09:00:00	4	0	OPEN
1568	2	2026-11-28	08:00:00	09:00:00	4	0	OPEN
1569	3	2026-11-28	08:00:00	09:00:00	4	0	OPEN
1570	1	2026-11-28	09:00:00	10:00:00	4	0	OPEN
1571	2	2026-11-28	09:00:00	10:00:00	4	0	OPEN
1572	3	2026-11-28	09:00:00	10:00:00	4	0	OPEN
1573	1	2026-11-28	10:00:00	11:00:00	4	0	OPEN
1574	2	2026-11-28	10:00:00	11:00:00	4	0	OPEN
1575	3	2026-11-28	10:00:00	11:00:00	4	0	OPEN
1576	1	2026-11-28	11:00:00	12:00:00	4	0	OPEN
1577	2	2026-11-28	11:00:00	12:00:00	4	0	OPEN
1578	3	2026-11-28	11:00:00	12:00:00	4	0	OPEN
1579	1	2026-11-28	12:00:00	13:00:00	4	0	OPEN
1580	2	2026-11-28	12:00:00	13:00:00	4	0	OPEN
1581	3	2026-11-28	12:00:00	13:00:00	4	0	OPEN
1582	1	2026-11-28	13:00:00	14:00:00	4	0	OPEN
1583	2	2026-11-28	13:00:00	14:00:00	4	0	OPEN
1584	3	2026-11-28	13:00:00	14:00:00	4	0	OPEN
1585	1	2026-11-28	14:00:00	15:00:00	4	0	OPEN
1586	2	2026-11-28	14:00:00	15:00:00	4	0	OPEN
1587	3	2026-11-28	14:00:00	15:00:00	4	0	OPEN
1588	1	2026-11-28	15:00:00	16:00:00	4	0	OPEN
1589	2	2026-11-28	15:00:00	16:00:00	4	0	OPEN
1590	3	2026-11-28	15:00:00	16:00:00	4	0	OPEN
1591	1	2026-11-28	16:00:00	17:00:00	4	0	OPEN
1592	2	2026-11-28	16:00:00	17:00:00	4	0	OPEN
1593	3	2026-11-28	16:00:00	17:00:00	4	0	OPEN
1594	1	2026-11-29	08:00:00	09:00:00	4	0	OPEN
1595	2	2026-11-29	08:00:00	09:00:00	4	0	OPEN
1596	3	2026-11-29	08:00:00	09:00:00	4	0	OPEN
1597	1	2026-11-29	09:00:00	10:00:00	4	0	OPEN
1598	2	2026-11-29	09:00:00	10:00:00	4	0	OPEN
1599	3	2026-11-29	09:00:00	10:00:00	4	0	OPEN
1600	1	2026-11-29	10:00:00	11:00:00	4	0	OPEN
1601	2	2026-11-29	10:00:00	11:00:00	4	0	OPEN
1602	3	2026-11-29	10:00:00	11:00:00	4	0	OPEN
1603	1	2026-11-29	11:00:00	12:00:00	4	0	OPEN
1604	2	2026-11-29	11:00:00	12:00:00	4	0	OPEN
1605	3	2026-11-29	11:00:00	12:00:00	4	0	OPEN
1606	1	2026-11-29	12:00:00	13:00:00	4	0	OPEN
1607	2	2026-11-29	12:00:00	13:00:00	4	0	OPEN
1608	3	2026-11-29	12:00:00	13:00:00	4	0	OPEN
1609	1	2026-11-29	13:00:00	14:00:00	4	0	OPEN
1610	2	2026-11-29	13:00:00	14:00:00	4	0	OPEN
1611	3	2026-11-29	13:00:00	14:00:00	4	0	OPEN
1612	1	2026-11-29	14:00:00	15:00:00	4	0	OPEN
1613	2	2026-11-29	14:00:00	15:00:00	4	0	OPEN
1614	3	2026-11-29	14:00:00	15:00:00	4	0	OPEN
1615	1	2026-11-29	15:00:00	16:00:00	4	0	OPEN
1616	2	2026-11-29	15:00:00	16:00:00	4	0	OPEN
1617	3	2026-11-29	15:00:00	16:00:00	4	0	OPEN
1618	1	2026-11-29	16:00:00	17:00:00	4	0	OPEN
1619	2	2026-11-29	16:00:00	17:00:00	4	0	OPEN
1620	3	2026-11-29	16:00:00	17:00:00	4	0	OPEN
1621	1	2026-11-30	08:00:00	09:00:00	4	0	OPEN
1622	2	2026-11-30	08:00:00	09:00:00	4	0	OPEN
1623	3	2026-11-30	08:00:00	09:00:00	4	0	OPEN
1624	1	2026-11-30	09:00:00	10:00:00	4	0	OPEN
1625	2	2026-11-30	09:00:00	10:00:00	4	0	OPEN
1626	3	2026-11-30	09:00:00	10:00:00	4	0	OPEN
1627	1	2026-11-30	10:00:00	11:00:00	4	0	OPEN
1628	2	2026-11-30	10:00:00	11:00:00	4	0	OPEN
1629	3	2026-11-30	10:00:00	11:00:00	4	0	OPEN
1630	1	2026-11-30	11:00:00	12:00:00	4	0	OPEN
1631	2	2026-11-30	11:00:00	12:00:00	4	0	OPEN
1632	3	2026-11-30	11:00:00	12:00:00	4	0	OPEN
1633	1	2026-11-30	12:00:00	13:00:00	4	0	OPEN
1634	2	2026-11-30	12:00:00	13:00:00	4	0	OPEN
1635	3	2026-11-30	12:00:00	13:00:00	4	0	OPEN
1636	1	2026-11-30	13:00:00	14:00:00	4	0	OPEN
1637	2	2026-11-30	13:00:00	14:00:00	4	0	OPEN
1638	3	2026-11-30	13:00:00	14:00:00	4	0	OPEN
1639	1	2026-11-30	14:00:00	15:00:00	4	0	OPEN
1640	2	2026-11-30	14:00:00	15:00:00	4	0	OPEN
1641	3	2026-11-30	14:00:00	15:00:00	4	0	OPEN
1642	1	2026-11-30	15:00:00	16:00:00	4	0	OPEN
1643	2	2026-11-30	15:00:00	16:00:00	4	0	OPEN
1644	3	2026-11-30	15:00:00	16:00:00	4	0	OPEN
1645	1	2026-11-30	16:00:00	17:00:00	4	0	OPEN
1646	2	2026-11-30	16:00:00	17:00:00	4	0	OPEN
1647	3	2026-11-30	16:00:00	17:00:00	4	0	OPEN
298	1	2026-10-12	08:00:00	09:00:00	4	1	OPEN
383	2	2026-10-15	09:00:00	10:00:00	4	1	OPEN
517	1	2026-10-20	09:00:00	10:00:00	4	1	OPEN
651	3	2026-10-25	08:00:00	09:00:00	4	1	OPEN
946	1	2026-11-05	08:00:00	09:00:00	4	1	OPEN
979	1	2026-11-06	10:00:00	11:00:00	4	1	OPEN
994	1	2026-11-06	15:00:00	16:00:00	4	1	OPEN
1000	1	2026-11-07	08:00:00	09:00:00	4	1	OPEN
1003	1	2026-11-07	09:00:00	10:00:00	4	1	OPEN
1006	1	2026-11-07	10:00:00	11:00:00	4	1	OPEN
1007	2	2026-11-07	10:00:00	11:00:00	4	1	OPEN
1015	1	2026-11-07	13:00:00	14:00:00	4	1	OPEN
1018	1	2026-11-07	14:00:00	15:00:00	4	1	OPEN
1027	1	2026-11-08	08:00:00	09:00:00	4	2	OPEN
1030	1	2026-11-08	09:00:00	10:00:00	4	1	OPEN
1032	3	2026-11-08	09:00:00	10:00:00	4	1	OPEN
1033	1	2026-11-08	10:00:00	11:00:00	4	2	OPEN
1036	1	2026-11-08	11:00:00	12:00:00	4	2	OPEN
1042	1	2026-11-08	13:00:00	14:00:00	4	1	OPEN
1046	2	2026-11-08	14:00:00	15:00:00	4	1	OPEN
1048	1	2026-11-08	15:00:00	16:00:00	4	1	OPEN
1051	1	2026-11-08	16:00:00	17:00:00	4	1	OPEN
1054	1	2026-11-09	08:00:00	09:00:00	4	1	OPEN
1057	1	2026-11-09	09:00:00	10:00:00	4	2	OPEN
1060	1	2026-11-09	10:00:00	11:00:00	4	1	OPEN
1072	1	2026-11-09	14:00:00	15:00:00	4	1	OPEN
1081	1	2026-11-10	08:00:00	09:00:00	4	1	OPEN
1111	1	2026-11-11	09:00:00	10:00:00	4	1	OPEN
1142	2	2026-11-12	10:00:00	11:00:00	4	1	OPEN
1153	1	2026-11-12	14:00:00	15:00:00	4	1	OPEN
1167	3	2026-11-13	09:00:00	10:00:00	4	1	OPEN
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (user_id, role_id, email, phone, password_hash, full_name, status, failed_login_count, locked_until, last_login_at, created_at, updated_at) FROM stdin;
1	6	admin@autocare.vn	0900000001	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Nguyễn Trường Giang	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
2	5	manager.cg@autocare.vn	0910000001	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Phạm Minh Quân	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
3	2	reception1.cg@autocare.vn	0910100001	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Lê Thu Hà	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
4	2	reception2.cg@autocare.vn	0910200001	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Nguyễn Hoàng Nam	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
5	4	cashier.cg@autocare.vn	0910300001	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Trần Bảo Ngọc	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
6	3	mechanic1.cg@autocare.vn	0910400001	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Đỗ Văn Hùng	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
7	3	mechanic2.cg@autocare.vn	0910500001	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Vũ Đức Thắng	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
8	3	mechanic3.cg@autocare.vn	0910600001	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Bùi Quốc Khánh	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
9	5	manager.hd@autocare.vn	0920000002	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Hoàng Thị Lan	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
10	2	reception1.hd@autocare.vn	0920100002	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Ngô Quang Huy	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
11	2	reception2.hd@autocare.vn	0920200002	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Đặng Mai Anh	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
12	4	cashier.hd@autocare.vn	0920300002	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Phan Thanh Tùng	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
13	3	mechanic1.hd@autocare.vn	0920400002	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Trịnh Văn Long	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
14	3	mechanic2.hd@autocare.vn	0920500002	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Lý Minh Tuấn	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
15	3	mechanic3.hd@autocare.vn	0920600002	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Mai Xuân Phúc	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
16	5	manager.q7@autocare.vn	0930000003	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Võ Thị Hồng	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
17	2	reception1.q7@autocare.vn	0930100003	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Huỳnh Gia Bảo	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
18	2	reception2.q7@autocare.vn	0930200003	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Châu Ngọc Trâm	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
19	4	cashier.q7@autocare.vn	0930300003	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Dương Minh Khoa	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
20	3	mechanic1.q7@autocare.vn	0930400003	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Tạ Văn Lộc	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
21	3	mechanic2.q7@autocare.vn	0930500003	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	La Hoàng Sơn	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
22	3	mechanic3.q7@autocare.vn	0930600003	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Kiều Anh Dũng	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-01-06 08:00:00+07	2026-01-06 08:00:00+07
23	1	customer1@gmail.com	0912000001	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Nguyễn Văn An	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-02-01 08:00:00+07	2026-02-01 08:00:00+07
24	1	customer2@gmail.com	0912000002	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Trần Thị Bình	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-02-01 08:00:00+07	2026-02-01 08:00:00+07
25	1	customer3@gmail.com	0912000003	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Lê Hoàng Cường	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-02-01 08:00:00+07	2026-02-01 08:00:00+07
26	1	customer4@gmail.com	0912000004	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Phạm Thu Dung	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-02-01 08:00:00+07	2026-02-01 08:00:00+07
27	1	customer5@gmail.com	0912000005	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Hoàng Minh Đức	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-02-01 08:00:00+07	2026-02-01 08:00:00+07
28	1	customer6@gmail.com	0912000006	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Vũ Thị Giang	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-02-01 08:00:00+07	2026-02-01 08:00:00+07
29	1	customer7@gmail.com	0912000007	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Đặng Quốc Huy	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-02-01 08:00:00+07	2026-02-01 08:00:00+07
30	1	customer8@gmail.com	0912000008	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Bùi Thanh Hương	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-02-01 08:00:00+07	2026-02-01 08:00:00+07
31	1	customer9@gmail.com	0912000009	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Ngô Đức Khải	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-02-01 08:00:00+07	2026-02-01 08:00:00+07
32	1	customer10@gmail.com	0912000010	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Đỗ Thị Lan	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-02-01 08:00:00+07	2026-02-01 08:00:00+07
33	1	customer11@gmail.com	0912000011	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Phan Văn Minh	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-02-01 08:00:00+07	2026-02-01 08:00:00+07
34	1	customer12@gmail.com	0912000012	$2a$10$xtHB3STb9XwUrZZAfXRN.uTnUIfGXvyLj0tvOT/PwwzzoC.SnIJ76	Trịnh Ngọc Oanh	ACTIVE	0	\N	2026-11-07 17:30:00+07	2026-02-01 08:00:00+07	2026-02-01 08:00:00+07
\.


--
-- Data for Name: vehicle_handovers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vehicle_handovers (handover_id, appointment_id, invoice_id, handed_by, odometer_out, customer_confirmed, note, handed_at) FROM stdin;
1	1	1	3	45322	t	Khách đã kiểm tra và nhận xe	2026-10-12 15:30:00+07
2	2	2	3	21922	t	Khách đã kiểm tra và nhận xe	2026-10-20 16:30:00+07
3	19	3	10	95122	t	Khách đã kiểm tra và nhận xe	2026-10-15 16:30:00+07
4	23	4	17	18322	t	Khách đã kiểm tra và nhận xe	2026-10-25 15:30:00+07
\.


--
-- Data for Name: vehicle_receptions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vehicle_receptions (reception_id, appointment_id, received_by, odometer_reading, vehicle_condition, checked_in_at) FROM stdin;
1	1	3	45320	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-10-12 08:00:00+07
2	2	3	21920	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-10-20 09:00:00+07
3	3	3	38820	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-05 08:00:00+07
4	4	3	72220	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-06 10:00:00+07
5	5	3	40220	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-07 08:00:00+07
6	6	3	88520	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-07 09:00:00+07
7	7	3	26620	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-07 13:00:00+07
8	8	3	33420	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-08 08:00:00+07
9	9	3	12520	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-08 09:00:00+07
10	10	3	31020	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-08 10:00:00+07
11	11	3	30620	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-08 10:00:00+07
12	12	3	15920	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-08 11:00:00+07
13	13	3	22120	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-08 13:00:00+07
14	19	10	95120	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-10-15 09:00:00+07
15	20	10	9920	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-07 10:00:00+07
16	21	10	95120	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-08 14:00:00+07
17	23	17	18320	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-10-25 08:00:00+07
18	24	17	15920	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-08 09:00:00+07
19	29	3	120420	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-09 08:00:00+07
20	30	3	35620	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-09 09:00:00+07
21	31	3	61120	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-08 15:00:00+07
22	32	3	21920	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-08 16:00:00+07
23	33	3	58120	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-08 08:00:00+07
24	34	3	31120	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-08 11:00:00+07
25	35	3	76120	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-07 14:00:00+07
26	36	3	12120	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-06 15:00:00+07
27	37	3	20120	Xe trầy nhẹ cản sau, nhiên liệu 1/2 bình, không có đồ giá trị	2026-11-07 10:00:00+07
\.


--
-- Data for Name: vehicles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vehicles (vehicle_id, customer_id, license_plate, vehicle_type, brand, model, manufacture_year, vin, color, current_odometer, status, created_at, updated_at) FROM stdin;
1	1	30A-123.45	CAR	Toyota	Vios 1.5G	2020	\N	Đen	45200	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
2	2	30G-456.78	CAR	Honda	City RS	2022	\N	Bạc	21800	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
3	1	29B1-234.56	MOTORCYCLE	Honda	Wave Alpha	2019	\N	Đỏ	30500	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
4	3	30E-987.65	CAR	Mazda	Mazda3 1.5	2021	\N	Xanh	38700	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
5	4	30F-111.22	CAR	Kia	Morning	2018	\N	Trắng	72100	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
6	5	30H-222.33	CAR	Hyundai	Accent 1.4AT	2021	\N	Đen	40100	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
7	6	29C-345.67	CAR	Ford	Ranger XLS	2020	\N	Bạc	88400	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
8	6	29C-345.68	CAR	Ford	Transit	2019	\N	Đỏ	120300	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
9	7	29D-456.12	CAR	Toyota	Innova 2.0E	2019	\N	Xanh	95000	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
10	8	30K-567.89	CAR	Mitsubishi	Xpander AT	2022	\N	Trắng	26500	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
11	9	30L-678.90	CAR	VinFast	Fadil	2021	\N	Đen	33300	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
12	10	51G-789.01	CAR	Toyota	Corolla Cross	2023	\N	Bạc	15800	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
13	10	59X1-890.12	MOTORCYCLE	Yamaha	Exciter 155	2022	\N	Đỏ	18200	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
14	11	30M-901.23	CAR	Toyota	Innova Cross	2023	\N	Xanh	12400	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
15	12	30N-012.34	CAR	Honda	CR-V L	2022	\N	Trắng	30900	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
16	12	29E1-135.79	MOTORCYCLE	Honda	Air Blade	2021	\N	Đen	22000	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
17	8	29F-246.80	CAR	Kia	Seltos	2023	\N	Bạc	9800	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
18	3	29G-112.23	CAR	Suzuki	XL7	2022	\N	Đỏ	41000	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
19	2	30G-789.12	CAR	Toyota	Camry 2.5Q	2021	\N	Xanh	52000	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
20	5	30H-345.21	CAR	Honda	Civic RS	2022	\N	Trắng	28000	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
21	9	29A-654.32	CAR	Mazda	CX-5 2.0	2020	\N	Đen	61000	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
22	11	29H1-777.88	MOTORCYCLE	Honda	SH 150i	2023	\N	Bạc	8000	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
23	4	30E-246.13	CAR	Hyundai	Tucson 2.0	2022	\N	Đỏ	35500	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
24	6	30K-135.79	CAR	Toyota	Fortuner 2.7	2021	\N	Xanh	58000	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
25	12	30L-864.20	CAR	Kia	Carnival	2022	\N	Trắng	31000	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
26	3	30M-555.66	CAR	Ford	Everest	2020	\N	Đen	76000	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
27	8	30A-246.80	CAR	Honda	HR-V	2023	\N	Bạc	12000	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
28	11	30F-777.12	CAR	Mazda	CX-3	2022	\N	Đỏ	20000	ACTIVE	2026-02-03 08:00:00+07	2026-02-03 08:00:00+07
\.


--
-- Data for Name: warehouses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.warehouses (warehouse_id, branch_id, warehouse_name, location, status) FROM stdin;
1	1	Kho phụ tùng chính	Tầng 1, khu B	ACTIVE
2	2	Kho phụ tùng chính	Tầng 1, khu B	ACTIVE
3	3	Kho phụ tùng chính	Tầng 1, khu B	ACTIVE
\.


--
-- Data for Name: warranties; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.warranties (warranty_id, warranty_code, policy_id, vehicle_id, repair_order_id, quotation_item_id, start_date, end_date, start_odometer, max_odometer, status, created_at) FROM stdin;
1	WR-261012-0001	2	1	1	1	2026-10-12	2027-01-12	45322	50322	ACTIVE	2026-10-12 15:30:00+07
2	WR-261012-0002	1	1	1	2	2026-10-12	2027-04-12	45322	55322	ACTIVE	2026-10-12 15:30:00+07
3	WR-261012-0003	3	1	1	5	2026-10-12	2027-04-12	45322	55322	ACTIVE	2026-10-12 15:30:00+07
4	WR-261020-0001	4	2	2	10	2026-10-20	2027-10-20	21922	\N	ACTIVE	2026-10-20 16:30:00+07
\.


--
-- Data for Name: warranty_policies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.warranty_policies (policy_id, policy_code, policy_name, applies_to, service_id, part_id, duration_months, max_odometer_km, terms, status, created_at) FROM stdin;
1	WP-BRAKE-6M	Bảo hành dịch vụ phanh 6 tháng	SERVICE	2	\N	6	10000	Bảo hành tay nghề thay má phanh trong 6 tháng hoặc 10.000 km.	ACTIVE	2026-01-05 08:00:00+07
2	WP-MAINT-3M	Bảo hành bảo dưỡng 3 tháng	SERVICE	3	\N	3	5000	Bảo hành lỗi do quá trình bảo dưỡng.	ACTIVE	2026-01-05 08:00:00+07
3	WP-PAD-6M	Bảo hành má phanh 6 tháng	PART	\N	5	6	10000	Bảo hành lỗi vật liệu má phanh.	ACTIVE	2026-01-05 08:00:00+07
4	WP-BATT-12M	Bảo hành ắc quy 12 tháng	PART	\N	8	12	\N	Bảo hành 1 đổi 1 khi ắc quy lỗi nhà sản xuất.	ACTIVE	2026-01-05 08:00:00+07
\.


--
-- Data for Name: warranty_repairs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.warranty_repairs (warranty_repair_id, request_id, repair_order_id, internal_cost, customer_charge, repair_date, created_at) FROM stdin;
\.


--
-- Data for Name: warranty_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.warranty_requests (request_id, request_code, warranty_id, customer_id, branch_id, issue_description, current_odometer, status, is_eligible, assessed_by, assessment_note, approved_by, decided_at, created_at) FROM stdin;
1	WQ-261107-0001	4	2	1	Ắc quy yếu, sáng ra khó đề nổ	22700	SUBMITTED	\N	\N	\N	\N	\N	2026-11-07 08:30:00+07
2	WQ-261106-0001	2	1	1	Phanh kêu rít khi đạp nhẹ	46700	ASSESSED	t	8	Má phanh lắp lệch, thuộc phạm vi bảo hành tay nghề	\N	\N	2026-11-06 14:00:00+07
\.


--
-- Name: appointments_appointment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.appointments_appointment_id_seq', 37, true);


--
-- Name: audit_logs_audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.audit_logs_audit_id_seq', 61, true);


--
-- Name: billing_information_billing_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.billing_information_billing_id_seq', 6, true);


--
-- Name: branches_branch_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.branches_branch_id_seq', 3, true);


--
-- Name: customers_customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customers_customer_id_seq', 12, true);


--
-- Name: e_invoices_e_invoice_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.e_invoices_e_invoice_id_seq', 6, true);


--
-- Name: einvoice_configs_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.einvoice_configs_config_id_seq', 1, true);


--
-- Name: inspection_items_inspection_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inspection_items_inspection_item_id_seq', 90, true);


--
-- Name: inspections_inspection_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inspections_inspection_id_seq', 26, true);


--
-- Name: inventories_inventory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inventories_inventory_id_seq', 60, true);


--
-- Name: inventory_receipt_items_receipt_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inventory_receipt_items_receipt_item_id_seq', 63, true);


--
-- Name: inventory_receipts_receipt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inventory_receipts_receipt_id_seq', 4, true);


--
-- Name: inventory_transactions_transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inventory_transactions_transaction_id_seq', 132, true);


--
-- Name: invoice_lines_line_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.invoice_lines_line_id_seq', 30, true);


--
-- Name: invoices_invoice_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.invoices_invoice_id_seq', 9, true);


--
-- Name: notifications_notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.notifications_notification_id_seq', 58, true);


--
-- Name: part_request_items_request_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.part_request_items_request_item_id_seq', 28, true);


--
-- Name: part_requests_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.part_requests_request_id_seq', 14, true);


--
-- Name: part_reservations_reservation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.part_reservations_reservation_id_seq', 44, true);


--
-- Name: parts_part_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.parts_part_id_seq', 20, true);


--
-- Name: payments_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payments_payment_id_seq', 6, true);


--
-- Name: quotation_items_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.quotation_items_item_id_seq', 85, true);


--
-- Name: quotations_quotation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.quotations_quotation_id_seq', 23, true);


--
-- Name: repair_notes_note_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.repair_notes_note_id_seq', 16, true);


--
-- Name: repair_order_types_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.repair_order_types_type_id_seq', 4, true);


--
-- Name: repair_orders_repair_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.repair_orders_repair_order_id_seq', 21, true);


--
-- Name: repair_task_parts_task_part_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.repair_task_parts_task_part_id_seq', 25, true);


--
-- Name: repair_tasks_task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.repair_tasks_task_id_seq', 30, true);


--
-- Name: roles_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roles_role_id_seq', 6, true);


--
-- Name: service_ratings_rating_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.service_ratings_rating_id_seq', 4, true);


--
-- Name: services_service_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.services_service_id_seq', 10, true);


--
-- Name: staff_staff_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.staff_staff_id_seq', 22, true);


--
-- Name: tax_rules_tax_rule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tax_rules_tax_rule_id_seq', 6, true);


--
-- Name: time_slots_slot_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.time_slots_slot_id_seq', 1647, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_user_id_seq', 34, true);


--
-- Name: vehicle_handovers_handover_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vehicle_handovers_handover_id_seq', 4, true);


--
-- Name: vehicle_receptions_reception_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vehicle_receptions_reception_id_seq', 27, true);


--
-- Name: vehicles_vehicle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vehicles_vehicle_id_seq', 28, true);


--
-- Name: warehouses_warehouse_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.warehouses_warehouse_id_seq', 3, true);


--
-- Name: warranties_warranty_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.warranties_warranty_id_seq', 4, true);


--
-- Name: warranty_policies_policy_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.warranty_policies_policy_id_seq', 4, true);


--
-- Name: warranty_repairs_warranty_repair_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.warranty_repairs_warranty_repair_id_seq', 1, false);


--
-- Name: warranty_requests_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.warranty_requests_request_id_seq', 2, true);


--
-- Name: appointments appointments_appointment_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_appointment_code_key UNIQUE (appointment_code);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (appointment_id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (audit_id);


--
-- Name: billing_information billing_information_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_information
    ADD CONSTRAINT billing_information_pkey PRIMARY KEY (billing_id);


--
-- Name: branches branches_branch_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_branch_code_key UNIQUE (branch_code);


--
-- Name: branches branches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (branch_id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: customers customers_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_user_id_key UNIQUE (user_id);


--
-- Name: e_invoices e_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.e_invoices
    ADD CONSTRAINT e_invoices_pkey PRIMARY KEY (e_invoice_id);


--
-- Name: einvoice_configs einvoice_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.einvoice_configs
    ADD CONSTRAINT einvoice_configs_pkey PRIMARY KEY (config_id);


--
-- Name: inspection_items inspection_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspection_items
    ADD CONSTRAINT inspection_items_pkey PRIMARY KEY (inspection_item_id);


--
-- Name: inspections inspections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspections
    ADD CONSTRAINT inspections_pkey PRIMARY KEY (inspection_id);


--
-- Name: inspections inspections_reception_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspections
    ADD CONSTRAINT inspections_reception_id_key UNIQUE (reception_id);


--
-- Name: inventories inventories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventories
    ADD CONSTRAINT inventories_pkey PRIMARY KEY (inventory_id);


--
-- Name: inventory_receipt_items inventory_receipt_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_receipt_items
    ADD CONSTRAINT inventory_receipt_items_pkey PRIMARY KEY (receipt_item_id);


--
-- Name: inventory_receipts inventory_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_receipts
    ADD CONSTRAINT inventory_receipts_pkey PRIMARY KEY (receipt_id);


--
-- Name: inventory_receipts inventory_receipts_receipt_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_receipts
    ADD CONSTRAINT inventory_receipts_receipt_code_key UNIQUE (receipt_code);


--
-- Name: inventory_transactions inventory_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_pkey PRIMARY KEY (transaction_id);


--
-- Name: invoice_lines invoice_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_lines
    ADD CONSTRAINT invoice_lines_pkey PRIMARY KEY (line_id);


--
-- Name: invoices invoices_invoice_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_code_key UNIQUE (invoice_code);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (invoice_id);


--
-- Name: invoices invoices_repair_order_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_repair_order_id_key UNIQUE (repair_order_id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (notification_id);


--
-- Name: part_request_items part_request_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_request_items
    ADD CONSTRAINT part_request_items_pkey PRIMARY KEY (request_item_id);


--
-- Name: part_requests part_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_requests
    ADD CONSTRAINT part_requests_pkey PRIMARY KEY (request_id);


--
-- Name: part_requests part_requests_request_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_requests
    ADD CONSTRAINT part_requests_request_code_key UNIQUE (request_code);


--
-- Name: part_reservations part_reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_reservations
    ADD CONSTRAINT part_reservations_pkey PRIMARY KEY (reservation_id);


--
-- Name: parts parts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parts
    ADD CONSTRAINT parts_pkey PRIMARY KEY (part_id);


--
-- Name: parts parts_sku_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parts
    ADD CONSTRAINT parts_sku_key UNIQUE (sku);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- Name: appointment_services pk_appointment_services; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_services
    ADD CONSTRAINT pk_appointment_services PRIMARY KEY (appointment_id, service_id);


--
-- Name: branch_services pk_branch_services; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_services
    ADD CONSTRAINT pk_branch_services PRIMARY KEY (branch_id, service_id);


--
-- Name: quotation_items quotation_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotation_items
    ADD CONSTRAINT quotation_items_pkey PRIMARY KEY (item_id);


--
-- Name: quotations quotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_pkey PRIMARY KEY (quotation_id);


--
-- Name: quotations quotations_quotation_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_quotation_code_key UNIQUE (quotation_code);


--
-- Name: repair_notes repair_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_notes
    ADD CONSTRAINT repair_notes_pkey PRIMARY KEY (note_id);


--
-- Name: repair_order_types repair_order_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_order_types
    ADD CONSTRAINT repair_order_types_pkey PRIMARY KEY (type_id);


--
-- Name: repair_order_types repair_order_types_type_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_order_types
    ADD CONSTRAINT repair_order_types_type_code_key UNIQUE (type_code);


--
-- Name: repair_orders repair_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_orders
    ADD CONSTRAINT repair_orders_pkey PRIMARY KEY (repair_order_id);


--
-- Name: repair_orders repair_orders_quotation_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_orders
    ADD CONSTRAINT repair_orders_quotation_id_key UNIQUE (quotation_id);


--
-- Name: repair_orders repair_orders_ro_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_orders
    ADD CONSTRAINT repair_orders_ro_code_key UNIQUE (ro_code);


--
-- Name: repair_task_parts repair_task_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_task_parts
    ADD CONSTRAINT repair_task_parts_pkey PRIMARY KEY (task_part_id);


--
-- Name: repair_tasks repair_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_tasks
    ADD CONSTRAINT repair_tasks_pkey PRIMARY KEY (task_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);


--
-- Name: roles roles_role_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_role_code_key UNIQUE (role_code);


--
-- Name: service_ratings service_ratings_appointment_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_ratings
    ADD CONSTRAINT service_ratings_appointment_id_key UNIQUE (appointment_id);


--
-- Name: service_ratings service_ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_ratings
    ADD CONSTRAINT service_ratings_pkey PRIMARY KEY (rating_id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (service_id);


--
-- Name: services services_service_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_service_code_key UNIQUE (service_code);


--
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (staff_id);


--
-- Name: staff staff_staff_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_staff_code_key UNIQUE (staff_code);


--
-- Name: staff staff_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_user_id_key UNIQUE (user_id);


--
-- Name: tax_rules tax_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_rules
    ADD CONSTRAINT tax_rules_pkey PRIMARY KEY (tax_rule_id);


--
-- Name: time_slots time_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_slots
    ADD CONSTRAINT time_slots_pkey PRIMARY KEY (slot_id);


--
-- Name: inventories uq_inventories_warehouse_id_part_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventories
    ADD CONSTRAINT uq_inventories_warehouse_id_part_id UNIQUE (warehouse_id, part_id);


--
-- Name: time_slots uq_time_slots_branch_id_slot_date_start_time; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_slots
    ADD CONSTRAINT uq_time_slots_branch_id_slot_date_start_time UNIQUE (branch_id, slot_date, start_time);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: vehicle_handovers vehicle_handovers_appointment_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_handovers
    ADD CONSTRAINT vehicle_handovers_appointment_id_key UNIQUE (appointment_id);


--
-- Name: vehicle_handovers vehicle_handovers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_handovers
    ADD CONSTRAINT vehicle_handovers_pkey PRIMARY KEY (handover_id);


--
-- Name: vehicle_receptions vehicle_receptions_appointment_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_receptions
    ADD CONSTRAINT vehicle_receptions_appointment_id_key UNIQUE (appointment_id);


--
-- Name: vehicle_receptions vehicle_receptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_receptions
    ADD CONSTRAINT vehicle_receptions_pkey PRIMARY KEY (reception_id);


--
-- Name: vehicles vehicles_license_plate_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_license_plate_key UNIQUE (license_plate);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (vehicle_id);


--
-- Name: vehicles vehicles_vin_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_vin_key UNIQUE (vin);


--
-- Name: warehouses warehouses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_pkey PRIMARY KEY (warehouse_id);


--
-- Name: warranties warranties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranties
    ADD CONSTRAINT warranties_pkey PRIMARY KEY (warranty_id);


--
-- Name: warranties warranties_warranty_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranties
    ADD CONSTRAINT warranties_warranty_code_key UNIQUE (warranty_code);


--
-- Name: warranty_policies warranty_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranty_policies
    ADD CONSTRAINT warranty_policies_pkey PRIMARY KEY (policy_id);


--
-- Name: warranty_policies warranty_policies_policy_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranty_policies
    ADD CONSTRAINT warranty_policies_policy_code_key UNIQUE (policy_code);


--
-- Name: warranty_repairs warranty_repairs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranty_repairs
    ADD CONSTRAINT warranty_repairs_pkey PRIMARY KEY (warranty_repair_id);


--
-- Name: warranty_repairs warranty_repairs_request_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranty_repairs
    ADD CONSTRAINT warranty_repairs_request_id_key UNIQUE (request_id);


--
-- Name: warranty_requests warranty_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranty_requests
    ADD CONSTRAINT warranty_requests_pkey PRIMARY KEY (request_id);


--
-- Name: warranty_requests warranty_requests_request_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranty_requests
    ADD CONSTRAINT warranty_requests_request_code_key UNIQUE (request_code);


--
-- Name: idx_appointments_branch_id_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointments_branch_id_status ON public.appointments USING btree (branch_id, status);


--
-- Name: idx_appointments_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointments_customer_id ON public.appointments USING btree (customer_id);


--
-- Name: idx_appointments_slot_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointments_slot_id ON public.appointments USING btree (slot_id);


--
-- Name: idx_audit_logs_entity_name_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_logs_entity_name_entity_id ON public.audit_logs USING btree (entity_name, entity_id);


--
-- Name: idx_billing_information_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_billing_information_customer_id ON public.billing_information USING btree (customer_id);


--
-- Name: idx_e_invoices_invoice_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_e_invoices_invoice_id ON public.e_invoices USING btree (invoice_id);


--
-- Name: idx_e_invoices_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_e_invoices_status ON public.e_invoices USING btree (status);


--
-- Name: idx_inspection_items_inspection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inspection_items_inspection_id ON public.inspection_items USING btree (inspection_id);


--
-- Name: idx_inspections_mechanic_id_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inspections_mechanic_id_status ON public.inspections USING btree (mechanic_id, status);


--
-- Name: idx_inventory_receipt_items_receipt_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inventory_receipt_items_receipt_id ON public.inventory_receipt_items USING btree (receipt_id);


--
-- Name: idx_inventory_transactions_inventory_id_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inventory_transactions_inventory_id_created_at ON public.inventory_transactions USING btree (inventory_id, created_at);


--
-- Name: idx_invoice_lines_invoice_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_invoice_lines_invoice_id ON public.invoice_lines USING btree (invoice_id);


--
-- Name: idx_invoices_payment_status_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_invoices_payment_status_created_at ON public.invoices USING btree (payment_status, created_at);


--
-- Name: idx_notifications_user_id_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_user_id_status ON public.notifications USING btree (user_id, status);


--
-- Name: idx_part_request_items_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_part_request_items_request_id ON public.part_request_items USING btree (request_id);


--
-- Name: idx_part_requests_repair_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_part_requests_repair_order_id ON public.part_requests USING btree (repair_order_id);


--
-- Name: idx_part_requests_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_part_requests_status ON public.part_requests USING btree (status);


--
-- Name: idx_part_reservations_repair_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_part_reservations_repair_order_id ON public.part_reservations USING btree (repair_order_id);


--
-- Name: idx_payments_invoice_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_invoice_id ON public.payments USING btree (invoice_id);


--
-- Name: idx_quotation_items_quotation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quotation_items_quotation_id ON public.quotation_items USING btree (quotation_id);


--
-- Name: idx_quotations_inspection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quotations_inspection_id ON public.quotations USING btree (inspection_id);


--
-- Name: idx_repair_notes_repair_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repair_notes_repair_order_id ON public.repair_notes USING btree (repair_order_id);


--
-- Name: idx_repair_orders_branch_id_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repair_orders_branch_id_status ON public.repair_orders USING btree (branch_id, status);


--
-- Name: idx_repair_task_parts_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repair_task_parts_task_id ON public.repair_task_parts USING btree (task_id);


--
-- Name: idx_repair_tasks_mechanic_id_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repair_tasks_mechanic_id_status ON public.repair_tasks USING btree (mechanic_id, status);


--
-- Name: idx_repair_tasks_repair_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repair_tasks_repair_order_id ON public.repair_tasks USING btree (repair_order_id);


--
-- Name: idx_staff_branch_id_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_staff_branch_id_position ON public.staff USING btree (branch_id, "position");


--
-- Name: idx_tax_rules_item_type_effective_from; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tax_rules_item_type_effective_from ON public.tax_rules USING btree (item_type, effective_from);


--
-- Name: idx_time_slots_branch_id_slot_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_time_slots_branch_id_slot_date ON public.time_slots USING btree (branch_id, slot_date);


--
-- Name: idx_users_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_role_id ON public.users USING btree (role_id);


--
-- Name: idx_vehicles_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vehicles_customer_id ON public.vehicles USING btree (customer_id);


--
-- Name: idx_warehouses_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_warehouses_branch_id ON public.warehouses USING btree (branch_id);


--
-- Name: idx_warranties_vehicle_id_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_warranties_vehicle_id_status ON public.warranties USING btree (vehicle_id, status);


--
-- Name: idx_warranty_requests_branch_id_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_warranty_requests_branch_id_status ON public.warranty_requests USING btree (branch_id, status);


--
-- Name: uq_billing_default; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_billing_default ON public.billing_information USING btree (customer_id) WHERE is_default;


--
-- Name: uq_einvoice_config_active; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_einvoice_config_active ON public.einvoice_configs USING btree (is_active) WHERE is_active;


--
-- Name: inventory_transactions trg_inventory_tx_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_inventory_tx_immutable BEFORE DELETE OR UPDATE ON public.inventory_transactions FOR EACH ROW EXECUTE FUNCTION public.fn_block_modify();


--
-- Name: appointment_services appointment_services_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_services
    ADD CONSTRAINT appointment_services_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(appointment_id) ON DELETE RESTRICT;


--
-- Name: appointment_services appointment_services_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_services
    ADD CONSTRAINT appointment_services_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(service_id) ON DELETE RESTRICT;


--
-- Name: appointments appointments_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id) ON DELETE RESTRICT;


--
-- Name: appointments appointments_confirmed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_confirmed_by_fkey FOREIGN KEY (confirmed_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: appointments appointments_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON DELETE RESTRICT;


--
-- Name: appointments appointments_slot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_slot_id_fkey FOREIGN KEY (slot_id) REFERENCES public.time_slots(slot_id) ON DELETE RESTRICT;


--
-- Name: appointments appointments_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id) ON DELETE RESTRICT;


--
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: billing_information billing_information_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_information
    ADD CONSTRAINT billing_information_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON DELETE RESTRICT;


--
-- Name: branch_services branch_services_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_services
    ADD CONSTRAINT branch_services_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id) ON DELETE RESTRICT;


--
-- Name: branch_services branch_services_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_services
    ADD CONSTRAINT branch_services_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(service_id) ON DELETE RESTRICT;


--
-- Name: customers customers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: e_invoices e_invoices_config_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.e_invoices
    ADD CONSTRAINT e_invoices_config_id_fkey FOREIGN KEY (config_id) REFERENCES public.einvoice_configs(config_id) ON DELETE RESTRICT;


--
-- Name: e_invoices e_invoices_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.e_invoices
    ADD CONSTRAINT e_invoices_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(invoice_id) ON DELETE RESTRICT;


--
-- Name: e_invoices e_invoices_original_e_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.e_invoices
    ADD CONSTRAINT e_invoices_original_e_invoice_id_fkey FOREIGN KEY (original_e_invoice_id) REFERENCES public.e_invoices(e_invoice_id) ON DELETE RESTRICT;


--
-- Name: inspection_items inspection_items_inspection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspection_items
    ADD CONSTRAINT inspection_items_inspection_id_fkey FOREIGN KEY (inspection_id) REFERENCES public.inspections(inspection_id) ON DELETE RESTRICT;


--
-- Name: inspection_items inspection_items_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspection_items
    ADD CONSTRAINT inspection_items_part_id_fkey FOREIGN KEY (part_id) REFERENCES public.parts(part_id) ON DELETE RESTRICT;


--
-- Name: inspection_items inspection_items_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspection_items
    ADD CONSTRAINT inspection_items_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(service_id) ON DELETE RESTRICT;


--
-- Name: inspections inspections_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspections
    ADD CONSTRAINT inspections_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: inspections inspections_mechanic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspections
    ADD CONSTRAINT inspections_mechanic_id_fkey FOREIGN KEY (mechanic_id) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: inspections inspections_reception_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspections
    ADD CONSTRAINT inspections_reception_id_fkey FOREIGN KEY (reception_id) REFERENCES public.vehicle_receptions(reception_id) ON DELETE RESTRICT;


--
-- Name: inventories inventories_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventories
    ADD CONSTRAINT inventories_part_id_fkey FOREIGN KEY (part_id) REFERENCES public.parts(part_id) ON DELETE RESTRICT;


--
-- Name: inventories inventories_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventories
    ADD CONSTRAINT inventories_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(warehouse_id) ON DELETE RESTRICT;


--
-- Name: inventory_receipt_items inventory_receipt_items_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_receipt_items
    ADD CONSTRAINT inventory_receipt_items_part_id_fkey FOREIGN KEY (part_id) REFERENCES public.parts(part_id) ON DELETE RESTRICT;


--
-- Name: inventory_receipt_items inventory_receipt_items_receipt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_receipt_items
    ADD CONSTRAINT inventory_receipt_items_receipt_id_fkey FOREIGN KEY (receipt_id) REFERENCES public.inventory_receipts(receipt_id) ON DELETE RESTRICT;


--
-- Name: inventory_receipts inventory_receipts_received_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_receipts
    ADD CONSTRAINT inventory_receipts_received_by_fkey FOREIGN KEY (received_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: inventory_receipts inventory_receipts_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_receipts
    ADD CONSTRAINT inventory_receipts_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(warehouse_id) ON DELETE RESTRICT;


--
-- Name: inventory_transactions inventory_transactions_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_inventory_id_fkey FOREIGN KEY (inventory_id) REFERENCES public.inventories(inventory_id) ON DELETE RESTRICT;


--
-- Name: inventory_transactions inventory_transactions_performed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_performed_by_fkey FOREIGN KEY (performed_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: invoice_lines invoice_lines_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_lines
    ADD CONSTRAINT invoice_lines_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(invoice_id) ON DELETE RESTRICT;


--
-- Name: invoice_lines invoice_lines_quotation_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_lines
    ADD CONSTRAINT invoice_lines_quotation_item_id_fkey FOREIGN KEY (quotation_item_id) REFERENCES public.quotation_items(item_id) ON DELETE RESTRICT;


--
-- Name: invoices invoices_billing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_billing_id_fkey FOREIGN KEY (billing_id) REFERENCES public.billing_information(billing_id) ON DELETE RESTRICT;


--
-- Name: invoices invoices_finalized_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_finalized_by_fkey FOREIGN KEY (finalized_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: invoices invoices_repair_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_repair_order_id_fkey FOREIGN KEY (repair_order_id) REFERENCES public.repair_orders(repair_order_id) ON DELETE RESTRICT;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: part_request_items part_request_items_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_request_items
    ADD CONSTRAINT part_request_items_part_id_fkey FOREIGN KEY (part_id) REFERENCES public.parts(part_id) ON DELETE RESTRICT;


--
-- Name: part_request_items part_request_items_quotation_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_request_items
    ADD CONSTRAINT part_request_items_quotation_item_id_fkey FOREIGN KEY (quotation_item_id) REFERENCES public.quotation_items(item_id) ON DELETE RESTRICT;


--
-- Name: part_request_items part_request_items_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_request_items
    ADD CONSTRAINT part_request_items_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.part_requests(request_id) ON DELETE RESTRICT;


--
-- Name: part_requests part_requests_processed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_requests
    ADD CONSTRAINT part_requests_processed_by_fkey FOREIGN KEY (processed_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: part_requests part_requests_repair_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_requests
    ADD CONSTRAINT part_requests_repair_order_id_fkey FOREIGN KEY (repair_order_id) REFERENCES public.repair_orders(repair_order_id) ON DELETE RESTRICT;


--
-- Name: part_requests part_requests_requested_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_requests
    ADD CONSTRAINT part_requests_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: part_requests part_requests_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_requests
    ADD CONSTRAINT part_requests_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.repair_tasks(task_id) ON DELETE RESTRICT;


--
-- Name: part_reservations part_reservations_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_reservations
    ADD CONSTRAINT part_reservations_inventory_id_fkey FOREIGN KEY (inventory_id) REFERENCES public.inventories(inventory_id) ON DELETE RESTRICT;


--
-- Name: part_reservations part_reservations_quotation_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_reservations
    ADD CONSTRAINT part_reservations_quotation_item_id_fkey FOREIGN KEY (quotation_item_id) REFERENCES public.quotation_items(item_id) ON DELETE RESTRICT;


--
-- Name: part_reservations part_reservations_repair_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_reservations
    ADD CONSTRAINT part_reservations_repair_order_id_fkey FOREIGN KEY (repair_order_id) REFERENCES public.repair_orders(repair_order_id) ON DELETE RESTRICT;


--
-- Name: part_reservations part_reservations_reserved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.part_reservations
    ADD CONSTRAINT part_reservations_reserved_by_fkey FOREIGN KEY (reserved_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: payments payments_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(invoice_id) ON DELETE RESTRICT;


--
-- Name: payments payments_received_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_received_by_fkey FOREIGN KEY (received_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: quotation_items quotation_items_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotation_items
    ADD CONSTRAINT quotation_items_part_id_fkey FOREIGN KEY (part_id) REFERENCES public.parts(part_id) ON DELETE RESTRICT;


--
-- Name: quotation_items quotation_items_quotation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotation_items
    ADD CONSTRAINT quotation_items_quotation_id_fkey FOREIGN KEY (quotation_id) REFERENCES public.quotations(quotation_id) ON DELETE RESTRICT;


--
-- Name: quotation_items quotation_items_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotation_items
    ADD CONSTRAINT quotation_items_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(service_id) ON DELETE RESTRICT;


--
-- Name: quotations quotations_inspection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_inspection_id_fkey FOREIGN KEY (inspection_id) REFERENCES public.inspections(inspection_id) ON DELETE RESTRICT;


--
-- Name: quotations quotations_parent_quotation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_parent_quotation_id_fkey FOREIGN KEY (parent_quotation_id) REFERENCES public.quotations(quotation_id) ON DELETE RESTRICT;


--
-- Name: quotations quotations_prepared_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_prepared_by_fkey FOREIGN KEY (prepared_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: repair_notes repair_notes_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_notes
    ADD CONSTRAINT repair_notes_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: repair_notes repair_notes_repair_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_notes
    ADD CONSTRAINT repair_notes_repair_order_id_fkey FOREIGN KEY (repair_order_id) REFERENCES public.repair_orders(repair_order_id) ON DELETE RESTRICT;


--
-- Name: repair_notes repair_notes_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_notes
    ADD CONSTRAINT repair_notes_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.repair_tasks(task_id) ON DELETE RESTRICT;


--
-- Name: repair_orders repair_orders_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_orders
    ADD CONSTRAINT repair_orders_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id) ON DELETE RESTRICT;


--
-- Name: repair_orders repair_orders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_orders
    ADD CONSTRAINT repair_orders_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: repair_orders repair_orders_quotation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_orders
    ADD CONSTRAINT repair_orders_quotation_id_fkey FOREIGN KEY (quotation_id) REFERENCES public.quotations(quotation_id) ON DELETE RESTRICT;


--
-- Name: repair_orders repair_orders_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_orders
    ADD CONSTRAINT repair_orders_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.repair_order_types(type_id) ON DELETE RESTRICT;


--
-- Name: repair_task_parts repair_task_parts_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_task_parts
    ADD CONSTRAINT repair_task_parts_inventory_id_fkey FOREIGN KEY (inventory_id) REFERENCES public.inventories(inventory_id) ON DELETE RESTRICT;


--
-- Name: repair_task_parts repair_task_parts_issued_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_task_parts
    ADD CONSTRAINT repair_task_parts_issued_by_fkey FOREIGN KEY (issued_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: repair_task_parts repair_task_parts_request_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_task_parts
    ADD CONSTRAINT repair_task_parts_request_item_id_fkey FOREIGN KEY (request_item_id) REFERENCES public.part_request_items(request_item_id) ON DELETE RESTRICT;


--
-- Name: repair_task_parts repair_task_parts_reservation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_task_parts
    ADD CONSTRAINT repair_task_parts_reservation_id_fkey FOREIGN KEY (reservation_id) REFERENCES public.part_reservations(reservation_id) ON DELETE RESTRICT;


--
-- Name: repair_task_parts repair_task_parts_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_task_parts
    ADD CONSTRAINT repair_task_parts_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.repair_tasks(task_id) ON DELETE RESTRICT;


--
-- Name: repair_tasks repair_tasks_mechanic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_tasks
    ADD CONSTRAINT repair_tasks_mechanic_id_fkey FOREIGN KEY (mechanic_id) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: repair_tasks repair_tasks_quotation_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_tasks
    ADD CONSTRAINT repair_tasks_quotation_item_id_fkey FOREIGN KEY (quotation_item_id) REFERENCES public.quotation_items(item_id) ON DELETE RESTRICT;


--
-- Name: repair_tasks repair_tasks_repair_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repair_tasks
    ADD CONSTRAINT repair_tasks_repair_order_id_fkey FOREIGN KEY (repair_order_id) REFERENCES public.repair_orders(repair_order_id) ON DELETE RESTRICT;


--
-- Name: service_ratings service_ratings_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_ratings
    ADD CONSTRAINT service_ratings_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(appointment_id) ON DELETE RESTRICT;


--
-- Name: service_ratings service_ratings_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_ratings
    ADD CONSTRAINT service_ratings_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON DELETE RESTRICT;


--
-- Name: staff staff_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id) ON DELETE RESTRICT;


--
-- Name: staff staff_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: tax_rules tax_rules_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_rules
    ADD CONSTRAINT tax_rules_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: time_slots time_slots_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_slots
    ADD CONSTRAINT time_slots_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id) ON DELETE RESTRICT;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(role_id) ON DELETE RESTRICT;


--
-- Name: vehicle_handovers vehicle_handovers_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_handovers
    ADD CONSTRAINT vehicle_handovers_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(appointment_id) ON DELETE RESTRICT;


--
-- Name: vehicle_handovers vehicle_handovers_handed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_handovers
    ADD CONSTRAINT vehicle_handovers_handed_by_fkey FOREIGN KEY (handed_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: vehicle_handovers vehicle_handovers_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_handovers
    ADD CONSTRAINT vehicle_handovers_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(invoice_id) ON DELETE RESTRICT;


--
-- Name: vehicle_receptions vehicle_receptions_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_receptions
    ADD CONSTRAINT vehicle_receptions_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(appointment_id) ON DELETE RESTRICT;


--
-- Name: vehicle_receptions vehicle_receptions_received_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_receptions
    ADD CONSTRAINT vehicle_receptions_received_by_fkey FOREIGN KEY (received_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: vehicles vehicles_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON DELETE RESTRICT;


--
-- Name: warehouses warehouses_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id) ON DELETE RESTRICT;


--
-- Name: warranties warranties_policy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranties
    ADD CONSTRAINT warranties_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.warranty_policies(policy_id) ON DELETE RESTRICT;


--
-- Name: warranties warranties_quotation_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranties
    ADD CONSTRAINT warranties_quotation_item_id_fkey FOREIGN KEY (quotation_item_id) REFERENCES public.quotation_items(item_id) ON DELETE RESTRICT;


--
-- Name: warranties warranties_repair_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranties
    ADD CONSTRAINT warranties_repair_order_id_fkey FOREIGN KEY (repair_order_id) REFERENCES public.repair_orders(repair_order_id) ON DELETE RESTRICT;


--
-- Name: warranties warranties_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranties
    ADD CONSTRAINT warranties_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id) ON DELETE RESTRICT;


--
-- Name: warranty_policies warranty_policies_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranty_policies
    ADD CONSTRAINT warranty_policies_part_id_fkey FOREIGN KEY (part_id) REFERENCES public.parts(part_id) ON DELETE RESTRICT;


--
-- Name: warranty_policies warranty_policies_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranty_policies
    ADD CONSTRAINT warranty_policies_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(service_id) ON DELETE RESTRICT;


--
-- Name: warranty_repairs warranty_repairs_repair_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranty_repairs
    ADD CONSTRAINT warranty_repairs_repair_order_id_fkey FOREIGN KEY (repair_order_id) REFERENCES public.repair_orders(repair_order_id) ON DELETE RESTRICT;


--
-- Name: warranty_repairs warranty_repairs_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranty_repairs
    ADD CONSTRAINT warranty_repairs_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.warranty_requests(request_id) ON DELETE RESTRICT;


--
-- Name: warranty_requests warranty_requests_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranty_requests
    ADD CONSTRAINT warranty_requests_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: warranty_requests warranty_requests_assessed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranty_requests
    ADD CONSTRAINT warranty_requests_assessed_by_fkey FOREIGN KEY (assessed_by) REFERENCES public.staff(staff_id) ON DELETE RESTRICT;


--
-- Name: warranty_requests warranty_requests_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranty_requests
    ADD CONSTRAINT warranty_requests_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id) ON DELETE RESTRICT;


--
-- Name: warranty_requests warranty_requests_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranty_requests
    ADD CONSTRAINT warranty_requests_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON DELETE RESTRICT;


--
-- Name: warranty_requests warranty_requests_warranty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warranty_requests
    ADD CONSTRAINT warranty_requests_warranty_id_fkey FOREIGN KEY (warranty_id) REFERENCES public.warranties(warranty_id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict jnpyC95pGam6o65WsJ1ChXTvhIW5kQ3EbPBysn9axmMDZ1CuTqEadZzM9ZUY8Aw

