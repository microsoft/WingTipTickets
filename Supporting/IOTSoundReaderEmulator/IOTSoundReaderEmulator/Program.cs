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
        #region - Fields -

        private static VenueRepository _venueRepository;
	    private static SeatSectionRepository _seatSectionRepository;
		private static List<ISender> _senders;
        private static Random _rnd;

        #endregion

	    #region - Main Method -

	    private static void Main(string[] args)
	    {
	        _venueRepository = new VenueRepository();
	        _seatSectionRepository = new SeatSectionRepository();

	        _senders = new List<ISender>
	        {
	            new EventHubSender(),
	            new DocumentDbSender()
	        };
	        
	        while (true)
	        {
	            // Generate a random sleep time. 
	            // To fake iot devices are random intervals pick up sounds
	            _rnd = new Random();
	            var sleepTime = _rnd.Next(10, 20);
	            Thread.Sleep(sleepTime);

	            var soundRecord = GetSoundLevel();
                
	            foreach (var sender in _senders)
	            {
	                sender.SendInfo(soundRecord);
	            }
	        }
	    }

	    #endregion

	    #region - Private Methods -

	    private static SoundRecord GetSoundLevel()
	    {
	        int venueId = _rnd.Next(1, 13);
	        int sectionNumber = _rnd.Next(1, 11);
	        int seatSectionId = ((venueId - 1)*10) + sectionNumber;

	        // Read SeatCount from SeatSection table for calculated SectionId
	        int seatCount = _seatSectionRepository.GetSeatCount(seatSectionId);

	        // Generate a SeatNumber between 1 and SeatCount read above
	        int seatNumber = _rnd.Next(1, seatCount + 1);
	        int deviceId = seatNumber + _seatSectionRepository.CalculateSum(venueId, seatSectionId);

	        DateTime currentDateTime = DateTime.UtcNow;
	        int decibelLevel = GetDecibelLevel(currentDateTime.Minute, deviceId);
            
	        decimal longitude = 0;
	        decimal latitude = 0;

	        // Get venue details from repo
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
	            VenueId = venueId,
	            Seat = seatNumber,
	            SeatSection = sectionNumber
            };

	        return soundRecord;
	    }

	    private static int GetDecibelLevel(int currentMinute, int deviceId)
	    {
	        int decibelLevel;

	        if (currentMinute >= 15 && currentMinute <= 25 && deviceId % 2 == 0)
	        {
	            decibelLevel = _rnd.Next(120, 141); 
	        }
	        else if (currentMinute >= 25 && currentMinute <= 35 && deviceId % 3 == 0)
	        {
	            decibelLevel = _rnd.Next(40, 61); 
	        }
	        else if (currentMinute >= 35 && currentMinute <= 45 && deviceId % 5 == 0)
	        {
	            decibelLevel = _rnd.Next(120, 141); 
	        }
	        else
	        {
	            decibelLevel = _rnd.Next(80, 101); 
	        }

	        return decibelLevel;
	    }

	    #endregion
    }
}

