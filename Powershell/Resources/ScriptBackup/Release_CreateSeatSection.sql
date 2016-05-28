TRUNCATE TABLE [SeatSection]
GO

Declare @index numeric = 1

While @index <= 12
Begin
	Insert [dbo].[SeatSection] ([SeatCount], [VenueId], [Description]) Values (60,  @index,  N'Orchestra Pit')
	Insert [dbo].[SeatSection] ([SeatCount], [VenueId], [Description]) Values (100, @index,  N'Orchestra Front')
	Insert [dbo].[SeatSection] ([SeatCount], [VenueId], [Description]) Values (194, @index,  N'Orchestra Back')
	Insert [dbo].[SeatSection] ([SeatCount], [VenueId], [Description]) Values (8,   @index,  N'Box 1')
	Insert [dbo].[SeatSection] ([SeatCount], [VenueId], [Description]) Values (8,   @index,  N'Box 2')
	Insert [dbo].[SeatSection] ([SeatCount], [VenueId], [Description]) Values (8,   @index,  N'Box 3')
	Insert [dbo].[SeatSection] ([SeatCount], [VenueId], [Description]) Values (8,   @index,  N'Box 4')
	Insert [dbo].[SeatSection] ([SeatCount], [VenueId], [Description]) Values (32,  @index,  N'1st Tier 1')
	Insert [dbo].[SeatSection] ([SeatCount], [VenueId], [Description]) Values (32,  @index,  N'1st Tier 2')
	Insert [dbo].[SeatSection] ([SeatCount], [VenueId], [Description]) Values (198, @index,  N'2nd Tier')

	Set @index = @index + 1
End