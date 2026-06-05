CREATE TABLE user_profiles (
    id              BIGSERIAL       PRIMARY KEY,
    keycloak_id     VARCHAR(255)    NOT NULL,
    first_name      VARCHAR(100),
    last_name       VARCHAR(100),
    phone_number    VARCHAR(20),
    address         VARCHAR(500),
    city            VARCHAR(100),
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_user_profiles_keycloak_id UNIQUE (keycloak_id)
);