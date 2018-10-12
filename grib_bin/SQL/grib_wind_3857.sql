create table "IS_STUFF".grib_wind_3857
as 
select
objectid, 
magn_res1, 
wind_dir_r,
ST_Transform(shape, 3857) as shape
from "IS_STUFF".grib_wind

ALTER TABLE "IS_STUFF".grib_wind_3857
  OWNER TO bpd_owner;
GRANT SELECT ON TABLE "IS_STUFF".grib_wind_3857 TO "BPD_READERS";
GRANT ALL ON TABLE "IS_STUFF".grib_wind_3857 TO bpd_owner;

-- Index: "IS_STUFF".sidx_grib_wind_shape

-- DROP INDEX "IS_STUFF".sidx_grib_wind_shape;

CREATE INDEX sidx_grib_wind_3857_shape
  ON "IS_STUFF".grib_wind_3857
  USING gist
  (shape);