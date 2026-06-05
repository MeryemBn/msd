-- SOS requests core table
CREATE TABLE sos_requests (
    id                   UUID         PRIMARY KEY,
    patient_id           BIGINT       NOT NULL,
    professional_id      BIGINT,
    service_type         VARCHAR(50)  NOT NULL,
    ambulance_type       VARCHAR(50),
    specialty            VARCHAR(100),
    intervention_mode    VARCHAR(50)  NOT NULL,
    appointment_datetime TIMESTAMP,
    payment_method       VARCHAR(50)  NOT NULL,
    base_price           DECIMAL(12,2),
    final_price          DECIMAL(12,2),
    status               VARCHAR(30)  NOT NULL,
    created_at           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_sos_request_patient       FOREIGN KEY (patient_id)      REFERENCES user_profiles(id),
    CONSTRAINT fk_sos_request_professional  FOREIGN KEY (professional_id) REFERENCES user_profiles(id)
);

-- Separate location table as per schema
CREATE TABLE location_details (
    id           UUID         PRIMARY KEY,
    request_id   UUID         NOT NULL,
    address      VARCHAR(500) NOT NULL,
    apartment    VARCHAR(100),
    floor        VARCHAR(50),
    entry_code   VARCHAR(50),
    latitude     DOUBLE PRECISION NOT NULL,
    longitude    DOUBLE PRECISION NOT NULL,

    CONSTRAINT fk_location_sos_request FOREIGN KEY (request_id) REFERENCES sos_requests(id)
);

-- Full audit trail of status changes
CREATE TABLE request_status_history (
    id          UUID      PRIMARY KEY,
    request_id  UUID      NOT NULL,
    changed_by  BIGINT    NOT NULL,
    status      VARCHAR(30) NOT NULL,
    reason      TEXT,
    changed_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_status_history_request     FOREIGN KEY (request_id) REFERENCES sos_requests(id),
    CONSTRAINT fk_status_history_changed_by  FOREIGN KEY (changed_by) REFERENCES user_profiles(id)
);

-- Patient medical records (one row per medical entry, a patient can have multiple)
CREATE TABLE patient_medical_records (
    id            BIGSERIAL    PRIMARY KEY,
    patient_id    BIGINT       NOT NULL,
    type          TEXT         NOT NULL,
    description   TEXT         NOT NULL,
    severity      VARCHAR(50),
    diagnosed_at  DATE,

    CONSTRAINT fk_medical_record_patient FOREIGN KEY (patient_id) REFERENCES user_profiles(id)
);
