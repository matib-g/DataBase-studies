#1----------

DROP DATABASE IF EXISTS Music;
CREATE DATABASE Music;
USE Music;

DROP USER IF EXISTS 'MusicAdmin'@'localhost';
FLUSH PRIVILEGES;
CREATE USER 'MusicAdmin'@'localhost' IDENTIFIED BY 'Cisum321';
GRANT ALL PRIVILEGES ON Music TO 'MusicAdmin'@'localhost';
FLUSH PRIVILEGES;
#SHOW GRANTS FOR 'MusicAdmin'@'localhost';

DROP USER IF EXISTS 'Mateusz089'@'localhost';
FLUSH PRIVILEGES;
CREATE USER 'Mateusz089'@'localhost' IDENTIFIED BY 'Muzyka7';
GRANT SELECT ON chinook.* TO 'Mateusz089'@'localhost';
GRANT SELECT ON music.* TO 'Mateusz089'@'localhost';
GRANT UPDATE ON music.* TO 'Mateusz089'@'localhost';
FLUSH PRIVILEGES;
#SHOW GRANTS FOR 'Mateusz089'@'localhost';

#SELECT * FROM mysql.user;

#2----------

CREATE TABLE Music.bands(
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(90),
noAlbums INT DEFAULT NULL
);

CREATE TABLE Music.albums(
title VARCHAR(90),
genre VARCHAR(30),
band INT,
PRIMARY KEY (title, band)
);

CREATE TABLE Music.songs(
id INT AUTO_INCREMENT PRIMARY KEY,
title VARCHAR(90),
length INT CHECK (length >=0 ),
album VARCHAR(90),
band INT,
FOREIGN KEY (album) REFERENCES Music.albumS(title) ON DELETE CASCADE,
FOREIGN KEY (band) REFERENCES Music.bands(id) ON DELETE CASCADE
);

CREATE TABLE Music.playlist(
	id INT AUTO_INCREMENT PRIMARY KEY,
	threshold INT,
    song INT,
    FOREIGN KEY (song) REFERENCES music.songs(Id) ON DELETE CASCADE
);
SELECT * FROM Music.playlist;

-- UPDATE table 
#DELIMITER //
#CREATE TRIGGER insertIntoSongs
#AFTER INSERT ON music.songs
#FOR EACH ROW BEGIN 
#UPDATE music.songs SET LENGTH=NEW.LENGTH/1000 WHERE LENGTH=NEW.length;
#END; //

#-----3

INSERT INTO Music.bands (name, noAlbums)
SELECT a.name, COUNT(al.title) FROM Chinook.artist a
JOIN Chinook.album al ON al.artistid = a.artistid GROUP BY al.artistid;
#SELECT * FROM Music.bands;

INSERT INTO Music.albums (title, genre, band)
SELECT DISTINCT a.Title, g.Name, b.Id FROM Chinook.Album a
JOIN chinook.track t ON a.AlbumId = t.AlbumId 
JOIN chinook.artist ar ON a.ArtistId = ar.ArtistId
JOIN Music.bands b ON ar.Name = b.Name
JOIN chinook.genre g ON t.GenreId = g.GenreId
WHERE (b.id not IN (45, 55, 66, 110, 111, 112, 119, 172) ) #some albums have two diff genre... 
#SELECT AlbumId, AVG(GenreId) FROM track GROUP BY AlbumId; to find numbers above...
ORDER BY b.id, a.title; 
#SELECT * FROM Music.albums;

INSERT INTO Music.songs (title, length, album, band)
SELECT t.Name, t.Milliseconds/1000, ma.title, b.id FROM chinook.track t
JOIN chinook.album a ON t.AlbumId=a.AlbumId
JOIN chinook.artist ar ON a.ArtistId = ar.ArtistId
JOIN music.bands b ON ar.Name = b.name
JOIN music.albums ma ON a.Title=ma.title
WHERE t.name NOT LIKE '%v%' AND length(t.name) < 90;
#SELECT * FROM Music.songs;

#-----4

DELIMITER $$
CREATE PROCEDURE counter()
BEGIN
DECLARE bandId VARCHAR(90);
DECLARE noAlbums INT DEFAULT 0;
DECLARE done INT DEFAULT FALSE;
DECLARE fillNoAlbums CURSOR FOR
(SELECT b.id, COUNT(a.title) FROM Music.bands b JOIN Music.albums a ON b.id = a.band GROUP BY b.id);
DECLARE CONTINUE HANDLER
FOR NOT FOUND SET done = 1;
	OPEN fillNoAlbums;
	updateLoop: LOOP
		FETCH fillNoAlbums INTO bandId, noAlbums;
        IF done THEN
			LEAVE updateLoop;
		END IF;
        UPDATE Music.bands SET noAlbums = noAlbums WHERE Music.bands.id = bandId;
	END LOOP updateLoop;
	CLOSE fillNoAlbums;
END $$

CALL counter();

#SELECT * FROM Music.bands;

#-----5

DELIMITER $$
CREATE TRIGGER updateNoAlbums
AFTER INSERT ON Music.albums
FOR EACH ROW BEGIN
UPDATE Music.bands SET noAlbums = (SELECT COUNT(title) FROM Music.albums WHERE band = NEW.band GROUP BY band); #WHERE Music.bands.id = Music.albums.band;
DELETE FROM Music.bands WHERE Music.bands.noAlbums = 0;
END; $$

#-----6

DROP PROCEDURE IF EXISTS randAlbums;

DELIMITER $$
CREATE PROCEDURE randAlbums(k INT)
BEGIN
DECLARE ranBand INT;
DECLARE ranGen INT;
DECLARE randTitleStr VARCHAR(90);
DECLARE noSongs INT;
DECLARE ranLen INT;
DECLARE i INT;
DECLARE j INT;
DECLARE genName VARCHAR(30);
DECLARE var INT;
SET SQL_SAFE_UPDATES = 0;

SET i = 1;
WHILE(i<k+1) DO
	SET ranBand = FLOOR(1 + RAND() * (SELECT COUNT(*) FROM bands));
	SET ranGen = FLOOR(1 + RAND() * 24);
	SET randTitleStr = CONCAT("rand", FLOOR(1 + RAND() * 10000));
	SET noSongs = FLOOR(4 + RAND() * 21);
	IF ranBand NOT IN (SELECT id FROM bands) THEN
		INSERT INTO bands (name, noAlbums) VALUES (ranBand, 0);
	END IF;
	SELECT name FROM Chinook.genre WHERE (genreid = ranGen) INTO genName;
	INSERT INTO Music.albums VALUES (randTitleStr, genName, ranBand);
        
	SET j = 1;
	WHILE(j<noSongs+1) DO
		SET ranLen = FLOOR(1 + RAND() * 600);
		SELECT COUNT(*) FROM Music.songs INTO var;
		INSERT INTO Music.songs (title, length, album, band) VALUES (CONCAT("rand", var), ranLen, randTitleStr, ranBand);
		SET j = j + 1;
	END WHILE;
        
	SET i = i +1;
END while;
SET SQL_SAFE_UPDATES = 1;
END; $$

CALL randAlbums(5);
SELECT * FROM albums;
SELECT * FROM bands;
SELECT * FROM songs;

#-----7

DELIMITER $$
CREATE PROCEDURE shortestAlbumOfTheBand (IN bandName VARCHAR(90), OUT albumLength INT)
BEGIN
SET @bandId = (SELECT Id FROM music.bands WHERE name = bandName);
SET albumLength = (SELECT MIN(t.sumLength) FROM (SELECT SUM(LENGTH) AS sumLength FROM music.songs WHERE band=@bandId GROUP BY album) t);
SELECT albumLength;
END; $$

CALL shortestAlbumOfTheBand('U2', @albumLength);
#SELECT @albumLength;

#-----8

CREATE VIEW longerThanThree AS
SELECT s.title AS songTitle, s.length, a.title AS albumTitle, a.genre, b.name AS band, b.noAlbums FROM music.songs s 
JOIN music.albums a ON s.album = a.title
JOIN music.bands b ON a.band=b.Id
WHERE s.length > 180;

#SELECT * FROM longerThanThree;

#-----9

SET @str = CONCAT('SELECT b.name, COUNT(a.title) FROM music.albums a JOIN Music.bands b ON a.band = b.id WHERE a.genre = ? GROUP BY genre, band;');
PREPARE stmt FROM @str;
SET @n = 'Rock';
EXECUTE stmt USING @n;

#-----10

DELIMITER $$
CREATE PROCEDURE selectRelAgg (IN rel VARCHAR(10), IN agg VARCHAR(10))
BEGIN
	SET @selectedAgg = '';
    SELECT CASE
		WHEN UPPER(agg) = 'MIN' THEN CONCAT('MIN(length)')
        WHEN UPPER(agg) = 'MAX' THEN CONCAT('MAX(length)')
        WHEN UPPER(agg) = 'AVG' THEN CONCAT('AVG(length)')
    END
    INTO @selectedAgg;
    
    SET @stmt = CONCAT('SELECT * FROM Music.songs s WHERE (SELECT ', @selectedAgg, ' FROM Music.songs) ', rel, ' s.length;');
    PREPARE stmtExec FROM @stmt;
    EXECUTE stmtExec;
END; $$

#CALL selectRelAgg('>', 'AVG');

#-----11

DELIMITER $$
CREATE PROCEDURE randomPlaylist (IN thresh INT)
BEGIN
START TRANSACTION;
SELECT * FROM music.songs WHERE LENGTH < thresh ORDER BY RAND() LIMIT 20;
END; $$

#CALL randomPlaylist(300);

#-----12

#DROP TABLE IF EXISTS Music.playlist;
/*
CREATE TABLE Music.playlist(
	id INT AUTO_INCREMENT PRIMARY KEY,
	threshold INT,
    song INT,
    FOREIGN KEY (song) REFERENCES music.songs(Id) ON DELETE CASCADE
);
SELECT * FROM Music.playlist;
*/

DELIMITER $$
CREATE PROCEDURE insertIntoplaylist (IN thresh INT)
BEGIN 
DECLARE i INT;
START TRANSACTION;
SET i =1;
INSERT INTO Music.playlist (threshold, song)
SELECT thresh, s.id FROM Music.songs s WHERE s.length < thresh ORDER BY RAND() LIMIT 20;
COMMIT;
END; $$

#CALL insertIntoplaylist (300);
#SELECT * FROM Music.playlist;

#-----Quiz2
# k=0

DELIMITER $$
CREATE PROCEDURE sortedG (IN g VARCHAR(20), IN ord VARCHAR(10))
BEGIN
	SET @selectedOrd = '';
    SELECT CASE
		WHEN UPPER(ord) = 'ASC' THEN 'ASC'
        WHEN UPPER(ord) = 'DESC' THEN 'DESC'
	END
    INTO @selectedOrd;
    
    SET @stmt = CONCAT('SELECT DISTINCT b.name FROM Music.bands b JOIN Music.albums a ON b.id = a.band WHERE a.genre = "', g, '" ORDER BY b.name ', @selectedOrd,';');
    PREPARE stmtExec FROM @stmt;
    EXECUTE stmtExec;
END;$$

CALL sortedG ('Rock', 'DESC');

# k=1
#1.
/*
DELIMITER $$
CREATE TRIGGER deleteNoAlbums
AFTER UPDATE ON Music.bands
FOR EACH ROW BEGIN
DELETE FROM Music.bands WHERE Music.bands.noAlbums = 0;
END; $$

SELECT * FROM Music.bands ORDER BY Music.bands.noAlbums ASC;

INSERT INTO Music.bands VALUE (null, 'zaspol1', 0);

SELECT * FROM Music.bands ORDER BY Music.bands.noAlbums ASC;
*/

#-----Quiz2

#k=0
DELIMITER $$
CREATE PROCEDURE mosT (IN t INT)
BEGIN
SET @n = t;
	#SET @stmt = 'SELECT DISTINCT b.name, COUNT(*) AS "noSongs" FROM Music.bands b JOIN Music.songs s ON b.id = s.band WHERE "noSongs" < ? GROUP BY s.band;';
    SET @stmt = 'SELECT n.name, n.noSongs FROM (SELECT b.name, COUNT(*) AS "noSongs" FROM Music.bands b JOIN Music.songs s ON b.id = s.band GROUP BY s.band) n WHERE n.noSongs < ?';
    PREPARE stmtExec FROM @stmt;
    EXECUTE stmtExec USING @n;
END; $$

#CALL mosT(12);

#QUIZ
DELIMITER $$
CREATE PROCEDURE songsofG (IN g VARCHAR(20))
BEGIN
	SET @n = g;
    SET @stmt = 'SELECT gs.t1, gs.length l1 FROM (SELECT s.title t1, a.title t2, a.genre, s.length FROM Music.songs s JOIN Music.albums a ON s.album = a.title WHERE a.genre = ?) gs WHERE gs.l1 < (SELECT AVG(length) FROM gs)';
	#SET @stmt = 'SELECT * FROM Music.songs s JOIN Music.albums a ON s.album = a.title WHERE a.genre = ?';
	PREPARE stmtExec FROM @stmt;
	EXECUTE stmtExec USING @n;
END; $$

CALL songsofG('Rock');










