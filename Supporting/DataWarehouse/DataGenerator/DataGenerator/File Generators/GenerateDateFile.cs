using DataCleaner.Properties;

namespace DataCleaner
{
    class GenerateDateFile : FileGenerator
    {
        public GenerateDateFile()
        {
            Description = "Date";
            FileName = "DimDate.txt";
            LoadDataFromResource(Resources.DimDate);
        }
    }
}


