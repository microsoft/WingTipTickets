using System.Collections.Generic;
using DataCleaner.Properties;

namespace DataCleaner
{
    class GenerateGeographyFile : FileGenerator
    {
        public GenerateGeographyFile()
        {
            Description = "Geography";
            FileName = "DimGeography.txt";
            LoadDataFromResource(Resources.DimGeography);
            AddData();
        }

        private void AddData()
        {
            Lines.Add(new List<string>()
            {
                "953", "City", "North America", "Salt Lake City", "Utah", "United States", "1", "2012-08-01 00:00:00.000", "2012-08-01 00:00:00.000"
            });
            Lines.Add(new List<string>()
            {
                "954", "City", "North America", "Detroit", "Michigan", "United States", "1", "2012-08-01 00:00:00.000", "2012-08-01 00:00:00.000"
            });
        }
    }
}


