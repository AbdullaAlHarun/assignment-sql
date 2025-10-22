#ABDULLA AL HARUN

#Question 2.1.1 Solution

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


#Question 2.1.2 Solution
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


#Question 2.1.3 Solution
