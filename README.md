# ACHIEVIA shared-config starter

This package supports a shared Supabase connection for all visitors through `config.js`.

## Important
- The SQL schema was already run in your Supabase project, so do NOT run `schema.sql` again unless you intentionally need to reset/review the schema.
- Before publishing, edit `config.js` and replace both placeholders:
  - `supabaseUrl`: Supabase Project URL
  - `supabaseKey`: public anon/publishable key only
- Never put the `service_role` secret key in browser files.
- These files are a starter, not yet a production-audited website. Test signup, profile access, and admin permissions with a separate normal account before sharing widely.

## Publish
Upload `index.html`, `config.js`, and any required assets to the same static-site root. `schema.sql` is for database setup only and is not needed by the public website.

## Admin setup
1. Create/sign up your owner account through the site.
2. In Supabase SQL Editor, grant `role = 'admin'` to that exact owner account using its email. Only do this for your trusted account. Never let ordinary members edit the role.
3. Check Auth URL Configuration and add the deployed site URL to allowed redirect URLs if needed.
