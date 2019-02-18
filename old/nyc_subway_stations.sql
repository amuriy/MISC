alter table
	"import".z15_point 
	add column color text ;


update 
	"import".z15_point
set 
	color = tmp.lcolor	
from
(
select
	p.id as pid,
	l.color as lcolor
from
	"import".z15_point p
join																				
	"import".z15_line l
on
	ST_DWithin(p.geom_data, l.geom_data, 50)																			
where 
	l.object_category = 2 
	and l.object_type = 6
	and p.object_category = 5
	and p.object_type = 4
) as tmp
where
	id = tmp.pid
	and object_category = 5
	and object_type = 4
;



-- select *
-- from
-- "import".z15_point
-- where
-- 	 object_category = 5
-- 	and object_type = 4
