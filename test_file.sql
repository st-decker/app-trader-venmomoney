--Part 1
--Round ratings in both tables
---App store already rounded
--Get rid of $ sign in playstore prices
--Convert playstore prices to numeric (like appstore)

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

--Create a clean appstore CTE


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
			name AS cpn,
			CAST(REPLACE(price,'$','') AS NUMERIC) AS cpp,
			ROUND((FLOOR(rating*2)/2), 1) AS cpr,
			genres AS cpg
		FROM play_store_apps
		WHERE rating IS NOT NULL
		GROUP BY cpn, cpp, cpr, cpg
),
	cpfunc AS (
		SELECT
		cpn,
			CASE 
				WHEN cpp BETWEEN 0 AND 1 THEN 10000
				ELSE (cpp * 10000) END AS cpbuyprice,
		FLOOR((cpr * 2) + 1) AS cplongevity,
		(FLOOR((cpr * 2) + 1) *12) * 5000  AS cprevenue,
		(FLOOR((cpr * 2) + 1) *12) * 1000  AS cpmarketing
		
		FROM cp
),
	endcp AS (
		SELECT
			cpn,
			cpbuyprice,
			cplongevity,
			cprevenue,
			cpmarketing,
			((cpfunc.cprevenue - cpfunc.cpmarketing) - cpfunc.cpbuyprice) AS cpexpectedprofit
	FROM cpfunc
)

--Greatest expected profit is $518,000
SELECT * 
FROM endcp 
WHERE cpexpectedprofit >= 0 
ORDER BY cpexpectedprofit DESC