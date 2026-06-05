-- Heure de créneau personnalisable par ligne (défaut = horaire du traitement au même index).

ALTER TABLE intake_log ADD COLUMN slot_time TIME;

WITH ordered AS (
    SELECT mit.medication_id,
           mit.intake_time,
           ROW_NUMBER() OVER (PARTITION BY mit.medication_id ORDER BY mit.intake_time) - 1 AS idx
    FROM medication_intake_times mit
)
UPDATE intake_log il
SET slot_time = o.intake_time
FROM ordered o
WHERE il.medication_id = o.medication_id
  AND il.day_slot_index = o.idx;

UPDATE intake_log
SET slot_time = time '12:00:00'
WHERE slot_time IS NULL;

ALTER TABLE intake_log ALTER COLUMN slot_time SET NOT NULL;
