/*
Final table should ressemble something like this 
-- Buy price
-- Longevity
-- Marketing Cost
-- Margin
*/

/*
--How many apps in both?
SELECT COUNT(*) AS app_store,
	--Subquery, remember to surround in parentheses
	(SELECT COUNT(*) AS play_store
		FROM play_store_apps)
FROM app_store_apps;
*/

--Only 11-12 price ranges
-- SELECT a.price
-- FROM app_store_apps AS a
-- INNER JOIN play_store_apps AS p
-- ON a.name = p.name
-- GROUP BY a.price
-- ORDER BY price DESC;

/*SELECT a.name, a.price, a.rating
FROM app_store_apps AS a
LEFT JOIN play_store_apps AS p
ON a.name = p.name
WHERE a.rating = 4.5 and p.rating = 4.5
	AND a.price BETWEEN 0 AND 1.99
ORDER BY a.price DESC;*/

/*SELECT a.name, a.price, p.name, p.price 
FROM app_store_apps AS a
INNER JOIN play_store_apps as p
ON a.name = p.name
WHERE a.price <= .99 AND CAST(p.price AS INTEGER) <= .99
	AND p.price NOT LIKE '$_.%'
	AND p.price NOT LIKE '$__.%'
	AND p.price NOT LIKE '$___.%'*/
	
--Testing apps that are $0, ignoring play_store's text prices
/*
SELECT a.name, a.price, p.price 
FROM app_store_apps AS a
INNER JOIN play_store_apps as p
ON a.name = p.name
WHERE a.price <= .99 AND CAST(p.price AS INTEGER) <= .99
	AND p.price NOT LIKE '$%.%'
*/

--Are there any duplicates? App store
--VR Roller Coaster and Mannequin Challenge 
/*
SELECT name, COUNT(name) as test
FROM app_store_apps
GROUP BY name
HAVING COUNT(name) > 1
*/

/*
--Are there any duplicates? Play store
--Tons
SELECT name, COUNT(name) as test
FROM play_store_apps
GROUP BY name
HAVING COUNT(name) > 1
*/

--What is type in playstore?
--Whether an app is free or not/
/*
SELECT type
FROM play_store_apps;
*/

--What is the difference between category and genres in playstore?
--Kind of similar, don't think category really matters
/*
SELECT DISTINCT(category), genres
FROM play_store_apps;
*/

--Can I group all the apps in play store together to get rid of the duplicates?
--How do I save this? I think I have to create a new table.
-- SELECT name, rating, content_rating, price, genres
-- FROM play_store_apps
-- WHERE rating IS NOT NULL
-- GROUP BY name, rating, content_rating, price, genres

--Maybe use a CTE?
--Apps with similar names like "Angry Birds, Mircosoft"
/*Most apps seem to be the same name within both, ratings can be different but it won't matter since we are only looking at
4.5+ rating I think.
*/
WITH playstore AS (
	SELECT name, rating, content_rating, price, genres
	FROM play_store_apps
	WHERE rating IS NOT NULL
	GROUP BY name, rating, content_rating, price, genres
)
