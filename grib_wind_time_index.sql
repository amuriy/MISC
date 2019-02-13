--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.14
-- Dumped by pg_dump version 9.5.14

-- Started on 2019-02-13 13:37:40 MSK

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
--
-- TOC entry 3632 (class 0 OID 63990)
-- Dependencies: 198
-- Data for Name: grib_wind_time_index; Type: TABLE DATA; Schema: is_grib; Owner: postgres
--

INSERT INTO is_grib.grib_wind_time_index (objectid, time_data, id, shape, location) VALUES (1, '2019-02-13 03:00:00', NULL, '0103000020E6100000010000000500000000000000008066C0000000000080564000000000008066400000000000805640000000000080664000000000008056C000000000008066C000000000008056C000000000008066C00000000000805640', '/gip/data/grib/wind_speed_10m_2019021303.tif');
INSERT INTO is_grib.grib_wind_time_index (objectid, time_data, id, shape, location) VALUES (2, '2019-02-13 15:00:00', NULL, '0103000020E6100000010000000500000000000000008066C0000000000080564000000000008066400000000000805640000000000080664000000000008056C000000000008066C000000000008056C000000000008066C00000000000805640', '/gip/data/grib/wind_speed_10m_2019021315.tif');
INSERT INTO is_grib.grib_wind_time_index (objectid, time_data, id, shape, location) VALUES (3, '2019-02-13 09:00:00', NULL, '0103000020E6100000010000000500000000000000008066C0000000000080564000000000008066400000000000805640000000000080664000000000008056C000000000008066C000000000008056C000000000008066C00000000000805640', '/gip/data/grib/wind_speed_10m_2019021309.tif');


-- Completed on 2019-02-13 13:37:40 MSK

--
-- PostgreSQL database dump complete
--

