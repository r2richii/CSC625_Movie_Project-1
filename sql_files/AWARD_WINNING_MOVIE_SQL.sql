CREATE DATABASE AWARD_WINNING_MOVIES;
GO

USE AWARD_WINNING_MOVIES;
GO

-- CREATE TABLES
--------------------------------- ACTOR AWARDS
CREATE TABLE [dbo].[ACTOR_AWARDS](
	[ACTOR_AWARD_ID] [int] NOT NULL,
	[ACTOR_AWARD_NAME] [varchar](50) NULL,
	[ACTOR_AWARD_YEAR] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACTOR_AWARDS] ADD PRIMARY KEY CLUSTERED 
(
	[ACTOR_AWARD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

--------------------------------- ACTOR
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ACTOR](
	[ACTOR_ID] [int] NOT NULL,
	[ACTOR_NAME] [varchar](50) NULL,
	[ACTOR_AWARD_ID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACTOR] ADD PRIMARY KEY CLUSTERED 
(
	[ACTOR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACTOR]  WITH CHECK ADD FOREIGN KEY([ACTOR_AWARD_ID])
REFERENCES [dbo].[ACTOR_AWARDS] ([ACTOR_AWARD_ID])
GO

--------------------------------- GENRE
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GENRE](
	[GENRE_ID] [int] NOT NULL,
	[GENRE_NAME] [varchar](50) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GENRE] ADD PRIMARY KEY CLUSTERED 
(
	[GENRE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------- MOVIE
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MOVIE](
	[MOVIE_ID] [int] NOT NULL,
	[TITLE] [varchar](50) NULL,
	[DESCRIPTION] [varchar](50) NULL,
	[GENRE_ID] [int] NULL,
	[RELEASE_DATE] [date] NULL,
	[RATING] [decimal](5, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MOVIE] ADD PRIMARY KEY CLUSTERED 
(
	[MOVIE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MOVIE]  WITH NOCHECK ADD FOREIGN KEY([GENRE_ID])
REFERENCES [dbo].[GENRE] ([GENRE_ID])
GO
drop table movie_Database_log;GO
-- MOVIE LOG
CREATE TABLE MOVIE_DATABASE_LOG(
    LOG_ID VARCHAR(36),
    ACTOR_ID INT NULL,
    MOVIE_ID INT NULL,
    GENRE_ID INT NULL,
    USER_NAME VARCHAR(50) NULL,
    LOG_DESCRIPTION VARCHAR(200) NULL,
    TIME_STAMP DATETIME
);
GO

-- USER LOGIN
CREATE TABLE USER_LOGIN(
    ENTRY_ID INT IDENTITY(1,1) PRIMARY KEY,
    USERNAME VARCHAR(50),
    PASSWORD VARCHAR(100)
);
GO

-------------------------------------------------------------------------
-------------------------------------------------------------------------
--------------------- STORED PROCEDURES
-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- SELECT ALL ACTORS
CREATE PROCEDURE sp_select_all_actors
AS
BEGIN
SELECT * FROM ACTOR
END
GO

-- SELECT SINGLE ACTOR
CREATE PROCEDURE sp_select_single_actor
    @ACTOR_ID INT
AS
BEGIN
    SELECT * FROM ACTOR WHERE ACTOR_ID = @ACTOR_ID
END
GO

-- INSERT ACTOR
CREATE PROCEDURE sp_insert_actor
    @ACTOR_ID INT,
    @ACTOR_NAME VARCHAR(50),
    @ACTOR_AWARD_ID INT
AS
BEGIN
    INSERT INTO ACTOR
    (ACTOR_ID,ACTOR_NAME,ACTOR_AWARD_ID)
    VALUES
    (@ACTOR_ID,@ACTOR_NAME,@ACTOR_AWARD_ID)
END
GO

-- UPDATE ACTOR
CREATE PROCEDURE sp_update_actor
    @ACTOR_ID INT,
    @ACTOR_NAME VARCHAR(50),
    @ACTOR_AWARD_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = 'UPDATE ACTOR SET ';

    IF @ACTOR_NAME IS NOT NULL
        SET @SQL = @SQL + 'ACTOR_NAME = '''+UPPER(@ACTOR_NAME)+''', ';
    
    IF @ACTOR_AWARD_ID IS NOT NULL  
        SET @SQL = @SQL + 'ACTOR_AWARD_ID = '+CONVERT(NVARCHAR(MAX),@ACTOR_AWARD_ID)+', ';
    
    SET @SQL = LEFT(@SQL, LEN(@SQL)-1)+' WHERE ACTOR_ID = '+CONVERT(NVARCHAR(MAX),@ACTOR_ID);
    EXEC sp_executesql @SQL
END
GO

-- DELETE ACTOR
CREATE PROCEDURE sp_delete_actor
    @ACTOR_ID INT
AS
BEGIN
    DELETE FROM ACTOR
    WHERE ACTOR_ID = @ACTOR_ID
END
GO

-- SELECT ALL MOVIES
CREATE PROCEDURE sp_select_all_movies
AS
BEGIN
    SELECT M.MOVIE_ID,M.TITLE,M.DESCRIPTION,G.GENRE_NAME,M.RELEASE_DATE,M.RATING
    FROM MOVIE M
    INNER JOIN GENRE G ON G.GENRE_ID=M.GENRE_ID 
END 
GO

-- SELECT MOVIE
CREATE PROCEDURE sp_select_movie
    @MOVIE_ID INT
AS
BEGIN
    SELECT M.MOVIE_ID,M.TITLE,M.DESCRIPTION,M.GENRE_ID,M.RELEASE_DATE,M.RATING
    FROM MOVIE M
    INNER JOIN GENRE G ON G.GENRE_ID=M.GENRE_ID
    WHERE M.MOVIE_ID = @MOVIE_ID
END
GO

-- INSERT MOVIE
CREATE PROCEDURE sp_insert_movie
    @MOVIE_ID INT,
    @TITLE VARCHAR(50),
    @DESCRIPTION VARCHAR(50),
    @GENRE_ID INT,
    @RELEASE_DATE DATE,
    @RATING DECIMAL(5,2)
AS
BEGIN
    INSERT INTO MOVIE
    (MOVIE_ID,TITLE,DESCRIPTION,GENRE_ID,RELEASE_DATE,RATING)
    VALUES
    (@MOVIE_ID,@TITLE,@DESCRIPTION,@GENRE_ID,@RELEASE_DATE,@RATING)
END
GO

-- DELETE MOVIE
CREATE PROCEDURE sp_delete_movie
    @MOVIE_ID INT
AS
BEGIN
    DELETE FROM MOVIE WHERE MOVIE_ID=@MOVIE_ID
END
GO

-- UPDATE MOVIE
CREATE PROCEDURE sp_update_movie
    @MOVIE_ID INT,
    @TITLE VARCHAR(50),
    @DESCRIPTION VARCHAR(200),
    @GENRE_ID INT,
    @RELEASE_DATE DATE,
    @RATING DECIMAL(5,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = 'UPDATE MOVIE SET ';
    
    IF @TITLE IS NOT NULL
        SET @SQL = @SQL + 'TITLE = '''+UPPER(@TITLE)+''', ';

    IF @DESCRIPTION IS NOT NULL
        SET @SQL = @SQL + 'DESCRIPTION = '''+UPPER(@DESCRIPTION)+''', ';
    
    IF @GENRE_ID IS NOT NULL
        SET @SQL = @SQL + 'GENRE_ID = '+CONVERT(NVARCHAR(MAX),@GENRE_ID)+', ';
   
    IF @RELEASE_DATE IS NOT NULL
        SET @SQL = @SQL + 'RELEASE_DATE = '''+CONVERT(NVARCHAR(MAX),@RELEASE_DATE,23)+''', ';
   
    IF @RATING IS NOT NULL
        SET @SQL = @SQL + 'RATING = '+CONVERT(NVARCHAR(MAX),@RATING,2)+', ';
   
    SET @SQL = LEFT(@SQL, LEN(@SQL)-1)+' WHERE MOVIE_ID = '+CONVERT(NVARCHAR(MAX),@MOVIE_ID);

    EXEC sp_executesql @SQL;
    END
    GO

-------------------------------------------------------------------------
-------------------------------------------------------------------------
--------------------- TRIGGERS
-------------------------------------------------------------------------
-------------------------------------------------------------------------
----- MOVIE TRIGGER
CREATE TRIGGER trg_movie_log
ON MOVIE
AFTER INSERT, DELETE, UPDATE
AS
BEGIN

    DECLARE @ID VARCHAR(36)
    DECLARE @MOVIE_ID INT
    DECLARE @LOG_DESCRIPTION VARCHAR(200)
    DECLARE @TS DATETIME
    DECLARE @MOVIE_TITLE VARCHAR(50)

    -- INSERT SECTION
    IF EXISTS(SELECT * FROM inserted)
    BEGIN
        SET @ID = CONVERT(VARCHAR(36), NEWID())
        SET @TS = GETDATE()
        SELECT @MOVIE_ID = MOVIE_ID, @MOVIE_TITLE = TITLE FROM inserted;
        SET @LOG_DESCRIPTION = 'MOVIE NAME: '+@MOVIE_TITLE+', HAS BEEN INSERTED'

        INSERT INTO MOVIE_DATABASE_LOG
        (LOG_ID,ACTOR_ID,MOVIE_ID,GENRE_ID,[USER_NAME],LOG_DESCRIPTION,TIME_STAMP)
        SELECT @ID,NULL,@MOVIE_ID,NULL,NULL,@LOG_DESCRIPTION,@TS 
        FROM inserted
    END

    -- DELETE SECTION
    IF EXISTS(SELECT * FROM deleted)
    BEGIN
        SET @ID = CONVERT(VARCHAR(36), NEWID())
        SET @TS = GETDATE()
        SELECT @MOVIE_ID = MOVIE_ID, @MOVIE_TITLE = TITLE FROM deleted;
        SET @LOG_DESCRIPTION = 'MOVIE DELETED: '+@MOVIE_TITLE+' HAS BEEN DELETED'

        INSERT INTO MOVIE_DATABASE_LOG
        (LOG_ID,ACTOR_ID,MOVIE_ID,GENRE_ID,[USER_NAME],LOG_DESCRIPTION,TIME_STAMP)
        SELECT @ID,NULL,@MOVIE_ID,NULL,NULL,@LOG_DESCRIPTION,@TS 
        FROM deleted
    END
END
GO

----- ACTOR TRIGGER
CREATE TRIGGER trg_actor_log
ON ACTOR
AFTER INSERT, DELETE, UPDATE
AS
BEGIN

    DECLARE @ID VARCHAR(36)
    DECLARE @ACTOR_ID INT
    DECLARE @LOG_DESCRIPTION VARCHAR(200)
    DECLARE @TS DATETIME
    DECLARE @ACTOR_NAME VARCHAR(50)

    -- INSERT SECTION
    IF EXISTS(SELECT * FROM inserted)
    BEGIN
        SET @ID = CONVERT(VARCHAR(36), NEWID())
        SET @TS = GETDATE()
        SELECT @ACTOR_ID = ACTOR_ID, @ACTOR_NAME = ACTOR_NAME FROM inserted;
        SET @LOG_DESCRIPTION = 'ACTOR NAME: '+@ACTOR_NAME+', HAS BEEN INSERTED'

        INSERT INTO MOVIE_DATABASE_LOG
        (LOG_ID,ACTOR_ID,MOVIE_ID,GENRE_ID,[USER_NAME],LOG_DESCRIPTION,TIME_STAMP)
        SELECT @ID,@ACTOR_ID,NULL,NULL,NULL,@LOG_DESCRIPTION,@TS 
        FROM inserted
    END

    -- DELETE SECTION
    IF EXISTS(SELECT * FROM deleted)
    BEGIN
        SET @ID = CONVERT(VARCHAR(36), NEWID())
        SET @TS = GETDATE()
        SELECT @ACTOR_ID = ACTOR_ID, @ACTOR_NAME = ACTOR_NAME FROM deleted;
        SET @LOG_DESCRIPTION = 'ACTOR DELETED: '+@ACTOR_NAME+' HAS BEEN DELETED'

        INSERT INTO MOVIE_DATABASE_LOG
        (LOG_ID,ACTOR_ID,MOVIE_ID,GENRE_ID,[USER_NAME],LOG_DESCRIPTION,TIME_STAMP)
        SELECT @ID,@ACTOR_ID,NULL,NULL,NULL,@LOG_DESCRIPTION,@TS 
        FROM deleted
    END
END
GO

----- USER_LOGIN TRIGGER
CREATE TRIGGER trg_login_log
ON USER_LOGIN
AFTER INSERT, DELETE, UPDATE
AS
BEGIN

    DECLARE @ID VARCHAR(36)
    DECLARE @ENTRY_ID INT
    DECLARE @LOG_DESCRIPTION VARCHAR(200)
    DECLARE @TS DATETIME
    DECLARE @USERNAME VARCHAR(50)

    -- INSERT SECTION
    IF EXISTS(SELECT * FROM inserted)
    BEGIN
        SET @ID = CONVERT(VARCHAR(36), NEWID())
        SET @TS = GETDATE()
        SELECT @ENTRY_ID = ENTRY_ID, @USERNAME = USERNAME FROM inserted;
        SET @LOG_DESCRIPTION = 'USER NAME: '+@USERNAME+', HAS BEEN INSERTED'

        INSERT INTO MOVIE_DATABASE_LOG
        (LOG_ID,ACTOR_ID,MOVIE_ID,GENRE_ID,[USER_NAME],LOG_DESCRIPTION,TIME_STAMP)
        SELECT @ID,NULL,NULL,NULL,NULL,@LOG_DESCRIPTION,@TS 
        FROM inserted
    END

    -- DELETE SECTION
    IF EXISTS(SELECT * FROM deleted)
    BEGIN
        SET @ID = CONVERT(VARCHAR(36), NEWID())
        SET @TS = GETDATE()
        SELECT @ENTRY_ID = ENTRY_ID, @USERNAME = USERNAME FROM deleted;
        SET @LOG_DESCRIPTION = 'USER NAME: '+@USERNAME+', HAS BEEN DELETED'

        INSERT INTO MOVIE_DATABASE_LOG
        (LOG_ID,ACTOR_ID,MOVIE_ID,GENRE_ID,[USER_NAME],LOG_DESCRIPTION,TIME_STAMP)
        SELECT @ID,NULL,NULL,NULL,NULL,@LOG_DESCRIPTION,@TS 
        FROM deleted
    END
END
GO

----- GENRE TRIGGER
CREATE TRIGGER trg_genre_log
ON GENRE
AFTER INSERT, DELETE, UPDATE
AS
BEGIN

    DECLARE @ID VARCHAR(36)
    DECLARE @GENRE_ID INT
    DECLARE @LOG_DESCRIPTION VARCHAR(200)
    DECLARE @TS DATETIME
    DECLARE @GENRE_NAME VARCHAR(50)

    -- INSERT SECTION
    IF EXISTS(SELECT * FROM inserted)
    BEGIN
        SET @ID = CONVERT(VARCHAR(36), NEWID())
        SET @TS = GETDATE()
        SELECT @GENRE_ID = GENRE_ID, @GENRE_NAME = GENRE_NAME FROM inserted;
        SET @LOG_DESCRIPTION = 'GENRE NAME: '+@GENRE_NAME+' HAS BEEN INSERTED';

        INSERT INTO MOVIE_DATABASE_LOG
        (LOG_ID,ACTOR_ID,MOVIE_ID,GENRE_ID,[USER_NAME],LOG_DESCRIPTION,TIME_STAMP)
        SELECT @ID,NULL,NULL,@GENRE_ID,NULL,@LOG_DESCRIPTION,@TS 
        FROM inserted
    END

    -- DELETE SECTION
    IF EXISTS(SELECT * FROM deleted)
    BEGIN
        SET @ID = CONVERT(VARCHAR(36), NEWID())
        SET @TS = GETDATE()
        SELECT @GENRE_ID = GENRE_ID, @GENRE_NAME = GENRE_NAME FROM deleted;
        SET @LOG_DESCRIPTION = 'GENRE NAME: '+@GENRE_NAME+' HAS BEEN DELETED';

        INSERT INTO MOVIE_DATABASE_LOG
        (LOG_ID,ACTOR_ID,MOVIE_ID,GENRE_ID,[USER_NAME],LOG_DESCRIPTION,TIME_STAMP)
        SELECT @ID,NULL,NULL,@GENRE_ID,NULL,@LOG_DESCRIPTION,@TS 
        FROM deleted
    END
END
GO
-------------------------------------------------------------------------
-------------------------------------------------------------------------
--------------------- INSERT STATEMENTS
-------------------------------------------------------------------------
-------------------------------------------------------------------------

---------------------------------------------------------- GENRE

INSERT INTO GENRE
(GENRE_ID,GENRE_NAME)
VALUES
(1001,'ACTION/ADVENTURE/COMEDY');
GO
INSERT INTO GENRE
(GENRE_ID, GENRE_NAME)
VALUES
(1013,'BIOGRAPHY/DRAMA/HISTORY');
GO
INSERT INTO GENRE
(GENRE_ID, GENRE_NAME)
VALUES
(1014,'DRAMA/THRILLER/WAR');
GO
INSERT INTO GENRE
(GENRE_ID, GENRE_NAME)
VALUES
(1015,'CRIME/DRAMA/ROMANCE');
GO
INSERT INTO GENRE
(GENRE_ID, GENRE_NAME)
VALUES
(1016,'CRIME/DRAMA/THRILLER');
GO
INSERT INTO GENRE
(GENRE_ID, GENRE_NAME)
VALUES
(1017,'CRIME/DRAMA/THRILLER');
GO
SELECT * FROM MOVIE;GO
SELECT * FROM MOVIE_DATABASE_LOG;GO
---------------------------------------------------------- MOVIE
INSERT INTO MOVIE
(MOVIE_ID,TITLE,[DESCRIPTION],GENRE_ID,RELEASE_DATE,RATING)
VALUES
(2013,'THE_KINGS_SPEECH','THE STORY OF KING GEORGE VI',1013,'2010-09-06','0.94');
GO
INSERT INTO MOVIE
(MOVIE_ID,TITLE,[DESCRIPTION],GENRE_ID,RELEASE_DATE,RATING)
VALUES
(2014,'THE_HURT_LOCKER','DURING THE IRAQ WAR, A SERGEANT',1014,'2009-06-26','0.97');
GO
INSERT INTO MOVIE
(MOVIE_ID,TITLE,[DESCRIPTION],GENRE_ID,RELEASE_DATE,RATING)
VALUES
(2015,'SLUMDOG_MILLIONAIRE','A MUMBAI TEENAGER REFLECTS ON HIS LIFE ',1015,'2008-11-12','0.91');
GO
INSERT INTO MOVIE
(MOVIE_ID,TITLE,[DESCRIPTION],GENRE_ID,RELEASE_DATE,RATING)
VALUES
(2016,'NO_COUNTRY_FOR_OLD_MEN','VIOLENCE AND MAYHEM ENSUE AFTER A HUNTER ',1016,'2007-11-21','0.93');
GO
INSERT INTO MOVIE
(MOVIE_ID,TITLE,[DESCRIPTION],GENRE_ID,RELEASE_DATE,RATING)
VALUES
(2017,'THE_DEPARTED','AN UNDERCOVER COP AND A MOLE ',1017,'2006-10-06','0.91');

---------------------------------------------------------- ACTOR
INSERT INTO ACTOR (ACTOR_ID, ACTOR_NAME, ACTOR_AWARD_ID)
VALUES
(1, 'Colin Firth', 1),
(2, 'Tom Hooper', 2),
(3, 'David Seidler', 3),
(4, 'Kathryn Bigelow', 4),
(5, 'Mark Boal',5),
(6, 'Bob Murawski', 6),
(7, 'Paul N.J. Ottosson',7),
(8, 'Christian Colson', 8),
(9, 'Danny Boyle', 9),
(10, 'Simon Beaufoy', 10),
(11, 'Anthony Dod Mantle', 11),
(12, 'Chris Dickens', 12),
(13, 'A.R Rahman', 13),
(14, 'Ian Tapp', 14),
(15, 'Javier Bardem', 15),
(16, 'Ethan Coen',16),
(17, 'Joel Coen',17),
(18, 'Graham King', 18),
(19,'Martin Scorsese', 19),
(20, 'William Monahan', 20),
(21, 'Thelma Schoonmaker',21);
GO

---------------------------------------------------------- ACTOR AWARDS
INSERT INTO ACTOR_AWARDS (ACTOR_AWARD_ID, ACTOR_AWARD_NAME, ACTOR_AWARD_YEAR)
VALUES
(1, 'Best Performance by an Actor in a Leading Role', 2011),
(2, 'Best Achievement in Directing', 2011),
(3, 'Best Writing', 2011),
(4, 'Best Achievement in Directing', 2010),
(5, 'Best Writing', 2010),
(6, 'Best Achievement in Film Editing', 2010),
(7, 'Best Achievement in Sound Editing', 2010),
(8, 'Best Motion Picture of the Year', 2009),
(9, 'Best Achievement in Directing', 2009),
(10, 'Best Writing', 2009),
(11, 'Best Achievement in Cinematography', 2009),
(12, 'Best Achievement in Film Editing', 2009),
(13, 'Best Achievement in Music Written for Motion Pictures, Original Song', 2009),
(14, 'Best Achievement in Sound Mixing', 2009),
(15, 'Best Performance by an Actor in a Supporting Role',2008),
(16, 'Best Achievement in Directing', 2008),
(17, 'Best Writing', 2008),
(18, 'Best Motion Picture of the Year', 2007),
(19, 'Best Achievement in Directing', 2007),
(20, 'Best Writing', 2007),
(21, 'Best Achievement in Film Editing', 2007);
GO