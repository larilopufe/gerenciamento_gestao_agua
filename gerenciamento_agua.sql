--
-- PostgreSQL database dump
--

\restrict vQCoopLd7IOMOIMPRivuwPDltjgzrebnTZHgG1aILA3IrbG8d7bti0wrD6KC2uZ

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

-- Started on 2026-05-22 12:18:31

CREATE DATABASE gerenciamento_agua;

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
-- TOC entry 243 (class 1255 OID 16657)
-- Name: fn_atualizar_fechamento(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_atualizar_fechamento() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_mes SMALLINT;
    v_ano SMALLINT;
    v_cliente INTEGER;
    v_usuario INTEGER;
BEGIN

    -- DELETE usa OLD
    IF TG_OP = 'DELETE' THEN

        v_mes := EXTRACT(MONTH FROM OLD.data_operacao);
        v_ano := EXTRACT(YEAR FROM OLD.data_operacao);

        v_cliente := OLD.id_cliente;
        v_usuario := OLD.id_usuario;

    ELSE

        v_mes := EXTRACT(MONTH FROM NEW.data_operacao);
        v_ano := EXTRACT(YEAR FROM NEW.data_operacao);

        v_cliente := NEW.id_cliente;
        v_usuario := NEW.id_usuario;

    END IF;

    INSERT INTO fechamento_mensal (
        id_cliente,
        id_usuario,
        mes,
        ano,
        total_operacoes,
        total_quantidade
    )

    SELECT
        v_cliente,
        v_usuario,
        v_mes,
        v_ano,

        COUNT(*) AS total_operacoes,

        COALESCE(SUM(quantidade), 0) AS total_quantidade

    FROM operacao

    WHERE id_cliente = v_cliente

    AND EXTRACT(MONTH FROM data_operacao) = v_mes

    AND EXTRACT(YEAR FROM data_operacao) = v_ano

    ON CONFLICT (id_cliente, mes, ano)

    DO UPDATE SET

        total_operacoes = EXCLUDED.total_operacoes,

        total_quantidade = EXCLUDED.total_quantidade,

        gerado_em = CURRENT_TIMESTAMP;

    RETURN NULL;

END;
$$;


ALTER FUNCTION public.fn_atualizar_fechamento() OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 16662)
-- Name: fn_criar_vale_automatico(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_criar_vale_automatico() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

    INSERT INTO vale (
        id_operacao,
        valor
    )
    VALUES (
        NEW.id_operacao,
        NEW.valor
    );

    RETURN NEW;

END;
$$;


ALTER FUNCTION public.fn_criar_vale_automatico() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 224 (class 1259 OID 16555)
-- Name: caminhao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.caminhao (
    id_caminhao integer NOT NULL,
    placa character varying(10) NOT NULL,
    motorista character varying(100) NOT NULL,
    capacidade_litros integer NOT NULL,
    CONSTRAINT chk_capacidade_litros CHECK ((capacidade_litros > 0))
);


ALTER TABLE public.caminhao OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16554)
-- Name: caminhao_id_caminhao_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.caminhao_id_caminhao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.caminhao_id_caminhao_seq OWNER TO postgres;

--
-- TOC entry 5100 (class 0 OID 0)
-- Dependencies: 223
-- Name: caminhao_id_caminhao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.caminhao_id_caminhao_seq OWNED BY public.caminhao.id_caminhao;


--
-- TOC entry 222 (class 1259 OID 16545)
-- Name: cliente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cliente (
    id_cliente integer NOT NULL,
    nome character varying(100) NOT NULL,
    telefone character varying(20),
    endereco character varying(255),
    criado_em timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.cliente OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16544)
-- Name: cliente_id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cliente_id_cliente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cliente_id_cliente_seq OWNER TO postgres;

--
-- TOC entry 5101 (class 0 OID 0)
-- Dependencies: 221
-- Name: cliente_id_cliente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cliente_id_cliente_seq OWNED BY public.cliente.id_cliente;


--
-- TOC entry 230 (class 1259 OID 16622)
-- Name: fechamento_mensal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fechamento_mensal (
    id_fechamento integer NOT NULL,
    id_cliente integer NOT NULL,
    id_usuario integer NOT NULL,
    mes smallint NOT NULL,
    ano smallint NOT NULL,
    total_operacoes integer DEFAULT 0 NOT NULL,
    total_quantidade integer DEFAULT 0 NOT NULL,
    gerado_em timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_mes CHECK (((mes >= 1) AND (mes <= 12))),
    CONSTRAINT chk_total_operacoes CHECK ((total_operacoes >= 0)),
    CONSTRAINT chk_total_quantidade CHECK ((total_quantidade >= 0))
);


ALTER TABLE public.fechamento_mensal OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16621)
-- Name: fechamento_mensal_id_fechamento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fechamento_mensal_id_fechamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fechamento_mensal_id_fechamento_seq OWNER TO postgres;

--
-- TOC entry 5102 (class 0 OID 0)
-- Dependencies: 229
-- Name: fechamento_mensal_id_fechamento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fechamento_mensal_id_fechamento_seq OWNED BY public.fechamento_mensal.id_fechamento;


--
-- TOC entry 226 (class 1259 OID 16569)
-- Name: operacao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.operacao (
    id_operacao integer NOT NULL,
    id_cliente integer NOT NULL,
    id_caminhao integer NOT NULL,
    id_usuario integer NOT NULL,
    tipo character varying(20) NOT NULL,
    quantidade integer NOT NULL,
    data_operacao timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    observacao text,
    valor numeric(10,2) NOT NULL,
    CONSTRAINT chk_quantidade_operacao CHECK ((quantidade > 0)),
    CONSTRAINT chk_tipo_operacao CHECK (((tipo)::text = ANY ((ARRAY['ENTREGA'::character varying, 'RETIRADA'::character varying])::text[]))),
    CONSTRAINT chk_valor_operacao CHECK ((valor > (0)::numeric))
);


ALTER TABLE public.operacao OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16568)
-- Name: operacao_id_operacao_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.operacao_id_operacao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.operacao_id_operacao_seq OWNER TO postgres;

--
-- TOC entry 5103 (class 0 OID 0)
-- Dependencies: 225
-- Name: operacao_id_operacao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.operacao_id_operacao_seq OWNED BY public.operacao.id_operacao;


--
-- TOC entry 220 (class 1259 OID 16531)
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    id_usuario integer NOT NULL,
    nome character varying(100) NOT NULL,
    login character varying(50) NOT NULL,
    senha_hash character varying(255) NOT NULL,
    perfil character varying(30) NOT NULL
);


ALTER TABLE public.usuario OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16530)
-- Name: usuario_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuario_id_usuario_seq OWNER TO postgres;

--
-- TOC entry 5104 (class 0 OID 0)
-- Dependencies: 219
-- Name: usuario_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;


--
-- TOC entry 228 (class 1259 OID 16602)
-- Name: vale; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vale (
    id_vale integer NOT NULL,
    id_operacao integer NOT NULL,
    valor numeric(10,2) NOT NULL,
    data_emissao timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    pago boolean DEFAULT false,
    data_pagamento timestamp without time zone,
    CONSTRAINT chk_valor_vale CHECK ((valor > (0)::numeric))
);


ALTER TABLE public.vale OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16601)
-- Name: vale_id_vale_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vale_id_vale_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vale_id_vale_seq OWNER TO postgres;

--
-- TOC entry 5105 (class 0 OID 0)
-- Dependencies: 227
-- Name: vale_id_vale_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vale_id_vale_seq OWNED BY public.vale.id_vale;


--
-- TOC entry 4886 (class 2604 OID 16558)
-- Name: caminhao id_caminhao; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caminhao ALTER COLUMN id_caminhao SET DEFAULT nextval('public.caminhao_id_caminhao_seq'::regclass);


--
-- TOC entry 4884 (class 2604 OID 16548)
-- Name: cliente id_cliente; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente ALTER COLUMN id_cliente SET DEFAULT nextval('public.cliente_id_cliente_seq'::regclass);


--
-- TOC entry 4892 (class 2604 OID 16625)
-- Name: fechamento_mensal id_fechamento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fechamento_mensal ALTER COLUMN id_fechamento SET DEFAULT nextval('public.fechamento_mensal_id_fechamento_seq'::regclass);


--
-- TOC entry 4887 (class 2604 OID 16572)
-- Name: operacao id_operacao; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operacao ALTER COLUMN id_operacao SET DEFAULT nextval('public.operacao_id_operacao_seq'::regclass);


--
-- TOC entry 4883 (class 2604 OID 16534)
-- Name: usuario id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);


--
-- TOC entry 4889 (class 2604 OID 16605)
-- Name: vale id_vale; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vale ALTER COLUMN id_vale SET DEFAULT nextval('public.vale_id_vale_seq'::regclass);


--
-- TOC entry 5088 (class 0 OID 16555)
-- Dependencies: 224
-- Data for Name: caminhao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.caminhao (id_caminhao, placa, motorista, capacidade_litros) FROM stdin;
1	XYZ9K88	João Motorista	12000
\.


--
-- TOC entry 5086 (class 0 OID 16545)
-- Dependencies: 222
-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cliente (id_cliente, nome, telefone, endereco, criado_em) FROM stdin;
1	Construtora Beta	(19)98888-7777	Campinas - SP	2026-05-22 08:36:10.228155
\.


--
-- TOC entry 5094 (class 0 OID 16622)
-- Dependencies: 230
-- Data for Name: fechamento_mensal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fechamento_mensal (id_fechamento, id_cliente, id_usuario, mes, ano, total_operacoes, total_quantidade, gerado_em) FROM stdin;
9	1	1	5	2026	1	8000	2026-05-22 12:06:52.221319
\.


--
-- TOC entry 5090 (class 0 OID 16569)
-- Dependencies: 226
-- Data for Name: operacao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.operacao (id_operacao, id_cliente, id_caminhao, id_usuario, tipo, quantidade, data_operacao, observacao, valor) FROM stdin;
8	1	1	1	ENTREGA	8000	2026-05-22 12:06:52.221319	Entrega automática	650.00
\.


--
-- TOC entry 5084 (class 0 OID 16531)
-- Dependencies: 220
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuario (id_usuario, nome, login, senha_hash, perfil) FROM stdin;
1	Larissa	larissa	hash_teste	ADMIN
2	João	admin	hash	ADMIN
\.


--
-- TOC entry 5092 (class 0 OID 16602)
-- Dependencies: 228
-- Data for Name: vale; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vale (id_vale, id_operacao, valor, data_emissao, pago, data_pagamento) FROM stdin;
5	8	650.00	2026-05-22 12:06:52.221319	f	\N
\.


--
-- TOC entry 5106 (class 0 OID 0)
-- Dependencies: 223
-- Name: caminhao_id_caminhao_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.caminhao_id_caminhao_seq', 1, true);


--
-- TOC entry 5107 (class 0 OID 0)
-- Dependencies: 221
-- Name: cliente_id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cliente_id_cliente_seq', 1, true);


--
-- TOC entry 5108 (class 0 OID 0)
-- Dependencies: 229
-- Name: fechamento_mensal_id_fechamento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fechamento_mensal_id_fechamento_seq', 9, true);


--
-- TOC entry 5109 (class 0 OID 0)
-- Dependencies: 225
-- Name: operacao_id_operacao_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.operacao_id_operacao_seq', 8, true);


--
-- TOC entry 5110 (class 0 OID 0)
-- Dependencies: 219
-- Name: usuario_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 3, true);


--
-- TOC entry 5111 (class 0 OID 0)
-- Dependencies: 227
-- Name: vale_id_vale_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vale_id_vale_seq', 5, true);


--
-- TOC entry 4911 (class 2606 OID 16565)
-- Name: caminhao caminhao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caminhao
    ADD CONSTRAINT caminhao_pkey PRIMARY KEY (id_caminhao);


--
-- TOC entry 4913 (class 2606 OID 16567)
-- Name: caminhao caminhao_placa_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.caminhao
    ADD CONSTRAINT caminhao_placa_key UNIQUE (placa);


--
-- TOC entry 4909 (class 2606 OID 16553)
-- Name: cliente cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);


--
-- TOC entry 4924 (class 2606 OID 16640)
-- Name: fechamento_mensal fechamento_mensal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fechamento_mensal
    ADD CONSTRAINT fechamento_mensal_pkey PRIMARY KEY (id_fechamento);


--
-- TOC entry 4917 (class 2606 OID 16585)
-- Name: operacao operacao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operacao
    ADD CONSTRAINT operacao_pkey PRIMARY KEY (id_operacao);


--
-- TOC entry 4927 (class 2606 OID 16642)
-- Name: fechamento_mensal unq_fechamento; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fechamento_mensal
    ADD CONSTRAINT unq_fechamento UNIQUE (id_cliente, mes, ano);


--
-- TOC entry 4905 (class 2606 OID 16543)
-- Name: usuario usuario_login_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_login_key UNIQUE (login);


--
-- TOC entry 4907 (class 2606 OID 16541)
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 4920 (class 2606 OID 16615)
-- Name: vale vale_id_operacao_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vale
    ADD CONSTRAINT vale_id_operacao_key UNIQUE (id_operacao);


--
-- TOC entry 4922 (class 2606 OID 16613)
-- Name: vale vale_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vale
    ADD CONSTRAINT vale_pkey PRIMARY KEY (id_vale);


--
-- TOC entry 4925 (class 1259 OID 16656)
-- Name: idx_fechamento_cliente; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fechamento_cliente ON public.fechamento_mensal USING btree (id_cliente);


--
-- TOC entry 4914 (class 1259 OID 16653)
-- Name: idx_operacao_cliente; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_operacao_cliente ON public.operacao USING btree (id_cliente);


--
-- TOC entry 4915 (class 1259 OID 16654)
-- Name: idx_operacao_data; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_operacao_data ON public.operacao USING btree (data_operacao);


--
-- TOC entry 4918 (class 1259 OID 16655)
-- Name: idx_vale_operacao; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vale_operacao ON public.vale USING btree (id_operacao);


--
-- TOC entry 4934 (class 2620 OID 16663)
-- Name: operacao trg_criar_vale; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_criar_vale AFTER INSERT ON public.operacao FOR EACH ROW EXECUTE FUNCTION public.fn_criar_vale_automatico();


--
-- TOC entry 4935 (class 2620 OID 16658)
-- Name: operacao trg_fechamento_mensal; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_fechamento_mensal AFTER INSERT OR DELETE OR UPDATE ON public.operacao FOR EACH ROW EXECUTE FUNCTION public.fn_atualizar_fechamento();


--
-- TOC entry 4932 (class 2606 OID 16643)
-- Name: fechamento_mensal fk_fechamento_cliente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fechamento_mensal
    ADD CONSTRAINT fk_fechamento_cliente FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);


--
-- TOC entry 4933 (class 2606 OID 16648)
-- Name: fechamento_mensal fk_fechamento_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fechamento_mensal
    ADD CONSTRAINT fk_fechamento_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 4928 (class 2606 OID 16591)
-- Name: operacao fk_operacao_caminhao; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operacao
    ADD CONSTRAINT fk_operacao_caminhao FOREIGN KEY (id_caminhao) REFERENCES public.caminhao(id_caminhao);


--
-- TOC entry 4929 (class 2606 OID 16586)
-- Name: operacao fk_operacao_cliente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operacao
    ADD CONSTRAINT fk_operacao_cliente FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);


--
-- TOC entry 4930 (class 2606 OID 16596)
-- Name: operacao fk_operacao_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.operacao
    ADD CONSTRAINT fk_operacao_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 4931 (class 2606 OID 16616)
-- Name: vale fk_vale_operacao; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vale
    ADD CONSTRAINT fk_vale_operacao FOREIGN KEY (id_operacao) REFERENCES public.operacao(id_operacao) ON DELETE CASCADE;


-- Completed on 2026-05-22 12:18:31

--
-- PostgreSQL database dump complete
--

\unrestrict vQCoopLd7IOMOIMPRivuwPDltjgzrebnTZHgG1aILA3IrbG8d7bti0wrD6KC2uZ

