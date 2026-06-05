-- Pro-only fields: null for patients, populated for professionals
ALTER TABLE user_profiles ADD COLUMN service_type VARCHAR(100);
ALTER TABLE user_profiles ADD COLUMN specialty    VARCHAR(100);
