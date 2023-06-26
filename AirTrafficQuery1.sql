/*
AirTraffic Project - Part 1 - Data Analysis in SQL
Date: 		June 24, 2023
Author: 	John Narvaez
Summary: 	This is a project to provide insights from flights & airport table. To analyze performance or efficiency
			of three (3) airlines for fund manager where to invest stocks.
            It also provides airport delay and cancellation and causes.
RDBMS:	 	MySQL Workbench 8.0
*/

USE airtraffic;

/*
The managers of the BrainStation Mutual Fund want to know some basic details about the data. 
Use fully commented SQL queries to address each of the following questions:
*/

/* Question 1 */
/* Q1.1 How many flights were there in 2018 and 2019 separately? */
-- Total flights in 2018 - 3,218,653
SELECT COUNT(FlightDate) AS Flight_Count_2018
FROM flights
WHERE (FlightDate >= '2018-01-01' AND FlightDate <= '2018-12-31')
;
/* Result
Flight_Count_2018
'3218653'
*/

-- Total flights in 2019 - 3,302,708
SELECT COUNT(FlightDate) AS Flight_Count_2019
FROM flights
WHERE (FlightDate >= '2019-01-01' AND FlightDate <= '2019-12-31');
;
/* Result
Flight_Count_2019
'3302708'
*/

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
/* Result
Flight_Cnt_2018		Flight_Cnt_2019
3218653				3302708
 */

/* Q1.2. In total, how many flights were cancelled or departed late over both years? */
-- Delayed-2,542,442
-- Query cancelled column / field data.
SELECT cancelled
FROM flights
/* Noticed the 'cancelled' column/field is either 0 or 1. Which I assume
0 is not cancelled and 1 is cancelled. 
*/
;

-- Query the count of cancelled flights from 2018 to 2019 (whole data set) 
-- 92,363 flights were cancelled.
SELECT COUNT(cancelled) AS Num_Cancelled_Flights
FROM flights_2
WHERE cancelled <> 0
;
/* Result
Num_Cancelled_Flights
'92363'
*/

-- Check the DepDelay column data
SELECT CRSDepTime, 
	   DepTime, 
       DepDelay 
FROM flights
WHERE DepDelay IS NOT NULL; -- Look at available data in DepDelay field.
/* Observed that DepDelay is the result of CRSDepTime minus DepTime */

-- Number of delay 2,542,442
SELECT COUNT(DepDelay) AS Num_of_Delays_2018_and_2019
FROM flights
WHERE DepDelay > 0; -- Any number greater than 0 minutes is considered a delay.
/* Result
Num_of_Delays_2018_and_2019
'2542442'
*/

/* Q1.3. Show the number of flights that were cancelled broken down by the reason for cancellation. 
Weather	50,225, Carrier	34,141, National Air System	7,962, Security	35 */
SELECT CancellationReason, 
	   COUNT(cancellationReason) AS Numbers
FROM flights
WHERE CancellationReason IS NOT NULL
GROUP BY CancellationReason
;
/* Result
CancellationReason		Numbers
'Weather', 				'50225'
'Carrier', 				'34141'
'National Air System', 	 '7962'
'Security', 			   '35'
*/

/* Q1.4. For each month in 2019, report both the total number of flights and percentage of flights cancelled. 
Based on your results, what might you say about the cyclic nature of airline revenue? */ 
-- 
SELECT	MONTH(FlightDate) AS Mth, -- Extract the month number
		-- Count the number of flights
	    COUNT(FlightDate) AS Num_Flights_2019, 
        -- Count the number of CancellationReason with data (Not NULL)
        COUNT(CASE
				WHEN CancellationReason IS NOT NULL 
				THEN CancellationReason
				ELSE NULL
            END) AS Total_Cancellation_2019
FROM flights_2019
GROUP BY Mth
ORDER BY Mth
;
/* Result
Mth		Num_Flights_2019	Total_Cancellation_2019
1		262165				5788
2		237896				5502
3		283648				7079
4		274115				7429
5		285094				6912
6		282653				6172
7		291955				4523
8		290493				3624
9		268625				3318
10		283815				2291
11		266878				1580
12		275371				1397
*/

-- Create a temp table to compute Total_Cancellation_2019 / Num_Flights_2019
WITH CTE AS (
SELECT	MONTH(FlightDate) AS Mth, -- Extract the month number
		-- Count the number of flights
	    COUNT(FlightDate) AS Num_Flights_2019, 
        -- Count the number of CancellationReason with data (Not NULL)
        COUNT(CASE
				WHEN CancellationReason IS NOT NULL 
				THEN CancellationReason
				ELSE NULL
            END) AS Total_Cancellation_2019
FROM flights_2019 -- This table is created at Question 2.1
GROUP BY Mth
ORDER BY Mth )
-- ;

-- Query the Cancel Percentage
SELECT Mth,
	   Num_Flights_2019,
	   CAST(Total_Cancellation_2019 / Num_Flights_2019 AS DECIMAL(3, 2)) * 100 AS Cancel_Percentage
FROM CTE
;
/* Result
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
months are the stormiest and snowiest periods of the year in the United States */


/* ------------------------------------------------------------------------------------- */
/* Question 2 */
/* Q2.1. Create two new tables, one for each year (2018 and 2019) showing the total miles traveled 
   and number of flights broken down by airline. */

/* Breakdown the flights table in to flights_2018 & flights_ 2019 */
-- Create a table flights_2018 from flights table filtering year from 2018-01-01 to 2018-12-31
DROP TABLE IF EXISTS flights_2018;
CREATE TABLE flights_2018 AS (
		SELECT * 
        FROM flights
		WHERE flightdate >= '2018-01-01' AND flightdate <= '2018-12-31' )
;

-- Create a table flights_2019 from flights table filtering year from 2019-01-01 to 2019-12-31
DROP TABLE IF EXISTS flights_2019;
CREATE TABLE flights_2019 AS (
		SELECT * 
        FROM flights
		WHERE flightdate >= '2019-01-01' AND flightdate <= '2019-12-31')
;

-- Query total miles traveled and number of flights broken down by airline in 2018.
/*
Delta Air Lines Inc.	842,409,169
American Airlines Inc.	933,094,276
Southwest Airlines Co.	1,012,847,097 */ -- Total: 2,788,350,542
SELECT AirlineName, 
	   SUM(Distance) AS Travel_Dist_2018_Miles
FROM flights_2018
GROUP BY AirlineName
;
/* Result
AirlineName						Travel_Dist_2018_Miles
Delta Air Lines Inc.			842409169
American Airlines Inc.			933094276
Southwest Airlines Co.			1012847097
*/

-- Query total miles traveled and number of flights broken down by airline in 2019.
/* 
Delta Air Lines Inc.	  889,277,534
American Airlines Inc.	  938,328,443
Southwest Airlines Co.	1,011,583,832 */ -- Total: 2,839,189,809
SELECT AirlineName, 
	   SUM(Distance) AS Travel_Dist_2019_Miles
FROM flights_2019
GROUP BY AirlineName;
;
/* Result
AirlineName				Travel_Dist_2019_Miles
Delta Air Lines Inc.	889277534
American Airlines Inc.	938328443
Southwest Airlines Co.	1011583832
*/

/* Additional Query to check total miles in each year */
-- Total Miles in 2018 - '2788350542'
SELECT SUM(Distance) AS Total_Miles_2018
FROM flights_2018
;

-- Total Miles in 2019 - '2839189809'
SELECT SUM(Distance) AS Total_Miles_2018
FROM flights_2019
;

/* Q2.2. Using your new tables, find the year-over-year percent change in total flights and miles 
   traveled for each airline.
   Use fully commented SQL queries to address the questions above. What investment guidance 
   would you give to the fund managers based on your results? */

-- Number of flights broken down by Airlines 2018.
-- Create a CTE to create a temporary table of just AirlineName
WITH CTE AS (
			SELECT AirlineName
			FROM flights_2018
            -- Below will filter that has no cancellation reason. NULL values
			WHERE CancellationReason IS NULL
)
SELECT AirlineName, COUNT(AirlineName) AS Num_Flights_2018
FROM CTE
GROUP BY AirlineName; -- This code took 19.735 sec (Remove this code before submission)


-- This code took 19.937 sec. Slightly slower!
SELECT AirlineName, COUNT(AirlineName) AS Num_Flights_2018
FROM flights_2018
WHERE CancellationReason IS NULL 
GROUP BY AirlineName -- 26.750
; 
/* Result 
AirlineName				Num_Flights_2018
Delta Air Lines Inc.	  945,755
American Airlines Inc.	  901,873
Southwest Airlines Co.	1,334,277
*/

-- Number of flights broken down by Airlines 2019.
SELECT AirlineName, COUNT(AirlineName) AS Num_Flights_2019
FROM flights_2019
WHERE CancellationReason IS NULL 
GROUP BY AirlineName
; 
/* Result 
AirlineName				Num_Flights_2019
Delta Air Lines Inc.	  990,144
American Airlines Inc.	  926,625
Southwest Airlines Co.	1,330,324
*/

/* Query the year-over-year percent change in total flights and miles 
   traveled for each airline. */
   
-- Delta Air Lines Inc. Difference from 2019 & 2018 1.0450 % . A 4.5% Increase
SELECT
	-- Subquery of total Delta flights in 2019
	(SELECT COUNT(AirlineName) AS Delta_Num_Flights_2019
	 FROM flights_2019
	 WHERE AirlineName = 'Delta Air Lines Inc.') 
    / -- Divided both subquery
    -- Subquery of total Delta flights in 2018
    (SELECT COUNT(AirlineName) AS Delta_Num_Flights_2018
	 FROM flights_2018
	 WHERE AirlineName = 'Delta Air Lines Inc.') AS Delta_YoY
;
 /* Result 
 Delta_YoY
 '1.0450'
 */
    
-- American Airlines Inc. % difference from 2019 & 2018 is 1.0327. A 3.27% Increase
SELECT
	-- Subquery of total American Airlines in 2019
	(SELECT count(AirlineName) AS AA_Num_Flights_2019
	 FROM flights_2019
	 WHERE AirlineName = 'American Airlines Inc.') 
   / -- Divide both subquery. Ran 14.125 sec but with several decimal digit
    -- DIV -- Ran 14.672
    -- Subquery of total American Airlines in 2018
    (SELECT count(AirlineName) AS AA_Num_Flights_2018
	 FROM flights_2018
	 WHERE AirlineName = 'American Airlines Inc.') AS AA_YoY
;
/* Result 
AA_YoY
'1.0327'
 */
	
/* Southwest Airlines Co. % difference from 2019 & 2018 is 1.0084. A 0.8% increase*/
SELECT
	-- Subquery of total Southwest Airlines Co. flights in 2019
	(SELECT count(AirlineName) AS AA_Num_Flights_2019
	 FROM flights_2019
	 WHERE AirlineName = 'Southwest Airlines Co.') 
   / -- Divide both subquery. This ran 15.406 sec
    -- DIV -- Division ran 15.641 sec
    -- Subquery of total Southwest Airlines Co. flights in 2018
    (SELECT count(AirlineName) AS AA_Num_Flights_2018
	 FROM flights_2018
	 WHERE AirlineName = 'Southwest Airlines Co.') AS SWA_YoY
;
/* Result 
SWA_YoY
'1.0084'
*/

/* The total travel flight in 2019 is almost 51 Million more than 2018. 

Delta Air Lines and the American Airlines have a flight increase between 3-5 %.
While Southwest Airlines remains flat. It seems Delta and American Airlines gaining more market share of customers.

As a business point for investment or share I would recommend to invest in Delta and/or American Airlines.
But for Southwest I would ask them to analyze pricing, services, travel destination, convenience etc of their competitors 
*/


/* ------------------------------------------------------------------------------------- */
/*Question 3 */
/*
Another critical piece of information is what airports the three airlines utilize most commonly.
1. What are the names of the 10 most popular destination airports overall? For this question, generate a 
SQL query that first joins flights and airports then does the necessary aggregation.

2. Answer the same question but using a subquery to aggregate & limit the flight data before your join with 
the airport information, hence optimizing your query runtime.
If done correctly, the results of these two queries are the same, but their runtime is not. In your SQL script, 
comment on the runtime: which is faster and why? */

-- SELECT * FROM airports; -- has the airports.AirportID connected to flights.DestAirportID
-- SELECT * FROM flights; -- 

/*Query of both under Q3.2 query runtime.*/
-- Below script join the tables before aggregation. It ran 73.969 sec sec
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
LIMIT 10; -- 73.969 sec

-- Below code aggregate and limit before joining tables. It ran 10.344 sec
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
ORDER BY f.cnt DESC -- 10.344 sec
;
/* The latter code ran faster because the aggregate or filtered table is smaller before combining both table.
Rather than aggregate or filtering on a larger table. */

/* Q3.1 - 10 Most popular airports
Result 
DestAirportID	AirportName									Planes_Arrived_2018_to_2019
10397			Hartsfield-Jackson Atlanta International	595527
11298			Dallas/Fort Worth International				314423
14107			Phoenix Sky Harbor International			253697
12892			Los Angeles International					238092
11057			Charlotte Douglas International				216389
12889			Harry Reid International					200121
11292			Denver International						184935
10821			Baltimore/Washington 
				International Thurgood Marshall				168334
13487			Minneapolis-St Paul International			165367
13232			Chicago Midway International				165007
*/


/* ------------------------------------------------------------------------------------- */
/*Question 4 */
/*
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
your findings: how do these results impact your estimates of each airline's finances? 
*/

SELECT * FROM flights;
SELECT * FROM airports;

-- Number of unique aircraft by each airline
SELECT AirlineName, 
	   COUNT(DISTINCT(Tail_Number)) AS Num_Planes
FROM flights
GROUP BY AirlineName; -- 29.937 sec
/* Result 
AirlineName				Num_Planes
American Airlines Inc.	993
Delta Air Lines Inc.	988
Southwest Airlines Co. 	754
*/

-- American Airlines Inc aircraft avg distance travel per aircraft (Tail_Number NxxxAN)
SELECT Tail_Number, 
	   SUM(Distance) AS Total_Dist_2019_AND_2018, 
       CAST(AVG(Distance) AS DECIMAL) AS Avg_Dist
FROM flights
WHERE AirlineName = 'American Airlines Inc.' AND Tail_Number IS NOT NULL
GROUP BY Tail_Number
ORDER BY Avg_Dist DESC
;
/* Result
Tail_Number		Total_Dist_2019_AND_2018	Avg_Dist
N750AN			662365						2819
N758AN			801684						2793
N752AN			700112						2735
N781AN			789194						2721
N775AN			813141						2710
--snip
*/

-- Delta Air Lines Inc. aircraft avg distance travel per aircraft (Tail_NumberNxxxNW/DA)
SELECT Tail_Number, 
	   SUM(Distance) AS Total_Dist_2019_AND_2018, 
       CAST(AVG(Distance) AS DECIMAL) AS Avg_Dist
FROM flights
WHERE AirlineName = 'Delta Air Lines Inc.' AND Tail_Number IS NOT NULL
GROUP BY Tail_Number
ORDER BY Avg_Dist DESC
;
/* Result 
Tail_Number		Total_Dist_2019_AND_2018	Avg_Dist
N860DA			191999						3765
N812NW			163221						3139
N820NW			159288						3123
N811NW			112809						3049
N809NW			242271						2991
--snip
*/

-- Southwest Airlines Co. aircraft avg distance travel per aircraft (Tail_NumberNxxxxQ/H/M/D/W/A)
SELECT Tail_Number, 
	   SUM(Distance) AS Total_Dist_2019_AND_2018, 
       CAST(AVG(Distance) AS DECIMAL) AS Avg_Dist
FROM flights
WHERE AirlineName = 'Southwest Airlines Co.' AND Tail_Number IS NOT NULL
GROUP BY Tail_Number
ORDER BY Avg_Dist DESC
;
/* Result 
Tail_Number		Total_Dist_2019_AND_2018	Avg_Dist
N8718Q			1428160						1072
N8726H			751200						1070
N8723Q			577707						1064
N8711Q			1921475						1056
N8717M			1541472						1055
*/

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
SELECT SUM(Total_Dist_2019_AND_2018) AS Accumulated_Dist_Travelled_by_AA
FROM CTE_AA
;
/* Result 
Accumulated_Dist_Travelled_by_AA
1870581324
*/

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
SELECT SUM(Total_Dist_2019_AND_2018) AS Accumulated_Dist_Travelled_by_DA
FROM CTE_DA
;
/* Result 
Accumulated_Dist_Travelled_by_DA
'1731685970'
*/

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
SELECT SUM(Total_Dist_2019_AND_2018) AS Accumulated_Dist_Travelled_by_SA
FROM CTE_SW
;
/* Result 
Accumulated_Dist_Travelled_by_SA
'2017051073'
*/

/* 
Looking at total accumulate miles Southwest Airlines Co. have 200M miles compare to the 2
two (2) other airlines and about 200 plane less. Has more utilization of plane. 
But the number of Southwest Airlines Co. number of flights almost the same in 2018 & 2019.(Ref Q2.2)
*/


/* ------------------------------------------------------------------------------------- */
/*Question 5 */
/*
Finally, the fund managers would like you to investigate the three airlines and major airports 
in terms of on-time performance as well. 

For each of the following questions, consider early 
departures and arrivals (negative values) as on-time (0 delay) in your calculations.
Next, we will look into on-time performance more granularly in relation to the time of departure. 

We can break up the departure times into three categories as follows:
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
Make sure you comment on the results in your script. 
*/

-- SELECT * FROM flights;
-- SELECT * FROM airports;

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

-- Create a temp table with the query code above.
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
/* Result 
time_of_day		Avg_Min_Delay 
1-morning		26
2-afternoon		30
3-evening		36
4-night			30 
Average delay in minutes at each time of day
*/

-- Now, find the average departure delay for each airport and time-of-day combination. 
DROP VIEW IF EXISTS airport_delay;
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
			FROM airport_delay -- From the created view table
			LIMIT 10
)
SELECT DISTINCT(AirportName), Avg_Minutes_Delay, time_of_day
FROM airports
JOIN CTE_Airport_Delay
	ON airports.AirportID = CTE_Airport_Delay.OriginAirportID
;
/*
AirportName									Avg_Minutes_Delay	time_of_day
Hartsfield-Jackson Atlanta International		30.8652			2-afternoon
Hartsfield-Jackson Atlanta International		30.8652	  		4-night
Hartsfield-Jackson Atlanta International		30.8652	  		1-morning
Ronald Reagan Washington National				30.8652			3-evening
Denver International							30.8652			2-afternoon
Dallas/Fort Worth International					30.8652			2-afternoon
-- snip--
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
-- SELECT * FROM Tbl;
/* Result of running SELECT * FROM Tbl
OriginAirportID		FlightDate		DepDelay	time_of_day
'10397', 			'2018-10-10', 	'4', 		'2-afternoon'
'14027', 			'2018-10-10', 	'8', 		'1-morning'
--snip--
*/

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
-- SELECT * FROM Tbl1mng;
/* Result of running SELECT * FROM Tbl1mng
OriginAirportID		FlightDate		Minutes_Delay		time_of_day
14027				2018-10-10		8					1-morning
--snip--
*/

-- Create a table of flight count (TblFlgCnt)
DROP VIEW IF EXISTS TblFlgCnt;
CREATE VIEW TblFlgCnt AS
		SELECT OriginAirportID,
			   COUNT(FlightDate) AS flight_count
		FROM flights
		GROUP BY OriginAirportID
;
SELECT * FROM TblFlgCnt;
/* Result of running SELECT * FROM TblFlgCnt
OriginAirportID		flight_count	
14747				97380
--snip--
*/

-- Filter OriginAirportID, AirportName with 10K and above
-- To be used as a filter table (Tbl10K)
DROP VIEW IF EXISTS Tbl10K;
CREATE VIEW Tbl10K AS
		SELECT t.OriginAirportID, 
			   a.AirportName,
			   t.flight_count AS flight_count
		FROM TblFlgCnt t
		JOIN airports a
			ON a.AirportID = t.OriginAirportID
		WHERE flight_count >= 10000
		GROUP BY OriginAirportID, a.AirportName
;
-- SELECT * FROM Tbl10K;
 /* Result of running SELECT * FROM Tbl10K
 OriginAirportID	AirportName								flight_count
'10140', 			'Albuquerque International Sunport', 	'30572'
--snip--
*/       
        
-- Query a table where the time_of_day is 1-morning and
-- using subquery to filter with airport of 10k flights table
-- By casting to DECIMAL it ran (26.703 ran more 0.062 sec). Without CAST 26.641
SELECT OriginAirportID, CAST(AVG(Minutes_Delay) AS DECIMAL) AS Avg_Minutes_Delay
FROM Tbl1Mng
WHERE OriginAirportID IN
				-- Subquery of airport with 10K flights
				(SELECT t.OriginAirportID 
				FROM Tbl10K t
				-- LIMIT 10
	 )
GROUP BY OriginAirportID
ORDER BY Avg_Minutes_Delay DESC
-- LIMIT 1000 -- Uncomment for testing, Comment to get full list;
/* Result
OriginAirportID		Avg_Minutes_Delay
14843					49
11618					43
12266					43
--snip--
*/
;

/* Create a view of RnkDelay embedded with a temp table CTE */
/* */
DROP VIEW IF EXISTS RnkDelay;
CREATE VIEW RnkDelay AS
		WITH CTE AS (
			  SELECT OriginAirportID, 
					 CAST(AVG(Minutes_Delay) AS DECIMAL) AS Avg_Minutes_Delay
			  FROM Tbl1Mng
			  WHERE OriginAirportID IN
								(SELECT t.OriginAirportID 
								 FROM Tbl10K t
								-- LIMIT 10 -- MySQL doesn't support LIMIT & IN/ALL/ANY
                                )
		GROUP BY OriginAirportID
		ORDER BY Avg_Minutes_Delay DESC )

SELECT 	a.City, 
		a.AirportName, 
        Avg_Minutes_Delay,
        RANK() OVER(ORDER BY Avg_Minutes_Delay DESC) AS rnk
        -- DENSE_RANK () OVER(ORDER BY Avg_Minutes_Delay DESC) AS denseRank
FROM airports a
JOIN CTE c
	ON c.OriginAirportID = a.AirportID
;
/* */

SELECT *
FROM RnkDelay
WHERE rnk <= 10 -- TopN. Change whatever ranking it wants.
-- WHERE denseRank <=10 -- If using uncomment the DENSE_RANK() and re-run the view.
;

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
-- snip--
*/
