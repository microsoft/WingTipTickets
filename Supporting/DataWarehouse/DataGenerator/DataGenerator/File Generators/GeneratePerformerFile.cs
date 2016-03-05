using System;
using System.Collections.Generic;

namespace DataCleaner
{
    class GeneratePerformerFile : FileGenerator
    {
        public GeneratePerformerFile()
        {
            Description = "Performer";
            FileName = "DimPerformer.txt";
            AddData();
        }

        private void AddData()
        {
            Lines = new List<List<String>>()
            {
                new List<string>()
                {
                    "1", "Julie Plantes", "Pop Music"
                },
                new List<string>()
                {
                    "2", "Walla Walla Symphony", "Classic Music"
                },
                new List<string>()
                {
                    "3", "The Archie Boyle Band", "Rock Music"
                },
            };
        }
    }
}


