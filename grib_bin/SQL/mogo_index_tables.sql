-- DROP TABLE is_mogo.grib_precip_time_index;
-- DROP TABLE is_mogo.grib_temper_time_index;
-- DROP TABLE is_mogo.grib_wind_time_index;
-- 
-- 


CREATE TABLE is_mogo.grib_precip_time_index
(
  objectid serial NOT NULL,
  shape geometry(Polygon,4326),
  location character varying(254),
  time_data timestamp(0) without time zone DEFAULT now(),
  CONSTRAINT grib_precip_time_index_pkey PRIMARY KEY (objectid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE is_mogo.grib_precip_time_index
  OWNER TO "BPD_OWNERS";
GRANT ALL ON TABLE is_mogo.grib_precip_time_index TO "BPD_OWNERS";
GRANT SELECT ON TABLE is_mogo.grib_precip_time_index TO "BPD_READERS";



CREATE TABLE is_mogo.grib_temper_time_index
(
  objectid serial NOT NULL,
  shape geometry(Polygon,4326),
  location character varying(254),
  time_data timestamp(0) without time zone DEFAULT now(),
  CONSTRAINT grib_temper_time_index_pkey PRIMARY KEY (objectid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE is_mogo.grib_temper_time_index
  OWNER TO "BPD_OWNERS";
GRANT ALL ON TABLE is_mogo.grib_temper_time_index TO "BPD_OWNERS";
GRANT SELECT ON TABLE is_mogo.grib_temper_time_index TO "BPD_READERS";


CREATE TABLE is_mogo.grib_wind_time_index
(
  objectid serial NOT NULL,
  shape geometry(Polygon,4326),
  location character varying(254),
  time_data timestamp(0) without time zone DEFAULT now(),
  CONSTRAINT grib_wind_time_index_pkey PRIMARY KEY (objectid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE is_mogo.grib_wind_time_index
  OWNER TO "BPD_OWNERS";
GRANT ALL ON TABLE is_mogo.grib_wind_time_index TO "BPD_OWNERS";
GRANT SELECT ON TABLE is_mogo.grib_wind_time_index TO "BPD_READERS";


