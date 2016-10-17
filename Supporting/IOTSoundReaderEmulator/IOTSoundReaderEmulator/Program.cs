using System;
using System.Collections.Generic;
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
			_senders = new List<ISender>
			{
				new EventHubSender(),
				new DocumentDbSender()
			};

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
			int deviceId = rnd.Next(1, 1001); //DeviceId: Random between 1 & 1000

            //get decibelLevel
            int decibelLevel;
            DateTime currentDateTime = DateTime.UtcNow;
            var currentMinute = currentDateTime.Minute;
            if (currentMinute >= 15 && currentMinute <= 25 && deviceId % 2 == 0)
            {
                decibelLevel = rnd.Next(120, 141); //DecibelLevel: Random between 120 & 140
            }
            else if (currentMinute >= 25 && currentMinute <= 35 && deviceId % 3 == 0)
            {
                decibelLevel = rnd.Next(40, 61); //DecibelLevel: Random between 40 & 60
            }
            else if (currentMinute >= 35 && currentMinute <= 45 && deviceId % 5 == 0)
            {
                decibelLevel = rnd.Next(120, 141); //DecibelLevel: Random between 120 & 140
            }
            else
            {
                decibelLevel = rnd.Next(80, 101); //DecibelLevel: Random between 80 & 100
            }

            decimal longitude = 0;
            decimal latitude = 0;

			//get venue details from repo
			var venueModel = _venueRepository.GetVenueInformation(venueId);
		    if (venueModel != null)
		    {
                longitude = venueModel.Longitude;
                latitude = venueModel.Latitude;
            }

            SoundRecord soundRecord = new SoundRecord
			{
				DateTime = currentDateTime.ToString("o"),
				Location = new SoundRecord.GeoLocation()
				{
					Type = "Point",
					Coordinates = new List<decimal>()
					{
						longitude,
						latitude
					}
				},
				DecibelLevel = decibelLevel,
				DeviceId = deviceId,
				VenueId = venueId
			};

			return soundRecord;
		}
	}
}

