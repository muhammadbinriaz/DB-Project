

CREATE TABLE Students (
    Student_ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Age INT CHECK (Age BETWEEN 15 AND 60),
    Gender VARCHAR(10),
    Enrollment_Date DATE
);


CREATE TABLE Courses (
    Course_ID INT PRIMARY KEY AUTO_INCREMENT,
    Course_Name VARCHAR(100) NOT NULL,
    Credits INT CHECK (Credits > 0)
);


CREATE TABLE Teachers (
    Teacher_ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100),
    Email VARCHAR(100) UNIQUE
);


CREATE TABLE Enrollment (
    Enrollment_ID INT PRIMARY KEY AUTO_INCREMENT,
    Student_ID INT,
    Course_ID INT,
    
    FOREIGN KEY (Student_ID) REFERENCES Students(Student_ID)
        ON DELETE CASCADE,
    FOREIGN KEY (Course_ID) REFERENCES Courses(Course_ID)
        ON DELETE CASCADE,
    
    UNIQUE (Student_ID, Course_ID)
);






INSERT INTO Students (Name, Age, Gender, Enrollment_Date)
VALUES
('Hanzala Baqir', 21, 'Male', '2023-09-01'),
('Ahmed Ali', 22, 'Male', '2023-09-01'),
('Ayesha Noor', 20, 'Female', '2023-09-01');

INSERT INTO Courses (Course_Name, Credits)
VALUES
('Database Systems', 3),
('Data Structures', 4);

INSERT INTO Enrollment (Student_ID, Course_ID)
VALUES
(1,1),(2,1),(3,2);

INSERT INTO Attendance (Student_ID, Course_ID, Attendance_Percentage)
VALUES
(1,1,85),
(2,1,45),
(3,2,60);

INSERT INTO Grades (Student_ID, Course_ID, Marks)
VALUES
(1,1,78),
(2,1,35),
(3,2,50);


SELECT s.Name, a.Attendance_Percentage, g.Marks
FROM Students s
JOIN Attendance a ON s.Student_ID = a.Student_ID
JOIN Grades g ON s.Student_ID = g.Student_ID
WHERE a.Attendance_Percentage < 50 AND g.Marks < 40;


SELECT s.Name
FROM Students s
JOIN Attendance a ON s.Student_ID = a.Student_ID
JOIN Grades g ON s.Student_ID = g.Student_ID
WHERE a.Attendance_Percentage BETWEEN 50 AND 70;


SELECT s.Name
FROM Students s
JOIN Attendance a ON s.Student_ID = a.Student_ID
JOIN Grades g ON s.Student_ID = g.Student_ID
WHERE a.Attendance_Percentage > 70 AND g.Marks > 50;


SELECT * FROM Students;

SELECT s.Name, c.Course_Name, g.Marks, a.Attendance_Percentage
FROM Students s
JOIN Enrollment e ON s.Student_ID = e.Student_ID
JOIN Courses c ON e.Course_ID = c.Course_ID
JOIN Grades g ON s.Student_ID = g.Student_ID
JOIN Attendance a ON s.Student_ID = a.Student_ID;
