Use Sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name,last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in 
-- upper case letters. Name the column `Actor Name`.
ALTER TABLE actor ADD COLUMN Actor_Name VARCHAR(50);
UPDATE actor SET Actor_Name = CONCAT(first_name,' ',last_name);
SELECT * from actor;

-- 2a. You need to find the ID number, first name, and last name 
-- of an actor, of whom you know only the first name, "Joe." What 
-- is one query would you use to obtain this information?
SELECT actor_id,first_name,last_name from actor where first_name='Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT Actor_Name from actor where last_name like '%GEN' 
	OR last_name like '%GEN%' 
	OR last_name like 'GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:
SELECT last_name,first_name from actor where last_name like '%LI' 
	OR last_name like '%LI%' 
	OR last_name like 'LI%'
	ORDER BY last_name,first_name;
    
-- 2d. Using `IN`, display the `country_id` and `country` columns of the 
-- following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country 
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` and use 
-- the data type `BLOB` (Make sure to research the type `BLOB`, as the difference 
-- between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT COUNT(actor_id), last_name
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but 
-- only for names that are shared by at least two actors
SELECT COUNT(actor_id), last_name
FROM actor
GROUP BY last_name
HAVING COUNT(actor_id)>1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
-- Write a query to fix the record.
UPDATE actor 
SET first_name = "HARPO", Actor_Name = CONCAT(first_name,' ',last_name)
WHERE Actor_Name = "GROUCHO WILLIAMS";

-- to check correction:
SELECT Actor_Name from actor
ORDER BY Actor_Name;

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
-- It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor 
SET first_name = "GROUCHO", Actor_Name = CONCAT(first_name,' ',last_name)
WHERE first_name = "HARPO";

-- to check correction:
SELECT Actor_Name from actor
ORDER BY Actor_Name;

-- 5a. You cannot locate the schema of the `address` table. 
-- Which query would you use to re-create it?
-- Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html]
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
-- Use the tables `staff` and `address`:
SELECT * from address;
SELECT * from staff;

SELECT staff.first_name, staff.last_name, address.address
FROM staff
JOIN address ON
staff.address_id=address.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005.
-- Use tables `staff` and `payment`.
SELECT s.first_name, s.last_name, SUM(p.amount) AS "Rung Up Sum ($)"
FROM payment p
JOIN staff s
ON s.staff_id=p.staff_id
WHERE payment_date like "2005-08%"
GROUP BY s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film.
-- Use tables `film_actor` and `film`. Use inner join.
SELECT * from film_actor;

SELECT f.title, COUNT(fa.actor_id) AS '# of Actors'
FROM film f
INNER JOIN film_actor fa
ON f.film_id=fa.film_id
GROUP BY f.film_id;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT f.title, COUNT(i.inventory_id) AS "Number of Copies"
FROM inventory i
JOIN film f
ON i.film_id=f.film_id
WHERE f.title IN ("Hunchback Impossible")
GROUP BY f.film_id;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer.
-- List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) AS "Total Paid ($)"
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title FROM film 
WHERE title LIKE "Q%" OR title LIKE "K%" AND language_id IN
(
	SELECT language_id FROM language
    WHERE name IN ("English")
); 

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name FROM actor 
WHERE actor_id IN
(
	SELECT actor_id FROM film_actor
    WHERE film_id IN 
    (
		SELECT film_id FROM film
        WHERE title IN ("Alone Trip")
	)
); 

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT c.first_name, c.last_name, c.email
FROM customer c
JOIN address a
ON c.address_id=a.address_id
WHERE a.city_id IN
	(
		SELECT city_id
		FROM city
		JOIN country
		ON city.country_id=country.country_id
		WHERE country.country="Canada"
	);
        
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.
SELECT * from category;
SELECT title FROM film 
WHERE film_id IN
(
	SELECT film_id 
    FROM film_category
    WHERE category_id IN
    (
		SELECT category_id
        FROM category
        WHERE name IN ('Family')
	)
);

-- alternative way
SELECT f.title
FROM film f
JOIN film_category fc
ON f.film_id=fc.film_id
WHERE fc.category_id IN
	(
		SELECT c.category_id
		FROM category c
		JOIN film_category fc
		ON c.category_id=fc.category_id
		WHERE c.name="Family"
	);

-- 7e. Display the most frequently rented movies in descending order.
-- rental (inventory_id) --> inventory (film_id) --> film(title)
SELECT f.title, COUNT(f.film_id) AS "Rental Frequency"
FROM film f
JOIN inventory i
ON f.film_id=i.film_id
WHERE i.inventory_id IN
(
	SELECT i.inventory_id
    FROM inventory i
    JOIN rental r
    ON i.inventory_id=r.inventory_id
)
GROUP BY f.film_id
ORDER BY COUNT(f.film_id) DESC, title;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- payment(staff_id) --> staff(store_id)
SELECT s.store_id, SUM(p.amount) AS "Business ($)"
FROM staff s
JOIN payment p 
	ON s.staff_id=p.staff_id
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
-- store(address_id) --> address(city_id) --> city (country_id) --> country

SELECT s.store_id, cty.city, ctry.country
FROM store s 
JOIN address a 
	ON s.address_id = a.address_id
JOIN city cty
    ON a.city_id = cty.city_id
JOIN country ctry 
	ON cty.country_id=ctry.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- category(category_id) --> film_category(film_id) --> inventory(inventory_id) --> 
-- rental(rental_id) --> payment(amount)
SELECT c.name, SUM(p.amount) AS "Gross Revenue"
FROM category c
JOIN film_category fc
	ON c.category_id = fc.category_id
JOIN inventory i
	ON fc.film_id = i.film_id
JOIN rental r
	ON i.inventory_id = r.inventory_id
JOIN payment p
	ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five
-- genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h,
-- you can substitute another query to create a view.
CREATE VIEW top_5_revenue_genres AS
SELECT c.name AS "Genre", SUM(p.amount) AS "Gross Revenue"
FROM category c
JOIN film_category fc
	ON c.category_id = fc.category_id
JOIN inventory i
	ON fc.film_id = i.film_id
JOIN rental r
	ON i.inventory_id = r.inventory_id
JOIN payment p
	ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_5_revenue_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_5_revenue_genres;