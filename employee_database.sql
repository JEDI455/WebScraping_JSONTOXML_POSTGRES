CREATE TABLE Employees (
    Employee_ID SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Surname VARCHAR(100) NOT NULL,
    Patronymic VARCHAR(100) NOT NULL,
    Gender VARCHAR(20) NOT NULL,
    JobID INT,
    Date_latest DATE NOT NULL,
    DepartmentID INT,
    FOREIGN KEY (JobID) REFERENCES Job(JobID),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID) 
);
CREATE TABLE Departments (
    DepartmentID SERIAL PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL,
);
CREATE TABLE Job (
    JobID SERIAL PRIMARY KEY,
    JobName VARCHAR(100) NOT NULL,
    DepartmentID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);
CREATE TABLE Salaries (
    SalaryID SERIAL PRIMARY KEY,
    Employee_ID INT,
    Salary INT NOT NULL,
    FOREIGN KEY (Employee_ID) REFERENCES Employees(Employee_ID)
);

CREATE TABLE Employment_History (
    HistoryID SERIAL PRIMARY KEY,
    Promotion_Date DATE NOT NULL,
    Employee_ID INT,
    FOREIGN KEY (Employee_ID) REFERENCES Employees(Employee_ID)
);
