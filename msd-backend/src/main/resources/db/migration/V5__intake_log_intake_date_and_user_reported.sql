-- Remplace planned_date_time par intake_date + day_slot_index ; réintroduit actual_taken_date_time (prise déclarée par l'utilisateur).

ALTER TABLE intake_log ADD COLUMN IF NOT EXISTS actual_taken_date_time TIMESTAMP;

ALTER TABLE intake_log ADD COLUMN intake_date DATE;
UPDATE intake_log SET intake_date = (planned_date_time)::date WHERE intake_date IS NULL;
ALTER TABLE intake_log ALTER COLUMN intake_date SET NOT NULL;

ALTER TABLE intake_log ADD COLUMN day_slot_index INTEGER NOT NULL DEFAULT 0;

WITH ranked AS (
    SELECT id,
           (ROW_NUMBER() OVER (PARTITION BY medication_id, ((planned_date_time)::date) ORDER BY planned_date_time) - 1)::integer AS idx
    FROM intake_log
)
UPDATE intake_log l
SET day_slot_index = r.idx
FROM ranked r
WHERE l.id = r.id;

ALTER TABLE intake_log DROP COLUMN planned_date_time;
