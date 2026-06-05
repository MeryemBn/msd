CREATE TABLE professional_info (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    service_type VARCHAR(100), -- Autorise NULL pour le setup initial
    specialty VARCHAR(100),
    ambulance_type VARCHAR(100),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    verified BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_professional_info_user FOREIGN KEY (user_id) REFERENCES user_profiles(id) ON DELETE CASCADE
);

-- Migrer les données existantes de user_profiles vers professional_info
INSERT INTO professional_info (user_id, service_type, specialty, verified, is_available)
SELECT id, service_type, specialty, false, false
FROM user_profiles
WHERE service_type IS NOT NULL;

-- Supprimer les anciennes colonnes de user_profiles
ALTER TABLE user_profiles DROP COLUMN service_type;
ALTER TABLE user_profiles DROP COLUMN specialty;
