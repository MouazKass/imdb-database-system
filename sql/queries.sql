-- =============================================================================
-- IMDb Movie Database Management System
-- Analytical Queries
-- Oracle SQL
-- =============================================================================


-- =============================================================================
-- QUERY 1: Find all titles with their ratings and genres (rated 8.0+)
-- =============================================================================
-- Demonstrates multi-table JOINs across Title, Rating, Has_Genre, and Genre.
-- Filters for highly-rated titles and orders by rating and release year.

SELECT
    t.titleName,
    t.releaseYear,
    r.averageRating,
    r.numVotes,
    g.genreName
FROM Title t
JOIN Rating r      ON t.tconst = r.tconst
JOIN Has_Genre hg  ON t.tconst = hg.tconst
JOIN Genre g       ON hg.genreName = g.genreName
WHERE r.averageRating >= 8.0
ORDER BY r.averageRating DESC, t.releaseYear DESC;


-- =============================================================================
-- QUERY 2: Count the number of titles directed by each director
-- =============================================================================
-- Demonstrates GROUP BY with aggregation (COUNT) and HAVING clause filtering.
-- Uses string concatenation to build a full director name.
-- Only returns directors with 2 or more films.

SELECT
    p.firstName || ' ' || p.lastName AS directorName,
    p.birthYear,
    COUNT(db.tconst) AS numberOfFilms
FROM Person p
JOIN Directed_By db ON p.nconst = db.nconst
GROUP BY p.nconst, p.firstName, p.lastName, p.birthYear
HAVING COUNT(db.tconst) >= 2
ORDER BY numberOfFilms DESC;


-- =============================================================================
-- QUERY 3: Find actors and the characters they played in specific titles
-- =============================================================================
-- Demonstrates JOINs on the Works_On junction table to retrieve cast info.
-- Filters by category to return only acting roles.

SELECT
    t.titleName,
    p.firstName || ' ' || p.lastName AS actorName,
    wo.character AS characterPlayed,
    wo.job,
    t.releaseYear
FROM Title t
JOIN Works_On wo ON t.tconst = wo.tconst
JOIN Person p    ON wo.nconst = p.nconst
WHERE wo.category = 'Acting'
ORDER BY t.releaseYear DESC, t.titleName;


-- =============================================================================
-- QUERY 4: Average rating and total votes by genre
-- =============================================================================
-- Demonstrates multi-table JOINs with aggregation functions (COUNT, AVG, SUM).
-- Uses DISTINCT to avoid double-counting titles in multiple genres.
-- Useful for genre-level analytics and reporting.

SELECT
    g.genreName,
    COUNT(DISTINCT t.tconst) AS numberOfTitles,
    ROUND(AVG(r.averageRating), 2) AS avgGenreRating,
    SUM(r.numVotes) AS totalVotes
FROM Genre g
JOIN Has_Genre hg ON g.genreName = hg.genreName
JOIN Title t      ON hg.tconst = t.tconst
JOIN Rating r     ON t.tconst = r.tconst
GROUP BY g.genreName
ORDER BY avgGenreRating DESC;
