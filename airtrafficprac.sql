USE airtraffic;
            
 create table yourNewTableName like yourOldTableName;
 insert into yourNewTableName select *from yourOldTableName.
 
DROP TABLE IF EXISTS flights_2;
CREATE TABLE flights_2 select FlightDate, AirlineName, DepDelay, Cancelled, CancellationReason from flights;
 
INSERT INTO flights_2
SELECT	FlightDate, 
		AirlineName, 
        DepDelay, 
        Cancelled, 
        CancellationReason
FROM flights;
 
-- This is faster than the BETWEEN
SELECT COUNT(FlightDate) AS Flight_Count_2018
FROM flights
WHERE (FlightDate >= '2018-01-01' AND FlightDate <= '2018-12-31');

-- This is slower than the <= >=
SELECT COUNT(FlightDate) AS Flight_Count_2018
FROM flights
WHERE (FlightDate BETWEEN '2018-01-01' AND '2018-12-31');


-- Common Table Expression
WITH CTE AS (
			SELECT FlightDate, AirlineName, DepDelay, Cancelled, CancellationReason
			FROM flights)
            

SELECT AirlineName, sum(Distance)
FROM flights
where AirlineName="Southwest Airlines Co.";


DROP TABLE IF EXISTS flights_2018;
CREATE TABLE flights_2018 AS
SELECT *
	  FROM flights 
	  WHERE (FlightDate >= '2018-01-01' AND FlightDate <= '2018-12-31');
 
 SELECT * from flight_2018;
 
INSERT INTO flights_2018
SELECT	AirlineName, 
        Distance
FROM flights;

select * from flights
where flightdate > '2018-01-01' and flightdate < '2018-12-31';

-- DROP TABLE IF EXISTS flights_2018;
-- with cte as (select * from flights
-- where flightdate >= '2018-01-01' and flightdate <= '2018-12-31'
-- )
-- CREATE table flights_2018 AS select * from cte;
-- select * from cte;

DROP TABLE IF EXISTS flights_2018;
CREATE TABLE flights_2018 LIKE flights;
CREATE TABLE flights_2018 AS
SELECT * FROM flights
WHERE flightdate >= '2018-01-01' AND flightdate <= '2018-12-31';

SELECT * FROM flights_2018 WHERE FlightDate='2018-12-31' -- OR FlightDate='2018-01-01';

INSERT INTO flights_2018
SELECT * 
FROM flights
WHERE flightdate >= '2018-01-01' AND flightdate <= '2018-12-31';

-- This one work fine.
CREATE TABLE flights_2019 LIKE flights;
SELECT * FROM flights_2019;

DROP TABLE IF EXISTS flights_2019;
CREATE TABLE flights_2019 AS
SELECT * FROM flights
WHERE flightdate >= '2019-01-01' AND flightdate <= '2019-12-31';

select * from flights_2018;
select * from flights_2019;

select * from flights where flightDate >= '2018-12-28'


select * from flights;
select distinct(AirlineName) from flights;
select AirlineName, sum(distance) from flights group by AirlineName;
select AirlineName, distance from flights;

select sum(distance) over (partition by AirlineName) from flights where AirlineName="Delta Air Lines Inc";

select AirlineName, sum(distance) from flights where AirlineName="Delta Air Lines Inc.";

-- Delta Air Lines Inc.
-- American Airlines Inc.
-- Southwest Airlines Co.

SELECT AirlineName, 
	   Distance
FROM flights 
WHERE AirlineName="Delta Air Lines Inc.";

with cte as (
SELECT DISTINCT(AirlineName), 
	   Distance
FROM flights 
WHERE AirlineName<>"Delta Air Lines Inc.")

select sum(distance) from cte;




SELECT DISTINCT(AirlineName), SUM(Distance) OVER(PARTITION BY AirLineName) AS Total_Distance
FROM flights 
WHERE AirlineName="Delta Air Lines Inc.";


select distinct(airlineName) from flights;

select AirlineName, SUM(distance) OVER(PARTITION BY AirlineName) AS AL FROM flights where AirlineName="Southwest Airlines Co.";



    
    
-- ----------------------------

select count(AirlineName) AS Delta_Num_Flights_2018
from flights_2018
where AirlineName = 'Delta Air Lines Inc.'
union
select count(AirlineName) AS Delta_Num_Flights_2019
from flights_2019
where AirlineName = 'Delta Air Lines Inc.';
SELECT @@sql_mode;

SELECT COUNT(AirlineName) AS NumFlights
FROM flights_2018
WHERE CancellationReason IS NULL;

SELECT a.FlightDate, 
		a.AirlineName, 
		a.Distance, 
        b.FlightDate, 
        b.AirlineName, 
        b.Distance
FROM flights_2018 AS a, flights_2019 AS b
ORDER BY a.FlightDate, b.FlightDate;
-- GROUP BY a.AirlineName;
