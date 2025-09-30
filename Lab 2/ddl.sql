--
-- PostgreSQL database dump
--

-- Dumped from database version 16.8 (Debian 16.8-1.pgdg120+1)
-- Dumped by pg_dump version 16.6

-- Started on 2025-09-30 07:34:50 UTC

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 7 (class 2615 OID 16676)
-- Name: dw; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA dw;


ALTER SCHEMA dw OWNER TO admin;

--
-- TOC entry 6 (class 2615 OID 16647)
-- Name: stg; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA stg;


ALTER SCHEMA stg OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 230 (class 1259 OID 16709)
-- Name: calendar_dim; Type: TABLE; Schema: dw; Owner: admin
--

CREATE TABLE dw.calendar_dim (
    dateid integer NOT NULL,
    year integer NOT NULL,
    quarter integer NOT NULL,
    month integer NOT NULL,
    week integer NOT NULL,
    date date NOT NULL,
    week_day character varying(20) NOT NULL,
    leap character varying(20) NOT NULL
);


ALTER TABLE dw.calendar_dim OWNER TO admin;

--
-- TOC entry 229 (class 1259 OID 16708)
-- Name: calendar_dim_dateid_seq; Type: SEQUENCE; Schema: dw; Owner: admin
--

CREATE SEQUENCE dw.calendar_dim_dateid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dw.calendar_dim_dateid_seq OWNER TO admin;

--
-- TOC entry 3428 (class 0 OID 0)
-- Dependencies: 229
-- Name: calendar_dim_dateid_seq; Type: SEQUENCE OWNED BY; Schema: dw; Owner: admin
--

ALTER SEQUENCE dw.calendar_dim_dateid_seq OWNED BY dw.calendar_dim.dateid;


--
-- TOC entry 224 (class 1259 OID 16685)
-- Name: customer_dim; Type: TABLE; Schema: dw; Owner: admin
--

CREATE TABLE dw.customer_dim (
    cust_id integer NOT NULL,
    customer_id character varying(8) NOT NULL,
    customer_name character varying(22) NOT NULL
);


ALTER TABLE dw.customer_dim OWNER TO admin;

--
-- TOC entry 223 (class 1259 OID 16684)
-- Name: customer_dim_cust_id_seq; Type: SEQUENCE; Schema: dw; Owner: admin
--

CREATE SEQUENCE dw.customer_dim_cust_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dw.customer_dim_cust_id_seq OWNER TO admin;

--
-- TOC entry 3429 (class 0 OID 0)
-- Dependencies: 223
-- Name: customer_dim_cust_id_seq; Type: SEQUENCE OWNED BY; Schema: dw; Owner: admin
--

ALTER SEQUENCE dw.customer_dim_cust_id_seq OWNED BY dw.customer_dim.cust_id;


--
-- TOC entry 226 (class 1259 OID 16692)
-- Name: geo_dim; Type: TABLE; Schema: dw; Owner: admin
--

CREATE TABLE dw.geo_dim (
    geo_id integer NOT NULL,
    country character varying(13) NOT NULL,
    city character varying(17) NOT NULL,
    state character varying(20) NOT NULL,
    postal_code character varying(20)
);


ALTER TABLE dw.geo_dim OWNER TO admin;

--
-- TOC entry 225 (class 1259 OID 16691)
-- Name: geo_dim_geo_id_seq; Type: SEQUENCE; Schema: dw; Owner: admin
--

CREATE SEQUENCE dw.geo_dim_geo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dw.geo_dim_geo_id_seq OWNER TO admin;

--
-- TOC entry 3430 (class 0 OID 0)
-- Dependencies: 225
-- Name: geo_dim_geo_id_seq; Type: SEQUENCE OWNED BY; Schema: dw; Owner: admin
--

ALTER SEQUENCE dw.geo_dim_geo_id_seq OWNED BY dw.geo_dim.geo_id;


--
-- TOC entry 228 (class 1259 OID 16700)
-- Name: product_dim; Type: TABLE; Schema: dw; Owner: admin
--

CREATE TABLE dw.product_dim (
    prod_id integer NOT NULL,
    product_id character varying(50) NOT NULL,
    product_name character varying(127) NOT NULL,
    category character varying(15) NOT NULL,
    sub_category character varying(11) NOT NULL,
    segment character varying(11) NOT NULL
);


ALTER TABLE dw.product_dim OWNER TO admin;

--
-- TOC entry 227 (class 1259 OID 16699)
-- Name: product_dim_prod_id_seq; Type: SEQUENCE; Schema: dw; Owner: admin
--

CREATE SEQUENCE dw.product_dim_prod_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dw.product_dim_prod_id_seq OWNER TO admin;

--
-- TOC entry 3431 (class 0 OID 0)
-- Dependencies: 227
-- Name: product_dim_prod_id_seq; Type: SEQUENCE OWNED BY; Schema: dw; Owner: admin
--

ALTER SEQUENCE dw.product_dim_prod_id_seq OWNED BY dw.product_dim.prod_id;


--
-- TOC entry 232 (class 1259 OID 16716)
-- Name: sales_fact; Type: TABLE; Schema: dw; Owner: admin
--

CREATE TABLE dw.sales_fact (
    sales_id integer NOT NULL,
    cust_id integer NOT NULL,
    order_date_id integer NOT NULL,
    ship_date_id integer NOT NULL,
    prod_id integer NOT NULL,
    ship_id integer NOT NULL,
    geo_id integer NOT NULL,
    order_id character varying(25) NOT NULL,
    sales numeric(9,4) NOT NULL,
    profit numeric(21,16) NOT NULL,
    quantity integer NOT NULL,
    discount numeric(4,2) NOT NULL
);


ALTER TABLE dw.sales_fact OWNER TO admin;

--
-- TOC entry 217 (class 1259 OID 16648)
-- Name: orders; Type: TABLE; Schema: stg; Owner: admin
--

CREATE TABLE stg.orders (
    row_id integer NOT NULL,
    order_id character varying(14) NOT NULL,
    order_date date NOT NULL,
    ship_date date NOT NULL,
    ship_mode character varying(14) NOT NULL,
    customer_id character varying(8) NOT NULL,
    customer_name character varying(22) NOT NULL,
    segment character varying(11) NOT NULL,
    country character varying(13) NOT NULL,
    city character varying(17) NOT NULL,
    state character varying(20) NOT NULL,
    postal_code character varying(50),
    region character varying(7) NOT NULL,
    product_id character varying(15) NOT NULL,
    category character varying(15) NOT NULL,
    subcategory character varying(11) NOT NULL,
    product_name character varying(127) NOT NULL,
    sales numeric(9,4) NOT NULL,
    quantity integer NOT NULL,
    discount numeric(4,2) NOT NULL,
    profit numeric(21,16) NOT NULL
);


ALTER TABLE stg.orders OWNER TO admin;

--
-- TOC entry 233 (class 1259 OID 16727)
-- Name: region; Type: VIEW; Schema: dw; Owner: admin
--

CREATE VIEW dw.region AS
 SELECT o.region,
    o.country,
    sum(f.sales) AS total_sales,
    sum(f.profit) AS total_profit,
    sum(f.quantity) AS total_quantity,
    avg(f.discount) AS avg_discount
   FROM (dw.sales_fact f
     JOIN stg.orders o ON (((f.order_id)::text = (o.order_id)::text)))
  GROUP BY o.region, o.country;


ALTER VIEW dw.region OWNER TO admin;

--
-- TOC entry 234 (class 1259 OID 16732)
-- Name: return_people; Type: TABLE; Schema: dw; Owner: admin
--

CREATE TABLE dw.return_people (
    manager character varying(17),
    region character varying(7),
    total_returns bigint,
    returned_sales numeric,
    returned_profit numeric
);


ALTER TABLE dw.return_people OWNER TO admin;

--
-- TOC entry 231 (class 1259 OID 16715)
-- Name: sales_fact_sales_id_seq; Type: SEQUENCE; Schema: dw; Owner: admin
--

CREATE SEQUENCE dw.sales_fact_sales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dw.sales_fact_sales_id_seq OWNER TO admin;

--
-- TOC entry 3432 (class 0 OID 0)
-- Dependencies: 231
-- Name: sales_fact_sales_id_seq; Type: SEQUENCE OWNED BY; Schema: dw; Owner: admin
--

ALTER SEQUENCE dw.sales_fact_sales_id_seq OWNED BY dw.sales_fact.sales_id;


--
-- TOC entry 222 (class 1259 OID 16678)
-- Name: shipping_dim; Type: TABLE; Schema: dw; Owner: admin
--

CREATE TABLE dw.shipping_dim (
    ship_id integer NOT NULL,
    shipping_mode character varying(14) NOT NULL
);


ALTER TABLE dw.shipping_dim OWNER TO admin;

--
-- TOC entry 221 (class 1259 OID 16677)
-- Name: shipping_dim_ship_id_seq; Type: SEQUENCE; Schema: dw; Owner: admin
--

CREATE SEQUENCE dw.shipping_dim_ship_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dw.shipping_dim_ship_id_seq OWNER TO admin;

--
-- TOC entry 3433 (class 0 OID 0)
-- Dependencies: 221
-- Name: shipping_dim_ship_id_seq; Type: SEQUENCE OWNED BY; Schema: dw; Owner: admin
--

ALTER SEQUENCE dw.shipping_dim_ship_id_seq OWNED BY dw.shipping_dim.ship_id;


--
-- TOC entry 218 (class 1259 OID 16658)
-- Name: orders; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.orders (
    row_id integer NOT NULL,
    order_id character varying(14) NOT NULL,
    order_date date NOT NULL,
    ship_date date NOT NULL,
    ship_mode character varying(14) NOT NULL,
    customer_id character varying(8) NOT NULL,
    customer_name character varying(22) NOT NULL,
    segment character varying(11) NOT NULL,
    country character varying(13) NOT NULL,
    city character varying(17) NOT NULL,
    state character varying(20) NOT NULL,
    postal_code integer,
    region character varying(7) NOT NULL,
    product_id character varying(15) NOT NULL,
    category character varying(15) NOT NULL,
    subcategory character varying(11) NOT NULL,
    product_name character varying(127) NOT NULL,
    sales numeric(9,4) NOT NULL,
    quantity integer NOT NULL,
    discount numeric(4,2) NOT NULL,
    profit numeric(21,16) NOT NULL
);


ALTER TABLE public.orders OWNER TO admin;

--
-- TOC entry 219 (class 1259 OID 16668)
-- Name: people; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.people (
    person character varying(17) NOT NULL,
    region character varying(7) NOT NULL
);


ALTER TABLE public.people OWNER TO admin;

--
-- TOC entry 220 (class 1259 OID 16673)
-- Name: returns; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.returns (
    returned character varying(17) NOT NULL,
    order_id character varying(20) NOT NULL
);


ALTER TABLE public.returns OWNER TO admin;

--
-- TOC entry 3258 (class 2604 OID 16712)
-- Name: calendar_dim dateid; Type: DEFAULT; Schema: dw; Owner: admin
--

ALTER TABLE ONLY dw.calendar_dim ALTER COLUMN dateid SET DEFAULT nextval('dw.calendar_dim_dateid_seq'::regclass);


--
-- TOC entry 3255 (class 2604 OID 16688)
-- Name: customer_dim cust_id; Type: DEFAULT; Schema: dw; Owner: admin
--

ALTER TABLE ONLY dw.customer_dim ALTER COLUMN cust_id SET DEFAULT nextval('dw.customer_dim_cust_id_seq'::regclass);


--
-- TOC entry 3256 (class 2604 OID 16695)
-- Name: geo_dim geo_id; Type: DEFAULT; Schema: dw; Owner: admin
--

ALTER TABLE ONLY dw.geo_dim ALTER COLUMN geo_id SET DEFAULT nextval('dw.geo_dim_geo_id_seq'::regclass);


--
-- TOC entry 3257 (class 2604 OID 16703)
-- Name: product_dim prod_id; Type: DEFAULT; Schema: dw; Owner: admin
--

ALTER TABLE ONLY dw.product_dim ALTER COLUMN prod_id SET DEFAULT nextval('dw.product_dim_prod_id_seq'::regclass);


--
-- TOC entry 3259 (class 2604 OID 16719)
-- Name: sales_fact sales_id; Type: DEFAULT; Schema: dw; Owner: admin
--

ALTER TABLE ONLY dw.sales_fact ALTER COLUMN sales_id SET DEFAULT nextval('dw.sales_fact_sales_id_seq'::regclass);


--
-- TOC entry 3254 (class 2604 OID 16681)
-- Name: shipping_dim ship_id; Type: DEFAULT; Schema: dw; Owner: admin
--

ALTER TABLE ONLY dw.shipping_dim ALTER COLUMN ship_id SET DEFAULT nextval('dw.shipping_dim_ship_id_seq'::regclass);


--
-- TOC entry 3275 (class 2606 OID 16714)
-- Name: calendar_dim pk_calendar_dim; Type: CONSTRAINT; Schema: dw; Owner: admin
--

ALTER TABLE ONLY dw.calendar_dim
    ADD CONSTRAINT pk_calendar_dim PRIMARY KEY (dateid);


--
-- TOC entry 3269 (class 2606 OID 16690)
-- Name: customer_dim pk_customer_dim; Type: CONSTRAINT; Schema: dw; Owner: admin
--

ALTER TABLE ONLY dw.customer_dim
    ADD CONSTRAINT pk_customer_dim PRIMARY KEY (cust_id);


--
-- TOC entry 3271 (class 2606 OID 16697)
-- Name: geo_dim pk_geo_dim; Type: CONSTRAINT; Schema: dw; Owner: admin
--

ALTER TABLE ONLY dw.geo_dim
    ADD CONSTRAINT pk_geo_dim PRIMARY KEY (geo_id);


--
-- TOC entry 3273 (class 2606 OID 16705)
-- Name: product_dim pk_product_dim; Type: CONSTRAINT; Schema: dw; Owner: admin
--

ALTER TABLE ONLY dw.product_dim
    ADD CONSTRAINT pk_product_dim PRIMARY KEY (prod_id);


--
-- TOC entry 3277 (class 2606 OID 16721)
-- Name: sales_fact pk_sales_fact; Type: CONSTRAINT; Schema: dw; Owner: admin
--

ALTER TABLE ONLY dw.sales_fact
    ADD CONSTRAINT pk_sales_fact PRIMARY KEY (sales_id);


--
-- TOC entry 3267 (class 2606 OID 16683)
-- Name: shipping_dim pk_shipping_dim; Type: CONSTRAINT; Schema: dw; Owner: admin
--

ALTER TABLE ONLY dw.shipping_dim
    ADD CONSTRAINT pk_shipping_dim PRIMARY KEY (ship_id);


--
-- TOC entry 3263 (class 2606 OID 16662)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (row_id);


--
-- TOC entry 3265 (class 2606 OID 16672)
-- Name: people people_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_pkey PRIMARY KEY (person);


--
-- TOC entry 3261 (class 2606 OID 16652)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: stg; Owner: admin
--

ALTER TABLE ONLY stg.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (row_id);


--
-- TOC entry 3427 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO admin;


-- Completed on 2025-09-30 07:34:50 UTC

--
-- PostgreSQL database dump complete
--

