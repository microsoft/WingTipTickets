--CREATE TABLE [dbo].[SeatSectionLayout]
--(
--	[SeatSectionLayoutId] int PRIMARY KEY IDENTITY (1, 1),
--	[SeatSectionId] int,
--	[RowNumber] int,
--	[SkipCount] int,
--	[StartNumber] int,
--	[EndNumber] int
--)
--GO

TRUNCATE TABLE [SeatSectionLayout]
GO

Declare @indexSection numeric = 1
Declare @indexConcert numeric = 1

While @indexConcert <= 12
Begin

	--  Orchestra Pit
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 0, 1, 0, 1,  20)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 0, 2, 0, 21, 40)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 0, 3, 0, 41, 60)

	-- Orchestra Front
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 1, 1, 0, 1,  20)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 1, 2, 0, 21, 40)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 1, 3, 0, 41, 60)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 1, 4, 0, 61, 80)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 1, 5, 0, 81, 100)
	
	-- Orchestra Back
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 2, 1,  0,  1,   20)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 2, 2,  0,  21,  40)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 2, 3,  0,  41,  60)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 2, 4,  0,  61,  80)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 2, 5,  0,  81,  100)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 2, 6,  0,  101, 120)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 2, 7,  0,  121, 140)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 2, 8,  0,  141, 160)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 2, 9,  1,  161, 178)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 2, 10, 2,  179, 194)

	-- Box 1
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 3, 1, 0, 1, 2)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 3, 2, 0, 3, 4)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 3, 3, 0, 5, 6)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 3, 4, 0, 7, 8)

	-- Box 2
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 4, 1, 0, 1, 2)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 4, 2, 0, 3, 4)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 4, 3, 0, 5, 6)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 4, 4, 0, 7, 8)

	-- Box 3
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 5, 1, 0, 1, 2)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 5, 2, 0, 3, 4)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 5, 3, 0, 5, 6)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 5, 4, 0, 7, 8)

	-- Box 4
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 6, 1, 0, 1, 2)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 6, 2, 0, 3, 4)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 6, 3, 0, 5, 6)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 6, 4, 0, 7, 8)

	-- 1st Tier 1
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 7, 1, 0,  1,  7)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 7, 2, 0,  8,  14)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 7, 3, 0,  15, 21)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 7, 4, 0,  22, 27)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 7, 5, 0,  28, 32)

	-- 1st Tier 2
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 8, 1, 0,  1,  7)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 8, 2, 0,  8,  14)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 8, 3, 0,  15, 21)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 8, 4, 1,  22, 27)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 8, 5, 2,  28, 32)

	-- 2nd Tier
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 9, 1,  4,  1,   15)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 9, 2,  4,  16,  30)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 9, 3,  4,  31,  45)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 9, 4,  4,  46,  60)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 9, 5,  0,  61,  83)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 9, 6,  0,  84,  106)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 9, 7,  0,  107, 129)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 9, 8,  0,  130, 152)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 9, 9,  0,  153, 175)
	INSERT [dbo].[SeatSectionLayout] ([SeatSectionId], [RowNumber], [SkipCount], [StartNumber], [EndNumber]) Values (@indexSection + 9, 10, 0,  176, 198)

	Set @indexConcert = @indexConcert + 1
	Set @indexSection = @indexSection + 10
End