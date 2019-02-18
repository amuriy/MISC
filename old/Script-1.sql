/*
select
distinct "name"
from
	"import".z15_line
where tags::text like '%subway%'
and name like '%Line%'
group by "name";


alter table
	"import".z14_line 
	add column color text ;
*/

-- https://en.wikipedia.org/wiki/List_of_New_York_City_Subway_lines#Line_listing


update "import".z15_line	
set color = '#FCCC0A'
where "name" = 'BMT 63rd Street Line' ;

update "import".z15_line	
set color = '#996633'
where "name" = 'BMT Archer Avenue Line' ;

update "import".z15_line	
set color = 'FCCC0A'
where "name" = 'BMT Astoria Line' ;

update "import".z15_line	
set color = 'FCCC0A'
where "name" = 'BMT Brighton / Fourth Avenue Lines' ;


/*

BMT Brighton Line
BMT Broadway Line
BMT Canarsie Line
BMT Fourth Avenue Line
BMT Franklin Avenue Line
BMT Jamaica Line
BMT Myrtle Avenue Line
BMT Nassau Street Line
BMT Sea Beach Line
BMT West End Line
IND 63rd Street Line
IND Archer Avenue Line
IND/BMT Archer Avenue Lines
IND Concourse Line
IND Crosstown Line
IND Culver Line
IND Eighth Avenue Line
IND Fulton Street Line
IND Queens Boulevard Line
IND Rockaway Line
IND Sixth Avenue Line
IRT 42nd Street Line
IRT 42nd Street Line - IRT Lexington Avenue Line connection
IRT Broadway-Seventh Avenue Line
IRT Dyre Avenue Line
IRT Eastern Parkway Line
IRT Flushing Line
IRT Flushing Line (extension)
IRT Jerome Avenue Line
IRT Lenox Avenue Line
IRT Lexington Avenue Line
IRT Lexington Avenue Line (South Ferry Loop)
IRT New Lots Line
IRT Nostrand Avenue Line
IRT Pelham Line
IRT White Plains Road Line
*/
