-- Open database
USE SAKILA;

-- 1a. Display the first and last names of all actors from the table actor
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name, " ", last_name) AS Actor_Name FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id as ID_number, first_name, last_name FROM sakila.actor WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id as ID_number, first_name, last_name FROM sakila.actor WHERE last_name LIKE "%gen%";

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT actor_id as ID_number, first_name, last_name FROM sakila.actor WHERE last_name LIKE "%LI%" ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM sakila.country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

ALTER TABLE actor
ADD COLUMN Description blob;
SELECT * FROM sakila.actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN Description;
SELECT * FROM sakila.actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name as 'Last Name', count(last_name) as 'Total Count'
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name as 'Last Name', count(last_name) as 'Total Count'
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE sakila.actor SET first_name='HARPO' WHERE actor_id=172;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE sakila.actor SET first_name='GROUCHO' WHERE first_name='HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
CREATE TABLE IF NOT EXISTS
 `address` (
 `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
 `address` varchar(50) NOT NULL,
 `address2` varchar(50) DEFAULT NULL,
 `district` varchar(20) NOT NULL,
 `city_id` smallint(5) unsigned NOT NULL,
 `postal_code` varchar(10) DEFAULT NULL,
 `phone` varchar(20) NOT NULL,
 `location` geometry NOT NULL,
 `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 PRIMARY KEY (`address_id`),
 KEY `idx_fk_city_id` (`city_id`),
 SPATIAL KEY `idx_location` (`location`),
 CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address , address.district, address.city_id, address.postal_code
FROM staff
JOIN address on staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, sum(payment.amount) as 'Total Amount'
FROM staff
JOIN payment on staff.staff_id = payment.staff_id
WHERE payment_date LIKE '2005-08%'
group by staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title as 'Name of Film', count(film_actor.actor_id) as 'Number of Actors'
FROM film
INNER JOIN film_actor on film.film_id = film_actor.film_id
group by film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title as 'Name of Film', count(i.film_id) as 'Number of Copies'
FROM film f
JOIN inventory i on f.film_id = i.film_id
where f.title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, sum(p.amount) as 'Total paid by Customer'
FROM customer c
JOIN payment p on c.customer_id = p.customer_id
group by c.last_name ORDER BY c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film
WHERE language_id 
	IN (SELECT language_id FROM language WHERE name = "English"
    AND title LIKE "K%" OR title LIKE "Q%");

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor
WHERE actor_id in
	(SELECT actor_id
	FROM film_actor
	WHERE film_id in
    (SELECT film_id
    FROM FILM 
    WHERE title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT customer.email, customer.first_name, customer.last_name
FROM customer 
    INNER JOIN address 
        ON customer.address_id = address.address_id
    INNER JOIN city
        ON address.city_id = city.city_id
	INNER JOIN country
        ON city.country_id = country.country_id
	WHERE country.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT film.title as 'Family Films'
FROM film 
    INNER JOIN film_category 
        ON film.film_id = film_category.film_id
    INNER JOIN category
        ON film_category.category_id = category.category_id
	WHERE category.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title as 'Movie', COUNT(title) AS 'Rented Movies - Total'
FROM film, inventory, rental
WHERE film.film_id = inventory.film_id
AND rental.inventory_id = inventory.inventory_id
GROUP BY inventory.film_id
ORDER BY COUNT(title) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id as 'Store', concat('$', format(sum(payment.amount), 2)) AS 'Total Revenue' 
FROM store, payment, staff
WHERE store.store_id = staff.store_id
AND staff.staff_id = payment.staff_id
GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id as 'Store ID', city.city as 'City', country.country as 'Country'
FROM store, city, country, address
WHERE store.address_id = address.address_id
AND city.city_id = address.city_id
AND country.country_id = city.country_id
GROUP BY store.store_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name AS 'Genre', SUM(payment.amount) AS Total_Revenue
FROM category, film_category, inventory, rental, payment
WHERE 
film_category.category_id = category.category_id
AND inventory.film_id = film_category.film_id
AND rental.inventory_id = inventory.inventory_id
AND payment.rental_id = rental.rental_id
GROUP BY Genre
ORDER BY Total_Revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Genre_Top_5_Revenue as
(SELECT category.name AS 'Genre', SUM(payment.amount) AS Total_Revenue
FROM category, film_category, inventory, rental, payment
WHERE 
film_category.category_id = category.category_id
AND inventory.film_id = film_category.film_id
AND rental.inventory_id = inventory.inventory_id
AND payment.rental_id = rental.rental_id
GROUP BY Genre
ORDER BY Total_Revenue DESC
LIMIT 5);

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM Genre_Top_5_Revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW Genre_Top_5_Revenue;