using System;
using System.Collections.Generic;
using System.Globalization;
using System.Threading;
using IOTSoundReaderEmulator.Interfaces;
using IOTSoundReaderEmulator.Models;
using IOTSoundReaderEmulator.Repositories;
using IOTSoundReaderEmulator.Senders;

namespace IOTSoundReaderEmulator
{
    internal class Program
    {
        private static VenueRepository _venueRepository;
        private static List<ISender> _senders;

        private static void Main(string[] args)
        {
            _venueRepository = new VenueRepository();
            _senders = new List<ISender> {new EventHubSender(), new DocumentDbSender()};

            while (true) //loop forever
            {
                // Generate a random sleep time. 
                // To fake iot devices are random intervals pick up sounds
                Random rnd = new Random();
                var sleepTime = rnd.Next(500, 2000);
                Thread.Sleep(sleepTime);

                var soundRecord = GetSoundLevel();

                foreach (var sender in _senders)
                {
                    sender.SendInfo(soundRecord);
                }
            }
        }



        private static SoundRecord GetSoundLevel()
        {
            Random rnd = new Random();
            int venueId = rnd.Next(1, 13); //VenueId: Random between 1 & 12
            int deviceId = rnd.Next(1, 5); //DeviceId: Random between 1 & 4
            int decibelLevel = rnd.Next(60, 131); //DecibelLevel: Random between 60 & 130

            string dateTime = DateTime.Now.ToString("M/d/yyyy h:mm:ss tt", CultureInfo.InvariantCulture); //DateTime: Current date and time e.g "9/14/2016 10:25:34 PM"
            string longitude = "";
            string latitude = "";

            //get venue details from repo
            var venueModel = _venueRepository.GetVenueInformation(venueId);
            if (!string.IsNullOrEmpty(venueModel.Longitude))
            {
                longitude = venueModel.Longitude;
            }
            if (!string.IsNullOrEmpty(venueModel.Latitude))
            {
                latitude = venueModel.Latitude;
            }

            SoundRecord soundRecord = new SoundRecord
            {
                DateTime = dateTime,
                Latitude = latitude,
                Longitude = longitude,
                DecibelLevel = decibelLevel,
                DeviceId = deviceId,
                VenueId = venueId
            };

            return soundRecord;
        }

    }
}
