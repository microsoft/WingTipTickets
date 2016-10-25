using System;
using System.Collections.Generic;
using Newtonsoft;
using Newtonsoft.Json;

namespace IOTSoundReaderEmulator.Models
{
	public class SoundRecord
	{
		public int VenueId { get; set; }
		public int DeviceId { get; set; }
        public int Seat { get; set; }
        public int SeatSection { get; set; }
        public GeoLocation Location { get; set; }
		public string DateTime { get; set; }
		public decimal DecibelLevel { get; set; }
      

        public class GeoLocation
		{
            [JsonProperty("type")]
            public string Type { get; set; }
            [JsonProperty("coordinates")]
            public List<decimal> Coordinates { get; set; }
		}
	}
}
