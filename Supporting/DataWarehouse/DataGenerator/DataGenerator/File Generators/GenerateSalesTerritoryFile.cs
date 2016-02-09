using DataCleaner.Properties;

namespace DataCleaner
{
    class GenerateSalesTerritoryFile : FileGenerator
    {
        public GenerateSalesTerritoryFile()
        {
            Description = "Sales Territory";
            FileName = "DimSalesTerritory.txt";
            LoadDataFromResource(Resources.DimSalesTerritory);
        }
    }
}


