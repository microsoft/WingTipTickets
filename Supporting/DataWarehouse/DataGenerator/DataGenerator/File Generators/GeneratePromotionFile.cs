using System;
using System.Collections.Generic;

namespace DataCleaner
{
    class GeneratePromotionFile : FileGenerator
    {
        public GeneratePromotionFile()
        {
            Description = "Promotion";
            FileName = "DimPromotion.txt";
            AddData();
        }

        private void AddData()
        {
            Lines = new List<List<String>>()
            {
                new List<string>()
                {
                    "1", "001", "No Discount", "No Discount", "0.0", "No Discount", "No Discount", "2003-01-01 00:00:00.000", "2010-12-31 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "2", "002", "North America Spring Promotion", "North America Spring Promotion", "5.0000000000000003E-2", "Seasonal Discount", "Venue", "2007-01-01 00:00:00.000", "2007-03-31 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "3", "003", "North America Summer Promotion", "North America Summer Promotion", "0.10000000000000001", "Seasonal Discount", "Venue", "2007-07-01 00:00:00.000", "2007-09-30 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "4", "004", "North America Holiday Promotion", "North America Holiday Promotion", "0.20000000000000001", "Seasonal Discount", "Venue", "2007-11-01 00:00:00.000", "2007-12-31 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "5", "005", "Asian Holiday Promotion", "Asian Holiday Promotion", "0.14999999999999999", "Seasonal Discount", "Venue", "2007-11-01 00:00:00.000", "2008-01-31 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "6", "006", "Asian Spring Promotion", "Asian Spring Promotion", "0.20000000000000001", "Seasonal Discount", "Venue", "2007-02-01 00:00:00.000", "2007-04-30 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "7", "007", "Asian Summer Promotion", "Asian Summer Promotion", "0.10000000000000001", "Seasonal Discount", "Venue", "2007-05-01 00:00:00.000", "2007-06-30 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "8", "008", "European Spring Promotion", "European Spring Promotion", "7.0000000000000007E-2", "Seasonal Discount", "Venue", "2007-02-01 00:00:00.000", "2007-04-30 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "9", "009", "European Summer Promotion", "European Summer Promotion", "0.10000000000000001", "Seasonal Discount", "Venue", "2007-08-01 00:00:00.000", "2007-09-30 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "10", "010", "European Holiday Promotion", "European Holiday Promotion", "0.20000000000000001", "Seasonal Discount", "Venue", "2007-10-01 00:00:00.000", "2008-01-31 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "11", "011", "North America Spring Promotion", "North America Spring Promotion", "5.0000000000000003E-2", "Seasonal Discount", "Venue", "2008-01-01 00:00:00.000", "2008-03-31 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "12", "012", "North America Summer Promotion", "North America Summer Promotion", "0.10000000000000001", "Seasonal Discount", "Venue", "2008-07-01 00:00:00.000", "2008-09-30 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "13", "013", "North America Holiday Promotion", "North America Holiday Promotion", "0.20000000000000001", "Seasonal Discount", "Venue", "2008-11-01 00:00:00.000", "2008-12-31 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "14", "014", "Asian Holiday Promotion", "Asian Holiday Promotion", "0.14999999999999999", "Seasonal Discount", "Venue", "2008-11-01 00:00:00.000", "2009-01-31 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "15", "015", "Asian Spring Promotion", "Asian Spring Promotion", "0.20000000000000001", "Seasonal Discount", "Venue", "2008-02-01 00:00:00.000", "2008-04-30 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "16", "016", "Asian Summer Promotion", "Asian Summer Promotion", "0.10000000000000001", "Seasonal Discount", "Venue", "2008-05-01 00:00:00.000", "2008-06-30 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "17", "017", "European Spring Promotion", "European Spring Promotion", "7.0000000000000007E-2", "Seasonal Discount", "Venue", "2008-02-01 00:00:00.000", "2008-04-30 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "18", "018", "European Summer Promotion", "European Summer Promotion", "0.10000000000000001", "Seasonal Discount", "Venue", "2008-08-01 00:00:00.000", "2008-09-30 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "19", "019", "European Holiday Promotion", "European Holiday Promotion", "0.20000000000000001", "Seasonal Discount", "Venue", "2008-10-01 00:00:00.000", "2009-01-31 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "20", "020", "North America Spring Promotion", "North America Spring Promotion", "5.0000000000000003E-2", "Seasonal Discount", "Venue", "2009-01-01 00:00:00.000", "2010-03-31 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "21", "021", "North America Summer Promotion", "North America Summer Promotion", "0.10000000000000001", "Seasonal Discount", "Venue", "2009-07-01 00:00:00.000", "2009-09-30 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "22", "022", "North America Holiday Promotion", "North America Holiday Promotion", "0.20000000000000001", "Seasonal Discount", "Venue", "2009-11-01 00:00:00.000", "2009-12-31 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "23", "023", "Asian Holiday Promotion", "Asian Holiday Promotion", "0.14999999999999999", "Seasonal Discount", "Venue", "2009-11-01 00:00:00.000", "2010-01-31 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "24", "024", "Asian Spring Promotion", "Asian Spring Promotion", "0.20000000000000001", "Seasonal Discount", "Venue", "2009-02-01 00:00:00.000", "2009-04-30 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "25", "025", "Asian Summer Promotion", "Asian Summer Promotion", "0.10000000000000001", "Seasonal Discount", "Venue", "2009-05-01 00:00:00.000", "2009-06-30 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "26", "026", "European Spring Promotion", "European Spring Promotion", "7.0000000000000007E-2", "Seasonal Discount", "Venue", "2009-02-01 00:00:00.000", "2009-04-30 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "27", "027", "European Summer Promotion", "European Summer Promotion", "0.10000000000000001", "Seasonal Discount", "Venue", "2009-08-01 00:00:00.000", "2009-09-30 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
                new List<string>()
                {
                    "28", "028", "European Holiday Promotion", "European Holiday Promotion", "0.20000000000000001", "Seasonal Discount", "Venue", "2009-10-01 00:00:00.000", "2010-01-31 00:00:00.000", "", "", "1", "2009-09-01 00:00:00.000", "2009-09-01 00:00:00.000"
                },
            };
        }
    }
}


