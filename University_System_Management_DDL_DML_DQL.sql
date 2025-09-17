/* ===================================================
   DATABASE CREATION
   =================================================== */
DROP DATABASE IF EXISTS university_system_management;   
-- Create the database schema university_system_management
CREATE DATABASE university_system_management;

-- Switch to the new database
USE university_system_management;


-- ============================================================================= --


/* ===================================================
Data Definition Language (DDL)
Create all tables with proper constraints (PK, FK, CHECK, NOT NULL, UNIQUE),
views, stored procedures, triggers and indexes.
=================================================== */

/* ===================================================
   TABLES CREATION
   =================================================== */

-- ================================================
-- 1. Rooms
-- Information about classrooms and their capacity.
-- ================================================
CREATE TABLE Rooms (
    room_id INT PRIMARY KEY,						-- Unique identifier for the room
    building VARCHAR(50) NOT NULL,					-- Building name
    room_number VARCHAR(10) NOT NULL,				-- Room number
    room_type VARCHAR(50),							-- Room type (e.g. lab, lecture hall)
    capacity INT CHECK (capacity > 0)				-- Maximum capacity
);

-- ================================================
-- 2. Terms
-- Academic terms in the university (e.g. Fall 2025).
-- ================================================
CREATE TABLE Terms (
    term_id INT PRIMARY KEY,			-- Unique identifier for the term
    name VARCHAR(50) NOT NULL,			-- Term name
    start_date DATE NOT NULL,			-- Term start date
    end_date DATE NOT NULL				-- Term end date
);

-- ================================================
-- 3. Departments
-- Stores academic departments at the university.
-- Each department may have an instructor acting as chair.
-- ================================================
CREATE TABLE Departments (
    department_id INT PRIMARY KEY,													-- Unique identifier for the department
    name VARCHAR(100) NOT NULL,														-- Department name
    chair_instructor_id INT													        -- Instructor who serves as the chair
);

-- ================================================
-- 4. Instructors
-- University instructors associated with departments.
-- ================================================
CREATE TABLE Instructors (
    instructor_id INT PRIMARY KEY,											-- Unique identifier for the instructor
    department_id INT NOT NULL,												-- Department the instructor belongs to
    first_name VARCHAR(50) NOT NULL,										-- Instructor First name
    last_name VARCHAR(50) NOT NULL,											-- Instructor Last name
    email VARCHAR(100) UNIQUE NOT NULL,										-- Instructor Unique email address
    rank_title VARCHAR(50),													-- Academic rank/title (e.g. Professor, Lecturer, Adjunct Instructor, Assistant Professor)
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)		-- Associates the instructor with an existing department.
);

-- ================================================
-- Adding Foreing Key to Departments Table After Creation
-- ================================================
ALTER TABLE Departments
ADD CONSTRAINT fk_chair FOREIGN KEY (chair_instructor_id) REFERENCES Instructors(instructor_id);

-- ================================================
-- 5. Programs
-- Academic programs offered by departments.
-- Examples: Bachelor in Engineering, Master of Data Analytics.
-- ================================================
CREATE TABLE Programs (
    program_id INT PRIMARY KEY,															-- Unique identifier for the program
    department_id INT NOT NULL,				        									-- Department that offers the program
    name VARCHAR(100) NOT NULL,					    									-- Program name
    degree_level VARCHAR(50) CHECK (degree_level IN ('Bachelor', 'Master', 'PhD')),		-- Academic level
    credits_required INT CHECK (credits_required > 0),									-- Required credits to graduate
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)					-- Ensures each program is associated with an existing department.
);

-- ================================================
-- 6. Students
-- Stores student information.
-- Includes enrollment program, status, and unique email.
-- ================================================
CREATE TABLE Students (
    student_id INT PRIMARY KEY,														-- Unique identifier for the student
    program_id INT NOT NULL,														-- Program in which the student is enrolled
    first_name VARCHAR(50) NOT NULL,												-- Student First name
    last_name VARCHAR(50) NOT NULL,													-- Student Last name
    email VARCHAR(100) UNIQUE NOT NULL,												-- Student Unique email address
    status VARCHAR(20) CHECK (status IN ('active', 'inactive', 'graduated')),		-- Student status
    profile_json JSON,							    								-- Additional profile data stored as JSON
    FOREIGN KEY (program_id) REFERENCES Programs(program_id)						-- This links the department to the instructor who is the chair of the department.
);

-- ================================================
-- 7. Courses
-- Courses offered by university departments.
-- ================================================
CREATE TABLE Courses (
    course_id INT PRIMARY KEY,												-- Unique identifier for the course
    department_id INT NOT NULL,												-- Department that offers the course
    title VARCHAR(100) NOT NULL,											-- Course title
    credits INT CHECK (credits > 0),										-- Number of credits
    description TEXT,														-- Course description
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)		-- Associates the course with the department that offers it.
);

-- ================================================
-- 8. Course_Sections
-- Specific sections of a course offered in a given term.
-- ================================================
CREATE TABLE Course_Sections (
    section_id INT PRIMARY KEY,									-- Unique identifier for the section
    course_id INT NOT NULL,										-- Related course
    term_id INT NOT NULL,										-- Related academic term
    section_code VARCHAR(20) NOT NULL,							-- Section code (e.g. DAMO501, DAMO502)
    capacity INT CHECK (capacity > 0),							-- Maximum number of students allowed
    language VARCHAR(50),										-- Language of instruction
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),		-- Links the section to its parent course.
    FOREIGN KEY (term_id) REFERENCES Terms(term_id)				-- Indicates the term in which the section is offered.
);

-- ================================================
-- 9. Instructor_Contracts
-- Contracts assigned to instructors for a given academic term.
-- ================================================
CREATE TABLE Instructor_Contracts (
    instructor_id INT,														-- Instructor identifier
    term_id INT,															-- Academic term identifier
    contract_type VARCHAR(50),												-- Contract type (e.g. full-time, part-time)
    start_date DATE NOT NULL,												-- Contract start date
    end_date DATE NOT NULL,													-- Contract end date
    salary DECIMAL(10,2) CHECK (salary >= 0),								-- Contract salary
    PRIMARY KEY (instructor_id, term_id),									-- Composite key: one contract per instructor per term
    FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id),		-- Links contract to an existing instructor.
    FOREIGN KEY (term_id) REFERENCES Terms(term_id)							-- Ensures the contract is tied to a valid academic term.
);

-- ================================================
-- 10. Schedules
-- Class schedules: assign sections to rooms and instructors.
-- ================================================
CREATE TABLE Schedules (
    schedule_id INT PRIMARY KEY,             												-- Unique identifier for the schedule
    section_id INT NOT NULL,                 												-- Related section
    room_id INT NOT NULL,                    												-- Assigned classroom
    instructor_id INT NOT NULL,              												-- Assigned instructor
    day_of_week VARCHAR(10) CHECK (day_of_week IN 
        ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')), 	-- Day of the week
    start_time TIME NOT NULL,                												-- Start time
    end_time TIME NOT NULL,                  												-- End time
    FOREIGN KEY (section_id) REFERENCES Course_Sections(section_id),			   			-- Ensures the schedule entry corresponds to an existing course section.
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id),							  			-- Assigns the schedule to an existing physical room.	
    FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)			   			-- Associates the scheduled class with the instructor who teaches it.
);

-- ================================================
-- 11. Enrollments
-- Records student enrollments in specific sections.
-- ================================================
CREATE TABLE Enrollments (
    enrollment_id INT PRIMARY KEY,           								-- Unique identifier for the enrollment
    student_id INT NOT NULL,                 								-- Enrolled student
    section_id INT NOT NULL,                 								-- Section the student is enrolled in
    FOREIGN KEY (student_id) REFERENCES Students(student_id),			    -- Links enrollment to an existing student.
    FOREIGN KEY (section_id) REFERENCES Course_Sections(section_id)			-- Links enrollment to the specific section.	
);

-- ================================================
-- 12. Assessments
-- Evaluations (quiz, exam, assignment) linked to course sections.
-- ================================================
CREATE TABLE Assessments (
    assessment_id INT PRIMARY KEY,           									-- Unique identifier for the assessment
    section_id INT NOT NULL,                 									-- Related course section
    type VARCHAR(50) CHECK (type IN ('quiz', 'exam', 'assignment')), 			-- Type of assessment
    title VARCHAR(100) NOT NULL,             									-- Assessment title
    weight_pct DECIMAL(5,2) CHECK (weight_pct >= 0 AND weight_pct <= 100), 		-- Percentage weight
    due_date DATE NOT NULL,                  									-- Due date
    FOREIGN KEY (section_id) REFERENCES Course_Sections(section_id)				-- Associates the assessment with the section in which it will be given.
);

-- ================================================
-- 13. Grades
-- Student grades for specific assessments.
-- Ensures each student has only one grade per assessment.
-- ================================================
CREATE TABLE Grades (
    grade_id INT PRIMARY KEY,                								-- Unique identifier for the grade
    assessment_id INT NOT NULL,              								-- Related assessment
    student_id INT NOT NULL,                 								-- Related student
    score DECIMAL(5,2) CHECK (score >= 0 AND score <= 100), 				-- Score obtained
    graded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 							-- Timestamp when grade was recorded
    UNIQUE (assessment_id, student_id),      								-- Constraint: one student cannot have two grades for the same assessment
    FOREIGN KEY (assessment_id) REFERENCES Assessments(assessment_id),		-- Links the grade to the specific assessment (quiz/exam/assignment).
    FOREIGN KEY (student_id) REFERENCES Students(student_id)				-- Links the grade to the student who received it.
);

-- ================================================
-- 14. Payments
-- Records payments made by students for academic terms.
-- ================================================
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,              						-- Unique identifier for the payment
    student_id INT NOT NULL,                 						-- Student making the payment
    term_id INT NOT NULL,                    						-- Term the payment is for
    amount DECIMAL(10,2) CHECK (amount >= 0),						-- Payment amount
    payment_date DATE NOT NULL,              						-- Payment date
    payment_type VARCHAR(50),                						-- Payment method (e.g. card, cash)
    invoice_xml TEXT,                        						-- Invoice information stored as XML
    FOREIGN KEY (student_id) REFERENCES Students(student_id),		-- Associates the payment record with the student who paid.
    FOREIGN KEY (term_id) REFERENCES Terms(term_id)					-- Associates the payment with the academic term it covers.
);

-- =================================================
-- 15. Payments_Log
-- Records to track the payments made by students.
-- =================================================
CREATE TABLE Payments_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,     -- Unique identifier for the log entry
    payment_id INT NOT NULL,                   -- ID of the recorded payment
    student_id INT NOT NULL,                   -- ID of the student
    term_id INT NOT NULL,                      -- Academic term ID
    amount DECIMAL(10,2) CHECK (amount >= 0),  -- Payment amount
    payment_date DATE NOT NULL,                -- Date of the payment
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Timestamp when the log was created
);


/* ===================================================
   DATABASE VIEWS
   =================================================== */

-- ===================================================
-- View 1: Student_Program_Info
-- Combines student data with their program and department.
-- Useful for quickly seeing which program and department
-- each student belongs to.
-- ===================================================
CREATE VIEW Student_Program_Info AS
SELECT 
    s.student_id, 
    s.first_name, 
    s.last_name, 
    s.email, 
    s.status, 
    p.name AS program_name, 
    p.degree_level, 
    d.name AS department_name
FROM Students s
JOIN Programs p ON s.program_id = p.program_id
JOIN Departments d ON p.department_id = d.department_id;

-- ===================================================
-- View 2: Course_Section_Schedule
-- Provides a complete view of course sections, their term,
-- assigned instructor, and classroom.
-- Useful for administrators when building timetables.
-- ===================================================
CREATE VIEW Course_Section_Schedule AS
SELECT 
    cs.section_id,
    c.title AS course_title,
    cs.section_code,
    t.name AS term_name,
    r.building, 
    r.room_number,
    sch.day_of_week,
    sch.start_time,
    sch.end_time,
    i.first_name || ' ' || i.last_name AS instructor_name
FROM Course_Sections cs
JOIN Courses c ON cs.course_id = c.course_id
JOIN Terms t ON cs.term_id = t.term_id
JOIN Schedules sch ON cs.section_id = sch.section_id
JOIN Rooms r ON sch.room_id = r.room_id
JOIN Instructors i ON sch.instructor_id = i.instructor_id;

-- ===================================================
-- View 3: Student_Enrollments
-- Shows which students are enrolled in which course sections,
-- along with instructor and term details.
-- Useful for checking rosters.
-- ===================================================
CREATE VIEW Student_Enrollments AS
SELECT 
    e.enrollment_id,
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    c.title AS course_title,
    cs.section_code,
    t.name AS term_name,
    i.first_name || ' ' || i.last_name AS instructor_name
FROM Enrollments e
JOIN Students s ON e.student_id = s.student_id
JOIN Course_Sections cs ON e.section_id = cs.section_id
JOIN Courses c ON cs.course_id = c.course_id
JOIN Terms t ON cs.term_id = t.term_id
JOIN Schedules sch ON cs.section_id = sch.section_id
JOIN Instructors i ON sch.instructor_id = i.instructor_id;

-- ===================================================
-- View 4: Student_Grades_Report
-- Displays grades per student per assessment,
-- including course, section, and instructor context.
-- Useful for academic performance reports.
-- ===================================================
CREATE VIEW Student_Grades_Report AS
SELECT 
    g.grade_id,
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    c.title AS course_title,
    cs.section_code,
    a.type AS assessment_type,
    a.title AS assessment_title,
    g.score,
    g.graded_at,
    i.first_name || ' ' || i.last_name AS instructor_name
FROM Grades g
JOIN Students s ON g.student_id = s.student_id
JOIN Assessments a ON g.assessment_id = a.assessment_id
JOIN Course_Sections cs ON a.section_id = cs.section_id
JOIN Courses c ON cs.course_id = c.course_id
JOIN Schedules sch ON cs.section_id = sch.section_id
JOIN Instructors i ON sch.instructor_id = i.instructor_id;

-- ===================================================
-- View 5: Active_Student_Info
-- Shows only students with 'active' status along with their
-- program and department info.
-- Useful for reports focusing on currently active students.
-- ===================================================
CREATE VIEW Active_Student_Info AS
SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    s.email,
    s.status,
    p.name AS program_name,
    d.name AS department_name
FROM Students s
JOIN Programs p ON s.program_id = p.program_id
JOIN Departments d ON p.department_id = d.department_id
WHERE s.status = 'active';

-- ===================================================
-- View 6: Instructor_Timetable
-- Displays the teaching schedule for each instructor,
-- including course, section, day, time, and room.
-- Useful for instructors and administrators.
-- ===================================================
CREATE VIEW Instructor_Timetable AS
SELECT 
    i.instructor_id,
    i.first_name,
    i.last_name,
    c.title AS course_title,
    cs.section_code,
    sch.day_of_week,
    sch.start_time,
    sch.end_time,
    r.building,
    r.room_number
FROM Instructors i
JOIN Schedules sch ON i.instructor_id = sch.instructor_id
JOIN Course_Sections cs ON sch.section_id = cs.section_id
JOIN Courses c ON cs.course_id = c.course_id
JOIN Rooms r ON sch.room_id = r.room_id;


/* ===================================================
   DATABASE STORED PROCEDURES
   =================================================== */

-- ===================================================
-- Stored Procedure: Enroll_Student
-- Adds a student to a course section and checks capacity.
-- Prevents enrollment if the section is full.
-- ===================================================
DELIMITER //

CREATE PROCEDURE Enroll_Student (
    IN p_student_id INT,
    IN p_section_id INT
)
BEGIN
    DECLARE section_capacity INT;
    DECLARE enrolled_count INT;

    -- Get section capacity
    SELECT capacity INTO section_capacity
    FROM Course_Sections
    WHERE section_id = p_section_id;

    -- Count currently enrolled students
    SELECT COUNT(*) INTO enrolled_count
    FROM Enrollments
    WHERE section_id = p_section_id;

    -- Check if there is room
    IF enrolled_count < section_capacity THEN
        INSERT INTO Enrollments(student_id, section_id)
        VALUES (p_student_id, p_section_id);
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Section is full, cannot enroll student';
    END IF;
END //

DELIMITER ;

-- ===================================================
-- Stored Procedure: Assign_Instructor_Section
-- Assigns an instructor to a course section.
-- Checks for schedule conflicts before assignment.
-- ===================================================
DELIMITER //

CREATE PROCEDURE Assign_Instructor_Section (
    IN p_instructor_id INT,
    IN p_section_id INT,
    IN p_day VARCHAR(10),
    IN p_start TIME,
    IN p_end TIME
)
BEGIN
    DECLARE conflict_count INT;

    -- Check for schedule conflicts
    SELECT COUNT(*) INTO conflict_count
    FROM Schedules
    WHERE instructor_id = p_instructor_id
      AND day_of_week = p_day
      AND ((start_time < p_end AND end_time > p_start));

    IF conflict_count = 0 THEN
        INSERT INTO Schedules(section_id, room_id, instructor_id, day_of_week, start_time, end_time)
        VALUES (p_section_id, NULL, p_instructor_id, p_day, p_start, p_end);
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Schedule conflict: Instructor cannot be assigned';
    END IF;
END //

DELIMITER ;

-- ===================================================
-- Stored Procedure: Calculate_Student_GPA
-- Calculates the weighted GPA for a student based on scores and assessment weights.
-- ===================================================
DELIMITER //

CREATE PROCEDURE Calculate_Student_GPA (
    IN p_student_id INT,
    OUT p_gpa DECIMAL(5,2)
)
BEGIN
    SELECT 
        SUM(g.score * a.weight_pct / 100) / SUM(a.weight_pct) 
    INTO p_gpa
    FROM Grades g
    JOIN Assessments a ON g.assessment_id = a.assessment_id
    WHERE g.student_id = p_student_id;
END //

DELIMITER ;

-- ===================================================
-- Stored Procedure: Generate_Payment_Report
-- Returns a summary of payments for a given student.
-- ===================================================
DELIMITER //

CREATE PROCEDURE Generate_Payment_Report (
    IN p_student_id INT
)
BEGIN
    SELECT 
        payment_id,
        term_id,
        amount,
        payment_date,
        payment_type
    FROM Payments
    WHERE student_id = p_student_id
    ORDER BY payment_date DESC;
END //

DELIMITER ;


/* ===================================================
   DATABASE TRIGGERS
   =================================================== */
   
-- ===================================================
-- Trigger: Update_Student_Status
-- Automatically updates student status to 'graduated'
-- when they complete all required credits for their program.
-- ===================================================
DELIMITER //

CREATE TRIGGER Update_Student_Status
AFTER INSERT ON Grades
FOR EACH ROW
BEGIN
    DECLARE total_credits INT;

    -- Sum credits of all courses with passing grades
    SELECT SUM(c.credits) INTO total_credits
    FROM Enrollments e
    JOIN Course_Sections cs ON e.section_id = cs.section_id
    JOIN Courses c ON cs.course_id = c.course_id
    JOIN Grades g ON g.student_id = e.student_id AND g.assessment_id IN (
        SELECT assessment_id FROM Assessments WHERE score >= 50
    )
    WHERE e.student_id = NEW.student_id;

    -- Update student status if they have enough credits
    IF total_credits >= (
        SELECT credits_required 
        FROM Programs p
        JOIN Students s ON s.program_id = p.program_id
        WHERE s.student_id = NEW.student_id
    ) THEN
        UPDATE Students
        SET status = 'graduated'
        WHERE student_id = NEW.student_id;
    END IF;
END //

DELIMITER ;

-- ===================================================
-- Trigger: Log_Payment_Insert
-- Automatically logs every new payment into Payments_Log table for auditing.
-- ===================================================
DELIMITER //

CREATE TRIGGER Log_Payment_Insert
AFTER INSERT ON Payments
FOR EACH ROW
BEGIN
    INSERT INTO Payments_Log(payment_id, student_id, term_id, amount, payment_date)
    VALUES (NEW.payment_id, NEW.student_id, NEW.term_id, NEW.amount, NEW.payment_date);
END //

DELIMITER ;

-- ===================================================
-- Trigger: Prevent_Duplicate_Enrollment
-- Prevents a student from being enrolled in the same section twice.
-- ===================================================
DELIMITER //

CREATE TRIGGER Prevent_Duplicate_Enrollment
BEFORE INSERT ON Enrollments
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM Enrollments
        WHERE student_id = NEW.student_id
          AND section_id = NEW.section_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Student is already enrolled in this section';
    END IF;
END //

DELIMITER ;

-- Indexes to Optimize Queries
-- ===================================================
-- Optimized Indexes for university_system_management
-- ===================================================


/* ===================================================
   DATABASE INDEXES
   =================================================== */
   
-- Students: Search students by program_id
CREATE INDEX idx_students_program ON Students(program_id);

-- Instructors: already has UNIQUE index on email, so only add department lookup
CREATE INDEX idx_instructors_department ON Instructors(department_id);

-- Courses: frequently searched by department and title
CREATE INDEX idx_courses_department ON Courses(department_id);
CREATE INDEX idx_courses_title ON Courses(title);

-- Enrollments: queries usually filter by student or course
CREATE INDEX idx_enrollments_student ON Enrollments(student_id);
CREATE INDEX idx_enrollments_section ON Enrollments(section_id);

-- Assessments: access by section and assessment_type
CREATE INDEX idx_assessments_course ON Assessments(section_id);
CREATE INDEX idx_assessments_type ON Assessments(type);

-- Grades: search by student and course (via assessment)
CREATE INDEX idx_grades_student_assessment ON Grades(student_id, assessment_id);

-- Payments: queries by student and term (payment history per student)
CREATE INDEX idx_payments_student_term ON Payments(student_id, term_id);

-- Programs: often filtered by department
CREATE INDEX idx_programs_department ON Programs(department_id);


-- ============================================================================= --


/* ===================================================
Data Manipulation Language (DML)
Demonstrate INSERT, UPDATE, and DELETE operations
with realistic records across tables.
=================================================== */

-- =====================================
-- INSERTS: Deparments
-- =====================================
INSERT INTO Departments (department_id, name, chair_instructor_id) VALUES
(1, 'Engineering', NULL),
(2, 'Business', NULL),
(3, 'Arts', NULL),
(4, 'Health Sciences', NULL),
(5, 'Computer Science', NULL);

-- =====================================
-- INSERTS: Programs
-- =====================================
INSERT INTO Programs (program_id, department_id, name, degree_level, credits_required) VALUES
(101, 1, 'Mechanical Engineering', 'Bachelor', 120),
(102, 2, 'Marketing', 'Bachelor', 120),
(103, 3, 'Graphic Design', 'Bachelor', 120),
(104, 4, 'Nursing', 'Bachelor', 120),
(105, 5, 'Data Analytics', 'Master', 60),
(106, 5, 'Software Development', 'Bachelor', 120),
(107, 2, 'Finance', 'Master', 60),
(108, 1, 'Civil Engineering', 'Bachelor', 120),
(109, 3, 'Music Theory', 'Bachelor', 120),
(110, 4, 'Public Health', 'Master', 60);

-- =====================================
-- INSERTS: Academic Terms
-- =====================================
INSERT INTO Terms (term_id, name, start_date, end_date) VALUES
(1, 'Term 1', '2025-09-01', '2025-12-10');
INSERT INTO Terms (term_id, name, start_date, end_date) VALUES
(2, 'Term 2', '2025-12-30', '2026-04-09');
INSERT INTO Terms (term_id, name, start_date, end_date) VALUES
(3, 'Term 3', '2026-04-29', '2026-08-07');

-- =====================================
-- INSERTS: Instructors
-- =====================================
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(1, 4, 'Danielle', 'Johnson', 'john21@example.net', 'Lecturer');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(2, 3, 'Joy', 'Gardner', 'fjohnson@example.org', 'Adjunct Instructor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(3, 1, 'Jesse', 'Guzman', 'jennifermiles@example.com', 'Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(4, 4, 'Jeffrey', 'Lawrence', 'blakeerik@example.com', 'Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(5, 1, 'Matthew', 'Moore', 'curtis61@example.com', 'Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(6, 1, 'Melanie', 'Munoz', 'blairamanda@example.com', 'Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(7, 2, 'Christian', 'Carter', 'barbara10@example.net', 'Associate Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(8, 2, 'Jeremy', 'Roberts', 'wyattmichelle@example.com', 'Lecturer');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(9, 5, 'Joshua', 'Reid', 'francisco53@example.net', 'Assistant Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(10, 3, 'Joseph', 'Zuniga', 'lynchgeorge@example.net', 'Associate Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(11, 5, 'John', 'Ford', 'veronica83@example.net', 'Associate Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(12, 4, 'Mark', 'Tate', 'perezantonio@example.com', 'Lecturer');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(13, 5, 'Richard', 'Jones', 'jason76@example.net', 'Lecturer');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(14, 3, 'Stephen', 'Baker', 'julieryan@example.net', 'Adjunct Instructor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(15, 1, 'Brenda', 'Hurst', 'icox@example.net', 'Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(16, 4, 'Trevor', 'Campos', 'hernandezernest@example.net', 'Adjunct Instructor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(17, 4, 'Robert', 'Brown', 'dcarlson@example.net', 'Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(18, 1, 'John', 'Tran', 'frazierdanny@example.net', 'Assistant Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(19, 4, 'Karen', 'Mack', 'daniel62@example.com', 'Assistant Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(20, 3, 'Aaron', 'Bowen', 'teresa28@example.org', 'Assistant Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(21, 5, 'Monica', 'Evans', 'ericfarmer@example.net', 'Lecturer');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(22, 4, 'Stephanie', 'Nielsen', 'georgetracy@example.org', 'Associate Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(23, 5, 'Sarah', 'Koch', 'john39@example.org', 'Assistant Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(24, 1, 'Christopher', 'Tucker', 'spenceamanda@example.org', 'Assistant Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(25, 2, 'David', 'Alvarez', 'josephbrennan@example.com', 'Adjunct Instructor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(26, 1, 'Tamara', 'Hickman', 'jenniferross@example.net', 'Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(27, 2, 'Debra', 'Kim', 'omartinez@example.org', 'Associate Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(28, 4, 'Matthew', 'Chapman', 'briannasmith@example.net', 'Lecturer');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(29, 3, 'Crystal', 'Perez', 'heathchad@example.org', 'Assistant Professor');
INSERT INTO Instructors (instructor_id, department_id, first_name, last_name, email, rank_title) VALUES
(30, 2, 'Joshua', 'Washington', 'jenniferkhan@example.net', 'Associate Professor');

-- =====================================
-- INSERTS: Students
-- =====================================
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1001, 106, 'Kristen', 'Aguirre', 'clintonhopkins@example.com', 'active', '{"language":"es","interests":["material","eight"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1002, 107, 'Stuart', 'Daniel', 'brownjessica@example.org', 'graduated', '{"language":"es","interests":["land","item"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1003, 103, 'James', 'West', 'dwhite@example.org', 'inactive', '{"language":"es","interests":["energy","dark"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1004, 104, 'Charles', 'Morton', 'williamsyvette@example.org', 'active', '{"language":"es","interests":["two","wind"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1005, 104, 'Karen', 'Young', 'ntucker@example.com', 'inactive', '{"language":"fr","interests":["better","with"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1006, 110, 'Franklin', 'Smith', 'ybaker@example.com', 'inactive', '{"language":"en","interests":["weight","artist"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1007, 105, 'Heather', 'Cross', 'smoore@example.org', 'graduated', '{"language":"fr","interests":["feeling","land"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1008, 106, 'Jill', 'Brown', 'brian97@example.net', 'graduated', '{"language":"es","interests":["article","particularly"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1009, 107, 'Amanda', 'Brown', 'yorkcasey@example.org', 'inactive', '{"language":"en","interests":["wide","tonight"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1010, 109, 'Joe', 'Wilson', 'bethwilliams@example.org', 'active', '{"language":"en","interests":["Republican","training"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1011, 102, 'Brandy', 'Mills', 'james53@example.com', 'active', '{"language":"en","interests":["kind","really"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1012, 102, 'Emily', 'Evans', 'sarah10@example.com', 'active', '{"language":"en","interests":["individual","catch"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1013, 108, 'Wendy', 'Jones', 'williamanderson@example.com', 'graduated', '{"language":"en","interests":["pretty","order"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1014, 105, 'Natasha', 'Wood', 'samueldaniels@example.com', 'graduated', '{"language":"fr","interests":["upon","authority"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1015, 106, 'Destiny', 'Smith', 'sarah12@example.com', 'active', '{"language":"en","interests":["population","surface"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1016, 101, 'Daniel', 'Tran', 'juan35@example.org', 'graduated', '{"language":"es","interests":["business","voice"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1017, 110, 'Melissa', 'Wagner', 'rebecca01@example.net', 'inactive', '{"language":"fr","interests":["right","protect"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1018, 105, 'Joshua', 'Smith', 'danagreen@example.net', 'inactive', '{"language":"en","interests":["land","themselves"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1019, 103, 'Janice', 'Hoffman', 'jonesnicole@example.org', 'inactive', '{"language":"en","interests":["letter","ok"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1020, 108, 'Mary', 'Aguilar', 'russellwilliams@example.com', 'graduated', '{"language":"fr","interests":["offer","also"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1021, 108, 'Laura', 'Valencia', 'jason31@example.com', 'inactive', '{"language":"en","interests":["way","worker"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1022, 107, 'Nicole', 'Russell', 'sarayoung@example.org', 'graduated', '{"language":"es","interests":["state","opportunity"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1023, 109, 'Gregory', 'Gutierrez', 'jillcook@example.com', 'graduated', '{"language":"en","interests":["such","talk"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1024, 109, 'Michelle', 'Cochran', 'erik16@example.org', 'graduated', '{"language":"en","interests":["suffer","relationship"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1025, 107, 'Jeffrey', 'Velasquez', 'ybailey@example.org', 'graduated', '{"language":"es","interests":["town","many"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1026, 106, 'Donna', 'Ross', 'michelle45@example.net', 'inactive', '{"language":"en","interests":["dog","agent"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1027, 106, 'Erin', 'Anthony', 'sheila14@example.org', 'graduated', '{"language":"es","interests":["Mr","instead"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1028, 103, 'Benjamin', 'Carlson', 'jessica56@example.net', 'graduated', '{"language":"fr","interests":["partner","evidence"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1029, 109, 'Paul', 'Ray', 'bradley60@example.net', 'active', '{"language":"en","interests":["much","business"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1030, 104, 'Amanda', 'Ball', 'michaeljones@example.net', 'active', '{"language":"es","interests":["wish","sure"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1031, 110, 'Cindy', 'Alvarado', 'cortezkevin@example.com', 'active', '{"language":"es","interests":["wife","give"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1032, 104, 'Mark', 'Terry', 'jamesortega@example.com', 'inactive', '{"language":"fr","interests":["reflect","issue"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1033, 105, 'Raven', 'Gilbert', 'richard04@example.com', 'inactive', '{"language":"en","interests":["research","smile"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1034, 103, 'Kristi', 'Lawson', 'steven73@example.net', 'inactive', '{"language":"en","interests":["develop","law"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1035, 108, 'Rachel', 'Flynn', 'donnacampbell@example.net', 'inactive', '{"language":"en","interests":["material","student"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1036, 102, 'Matthew', 'Cardenas', 'emilywalker@example.org', 'graduated', '{"language":"en","interests":["property","president"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1037, 109, 'Brandon', 'Riggs', 'gibsonolivia@example.net', 'graduated', '{"language":"fr","interests":["choice","ago"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1038, 109, 'Heather', 'Snyder', 'dylanwatts@example.org', 'inactive', '{"language":"fr","interests":["day","serious"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1039, 109, 'Jeffery', 'Brock', 'pwilliams@example.org', 'active', '{"language":"es","interests":["start","large"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1040, 108, 'Laurie', 'Contreras', 'stephanie79@example.net', 'active', '{"language":"es","interests":["loss","cell"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1041, 102, 'Ronald', 'Meadows', 'vmerritt@example.com', 'graduated', '{"language":"fr","interests":["wait","mother"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1042, 108, 'Karen', 'Larsen', 'katie87@example.net', 'inactive', '{"language":"fr","interests":["listen","event"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1043, 109, 'Scott', 'Reeves', 'josephflores@example.net', 'active', '{"language":"fr","interests":["edge","face"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1044, 109, 'Edward', 'Reyes', 'jasminebrown@example.com', 'active', '{"language":"en","interests":["be","certainly"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1045, 110, 'Steven', 'Brown', 'xprice@example.net', 'inactive', '{"language":"es","interests":["give","occur"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1046, 109, 'Andrew', 'Gilmore', 'wwoods@example.com', 'inactive', '{"language":"en","interests":["young","safe"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1047, 105, 'Melissa', 'Ashley', 'vmedina@example.net', 'graduated', '{"language":"fr","interests":["some","in"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1048, 101, 'Rachael', 'Freeman', 'ryan06@example.com', 'graduated', '{"language":"en","interests":["such","player"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1049, 105, 'Lauren', 'Ramsey', 'ncalhoun@example.net', 'graduated', '{"language":"en","interests":["relate","respond"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1050, 102, 'Phillip', 'Elliott', 'millerroy@example.com', 'graduated', '{"language":"es","interests":["agreement","what"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1051, 101, 'Jorge', 'Murphy', 'wmurphy@example.com', 'inactive', '{"language":"es","interests":["court","apply"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1052, 103, 'Stephanie', 'Fisher', 'ruizkaitlyn@example.org', 'active', '{"language":"fr","interests":["fall","soldier"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1053, 102, 'Debra', 'Harrington', 'websterstefanie@example.org', 'active', '{"language":"fr","interests":["hard","door"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1054, 107, 'Christine', 'Allen', 'kcaldwell@example.org', 'inactive', '{"language":"en","interests":["those","again"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1055, 109, 'Jonathan', 'Wood', 'stricklandfrank@example.com', 'active', '{"language":"en","interests":["make","scene"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1056, 108, 'Anthony', 'Collins', 'tsanders@example.org', 'active', '{"language":"en","interests":["box","particular"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1057, 107, 'Hannah', 'Burton', 'terrykevin@example.net', 'graduated', '{"language":"fr","interests":["bag","person"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1058, 104, 'David', 'Riggs', 'reedross@example.com', 'active', '{"language":"es","interests":["plan","support"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1059, 109, 'Deborah', 'Smith', 'gshort@example.com', 'graduated', '{"language":"en","interests":["authority","move"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1060, 108, 'Patricia', 'Stevens', 'ryangross@example.net', 'graduated', '{"language":"fr","interests":["high","prove"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1061, 107, 'Lindsey', 'Medina', 'umarshall@example.net', 'graduated', '{"language":"es","interests":["expect","power"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1062, 102, 'Melissa', 'Rivas', 'ramirezshannon@example.com', 'active', '{"language":"en","interests":["executive","future"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1063, 101, 'Elizabeth', 'Rogers', 'lrosales@example.com', 'graduated', '{"language":"fr","interests":["over","poor"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1064, 102, 'Lauren', 'Peterson', 'angela83@example.org', 'active', '{"language":"es","interests":["difference","hear"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1065, 110, 'Richard', 'Peters', 'hannahbrewer@example.com', 'active', '{"language":"en","interests":["effort","service"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1066, 104, 'Andre', 'Phillips', 'tholt@example.net', 'active', '{"language":"fr","interests":["line","structure"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1067, 106, 'Thomas', 'Schmidt', 'jbarajas@example.com', 'inactive', '{"language":"fr","interests":["party","home"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1068, 102, 'Shawn', 'Parker', 'davidlee@example.org', 'graduated', '{"language":"es","interests":["he","scientist"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1069, 108, 'Stephanie', 'Vaughn', 'javierwashington@example.net', 'active', '{"language":"fr","interests":["situation","north"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1070, 109, 'Alicia', 'Campbell', 'wallkenneth@example.com', 'graduated', '{"language":"en","interests":["perform","soon"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1071, 108, 'Alexis', 'Ferguson', 'brandon08@example.com', 'active', '{"language":"fr","interests":["country","five"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1072, 101, 'David', 'Oneill', 'agarcia@example.net', 'active', '{"language":"es","interests":["save","yet"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1073, 103, 'Timothy', 'Peterson', 'kingmichelle@example.org', 'active', '{"language":"fr","interests":["feel","manager"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1074, 108, 'Richard', 'Jones', 'hernandezlisa@example.com', 'active', '{"language":"en","interests":["term","attention"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1075, 106, 'David', 'Duran', 'kimberlyjames@example.com', 'active', '{"language":"en","interests":["bed","energy"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1076, 106, 'Brianna', 'Patterson', 'lynchjody@example.org', 'inactive', '{"language":"fr","interests":["finish","trade"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1077, 107, 'Joseph', 'Miller', 'glennjones@example.org', 'graduated', '{"language":"en","interests":["process","development"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1078, 104, 'Hannah', 'Harrison', 'halljasmine@example.net', 'active', '{"language":"en","interests":["issue","little"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1079, 105, 'Charles', 'Hall', 'kristin93@example.com', 'graduated', '{"language":"es","interests":["trade","long"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1080, 102, 'Jeffrey', 'Hernandez', 'margaret10@example.org', 'inactive', '{"language":"fr","interests":["building","off"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1081, 108, 'Brooke', 'Holloway', 'scott74@example.net', 'active', '{"language":"fr","interests":["structure","food"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1082, 101, 'Joseph', 'Fernandez', 'cmiller@example.com', 'inactive', '{"language":"fr","interests":["interesting","yes"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1083, 110, 'Cassandra', 'Johnson', 'suzannehuff@example.net', 'graduated', '{"language":"en","interests":["simple","future"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1084, 101, 'Yvonne', 'Chambers', 'barbara27@example.net', 'active', '{"language":"es","interests":["people","against"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1085, 102, 'Sabrina', 'White', 'fwalters@example.org', 'inactive', '{"language":"es","interests":["reach","letter"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1086, 101, 'Ricky', 'Morris', 'hodgemark@example.net', 'graduated', '{"language":"en","interests":["many","happen"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1087, 106, 'Elaine', 'Morales', 'gibsonleonard@example.com', 'active', '{"language":"fr","interests":["mission","fight"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1088, 102, 'Richard', 'Robertson', 'sandovalamy@example.com', 'inactive', '{"language":"fr","interests":["business","spring"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1089, 105, 'April', 'Dean', 'wgarrett@example.org', 'active', '{"language":"fr","interests":["arm","cup"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1090, 105, 'Andrea', 'Pennington', 'fgilmore@example.org', 'active', '{"language":"en","interests":["Democrat","example"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1091, 110, 'Chelsea', 'Allen', 'lancesmith@example.com', 'graduated', '{"language":"en","interests":["air","professor"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1092, 104, 'Victoria', 'Durham', 'pvalentine@example.org', 'graduated', '{"language":"es","interests":["better","down"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1093, 106, 'Jennifer', 'Hicks', 'robert77@example.org', 'graduated', '{"language":"fr","interests":["moment","worker"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1094, 109, 'Duane', 'Lee', 'michellehill@example.com', 'graduated', '{"language":"es","interests":["loss","ok"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1095, 108, 'Kristin', 'Adams', 'campbellkenneth@example.net', 'active', '{"language":"es","interests":["grow","world"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1096, 102, 'Tracy', 'Hernandez', 'jreed@example.net', 'inactive', '{"language":"fr","interests":["particularly","receive"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1097, 106, 'Sarah', 'Kane', 'ashleyhall@example.com', 'active', '{"language":"en","interests":["huge","lose"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1098, 103, 'Julie', 'Thornton', 'qhughes@example.net', 'graduated', '{"language":"fr","interests":["animal","friend"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1099, 105, 'Tammie', 'Martinez', 'molly71@example.net', 'inactive', '{"language":"fr","interests":["civil","mission"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1100, 101, 'Alexis', 'Thomas', 'charlesharrington@example.com', 'active', '{"language":"es","interests":["whether","loss"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1101, 102, 'Heather', 'Santos', 'melissa86@example.com', 'active', '{"language":"fr","interests":["ground","price"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1102, 106, 'Paige', 'Freeman', 'williamsonjimmy@example.net', 'graduated', '{"language":"es","interests":["produce","serious"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1103, 105, 'Wendy', 'Francis', 'wgood@example.net', 'graduated', '{"language":"en","interests":["will","field"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1104, 102, 'Craig', 'Jackson', 'rebecca05@example.org', 'active', '{"language":"en","interests":["score","turn"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1105, 104, 'Nicholas', 'Thomas', 'yknight@example.org', 'active', '{"language":"en","interests":["finally","her"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1106, 110, 'Christian', 'Pitts', 'tyleraguilar@example.org', 'graduated', '{"language":"es","interests":["conference","continue"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1107, 106, 'Jonathan', 'Scott', 'nolansteven@example.com', 'inactive', '{"language":"fr","interests":["main","pull"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1108, 107, 'Eric', 'Alexander', 'vanessa46@example.net', 'inactive', '{"language":"fr","interests":["research","office"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1109, 109, 'Megan', 'Gonzalez', 'gcastaneda@example.org', 'active', '{"language":"en","interests":["enough","loss"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1110, 102, 'Michael', 'Phillips', 'andrew64@example.org', 'active', '{"language":"fr","interests":["I","owner"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1111, 107, 'Gina', 'Garner', 'lozanojulie@example.com', 'active', '{"language":"fr","interests":["others","treatment"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1112, 106, 'Jerry', 'Pham', 'danaoliver@example.net', 'graduated', '{"language":"es","interests":["stand","successful"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1113, 105, 'Katrina', 'Becker', 'courtneyberger@example.net', 'active', '{"language":"fr","interests":["someone","set"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1114, 108, 'Kristina', 'Johnson', 'jessica14@example.com', 'active', '{"language":"es","interests":["among","for"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1115, 101, 'Gregory', 'Anderson', 'alyssa42@example.com', 'active', '{"language":"fr","interests":["small","just"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1116, 107, 'Sherry', 'Coffey', 'julie51@example.com', 'active', '{"language":"fr","interests":["white","thank"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1117, 107, 'Karen', 'Perez', 'zcoffey@example.net', 'active', '{"language":"fr","interests":["bag","chance"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1118, 108, 'Krystal', 'Smith', 'gibsonemily@example.net', 'active', '{"language":"fr","interests":["history","believe"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1119, 105, 'Parker', 'Little', 'daniel37@example.org', 'graduated', '{"language":"en","interests":["everybody","pattern"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1120, 102, 'Sherry', 'Murphy', 'deborahreid@example.com', 'inactive', '{"language":"en","interests":["president","usually"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1121, 101, 'Kevin', 'Ortiz', 'brandonjohnson@example.com', 'inactive', '{"language":"en","interests":["where","school"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1122, 105, 'Jimmy', 'Medina', 'qchavez@example.net', 'graduated', '{"language":"es","interests":["business","bill"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1123, 103, 'Amber', 'Matthews', 'nicolepena@example.com', 'graduated', '{"language":"es","interests":["same","young"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1124, 101, 'Sheila', 'Ramirez', 'jeff73@example.com', 'inactive', '{"language":"en","interests":["power","involve"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1125, 103, 'Michael', 'Winters', 'bruce43@example.org', 'active', '{"language":"fr","interests":["bit","rich"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1126, 107, 'Shawn', 'Bates', 'williamsmatthew@example.org', 'inactive', '{"language":"en","interests":["thus","than"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1127, 109, 'Jamie', 'Gallegos', 'brendali@example.org', 'graduated', '{"language":"es","interests":["stop","other"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1128, 105, 'Dylan', 'Lester', 'ramireztracey@example.org', 'graduated', '{"language":"fr","interests":["get","staff"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1129, 101, 'Lauren', 'Rodriguez', 'andersonmichael@example.org', 'graduated', '{"language":"es","interests":["now","enough"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1130, 106, 'Alfred', 'Baker', 'judyfox@example.net', 'inactive', '{"language":"fr","interests":["per","game"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1131, 107, 'Shane', 'Cox', 'hayesjeffrey@example.net', 'graduated', '{"language":"en","interests":["attack","maybe"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1132, 105, 'Krista', 'Camacho', 'stephen00@example.com', 'graduated', '{"language":"fr","interests":["animal","short"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1133, 110, 'Ronald', 'Rodriguez', 'fjones@example.com', 'active', '{"language":"en","interests":["throw","interest"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1134, 102, 'Cameron', 'Hill', 'oscar98@example.com', 'graduated', '{"language":"fr","interests":["political","choose"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1135, 101, 'Catherine', 'Garcia', 'farrelldebra@example.net', 'graduated', '{"language":"es","interests":["long","mouth"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1136, 109, 'Jason', 'Hayes', 'robertwilcox@example.com', 'inactive', '{"language":"es","interests":["set","tree"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1137, 105, 'Cody', 'Simmons', 'nicholas27@example.org', 'graduated', '{"language":"es","interests":["just","show"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1138, 110, 'Christopher', 'Reynolds', 'lisa80@example.net', 'graduated', '{"language":"en","interests":["benefit","theory"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1139, 110, 'Mark', 'Martinez', 'morgan60@example.com', 'inactive', '{"language":"fr","interests":["or","or"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1140, 108, 'Michael', 'Lane', 'ericolson@example.org', 'active', '{"language":"es","interests":["plan","forget"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1141, 106, 'Angela', 'Wilson', 'audrey68@example.net', 'graduated', '{"language":"en","interests":["hard","through"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1142, 101, 'Dawn', 'Johnson', 'anthony44@example.com', 'active', '{"language":"en","interests":["positive","Republican"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1143, 109, 'Howard', 'Thomas', 'vjones@example.net', 'inactive', '{"language":"es","interests":["have","according"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1144, 107, 'Julie', 'Lewis', 'kchavez@example.com', 'inactive', '{"language":"es","interests":["allow","benefit"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1145, 102, 'Mark', 'Pugh', 'wareeric@example.net', 'inactive', '{"language":"es","interests":["forget","set"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1146, 108, 'Christopher', 'Ramos', 'ctucker@example.com', 'active', '{"language":"es","interests":["appear","represent"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1147, 102, 'Kari', 'Wilson', 'rrodriguez@example.net', 'graduated', '{"language":"en","interests":["explain","dinner"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1148, 110, 'Alison', 'Parker', 'randallgreene@example.org', 'graduated', '{"language":"en","interests":["personal","message"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1149, 107, 'Sierra', 'Saunders', 'keith10@example.com', 'inactive', '{"language":"en","interests":["democratic","fish"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1150, 107, 'Gregory', 'James', 'vincentwhitaker@example.com', 'inactive', '{"language":"es","interests":["skin","law"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1151, 104, 'Michelle', 'Williams', 'stevenschristian@example.com', 'inactive', '{"language":"en","interests":["away","industry"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1152, 108, 'Ashley', 'Mckinney', 'zroberts@example.org', 'graduated', '{"language":"en","interests":["parent","laugh"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1153, 103, 'Laurie', 'Montgomery', 'christopher13@example.com', 'graduated', '{"language":"es","interests":["garden","Congress"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1154, 102, 'Alexandria', 'Foster', 'julie35@example.org', 'graduated', '{"language":"es","interests":["perform","institution"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1155, 101, 'Cynthia', 'Schmidt', 'rebeccabailey@example.net', 'inactive', '{"language":"en","interests":["ball","Mrs"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1156, 105, 'Lisa', 'Young', 'jonathanthompson@example.org', 'inactive', '{"language":"es","interests":["tell","quite"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1157, 101, 'Diana', 'Thompson', 'kmarshall@example.net', 'active', '{"language":"en","interests":["soon","song"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1158, 108, 'Sandra', 'Cunningham', 'michelle52@example.com', 'inactive', '{"language":"es","interests":["list","responsibility"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1159, 101, 'Scott', 'Turner', 'brittany58@example.org', 'inactive', '{"language":"es","interests":["author","manager"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1160, 107, 'Shannon', 'Brown', 'chase19@example.net', 'active', '{"language":"es","interests":["force","main"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1161, 109, 'Steven', 'Spencer', 'colelisa@example.net', 'inactive', '{"language":"en","interests":["movement","if"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1162, 105, 'Cassidy', 'Mason', 'hayeslisa@example.com', 'graduated', '{"language":"fr","interests":["cup","fund"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1163, 108, 'William', 'Thompson', 'jasmineritter@example.net', 'active', '{"language":"en","interests":["send","become"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1164, 109, 'Erik', 'Watson', 'paul59@example.org', 'inactive', '{"language":"fr","interests":["necessary","poor"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1165, 109, 'Deborah', 'Jones', 'grantpaul@example.com', 'graduated', '{"language":"es","interests":["strategy","program"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1166, 102, 'Diane', 'Escobar', 'mathewaguilar@example.org', 'graduated', '{"language":"fr","interests":["shake","together"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1167, 106, 'Kyle', 'Douglas', 'tanderson@example.org', 'graduated', '{"language":"en","interests":["whom","hard"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1168, 105, 'Nicholas', 'Conner', 'elizabethcalderon@example.net', 'active', '{"language":"es","interests":["force","operation"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1169, 108, 'Alicia', 'Lucas', 'bromero@example.com', 'inactive', '{"language":"es","interests":["reveal","while"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1170, 103, 'Stephanie', 'Peterson', 'ilee@example.org', 'inactive', '{"language":"fr","interests":["for","couple"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1171, 103, 'Megan', 'Garcia', 'stanleynancy@example.net', 'inactive', '{"language":"fr","interests":["bank","find"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1172, 110, 'Nicholas', 'Martin', 'jenniferwilliams@example.com', 'inactive', '{"language":"en","interests":["catch","picture"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1173, 101, 'John', 'Wallace', 'karen73@example.net', 'inactive', '{"language":"es","interests":["require","serve"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1174, 102, 'Tammy', 'Mueller', 'michealvalentine@example.com', 'inactive', '{"language":"fr","interests":["edge","for"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1175, 107, 'Juan', 'Reyes', 'mburch@example.net', 'graduated', '{"language":"fr","interests":["main","specific"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1176, 103, 'John', 'Davidson', 'angela18@example.org', 'graduated', '{"language":"en","interests":["certainly","turn"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1177, 110, 'Kathryn', 'Nelson', 'mariahdavis@example.org', 'graduated', '{"language":"es","interests":["feel","because"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1178, 110, 'Nicole', 'Arias', 'gbrown@example.com', 'graduated', '{"language":"fr","interests":["technology","little"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1179, 102, 'Virginia', 'Brooks', 'florescory@example.net', 'graduated', '{"language":"fr","interests":["eat","imagine"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1180, 103, 'Lacey', 'Taylor', 'samantha72@example.net', 'active', '{"language":"es","interests":["rate","government"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1181, 103, 'Christina', 'Bullock', 'scottmary@example.net', 'inactive', '{"language":"en","interests":["manager","list"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1182, 104, 'Chelsea', 'Henderson', 'john10@example.org', 'active', '{"language":"en","interests":["yard","short"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1183, 107, 'Laura', 'Bryant', 'copelandvincent@example.net', 'graduated', '{"language":"en","interests":["kind","purpose"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1184, 103, 'Zachary', 'Allen', 'kellysmith@example.com', 'graduated', '{"language":"fr","interests":["admit","project"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1185, 110, 'Robert', 'Beck', 'millsmichael@example.net', 'active', '{"language":"en","interests":["effect","own"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1186, 105, 'Kristin', 'Romero', 'myerstheodore@example.net', 'active', '{"language":"en","interests":["off","movement"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1187, 102, 'Jon', 'Smith', 'cooperjessica@example.net', 'inactive', '{"language":"es","interests":["impact","hour"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1188, 103, 'Bonnie', 'Sherman', 'bradleypayne@example.net', 'active', '{"language":"fr","interests":["body","sport"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1189, 101, 'Kimberly', 'Marshall', 'zwelch@example.org', 'graduated', '{"language":"fr","interests":["continue","then"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1190, 102, 'Kimberly', 'Ellis', 'james30@example.com', 'inactive', '{"language":"fr","interests":["at","sense"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1191, 101, 'Zachary', 'Hays', 'wking@example.net', 'inactive', '{"language":"es","interests":["worker","force"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1192, 102, 'Michael', 'Norman', 'joshua56@example.com', 'inactive', '{"language":"fr","interests":["cut","feeling"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1193, 102, 'Patricia', 'Hughes', 'tylerjimenez@example.net', 'graduated', '{"language":"en","interests":["six","less"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1194, 104, 'Christopher', 'Coleman', 'lmorrison@example.net', 'inactive', '{"language":"es","interests":["example","suddenly"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1195, 107, 'Curtis', 'Murphy', 'kirk96@example.org', 'inactive', '{"language":"fr","interests":["finally","full"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1196, 108, 'Michael', 'Williams', 'christina64@example.net', 'graduated', '{"language":"fr","interests":["road","life"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1197, 108, 'Brian', 'Lambert', 'zcox@example.net', 'active', '{"language":"en","interests":["strong","yourself"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1198, 101, 'Stephanie', 'Thomas', 'ejohnson@example.org', 'active', '{"language":"en","interests":["respond","collection"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1199, 101, 'Michael', 'Reyes', 'jacobserika@example.com', 'graduated', '{"language":"es","interests":["start","quite"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1200, 106, 'Kathryn', 'Berry', 'raymond43@example.org', 'active', '{"language":"es","interests":["hot","life"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1201, 109, 'Jacob', 'Holmes', 'greenjorge@example.com', 'inactive', '{"language":"fr","interests":["agree","simply"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1202, 103, 'Justin', 'Hendricks', 'igonzalez@example.org', 'inactive', '{"language":"en","interests":["difficult","population"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1203, 109, 'Rachel', 'Wallace', 'cochrantammy@example.com', 'active', '{"language":"fr","interests":["live","consider"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1204, 104, 'Jenna', 'Pierce', 'patricia22@example.com', 'graduated', '{"language":"es","interests":["region","hand"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1205, 103, 'David', 'Harris', 'joelsnyder@example.com', 'active', '{"language":"es","interests":["movie","door"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1206, 106, 'Miguel', 'Lara', 'cherylmiller@example.com', 'inactive', '{"language":"en","interests":["once","page"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1207, 108, 'Jennifer', 'Fox', 'emorrow@example.org', 'inactive', '{"language":"fr","interests":["information","series"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1208, 106, 'Charles', 'Owens', 'david89@example.org', 'graduated', '{"language":"fr","interests":["free","quality"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1209, 104, 'Ryan', 'Bartlett', 'guerraapril@example.com', 'active', '{"language":"es","interests":["special","carry"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1210, 103, 'Marcus', 'Fletcher', 'stacey84@example.org', 'inactive', '{"language":"es","interests":["community","color"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1211, 103, 'Cynthia', 'Pierce', 'colleenmendez@example.org', 'graduated', '{"language":"en","interests":["enough","debate"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1212, 101, 'Gary', 'David', 'georgeweber@example.net', 'graduated', '{"language":"en","interests":["morning","put"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1213, 108, 'Sandra', 'Williams', 'millerstacy@example.net', 'active', '{"language":"es","interests":["green","thousand"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1214, 108, 'Jason', 'Armstrong', 'jimenezcourtney@example.com', 'active', '{"language":"es","interests":["evidence","rather"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1215, 107, 'Timothy', 'Ballard', 'eevans@example.net', 'inactive', '{"language":"fr","interests":["quality","five"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1216, 109, 'Scott', 'Washington', 'matthewthomas@example.net', 'active', '{"language":"es","interests":["as","coach"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1217, 105, 'Vanessa', 'Reed', 'xanderson@example.net', 'active', '{"language":"fr","interests":["from","similar"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1218, 103, 'Luis', 'Owens', 'shannon21@example.org', 'active', '{"language":"en","interests":["or","born"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1219, 110, 'Patrick', 'Gilbert', 'sydneybarrera@example.com', 'graduated', '{"language":"en","interests":["fill","young"]}');
INSERT INTO Students (student_id, program_id, first_name, last_name, email, status, profile_json) VALUES
(1220, 108, 'Jennifer', 'Lee', 'tyronerobertson@example.com', 'inactive', '{"language":"fr","interests":["world","participant"]}');

-- =====================================
-- INSERTS: Payments
-- =====================================
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5001, 1026, 1, 1200.7, '2025-08-17', 'cash', '<invoice><student>1026</student><amount>1200.7</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5002, 1069, 1, 1644.05, '2025-01-07', 'card', '<invoice><student>1069</student><amount>1644.05</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5003, 1056, 3, 1812.33, '2025-03-22', 'cash', '<invoice><student>1056</student><amount>1812.33</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5004, 1178, 3, 1544.78, '2024-09-19', 'card', '<invoice><student>1178</student><amount>1544.78</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5005, 1040, 1, 1445.08, '2024-10-14', 'cash', '<invoice><student>1040</student><amount>1445.08</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5006, 1217, 1, 1376.34, '2025-02-09', 'card', '<invoice><student>1217</student><amount>1376.34</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5007, 1007, 1, 702.91, '2025-03-25', 'transfer', '<invoice><student>1007</student><amount>702.91</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5008, 1022, 2, 1671.68, '2025-03-06', 'transfer', '<invoice><student>1022</student><amount>1671.68</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5009, 1043, 2, 1147.43, '2024-12-12', 'cash', '<invoice><student>1043</student><amount>1147.43</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5010, 1135, 2, 1666.02, '2024-12-02', 'transfer', '<invoice><student>1135</student><amount>1666.02</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5011, 1156, 2, 1667.34, '2025-04-24', 'cash', '<invoice><student>1156</student><amount>1667.34</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5012, 1127, 1, 1837.82, '2025-01-25', 'card', '<invoice><student>1127</student><amount>1837.82</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5013, 1082, 1, 1241.12, '2024-09-28', 'transfer', '<invoice><student>1082</student><amount>1241.12</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5014, 1188, 1, 820.55, '2024-09-29', 'cash', '<invoice><student>1188</student><amount>820.55</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5015, 1100, 2, 1406.81, '2024-12-28', 'transfer', '<invoice><student>1100</student><amount>1406.81</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5016, 1081, 3, 1529.53, '2025-03-21', 'cash', '<invoice><student>1081</student><amount>1529.53</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5017, 1009, 2, 517.67, '2025-04-30', 'cash', '<invoice><student>1009</student><amount>517.67</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5018, 1083, 2, 1784.78, '2025-08-18', 'cash', '<invoice><student>1083</student><amount>1784.78</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5019, 1145, 1, 942.56, '2025-08-03', 'cash', '<invoice><student>1145</student><amount>942.56</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5020, 1201, 3, 1777.79, '2025-05-22', 'transfer', '<invoice><student>1201</student><amount>1777.79</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5021, 1162, 1, 1930.95, '2025-05-29', 'cash', '<invoice><student>1162</student><amount>1930.95</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5022, 1114, 3, 882.58, '2025-03-11', 'cash', '<invoice><student>1114</student><amount>882.58</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5023, 1189, 1, 1743.76, '2024-12-29', 'card', '<invoice><student>1189</student><amount>1743.76</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5024, 1018, 3, 1271.66, '2025-04-06', 'card', '<invoice><student>1018</student><amount>1271.66</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5025, 1201, 3, 1121.35, '2024-09-13', 'cash', '<invoice><student>1201</student><amount>1121.35</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5026, 1125, 1, 605.22, '2025-08-05', 'transfer', '<invoice><student>1125</student><amount>605.22</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5027, 1182, 3, 1351.84, '2024-10-21', 'transfer', '<invoice><student>1182</student><amount>1351.84</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5028, 1113, 3, 1412.38, '2025-02-24', 'transfer', '<invoice><student>1113</student><amount>1412.38</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5029, 1188, 2, 1023.8, '2024-11-01', 'cash', '<invoice><student>1188</student><amount>1023.8</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5030, 1073, 1, 1556.52, '2025-08-18', 'card', '<invoice><student>1073</student><amount>1556.52</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5031, 1114, 2, 1871.43, '2024-12-21', 'card', '<invoice><student>1114</student><amount>1871.43</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5032, 1046, 3, 671.81, '2025-06-19', 'transfer', '<invoice><student>1046</student><amount>671.81</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5033, 1167, 3, 1741.1, '2025-01-30', 'card', '<invoice><student>1167</student><amount>1741.1</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5034, 1200, 1, 751.06, '2025-07-03', 'card', '<invoice><student>1200</student><amount>751.06</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5035, 1122, 3, 869.28, '2025-02-13', 'card', '<invoice><student>1122</student><amount>869.28</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5036, 1026, 1, 1727.91, '2025-01-30', 'cash', '<invoice><student>1026</student><amount>1727.91</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5037, 1053, 2, 1928.59, '2024-09-27', 'cash', '<invoice><student>1053</student><amount>1928.59</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5038, 1133, 1, 1269.93, '2025-02-12', 'card', '<invoice><student>1133</student><amount>1269.93</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5039, 1149, 1, 518.26, '2024-09-29', 'card', '<invoice><student>1149</student><amount>518.26</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5040, 1042, 2, 1941.2, '2025-04-19', 'cash', '<invoice><student>1042</student><amount>1941.2</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5041, 1120, 2, 1862.04, '2025-04-16', 'cash', '<invoice><student>1120</student><amount>1862.04</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5042, 1164, 3, 1094.97, '2024-11-24', 'card', '<invoice><student>1164</student><amount>1094.97</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5043, 1133, 2, 1709.55, '2025-01-28', 'card', '<invoice><student>1133</student><amount>1709.55</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5044, 1067, 1, 977.16, '2025-04-12', 'cash', '<invoice><student>1067</student><amount>977.16</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5045, 1108, 3, 1146.17, '2024-12-31', 'card', '<invoice><student>1108</student><amount>1146.17</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5046, 1062, 2, 753.41, '2024-10-08', 'cash', '<invoice><student>1062</student><amount>753.41</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5047, 1027, 3, 1427.28, '2025-02-07', 'cash', '<invoice><student>1027</student><amount>1427.28</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5048, 1023, 2, 817.95, '2025-03-24', 'cash', '<invoice><student>1023</student><amount>817.95</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5049, 1022, 1, 708.64, '2025-03-03', 'cash', '<invoice><student>1022</student><amount>708.64</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5050, 1132, 2, 1132.39, '2025-07-03', 'cash', '<invoice><student>1132</student><amount>1132.39</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5051, 1059, 1, 1690.59, '2025-04-11', 'transfer', '<invoice><student>1059</student><amount>1690.59</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5052, 1216, 2, 1473.37, '2024-12-27', 'card', '<invoice><student>1216</student><amount>1473.37</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5053, 1139, 3, 1615.98, '2025-07-27', 'cash', '<invoice><student>1139</student><amount>1615.98</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5054, 1090, 1, 1232.27, '2025-05-10', 'card', '<invoice><student>1090</student><amount>1232.27</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5055, 1167, 2, 1677.59, '2025-06-01', 'card', '<invoice><student>1167</student><amount>1677.59</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5056, 1014, 1, 1367.28, '2025-05-05', 'transfer', '<invoice><student>1014</student><amount>1367.28</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5057, 1189, 2, 1950.98, '2024-10-26', 'transfer', '<invoice><student>1189</student><amount>1950.98</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5058, 1060, 1, 947.24, '2024-10-29', 'cash', '<invoice><student>1060</student><amount>947.24</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5059, 1046, 3, 1340.82, '2024-10-17', 'transfer', '<invoice><student>1046</student><amount>1340.82</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5060, 1103, 2, 714.62, '2025-02-09', 'transfer', '<invoice><student>1103</student><amount>714.62</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5061, 1101, 2, 787.79, '2025-02-01', 'cash', '<invoice><student>1101</student><amount>787.79</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5062, 1048, 1, 1033.66, '2025-07-15', 'transfer', '<invoice><student>1048</student><amount>1033.66</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5063, 1006, 3, 1078.29, '2025-01-19', 'cash', '<invoice><student>1006</student><amount>1078.29</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5064, 1203, 1, 905.44, '2025-04-14', 'card', '<invoice><student>1203</student><amount>905.44</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5065, 1081, 2, 1813.7, '2025-09-09', 'transfer', '<invoice><student>1081</student><amount>1813.7</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5066, 1140, 2, 964.48, '2025-01-29', 'transfer', '<invoice><student>1140</student><amount>964.48</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5067, 1065, 3, 1264.08, '2025-06-30', 'card', '<invoice><student>1065</student><amount>1264.08</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5068, 1153, 1, 798.26, '2024-11-05', 'card', '<invoice><student>1153</student><amount>798.26</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5069, 1069, 1, 1327.58, '2024-11-26', 'transfer', '<invoice><student>1069</student><amount>1327.58</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5070, 1057, 1, 625.26, '2025-05-01', 'cash', '<invoice><student>1057</student><amount>625.26</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5071, 1148, 1, 968.1, '2025-03-26', 'cash', '<invoice><student>1148</student><amount>968.1</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5072, 1105, 3, 1457.67, '2025-02-12', 'transfer', '<invoice><student>1105</student><amount>1457.67</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5073, 1031, 3, 717.24, '2025-03-23', 'cash', '<invoice><student>1031</student><amount>717.24</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5074, 1031, 3, 1841.76, '2024-09-25', 'transfer', '<invoice><student>1031</student><amount>1841.76</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5075, 1096, 2, 1632.89, '2024-09-27', 'cash', '<invoice><student>1096</student><amount>1632.89</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5076, 1208, 3, 1831.51, '2024-09-25', 'card', '<invoice><student>1208</student><amount>1831.51</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5077, 1101, 1, 933.25, '2024-11-02', 'card', '<invoice><student>1101</student><amount>933.25</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5078, 1003, 2, 1408.71, '2025-06-14', 'cash', '<invoice><student>1003</student><amount>1408.71</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5079, 1171, 3, 1641.73, '2025-01-17', 'card', '<invoice><student>1171</student><amount>1641.73</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5080, 1198, 1, 1752.02, '2025-07-19', 'card', '<invoice><student>1198</student><amount>1752.02</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5081, 1179, 2, 1948.61, '2025-03-12', 'card', '<invoice><student>1179</student><amount>1948.61</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5082, 1162, 3, 1342.7, '2025-03-30', 'cash', '<invoice><student>1162</student><amount>1342.7</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5083, 1182, 2, 1779.95, '2025-03-06', 'cash', '<invoice><student>1182</student><amount>1779.95</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5084, 1075, 3, 992.67, '2024-11-06', 'cash', '<invoice><student>1075</student><amount>992.67</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5085, 1075, 2, 843.89, '2025-05-03', 'transfer', '<invoice><student>1075</student><amount>843.89</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5086, 1112, 1, 1990.41, '2025-08-22', 'cash', '<invoice><student>1112</student><amount>1990.41</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5087, 1077, 1, 967.71, '2025-03-29', 'cash', '<invoice><student>1077</student><amount>967.71</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5088, 1206, 3, 1795.06, '2024-11-03', 'cash', '<invoice><student>1206</student><amount>1795.06</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5089, 1001, 2, 1438.08, '2025-01-15', 'transfer', '<invoice><student>1001</student><amount>1438.08</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5090, 1055, 3, 866.94, '2025-09-06', 'cash', '<invoice><student>1055</student><amount>866.94</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5091, 1039, 3, 1363.28, '2025-05-06', 'cash', '<invoice><student>1039</student><amount>1363.28</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5092, 1137, 1, 885.56, '2025-01-11', 'transfer', '<invoice><student>1137</student><amount>885.56</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5093, 1178, 2, 623.72, '2024-11-12', 'cash', '<invoice><student>1178</student><amount>623.72</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5094, 1189, 1, 1055.55, '2025-02-09', 'card', '<invoice><student>1189</student><amount>1055.55</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5095, 1112, 3, 1147.89, '2025-05-07', 'cash', '<invoice><student>1112</student><amount>1147.89</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5096, 1156, 3, 1264.71, '2025-06-24', 'card', '<invoice><student>1156</student><amount>1264.71</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5097, 1056, 3, 1063.77, '2025-08-03', 'cash', '<invoice><student>1056</student><amount>1063.77</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5098, 1099, 3, 1024.5, '2025-01-04', 'cash', '<invoice><student>1099</student><amount>1024.5</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5099, 1132, 2, 1014.25, '2025-04-28', 'cash', '<invoice><student>1132</student><amount>1014.25</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5100, 1073, 2, 1371.56, '2025-01-18', 'transfer', '<invoice><student>1073</student><amount>1371.56</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5101, 1027, 2, 1096.11, '2025-03-26', 'cash', '<invoice><student>1027</student><amount>1096.11</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5102, 1214, 3, 1277.15, '2025-07-28', 'cash', '<invoice><student>1214</student><amount>1277.15</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5103, 1181, 2, 1401.6, '2025-03-26', 'transfer', '<invoice><student>1181</student><amount>1401.6</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5104, 1163, 3, 1513.12, '2025-04-04', 'transfer', '<invoice><student>1163</student><amount>1513.12</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5105, 1021, 2, 1823.99, '2025-03-19', 'card', '<invoice><student>1021</student><amount>1823.99</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5106, 1083, 2, 1050.23, '2025-06-12', 'cash', '<invoice><student>1083</student><amount>1050.23</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5107, 1088, 2, 1876.44, '2025-04-16', 'card', '<invoice><student>1088</student><amount>1876.44</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5108, 1012, 2, 1430.9, '2025-01-04', 'card', '<invoice><student>1012</student><amount>1430.9</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5109, 1021, 2, 1010.37, '2025-03-13', 'card', '<invoice><student>1021</student><amount>1010.37</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5110, 1197, 1, 557.34, '2025-07-23', 'cash', '<invoice><student>1197</student><amount>557.34</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5111, 1032, 1, 1491.1, '2024-09-16', 'cash', '<invoice><student>1032</student><amount>1491.1</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5112, 1130, 3, 780.01, '2025-01-31', 'card', '<invoice><student>1130</student><amount>780.01</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5113, 1115, 2, 1373.93, '2025-01-16', 'card', '<invoice><student>1115</student><amount>1373.93</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5114, 1151, 2, 831.61, '2025-05-29', 'cash', '<invoice><student>1151</student><amount>831.61</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5115, 1013, 2, 1580.73, '2024-10-22', 'card', '<invoice><student>1013</student><amount>1580.73</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5116, 1204, 3, 1210.42, '2025-02-18', 'transfer', '<invoice><student>1204</student><amount>1210.42</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5117, 1163, 2, 1546.28, '2025-04-24', 'transfer', '<invoice><student>1163</student><amount>1546.28</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5118, 1003, 2, 1783.9, '2025-01-07', 'card', '<invoice><student>1003</student><amount>1783.9</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5119, 1071, 1, 608.59, '2025-07-16', 'card', '<invoice><student>1071</student><amount>608.59</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5120, 1123, 3, 1183.57, '2025-08-25', 'card', '<invoice><student>1123</student><amount>1183.57</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5121, 1188, 3, 1358.2, '2025-06-18', 'cash', '<invoice><student>1188</student><amount>1358.2</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5122, 1104, 1, 1095.46, '2025-08-14', 'transfer', '<invoice><student>1104</student><amount>1095.46</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5123, 1111, 1, 1200.94, '2025-06-04', 'cash', '<invoice><student>1111</student><amount>1200.94</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5124, 1207, 3, 1545.98, '2025-05-12', 'transfer', '<invoice><student>1207</student><amount>1545.98</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5125, 1079, 1, 1190.08, '2024-09-20', 'cash', '<invoice><student>1079</student><amount>1190.08</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5126, 1170, 2, 1107.2, '2025-04-29', 'transfer', '<invoice><student>1170</student><amount>1107.2</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5127, 1202, 3, 700.88, '2025-03-13', 'transfer', '<invoice><student>1202</student><amount>700.88</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5128, 1080, 3, 711.85, '2024-12-22', 'cash', '<invoice><student>1080</student><amount>711.85</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5129, 1171, 2, 1365.42, '2025-05-22', 'card', '<invoice><student>1171</student><amount>1365.42</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5130, 1143, 2, 1363.74, '2025-07-11', 'card', '<invoice><student>1143</student><amount>1363.74</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5131, 1090, 1, 1987.97, '2025-07-08', 'transfer', '<invoice><student>1090</student><amount>1987.97</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5132, 1200, 2, 1995.87, '2025-04-22', 'card', '<invoice><student>1200</student><amount>1995.87</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5133, 1189, 1, 1178.62, '2025-04-22', 'cash', '<invoice><student>1189</student><amount>1178.62</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5134, 1122, 2, 1347.59, '2024-12-07', 'card', '<invoice><student>1122</student><amount>1347.59</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5135, 1215, 1, 899.98, '2025-06-17', 'cash', '<invoice><student>1215</student><amount>899.98</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5136, 1130, 2, 1436.18, '2024-09-29', 'cash', '<invoice><student>1130</student><amount>1436.18</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5137, 1126, 3, 568.23, '2025-04-24', 'transfer', '<invoice><student>1126</student><amount>568.23</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5138, 1089, 1, 889.2, '2025-03-15', 'cash', '<invoice><student>1089</student><amount>889.2</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5139, 1063, 3, 532.23, '2024-11-15', 'card', '<invoice><student>1063</student><amount>532.23</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5140, 1081, 3, 1969.94, '2025-04-01', 'transfer', '<invoice><student>1081</student><amount>1969.94</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5141, 1010, 3, 1355.97, '2025-05-12', 'transfer', '<invoice><student>1010</student><amount>1355.97</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5142, 1058, 1, 508.94, '2025-06-17', 'card', '<invoice><student>1058</student><amount>508.94</amount><method>card</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5143, 1010, 3, 526.27, '2025-05-08', 'transfer', '<invoice><student>1010</student><amount>526.27</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5144, 1068, 1, 1540.94, '2025-07-07', 'cash', '<invoice><student>1068</student><amount>1540.94</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5145, 1092, 1, 1701.72, '2025-08-02', 'cash', '<invoice><student>1092</student><amount>1701.72</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5146, 1214, 3, 1152.79, '2025-02-04', 'cash', '<invoice><student>1214</student><amount>1152.79</amount><method>cash</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5147, 1190, 2, 1571.76, '2024-11-06', 'transfer', '<invoice><student>1190</student><amount>1571.76</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5148, 1090, 3, 996.44, '2025-07-26', 'transfer', '<invoice><student>1090</student><amount>996.44</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5149, 1053, 3, 1422.51, '2025-06-01', 'transfer', '<invoice><student>1053</student><amount>1422.51</amount><method>transfer</method></invoice>');
INSERT INTO Payments (payment_id, student_id, term_id, amount, payment_date, payment_type, invoice_xml) VALUES
(5150, 1158, 3, 580.69, '2024-12-13', 'card', '<invoice><student>1158</student><amount>580.69</amount><method>card</method></invoice>');

-- =====================================
-- INSERTS: Courses
-- =====================================
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(301, 5, 'Almost Fundamentals', 4, 'Way body affect finish charge real improve simple turn their save artist catch.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(302, 5, 'Despite Fundamentals', 4, 'Foot production moment finish community treatment garden great sign return poor really particular.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(303, 4, 'Dark Fundamentals', 3, 'Everything fear walk word side relate real major look.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(304, 2, 'Opportunity Fundamentals', 3, 'Explain of myself time house generation significant chair among.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(305, 5, 'Send Fundamentals', 3, 'Get kind either look dark Mrs usually.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(306, 1, 'Safe Fundamentals', 4, 'Case past only drug prove most point appear including.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(307, 2, 'Series Fundamentals', 3, 'Beyond side accept nearly upon imagine various there local current white fly.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(308, 3, 'Race Fundamentals', 4, 'Traditional become off movement rich view.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(309, 5, 'White Fundamentals', 3, 'Individual study value already structure small control see.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(310, 3, 'Turn Fundamentals', 3, 'Theory across nothing blue work expect writer myself management.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(311, 3, 'Wrong Fundamentals', 4, 'Surface life cover both class learn either.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(312, 3, 'Cultural Fundamentals', 3, 'Say so nothing serious compare task.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(313, 5, 'Watch Fundamentals', 3, 'Still middle beautiful protect continue cell food easy end dog send.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(314, 3, 'Girl Fundamentals', 3, 'Old of end growth door property let civil rather.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(315, 3, 'Wind Fundamentals', 4, 'Real police wait happen determine whatever long lawyer writer.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(316, 3, 'Hour Fundamentals', 4, 'Reduce tree serious soon stay seven quite other skin moment month.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(317, 2, 'High Fundamentals', 3, 'True born stock total dark Mr.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(318, 2, 'Community Fundamentals', 3, 'Take kind quite response major together knowledge argue car indeed.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(319, 2, 'Organization Fundamentals', 3, 'Next pull final against effort able.');
INSERT INTO Courses (course_id, department_id, title, credits, description) VALUES
(320, 5, 'Discover Fundamentals', 4, 'Authority interest red must art thus worry line expert conference career political role.');

-- =====================================
-- INSERTS: Rooms
-- =====================================
INSERT INTO Rooms (room_id, building, room_number, room_type, capacity) VALUES
(401, 'Stuart', '278', 'lecture hall', 60);
INSERT INTO Rooms (room_id, building, room_number, room_type, capacity) VALUES
(402, 'Brooks', '441', 'lab', 67);
INSERT INTO Rooms (room_id, building, room_number, room_type, capacity) VALUES
(403, 'Vance', '235', 'lab', 24);
INSERT INTO Rooms (room_id, building, room_number, room_type, capacity) VALUES
(404, 'West', '436', 'lab', 59);
INSERT INTO Rooms (room_id, building, room_number, room_type, capacity) VALUES
(405, 'Stark', '192', 'seminar room', 56);
INSERT INTO Rooms (room_id, building, room_number, room_type, capacity) VALUES
(406, 'Bennett', '380', 'seminar room', 60);
INSERT INTO Rooms (room_id, building, room_number, room_type, capacity) VALUES
(407, 'Miller', '456', 'lecture hall', 91);
INSERT INTO Rooms (room_id, building, room_number, room_type, capacity) VALUES
(408, 'Brandt', '453', 'lab', 37);
INSERT INTO Rooms (room_id, building, room_number, room_type, capacity) VALUES
(409, 'Baxter', '344', 'lab', 24);
INSERT INTO Rooms (room_id, building, room_number, room_type, capacity) VALUES
(410, 'Anderson', '131', 'lecture hall', 34);

-- =====================================
-- INSERTS: Course Sections
-- =====================================
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(601, 315, 1, 'whlI245', 46, 'French');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(602, 308, 3, 'zHiU912', 37, 'French');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(603, 306, 2, 'oaWb989', 51, 'Spanish');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(604, 309, 2, 'tDRU129', 49, 'French');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(605, 313, 2, 'IBIy109', 50, 'French');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(606, 301, 3, 'opDw760', 47, 'French');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(607, 307, 1, 'jrmU528', 45, 'English');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(608, 311, 1, 'WhcZ981', 49, 'English');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(609, 302, 3, 'QANX995', 42, 'English');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(610, 314, 1, 'bpne386', 42, 'English');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(611, 313, 3, 'gMcC763', 32, 'French');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(612, 319, 2, 'MRTd345', 39, 'Spanish');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(613, 308, 1, 'pVcz214', 58, 'Spanish');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(614, 313, 2, 'CoIn451', 25, 'English');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(615, 313, 3, 'WXdi328', 29, 'Spanish');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(616, 317, 3, 'GsoU141', 54, 'French');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(617, 315, 1, 'KuKM695', 45, 'English');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(618, 307, 2, 'XRup663', 38, 'English');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(619, 306, 2, 'tjQH544', 59, 'English');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(620, 312, 1, 'oAtr911', 56, 'French');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(621, 302, 3, 'dJLV232', 58, 'French');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(622, 302, 2, 'lORB303', 42, 'French');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(623, 317, 1, 'JFdw167', 27, 'French');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(624, 317, 1, 'PQyY484', 55, 'French');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(625, 316, 3, 'HuSA264', 55, 'French');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(626, 305, 1, 'Ajty626', 33, 'Spanish');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(627, 312, 1, 'lWIE391', 39, 'Spanish');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(628, 310, 3, 'potT253', 49, 'Spanish');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(629, 304, 2, 'jZDd769', 41, 'Spanish');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(630, 307, 3, 'JAAJ407', 29, 'French');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(631, 316, 2, 'Hiyp992', 46, 'French');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(632, 309, 1, 'qnvP165', 37, 'English');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(633, 309, 3, 'fCxf584', 50, 'French');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(634, 303, 1, 'IUmd122', 33, 'English');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(635, 317, 2, 'ryRM788', 58, 'English');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(636, 320, 1, 'Mcem838', 29, 'French');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(637, 313, 2, 'ZWLU212', 45, 'Spanish');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(638, 307, 3, 'QJnE840', 47, 'Spanish');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(639, 307, 3, 'nvta278', 43, 'English');
INSERT INTO Course_Sections (section_id, course_id, term_id, section_code, capacity, language) VALUES
(640, 309, 2, 'nmVh533', 27, 'English');

-- =====================================
-- INSERTS: Schedules
-- =====================================
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(701, 627, 410, 25, 'Tuesday', '11:00:00', '13:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(702, 623, 402, 9, 'Friday', '09:00:00', '11:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(703, 638, 409, 14, 'Thursday', '08:00:00', '10:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(704, 630, 401, 2, 'Tuesday', '14:00:00', '16:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(705, 620, 404, 13, 'Tuesday', '11:00:00', '13:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(706, 606, 402, 21, 'Wednesday', '15:00:00', '17:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(707, 632, 403, 27, 'Thursday', '11:00:00', '13:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(708, 601, 403, 23, 'Wednesday', '10:00:00', '12:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(709, 632, 403, 22, 'Wednesday', '11:00:00', '13:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(710, 638, 404, 1, 'Friday', '10:00:00', '12:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(711, 602, 401, 5, 'Monday', '10:00:00', '12:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(712, 602, 408, 18, 'Thursday', '14:00:00', '16:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(713, 602, 405, 12, 'Wednesday', '08:00:00', '10:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(714, 603, 402, 30, 'Thursday', '08:00:00', '10:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(715, 601, 405, 16, 'Monday', '08:00:00', '10:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(716, 618, 407, 8, 'Wednesday', '14:00:00', '16:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(717, 608, 405, 13, 'Wednesday', '10:00:00', '12:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(718, 615, 406, 20, 'Tuesday', '12:00:00', '14:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(719, 632, 402, 19, 'Wednesday', '08:00:00', '10:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(720, 630, 407, 27, 'Friday', '10:00:00', '12:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(721, 634, 406, 8, 'Monday', '10:00:00', '12:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(722, 619, 407, 16, 'Monday', '15:00:00', '17:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(723, 620, 407, 29, 'Tuesday', '09:00:00', '11:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(724, 619, 405, 10, 'Thursday', '14:00:00', '16:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(725, 624, 404, 17, 'Tuesday', '13:00:00', '15:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(726, 631, 401, 17, 'Monday', '12:00:00', '14:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(727, 621, 405, 7, 'Tuesday', '14:00:00', '16:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(728, 633, 402, 3, 'Friday', '12:00:00', '14:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(729, 631, 410, 14, 'Friday', '09:00:00', '11:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(730, 614, 407, 26, 'Friday', '12:00:00', '14:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(731, 629, 403, 5, 'Thursday', '12:00:00', '14:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(732, 605, 403, 27, 'Wednesday', '15:00:00', '17:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(733, 639, 403, 4, 'Wednesday', '12:00:00', '14:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(734, 609, 407, 23, 'Thursday', '11:00:00', '13:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(735, 622, 407, 1, 'Monday', '15:00:00', '17:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(736, 639, 409, 9, 'Tuesday', '11:00:00', '13:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(737, 632, 402, 12, 'Friday', '14:00:00', '16:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(738, 610, 402, 2, 'Thursday', '12:00:00', '14:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(739, 602, 403, 24, 'Tuesday', '09:00:00', '11:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(740, 631, 406, 26, 'Monday', '15:00:00', '17:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(741, 602, 403, 27, 'Thursday', '11:00:00', '13:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(742, 630, 407, 11, 'Friday', '08:00:00', '10:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(743, 610, 406, 18, 'Friday', '14:00:00', '16:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(744, 605, 403, 21, 'Tuesday', '10:00:00', '12:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(745, 607, 405, 24, 'Monday', '13:00:00', '15:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(746, 601, 404, 27, 'Tuesday', '14:00:00', '16:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(747, 618, 405, 3, 'Friday', '09:00:00', '11:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(748, 608, 402, 20, 'Friday', '12:00:00', '14:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(749, 629, 406, 24, 'Tuesday', '12:00:00', '14:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(750, 634, 401, 14, 'Wednesday', '10:00:00', '12:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(751, 639, 403, 27, 'Wednesday', '11:00:00', '13:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(752, 622, 407, 23, 'Thursday', '11:00:00', '13:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(753, 622, 403, 12, 'Friday', '12:00:00', '14:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(754, 622, 405, 14, 'Thursday', '09:00:00', '11:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(755, 607, 407, 30, 'Friday', '08:00:00', '10:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(756, 640, 407, 8, 'Monday', '11:00:00', '13:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(757, 619, 401, 22, 'Thursday', '08:00:00', '10:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(758, 627, 402, 12, 'Monday', '12:00:00', '14:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(759, 611, 401, 1, 'Friday', '09:00:00', '11:00:00');
INSERT INTO Schedules (schedule_id, section_id, room_id, instructor_id, day_of_week, start_time, end_time) VALUES
(760, 604, 404, 16, 'Monday', '12:00:00', '14:00:00');

-- =====================================
-- INSERTS: Enrollments
-- =====================================
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(801, 1006, 607);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(802, 1186, 631);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(803, 1182, 636);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(804, 1076, 640);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(805, 1195, 616);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(806, 1054, 636);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(807, 1037, 604);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(808, 1186, 639);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(809, 1065, 611);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(810, 1185, 614);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(811, 1198, 619);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(812, 1166, 635);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(813, 1104, 639);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(814, 1131, 607);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(815, 1012, 637);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(816, 1001, 630);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(817, 1046, 638);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(818, 1052, 620);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(819, 1110, 638);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(820, 1207, 632);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(821, 1187, 617);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(822, 1109, 610);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(823, 1114, 606);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(824, 1052, 613);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(825, 1104, 603);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(826, 1038, 627);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(827, 1061, 613);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(828, 1159, 615);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(829, 1089, 615);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(830, 1052, 622);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(831, 1192, 612);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(832, 1087, 638);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(833, 1124, 613);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(834, 1163, 624);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(835, 1055, 604);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(836, 1079, 620);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(837, 1015, 634);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(838, 1001, 606);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(839, 1026, 620);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(840, 1205, 617);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(841, 1074, 603);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(842, 1200, 636);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(843, 1170, 639);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(844, 1197, 632);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(845, 1196, 640);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(846, 1103, 609);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(847, 1004, 625);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(848, 1106, 608);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(849, 1007, 611);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(850, 1034, 628);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(851, 1081, 629);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(852, 1010, 621);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(853, 1080, 616);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(854, 1161, 623);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(855, 1150, 619);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(856, 1181, 635);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(857, 1010, 637);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(858, 1047, 626);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(859, 1126, 623);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(860, 1158, 627);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(861, 1213, 609);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(862, 1214, 615);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(863, 1179, 603);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(864, 1082, 638);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(865, 1041, 639);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(866, 1077, 602);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(867, 1100, 622);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(868, 1006, 616);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(869, 1183, 613);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(870, 1097, 623);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(871, 1039, 637);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(872, 1050, 629);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(873, 1132, 640);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(874, 1126, 606);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(875, 1049, 620);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(876, 1186, 605);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(877, 1128, 606);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(878, 1193, 632);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(879, 1054, 631);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(880, 1142, 603);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(881, 1200, 602);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(882, 1112, 626);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(883, 1068, 613);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(884, 1112, 621);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(885, 1216, 604);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(886, 1068, 623);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(887, 1166, 612);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(888, 1188, 609);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(889, 1169, 636);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(890, 1214, 607);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(891, 1192, 627);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(892, 1216, 621);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(893, 1067, 611);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(894, 1140, 640);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(895, 1219, 633);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(896, 1066, 627);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(897, 1093, 611);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(898, 1108, 620);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(899, 1015, 602);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(900, 1035, 639);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(901, 1125, 613);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(902, 1055, 601);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(903, 1137, 601);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(904, 1185, 605);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(905, 1050, 609);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(906, 1130, 637);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(907, 1092, 618);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(908, 1076, 632);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(909, 1121, 610);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(910, 1161, 602);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(911, 1120, 616);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(912, 1163, 612);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(913, 1187, 620);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(914, 1144, 608);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(915, 1078, 613);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(916, 1097, 611);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(917, 1179, 632);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(918, 1153, 608);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(919, 1076, 615);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(920, 1161, 629);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(921, 1183, 633);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(922, 1201, 624);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(923, 1096, 626);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(924, 1218, 640);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(925, 1005, 638);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(926, 1140, 601);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(927, 1138, 631);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(928, 1010, 617);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(929, 1167, 635);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(930, 1034, 640);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(931, 1065, 605);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(932, 1165, 625);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(933, 1101, 639);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(934, 1045, 629);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(935, 1050, 613);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(936, 1139, 612);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(937, 1125, 604);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(938, 1131, 630);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(939, 1206, 611);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(940, 1194, 639);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(941, 1183, 624);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(942, 1061, 626);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(943, 1114, 637);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(944, 1187, 640);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(945, 1111, 608);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(946, 1120, 613);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(947, 1096, 631);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(948, 1001, 609);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(949, 1121, 621);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(950, 1094, 631);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(951, 1131, 620);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(952, 1076, 638);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(953, 1076, 616);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(954, 1106, 618);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(955, 1147, 616);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(956, 1159, 613);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(957, 1113, 621);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(958, 1153, 631);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(959, 1065, 606);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(960, 1102, 614);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(961, 1054, 635);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(962, 1062, 618);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(963, 1102, 636);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(964, 1006, 625);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(965, 1050, 630);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(966, 1028, 611);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(967, 1102, 638);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(968, 1184, 636);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(969, 1005, 625);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(970, 1188, 607);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(971, 1134, 616);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(972, 1041, 623);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(973, 1140, 622);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(974, 1105, 631);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(975, 1077, 622);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(976, 1139, 617);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(977, 1102, 619);
-- INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
-- (978, 1074, 603);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(979, 1104, 631);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(980, 1134, 617);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(981, 1109, 613);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(982, 1088, 612);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(983, 1112, 635);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(984, 1039, 620);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(985, 1179, 622);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(987, 1166, 625);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(988, 1092, 616);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(989, 1054, 611);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(990, 1059, 622);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(991, 1056, 617);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(992, 1088, 629);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(993, 1049, 626);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(994, 1218, 602);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(995, 1093, 607);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(996, 1029, 613);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(997, 1098, 615);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(998, 1016, 602);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(999, 1195, 630);
INSERT INTO Enrollments (enrollment_id, student_id, section_id) VALUES
(1000, 1032, 607);

-- =====================================
-- INSERTS: Assessments
-- =====================================
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(901, 617, 'assignment', 'Assignment 3', 13.71, '2025-10-18');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(902, 637, 'assignment', 'Assignment 3', 12.59, '2025-10-10');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(903, 639, 'exam', 'Exam 3', 12.41, '2025-11-17');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(904, 623, 'quiz', 'Quiz 3', 11.13, '2025-10-17');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(905, 631, 'quiz', 'Quiz 3', 13.29, '2025-11-02');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(906, 603, 'exam', 'Exam 3', 14.73, '2025-10-25');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(907, 618, 'assignment', 'Assignment 3', 13.9, '2025-11-13');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(908, 604, 'quiz', 'Quiz 1', 14.58, '2025-11-30');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(909, 639, 'exam', 'Exam 1', 24.51, '2025-12-13');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(910, 629, 'quiz', 'Quiz 2', 28.36, '2025-11-09');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(911, 606, 'assignment', 'Assignment 3', 11.27, '2025-10-30');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(912, 604, 'exam', 'Exam 2', 26.72, '2025-10-21');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(913, 615, 'exam', 'Exam 1', 15.71, '2025-11-09');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(914, 628, 'assignment', 'Assignment 3', 22.2, '2025-12-09');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(915, 629, 'quiz', 'Quiz 1', 26.97, '2025-12-06');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(916, 615, 'exam', 'Exam 2', 9.8, '2025-11-30');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(917, 626, 'exam', 'Exam 3', 29.06, '2025-09-20');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(918, 619, 'quiz', 'Quiz 3', 14.84, '2025-12-01');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(919, 615, 'assignment', 'Assignment 1', 14.06, '2025-11-02');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(920, 616, 'quiz', 'Quiz 1', 13.44, '2025-10-10');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(921, 612, 'quiz', 'Quiz 1', 6.36, '2025-11-11');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(922, 617, 'assignment', 'Assignment 1', 23.73, '2025-10-31');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(923, 601, 'assignment', 'Assignment 2', 19.4, '2025-11-20');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(924, 609, 'quiz', 'Quiz 2', 20.32, '2025-09-09');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(925, 626, 'quiz', 'Quiz 2', 20.76, '2025-10-13');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(926, 603, 'assignment', 'Assignment 2', 23.27, '2025-09-29');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(927, 636, 'assignment', 'Assignment 2', 14.59, '2025-09-04');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(928, 637, 'assignment', 'Assignment 1', 18.64, '2025-10-21');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(929, 601, 'quiz', 'Quiz 1', 12.58, '2025-11-21');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(930, 601, 'quiz', 'Quiz 2', 18.03, '2025-10-28');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(931, 638, 'exam', 'Exam 3', 29.94, '2025-09-30');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(932, 623, 'quiz', 'Quiz 1', 23.11, '2025-10-09');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(933, 638, 'assignment', 'Assignment 1', 9.17, '2025-11-04');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(934, 638, 'exam', 'Exam 1', 29.23, '2025-10-15');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(935, 609, 'assignment', 'Assignment 3', 20.89, '2025-11-13');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(936, 608, 'quiz', 'Quiz 2', 28.63, '2025-10-18');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(937, 623, 'quiz', 'Quiz 1', 21.44, '2025-12-06');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(938, 623, 'quiz', 'Quiz 3', 15.59, '2025-11-05');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(939, 604, 'assignment', 'Assignment 2', 18.81, '2025-10-20');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(940, 638, 'assignment', 'Assignment 1', 7.01, '2025-12-04');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(941, 640, 'quiz', 'Quiz 3', 8.86, '2025-12-05');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(942, 625, 'assignment', 'Assignment 3', 11.11, '2025-11-29');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(943, 628, 'exam', 'Exam 1', 23.71, '2025-10-03');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(944, 623, 'exam', 'Exam 1', 13.72, '2025-11-08');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(945, 639, 'exam', 'Exam 3', 14.72, '2025-10-03');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(946, 635, 'assignment', 'Assignment 1', 9.73, '2025-09-28');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(947, 629, 'assignment', 'Assignment 3', 25.26, '2025-12-04');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(948, 618, 'quiz', 'Quiz 3', 16.16, '2025-10-06');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(949, 620, 'exam', 'Exam 1', 9.89, '2025-09-12');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(950, 601, 'assignment', 'Assignment 1', 17.38, '2025-12-11');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(951, 614, 'exam', 'Exam 3', 28.83, '2025-09-07');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(952, 601, 'exam', 'Exam 2', 10.17, '2025-09-15');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(953, 606, 'quiz', 'Quiz 3', 17.4, '2025-09-10');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(954, 638, 'quiz', 'Quiz 3', 18.4, '2025-09-02');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(955, 606, 'quiz', 'Quiz 1', 27.93, '2025-11-20');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(956, 603, 'exam', 'Exam 1', 18.23, '2025-09-27');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(957, 621, 'quiz', 'Quiz 3', 6.65, '2025-10-15');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(958, 632, 'quiz', 'Quiz 1', 25.61, '2025-09-14');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(959, 605, 'exam', 'Exam 2', 5.44, '2025-09-30');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(960, 633, 'exam', 'Exam 1', 20.68, '2025-09-02');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(961, 628, 'quiz', 'Quiz 1', 8.57, '2025-10-13');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(962, 623, 'assignment', 'Assignment 1', 16.35, '2025-12-08');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(963, 612, 'quiz', 'Quiz 3', 7.44, '2025-11-28');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(964, 630, 'exam', 'Exam 3', 23.76, '2025-11-12');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(965, 605, 'quiz', 'Quiz 2', 28.53, '2025-09-12');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(966, 631, 'exam', 'Exam 3', 12.44, '2025-12-03');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(967, 612, 'exam', 'Exam 2', 23.04, '2025-12-04');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(968, 630, 'quiz', 'Quiz 3', 24.71, '2025-09-04');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(969, 610, 'exam', 'Exam 3', 20.94, '2025-09-02');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(970, 612, 'quiz', 'Quiz 2', 22.26, '2025-12-13');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(971, 637, 'assignment', 'Assignment 1', 18.59, '2025-11-19');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(972, 635, 'assignment', 'Assignment 1', 15.45, '2025-09-03');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(973, 628, 'quiz', 'Quiz 2', 20.89, '2025-09-04');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(974, 629, 'quiz', 'Quiz 1', 29.87, '2025-12-12');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(975, 628, 'quiz', 'Quiz 1', 23.82, '2025-10-24');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(976, 640, 'assignment', 'Assignment 2', 29.3, '2025-12-14');
INSERT INTO Assessments (assessment_id, section_id, type, title, weight_pct, due_date) VALUES
(977, 635, 'quiz', 'Quiz 1', 23.06, '2025-10-26');

-- =====================================
-- INSERTS: Grades
-- =====================================
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1001, 915, 1123, 74.13);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1002, 916, 1196, 52.02);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1003, 930, 1181, 75.84);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1004, 925, 1091, 64.49);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1005, 937, 1038, 80.6);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1006, 974, 1132, 87.89);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1008, 928, 1007, 87.6);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1009, 917, 1084, 97.84);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1010, 977, 1081, 66.47);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1011, 969, 1209, 71.15);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1012, 923, 1170, 83.14);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1013, 960, 1191, 84.83);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1014, 927, 1178, 66.09);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1015, 956, 1023, 63.28);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1016, 903, 1063, 89.43);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1017, 931, 1054, 94.14);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1018, 910, 1079, 94.91);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1019, 907, 1058, 98.58);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1020, 914, 1125, 70.79);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1021, 957, 1092, 54.7);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1022, 930, 1065, 88.0);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1023, 941, 1164, 64.64);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1024, 915, 1122, 59.42);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1025, 907, 1169, 51.66);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1026, 940, 1211, 65.39);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1027, 976, 1120, 64.0);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1028, 940, 1047, 63.28);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1029, 920, 1179, 77.38);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1030, 906, 1109, 52.52);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1031, 931, 1211, 76.68);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1032, 942, 1183, 72.18);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1033, 961, 1033, 59.98);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1034, 965, 1140, 50.29);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1035, 932, 1134, 82.43);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1036, 964, 1205, 68.82);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1037, 930, 1034, 94.02);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1038, 951, 1139, 66.72);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1039, 959, 1061, 55.11);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1040, 966, 1191, 97.66);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1041, 950, 1071, 64.66);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1042, 942, 1078, 67.48);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1043, 919, 1049, 65.57);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1044, 947, 1206, 92.25);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1045, 972, 1045, 57.88);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1046, 969, 1088, 67.62);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1047, 912, 1185, 69.68);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1048, 902, 1178, 77.24);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1049, 939, 1058, 81.14);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1050, 907, 1186, 77.12);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1051, 912, 1204, 50.59);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1052, 935, 1199, 91.15);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1053, 921, 1158, 94.58);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1054, 943, 1202, 88.87);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1055, 964, 1016, 54.76);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1056, 972, 1140, 59.89);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1057, 968, 1190, 74.76);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1058, 958, 1029, 76.78);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1059, 944, 1187, 74.22);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1060, 936, 1175, 73.95);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1061, 955, 1124, 76.14);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1062, 929, 1147, 87.69);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1063, 973, 1154, 60.14);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1064, 948, 1175, 71.75);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1065, 945, 1014, 89.81);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1066, 952, 1158, 82.06);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1067, 917, 1117, 83.09);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1068, 959, 1009, 57.61);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1069, 944, 1105, 60.85);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1070, 929, 1008, 50.4);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1071, 940, 1031, 84.81);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1072, 967, 1006, 60.35);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1073, 935, 1183, 58.97);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1074, 947, 1152, 91.8);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1075, 917, 1052, 63.07);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1076, 919, 1164, 84.91);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1077, 968, 1210, 92.93);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1078, 903, 1076, 79.53);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1079, 953, 1160, 82.8);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1080, 917, 1090, 68.25);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1081, 958, 1069, 85.43);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1082, 969, 1068, 71.72);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1083, 959, 1090, 50.77);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1084, 972, 1206, 80.16);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1085, 921, 1031, 88.43);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1086, 951, 1090, 82.11);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1087, 950, 1193, 90.99);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1088, 937, 1057, 93.57);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1089, 937, 1068, 71.69);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1090, 904, 1127, 57.28);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1091, 935, 1151, 89.83);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1093, 902, 1029, 71.92);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1094, 959, 1076, 97.67);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1095, 964, 1086, 90.47);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1096, 945, 1034, 72.44);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1097, 966, 1069, 59.79);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1098, 919, 1134, 72.46);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1099, 913, 1006, 61.53);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1100, 934, 1200, 97.46);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1101, 942, 1150, 82.08);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1102, 959, 1006, 68.47);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1103, 928, 1195, 68.41);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1104, 920, 1004, 75.25);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1105, 923, 1201, 77.76);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1106, 903, 1188, 75.75);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1107, 966, 1061, 74.41);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1108, 976, 1084, 89.8);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1109, 971, 1026, 85.09);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1110, 927, 1097, 83.01);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1112, 945, 1184, 88.23);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1113, 910, 1171, 73.58);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1114, 972, 1016, 60.44);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1115, 918, 1098, 64.99);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1116, 968, 1214, 62.04);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1117, 911, 1165, 96.25);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1118, 929, 1061, 77.44);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1119, 954, 1160, 72.99);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1120, 972, 1034, 84.36);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1121, 952, 1181, 86.08);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1122, 906, 1188, 82.89);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1123, 939, 1124, 67.2);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1124, 972, 1102, 90.15);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1125, 934, 1207, 55.37);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1126, 937, 1209, 71.09);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1127, 939, 1094, 87.54);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1128, 948, 1159, 84.85);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1129, 973, 1188, 50.07);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1130, 929, 1167, 92.05);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1131, 926, 1145, 69.29);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1132, 938, 1031, 80.14);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1134, 930, 1166, 89.16);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1135, 905, 1087, 61.28);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1136, 918, 1013, 97.53);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1137, 960, 1116, 53.91);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1138, 914, 1128, 99.47);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1139, 910, 1096, 63.28);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1140, 965, 1026, 89.69);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1142, 909, 1073, 77.62);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1143, 938, 1143, 90.72);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1144, 944, 1193, 84.15);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1145, 966, 1153, 94.91);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1146, 939, 1186, 52.13);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1147, 966, 1134, 96.51);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1148, 926, 1022, 50.69);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1149, 943, 1102, 84.35);
INSERT INTO Grades (grade_id, assessment_id, student_id, score) VALUES
(1150, 926, 1110, 86.88);

SET SQL_SAFE_UPDATES = 0;
-- =====================================
-- UPDATES: Students json profile field
-- =====================================
UPDATE Students
SET profile_json = JSON_ARRAY_APPEND(profile_json, '$.interests', 'AI')
WHERE student_id BETWEEN 1001 AND 1074;

-- =====================================
-- UPDATES: Payments xml fields
-- =====================================
UPDATE Payments
SET invoice_xml = REPLACE(invoice_xml, '<method>card</method>', '<method>transfer</method>')
WHERE payment_id IN (5001, 5009, 5017, 5064);

-- =====================================
-- UPDATES: Course section Languages
-- =====================================
UPDATE Course_Sections
SET language = 'Spanish'
WHERE section_id = 610;

-- =====================================
-- UPDATES: Instructor rank title
-- =====================================
UPDATE Instructors
SET rank_title = 'Associate Professor'
WHERE instructor_id = 12;

-- =====================================
-- UPDATES: Grades
-- =====================================
UPDATE Grades
SET score = LEAST(score + 5, 100)
WHERE score BETWEEN 60 AND 70;

-- =====================================
-- DELETE: Courses without sections
-- =====================================
DELETE FROM Courses
WHERE course_id NOT IN (SELECT course_id FROM Course_Sections);

-- =====================================
-- DELETE: Duplicated payments
-- =====================================
DELETE FROM Payments
WHERE payment_id NOT IN (
  SELECT payment_id FROM (
    SELECT MIN(payment_id) AS payment_id
    FROM Payments
    GROUP BY student_id, amount, payment_date
  ) AS t
);

-- =====================================
-- DELETE: Assessments without grades
-- =====================================
DELETE FROM Assessments
WHERE assessment_id NOT IN (
  SELECT assessment_id FROM Grades
);

-- =====================================
-- DELETE: Instructors without contracts
-- =====================================
DELETE FROM Instructors
WHERE instructor_id NOT IN (
  SELECT instructor_id FROM Instructor_Contracts
  UNION
  SELECT instructor_id FROM Schedules
);

-- =====================================
-- DELETE: Empty course sections
-- =====================================
DELETE FROM Course_Sections
WHERE section_id NOT IN (
  SELECT section_id FROM Enrollments
);

SET SQL_SAFE_UPDATES = 1;
-- ============================================================================= --


/* ===================================================
Data Query Language (DQL)
Craft complex queries
=================================================== */
/* ===================================================
   DQL-01: GPA RANKING BY PROGRAM (WINDOW FUNCTIONS)
   Description:
   - Computes a weighted GPA per student using Grades and Assessments.
   - Ranks students within each program and provides percentile.
   - Tables used: Students, Programs, Enrollments, Course_Sections, Assessments, Grades
   =================================================== */

WITH student_gpa AS (
    SELECT
        s.student_id,                                           -- Student identifier
        s.first_name,                                           -- First name
        s.last_name,                                            -- Last name
        p.program_id,                                           -- Program identifier
        p.name AS program_name,                                 -- Program name
        SUM(g.score * a.weight_pct / 100)
          / NULLIF(SUM(a.weight_pct), 0) AS gpa                 -- Weighted GPA across assessments
    FROM Students s
    JOIN Programs p        ON p.program_id = s.program_id
    JOIN Enrollments e     ON e.student_id = s.student_id
    JOIN Course_Sections cs ON cs.section_id = e.section_id
    JOIN Assessments a     ON a.section_id = cs.section_id
    JOIN Grades g          ON g.student_id = s.student_id
                           AND g.assessment_id = a.assessment_id
    GROUP BY s.student_id, s.first_name, s.last_name, p.program_id, p.name
)
SELECT
    student_id,
    first_name,
    last_name,
    program_id,
    program_name,
    ROUND(gpa, 2) AS gpa,                                       -- Rounded GPA
    ROW_NUMBER()   OVER (PARTITION BY program_id ORDER BY gpa DESC) AS rank_in_program,
    PERCENT_RANK() OVER (PARTITION BY program_id ORDER BY gpa)      AS pct_in_program
FROM student_gpa
ORDER BY program_id, rank_in_program;

/* ===================================================
   DQL-02: JSON ANALYTICS ON STUDENT PROFILES
   Description:
   - Extracts language and filters students whose "interests" array includes a given topic.
   - Aggregates student counts by declared language in profile_json (JSON).
   - Tables used: Students
   =================================================== */

SELECT
    JSON_UNQUOTE(JSON_EXTRACT(s.profile_json, '$.language')) AS language,  -- Language from JSON
    COUNT(*) AS students_count                                               -- Count of matching students
FROM Students s
WHERE JSON_CONTAINS(
        JSON_EXTRACT(s.profile_json, '$.interests'), 
        JSON_QUOTE('research')                                              -- Change 'research' to target interest
      )
GROUP BY language
ORDER BY students_count DESC;

/* ===================================================
   DQL-03: XML PARSING FROM PAYMENTS (REGEXP) + AGGREGATION
   Description:
   - Extracts <method> element from invoice_xml stored as TEXT.
   - Sums amounts by extracted payment method across terms.
   - Uses REGEXP_SUBSTR available in MySQL 8.
   =================================================== */

SELECT
    COALESCE(
        REGEXP_SUBSTR(p.invoice_xml, '<method>([^<]+)</method>'),
        'UNKNOWN'
    ) AS payment_method,                                        -- Extracted payment method from XML
    t.name AS term_name,                                        -- Term name
    SUM(p.amount) AS total_amount,                              -- Total paid amount per method/term
    COUNT(*) AS payments_count                                  -- Number of payments per method/term
FROM Payments p
JOIN Terms t ON t.term_id = p.term_id
GROUP BY payment_method, t.name
ORDER BY t.name, total_amount DESC;

/* ---------------------------------------------------
   Ensure FULLTEXT index exists for DQL-04
   --------------------------------------------------- */

-- Optional check
SHOW INDEX FROM Courses;

-- Create the composite FULLTEXT index (run once)
ALTER TABLE Courses 
  ADD FULLTEXT idx_courses_title_desc_ft (title, description);


/* ===================================================
   DQL-04: FULL-TEXT COURSE SEARCH WITH RELEVANCE
   Description:
   - Searches Courses by title/description using MATCH ... AGAINST.
   - Orders by relevance and returns top matches.
   - Requires FULLTEXT index on (title, description).
   =================================================== */

SELECT
    c.course_id,                                                -- Course identifier
    c.title,                                                    -- Course title
    MATCH(c.title, c.description) 
      AGAINST ('data science +machine -history' IN BOOLEAN MODE) AS relevance
FROM Courses c
WHERE MATCH(c.title, c.description) 
      AGAINST ('data science +machine -history' IN BOOLEAN MODE)
ORDER BY relevance DESC, c.title ASC
LIMIT 25;

/* ===================================================
   DQL-05: ROOM SCHEDULING CONFLICT DETECTION (WINDOW/LAG)
   Description:
   - Detects potential time overlaps per room and day using window functions.
   - Flags cases where a section’s start_time is before the previous end_time in same room/day.
   - Tables used: Schedules, Rooms, Course_Sections, Courses
   =================================================== */

WITH room_day_slots AS (
    SELECT
        r.building,                                             -- Building name
        r.room_number,                                          -- Room number
        sc.day_of_week,                                         -- Day of the week
        sc.start_time,                                          -- Slot start
        sc.end_time,                                            -- Slot end
        cs.section_id,                                          -- Section identifier
        c.title AS course_title,                                -- Course title
        LAG(sc.end_time) OVER (
            PARTITION BY r.room_id, sc.day_of_week
            ORDER BY sc.start_time
        ) AS prev_end_time                                      -- Previous slot end time in same room/day
    FROM Schedules sc
    JOIN Rooms r           ON r.room_id = sc.room_id
    JOIN Course_Sections cs ON cs.section_id = sc.section_id
    JOIN Courses c         ON c.course_id = cs.course_id
)
SELECT
    building,
    room_number,
    day_of_week,
    section_id,
    course_title,
    start_time,
    end_time,
    prev_end_time,
    (start_time < prev_end_time) AS has_conflict                 -- TRUE if overlapping
FROM room_day_slots
WHERE prev_end_time IS NOT NULL
  AND start_time < prev_end_time
ORDER BY building, room_number, day_of_week, start_time;

/* ===================================================
   DQL-06: SECTION CAPACITY UTILIZATION & OVERBOOKING RISK
   Description:
   - Computes fill rate per section (enrolled / capacity).
   - Highlights hot sections over 90% capacity and ranks within each term.
   - Tables used: Course_Sections, Enrollments, Terms
   =================================================== */

WITH enroll_counts AS (
    SELECT
        cs.section_id,                                          -- Section identifier
        cs.term_id,                                             -- Related term
        cs.capacity,                                            -- Section capacity
        COUNT(e.enrollment_id) AS enrolled                      -- Enrolled students
    FROM Course_Sections cs
    LEFT JOIN Enrollments e ON e.section_id = cs.section_id
    GROUP BY cs.section_id, cs.term_id, cs.capacity
),
utilization AS (
    SELECT
        ec.section_id,
        ec.term_id,
        t.name AS term_name,                                    -- Term name
        ec.capacity,
        ec.enrolled,
        ROUND(ec.enrolled / NULLIF(ec.capacity, 0) * 100, 2) AS fill_rate_pct,
        ROW_NUMBER() OVER (PARTITION BY ec.term_id ORDER BY ec.enrolled DESC) AS rank_in_term
    FROM enroll_counts ec
    JOIN Terms t ON t.term_id = ec.term_id
)
SELECT
    section_id,
    term_id,
    term_name,
    capacity,
    enrolled,
    fill_rate_pct,
    rank_in_term
FROM utilization
WHERE fill_rate_pct >= 90                                      -- Threshold for “hot” sections
ORDER BY term_id, rank_in_term;

-- ========================================================================================
-- DQL-07: Students above their program average in the same term (correlated subquery)
-- Schema mapping:
--   - program_id: Students
--   - term_id:    Course_Sections
--   - GPA term:   SUM(Grades.score * Assessments.weight_pct/100) / SUM(Assessments.weight_pct)
-- ========================================================================================
WITH term_gpa AS (
    SELECT 
        s.student_id,
        s.program_id,
        cs.term_id,
        SUM(g.score * a.weight_pct / 100.0) / NULLIF(SUM(a.weight_pct), 0) AS term_gpa
    FROM Enrollments e
    JOIN Students s         ON s.student_id  = e.student_id
    JOIN Course_Sections cs ON cs.section_id = e.section_id
    JOIN Assessments a      ON a.section_id  = cs.section_id
    JOIN Grades g           ON g.student_id  = s.student_id
                           AND g.assessment_id = a.assessment_id
    GROUP BY s.student_id, s.program_id, cs.term_id
)
SELECT 
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    p.name  AS program_name,
    t.name  AS term_name,
    ROUND(tg.term_gpa, 2) AS term_gpa,
    (
        SELECT ROUND(AVG(tg2.term_gpa), 2)
        FROM term_gpa tg2
        WHERE tg2.program_id = tg.program_id
          AND tg2.term_id    = tg.term_id
    ) AS program_term_avg
FROM term_gpa tg
JOIN Students  s ON s.student_id = tg.student_id
JOIN Programs  p ON p.program_id = tg.program_id
JOIN Terms     t ON t.term_id    = tg.term_id
WHERE tg.term_gpa > (
    SELECT AVG(tg3.term_gpa)
    FROM term_gpa tg3
    WHERE tg3.program_id = tg.program_id
      AND tg3.term_id    = tg.term_id
)
ORDER BY p.name, t.name, tg.term_gpa DESC;
