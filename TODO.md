# Project: deb-wordpress Update

## Status: In Progress
**Branch:** `update-wordpress-7.0.2`

## Task List
- [x] Update WordPress to version 7.0.2
- [x] Update README.md documentation
- [x] Migrate from s6-overlay to nitro init system
- [x] Replace `su-exec` with `gosu` in Dockerfile to fix build failure
- [x] Upgrade base image (Bullseye -> Trixie) for security
- [x] Upgrade mysqld_safe to mariadbd-safe
- [x] Fix "Error establishing a database connection" during setup
- [x] Implement Docker best practices (security hardening)
- [x] Update GitHub Actions to include build and boot-test
- [x] Add GitHub "Agents" (Security Scanner & Dependabot/Update monitor)
- [ ] Final verification and Push to origin
