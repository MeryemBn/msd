-- 1. Réparation des anciennes demandes pour éviter l'affichage "0 MAD"
-- On récupère la valeur par défaut cohérente selon le service pour les données qui auraient été perdues lors du merge
UPDATE sos_requests SET price = 350.00 WHERE price IS NULL AND service_type = 'doctor';
UPDATE sos_requests SET price = 150.00 WHERE price IS NULL AND service_type = 'nurse';
UPDATE sos_requests SET price = 600.00 WHERE price IS NULL AND service_type = 'ambulance';
UPDATE sos_requests SET price = 250.00 WHERE price IS NULL AND service_type = 'teleconsultation';
UPDATE sos_requests SET price = 150.00 WHERE price IS NULL; -- Sécurité finale

-- 2. Initialisation du Market Control Center ( Cockpit Admin )
-- On nettoie d'abord pour éviter les doublons
DELETE FROM pricing_limits;

-- On pré-remplit les unités de contrôle pour que l'admin n'ait qu'à réguler
INSERT INTO pricing_limits (service_type, specialty, ambulance_type, intervention_mode, min_price, max_price)
VALUES
('DOCTOR', NULL, NULL, 'SOS_URGENCY', 300, 1500),
('DOCTOR', NULL, NULL, 'APPOINTMENT', 200, 1200),
('TELECONSULTATION', NULL, NULL, 'APPOINTMENT', 150, 800),
('NURSE', NULL, NULL, 'SOS_URGENCY', 150, 600),
('NURSE', NULL, NULL, 'APPOINTMENT', 100, 500),
('AMBULANCE', NULL, 'A', 'SOS_URGENCY', 400, 2000),
('AMBULANCE', NULL, 'B', 'SOS_URGENCY', 600, 3500),
('AMBULANCE', NULL, 'C', 'SOS_URGENCY', 800, 5000);
