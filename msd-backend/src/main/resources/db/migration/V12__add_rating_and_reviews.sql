-- Ajout des colonnes de notation à professional_info
ALTER TABLE professional_info ADD COLUMN average_rating DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE professional_info ADD COLUMN total_reviews INTEGER DEFAULT 0;

-- Création de la table des avis
CREATE TABLE reviews (
    id BIGSERIAL PRIMARY KEY,
    sos_request_id UUID NOT NULL UNIQUE,
    patient_id BIGINT NOT NULL,
    professional_id BIGINT NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_sos_request FOREIGN KEY (sos_request_id) REFERENCES sos_requests (id),
    CONSTRAINT fk_review_patient FOREIGN KEY (patient_id) REFERENCES user_profiles (id),
    CONSTRAINT fk_review_professional FOREIGN KEY (professional_id) REFERENCES user_profiles (id)
);

CREATE INDEX idx_reviews_professional ON reviews(professional_id);
