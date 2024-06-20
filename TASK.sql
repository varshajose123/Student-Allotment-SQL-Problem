mysql> USE LEVELC1;
Database changed
mysql> CREATE TABLE StudentDetails (
    ->     StudentId INT PRIMARY KEY,
    ->     StudentName VARCHAR(100),
    ->     GPA DECIMAL(4, 2),
    ->     Branch VARCHAR(50),
    ->     Section CHAR(1)
    -> );
Query OK, 0 rows affected (0.04 sec)

mysql> CREATE TABLE SubjectDetails (
    ->     SubjectId VARCHAR(10) PRIMARY KEY,
    ->     SubjectName VARCHAR(100),
    ->     MaxSeats INT,
    ->     RemainingSeats INT
    -> );
Query OK, 0 rows affected (0.04 sec)

mysql> CREATE TABLE StudentPreference (
    ->     StudentId INT,
    ->     SubjectId VARCHAR(10),
    ->     Preference INT,
    ->     PRIMARY KEY (StudentId, Preference),
    ->     FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId),
    ->     FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId)
    -> );
Query OK, 0 rows affected (0.06 sec)

mysql> CREATE TABLE Allotments (
    ->     SubjectId VARCHAR(10),
    ->     StudentId INT,
    ->     PRIMARY KEY (SubjectId),
    ->     FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId),
    ->     FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
    -> );
Query OK, 0 rows affected (0.10 sec)

mysql> CREATE TABLE UnallotedStudents (
    ->     StudentId INT PRIMARY KEY,
    ->     FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
    -> );
Query OK, 0 rows affected (0.04 sec)

mysql> DELIMITER //
mysql>
mysql> CREATE PROCEDURE AllocateElectiveSubjects()
    -> BEGIN
    ->     DECLARE done INT DEFAULT FALSE;
    ->     DECLARE student_id_var INT;
    ->     DECLARE subject_id_var VARCHAR(10);
    ->     DECLARE preference_var INT;
    ->     DECLARE remaining_seats INT;
    ->     DECLARE gpa DECIMAL(4, 2);
    ->     DECLARE is_allotted BOOLEAN DEFAULT FALSE;
    ->
    ->     DECLARE cur_student CURSOR FOR
    ->         SELECT sp.StudentId, sp.SubjectId, sp.Preference
    ->         FROM StudentPreference sp
    ->         ORDER BY sp.StudentId, sp.Preference;
    ->
    ->     DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    ->
    ->     OPEN cur_student;
    ->
    ->     allocation_loop: LOOP
    ->         FETCH cur_student INTO student_id_var, subject_id_var, preference_var;
    ->         IF done THEN
    ->             LEAVE allocation_loop;
    ->         END IF;
    ->
    ->         -- Fetch GPA of the student
    ->         SELECT GPA INTO gpa
    ->         FROM StudentDetails
    ->         WHERE StudentId = student_id_var;
    ->
    ->         -- Process each preference
    ->         IF NOT is_allotted THEN
    ->             -- Check if the combination already exists
    ->             IF NOT EXISTS (
    ->                 SELECT 1
    ->                 FROM StudentPreference
    ->                 WHERE StudentId = student_id_var AND Preference = preference_var
    ->             ) THEN
    ->                 -- Preference 1
    ->                 IF preference_var = 1 THEN
    ->                     SELECT RemainingSeats INTO remaining_seats
    ->                     FROM SubjectDetails
    ->                     WHERE SubjectId = subject_id_var;
    ->
    ->                     IF remaining_seats > 0 THEN
    ->                         INSERT INTO Allotments (SubjectId, StudentId)
    ->                         VALUES (subject_id_var, student_id_var);
    ->                         UPDATE SubjectDetails
    ->                         SET RemainingSeats = RemainingSeats - 1
    ->                         WHERE SubjectId = subject_id_var;
    ->                         SET is_allotted = TRUE;
    ->                     END IF;
    ->                 END IF;
    ->             END IF;
    ->         END IF;
    ->
    ->         -- Handle unallotted students
    ->         IF NOT is_allotted THEN
    ->             INSERT INTO UnallotedStudents (StudentId)
    ->             VALUES (student_id_var);
    ->         END IF;
    ->
    ->         -- Reset flag for next iteration
    ->         SET is_allotted = FALSE;
    ->     END LOOP;
    ->
    ->     CLOSE cur_student;
    -> END //
Query OK, 0 rows affected (0.01 sec)

mysql>
mysql> DELIMITER ;
mysql> CALL AllocateElectiveSubjects();
Query OK, 0 rows affected (0.00 sec)

mysql>




























































