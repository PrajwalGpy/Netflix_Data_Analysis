SELECT show_id, "type", title, director, casts, country, date_added, release_year, rating, duration, listed_in, description
FROM public.netflix_titles;


-- 15 Business Problems & Solutions
-- 1. Count the number of Movies vs TV Shows
SELECT
    TYPE,
    COUNT(SHOW_ID) AS TOTAL_CONTENT
FROM
    NETFLIX_TITLES
GROUP BY
    1;




-- 2. Find the most common rating for movies and TV shows


SELECT
    *
FROM
    NETFLIX_TITLES;




SELECT
    TYPE,
    RATING
FROM
    (
        SELECT
            TYPE,
            RATING,
            COUNT(*),
            RANK() OVER (
                PARTITION BY
                    TYPE
                ORDER BY
                    COUNT(*) DESC
            ) AS RANKING
        FROM
            NETFLIX_TITLES
        GROUP BY
            1,
            2
    ) AS T1
WHERE
    RANKING = 1;




-- 3. List all movies released in a specific year (e.g., 2020)

SELECT
    *
FROM
    NETFLIX_TITLES
WHERE
    RELEASE_YEAR = 2020
    AND TYPE = 'Movie';

    

-- 4. Find the top 5 countries with the most content on Netflix

SELECT
    UNNEST(STRING_TO_ARRAY(COUNTRY, ',')) AS COUNTRY_UNNEST,
    COUNT(SHOW_ID)
FROM
    NETFLIX_TITLES
GROUP BY
    1
ORDER BY
    2 DESC
LIMIT
    5;




-- 5. Identify the longest movie


select
	*
from
	netflix_titles nt
where
	nt."type" = 'Movie'
	and nt.duration = (
	select
		MAX(duration)
	from
		netflix_titles)




-- 6. Find content added in the last 5 years
	
select
	*
from
	netflix_titles nt
where
	to_date(nt.date_added, 'FMMonth DD,YYYY') >= current_date - interval '5 Years';
	
	
	
	
-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select
	*
from
	netflix_titles nt
where
	nt.director ilike '%Rajiv Chilaka%'





-- 8. List all TV shows with more than 5 seasons

select
	*
from
	netflix_titles nt
where
	nt."type" = 'TV Show'
	and 
(split_part(nt.duration, ' ', 1))::int > 5
	
	
	
	
-- 9. Count the number of content items in each genre

select
	unnest(string_to_array(nt.listed_in, ',')) as genre,
	count(nt.show_id)
from
	netflix_titles nt
group by
	1;



-- 10.Find each year and the average numbers of content release in India on netflix.



select
	To_char(to_date(nt.date_added, 'FMMonth DD,YYYY'), 'YYYY') as FDate,
	count(nt.show_id)
from
	netflix_titles nt
where
	nt.country = 'India'
group by
	1
order by
	1 desc ;

------------------------------------------------------------------------------------------------------------------

select
	extract(year from (to_date(nt.date_added, 'FMMonth DD,YYYY') ) ) as year,
	Count(nt.show_id),
	round(count(*)::numeric /(select Count(*) from netflix_titles nt2 where nt2.country = 'India')::numeric * 100 , 2) as avg_content_per_year
from
	netflix_titles nt
where
	nt.country = 'India'
group by
	1
order by
	1 desc ;




-- return top 5 year with highest avg content release!

select
	nt.release_year,
	count(*),
	round(count(*)::numeric /(select Count(*) from netflix_titles nt2 )::numeric * 100 , 2) as avg_content_per_year
from
	netflix_titles nt
group by
	1
order by
	2 desc
limit 5;


-- 11. List all movies that are documentaries

select
	*
from
	netflix_titles nt
where
	nt."type" = 'Movie'
	and nt.listed_in ilike '%Documentaries%'



-- 12. Find all content without a director
	
select
	*
from
	netflix_titles nt
where
	nt.director is null
	
	
	
-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
	
select
	*
from
	netflix_titles nt
where
	nt.casts ilike '%Salman Khan%'
	and nt."type" = 'Movie'
	and (nt.release_year) >= extract(year from current_date) -10 ;



	
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select
	unnest(string_to_array(nt.casts, ',')),
	count(*)
from
	netflix_titles nt
where
	nt.country ilike '%India%' and nt."type" ='Movie'
group by
	1
order by
	2 desc
limit 10



-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

with new_Table
as (
select
	*,
	case
		when nt.description ilike '%kill%'
		or nt.description ilike '%violence%' then 'Bad_content'
		else 'Good_content'
	end as category
from
	netflix_titles nt
)
select
	category,
	count(*) as Total_content
from
	new_Table
group by
	category;

