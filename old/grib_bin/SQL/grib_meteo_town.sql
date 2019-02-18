-- 
-- insert into "IS_STUFF".osm_towns_rus 
-- (objectid,
-- shape,
-- admin_leve,
-- name
-- )
-- select
-- max(objectid)+1 as objectid,
-- shape,
-- admin_leve,
-- name
-- from
-- "IS_STUFF".osm_towns_rus
-- where name = 'Москва'
-- group by objectid
--  ;

-- 
-- 
-- update "IS_STUFF".osm_towns_rus 
-- set time_data = '2018-04-07'
-- where name = 'Москва' 
-- and objectid = '113237'
-- ;
-- 
-- 
-- 
-- update "IS_STUFF".osm_towns_rus 
-- set tmp = '2'
-- where name = 'Москва' 
-- and objectid = '113237'
-- ;
-- 





-- 
-- select
-- *
-- from
-- "IS_STUFF".osm_towns_rus
-- where name = 'Москва'
-- group by objectid
--  ;

-- 
-- 
-- select * from
-- "IS_STUFF".osm_towns_rus_new
-- where name = 'Москва'
-- ;
-- 
-- 
-- INSERT INTO "IS_STUFF".osm_towns_rus_new
-- SELECT (a #= hstore('objectid', '999999')).* 
-- FROM 
-- "IS_STUFF".osm_towns_rus_new a 
-- WHERE objectid = '113236';
-- 
-- 
-- select 
-- nextval(pg_get_serial_sequence('"IS_STUFF".osm_towns_rus_new', 'objectid'))
-- 





drop table "IS_STUFF".osm_towns_rus2

CREATE TABLE "IS_STUFF".osm_towns_rus2
(
  objectid serial NOT NULL,
  shape geometry(Point,4326),
  admin_leve character varying(254),
  name character varying(254),
  population integer,
  time_data character varying(254),
  temper double precision,
  CONSTRAINT osm_towns_rus2_pkey PRIMARY KEY (objectid)
)


INSERT INTO "IS_STUFF".osm_towns_rus2 (shape,admin_leve,name,population,time_data,temper) VALUES (ST_GeomFromText('POINT (37.617660594763585 55.75071779471552)',4326),'2','Москва',12380700,'2018-04-12 15:00:00',9.00000000 ) ;
INSERT INTO "IS_STUFF".osm_towns_rus2 (shape,admin_leve,name,population,time_data,temper) VALUES (ST_GeomFromText('POINT (37.617660594763585 55.75071779471552)',4326),'2','Москва',12380700,'2018-04-13 15:00:00',9.00000000 ) ;
INSERT INTO "IS_STUFF".osm_towns_rus2 (shape,admin_leve,name,population,time_data,temper) VALUES (ST_GeomFromText('POINT (37.617660594763585 55.75071779471552)',4326),'2','Москва',12380700,'2018-04-14 15:00:00',10.00000000 ) ;






















