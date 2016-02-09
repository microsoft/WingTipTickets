using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using Microsoft.SqlServer.Server;

namespace DataCleaner
{
    internal abstract class FileGenerator
    {
        #region - Fields -

        private static string _filePath;

        #endregion

        #region - Properties -

        protected List<List<string>> Lines;

        public string Description { get; set; }

        public string FileName { get; set; }

        public string FilePath
        {
            get
            {
                return Path.Combine(_filePath, FileName);
            }
        }

        #endregion

        #region - Constructors -

        static FileGenerator()
        {
            _filePath = @"C:\";
        }

        #endregion

        #region - Public Methods -

        public virtual void Generate()
        {
            using (var file = new StreamWriter(FilePath))
            {
                foreach (var lineValues in Lines)
                {
                    var counter = 0;

                    foreach (var value in lineValues)
                    {
                        file.Write(value);

                        if (counter != lineValues.Count - 1)
                        {
                            file.Write("\t");
                        }
                        else
                        {
                            file.WriteLine("");
                        }

                        counter++;
                    }
                }
            }
        }

        public virtual void GzipFile()
        {
            using (var fileStream = File.OpenRead(FilePath))
            {
                using (var compressedFileStream = File.Create(FilePath + ".gz"))
                {
                    using (var compressionStream = new GZipStream(compressedFileStream, CompressionMode.Compress))
                    {
                        fileStream.CopyTo(compressionStream);
                    }
                }
            }
        }

        public List<string> GetKeys()
        {
            var keys = new List<string>(Lines.Select(t => t.First()));
            keys.RemoveAll(string.IsNullOrEmpty);

            return keys;
        }

        public Dictionary<string, int> GetWeightedKeys()
        {
            var weight = 0;
            var random = new Random((int)DateTime.Now.Ticks);
            var weights = new List<int>() { 5, 30, 20, 2, 30, 15, 18, 30, 24, 30, 10, 18, 15, 10, 30, 2, 30, 20, 10, 13, 17, 25 };

            var keys = Lines.ToDictionary(line => line.First(), line => weights[random.Next(0, weights.Count)]);

            var distinctRanges = keys.Select(k => k.Value).Distinct();

            return keys;
        }

        public static void SetFilePath(string filePath)
        {
            _filePath = filePath;
        }

        #endregion

        #region - Protected Methods -

        protected void LoadDataFromResource(string resourceText)
        {
            // Remove new lines
            resourceText = resourceText.Replace("\n", "");

            // Split on return
            var splitLines = resourceText.Split('\r').ToList();

            // Split on tabs
            Lines = new List<List<string>>();
            splitLines.ForEach(l => Lines.Add(new List<string>(l.Split('\t'))));
        }

        #endregion
    }
}