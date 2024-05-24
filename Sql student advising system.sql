create database Advising_Team_36
GO
--create Procedure Procedures_AdminDeleteCourse 
--@course_ID int 
--AS 
--Begin
--update slot
--set instructor_id = null
--where course_id = @course_ID
--update slot 
--set course_id = null
--where course_id = @course_ID

--delete from Instructor_Course
--where @course_ID = course_id

--delete from Student_Instructor_Course_Take
--where @course_ID = course_id

--delete from Course_Semester 
--where @course_ID = course_id

--Delete from PreqCourse_course
--where course_id = @course_ID or  prerequisite_course_id = @course_ID
--End 

--Delete From Course
--Where course_id = @course_ID;
GO
--create function fn_helper_make_studentstatus_derived
--(@student_id int)
--returns bit
--AS
--begin 
--declare
--@res bit
--if exists(
--select *
--from payment p inner join Installment i on i.payment_id = p.payment_id
--where p.student_id = @student_id and i.status = 'notPaid' and i.deadline < CURRENT_TIMESTAMP
--)
--set @res = 0
--else
--set @res = 1

--return @res
--end
--GO
create procedure  CreateAllTables
AS
create table Advisor (
	advisor_id int Primary Key identity(1,1) ,
	name varchar (40), 
	email varchar (40), 
	office varchar (40), 
	password varchar(40),
)

create table Student (
	student_id int identity(1,1) Primary Key ,
	f_name varchar (40),
	l_name varchar (40),
	gpa decimal(10,2) check (gpa between 0.7 and 5), 
	faculty varchar (40), 
	email varchar (40),
	major varchar (40),
	password varchar (40),
	financial_status bit,
	semester int, 
	acquired_hours int check (acquired_hours >=34),
	assigned_hours int check (assigned_hours <=34) ,
	advisor_id int ,
	constraint fk_student Foreign key (advisor_id) references Advisor(advisor_id) on update cascade on delete set null
	)

	

	create table Student_Phone (
	student_id int , 
	phone_number varchar(40),
	Constraint Pk_Student_Phone Primary Key (student_id , phone_number),
	constraint fk_student_Phone Foreign key (student_id) references Student(student_id) on update cascade on delete cascade
)

    create table Course (
	course_id int Primary Key identity(1,1),
	name varchar (40), 
	major varchar(40),
	is_offered bit,
	credit_hours int,
	semester int,
)

create table PreqCourse_course (
	prerequisite_course_id int ,
	course_id int ,
	Constraint Pk_PreqCourse_course Primary Key (prerequisite_course_id ,course_id ),
	Constraint fk_PreqCourse_course1 Foreign key (prerequisite_course_id) references Course (course_id),
	Constraint fk_PreqCourse_course2 Foreign key (course_id) references Course (course_id) 

)

create table Instructor (
	instructor_id int Primary Key identity(1,1),
	name  varchar (40), 
	email  varchar (40), 
	faculty varchar (40),
	office varchar (40),
)

create table Instructor_Course (
	course_id int , 
	instructor_id int ,
	Constraint PK_Instructor_Course Primary Key (instructor_id ,course_id ),
	constraint fk_Instructor_CourseForeign1 foreign key (course_id) references Course(course_id) on update cascade on delete cascade,
	constraint fk_Instructor_CourseForeign2 Foreign key (instructor_id) references Instructor(instructor_id) on update cascade on delete cascade,
)

create table Student_Instructor_Course_Take (
	student_id int, 
	course_id int, 
	instructor_id int ,
	semester_code varchar (40),
	exam_type  varchar(40) default 'normal' Check (exam_type in ('Normal' , 'First_makeup' , 'Second_makeup')),
	grade varchar (40),
	Constraint PK_Course_Semester Primary Key (course_id , student_id, semester_code),
	constraint fk_Student_Instructor_Course_Take1 Foreign key (course_id) references Course(course_id) on update cascade on delete cascade,
	constraint fk_Student_Instructor_Course_Take2 Foreign key  (instructor_id) references Instructor(instructor_id) on update cascade on delete cascade,
	constraint fk_Student_Instructor_Course_Take3 Foreign key (student_id) references Student(student_id) on update cascade on delete cascade,
)

create table Semester (
	semester_code varchar(40) Primary Key , 
	start_date date, 
	end_date date
)

create table Course_Semester (
	course_id int  , 
	semester_code varchar (40)
	Constraint PK_Course_Semesters Primary Key (course_id , semester_code),
	Constraint fk_Course_Semester1 Foreign Key (course_id) references Course(course_id) on update cascade on delete cascade,
	Constraint fk_Course_Semester2 Foreign Key (semester_code) references Semester(semester_code) on update cascade on delete cascade,
)

create table Slot (
	slot_id int Primary Key identity(1,1) ,
	day varchar(40),
	time varchar(40),
	location varchar(40),
	course_id int ,
	instructor_id int,
	Constraint fk_slot1 Foreign Key (course_id) references Course(course_id) on update cascade on delete set null,
	Constraint fk_slot2 Foreign key (instructor_id) references Instructor(instructor_id) on update cascade on delete set null,
)

create table Graduation_Plan (
	plan_id int identity(1,1) ,
	semester_code varchar (40),
	semester_credit_hours int ,
	expected_grad_date date , 
	advisor_id int,
	student_id int,
	Constraint PK_Graduation_Plan Primary Key (semester_code, plan_id),
	constraint fk_Graduation_Plan1 Foreign Key (advisor_id) references Advisor(advisor_id) on update cascade on delete set null,
	constraint fk_Graduation_Plan2 Foreign key (student_id) references Student(student_id) 
)

create table GradPlan_Course (
	plan_id int, 
	semester_code varchar(40), 
	course_id int,
	Constraint PK_GradPlan_Course Primary Key (course_id ,semester_code, plan_id),
	--Foreign Key (course_id) references Course(course_id) on update cascade,
	constraint fk_GradPlan_Course1 Foreign Key (semester_code,plan_id) references Graduation_Plan(semester_code, plan_id) on update cascade on delete cascade
)

create table Request (
	request_id int Primary Key identity(1,1),
	type  varchar(40) check (type in ('course', 'credit_hours')),
	comment varchar (40),
	status varchar(40) default 'pending' Check ( status in ('pending', 'accepted', 'rejected')),
	credit_hours int,
	student_id int,
	advisor_id int,
	course_id int,
	constraint fk_request1 Foreign Key (course_id) references Course(course_id) on update cascade on delete set null,
	constraint fk_request2 Foreign Key (advisor_id) references Advisor(advisor_id) on update cascade on delete set null,
	constraint fk_request3 Foreign key (student_id) references Student(student_id) 
)

create table MakeUp_Exam (
	exam_id int  Primary Key identity(1,1),
	date Datetime,
	type varchar(40) default 'normal' Check (type in ('Normal' , 'First_makeup' , 'Second_makeup')),
	course_id int ,
	constraint fk_MakeUp_Exam Foreign Key (course_id) references Course(course_id) on update cascade on delete set null,
)

create table Exam_Student (
	exam_id int ,
	student_id int, 
	course_id int,
	Constraint PK_Exam_Student Primary Key (exam_id ,student_id),
	constraint fk_Exam_Student1 Foreign key (student_id) references Student(student_id) on update cascade on delete cascade,
	constraint fk_Exam_Student2 Foreign Key (exam_id) references  MakeUp_Exam (exam_id) on update cascade on delete cascade,
)

create table Payment(
	payment_id int Primary Key identity(1,1),
	amount int ,
	deadline datetime,
	n_installments int default 0 not null ,
	constraint n_installments check(n_installments = datediff(month,start_date,deadline) ),
	status varchar(40) default 'notPaid' Check (status in ('NotPaid' , 'Paid')),
	fund_percentage decimal,
	student_id int , 
	start_date datetime,
	semester_code varchar(40),
	constraint fk_payment1 Foreign key (student_id) references Student(student_id) on update cascade on delete set null,
	constraint fk_payment2 Foreign Key (semester_code) references Semester(semester_code) on update cascade on delete set null,
)

create table Installment (
	payment_id int ,
	deadline datetime,
	amount int ,
	status varchar(40) default 'NotPaid' Check (status in ('NotPaid' , 'Paid')),
	start_date datetime,
	constraint deadlinecheck check (deadline = dateadd(month,1,start_date )),
	Constraint PK_Installment Primary Key (payment_id ,deadline),
	constraint fk_installment Foreign key (payment_id) references Payment(payment_id) on update cascade on delete cascade,
	

)
GO
EXEC CreateAllTables
GO

create proc insertion
AS
-- Adding 10 records to the Course table
INSERT INTO Course(name, major, is_offered, credit_hours, semester)  VALUES
( 'Mathematics 2', 'Science', 1, 3, 2),
( 'CSEN 2', 'Engineering', 1, 4, 2),
( 'Database 1', 'MET', 1, 3, 5),
( 'Physics', 'Science', 0, 4, 1),
( 'CSEN 4', 'Engineering', 1, 3, 4),
( 'Chemistry', 'Engineering', 1, 4, 1),
( 'CSEN 3', 'Engineering', 1, 3, 3),
( 'Computer Architecture', 'MET', 0, 3, 6),
( 'Computer Organization', 'Engineering', 1, 4, 4),
( 'Database2', 'MET', 1, 3, 6);


-- Adding 10 records to the Instructor table
INSERT INTO Instructor(name, email, faculty, office) VALUES
( 'Professor Smith', 'prof.smith@example.com', 'MET', 'Office A'),
( 'Professor Johnson', 'prof.johnson@example.com', 'MET', 'Office B'),
( 'Professor Brown', 'prof.brown@example.com', 'MET', 'Office C'),
( 'Professor White', 'prof.white@example.com', 'MET', 'Office D'),
( 'Professor Taylor', 'prof.taylor@example.com', 'Mechatronics', 'Office E'),
( 'Professor Black', 'prof.black@example.com', 'Mechatronics', 'Office F'),
( 'Professor Lee', 'prof.lee@example.com', 'Mechatronics', 'Office G'),
( 'Professor Miller', 'prof.miller@example.com', 'Mechatronics', 'Office H'),
( 'Professor Davis', 'prof.davis@example.com', 'IET', 'Office I'),
( 'Professor Moore', 'prof.moore@example.com', 'IET', 'Office J');

-- Adding 10 records to the Semester table
INSERT INTO Semester(semester_code, start_date, end_date) VALUES
('W23', '2023-10-01', '2024-01-31'),
('S23', '2023-03-01', '2023-06-30'),
('S23R1', '2023-07-01', '2023-07-31'),
('S23R2', '2023-08-01', '2023-08-31'),
('W24', '2024-10-01', '2025-01-31'),
('S24', '2024-03-01', '2024-06-30'),
('S24R1', '2024-07-01', '2024-07-31'),
('S24R2', '2024-08-01', '2024-08-31')

-- Adding 10 records to the Advisor table
INSERT INTO Advisor(name, email, office, password) VALUES
( 'Dr. Anderson', 'anderson@example.com', 'Office A', 'password1'),
( 'Prof. Baker', 'baker@example.com', 'Office B', 'password2'),
( 'Dr. Carter', 'carter@example.com', 'Office C', 'password3'),
( 'Prof. Davis', 'davis@example.com', 'Office D', 'password4'),
( 'Dr. Evans', 'evans@example.com', 'Office E', 'password5'),
( 'Prof. Foster', 'foster@example.com', 'Office F', 'password6'),
( 'Dr. Green', 'green@example.com', 'Office G', 'password7'),
( 'Prof. Harris', 'harris@example.com', 'Office H', 'password8'),
( 'Dr. Irving', 'irving@example.com', 'Office I', 'password9'),
( 'Prof. Johnson', 'johnson@example.com', 'Office J', 'password10');

-- Adding 10 records to the Student table
INSERT INTO Student (f_name, l_name, GPA, faculty, email, major, password, financial_status, semester, acquired_hours, assigned_hours, advisor_id)   VALUES 
( 'John', 'Doe', 3.5, 'Engineering', 'john.doe@example.com', 'CS', 'password123', 1, 1, 90, 30, 1),
( 'Jane', 'Smith', 3.8, 'Engineering', 'jane.smith@example.com', 'CS', 'password456', 1, 2, 85, 34, 2),
( 'Mike', 'Johnson', 3.2, 'Engineering', 'mike.johnson@example.com', 'CS', 'password789', 1, 3, 75, 34, 3),
( 'Emily', 'White', 3.9, 'Engineering', 'emily.white@example.com', 'CS', 'passwordabc', 0, 4, 95, 34, 4),
( 'David', 'Lee', 3.4, 'Engineering', 'david.lee@example.com', 'IET', 'passworddef', 1, 5, 80, 34, 5),
( 'Grace', 'Brown', 3.7, 'Engineering', 'grace.brown@example.com', 'IET', 'passwordghi', 0, 6, 88, 34, 6),
( 'Robert', 'Miller', 3.1, 'Engineerings', 'robert.miller@example.com', 'IET', 'passwordjkl', 1, 7, 78, 34, 7),
( 'Sophie', 'Clark', 3.6, 'Engineering', 'sophie.clark@example.com', 'Mechatronics', 'passwordmno', 1, 8, 92, 34, 8),
( 'Daniel', 'Wilson', 3.3, 'Engineering', 'daniel.wilson@example.com', 'DMET', 'passwordpqr', 1, 9, 87, 34, 9),
( 'Olivia', 'Anderson', 3.7, 'Engineeringe', 'olivia.anderson@example.com', 'Mechatronics', 'passwordstu', 0, 10, 89, 34, 10);


-- Adding 10 records to the Student_Phone table
INSERT INTO Student_Phone(student_id, phone_number) VALUES
(4, '456-789-0123'),
(5, '567-890-1234'),
(6, '678-901-2345'),
(7, '789-012-3456'),
(8, '890-123-4567'),
(9, '901-234-5678'),
(10, '012-345-6789');


-- Adding 10 records to the PreqCourse_course table
INSERT INTO PreqCourse_course(prerequisite_course_id, course_id) VALUES
(2, 7),
(3, 10),
(2, 4),
(5, 6),
(4, 7),
(6, 8),
(7, 9),
(9, 10),
(9, 1),
(10, 3);


-- Adding 10 records to the Instructor_Course table
INSERT INTO Instructor_Course (instructor_id, course_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);


-- Adding 10 records to the Student_Instructor_Course_Take table
INSERT INTO Student_Instructor_Course_Take (student_id, course_id, instructor_id, semester_code,exam_type, grade) VALUES
(1, 1, 1, 'W23', 'Normal', 'A'),
(2, 2, 2, 'S23', 'First_makeup', 'B'),
(3, 3, 3, 'S23R1', 'Second_makeup', 'C'),
(4, 4, 4, 'S23R2', 'Normal', 'B+'),
(5, 5, 5, 'W23', 'Normal', 'A-'),
(6, 6, 6, 'W24', 'First_makeup', 'B'),
(7, 7, 7, 'S24', 'Second_makeup', 'C+'),
(8, 8, 8, 'S24R1', 'Normal', 'A+'),
(9, 9, 9, 'S24R2', 'Normal', 'FF'),
(10, 10, 10, 'S24', 'First_makeup', 'B-');



-- Adding 10 records to the Course_Semester table
INSERT INTO Course_Semester (course_id, semester_code) VALUES
(1, 'W23'),
(2, 'S23'),
(3, 'S23R1'),
(4, 'S23R2'),
(5, 'W23'),
(6, 'W24'),
(7, 'S24'),
(8, 'S24R1'),
(9, 'S24R2'),
(10, 'S24');

-- Adding 10 records to the Slot table
INSERT INTO Slot (day, time, location, course_id, instructor_id) VALUES
( 'Monday', 'First', 'Room A', 1, 1),
( 'Tuesday', 'First', 'Room B', 2, 2),
( 'Wednesday', 'Third', 'Room C', 3, 3),
( 'Thursday', 'Fifth', 'Room D', 4, 4),
( 'Saturday', 'Second', 'Room E', 5, 5),
( 'Monday', 'Fourth', 'Room F', 6, 6),
( 'Tuesday', 'Second', 'Room G', 7, 7),
( 'Wednesday', 'Fifth', 'Room H', 8, 8),
( 'Thursday', 'First', 'Room I', 9, 9),
( 'Sunday', 'Fourth', 'Room J', 10, 10);


-- Adding 10 records to the Graduation_Plan table
INSERT INTO Graduation_Plan (semester_code, semester_credit_hours, expected_grad_date, student_id, advisor_id) VALUES
( 'W23', 90,    '2024-01-31' ,   1, 1),
( 'S23', 85,    '2025-01-31'  ,     2, 2),
( 'S23R1', 75,  '2025-06-30' ,  3, 3),
( 'S23R2', 95,  '2024-06-30' , 4, 4),
( 'W23', 80,    '2026-01-31'   ,  5, 5),
( 'W24', 88,    '2024-06-30'   ,    6, 6),
( 'S24', 78,    '2024-06-30'    ,  7, 7),
( 'S24R1', 92,  '2025-01-31'  , 8, 8),
( 'S24R2', 87,  '2024-06-30'    ,  9, 9),
( 'S24', 89,    '2025-01-31'    ,    10, 10);

-- Adding 10 records to the GradPlan_Course table
INSERT INTO GradPlan_Course(plan_id, semester_code, course_id) VALUES
(1, 'W23', 1),
(2, 'S23', 2),
(3, 'S23R1', 3),
(4, 'S23R2', 4),
(5, 'W23', 5),
(6, 'W24', 6),
(7, 'S24', 7),
(8, 'S24R1', 8),
(9, 'S24R2', 9),
(10, 'S24', 10);

-- Adding 10 records to the Request table
INSERT INTO Request (type, comment, status, credit_hours, course_id, student_id, advisor_id) VALUES 
( 'course', 'Request for additional course', 'pending', null, 1, 1, 2),
( 'course', 'Need to change course', 'accepted', null, 2, 2, 2),
( 'credit_hours', 'Request for extra credit hours', 'pending', 3, null, 3, 3),
( 'credit_hours', 'Request for reduced credit hours', 'accepted', 1, null, 4, 5),
( 'course', 'Request for special course', 'rejected', null, 5, 5, 5),
( 'credit_hours', 'Request for extra credit hours', 'pending', 4, null, 6, 7),
( 'course', 'Request for course withdrawal', 'accepted', null, 7, 7, 7),
( 'course', 'Request for course addition', 'rejected', null, 8, 8, 8),
( 'credit_hours', 'Request for reduced credit hours', 'accepted', 2, null, 9, 8),
( 'course', 'Request for course substitution', 'pending', null, 10, 10, 10);

-- Adding 10 records to the MakeUp_Exam table
INSERT INTO MakeUp_Exam (date, type, course_id) VALUES
('2023-02-10', 'First_MakeUp', 1),
('2023-02-15', 'First_MakeUp', 2),
('2023-02-05', 'First_MakeUp', 3),
('2023-02-25', 'First_MakeUp', 4),
('2023-02-05', 'First_MakeUp', 5),
('2024-09-10', 'Second_MakeUp', 6),
('2024-09-20', 'Second_MakeUp', 7),
('2024-09-05', 'Second_MakeUp', 8),
('2024-09-10', 'Second_MakeUp', 9),
( '2024-09-15', 'Second_MakeUp', 10);

-- Adding 10 records to the Exam_Student table
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (1, 1, 1);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (1, 2, 2);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (1, 3, 3);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (2, 2, 4);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (2, 3, 5);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (2, 4, 6);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (3, 3, 7);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (3, 4, 8);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (3, 5, 9);
INSERT INTO Exam_Student(exam_id, student_id,course_id) VALUES (4, 4, 10);

-- Adding 10 records to the Payment table
INSERT INTO Payment (amount, start_date, n_installments, status, fund_percentage, student_id, semester_code, deadline)  VALUES
( 500, '2023-11-22', 1, 'notPaid', 50.00, 1, 'W23', '2023-12-22'),
( 700, '2023-11-23', 1, 'notPaid', 60.00, 2, 'S23', '2023-12-23'),
( 600, '2023-11-24', 4, 'notPaid', 40.00, 3, 'S23R1', '2024-03-24'),
( 800, '2023-11-25', 1, 'notPaid', 70.00, 4, 'S23R2', '2023-12-25'),
( 550, '2023-11-26', 5, 'notPaid', 45.00, 5, 'W23', '2024-04-26'),
( 900, '2023-11-27', 1, 'notPaid', 80.00, 6, 'W24', '2023-12-27'),
( 750, '2023-10-28', 2, 'Paid', 65.00, 7, 'S24', '2023-12-28'),
( 620, '2023-08-29', 4, 'Paid', 55.00, 8, 'S24R1', '2023-12-29'),
( 720, '2023-11-30', 2, 'notPaid', 75.00, 9, 'S24R2', '2024-01-30'),
( 580, '2023-11-30', 1, 'Paid', 47.00, 10, 'S24', '2023-12-31');



-- Adding 10 records to the Installment table
INSERT INTO Installment (payment_id, start_date, amount, status, deadline) VALUES
(1, '2023-11-22', 50, 'notPaid','2023-12-22'),
(2, '2023-11-23', 70, 'notPaid','2023-12-23'),
(3, '2023-12-24', 60, 'notPaid','2024-01-24'),
( 4,'2023-11-25', 80, 'notPaid','2023-12-25'),
(5, '2024-2-26', 55, 'notPaid','2024-3-26'),
( 6,'2023-11-27', 90, 'notPaid','2023-12-27'),
(7, '2023-10-28', 75, 'Paid','2023-11-28'),
( 7,'2023-11-28', 62, 'Paid','2023-12-28'),
( 9,'2023-12-30', 72, 'notPaid','2024-01-30'),
( 10,'2023-11-30', 58, 'Paid','2023-12-30');
GO
exec insertion
GO

GO
create procedure  DropAllTables
AS
DROP TABLE Student_Instructor_Course_Take;
DROP TABLE GradPlan_Course;
DROP TABLE Request;
DROP TABLE Exam_Student;
DROP TABLE Installment;
DROP TABLE Payment;
DROP TABLE Makeup_Exam;
Drop Table Student_Phone;
Drop Table Graduation_Plan;
Drop Table PreqCourse_course;
Drop Table Instructor_Course;
Drop Table Course_Semester;
Drop Table Slot;
Drop Table Student;
Drop Table Advisor;
Drop Table Course;
Drop Table Instructor;
Drop Table Semester;
GO
EXEC  DropAllTables 

GO
create procedure clearAllTables
AS
truncate TABLE Student_Instructor_Course_Take;
truncate TABLE GradPlan_Course;
truncate TABLE Request;
truncate TABLE Exam_Student;
truncate TABLE Installment;
truncate Table Student_Phone;
truncate Table PreqCourse_course;
truncate Table Instructor_Course;
truncate Table Course_Semester;
truncate Table Slot;


alter table Payment
drop constraint fk_payment1 
alter table Exam_Student
drop constraint fk_Exam_Student1
alter table Request
drop constraint  fk_request3
alter table Graduation_Plan
drop constraint fk_Graduation_Plan2 
alter table Student_Instructor_Course_Take
drop constraint fk_Student_Instructor_Course_Take3
alter table Student_Phone
drop constraint fk_student_Phone
alter table Request
drop constraint fk_request2
alter table Graduation_Plan
drop constraint fk_Graduation_Plan1
alter table Student
drop constraint fk_student 
alter table MakeUp_Exam
drop constraint fk_MakeUp_Exam
alter table Request
drop constraint fk_request1 
alter table Slot
drop Constraint fk_slot1 
alter table Course_Semester 
drop Constraint fk_Course_Semester1 
alter table Student_Instructor_Course_Take
drop constraint fk_Student_Instructor_Course_Take1
alter table Instructor_Course
drop constraint fk_Instructor_CourseForeign1 
alter table PreqCourse_course
drop constraint fk_PreqCourse_course1
alter table PreqCourse_course
drop Constraint fk_PreqCourse_course2 
alter table Slot
drop Constraint fk_slot2 
alter table Student_Instructor_Course_Take
drop constraint fk_Student_Instructor_Course_Take2 
alter table Instructor_Course
drop constraint fk_Instructor_CourseForeign2 
alter table Payment
drop constraint fk_payment2 
alter table Course_Semester
drop Constraint fk_Course_Semester2 
alter table Payment
add constraint fk_payment2 Foreign Key (semester_code) references Semester(semester_code) on update cascade on delete set null
alter table Course_Semester
add Constraint fk_Course_Semester2 Foreign Key (semester_code) references Semester(semester_code) on update cascade on delete cascade
alter table Exam_Student
drop constraint fk_Exam_Student2 
alter table Installment
drop constraint fk_installment
alter table GradPlan_Course
drop constraint fk_GradPlan_Course1
truncate Table Graduation_Plan
  truncate TABLE Payment
  truncate TABLE Makeup_Exam
  truncate Table Instructor
   truncate Table Course
  truncate Table Advisor
  truncate Table Student
  
alter table GradPlan_Course
add constraint fk_GradPlan_Course1 Foreign Key (semester_code,plan_id) references Graduation_Plan(semester_code, plan_id) on update cascade on delete cascade
alter table payment
add constraint fk_payment1 Foreign key (student_id) references Student(student_id) on update cascade on delete set null
alter table Exam_Student
add constraint fk_Exam_Student1 Foreign key (student_id) references Student(student_id) on update cascade on delete cascade
alter table Request
add constraint fk_request3 Foreign key (student_id) references Student(student_id)
alter table Graduation_Plan
add constraint fk_Graduation_Plan2 Foreign key (student_id) references Student(student_id) 
alter table Student_Instructor_Course_Take
add constraint fk_Student_Instructor_Course_Take3 Foreign key (student_id) references Student(student_id) on update cascade on delete cascade
alter table Student_Phone
add constraint fk_student_Phone Foreign key (student_id) references Student(student_id) on update cascade on delete cascade
alter table Request
add constraint fk_request2 Foreign Key (advisor_id) references Advisor(advisor_id) on update cascade on delete set null
alter table Graduation_Plan
add constraint fk_Graduation_Plan1 Foreign Key (advisor_id) references Advisor(advisor_id) on update cascade on delete set null
alter table student
add constraint fk_student Foreign key (advisor_id) references Advisor(advisor_id) on update cascade on delete set null
alter table MakeUp_Exam
add constraint fk_MakeUp_Exam Foreign Key (course_id) references Course(course_id) on update cascade on delete set null
alter table Request
add constraint fk_request1 Foreign Key (course_id) references Course(course_id) on update cascade on delete set null
alter table Slot
add Constraint fk_slot1 Foreign Key (course_id) references Course(course_id) on update cascade on delete set null
alter table Course_Semester
add Constraint fk_Course_Semester1 Foreign Key (course_id) references Course(course_id) on update cascade on delete cascade
alter table Student_Instructor_Course_Take
add constraint fk_Student_Instructor_Course_Take1 Foreign key (course_id) references Course(course_id) on update cascade on delete cascade
alter table Instructor_Course
add constraint fk_Instructor_CourseForeign1 foreign key (course_id) references Course(course_id) on update cascade on delete cascade
alter table PreqCourse_course
add Constraint fk_PreqCourse_course1 Foreign key (prerequisite_course_id) references Course (course_id) on delete cascade on update cascade
alter table PreqCourse_course
add Constraint fk_PreqCourse_course2 Foreign key (course_id) references Course (course_id) 
alter table slot 
add Constraint fk_slot2 Foreign key (instructor_id) references Instructor(instructor_id) on update cascade on delete set null
alter table Student_Instructor_Course_Take
add constraint fk_Student_Instructor_Course_Take2 Foreign key  (instructor_id) references Instructor(instructor_id) on update cascade on delete cascade
alter table Instructor_Course
add constraint fk_Instructor_CourseForeign2 Foreign key (instructor_id) references Instructor(instructor_id) on update cascade on delete cascade
alter table Exam_Student
add constraint fk_Exam_Student2 Foreign Key (exam_id) references  MakeUp_Exam (exam_id) on update cascade on delete cascade
 

alter table Installment
add constraint fk_installment Foreign key (payment_id) references Payment(payment_id) on update cascade on delete cascade
GO
EXEC clearAllTables
GO
create view view_Students 
AS 
select *
from Student S
where S.financial_status = 1
GO
select *
from view_Students
GO
create view view_Course_prerequisites
AS
select C1.name as 'Prerequisite Course Name', C1.course_id as 'Prerequisite Course ID', C2.name as 'Course Name', C2.course_id as 'Course ID'
from course C1 right outer join PreqCourse_course PC on C1.course_id = PC.prerequisite_course_id left outer join course C2 on PC.course_id = C2.course_id 
GO 
create view Instructors_AssignedCourses
AS
select I.name as 'Instructor Name',I.instructor_id as 'Instructor ID', C.name as 'Course Name', C.course_id as 'Course ID'
from Instructor_Course IC inner join Instructor I on IC.instructor_id = I.instructor_id inner join course C on IC.course_id = C.course_id
GO
Select *
from Instructors_AssignedCourses
GO

create view  Student_Payment
AS 
Select payment_id as 'Payment ID', amount as 'Payment Amount',n_installments as 'Number of installments', s.student_id as 'Student Id', s.f_name + ' '+  s.l_name as 'Studnet Name'
from payment p inner join student s on s.student_id = p.student_id
GO
Select *
from Student_Payment
GO

Create View Courses_Slots_Instructor 
AS
Select C.course_id as 'Course ID' , C.name as 'Course Name' , S.slot_id as 'Slot ID', S.day as 'Slot day' , S.time as' Slot Time', S.location as 'Slot Location', I.name as 'Instructor Name' 
From Instructor_Course IC , Slot S, Course C, Instructor I 
Where IC.course_id= S.course_id and IC .instructor_id = S.instructor_id and I.instructor_id= IC.instructor_id and C.course_id= IC.course_id
Go
Select *
from Courses_Slots_Instructor
GO

create view Courses_MakeUpExam 
AS 
select c.name as 'Course’s Name',c.course_id as 'Course ID', c.semester as 'Course’s Semester', s.semester_code as 'Semester Code', m.exam_id as 'Exam ID', date as 'Exam Date', type as 'Exam Type'
from Course_Semester cs inner join course c on cs.course_id = c.course_id inner join semester s on s.semester_code = cs.semester_code inner join MakeUp_Exam m on m.course_id = cs.course_id
GO 
Select *
from Courses_MakeUpExam 
GO

Create View Students_Courses_Transcript
AS
Select s.student_id as 'Student ID' , s.f_name +' '+ s.l_name as 'Student Name' , c.course_id as 'Course ID' , c.name as 'Course Name' , sict.exam_type as 'Exam Type' , sict.grade as 'Course Grade' , sict.semester_code as 'Semester' , i.name as 'Instructor Name'
From Student_Instructor_Course_Take sict inner join student s on s.student_id = sict.student_id inner join instructor i on i.instructor_id = sict.instructor_id inner join course c on sict.course_id = c.course_id
GO
Select *
from  Students_Courses_Transcript
GO

Create View Semster_offered_Courses 
AS
Select CS.course_id as 'Course ID', C.name as 'Course Name' , CS.semester_code as 'Semester Code'
From Course_Semester CS inner join Course C on C.course_id= CS.course_id
GO
Select *
from Semster_offered_Courses
GO

Create View Advisors_Graaduation_Plan 
AS
Select GP.plan_id as 'Plan ID' , GP.semester_code as 'Semester Code' ,  GP.expected_grad_date as 'Expected Graduation Date' ,GP.semester_credit_hours as 'Semester Credit Hours' , GP.student_id as 'Student ID', GP.advisor_id as 'Advisor ID' , A.name as 'Advisor Name'
From Advisor A inner join Graduation_Plan GP on GP.advisor_id= A.advisor_id
GO
Select *
from Advisors_Graaduation_Plan 
GO

create Procedure Procedures_StudentRegistration

@f_name varchar(40),
@L_name varchar(40),
@password varchar(40),
@faculty varchar(40),
@email varchar(40),
@major varchar(40),
@semester int,
@sid int output
AS
Begin 

Insert Into Student (f_name,l_name,faculty,email,major,password,semester)
values (@f_name, @L_name,@faculty, @email, @major, @password,  @semester)

Select @sid =  S.student_id
From Student S
Where S.f_name = @f_name and S.l_name = @L_name and @email = s.email and major = @major and semester = @semester;
End 
GO 
declare 
@res int
EXEC Procedures_StudentRegistration 'salma', 'nabil','BI','salma.nabil@example.com','BI','password1299',1 , @res output
print @res
GO


create Procedure Procedures_AdvisorRegistration 

@Advisor_name  varchar(40),
@password varchar(40),
@email varchar(40),
@office  varchar(40),
@sid int output

AS 
Begin 
Insert into Advisor (name , password,email, office)
values (@Advisor_name , @password, @email, @office )

Select @sid = advisor_id
From Advisor 
Where name = @Advisor_name and @password = password and @email = email and @office = office

end 
GO
declare 
@res int
EXEC Procedures_AdvisorRegistration  'Hala Yousry','password1299','hala.yousry@example.com','B5.301' , @res output
print @res
GO

create procedure Procedures_AdminListStudent 
AS
Select S.*
From Student S
GO
exec Procedures_AdminListStudent
GO

create procedure Procedures_AdminListAdvisor
AS
Select A.*
From Advisor A
GO
exec Procedures_AdminListAdvisor
GO

create procedure Procedures_AdminListStudentsWithAdvisor
AS
Select S.* , A.* 
From Advisor A inner join Student S on S.advisor_id= A.advisor_id
GO
exec Procedures_AdminListStudentsWithAdvisor
GO


Create procedure AdminAddingSemester

@start_date datetime,
@end_date  datetime,
@semester_code varchar(40)
as
Begin 
Insert Into Semester (start_date, end_date, semester_code)
values (@start_date, @end_date, @semester_code);

End 
GO 
exec AdminAddingSemester '2019/2/4', '2019/5/1','W023' 
GO

create procedure Procedures_AdminAddingCourse
@major varchar(40),
@semester  int,
@credit_hours int,
@course_name  varchar(40),
@offered bit
AS
Begin 

Insert Into Course (major, semester,credit_hours, name, is_offered)
Values (@major,@semester, @credit_hours, @course_name, @offered)

End 
GO

Exec Procedures_AdminAddingCourse '23',2,3,'e',0
GO

create procedure Procedures_AdminLinkInstructor
@InstructorId int,
@courseId int,
@slotID int
AS
insert into Instructor_Course
values(@courseId,@InstructorId)

update slot
set instructor_id = @InstructorId
where slot_id = @slotID
update slot
set course_id = @courseId
where slot_id = @slotID
GO
exec Procedures_AdminLinkInstructor 1,2,1
GO

Create Procedure Procedures_AdminLinkStudent

@Instructor_id int,
@student_id int,
@course_id int,
@Semester_code varchar(40)
AS
Begin

Insert into Student_Instructor_Course_Take (instructor_id, student_id, course_id,semester_code)
Values (@Instructor_id,@student_id, @course_id,@Semester_code)

End 
GO
exec Procedures_AdminLinkStudent 1,3,4,'s20'
GO

create procedure Procedures_AdminLinkStudentToAdvisor
@studentID int, 
@advisorID int 
AS
update student
set advisor_id = @advisorID
where student_id = @studentID
GO
exec Procedures_AdminLinkStudentToAdvisor 2,5
GO

Create Procedure Procedures_AdminAddExam

@Type varchar(40),
@date datetime,
@course_ID int 
AS
Begin 
Insert into MakeUp_Exam (type, date, course_id)
Values (@Type,@date, @course_id)
End 
GO
exec Procedures_AdminAddExam 'first_makeup','2023/4/3', 4
GO

create procedure Procedures_AdminIssueInstallment
@id int
AS 
DECLARE @i int 
DECLARE @constant int
DECLARE @res datetime
DECLARE @amount int
DECLARE @start datetime
Select @i = p.n_installments
from Payment p
where p.payment_id =@id

Select @res = p.start_date
from Payment p
where p.payment_id =@id

Select @amount = p.amount
from Payment p
where p.payment_id =@id

set @constant = @i
WHILE @i >0
	BEGIN
	if @i = @constant
	Begin
		insert into Installment
		values(@id, DATEADD(month, 1, @res),@amount/@constant,'NotPaid',@res)
		set @start = DATEADD(month, 1, @res)
	end
	else
	begin
	    insert into Installment
		values(@id, DATEADD(month, 1, @start) ,@amount/@constant,'NotPaid',@start)
		set @start = DATEADD(month, 1, @start)
	end
		SET @i = @i - 1
	END
GO
insert into payment(start_date,n_installments,amount)
values('2018/2/4',5,3000)
exec  Procedures_AdminIssueInstallment 11
GO

create Procedure Procedures_AdminDeleteCourse 
@course_ID int 
AS 
Begin
update slot
set instructor_id = null
where course_id = @course_ID

update slot
set course_id = null
where course_id = @course_ID

Delete from PreqCourse_course
where course_id = @course_ID or  prerequisite_course_id = @course_ID
End 

Delete From Course
Where course_id = @course_ID;
GO
exec Procedures_AdminDeleteCourse 1
GO
select *
from Slot
GO
create procedure Procedure_AdminUpdateStudentStatus
@StudentID int
AS
if exists(
select *
from payment p inner join Installment i on i.payment_id = p.payment_id
where p.student_id = @StudentID and i.status = 'notPaid' and i.deadline < CURRENT_TIMESTAMP
)
update Student
set financial_status = 0
where student_id = @StudentID
GO


create View all_Pending_Requests
AS
Select R.request_id as 'Request ID', R.type as 'Request Type', R.comment as 'Request Comment', R.course_id as 'Course ID', R.credit_hours as 'Course Credit Hours', R.student_id as 'Student ID', S.f_name +' '+ S.l_name as 'Student Name' , R.advisor_id as 'Advidor ID' , A.name as 'Advisor Name'
From  Request R inner join Student S on R.student_id = S.Student_id inner join Advisor A on R.advisor_id = A.advisor_id
Where R.status ='pending'
Go
select *
from all_Pending_Requests
GO

create Procedure Procedures_AdminDeleteSlots
@current_semster varchar(40)
AS
update slot
set instructor_id = null
where course_id in (
select course_id
from Course_Semester
where semester_code <> @current_semster)

update slot
set course_id = null
where course_id in (
select course_id
from Course_Semester
where semester_code <> @current_semster)
GO
exec Procedures_AdminDeleteSlots 'W23'
GO

create function FN_AdvisorLogin
(@ID int, @password varchar (40))
returns bit
 
AS
BEGIN
declare @success bit,
@pass varchar(40)
select @pass = password
from Advisor
where advisor_id = @id
if @pass = @password
begin 
set @success = 1
end
else
begin
set @success = 0
end
return @success
END
GO
print  dbo.FN_AdvisorLogin(1,'password1')
GO

create Procedure Procedures_AdvisorCreateGP
@Semester_code varchar(40),
@expected_graduation_date date,
@Sem_credit_hours int ,
@advisor_id int ,
@student_id int
AS
Begin 
declare 
@credit int,
@advid int

select @credit = acquired_hours, @advid =advisor_id
from Student
where @student_id = student_id
if @advid <> @Advisor_id
print 'This advisor is not authorized for this action!'
else
begin
if @credit >157 and @advid = @Advisor_id
begin
Insert Into Graduation_Plan ( semester_code, expected_grad_date,semester_credit_hours,advisor_id,student_id)
Values (@Semester_code,@expected_graduation_date,@Sem_credit_hours,@advisor_id,@student_id)
end
else
print'Sudent has not acquired enough credit hours to complete this action'
End 
END
GO
exec Procedures_AdvisorCreateGP 'w23', '2024/4/5', 19, 1,2
GO


create procedure Procedures_AdvisorAddCourseGP
@studentid int, 
@Semester_code varchar (40), 
@coursename varchar (40)
AS
declare 
@planid int,
@courseid int,
@c bit
Select @planid = plan_id
from Graduation_Plan
where student_id = @studentid and semester_code = @Semester_code

Select @courseid = course_id
from course 
where name = @coursename and course_id in(
Select course_id
from Course_Semester
where semester_code = @Semester_code
)
if @courseid is null
print 'This is course is not offered in the semester specified'
else
begin
insert into GradPlan_Course
values(@planid , @Semester_code, @courseid)
end
GO
exec Procedures_AdvisorAddCourseGP 1,'w23','csen 2'
GO

create procedure Procedures_AdvisorUpdateGP
@expected_grad_date date ,
@studentID int
AS

update Graduation_Plan
set expected_grad_date = @expected_grad_date
where student_id = @studentID
GO
exec Procedures_AdvisorUpdateGP '2028/4/2',2
GO

create procedure Procedures_AdvisorDeleteFromGP
@studentID int, 
@semestercode varchar (40) ,
@courseID int

AS
declare 
@planid int

Select @planid = plan_id
from Graduation_Plan
where student_id = @studentid and semester_code = @Semestercode
if @courseID in (
select course_id
from GradPlan_Course
where  plan_id = @planid and course_id = @courseID and semester_code = @semestercode
)
begin
delete from GradPlan_Course
where plan_id = @planid and course_id = @courseID and semester_code = @semestercode
end
else
print 'There is no such course in the Graduation Plan for this student!'
GO
exec Procedures_AdvisorDeleteFromGP 2, 's23',2
GO
create function FN_Advisors_Requests
(@advisorID int)
returns table

AS return (
Select r.request_id as 'Request ID',r.type as 'Request Type',r.comment as 'Comment',r.status as 'Request Status',r.credit_hours as 'Credit Hours',r.student_id as 'Student ID',s.f_name +' '+ s.l_name as 'Student Name',r.advisor_id as 'Advisor ID',r.course_id as 'Course ID'
from Request r inner join Student s on s.student_id = r.student_id
where r.advisor_id = @advisorID
)
GO
select *
from dbo.FN_Advisors_Requests(2)
GO

create procedure Procedures_AdvisorApproveRejectCHRequest
@RequestID int, @Currentsemestercode varchar (40)
AS
 declare 
 @studentid int,
 @assigned int,
 @credit int,
 @sum int,
 @check decimal,
 @type varchar(40),
 @status varchar(40)

 select @studentid = student_id , @credit = credit_hours, @type = type, @status = status
 from Request
 where request_id = @RequestID

 select @check = gpa
 from Student
 where @studentid = student_id
 
 Select @assigned = assigned_hours
 from Student
 where student_id = @studentid

 if @type = 'credit_hours' and @status = 'pending'
 begin
 if   (@credit <4 and @check <=3.7 and (@assigned is null or (@assigned is not null and @assigned + @credit<=34)) and exists(
 select course_id
 from Student_Instructor_Course_Take 
 where student_id = @studentid and grade in ('FF','F','FA') and course_id in(
 select course_id
 from Course_Semester
 where semester_code = @Currentsemestercode
 )
 ))
 begin
 

if @assigned is null
begin
update Student
set assigned_hours = @credit
where student_id = @studentid

update Request
set status = 'accepted'
where request_id =@RequestID and student_id = @studentid
end

else if @credit + @assigned <= 34 
begin
update Student
set assigned_hours =@assigned + @credit
where student_id = @studentid

update Request
set status = 'accepted'
where request_id =@RequestID and student_id = @studentid
end


end

else
begin
update Request
set status = 'rejected'
where request_id =@RequestID and student_id = @studentid
print 'Request Rejected!'
end

end 
else
print 'Wrong request type or status'
GO
exec Procedures_AdvisorApproveRejectCHRequest 6,'s23'
GO

create procedure Procedures_AdvisorViewAssignedStudents
@AdvisorID int,
@major varchar (40)
AS
select s.student_id as 'Student ID' , s.f_name +' '+ s.l_name as 'Student Name', s.major as 'Student Major', c.name as 'Courses Name'
from Student s inner join Student_Instructor_Course_Take sict on s.student_id = sict.student_id left outer join course c on c.course_id = sict.course_id
where s.advisor_id = @AdvisorID and s.major = @major
GO
exec Procedures_AdvisorViewAssignedStudents 1, 'cs'
GO

create procedure Procedures_AdvisorApproveRejectCourseRequest
@RequestID int, 
@current_semester_code varchar(40)
AS
declare 
@course int,
@student int,
@major varchar(40),
@assigned int,
@credit int,
@type varchar(40),
@status varchar(40)
select @course = course_id, @student = student_id, @type = type, @status = status
from Request
where @RequestID = request_id

select @credit = credit_hours
from Course
where course_id = @course

select @assigned = assigned_hours, @major = major
from Student
where student_id = @student
if @type = 'course' and @status = 'pending'
begin


if (@assigned is not null and @assigned - @credit >=0) and @course in(
select c1.course_id
from course c1 left outer join PreqCourse_course pc on pc.course_id = c1.course_id 
where c1.major = @major and pc.prerequisite_course_id in (
select course_id
from Student_Instructor_Course_Take
where student_id = @Student and grade not in ('FF', 'F', 'FA', null)
)) and exists(
select *
from Course_Semester
where course_id = @course and @current_semester_code = semester_code
)
begin
 if @assigned - @credit >=0
begin
update Student
set assigned_hours = @assigned - @credit
where student_id = @student

update Request
set status = 'accepted'
where request_id =@RequestID and student_id = @student

insert into Student_Instructor_Course_Take (student_id , course_id, instructor_id  ,semester_code)
values(@student, @course, null, @current_semester_code)
end

declare 
@pid int,
@deadline datetime

select @pid =p.payment_id, @deadline = i.deadline
from Payment p inner join Installment i on p.payment_id = i.payment_id
where student_id = @student and @current_semester_code = semester_code and i.start_date > CURRENT_TIMESTAMP and i.start_date = (
select min(i.start_date)
from Installment i inner join Payment p on  p.payment_id = i.payment_id
where student_id = @student and @current_semester_code = semester_code and i.start_date > CURRENT_TIMESTAMP
) 

update Payment
set amount = amount+ 1000
where payment_id = @pid

update Installment
set amount = amount + 1000
where deadline = @deadline and payment_id = @pid

END
else 
begin
update Request
set status = 'rejected'
where request_id =@RequestID and student_id = @student
end
END
else
print'There are no pending requests for this type of request'
GO
exec Procedures_AdvisorApproveRejectCourseRequest 10, 's23'
GO

create procedure Procedures_AdvisorViewPendingRequests
@AdvisorID int

AS

select *
from Request
where advisor_id = @AdvisorID and status = 'pending' and student_id in(
select Student_id
from student 
where advisor_id = @AdvisorID
)
GO
exec Procedures_AdvisorViewPendingRequests 3
GO

create function FN_StudentLogin
(@StudentID int, @password varchar (40))
returns bit
AS
begin
declare 
@success bit,
@pass varchar(40)
select @pass = password
from Student
where student_id = @StudentID
if @pass = @password
begin 
set @success = 1
end
else
begin
set @success = 0
end
return @success
END
GO
print dbo.FN_StudentLogin (1,'password123')
GO

create procedure Procedures_StudentaddMobile
@StudentID int, 
@mobile_number varchar (40)
AS
insert into Student_Phone
values(@StudentID, @mobile_number)
GO
exec Procedures_StudentaddMobile 1, '2010229029098'
GO

create function FN_SemsterAvailableCourses
(@semster_code varchar (40))
returns table
AS return(
select c.course_id as 'Course ID', c.name as 'Course Name'
from Course_Semester sc inner join course c on c.course_id = sc.course_id
where sc.semester_code = @semster_code
)
GO
Select *
from FN_SemsterAvailableCourses ('w23')
GO

create procedure Procedures_StudentSendingCourseRequest
@StudentID int, 
@courseID int, 
@type varchar (40), 
@comment varchar (40)
AS

declare 
@advid int

Select @advid = advisor_id
from Student
where student_id = @StudentID


insert into Request (type, comment,student_id, advisor_id, course_id)
values(@type, @comment,@StudentID, @advid,@courseID)
GO
exec Procedures_StudentSendingCourseRequest 1,4,'course','please'
GO

create procedure Procedures_StudentSendingCHRequest
@StudentID int, 
@credithours int, 
@type varchar (40),  
@comment varchar (40)
AS

declare 
@advid int

Select @advid = advisor_id
from Student
where student_id = @StudentID

insert into Request (type, comment,credit_hours,student_id, advisor_id)
values(@type, @comment,@credithours,@StudentID, @advid)
GO
exec Procedures_StudentSendingCHRequest 1,4,'credit_hours','please'
GO

create function FN_StudentViewGP
(@student_ID int)
returns table
AS return(
Select s.student_id as 'Student id', s.f_name+' '+s.l_name as 'Student name', gp.plan_id as 'Graduation plan id', c.course_id as 'Course id', 
c.name as 'Course name', gp.semester_code as 'Semester code', gp.expected_grad_date as 'Expected graduation date', 
gp.semester_credit_hours as 'Semester credit hours', gp.advisor_id as 'Advisor id'
from GradPlan_Course gc inner join Graduation_Plan gp on gc.plan_id = gp.plan_id inner join Course c on c.course_id = gc.course_id inner join Student s on s.student_id=gp.student_id
where @student_ID = gp.student_id
)
GO
select *
from dbo.FN_StudentViewGP(1)
GO

create function FN_StudentUpcoming_installment
(@StudentID int)
returns date
AS
BEGIN
declare
@res date
select @res = min(i.deadline)
from Payment p inner join Installment i on p.payment_id = i.payment_id
where student_id = @StudentID and i.status = 'notpaid'

return @res
END
GO
print dbo.FN_StudentUpcoming_installment(1)
GO

create function FN_StudentViewSlot
(@CourseID int, @InstructorID int)
returns table
AS return(
select s.slot_id as 'Slot ID', s.location as 'Slot Location', s.time as 'Slot Time', s.day as 'Slot Day', c.name as 'Course Name', i.name as 'Instructor Name'
from slot s inner join Instructor i on i.instructor_id =s.instructor_id inner join Course c on c.course_id = s.course_id
where c.course_id = @CourseID and i.instructor_id = @InstructorID
)
GO
select *
from dbo.FN_StudentViewSlot (4,4)
GO

create procedure Procedures_StudentRegisterFirstMakeup
@StudentID int, 
@courseID int, 
@studentCurrentsemester varchar (40)
AS
declare 
@date date,
@examid int,
@min int
if exists(
select *
from Student_Instructor_Course_Take
where course_id = @courseID and student_id = @StudentID and (grade ='FF' or grade = 'F' or grade is null) and exam_type = 'normal'
) and not exists(
select *
from Student_Instructor_Course_Take
where student_id =@StudentID and course_id = @courseID and exam_type like '%makeup%'
)
begin
select @date = start_date
from semester 
where semester_code = @studentCurrentsemester

select @min = min(x)
from(
select DATEDIFF(day,@date, date) as x
from MakeUp_Exam
where type = 'First_makeup' and course_id =@courseID and date> @date
) AS subquery


select @examid = exam_id
from MakeUp_Exam
where date = @min and course_id = @courseID
if @examid is not null
begin
insert into Exam_Student
values(@examid, @StudentID, @courseID)
end
else
print 'No exams currently found to register for'
End
GO
exec Procedures_StudentRegisterFirstMakeup 9,9,'w23'
GO

create function FN_StudentCheckSMEligiability
(@CourseID int,  @StudentID int)
returns bit
AS
Begin
declare
@res bit,
@i int
set @i = 2
if (exists(
select *
from MakeUp_Exam me inner join Exam_Student es on me.exam_id = es.exam_id 
inner join Student_Instructor_Course_Take sict on sict.student_id = es.student_id and sict.course_id = es.course_id
where es.course_id = @CourseID and es.student_id = @StudentID and me.type ='First_makeup' and sict.grade in ('FF', 'F')
) or not exists(
select *
from MakeUp_Exam me inner join Exam_Student es on me.exam_id = es.exam_id 
inner join Student_Instructor_Course_Take sict on sict.course_id = me.course_id and sict.student_id = es.student_id
where me.course_id = @CourseID and es.student_id = @StudentID and me.type = 'First_makeup'

)) 
and @i >=(
select count(*)
from Student_Instructor_Course_Take sict 
where grade in ('FF', 'F') )

set @res = 1
else
set @res = 0

return @res
end
GO
print dbo.FN_StudentCheckSMEligiability(5,7)
GO

create procedure Procedures_StudentRegisterSecondMakeup
@StudentID int, 
@courseID int, 
@StudentCurrentSemester Varchar(40)
AS
declare 
@res bit
set @res = dbo.FN_StudentCheckSMEligiability(@courseID, @StudentID)
if (@res =1)
begin
declare 
@date date,
@examid int,
@min int

select @date = start_date
from semester 
where semester_code = @studentCurrentsemester

select @min = min(x)
from(
select DATEDIFF(day,@date, date) as x
from MakeUp_Exam
where type = 'Second_makeup' and course_id =@courseID and date> @date
) AS subquery


select @examid = exam_id
from MakeUp_Exam
where date = @min and course_id = @courseID
if (@examid is not null)
begin
insert into Exam_Student
values(@examid, @StudentID, @courseID)
end
else
print 'There is currently no exams to register for'
End
else 
print'YOU CAN NOT REGISTER FOR A SECOND MAKEUP AS YOU ARE NOT ELIGIBLE'
GO
exec Procedures_StudentRegisterSecondMakeup 1,4,'s23'
GO

create procedure Procedures_ViewRequiredCourses
@StudentID int, 
@Currentsemestercode Varchar (40)
AS
declare 

@sem int
select @sem = semester
from Student
where student_id = @StudentID


select c.course_id as 'Course ID', c.name as 'Course Name', c.credit_hours as 'Credit Hours'
from Student_Instructor_Course_Take sict inner join course c on c.course_id = sict.course_id 
where student_id = @StudentID and grade in ('F','FF') and dbo.FN_StudentCheckSMEligiability(c.course_id, @StudentID) =0

union

select c.course_id as 'Course ID', c.name as 'Course Name', c.credit_hours as 'Credit Hours'
from Course_Semester cs inner join course c on c.course_id = cs.course_id inner join Semester s on s.semester_code = cs.semester_code 
inner join Student_Instructor_Course_Take sict on sict.course_id = c.course_id and sict.student_id = @StudentID
where (sict.grade ='FA'or c.course_id not in (
select course_id
from Student_Instructor_Course_Take
where student_id =@StudentID 
)) and c.semester <@sem and c.course_id in(
select course_id
from Course_Semester 
where semester_code = @Currentsemestercode
)
GO
exec Procedures_ViewRequiredCourses 9,'s24r2'
GO

create procedure Procedures_ViewOptionalCourse
@StudentID int, 
@Currentsemestercode Varchar (40)
AS
declare 
@date date,
@major varchar(40),
@sem int

select @sem = semester
from Student
where student_id = @StudentID


select @major = major
from Student
where student_id = @StudentID

select c.course_id as 'Course ID', c.name as 'Course Name', c.credit_hours as 'Credit Hours'
from Course_Semester cs inner join course c on c.course_id = cs.course_id inner join Semester s on s.semester_code = cs.semester_code
where c.semester > = @sem

intersect 

select c1.course_id as 'Course ID', c1.name as 'Course Name', c1.credit_hours as 'Credit Hours'
from course c1 left outer join PreqCourse_course pc on pc.course_id = c1.course_id 
where c1.major = @major and  pc.prerequisite_course_id  in (
select course_id
from Student_Instructor_Course_Take
where student_id = @StudentID and grade not in ('FF', 'F', 'FA',null)
) and c1.semester > =@sem and c1.course_id in(
select course_id
from Course_Semester 
where semester_code = @Currentsemestercode
)
GO
exec Procedures_ViewOptionalCourse 9,'s24r2'
GO

create procedure Procedures_ChooseInstructor
@StudentID int, 
@InstructorID int, 
@CourseID int,
@current_semester_code varchar(40)
AS

if exists(
select *
from Instructor_Course i
where i.course_id = @CourseID and i.instructor_id = @InstructorID
) and exists(
select *
from Course_Semester
where course_id = @CourseID and @current_semester_code = semester_code
)
begin
if(exists(
select *
from Student_Instructor_Course_Take
where course_id = @CourseID and semester_code = @current_semester_code and student_id = @StudentID and instructor_id is null
))
begin
update Student_Instructor_Course_Take
set instructor_id = @InstructorID
where course_id = @CourseID and semester_code = @current_semester_code and student_id = @StudentID and instructor_id is null

end
else
begin
insert into Student_Instructor_Course_Take (student_id, course_id , instructor_id, semester_code)
values(@StudentID,@CourseID, @InstructorID, @current_semester_code)
end

end
else
print 'Instructor does not teach this course or this course is not being offered in the current semester'
GO
exec Procedures_ChooseInstructor 1,5,5,'w23'
GO

create procedure Procedures_ViewMS
@StudentID int
AS
declare 
@major varchar(40)

select @major = major
from student
where student_id = @StudentID

select course_id as 'Course ID' , name as 'Course Name'
from Course
where major = @major

except

select sict.course_id as 'Course ID' , c.name as 'Course Name'
from Student_Instructor_Course_Take sict inner join course c on c.course_id = sict.course_id
where sict.grade not in ('F', 'FF', 'FA', null)
GO
exec Procedures_ViewMS 6

