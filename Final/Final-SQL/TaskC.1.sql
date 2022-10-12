-- =============================  Problem 1: Duplicate
SELECT BOOKINGID, COUNT(*) as duplicate_records
FROM MonCity.BOOKING
GROUP BY BOOKINGID
HAVING COUNT (*) >1;

-- solution
DROP TABLE Clean_Booking CASCADE CONSTRAINTS PURGE;
CREATE TABLE Clean_Booking as 
SELECT DISTINCT *
FROM MonCity.BOOKING;


-- =============================  Problem 2: Null value problem
SELECT * 
FROM moncity.ACCIDENTINFO
WHERE ACCIDENTID IS NULL;

-- solution
DROP TABLE Clean_Accidentinfo CASCADE CONSTRAINTS PURGE;
CREATE TABLE Clean_Accidentinfo as 
SELECT *
FROM MonCity.ACCIDENTINFO
WHERE ACCIDENTID IS NOT NULL;

-- =============================  Problem 3: Incorrect Values
SELECT *
FROM moncity.maintenance
WHERE maintenancecost < 0;

-- solution 
DROP TABLE Clean_maintenance CASCADE CONSTRAINTS PURGE;
CREATE TABLE Clean_maintenance as 
SELECT *
FROM MonCity.MAINTENANCE
WHERE MAINTENANCECOST > 0;

-- =============================  Problem 4: Relationship Problem
SELECT ERRORcode      
FROM ACCIDENTINFO
WHERE ERRORcode  NOT IN ( SELECT ERRORcode FROM MonCity.ERROR );

-- solution 
DELETE 
FROM CLEAN_ACCIDENTINFO
WHERE ERRORcode NOT IN ( SELECT ERRORcode FROM MonCity.ERROR );

-- =============================  Problem 5: Relationship Problem
SELECT *
FROM MONCITY.passenger
WHERE FACULTYID NOT IN
(SELECT FACULTYID
FROM moncity.faculty);

-- solution
DROP TABLE Clean_passenger CASCADE CONSTRAINTS PURGE;
CREATE TABLE Clean_passenger as 
SELECT DISTINCT *
FROM MonCity.passenger;

DELETE 
FROM Clean_passenger
WHERE FACULTYID NOT IN 
( SELECT FACULTYID
FROM moncity.faculty );
