-----------------------------------------------------------------------------------------------------------------------------
-- Bixi Project - Part 1 - Data Analysis in SQL --
/*
Our goal is to gain a high level understanding of how people use Bixi bikes, 
what factors influence the volume of usage, popular stations and overall business growth.
The data is a cleaned up version of data downloaded from the open data portal at Bixi Montreal: 
https://www.bixi.com/en/open-data
*/
-----------------------------------------------------------------------------------------------------------------------------
-- Question 1 --
-- First, we will attempt to gain an overall view of the volume of usage of Bixi Bikes and what factors influence it.
-----------------------------------------------------------------------------------------------------------------------------
/*
	||Q.1.1||
		The total number of trips for the year of 2016.
*/
SELECT 
    COUNT(id) AS 'Trips_2016'
FROM
    trips
WHERE
    start_date >= '2016-01-01'
        AND end_date < '2017-01-01';
/*
	//A.1.1\\
		There are '3917401' trips in 2016.
*/
/*
	||Q.1.2.|| 
		The total number of trips for the year of 2017.
*/
SELECT 
    COUNT(id) AS 'Trips_2017'
FROM
    trips
WHERE
    start_date >= '2017-01-01'
        AND end_date < '2018-01-01';
/*
	//A.1.2\\ 
		There are '4666765' trips in 2017.
*/
/*||Q.1.3|| 
	The total number of trips for the year of 2016 broken-down by month.
*/
SELECT 
    (CASE #Adding the names to months for readability
        WHEN DATE_FORMAT(start_date, '%m') = 1 THEN 'Jan'
        WHEN DATE_FORMAT(start_date, '%m') = 2 THEN 'Feb'
        WHEN DATE_FORMAT(start_date, '%m') = 3 THEN 'Mar'
        WHEN DATE_FORMAT(start_date, '%m') = 4 THEN 'Apr'
        WHEN DATE_FORMAT(start_date, '%m') = 5 THEN 'May'
        WHEN DATE_FORMAT(start_date, '%m') = 6 THEN 'Jun'
        WHEN DATE_FORMAT(start_date, '%m') = 7 THEN 'Jul'
        WHEN DATE_FORMAT(start_date, '%m') = 8 THEN 'Aug'
        WHEN DATE_FORMAT(start_date, '%m') = 9 THEN 'Sep'
        WHEN DATE_FORMAT(start_date, '%m') = 10 THEN 'Oct'
        WHEN DATE_FORMAT(start_date, '%m') = 11 THEN 'Nov'
        ELSE 'Dec'
    END) AS 'Month_2016',
    COUNT(id) AS 'Trips_2016'
FROM
    trips
WHERE
    start_date >= '2016-01-01'
        AND end_date < '2017-01-01'
GROUP BY Month_2016;
/* 
	//A.1.3\\ 
		The trip data in 2016 starts in April, and ends in Nov.
		The amount of trips reaches its peak in July. 
*/
/*
	||Q.1.4||
		The total number of trips for the year of 2017 broken-down by month.
*/
SELECT 
    (CASE #Adding the names to months for readability
        WHEN DATE_FORMAT(start_date, '%m') = 1 THEN 'Jan'
        WHEN DATE_FORMAT(start_date, '%m') = 2 THEN 'Feb'
        WHEN DATE_FORMAT(start_date, '%m') = 3 THEN 'Mar'
        WHEN DATE_FORMAT(start_date, '%m') = 4 THEN 'Apr'
        WHEN DATE_FORMAT(start_date, '%m') = 5 THEN 'May'
        WHEN DATE_FORMAT(start_date, '%m') = 6 THEN 'Jun'
        WHEN DATE_FORMAT(start_date, '%m') = 7 THEN 'Jul'
        WHEN DATE_FORMAT(start_date, '%m') = 8 THEN 'Aug'
        WHEN DATE_FORMAT(start_date, '%m') = 9 THEN 'Sep'
        WHEN DATE_FORMAT(start_date, '%m') = 10 THEN 'Oct'
        WHEN DATE_FORMAT(start_date, '%m') = 11 THEN 'Nov'
        ELSE 'Dec'
    END) AS 'Month_2017',
    COUNT(id) AS 'Trips_2017'
FROM
    trips
WHERE
    start_date >= '2017-01-01'
        AND end_date < '2018-01-01'
GROUP BY Month_2017;
/*
	//A.1.4\\
		again we see the trip data in 2017 starts in april and ends in Nov.
		We also see the same pattern with a peek in July
		The inactivity is possibly due to the winter seasons, and cold tempretures in Montreal.
		More information is needed to make this assumption.
*/
/* 
	||Q.1.5||
		The average number of trips a day for each year-month combination in the dataset.
*/
SELECT 
    Year_Month_, 
    ROUND(AVG(Num_of_Trips)) AS 'Avg_Trips'
FROM
    (SELECT 
        DATE_FORMAT(start_date, '%Y%m') AS 'Year_Month_',
            COUNT(*) AS 'Num_of_Trips'
    FROM
        trips
    GROUP BY DATE_FORMAT(start_date, '%Y%m')) AS a
GROUP BY Year_Month_;

-- Correct answer --
SELECT
	YEAR(start_date),
	MONTH(start_date),
	COUNT(*)/ROUND(COUNT(DISTINCT DAY(start_date)),0) AS daily_avg
    FROM trips
    GROUP BY YEAR(start_date), MONTH(start_date)
    ORDER BY YEAR(start_date), MONTH(start_date);

/* 
	//A.1.5\\
		Both years display a similar pattern where the trips are highest in June, July, and August(summer season). 
		Is temperature a factor?  
		By analyzing the Montreal weather data on the following website:
		https://weatherspark.com/h/y/25077/2017/Historical-Weather-during-2017-in-Montr%C3%A9al-Canada#Figures-Temperature
		The fluctuations in trips strongly suggest a correlation with temperature and the amount of riders. 
*/
/* 
	||Q.1.6||
		Save your query results from the previous question (Q1.5) by creating a table called working_table1.
*/
#| Step 1 | Drop existing table
DROP TABLE IF EXISTS working_table1;

#| Step 2 | Creating 'working_table1'.
CREATE TABLE working_table1 (
	SELECT 
		Year_Month_Date, 
		ROUND(AVG(Num_of_Trips)) AS 'Avg_Trips' 
    FROM (
		SELECT 
			DATE_FORMAT(start_date, '%Y%m') AS 'Year_Month_Date',
            COUNT(id) AS 'Num_of_Trips'
		FROM
			trips
		GROUP BY DATE_FORMAT(start_date, '%Y%m')) AS a
GROUP BY Year_Month_Date);
-----------------------------------------------------------------------------------------------------------------------------
-- Question 2 --
/* 
	Unsurprisingly, the number of trips varies greatly throughout the year. How about membership status? 
	Should we expect member and non-member to behave differently? To start investigating that, calculate: 
*/
-----------------------------------------------------------------------------------------------------------------------------
/*
	||Q2.1||
		The total number of trips in the year 2017 broken-down by membership status (member/non-member).
*/
SELECT 
    COUNT(id) AS 'Num_of_Members_2017',
    IF(is_member = 1, #adding labels for readability
        'Member',
        'Non-member') AS 'Membership_Status'
FROM
    trips
WHERE
    start_date >= '2017-01-01'
        AND end_date < '2018-01-01'
GROUP BY is_member;
/*
	//A2.1\\
	  The total numbers are: 
							 Members: 3784682 
                             Non-Members: 882083
	  Approximately 81% of riders are members, and 19% are non-members. 
      It is safe to assume that customers favor bixi membership programs, and strong marketing stratagies may
      already be in place to attract customers to membership programs.
*/
/*
	||Q2.2||
		The fraction of total trips that were done by members for the year of 2017 broken-down by month.
*/
SELECT 
    CASE #Adding the names to months for readability
        WHEN Month = 1 THEN 'Jan'
        WHEN Month = 2 THEN 'Feb'
        WHEN Month = 3 THEN 'Mar'
        WHEN Month = 4 THEN 'Apr'
        WHEN Month = 5 THEN 'May'
        WHEN Month = 6 THEN 'Jun'
        WHEN Month = 7 THEN 'Jul'
        WHEN Month = 8 THEN 'Aug'
        WHEN Month = 9 THEN 'Sep'
        WHEN Month = 10 THEN 'Oct'
        WHEN Month = 11 THEN 'Nov'
        ELSE 'Dec'
    END AS 'Month_in_2017',
    ROUND(Num_of_Trips_2017 / ( #applying fraction to 'trips per month' with 'total trips in 2017'
				SELECT 
                    COUNT(id) AS 'Num_of_Members_2017'
                FROM
                    trips
                WHERE
                    start_date >= '2017-01-01'
                        AND end_date < '2018-01-01'
                        AND is_member = 1) * 100, 1) AS '%Trips_Members' #Converted to percent and rounded for readability
FROM
    (SELECT 
        DATE_FORMAT(start_date, '%m') AS 'Month',
            COUNT(id) AS 'Num_of_Trips_2017'
    FROM
        trips
    WHERE
        start_date >= '2017-01-01'
            AND end_date < '2018-01-01'
            AND is_member = 1
    GROUP BY DATE_FORMAT(start_date, '%m')) AS a;
/* 
	//A2.2\\
		We can now gauge 2017 rider numbers with percentages. 
		There is a peek in july, with approximately 17.4% of total members active.
*/
-----------------------------------------------------------------------------------------------------------------------------
-- Question 3 --
-- Use the above queries to answer the questions below.
-----------------------------------------------------------------------------------------------------------------------------
/* 
	||Q3.1||
		Which time of the year the demand for Bixi bikes is at its peak?
    
	//A3.1\\
		The highest demand for Bixi Bikes is in these months:
			1.July 17.4% 
			2.August 17.3%
			3.June 15.8%, 
		The combined total of approximately 50.6%, of members, are active within these 3 months.
*/
/* 
	||Q3.2||
		If you were to offer non-members a special promotion
		in an attempt to convert them to members, when would you do it?
*/
# Querying for non-members
SELECT 
    DATE_FORMAT(start_date, '%m') AS 'Month_in_2017',
    ROUND((COUNT(id) / 882083) * 100, 2) AS '%Trips_by_NonMembers' #882083 is the total nonMembers in 2017 found in the previous query.
FROM
    trips
WHERE
    start_date >= '2017-01-01'
        AND end_date < '2018-01-01'
        AND is_member = '0'
GROUP BY DATE_FORMAT(start_date, '%m')
ORDER BY ROUND((COUNT(id) / 882083), 3) DESC;
/* 
	//A3.2\\
		The demand reaches its peek for 'non-members' is the same as it is with 'members', July.
		I would offer my promotions at this time because the majority of riders will be active.
		Thus having a higher chance to convert a larger amount of non-members
*/ 
-----------------------------------------------------------------------------------------------------------------------------
-- Question 4 --
/* 
	It is clear now that average temperature and membership status are intertwined and influence greatly 
	how people use Bixi bikes. Let’s try to bring this knowledge with us and learn something about station popularity.
*/
-----------------------------------------------------------------------------------------------------------------------------
/*
	||Q4.1||
		What are the names of the 5 most popular starting stations? Solve this problem without using a subquery.
*/
SELECT 
    name AS 'station_name', 
    COUNT(start_station_code) AS 'Num_of_Trips'
FROM
    trips AS a
INNER JOIN
    stations AS b 
ON a.start_station_code = b.code
GROUP BY name
ORDER BY Num_of_Trips DESC
LIMIT 5;
/*
	//A4.1\\
		The top 5 most popular stations are:
			1.'Mackay / de Maisonneuve'
            2.'Métro Mont-Royal (Rivard / du Mont-Royal)'
            3.'Métro Place-des-Arts (de Maisonneuve / de Bleury)'
            4.'Métro Laurier (Rivard / Laurier)'
            5.'Métro Peel (de Maisonneuve / Stanley)'
*/
/*
	||Q4.2||
		Solve the same question as Q4.1, but now use a subquery. Is there a difference in query run time between 4.1 and 4.2?    
*/
SELECT 
    a.name AS 'station_name', 
    b.Num_of_Trips
FROM
    stations AS a
INNER JOIN
    (SELECT 
        start_station_code, 
        COUNT(start_station_code) AS 'Num_of_Trips'
    FROM
        trips
    GROUP BY start_station_code) AS b 
ON a.code = b.start_station_code
ORDER BY b.Num_of_Trips DESC
LIMIT 5;
/*
	When applying the subquery, 4.2 loads significantly faster than 4.1.
	This has to do the fact that 4.2 does the aggregations first in the subquery, 
	and therefore making it more efficient when joining tables.
*/
-----------------------------------------------------------------------------------------------------------------------------
-- Question 5 --
-- If we break-up the hours of the day as follows:
/* 
	SELECT CASE
       WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning"
       WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN "afternoon"
       WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening"
       ELSE "night"
       END AS "time_of_day",
       ... 
*/
-----------------------------------------------------------------------------------------------------------------------------
/*
	||Q5.1||
		How is the number of starts and ends distributed for the station Mackay / de Maisonneuve throughout the day?
*/
# Step 1. Querying the number of 'starts' at 'Mackay / de Maisonneuve'.
SELECT 
    b.name AS 'Station_Name',
    (CASE
        WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN 'morning'
        WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN 'afternoon'
        WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN 'evening'
        ELSE 'night'
    END) AS 'Time_of_Day',
    COUNT(*) AS 'Start_Trips'
FROM
    trips AS a
INNER JOIN
    stations AS b 
ON a.start_station_code = b.code
WHERE
    b.name = 'Mackay / de Maisonneuve'
GROUP BY Time_of_Day;

# Step 2. Querying the number of ends at 'Mackay / de Maisonneuve'.
SELECT 
    b.name AS 'Station_Name',
    (CASE
        WHEN HOUR(end_date) BETWEEN 7 AND 11 THEN 'morning'
        WHEN HOUR(end_date) BETWEEN 12 AND 16 THEN 'afternoon'
        WHEN HOUR(end_date) BETWEEN 17 AND 21 THEN 'evening'
        ELSE 'night'
    END) AS 'Time_of_Day',
    COUNT(*) AS 'End_Trips'
FROM
    trips AS a
INNER JOIN
    stations AS b 
ON a.start_station_code = b.code
WHERE
    b.name = 'Mackay / de Maisonneuve'
GROUP BY Time_of_Day;

# Step 3. Combining both queries for readability.
SELECT 
	start_a.Time_of_Day,
    start_a.Start_Trips,
    end_b.End_Trips
FROM (SELECT 
    sb.name AS 'Station_Name',
    CASE
        WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN 'morning'
        WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN 'afternoon'
        WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN 'evening'
        ELSE 'night'
    END AS 'Time_of_Day',
    COUNT(*) AS 'Start_Trips'
	FROM
		trips AS sa
	INNER JOIN
		stations AS sb 
	ON sa.start_station_code = sb.code
	WHERE
		sb.name = 'Mackay / de Maisonneuve'
GROUP BY Time_of_Day) AS start_a
INNER JOIN
(SELECT 
    eb.name AS 'Station_Name',
    (CASE
        WHEN HOUR(end_date) BETWEEN 7 AND 11 THEN 'morning'
        WHEN HOUR(end_date) BETWEEN 12 AND 16 THEN 'afternoon'
        WHEN HOUR(end_date) BETWEEN 17 AND 21 THEN 'evening'
        ELSE 'night'
    END) AS 'Time_of_Day',
    COUNT(*) AS 'End_Trips'
FROM
    trips AS ea
INNER JOIN
    stations AS eb 
ON ea.start_station_code = eb.code
WHERE
    eb.name = 'Mackay / de Maisonneuve'
GROUP BY Time_of_Day) AS end_b
ON start_a.Time_of_Day = end_b.Time_of_Day
ORDER BY FIELD(start_a.Time_of_Day,
        'morning',
        'afternoon',
        'evening',
        'night');
/* 
   //A5.1\\
		The number of starts and ends are distributed by the time of day. We can see that both starts and ends
		have a similar pattern where the peak of trips are in the evening, and lowest amount of trips transpire at night.
*/
/*
   ||Q5.2||
		Explain the differences you see and discuss why the numbers are the way they are.
	
   //A5.2\\
		In the morning and afternoon, the numbers for Start_Trips are higher than End_trips.
		During the evening and night, the opposite is shown. This indicates that riders prefer to start their trips 
        in the mornings and afternoons at Mackay / de Maisonneuve, while the evening and nights is more favored for 
        ending their trips in Mackay / de Maisonneuve. 
*/
-----------------------------------------------------------------------------------------------------------------------------
-- Question 6 --
/*
	List all stations for which at least 10% of trips are round trips. 
	Round trips are those that start and end in the same station. This time 
	we will only consider stations with at least 500 starting trips. (Please include answers for all steps outlined here)
*/
-----------------------------------------------------------------------------------------------------------------------------
/*
	||Q6.1||
		First, write a query that counts the number of starting trips per station.
*/
SELECT 
    start_station_code,
    COUNT(start_station_code) AS 'Starting_Trips'
FROM
    trips
GROUP BY start_station_code;
/*
	||Q6.2|| 
		Second, write a query that counts, for each station, the number of round trips.
*/
SELECT 
	start_station_code,
    COUNT(start_station_code) AS 'Round_Trips'
FROM
    trips
WHERE
    start_station_code = end_station_code
GROUP BY start_station_code;
/* 
	||Q6.3||
		Combine the above queries and calculate the fraction of round trips to the total number
		of starting trips for each station.
*/
#| Step 1 | - setting up the table size buffer limit for my working tables.
SET GLOBAL innodb_buffer_pool_size=268435456;

#| Step 2 | - Drop existing tables.
DROP TABLE IF EXISTS round_trips, starting_trips;

#| Step 3 | - Creating 2 working tables to allow more efficient queries.
-- table 1 'starting_trips'
CREATE TABLE starting_trips (
	SELECT 
		start_station_code,
		COUNT(start_station_code) AS 'Starting_Trips' 
	FROM
		trips
	GROUP BY start_station_code);

-- table 2 'round_trips' **NOTE** This query takes very long to run.
CREATE TABLE round_trips (
	SELECT 
		start_station_code,
		COUNT(start_station_code) AS 'Round_Trips'
	FROM
		trips
	WHERE
		start_station_code = end_station_code
	GROUP BY start_station_code);

# Step 4 - combining working tables and selecting the fractions.
SELECT 
    b.start_station_code,
    (b.Round_Trips / a.Starting_Trips) AS 'Fraction_of_Trips'
FROM
    starting_trips AS a
LEFT JOIN
    round_trips AS b 
	USING (start_station_code);
/* 
	||Q6.4||
		Filter down to stations with at least 500 trips originating from them and having at 
		least 10% of their trips as round trips.
*/
SELECT 
	start_station_code AS 'Station_Code',
    Round_Trips,
    Starting_Trips,
    (b.Round_Trips / a.Starting_Trips) AS 'Fraction_of_Roundtrips'
FROM
    starting_trips AS a
INNER JOIN
    round_trips AS b 
	USING (start_station_code)
WHERE Starting_Trips >= 500 #filtering start stations 500 or more.
HAVING (b.Round_Trips / a.Starting_Trips) >= 0.10; #filtering 10% or more rounded trips
/*
	||Q6.5|| 
		Where would you expect to find stations with a high fraction of round trips?
*/
#| Step 1 | Querying the highest fractions with latitude and longitude.
SELECT 
    name AS 'Station_Name',
    (b.Round_Trips / a.Starting_Trips) AS 'Fraction_of_Roundtrips',
    latitude,
    longitude
FROM
    starting_trips AS a
INNER JOIN
    Round_Trips AS b 
	USING (start_station_code)
INNER JOIN 
	stations AS c #Joining the station table to add the name of the station.
    ON b.start_station_code = c.code
WHERE Starting_Trips >= 500 AND (b.Round_Trips / a.Starting_Trips) >= 0.10
ORDER BY Fraction_of_Roundtrips DESC;
#| Step 2 | - Plotting the coordinates on google maps.
/*
	//A6.5\\
        After inspecting the coordinates, the majority of high fraction round trips are located in high-traffic
		areas. Some notable areas include St. Helen's Island, Nuns' Island, and Angrignon Park. These areas are
        mainly known for tourist attractions, and large biking trails which are an ideal place to place Bixi stations.
*/
