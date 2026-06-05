-- Table principale des médicaments
CREATE TABLE medication (
    id UUID PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    medication_name VARCHAR(255) NOT NULL,
    dosage VARCHAR(100),
    instructions TEXT,
    start_date DATE NOT NULL,
    duration_in_days INT NOT NULL,
    initial_stock INT NOT NULL,
    current_stock INT NOT NULL,
    low_stock_threshold INT NOT NULL
);

-- Table pour les horaires de prise
CREATE TABLE medication_intake_times (
    medication_id UUID NOT NULL,
    intake_time TIME NOT NULL,
    CONSTRAINT fk_med_times FOREIGN KEY (medication_id) REFERENCES medication(id) ON DELETE CASCADE
);

-- Table pour le suivi des prises (Journal)
CREATE TABLE intake_log (
    id UUID PRIMARY KEY,
    medication_id UUID NOT NULL,
    planned_date_time TIMESTAMP NOT NULL,
    actual_taken_date_time TIMESTAMP,
    status VARCHAR(20) NOT NULL,
    CONSTRAINT fk_med_logs FOREIGN KEY (medication_id) REFERENCES medication(id) ON DELETE CASCADE
);