-- Add profile completion flag to user_profiles
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS is_profile_complete BOOLEAN DEFAULT FALSE;

-- Update professional_info: replace verified boolean with status_validation enum-like string
ALTER TABLE professional_info ADD COLUMN IF NOT EXISTS status_validation VARCHAR(50) DEFAULT 'PENDING';

-- Migrate existing verified data if any
UPDATE professional_info SET status_validation = 'VALIDATED' WHERE verified = TRUE;
UPDATE professional_info SET status_validation = 'PENDING' WHERE verified = FALSE OR verified IS NULL;

-- Now safe to drop verified column
ALTER TABLE professional_info DROP COLUMN IF EXISTS verified;

-- Create professional_documents table for uploads
CREATE TABLE IF NOT EXISTS professional_documents (
    id BIGSERIAL PRIMARY KEY,
    professional_info_id BIGINT NOT NULL,
    document_type VARCHAR(100) NOT NULL,
    file_path TEXT NOT NULL,
    file_name VARCHAR(255),
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pro_info_docs FOREIGN KEY (professional_info_id) REFERENCES professional_info(id) ON DELETE CASCADE
);
