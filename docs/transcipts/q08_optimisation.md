# QUERRY

Optimise the following MySQL query code:
WITH dept_day AS (
    SELECT DISTINCT ds.dept_name, s.day
    FROM dept_shift ds
    INNER JOIN shift s ON ds.shift_id = s.shift_id
    WHERE s.status = 1
)
SELECT
    hlpr_doc.dept_name,
    hlpr_doc.day,
    hlpr_doc.doctors_not_on_call,
    hlpr_nurse.nurses_not_on_call,
    hlpr_admin.admin_staff_not_on_call
FROM (
    SELECT 
        dd.dept_name,
        dd.day,
        d.AMKA AS doctors_not_on_call
        -- count(d.AMKA) AS doctors_not_on_call
    FROM dept_day dd
    CROSS JOIN doctor d
    WHERE NOT EXISTS (
            SELECT *
            FROM doctor_shift dcs
            INNER JOIN dept_shift ds ON dcs.shift_id = ds.shift_id
            INNER JOIN shift s ON ds.shift_id = s.shift_id
            WHERE dcs.AMKA = d.AMKA
            AND ds.dept_name = dd.dept_name
            AND s.day = dd.day
            AND s.status = 1
        )
    -- GROUP BY dd.dept_name, dd.day
    ) AS hlpr_doc
INNER JOIN (
    SELECT 
        dd.dept_name,
        dd.day,
        d.AMKA AS nurses_not_on_call
        -- count(d.AMKA) AS nurses_not_on_call
    FROM dept_day dd
    CROSS JOIN nurse d
    WHERE NOT EXISTS (
            SELECT *
            FROM nurse_shift dcs
            INNER JOIN dept_shift ds ON dcs.shift_id = ds.shift_id
            INNER JOIN shift s ON ds.shift_id = s.shift_id
            WHERE dcs.AMKA = d.AMKA
            AND ds.dept_name = dd.dept_name
            AND s.day = dd.day
            AND s.status = 1
        )
    -- GROUP BY dd.dept_name, dd.day
    ) AS hlpr_nurse 
ON hlpr_doc.dept_name = hlpr_nurse.dept_name 
AND hlpr_doc.day = hlpr_nurse.day
INNER JOIN (
    SELECT 
        dd.dept_name,
        dd.day,
        d.AMKA AS admin_staff_not_on_call
        -- count(d.AMKA) AS admin_staff_not_on_call
    FROM dept_day dd
    CROSS JOIN administrative_staff d
    WHERE NOT EXISTS (
            SELECT *
            FROM admin_shift dcs
            INNER JOIN dept_shift ds ON dcs.shift_id = ds.shift_id
            INNER JOIN shift s ON ds.shift_id = s.shift_id
            WHERE dcs.AMKA = d.AMKA
            AND ds.dept_name = dd.dept_name
            AND s.day = dd.day
            AND s.status = 1
        )
    -- GROUP BY dd.dept_name, dd.day
    ) AS hlpr_admin 
ON hlpr_doc.dept_name = hlpr_admin.dept_name 
AND hlpr_doc.day = hlpr_admin.day

# RESPONSE

Right now this query is doing **a lot more work than necessary**:

* You repeat the same logic **3 times** (doctor / nurse / admin)
* Each block does a **CROSS JOIN + NOT EXISTS**
* Then you **join the results back together**, which explodes row counts
* You’re also joining on `dept_name` (string) instead of an ID → slower

Let’s clean this up properly.

---

# 🔴 Core inefficiency

You are generating:

```
(dept_day × doctors)
(dept_day × nurses)
(dept_day × admin)
```

…three separate times, and then joining them.

👉 That’s **redundant and expensive**

---

# ✅ Optimized approach (single pass per role, then join aggregates)

Instead of returning individual AMKA rows and joining them, compute **counts per role first**, then join those small aggregated results.

---

## ✅ Optimized query

```sql id="opt1qz"
WITH dept_day AS (
    SELECT DISTINCT ds.dept_id, ds.dept_name, s.day
    FROM dept_shift ds
    INNER JOIN shift s ON ds.shift_id = s.shift_id
    WHERE s.status = 1
),

doctor_counts AS (
    SELECT 
        dd.dept_id,
        dd.day,
        COUNT(*) AS doctors_not_on_call
    FROM dept_day dd
    CROSS JOIN doctor d
    WHERE NOT EXISTS (
        SELECT 1
        FROM doctor_shift dcs
        INNER JOIN dept_shift ds ON dcs.shift_id = ds.shift_id
        INNER JOIN shift s ON ds.shift_id = s.shift_id
        WHERE dcs.AMKA = d.AMKA
          AND ds.dept_id = dd.dept_id
          AND s.day = dd.day
          AND s.status = 1
    )
    GROUP BY dd.dept_id, dd.day
),

nurse_counts AS (
    SELECT 
        dd.dept_id,
        dd.day,
        COUNT(*) AS nurses_not_on_call
    FROM dept_day dd
    CROSS JOIN nurse n
    WHERE NOT EXISTS (
        SELECT 1
        FROM nurse_shift ns
        INNER JOIN dept_shift ds ON ns.shift_id = ds.shift_id
        INNER JOIN shift s ON ds.shift_id = s.shift_id
        WHERE ns.AMKA = n.AMKA
          AND ds.dept_id = dd.dept_id
          AND s.day = dd.day
          AND s.status = 1
    )
    GROUP BY dd.dept_id, dd.day
),

admin_counts AS (
    SELECT 
        dd.dept_id,
        dd.day,
        COUNT(*) AS admin_staff_not_on_call
    FROM dept_day dd
    CROSS JOIN administrative_staff a
    WHERE NOT EXISTS (
        SELECT 1
        FROM admin_shift ads
        INNER JOIN dept_shift ds ON ads.shift_id = ds.shift_id
        INNER JOIN shift s ON ds.shift_id = s.shift_id
        WHERE ads.AMKA = a.AMKA
          AND ds.dept_id = dd.dept_id
          AND s.day = dd.day
          AND s.status = 1
    )
    GROUP BY dd.dept_id, dd.day
)

SELECT 
    dd.dept_name,
    dd.day,
    dc.doctors_not_on_call,
    nc.nurses_not_on_call,
    ac.admin_staff_not_on_call
FROM dept_day dd
LEFT JOIN doctor_counts dc ON dd.dept_id = dc.dept_id AND dd.day = dc.day
LEFT JOIN nurse_counts nc  ON dd.dept_id = nc.dept_id AND dd.day = nc.day
LEFT JOIN admin_counts ac  ON dd.dept_id = ac.dept_id AND dd.day = ac.day;
```

---

# 🧠 Why this is faster

### 1. No row explosion

You no longer join:

```
doctor × nurse × admin
```

(which is huge)

---

### 2. Aggregation early

Each role is reduced to:

```
(dept_id, day) → COUNT
```

before joining

---

### 3. Uses `dept_id` instead of `dept_name`

String joins are slower and less reliable

---

### 4. `SELECT 1` instead of `SELECT *`

Slight optimization in `NOT EXISTS`

---

# 🚀 Further optimization (big datasets)

If your tables are large, indexes matter a lot:

```sql id="idx1"
doctor_shift(AMKA, shift_id)
nurse_shift(AMKA, shift_id)
admin_shift(AMKA, shift_id)

dept_shift(shift_id, dept_id)

shift(shift_id, day, status)
```

---

# 💡 Even better (advanced idea)

If performance becomes critical, you can:

* Precompute **(dept_id, day, AMKA assigned)** into a temporary table
* Then anti-join once per role

That avoids repeating the same joins 3 times.

---

# ⚠️ Final takeaway

Your original query was slow because:

* repeated logic ×3
* late aggregation
* joining large intermediate results

The fix is always:

> **aggregate early, join small**

---

If you want, I can push this one step further and remove the `CROSS JOIN` entirely (that’s the next level of optimization).

# QUERY

dept_id doesn't exist. The table's primary key is dept_name. We want the staff's AMKA, not their count.

# RESPONSE

Got it—and that changes the optimization strategy quite a bit.

Since you want **actual AMKA values (not counts)**, you *cannot aggregate early*. Also, since `dept_name` is your PK, we’ll stick with it (even though it’s not ideal performance-wise).

---

# 🔴 What’s inefficient in your current query

1. You repeat the same logic **3 times**
2. You **join the three result sets**, which creates:

   ```
   doctor × nurse × admin combinations
   ```

   → massive row explosion (this is the real killer)
3. You recompute the same `(dept_name, day)` logic repeatedly

---

# ✅ Better approach: normalize roles instead of joining them

Instead of producing:

```
one row with doctor + nurse + admin columns
```

👉 Produce:

```
one row per (dept, day, role, AMKA)
```

This avoids the combinatorial explosion entirely.

---

## ✅ Optimized query (clean + fast)

```sql id="optflat1"
WITH dept_day AS (
    SELECT DISTINCT ds.dept_name, s.day
    FROM dept_shift ds
    INNER JOIN shift s ON ds.shift_id = s.shift_id
    WHERE s.status = 1
),

staff_not_on_call AS (

    -- Doctors
    SELECT 
        dd.dept_name,
        dd.day,
        'doctor' AS role,
        d.AMKA
    FROM dept_day dd
    CROSS JOIN doctor d
    WHERE NOT EXISTS (
        SELECT 1
        FROM doctor_shift dcs
        INNER JOIN dept_shift ds ON dcs.shift_id = ds.shift_id
        INNER JOIN shift s ON ds.shift_id = s.shift_id
        WHERE dcs.AMKA = d.AMKA
          AND ds.dept_name = dd.dept_name
          AND s.day = dd.day
          AND s.status = 1
    )

    UNION ALL

    -- Nurses
    SELECT 
        dd.dept_name,
        dd.day,
        'nurse' AS role,
        n.AMKA
    FROM dept_day dd
    CROSS JOIN nurse n
    WHERE NOT EXISTS (
        SELECT 1
        FROM nurse_shift ns
        INNER JOIN dept_shift ds ON ns.shift_id = ds.shift_id
        INNER JOIN shift s ON ds.shift_id = s.shift_id
        WHERE ns.AMKA = n.AMKA
          AND ds.dept_name = dd.dept_name
          AND s.day = dd.day
          AND s.status = 1
    )

    UNION ALL

    -- Admin
    SELECT 
        dd.dept_name,
        dd.day,
        'admin' AS role,
        a.AMKA
    FROM dept_day dd
    CROSS JOIN administrative_staff a
    WHERE NOT EXISTS (
        SELECT 1
        FROM admin_shift ads
        INNER JOIN dept_shift ds ON ads.shift_id = ds.shift_id
        INNER JOIN shift s ON ds.shift_id = s.shift_id
        WHERE ads.AMKA = a.AMKA
          AND ds.dept_name = dd.dept_name
          AND s.day = dd.day
          AND s.status = 1
    )
)

SELECT *
FROM staff_not_on_call
ORDER BY dept_name, day, role, AMKA;
```

---

# 🧠 Why this is better

### ✅ No Cartesian explosion across roles

You **removed this completely**:

```sql
doctor × nurse × admin
```

---

### ✅ Logic written once per role, not joined

Each role is independent → combined via `UNION ALL`

---

### ✅ Output is more usable

Instead of:

```
doctor | nurse | admin  (wide, sparse, duplicated)
```

You get:

```
dept | day | role | AMKA  (normalized, clean)
```

---

# 💡 If you REALLY need one row with 3 columns

Then you’d have to aggregate back (e.g. `GROUP_CONCAT`), but that’s usually worse:

```sql id="pivot1"
GROUP_CONCAT(CASE WHEN role='doctor' THEN AMKA END)
```

Only do this if your application strictly requires it.

---

# 🚀 Indexes (critical for performance)

```sql id="idx2"
doctor_shift(AMKA, shift_id)
nurse_shift(AMKA, shift_id)
admin_shift(AMKA, shift_id)

dept_shift(shift_id, dept_name)

shift(shift_id, day, status)
```

---

# ⚠️ Final takeaway

Your original design was slow because:

* you tried to **merge 3 independent sets horizontally**
* SQL performs much better when you **stack vertically (`UNION ALL`)**

---

If you want, I can show you an even more advanced version that:

* eliminates the `CROSS JOIN`
* and runs significantly faster on large datasets (millions of rows)
