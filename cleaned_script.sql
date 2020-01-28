/*
To do
1) Round the ratings in the play store
--App store is already rounded
2) Get rid of the '$' within the play store prices
3) Convert play store prices to numeric
4) Generate CTEs to hold cleaned data, functions, etc.
5) Compare combined tables using given assumptions

Top 10 Black Friday Apps
"ASOS" - Shopping
"The Guardian" - News
"Domino's Pizza USA" - Food & Drink
"Wish - Shopping Made Fun" - Shopping
"PewDiePie's Tuber Simulator" - Games
"Geometry Dash Lite" - Games
"Egg, Inc." - Games
"Cytus" - Games
"Chase Mobile" - Finance
"Instagram" - Photo & Video


General recommendations
1) Focus on ratings that tend to be higher i.e. 4.5 to 5.0. 
	A higher longevity with a slightly higher app purchasing price tends to pay out more than a free app with a lower longevity.
2) The most profitable apps tend to be games, so if you wish to look outside the top 10 then games are a good area to start. 
3) The highest possible expected profit an app can make in either the app store or the play store is $518,000
However, it is more profitable to focus on apps that are within both stores because you save money through marketing. The combined
	price of an app within both stores is $988,000 although hypothetically it should be $1,036,000. Would need to explore further, 
	possibly an error when combining tables.
4) There does not seem to be high correlation between content rating and profitability, although most apps seem to be 4+ (app store) or
	'Everyone' (play store), so outside of the top 10 it might be worthwhile to look into with a lower content rating. 
5) After excluding 'Games' you might be interested in diversifying your app genres. Apps outside of the top 10 that are not games 
	top out at $940,000. If you are looking for the highest average rating between both stores, apps such as "The EO Bar" and 
	"H*onest Meditation" are good options. A blend of all worlds would be "Chase Mobile"
6) Apps making the top profit within three different genres, three different content ratings,
	with high ratings and with high review counts would be "Instagram", "Wish - Shopping Made Fun" and the "Bible"
*/

--Steps to CTEs

/*
--Retreiving err with below. 
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

--Cleaned CTEs listed below
WITH clean_play AS (
		SELECT 
			name,
			CAST(REPLACE(price,'$','') AS NUMERIC) AS play_price,
			ROUND((FLOOR(rating*2)/2), 1) AS play_rating,
			CAST(REPLACE(REPLACE(install_count,'+',''),',','') AS NUMERIC) AS play_install,
			genres AS play_genre,
			content_rating,
			review_count,
			rating
		FROM play_store_apps
		 --WHERE rating IS NOT NULL
		GROUP BY name, play_price, play_rating, play_install, play_genre, content_rating, review_count, rating
),
	play_func AS (
		SELECT
		name,
			CASE 
				WHEN play_price BETWEEN 0 AND 1 THEN 10000
				ELSE (play_price * 10000) END AS play_buy_price,
		FLOOR((play_rating * 2) + 1) AS play_longevity,
		(FLOOR((play_rating * 2) + 1) *12) * 5000  AS play_revenue,
		(FLOOR((play_rating * 2) + 1) *12) * 1000  AS play_marketing_cost,
		play_genre,
		content_rating,
		review_count,
		rating
		FROM clean_play
),
	play_table AS (
		SELECT
			name,
			play_buy_price,
			play_longevity ,
			play_revenue,
			play_marketing_cost,
			((play_func.play_revenue - play_func.play_marketing_cost) - play_func.play_buy_price) AS play_expected_profit,
			play_genre,
			content_rating,
			review_count,
			rating
	FROM play_func
),
	app_func AS (
		SELECT
		name,
			CASE 
				WHEN price BETWEEN 0 AND 1 THEN 10000
				ELSE (price * 10000) END AS app_buy_price,
		FLOOR((rating * 2) + 1) AS app_longevity,
		(FLOOR((rating * 2) + 1) *12) * 5000  AS app_revenue,
		(FLOOR((rating * 2) + 1) *12) * 1000  AS app_marketing_cost,
		rating,
		primary_genre AS genre, 
		content_rating, 
		CAST(review_count AS INTEGER)
		FROM app_store_apps	
), 
	app_table AS (
		SELECT
			name,
			app_buy_price,
			app_longevity,
			app_revenue,
			app_marketing_Cost,
			((app_func.app_revenue - app_func.app_marketing_cost) - app_func.app_buy_price) AS app_expected_profit,
			genre,
			rating,
			content_rating,
			review_count
	FROM app_func
)

--Average rating for apps in both stores, along with combined review counts
--Only looking at apps with 4.5 and above.
--Top 8 Apps are 4.85 or above, besides Geometry Dash Lite which is 4.75. Of top 8, 4 are games, 2 are shopping
--Kept switching ORDER BY * DESC and examined apps based on average_rating, content_rating, genre


SELECT
	a.name,
	app_expected_profit + play_expected_profit AS joined_expected_profit
FROM app_table AS a
INNER JOIN play_table as p
ON a.name = p.name
ORDER BY joined_expected_profit DESC
/*
SELECT 
	a.name,
	app_expected_profit + play_expected_profit AS joined_expected_profit,
	genre,
	p.content_rating,
	(a.rating + p.rating) / 2 AS average_rating,
	a.review_count + p.review_count AS joined_review_count
FROM app_table AS a
INNER JOIN play_table AS p
ON a.name = p.name
WHERE (a.rating + p.rating) / 2 >= 4.5
	AND genre <> 'Games'
ORDER BY joined_expected_profit DESC
*/