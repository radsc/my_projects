USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/


-- 1. The total number of rows in each table of the schema

select count(*) as row_counts from director_mapping;
select count(*) as row_counts from genre;
select count(*) as row_counts from movie;
select count(*) as row_counts from names;
select count(*) as row_counts from ratings;
select count(*) as row_counts from role_mapping;


-- 2. The columns in the movie table have null values?

SELECT 
    SUM(CASE
        WHEN id IS NULL THEN 1
        ELSE 0
    END) AS id_null,
    SUM(CASE
        WHEN title IS NULL THEN 1
        ELSE 0
    END) AS title_null,
    SUM(CASE
        WHEN year IS NULL THEN 1
        ELSE 0
    END) AS year_null,
    SUM(CASE
        WHEN date_published IS NULL THEN 1
        ELSE 0
    END) AS date_published_null,
    SUM(CASE
        WHEN duration IS NULL THEN 1
        ELSE 0
    END) AS duration_null,
    SUM(CASE
        WHEN country IS NULL THEN 1
        ELSE 0
    END) AS country_null,
    SUM(CASE
        WHEN worlwide_gross_income IS NULL THEN 1
        ELSE 0
    END) AS worlwide_gross_income_null,
    SUM(CASE
        WHEN languages IS NULL THEN 1
        ELSE 0
    END) AS languages_null,
    SUM(CASE
        WHEN production_company IS NULL THEN 1
        ELSE 0
    END) AS production_company_null
FROM
    movie;



-- Now as we can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- 3. The total number of movies released each year and the trend look month wise?

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT 
    Year, COUNT(id) AS number_of_movies
FROM
    movie
GROUP BY year;

SELECT 
    MONTH(date_published) AS month_num,
    COUNT(id) AS number_of_movies
FROM
    movie
GROUP BY month_num
ORDER BY month_num;



/*The highest number of movies is produced in the month of March.
So, now that we have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- 4. The number of movies were produced in the USA or India in the year 2019.

WITH movie_country
     AS (SELECT id,
                CASE
                  WHEN country LIKE '%India%' THEN 'India'
                  WHEN country LIKE '%USA%' THEN 'USA'
                END AS country_produced
         FROM movie
         WHERE year = 2019)
SELECT country_produced,
       Count(id) as movie_count
FROM movie_country
WHERE country_produced IS NOT NULL
GROUP BY country_produced;


/* USA and India produced more than a thousand movies in the year 2019.
Let’s find out the different genres in the dataset.*/

-- 5.The unique list of the genres present in the data set.

SELECT DISTINCT
    (genre) AS unique_genre
FROM
    genre;

/* So, RSVP Movies plans to make a movie of one of these genres.
Combining both the movie and genres tables can give more interesting insights. */

-- 6. The genre had the highest number of movies produced overall.

SELECT 
    genre, COUNT(id) AS number_of_movies
FROM
    genre g
        INNER JOIN
    movie m ON (g.movie_id = m.id)
GROUP BY genre
ORDER BY number_of_movies DESC
LIMIT 1;



/* So, based on the insight that we just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- 7. The number of movies belong to only one genre.

SELECT 
    COUNT(*) AS total_movies
FROM
    (SELECT 
        movie_id, COUNT(genre) AS num_genre
    FROM
        genre
    GROUP BY movie_id
    HAVING num_genre = 1) AS movie_genre;



/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- 8. The average duration of movies in each genre? 

/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
SELECT 
    genre, ROUND(AVG(duration)) AS avg_duration
FROM
    genre g
        INNER JOIN
    movie m ON g.movie_id = m.id
GROUP BY genre;


/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- 9. The rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 

/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/

WITH temp_genre_rank
     AS (SELECT genre,
                Count(movie_id)                       AS movie_count,
                Rank()
                  OVER (ORDER BY Count(movie_id) DESC) AS genre_rank
         FROM   genre
         GROUP  BY genre)
SELECT *
FROM   temp_genre_rank
WHERE  genre = 'Thriller';


/*Thriller movies is in top 3 among all genres in terms of number of movies.
 In the previous segment, we analysed the movies and genres tables. 
 In this segment, we will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/


-- 10. The minimum and maximum values in  each column of the ratings table except the movie_id column.
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/

SELECT ROUND(MIN(avg_rating)) AS min_avg_rating, 
	   ROUND(MAX(avg_rating)) AS max_avg_rating,
	   ROUND(MIN(total_votes)) AS min_total_votes, 
       ROUND(MAX(total_votes)) AS max_total_votes,
       ROUND(MIN(median_rating)) AS min_median_rating, 
       ROUND(MAX(median_rating)) AS max_median_rating
FROM ratings;



/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- 11.The top 10 movies based on average rating.
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/

WITH movie_ratings
     AS (SELECT title,
                avg_rating,
                Dense_rank() OVER(ORDER BY avg_rating DESC) AS movie_rank
         FROM   movie m
                INNER JOIN ratings r
                        ON m.id = r.movie_id)
SELECT *
FROM   movie_ratings
WHERE  movie_rank <= 10 ;



/* So, now that we know the top 10 movies, do we think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- 12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT 
    median_rating, COUNT(movie_id) AS movie_count
FROM
    ratings
GROUP BY median_rating
ORDER BY movie_count DESC;



/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- 13. The production house has produced the most number of hit movies (average rating > 8).
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/

WITH production_details
     AS (SELECT DISTINCT production_company,
                         Count(id) OVER(partition BY production_company) AS movie_count
         FROM   movie m
                INNER JOIN ratings r
                        ON m.id = r.movie_id
         WHERE  production_company IS NOT NULL
                AND r.avg_rating > 8)
SELECT *,
       Dense_rank() OVER(ORDER BY movie_count DESC) AS prod_company_rank
FROM   production_details
ORDER  BY prod_company_rank;


-- 14. The number of movies released in each genre during March 2017 in the USA had more than 1,000 votes.
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT g.genre,
       Count(m.id) AS movie_count
FROM   movie m
       INNER JOIN genre g
               ON m.id = g.movie_id
       INNER JOIN ratings r
               ON m.id = r.movie_id
WHERE  m.year = 2017
       AND Date_format(m.date_published, '%M') = 'March'
       AND m.country LIKE '%USA%'
       AND r.total_votes > 1000
GROUP  BY g.genre;



-- Lets try to analyse with a unique problem statement.
-- 15. The number of movies of each genre that start with the word ‘The’ and which have an average rating > 8.
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/

SELECT title,
       avg_rating,
       genre
FROM   movie m
       INNER JOIN genre g
               ON m.id = g.movie_id
       INNER JOIN ratings r
               ON r.movie_id = m.id
WHERE  avg_rating > 8
       AND title REGEXP '^The'
GROUP  BY genre,
          title,
          avg_rating;


-- Lets check whether the ‘median rating’ column gives any significant insights.
-- 16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

SELECT Count(*) AS movie_count
FROM   movie m
       INNER JOIN ratings r
               ON m.id = r.movie_id
WHERE  m.date_published BETWEEN '2018-04-01' AND '2019-04-01'
       AND r.median_rating = 8;



-- 17. Lets check German movies get more votes than Italian movies. 

WITH movie_language_details
     AS (SELECT id,
                CASE
                  WHEN languages LIKE '%German%' THEN 'German'
                  WHEN languages LIKE '%Italian%' THEN 'Italian'
                END AS movie_language
         FROM   movie)
SELECT DISTINCT l.movie_language,
                Sum(r.total_votes)  OVER(partition BY l.movie_language) AS no_of_votes
FROM   movie_language_details l
       INNER JOIN ratings r
               ON l.id = r.movie_id
WHERE  movie_language IN ( 'German', 'Italian' );

-- Answer is Yes

/* Now that we have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/


-- 18. The columns in the names table have null values.
/* The output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/

SELECT 
    SUM(CASE
        WHEN name IS NULL THEN 1
        ELSE 0
    END) AS name_nulls,
    SUM(CASE
        WHEN height IS NULL THEN 1
        ELSE 0
    END) AS height_nulls,
    SUM(CASE
        WHEN date_of_birth IS NULL THEN 1
        ELSE 0
    END) AS date_of_birth_nulls,
    SUM(CASE
        WHEN known_for_movies IS NULL THEN 1
        ELSE 0
    END) AS known_for_movies_nulls
FROM
    names;


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- 19. The top three directors in the top three genres whose movies have an average rating > 8.
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

WITH top_genres
AS
  (
             SELECT     genre,
                        count(id) AS movie_count
             FROM       ratings r
             INNER JOIN movie m
             ON         r.movie_id = m.id
             INNER JOIN genre g
             ON         g.movie_id = m.id
             WHERE      avg_rating > 8
             GROUP BY   genre
             ORDER BY   movie_count DESC
             LIMIT      3)
  SELECT     name        AS director_name,
             count(m.id) AS movie_count
  FROM       names n
  INNER JOIN director_mapping dm
  ON         n.id = dm.name_id
  INNER JOIN movie m
  ON         dm.movie_id = m.id
  INNER JOIN genre g
  ON         g.movie_id = m.id
  INNER JOIN ratings r
  ON         r.movie_id = m.id
  WHERE      avg_rating > 8
  AND        genre IN
             (
                    SELECT genre
                    FROM   top_genres)
  GROUP BY   director_name
  ORDER BY   movie_count DESC
  LIMIT      3;



/* James Mangold can be hired as the director for RSVP's next project. 
Now, let’s find out the top two actors.*/

-- 20. The top two actors whose movies have a median rating >= 8
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT name              AS actor_name,
       Count(r.movie_id) AS movie_count
FROM   ratings AS r
       INNER JOIN role_mapping AS rm
               ON rm.movie_id = r.movie_id
       INNER JOIN names AS n
               ON rm.name_id = n.id
WHERE  median_rating >= 8
       AND category = 'actor'
GROUP  BY name
ORDER  BY movie_count DESC
LIMIT  2; 


/* RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- 21. The top three production houses based on the number of votes received by their movies.
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/

SELECT     production_company,
           Sum(total_votes)                                  AS vote_count,
           Dense_rank() over (ORDER BY sum(total_votes) DESC) AS prod_comp_rank
FROM       movie m
INNER JOIN ratings r
ON         m.id = r.movie_id
GROUP BY   production_company
ORDER BY   prod_comp_rank
LIMIT      3;



/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- 22. Rank actors with movies released in India based on their average ratings. The actor ho is at the top of the list.

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

WITH actor_details
AS
  (
             SELECT     n.name AS actor_name,
                        sum(r.total_votes) as total_votes,
                        count(n.id) as movie_count,
                        round(sum(r.avg_rating * r.total_votes)/sum(r.total_votes),2) as actor_avg_rating
             FROM       role_mapping rm
             INNER JOIN names n
             ON         rm.name_id = n.id
             INNER JOIN movie m
             ON         rm.movie_id = m.id
             INNER JOIN ratings r
             ON         m.id = r.movie_id
             WHERE      m.country LIKE '%India%'
             and rm.category = 'actor'
             group by n.name
)
  SELECT   *,
           dense_rank() over(ORDER BY actor_avg_rating DESC, total_votes DESC)  AS actor_rank
  FROM     actor_details where movie_count >=5 order by actor_rank;



-- Top actor is Vijay Sethupathi

-- 23.The top five actresses in Hindi movies released in India based on their average ratings.
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

WITH actress_details
     AS (SELECT DISTINCT n.NAME  AS  actress_name,
                         Sum(total_votes) AS total_votes,
                         Count(rm.movie_id) AS movie_count,
                         Round(Sum(avg_rating * total_votes) / Sum(total_votes),2) AS actress_avg_rating
         FROM   role_mapping rm
                INNER JOIN names n
                        ON rm.name_id = n.id
                INNER JOIN movie m
                        ON rm.movie_id = m.id
                INNER JOIN ratings r
                        ON m.id = r.movie_id
         WHERE  country LIKE '%India%'
                AND languages LIKE '%Hindi%'
                AND rm.category = 'actress'
         GROUP  BY n.NAME)
SELECT *,
       Dense_rank()
         OVER(ORDER BY actress_avg_rating DESC, total_votes DESC) AS actress_rank
FROM   actress_details
WHERE  movie_count >= 3
ORDER  BY actress_rank; 



/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* 24. The thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/

SELECT 
    title,
    avg_rating,
    CASE
        WHEN avg_rating > 8 THEN 'Superhit movies'
        WHEN avg_rating > 7 AND avg_rating <= 8 THEN 'Hit movies'
        WHEN avg_rating >= 5 AND avg_rating <= 7 THEN 'One-time-watch movies'
        ELSE 'Flop movies'
    END AS avg_rating_category
FROM
    movie m
        INNER JOIN
    ratings r ON m.id = r.movie_id
        INNER JOIN
    genre g ON r.movie_id = g.movie_id
WHERE
    genre = 'Thriller';



/* Until now, we have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/


-- 25. The genre-wise running total and moving average of the average movie duration.

/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/

WITH genre_details
AS
  (
             SELECT     g.genre,
                        round(avg(duration)) avg_duration
             FROM       genre g
             INNER JOIN movie m
             ON         g.movie_id = m.id
             GROUP BY   genre)
  SELECT   *,
           round(sum(avg_duration) over w , 2) AS running_total_duration,
           round(avg(avg_duration) over w , 2) AS moving_avg_duration
  FROM     genre_details 
  window w AS (ORDER BY genre ROWS BETWEEN unbounded preceding AND current row);


-- Let us find top 5 movies of each year with top 3 genres.

-- 26. The five highest-grossing movies of each year that belong to the top three genres.

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

-- Top 3 Genres based on most number of movies

-- Note : As there is discrepancy on currency(both INR and $ are included). In our analysis, we have ignored INR values.


WITH genre_details AS
(
                SELECT DISTINCT genre,
                                Count(*) OVER(partition BY genre) AS movie_count
                FROM            genre g
                INNER JOIN      movie m
                ON              g.movie_id = m.id
                ORDER BY        movie_count DESC limit 3), 
genre_movie_details AS
(
           SELECT     g.genre,
                      m.year,
                      m.title as movie_name,
                      m.worlwide_gross_income as worldwide_gross_income,
                      Dense_rank() OVER(partition BY year ORDER BY Cast(Substring(m.worlwide_gross_income,3) AS UNSIGNED integer) DESC) AS movie_rank
           FROM       movie m
           INNER JOIN genre g
           ON         m.id = g.movie_id
           WHERE      g.genre IN
                      (
                             SELECT genre
                             FROM   genre_details))
SELECT *
FROM   genre_movie_details
WHERE  movie_rank <= 5;


-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- 27.  The top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies.
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/

SELECT     production_company,
           Count(movie_id)                                   AS movie_count,
           Dense_rank() over (ORDER BY count(movie_id) DESC) AS prod_comp_rank
FROM       movie m
INNER JOIN ratings r
ON         m.id = r.movie_id
WHERE      median_rating >= 8
AND        production_company IS NOT NULL
AND        position(',' IN languages)>=1
GROUP BY   production_company
LIMIT      2;



-- 28. The top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre.
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

WITH actress_details AS
(
           SELECT     n.NAME                   actress_name,
                      Sum(total_votes)         AS total_votes,
                      Count(m.id)                 AS movie_count,
                      Round(Avg(avg_rating),2) AS actress_avg_rating
           FROM       role_mapping rm
           INNER JOIN names n
           ON         rm.name_id = n.id
           INNER JOIN movie m
           ON         rm.movie_id = m.id
           INNER JOIN ratings r
           ON         r.movie_id = m.id
           INNER JOIN genre g
           ON         g.movie_id = m.id
           WHERE      rm.category = 'actress'
           AND        r.avg_rating > 8
           AND        g.genre = 'Drama'
           GROUP BY   n.NAME)
SELECT   *,
         Dense_rank() OVER(ORDER BY movie_count DESC) AS actress_rank
FROM     actress_details LIMIT 3;



/* 29. Extract the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/

WITH director_details AS
(
           SELECT     dm.name_id                                             AS director_id,
                      n.NAME                                                 AS director_name,
                      count(m.id) OVER w1                                    AS number_of_movies,
                      round(avg(r.avg_rating) OVER w1 ,2)                    AS avg_rating,
                      sum(r.total_votes) OVER w1                             AS total_votes,
                      min(r.avg_rating) OVER w1                              AS min_rating,
                      max(r.avg_rating) OVER w1                              AS max_rating,
                      sum(m.duration) OVER w1                                AS total_duration,
                      datediff(date_published, lead(date_published) OVER w2) AS published_difference
           FROM       director_mapping dm
           INNER JOIN names n
           ON         dm.name_id = n.id
           INNER JOIN movie m
           ON         dm.movie_id = m.id
           INNER JOIN ratings r
           ON         r.movie_id = m.id 
           window w1 AS (partition BY dm.name_id),
				  w2 AS (partition BY dm.name_id ORDER BY date_published DESC)
           ORDER BY   number_of_movies DESC)
SELECT DISTINCT director_id,
                director_name,
                number_of_movies,
                round(sum(published_difference) OVER(partition BY director_name)/(number_of_movies - 1)) AS avg_inter_movie_days,
                avg_rating,
                total_votes,
                min_rating,
                max_rating,
                total_duration
FROM            director_details
ORDER BY        number_of_movies DESC, director_name
LIMIT 9;
