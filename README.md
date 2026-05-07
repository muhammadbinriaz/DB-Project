# Student Academic Progression & Early Dropout Risk Detection System
**DBMS Semester Project — Riphah International University**  
Muhammad Bin Riaz | SAP: 65256 | BSCS 4-2 | Fall 2026

---

## What It Does
A MySQL database system that tracks student GPA, attendance, and course grades to automatically classify students as **High / Moderate / Low** dropout risk.

---

## Database Tables
| Table | Description |
|---|---|
| `Department` | Departments and HODs |
| `Student` | Student profiles with CGPA and status |
| `Course` | Courses offered per department |
| `Enrollment` | Student–course links with grades |
| `Attendance_Log` | Daily attendance records |
| `Semester_GPA` | Per-semester GPA history |

---

## Risk Detection Logic
| Indicator | Threshold |
|---|---|
| GPA Decline | 2+ consecutive semesters dropping |
| Low Attendance | Below 60% |
| Course Failures | 2 or more F grades |
| Low CGPA | Below 2.0 after 2nd semester |

- **High Risk** → 2+ indicators  
- **Moderate Risk** → 1 indicator  
- **Low Risk** → None  

---

## Tools
- **Database:** MySQL 8.0  
- **IDE:** MySQL Workbench  
