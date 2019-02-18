delete from
is_grib.grib_vis_time_index 
where objectid in
(
select objectid from (
  SELECT objectid,
  ROW_NUMBER() OVER(PARTITION BY time_data) AS Row
  FROM is_grib.grib_vis_time_index 
) dups
where 
dups.Row > 1
) ;