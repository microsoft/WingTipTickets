using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;

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