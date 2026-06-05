-- Rattrapage : Mettre à jour le compteur de missions terminées pour tous les pros
UPDATE professional_info p
SET completed_missions_count = (
    SELECT count(*)
    FROM sos_requests s
    WHERE s.professional_id = p.user_id
    AND s.status = 'completed'
);

-- Sécurité : S'assurer que les nouveaux profils ont 0 par défaut et non NULL
ALTER TABLE professional_info ALTER COLUMN completed_missions_count SET DEFAULT 0;
UPDATE professional_info SET completed_missions_count = 0 WHERE completed_missions_count IS NULL;
