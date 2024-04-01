--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.2

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    employee_id integer NOT NULL,
    name character varying(100) NOT NULL,
    surname character varying(100) NOT NULL,
    patronymic character varying(100) NOT NULL,
    gender character varying(20) NOT NULL,
    jobid integer,
    departmentid integer,
    date_latest date NOT NULL
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- Name: job; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job (
    jobid integer NOT NULL,
    jobname character varying(100) NOT NULL
);


ALTER TABLE public.job OWNER TO postgres;

--
-- Name: salaries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.salaries (
    salaryid integer NOT NULL,
    employee_id integer,
    salary integer NOT NULL
);


ALTER TABLE public.salaries OWNER TO postgres;

--
-- Name: averagesalary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.averagesalary AS
 SELECT j.jobname AS "Должность",
    round(avg(s.salary), 2) AS "СредняяЗП",
        CASE
            WHEN (avg(s.salary) > avg_salary_table.overall_avg_salary) THEN 'Да'::text
            ELSE 'Нет'::text
        END AS "ВышеСредней"
   FROM (((public.job j
     JOIN public.employees e ON ((j.jobid = e.jobid)))
     JOIN public.salaries s ON ((e.employee_id = s.employee_id)))
     CROSS JOIN ( SELECT round(avg(salaries.salary), 2) AS overall_avg_salary
           FROM public.salaries) avg_salary_table)
  GROUP BY j.jobname, avg_salary_table.overall_avg_salary;


ALTER VIEW public.averagesalary OWNER TO postgres;

--
-- Name: davidemployee; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.davidemployee AS
 SELECT a.name,
    b.salary,
    c.jobname
   FROM ((public.employees a
     LEFT JOIN public.salaries b ON ((a.employee_id = b.employee_id)))
     LEFT JOIN public.job c ON ((a.jobid = c.jobid)))
  WHERE ((a.name)::text = 'Давид'::text);


ALTER VIEW public.davidemployee OWNER TO postgres;

--
-- Name: departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departments (
    departmentid integer NOT NULL,
    departmentname character varying(100) NOT NULL
);


ALTER TABLE public.departments OWNER TO postgres;

--
-- Name: departments_departmentid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.departments_departmentid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departments_departmentid_seq OWNER TO postgres;

--
-- Name: departments_departmentid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.departments_departmentid_seq OWNED BY public.departments.departmentid;


--
-- Name: employeebyname; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.employeebyname AS
 SELECT employee_id,
    name,
    surname,
    patronymic,
    gender,
    jobid,
    departmentid,
    date_latest
   FROM public.employees
  WHERE ((name)::text = 'Давид'::text);


ALTER VIEW public.employeebyname OWNER TO postgres;

--
-- Name: employees_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employees_employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employees_employee_id_seq OWNER TO postgres;

--
-- Name: employees_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employees_employee_id_seq OWNED BY public.employees.employee_id;


--
-- Name: employment_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employment_history (
    historyid integer NOT NULL,
    promotion_date date NOT NULL,
    employee_id integer
);


ALTER TABLE public.employment_history OWNER TO postgres;

--
-- Name: employment_history_historyid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employment_history_historyid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employment_history_historyid_seq OWNER TO postgres;

--
-- Name: employment_history_historyid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employment_history_historyid_seq OWNED BY public.employment_history.historyid;


--
-- Name: job_jobid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_jobid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.job_jobid_seq OWNER TO postgres;

--
-- Name: job_jobid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_jobid_seq OWNED BY public.job.jobid;


--
-- Name: jobsummary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.jobsummary AS
 SELECT j.jobname AS job,
    array_agg(DISTINCT d.departmentname) AS departments,
    ( SELECT jsonb_agg(jsonb_build_object('Имя', e_1.name, 'Фамилия', e_1.surname, 'ДатаНазначения', eh.promotion_date, 'ЗП', s_1.salary)) AS jsonb_agg
           FROM ((public.employees e_1
             JOIN public.salaries s_1 ON ((e_1.employee_id = s_1.employee_id)))
             JOIN public.employment_history eh ON ((e_1.employee_id = eh.employee_id)))
          WHERE ((e_1.jobid = j.jobid) AND (eh.promotion_date >= '2021-01-01'::date))) AS employees,
    round(avg(s.salary), 2) AS avgsalary
   FROM (((public.job j
     JOIN public.employees e ON ((j.jobid = e.jobid)))
     JOIN public.salaries s ON ((e.employee_id = s.employee_id)))
     JOIN public.departments d ON ((e.departmentid = d.departmentid)))
  GROUP BY j.jobname, j.jobid;


ALTER VIEW public.jobsummary OWNER TO postgres;

--
-- Name: salaries_salaryid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.salaries_salaryid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.salaries_salaryid_seq OWNER TO postgres;

--
-- Name: salaries_salaryid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.salaries_salaryid_seq OWNED BY public.salaries.salaryid;


--
-- Name: salarybydept; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.salarybydept AS
 SELECT a.departmentname,
    sum(b.salary) AS totalsalary
   FROM ((public.employees e
     JOIN public.departments a ON ((e.departmentid = a.departmentid)))
     LEFT JOIN public.salaries b ON ((e.employee_id = b.employee_id)))
  GROUP BY a.departmentname;


ALTER VIEW public.salarybydept OWNER TO postgres;

--
-- Name: departments departmentid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments ALTER COLUMN departmentid SET DEFAULT nextval('public.departments_departmentid_seq'::regclass);


--
-- Name: employees employee_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees ALTER COLUMN employee_id SET DEFAULT nextval('public.employees_employee_id_seq'::regclass);


--
-- Name: employment_history historyid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employment_history ALTER COLUMN historyid SET DEFAULT nextval('public.employment_history_historyid_seq'::regclass);


--
-- Name: job jobid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job ALTER COLUMN jobid SET DEFAULT nextval('public.job_jobid_seq'::regclass);


--
-- Name: salaries salaryid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salaries ALTER COLUMN salaryid SET DEFAULT nextval('public.salaries_salaryid_seq'::regclass);


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departments (departmentid, departmentname) FROM stdin;
1	Снабжение
2	Разработка
3	Логистика
4	Продажи
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees (employee_id, name, surname, patronymic, gender, jobid, departmentid, date_latest) FROM stdin;
1	Айлин	Ким	Алихановна	Женский	3	4	2020-08-01
2	Алан	Искаков	Амирович	Мужской	3	4	2017-05-09
3	Айсултан	Сулейменов	Айсултанович	Мужской	3	1	2016-04-09
4	Давид	Алиев	Аланович	Мужской	1	3	2024-01-01
5	Айлин	Оспанова	Алановна	Женский	7	2	2016-02-26
6	Алихан	Ким	Омарович	Мужской	1	2	2022-05-30
7	Светлана	Оспанова	Нурисламовна	Женский	2	3	2020-08-18
8	Айым	Алиева	Алдияровна	Женский	1	1	2019-11-10
9	Амина	Сулейменова	Алановна	Женский	3	2	2017-08-15
10	Амир	Искаков	Аланович	Мужской	6	1	2021-06-13
11	Омар	Иванов	Алдиярович	Мужской	1	3	2017-02-22
12	Амир	Искаков	Омарович	Мужской	1	3	2019-11-14
13	Давид	Оспанов	Амирович	Мужской	3	3	2023-02-02
14	Раяна	Ахметова	Алдияровна	Женский	3	2	2021-03-11
15	Нурислам	Ким	Давидович	Мужской	4	1	2015-08-18
16	Омар	Алиев	Давидович	Мужской	3	4	2022-04-14
17	Али	Манукян	Айсултанович	Мужской	5	4	2022-07-28
18	Амина	Манукян	Алиевна	Женский	8	3	2017-03-31
19	Давид	Ким	Алиевич	Мужской	3	3	2018-01-30
20	Асылым	Омарова	Айсултановна	Женский	3	3	2014-12-26
21	Раяна	Ахметова	Нурисламовна	Женский	4	4	2019-03-20
22	Амина	Иванова	Алдияровна	Женский	2	1	2020-08-12
23	Али	Иванов	Алдиярович	Мужской	7	3	2022-01-17
24	Нурислам	Иванов	Алиханович	Мужской	4	3	2023-04-17
25	Алихан	Алиев	Айсултанович	Мужской	4	3	2019-09-15
26	Асылым	Омарова	Айсултановна	Женский	6	1	2020-04-07
27	Омар	Оспанов	Алдиярович	Мужской	3	4	2021-12-23
28	Нурислам	Сулейменов	Аланович	Мужской	5	3	2019-09-18
29	Медина	Искакова	Алихановна	Женский	1	3	2019-11-07
30	Асылым	Алиева	Омаровна	Женский	8	4	2017-06-04
31	Алан	Омаров	Нурисламович	Мужской	1	1	2023-06-19
32	Айлин	Омарова	Омаровна	Женский	6	1	2016-04-17
33	Давид	Иванов	Давидович	Мужской	5	4	2018-07-30
34	Айым	Ким	Нурисламовна	Женский	5	2	2020-11-29
35	Алихан	Алиев	Аланович	Мужской	3	4	2016-07-03
36	Алихан	Алиев	Давидович	Мужской	3	1	2020-01-18
37	Алихан	Искаков	Нурисламович	Мужской	2	3	2022-01-01
38	Омар	Иванов	Аланович	Мужской	1	4	2021-03-18
39	Давид	Сулейменов	Алиханович	Мужской	1	2	2021-04-07
40	Айым	Омарова	Амировна	Женский	8	1	2017-06-24
41	Медина	Иванова	Нурисламовна	Женский	5	1	2023-12-16
42	Алдияр	Оспанов	Алиевич	Мужской	6	3	2023-04-28
43	Амина	Омарова	Омаровна	Женский	8	2	2020-08-29
44	Алдияр	Иванов	Омарович	Мужской	3	1	2017-11-28
45	Амир	Иванов	Алиханович	Мужской	5	1	2023-04-23
46	Алан	Омаров	Давидович	Мужской	1	1	2015-11-24
47	Медина	Ахметова	Омаровна	Женский	4	3	2019-07-09
48	Амир	Иванов	Алиевич	Мужской	1	2	2015-09-11
49	Раяна	Алиева	Алдияровна	Женский	7	3	2023-02-25
50	Алихан	Сулейменов	Давидович	Мужской	6	2	2015-07-05
51	Айсултан	Оспанов	Алиевич	Мужской	3	2	2016-12-31
52	Айсултан	Иванов	Алиханович	Мужской	8	1	2022-08-31
53	Айсултан	Манукян	Аланович	Мужской	6	2	2020-02-20
54	Медина	Оспанова	Амировна	Женский	4	3	2016-08-27
55	Айлин	Иванова	Алихановна	Женский	2	3	2021-06-15
56	Амина	Алиева	Амировна	Женский	2	3	2023-10-29
57	Раяна	Омарова	Алихановна	Женский	5	1	2019-04-30
58	Раяна	Манукян	Нурисламовна	Женский	2	1	2016-10-07
59	Алихан	Оспанов	Омарович	Мужской	4	4	2021-02-22
60	Айым	Омарова	Нурисламовна	Женский	3	3	2015-12-28
61	Раяна	Алиева	Алиевна	Женский	2	3	2022-04-23
62	Амир	Алиев	Аланович	Мужской	5	2	2021-09-26
63	Али	Алиев	Омарович	Мужской	5	4	2020-12-03
64	Айлин	Иванова	Алиевна	Женский	2	4	2015-06-20
65	Нурислам	Омаров	Нурисламович	Мужской	7	1	2018-11-01
66	Нурислам	Ким	Нурисламович	Мужской	8	4	2023-11-22
67	Сафия	Алиева	Алдияровна	Женский	8	2	2022-04-25
68	Томирис	Иванова	Нурисламовна	Женский	1	2	2016-09-25
69	Амина	Искакова	Амировна	Женский	1	4	2022-02-24
70	Айым	Омарова	Давидовна	Женский	4	1	2015-04-22
71	Амир	Оспанов	Алдиярович	Мужской	6	1	2023-04-22
72	Медина	Алиева	Алиевна	Женский	2	2	2020-04-18
73	Алихан	Искаков	Давидович	Мужской	7	1	2023-05-22
74	Али	Алиев	Алиевич	Мужской	6	2	2021-10-23
75	Амир	Омаров	Омарович	Мужской	3	4	2024-03-24
76	Али	Манукян	Алиханович	Мужской	8	3	2016-07-10
77	Али	Алиев	Аланович	Мужской	4	3	2015-09-11
78	Алдияр	Ким	Давидович	Мужской	1	2	2017-12-07
79	Айсултан	Омаров	Амирович	Мужской	2	4	2023-11-30
80	Айым	Ахметова	Давидовна	Женский	7	4	2018-08-17
81	Давид	Манукян	Алиевич	Мужской	1	1	2020-12-11
82	Амир	Ахметов	Нурисламович	Мужской	2	1	2019-04-24
83	Амина	Омарова	Амировна	Женский	2	2	2018-05-16
84	Светлана	Манукян	Алихановна	Женский	3	1	2020-01-13
85	Давид	Алиев	Аланович	Мужской	1	4	2017-04-12
86	Айлин	Иванова	Алдияровна	Женский	5	2	2021-01-22
87	Алдияр	Ким	Айсултанович	Мужской	4	1	2017-03-01
88	Медина	Алиева	Алдияровна	Женский	1	2	2020-12-22
89	Омар	Сулейменов	Давидович	Мужской	7	1	2015-11-12
90	Амир	Ким	Алдиярович	Мужской	2	2	2015-04-27
91	Сафия	Иванова	Нурисламовна	Женский	7	4	2022-09-15
92	Алихан	Омаров	Алиханович	Мужской	3	4	2019-10-27
93	Амина	Алиева	Алдияровна	Женский	4	2	2022-05-09
94	Айым	Ахметова	Алиевна	Женский	1	1	2021-11-18
95	Раяна	Оспанова	Алдияровна	Женский	7	1	2023-02-05
96	Раяна	Оспанова	Алиевна	Женский	3	3	2022-04-30
97	Омар	Омаров	Алиханович	Мужской	8	2	2023-08-02
98	Амина	Алиева	Алиевна	Женский	8	2	2021-09-17
99	Алихан	Омаров	Аланович	Мужской	2	3	2017-11-16
100	Айлин	Омарова	Алихановна	Женский	8	4	2021-11-06
\.


--
-- Data for Name: employment_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employment_history (historyid, promotion_date, employee_id) FROM stdin;
1	2020-08-01	1
2	2017-05-09	2
3	2016-04-09	3
4	2024-01-01	4
5	2016-02-26	5
6	2022-05-30	6
7	2020-08-18	7
8	2019-11-10	8
9	2017-08-15	9
10	2021-06-13	10
11	2017-02-22	11
12	2019-11-14	12
13	2023-02-02	13
14	2021-03-11	14
15	2015-08-18	15
16	2022-04-14	16
17	2022-07-28	17
18	2017-03-31	18
19	2018-01-30	19
20	2014-12-26	20
21	2019-03-20	21
22	2020-08-12	22
23	2022-01-17	23
24	2023-04-17	24
25	2019-09-15	25
26	2020-04-07	26
27	2021-12-23	27
28	2019-09-18	28
29	2019-11-07	29
30	2017-06-04	30
31	2023-06-19	31
32	2016-04-17	32
33	2018-07-30	33
34	2020-11-29	34
35	2016-07-03	35
36	2020-01-18	36
37	2022-01-01	37
38	2021-03-18	38
39	2021-04-07	39
40	2017-06-24	40
41	2023-12-16	41
42	2023-04-28	42
43	2020-08-29	43
44	2017-11-28	44
45	2023-04-23	45
46	2015-11-24	46
47	2019-07-09	47
48	2015-09-11	48
49	2023-02-25	49
50	2015-07-05	50
51	2016-12-31	51
52	2022-08-31	52
53	2020-02-20	53
54	2016-08-27	54
55	2021-06-15	55
56	2023-10-29	56
57	2019-04-30	57
58	2016-10-07	58
59	2021-02-22	59
60	2015-12-28	60
61	2022-04-23	61
62	2021-09-26	62
63	2020-12-03	63
64	2015-06-20	64
65	2018-11-01	65
66	2023-11-22	66
67	2022-04-25	67
68	2016-09-25	68
69	2022-02-24	69
70	2015-04-22	70
71	2023-04-22	71
72	2020-04-18	72
73	2023-05-22	73
74	2021-10-23	74
75	2024-03-24	75
76	2016-07-10	76
77	2015-09-11	77
78	2017-12-07	78
79	2023-11-30	79
80	2018-08-17	80
81	2020-12-11	81
82	2019-04-24	82
83	2018-05-16	83
84	2020-01-13	84
85	2017-04-12	85
86	2021-01-22	86
87	2017-03-01	87
88	2020-12-22	88
89	2015-11-12	89
90	2015-04-27	90
91	2022-09-15	91
92	2019-10-27	92
93	2022-05-09	93
94	2021-11-18	94
95	2023-02-05	95
96	2022-04-30	96
97	2023-08-02	97
98	2021-09-17	98
99	2017-11-16	99
100	2021-11-06	100
\.


--
-- Data for Name: job; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job (jobid, jobname) FROM stdin;
1	Менеджер
2	Дизайнер
3	Програмист
4	Бухгалтер
5	Юрист
6	HR
7	Продажи
8	Тестировщик
\.


--
-- Data for Name: salaries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.salaries (salaryid, employee_id, salary) FROM stdin;
1	1	511934
2	2	502648
3	3	724393
4	4	1133782
5	5	1750270
6	6	2828426
7	7	782815
8	8	475386
9	9	2553227
10	10	969105
11	11	2554685
12	12	865960
13	13	1467857
14	14	1136615
15	15	1881746
16	16	1286285
17	17	595592
18	18	1541677
19	19	1633638
20	20	740522
21	21	770004
22	22	2066967
23	23	279803
24	24	1479638
25	25	398260
26	26	2788122
27	27	2666441
28	28	2244869
29	29	789685
30	30	383316
31	31	649626
32	32	2133295
33	33	1990258
34	34	1486638
35	35	2137311
36	36	2187049
37	37	2357673
38	38	1311546
39	39	2829897
40	40	2529714
41	41	1780109
42	42	2172750
43	43	1930824
44	44	1182484
45	45	767361
46	46	2035123
47	47	1951883
48	48	2792710
49	49	898086
50	50	544029
51	51	1773789
52	52	2100736
53	53	2160722
54	54	1871300
55	55	554733
56	56	2700145
57	57	553543
58	58	2600508
59	59	2088481
60	60	2517652
61	61	2284550
62	62	1399608
63	63	663394
64	64	1347511
65	65	1971946
66	66	1439680
67	67	2655176
68	68	2840775
69	69	1171555
70	70	2380450
71	71	2330731
72	72	2665541
73	73	480326
74	74	1915801
75	75	2689024
76	76	1691641
77	77	2378031
78	78	969518
79	79	1753491
80	80	1679935
81	81	843576
82	82	515195
83	83	2546255
84	84	2870775
85	85	778242
86	86	1389352
87	87	2048531
88	88	2082318
89	89	2497011
90	90	2727546
91	91	310430
92	92	800566
93	93	483588
94	94	1951174
95	95	1628287
96	96	2212050
97	97	1788503
98	98	735415
99	99	448576
100	100	1230436
\.


--
-- Name: departments_departmentid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.departments_departmentid_seq', 4, true);


--
-- Name: employees_employee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employees_employee_id_seq', 100, true);


--
-- Name: employment_history_historyid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employment_history_historyid_seq', 100, true);


--
-- Name: job_jobid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_jobid_seq', 8, true);


--
-- Name: salaries_salaryid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.salaries_salaryid_seq', 100, true);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (departmentid);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (employee_id);


--
-- Name: employment_history employment_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employment_history
    ADD CONSTRAINT employment_history_pkey PRIMARY KEY (historyid);


--
-- Name: job job_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (jobid);


--
-- Name: salaries salaries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salaries
    ADD CONSTRAINT salaries_pkey PRIMARY KEY (salaryid);


--
-- Name: employees employees_departmentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_departmentid_fkey FOREIGN KEY (departmentid) REFERENCES public.departments(departmentid);


--
-- Name: employees employees_jobid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_jobid_fkey FOREIGN KEY (jobid) REFERENCES public.job(jobid);


--
-- Name: employment_history employment_history_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employment_history
    ADD CONSTRAINT employment_history_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(employee_id);


--
-- Name: salaries salaries_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salaries
    ADD CONSTRAINT salaries_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(employee_id);


--
-- PostgreSQL database dump complete
--

