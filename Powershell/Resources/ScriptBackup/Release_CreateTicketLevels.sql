TRUNCATE TABLE [TicketLevels]
GO

Declare @indexSection numeric = 1
Declare @indexConcert numeric = 1

While @indexConcert <= 12
Begin

	Insert [dbo].[TicketLevels] ([TicketLevel], [Description], [SeatSectionId], [ConcertId], [TicketPrice]) Values ('Level 1', 'Orchestra Pit - $100.00', @indexSection + 0,  @indexConcert, 100)
	Insert [dbo].[TicketLevels] ([TicketLevel], [Description], [SeatSectionId], [ConcertId], [TicketPrice]) Values ('Level 1', 'Orchestra Front - $80.00',  @indexSection + 1,  @indexConcert, 80)
	Insert [dbo].[TicketLevels] ([TicketLevel], [Description], [SeatSectionId], [ConcertId], [TicketPrice]) Values ('Level 1', 'Orchestra Back - $60.00',  @indexSection + 2,  @indexConcert, 60)
																																 										    
	Insert [dbo].[TicketLevels] ([TicketLevel], [Description], [SeatSectionId], [ConcertId], [TicketPrice]) Values ('Level 2', 'Box 1 - $90.00',  @indexSection + 3,  @indexConcert, 90)
	Insert [dbo].[TicketLevels] ([TicketLevel], [Description], [SeatSectionId], [ConcertId], [TicketPrice]) Values ('Level 2', 'Box 2 - $90.00',  @indexSection + 4,  @indexConcert, 90)
	Insert [dbo].[TicketLevels] ([TicketLevel], [Description], [SeatSectionId], [ConcertId], [TicketPrice]) Values ('Level 2', 'Box 3 - $70.00',  @indexSection + 5,  @indexConcert, 70)
	Insert [dbo].[TicketLevels] ([TicketLevel], [Description], [SeatSectionId], [ConcertId], [TicketPrice]) Values ('Level 2', 'Box 4 - $70.00',  @indexSection + 6,  @indexConcert, 70)
																																 					    				    
	Insert [dbo].[TicketLevels] ([TicketLevel], [Description], [SeatSectionId], [ConcertId], [TicketPrice]) Values ('Level 3', '1st Tier 1 - $50.00',  @indexSection + 7,  @indexConcert, 50)
	Insert [dbo].[TicketLevels] ([TicketLevel], [Description], [SeatSectionId], [ConcertId], [TicketPrice]) Values ('Level 3', '1st Tier 2 - $50.00',  @indexSection + 8,  @indexConcert, 50)
																																	 				    				    
	Insert [dbo].[TicketLevels] ([TicketLevel], [Description], [SeatSectionId], [ConcertId], [TicketPrice]) Values ('Level 4', '2nd Tier - $35.00',  @indexSection + 9,  @indexConcert, 35)

	Set @indexConcert = @indexConcert + 1
	Set @indexSection = @indexSection + 10
End

