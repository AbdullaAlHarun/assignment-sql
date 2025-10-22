#ABDULLA AL HARUN

-- ─────────────────────────────────────────────────────────────────────────────
#Question 2.1.1 Solution
-- ─────────────────────────────────────────────────────────────────────────────

USE LibraryDB;

SELECT DISTINCT
  a.LastName, a.FirstName,
  CONCAT(a.FirstName, ' ', a.LastName) AS AuthorName
FROM Authors a
JOIN Books  b ON b.AuthorID = a.AuthorID
JOIN Media  m ON m.BookID   = b.BookID
WHERE m.MediaType = 'Movie'
  AND m.ReleaseYear > 2000
ORDER BY a.LastName, a.FirstName;

-- ─────────────────────────────────────────────────────────────────────────────
#Question 2.1.2 Solution
-- ─────────────────────────────────────────────────────────────────────────────

USE LibraryDB;

SELECT
  CONCAT(a.FirstName, ' ', a.LastName)           AS AuthorName,
  COUNT(DISTINCT b.BookID)                       AS TotalBooks,
  COUNT(DISTINCT CASE WHEN m.MediaType = 'Movie'
                      THEN b.BookID END)         AS TotalMovies
FROM Authors a
LEFT JOIN Books  b ON b.AuthorID = a.AuthorID
LEFT JOIN Media  m ON m.BookID   = b.BookID
GROUP BY a.AuthorID, a.LastName, a.FirstName
ORDER BY TotalBooks DESC, TotalMovies DESC, a.LastName ASC, a.FirstName ASC;


-- ─────────────────────────────────────────────────────────────────────────────
#Question 2.1.3 Solution
-- ─────────────────────────────────────────────────────────────────────────────

USE LibraryDB;
SELECT
  b.BookID,
  b.Title
FROM Books b
JOIN Media m ON m.BookID = b.BookID
WHERE b.Title LIKE '%I%'
  AND m.MediaType IN ('Audiobook', 'Movie')
GROUP BY b.BookID, b.Title
HAVING COUNT(DISTINCT m.MediaType) = 2
ORDER BY b.Title;

-- ─────────────────────────────────────────────────────────────────────────────
#Question 2.1.4 Solution
-- ─────────────────────────────────────────────────────────────────────────────

USE LibraryDB;
START TRANSACTION;
-- 1) Ensure author and publisher exist (create if missing)

INSERT INTO Authors (FirstName, LastName, BirthYear, Country)
SELECT 'Frank','Herbert',1920,'United States'
WHERE NOT EXISTS (
  SELECT 1 FROM Authors WHERE FirstName='Frank' AND LastName='Herbert'
);

INSERT INTO Publishers (Name, Country)
SELECT 'Chilton Books','United States'
WHERE NOT EXISTS (
  SELECT 1 FROM Publishers WHERE Name='Chilton Books'
);

-- Use the canonical (lowest) IDs if duplicates exist
SET @AuthorID    := (SELECT MIN(AuthorID)    FROM Authors    WHERE FirstName='Frank' AND LastName='Herbert');
SET @PublisherID := (SELECT MIN(PublisherID) FROM Publishers WHERE Name='Chilton Books');

-- If duplicates exist for the author/publisher, point any books at the kept IDs,
-- then remove the extra rows.
UPDATE Books
SET AuthorID = @AuthorID
WHERE AuthorID IN (
  SELECT a.AuthorID FROM Authors a
  WHERE a.FirstName='Frank' AND a.LastName='Herbert' AND a.AuthorID <> @AuthorID
);

DELETE FROM Authors
WHERE FirstName='Frank' AND LastName='Herbert' AND AuthorID <> @AuthorID;

UPDATE Books
SET PublisherID = @PublisherID
WHERE PublisherID IN (
  SELECT p.PublisherID FROM Publishers p
  WHERE p.Name='Chilton Books' AND p.PublisherID <> @PublisherID
);

DELETE FROM Publishers
WHERE Name='Chilton Books' AND PublisherID <> @PublisherID;


-- 2) Ensure the book "Dune" (1965) exists for Frank Herbert @ Chilton Books

INSERT INTO Books (Title, AuthorID, PublisherID, PublishYear, ISBN)
SELECT 'Dune', @AuthorID, @PublisherID, 1965, '9780441172719'
WHERE NOT EXISTS (
  SELECT 1 FROM Books
  WHERE Title='Dune' AND AuthorID=@AuthorID
);

-- If multiple Dune rows exist, keep the lowest BookID, move media to it, delete the rest.
SET @KeepBookID := (SELECT MIN(BookID) FROM Books WHERE Title='Dune' AND AuthorID=@AuthorID);

INSERT INTO Media (BookID, MediaType, ReleaseYear)
SELECT @KeepBookID, m.MediaType, m.ReleaseYear
FROM Media m
JOIN Books b ON b.BookID = m.BookID
WHERE b.Title='Dune' AND b.AuthorID=@AuthorID AND b.BookID <> @KeepBookID
  AND NOT EXISTS (
      SELECT 1 FROM Media x
      WHERE x.BookID=@KeepBookID AND x.MediaType=m.MediaType AND x.ReleaseYear=m.ReleaseYear
  );

DELETE FROM Media
WHERE BookID IN (
  SELECT BookID FROM Books
  WHERE Title='Dune' AND AuthorID=@AuthorID AND BookID <> @KeepBookID
);

DELETE FROM Books
WHERE Title='Dune' AND AuthorID=@AuthorID AND BookID <> @KeepBookID;


-- 3) Ensure the two Villeneuve movies exist (2021, 2024)

INSERT INTO Media (BookID, MediaType, ReleaseYear)
SELECT @KeepBookID, 'Movie', 2021
WHERE NOT EXISTS (
  SELECT 1 FROM Media WHERE BookID=@KeepBookID AND MediaType='Movie' AND ReleaseYear=2021
);

INSERT INTO Media (BookID, MediaType, ReleaseYear)
SELECT @KeepBookID, 'Movie', 2024
WHERE NOT EXISTS (
  SELECT 1 FROM Media WHERE BookID=@KeepBookID AND MediaType='Movie' AND ReleaseYear=2024
);

COMMIT;


-- 4) To be sure everything ran as expected (for checking)

USE LibraryDB;

SELECT b.Title,
       CONCAT(a.FirstName,' ',a.LastName) AS Author,
       p.Name AS Publisher,
       m.MediaType, m.ReleaseYear
FROM Books b
JOIN Authors a    ON a.AuthorID=b.AuthorID
JOIN Publishers p ON p.PublisherID=b.PublisherID
LEFT JOIN Media m ON m.BookID=b.BookID
WHERE b.Title='Dune'


-- ─────────────────────────────────────────────────────────────────────────────
#Question 2.1.5 Solution
-- ─────────────────────────────────────────────────────────────────────────────
USE LibraryDB;

WITH
  first_tolkien AS (
    SELECT MIN(b.PublishYear) AS y
    FROM Authors a
    JOIN Books b ON b.AuthorID = a.AuthorID
    WHERE a.LastName = 'Tolkien'   -- handles J.R.R. Tolkien
  ),
  last_hp_movie AS (
    SELECT MAX(m.ReleaseYear) AS y
    FROM Books b
    JOIN Media m ON m.BookID = b.BookID
    WHERE m.MediaType = 'Movie'
      AND b.Title LIKE 'Harry Potter%'   -- all HP titles
  )
SELECT
  ft.y  AS FirstTolkienYear,
  hp.y  AS LastHPMovieYear,
  (hp.y - ft.y) AS YearDifference
FROM first_tolkien ft, last_hp_movie hp;
