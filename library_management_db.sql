/* Library Management System Database
 Create Database for use */

CREATE DATABASE IF NOT EXISTS library_management_system;
USE library_management_system;

-- Drop existing tables if they exist (for clean setup)
DROP TABLE IF EXISTS fine_payments;
DROP TABLE IF EXISTS book_loans;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS book_genres;
DROP TABLE IF EXISTS book_copies;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS member_types;

-- Create tables with appropriate constraints

-- Member Types table
CREATE TABLE member_types (
    member_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    max_books INT NOT NULL DEFAULT 3,
    loan_duration INT NOT NULL DEFAULT 14,  -- this is in days
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Members table
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address VARCHAR(255),
    date_of_birth DATE,
    member_type_id INT NOT NULL,
    join_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    expiry_date DATE NOT NULL,
    status ENUM('Active', 'Suspended', 'Expired') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_members_member_type FOREIGN KEY (member_type_id) 
        REFERENCES member_types(member_type_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Departments table
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Staff table
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    position VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_staff_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Authors table
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    death_date DATE,
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT unique_author UNIQUE (first_name, last_name, birth_date)
) ENGINE=InnoDB;

-- Genres table
CREATE TABLE genres (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Books table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    publication_year INT,
    publisher VARCHAR(100),
    language VARCHAR(50) DEFAULT 'English',
    summary TEXT,
    cover_image VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Book_Authors table (Many-to-Many relationship between Books and Authors)
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_role ENUM('Primary', 'Secondary', 'Editor', 'Translator') DEFAULT 'Primary',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_book_authors_book FOREIGN KEY (book_id) 
        REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_book_authors_author FOREIGN KEY (author_id) 
        REFERENCES authors(author_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Book_Genres table (Many-to-Many relationship between Books and Genres)
CREATE TABLE book_genres (
    book_id INT NOT NULL,
    genre_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (book_id, genre_id),
    CONSTRAINT fk_book_genres_book FOREIGN KEY (book_id) 
        REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_book_genres_genre FOREIGN KEY (genre_id) 
        REFERENCES genres(genre_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Book_Copies table (Individual copies of books that can be loaned)
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    copy_number VARCHAR(50) NOT NULL,
    acquisition_date DATE NOT NULL,
    price DECIMAL(10,2),
    physical_condition ENUM('New', 'Good', 'Fair', 'Poor', 'Damaged') DEFAULT 'New',
    status ENUM('Available', 'On Loan', 'Reserved', 'In Repair', 'Lost') DEFAULT 'Available',
    location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_book_copies_book FOREIGN KEY (book_id) 
        REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT unique_copy UNIQUE (book_id, copy_number)
) ENGINE=InnoDB;

-- Book_Loans table with records of book borrowing
CREATE TABLE book_loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    member_id INT NOT NULL,
    staff_id INT,  -- Staff who processed the loan
    loan_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE,
    is_renewed BOOLEAN DEFAULT FALSE,
    renewal_count INT DEFAULT 0,
    status ENUM('Active', 'Returned', 'Overdue', 'Lost') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_book_loans_copy FOREIGN KEY (copy_id) 
        REFERENCES book_copies(copy_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_book_loans_member FOREIGN KEY (member_id) 
        REFERENCES members(member_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_book_loans_staff FOREIGN KEY (staff_id) 
        REFERENCES staff(staff_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Fine_Payments table (Records of fines for late returns)
CREATE TABLE fine_payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Online') DEFAULT 'Cash',
    staff_id INT,  -- Staff who processed the payment
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_fine_payments_loan FOREIGN KEY (loan_id) 
        REFERENCES book_loans(loan_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_fine_payments_staff FOREIGN KEY (staff_id) 
        REFERENCES staff(staff_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Insert sample data for testing

-- Insert Member Types
INSERT INTO member_types (type_name, max_books, loan_duration) VALUES 
('Student', 5, 14),
('Faculty', 10, 30),
('Standard', 3, 14),
('Premium', 8, 21);

-- Insert Departments
INSERT INTO departments (department_name, location) VALUES 
('Circulation', 'Ground Floor'),
('Reference', 'First Floor'),
('Technical Services', 'Basement'),
('Administration', 'Second Floor');

-- Insert Staff members
INSERT INTO staff (first_name, last_name, email, phone, position, department_id, hire_date, salary) VALUES 
('John', 'Smith', 'john.smith@library.com', '555-1234', 'Librarian', 1, '2018-06-15', 52000.00),
('Sarah', 'Johnson', 'sarah.johnson@library.com', '555-5678', 'Senior Librarian', 2, '2015-03-10', 65000.00),
('Michael', 'Williams', 'michael.williams@library.com', '555-9012', 'Library Assistant', 1, '2020-01-05', 38000.00),
('Emily', 'Davis', 'emily.davis@library.com', '555-3456', 'Library Director', 4, '2010-09-01', 85000.00);

-- Insert Genres
INSERT INTO genres (genre_name, description) VALUES 
('Fiction', 'Literary works created from the imagination'),
('Science Fiction', 'Fiction based on scientific discoveries or advanced technology'),
('Mystery', 'Fiction dealing with solving a crime or puzzling event'),
('Biography', 'An account of someone\'s life written by someone else'),
('History', 'Books about past events of significance'),
('Philosophy', 'Study of fundamental questions about existence, knowledge, ethics, etc.');

-- Insert Authors
INSERT INTO authors (first_name, last_name, birth_date, biography) VALUES 
('J.K.', 'Rowling', '1965-07-31', 'British author best known for the Harry Potter series'),
('George', 'Orwell', '1903-06-25', 'English novelist, essayist, and critic'),
('Jane', 'Austen', '1775-12-16', 'English novelist known for her six major novels'),
('Stephen', 'King', '1947-09-21', 'American author of horror, supernatural fiction, and fantasy'),
('Agatha', 'Christie', '1890-09-15', 'English writer known for her detective novels');

-- Insert Books
INSERT INTO books (title, isbn, publication_year, publisher, summary) VALUES 
('Harry Potter and the Philosopher\'s Stone', '9780747532699', 1997, 'Bloomsbury', 'The first novel in the Harry Potter series about a young wizard'),
('1984', '9780451524935', 1949, 'Secker & Warburg', 'Dystopian social science fiction novel set in a totalitarian regime'),
('Pride and Prejudice', '9780141439518', 1813, 'T. Egerton', 'Novel of manners about the Bennett family and Mr. Darcy'),
('The Shining', '9780307743657', 1977, 'Doubleday', 'Horror novel about a family staying at an isolated hotel'),
('Murder on the Orient Express', '9780062693662', 1934, 'Collins Crime Club', 'Detective novel featuring Hercule Poirot');

-- Associate books with authors
INSERT INTO book_authors (book_id, author_id) VALUES 
(1, 1),  -- Harry Potter - J.K. Rowling
(2, 2),  -- 1984 - George Orwell
(3, 3),  -- Pride and Prejudice - Jane Austen
(4, 4),  -- The Shining - Stephen King
(5, 5);  -- Murder on the Orient Express - Agatha Christie

-- Associate books with genres
INSERT INTO book_genres (book_id, genre_id) VALUES 
(1, 1),  -- Harry Potter - Fiction
(1, 2),  -- Harry Potter - Science Fiction 
(2, 1),  -- 1984 - Fiction
(2, 2),  -- 1984 - Science Fiction
(3, 1),  -- Pride and Prejudice - Fiction
(4, 1),  -- The Shining - Fiction
(5, 1),  -- Murder on the Orient Express - Fiction
(5, 3);  -- Murder on the Orient Express - Mystery

-- Insert Book Copies
INSERT INTO book_copies (book_id, copy_number, acquisition_date, price, physical_condition, status, location) VALUES 
(1, 'HP1-001', '2020-01-15', 15.99, 'Good', 'Available', 'Shelf A1'),
(1, 'HP1-002', '2020-01-15', 15.99, 'Good', 'Available', 'Shelf A1'),
(2, '1984-001', '2019-05-22', 12.50, 'Good', 'Available', 'Shelf B2'),
(3, 'PP-001', '2018-11-30', 10.99, 'Fair', 'Available', 'Shelf C3'),
(4, 'TS-001', '2021-02-10', 14.75, 'New', 'Available', 'Shelf D4'),
(5, 'MOTE-001', '2020-08-05', 11.25, 'Good', 'Available', 'Shelf E5');

-- Insert Members
INSERT INTO members (first_name, last_name, email, phone, member_type_id, join_date, expiry_date) VALUES 
('David', 'Wilson', 'david.wilson@email.com', '555-7890', 1, '2022-01-10', '2023-01-10'),
('Jennifer', 'Brown', 'jennifer.brown@email.com', '555-0123', 3, '2021-05-15', '2022-05-15'),
('Robert', 'Taylor', 'robert.taylor@email.com', '555-4567', 2, '2020-11-20', '2022-11-20'),
('Patricia', 'Anderson', 'patricia.anderson@email.com', '555-8901', 4, '2022-03-05', '2023-03-05');

-- Insert Book Loans
INSERT INTO book_loans (copy_id, member_id, staff_id, loan_date, due_date, status) VALUES 
(2, 1, 1, '2022-04-01', '2022-04-15', 'Active'),
(3, 2, 1, '2022-03-25', '2022-04-08', 'Overdue'),
(5, 3, 2, '2022-04-05', '2022-05-05', 'Active');

-- Insert a Fine Payment
INSERT INTO fine_payments (loan_id, amount, payment_date, payment_method, staff_id, notes) VALUES 
(2, 5.00, '2022-04-10', 'Cash', 3, 'Partial payment for overdue book');

-- Views for common queries

-- View of available books
CREATE VIEW available_books AS
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    COUNT(bc.copy_id) AS available_copies,
    a.first_name AS author_first_name,
    a.last_name AS author_last_name
FROM 
    books b
JOIN 
    book_copies bc ON b.book_id = bc.book_id
JOIN 
    book_authors ba ON b.book_id = ba.book_id
JOIN 
    authors a ON ba.author_id = a.author_id
WHERE 
    bc.status = 'Available'
GROUP BY 
    b.book_id, a.author_id;

-- View of overdue loans
CREATE VIEW overdue_loans AS
SELECT 
    bl.loan_id,
    b.title,
    bc.copy_number,
    m.first_name AS member_first_name,
    m.last_name AS member_last_name,
    m.email AS member_email,
    bl.loan_date,
    bl.due_date,
    DATEDIFF(CURRENT_DATE, bl.due_date) AS days_overdue,
    DATEDIFF(CURRENT_DATE, bl.due_date) * 0.25 AS estimated_fine
FROM 
    book_loans bl
JOIN 
    book_copies bc ON bl.copy_id = bc.copy_id
JOIN 
    books b ON bc.book_id = b.book_id
JOIN 
    members m ON bl.member_id = m.member_id
WHERE 
    bl.status = 'Overdue'
    OR (bl.status = 'Active' AND bl.due_date < CURRENT_DATE);

-- Triggers for business logic

-- Trigger to update book copy status when loaned
DELIMITER //
CREATE TRIGGER after_loan_insert
AFTER INSERT ON book_loans
FOR EACH ROW
BEGIN
    UPDATE book_copies
    SET status = 'On Loan'
    WHERE copy_id = NEW.copy_id;
END//
DELIMITER ;

-- Trigger to update book copy status when returned
DELIMITER //
CREATE TRIGGER after_loan_update
AFTER UPDATE ON book_loans
FOR EACH ROW
BEGIN
    IF NEW.status = 'Returned' AND OLD.status != 'Returned' THEN
        UPDATE book_copies
        SET status = 'Available'
        WHERE copy_id = NEW.copy_id;
    END IF;
END//
DELIMITER ;

-- Stored Procedures for common operations

-- Procedure to renew a book loan
DELIMITER //
CREATE PROCEDURE RenewLoan(IN loan_id_param INT, OUT success BOOLEAN)
BEGIN
    DECLARE current_status VARCHAR(20);
    DECLARE current_renewal_count INT;
    DECLARE member_loan_duration INT;
    
    -- Get current loan status and renewal count
    SELECT bl.status, bl.renewal_count, mt.loan_duration
    INTO current_status, current_renewal_count, member_loan_duration
    FROM book_loans bl
    JOIN members m ON bl.member_id = m.member_id
    JOIN member_types mt ON m.member_type_id = mt.member_type_id
    WHERE bl.loan_id = loan_id_param;
    
    -- Check if loan can be renewed
    IF current_status = 'Active' AND current_renewal_count < 2 THEN
        -- Renew the loan
        UPDATE book_loans
        SET due_date = DATE_ADD(due_date, INTERVAL member_loan_duration DAY),
            renewal_count = renewal_count + 1,
            is_renewed = TRUE
        WHERE loan_id = loan_id_param;
        
        SET success = TRUE;
    ELSE
        SET success = FALSE;
    END IF;
END//
DELIMITER ;

-- Procedure to check for and mark overdue loans
DELIMITER //
CREATE PROCEDURE CheckOverdueLoans()
BEGIN
    UPDATE book_loans
    SET status = 'Overdue'
    WHERE due_date < CURRENT_DATE
    AND status = 'Active';
END//
DELIMITER ;

-- Procedure to add a new book with authors and genres
DELIMITER //
CREATE PROCEDURE AddBook(
    IN title_param VARCHAR(255),
    IN isbn_param VARCHAR(20),
    IN publication_year_param INT,
    IN publisher_param VARCHAR(100),
    IN author_id_param INT,
    IN genre_id_param INT,
    IN copies_param INT,
    IN price_param DECIMAL(10,2),
    OUT book_id_out INT
)
BEGIN
    DECLARE i INT DEFAULT 1;
    
    -- Insert the book
    INSERT INTO books (title, isbn, publication_year, publisher)
    VALUES (title_param, isbn_param, publication_year_param, publisher_param);
    
    SET book_id_out = LAST_INSERT_ID();
    
    -- Associate with author
    INSERT INTO book_authors (book_id, author_id)
    VALUES (book_id_out, author_id_param);
    
    -- Associate with genre
    INSERT INTO book_genres (book_id, genre_id)
    VALUES (book_id_out, genre_id_param);
    
    -- Add specified number of copies
    WHILE i <= copies_param DO
        INSERT INTO book_copies (book_id, copy_number, acquisition_date, price, physical_condition, status)
        VALUES (book_id_out, CONCAT(REPLACE(title_param, ' ', '-'), '-', LPAD(i, 3, '0')), 
                CURRENT_DATE, price_param, 'New', 'Available');
        SET i = i + 1;
    END WHILE;
END//
DELIMITER ;

-- Procedure to register a new member
DELIMITER //
CREATE PROCEDURE RegisterMember(
    IN first_name_param VARCHAR(50),
    IN last_name_param VARCHAR(50),
    IN email_param VARCHAR(100),
    IN phone_param VARCHAR(20),
    IN address_param VARCHAR(255),
    IN date_of_birth_param DATE,
    IN member_type_id_param INT,
    OUT member_id_out INT
)
BEGIN
    -- Calculate expiry date (1 year from join date)
    DECLARE expiry_date_param DATE;
    SET expiry_date_param = DATE_ADD(CURRENT_DATE, INTERVAL 1 YEAR);
    
    -- Insert the new member
    INSERT INTO members (
        first_name, 
        last_name, 
        email, 
        phone, 
        address, 
        date_of_birth, 
        member_type_id, 
        join_date, 
        expiry_date
    )
    VALUES (
        first_name_param, 
        last_name_param, 
        email_param, 
        phone_param, 
        address_param, 
        date_of_birth_param, 
        member_type_id_param, 
        CURRENT_DATE, 
        expiry_date_param
    );
    
    SET member_id_out = LAST_INSERT_ID();
END//
DELIMITER ;

-- Event for scheduled tasks

-- Enable event scheduler
SET GLOBAL event_scheduler = ON;

-- Create event to check for overdue loans daily
DELIMITER //
CREATE EVENT IF NOT EXISTS daily_overdue_check
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 1 DAY
DO
BEGIN
    CALL CheckOverdueLoans();
END//
DELIMITER ;