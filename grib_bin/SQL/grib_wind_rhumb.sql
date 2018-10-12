ALTER TABLE "IS_STUFF".grib_wind add speed_ms numeric
ALTER TABLE "IS_STUFF".grib_wind add speed_kn_raw numeric

UPDATE "IS_STUFF".grib_wind set rhumb = 'Ю' where (direct >= -22.5 and direct < 22.5)
UPDATE "IS_STUFF".grib_wind set rhumb = 'ЮЗ' where (direct >= 22.5 and direct < 67.5)
UPDATE "IS_STUFF".grib_windset rhumb = 'З' where (direct >= 67.5 and direct < 112.5)
UPDATE "IS_STUFF".grib_wind set rhumb = 'СЗ' where (direct >= 112.5 and direct < 157.5)
UPDATE "IS_STUFF".grib_wind set rhumb = 'С' where direct >= 157.5 
UPDATE "IS_STUFF".grib_wind set rhumb = 'С' where direct < -157.5
UPDATE "IS_STUFF".grib_wind set rhumb = 'СВ' where (direct >= -157.5 and direct < -112.5)
UPDATE "IS_STUFF".grib_wind set rhumb = 'В' where (direct >= -112.5 and direct < -67.5)
UPDATE "IS_STUFF".grib_wind set rhumb = 'ЮВ' where (direct >= -67.5 and direct < -22.5)

UPDATE "IS_STUFF".grib_wind set speed_ms = speed
UPDATE "IS_STUFF".grib_wind set speed_kn_raw = speed_kn

UPDATE "IS_STUFF".grib_wind set rhumb = null where speed_kn <= 2

UPDATE "IS_STUFF".grib_wind set speed_ms = round(speed, 1), speed_kn = round(speed_kn_raw, 1)

ALTER TABLE "IS_STUFF".grib_wind RENAME COLUMN speed TO speed_ms
