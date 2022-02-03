-- lab-predictions-logistic-regression

-- 1. Create a query or queries to extract the information you think may be relevant for building 
-- the prediction model. It should include some film features and some rental features. Use the data from 2005.

DROP TABLE IF EXISTS film_rental;
CREATE TABLE film_rental AS
WITH cte_rental AS (SELECT f.film_id, COUNT(r.rental_id) AS n_rentals 
					FROM sakila.film f
                    JOIN sakila.inventory i USING (film_id)
                    JOIN sakila.rental r USING (inventory_id)
                    WHERE YEAR(CONVERT(r.rental_date, DATE)) = 2005
                    GROUP BY film_id)
    SELECT f.film_id, 
    n_rentals, 
    c.name AS category,
    f.rental_rate,
    CEIL(f.replacement_cost) AS replacement_cost,
    f.rating
FROM
    cte_rental
		JOIN
    sakila.film f USING (film_id)
        JOIN
    sakila.film_category fc USING (film_id)
        JOIN
    sakila.category c USING (category_id)
    ORDER BY film_id;

-- 4. Create a query to get the list of films and a boolean indicating if it was rented last month (August 2005).
-- This would be our target variable.

DROP TABLE IF EXISTS rental_prediction;
CREATE TABLE rental_prediction AS
WITH cte_months AS (SELECT f.film_id, COUNT(*) AS rented_august 
					FROM sakila.rental r
                    JOIN sakila.inventory i USING (inventory_id)
                    JOIN sakila.film f USING (film_id)
                    WHERE MONTH(CONVERT(r.rental_date , DATE)) = 08 
                    GROUP BY f.film_id)
SELECT f.film_id, f.n_rentals, f.category, f.rental_rate, f.replacement_cost, f.rating,
    CASE
        WHEN c.rented_august < 6 THEN 'No'
        ELSE 'Yes'
    END AS rented_last_month
FROM
    film_rental f
        JOIN
    cte_months c USING (film_id);

    
