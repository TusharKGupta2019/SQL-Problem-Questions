

WITH cte AS (
    SELECT
        employee_id,
        CONVERT(DATE, activity_time) AS activity_day,
        DATEDIFF(HOUR,
            MIN(CASE WHEN activity_type = 'login' THEN activity_time END),
            MAX(CASE WHEN activity_type = 'logout' THEN activity_time END)
        ) AS total_hours
    FROM 
        dbo.sheet1
    GROUP BY 
        employee_id, 
        CONVERT(DATE, activity_time)
),
cte2 AS (
    SELECT
        employee_id,
        CONVERT(DATE, activity_time) AS activity_day,
        activity_type,
        activity_time,
        LEAD(activity_time) OVER (PARTITION BY employee_id, CONVERT(DATE, activity_time) ORDER BY activity_time) AS next_time
    FROM 
        dbo.sheet1
),
cte3 AS (
    SELECT 
        employee_id, 
        activity_day,
        SUM(DATEDIFF(HOUR, activity_time, next_time)) AS productive_hours
    FROM 
        cte2 
    WHERE 
        activity_type = 'login'
    GROUP BY 
        employee_id, 
        activity_day
)
SELECT
    a.employee_id,
    a.activity_day,
    a.total_hours,
    b.productive_hours
FROM 
    cte a
JOIN 
    cte3 b ON a.employee_id = b.employee_id AND a.activity_day = b.activity_day;
