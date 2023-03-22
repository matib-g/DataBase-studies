#1
#(IF NOT EXISTS) Music - how to use if not exists?
CREATE DATABASE Music

CREATE USER 'MusicAdmin'@'%';
SET PASSWORD FOR 'MusicAdmin'@'localhost' = PASSWORD('Music123');

#Nie działa 
#REVOKE ALL PRIVILEGES ON *.* TO 'MusicAdmin'@'localhost'

GRANT ALL PRIVILEGES ON Music TO 'MusicAdmin'@'localhost'
FLUSH PRIVILEGES 
SHOW GRANTS FOR 'MusicAdmin'@'localhost'

CREATE USER 'Mateusz045'@'localhost';
SET PASSWORD FOR 'Mateusz045'@'localhost' = PASSWORD('Mateusz123');

GRANT SELECT ON chinook.* TO 'Mateusz045'@'localhost'
GRANT SELECT ON music.* TO 'Mateusz045'@'localhost'
GRANT UPDATE ON music.* TO 'Mateusz045'@'localhost'
FLUSH PRIVILEGES 
SHOW GRANTS FOR 'Mateusz045'@'localhost'

SELECT * FROM mysql.user

#2
CREATE TABLE music.bands2(
Id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(90),
noAlbums INT DEFAULT NULL) 

CREATE TABLE music.albums(
title VARCHAR(90),
genre VARCHAR(30),
band INT,
PRIMARY KEY (title, band))

CREATE TABLE music.songs(
Id INT AUTO_INCREMENT PRIMARY KEY,
title VARCHAR(90),
length INT CHECK (length >=0 ),
album VARCHAR(90),
band INT,
FOREIGN KEY (album) REFERENCES music.albums(title) ON DELETE CASCADE,
FOREIGN KEY (band) REFERENCES music.bands(Id) ON DELETE CASCADE)

-- UPDATE table 
DELIMITER //
CREATE TRIGGER insertIntoSongs
AFTER INSERT ON music.songs
FOR EACH ROW BEGIN 
UPDATE music.songs SET LENGTH=NEW.LENGTH/1000 WHERE LENGTH=NEW.length;
END; //

#3 
INSERT INTO music.bands (NAME, noAlbums) 
SELECT a.name, COUNT(al.Title) FROM chinook.artist a 
JOIN chinook.album al ON al.ArtistId=a.ArtistId GROUP BY al.ArtistId

INSERT INTO music.albums (title, genre, band)
SELECT DISTINCT a.Title, g.Name, b.Id FROM chinook.album a 
JOIN chinook.track t ON a.AlbumId = t.AlbumId 
JOIN chinook.artist ar ON a.ArtistId = ar.ArtistId 
JOIN music.bands b ON ar.Name = b.Name
JOIN chinook.genre g ON t.GenreId = g.GenreId
WHERE (b.id not IN (50, 59, 69, 112, 113, 114, 120, 281, 172) )
ORDER BY b.id, a.title

INSERT INTO music.songs (title, LENGTH, album, band)
SELECT t.Name, t.Milliseconds/1000, ma.title, b.id FROM chinook.track t
JOIN chinook.album a ON t.AlbumId=a.AlbumId
JOIN chinook.artist ar ON a.ArtistId = ar.ArtistId
JOIN music.bands b ON ar.Name = b.name
JOIN music.albums ma ON a.Title=ma.title
WHERE t.name NOT LIKE '%v%' AND length(t.name) < 90

SELECT * FROM songs

#4
DELIMITER $$
CREATE PROCEDURE counter()
BEGIN 
DECLARE bandId VARCHAR(90);
DECLARE noAlbums INT DEFAULT 0;
DECLARE done INT DEFAULT FALSE;
DECLARE fillNoAlbums CURSOR FOR
(SELECT id, COUNT(title) FROM music.bands GROUP BY band);
DECLARE CONTINUE handler 
FOR NOT FOUND SET done = 1;
OPEN fillNoAlbums;
	updateLoop : LOOP
		FETCH fillNoAlbums INTO bandId, noAlbums;
		IF done THEN
			LEAVE updateLoop;
		END IF;
UPDATE music.bands SET noAlbums = (SELECT COUNT(title) FROM music.albums WHERE band = bandId) WHERE band = bandId;
	END LOOP updateLoop;
CLOSE fillNoAlbums;
END $$

CALL counter ();

#5
DELIMITER //

CREATE TRIGGER updatenoAlbums
AFTER INSERT ON music.albums
FOR EACH ROW BEGIN
UPDATE music.bands SET noAlbums = (SELECT COUNT(title) FROM music.albums WHERE band=NEW.band GROUP BY band);
END; // 


#6

#7-- Dodać zabezpieczenia
DELIMITER $$
CREATE PROCEDURE shortestAbum (IN bandName VARCHAR(90), OUT albumLength INT )
BEGIN
SET @bandId = (SELECT Id FROM music.bands WHERE NAME = bandName);
SET albumLength = (SELECT MIN(t.sumLength) FROM (SELECT SUM(LENGTH) AS sumLength FROM music.songs WHERE band=@bandId GROUP BY album) t);
END; $$

CALL shortestAlbum('AC/DC')

#8
CREATE VIEW longSongs AS
SELECT s.title AS songTitle, s.length, a.title AS albumTitle, a.genre, b.name, b.noAlbums FROM music.songs s 
JOIN music.albums a ON s.album = a.title
JOIN music.bands b ON a.band=b.Id
WHERE s.length > 180

#9
SET @str = "SELECT COUNT(title) FROM music.albums WHERE genre=? GROUP BY genre, band";
PREPARE stmt FROM @str;
SET @n = 'Rock';
EXECUTE stmt USING @n;

#10

#11
DELIMITER $$
CREATE PROCEDURE randomPlaylist (IN thresh INT)
BEGIN 
SET autocommit = 0
START TRANSACTION;
SELECT * FROM music.songs WHERE LENGTH < 300 ORDER BY RAND() LIMIT 20;
END; $$




#12
CREATE TABLE playlists(
Id INT AUTO_INCREMENT PRIMARY KEY,
threshold INT);

CREATE TABLE playlistsongs(
Id INT AUTO_INCREMENT PRIMARY KEY,
playlist INT,
song INT,
FOREIGN KEY (playlist) REFERENCES music.playlists(Id) ON DELETE CASCADE,
FOREIGN KEY (song) REFERENCES music.songs(Id) ON DELETE CASCADE);






