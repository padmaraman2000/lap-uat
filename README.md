# LAP UAT System — MFL × FinBox

> Full UAT environment for Loan Against Property workflow: QDE → DDE → DDE Review → BPO Review → Under Review → In Principle Sanction → Loan Sanction → Disbursal Ready → Fully Disbursed

---

## What's included

| Feature | Description |
|---------|-------------|
| Real login | Supabase Auth — email + password per user |
| Role-based access | CO, BPO, BCM, BBM, OPS, Admin |
| Branch management | Create and assign branches to users |
| Lead creation | Full QDE + DDE form (personal, property, income, docs) |
| Case pool | All cases with filter by stage |
| Self-assign | Users pick cases from the pool |
| Stage movement | Move cases forward based on role permissions |
| Stage checklist | Role-specific checklists per stage |
| Stage history | Timeline of all stage movements |
| Multiple leads | Create and manage unlimited leads |
| Disbursement | OPS user marks Fully Disbursed → triggers LMS note |

---

## Role Permissions

| Role | Stages they can act on |
|------|------------------------|
| CO (Credit Officer) | QDE, DDE, DDE Review, Loan Sanction, Disbursal Ready |
| BPO / BPM | BPO Review, Disbursal Ready |
| BCM | Under Review, In Principle Sanction |
| BBM | In Principle Sanction (offer negotiation) |
| OPS | Disbursal Ready (final approval) |
| ADMIN | All stages + User management + Branch management |

---

## Project Files

```
lap-uat/
├── index.html           ← The entire web app (single file)
├── supabase_setup.sql   ← Run this once in Supabase SQL Editor
└── README.md            ← This file
```

---

## STEP 1 — Create a Supabase Project (Free)

1. Go to **https://supabase.com** → Sign up (free)
2. Click **New Project**
3. Fill in:
   - **Name:** `lap-uat`
   - **Database Password:** something strong (save it!)
   - **Region:** Asia (Singapore) — closest to India
4. Click **Create new project** — wait ~2 minutes

---

## STEP 2 — Run the Database Setup SQL

1. In your Supabase project, click **SQL Editor** (left sidebar)
2. Click **New Query**
3. Open the file `supabase_setup.sql` from this project
4. Copy ALL the content and paste it into the SQL Editor
5. Click **Run** (green button)
6. You should see: *"Success. No rows returned"*

This creates:
- `profiles` table (user details + roles)
- `branches` table (with 8 pre-seeded branches)
- `leads` table (all loan application data)
- Row Level Security policies
- Auto-triggers for timestamps and profile creation

---

## STEP 3 — Get Your Supabase API Keys

1. In your Supabase project → **Settings** (gear icon, bottom left)
2. Click **API**
3. Copy two values:
   - **Project URL** — looks like `https://abcdefgh.supabase.co`
   - **anon public key** — long JWT token starting with `eyJ...`

Keep these handy for Step 5.

---

## STEP 4 — Create Your Admin User

1. In Supabase → **Authentication** → **Users** tab
2. Click **Add user** → **Create new user**
3. Enter:
   - **Email:** `admin@mfl.com`
   - **Password:** `Admin@1234`
4. Click **Create user**
5. Now go to **Table Editor** → **profiles** table
6. Find the row for `admin@mfl.com`
7. Click the row → set `role` = `ADMIN`, `full_name` = `Admin User`
8. Save the row

---

## STEP 5 — Open the App & Configure Supabase

1. Open `index.html` in your browser (double-click the file)
2. The app will show a **"Configure Supabase"** popup
3. Paste your **Project URL** and **anon public key** from Step 3
4. Click **Save & Connect**

---

## STEP 6 — Login as Admin

1. Email: `admin@mfl.com`
2. Password: `Admin@1234`
3. You should see the full dashboard with **Admin** role

---

## STEP 7 — Create Users for Each Role

As Admin, click **Users & Roles** in the sidebar → **+ New User**

Create these test users:

| Name | Email | Password | Role | Branch |
|------|-------|----------|------|--------|
| Anitha CO | co@mfl.com | Test@1234 | CO | S0001-MFL-MAIN |
| Ravi BPO | bpo@mfl.com | Test@1234 | BPO | S0001-MFL-MAIN |
| Sundar BCM | bcm@mfl.com | Test@1234 | BCM | S0001-MFL-MAIN |
| Priya OPS | ops@mfl.com | Test@1234 | OPS | S0001-MFL-MAIN |

> Note: After creating a user, go to Supabase → Table Editor → profiles → find the new user row → manually set their `role` field if it didn't save from the form.

---

## STEP 8 — Create Your First Lead

1. Login as `co@mfl.com`
2. Click **+ New Lead**
3. Fill in QDE (Step 1):
   - Applicant name, mobile, loan amount, purpose, product type, branch
4. Click **Next** through all 5 steps
5. On Step 5 (Documents), tick the collected documents
6. Click **Submit Application**

The lead will appear in the **All Cases** pool with stage **DDE Review**.

---

## STEP 9 — Test the Full Workflow

Follow this sequence to test end-to-end:

### DDE Review (Login as CO)
1. Open the case from the pool
2. Click **Pick Case** to self-assign
3. Go to **Checklist** tab → complete all items
4. Click **Move to: BPO Review →**

### BPO Review (Login as BPO)
1. Open the case → Pick Case
2. Complete the BPO checklist
3. Move to: Under Review

### Under Review (Login as BCM)
1. Pick Case → complete checklist
2. Move to: In Principle Sanction

### In Principle Sanction (BCM)
1. Case auto-assigned to BCM
2. Complete checklist → Move to: Loan Sanction

### Loan Sanction (Login as CO)
1. Case auto-assigned to CO
2. Complete checklist → Move to: Disbursal Ready

### Disbursal Ready (Login as OPS)
1. Pick Case
2. Complete OPS checklist
3. Click **Mark Fully Disbursed ✓**

---

## Deploy to GitHub Pages (Share with Team)

Once everything works locally, put it online:

1. Create GitHub repo named `lap-uat` (must be Public)
2. Upload `index.html` and `README.md`
3. Go to Settings → Pages → Branch: main, Folder: / (root) → Save
4. Share the URL: `https://yourusername.github.io/lap-uat/`

Everyone on your team can open this URL, click **Configure Supabase**, enter the same Project URL + anon key, and they'll share the same live database.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "Invalid login credentials" | Check email/password. Make sure user exists in Supabase Auth |
| "row-level security violation" | Re-run the SQL setup script — RLS policies may not have applied |
| No branches in dropdown | Make sure the SQL script ran successfully (branches table seeded) |
| User role shows blank | Go to Supabase → Table Editor → profiles → set role manually |
| Cases not showing | Check Supabase → Table Editor → leads table has data |
| Can't move stage | Your role may not have permission for that stage — check Role Permissions table above |

---

## Support

For any issues, check:
- Supabase status: **https://status.supabase.com**
- Supabase docs: **https://supabase.com/docs**
