USE signup_flow;

WITH total_visitors AS (
    SELECT 
        v.visitor_id,
        v.first_visit_date, 
        s.date_registered AS registration_date,
        MAX(p.purchase_date) AS purchase_date  -- Use MAX() to aggregate purchase_date
    FROM 
        visitors AS v
    LEFT JOIN 
        students AS s ON v.user_id = s.user_id
    LEFT JOIN 
        student_purchases AS p ON v.user_id = p.user_id
    GROUP BY 
        v.visitor_id, v.first_visit_date, s.date_registered
),

count_visitors AS (
    SELECT 
        first_visit_date AS date_session,
        COUNT(*) AS count_total_visitors
    FROM 
        total_visitors 
    GROUP BY 
        date_session
),

count_registered AS (
    SELECT 
        first_visit_date AS date_session,
        COUNT(*) AS count_registered
    FROM 
        total_visitors
    WHERE 
        registration_date IS NOT NULL
    GROUP BY 
        date_session
),

count_registered_free AS (
    SELECT 
        first_visit_date AS date_session,
        COUNT(*) AS count_registered_free
    FROM 
        total_visitors
    WHERE 
        registration_date IS NOT NULL
        AND (purchase_date IS NULL OR TIMESTAMPDIFF(minute, registration_date, purchase_date) > 30)
    GROUP BY 
        date_session
)

SELECT 
    v.date_session AS date_session,
    v.count_total_visitors,
    IFNULL(r.count_registered, 0) AS count_registered,
    IFNULL(fr.count_registered_free, 0) AS free_registered_users
FROM 
    count_visitors AS v
LEFT JOIN 
    count_registered AS r ON v.date_session = r.date_session
LEFT JOIN 
    count_registered_free AS fr ON v.date_session = fr.date_session
WHERE 
    v.date_session < '2024-10-01'
ORDER BY 
    v.date_session;
