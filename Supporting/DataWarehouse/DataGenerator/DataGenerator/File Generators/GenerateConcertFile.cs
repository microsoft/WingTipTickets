using System;
using System.Collections.Generic;

namespace DataCleaner
{
    class GenerateConcertFile : FileGenerator
    {
        public GenerateConcertFile()
        {
            Description = "Concert";
            FileName = "DimConcert.txt";
            AddData();
        }

        private void AddData()
        {
            Lines = new List<List<String>>()
            {
                new List<string>()
                {
                    "2", "Julie and the Plantes Illumination Tour", "", "2015-12-04 19:31:04.620", "3", "3", "1"
                },
                new List<string>()
                {
                    "3", "Julie and the Plantes Illumination Tour", "", "2015-12-05 19:31:04.620", "3", "4", "1"
                },
                new List<string>()
                {
                    "4", "Julie and the Plantes Illumination Tour", "", "2015-12-06 19:31:04.620", "3", "5", "1"
                },
                new List<string>()
                {
                    "5", "Julie and the Plantes Illumination Tour", "", "2015-12-07 19:31:04.620", "3", "6", "1"
                },
                new List<string>()
                {
                    "6", "Julie and the Plantes Illumination Tour", "", "2015-12-08 19:31:04.620", "3", "7", "1"
                },
                new List<string>()
                {
                    "7", "Julie and the Plantes Illumination Tour", "", "2015-12-09 19:31:04.620", "3", "8", "1"
                },
                new List<string>()
                {
                    "8", "Julie and the Plantes Illumination Tour", "", "2015-12-10 19:31:04.620", "3", "9", "1"
                },
                new List<string>()
                {
                    "9", "Julie and the Plantes Illumination Tour", "", "2015-12-11 19:31:04.620", "3", "10", "1"
                },
                new List<string>()
                {
                    "10", "Julie and the Plantes Illumination Tour", "", "2015-12-12 19:31:04.620", "3", "11", "1"
                },
                new List<string>()
                {
                    "11", "Julie and the Plantes Illumination Tour", "", "2015-12-13 19:31:04.620", "3", "12", "1"
                },
                new List<string>()
                {
                    "12", "Julie and the Plantes Illumination Tour", "", "2015-12-14 19:31:04.620", "3", "13", "1"
                },
                new List<string>()
                {
                    "13", "Julie and the Plantes Illumination Tour", "", "2015-12-15 19:31:04.620", "3", "14", "1"
                },
                new List<string>()
                {
                    "14", "Mozart Violin Concerto No. 5", "", "2015-12-04 19:31:04.620", "3", "3", "2"
                },
                new List<string>()
                {
                    "15", "Bach Violin Concerto in A minor", "", "2015-12-05 19:31:04.620", "3", "4", "2"
                },
                new List<string>()
                {
                    "16", "Mozart Violin Concerto No. 3", "", "2015-12-06 19:31:04.620", "3", "5", "2"
                },
                new List<string>()
                {
                    "17", "Tchaikovsky Violin Concerto, Op. 35", "", "2015-12-07 19:31:04.620", "3", "6", "2"
                },
                new List<string>()
                {
                    "18", "Brahms Symphony No. 4", "", "2015-12-05 19:31:04.620", "3", "7", "2"
                },
                new List<string>()
                {
                    "19", "Tchaikovsky Symphony No. 6", "", "2015-12-06 19:31:04.620", "3", "8", "2"
                },
                new List<string>()
                {
                    "20", "Rachmaninov Symphony No. 2", "", "2015-12-07 19:31:04.620", "3", "9", "2"
                },
                new List<string>()
                {
                    "21", "Beethoven Piano Concerto No. 5", "", "2015-12-08 19:31:04.620", "3", "10", "2"
                },
                new List<string>()
                {
                    "22", "Mozart Piano Sonata No. 16", "", "2015-12-09 19:31:04.620", "3", "11", "2"
                },
                new List<string>()
                {
                    "23", "Beethoven Piano Concerto No. 1", "", "2015-12-10 19:31:04.620", "3", "12", "2"
                },
                new List<string>()
                {
                    "24", "Chopin Nocturnes", "", "2015-12-11 19:31:04.620", "3", "3", "3"
                },
                new List<string>()
                {
                    "25", "Chopin Nocturnes", "", "2015-12-12 19:31:04.620", "3", "4", "3"
                },
                new List<string>()
                {
                    "26", "Archie Boyle Live", "", "2015-12-04 19:31:04.620", "3", "5", "3"
                },
                new List<string>()
                {
                    "27", "Archie Boyle Live", "", "2015-12-05 19:31:04.620", "3", "6", "3"
                },
                new List<string>()
                {
                    "28", "Archie Boyle Live", "", "2015-12-06 19:31:04.620", "3", "7", "3"
                },
                new List<string>()
                {
                    "29", "Archie Boyle Live", "", "2015-12-07 19:31:04.620", "3", "8", "3"
                },
                new List<string>()
                {
                    "30", "Archie Boyle Live", "", "2015-12-08 19:31:04.620", "3", "9", "3"
                },
                new List<string>()
                {
                    "31", "Archie Boyle Live", "", "2015-12-09 19:31:04.620", "3", "10", "3"
                },
                new List<string>()
                {
                    "32", "Archie Boyle Live", "", "2015-12-10 19:31:04.620", "3", "11", "3"
                },
                new List<string>()
                {
                    "33", "Archie Boyle Live", "", "2015-12-11 19:31:04.620", "3", "12", "3"
                },
                new List<string>()
                {
                    "34", "Archie Boyle Live", "", "2015-12-12 19:31:04.620", "3", "3", "3"
                },
                new List<string>()
                {
                    "35", "Archie Boyle Live", "", "2015-12-13 19:31:04.620", "3", "4", "3"
                },
                new List<string>()
                {
                    "52", "Archie Boyle Live", "", "2015-12-14 19:31:04.620", "3", "5", "3"
                },
                new List<string>()
                {
                    "53", "Archie Boyle Live", "", "2015-12-15 19:31:04.620", "3", "6", "3"
                },
            };
        }
    }
}


