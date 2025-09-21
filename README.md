# hats
Highly Available Transaction System

# HATS Authentication & MFA System

## 📌 Overview
This project implements a secure **authentication system** fully in Oracle SQL and PL/SQL.  
It supports:

- Email + password login (encryption and decryption stored in DB)
- Email verification (signup, reset password)
- MFA (Multi-Factor Authentication) codes valid for 15 minutes
- User sessions (with configurable single-session or multi-session behavior)
- Full auditing of logins, logouts, password resets
- Automated purging of expired codes and sessions

## 🏗️ Database Objects
### Tables
- **`authentication_tbl`** → Stores accounts (email, password hash, salt, status)
- **`verification_tbl`** → Stores one-time email verification codes
- **`mfa_tbl`** → Stores 15-minute MFA codes for login
- **`user_session_tbl`** → Active sessions with session tokens
- **`scrutiny_tbl`** → Audit trail of all auth-related events
- **`images_tbl`** → stores link to user images
- **`person_tbl`** → stores details about a person
- **`address_tbl`** → stores physical address details
- **`contact_tbl`** → stores personal contact details
- **`country_tbl`** → stores the list of all countries of the world
- **`profile_tbl`** → store personal profile details
- **`horoscope_tbl`** → stores daily horoscope per signs

### Triggers
- Update `modified_date` automatically on insert/update for all auth tables.

### PL/SQL Package: `auth_pkg`, `profile_pkg`
Implements authentication flows:
- `signup(email, password)` → Create account + issue verification code
- `issue_email_verification(email)` → Generate email verification code
- `confirm_email_verification(email, code)` → Verify email & activate account
- `login_request(email, password)` → Validate password & issue MFA code
- `confirm_mfa(email, code)` → Validate MFA & issue session token
- `logout(email, token)` → End session
- `forgot_password_request(email)` → Issue verification code
- `reset_password(email, code, new_password)` → Reset password
- `SavePerson(email, firstname, lastname, gender)` → stores personal details
- `SaveImage(email, avatar)` → Stores user images 
- `SaveAddress(email, firstline, city, country)` → Stores physical address
- `SaveContact(email, channel, address, consent)` → Stores contact information such facebook, instagram etc
- `SaveProfile(email, maritalStatus, religion etec)` → stores peronal profile details known
- `GetCountry(countryCode)` → Retrieve the country details
- `SaveHoroscope(zodiac, currentDay, narative)` → Stores the daily horoscope
- `GetHoroscope(zodiac)` → Retrieve horoscope details stored


## 🔐 Security Features
- Passwords stored as **hashes**
- MFA required for every login, valid for 15 minutes
- Email verification before account activation
- Full audit logging (`scrutiny_tbl`)

## 🚀 How to Use
1. Run the SQL scripts to create tables, triggers, and package.
2. Use PL/SQL calls (or REST/SOAP APIs on top) to integrate into your app.