# Database Auditing, Hierarchical Data and Security

## Project Overview

This project demonstrates advanced PostgreSQL database management techniques.

## Objectives

- Implement trigger-based audit logging.
- Track INSERT, UPDATE and DELETE operations.
- Model hierarchical categories using self-referencing relationships.
- Query hierarchical data using recursive CTEs.
- Manage schema changes using Flyway versioned migrations.
- Implement database security using roles and least-privilege permissions.

## Technologies Used

- PostgreSQL 16
- SQL
- PL/pgSQL
- Flyway
- pgAdmin 4

## Implementation

### 1. Audit Logging
Created an audit_log table and reusable trigger function to automatically record database changes.

### 2. Hierarchical Categories
Created a self-referencing categories table and used recursive CTEs to retrieve category trees.

### 3. Database Migrations
Organized schema changes into versioned Flyway migration files.

### 4. Database Security
Created app_read and app_write roles and assigned appropriate permissions. Created an API user with write-role membership.

## Testing and Verification

Verified audit records, trigger execution, category hierarchy, migration history and database permissions.

## Conclusion

This project demonstrates database auditing, hierarchical data modeling, version-controlled schema management and least-privilege database security.
