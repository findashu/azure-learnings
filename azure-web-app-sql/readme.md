### SQL Queries before running the web application

* Create Table

```sql
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    HireDate DATE NOT NULL,
    Salary DECIMAL(18, 2) CHECK (Salary >= 0)
);
```
* Insert Data

```sql
INSERT INTO Employees (FirstName, LastName, Email, HireDate, Salary)
VALUES 
    ('John', 'Doe', 'john.doe@example.com', '2023-01-15', 60000.00),
    ('Jane', 'Smith', 'jane.smith@example.com', '2023-02-20', 65000.00),
    ('Alice', 'Johnson', 'alice.johnson@example.com', '2023-03-10', 70000.00),
    ('Bob', 'Brown', 'bob.brown@example.com', '2023-04-05', 55000.00);

```
* Add WebApp Managed Identity as SQLDB user

```sql
DROP USER IF EXISTS [skillhub-webapp-dev]
GO
CREATE USER [skillhub-webapp-dev] FROM EXTERNAL PROVIDER;
GO
ALTER ROLE db_datareader ADD MEMBER [skillhub-webapp-dev];
ALTER ROLE db_datawriter ADD MEMBER [skillhub-webapp-dev];
GRANT EXECUTE TO [skillhub-webapp-dev]
GO
```