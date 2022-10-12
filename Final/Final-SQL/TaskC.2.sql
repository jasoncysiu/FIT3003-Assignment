-- ========================= ShareDIM ==================================
-- DIM: CarbodyDIM 
DROP TABLE CarBodyTypeDIM CASCADE CONSTRAINTS PURGE; 
CREATE TABLE CarBodyTypeDIM AS 
(SELECT DISTINCT(CARBODYTYPE), numseats FROM moncity.car);

-- ========================= BookingFact ===============================
-- DIM: PassengerDIM 
DROP TABLE PassengerDIM CASCADE CONSTRAINTS PURGE;
CREATE TABLE PassengerDIM 
	AS (SELECT PASSENGERID, PASSENGERAGE
FROM Clean_passenger
);

-- DIM: DateDIM 
DROP TABLE DateDIM CASCADE CONSTRAINTS PURGE;
CREATE TABLE DateDIM 
AS (SELECT BOOKINGDATE
FROM Clean_Booking
);

-- DIM: FacultyDIM 
DROP TABLE FacultyDIM CASCADE CONSTRAINTS PURGE; 
CREATE TABLE FacultyDIM AS
(SELECT FACULTYID, FACULTYNAME
FROM moncity.faculty);

-- ========================= MaintenanceFact ===============================
-- DIM: MaintenanceTypeDIM 
DROP TABLE MaintenanceTypeDIM CASCADE CONSTRAINTS PURGE; 
CREATE TABLE MaintenanceTypeDIM AS 
(SELECT maintenancetype
FROM moncity.maintenancetype);

-- DIM: (B) MaintenanceTeamDIM_V2 
DROP TABLE MaintenanceTeamDIM_V2 CASCADE CONSTRAINTS PURGE; 
CREATE TABLE MaintenanceTeamDIM_V2 AS 
(SELECT TEAMID 
FROM moncity.maintenanceTeam 
);

-- DIM: (B) BridgeTable 
DROP TABLE BridgeTable CASCADE CONSTRAINTS PURGE; 
CREATE TABLE BridgeTable
AS (SELECT * FROM moncity.belongto);

-- DIM: (B) ResearchCenterDIM
DROP TABLE ResearchCenterDIM  CASCADE CONSTRAINTS PURGE;
CREATE TABLE ResearchCenterDIM 
AS(
SELECT CENTERID, CENTERNAME
FROM moncity.researchcenter
);

-- DIM: MaintenanceDIM 
DROP TABLE MaintenanceDIM CASCADE CONSTRAINTS PURGE;
CREATE TABLE MaintenanceDIM 
AS(
SELECT maintenanceid
FROM Clean_maintenance
);

-- ========================= AccidentFact ===============================

-- DIM: AccidentZoneDIM
DROP TABLE AccidentZoneDIM CASCADE CONSTRAINTS PURGE;
CREATE TABLE AccidentZoneDIM AS
(SELECT DISTINCT accidentzone
FROM clean_accidentinfo);

-- DIM: AccidentInfoDIM_V2
DROP TABLE AccidentInfoDIM_V2 CASCADE CONSTRAINTS PURGE; 
CREATE TABLE AccidentInfoDIM_V2 AS 
(
SELECT clean_accidentinfo.accidentid
FROM clean_accidentinfo 
);

-- DIM: CarAccidentDIM 
DROP TABLE CarAccidentDIM CASCADE CONSTRAINTS PURGE; 
CREATE TABLE CarAccidentDIM AS
(SELECT REGISTRATIONNO, accidentid FROM moncity.caraccident);

-- DIM: ErrorDIM
DROP TABLE ErrorDIM CASCADE CONSTRAINTS PURGE; 
CREATE TABLE ErrorDIM AS 
(SELECT errorcode FROM moncity.error);

-- DIM: CarDamageSeverityDIM
DROP TABLE CarDamageSeverityDIM CASCADE CONSTRAINTS PURGE; 
CREATE TABLE CarDamageSeverityDIM AS 
(SELECT DISTINCT (CAR_DAMAGE_SEVERITY)
FROM clean_accidentinfo);

-- DIM: CarDIM
DROP TABLE CarDIM CASCADE CONSTRAINTS PURGE; 
CREATE TABLE CarDIM AS 
(SELECT DISTINCT registrationno, CARBODYTYPE 
FROM moncity.car);

--------------------------------------------------------------------------------
-- Creating facts:
--------------------------------------------------------------------------------
-- =========================  FACT: AccidentFACT  ========================= 
DROP TABLE AccidentFACT_V2 CASCADE CONSTRAINTS PURGE; 
CREATE TABLE AccidentFACT_V2 
AS (
SELECT accidentzone, errorcode, car_damage_severity, accidentid,
count(accidentid) as num_of_accident
FROM clean_accidentinfo 
GROUP BY 
accidentzone, 
car_damage_severity,
errorcode,
accidentid
);


-- =========================  FACT: BookingFact  =========================
-- Create BookingFact 
DROP TABLE BookingFACT_V2 CASCADE CONSTRAINTS PURGE; 
CREATE TABLE BookingFACT_V2 
AS (
SELECT b.bookingdate, f.facultyid, c.carbodytype, p.passengerage, b.bookingid, count(bookingid) as num_of_booking_record
FROM Clean_Booking b, Clean_passenger p, moncity.faculty f, moncity.car c
WHERE b.passengerid  = p.passengerid AND f.facultyid = p.facultyid AND b.REGISTRATIONNO = c.REGISTRATIONNO
GROUP BY b.bookingdate, f.facultyid, c.carbodytype, p.passengerage, b.bookingid
);

-- =========================  FACT: MaintenanceFact  =========================
DROP TABLE MaintenanceFact_V2 CASCADE CONSTRAINTS PURGE; 
CREATE TABLE MaintenanceFact_V2 
AS (
SELECT m.maintenanceid,
m.maintenancetype, 
c.carbodytype,
m.teamid, 
count(DISTINCT  m.maintenanceid) as num_of_main_record, 
sum(m.maintenancecost) as main_cost

FROM Clean_maintenance m, 

(SELECT DISTINCT  b.teamid FROM  
moncity.maintenanceteam mte, moncity.belongto b, moncity.researchcenter r )  mTeam,

moncity.maintenancetype mty,
moncity.car c

WHERE m.teamid = mTeam.teamid AND
mty.maintenancetype = m.maintenancetype and 
c.registrationno = m.registrationno


GROUP BY m.maintenanceid, m.maintenancetype, c.carbodytype,m.teamid
);

-- =========================  Level 1   ======================================
-- ========================= SharedDim ===============================

-- DIM: CarbodyDIM 
DROP TABLE CarBodyTypeDIM CASCADE CONSTRAINTS PURGE; 
CREATE TABLE CarBodyTypeDIM AS 
(SELECT DISTINCT(CARBODYTYPE), numseats FROM moncity.car);

-- DIM: CarDim 
DROP TABLE CarDIM CASCADE CONSTRAINTS PURGE; 
CREATE TABLE CarDIM AS 
(SELECT DISTINCT registrationno, CARBODYTYPE, numseats 
FROM moncity.car);

-- ========================= AccidentFact ===============================

-- DIM: AccidentZoneDIM
DROP TABLE AccidentZoneDIM CASCADE CONSTRAINTS PURGE;
CREATE TABLE AccidentZoneDIM AS
(SELECT DISTINCT accidentzone
FROM clean_accidentinfo);

-- DIM: AccidentInfoDIM_V1
DROP TABLE AccidentInfoDIM_V1 CASCADE CONSTRAINTS PURGE; 
CREATE TABLE AccidentInfoDIM_V1 AS 
(
SELECT ai.accidentid, 
1.0/count(ca.accidentid) As WeightFactor,
LISTAGG (ca.registrationno, '_') Within Group (Order By ai.accidentid) As TeamGroupList 
FROM clean_accidentinfo ai, moncity.caraccident ca
WHERE ai.accidentid = ca.accidentid
Group By ai.accidentid
);

-- DIM: CarAccidentDIM 
DROP TABLE CarAccidentDIM CASCADE CONSTRAINTS PURGE; 
CREATE TABLE CarAccidentDIM AS
(SELECT REGISTRATIONNO, accidentid FROM moncity.caraccident);

-- DIM: ErrorDIM
DROP TABLE ErrorDIM CASCADE CONSTRAINTS PURGE; 
CREATE TABLE ErrorDIM AS 
(SELECT errorcode FROM moncity.error);

-- DIM: CarDamageSeverityDIM
DROP TABLE CarDamageSeverityDIM CASCADE CONSTRAINTS PURGE; 
CREATE TABLE CarDamageSeverityDIM AS 
(SELECT DISTINCT (CAR_DAMAGE_SEVERITY)
FROM clean_accidentinfo);



-- ========================= MaintenanceFact ===============================

-- DIM: MaintenanceTypeDIM 
DROP TABLE MaintenanceTypeDIM CASCADE CONSTRAINTS PURGE; 
CREATE TABLE MaintenanceTypeDIM AS 
(SELECT maintenancetype
FROM moncity.maintenancetype);

-- DIM: (B) MaintenanceTeamDIM_V1 
DROP TABLE MaintenanceTeamDIM_V1 CASCADE CONSTRAINTS PURGE; 
CREATE TABLE MaintenanceTeamDIM_V1 AS 
(
SELECT T.TEAMID, 
1.0/count(B.CENTERID) As WeightFactor,
LISTAGG (B.CENTERID, '_') Within Group (Order By B.CENTERID) As TeamGroupList 
FROM moncity.maintenanceTeam T, moncity.belongto B
WHERE T.TEAMID = B.TEAMID
Group By T.TEAMID
);

-- DIM: (B) BridgeTable 
DROP TABLE BridgeTable CASCADE CONSTRAINTS PURGE; 
CREATE TABLE BridgeTable
AS (SELECT * FROM moncity.belongto);

-- DIM: (B) ResearchCenterDIM
DROP TABLE ResearchCenterDIM  CASCADE CONSTRAINTS PURGE;
CREATE TABLE ResearchCenterDIM 
AS(
SELECT CENTERID, CENTERNAME
FROM moncity.researchcenter
);

-- ========================= BookingFact ===============================

-- DIM: FacultyDIM 
DROP TABLE FacultyDIM CASCADE CONSTRAINTS PURGE; 
CREATE TABLE FacultyDIM AS
(SELECT FACULTYID, FACULTYNAME
FROM moncity.faculty);

-- DIM: (M) MonthDIM
DROP TABLE MonthDIM CASCADE CONSTRAINTS PURGE; 
CREATE TABLE MonthDIM AS
SELECT distinct to_char(BOOKINGDATE, 'MM') as MonthID,
to_char(BOOKINGDATE, 'MONTH') as Month_Des
FROM Clean_Booking;

-- DIM: (M) AgeDim 
DROP TABLE AgeDim CASCADE CONSTRAINTS PURGE; 
CREATE TABLE AgeDim
(AgeID varchar2(10),
Age_grp_desc varchar2(50),
Start_age  number(3),
End_age number(3));

-- Insert age group

Insert into AgeDim values ('Group 1', 'Young adult', 18, 35);
Insert into AgeDim values ('Group 2', 'Middle adult', 36, 59);
Insert into AgeDim values ('Group 3', 'Old-aged adult', 60, 110);



--------------------------------------------------------------------------------
-- Creating facts:
--------------------------------------------------------------------------------

-- =========================  FACT: AccidentFACT  =========================

DROP TABLE AccidentFACT_V1 CASCADE CONSTRAINTS PURGE; 
CREATE TABLE AccidentFACT_V1 
AS (
SELECT accidentzone, 
errorcode,
car_damage_severity,
accidentid,
count(accidentid) as num_of_accident
FROM clean_accidentinfo 
GROUP BY 
accidentzone, 
car_damage_severity,
errorcode,
accidentid
);


-- =========================  FACT: BookingFact  =========================
-- 1. Create BookingTempFact 
DROP TABLE BookingTempFact CASCADE CONSTRAINTS PURGE; 
		CREATE TABLE BookingTempFact 
AS (
SELECT to_char(bookingdate, 'MM') as MonthID, f.facultyid, c.carbodytype, p.passengerage, b.bookingid
FROM clean_booking b, clean_passenger p, moncity.faculty f, moncity.car c
WHERE b.passengerid  = p.passengerid AND f.facultyid = p.facultyid AND b.REGISTRATIONNO = c.REGISTRATIONNO
);

-- 2. Create columns of AgeID and TimeID

ALTER table BookingTempFact 
ADD(
AgeID varchar(15)
);


-- 3. Update values of ageDim
Update BookingTempFact
Set ageid = 'Group 1'
WHERE ( passengerage between 18 AND 35);

Update BookingTempFact
Set ageid = 'Group 2'
WHERE ( passengerage between 36 AND 59);

Update BookingTempFact
Set ageid = 'Group 3'
WHERE ( passengerage between 60 AND 110);



-- 4. Create BookingFACT 
DROP TABLE BookingFACT_V1 CASCADE CONSTRAINTS PURGE; 
CREATE TABLE BookingFACT_V1 
AS (
SELECT b.FACULTYID, b.CARBODYTYPE, b.AGEID , b.MONTHID, 
count (b.BOOKINGID) as num_of_booking
FROM bookingtempfact b
GROUP BY b.FACULTYID, b.CARBODYTYPE, b.AGEID , b.MONTHID
);


-- =========================  FACT: MaintenanceFact  =========================
DROP TABLE MaintenanceFact_V1 CASCADE CONSTRAINTS PURGE; 
CREATE TABLE MaintenanceFact_V1 
AS (
SELECT m.maintenancetype, 
carbodytype,m.teamid, 

count (DISTINCT  m.maintenanceid) as num_of_main_record, 
sum(m.maintenancecost) as main_cost

FROM clean_maintenance m, 

(SELECT DISTINCT  b.teamid FROM  
moncity.maintenanceteam mte, moncity.belongto b, moncity.researchcenter r )  mTeam,

moncity.maintenancetype mty,
moncity.car c

WHERE m.teamid = mTeam.teamid AND
mty.maintenancetype = m.maintenancetype AND 
c.registrationno = m.registrationno

GROUP BY m.maintenancetype, carbodytype,m.teamid
);