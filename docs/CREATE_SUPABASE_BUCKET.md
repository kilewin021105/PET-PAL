# Create Supabase Storage Bucket: `pet_profile`

This project expects a Supabase storage bucket named `pet_profile` for storing pet profile pictures. Create this bucket using the Supabase UI or the Supabase CLI.

## Option A — Supabase Web UI
1. Open your Supabase project in the dashboard.
2. Go to "Storage" in the left menu.
3. Click "Create a new bucket".
4. Set the bucket name to: `pet_profile`.
5. Choose whether the bucket should be public (if you need direct public URLs) or private. The code currently expects public access for `getPublicUrl` to work without signed URLs.

## Option B — Supabase CLI (recommended for automation)
Make sure you have the Supabase CLI installed and authenticated.

PowerShell example (replace with your own project/credentials if needed):

```powershell
# Install supabase CLI if not installed
# winget install supabase.supabase-cli -s winget

# Create a public bucket named pet_profile
supabase storage create-bucket pet_profile --public
```

If you want private buckets, remove `--public` and adjust your code to use signed URLs or the Supabase client to generate download links.

## Notes for this project
- The app uses `supabase.storage.from('pet_profile')` in `lib/InsideAcc/pet_profile_page.dart`.
- Upload path in code uses the prefix `public/` by default; you can change this as desired.
- If you run into permission issues, confirm that the bucket policy allows the operations (upload/getPublicUrl) for your auth role.

If you'd like, I can add a short script that calls the Supabase REST API to create the bucket (requires a Service Role key). Otherwise the CLI or UI are the safest options.