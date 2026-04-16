-- =============================================================================
-- IMDb Movie Database Management System
-- Schema Definition, Triggers, and Sample Data Population
-- Oracle SQL
-- =============================================================================


-- =============================================================================
-- CORE ENTITY TABLES
-- =============================================================================

-- REGION
CREATE TABLE Region (
    regionCode      VARCHAR2(10)   PRIMARY KEY,
    regionName      VARCHAR2(100)  NOT NULL,
    primaryLanguage VARCHAR2(50)
);

-- GENRE
CREATE TABLE Genre (
    genreName   VARCHAR2(50)  PRIMARY KEY,
    description VARCHAR2(255)
);

-- PRODUCTION COMPANY
CREATE TABLE Production_Company (
    companyID    VARCHAR2(10)  PRIMARY KEY,
    companyName  VARCHAR2(255) NOT NULL,
    headquarters VARCHAR2(255),
    website      VARCHAR2(255),
    foundedYear  NUMBER(4)
);

-- PERSON
CREATE TABLE Person (
    nconst    VARCHAR2(10) PRIMARY KEY,
    firstName VARCHAR2(100),
    lastName  VARCHAR2(100),
    birthYear NUMBER(4),
    deathYear NUMBER(4)
);

-- TITLE
CREATE TABLE Title (
    tconst         VARCHAR2(10)  PRIMARY KEY,
    titleName      VARCHAR2(255) NOT NULL,
    runtimeMinutes NUMBER,
    releaseYear    NUMBER(4),
    ageRating      VARCHAR2(10),
    regionCode     VARCHAR2(10),
    CONSTRAINT fk_title_region
        FOREIGN KEY (regionCode)
        REFERENCES Region(regionCode),
    CONSTRAINT ck_title_runtime
        CHECK (runtimeMinutes IS NULL OR runtimeMinutes >= 0)
);

-- EPISODE
CREATE TABLE Episode (
    episodeID     VARCHAR2(10) PRIMARY KEY,
    tconst        VARCHAR2(10) NOT NULL,
    seasonNumber  NUMBER,
    episodeNumber NUMBER,
    episodeTitle  VARCHAR2(255),
    CONSTRAINT fk_episode_title
        FOREIGN KEY (tconst)
        REFERENCES Title(tconst)
);

-- RATING
CREATE TABLE Rating (
    rconst        VARCHAR2(10) PRIMARY KEY,
    averageRating NUMBER(3,1),
    numVotes      NUMBER,
    tconst        VARCHAR2(10) NOT NULL,
    CONSTRAINT fk_rating_title
        FOREIGN KEY (tconst)
        REFERENCES Title(tconst),
    CONSTRAINT ck_rating_range
        CHECK (averageRating BETWEEN 0 AND 10)
);


-- =============================================================================
-- WEAK ENTITY / MULTI-VALUED ATTRIBUTE TABLES
-- =============================================================================

-- PERSONS_PRIMARYPROFESSION (multi-valued attribute)
CREATE TABLE Persons_PrimaryProfession (
    nconst            VARCHAR2(10),
    primaryProfession VARCHAR2(100),
    CONSTRAINT pk_person_primary_prof
        PRIMARY KEY (nconst, primaryProfession),
    CONSTRAINT fk_pp_person
        FOREIGN KEY (nconst)
        REFERENCES Person(nconst)
);

-- PERSONS_KNOWNFORTITLES (multi-valued attribute)
CREATE TABLE Persons_knownForTitles (
    nconst VARCHAR2(10),
    tconst VARCHAR2(10),
    CONSTRAINT pk_person_known_titles
        PRIMARY KEY (nconst, tconst),
    CONSTRAINT fk_pkt_person
        FOREIGN KEY (nconst)
        REFERENCES Person(nconst),
    CONSTRAINT fk_pkt_title
        FOREIGN KEY (tconst)
        REFERENCES Title(tconst)
);


-- =============================================================================
-- RELATIONSHIP TABLES
-- =============================================================================

-- WORKS_ON (Person - Title)
CREATE TABLE Works_On (
    nconst    VARCHAR2(10),
    tconst    VARCHAR2(10),
    job       VARCHAR2(100),
    character VARCHAR2(255),
    category  VARCHAR2(50),
    CONSTRAINT pk_works_on
        PRIMARY KEY (nconst, tconst),
    CONSTRAINT fk_wo_person
        FOREIGN KEY (nconst)
        REFERENCES Person(nconst),
    CONSTRAINT fk_wo_title
        FOREIGN KEY (tconst)
        REFERENCES Title(tconst)
);

-- WRITTEN_BY (Person - Title)
CREATE TABLE Written_By (
    nconst VARCHAR2(10),
    tconst VARCHAR2(10),
    CONSTRAINT pk_written_by
        PRIMARY KEY (nconst, tconst),
    CONSTRAINT fk_wb_person
        FOREIGN KEY (nconst)
        REFERENCES Person(nconst),
    CONSTRAINT fk_wb_title
        FOREIGN KEY (tconst)
        REFERENCES Title(tconst)
);

-- DIRECTED_BY (Person - Title)
CREATE TABLE Directed_By (
    nconst VARCHAR2(10),
    tconst VARCHAR2(10),
    CONSTRAINT pk_directed_by
        PRIMARY KEY (nconst, tconst),
    CONSTRAINT fk_db_person
        FOREIGN KEY (nconst)
        REFERENCES Person(nconst),
    CONSTRAINT fk_db_title
        FOREIGN KEY (tconst)
        REFERENCES Title(tconst)
);

-- PRODUCES (Person - Production_Company - Title)
CREATE TABLE Produces (
    nconst    VARCHAR2(10),
    companyID VARCHAR2(10),
    tconst    VARCHAR2(10),
    CONSTRAINT pk_produces
        PRIMARY KEY (nconst, companyID, tconst),
    CONSTRAINT fk_prod_person
        FOREIGN KEY (nconst)
        REFERENCES Person(nconst),
    CONSTRAINT fk_prod_company
        FOREIGN KEY (companyID)
        REFERENCES Production_Company(companyID),
    CONSTRAINT fk_prod_title
        FOREIGN KEY (tconst)
        REFERENCES Title(tconst)
);

-- HAS_GENRE (Title - Genre)
CREATE TABLE Has_Genre (
    genreName VARCHAR2(50),
    tconst    VARCHAR2(10),
    CONSTRAINT pk_has_genre
        PRIMARY KEY (genreName, tconst),
    CONSTRAINT fk_hg_genre
        FOREIGN KEY (genreName)
        REFERENCES Genre(genreName),
    CONSTRAINT fk_hg_title
        FOREIGN KEY (tconst)
        REFERENCES Title(tconst)
);

-- HAS_RATING (Title - Rating)
CREATE TABLE Has_Rating (
    rconst VARCHAR2(10),
    tconst VARCHAR2(10),
    CONSTRAINT pk_has_rating
        PRIMARY KEY (rconst, tconst),
    CONSTRAINT fk_hr_rating
        FOREIGN KEY (rconst)
        REFERENCES Rating(rconst),
    CONSTRAINT fk_hr_title
        FOREIGN KEY (tconst)
        REFERENCES Title(tconst)
);


-- =============================================================================
-- TRIGGERS
-- =============================================================================

-- Automatically inserts into Has_Rating when a new Rating is inserted
CREATE OR REPLACE TRIGGER trg_insert_has_rating
AFTER INSERT ON Rating
FOR EACH ROW
BEGIN
    INSERT INTO Has_Rating (rconst, tconst)
    VALUES (:NEW.rconst, :NEW.tconst);
END;
/


-- =============================================================================
-- DATA POPULATION
-- =============================================================================

-- REGION DATA
INSERT INTO Region (regionCode, regionName, primaryLanguage) VALUES ('US', 'United States', 'English');
INSERT INTO Region (regionCode, regionName, primaryLanguage) VALUES ('UAE', 'United Arab Emirates', 'Arabic');
INSERT INTO Region (regionCode, regionName, primaryLanguage) VALUES ('KR', 'South Korea', 'Korean');
INSERT INTO Region (regionCode, regionName, primaryLanguage) VALUES ('TR', 'Turkey', 'Turkish');
COMMIT;

-- GENRE DATA
INSERT INTO Genre (genreName, description) VALUES ('Action', 'High-energy films with physical stunts and chase sequences');
INSERT INTO Genre (genreName, description) VALUES ('Drama', 'Serious narrative focusing on character development');
INSERT INTO Genre (genreName, description) VALUES ('Comedy', 'Entertainment designed to make the audience laugh');
INSERT INTO Genre (genreName, description) VALUES ('Sci-Fi', 'Science fiction exploring futuristic concepts');
COMMIT;

-- PRODUCTION COMPANY DATA
INSERT INTO Production_Company (companyID, companyName, headquarters, website, foundedYear) VALUES ('PC001', 'Warner Bros', 'Burbank, California', 'www.warnerbros.com', 1923);
INSERT INTO Production_Company (companyID, companyName, headquarters, website, foundedYear) VALUES ('PC002', 'Universal Pictures', 'Universal City, California', 'www.universalpictures.com', 1912);
INSERT INTO Production_Company (companyID, companyName, headquarters, website, foundedYear) VALUES ('PC003', 'Netflix Studios', 'Los Gatos, California', 'www.netflix.com', 1997);
INSERT INTO Production_Company (companyID, companyName, headquarters, website, foundedYear) VALUES ('PC004', 'A24', 'New York City, New York', 'www.a24films.com', 2012);
INSERT INTO Production_Company (companyID, companyName, headquarters, website, foundedYear) VALUES ('PC005', 'Legendary Entertainment', 'Burbank, California', 'www.legendary.com', 2000);
COMMIT;

-- PERSON DATA
INSERT INTO Person (nconst, firstName, lastName, birthYear, deathYear) VALUES ('NM001', 'Christopher', 'Nolan', 1970, NULL);
INSERT INTO Person (nconst, firstName, lastName, birthYear, deathYear) VALUES ('NM002', 'Cillian', 'Murphy', 1976, NULL);
INSERT INTO Person (nconst, firstName, lastName, birthYear, deathYear) VALUES ('NM003', 'Greta', 'Gerwig', 1983, NULL);
INSERT INTO Person (nconst, firstName, lastName, birthYear, deathYear) VALUES ('NM004', 'Margot', 'Robbie', 1990, NULL);
INSERT INTO Person (nconst, firstName, lastName, birthYear, deathYear) VALUES ('NM005', 'Pedro', 'Pascal', 1975, NULL);
INSERT INTO Person (nconst, firstName, lastName, birthYear, deathYear) VALUES ('NM006', 'Emily', 'Blunt', 1983, NULL);
INSERT INTO Person (nconst, firstName, lastName, birthYear, deathYear) VALUES ('NM007', 'Ryan', 'Gosling', 1980, NULL);
INSERT INTO Person (nconst, firstName, lastName, birthYear, deathYear) VALUES ('NM008', 'Denis', 'Villeneuve', 1967, NULL);
INSERT INTO Person (nconst, firstName, lastName, birthYear, deathYear) VALUES ('NM009', 'Timothee', 'Chalamet', 1995, NULL);
INSERT INTO Person (nconst, firstName, lastName, birthYear, deathYear) VALUES ('NM010', 'Zendaya', 'Coleman', 1996, NULL);
COMMIT;

-- PERSONS_PRIMARYPROFESSION DATA
INSERT INTO Persons_PrimaryProfession (nconst, primaryProfession) VALUES ('NM001', 'Director');
INSERT INTO Persons_PrimaryProfession (nconst, primaryProfession) VALUES ('NM001', 'Writer');
INSERT INTO Persons_PrimaryProfession (nconst, primaryProfession) VALUES ('NM002', 'Actor');
INSERT INTO Persons_PrimaryProfession (nconst, primaryProfession) VALUES ('NM003', 'Director');
INSERT INTO Persons_PrimaryProfession (nconst, primaryProfession) VALUES ('NM003', 'Writer');
INSERT INTO Persons_PrimaryProfession (nconst, primaryProfession) VALUES ('NM004', 'Actor');
INSERT INTO Persons_PrimaryProfession (nconst, primaryProfession) VALUES ('NM004', 'Producer');
INSERT INTO Persons_PrimaryProfession (nconst, primaryProfession) VALUES ('NM005', 'Actor');
INSERT INTO Persons_PrimaryProfession (nconst, primaryProfession) VALUES ('NM006', 'Actor');
INSERT INTO Persons_PrimaryProfession (nconst, primaryProfession) VALUES ('NM007', 'Actor');
INSERT INTO Persons_PrimaryProfession (nconst, primaryProfession) VALUES ('NM007', 'Producer');
INSERT INTO Persons_PrimaryProfession (nconst, primaryProfession) VALUES ('NM008', 'Director');
INSERT INTO Persons_PrimaryProfession (nconst, primaryProfession) VALUES ('NM008', 'Writer');
INSERT INTO Persons_PrimaryProfession (nconst, primaryProfession) VALUES ('NM009', 'Actor');
INSERT INTO Persons_PrimaryProfession (nconst, primaryProfession) VALUES ('NM010', 'Actor');
COMMIT;

-- TITLE DATA
INSERT INTO Title (tconst, titleName, runtimeMinutes, releaseYear, ageRating, regionCode) VALUES ('TT001', 'Oppenheimer', 180, 2023, 'R', 'US');
INSERT INTO Title (tconst, titleName, runtimeMinutes, releaseYear, ageRating, regionCode) VALUES ('TT002', 'Barbie', 114, 2023, 'PG-13', 'US');
INSERT INTO Title (tconst, titleName, runtimeMinutes, releaseYear, ageRating, regionCode) VALUES ('TT003', 'Squid Game', 60, 2021, 'TV-MA', 'KR');
INSERT INTO Title (tconst, titleName, runtimeMinutes, releaseYear, ageRating, regionCode) VALUES ('TT004', 'The Last of Us', 55, 2023, 'TV-MA', 'US');
INSERT INTO Title (tconst, titleName, runtimeMinutes, releaseYear, ageRating, regionCode) VALUES ('TT005', 'Dune: Part Two', 166, 2024, 'PG-13', 'US');
INSERT INTO Title (tconst, titleName, runtimeMinutes, releaseYear, ageRating, regionCode) VALUES ('TT006', 'Inception', 148, 2010, 'PG-13', 'US');
INSERT INTO Title (tconst, titleName, runtimeMinutes, releaseYear, ageRating, regionCode) VALUES ('TT007', 'The Dark Knight', 152, 2008, 'PG-13', 'US');
INSERT INTO Title (tconst, titleName, runtimeMinutes, releaseYear, ageRating, regionCode) VALUES ('TT008', 'Stranger Things', 50, 2016, 'TV-14', 'US');
COMMIT;

-- RATING DATA
INSERT INTO Rating (rconst, averageRating, numVotes, tconst) VALUES ('R001', 8.5, 650000, 'TT001');
INSERT INTO Rating (rconst, averageRating, numVotes, tconst) VALUES ('R002', 7.0, 450000, 'TT002');
INSERT INTO Rating (rconst, averageRating, numVotes, tconst) VALUES ('R003', 8.0, 580000, 'TT003');
INSERT INTO Rating (rconst, averageRating, numVotes, tconst) VALUES ('R004', 8.8, 720000, 'TT004');
INSERT INTO Rating (rconst, averageRating, numVotes, tconst) VALUES ('R005', 8.7, 520000, 'TT005');
INSERT INTO Rating (rconst, averageRating, numVotes, tconst) VALUES ('R006', 8.8, 2400000, 'TT006');
INSERT INTO Rating (rconst, averageRating, numVotes, tconst) VALUES ('R007', 9.0, 2800000, 'TT007');
INSERT INTO Rating (rconst, averageRating, numVotes, tconst) VALUES ('R008', 8.7, 1200000, 'TT008');
COMMIT;

-- EPISODE DATA (TV Series Only)
INSERT INTO Episode (episodeID, tconst, seasonNumber, episodeNumber, episodeTitle) VALUES ('EP001', 'TT003', 1, 1, 'Red Light, Green Light');
INSERT INTO Episode (episodeID, tconst, seasonNumber, episodeNumber, episodeTitle) VALUES ('EP002', 'TT003', 1, 2, 'Hell');
INSERT INTO Episode (episodeID, tconst, seasonNumber, episodeNumber, episodeTitle) VALUES ('EP003', 'TT003', 1, 3, 'The Man with the Umbrella');
INSERT INTO Episode (episodeID, tconst, seasonNumber, episodeNumber, episodeTitle) VALUES ('EP004', 'TT004', 1, 1, 'When You''re Lost in the Darkness');
INSERT INTO Episode (episodeID, tconst, seasonNumber, episodeNumber, episodeTitle) VALUES ('EP005', 'TT004', 1, 2, 'Infected');
INSERT INTO Episode (episodeID, tconst, seasonNumber, episodeNumber, episodeTitle) VALUES ('EP006', 'TT008', 1, 1, 'Chapter One: The Vanishing of Will Byers');
INSERT INTO Episode (episodeID, tconst, seasonNumber, episodeNumber, episodeTitle) VALUES ('EP007', 'TT008', 1, 2, 'Chapter Two: The Weirdo on Maple Street');
INSERT INTO Episode (episodeID, tconst, seasonNumber, episodeNumber, episodeTitle) VALUES ('EP008', 'TT008', 2, 1, 'Chapter One: MADMAX');
COMMIT;

-- PERSONS_KNOWNFORTITLES DATA
INSERT INTO Persons_knownForTitles (nconst, tconst) VALUES ('NM001', 'TT001');
INSERT INTO Persons_knownForTitles (nconst, tconst) VALUES ('NM001', 'TT006');
INSERT INTO Persons_knownForTitles (nconst, tconst) VALUES ('NM001', 'TT007');
INSERT INTO Persons_knownForTitles (nconst, tconst) VALUES ('NM002', 'TT001');
INSERT INTO Persons_knownForTitles (nconst, tconst) VALUES ('NM003', 'TT002');
INSERT INTO Persons_knownForTitles (nconst, tconst) VALUES ('NM004', 'TT002');
INSERT INTO Persons_knownForTitles (nconst, tconst) VALUES ('NM005', 'TT004');
INSERT INTO Persons_knownForTitles (nconst, tconst) VALUES ('NM006', 'TT001');
INSERT INTO Persons_knownForTitles (nconst, tconst) VALUES ('NM007', 'TT002');
INSERT INTO Persons_knownForTitles (nconst, tconst) VALUES ('NM008', 'TT005');
INSERT INTO Persons_knownForTitles (nconst, tconst) VALUES ('NM009', 'TT005');
INSERT INTO Persons_knownForTitles (nconst, tconst) VALUES ('NM010', 'TT005');
COMMIT;

-- WORKS_ON DATA (Acting roles with characters)
INSERT INTO Works_On (nconst, tconst, job, character, category) VALUES ('NM002', 'TT001', 'Lead Actor', 'J. Robert Oppenheimer', 'Acting');
INSERT INTO Works_On (nconst, tconst, job, character, category) VALUES ('NM004', 'TT002', 'Lead Actor', 'Barbie', 'Acting');
INSERT INTO Works_On (nconst, tconst, job, character, category) VALUES ('NM005', 'TT004', 'Lead Actor', 'Joel Miller', 'Acting');
INSERT INTO Works_On (nconst, tconst, job, character, category) VALUES ('NM006', 'TT001', 'Supporting Actor', 'Kitty Oppenheimer', 'Acting');
INSERT INTO Works_On (nconst, tconst, job, character, category) VALUES ('NM007', 'TT002', 'Lead Actor', 'Ken', 'Acting');
INSERT INTO Works_On (nconst, tconst, job, character, category) VALUES ('NM009', 'TT005', 'Lead Actor', 'Paul Atreides', 'Acting');
INSERT INTO Works_On (nconst, tconst, job, character, category) VALUES ('NM010', 'TT005', 'Lead Actor', 'Chani', 'Acting');
COMMIT;

-- DIRECTED_BY DATA
INSERT INTO Directed_By (nconst, tconst) VALUES ('NM001', 'TT001');
INSERT INTO Directed_By (nconst, tconst) VALUES ('NM001', 'TT006');
INSERT INTO Directed_By (nconst, tconst) VALUES ('NM001', 'TT007');
INSERT INTO Directed_By (nconst, tconst) VALUES ('NM003', 'TT002');
INSERT INTO Directed_By (nconst, tconst) VALUES ('NM008', 'TT005');
COMMIT;

-- WRITTEN_BY DATA
INSERT INTO Written_By (nconst, tconst) VALUES ('NM001', 'TT001');
INSERT INTO Written_By (nconst, tconst) VALUES ('NM001', 'TT006');
INSERT INTO Written_By (nconst, tconst) VALUES ('NM001', 'TT007');
INSERT INTO Written_By (nconst, tconst) VALUES ('NM003', 'TT002');
INSERT INTO Written_By (nconst, tconst) VALUES ('NM008', 'TT005');
COMMIT;

-- PRODUCES DATA (Ternary: Person - Company - Title)
INSERT INTO Produces (nconst, companyID, tconst) VALUES ('NM001', 'PC001', 'TT001');
INSERT INTO Produces (nconst, companyID, tconst) VALUES ('NM001', 'PC001', 'TT006');
INSERT INTO Produces (nconst, companyID, tconst) VALUES ('NM001', 'PC001', 'TT007');
INSERT INTO Produces (nconst, companyID, tconst) VALUES ('NM003', 'PC001', 'TT002');
INSERT INTO Produces (nconst, companyID, tconst) VALUES ('NM004', 'PC004', 'TT002');
INSERT INTO Produces (nconst, companyID, tconst) VALUES ('NM008', 'PC001', 'TT005');
INSERT INTO Produces (nconst, companyID, tconst) VALUES ('NM008', 'PC005', 'TT005');
INSERT INTO Produces (nconst, companyID, tconst) VALUES ('NM007', 'PC003', 'TT008');
COMMIT;

-- HAS_GENRE DATA (Title - Genre relationships)
INSERT INTO Has_Genre (genreName, tconst) VALUES ('Drama', 'TT001');
INSERT INTO Has_Genre (genreName, tconst) VALUES ('Action', 'TT001');
INSERT INTO Has_Genre (genreName, tconst) VALUES ('Comedy', 'TT002');
INSERT INTO Has_Genre (genreName, tconst) VALUES ('Drama', 'TT003');
INSERT INTO Has_Genre (genreName, tconst) VALUES ('Action', 'TT004');
INSERT INTO Has_Genre (genreName, tconst) VALUES ('Drama', 'TT004');
INSERT INTO Has_Genre (genreName, tconst) VALUES ('Sci-Fi', 'TT005');
INSERT INTO Has_Genre (genreName, tconst) VALUES ('Action', 'TT005');
INSERT INTO Has_Genre (genreName, tconst) VALUES ('Sci-Fi', 'TT006');
INSERT INTO Has_Genre (genreName, tconst) VALUES ('Action', 'TT006');
INSERT INTO Has_Genre (genreName, tconst) VALUES ('Action', 'TT007');
INSERT INTO Has_Genre (genreName, tconst) VALUES ('Drama', 'TT007');
INSERT INTO Has_Genre (genreName, tconst) VALUES ('Sci-Fi', 'TT008');
INSERT INTO Has_Genre (genreName, tconst) VALUES ('Drama', 'TT008');
COMMIT;
