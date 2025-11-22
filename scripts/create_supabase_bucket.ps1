# PowerShell helper: create Supabase storage bucket
# Requires: supabase CLI installed and `supabase login` completed

param(
    [string]$BucketName = 'pet_profile',
    [switch]$Public = $true
)

$publicFlag = $Public.IsPresent ? '--public' : ''
Write-Host "Creating bucket: $BucketName (public: $Public)"

supabase storage create-bucket $BucketName $publicFlag

if ($LASTEXITCODE -ne 0) {
    Write-Error "supabase CLI returned exit code $LASTEXITCODE. Check that the CLI is installed and you're logged in."
} else {
    Write-Host "Bucket created (or already exists)."
}