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
			CAST(REPLACE(REPLACE(install_count,'+',''),',','') AS NUMERIC) AS cp_install,
			genres AS genre,
			review_count
		FROM play_store_apps
		WHERE rating IS NOT NULL
		GROUP BY name, cpp, cpr, cp_install, genre, review_count
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
		review_count,
		cp_install
		FROM cp
),
	endcp AS (
		SELECT
			name,
			cpbuyprice,
			cplongevity ,
			cprevenue,
			cpmarketing,
			((cpfunc.cprevenue - cpfunc.cpmarketing) - cpfunc.cpbuyprice) AS cpexpectedprofit,
			genre,
			review_count,
			cp_install
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
		rating,
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
			genre,
			rating
	FROM cafunc
)
/*
	 combined_clean_table AS (
		SELECT
			a.name AS appname,
			a.cabuyprice,
			a.calongevity,
			a.carevenue,
			a.camarketing,
			a.caexpectedprofit,
			a.genre,
			a.rating,
			p.name AS playname,
			p.cpbuyprice,
			p.cplongevity ,
			p.cprevenue,
			p.cpmarketing,
			p.cpexpectedprofit,
			p.genre,
			p.review_count,
			p.cp_install
		FROM endcp AS p
		INNER JOIN endca AS a
		ON p.name = a.name
), 
	deliverables AS (
		SELECT 
			(cpbuyprice + cabuyprice) AS combined_buyprice,
			(cpmarketing + camarketing) AS combined_marketing,
			(cprevenue + carevenue) AS combined_revenue,
			(cpexpectedprofit + caexpectedprofit) AS combined_profit
		FROM combined_clean_table
)
*/

--Combined table
/*
SELECT *
FROM combined_clean_table
WHERE cpexpectedprofit > 0
ORDER BY caexpectedprofit DESC
*/

--Greatest expected profit is $518,000 for only cleaned play store table
--SELECT cpexpectedprofit FROM endcp ORDER BY cpexpectedprofit DESC

--Greatest expected profit is also $518,000 for app store table
--SELECT name, caexpectedprofit FROM endca ORDER BY caexpectedprofit DESC
--Need to differentiate apps. Explore what will make some stand out ie review_count, content_rating, genre
/*
SELECT * 
FROM endcp 
WHERE cpexpectedprofit >= 0 
ORDER BY cpexpectedprofit DESC
*/

--Top 10 apps from joining the two cleaned tables
/*
"PewDiePie's Tuber Simulator", "The Guardian","Egg, Inc.""Domino's Pizza USA"
"Geometry Dash Lite", "ASOS", "Cytus", "Narcos: Cartel Wars", "YouTube Kids", "Smashy Road: Arena"

Cytus, Narcos: Cartel Wars, YouTube Kids, Smashy Road: Arena are not making max profit from app store. Explore play store 
apps making more
*/

/*
SELECT endca.name, endca.caexpectedprofit, endca.genre, endcp.genre
FROM endca
INNER JOIN endcp
ON endca.name = endcp.name
WHERE caexpectedprofit >0 and cpexpectedprofit >0
ORDER BY caexpectedprofit DESC
*/

--test
WITH test_play AS (
		SELECT 
			name,
			CAST(REPLACE(price,'$','') AS NUMERIC) AS cleaned_price,
			ROUND((FLOOR(rating*2)/2), 1) AS cleaned_rating,
			CAST(REPLACE(REPLACE(install_count,'+',''),',','') AS NUMERIC) AS cleaned_install,
			genres AS play_genre,
			content_rating,
			review_count,
			rating
		FROM play_store_apps
		 --WHERE rating IS NOT NULL
		GROUP BY name, play_price, play_rating, play_install, play_genre, content_rating, review_count, rating
)