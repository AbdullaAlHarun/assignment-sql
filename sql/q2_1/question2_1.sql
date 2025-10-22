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