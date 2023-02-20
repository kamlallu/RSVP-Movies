USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
/* 1.Using Union to combine the all result set
   2.Count(*) --To check the nunber of record without including the null
				values..
*/

SELECT 'director_mapping' AS tablename, 
       Count(*)           AS ROWCOUNT 
FROM   director_mapping 
UNION 
SELECT 'genre' AS tablename, 
       Count(*) 
FROM   genre 
UNION 
SELECT 'movie' AS tablename, 
       Count(*) 
FROM   movie 
UNION 
SELECT 'names' AS tablename, 
       Count(*) 
FROM   names 
UNION 
SELECT 'ratings' AS tablename, 
       Count(*) 
FROM   ratings 
UNION 
SELECT 'role_mapping' AS tablename, 
       Count(*) 
FROM   role_mapping; 
-- Q2. Which columns in the movie table have null values?
-- Type your code below:
WITH null_summary
     AS (SELECT 'id'     AS 'column_name', 
                Count(*) AS null_count 
         FROM   movie 
         WHERE  id IS NULL 
         UNION ALL 
         SELECT 'title'  AS 'column_name', 
                Count(*) AS null_count 
         FROM   movie 
         WHERE  title IS NULL 
         UNION ALL 
         SELECT 'year'   AS 'column_name', 
                Count(*) AS null_count 
         FROM   movie 
         WHERE  year IS NULL 
         UNION ALL 
         SELECT 'date_published' AS 'column_name', 
                Count(*)         AS null_count 
         FROM   movie 
         WHERE  date_published IS NULL 
         UNION ALL 
         SELECT 'duration' AS 'column_name', 
                Count(*)   AS null_count 
         FROM   movie 
         WHERE  duration IS NULL 
         UNION ALL 
         SELECT 'country' AS 'column_name', 
                Count(*)  AS null_count 
         FROM   movie 
         WHERE  country IS NULL 
         UNION ALL 
         SELECT 'worlwide_gross_income' AS 'column', 
                Count(*)                AS null_count 
         FROM   movie 
         WHERE  worlwide_gross_income IS NULL 
         UNION ALL 
         SELECT 'languages' AS 'column_name', 
                Count(*)    AS null_count 
         FROM   movie 
         WHERE  languages IS NULL 
         UNION ALL 
         SELECT 'production_company' AS 'column_name', 
                Count(*)             AS null_count 
         FROM   movie 
         WHERE  production_company IS NULL) 
SELECT * 
FROM   null_summary 
WHERE  null_count > 0; 

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

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
-- Type your code below:
-- total number of movies released each year.
SELECT   year, 
         Count(id) AS number_of_movie 
FROM     movie 
GROUP BY year 
ORDER BY year ,
         number_of_movie;
-- In 2017 no of movie is greater than the movie release in 2018 and 2019
-- There could be reason behind this less no of movies release 2018 and 2019

-- trend look month wise        
SELECT Month(date_published) AS month_num, 
       Count(id)             AS number_of_movie 
FROM   movie 
GROUP  BY month_num 
ORDER  BY month_num, 
          number_of_movie;
-- As we see there is downword trend in month ,In march month no of movie is higher..
-- month march,Jan,Nov,Dec are mostly Festival Month so to increase the sales of ticket mostly movie release in this month..

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:
SELECT COUNT(id) AS Number_of_movie, 
       year 
FROM   movie 
WHERE  (country like  '%USA%' or country like '%India%')
       AND year = 2019 
GROUP  BY year; 
    
/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
SELECT genre 
FROM   genre 
GROUP  BY genre; 

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:
WITH genre_wise_movie_count 
     AS (SELECT genre, 
                Count(id)                   AS number_of_movie, 
                Row_number() 
                  OVER( 
                    ORDER BY Count(id)DESC) AS genre_rank 
         FROM   genre R 
                INNER JOIN movie M 
                        ON R.movie_id = M.id 
         GROUP  BY genre 
         ORDER  BY number_of_movie DESC) 
SELECT * 
FROM   genre_wise_movie_count gc 
WHERE  gc.genre_rank = 1; 


/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
WITH genre_count 
     AS (SELECT movie_id, 
                Count(genre) AS no_of_genre 
         FROM   genre 
         GROUP  BY movie_id) 
SELECT Count(movie_id) 
FROM   genre_count 
WHERE  no_of_genre = 1; 
-- We get 3289 movies bleong to only one genre

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT genre, 
       Round(Avg(duration), 2) AS avg_duration 
FROM   genre G 
       INNER JOIN movie M 
               ON G.movie_id = M.id 
GROUP  BY genre 
ORDER  BY avg_duration DESC;
 


/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
SELECT genre, 
       Count(movie_id)  AS movie_count, 
       ROW_NUMBER() 
	   OVER (ORDER BY Count(movie_id) DESC) AS genre_rank 
FROM   genre 
GROUP  BY genre 
ORDER  BY movie_count DESC;
-- 3rd Rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced


/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:
SELECT Min(avg_rating)    AS min_avg_rating, 
       Max(avg_rating)    AS max_avg_rating, 
       Min(total_votes)   AS min_total_votes, 
       Max(total_votes)   AS max_total_votes, 
       Min(median_rating) AS min_median_rating, 
       Max(median_rating) AS max_median_rating 
FROM   ratings; 

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too
-- Join the movie and ratings table to get required details
WITH moviesummary 
     AS (SELECT title,
				avg_rating,
				DENSE_RANK() OVER(ORDER BY avg_rating DESC) AS dense_movie_rank 
		FROM   movie M 
				INNER JOIN ratings R 
				ON R.movie_id = M.id) 
SELECT * 
FROM   moviesummary 
WHERE  dense_movie_rank <= 10;
 -- Check the Indian movies summaary
 WITH moviesummary 
     AS (SELECT title,country,
				avg_rating,
				DENSE_RANK() OVER(ORDER BY avg_rating DESC) AS dense_movie_rank 
		FROM   movie M 
				INNER JOIN ratings R 
				ON R.movie_id = M.id) 
SELECT * 
FROM   moviesummary 
WHERE  dense_movie_rank <= 10
and country = 'India';


/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have
SELECT median_rating, 
       Count(movie_id) AS movie_count 
FROM   ratings 
GROUP  BY median_rating 
ORDER  BY median_rating;

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
WITH production_rank_details 
     AS (SELECT production_company, 
		        Count(id) AS movie_count, 
                ROW_NUMBER() OVER(ORDER BY Count(id) DESC) AS prod_company_rank 
         FROM   movie M 
                INNER JOIN ratings R 
                        ON M.id = R.movie_id 
         WHERE  avg_rating > 8 
                AND production_company IS NOT NULL 
         GROUP  BY production_company) 
SELECT * 
FROM   production_rank_details 
WHERE  prod_company_rank <= 2; 
 

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT genre, 
       Count(M.id) AS movie_count 
FROM   genre G 
       INNER JOIN movie M 
               ON M.id = G.movie_id 
       INNER JOIN ratings R 
               ON M.id = R.movie_id 
WHERE  Month(date_published) = 3 
       AND year = 2017 
       AND country = 'USA' 
       AND total_votes > 1000 
GROUP  BY genre 
ORDER  BY movie_count DESC;

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
SELECT title, 
       avg_rating, 
       genre 
FROM   movie M 
       INNER JOIN ratings R 
               ON M.id = R.movie_id 
       INNER JOIN genre G USING (movie_id) 
WHERE  title REGEXP '^The' 
       AND avg_rating > 8
ORDER BY
	   avg_rating
DESC;
-- check whether the ‘median rating’ column gives any significant insights
SELECT title, 
       median_rating, 
       genre 
FROM   movie M 
       INNER JOIN ratings R 
               ON M.id = R.movie_id 
       INNER JOIN genre G USING (movie_id) 
WHERE  title REGEXP '^The' 
       AND avg_rating > 8
ORDER BY
	   avg_rating
DESC;

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
-- Checking movies release in between 1 April 2018 and 1 April 2019.
SELECT Count(id) AS movie_count 
FROM   movie 
WHERE  date_published BETWEEN '2018-04-01' AND '2019-04-01'; 
-- Checking the count of movies having median rating is 8.
SELECT Count(id) AS movie_count 
FROM   movie M 
       INNER JOIN ratings R 
               ON M.id = R.movie_id 
WHERE  median_rating = 8 
       AND date_published BETWEEN '2018-04-01' AND '2019-04-01';
		
-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:
SELECT country, 
       Sum(total_votes) AS Total_votes_per_country 
FROM   movie M 
       INNER JOIN ratings R 
               ON M.id = R.movie_id 
GROUP  BY country 
HAVING country IN ( 'Germany', 'Italy' ) 
ORDER  BY total_votes_per_country DESC; 
-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT Sum(CASE 
             WHEN NAME IS NULL THEN 1 
             ELSE 0 
           END) AS name_null, 
       Sum(CASE 
             WHEN height IS NULL THEN 1 
             ELSE 0 
           END) AS height_nulls, 
       Sum(CASE 
             WHEN date_of_birth IS NULL THEN 1 
             ELSE 0 
           END) AS date_of_birth_nulls, 
       Sum(CASE 
             WHEN known_for_movies IS NULL THEN 1 
             ELSE 0 
           END) AS known_for_movies_nulls 
FROM   names; 

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. 
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below: 
-- Fetch top genre having  rating more than 8
WITH top_genres AS 
( 
           SELECT     genre 
           FROM       genre 
           INNER JOIN ratings 
           using      (movie_id) 
           WHERE      avg_rating>8 
           GROUP BY   genre 
           ORDER BY   Count(movie_id) DESC limit 3), top_director AS 
( 
           SELECT     n.NAME                                           AS 'director_name', 
                      Count(g.movie_id)                                AS 'movie_count', 
                      Rank() OVER(ORDER BY Count(movie_id) DESC) AS dir_rank 
           FROM       genre g 
           INNER JOIN director_mapping dm 
           ON         g.movie_id = dm.movie_id 
           INNER JOIN names n 
           ON         dm.name_id = n.id 
           INNER JOIN ratings r 
           ON         g.movie_id = r.movie_id, 
                      top_genres 
           WHERE      avg_rating > 8 
           AND        g.genre IN (top_genres.genre) 
           GROUP BY   n.NAME ) 
SELECT director_name, 
       movie_count 
FROM   top_director 
WHERE  dir_rank<=3;

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT actor_name, 
       movie_count 
FROM  (SELECT n.NAME                                AS actor_name, 
              Count(rm.movie_id)                    AS movie_count, 
              Dense_rank() 
                OVER ( 
                  ORDER BY Count(rm.movie_id) DESC) AS actor_rank 
       FROM   role_mapping rm 
              INNER JOIN names n 
                      ON n.id = rm.name_id 
              INNER JOIN ratings r 
                      ON rm.movie_id = r.movie_id 
       WHERE  median_rating >= 8 
       GROUP  BY n.NAME 
       ORDER  BY movie_count DESC) x 
WHERE  x.actor_rank <= 2; 

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
WITH top_production_company AS 
( 
           SELECT     production_company, 
                      Sum(total_votes)                                   AS votes_count, 
                      Row_number() OVER (ORDER BY Sum(total_votes) DESC) AS prod_comp_rank 
           FROM       movie m 
           INNER JOIN ratings r 
           ON         m.id = r.movie_id 
           GROUP BY   production_company 
           ORDER BY   votes_count DESC) 
SELECT * 
FROM   top_production_company 
WHERE  prod_comp_rank <=3;

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH top_actor_based_on_actor_avg_rating AS 
( 
           SELECT     n.NAME                                                                                   AS actor_name,
                      Sum(total_votes)                                                                         AS total_votes,
                      Count(m.id)                                                                              AS movie_count,
                      Sum(r.avg_rating * r.total_votes) / Sum(r.total_votes)                                   AS actor_avg_rating,
                      Row_number() OVER (ORDER BY Sum(r.avg_rating * r.total_votes) / Sum(r.total_votes) DESC) AS actor_rank
           FROM       names n 
           INNER JOIN role_mapping rm 
           ON         n.id = rm.name_id 
           INNER JOIN movie m 
           ON         rm.movie_id = m.id 
           INNER JOIN ratings r 
           ON         rm.movie_id = r.movie_id 
           WHERE      m.country LIKE '%India%'
					  AND category = 'actor'
           GROUP BY   n.NAME 
           HAVING     movie_count>=5) 
SELECT * 
FROM   top_actor_based_on_actor_avg_rating;


-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH top_actress_based_on_actor_avg_rating AS 
( 
   SELECT     n.NAME                                                                                   AS actress_name,
			  Sum(total_votes)                                                                         AS total_votes,
			  Count(m.id)                                                                              AS movie_count,
			  Sum(r.avg_rating * r.total_votes) / Sum(r.total_votes)                                   AS actress_avg_rating,
			  Row_number() OVER (ORDER BY Sum(r.avg_rating * r.total_votes) / Sum(r.total_votes) DESC) AS actress_rank
   FROM       names n 
   INNER JOIN role_mapping rm 
   ON         n.id = rm.name_id 
   INNER JOIN movie m 
   ON         rm.movie_id = m.id 
   INNER JOIN ratings r 
   ON         rm.movie_id = r.movie_id
   WHERE      m.country LIKE '%India%'
			  AND m.languages = 'Hindi'
              AND category = 'actress'
   GROUP BY   n.NAME 
   HAVING     movie_count>=3) 
SELECT * 
FROM   top_actress_based_on_actor_avg_rating
where actress_rank<=5;

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:
WITH thriller_movie 
     AS (SELECT m.title, 
                g.genre, 
                r.avg_rating 
         FROM   genre g 
                INNER JOIN movie m 
                        ON g.movie_id = m.id 
                INNER JOIN ratings r 
                        ON m.id = r.movie_id 
         WHERE  genre = 'Thriller' 
         ORDER  BY title) 
SELECT title, 
       genre, 
       avg_rating, 
       CASE 
         WHEN avg_rating > 8 THEN 'Superhit movies' 
         WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit Movies' 
         WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies' 
         ELSE 'Flop movies' 
       END AS 'Category' 
FROM   thriller_movie;

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
SELECT     genre, 
           Round(Avg(duration))                AS avg_duration, 
           round(sum(Avg(duration)) OVER w1,2) AS running_total_duration, 
           round(avg(avg(duration)) OVER w2,2) AS moving_avg_duration 
FROM       genre g 
INNER JOIN movie m
ON         g.movie_id = m.id 
GROUP BY   genre window w1 AS (ORDER BY genre rows UNBOUNDED PRECEDING), 
           w2              AS (ORDER BY genre rows BETWEEN 3 PRECEDING AND 3 FOLLOWING);
       
	
-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies
-- checking data-type of worldwide_gross_income column
SELECT column_name, 
       data_type 
FROM   information_schema.columns 
WHERE  table_schema = 'imdb' 
AND    table_name = 'movie' 
AND    column_name = 'worlwide_gross_income'; 

-- 'varchar'. Datatype of this column needs to be changed to numeric.
WITH genre_wise_summary AS 
( 
           SELECT     genre 
           FROM       genre g 
           INNER JOIN ratings r 
           ON         g.movie_id = r.movie_id 
           WHERE      avg_rating>8 
           GROUP BY   genre 
           ORDER BY   Count(g.movie_id) DESC limit 3), movie_info AS 
( 
           SELECT     g.genre , 
                      year, 
                      title                                                                                                                           AS movie_name, 
                      Cast(Replace(Replace(worlwide_gross_income,'INR',''),'$','')AS DECIMAL(12))                                                     AS worlwide_gross_income, 
                      Dense_rank() OVER (partition BY year ORDER BY Cast(Replace(Replace(worlwide_gross_income,'INR',''),'$','')AS DECIMAL(12)) DESC) AS movie_rank 
           FROM       genre g 
           INNER JOIN movie m 
           ON         g.movie_id = m.id, 
                      genre_wise_summary 
           WHERE      g.genre IN (genre_wise_summary.genre) 
           ORDER BY   worlwide_gross_income DESC) 
SELECT   * 
FROM     movie_info 
WHERE    movie_rank<=5 
ORDER BY year;

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
WITH production_info 
     AS (SELECT production_company, 
                Count(movie_id)                    AS movie_count, 
                Row_number() 
                  over ( 
                    ORDER BY Count(movie_id) DESC) AS prod_comp_rank 
         FROM   movie m 
                inner join ratings r 
                        ON m.id = r.movie_id 
         WHERE  median_rating > 8 
                AND Position(',' IN m.languages) > 0 
                AND production_company IS NOT NULL 
         GROUP  BY production_company 
         ORDER  BY movie_count DESC) 
SELECT * 
FROM   production_info p 
WHERE  p.prod_comp_rank <= 2; 

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH top_actress 
     AS (SELECT n.NAME                                                     AS 
                "actress_name", 
                Sum(total_votes)                                           AS 
                   total_votes, 
                Count(g.movie_id)                                          AS 
                   movie_count, 
                Round(Sum(total_votes * avg_rating) / Sum(total_votes), 2) AS 
                   actor_avg_rating, 
                Row_number() 
                  OVER ( 
                    ORDER BY Count(g.movie_id) DESC)                       AS 
                   actress_rank 
         FROM   names n 
                INNER JOIN role_mapping rm 
                        ON n.id = rm.name_id 
                INNER JOIN genre g 
                        ON rm.movie_id = g.movie_id 
                INNER JOIN ratings r 
                        ON g.movie_id = r.movie_id 
         WHERE  avg_rating > 8 
                AND genre = 'Drama' 
                AND category = 'actress' 
         GROUP  BY n.NAME 
         ORDER  BY movie_count DESC) 
SELECT * 
FROM   top_actress ta 
WHERE  ta.actress_rank <= 3; 
/* Q29. Get the following details for top 9 directors (based on number of movies)
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
-- Type you code below:
WITH director_details 
     AS (SELECT dm.name_id, 
                n.NAME, 
                dm.movie_id, 
                r.avg_rating, 
                r.total_votes, 
                m.duration, 
                m.date_published, 
                Lag(date_published, 1) 
                  OVER( 
                    partition BY dm.name_id 
                    ORDER BY m.date_published ) AS prev_date_published 
         FROM   names n 
                INNER JOIN director_mapping dm 
                        ON n.id = dm.name_id 
                INNER JOIN movie m 
                        ON dm.movie_id = m.id 
                INNER JOIN ratings r 
                        ON r.movie_id = m.id 
         ORDER  BY date_published), 
     full_info 
     AS (SELECT name_id                                                      AS 
                'director_id', 
                NAME                                                         AS 
                   'director_name', 
                Count(movie_id)                                              AS 
                   no_of_movies, 
                Round(Avg(Datediff(date_published, prev_date_published)), 2) AS 
                avg_inter_movie_days, 
                Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2)   AS 
                   avg_rating, 
                Sum(total_votes)                                             AS 
                   total_votes, 
                Round(Min(avg_rating), 1)                                    AS 
                   min_rating, 
                Round(Max(avg_rating), 1)                                    AS 
                   max_rating, 
                Sum(duration)                                                AS 
                   total_duration, 
                Row_number() 
                  OVER( 
                    ORDER BY Count(movie_id) DESC)                           AS 
                   director_rank 
         FROM   director_details 
         GROUP  BY director_id 
         ORDER  BY no_of_movies DESC) 
SELECT director_id, 
       director_name, 
       no_of_movies, 
       avg_inter_movie_days, 
       avg_rating, 
       total_votes, 
       min_rating, 
       max_rating, 
       total_duration 
FROM   full_info fi 
WHERE  fi.director_rank <= 9; 
