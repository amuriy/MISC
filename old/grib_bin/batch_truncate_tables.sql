﻿DO $$
DECLARE
    tables CURSOR FOR
       SELECT tablename
       FROM pg_tables
       WHERE schemaname = 'is_grib'
       and tablename LIKE 'grib%'
       and tablename not like '%grib_wind_speed_dir%'
       and tablename not like '%grib_towns%' ;
BEGIN
    FOR table_record IN tables LOOP
	EXECUTE 'TRUNCATE TABLE ' || '"is_grib".' || '"' || table_record.tablename || '" RESTART IDENTITY;' ;	
    END LOOP;
END$$;




