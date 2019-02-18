
-- 
-- alter table "IS_STUFF".grib_wind2 
--     drop column direct_kn ;

alter table "IS_STUFF".grib_wind2 
    add column speed_kn numeric; 

update "IS_STUFF".grib_wind2 
    set speed_kn = speed * 1.943844 ;