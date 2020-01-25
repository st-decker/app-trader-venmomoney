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
SELECT ROUND((FLOOR(rating*2)/2), 1) AS test
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