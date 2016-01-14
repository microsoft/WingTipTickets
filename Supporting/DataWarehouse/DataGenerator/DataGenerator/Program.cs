using System;
using System.Collections.Generic;

namespace DataCleaner
{
    class Program
    {
        #region - Fields -

        private static string _filePath = @"D:\";

        // Build up the File Generator List
        private static readonly List<FileGenerator> _generators = new List<FileGenerator>()
        {
            new GenerateConcertFile(),
            new GenerateCurrencyFile(),
            new GenerateCustomerFile(),
            new GenerateDateFile(),
            new GenerateGeographyFile(),
            new GeneratePerformerFile(),
            new GeneratePromotionFile(),
            new GenerateSalesTerritoryFile(),
            new GenerateVenueFile(),
        };

        #endregion

        #region - Main -

        private static void Main(string[] args)
        {
            GenerateSupportFiles();
            //GenerateSalesFile();

            Console.WriteLine();
            Console.WriteLine("Done, hit any key to Exit");
            Console.ReadKey();
        }

        #endregion

        #region - Private Helpers -

        private static void GenerateSupportFiles()
        {
            FileGenerator.SetFilePath(_filePath);

            Heading("Generating Files");
            foreach (var generator in _generators)
            {
                Console.WriteLine(generator.Description);
                generator.Generate();
                generator.GzipFile();
            }
        }

        private static void GenerateSalesFile()
        {
            Heading("Cleaning Sales File");
            var salesGenerator = new GenerateSalesData(_filePath)
            {
                OnGeneratingLine = PrintLineNumber
            };

            salesGenerator.Run(1, 1000000000);
            salesGenerator.GzipFile();
        }

        private static void PrintLineNumber(long lineNumber)
        {
            Console.WriteLine("Cleaning Line Number: {0}", lineNumber);
        }

        private static void Heading(string caption)
        {
            Console.WriteLine();
            Console.WriteLine("==================================================");
            Console.WriteLine("{0}: ", caption);
            Console.WriteLine("==================================================");
            Console.WriteLine();
        }

        #endregion
    }
}
