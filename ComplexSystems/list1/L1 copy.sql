USE chinook;

#1
#SHOW TABLES;

#2
#DESCRIBE track;
#SHOW COLUMNS FROM track;

#3
#SELECT t.Name AS TrackTitle, a.Title AS AlbumTitle FROM Track t JOIN Album a ON t.albumid=a.albumid;

#4
#SELECT * FROM Album al JOIN Artist ar ON al.ArtistId=ar.ArtistId WHERE ar.Name='Various Artists';

#5
#SELECT DISTINCT NAME FROM Artist;

#6
#SELECT ar.Name AS ArtistName, al.Title AS AlbumTitle FROM Album al JOIN Artist ar ON al.ArtistId=al.ArtistId;

#7
#SELECT * FROM track WHERE Composer!='Queen';

#8
#SELECT * FROM Track WHERE Milliseconds > 275000 AND Milliseconds < 400000;

#9
#SELECT t.Name, a.Title FROM Track t JOIN Album a ON t.AlbumId=a.AlbumId WHERE t.MediaTypeId=3;

#10


#11
#SELECT DISTINCT City FROM Customer;

#12
#SELECT City FROM Customer WHERE State IS NULL AND Country ='USA';

#13
#SELECT DISTINCT Country FROM Customer WHERE State IS NULL;

#14
#SELECT DISTINCT SUBSTR(Email, INSTR(Email, '@')+1)  FROM Customer;

#15
#SELECT SUBSTRING_INDEX(SUBSTR(Email, INSTR(Email, '@')+1),'.',1) AS CompanyName, COUNT(*) AS NumberOfClients FROM Customer GROUP BY CompanyName;

#16
#SELECT BillingCountry, COUNT(*) FROM Invoice GROUP BY BillingCountry;

#17
#SELECT BillingCountry, AVG(total) FROM Invoice GROUP BY BillingCountry;

#18


#19


#20
#SELECT * FROM Employee WHERE Employeeid NOT IN (SELECT DISTINCT c.Supportrepid FROM Customer c);

#21
#SELECT DISTINCT e.* FROM Customer c JOIN Employee e ON c.Supportrepid=e.Employeeid WHERE c.city != e.city;

#22
#SELECT t.Name, t.UnitPrice FROM Track t JOIN Genre g ON t.Genreid=g.GenreId WHERE g.Name IN ('Sci Fi & Fantasy', 'Science Fiction');

#23

#24
#SELECT * FROM (SELECT e.LastName,e.HireDate,e.BirthDate,DATEDIFF(e.HireDate,e.BirthDate) AS d FROM Employee e)t WHERE t.d = (SELECT MIN(DATEDIFF(e.HireDate,e.BirthDate)) FROM employee e );

#25
#SELECT t.Name, a.Title FROM Track t JOIN Album a ON t.AlbumId=a.AlbumId WHERE a.Title LIKE '%battlestar galactica%' ORDER BY t.Name;

#26


#27
#SELECT * FROM  Track t JOIN Album al ON t.AlbumId=al.AlbumId JOIN Artist ar ON al.ArtistId=ar.ArtistId WHERE ar.Name LIKE '%santana%';

#28
#SELECT DISTINCT NAME FROM Track WHERE Composer LIKE '%john %' ORDER BY NAME;

#29

#30
#INSERT INTO Customer (Customerid, Firstname, Lastname, Company, Address, City, State, Country, Postalcode, Phone, Email, Supportrepid)
#SELECT MAX(Customerid)+1, 'Scott', 'Ford', 'Company', '462 W 7th Street', 'Bakersfield', 'CA', 'USA', '83529', '123456789', 'sford@gmail.com', 3 FROM Customer;

#31
#ALTER TABLE Customer ADD FavGenre INT DEFAULT NULL;

#33
#ALTER TABLE Customer DROP Fax;

#34


#35
