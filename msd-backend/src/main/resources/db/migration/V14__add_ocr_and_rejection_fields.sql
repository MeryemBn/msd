-- Add OCR result storage to professional documents
ALTER TABLE professional_documents ADD COLUMN IF NOT EXISTS ocr_result TEXT;

-- Add rejection reason to professional info for admin feedback
ALTER TABLE professional_info ADD COLUMN IF NOT EXISTS rejection_reason VARCHAR(500);
