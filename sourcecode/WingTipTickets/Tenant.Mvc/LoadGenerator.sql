Declare @CustomerId Numeric = 1
Declare @ConcertId Nvarchar(8) = '69'
Declare @TicketLevelId Nvarchar(8) = '275'
Declare @MinutesToRunFor numeric = 1
Declare @MaximumTicketsToPurchase numeric = 60
Declare @NumberOfDelaysBetweenPurchases numeric = 6
Declare @DeleteExisting bit = false

if (@DeleteExisting = true)
Begin
	Delete from Tickets Where ConcertId=@ConcertId and CustomerId=@CustomerId
End

Declare @TempTimeString nvarchar(20)
Declare @Index Numeric = 0
While (@Index < @NumberOfDelaysBetweenPurchases)
Begin
	Declare @ticketIndex numeric = 0
	Declare @ticketsToPurchaseNow numeric = @MaximumTicketsToPurchase/@NumberOfDelaysBetweenPurchases
	While (@ticketIndex < @ticketsToPurchaseNow)
	Begin
		Insert Into Tickets (CustomerId, Name, TicketLevelId, ConcertId, PurchaseDate)
		Values (Cast(@CustomerId as nvarchar(6)), 'Ticket (' + Cast(@ticketIndex as nvarchar(6)) + ' of ' +
		Cast(@ticketsToPurchaseNow as nvarchar(6)) + ') for user  to concert-' + @concertId, @ticketLevelId, @concertId, GETDATE())
		set @ticketIndex = @ticketIndex + 1
	End
	Declare @DelayInSeconds numeric = (@minutesToRunFor*60)/@NumberOfDelaysBetweenPurchases
	Set @TempTimeString = '00:00:' + Cast(@DelayInSeconds as nvarchar(2))
	WaitFor Delay @TempTimeString
	Set @index = @index + 1
End
Go