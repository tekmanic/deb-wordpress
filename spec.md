# Project Specification: deb-wordpress

## 1. Vision & Goals (B - Background)
`deb-wordpress` is a specialized Docker image designed for rapid deployment of isolated WordPress sandbox environments. Unlike standard WordPress images that require a separate database container, `deb-wordpress` integrates MariaDB internally, enabling a "single-container" deployment model ideal for development, testing, and ephemeral environments.

### Primary Objectives
- **Zero-Config Startup:** Provide a fully functional WordPress + MariaDB stack in one container.
- **Isolation:** Allow multiple parallel instances on a single host without port or data conflicts.
- **Automation:** Leverage WP-CLI for automated site initialization and plugin management.
- **Security Hardening:** Transition to modern base images and implement container security best practices.

---

## 2. System Architecture (M - Model)

### Component Stack
- **OS:** Debian Bookworm (Stable)
- **Web Server:** Apache 2.4
- **Runtime:** PHP 8.x (with optimized opcache and error logging)
- **Database:** MariaDB Server (internal)
- **Orchestration:** nitro (for process management and init)
- **Tooling:** WP-CLI (for automated setup)

### Data Flow & Persistence
- **Ephemeral Layer:** The core WordPress installation resides in `/usr/src/wordpress`.
- **Persistent Layer:** The `/content` volume is bind-mounted to `/var/www/html/wp-content`, preserving themes, plugins, and uploads across container restarts.
- **Initialization:** On first boot, `init.sh` handles the database creation, WordPress installation, and plugin activation using environment variables.

---

## 3. Implementation Details (A - Analysis)

### Environment Configuration
The system is configured via the following primary environment variables:
- `URL`: The public-facing URL of the site.
- `ADMIN_NAME/PASSWORD/EMAIL`: Credentials for the initial WP admin account.
- `PLUGINS`: A space-separated list of plugin slugs to be installed via WP-CLI.
- `BASIC_AUTH_ENABLED`: Toggle for adding an extra layer of security via `.htpasswd`.

### Memory & Resource Constraints
Given the underlying LLM context limit (65k tokens), the project is managed using a modular approach:
- **Spec File:** Acts as the "Source of Truth" for high-level design.
- **TODO.md:** Tracks granular task execution.
- **Modular Scripts:** Logic is split between `Dockerfile`, `init.sh`, and `run.sh` to keep individual files small and maintainable.

---

## 4. Roadmap & Validation (D - Delivery)

### Current Phase: Update & Hardening
- [x] **WordPress Update:** Migrated to v7.0.2.
- [x] **Base Image Upgrade:** Moved from Debian Bullseye $\rightarrow$ Bookworm.
- [ ] **Security Hardening:** 
    - Implement non-root user for PHP/Apache processes.
    - Tighten filesystem permissions.
    - Remove unnecessary build-time dependencies.
- [ ] **CI/CD Integration:** 
    - Implement GitHub Actions for automated builds.
    - Add "Boot-Test" to verify that the container reaches a "ready" state.
- [ ] **Monitoring:** Integrate Dependabot and security scanners.

### Success Criteria
1. Container boots in < 30 seconds.
2. `wp-admin` is accessible via the configured `URL`.
3. Specified plugins are active upon first login.
4. No critical vulnerabilities reported by standard container scanners.