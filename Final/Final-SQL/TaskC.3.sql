-- Report 1.
SELECT b.facultyid, m.Month_Des, SUM(b.num_of_booking) as Total_Booking,
TO_CHAR (SUM(SUM(num_of_booking)) OVER
(ORDER BY b.facultyid, to_date(m.Month_Des, 'Month')
ROWS UNBOUNDED PRECEDING),
'9,999,999,999') AS CUM_booking
FROM bookingfact_V1 b, monthdim m
WHERE b.facultyid = 'FIT' and b.monthid = m.monthid
GROUP BY b.facultyid, m.Month_Des
ORDER BY MIN(m.monthid);

-- Report 2. 
SELECT 
DECODE (GROUPING(teamid), 1, 'All Team', teamid) as teamid, 
DECODE (GROUPING(carbodytype), 1, 'All Car Body Types', carbodytype) as carbodytype, 
sum(num_of_main_record) as total_number_of_maintenance,
sum(main_cost) as total_maintenance_cost
FROM MaintenanceFact_V1
WHERE TEAMID = 'T002' OR TEAMID ='T003'
GROUP BY CUBE(teamid, carbodytype);

-- Report 3. 
WITH  report_three as(
Select af.ERRORCODE, bridge.REGISTRATIONNO,
bridge.CARBODYTYPE, sum(af.NUM_OF_ACCIDENT) AS Total_number_of_accidents,
    DENSE_RANK() OVER (
    PARTITION BY ERRORCODE
    ORDER BY sum(af.NUM_OF_ACCIDENT) DESC
) AS ACCIDENT_RANK
FROM accidentfact_v1 af, 
(
select ca.registrationno as registrationno , carbodytype , ca.accidentid as accidentid
from cardim c , CarAccidentDIM ca, accidentinfodim_V1 ai
where c.registrationno = ca.registrationno AND ai.accidentid = ca.accidentid
) bridge
where af.accidentid  = bridge.accidentid
GROUP BY ERRORCODE, REGISTRATIONNO, CARBODYTYPE
) SELECT *
FROM report_three
WHERE accident_rank in (1,2,3);

-- Report 4. 
SELECT carbodytype, 
DECODE (GROUPING(ageid), 1, 'All Age groups', ageid) as age_group, 
DECODE (GROUPING(facultyid), 1, 'All faculties', facultyid) as faculty_id, 
SUM(num_of_booking) as total_booking 
FROM BookingFACT_V1 bf
WHERE carbodytype = 'People Mover' 
GROUP BY carbodytype, CUBE(ageid, facultyid);

-- Report 5.
SELECT 
DISTINCT DECODE (GROUPING(facultyid), 1, 'All Faculties', facultyid) as facultyid,
DECODE (GROUPING(carbodytype), 1, 'All Car Body Types', carbodytype) as carbodytype, 
DECODE (GROUPING(monthid), 1, 'All Month', monthid) as monthid, 
SUM(num_of_booking) as count
FROM bookingfact_V1
GROUP BY ROLLUP(facultyid,
carbodytype,
monthid)
ORDER BY facultyid,
carbodytype,
monthid;

-- Report 6. 
SELECT 
DISTINCT facultyid,
DECODE (GROUPING(carbodytype), 1, 'All Car Body Types', carbodytype) as carbodytype, 
DECODE (GROUPING(monthid), 1, 'All Month', monthid) as monthid, 
sum(num_of_booking) as count
FROM bookingfact_V1
GROUP BY facultyid, ROLLUP(
carbodytype,
monthid)
ORDER BY facultyid,
carbodytype,
monthid;

-- Report 7. 
Select MONTHID, SUM(NUM_OF_BOOKING) AS Num_Booking,
 TO_CHAR(AVG(SUM(NUM_OF_BOOKING))
 OVER(ORDER BY MONTHID ROWS 2 PRECEDING),
 '9,999,999.99') AS Moving_2_Months_Avg
From bookingfact_V1
Group By MONTHID;

-- Report 8.
 
SELECT maintenancetype, teamid, 
SUM(num_of_main_record) AS total_num_of_main_record, 
to_char(SUM(main_cost), '9,999,999,999') AS total_main_cost,
TO_CHAR (SUM(SUM(main_cost)) OVER
(ORDER BY maintenancetype, teamid
ROWS UNBOUNDED PRECEDING), '9,999,999,999') AS cum_total_main_cost 
FROM maintenancefact_v1
GROUP BY maintenancetype, teamid;