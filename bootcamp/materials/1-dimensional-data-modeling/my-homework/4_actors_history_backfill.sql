INSERT INTO actors
WITH last_year AS (
    SELECT * 
    FROM actors 
    WHERE current_year = 1976
),
today AS (
    SELECT
        actor,
        actorid,
        ROW(film, votes, rating, filmid)::films AS films,
        rating,
        year
    FROM actor_films
    WHERE year = 1977
),
aggregated_today AS (
    SELECT
        actor,
        actorid,
        ARRAY_AGG(films) AS films,
        avg(rating) as avg_rating,
        year
    FROM today
    GROUP BY actor, actorid, year
) 
SELECT 
    COALESCE(a.actor, l.actor) AS actor,
    COALESCE(a.actorid, l.actorid) AS actorid,
    CASE 
        WHEN l.films IS NULL THEN a.films  -- Use current year's films if no previous films exist
        WHEN a.films IS NOT NULL THEN l.films || a.films  -- Combine previous and current year's films
        ELSE l.films
    END AS films,
    CASE
        WHEN a.avg_rating > 8 THEN 'star'
        WHEN a.avg_rating > 7 THEN 'good'
        WHEN a.avg_rating > 6 THEN 'average'
        ELSE 'bad'
    END::quality_class AS quality_class,
    COALESCE(a.year, l.current_year + 1) AS current_year,
    CASE
        WHEN a.year IS NULL
            THEN FALSE
        ELSE TRUE
    END AS is_active
FROM aggregated_today a 
FULL OUTER JOIN last_year l 
    ON a.actorid = l.actorid;
