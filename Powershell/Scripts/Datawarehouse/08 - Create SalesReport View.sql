-- ================================================================
-- Creating SalesReport View
-- ================================================================
IF OBJECT_ID('dbo.SalesReport') IS NOT NULL
    DROP VIEW dbo.SalesReport;
GO

CREATE VIEW SalesReport
AS
SELECT c.concertname, f.salesamount, f.salesquantity, v.venuename, g.stateprovincename, st.salesterritoryRegion, f.discountquantity, f.totalcost
FROM dbo.factsales f
	LEFT JOIN dbo.DimConcert c
		ON f.ConcertKey = c.Concertkey
	LEFT JOIN dbo.DimVenue v 
		ON f.VenueKey = v.VenueKey
	LEFT JOIN dbo.DimGeography g
		ON g.GeographyKey = v.Geographykey
	Left Join dbo.DimSalesTerritory st
		on st.GeographyKey = g.GeographyKey
GO