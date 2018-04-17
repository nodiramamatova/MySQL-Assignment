
USE sakila;
SHOW tables;

#1a. Display the first and last names of all actors from the table `actor`. 
SELECT first_name, last_name
FROM actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 
SELECT CONCAT(UCASE(first_name), " ", UCASE(last_name)) AS `Actor Name`
FROM actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name="JOE";

#2b. Find all actors whose last name contain the letters `GEN`:
SELECT * FROM actor
WHERE last_name LIKE '%gen%';

#2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
WHERE last_name LIKE '%li%'
ORDER BY last_name, first_name;

#2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

# 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(50)  AFTER first_name;

SELECT * FROM actor;

# 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor
MODIFY COLUMN middle_name BLOB;

SELECT * FROM actor;

# Now delete the `middle_name` column.
ALTER TABLE actor
DROP middle_name;

SELECT * FROM actor;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) AS occurence
FROM actor
GROUP BY last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS occurence
FROM actor
GROUP BY last_name 
HAVING occurence >= 2 ;

# 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`,
# the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name ="HARPO", last_name = "WILLIAMS"
WHERE first_name ="GROUCHO" AND last_name = "WILLIAMS";

/*4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, 
change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. 
BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)*/
UPDATE actor
SET first_name = CASE
		WHEN ( first_name ="HARPO" AND last_name = "WILLIAMS") THEN "GROUCHO"
        ELSE "MUCHO GROUCHO" END
WHERE first_name ="HARPO" AND last_name = "WILLIAMS";       

#5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it? 
SHOW CREATE TABLE address;

 #6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT s.first_name, s.last_name, a.address
FROM staff s
JOIN address a ON s.address_id = a.address_id;


# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 
SELECT s.*,   p.total_amount 
FROM staff s
LEFT JOIN (
        SELECT SUM(amount) total_amount, staff_id FROM payment  WHERE payment_date LIKE "2005-08%" GROUP BY staff_id) p
ON s.staff_id = p.staff_id;

#6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT f.title, fa.number_of_actors
FROM film f 
INNER JOIN (
                 SELECT COUNT(actor_id)  number_of_actors, film_id FROM film_actor GROUP BY film_id )  fa
  ON f.film_id = fa.film_id;       
  
#  6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(inventory_id)  num  FROM inventory WHERE film_id  IN
           (
			 SELECT film_id FROM film WHERE title = "Hunchback Impossible"
			)  
GROUP BY film_id ;
         
# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, p.total_paid
FROM customer c 
JOIN (
           SELECT SUM(amount) total_paid, customer_id FROM payment GROUP BY customer_id ) p 
ON c.customer_id = p.customer_id 
ORDER BY c.last_name;

/*7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. */
SELECT title
FROM film 
WHERE (title LIKE "K%" OR  title  LIKE "Q%") AND  language_id IN 
(         
     SELECT language_id FROM language WHERE name="English"
);


#7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor 
WHERE actor_id IN 
(
       SELECT actor_id 
       FROM film_actor 
       WHERE film_id IN
       (
          SELECT film_id 
          FROM film
          WHERE title = "Alone Trip"
        ) GROUP BY film_id
   )  ;   
   
 /* 7c. You want to run an email marketing campaign in Canada, 
 for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.*/  
 SELECT c.first_name, c.last_name, c.email, ctr.country
 FROM customer c
	 JOIN address a ON c.address_id =   a.address_id
	 JOIN city ct ON a.city_id = ct.city_id
	 JOIN country ctr ON ct.country_id = ctr.country_id
 WHERE ctr.country = "Canada";
 
 #7d. Sales have been lagging among young families, 
 #and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
 SELECT  f.title, c.name
 FROM film f
	 JOIN film_category fc ON  f.film_id = fc.film_id
	 JOIN category c ON fc.category_id = c.category_id
WHERE c.name = "Family";   

 #7e. Display the most frequently rented movies in descending order.
 SELECT f.title, r.rent_count
 FROM film f
 JOIN inventory inv ON  f.film_id = inv.film_id
 JOIN (
            SELECT COUNT(rental_id) rent_count, inventory_id FROM rental  GROUP BY inventory_id
           ) r 
ON inv.inventory_id = r.inventory_id
ORDER BY r.rent_count DESC;

# 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, p.total_sum
FROM store  s 
	JOIN (
			   SELECT  SUM(amount) total_sum, staff_id FROM payment  GROUP BY staff_id
			)  p  
ON s.manager_staff_id = p.staff_id;  

#7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, cn.country
FROM store s 
	JOIN address a ON s.address_id = a.address_id
	JOIN city c ON a.city_id = c.city_id 
	JOIN country cn ON c.country_id = cn.country_id;
    
#7h. List the top five genres in gross revenue in descending order. 
#(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT name AS genre , SUM(amount)  AS  gross_revenue		
FROM category c
	JOIN film_category fc ON c.category_id = fc.category_id
	JOIN inventory inv ON fc.film_id = inv.film_id
	JOIN rental r ON inv.inventory_id = r.inventory_id
	JOIN payment p ON r.rental_id = p.rental_id
	GROUP BY genre
	ORDER BY gross_revenue DESC
	LIMIT 5;
    
 /*8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
 Use the solution from the problem above to create a view.
 If you haven't solved 7h, you can substitute another query to create a view.   */
 
 CREATE VIEW top_5_genres_by_gross_revenue AS (
	 SELECT name AS genre , SUM(amount)  AS  gross_revenue		
	 FROM category c
		JOIN film_category fc ON c.category_id = fc.category_id
		JOIN inventory inv ON fc.film_id = inv.film_id
		JOIN rental r ON inv.inventory_id = r.inventory_id
		JOIN payment p ON r.rental_id = p.rental_id
		GROUP BY genre
		ORDER BY gross_revenue DESC
		LIMIT 5
);

# 8b. How would you display the view that you created in 8a?

SELECT * FROM top_5_genres_by_gross_revenue ;

#8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW top_5_genres_by_gross_revenue ;

