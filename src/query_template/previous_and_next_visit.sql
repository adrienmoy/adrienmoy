WITH available_tech AS (
    SELECT  employee_id
    FROM timeslot_timeslot
        WHERE 
        beginning = {{ beginning }}
        AND total_capacity > nb_bookings
    ),
    
    previous_visit AS (
    SELECT 
        available_tech.employee_id,
        MAX(timeslot.beginning) as previous_visit_beginning,
        MAX(customer.postal_code) as previous_visit_postal_code 
            --déterminer comment sortir le postal code de la visite la plus proche
    FROM available_tech
    LEFT JOIN timeslot_timeslot AS timeslot
        ON available_tech.employee_id = timeslot.employee_id
    JOIN murfy_erp_visit AS visit
        ON visit.timeslot_id = timeslot.id
    JOIN murfy_erp_customerfile customer
        ON visit.customer_file_id = customer.id
    WHERE beginning < {{ beginning }}
        AND beginning > {{ day_start }} --same day (trunc timeslot to day)
        --AND visit.satus = ça va
    GROUP BY available_tech.employee_id
    ),
    
    next_visit AS (
    SELECT 
        available_tech.employee_id,
        MAX(timeslot.beginning) as next_visit_beginning,
        MAX(customer.postal_code) as next_visit_postal_code 
            --déterminer comment sortir le postal code de la visite la plus proche
    FROM available_tech
    LEFT JOIN timeslot_timeslot AS timeslot
        ON available_tech.employee_id = timeslot.employee_id
    JOIN murfy_erp_visit AS visit
        ON visit.timeslot_id = timeslot.id
    JOIN murfy_erp_customerfile customer
        ON visit.customer_file_id = customer.id
    WHERE beginning > {{ beginning }}
        AND beginning < {{ day_end }} --before the end of the same day
        --AND visit.satus = ça va
    GROUP BY available_tech.employee_id
    )
    
SELECT 
    a.employee_id,
    previous_visit_postal_code,
    next_visit_postal_code
FROM available_tech AS a
LEFT JOIN previous_visit AS p
    ON a.employee_id = p.employee_id 
LEFT JOIN next_visit AS n 
    ON a.employee_id = n.employee_id 
    
--join tout ça sur le base point de chaque tech