
update "IS_STUFF".grib_wind2 
set  rhumb = concat('➡ ',rhumb) 
where rhumb = 'З'
;
update "IS_STUFF".grib_wind2 
set  rhumb = concat('⬅ ',rhumb) 
where rhumb = 'В'
;
update "IS_STUFF".grib_wind2 
set  rhumb = concat('⬇ ',rhumb) 
where rhumb = 'С'
;
update "IS_STUFF".grib_wind2 
set  rhumb = concat('⬆ ',rhumb) 
where rhumb = 'Ю'
;
update "IS_STUFF".grib_wind2 
set  rhumb = concat('⬊ ',rhumb) 
where rhumb = 'СЗ'
;
update "IS_STUFF".grib_wind2 
set  rhumb = concat('⬈ ',rhumb) 
where rhumb = 'ЮЗ'
;
update "IS_STUFF".grib_wind2 
set  rhumb = concat('⬋ ',rhumb) 
where rhumb = 'СВ'
;
update "IS_STUFF".grib_wind2 
set  rhumb = concat('⬉ ',rhumb) 
where rhumb = 'ЮВ'
;
-- ----------------------------

update "IS_STUFF".grib_wind 
set  rhumb = concat('➡ ',rhumb) 
where rhumb = 'З' ;
;
update "IS_STUFF".grib_wind 
set  rhumb = concat('⬅ ',rhumb) 
where rhumb = 'В' ;
;
update "IS_STUFF".grib_wind 
set  rhumb = concat('⬇ ',rhumb) 
where rhumb = 'С'
;
update "IS_STUFF".grib_wind 
set  rhumb = concat('⬆ ',rhumb) 
where rhumb = 'Ю'
;
update "IS_STUFF".grib_wind 
set  rhumb = concat('⬊ ',rhumb) 
where rhumb = 'СЗ'
;
update "IS_STUFF".grib_wind 
set  rhumb = concat('⬈ ',rhumb) 
where rhumb = 'ЮЗ'
;
update "IS_STUFF".grib_wind 
set  rhumb = concat('⬋ ',rhumb) 
where rhumb = 'СВ'
;
update "IS_STUFF".grib_wind 
set  rhumb = concat('⬉ ',rhumb) 
where rhumb = 'ЮВ'


