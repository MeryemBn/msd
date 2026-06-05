-- Ajout du compteur de missions terminées à professional_info
ALTER TABLE professional_info ADD COLUMN completed_missions_count INTEGER DEFAULT 0;
