-- ===========================================================================================
-- CREATE VIEWS
-- ===========================================================================================

CREATE	VIEW ConcertSearch AS
SELECT	c.ConcertId, 
		c.ConcertName, 
		CONVERT(DATETIMEOFFSET, 
		c.ConcertDate) AS ConcertDate, 
	    c.VenueId, 
		v.VenueName, 
		i.CityName AS VenueCity, 
		s.StateName AS VenueState, 
		p.CountryName AS VenueCountry, 
	    a.PerformerId, a.ShortName AS PerformerName,
	    c.ConcertName + ' featuring ' + a.ShortName + ' playing at ' + v.VenueName + ' in ' + i.CityName + ' on ' + DATENAME(M, c.ConcertDate) + ' ' + DATENAME(D, c.ConcertDate) AS FullTitle,
	    (
			SELECT	MAX(RowVersion) 
			FROM	(
						SELECT c.RowVersion UNION 
						SELECT v.RowVersion UNION 
						SELECT a.RowVersion
					) r
		) AS [RowVersion]
FROM	Concerts c
JOIN	Venues v ON c.VenueId = v.VenueId
JOIN	City i ON v.CityId = i.CityId
JOIN	States s ON i.StateId = s.StateId
JOIN	Country p ON s.CountryId = p.CountryId
JOIN	Performers a ON c.PerformerId = a.PerformerId