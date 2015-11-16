Declare @ConcertId Numeric = 0
Declare @Index Numeric = 1
Declare ConcertCursor Cursor For Select ConcertId From Concerts
Open ConcertCursor
Fetch Next From ConcertCursor Into @ConcertId
While @@Fetch_Status = 0
Begin
	Update Concerts Set ConcertDate=(DATEADD(Day,@Index,GETDATE())) Where ConcertId=@ConcertId
	Set @Index = @Index + 1
	Fetch Next From ConcertCursor Into @ConcertId
End
Close ConcertCursor
Deallocate ConcertCursor