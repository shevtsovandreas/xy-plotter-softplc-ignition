--
-- PostgreSQL database dump
--

\restrict TKeO9um5pPvynQdhKPn2t9LGpXXIQ1itMyQIPhmxLHFW0Jn5FQm6fzbYCgT6apb

-- Dumped from database version 17.11 (Debian 17.11-0+deb13u1)
-- Dumped by pg_dump version 17.11 (Debian 17.11-0+deb13u1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: comm_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comm_log (
    id bigint NOT NULL,
    event_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    signal_id integer NOT NULL,
    old_value smallint NOT NULL,
    new_value smallint NOT NULL
);


--
-- Name: comm_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comm_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comm_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comm_log_id_seq OWNED BY public.comm_log.id;


--
-- Name: comm_signal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comm_signal (
    id integer NOT NULL,
    register_name character varying(20) NOT NULL,
    data_type character varying(10) NOT NULL,
    bit_number integer NOT NULL,
    signal_name character varying(100) NOT NULL,
    description character varying(255),
    direction character varying(20) NOT NULL,
    operation_type character varying(10) NOT NULL
);


--
-- Name: comm_signal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comm_signal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comm_signal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comm_signal_id_seq OWNED BY public.comm_signal.id;


--
-- Name: drawing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drawing (
    drawing_id integer NOT NULL,
    name character varying NOT NULL,
    file_name character varying NOT NULL,
    gcode_text text NOT NULL,
    svg_preview text NOT NULL,
    width_mm numeric,
    height_mm numeric,
    point_count integer,
    contour_count integer,
    active boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    min_x numeric,
    max_x numeric,
    min_y numeric,
    max_y numeric,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: drawing_drawing_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drawing_drawing_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drawing_drawing_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drawing_drawing_id_seq OWNED BY public.drawing.drawing_id;


--
-- Name: drawing_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drawing_history (
    id bigint NOT NULL,
    drawing_id integer NOT NULL,
    start_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    finish_timestamp timestamp without time zone,
    result character varying DEFAULT 'ACTIVE'::character varying NOT NULL,
    points_completed integer DEFAULT 0 NOT NULL,
    error_code integer,
    CONSTRAINT drawing_history_points_completed_check CHECK ((points_completed >= 0)),
    CONSTRAINT drawing_history_result_check CHECK (((result)::text = ANY ((ARRAY['ACTIVE'::character varying, 'COMPLETED'::character varying, 'FAILED'::character varying, 'STOPPED'::character varying])::text[])))
);


--
-- Name: drawing_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drawing_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drawing_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drawing_history_id_seq OWNED BY public.drawing_history.id;


--
-- Name: error_catalog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.error_catalog (
    code integer NOT NULL,
    source character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    priority character varying NOT NULL
);


--
-- Name: error_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.error_history (
    id bigint NOT NULL,
    code integer NOT NULL,
    start_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    finish_timestamp timestamp without time zone,
    state character varying NOT NULL
);


--
-- Name: error_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.error_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: error_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.error_history_id_seq OWNED BY public.error_history.id;


--
-- Name: comm_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comm_log ALTER COLUMN id SET DEFAULT nextval('public.comm_log_id_seq'::regclass);


--
-- Name: comm_signal id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comm_signal ALTER COLUMN id SET DEFAULT nextval('public.comm_signal_id_seq'::regclass);


--
-- Name: drawing drawing_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drawing ALTER COLUMN drawing_id SET DEFAULT nextval('public.drawing_drawing_id_seq'::regclass);


--
-- Name: drawing_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drawing_history ALTER COLUMN id SET DEFAULT nextval('public.drawing_history_id_seq'::regclass);


--
-- Name: error_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_history ALTER COLUMN id SET DEFAULT nextval('public.error_history_id_seq'::regclass);


--
-- Name: comm_log comm_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comm_log
    ADD CONSTRAINT comm_log_pkey PRIMARY KEY (id);


--
-- Name: comm_signal comm_signal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comm_signal
    ADD CONSTRAINT comm_signal_pkey PRIMARY KEY (id);


--
-- Name: drawing_history drawing_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drawing_history
    ADD CONSTRAINT drawing_history_pkey PRIMARY KEY (id);


--
-- Name: drawing drawing_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drawing
    ADD CONSTRAINT drawing_pkey PRIMARY KEY (drawing_id);


--
-- Name: error_catalog error_catalog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_catalog
    ADD CONSTRAINT error_catalog_pkey PRIMARY KEY (code);


--
-- Name: error_history error_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_history
    ADD CONSTRAINT error_history_pkey PRIMARY KEY (id);


--
-- Name: comm_signal uq_comm_signal; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comm_signal
    ADD CONSTRAINT uq_comm_signal UNIQUE (register_name, bit_number);


--
-- Name: idx_comm_log_event_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comm_log_event_time ON public.comm_log USING btree (event_time DESC);


--
-- Name: idx_comm_log_signal_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comm_log_signal_id ON public.comm_log USING btree (signal_id);


--
-- Name: drawing_history drawing_history_drawing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drawing_history
    ADD CONSTRAINT drawing_history_drawing_id_fkey FOREIGN KEY (drawing_id) REFERENCES public.drawing(drawing_id);


--
-- Name: comm_log fk_comm_log_signal; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comm_log
    ADD CONSTRAINT fk_comm_log_signal FOREIGN KEY (signal_id) REFERENCES public.comm_signal(id);


--
-- PostgreSQL database dump complete
--

\unrestrict TKeO9um5pPvynQdhKPn2t9LGpXXIQ1itMyQIPhmxLHFW0Jn5FQm6fzbYCgT6apb

