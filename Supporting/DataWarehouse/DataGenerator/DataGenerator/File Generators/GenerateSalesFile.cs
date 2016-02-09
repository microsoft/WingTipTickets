using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Threading.Tasks;

namespace DataCleaner
{
    internal class GenerateSalesData
    {
        public const int ReportAtLineCount = 5000;
        public const int WriteAtLineCount = 100000;

        #region - Fields -

        private object _saveLock = new object();

        private long _lineCount;
        private readonly string _filePath;
        private readonly string _fileName;

        #endregion

        #region - Properties -
        
        public Action<long> OnGeneratingLine;

        public Random Random = new Random((int)DateTime.Now.Ticks);
        private StreamWriter _streamWriter;

        #endregion

        #region - Constructors -

        public GenerateSalesData(string filePath)
        {
            _lineCount = 0;
            _filePath = filePath;
            _fileName = "FactSales.txt";
        }

        #endregion

        #region - Public Methods -

        public void Run(int taskCount, long targetSize)
        {
            var fileName = Path.Combine(_filePath, _fileName);

            using (_streamWriter = File.AppendText(fileName))
            {
                var generators = new List<GenerateSalesFile>();
                var tasks = new List<Task>();

                for (var x = 0; x < taskCount; x ++)
                {
                    var targetLineCount = targetSize / taskCount;
                    var salesKeySeed = targetLineCount * x + 1;

                    var generator = new GenerateSalesFile(targetLineCount, salesKeySeed)
                    {
                        OnLineGenerated = LineGeneratedHandler,
                        OnWriteDataToFile = WriteDataToFileHandler,
                    };

                    generators.Add(generator);
                    tasks.Add(new Task(generator.Run));
                }

                tasks.ForEach(t => t.Start());
                Task.WaitAll(tasks.ToArray());
            }
        }

        public void GzipFile()
        {
            var fileName = Path.Combine(_filePath, _fileName);

            using (var fileStream = File.OpenRead(fileName))
            {
                using (var compressedFileStream = File.Create(_fileName + ".gz"))
                {
                    using (var compressionStream = new GZipStream(compressedFileStream, CompressionMode.Compress))
                    {
                        fileStream.CopyTo(compressionStream);
                    }
                }
            }
        }

        #endregion

        #region - Event Handlers -

        private void LineGeneratedHandler(long lineCount)
        {
            _lineCount += ReportAtLineCount;

            // Update console
            if (OnGeneratingLine != null)
            {
                OnGeneratingLine(_lineCount);
            }
        }

        private void WriteDataToFileHandler(string data)
        {
            lock (_saveLock)
            {
                _streamWriter.WriteLine(data);
            }
        }

        #endregion
    }

    internal class GenerateSalesFile
    {
        #region - Fields -

        private readonly long _targetLineCount;
        private long _salesKey;
        
        private readonly List<string> _dateKeys;
        private readonly List<string> _venueKeys;
        private readonly Dictionary<string, int> _concertKeys;
        private readonly List<string> _customerKeys;
        private readonly List<string> _promotionKeys;

        #endregion

        #region - Properties -

        public Action<long> OnLineGenerated;
        public Action<string> OnWriteDataToFile;

        public Random Random = new Random((int)DateTime.Now.Ticks);

        #endregion

        #region - Constructors -

        public GenerateSalesFile(long targetLineCount, long salesKeySeed)
        {
            _targetLineCount = targetLineCount;
            _salesKey = salesKeySeed;

            _dateKeys = (new GenerateDateFile()).GetKeys();
            _concertKeys = (new GenerateConcertFile()).GetWeightedKeys();
            _venueKeys = (new GenerateVenueFile()).GetKeys();
            _promotionKeys = (new GeneratePromotionFile()).GetKeys();
            _customerKeys = (new GenerateCustomerFile()).GetKeys();
        }

        #endregion

        #region - Public Methods -

        public void Run()
        {
            var internalLineCount = 0;

            do
            {
                var values = new List<string>();

                // Update counters
                internalLineCount++;
                _salesKey++;

                // Update Parent
                if (internalLineCount % GenerateSalesData.ReportAtLineCount == 0)
                {
                    OnLineGenerated(internalLineCount);
                }

                #region - Create Sales Values -

                // Sales Order Key
                values.Add(_salesKey.ToString());

                // Sales Date
                var salesDate = _dateKeys.GetRandomElement();
                values.Add(salesDate);

                // Venue
                var venue = _venueKeys.GetRandomElement();
                values.Add(venue);

                // Concert
                var concert = Convert.ToInt32(_concertKeys.GetRandomElement().Key);
                values.Add(concert.ToString());

                // Unit Cost
                var unitCost = 0;

                if (concert >= 2 && concert <= 13)
                {
                    unitCost = 85;
                }
                else if (concert >= 14 && concert <= 23)
                {
                    unitCost = 60;
                }
                else
                {
                    unitCost = 120;
                }

                // Promotion
                var promotionKey = _promotionKeys.GetRandomElement();
                values.Add(promotionKey);

                // Currency - US Dollar
                values.Add("1");

                // Customer
                var customerKey = _customerKeys.GetRandomElement();
                values.Add(customerKey);

                // Sales Order Number
                values.Add(_salesKey.PadWithZeros(18));

                // Sales Order Line Number
                values.Add("1");

                // Sales Quantity
                var salesQty = Random.Next(1, 11);
                values.Add(salesQty.ToString());

                // Sales Amount
                var salesAmount = salesQty * unitCost;
                values.Add(salesAmount.ToString());

                // Return Quantity and Amount
                var returnRdn = Random.Next(1, 30);
                var returnQty = 0;
                var returnAmount = 0;

                if (returnRdn == 5)
                {
                    returnQty = Random.Next(1, salesQty);
                    returnAmount = returnQty * unitCost;
                }

                values.Add(returnQty.ToString());
                values.Add(returnAmount.ToString());

                // Discount Quantity and Amount
                var discountRdn = Random.Next(1, 15);
                var discountQty = 0;
                var discountAmount = 0;

                if (discountRdn == 5 && salesQty > 5)
                {
                    discountQty = Random.Next(1, salesQty - 2);
                    discountAmount = discountQty * unitCost;
                }

                values.Add(discountQty.ToString());
                values.Add(discountAmount.ToString());

                // Total Cost
                values.Add((salesAmount - returnAmount - discountAmount).ToString());

                // Unit Cost
                values.Add((unitCost - 20).ToString());

                // Unit Price
                values.Add(unitCost.ToString());

                // ETL Load Id
                values.Add("0");

                // Load Date
                values.Add("1899-12-30 00:00:00.000");

                // Update Date
                values.Add("1899-12-30 00:00:00.000");

                #endregion

                OnWriteDataToFile(string.Join("\t", values));
            }
            while (internalLineCount <= _targetLineCount);
        }

        #endregion
    }
}