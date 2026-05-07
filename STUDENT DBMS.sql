-- STUDENT ACADEMIC PROGRESSION & EARLY DROPOUT RISK DETECTION SYSTEM

-- 1. DEPARTMENT TABLE
CREATE TABLE Department (
    Dept_ID INT PRIMARY KEY AUTO_INCREMENT,
    Dept_Name VARCHAR(100) NOT NULL,
    HOD_Name VARCHAR(100) NOT NULL
);

-- 2. STUDENT TABLE
CREATE TABLE Student (
    Student_ID INT PRIMARY KEY AUTO_INCREMENT,
    Dept_ID INT NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    CGPA DECIMAL(3,2) DEFAULT 0 CHECK (CGPA BETWEEN 0 AND 4),
    Status VARCHAR(20) DEFAULT 'Active' CHECK (Status IN ('Active','Probation','Dropout')),
    FOREIGN KEY (Dept_ID) REFERENCES Department(Dept_ID)
);

-- 3. COURSE TABLE
CREATE TABLE Course (
    Course_ID INT PRIMARY KEY AUTO_INCREMENT,
    Dept_ID INT NOT NULL,
    Course_Title VARCHAR(100) NOT NULL,
    Credit_Hours INT CHECK (Credit_Hours > 0),
    FOREIGN KEY (Dept_ID) REFERENCES Department(Dept_ID)
);

-- 4. ENROLLMENT TABLE
CREATE TABLE Enrollment (
    Enrollment_ID INT PRIMARY KEY AUTO_INCREMENT,
    Student_ID INT NOT NULL,
    Course_ID INT NOT NULL,
    Semester VARCHAR(20) NOT NULL,
    Grade VARCHAR(2),
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID) ON DELETE CASCADE,
    FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID) ON DELETE CASCADE,
    UNIQUE (Student_ID, Course_ID, Semester)
);

-- 5. ATTENDANCE_LOG TABLE
CREATE TABLE Attendance_Log (
    Attendance_ID INT PRIMARY KEY AUTO_INCREMENT,
    Student_ID INT NOT NULL,
    Att_Date DATE NOT NULL,
    Status VARCHAR(10) CHECK (Status IN ('Present', 'Absent', 'Late')),
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID) ON DELETE CASCADE
);

-- 6. SEMESTER_GPA TABLE
CREATE TABLE Semester_GPA (
    GPA_Record_ID INT PRIMARY KEY AUTO_INCREMENT,
    Student_ID INT NOT NULL,
    Semester VARCHAR(20) NOT NULL,
    GPA DECIMAL(3,2) CHECK (GPA BETWEEN 0 AND 4),
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID) ON DELETE CASCADE
);

-- DML - INSERT SAMPLE DATA

INSERT INTO Department VALUES (1, 'Computer Science', 'Dr. Tariq');
INSERT INTO Department VALUES (2, 'Software Engineering', 'Dr. Amna');

INSERT INTO Student VALUES (101, 1, 'Muhammad Bin Riaz', 'muhammad@riphah.edu.pk', 3.5, 'Active');
INSERT INTO Student VALUES (102, 1, 'Ahmed Ali', 'ahmed@riphah.edu.pk', 1.8, 'Probation');
INSERT INTO Student VALUES (103, 2, 'Ayesha Noor', 'ayesha@riphah.edu.pk', 2.9, 'Active');
INSERT INTO Student VALUES (104, 2, 'Bilal Khan', 'bilal@riphah.edu.pk', 1.5, 'Probation');

INSERT INTO Course VALUES (201, 1, 'Database Systems', 3);
INSERT INTO Course VALUES (202, 1, 'Data Structures', 4);
INSERT INTO Course VALUES (203, 2, 'Software Design', 3);

INSERT INTO Enrollment VALUES (301, 101, 201, 'Fall-2025', 'A');
INSERT INTO Enrollment VALUES (302, 102, 201, 'Fall-2025', 'F');
INSERT INTO Enrollment VALUES (303, 103, 202, 'Fall-2025', 'B');
INSERT INTO Enrollment VALUES (304, 104, 201, 'Fall-2025', 'F');
INSERT INTO Enrollment VALUES (305, 104, 202, 'Fall-2025', 'F');

INSERT INTO Attendance_Log VALUES (401, 101, '2025-10-01', 'Present');
INSERT INTO Attendance_Log VALUES (402, 102, '2025-10-01', 'Absent');
INSERT INTO Attendance_Log VALUES (403, 103, '2025-10-01', 'Present');
INSERT INTO Attendance_Log VALUES (404, 104, '2025-10-01', 'Absent');
INSERT INTO Attendance_Log VALUES (405, 101, '2025-10-02', 'Present');
INSERT INTO Attendance_Log VALUES (406, 102, '2025-10-02', 'Absent');
INSERT INTO Attendance_Log VALUES (407, 103, '2025-10-02', 'Present');
INSERT INTO Attendance_Log VALUES (408, 104, '2025-10-02', 'Absent');
INSERT INTO Attendance_Log VALUES (409, 101, '2025-10-03', 'Present');
INSERT INTO Attendance_Log VALUES (410, 102, '2025-10-03', 'Absent');
INSERT INTO Attendance_Log VALUES (411, 103, '2025-10-03', 'Late');
INSERT INTO Attendance_Log VALUES (412, 104, '2025-10-03', 'Absent');

INSERT INTO Semester_GPA VALUES (501, 101, 'Spring-2025', 3.7);
INSERT INTO Semester_GPA VALUES (502, 101, 'Fall-2025', 3.5);
INSERT INTO Semester_GPA VALUES (503, 102, 'Spring-2025', 2.8);
INSERT INTO Semester_GPA VALUES (504, 102, 'Fall-2025', 1.8);
INSERT INTO Semester_GPA VALUES (505, 104, 'Spring-2025', 2.0);
INSERT INTO Semester_GPA VALUES (506, 104, 'Fall-2025', 1.5);

-- VIEWS

CREATE OR REPLACE VIEW vw_AtRisk_Students AS
SELECT s.Student_ID, s.Name, s.CGPA,
    COUNT(CASE WHEN e.Grade = 'F' THEN 1 END) AS Failed_Courses,
    ROUND(COUNT(CASE WHEN a.Status = 'Present' THEN 1 END) * 100.0 / NULLIF(COUNT(a.Attendance_ID), 0), 1) AS Attendance_Pct
FROM Student s
LEFT JOIN Enrollment e ON s.Student_ID = e.Student_ID
LEFT JOIN Attendance_Log a ON s.Student_ID = a.Student_ID
GROUP BY s.Student_ID, s.Name, s.CGPA
HAVING s.CGPA < 2.5 OR COUNT(CASE WHEN e.Grade = 'F' THEN 1 END) >= 2
    OR (COUNT(CASE WHEN a.Status = 'Present' THEN 1 END) * 100.0 / NULLIF(COUNT(a.Attendance_ID), 0)) < 60;

CREATE OR REPLACE VIEW vw_Dept_Summary AS
SELECT d.Dept_Name, COUNT(s.Student_ID) AS Total_Students,
    ROUND(AVG(s.CGPA),2) AS Avg_CGPA,
    COUNT(CASE WHEN s.Status = 'Probation' THEN 1 END) AS On_Probation,
    COUNT(CASE WHEN s.Status = 'Dropout' THEN 1 END) AS Dropped_Out
FROM Department d
LEFT JOIN Student s ON d.Dept_ID = s.Dept_ID
GROUP BY d.Dept_Name;

-- RISK DETECTION QUERIES

-- Students with 2+ F grades
SELECT s.Student_ID, s.Name, COUNT(e.Grade) AS F_Count
FROM Student s
JOIN Enrollment e ON s.Student_ID = e.Student_ID
WHERE e.Grade = 'F'
GROUP BY s.Student_ID, s.Name
HAVING COUNT(e.Grade) >= 2;

-- Consecutive GPA Decline
SELECT g1.Student_ID, s.Name, g1.Semester AS Sem1, g1.GPA AS GPA1,
    g2.Semester AS Sem2, g2.GPA AS GPA2
FROM Semester_GPA g1
JOIN Semester_GPA g2 ON g1.Student_ID = g2.Student_ID
JOIN Student s ON g1.Student_ID = s.Student_ID
WHERE g2.GPA < g1.GPA AND g1.Semester < g2.Semester
ORDER BY g1.Student_ID;

-- Comprehensive Risk Report
SELECT s.Student_ID, s.Name, s.CGPA,
    (SELECT COUNT(*) FROM Enrollment e WHERE e.Student_ID = s.Student_ID AND e.Grade = 'F') AS F_Grades,
    ROUND((SELECT COUNT(*) FROM Attendance_Log a WHERE a.Student_ID = s.Student_ID AND a.Status = 'Present') * 100.0 /
        NULLIF((SELECT COUNT(*) FROM Attendance_Log a2 WHERE a2.Student_ID = s.Student_ID), 0), 1) AS Attendance_Pct,
    CASE
        WHEN s.CGPA < 2.0 AND (SELECT COUNT(*) FROM Enrollment e WHERE e.Student_ID = s.Student_ID AND e.Grade = 'F') >= 2 THEN 'HIGH RISK'
        WHEN s.CGPA < 2.5 OR (SELECT COUNT(*) FROM Enrollment e WHERE e.Student_ID = s.Student_ID AND e.Grade = 'F') >= 1 THEN 'MODERATE RISK'
        ELSE 'LOW RISK'
    END AS Risk_Level
FROM Student s
ORDER BY Risk_Level, s.CGPA ASC;

-- Attendance below 60%
SELECT s.Student_ID, s.Name,
    ROUND((COUNT(CASE WHEN a.Status = 'Present' THEN 1 END) * 100.0) / COUNT(a.Attendance_ID), 1) AS Attendance_Pct
FROM Student s
JOIN Attendance_Log a ON s.Student_ID = a.Student_ID
GROUP BY s.Student_ID, s.Name
HAVING (COUNT(CASE WHEN a.Status = 'Present' THEN 1 END) * 100.0) / COUNT(a.Attendance_ID) < 60;
