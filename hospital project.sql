create database hospital;
use hospital;
-- 1. Table: Departments
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY AUTO_INCREMENT,
    DepartmentName VARCHAR(100) NOT NULL
);

-- 2. Table: Doctors
CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY AUTO_INCREMENT,
    DoctorName VARCHAR(100) NOT NULL,
    Specialty VARCHAR(100),
    DepartmentID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- 3. Table: Patients
CREATE TABLE Patients (
    PatientID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    DateOfBirth DATE,
    Gender VARCHAR(10),
    Address VARCHAR(255),
    PhoneNumber VARCHAR(15)
);

-- 4. Table: Appointments
CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT,
    DoctorID INT,
    AppointmentDate DATETIME,
    Reason VARCHAR(255),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

-- 5. Table: Medications
CREATE TABLE Medications (
    MedicationID INT PRIMARY KEY AUTO_INCREMENT,
    MedicationName VARCHAR(100),
    Dosage VARCHAR(50)
);

-- 6. Table: Prescriptions
CREATE TABLE Prescriptions (
    PrescriptionID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT,
    DoctorID INT,
    MedicationID INT,
    PrescriptionDate DATE,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    FOREIGN KEY (MedicationID) REFERENCES Medications(MedicationID)
);

-- 7. Table: Billing
CREATE TABLE Billing (
    BillID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT,
    AppointmentID INT,
    Amount DECIMAL(10, 2),
    PaymentStatus VARCHAR(50),
    BillingDate DATE,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID)
);

-- Sample Data Generation (Using INSERT statements)
-- Departments
INSERT INTO Departments (DepartmentName) VALUES
('Cardiology'),
('Neurology'),
('Pediatrics'),
('Orthopedics'),
('Oncology');

-- Doctors
INSERT INTO Doctors (DoctorName, Specialty, DepartmentID) VALUES
('Dr. John Smith', 'Cardiologist', 1),
('Dr. Alice Brown', 'Neurologist', 2),
('Dr. Emily White', 'Pediatrician', 3),
('Dr. Robert Johnson', 'Orthopedic Surgeon', 4),
('Dr. Michael Green', 'Oncologist', 5);

-- Patients
INSERT INTO Patients (FirstName, LastName, DateOfBirth, Gender, Address, PhoneNumber) VALUES
('John', 'Doe', '1985-05-15', 'Male', '123 Elm Street', '555-123-4567'),
('Jane', 'Smith', '1990-07-22', 'Female', '456 Oak Avenue', '555-987-6543');

-- Generate more Patients
DELIMITER $$
CREATE PROCEDURE GeneratePatients()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 1000 DO
        INSERT INTO Patients (FirstName, LastName, DateOfBirth, Gender, Address, PhoneNumber)
        VALUES (
            CONCAT('Patient', i), 
            CONCAT('LastName', i), 
            DATE_ADD('1970-01-01', INTERVAL FLOOR(RAND() * 18250) DAY),
            IF(MOD(i, 2) = 0, 'Male', 'Female'),
            CONCAT(FLOOR(RAND() * 999), ' Random Street'),
            CONCAT('555-', FLOOR(1000000 + RAND() * 9000000))
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;
CALL GeneratePatients();

-- Generate Appointments
DELIMITER $$
CREATE PROCEDURE GenerateAppointments()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 1000 DO
        INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Reason)
        VALUES (
            FLOOR(1 + RAND() * 1000), 
            FLOOR(1 + RAND() * 5), 
            DATE_ADD(NOW(), INTERVAL FLOOR(RAND() * 365) DAY),
            CONCAT('Reason ', i)
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;
CALL GenerateAppointments();

-- Generate Prescriptions
DELIMITER $$
CREATE PROCEDURE GeneratePrescriptions()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 1000 DO
        INSERT INTO Prescriptions (PatientID, DoctorID, MedicationID, PrescriptionDate)
        VALUES (
            FLOOR(1 + RAND() * 1000), 
            FLOOR(1 + RAND() * 5), 
            FLOOR(1 + RAND() * 10), 
            DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 1825) DAY)
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;
CALL GeneratePrescriptions();

-- Generate Medications
INSERT INTO Medications (MedicationName, Dosage) VALUES
('Medication A', '10mg'),
('Medication B', '20mg'),
('Medication C', '5mg'),
('Medication D', '15mg'),
('Medication E', '25mg');

-- Generate Billing
DELIMITER $$
CREATE PROCEDURE GenerateBilling()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 1000 DO
        INSERT INTO Billing (PatientID, AppointmentID, Amount, PaymentStatus, BillingDate)
        VALUES (
            FLOOR(1 + RAND() * 1000), 
            FLOOR(1 + RAND() * 1000), 
            ROUND(50 + RAND() * 500, 2), 
            IF(MOD(i, 2) = 0, 'Paid', 'Pending'),
            DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 1825) DAY)
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;
CALL GenerateBilling();




-- We can analyze the distribution of patients by gender and age group. This helps in understanding the patient demographics and can be used to tailor healthcare services.
-- -----------------------------------------------------------1. Demographic Distribution of Patients-------------------------------------------------

-- Gender Distribution of Patients
 SELECT Gender, COUNT(*) AS PatientCount
FROM Patients
GROUP BY Gender;

-- Age Group Distribution
-- We can categorize patients into different age groups to assess the distribution of patients by age.
SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, DateOfBirth, CURDATE()) < 18 THEN 'Under 18'
        WHEN TIMESTAMPDIFF(YEAR, DateOfBirth, CURDATE()) BETWEEN 18 AND 40 THEN '18-40'
        WHEN TIMESTAMPDIFF(YEAR, DateOfBirth, CURDATE()) BETWEEN 41 AND 60 THEN '41-60'
        ELSE '60+' 
    END AS AgeGroup, 
    COUNT(*) AS PatientCount
FROM Patients
GROUP BY AgeGroup;


-- --------------------------------------------- 2. Doctor Appointment Insights-------------------------------------------------------------
-- We can analyze appointment trends to identify the most popular doctors and the departments with the highest demand.

-- Most Popular Doctors (By Number of Appointments)

SELECT d.DoctorName, COUNT(a.AppointmentID) AS AppointmentCount
FROM Appointments a
JOIN Doctors d ON a.DoctorID = d.DoctorID
GROUP BY d.DoctorName
ORDER BY AppointmentCount DESC;


-- Most Active Departments (By Number of Appointments)
SELECT dept.DepartmentName, COUNT(a.AppointmentID) AS AppointmentCount
FROM Appointments a
JOIN Doctors d ON a.DoctorID = d.DoctorID
JOIN Departments dept ON d.DepartmentID = dept.DepartmentID
GROUP BY dept.DepartmentName
ORDER BY AppointmentCount DESC;


-- ---------------------------------------------------------- 3. Revenue Analysis-----------------------------------------------------------
-- We can analyze the revenue generated by each department, based on the billing data. This can provide insights into the financial performance of the hospital's departments.

-- Revenue by Department
 SELECT dept.DepartmentName, SUM(b.Amount) AS TotalRevenue
FROM Billing b
JOIN Appointments a ON b.AppointmentID = a.AppointmentID
JOIN Doctors d ON a.DoctorID = d.DoctorID
JOIN Departments dept ON d.DepartmentID = dept.DepartmentID
GROUP BY dept.DepartmentName
ORDER BY TotalRevenue DESC;


-- Payment Status Analysis
-- We can also analyze the payment status of bills to identify issues with pending payments.

SELECT PaymentStatus, COUNT(*) AS BillCount
FROM Billing
GROUP BY PaymentStatus;


-- -------------------------------------------------- 4. Prescription Patterns----------------------------------------------------
-- We can analyze medication prescription patterns to identify the most commonly prescribed medications and the doctors who prescribe them.

-- Most Prescribed Medications

SELECT m.MedicationName, COUNT(p.PrescriptionID) AS PrescriptionCount
FROM Prescriptions p
JOIN Medications m ON p.MedicationID = m.MedicationID
GROUP BY m.MedicationName
ORDER BY PrescriptionCount DESC;


-- Doctor Prescription Patterns

SELECT d.DoctorName, m.MedicationName, COUNT(p.PrescriptionID) AS PrescriptionCount
FROM Prescriptions p
JOIN Doctors d ON p.DoctorID = d.DoctorID
JOIN Medications m ON p.MedicationID = m.MedicationID
GROUP BY d.DoctorName, m.MedicationName
ORDER BY PrescriptionCount DESC;


--  -----------------------------------------------5. Appointment Trends (By Month)----------------------------------------------
-- We can identify seasonal trends in appointments by grouping the data by month.
-- Monthly Appointment Trends

SELECT MONTH(AppointmentDate) AS Month, COUNT(*) AS AppointmentCount
FROM Appointments
GROUP BY Month
ORDER BY Month;

-- -----------------------------------------------------6. Utilization of Underutilized Departments-----------------------------------------------
-- Identify underutilized departments to focus marketing efforts or promotions.

-- Underutilized Departments (By Number of Appointments)
 SELECT dept.DepartmentName, COUNT(a.AppointmentID) AS AppointmentCount
FROM Appointments a
JOIN Doctors d ON a.DoctorID = d.DoctorID
JOIN Departments dept ON d.DepartmentID = dept.DepartmentID
GROUP BY dept.DepartmentName
ORDER BY AppointmentCount ASC;


-- ----------------------------------------7. Billing Insights (Average Bill Amount and Payment Status)------------------------------------
-- We can calculate the average bill amount across appointments and analyze the payment statuses.

-- Average Billing Amount
 SELECT AVG(Amount) AS AverageBillAmount
FROM Billing;


-- Billing Payment Status Breakdown
SELECT PaymentStatus, AVG(Amount) AS AverageBillAmount
FROM Billing
GROUP BY PaymentStatus;

 -- ----------------------------------------------------------------------insights------------------------------------------------------
 -- Demographics: Analyze gender and age distributions to tailor services.
-- Doctor and Department Demand: Identify popular doctors and high-demand departments for resource allocation.
-- Revenue: Focus on high-revenue departments like Cardiology and Oncology.
-- Prescriptions: Monitor frequent medications to update treatment protocols.
-- Appointments: Use monthly trends to manage seasonal demand.
-- Payments: Address pending payments with improved billing processes.
-- Underutilized Departments: Promote less visited departments through marketing efforts.






You’ve hit the Free pla


