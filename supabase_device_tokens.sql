-- Create device_tokens table for storing FCM tokens
CREATE TABLE IF NOT EXISTS device_tokens (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, token) -- Prevent duplicate tokens per user
);

-- Enable Row Level Security
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to insert their own tokens
CREATE POLICY "Users can insert their own device tokens" ON device_tokens
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create policy to allow users to view their own tokens
CREATE POLICY "Users can view their own device tokens" ON device_tokens
    FOR SELECT USING (auth.uid() = user_id);

-- Create policy to allow users to delete their own tokens
CREATE POLICY "Users can delete their own device tokens" ON device_tokens
    FOR DELETE USING (auth.uid() = user_id);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_device_tokens_user_id ON device_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_device_tokens_token ON device_tokens(token);
