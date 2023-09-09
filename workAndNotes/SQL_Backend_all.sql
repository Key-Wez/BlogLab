/*
CREATE DATABASE BlogDB;
USE BlogDB;
*/
--	================================================	TABLES
CREATE TABLE ApplicationUser(
	ApplicationUserId INT NOT NULL IDENTITY(1,1),
	Username VARCHAR(20) NOT NULL,
	NormalizedUsername VARCHAR(20) NOT NULL,
	Email VARCHAR(30) NOT NULL,
	NormalizedEmail VARCHAR(30) NOT NULL,
	Fullname VARCHAR(30) NULL,
	PasswordHash NVARCHAR(MAX) NOT NULL,
	PRIMARY KEY(ApplicationUserId)
	)

	CREATE INDEX[IX_ApplicationUser_NormalizedUsername] ON [dbo].[ApplicationUser]([NormalizedUsername])
	CREATE INDEX[IX_ApplicationUser_NormalizedEmail] ON [dbo].[ApplicationUser]([NormalizedEmail])

	-- SELECT * FROM ApplicationUser

CREATE TABLE Photo(
	PhotoId INT NOT NULL IDENTITY(1,1),
	ApplicationUserId INT NOT NULL,
	PublicId VARCHAR(50) NOT NULL,
	ImageUrl VARCHAR(250) NOT NULL,
	[Description] VARCHAR(30) NOT NULL,
	PublishDate DATETIME NOT NULL DEFAULT GETDATE(),
	UpdateDate DATETIME NOT NULL DEFAULT GETDATE(),
	PRIMARY KEY(PhotoId),
	FOREIGN KEY(ApplicationUserId) REFERENCES ApplicationUser(ApplicationUserId)
	)

CREATE TABLE Blog(
	BlogId INT NOT NULL IDENTITY(1,1),
	ApplicationUserId INT NOT NULL,
	PhotoId INT NULL,
	Title VARCHAR(50) NOT NULL,
	Content VARCHAR(MAX) NOT NULL,
	PublishDate DATETIME NOT NULL DEFAULT GETDATE(),
	UpdateDate DATETIME NOT NULL DEFAULT GETDATE(),
	ActiveInd BIT NOT NULL DEFAULT CONVERT(BIT, 1),
	PRIMARY KEY(BlogId),
	FOREIGN KEY(ApplicationUserId) REFERENCES ApplicationUser(ApplicationUserId),
	FOREIGN KEY(PhotoId) REFERENCES Photo(PhotoId)
	)

CREATE TABLE BlogComment(
	BlogCommentId INT NOT NULL IDENTITY(1,1),
	ParentBlogCommentId INT NULL,
	BlogId INT NOT NULL,
	ApplicationUserId INT NOT NULL,
	Content VARCHAR(300) NOT NULL,
	PublishDate DATETIME NOT NULL DEFAULT GETDATE(),
	UpdateDate DATETIME NOT NULL DEFAULT GETDATE(),
	ActiveInd BIT NOT NULL DEFAULT CONVERT(BIT, 1),
	PRIMARY KEY(BlogCommentId),
	FOREIGN KEY(BlogId) REFERENCES Blog(BlogId),
	FOREIGN KEY(ApplicationUserId) REFERENCES ApplicationUser(ApplicationUserId)
	)

--	================================================	SCHEMA / VIEWS
	CREATE SCHEMA [aggregate]
--	================================================	VIEWS
	CREATE VIEW [aggregate].[Blog]
	AS
	SELECT 
		t1.BlogId,
		t1.ApplicationUserId,
		t2.Username,
		t1.Title,
		t1.Content,
		t1.PhotoId,
		t1.PublishDate,
		t1.UpdateDate,
		t1.ActiveInd
	FROM 
		dbo.Blog t1
	INNER JOIN 
		dbo.ApplicationUser t2 on t2.ApplicationUserId = t1.ApplicationUserId
	-- select * from [aggregate].[Blog]

	CREATE VIEW [aggregate].[BlogComment]
	AS
	SELECT 
		t1.BlogCommentId,
		t1.ParentBlogCommentId,
		t1.BlogId,
		t1.Content,
		t1.ApplicationUserId,
		t2.Username,
		t1.PublishDate,
		t1.UpdateDate,
		t1.ActiveInd
	FROM 
		dbo.BlogComment t1
	INNER JOIN 
		dbo.ApplicationUser t2 on t2.ApplicationUserId = t1.ApplicationUserId
	-- select * from [aggregate].[BlogComment]

--	================================================	TYPES

CREATE TYPE [dbo].[AccountType] AS TABLE
(
	[Username] VARCHAR(20) NOT NULL,
	[NormalizedUsername] VARCHAR(20) NOT NULL,
	[Email] VARCHAR(30) NOT NULL,
	[NormalizedEmail] VARCHAR(30) NOT NULL,
	[FullName] VARCHAR(30) NULL,
	[PasswordHash] NVARCHAR(MAX) NOT NULL
)

CREATE TYPE [dbo].[PhotoType] AS TABLE
(
	[PublicId] VARCHAR(50) NOT NULL,
	[ImageUrl] VARCHAR(250) NOT NULL,
	[Description] VARCHAR(30) NOT NULL
)

CREATE TYPE [dbo].[BlogType] AS TABLE
(
	[BlogId] INT NOT NULL,
	[Title] VARCHAR(50) NOT NULL,
	[Content] VARCHAR(MAX) NOT NULL,
	[PhotoId] INT NULL
)

CREATE TYPE [dbo].[BlogCommentType] AS TABLE
(
	[BlogCommentId] INT NOT NULL,
	[ParentBlogCommentId] INT NULL,
	[BlogId] INT NOT NULL,
	[Content] VARCHAR(300) NOT NULL
)

--	================================================	Stored Procedures

CREATE PROCEDURE [dbo].[GetByUserName]
	@NormalizedUsername VARCHAR(20)
AS
	SELECT [ApplicationUserId]
		  ,[Username]
          ,[NormalizedUsername]
	      ,[Email]
	      ,[NormalizedEmail]
	      ,[FullName]
	      ,[PasswordHash]
	FROM
		[dbo].[ApplicationUser] t1
	WHERE
		t1.[NormalizedUsername] = @NormalizedUsername

---

CREATE PROCEDURE [dbo].[Account_Insert]
	@Account [AccountType] READONLY
AS
	INSERT INTO [dbo].[ApplicationUser]
           ([Username]
           ,[NormalizedUsername]
           ,[Email]
           ,[NormalizedEmail]
           ,[FullName]
           ,[PasswordHash])
     SELECT
            [Username]
		   ,[NormalizedUsername]
		   ,[Email]
		   ,[NormalizedEmail]
		   ,[FullName]
		   ,[PasswordHash]
	FROM
		@Account
	SELECT CAST(SCOPE_IDENTITY() AS INT);

--	================================================	Stored Procedures - BLOG

CREATE PROCEDURE [dbo].[Blog_Delete]
	@BlogId INT
AS
	UPDATE [dbo].[BlogComment]
	SET [ActiveInd] = CONVERT(BIT,0)
	WHERE 
		[BlogId] = @BlogId

	UPDATE [dbo].[Blog]
	SET 
		[PhotoId] = NULL,
		[ActiveInd] = CONVERT(BIT,0)
	WHERE 
		[BlogId] = @BlogId
	
---

CREATE PROCEDURE [dbo].[Blog_Get]
	@BlogId INT
AS
	SELECT 
		[BlogId]
       ,[ApplicationUserId]
       ,[Username]
       ,[Title]
       ,[Content]
       ,[PhotoId]
       ,[PublishDate]
       ,[UpdateDate]
  FROM	[aggregate].[Blog] t1
  WHERE 
		t1.[BlogId] = @BlogId AND
		t1.ActiveInd = CONVERT(BIT,1)
		
---
CREATE PROCEDURE [dbo].[Blog_GetAll]
	@Offset INT,
	@PageSize INT
AS
	SELECT 
		[BlogId]
       ,[ApplicationUserId]
       ,[Username]
       ,[Title]
       ,[Content]
       ,[PhotoId]
       ,[PublishDate]
       ,[UpdateDate]
  FROM	[aggregate].[Blog] t1
  WHERE 
		t1.ActiveInd = CONVERT(BIT,1)
  ORDER BY
		t1.[BlogId]
  OFFSET @OFFSET ROWS
  FETCH NEXT @PageSize ROWS ONLY;

  SELECT COUNT(*) FROM [aggregate].[Blog] t1 WHERE t1.ActiveInd = CONVERT(BIT,1);
  	
---
CREATE PROCEDURE [dbo].[Blog_GetAllFamous]
AS
	SELECT TOP 6
		t1.[BlogId]
       ,t1.[ApplicationUserId]
       ,t1.[Username]
       ,t1.[Title]
       ,t1.[Content]
       ,t1.[PhotoId]
       ,t1.[PublishDate]
       ,t1.[UpdateDate]
  FROM	[aggregate].[Blog] t1
  INNER JOIN
		[dbo].[BlogComment] t2 on t1.BlogId = t2.BlogId
  WHERE 
		t1.ActiveInd = CONVERT(BIT,1) AND
		t2.ActiveInd = CONVERT(BIT,1)
  GROUP BY
		t1.[BlogId]
       ,t1.[ApplicationUserId]
       ,t1.[Username]
       ,t1.[Title]
       ,t1.[Content]
       ,t1.[PhotoId]
       ,t1.[PublishDate]
       ,t1.[UpdateDate]
  ORDER BY
		COUNT(t2.[BlogCommentId]) DESC

---
CREATE PROCEDURE [dbo].[Blog_GetByUserId]
@ApplicationUserId INT
AS
	SELECT 
	   [BlogId]
      ,[ApplicationUserId]
      ,[Username]
      ,[Title]
      ,[Content]
      ,[PhotoId]
      ,[PublishDate]
      ,[UpdateDate]
  FROM [aggregate].[Blog] t1
  WHERE 
	   t1.[ApplicationUserId] = @ApplicationUserId AND
	   t1.[ActiveInd] = CONVERT(BIT,1)

---
CREATE PROCEDURE [dbo].[Blog_Upsert]
	@Blog BlogType READONLY,
	@ApplicationUserId INT
AS
	MERGE INTO BLOG TARGET
	USING (
		SELECT
			BlogId,
			@ApplicationUserId AS [ApplicationUserId],
			Title,
			Content,
			PhotoId
		FROM
			@Blog
	) AS SOURCE
	ON
	(
		TARGET.BlogId = SOURCE.BlogId AND TARGET.[ApplicationUserId] = SOURCE.[ApplicationUserId]
	)
	WHEN MATCHED THEN
		UPDATE SET
			TARGET.[Title] = SOURCE.[Title]
           ,TARGET.[Content] = SOURCE.[Content]
           ,TARGET.[PhotoId] = SOURCE.[PhotoId]
           ,TARGET.[UpdateDate] = GETDATE()
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[ApplicationUserId]
           ,[Title]
           ,[Content]
           ,[PhotoId]
		   )
		VALUES (
			SOURCE.[ApplicationUserId]
           ,SOURCE.[Title]
           ,SOURCE.[Content]
           ,SOURCE.[PhotoId]
		   );
		SELECT CAST(SCOPE_IDENTITY() AS INT);

--	================================================	Stored Procedures - BLOG COMMENTS
--	[BlogComment_Delete]
CREATE PROCEDURE [dbo].[BlogComment_Delete]
	@BlogCommentId INT
AS
	DROP TABLE IF EXISTS #BlogCommentsToBeDeleted;

	WITH cte_blogComments AS (
		SELECT
			t1.BlogCommentId,
			t1.ParentBlogCommentId
		FROM
			[dbo].[BlogComment] t1
		WHERE
			t1.BlogCommentId = @BlogCommentId
		UNION ALL
		SELECT
			t2.BlogCommentId,
			t2.ParentBlogCommentId
		FROM
			[dbo].[BlogComment] t2
			INNER JOIN cte_blogComments t3 ON 
				t3.[BlogCommentId] = t2.[ParentBlogCommentId]
	)
	SELECT
		[BlogCommentId],
		[ParentBlogCommentId]
	INTO
		#BlogCommentsToBeDeleted
	FROM
		cte_blogComments;

	UPDATE t1
	SET
		t1.[ActiveInd] = CONVERT(BIT, 0),
		t1.[UpdateDate] = GETDATE()
	FROM
		[dbo].[BlogComment] t1
		INNER JOIN #BlogCommentsToBeDeleted t2
			ON t1.[BlogCommentId] = t2.[BlogCommentId]

--	[BlogComment_Get]
CREATE PROCEDURE [dbo].[BlogComment_Get]
	@BlogCommentId INT
AS
	SELECT 
		 t1.[BlogCommentId]
		,t1.[ParentBlogCommentId]
		,t1.[BlogId]
		,t1.[ApplicationUserId]
		,t1.[Username]
		,t1.[Content]
		,t1.[PublishDate]
		,t1.[UpdateDate]
	FROM 
		[aggregate].[BlogComment] t1
	WHERE
		t1.[BlogCommentId] = @BlogCommentId AND
		t1.[ActiveInd] = CONVERT(BIT, 1)

--	[BlogComment_Upsert]
CREATE PROCEDURE [dbo].[BlogComment_Upsert]
	@BlogComment BlogCommentType READONLY,
	@ApplicationUserId INT
AS
	MERGE INTO [dbo].[BlogComment] TARGET
	USING (
		SELECT 
			 [BlogCommentId]
			,[ParentBlogCommentId]
			,[BlogId]
			,[Content]
			,@ApplicationUserId AS [ApplicationUserId]
		FROM 
			@BlogComment
	) AS SOURCE
	ON
	(
		TARGET.[BlogCommentId] = SOURCE.[BlogCommentId] AND
		TARGET.[ApplicationUserId] = SOURCE.[ApplicationUserId]
	)
	WHEN MATCHED THEN
		UPDATE SET
			TARGET.[CONTENT] = SOURCE.[CONTENT],
			TARGET.[UpdateDate] = GETDATE()
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[ParentBlogCommentId],
			[BlogId],
			[ApplicationUserId],
			[Content]
		)
		VALUES
		(
			SOURCE.[ParentBlogCommentId],
			SOURCE.[BlogId],
			SOURCE.[ApplicationUserId],
			SOURCE.[Content]
		);

	SELECT CAST(SCOPE_IDENTITY() AS INT);

--	================================================	Stored Procedures - PHOTO
--	Photo_Delete
CREATE PROCEDURE [dbo].[Photo_Delete]
	@PhotoId INT
AS
	DELETE FROM [dbo].[Photo] 
	WHERE [PhotoId] = @PhotoId

--  Photo_Get
CREATE PROCEDURE [dbo].[Photo_Get]
	@PhotoId INT
AS 
	SELECT 
		 t1.[PhotoId]
		,t1.[ApplicationUserId]
		,t1.[PublicId]
		,t1.[ImageUrl]
		,t1.[Description]
		,t1.[PublishDate]
		,t1.[UpdateDate]
	FROM 
		[dbo].[Photo] t1
	WHERE
		t1.[PhotoId] = @PhotoId

--	Photo_GetByUserId
CREATE PROCEDURE [dbo].[Photo_GetByUserId]
	@ApplicationUserId INT
AS
	SELECT 
		 t1.[PhotoId]
		,t1.[ApplicationUserId]
		,t1.[PublicId]
		,t1.[ImageUrl]
		,t1.[Description]
		,t1.[PublishDate]
		,t1.[UpdateDate]
	FROM 
		[dbo].[Photo] t1
	WHERE
		t1.[ApplicationUserId] = @ApplicationUserId

--	Photo_Insert
CREATE PROCEDURE [dbo].[Photo_Insert]
	@Photo PhotoType READONLY,
	@ApplicationUserId INT
AS
	INSERT INTO [dbo].[Photo]
           ([ApplicationUserId]
           ,[PublicId]
           ,[ImageUrl]
           ,[Description])
     SELECT
		@ApplicationUserId,
		[PublicId],
        [ImageUrl],
		[Description]
	FROM @Photo;

	SELECT CAST(SCOPE_IDENTITY() AS INT);