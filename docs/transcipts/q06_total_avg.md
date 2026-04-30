# QUERY

Consider the following query. We use it to find, for each patient with id AMKA, their hospitalisation record, admission and discharge diagnosis, total hospitalisation cost and average rating for that hospitalisation. How would we find their average rating across all hospitalisations in their record?

SELECT 
    pr.AMKA, 
    h.hosp_id, 
    calculate_hospit_cost(h.hosp_id) AS cost, 
    ad.diag_id as admission_diagnosis, 
    dd.diag_id as discharge_diagnosis, 
    (r.medical_care + r.nursing_care + r.cleanliness + r.food + r.experience) / 5 AS avg_rating
FROM patient_record pr
INNER JOIN hospitalisation h ON h.hosp_id = pr.hosp_id
INNER JOIN admission_diagnosis ad ON h.hosp_id = ad.hosp_id
LEFT JOIN discharge_diagnosis dd ON h.hosp_id = dd.hosp_id
LEFT JOIN rating r ON h.hosp_id = r.hosp_id
ORDER BY pr.AMKA;

# RESPONSE

Right now your query calculates the **average rating per hospitalisation** (per `h.hosp_id`). What you want instead is:

> **average rating across all hospitalisations for each patient (AMKA)**

That means you need to **aggregate over all rows belonging to the same `AMKA`**, not per hospitalisation.

---

## Option 1 — Add a window function (cleanest)

If your MariaDB version supports window functions:

```sql
SELECT 
    pr.AMKA, 
    h.hosp_id, 
    calculate_hospit_cost(h.hosp_id) AS cost, 
    ad.diag_id AS admission_diagnosis, 
    dd.diag_id AS discharge_diagnosis, 
    (r.medical_care + r.nursing_care + r.cleanliness + r.food + r.experience) / 5 AS avg_rating,
    
    AVG((r.medical_care + r.nursing_care + r.cleanliness + r.food + r.experience) / 5)
        OVER (PARTITION BY pr.AMKA) AS avg_rating_all_hospitalisations

FROM patient_record pr
INNER JOIN hospitalisation h ON h.hosp_id = pr.hosp_id
INNER JOIN admission_diagnosis ad ON h.hosp_id = ad.hosp_id
LEFT JOIN discharge_diagnosis dd ON h.hosp_id = dd.hosp_id
LEFT JOIN rating r ON h.hosp_id = r.hosp_id
ORDER BY pr.AMKA;
```

### Why this works

* `PARTITION BY pr.AMKA` groups rows logically per patient
* You still keep **one row per hospitalisation**, but add a column with the **overall average**

---

## Option 2 — Use a subquery (more portable)

If window functions aren’t available:

```sql
SELECT 
    pr.AMKA, 
    h.hosp_id, 
    calculate_hospit_cost(h.hosp_id) AS cost, 
    ad.diag_id AS admission_diagnosis, 
    dd.diag_id AS discharge_diagnosis, 
    (r.medical_care + r.nursing_care + r.cleanliness + r.food + r.experience) / 5 AS avg_rating,
    
    (
        SELECT AVG((r2.medical_care + r2.nursing_care + r2.cleanliness + r2.food + r2.experience) / 5)
        FROM patient_record pr2
        JOIN hospitalisation h2 ON h2.hosp_id = pr2.hosp_id
        LEFT JOIN rating r2 ON h2.hosp_id = r2.hosp_id
        WHERE pr2.AMKA = pr.AMKA
    ) AS avg_rating_all_hospitalisations

FROM patient_record pr
INNER JOIN hospitalisation h ON h.hosp_id = pr.hosp_id
INNER JOIN admission_diagnosis ad ON h.hosp_id = ad.hosp_id
LEFT JOIN discharge_diagnosis dd ON h.hosp_id = dd.hosp_id
LEFT JOIN rating r ON h.hosp_id = r.hosp_id
ORDER BY pr.AMKA;
```

---

## Subtle issue to be aware of

Your joins can **duplicate rows** if:

* A hospitalisation has multiple diagnoses
* A hospitalisation has multiple ratings (or none)

This can distort averages.

If that’s possible, you may want to:

* Aggregate ratings **per hospitalisation first**, then
* Aggregate per patient

---

If you want, I can rewrite this into a **fully normalized, duplication-safe version**—that’s usually what professors/examiners are actually looking for.

