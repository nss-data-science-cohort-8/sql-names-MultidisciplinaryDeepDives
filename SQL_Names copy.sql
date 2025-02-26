-- 1. How many rows are in the names table?
-- Ans: 1957046

SELECT COUNT(*)
FROM names
;


-- 2. How many total registered people appear in the dataset?
-- Ans: 351653025

SELECT SUM(num_registered)
FROM names
;



-- 3. Which name had the most appearances in a single year in the dataset?
-- Ans: Linda


SELECT *
FROM names
WHERE num_registered = (SELECT MAX(num_registered) FROM names)
;


--Alternative solution:

SELECT name, num_registered, year
FROM names
ORDER BY num_registered DESC
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


-- Alternative solution:

SELECT SUM(num_registered) AS total_registered, year
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


SELECT gender, COUNT(*)
FROM names
GROUP BY gender 
;



--Alternative solution:

select (case when males > females then 'true' else 'false' end) as are_more_males_than_females_registered
from (select count(gender) from names where gender = 'M') males,
     (select count(gender) from names where gender = 'F') females;




-- 8. What are the most popular male and female names overall (i.e., the most total registrations)??
-- Ans: James, John, Robert, Michael, Mary, ...


SELECT name, gender, SUM(num_registered)
FROM names 
GROUP BY name, gender
ORDER BY SUM(num_registered) DESC
;



--Alternative solution 1

SELECT name, SUM(num_registered)
FROM names
WHERE gender = 'F'
GROUP BY name
ORDER BY SUM(num_registered) DESC
LIMIT 1;
-- Most popular overall female name is Mary (4,125,675 registered)


SELECT name, SUM(num_registered)
FROM names
WHERE gender = 'M'
GROUP BY name
ORDER BY SUM(num_registered) DESC
LIMIT 1; 
--Most popular overall male name is James (5,164,280)


--Alternative solution 2
select distinct name, gender, sum(num_registered) over (partition by name, gender) as total_registrations
from names
order by total_registrations desc;






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

select distinct name, gender, sum(num_registered) over (partition by name, gender) as total_registrations
from names
where year between 2000 and 2009
order by total_registrations desc;



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


--Alternative solution 1:

SELECT DISTINCT(name) 
FROM names 
WHERE name LIKE 'Q%' 
	AND name NOT LIKE '_u%'
;

--Alternative solution 2: 

SELECT DISTINCT(name) 
FROM names 
WHERE name LIKE 'Q%' 
	AND name NOT LIKE 'Qu%'
;



-- 13. Which is the more popular spelling between "Stephen" and "Steven"? Use a single query to answer this question.
-- Ans: Steven is more popular

SELECT name, SUM(num_registered)
FROM names
WHERE name = 'Stephen' OR name = 'Steven'
GROUP BY name 
;

--Alternative solution with slight modifications

SELECT name, SUM(num_registered)
FROM names
WHERE name IN ('Stephen', 'Steven')
GROUP BY name;





-- 14. Find all names that are "unisex" - that is all names that have been used both for boys and for girls.
-- Ans:  


SELECT name
FROM names
GROUP BY name
HAVING COUNT(DISTINCT gender) = 2  
ORDER BY name
;

-- Alternative solution: make 2 tables, then inner join them

-- One way to verify (sanity check): 
SELECT *
FROM names
WHERE name = 'Alejandra'
;	





-- 15. Find all names that have made an appearance in every single year since 1880.
-- My Ans: 


SELECT COUNT(DISTINCT year)
	FROM names
;
-- 139 yrs


SELECT COUNT(DISTINCT year)
	FROM names
	WHERE name = 'Ashley'
;


SELECT name, COUNT(DISTINCT year)
FROM names
GROUP BY name  
HAVING COUNT(DISTINCT year)=139  
;




 




-- 16. Find all names that have only appeared in one year.
-- My Ans: 


SELECT name, COUNT(DISTINCT year)
	FROM names
	GROUP BY name  
	HAVING COUNT(DISTINCT year) = 1  
;

 



-- 17. Find all names that only appeared in the 1950s.
-- Ans: 

SELECT DISTINCT name
	FROM names
	GROUP BY name
	HAVING MIN(year) >= 1950 AND MAX(year) <= 1959
;


-- Alternative solution:

SELECT name
FROM(SELECT name
	FROM names
	WHERE year BETWEEN 1950 AND 1959
	EXCEPT
	SELECT name
	FROM names
	WHERE year < 1950 OR year >1959) AS fifties_names;




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

SELECT name, 2018 - MAX(year) AS years_since_named
FROM names
GROUP BY name
ORDER BY years_since_named DESC
;


-- Alternative solution

SELECT name, MAX(year)
FROM names
GROUP BY name
ORDER BY MAX(year)
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


	  