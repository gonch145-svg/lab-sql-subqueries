USE sakila;

-- 1. Number of copies of "Hunchback Impossible" in inventory
SELECT
    COUNT(*) AS number_of_copies
FROM inventory i
JOIN film f
    ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';

-- 2. Films longer than the average length of all films
SELECT
    title,
    length
FROM film
WHERE length > (
    SELECT AVG(length)
    FROM film
)
ORDER BY length DESC, title ASC;

-- 3. All actors who appear in the film "Alone Trip"
SELECT
    a.actor_id,
    a.first_name,
    a.last_name
FROM actor a
JOIN film_actor fa
    ON a.actor_id = fa.actor_id
WHERE fa.film_id = (
    SELECT film_id
    FROM film
    WHERE title = 'Alone Trip'
);

-- Bonus 1: All movies categorized as family films
SELECT
    f.title
FROM film f
JOIN film_category fc
    ON f.film_id = fc.film_id
JOIN category c
    ON fc.category_id = c.category_id
WHERE c.name = 'Family'
ORDER BY f.title ASC;

-- Bonus 2A: Name and email of customers from Canada using joins
SELECT
    c.first_name,
    c.last_name,
    c.email
FROM customer c
JOIN address a
    ON c.address_id = a.address_id
JOIN city ci
    ON a.city_id = ci.city_id
JOIN country co
    ON ci.country_id = co.country_id
WHERE co.country = 'Canada'
ORDER BY c.last_name, c.first_name;

-- Bonus 2B: Name and email of customers from Canada using subqueries
SELECT
    first_name,
    last_name,
    email
FROM customer
WHERE address_id IN (
    SELECT address_id
    FROM address
    WHERE city_id IN (
        SELECT city_id
        FROM city
        WHERE country_id = (
            SELECT country_id
            FROM country
            WHERE country = 'Canada'
        )
    )
)
ORDER BY last_name, first_name;

-- Bonus 3: Films starred by the most prolific actor
SELECT
    f.title
FROM film f
JOIN film_actor fa
    ON f.film_id = fa.film_id
WHERE fa.actor_id = (
    SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    ORDER BY COUNT(film_id) DESC
    LIMIT 1
)
ORDER BY f.title ASC;

-- Bonus 4: Films rented by the most profitable customer
SELECT DISTINCT
    f.title
FROM film f
JOIN inventory i
    ON f.film_id = i.film_id
JOIN rental r
    ON i.inventory_id = r.inventory_id
WHERE r.customer_id = (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    ORDER BY SUM(amount) DESC
    LIMIT 1
)
ORDER BY f.title ASC;

-- Bonus 5: client_id and total_amount_spent of clients who spent more than the average total spent by each client
SELECT
    customer_id AS client_id,
    SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (
    SELECT AVG(total_spent)
    FROM (
        SELECT
            customer_id,
            SUM(amount) AS total_spent
        FROM payment
        GROUP BY customer_id
    AS customer_totals
    )
)
ORDER BY total_amount_spent DESC;