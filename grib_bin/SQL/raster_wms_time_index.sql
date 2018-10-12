

alter table 
"IS_TEST".temper_gdaltindex_4326
add column
  time_data timestamp(0) without time zone ;  -- Системное поле – дата и время создания объекта


--  -------------------
drop table "IS_TEST".temper_gdaltindex_3857

create table "IS_TEST".temper_gdaltindex_3857
as 
select
objectid, 
filepath, 
time_data,
ST_Transform(shape, 3857) as shape
from "IS_TEST".temper_gdaltindex_4326

ALTER TABLE "IS_TEST".temper_gdaltindex_3857
  OWNER TO "BPD_OWNERS";
GRANT ALL ON TABLE "IS_TEST".temper_gdaltindex_3857 TO "BPD_OWNERS";
GRANT SELECT ON TABLE "IS_TEST".temper_gdaltindex_3857 TO "BPD_READERS";

-- Index: "IS_TEST".sidx_temper_gdaltindex_4326_shape

-- DROP INDEX "IS_TEST".sidx_temper_gdaltindex_4326_shape;

CREATE INDEX sidx_temper_gdaltindex_3857_shape
  ON "IS_TEST".temper_gdaltindex_3857
  USING gist
  (shape);



-- select shape,objectid,filepath,time_data from "IS_TEST"."temper_gdaltindex_3857" as subquery