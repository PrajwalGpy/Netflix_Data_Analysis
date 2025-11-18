# Netflix Data Analysis with SQL
![](https://github.com/PrajwalGpy/Netflix_Data_Analysis/blob/main/logo.png)

This project demonstrates the use of SQL (specifically PostgreSQL) to analyze the "Netflix Titles" dataset. It includes 15 common business questions and their corresponding SQL queries to extract meaningful insights from the data.

The queries showcase a range of SQL techniques, including:

- Aggregations (`COUNT`, `GROUP BY`)
- Window Functions (`RANK`)
- String Manipulation (`UNNEST`, `STRING_TO_ARRAY`, `SPLIT_PART`, `ILIKE`)
- Date/Time Functions (`TO_DATE`, `EXTRACT`, `INTERVAL`)
- Subqueries
- Common Table Expressions (CTEs)
- Conditional Logic (`CASE`)

## Dataset

This project assumes a single table, `public.netflix_titles`, with the following schema:

- `show_id` (text): Unique ID for the title
- `type` (text): 'Movie' or 'TV Show'
- `title` (text): Name of the title
- `director` (text): Director(s)
- `casts` (text): Main actors (comma-separated)
- `country` (text): Country/countries of production (comma-separated)
- `date_added` (text): Date added to Netflix (e.g., "January 1, 2020")
- `release_year` (integer): Year the title was originally released
- `rating` (text): TV/Movie rating (e.g., "PG-13", "TV-MA")
- `duration` (text): Duration (e.g., "90 min" or "2 Seasons")
- `listed_in` (text): Genres (comma-separated)
- `description` (text): Synopsis

---

## Business Problems & SQL Solutions

Here are 15 analytical questions and the SQL queries used to answer them.

### 1. Count the number of Movies vs. TV Shows

```sql
SELECT
    type,
    COUNT(show_id) AS total_content
FROM
    netflix_titles
GROUP BY
    1;
```

### 2. Find the most common rating for movies and TV shows

```sql
SELECT
    type,
    rating
FROM
    (
        SELECT
            type,
            rating,
            COUNT(*),
            RANK() OVER (
                PARTITION BY
                    type
                ORDER BY
                    COUNT(*) DESC
            ) AS ranking
        FROM
            netflix_titles
        GROUP BY
            1,
            2
    ) AS t1
WHERE
    ranking = 1;
```

### 3. List all movies released in a specific year (e.g., 2020)

```sql
SELECT
    *
FROM
    netflix_titles
WHERE
    release_year = 2020
    AND type = 'Movie';
```

### 4. Find the top 5 countries with the most content on Netflix

```sql
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country_unnest,
    COUNT(show_id)
FROM
    netflix_titles
GROUP BY
    1
ORDER BY
    2 DESC
LIMIT
    5;
```

### 5. Identify the longest movie

```sql
SELECT
    *
FROM
    netflix_titles nt
WHERE
    nt."type" = 'Movie'
    AND nt.duration = (
        SELECT
            MAX(duration)
        FROM
            netflix_titles
        WHERE
            "type" = 'Movie'
    );
```

### 6. Find content added in the last 5 years

```sql
SELECT
    *
FROM
    netflix_titles nt
WHERE
    to_date(nt.date_added, 'FMMonth DD, YYYY') >= current_date - interval '5 Years';
```

### 7. Find all movies/TV shows by director 'Rajiv Chilaka'

```sql
SELECT
    *
FROM
    netflix_titles nt
WHERE
    nt.director ILIKE '%Rajiv Chilaka%';
```

### 8. List all TV shows with more than 5 seasons

```sql
SELECT
    *
FROM
    netflix_titles nt
WHERE
    nt."type" = 'TV Show'
    AND (split_part(nt.duration, ' ', 1))::int > 5;
```

### 9. Count the number of content items in each genre

```sql
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(nt.listed_in, ','))) AS genre,
    COUNT(nt.show_id)
FROM
    netflix_titles nt
GROUP BY
    1
ORDER BY
    2 DESC;
```

### 10. Find content release trends in India

**A. Content count per year for India**

```sql
SELECT
    TO_CHAR(to_date(nt.date_added, 'FMMonth DD, YYYY'), 'YYYY') AS fdate,
    COUNT(nt.show_id)
FROM
    netflix_titles nt
WHERE
    nt.country = 'India'
GROUP BY
    1
ORDER BY
    1 DESC;
```

**B. Content count and percentage per year for India**

```sql
SELECT
    EXTRACT(
        YEAR
        FROM
            (to_date(nt.date_added, 'FMMonth DD, YYYY'))
    ) AS year,
    COUNT(nt.show_id),
    ROUND(
        COUNT(*)::numeric / (
            SELECT
                COUNT(*)
            FROM
                netflix_titles nt2
            WHERE
                nt2.country = 'India'
        )::numeric * 100,
        2
    ) AS avg_content_per_year
FROM
    netflix_titles nt
WHERE
    nt.country = 'India'
GROUP BY
    1
ORDER BY
    1 DESC;
```

**C. Top 5 release years by total content count (global)**

```sql
SELECT
    nt.release_year,
    COUNT(*),
    ROUND(
        COUNT(*)::numeric / (
            SELECT
                COUNT(*)
            FROM
                netflix_titles nt2
        )::numeric * 100,
        2
    ) AS avg_content_per_year
FROM
    netflix_titles nt
GROUP BY
    1
ORDER BY
    2 DESC
LIMIT
    5;
```

### 11. List all movies that are documentaries

```sql
SELECT
    *
FROM
    netflix_titles nt
WHERE
    nt."type" = 'Movie'
    AND nt.listed_in ILIKE '%Documentaries%';
```

### 12. Find all content without a director

```sql
SELECT
    *
FROM
    netflix_titles nt
WHERE
    nt.director IS NULL;
```

### 13. Find movies actor 'Salman Khan' appeared in (last 10 years)

```sql
SELECT
    *
FROM
    netflix_titles nt
WHERE
    nt.casts ILIKE '%Salman Khan%'
    AND nt."type" = 'Movie'
    AND (nt.release_year) >= EXTRACT(YEAR FROM current_date) - 10;
```

### 14. Find the top 10 actors in movies produced in India

```sql
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(nt.casts, ','))) AS actor,
    COUNT(*)
FROM
    netflix_titles nt
WHERE
    nt.country ILIKE '%India%'
    AND nt."type" = 'Movie'
GROUP BY
    1
ORDER BY
    2 DESC
LIMIT
    10;
```

### 15. Categorize content based on description keywords ('kill', 'violence')

```sql
WITH new_Table AS (
    SELECT
        *,
        CASE
            WHEN nt.description ILIKE '%kill%'
            OR nt.description ILIKE '%violence%' THEN 'Bad_content'
            ELSE 'Good_content'
        END AS category
    FROM
        netflix_titles nt
)
SELECT
    category,
    COUNT(*) AS total_content
FROM
    new_Table
GROUP BY
    category;
```
