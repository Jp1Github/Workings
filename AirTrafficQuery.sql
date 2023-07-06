/*

Date: June 23, 2023
Author: John Narvaez
Summary: 
Written on MySQL Workbench 8.0
*/

USE airtraffic;

/* Question 1:
The managers of the BrainStation Mutual Fund want to know some basic details about the data. 
Use fully commented SQL queries to address each of the following questions:
1. How many flights were there in 2018 and 2019 separately?
2. In total, how many flights were cancelled or departed late over both years?
3. Show the number of flights that were cancelled broken down by the reason for cancellation.
4. For each month in 2019, report both the total number of flights and percentage of flights cancelled. 
Based on your results, what might you say about the cyclic nature of airline revenue? 
*/

/* Question 1 */
/* 1. How many flights were there in 2018 and 2019 separately? */
-- Total flights in 2018 - 3,218,653
SELECT COUNT(FlightDate) AS Flight_Count_2018
FROM flights
WHERE (FlightDate >= '2018-01-01' AND FlightDate <= '2018-12-31');

-- Total flights in 2019 - 3,302,708
SELECT COUNT(FlightDate) AS Flight_Count_2019
FROM flights
WHERE (FlightDate >= '2019-01-01' AND FlightDate <= '2019-12-31');

-- Remove code below
SELECT COUNT(FlightDate) AS Flight_Count_2019
FROM flights_2
WHERE (FlightDate BETWEEN '2019-01-01' AND '2019-12-31');


-- Below code shows side by side 2018 & 2019 flights
SELECT *
FROM (
		SELECT COUNT(FlightDate) AS Flight_Cnt_2018
		FROM flights
		WHERE (FlightDate >= '2018-01-01' AND FlightDate <= '2018-12-31') ) a
        CROSS JOIN
        (SELECT COUNT(FlightDate) AS Flight_Cnt_2019
		FROM flights
		WHERE (FlightDate >= '2019-01-01' AND FlightDate <= '2019-12-31') ) b
        ;

/* 2. In total, how many flights were cancelled or departed late over both years? */
/* Noticed the 'cancelled' column/field is either 0 or 1. Which I assume
0 is not cancelled and 1 is cancelled.  Cancelled-92,363, Delayed-2,542,442 */
SELECT cancelled
FROM flights
WHERE cancelled <> 0;

-- 92,363 flights were cancelled.
SELECT COUNT(cancelled) AS Num_Cancelled_Flights
FROM flights_2
WHERE cancelled <> 0;

-- Check the DepDelay column data
SELECT DepDelay 
FROM flights
WHERE DepDelay > 0; -- Any number greater than 0 minutes is a delay.

-- Number of delay 2,542,442
SELECT COUNT(DepDelay) AS Num_of_Delays_2018_and_2019
FROM flights
WHERE DepDelay > 0; -- Any number greater than 0 minutes is considered a delay.

/* 3. Show the number of flights that were cancelled broken down by the reason for cancellation. 
Weather	50,225, Carrier	34,141, National Air System	7,962, Security	35 */
SELECT CancellationReason, 
	   COUNT(cancellationReason) AS Numbers
FROM flights
WHERE CancellationReason IS NOT NULL
GROUP BY CancellationReason;

/* 4. For each month in 2019, report both the total number of flights and percentage of flights cancelled. 
Based on your results, what might you say about the cyclic nature of airline revenue? */ 

WITH CTE AS (
SELECT	MONTH(FlightDate) AS Mth, 
	    COUNT(FlightDate) AS Num_Flights_2019,
        COUNT(CASE
				WHEN CancellationReason IS NOT NULL 
				THEN CancellationReason
				ELSE NULL
            END) AS Total_Cancellation_2019
FROM flights_2019
GROUP BY Mth
ORDER BY Mth )
-- ;

SELECT Mth,
	   Num_Flights_2019,
	   CAST(Total_Cancellation_2019 / Num_Flights_2019 AS DECIMAL(3, 2)) * 100 AS Cancel_Percentage
FROM CTE
;
-- DECIMAL(3, 2)
/*
Mth Num_Flights_2019   Cancel_Percentage
1	262165				2.00
2	237896				2.00
3	283648				2.00
4	274115				3.00
5	285094				2.00
6	282653				2.00
7	291955				2.00
8	290493				1.00
9	268625				1.00
10	283815				1.00
11	266878				1.00
12	275371				1.00
*/
/* Jan to July seem has the highest cancellation as further research that those
months are the stormiest and snowiest periods of the year in United States */


-- SELECT COUNT(CancellationReason)
-- FROM flights
-- WHERE  CancellationReason IS NOT NULL; -- 92,363

-- SELECT COUNT(flightDate) 
-- FROM flights; -- 6,521,361

-- -- Divide both query
-- SELECT (
-- 		(SELECT COUNT(CancellationReason) 
-- 		FROM flights 
-- 		WHERE CancellationReason IS NOT NULL )
-- 		/
-- 		(SELECT COUNT(FlightDate) FROM flights)) *100 AS Delay_Percentage;

-- SELECT (92363 / 6521361)*100 AS Delay_Percentage;


/* ------------------------------------------------------------------------------------- */
/* Question 2
1. Create two new tables, one for each year (2018 and 2019) showing the total miles traveled 
   and number of flights broken down by airline.

2. Using your new tables, find the year-over-year percent change in total flights and miles 
   traveled for each airline.
   Use fully commented SQL queries to address the questions above. What investment guidance 
   would you give to the fund managers based on your results? */

/* Breakdown the flights table in to flights_2018 & flights_ 2019 */

-- Create a table flights_2018 from flights table filtering year from 2018-01-01 to 2018-12-31
DROP TABLE IF EXISTS flights_2018;
CREATE TABLE flights_2018 AS (
		SELECT * 
        FROM flights
		WHERE flightdate >= '2018-01-01' AND flightdate <= '2018-12-31' )
        ;

-- Create a table flights_2018 from flights table filtering year from 2019-01-01 to 2019-12-31
DROP TABLE IF EXISTS flights_2019;
CREATE TABLE flights_2019 AS (
		SELECT * 
        FROM flights
		WHERE flightdate >= '2019-01-01' AND flightdate <= '2019-12-31')
        ;

-- SELECT * FROM flights_2018;
/* Delta Air Lines Inc.	842,409,169
American Airlines Inc.	933,094,276
Southwest Airlines Co.	1,012,847,097 */ -- Total: 2,788,350,542
SELECT AirlineName, 
	   SUM(Distance) AS Travel_Dist_2018_Miles
FROM flights_2018
GROUP BY AirlineName;

-- SELECT * FROM flights_2019;
/* 
Delta Air Lines Inc.	  889,277,534
American Airlines Inc.	  938,328,443
Southwest Airlines Co.	1,011,583,832 */ -- Total: 2,839,189,809
SELECT * FROM flights_2019;

SELECT AirlineName, 
	   SUM(Distance) AS Travel_Dist_2019_Miles
FROM flights_2019
GROUP BY AirlineName;

-- Total Flights
SELECT * FROM flights_2018;

SELECT a.AirlineName, 
	   SUM(a.Distance), SUM(b.Distance)
FROM flights_2018 AS a, flights_2019 AS b
GROUP BY a.AirlineName;

/* Number of flights broken down by Airlines 2018. 
Delta Air Lines Inc.	  945,755
American Airlines Inc.	  901,873
Southwest Airlines Co.	1,334,277
*/
-- Create a CTE to create a temporary table of just AirlineName
WITH CTE AS (
			SELECT AirlineName
			FROM flights_2018
            -- Below will filter that has no cancellation reason. NULL values
			WHERE CancellationReason IS NULL
)
SELECT AirlineName, COUNT(AirlineName) AS Num_Flights
FROM CTE
GROUP BY AirlineName; -- This code took 52.297 sec


-- This code took 51.469 sec. Slightly faster!
SELECT AirlineName, COUNT(AirlineName) AS Num_Flights_2018
FROM flights_2018
WHERE CancellationReason IS NULL 
GROUP BY AirlineName; 

/* Number of flights broken down by Airlines 2019
Delta Air Lines Inc.	  990,144
American Airlines Inc.	  926,625
Southwest Airlines Co.	1,330,324
*/
SELECT AirlineName, COUNT(AirlineName) AS Num_Flights_2019
FROM flights_2019
WHERE CancellationReason IS NULL 
GROUP BY AirlineName; 


/* Delta Air Lines Inc. Difference from 2019 & 2018 1.0450 % . A 4.5% Increase*/
SELECT
	(SELECT COUNT(AirlineName) AS Delta_Num_Flights_2019
	 FROM flights_2019
	 WHERE AirlineName = 'Delta Air Lines Inc.') 
    /
    (SELECT COUNT(AirlineName) AS Delta_Num_Flights_2018
	 FROM flights_2018
	 WHERE AirlineName = 'Delta Air Lines Inc.') AS Delta_YoY
     ;
    
    
/* American Airlines Inc. % difference from 2019 & 2018 is 1.0327. A 3.27% Increase*/
SELECT
	(SELECT count(AirlineName) AS AA_Num_Flights_2019
	 FROM flights_2019
	 WHERE AirlineName = 'American Airlines Inc.') 
    /
    (SELECT count(AirlineName) AS AA_Num_Flights_2018
	 FROM flights_2018
	 WHERE AirlineName = 'American Airlines Inc.') AS AA_YoY
     ;
     
	
/* Southwest Airlines Co. % difference from 2019 & 2018 is 1.0084. A 0.8% Increase*/
SELECT
	(SELECT count(AirlineName) AS AA_Num_Flights_2019
	 FROM flights_2019
	 WHERE AirlineName = 'Southwest Airlines Co.') 
    /
    (SELECT count(AirlineName) AS AA_Num_Flights_2018
	 FROM flights_2018
	 WHERE AirlineName = 'Southwest Airlines Co.') AS SWA_YoY
     ;
/* The total travel flight in 2019 is almost 51 Million more than 2018. 
Delta Air Lines and the American Airlines have a flight increase between 3-5 %.
While Southwest Airlines remains flat. It seems Delta and American Airlines gaining more market share of customers.
As a business point for investment or share I would recommend to go to Delta and American Airlines.
But for Southwest I would ask them to analyze pricing, services, travel destination, convenience etc of their competitors */


/* ------------------------------------------------------------------------------------- */
/*Question 3
Another critical piece of information is what airports the three airlines utilize most commonly.
What are the names of the 10 most popular destination airports overall? For this question, generate a 
SQL query that first joins flights and airports then does the necessary aggregation.

Answer the same question but using a subquery to aggregate & limit the flight data before your join with 
the airport information, hence optimizing your query runtime.
If done correctly, the results of these two queries are the same, but their runtime is not. In your SQL script, 
comment on the runtime: which is faster and why? */

SELECT * FROM airports; -- has the airports.AirportID connected to flights.DestAirportID, airport.name
SELECT * FROM flights; -- 

/* 10 Most popular airports
Hartsfield-Jackson Atlanta International	595,527
Dallas/Fort Worth International				314,423
Phoenix Sky Harbor International			253,697
Los Angeles International					238,092
Charlotte Douglas International				216,389
Harry Reid International					200,121
Denver International						184,935
Baltimore/Washington International 
Thurgood Marshall							168,334
Minneapolis-St Paul International			165,367
Chicago Midway International				165,007 
*/
-- Below script join the tables before aggregation. It ran 91.328 sec
WITH CTE AS (
			SELECT a.AirportID, a.AirportName, f.DestAirportID AS DestAirportID
			FROM airports a
			JOIN flights f
				ON a.AirportID = f.DestAirportID
                )
SELECT DestAirportID, AirportName, COUNT(AirportName) AS Planes_Arrived_2018_to_2019
FROM CTE
GROUP BY AirportName, DestAirportID
ORDER BY Planes_Arrived_2018_to_2019 DESC
LIMIT 10; -- 76.907 sec


-- Below code aggregate and limit before joining tables. It ran 11.532 sec
SELECT f.DestAirportID, a.AirportName AS AirportName, f.cnt AS Planes_Arrived_2018_to_2019
FROM (
	  SELECT DestAirportID, COUNT(DestAirportID) AS cnt
	  FROM flights
      GROUP BY DestAirportID
      ORDER BY cnt DESC 
      LIMIT 10
      ) f
JOIN airports a
	ON a.AirportID = f.DestAirportID
ORDER BY f.cnt DESC -- 9.578 sec
;
/* The latter code ran faster because the aggregate or filtered table is smaller before combining both table.
Rather than aggregate or filtering on a larger table. */


/* ------------------------------------------------------------------------------------- */
/*Question 4
The fund managers are interested in operating costs for each airline. We don't have actual cost 
or revenue information available, but we may be able to infer a general overview of how each airline's 
costs compare by looking at data that reflects equipment and fuel costs.

A flight's tail number is the actual number affixed to the fuselage of an aircraft, much like a car license 
plate. As such, each plane has a unique tail number and the number of unique tail numbers for each airline 
should approximate how many planes the airline operates in total. Using this information, determine the number
of unique aircraft each airline operated in total over 2018-2019.

Similarly, the total miles traveled by each airline gives an idea of total fuel costs and the distance traveled 
per plane gives an approximation of total equipment costs. What is the average distance traveled per aircraft for 
each of the three airlines?

As before, use fully commented SQL queries to address the questions. Compare the three airlines with respect to 
your findings: how do these results impact your estimates of each airline's finances? */

SELECT * FROM flights;
SELECT * FROM airports;

-- Number of unique aircraft
/* 
AA	American Airlines Inc.	993
DL	Delta Air Lines Inc.	988
WN	Southwest Airlines Co. 	754
*/
SELECT AirlineName, 
	   COUNT(DISTINCT(Tail_Number)) AS Num_Planes
FROM flights
GROUP BY AirlineName; -- 29.937 sec

-- American Airlines Inc aircraft avg distance travel per aircraft (Tail_Number NxxxAN)
SELECT Tail_Number, 
	   SUM(Distance) AS Total_Dist_2019_AND_2018, 
       CAST(AVG(Distance) AS DECIMAL) AS Avg_Dist
FROM flights
WHERE AirlineName = 'American Airlines Inc.' AND Tail_Number IS NOT NULL
GROUP BY Tail_Number
ORDER BY Avg_Dist DESC
;

-- Delta Air Lines Inc. aircraft avg distance travel per aircraft (Tail_NumberNxxxNW)
SELECT Tail_Number, 
	   SUM(Distance) AS Total_Dist_2019_AND_2018, 
       CAST(AVG(Distance) AS DECIMAL) AS Avg_Dist
FROM flights
WHERE AirlineName = 'Delta Air Lines Inc.' AND Tail_Number IS NOT NULL
GROUP BY Tail_Number
ORDER BY Avg_Dist DESC
;

-- Southwest Airlines Co. aircraft avg distance travel per aircraft (Tail_NumberNxxxxQ/H/M/D/W/A)
SELECT Tail_Number, 
	   SUM(Distance) AS Total_Dist_2019_AND_2018, 
       CAST(AVG(Distance) AS DECIMAL) AS Avg_Dist
FROM flights
WHERE AirlineName = 'Southwest Airlines Co.' AND Tail_Number IS NOT NULL
GROUP BY Tail_Number
ORDER BY Avg_Dist DESC
;

/* Check each airline total distance travel of all of its plane */

-- American Airlines Inc. Accumulated_Dist_Travelled 1,870,581,324 miles
-- Ran 30.812 sec
WITH CTE_AA AS (
				SELECT 	Tail_Number, 
						SUM(Distance) AS Total_Dist_2019_AND_2018, 
						CAST(AVG(Distance) AS DECIMAL) AS Avg_Dist
				FROM flights
				WHERE AirlineName = 'American Airlines Inc.' 
					AND Tail_Number IS NOT NULL
				GROUP BY Tail_Number
				ORDER BY Avg_Dist DESC
			)
SELECT SUM(Total_Dist_2019_AND_2018) AS Accumulated_Dist_Travelled
FROM CTE_AA
;

-- Delta Air Lines Inc. Accumulated_Dist_Travelled 1,731,685,970 miles
-- Ran 32.406 sec
WITH CTE_DA AS (
				SELECT 	Tail_Number, 
						SUM(Distance) AS Total_Dist_2019_AND_2018, 
						CAST(AVG(Distance) AS DECIMAL) AS Avg_Dist
				FROM flights
				WHERE AirlineName = 'Delta Air Lines Inc.' 
					AND Tail_Number IS NOT NULL
				GROUP BY Tail_Number
				ORDER BY Avg_Dist DESC
			)
SELECT SUM(Total_Dist_2019_AND_2018) AS Accumulated_Dist_Travelled
FROM CTE_DA
;

--  Southwest Airlines Co. Accumulated_Dist_Travelled 2,017,051,073 miles
-- Ran 43.234 sec
WITH CTE_SW AS (
				SELECT 	Tail_Number, 
						SUM(Distance) AS Total_Dist_2019_AND_2018, 
						CAST(AVG(Distance) AS DECIMAL) AS Avg_Dist
				FROM flights
				WHERE AirlineName = 'Southwest Airlines Co.' 
					AND Tail_Number IS NOT NULL
				GROUP BY Tail_Number
				ORDER BY Avg_Dist DESC
			)
SELECT SUM(Total_Dist_2019_AND_2018) AS Accumulated_Dist_Travelled
FROM CTE_SW
;

/* ------------------------------------------------------------------------------------- */
/*Question 5:
Finally, the fund managers would like you to investigate the three airlines and major airports in terms of on-time performance as well. For each of the following questions, consider early departures and arrivals (negative values) as on-time (0 delay) in your calculations.
Next, we will look into on-time performance more granularly in relation to the time of departure. We can break up the departure times into three categories as follows:
CASE
    WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN "1-morning"
    WHEN HOUR(CRSDepTime) BETWEEN 12 AND 16 THEN "2-afternoon"
    WHEN HOUR(CRSDepTime) BETWEEN 17 AND 21 THEN "3-evening"
    ELSE "4-night"
END AS "time_of_day"
Find the average departure delay for each time-of-day across the whole data set. Can you explain the pattern you see?
Now, find the average departure delay for each airport and time-of-day combination.
Next, limit your average departure delay analysis to morning delays and airports with at least 10,000 flights.
Finally, name the top-10 airports with the highest average morning delay. In what cities are these airports located?
Make sure you comment on the results in your script. */

SELECT * FROM flights;
SELECT * FROM airports;

SELECT * -- OriginAirportID, DepDelay,
	,  CASE 
			WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN "1-morning"
			WHEN HOUR(CRSDepTime) BETWEEN 12 AND 16 THEN "2-afternoon"
			WHEN HOUR(CRSDepTime) BETWEEN 17 AND 21 THEN "3-evening"
			ELSE "4-night"
	   END AS "time_of_day"
FROM flights
WHERE DepDelay > 0 -- Any greater than 0 is a departure delay in minutes.
LIMIT 10
;

 -- Find the average departure delay for each time-of-day across the whole data set.
-- WITH CTE AS(
-- SELECT OriginAirportID, DepDelay AS Num_Delay,
-- 	  CASE 
-- 			WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN "1-morning"
-- 			WHEN HOUR(CRSDepTime) BETWEEN 12 AND 16 THEN "2-afternoon"
-- 			WHEN HOUR(CRSDepTime) BETWEEN 17 AND 21 THEN "3-evening"
-- 			ELSE "4-night"
-- 	  END AS "time_of_day"
-- FROM flights
-- WHERE DepDelay > 0 -- Any greater than 0 is a departure delay in minutes.
-- LIMIT 10
-- )
;
WITH CTE AS(
SELECT OriginAirportID, DepDelay AS Minutes_Delay,
	  CASE 
			WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN "1-morning"
			WHEN HOUR(CRSDepTime) BETWEEN 12 AND 16 THEN "2-afternoon"
			WHEN HOUR(CRSDepTime) BETWEEN 17 AND 21 THEN "3-evening"
			ELSE "4-night"
	  END AS "time_of_day"
FROM flights
WHERE DepDelay > 0 -- Any greater than 0 is a departure delay in minutes.
)
SELECT DISTINCT(time_of_day), 
	   CAST(AVG(Minutes_Delay) OVER (PARTITION BY time_of_day) AS DECIMAL) AS Avg_Min_Delay
FROM CTE
;

/*
time_of_day 	Avg_Min_Delay 
1-morning		26
2-afternoon		30
3-evening		36
4-night			30 
Average delay in minutes at each time of day
*/


-- Now, find the average departure delay for each airport and time-of-day combination. 
CREATE VIEW airport_delay AS 
	SELECT OriginAirportID, DepDelay AS Minutes_Delay,
	  CASE 
			WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN "1-morning"
			WHEN HOUR(CRSDepTime) BETWEEN 12 AND 16 THEN "2-afternoon"
			WHEN HOUR(CRSDepTime) BETWEEN 17 AND 21 THEN "3-evening"
			ELSE "4-night"
	  END AS "time_of_day"
FROM flights
WHERE DepDelay > 0 -- Any greater than 0 is a departure delay in minutes.
-- LIMIT 10 -- Uncomment to speed up if testing. Comment it out to get the full list.
;
WITH CTE_Airport_Delay AS(
SELECT OriginAirportID,
	   AVG(Minutes_Delay) OVER() AS Avg_Minutes_Delay,
       time_of_day
FROM airport_delay
LIMIT 10)
SELECT DISTINCT(AirportName), Avg_Min_Delay, time_of_day
FROM airports
JOIN CTE_Airport_Delay
	ON airports.AirportID = CTE_Airport_Delay.OriginAirportID;
/*
AirportName									Avg_Minutes_Delay	time_of_day
Hartsfield-Jackson Atlanta International		30.8652			2-afternoon
Hartsfield-Jackson Atlanta International		30.8652	  		4-night
Hartsfield-Jackson Atlanta International		30.8652	  		1-morning
Ronald Reagan Washington National				30.8652			3-evening
Denver International							30.8652			2-afternoon
Dallas/Fort Worth International					30.8652			2-afternoon
-- snippet--
*/


-- Next, limit your average departure delay analysis to morning delays and airports with at least 10,000 flights.
-- Table (Tbl) with time_of_day column
DROP VIEW IF EXISTS Tbl;
CREATE VIEW Tbl AS 
SELECT 
	   OriginAirportID,
	   FlightDate, 
	   DepDelay
	,	CASE 
			WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN "1-morning"
			WHEN HOUR(CRSDepTime) BETWEEN 12 AND 16 THEN "2-afternoon"
			WHEN HOUR(CRSDepTime) BETWEEN 17 AND 21 THEN "3-evening"
			ELSE "4-night"
	  END AS "time_of_day"
FROM flights
WHERE DepDelay > 0
;

-- Create a table where time_of_day is 1-morning (Tbl1Mng)
DROP VIEW IF EXISTS Tbl1Mng;
CREATE VIEW Tbl1Mng AS 
		SELECT OriginAirportID, 
				FlightDate, 
                DepDelay AS Minutes_Delay,
                time_of_day
		FROM Tbl -- Table with the time_of_day column
		WHERE time_of_day ='1-morning'
;

-- Create a table of flight count (TblFlgCnt)
DROP VIEW IF EXISTS TblFlgCnt;
CREATE VIEW TblFlgCnt AS
		SELECT OriginAirportID,
			   COUNT(FlightDate) AS flight_cnt
		FROM flights
		GROUP BY OriginAirportID
;

-- Filter OriginAirportID, AirportName with 10K and above
-- To be used as a filter table (Tbl10K)
DROP VIEW IF EXISTS Tbl10K;
CREATE VIEW Tbl10K AS
		SELECT t.OriginAirportID, 
			   a.AirportName,
			   t.flight_cnt
		FROM TblFlgCnt t
		JOIN airports a
			ON a.AirportID = t.OriginAirportID
		WHERE t.flight_cnt >= 10000
		GROUP BY OriginAirportID, a.AirportName
	;
        
-- Query a table where the time_of_day is 1-morning and
-- using subquery to filter with airport of 10k flights table
-- By casting to DECIMAL it ran (26.703 ran more 0.062 sec). Without CAST 26.641
SELECT OriginAirportID, CAST(AVG(Minutes_Delay) AS DECIMAL) AS Avg_Minutes_Delay
FROM Tbl1Mng
WHERE OriginAirportID IN
	(SELECT t.OriginAirportID 
	 FROM Tbl10K t
     -- LIMIT 10
	 )
GROUP BY OriginAirportID
ORDER BY Avg_Minutes_Delay DESC
-- LIMIT 1000 -- Uncomment for testing, Comment to get full list;
/* 
OriginAirportID		Avg_Minutes_Delay
14843					49
11618					43
12266					43
11986					40
14771					39
15370					39
12173					38
11884					37
14122					36
13244					36
*/
;
DROP VIEW IF EXISTS RnkDelay;
CREATE VIEW RnkDelay AS
WITH CTE AS (
SELECT OriginAirportID, CAST(AVG(Minutes_Delay) AS DECIMAL) AS Avg_Minutes_Delay
FROM Tbl1Mng
WHERE OriginAirportID IN
	(SELECT t.OriginAirportID 
	 FROM Tbl10K t
     -- LIMIT 10
	 )
GROUP BY OriginAirportID
ORDER BY Avg_Minutes_Delay DESC)

SELECT 	a.City, 
		a.AirportName, 
        Avg_Minutes_Delay,
        RANK() OVER(ORDER BY Avg_Minutes_Delay DESC) AS rnk
        -- DENSE_RANK () OVER(ORDER BY Avg_Minutes_Delay DESC) AS dsernk
FROM airports a
JOIN CTE c
	ON c.OriginAirportID = a.AirportID
;

SELECT *
FROM RnkDelay
WHERE rnk <= 10;

/*
City				AirportName								Avg_Minute_Delay  	rnk
San Juan, PR		Luis Munoz Marin International			49					1
Houston, TX			George Bush Intercontinental/Houston	43					2
Newark, NJ			Newark Liberty International			43					2
Grand Rapids, MI	Gerald R. Ford International			40					4
San Francisco, CA	San Francisco International				39					5
Tulsa, OK			Tulsa International						39					5
Honolulu, HI		Daniel K Inouye International			38					7
Spokane, WA			Spokane International					37					8
-- snippet --
*/
