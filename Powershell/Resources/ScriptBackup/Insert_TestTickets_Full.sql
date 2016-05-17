TRUNCATE TABLE Tickets
GO

SET IDENTITY_INSERT [dbo].[Tickets] ON 
GO

DECLARE @index INT

SELECT @index = 1
WHILE(@index <= 60)
BEGIN
	INSERT [dbo].[Tickets] ([TicketId], [CustomerId], [Name], [TicketLevelId], [ConcertId], [PurchaseDate], [SeatNumber]) 
	VALUES (@index, 5, N'Ticket (1 of 1) for user Werner to concert-1', 1, 1, CAST(N'2016-05-17 13:12:47.000' AS DateTime), @index)

	SELECT @Index = @Index + 1;
END

SELECT @index = 1
WHILE(@index <= 100)
BEGIN
	INSERT [dbo].[Tickets] ([TicketId], [CustomerId], [Name], [TicketLevelId], [ConcertId], [PurchaseDate], [SeatNumber]) 
	VALUES (@index+60, 5, N'Ticket (1 of 1) for user Werner to concert-1', 2, 1, CAST(N'2016-05-17 13:12:47.000' AS DateTime), @index)

	SELECT @Index = @Index + 1;
END

SELECT @index = 1
WHILE(@index <= 194)
BEGIN
	INSERT [dbo].[Tickets] ([TicketId], [CustomerId], [Name], [TicketLevelId], [ConcertId], [PurchaseDate], [SeatNumber]) 
	VALUES (@index+160, 5, N'Ticket (1 of 1) for user Werner to concert-1', 3, 1, CAST(N'2016-05-17 13:12:47.000' AS DateTime), @index)

	SELECT @Index = @Index + 1;
END

SELECT @index = 1
WHILE(@index <= 8)
BEGIN
	INSERT [dbo].[Tickets] ([TicketId], [CustomerId], [Name], [TicketLevelId], [ConcertId], [PurchaseDate], [SeatNumber]) 
	VALUES (@index+354, 5, N'Ticket (1 of 1) for user Werner to concert-1', 4, 1, CAST(N'2016-05-17 13:12:47.000' AS DateTime), @index)

	SELECT @Index = @Index + 1;
END

SELECT @index = 1
WHILE(@index <= 8)
BEGIN
	INSERT [dbo].[Tickets] ([TicketId], [CustomerId], [Name], [TicketLevelId], [ConcertId], [PurchaseDate], [SeatNumber]) 
	VALUES (@index+362, 5, N'Ticket (1 of 1) for user Werner to concert-1', 5, 1, CAST(N'2016-05-17 13:12:47.000' AS DateTime), @index)

	SELECT @Index = @Index + 1;
END

SELECT @index = 1
WHILE(@index <= 8)
BEGIN
	INSERT [dbo].[Tickets] ([TicketId], [CustomerId], [Name], [TicketLevelId], [ConcertId], [PurchaseDate], [SeatNumber]) 
	VALUES (@index+370, 5, N'Ticket (1 of 1) for user Werner to concert-1', 6, 1, CAST(N'2016-05-17 13:12:47.000' AS DateTime), @index)

	SELECT @Index = @Index + 1;
END

SELECT @index = 1
WHILE(@index <= 8)
BEGIN
	INSERT [dbo].[Tickets] ([TicketId], [CustomerId], [Name], [TicketLevelId], [ConcertId], [PurchaseDate], [SeatNumber]) 
	VALUES (@index+378, 5, N'Ticket (1 of 1) for user Werner to concert-1', 7, 1, CAST(N'2016-05-17 13:12:47.000' AS DateTime), @index)

	SELECT @Index = @Index + 1;
END

SELECT @index = 1
WHILE(@index <= 32)
BEGIN
	INSERT [dbo].[Tickets] ([TicketId], [CustomerId], [Name], [TicketLevelId], [ConcertId], [PurchaseDate], [SeatNumber]) 
	VALUES (@index+386, 5, N'Ticket (1 of 1) for user Werner to concert-1', 8, 1, CAST(N'2016-05-17 13:12:47.000' AS DateTime), @index)

	SELECT @Index = @Index + 1;
END

SELECT @index = 1
WHILE(@index <= 32)
BEGIN
	INSERT [dbo].[Tickets] ([TicketId], [CustomerId], [Name], [TicketLevelId], [ConcertId], [PurchaseDate], [SeatNumber]) 
	VALUES (@index+418, 5, N'Ticket (1 of 1) for user Werner to concert-1', 9, 1, CAST(N'2016-05-17 13:12:47.000' AS DateTime), @index)

	SELECT @Index = @Index + 1;
END

SELECT @index = 1
WHILE(@index <= 198)
BEGIN
	INSERT [dbo].[Tickets] ([TicketId], [CustomerId], [Name], [TicketLevelId], [ConcertId], [PurchaseDate], [SeatNumber]) 
	VALUES (@index+450, 5, N'Ticket (1 of 1) for user Werner to concert-1', 10, 1, CAST(N'2016-05-17 13:12:47.000' AS DateTime), @index)

	SELECT @Index = @Index + 1;
END
GO

SET IDENTITY_INSERT [dbo].[Tickets] OFF
GO