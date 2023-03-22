USE chinook;

#1
#SHOW TABLES;

#2
#DESCRIBE Track;

#3 For each track print out a pair of track title and album title.
#SELECT Track.Name, Album.Title FROM Track JOIN Album ON Track.AlbumId=Album.AlbumId;

#4 Select all albums by ’Various Artists’.
#SELECT Album.Title FROM Album JOIN Artist ON Album.ArtistId=Artist.ArtistId WHERE Artist.Name='Various Artists';

#5 Print out all the unique names of the artists.
#SELECT DISTINCT Artist.Name FROM Artist;

#6 For each artist print out all the pairs (artist name, album title).
#SELECT Artist.Name, Album.Title FROM Artist JOIN Album ON Artist.ArtistId=Album.ArtistId;

#7 Print out all the tracks except the ones performed by Queen.
#SELECT Track.Name FROM Track JOIN Album ON Track.AlbumId=Album.AlbumId 
#WHERE Album.AlbumId NOT IN(
#SELECT AlbumID FROM Album JOIN Artist ON Album.ArtistId=Artist.ArtistId WHERE Artist.Name='Queen'
#);

#8  Print out all the audio files (both AAC and MPEG) that last between 275s and 400s.
#SELECT * FROM Track WHERE Milliseconds>=275000 AND Milliseconds<=400000;

#9  Select all non-audio tracks and their album titles.
#SELECT Track.Name, Album.Title FROM Track JOIN Album ON Album.AlbumId=Track.AlbumId WHERE Track.MediaTypeId=3;

#10  Select all tracks from each playlist that contains Classic substring in its name. The resulting schema should contain only track titles, album names, band names and the genre.
#SELECT Track.Name, Album.Title, Artist.Name, Genre.Name FROM Track JOIN PlaylistTrack ON Track.TrackId=PlaylistTrack.TrackId JOIN Playlist ON Playlist.PlaylistId=PlaylistTrack.PlaylistId JOIN Album ON Album.AlbumId=Track.AlbumId JOIN Artist ON Artist.ArtistId=Album.ArtistId JOIN Genre ON Genre.GenreId=Track.GenreId WHERE Playlist.Name LIKE '%Classic%';

#11  Select all the cities, from which came the clients in the database.
#SELECT DISTINCT City FROM Customer;

#12 Check whether all American cities in the database have a state assigned.
#SELECT City FROM Customer WHERE Customer.Country='USA' AND State IS NULL;

#13  List all the countries that do not have states assigned
#SELECT DISTINCT Country FROM Customer WHERE State IS NULL;

#14  List all the domains of the clients’ e-mails
#SELECT DISTINCT SUBSTR(Email, INSTR(Email, '@')+1) FROM Customer;

#15  For each of the domains print out the number of clients using them. Count together the companies without distinction on their country suffix.
#SELECT SUBSTRING_INDEX(SUBSTR(Email, INSTR(Email, '@')+1),'.',1), COUNT(*) AS freq FROM Customer GROUP BY SUBSTRING_INDEX(SUBSTR(Email, INSTR(Email, '@')+1),'.',1);

#16 Find country from which clients ordered products with highest joint value
#SELECT BillingCountry, SUM(Total) AS JoinedV FROM Invoice GROUP BY BillingCountry ORDER BY JoinedV DESC LIMIT 1;

#17 For each country print out the average value of ordered goods.
#SELECT BillingCountry, AVG(Total) FROM Invoice GROUP BY BillingCountry;

#18 Find the album of the highest value. The resulting scheme should contain the name of the artist, the title of the album, the number of the tracks and the total price.
#SELECT Artist.Name, Album.Title, t1.AlbumId, COUNT(*) AS TracksNumber, SUM(UnitPrice)AS TotalPrice FROM Track t1
#JOIN Album ON t1.AlbumId=Album.AlbumId 
#JOIN Artist ON Artist.ArtistId=Album.ArtistId
#GROUP BY t1.AlbumId ORDER BY TotalPrice DESC LIMIT 1;

#19  Find the artist with the second highest number of tracks
#SELECT Artist.Name, COUNT(*) AS NumberOfTracks FROM Track JOIN Album ON Album.AlbumId=Track.AlbumId JOIN Artist ON Artist.ArtistId=Album.AlbumId GROUP BY Artist.ArtistId ORDER BY NumberOfTracks DESC LIMIT 1,1;

#20  Using customer and employee tables, list the employees who are not currently responsible for customer service.
#SELECT E1.EmployeeId, E1.LastName, E1.FirstName, E1.Title FROM Employee E1 WHERE E1.EmployeeId NOT IN(
#SELECT E2.EmployeeId FROM Employee E2 JOIN Customer ON Customer.SupportRepId=E2.EmployeeId GROUP BY E2.EmployeeId);

#21  List all employees who do not serve any customer from their own city
#SELECT DISTINCT Employee.* FROM Employee JOIN Customer ON Employee.EmployeeId=Customer.SupportRepId WHERE Customer.City!=Employee.City;

#22  List all offered products belonging to Sci Fi & Fantasy or Science Fiction. The schema should include the titles and their price.
#SELECT Track.Name, Track.UnitPrice FROM Track JOIN Genre ON Track.GenreId=Genre.GenreId WHERE Genre.Name IN ('Sci Fi & Fantasy', 'Science Fiction');

#23  Find out which artist has the most Metal and Heavy Metal songs (combined). Display the band name and track count. Order the result by the number of tracks in a descending manner.
#SELECT Artist.Name, COUNT(*) AS NumberOfTracks FROM Track JOIN Genre ON Track.GenreId=Genre.GenreId JOIN Album ON Track.AlbumId=Album.AlbumId JOIN Artist ON Album.ArtistId=Artist.ArtistId WHERE Genre.Name IN ('Metal', 'Heavy Metal') GROUP BY Artist.Name ORDER BY NumberOfTracks DESC

#24 Find the employee that was the youngest when first hired.
#SELECT * FROM (SELECT Employee.FirstName, Employee.LastName, Employee.BirthDate, Employee.HireDate, DATEDIFF(Employee.HireDate,Employee.BirthDate) AS DiffDate FROM Employee) t WHERE t.DiffDate = (SELECT MIN(DATEDIFF(Employee.HireDate,Employee.BirthDate)) FROM Employee);

#25 Select all episodes of Battlestar Galactica on offer, include all seasons. Order the results by the title.
#SELECT Track.Name, Album.Title FROM Track JOIN Album ON Track.AlbumId=Album.AlbumId WHERE Album.Title LIKE '%battlestar galactica%' ORDER BY Track.Name;

#26  Select artist names and album titles in cases where the same title is used by two different bands. (Note: If (X, Y, A) is selected, the result should not include (Y, X, A)).
#SELECT ar1.Name, ar2.Name, al1.Title, al2.Title FROM Artist ar1 JOIN Album al1 ON al1.ArtistId=ar1.ArtistId, Artist ar2 JOIN Album al2 ON al2.ArtistId=ar2.ArtistId WHERE al1.Title=al2.Title AND ar1.ArtistId>ar2.ArtistId;
#test:
#SELECT Title, COUNT(*) AS freq FROM Album GROUP BY Title ORDER BY freq DESC;

#27  Select all the songs by Santana, regardless of who was featuring the record.
#SELECT * FROM Track JOIN Album ON Track.AlbumId=Album.AlbumId JOIN Artist ON Album.ArtistId=Artist.ArtistId WHERE Artist.Name LIKE '%santana%';

#28 Print out all the records composed by a person named John, ensure that none of the records are repeated. Order the results alphabetically in terms of the track title.
#SELECT DISTINCT Name FROM Track WHERE Composer LIKE '%john %' ORDER BY NAME;

#29  Sort all the artists in descending order of the average duration of their rock song. Do not include artists who have recorded less than 7 for songs in the Rock category.
#SELECT * FROM (SELECT Artist.Name, AVG(Track.Milliseconds) AS AvgDuration, COUNT(Artist.Name) AS NumberOfTracks FROM Artist JOIN Album ON Artist.ArtistId=Album.ArtistId JOIN Track ON Album.AlbumId=Track.AlbumId JOIN Genre ON Track.GenreId=Genre.GenreId WHERE Genre.Name='Rock' GROUP BY Artist.Name) a WHERE a.NumberOfTracks>6 ORDER BY a.AvgDuration DESC;

#30 Enter a new customer into the customer table, do not create any invoices for them.
#INSERT INTO Customer (Customerid, Firstname, Lastname, Company, Address, City, State, Country, Postalcode, Phone, Email, Supportrepid)
#SELECT MAX(Customerid)+1, 'Adam', 'Ford', 'Company', '462 W 7th Street', 'Bakersfield', 'CA', 'USA', '83529', '123456789', 'sford@gmail.com', 3 FROM Customer;

#31  Add a FavGenre column (as a last one) to the customer table. Set it, initially, to NULL for all clients.
#ALTER TABLE Customer ADD FavGenre INT DEFAULT NULL;

#32  For each customer, set the FavGenre value to genre ID of the genre he bought the most tracks of.
#CREATE VIEW v1 AS (SELECT 
#UPDATE Customer c SET FavGenre = (
#SELECT Genre.GenreId 
#FROM Customer JOIN Invoice ON Customer.CustomerId=Invoice.CustomerId JOIN InvoiceLine ON Invoice.InvoiceId=InvoiceLine.InvoiceId JOIN Track ON InvoiceLine.TrackId=Track.TrackId JOIN Genre ON Track.GenreId=Genre.GenreId 
#WHERE Genre.GenreId) WHERE  ;

#33 Remove the Fax column from the customer table.
#ALTER TABLE Customer DROP Fax;

#34  Delete from the invoice table all the invoices issued before 2010.
#DELETE FROM Invoice WHERE InvoiceDate < '2010-01-01 00:00:00';

#35 Remove from the database information about customers who are not related to any transaction.

#36


