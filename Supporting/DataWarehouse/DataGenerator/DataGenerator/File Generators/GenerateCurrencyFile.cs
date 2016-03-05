using DataCleaner.Properties;

namespace DataCleaner
{
    class GenerateCurrencyFile : FileGenerator
    {
        public GenerateCurrencyFile()
        {
            Description = "Currency";
            FileName = "DimCurrency.txt";
            LoadDataFromResource(Resources.DimCurrency);
        }
    }
}


