# QUERY

We want to model a hospital database with mySQL. We need to implement triggers such that no staff (that it: doctors, nurses and administrative staff) may be assigned to two consecutive shifts

# RESPONSE

To enforce the rule *“no staff member may be assigned to two consecutive shifts”* in a MySQL hospital database, you can use a **trigger** that checks shift assignments before inserting or updating records.

---

## 🧱 Assumed Schema

Let’s assume a simple table for shift assignments:

```sql
CREATE TABLE staff_shifts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    staff_id INT NOT NULL,
    shift_date DATE NOT NULL,
    shift_type ENUM('morning', 'afternoon', 'night') NOT NULL
);
```

We’ll treat shifts in this order:

```
morning → afternoon → night → next day morning → ...
```

---

## ⚙️ Trigger Logic

We need to prevent:

* A staff member from being assigned to a shift **immediately after their previous one**
* Example violations:

  * morning → afternoon (same day)
  * afternoon → night (same day)
  * night → next day morning

---

## 🚫 BEFORE INSERT Trigger

```sql
DELIMITER $$

CREATE TRIGGER prevent_consecutive_shifts
BEFORE INSERT ON staff_shifts
FOR EACH ROW
BEGIN
    DECLARE prev_shift_type VARCHAR(20);
    DECLARE prev_shift_date DATE;

    -- Get the most recent shift for this staff member
    SELECT shift_type, shift_date
    INTO prev_shift_type, prev_shift_date
    FROM staff_shifts
    WHERE staff_id = NEW.staff_id
    ORDER BY shift_date DESC,
             FIELD(shift_type, 'morning', 'afternoon', 'night') DESC
    LIMIT 1;

    -- Check for consecutive shifts
    IF prev_shift_type IS NOT NULL THEN

        -- Case 1: Same day consecutive shifts
        IF prev_shift_date = NEW.shift_date THEN
            IF (prev_shift_type = 'morning' AND NEW.shift_type = 'afternoon') OR
               (prev_shift_type = 'afternoon' AND NEW.shift_type = 'night') THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cannot assign consecutive shifts on the same day';
            END IF;
        END IF;

        -- Case 2: Night → next day morning
        IF prev_shift_type = 'night' AND
           prev_shift_date = DATE_SUB(NEW.shift_date, INTERVAL 1 DAY) AND
           NEW.shift_type = 'morning' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot assign night shift followed by next day morning shift';
        END IF;

    END IF;
END$$

DELIMITER ;
```

---

## 🔄 BEFORE UPDATE Trigger (Recommended)

To also enforce this rule when modifying records:

```sql
DELIMITER $$

CREATE TRIGGER prevent_consecutive_shifts_update
BEFORE UPDATE ON staff_shifts
FOR EACH ROW
BEGIN
    -- Similar logic as above, but exclude the current row (OLD.id)
    DECLARE prev_shift_type VARCHAR(20);
    DECLARE prev_shift_date DATE;

    SELECT shift_type, shift_date
    INTO prev_shift_type, prev_shift_date
    FROM staff_shifts
    WHERE staff_id = NEW.staff_id
      AND id != OLD.id
    ORDER BY shift_date DESC,
             FIELD(shift_type, 'morning', 'afternoon', 'night') DESC
    LIMIT 1;

    IF prev_shift_type IS NOT NULL THEN

        IF prev_shift_date = NEW.shift_date THEN
            IF (prev_shift_type = 'morning' AND NEW.shift_type = 'afternoon') OR
               (prev_shift_type = 'afternoon' AND NEW.shift_type = 'night') THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cannot assign consecutive shifts on the same day';
            END IF;
        END IF;

        IF prev_shift_type = 'night' AND
           prev_shift_date = DATE_SUB(NEW.shift_date, INTERVAL 1 DAY) AND
           NEW.shift_type = 'morning' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot assign night shift followed by next day morning shift';
        END IF;

    END IF;
END$$

DELIMITER ;
```

---

## ⚠️ Notes & Improvements

* This assumes **3 fixed shifts per day**. If your hospital has different shift structures, adjust accordingly.
* For stricter validation, you could:

  * Check **both previous and next shifts** (not just the latest one)
  * Normalize shifts into numeric order instead of ENUM
* You may also want a **UNIQUE constraint** to prevent duplicate assignments:

  ```sql
  UNIQUE(staff_id, shift_date, shift_type)
  ```

---

## 💡 Alternative (More Robust Design)

Instead of ENUM, create a `shifts` table with a numeric order:

```sql
shift_order: 1 = morning, 2 = afternoon, 3 = night
```

Then your trigger logic becomes simpler (difference = 1 ⇒ consecutive).

---

If you want, I can help you redesign the full hospital schema (staff, departments, scheduling, etc.) in a more scalable way.
