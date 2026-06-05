-- Bornes tarifaires fixées par l'Admin pour éviter les abus
CREATE TABLE pricing_limits (
    id BIGSERIAL PRIMARY KEY,
    service_type VARCHAR(50) NOT NULL,
    specialty VARCHAR(100),
    ambulance_type VARCHAR(50),
    intervention_mode VARCHAR(50),
    min_price DECIMAL(12, 2) NOT NULL,
    max_price DECIMAL(12, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tarifs fixés par chaque professionnel
CREATE TABLE professional_pricing (
    id BIGSERIAL PRIMARY KEY,
    professional_id BIGINT NOT NULL,
    service_type VARCHAR(50) NOT NULL,
    specialty VARCHAR(100),
    ambulance_type VARCHAR(50),
    intervention_mode VARCHAR(50),
    price DECIMAL(12, 2) NOT NULL,
    extra_km_price DECIMAL(12, 2) DEFAULT 0, -- Frais de déplacement par km
    km_radius_included INTEGER DEFAULT 0,    -- Rayon de gratuité
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pro_pricing_user FOREIGN KEY (professional_id) REFERENCES user_profiles(id) ON DELETE CASCADE
);

-- Historique des prix pour ne pas impacter les missions en cours
CREATE TABLE pricing_history (
    id BIGSERIAL PRIMARY KEY,
    professional_id BIGINT NOT NULL,
    service_type VARCHAR(50) NOT NULL,
    specialty VARCHAR(100),
    ambulance_type VARCHAR(50),
    intervention_mode VARCHAR(50),
    old_price DECIMAL(12, 2),
    new_price DECIMAL(12, 2) NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_pro_pricing_lookup ON professional_pricing(professional_id, service_type, specialty, ambulance_type, intervention_mode);

-- Unification du prix dans sos_requests
ALTER TABLE sos_requests RENAME COLUMN final_price TO price;
ALTER TABLE sos_requests DROP COLUMN base_price;
