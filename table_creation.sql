-- Table: public.chartevents_filter

-- DROP TABLE IF EXISTS public.chartevents_filter;

CREATE TABLE IF NOT EXISTS public.chartevents_filter
(
    subject_id integer,
    hadm_id integer,
    stay_id integer,
    caregiver_id integer,
    charttime timestamp without time zone,
    storetime timestamp without time zone,
    itemid integer,
    value text COLLATE pg_catalog."default",
    valuenum double precision,
    valueuom character varying(20) COLLATE pg_catalog."default",
    warning boolean,
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    CONSTRAINT chartevents_filter_pkey PRIMARY KEY (id)
)

-- TABLESPACE pg_default;

-- ALTER TABLE IF EXISTS public.chartevents_filter
--     OWNER to postgres;


CREATE TABLE public.icustays
(
    subject_id integer,
    hadm_id integer,
    stay_id integer NOT NULL,
    first_careunit character varying(100),
    last_careunit character varying(100),
    intime timestamp without time zone,
    outtime timestamp without time zone,
    los double precision,
    PRIMARY KEY (stay_id)
)

-- TABLESPACE pg_default;

-- ALTER TABLE IF EXISTS public.icustays
--     OWNER to postgres;

CREATE TABLE public.patients
(
    subject_id integer NOT NULL,
    gender "char",
    anchor_age integer,
    anchor_year integer,
    anchor_year_group character varying(50),
    dod date,
    PRIMARY KEY (subject_id)
)

-- TABLESPACE pg_default;

-- ALTER TABLE IF EXISTS public.patients
--     OWNER to postgres;

COPY public.chartevents_filter 
    (subject_id, hadm_id, stay_id, caregiver_id, charttime, storetime, itemid, value, valuenum, valueuom, warning)
FROM 'chartevents.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"',
    ESCAPE ''''
);

COPY public.icustays 
    (subject_id, hadm_id, stay_id, first_careunit, last_careunit, intime, outtime, los)
FROM 'icustays.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"',
    ESCAPE ''''
);