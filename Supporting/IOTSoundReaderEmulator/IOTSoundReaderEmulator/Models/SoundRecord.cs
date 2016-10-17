using System;
using System.Collections.Generic;

namespace IOTSoundReaderEmulator.Models
{
	public class SoundRecord
	{
		public int VenueId { get; set; }
		public int DeviceId { get; set; }
		public GeoLocation Location { get; set; }
		public string DateTime { get; set; }
		public decimal DecibelLevel { get; set; }

		public class GeoLocation
		{
			public string Type { get; set; }
			public List<decimal> Coordinates { get; set; }
		}
	}
}
