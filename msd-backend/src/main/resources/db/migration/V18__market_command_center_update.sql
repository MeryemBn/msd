-- 1. Réparer les anciennes demandes restées à NULL pour éviter le 0 MAD
UPDATE sos_requests SET price = 350.00 WHERE price IS NULL AND service_type = 'doctor';
UPDATE sos_requests SET price = 150.00 WHERE price IS NULL AND service_type = 'nurse';
UPDATE sos_requests SET price = 600.00 WHERE price IS NULL AND service_type = 'ambulance';
UPDATE sos_requests SET price = 250.00 WHERE price IS NULL AND service_type = 'teleconsultation';
UPDATE sos_requests SET price = 200.00 WHERE price IS NULL;

-- 2. Réinitialisation des limites avec les clés exactes des Enums Flutter
DELETE FROM pricing_limits;

-- Médecins
INSERT INTO pricing_limits (service_type, specialty, ambulance_type, intervention_mode, min_price, max_price)
VALUES
('doctor', NULL, NULL, 'sos_urgency', 300, 1500),
('doctor', NULL, NULL, 'appointment', 200, 1200);

-- Téléconsultation
INSERT INTO pricing_limits (service_type, specialty, ambulance_type, intervention_mode, min_price, max_price)
VALUES
('teleconsultation', NULL, NULL, 'appointment', 150, 800);

-- Infirmiers
INSERT INTO pricing_limits (service_type, specialty, ambulance_type, intervention_mode, min_price, max_price)
VALUES
('nurse', NULL, NULL, 'sos_urgency', 150, 600),
('nurse', NULL, NULL, 'appointment', 100, 500);

-- AMBULANCES (Clés exactes mapping AmbulanceType Enum)
INSERT INTO pricing_limits (service_type, specialty, ambulance_type, intervention_mode, min_price, max_price)
VALUES
('ambulance', NULL, 'AMBULANCE_MEDICALISEE_SMUR', 'sos_urgency', 800, 5000),
('ambulance', NULL, 'AMBULANCE_REANIMATION', 'sos_urgency', 600, 3500),
('ambulance', NULL, 'AMBULANCE_SANITAIRE', 'sos_urgency', 400, 2500),
('ambulance', NULL, 'VSL', 'sos_urgency', 200, 1500);
