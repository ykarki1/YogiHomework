-- Use the database called sakila
USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT 
    first_name, last_name
FROM
    actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT 
    UPPER(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
FROM
    actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
-- What is one query would you use to obtain this information?
SELECT 
    actor_ID, first_name, last_name
FROM
    actor
WHERE
    first_name = 'Joe';
    
-- 2b. Find all actors whose last name contain the letters GEN:
SELECT 
    first_name, last_name
FROM
    actor
WHERE
    last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT 
    first_name, last_name
FROM
    actor
WHERE
    last_name LIKE '%LI%'
ORDER BY last_name , first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT 
    country, country_id
FROM
    country
WHERE
    country IN ('Afghanistan' , 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table actor 
add description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor
drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT 
    last_name, COUNT(last_name) AS "No. of Actors"
FROM
    actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT 
    last_name, COUNT(last_name) AS count
FROM
    actor
GROUP BY last_name
HAVING count >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor 
SET 
    first_name = 'Harpo'
WHERE
    first_name = 'Grucho';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor 
SET 
    first_name = 'Grucho'
WHERE
    first_name = 'Harpo';


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT 
    s.first_name, s.last_name, a.address
FROM
    staff s
        JOIN
    address a ON s.address_id = s.address_id;	

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT 
    s.staff_id,
    s.first_name,
    s.last_name,
    SUM(p.amount) AS 'Amount in August 2005'
FROM
    staff s
        JOIN
    payment p ON s.staff_id = p.staff_id
WHERE
    payment_date LIKE '2005-08%'
GROUP BY staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT 
    f.title, COUNT(fa.actor_id) AS 'Number of Actors'
FROM
    film f
        JOIN
    film_actor fa ON f.film_id = fa.film_id
GROUP BY f.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
-- Found two solutions
SELECT 
    title,
    (SELECT 
            COUNT(*)
        FROM
            inventory
        WHERE
            film.film_id = inventory.film_id) AS 'Copy Counts'
FROM
    film
WHERE
    title = 'Hunchback impossible';

		
-- OR--


 SELECT 
    COUNT(film_id)
FROM
    inventory
WHERE
    film_id = (SELECT 
            film_id
        FROM
            film
        WHERE
            title = 'Hunchback Impossible');


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT 
    c.first_name,
    c.last_name,
    SUM(p.amount) AS 'Total Amount Paid'
FROM
    customer c
        JOIN
    payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT 
    title
FROM
    film
WHERE
    title IN (SELECT 
            title
        FROM
            film
        WHERE
            title LIKE 'q%'
                OR title LIKE 'k%' 
                AND language_id = 1);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT 
    CONCAT(first_name, ' ', last_name) AS 'Actors in Alone Trip'
FROM
    actor
WHERE
    actor_id IN (
		SELECT 
            actor_id
        FROM
            film_actor
        WHERE
            film_id = (SELECT 
                    film_id
                FROM
                    film
                WHERE
                    title = 'Alone Trip'));


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT 
    first_name, last_name, email
FROM
    customer
        join address ON customer.address_id=address.address_id
        join city on city.city_id = address.city_id
        join country on city.country_id = country.country_id
where country.country = "Canada";

-- OR --

SELECT 
    first_name, last_name, email
FROM
    customer,
    address,
    city,
    country
WHERE
    customer.address_id = address.address_id
        AND city.city_id = address.city_id
        AND city.country_id = country.country_id
        AND country.country = 'Canada';
        
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT 
    title
FROM
    film
        JOIN
    film_category ON film.film_id = film_category.film_id
        JOIN
    category ON film_category.category_id = category.category_id
WHERE
    category.name = 'Family';


-- 7e. Display the most frequently rented movies in descending order.

SELECT 
    title, COUNT(title) AS 'Rental Counts'
FROM
    film
        JOIN
    inventory ON inventory.film_id = film.film_id
        JOIN
    rental ON rental.inventory_id = inventory.inventory_id
GROUP BY title
ORDER BY COUNT(title) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT 
    store_id, SUM(amount) as "Total Sales"
FROM
    payment
        JOIN
    rental ON payment.rental_id = rental.rental_id
        JOIN
    inventory ON inventory.inventory_id = rental.inventory_id
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT 
    store_id, city, country
FROM
    store
        JOIN
    address ON address.address_id = store.address_id
        JOIN
    city ON city.city_id = address.city_id
        JOIN
    country ON country.country_id = city.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT 
    name AS genre, SUM(amount) AS gross_revenue
FROM
    category c
        JOIN
    film_category fc ON c.category_id = fc.category_id
        JOIN
    inventory i ON i.film_id = fc.film_id
        JOIN
    rental r ON r.inventory_id = i.inventory_id
        JOIN
    payment p ON p.rental_id = r.rental_id
GROUP BY genre
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top5_by_revenue AS
    SELECT 
        name AS genre, SUM(amount) AS gross_revenue
    FROM
        category c
            JOIN
        film_category fc ON c.category_id = fc.category_id
            JOIN
        inventory i ON i.film_id = fc.film_id
            JOIN
        rental r ON r.inventory_id = i.inventory_id
            JOIN
        payment p ON p.rental_id = r.rental_id
    GROUP BY genre
    ORDER BY gross_revenue DESC
    LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT 
    *
FROM
    top5_by_revenue;


-- 8c. You find that you no longer need the view top5_by_revenue. Write a query to delete it.
DROP VIEW top5_by_revenue;

