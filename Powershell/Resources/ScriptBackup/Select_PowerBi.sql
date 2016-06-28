SELECT		DISTINCT TOP 1000 
			T.*,
			ConcertFilterId = CAST(T.ConcertId AS varchar(100)),
			SeatSection = S.Description,
			Description =
			S.Description +
			' Seat ' + 
			CAST(SeatNumber as VARCHAR(100))
FROM		Tickets T
JOIN		TicketLevels L ON T.TicketLevelId = L.TicketLevelId
JOIN		SeatSection S ON T.TicketLevelId = S.SeatSectionId
WHERE 		T.SeatNumber <> -1
ORDER BY	S.Description, T.SeatNumber