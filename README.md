# Library Management System Database

## Project Overview

A comprehensive relational database system for managing all aspects of a modern library's operations, including book inventory, member management, loans, staff records, and fine collections.

## Description

This Library Management System database provides a complete solution for libraries to manage their collections, memberships, and daily operations. The system handles:

* **Book management** : Tracking books, their authors, genres, and individual copies
* **Member management** : Different membership types with varying loan privileges
* **Circulation** : Book loans, returns, renewals, and reservation processes
* **Staff operations** : Employee records and department organization
* **Fine processing** : Tracking and collecting overdue fines

The database incorporates best SQL practices including proper normalization, referential integrity through foreign keys, and business logic implementation via triggers, stored procedures, and scheduled events.

## Database Structure

### Core Tables

* **books** : Main book information (title, ISBN, publication details)
* **authors** : Information about book authors
* **genres** : Book categories and subjects
* **book_copies** : Individual physical copies available for loan
* **members** : Library patron information
* **member_types** : Categories of membership with different privileges
* **book_loans** : Records of all borrowing activities
* **staff** : Library employee information
* **departments** : Organizational structure
* **fine_payments** : Record of fines for late returns

### Relationships

* One-to-Many relationships between member types and members, departments and staff, books and copies
* Many-to-Many relationships between books and authors, books and genres
* Complex relationships for loan processing between members, book copies, and staff

## Setup Instructions

### Prerequisites

* MySQL Server (version 5.7 or higher)
* MySQL Workbench (optional, for visualization)

### Installation Steps

1. **Clone the repository**

   ```
   git clone https://github.com/yourusername/library-management-system.git
   cd library-management-system
   ```
2. **Import the SQL file**
   **Option 1: Using MySQL command line:**

   ```
   mysql -u username -p < library_management_system.sql
   ```

   **Option 2: Using MySQL Workbench:**

   * Open MySQL Workbench
   * Connect to your MySQL server
   * Select File > Open SQL Script
   * Navigate to the library_management_system.sql file
   * Click the Execute button (lightning bolt icon)
3. **Verify installation**

   ```
   mysql -u username -p
   USE library_management_system;
   SHOW TABLES;
   ```

   You should see all tables listed.

## Additional Notes

* The database includes sample data for testing purposes
* Automatic daily checks for overdue books using MySQL event scheduler
* Built-in triggers update book status when loans are created or returned
* Comprehensive error handling in stored procedures
