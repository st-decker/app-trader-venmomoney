--Part 1
--Round ratings in both tables
---App store already rounded
--Get rid of $ sign in playstore prices
--Convert playstore prices to numeric (like appstore)
--Generate CTEs to hold playstore and functions

--Part 2
/*
From other file I know there are lots of duplicate apps within the play store. Copy that code over.
Figure out how to store that table so I can use it without the duplicates
*/


--Retreiving err with below. 
/*
SELECT rating
FROM app_store_apps
WHERE rating NOT LIKE '%.5'
	AND rating NOT LIKE '%.0';
*/

--Corrected. LIKE/NOT LIKE is a string comparison 
--Result: Every rating is rounded
/*
SELECT rating
FROM app_store_apps
WHERE CAST(rating AS TEXT) NOT LIKE '%.5'
	AND CAST(rating AS TEXT) NOT LIKE '%.0'
*/

--Playstore is not rounded
--7188 not rounded
/*
SELECT COUNT(rating)
FROM play_store_apps
WHERE CAST(rating AS TEXT) NOT LIKE '%.5'
	AND CAST(rating AS TEXT) NOT LIKE '%.0'
*/

--Round the ratings in the playstore
/*
SELECT ROUND((FLOOR(rating*2)/2), 1) AS clean_play_rating
FROM play_store_apps
WHERE rating IS NOT NULL
ORDER BY test DESC
*/


--How do you change the format of the price table in play_store_apps? stuck
--Change $%.% to a number
--Get rid of $ and convert to numeric, not integer
/*
SELECT CAST(REPLACE(price,'$','') AS NUMERIC) AS clean_play_price
FROM play_store_apps
*/

--Create a clean playstore CTE
/*
WITH cp AS (
	SELECT 
 		name AS cpn,
		CAST(REPLACE(price,'$','') AS NUMERIC) AS cpp,
 		ROUND((FLOOR(rating*2)/2), 1) AS cpr,
 		genres AS cpg
 	FROM play_store_apps
	WHERE rating IS NOT NULL
	GROUP BY cpn, cpp, cpr, cpg
)
*/

--Create a clean appstore CTE. not sure if it's necessary, the relevant data seems to be clean already


--Compare the CTE with app_store_apps
--Some rating differences, some price differences
/*
SELECT
	cp.cpn,
	a.name,
	cp.cpp,
	a.price,
	cp.cpr,
	a.rating,
	cp.cpg,
	a.primary_genre
FROM cp
INNER JOIN app_store_apps AS a
ON cp.cpn = a.name
*/

--How many have different ratings
--181
/*
SELECT
	cp.cpn,
	a.name,
	cp.cpp,
	a.price,
	cp.cpr,
	a.rating
FROM cp
INNER JOIN app_store_apps AS a
ON cp.cpn = a.name
WHERE cp.cpr <> a.rating
*/

--30 apps not the same price with rating => 4.0
--DOUBLE CHECK WITH OUR FINAL TOP 10 TO SEE IF THESE ARE IN LIST
/*
SELECT
	cp.cpn,
	a.name,
	cp.cpp,
	a.price,
	cp.cpr,
	a.rating
FROM cp
INNER JOIN app_store_apps AS a
ON cp.cpn = a.name
WHERE cp.cpp <> a.price
	AND cp.cpr >= 4.0 AND a.rating >=4.0
*/
WITH cp AS (
		SELECT 
			name,
			CAST(REPLACE(price,'$','') AS NUMERIC) AS cpp,
			ROUND((FLOOR(rating*2)/2), 1) AS cpr,
			CAST(REPLACE(REPLACE(install_count,'+',''),',','') AS NUMERIC) AS cpic,
			genres AS genre
		FROM play_store_apps
		WHERE rating IS NOT NULL
		GROUP BY name, cpp, cpr, cpic, genre
),
	cpfunc AS (
		SELECT
		name,
			CASE 
				WHEN cpp BETWEEN 0 AND 1 THEN 10000
				ELSE (cpp * 10000) END AS cpbuyprice,
		FLOOR((cpr * 2) + 1) AS cplongevity,
		(FLOOR((cpr * 2) + 1) *12) * 5000  AS cprevenue,
		(FLOOR((cpr * 2) + 1) *12) * 1000  AS cpmarketing,
		genre,
		cpic
		FROM cp
),
	endcp AS (
		SELECT
			name,
			cpbuyprice,
			cplongevity,
			cprevenue,
			cpmarketing,
			((cpfunc.cprevenue - cpfunc.cpmarketing) - cpfunc.cpbuyprice) AS cpexpectedprofit,
			genre,
			cpic
	FROM cpfunc
),
	ca AS (
		SELECT
			name,
			price,
			rating,
			primary_genre AS genre
		FROM app_store_apps
		WHERE rating IS NOT NULL
		GROUP BY name, price, rating, genre	
),
	cafunc AS (
		SELECT
		name,
			CASE 
				WHEN price BETWEEN 0 AND 1 THEN 10000
				ELSE (price * 10000) END AS cabuyprice,
		FLOOR((rating * 2) + 1) AS calongevity,
		(FLOOR((rating * 2) + 1) *12) * 5000  AS carevenue,
		(FLOOR((rating * 2) + 1) *12) * 1000  AS camarketing,
		genre
		FROM ca	
), 
	endca AS (
		SELECT
			name,
			cabuyprice,
			calongevity,
			carevenue,
			camarketing,
			((cafunc.carevenue - cafunc.camarketing) - cafunc.cabuyprice) AS caexpectedprofit,
			genre
	FROM cafunc
)
SELECT caexpectedprofit from endca


--Greatest expected profit is $518,000 for only cleaned play store table
--Need to differentiate apps. Explore what will make some stand out ie review_count, content_rating, genre
/*
SELECT * 
FROM endcp 
WHERE cpexpectedprofit >= 0 
ORDER BY cpexpectedprofit DESC
*/

--Joined tables
--Max amount is $470000
/*
SELECT DISTINCT(cpn), cpg, cpic,
	CASE WHEN cpexpectedprofit <0 THEN NULL
		 ELSE cpexpectedprofit END
FROM endcp
INNER JOIN app_store_apps AS a
ON endcp.cpn = a.name
INNER JOIN play_store_apps
ON endcp.cpn = play_store_apps.name
WHERE endcp.cpexpectedprofit >= 470000
ORDER BY cpic DESC
*/