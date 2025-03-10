-- 1. How many rows are in the names table?
-- Ans: 1957046

SELECT COUNT(*)
FROM names
;


-- 2. How many total registered people appear in the dataset?
-- Ans: 351653025

SELECT SUM(num_registered)
FROM names
WHERE num_registered IS NOT NULL and num_registered > 0
;



-- 3. Which name had the most appearances in a single year in the dataset?
-- Ans: Linda


SELECT *
FROM names
WHERE num_registered = (SELECT MAX(num_registered) 
						FROM names)
;


--Alternative Solution 1:

SELECT *
FROM names
ORDER BY num_registered DESC
LIMIT 1  
;



--Alternative Solution 2: a more all-encompassing approach / a more on-point solution: 

SELECT name, year, SUM(num_registered) AS total_num_registered
FROM names
GROUP BY name, year
ORDER BY total_num_registered DESC
LIMIT 1
;





-- 4. What range of years are included?
-- Ans: 1880 ~ 2018


SELECT MIN(year), MAX(year)
	FROM names
;




-- 5. What year has the largest number of registrations?
-- Ans: 1947


SELECT year
	FROM names
	WHERE num_registered = (SELECT MAX(num_registered) FROM names)
;


-- Alternative Solution:

SELECT year, SUM(num_registered) AS total_registered
FROM names
GROUP BY year
ORDER BY SUM(num_registered) DESC
LIMIT 1;



-- 6. How many different (distinct) names are contained in the dataset??
-- Ans: 98400  


SELECT COUNT(DISTINCT(name))
FROM names
;




-- 7. Are there more males or more females registered?
-- Ans: Female


SELECT gender, SUM(num_registered), COUNT(*)
FROM names
GROUP BY gender 
;


--Alternative Solution 1:

SELECT (CASE WHEN males > females then 'true' else 'false' end) AS are_more_males_than_females_registered
FROM (SELECT SUM(num_registered) 
		FROM names 
		WHERE gender = 'M') AS males,
     (SELECT SUM(num_registered) 
	 	FROM names 
		WHERE gender = 'F') AS females;



--Alternative solution 2 (work-in-progress):

SELECT gender, LAG(SUM(num_registered)) OVER (ORDER BY gender) AS gender_reg_diff
FROM names
GROUP BY gender;

 



 


-- 8. What are the most popular male and female names overall (i.e., the most total registrations)??
-- Ans: James, John, Robert, Michael, Mary, ...


SELECT name, gender, SUM(num_registered) AS total_registered
FROM names 
GROUP BY name, gender
ORDER BY SUM(num_registered) DESC
;



--Alternative Solution 1

SELECT gender, name, SUM(num_registered) AS total_registered
FROM names
WHERE gender = 'F'
GROUP BY gender, name
ORDER BY total_registered DESC
LIMIT 1;
-- Most popular overall female name is Mary (4,125,675 registered)



SELECT gender, name, SUM(num_registered) AS total_registered
FROM names
WHERE gender = 'M'
GROUP BY gender, name
ORDER BY total_registered DESC
LIMIT 1;
--Most popular overall male name is James (5,164,280)





--Alternative Solution 2 (piecing together the 2 parts in Alt Solution 1)

SELECT * 
FROM (SELECT name, SUM(num_registered) as MAX_POPULAR 
		FROM names 
		WHERE gender = 'F' 
		GROUP BY gender, name 
		ORDER BY MAX_POPULAR DESC 
		LIMIT 1)
UNION
SELECT * 
FROM (SELECT name, SUM(num_registered) as MAX_POPULAR 
		FROM names 
		WHERE gender = 'M' 
		GROUP BY gender, name 
		ORDER BY MAX_POPULAR DESC 
		LIMIT 1)
;



--Alternative Solution 3
SELECT DISTINCT name, gender, SUM(num_registered) OVER (PARTITION BY name, gender) AS total_registrations
FROM names
ORDER BY total_registrations DESC
;



--Alternative Solution 4

SELECT DISTINCT ON (gender) name, gender, SUM(num_registered) AS total_registrations
FROM names
GROUP BY name, gender
ORDER BY gender, total_registrations DESC
;
 




-- 9. What are the most popular boy and girl names of the first decade of the 2000s (2000 - 2009)?
-- Ans: Jacob, Michael, Joshua, Emily, Matthew 


SELECT name, gender, SUM(num_registered)
	FROM names 
	WHERE year >= 2000 and year <= 2009
	GROUP BY name, gender
	ORDER BY SUM(num_registered) DESC
;



-- Alternative Solution 1

SELECT name, SUM(num_registered)
FROM names
WHERE gender = 'F'
	AND year BETWEEN 2000 AND 2009
GROUP BY name
ORDER BY SUM(num_registered) DESC
LIMIT 1;
--Most popular female name of this decade is Emily (223,690)



SELECT name, SUM(num_registered)
FROM names
WHERE gender = 'M'
	AND year BETWEEN 2000 AND 2009
GROUP BY name
ORDER BY SUM(num_registered) DESC
LIMIT 1;
--Most popular male name of this decade is Jacob (273,844)




-- Alternative Solution 2

SELECT DISTINCT name, gender, SUM(num_registered) OVER (PARTITION BY name, gender) AS total_registrations
FROM names
WHERE year BETWEEN 2000 AND 2009
ORDER BY total_registrations DESC
;


-- Alternative Solution 3

SELECT DISTINCT ON (gender) name, gender, SUM(num_registered)
FROM names
WHERE year BETWEEN 2000 AND 2009
GROUP BY name, gender
ORDER BY gender, SUM(num_registered) DESC
;




-- 10. Which year had the most variety in names (i.e. had the most distinct names)?
-- Ans: 2008

SELECT COUNT(DISTINCT name), year
FROM names
GROUP BY year
ORDER BY COUNT(DISTINCT name) DESC
LIMIT 1 
;
 



-- 11. What is the most popular name for a girl that starts with the letter X??
-- Ans: Xen


SELECT name, gender, SUM(num_registered)
FROM names 
WHERE name LIKE 'X%' 
	AND gender = 'F'
GROUP BY name, gender
ORDER BY SUM(num_registered) DESC
LIMIT 1
;


--Alternative solution with slight modification:

SELECT name, SUM(num_registered)
FROM names
WHERE name LIKE 'X%'
	AND gender = 'F'
GROUP BY name
ORDER BY SUM(num_registered) DESC
LIMIT 1;
;


 
-- 12. Write a query to find all (distinct) names that start with a 'Q' but whose second letter is not 'u'
-- Ans: 


SELECT DISTINCT(name) 
FROM names 
WHERE name LIKE 'Q%' 
	AND SUBSTR(name, 2, 1) != 'u'
;


--Alternative Solution with slight modification:

SELECT distinct name 
FROM names nm 
WHERE name LIKE 'Q%' 
	AND SUBSTRING(name, 2, 1) <> 'u'
;


--Alternative Solution 1:

SELECT DISTINCT(name) 
FROM names 
WHERE name LIKE 'Q%' 
	AND name NOT LIKE '_u%'
;


--Alternative Solution 2: 

SELECT DISTINCT(name) 
FROM names 
WHERE name LIKE 'Q%' 
	AND name NOT LIKE 'Qu%'
;

--Side Note: LIKE function doesn't work with regular expression. Reg_Match() and other similar functions are better suited for regular expression usage.



-- 13. Which is the more popular spelling between "Stephen" and "Steven"? Use a single query to answer this question.
-- Ans: Steven is more popular

SELECT name, SUM(num_registered) 
FROM names
WHERE name = 'Stephen' OR name = 'Steven'
GROUP BY name 
;

--Alternative solution with slight modifications

SELECT name, SUM(num_registered) AS total_registered
FROM names
WHERE name IN ('Stephen', 'Steven')
GROUP BY name
;





-- 14. Find all names that are "unisex" - that is all names that have been used both for boys and for girls.
-- Ans:  


SELECT name
FROM names
GROUP BY name
HAVING COUNT(DISTINCT gender) = 2  
ORDER BY name
;


-- Alternative solution 1: make 2 tables (1 containing all male names, 1 containing all female names), then inner join them


-- One way to verify (sanity check): 
SELECT *
FROM names
WHERE name = 'Alejandra'
;	



-- Alternative Solution 2:

SELECT DISTINCT N1.NAME
FROM NAMES N1
WHERE GENDER = 'M'
	AND EXISTS (
				SELECT 'x'
				FROM NAMES N2
				WHERE N2.NAME = N1.NAME
					AND N2.GENDER = 'F'
	);



-- Alternative Solution 3  ~  10773 rows *2 = 21546 rows:

SELECT DISTINCT gender, name
FROM names
WHERE name IN (SELECT name
				FROM names
				WHERE gender = 'F')
AND name IN (SELECT name
				FROM names
				WHERE gender = 'M')
ORDER BY name, gender;



--Alternative solution 4 ?


 

-- 15. Find all names that have made an appearance in every single year since 1880.
-- My Ans: 


SELECT COUNT(DISTINCT year)
	FROM names
;
-- 139 yrs




SELECT name, COUNT(DISTINCT year)
FROM names
GROUP BY name  
HAVING COUNT(DISTINCT year)=139  
ORDER BY name
;

--side step:
SELECT COUNT(DISTINCT year)
	FROM names
	WHERE name = 'Ashley'
;



---Alternative solution 1, using subqueries 

SELECT
	NAME,
	COUNT(DISTINCT YEAR)
FROM
	NAMES
GROUP BY
	NAME
HAVING
	COUNT(DISTINCT YEAR) = (
		SELECT
			COUNT(DISTINCT YEAR)
		FROM
			NAMES
	) ORDER BY
	NAME;


--Alternative solution 2. Doesn't quite work (ans=927, instead of 921, due to that some rows have "M/F")

SELECT DISTINCT
	NAME,
	GENDER,
	COUNT(YEAR) AS YEARCOUNT
FROM
	NAMES
GROUP BY
	NAME,
	GENDER
HAVING
	COUNT(YEAR) >= 139
ORDER BY
	NAME;


--Alternative solution 3 (review recording?):






-- 16. Find all names that have only appeared in one year.
-- My Ans: 

--This query renders 1 row per name (regardless of whether the name is used by 1 or both genders)

SELECT name, COUNT(DISTINCT year)
FROM names
GROUP BY name  
HAVING COUNT(DISTINCT year) = 1  
ORDER BY name
;


--This query yields 1 row per name, per gender - but only if the name "only appeared in one year" across both genders

SELECT name, gender, year
FROM names
WHERE name IN
	(SELECT name
	FROM names
	GROUP BY name
	HAVING COUNT(DISTINCT year) = 1)
ORDER BY name
;



--This query yields 1 row per name, per gender: more rows are returned by this query, since the "only appeared in one year" requirement is applied to each name's appearance with each gender

SELECT name, gender, COUNT(DISTINCT year)
FROM names
GROUP BY name, gender
HAVING COUNT(DISTINCT year) = 1
ORDER BY name
;



--Here're the 23 unisex names that account for the difference (seen above) in the # of rows yielded from the queries above

SELECT name, gender, year
FROM names
WHERE name IN (SELECT name
				FROM names
				GROUP BY name
				HAVING COUNT(DISTINCT YEAR) = 1 AND COUNT(gender) = 2)
ORDER BY name;





-- 17. Find all names that only appeared in the 1950s.
-- Ans: 

SELECT DISTINCT name
FROM names
GROUP BY name
HAVING MIN(year) >= 1950 AND MAX(year) <= 1959
;


-- Alternative solution 1:

SELECT name
FROM(SELECT name
		FROM names
		WHERE year BETWEEN 1950 AND 1959
		EXCEPT
		SELECT name
		FROM names
		WHERE year < 1950 OR year >1959
										) AS fifties_names;




-- 18. Find all names that made their first appearance in the 2010s.
-- Ans: 


SELECT DISTINCT name
FROM names
GROUP BY name
HAVING MIN(year) >= 2010
;

-- Alternative solution: 

SELECT DISTINCT name
FROM(SELECT name
	FROM names
	WHERE year >=2010
	EXCEPT
	SELECT name
	FROM names
	WHERE year < 2010) AS new_names
;
--11,270



-- 19. Find the names that have not be used in the longest.
-- Ans: 

SELECT name, MAX(year), 2018 - MAX(year) AS years_since_named
FROM names
GROUP BY name
ORDER BY years_since_named DESC
;

 


-- 20. Come up with a question that you would like to answer using this dataset. Then write a query to answer this question.
-- Q1: arrange names from the longest to the shortest, then by year from the earliest to the most recent
-- Ans: 
 
SELECT * 
FROM names 
ORDER BY CHAR_LENGTH(name) DESC, year  
;


-- Q2 = Q14.2: What percentage of names are "unisex" - that is what percentage of names have been used both for boys and for girls?
-- Solution 1 

SELECT COUNT(name)
FROM(SELECT name,
		COUNT(CASE WHEN gender = 'F' THEN 'f_count' END) AS F_count,
		COUNT(CASE WHEN gender = 'M' THEN 'm_count' END) AS M_count
	FROM names
	GROUP BY name
	ORDER BY F_count DESC) AS counts
WHERE F_count > 0
AND M_count > 0
;
-- 10,773

-- from Q6:
SELECT COUNT(DISTINCT(name))
FROM names
;
-- 98,400

-- 10,773 / 98,400 = 10.95%



-- Solution 2

SELECT COUNT(*)
FROM(SELECT name
	FROM names
	WHERE gender = 'F'
	INTERSECT
	SELECT name
	FROM names
	WHERE gender = 'M') AS unisex
;
-- 10,773




-- Solution 3
 
--Option A
SELECT name
FROM names
GROUP BY name
HAVING MIN(gender) = 'F' AND MAX(gender) = 'M';

--Option B
SELECT name,
	COUNT(DISTINCT gender) AS gender_count
FROM names
GROUP BY name
HAVING COUNT(DISTINCT gender) = 2;

SELECT 100*10733.0/COUNT(DISTINCT name)
FROM names;

 
-- Solution 4
SELECT CAST(MIN(unisex_count) AS FLOAT) / CAST(MAX(unisex_count) AS FLOAT) * 100
FROM
	(SELECT COUNT(*) AS unisex_count
	FROM 
		(SELECT name
		FROM names
		GROUP BY name
		HAVING COUNT(DISTINCT gender) > 1) AS ut
UNION
SELECT COUNT(DISTINCT name) AS total_count
FROM names AS n) AS union_table;



-- looking under the hood:


SELECT *
FROM
	(SELECT COUNT(*) AS unisex_count
	FROM 
		(SELECT name
		FROM names
		GROUP BY name
		HAVING COUNT(DISTINCT gender) > 1) AS ut
UNION
SELECT COUNT(DISTINCT name) AS total_count
FROM names AS n) AS union_table;


 



SELECT name
	FROM names
	GROUP BY name
	HAVING COUNT(DISTINCT gender) > 1;



SELECT DISTINCT name AS total_count
FROM names AS n;



-- Solution 5
SELECT COUNT(DISTINCT name)*100.00 / (SELECT count(distinct name) FROM names) as percent_unisex
FROM names
WHERE name in
      (SELECT name FROM names WHERE gender = 'M')
  AND name in
      (SELECT name FROM names WHERE gender = 'F')
;


	  