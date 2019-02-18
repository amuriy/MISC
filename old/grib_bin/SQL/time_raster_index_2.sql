-- drop TABLE "IS_TEST".time_raster_index_2


CREATE TABLE "IS_TEST".time_raster_index_2
(
  objectid serial NOT NULL,
  shape geometry(Polygon,4326),
  location character varying(254),
  time_data timestamp(0) without time zone DEFAULT now(),
  CONSTRAINT time_raster_index_2_pkey PRIMARY KEY (objectid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE "IS_TEST".time_raster_index_2
  OWNER TO "BPD_OWNERS";
GRANT ALL ON TABLE "IS_TEST".time_raster_index_2 TO "BPD_OWNERS";
GRANT SELECT ON TABLE "IS_TEST".time_raster_index_2 TO "BPD_READERS";