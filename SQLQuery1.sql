/*SELECT Avg(Age) AS AvgAge
FROM SQLTutorial.dbo.EmployeeDemographic AS Demo*/
/*SELECT Demo.EmployeeID, Sal.Salary
FROM SQLTutorial.dbo.EmployeeDemographic AS Demo
JOIN SQLTutorial.dbo.employeeSalary AS Sal
ON Demo.EmployeeID=Sal.EmployeeID*/


/*Intermediate SQL Tutorial | Partition By*/


SELECT FirstName,LastName,Gennder,Salary,
COUNT(Gennder) OVER (PARTITION BY Gennder) as TotalGennder
FROM SQLTutorial..EmployeeDemographic dem 
JOIN SQLTutorial..EmployeeSalary sal
ON dem.EmployeeID =sal.EmployeeID



