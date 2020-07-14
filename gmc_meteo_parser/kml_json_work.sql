/*
Количество осадков RK  - gmc_rk_pol_izo_kml
Грозовая активность TS - gmc_ts_pol_izo_kml
Средняя интенсивность осадков RN - gmc_rn_pol_izo_kml
Атмосферное давление PP - gmc_pp_lin_izo_kml (изолинии по зонам/ name, tessellate,extrude,visibility) 
- gmc_pp_pnt_fnd_json (сетка из точек/ name)
Метеорологическая температура TP - gmc_tp_lin_izo_kml (изолинии по зонам/ name, tessellate,extrude,visibility) 
- gmc_tp_pnt_fnd_json (сетка из точек/ name)
Температура точки росы TR - gmc_tr_lin_izo_kml (изолинии по зонам/ name, tessellate,extrude,visibility)
- gmc_tr_pnt_fnd_json (сетка из точек/ name)
Количество облачности CN - gmc_cn_pol_izo_kml 
- gmc_cn_pnt_dat_json (точки "в разброс" и "в самом позднем файле"/name, visibility, vislowbound, instlowbound, cloudamount, winddirection, windspeed, temperature, dewpoint, pressure, precipitation, phenomena) 
Горизонтальная видимость VV - gmc_vv_pol_izo_kml (полигоны "в самом позднем файле"/ name, tessellate,extrude,visibility)
Нижняя граница облачности HH - gmc_hh_pol_izo_kml 
Высота волны SE - gmc_se_pol_izo_kml 
Туман FG - gmc_fg_pol_izo_kml 
Осадки RR - gmc_rr_pol_izo_kml 




ПОЛИГОНЫ 
gmc_rk_pol_izo_kml	
gmc_ts_pol_izo_kml
gmc_rn_pol_izo_kml
gmc_vv_pol_izo_kml 
gmc_hh_pol_izo_kml 
gmc_se_pol_izo_kml 
gmc_fg_pol_izo_kml 
gmc_rr_pol_izo_kml 
gmc_cn_pol_izo_kml 	

*/

CREATE TABLE "is_grib"."gmc_*_pol_izo_kml"
(
    objectid uuid NOT NULL DEFAULT nextval_uuid(),
    shape geometry(MultiPolygon,4326),
    id character varying(255) COLLATE pg_catalog."default" NOT NULL,
    nsi_id character varying(255) COLLATE pg_catalog."default",
    parent_id character varying(255) COLLATE pg_catalog."default",
    class_id character varying(64) COLLATE pg_catalog."default" NOT NULL,
    sign_angle real DEFAULT 0,
    name character varying(255) COLLATE pg_catalog."default",
    label character varying(255) COLLATE pg_catalog."default",
    value real,
    link character varying(255) COLLATE pg_catalog."default",
    create_user character varying(128) COLLATE pg_catalog."default" DEFAULT "current_user"(),
    create_date timestamp with time zone DEFAULT now(),
    update_user character varying(128) COLLATE pg_catalog."default" DEFAULT "current_user"(),
    update_date timestamp with time zone DEFAULT now(),
    system_id uuid DEFAULT '68ea0a10-39d1-11e5-9025-000c29eec56a'::uuid,
    attributes xml,
    classif_id integer,
    libclass_id uuid,
    layer_id uuid,
    time_data timestamp with time zone,
    graph text COLLATE pg_catalog."default",
	tessellate integer,
    extrude integer,
    visibility integer
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE "is_grib"."gmc_*_pol_izo_kml"
    OWNER to bpd_owner;
###ДОБАВЛЯЕМ ДАННЫЕ 
INSERT INTO "is_grib"."gmc_*_pol_izo_kml"(
        id, name, shape, label, value, class_id, tessellate, extrude, visibility)
SELECT  id,'*', ST_Multi(shape), name, name::real, '*' as class_id, tessellate, extrude, visibility
FROM *;
###ДОБАВЛЯЕМ АТРИБУТЫ
	  UPDATE "is_grib"."gmc_*_pol_izo_kml"
SET attributes = XMLPARSE (CONTENT '<attributes>' || case when class_id is null then '' else '<attribute name="class_id" alias="Тип" type="String">' || class_id || '</attribute>' end
|| case when name is null then '' else '<attribute name="name" alias="Наименование" type="String">' || name || '</attribute>' end
|| case when label is null then '' else '<attribute name="label" alias="Подпись" type="String">' || label || '</attribute>' end
|| case when tessellate is null then '' else '<attribute name="tessellate" alias="tessellate" type="String">' || tessellate || '</attribute>' end
|| case when extrude is null then '' else '<attribute name="extrude" alias="extrude" type="String">' || extrude || '</attribute>' end
|| case when visibility is null then '' else '<attribute name="visibility" alias="visibility" type="String">' || visibility || '</attribute>' end
|| '</attributes>')
ИЗОЛИНИИ 
gmc_pp_lin_izo_kml 
gmc_tp_lin_izo_kml 
gmc_tr_lin_izo_kml 

CREATE TABLE "is_grib"."gmc_*_lin_izo_kml"
( objectid uuid NOT NULL DEFAULT nextval_uuid(),
  shape geometry(MultiLineString,4326),
   id character varying(255) COLLATE pg_catalog."default" NOT NULL,
   nsi_id character varying(255) COLLATE pg_catalog."default",
 parent_id character varying(255) COLLATE pg_catalog."default",
   class_id character varying(64) COLLATE pg_catalog."default" NOT NULL,
 sign_angle real DEFAULT 0,
   name character varying(255) COLLATE pg_catalog."default",
   label character varying(255) COLLATE pg_catalog."default",
   value real,
   link character varying(255) COLLATE pg_catalog."default",
   create_user character varying(128) COLLATE pg_catalog."default" DEFAULT "current_user"(),
 create_date timestamp with time zone DEFAULT now(),
 update_user character varying(128) COLLATE pg_catalog."default" DEFAULT "current_user"(),
    update_date timestamp with time zone DEFAULT now(),
   system_id uuid DEFAULT '68ea0a10-39d1-11e5-9025-000c29eec56a'::uuid,
  attributes xml,
    classif_id integer,
  libclass_id uuid,
   layer_id uuid,
    time_data timestamp with time zone,
   graph text COLLATE pg_catalog."default",
    name_zone character varying COLLATE pg_catalog."default",
    tessellate integer,
    extrude integer,
  visibility integer  
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;
ALTER TABLE "is_grib"."gmc_*_lin_izo_kml"
    OWNER to bpd_owner;  
-- ###ОТДЕЛЬНО ПО ЗОНАМ ДОБАВЛЯЕМ S,T,U,V,W,X
INSERT INTO "is_grib"."gmc_*_lin_izo_kml"(
        id, name, shape, label, value, class_id, name_zone, tessellate, extrude, visibility)
SELECT  id, *, ST_Multi(shape), name, name::real, * as class_id, 'S', tessellate, extrude, visibility
FROM *; 
INSERT INTO "is_grib"."gmc_*_lin_izo_kml"(
        id, name, shape, label, value, class_id, name_zone, tessellate, extrude, visibility)
SELECT  id, *, ST_Multi(shape), name, name::real, * as class_id, 'T', tessellate, extrude, visibility
FROM *; 
INSERT INTO "is_grib"."gmc_*_lin_izo_kml"(
        id, name, shape, label, value, class_id, name_zone, tessellate, extrude, visibility)
SELECT  id, *, ST_Multi(shape), name, name::real, * as class_id, 'U', tessellate, extrude, visibility
FROM *; 
INSERT INTO "is_grib"."gmc_*_lin_izo_kml"(
        id, name, shape, label, value, class_id, name_zone, tessellate, extrude, visibility)
SELECT  id, *, ST_Multi(shape), name, name::real, * as class_id, 'V', tessellate, extrude, visibility
FROM *; 
INSERT INTO "is_grib"."gmc_*_lin_izo_kml"(
        id, name, shape, label, value, class_id, name_zone, tessellate, extrude, visibility)
SELECT  id, *, ST_Multi(shape), name, name::real, * as class_id, 'W', tessellate, extrude, visibility
FROM *; 
INSERT INTO "is_grib"."gmc_*_lin_izo_kml"(
        id, name, shape, label, value, class_id, name_zone, tessellate, extrude, visibility)
SELECT  id, *, ST_Multi(shape), name, name::real, * as class_id, 'X', tessellate, extrude, visibility
FROM *; 


-- ###ПЕРЕМЕЩАЕМ ЛИНИИ В ЗОНАХ S,V,X
UPDATE "is_grib"."gmc_*_lin_izo_kml"
	SET shape=st_wrapx(st_shiftlongitude(shape::geometry), 180, -360) 
	WHERE (name_zone='U' or  name_zone='X' or name_zone='V' or name_zone='S');

-- ###ВЫРЕЗАЕМ ЛИШНЕЕ	
UPDATE
"is_grib"."gmc_*_lin_izo_kml" b
set
shape = ST_CollectionExtract(ST_Multi(ST_Intersection(a.shape, (ST_GeomFromText('POLYGON((-180 -90, -180 90, 180 90, 180 -90, -180 -90))', 4326)::geometry))),2)
from
"is_grib"."gmc_*_lin_izo_kml" a
where
a.objectid = b.objectid 

-- ###СШИВАЕМ ПО VALUE (тут сам посмотри еще как сшивать)
UPDATE  "is_grib"."gmc_*_lin_izo_kml"
set 
shape =
SELECT ST_collect(ST_GeometryN(shape, 1)) as shape FROM  "is_grib"."gmc_*_lin_izo_kml"   group by value

-- ###ДОБАВЛЯЕМ АТРИБУТЫ 		   
 UPDATE "is_grib"."gmc_*_lin_izo_kml"
SET attributes = XMLPARSE (CONTENT '<attributes>' || case when class_id is null then '' else '<attribute name="class_id" alias="Тип" type="String">' || class_id || '</attribute>' end
|| case when name is null then '' else '<attribute name="name" alias="Наименование" type="String">' || name || '</attribute>' end
|| case when label is null then '' else '<attribute name="label" alias="Подпись" type="String">' || label || '</attribute>' end
|| case when tessellate is null then '' else '<attribute name="tessellate" alias="tessellate" type="String">' || tessellate || '</attribute>' end
|| case when extrude is null then '' else '<attribute name="extrude" alias="extrude" type="String">' || extrude || '</attribute>' end
|| case when visibility is null then '' else '<attribute name="visibility" alias="visibility" type="String">' || visibility || '</attribute>' end
|| '</attributes>')

-- ТОЧКИ В УЗЛАХ СЕТКИ
gmc_tr_pnt_fnd_json (сетка из точек/ name)
gmc_pp_pnt_fnd_json (сетка из точек/ name)
gmc_tp_pnt_fnd_json (сетка из точек/ name)
CREATE TABLE "is_grib"." gmc_*_pnt_fnd_json "
(
    objectid uuid NOT NULL DEFAULT nextval_uuid(),
    shape geometry(MultiPoint,4326),
    id character varying(255) COLLATE pg_catalog."default" NOT NULL,
    nsi_id character varying(255) COLLATE pg_catalog."default",
    parent_id character varying(255) COLLATE pg_catalog."default",
    class_id character varying(64) COLLATE pg_catalog."default" NOT NULL,
    sign_angle real DEFAULT 0,
    name character varying(255) COLLATE pg_catalog."default",
    label character varying(255) COLLATE pg_catalog."default",
    value real,
    link character varying(255) COLLATE pg_catalog."default",
    create_user character varying(128) COLLATE pg_catalog."default" DEFAULT "current_user"(),
    create_date timestamp with time zone DEFAULT now(),
    update_user character varying(128) COLLATE pg_catalog."default" DEFAULT "current_user"(),
    update_date timestamp with time zone DEFAULT now(),
    system_id uuid DEFAULT '68ea0a10-39d1-11e5-9025-000c29eec56a'::uuid,
    attributes xml,
    classif_id integer,
    libclass_id uuid,
    layer_id uuid,
    time_data timestamp with time zone,
    graph text COLLATE pg_catalog."default",
    name_zone character varying COLLATE pg_catalog."default"
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE "is_grib"." gmc_*_pnt_fnd_json "
   OWNER to bpd_owner;


-- ###ОТДЕЛЬНО ПО ЗОНАМ ДОБАВЛЯЕМ S,T,U,V,W,X
INSERT INTO "is_grib"." gmc_*_pnt_fnd_json " (
        id, name, shape, label, value, class_id, name_zone)
SELECT  id,*, ST_Multi(shape), name, name::real, * as class_id, 'S'
FROM *; 
INSERT INTO "is_grib"." gmc_*_pnt_fnd_json " (
        id, name, shape, label, value, class_id, name_zone)
SELECT  id,*, ST_Multi(shape), name, name::real, * as class_id, 'T'
FROM *; 
INSERT INTO "is_grib"." gmc_*_pnt_fnd_json " (
        id, name, shape, label, value, class_id, name_zone)
SELECT  id,*, ST_Multi(shape), name, name::real, * as class_id, 'U'
FROM *; 
INSERT INTO "is_grib"." gmc_*_pnt_fnd_json " (
        id, name, shape, label, value, class_id, name_zone)
SELECT  id,*, ST_Multi(shape), name, name::real, * as class_id, 'V'
FROM *; 
INSERT INTO "is_grib"." gmc_*_pnt_fnd_json " (
        id, name, shape, label, value, class_id, name_zone)
SELECT  id,*, ST_Multi(shape), name, name::real, * as class_id, 'W'
FROM *; 
INSERT INTO "is_grib"." gmc_*_pnt_fnd_json " (
        id, name, shape, label, value, class_id, name_zone)
SELECT  id,*, ST_Multi(shape), name, name::real, * as class_id, 'X'
FROM *; 


-- ###ДОБАВЛЯЕМ АТРИБУТЫ 	
UPDATE "is_grib"." gmc_*_pnt_fnd_json "
SET attributes = XMLPARSE (CONTENT '<attributes>' || case when class_id is null then '' else '<attribute name="class_id" alias="Тип" type="String">' || class_id || '</attribute>' end
|| case when name is null then '' else '<attribute name="name" alias="Наименование" type="String">' || name || '</attribute>' end
|| case when label is null then '' else '<attribute name="label" alias="Подпись" type="String">' || label || '</attribute>' end
|| case when name_zone is null then '' else '<attribute name="name_zone" alias="Сегмент сетки" type="String">' || name_zone || '</attribute>' end
|| '</attributes>')



-- ТОЧКИ DAT JSON
gmc_cn_pnt_dat_json (точки "в разброс"/name, visibility, vislowbound, instlowbound, cloudamount, winddirection, windspeed, temperature, dewpoint, pressure, precipitation, phenomena)
 CREATE TABLE "is_grib"."gmc_cn_pnt_dat_json"
(
    objectid uuid NOT NULL DEFAULT nextval_uuid(),
    shape geometry(MultiPoint,4326),
    id character varying(255) COLLATE pg_catalog."default" NOT NULL,
    nsi_id character varying(255) COLLATE pg_catalog."default",
    parent_id character varying(255) COLLATE pg_catalog."default",
    class_id character varying(64) COLLATE pg_catalog."default" NOT NULL,
    sign_angle real DEFAULT 0,
    name character varying(255) COLLATE pg_catalog."default",
    label character varying(255) COLLATE pg_catalog."default",
    value real,
    link character varying(255) COLLATE pg_catalog."default",
    create_user character varying(128) COLLATE pg_catalog."default" DEFAULT "current_user"(),
    create_date timestamp with time zone DEFAULT now(),
    update_user character varying(128) COLLATE pg_catalog."default" DEFAULT "current_user"(),
    update_date timestamp with time zone DEFAULT now(),
    system_id uuid DEFAULT '68ea0a10-39d1-11e5-9025-000c29eec56a'::uuid,
    attributes xml,
    classif_id integer,
    libclass_id uuid,
    layer_id uuid,
    time_data timestamp with time zone,
    graph text COLLATE pg_catalog."default",
Visibility character varying(128) COLLATE pg_catalog."default",
visLowBound character varying(128) COLLATE pg_catalog."default",
instLowBound character varying(128) COLLATE pg_catalog."default",
CloudAmount character varying(128) COLLATE pg_catalog."default",
WindDirection character varying(128) COLLATE pg_catalog."default",
WindSpeed character varying(128) COLLATE pg_catalog."default",
Temperature character varying(128) COLLATE pg_catalog."default",
DewPoint character varying(128) COLLATE pg_catalog."default",
Pressure character varying(128) COLLATE pg_catalog."default",
Precipitation character varying(128) COLLATE pg_catalog."default",
Phenomena character varying(128) COLLATE pg_catalog."default"
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE "is_grib"."gmc_cn_pnt_dat_json"
    OWNER to bpd_owner;
	
INSERT INTO "is_grib"." gmc_cn_pnt_dat_json"(
        id, name, shape, label, class_id, visibility, vislowbound, instlowbound, cloudamount, winddirection, windspeed, temperature, dewpoint, pressure, precipitation, phenomena)
SELECT  id,'Количество облачности', ST_Multi(shape), name, 'CN' as class_id,
substring(data,strpos(data,'{ "Visibility": ')+length('{ "Visibility": '),strpos(data,'"visLowBound": ')-length(' ,  "visLowBound": ')) as Visibility,
substring(data,(strpos(data,'"visLowBound": ')+length(' "visLowBound": ')),(strpos(data,'", "instLowBound": ')-(strpos(data,'"visLowBound": '))-length(' "visLowBound": '))) as visLowBound,
substring(data,(strpos(data,'"instLowBound": ')+length(' "instLowBound": ')),(strpos(data,'", "CloudAmount": ')-(strpos(data,'"instLowBound": '))-length(' "instLowBound": '))) as instLowBound,
substring(data,(strpos(data,'"CloudAmount": ')+length('"CloudAmount": ')),(strpos(data,' "WindDirection": ')-(strpos(data,'"CloudAmount": '))-length(' "CloudAmount": '))) as CloudAmount,
substring(data,(strpos(data,'"WindDirection": ')+length('"WindDirection": ')),(strpos(data,' "WindSpeed": ')-(strpos(data,'"WindDirection": '))-length(' "WindDirection": '))) as WindDirection,
substring(data,(strpos(data,'"WindSpeed": ')+length('"WindSpeed": ')),(strpos(data,' "Temperature": ')-(strpos(data,'"WindSpeed": '))-length(' "WindSpeed": '))) as WindSpeed,
substring(data,(strpos(data,'"Temperature": ')+length('"Temperature": ')),(strpos(data,' "DewPoint": ')-(strpos(data,'"Temperature": '))-length(' "Temperature": '))) as Temperature,
substring(data,(strpos(data,'"DewPoint": ')+length('"DewPoint": ')),(strpos(data,' "Pressure": ')-(strpos(data,'"DewPoint": '))-length(' "DewPoint": '))) as DewPoint,
substring(data,(strpos(data,'"Pressure": ')+length('"Pressure": ')),(strpos(data,' "Precipitation": ')-(strpos(data,'"Pressure": '))-length(' "Pressure": '))) as Pressure,
substring(data,(strpos(data,'"Precipitation": ')+length('"Precipitation": ')),(strpos(data,' "Phenomena": ')-(strpos(data,'"Precipitation": '))-length(' "Precipitation": '))) as Precipitation,
substring(data,(strpos(data,'"Phenomena": ')+length('"Phenomena": ')),(strpos(data,' }')-(strpos(data,' "Phenomena": '))-length(' "Phenomena": '))) as Phenomena
FROM *; 

UPDATE "is_grib"." gmc_cn_pnt_dat_json"
SET attributes = XMLPARSE (CONTENT '<attributes>' || case when class_id is null then '' else '<attribute name="class_id" alias="Тип" type="String">' || class_id || '</attribute>' end
|| case when name is null then '' else '<attribute name="name" alias="Наименование" type="String">' || name || '</attribute>' end
|| case when visibility is null then '' else '<attribute name="visibility" alias="Видимость" type="String">' || visibility || '</attribute>' end
|| case when vislowbound is null then '' else '<attribute name="vislowbound" alias="vislowbound" type="String">' || vislowbound || '</attribute>' end
|| case when instlowbound is null then '' else '<attribute name="instlowbound" alias="instlowbound" type="String">' || instlowbound || '</attribute>' end
|| case when cloudamount is null then '' else '<attribute name="cloudamount" alias="Количество облаков" type="String">' || cloudamount || '</attribute>' end
|| case when winddirection is null then '' else '<attribute name="winddirection" alias="Направление ветра" type="String">' || winddirection || '</attribute>' end
|| case when windspeed is null then '' else '<attribute name="windspeed" alias="Скорость ветра" type="String">' || windspeed || '</attribute>' end
|| case when temperature is null then '' else '<attribute name="temperature" alias="Температура" type="String">' || temperature || '</attribute>' end
|| case when dewpoint is null then '' else '<attribute name="dewpoint" alias="Точка росы" type="String">' || dewpoint || '</attribute>' end
|| case when pressure is null then '' else '<attribute name="pressure" alias="Давление" type="String">' || pressure || '</attribute>' end
|| case when precipitation is null then '' else '<attribute name="precipitation" alias="Осадки" type="String">' || precipitation || '</attribute>' end
|| case when phenomena is null then '' else '<attribute name="phenomena" alias="phenomena" type="String">' || phenomena || '</attribute>' end
|| '</attributes>')
