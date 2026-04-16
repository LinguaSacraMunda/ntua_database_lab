# QUERRY

Consider a mySQL database that has an entity worker and a relation supervise, where a worker may be supervised by another worker. The relation is many to one, as one supervisor may supervise multiple workers. We do not allow circular relations, that is, if A supervises B, then B does not supervise A. How would we implement this in code?

# RESPONSE

To implement this in code, we need to model the `Worker` entity and the `Supervise` relation. The `Supervise` relation represents a **many-to-one** relationship, where multiple workers can be supervised by one supervisor (but a worker can have at most one supervisor).

Here’s a step-by-step approach to implementing this:

### 1. Define the `Worker` Table Structure

We'll have a `workers` table where each worker has an ID, a name (or other attributes), and a reference to their supervisor (if they have one).

Here’s how the `workers` table might look:

```sql
CREATE TABLE workers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    supervisor_id INT,
    FOREIGN KEY (supervisor_id) REFERENCES workers(id) ON DELETE SET NULL
);
```

* `id` is the unique identifier for the worker.
* `name` is just an example of an attribute; it can be more detailed depending on your use case.
* `supervisor_id` is a foreign key that refers to the `id` of the supervisor. If `supervisor_id` is `NULL`, the worker has no supervisor.

### 2. Enforce the No-Circular Supervision Rule

To prevent circular relationships (e.g., worker A supervising worker B, and worker B supervising worker A), we need to add a **constraint** or **logic** that checks for these cycles before inserting or updating a supervisor relationship. This can be done in two main ways:

#### Option 1: Use a Recursive Query to Check for Cycles (Application-Level Logic)

Before inserting a new supervisor or updating an existing one, you would need to check if the new supervisor creates a circular dependency. This can be done using a **recursive query** in MySQL.

You could write a query like this to check for a cycle:

```sql
WITH RECURSIVE supervisor_chain AS (
    SELECT id, supervisor_id
    FROM workers
    WHERE id = :worker_id  -- worker trying to be supervised
    UNION ALL
    SELECT w.id, w.supervisor_id
    FROM workers w
    INNER JOIN supervisor_chain sc ON w.id = sc.supervisor_id
)
SELECT 1
FROM supervisor_chain
WHERE id = :supervisor_id;  -- supervisor trying to supervise the worker
```

* The `WITH RECURSIVE` query walks up the chain of supervisors for the worker and checks if the supervisor is already part of the chain.
* If the supervisor is found in the recursive chain, a circular reference exists, and the insertion or update should be rejected.

#### Option 2: Implement Cycle Detection in the Application

Instead of doing the cycle detection in SQL, you could retrieve the full supervisor hierarchy for a worker and check for cycles programmatically (in your application code) before making the update or insert.

### 3. Insert and Update Operations

For inserting or updating a worker's supervisor, you'd use standard SQL `INSERT` or `UPDATE` statements, but before executing them, you need to ensure no cycle is introduced, either via the recursive query mentioned above or through application-level logic.

#### Inserting a New Worker

When inserting a new worker:

```sql
INSERT INTO workers (name, supervisor_id)
VALUES ('John Doe', 2);  -- assuming 2 is the supervisor_id
```

Before performing this insert, make sure the supervisor (`supervisor_id`) does not create a cycle using the recursive query or application logic.

#### Updating a Worker’s Supervisor

To update the supervisor of an existing worker:

```sql
UPDATE workers
SET supervisor_id = 3  -- new supervisor id
WHERE id = 5;  -- id of the worker being updated
```

Again, make sure the new supervisor (`supervisor_id = 3`) does not create a cycle with the worker being updated (`id = 5`) before executing this.

### 4. Code Example (Using an ORM like SQLAlchemy for Python)

If you're using an ORM like SQLAlchemy in Python, you could define the model as follows:

```python
from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class Worker(Base):
    __tablename__ = 'workers'
    
    id = Column(Integer, primary_key=True)
    name = Column(String)
    supervisor_id = Column(Integer, ForeignKey('workers.id', ondelete='SET NULL'))
    
    supervisor = relationship('Worker', remote_side=[id], backref='subordinates')
    
    def __init__(self, name, supervisor=None):
        self.name = name
        self.supervisor = supervisor

    def check_for_circular_supervision(self):
        """Checks if assigning this worker a new supervisor will cause a circular reference."""
        supervisor = self.supervisor
        while supervisor:
            if supervisor == self:
                return True  # Circular supervision found
            supervisor = supervisor.supervisor
        return False
```

* `supervisor_id` is the foreign key pointing to the worker's supervisor.
* The `check_for_circular_supervision` method ensures that a circular supervision relationship isn't created when assigning a supervisor.

### 5. Deleting a Worker

When deleting a worker, the `supervisor_id` of the subordinates should be set to `NULL`, which is handled by the `ON DELETE SET NULL` constraint in the database. This ensures no orphaned supervisor relationships remain.

```sql
DELETE FROM workers WHERE id = 3;
```

This will delete the worker with `id = 3`, and any workers supervised by them will have their `supervisor_id` set to `NULL`.

### Summary

1. **Database Design**: The `workers` table has a `supervisor_id` field, which is a foreign key pointing to the `id` of the supervisor.
2. **Cycle Prevention**: Use a recursive query or application-level logic to detect and prevent circular supervision relationships.
3. **CRUD Operations**: For each `INSERT` or `UPDATE` operation, ensure that a cycle check is performed before applying the change.
4. **ORM Example**: If you're using an ORM, you can define the relationships in code and add a method to check for cycles.

By following these steps, you can implement the worker-supervisor relationship with cycle prevention in your MySQL database.

# QUERRY

Could we implement this using triggers?

# RESPONSE

Yes, you can implement the cycle prevention logic using MySQL **triggers** to automatically detect circular supervision when inserting or updating a `worker`. However, MySQL triggers themselves are limited in their recursive capabilities, so you'd need to implement the cycle check logic through a combination of recursive queries (as we discussed earlier) and the trigger system.

### Here's how you can implement the circular supervision check using MySQL triggers:

### 1. **Table Design**

First, let's define the `workers` table. This will remain the same as previously discussed:

```sql
CREATE TABLE workers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    supervisor_id INT,
    FOREIGN KEY (supervisor_id) REFERENCES workers(id) ON DELETE SET NULL
);
```

### 2. **Trigger to Prevent Circular Supervision**

We need to create a **trigger** that will be fired **before insert** or **before update** of a worker's supervisor to ensure that a cycle isn't introduced.

We can use a **recursive query** inside the trigger to trace the chain of supervision and check if the supervisor already exists in the chain.

### Step-by-Step Implementation:

#### a. **Before Insert Trigger** (for adding a new worker)

This trigger will prevent adding a new worker if the supervisor creates a circular reference.

```sql
DELIMITER $$

CREATE TRIGGER before_worker_insert
BEFORE INSERT ON workers
FOR EACH ROW
BEGIN
    -- Recursive query to check if the supervisor creates a circular reference
    SET @worker_id = NEW.id;
    SET @supervisor_id = NEW.supervisor_id;
    
    -- Check if supervisor creates a cycle
    SET @is_cyclic = 0;
    
    -- Start recursive query to check if a cycle is formed
    RECURSIVE supervisor_check AS (
        SELECT id, supervisor_id
        FROM workers
        WHERE id = @worker_id
        UNION ALL
        SELECT w.id, w.supervisor_id
        FROM workers w
        JOIN supervisor_check sc ON w.id = sc.supervisor_id
    )
    SELECT COUNT(*) INTO @is_cyclic
    FROM supervisor_check
    WHERE id = @supervisor_id;
    
    IF @is_cyclic > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Circular supervision detected. Cannot insert worker with this supervisor.';
    END IF;
END$$

DELIMITER ;
```

* This trigger fires **before inserting** a new worker.
* The trigger uses a **recursive query** (`WITH RECURSIVE`) to traverse the supervisor hierarchy and check if the supervisor appears in the chain.
* If a cycle is detected (`@is_cyclic > 0`), the trigger raises a `SIGNAL SQLSTATE '45000'` error, which prevents the insertion and provides an error message.

#### b. **Before Update Trigger** (for changing the supervisor of an existing worker)

This trigger ensures that when updating a worker's supervisor, we also check for circular supervision.

```sql
DELIMITER $$

CREATE TRIGGER before_worker_update
BEFORE UPDATE ON workers
FOR EACH ROW
BEGIN
    -- Only check if supervisor_id is being updated
    IF OLD.supervisor_id != NEW.supervisor_id THEN
        SET @worker_id = NEW.id;
        SET @supervisor_id = NEW.supervisor_id;
        
        -- Check if supervisor creates a cycle
        SET @is_cyclic = 0;
        
        -- Start recursive query to check if a cycle is formed
        RECURSIVE supervisor_check AS (
            SELECT id, supervisor_id
            FROM workers
            WHERE id = @worker_id
            UNION ALL
            SELECT w.id, w.supervisor_id
            FROM workers w
            JOIN supervisor_check sc ON w.id = sc.supervisor_id
        )
        SELECT COUNT(*) INTO @is_cyclic
        FROM supervisor_check
        WHERE id = @supervisor_id;
        
        IF @is_cyclic > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Circular supervision detected. Cannot update worker with this supervisor.';
        END IF;
    END IF;
END$$

DELIMITER ;
```

* This trigger fires **before updating** a worker.
* It checks if the supervisor (`supervisor_id`) is being changed.
* If so, it uses the same recursive logic to check if the new supervisor would create a circular reference.
* If a cycle is detected, it raises an error, preventing the update.

### 3. **Handling Deletion**

Since we have the `ON DELETE SET NULL` foreign key constraint for the `supervisor_id`, MySQL will automatically set the `supervisor_id` of workers to `NULL` when their supervisor is deleted. Therefore, no additional trigger is needed for the deletion logic, as MySQL will handle it for you.

### 4. **Testing the Triggers**

Let’s test the triggers to ensure they work as expected:

#### a. **Insert Worker (Without Cycle)**

```sql
INSERT INTO workers (name, supervisor_id) VALUES ('John', NULL);
-- Successfully inserts a worker without a supervisor
```

#### b. **Insert Worker (With Valid Supervisor)**

```sql
INSERT INTO workers (name, supervisor_id) VALUES ('Alice', 1);
-- Successfully inserts Alice with worker 1 as the supervisor
```

#### c. **Insert Worker (With Circular Supervision)**

```sql
INSERT INTO workers (name, supervisor_id) VALUES ('Bob', 2);
-- If worker 2 supervises Bob and Bob tries to supervise 2, this will raise an error:
-- ERROR 1644 (45000): Circular supervision detected. Cannot insert worker with this supervisor.
```

#### d. **Update Worker (Without Cycle)**

```sql
UPDATE workers SET supervisor_id = 3 WHERE id = 4;
-- Successfully updates the supervisor without a cycle
```

#### e. **Update Worker (With Circular Supervision)**

```sql
UPDATE workers SET supervisor_id = 1 WHERE id = 4;
-- This will raise an error if it creates a circular relationship
-- ERROR 1644 (45000): Circular supervision detected. Cannot update worker with this supervisor.
```

### Summary

* We implemented **MySQL triggers** to prevent circular supervision by using **recursive queries** within the triggers.
* We created two triggers: one for the `INSERT` operation and one for the `UPDATE` operation.
* The triggers check if assigning or updating a supervisor creates a cycle and raise an error if a cycle is detected.

This method ensures that the circular supervision rule is enforced directly at the database level, without requiring application logic to perform the cycle check.

