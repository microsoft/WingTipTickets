using System;
using System.Collections.Generic;

namespace IOTSoundReaderEmulator.Models
{
    public class SoundRecord
    {
        public int VenueId { get; set; }
        public int DeviceId { get; set; }
        public GeoLocation Location { get; set; }
        public DateTime DateTime { get; set; }
        public decimal DecibelLevel { get; set; }
        
        public class GeoGeometry
        {
            public string Type { get; set; }
            public List<string>  Coordinates { get; set; }
        }

        public class GeoLocation
        {
            public string Type { get; set; }
            public GeoGeometry Geometry { get; set; }
        }
    }
}
