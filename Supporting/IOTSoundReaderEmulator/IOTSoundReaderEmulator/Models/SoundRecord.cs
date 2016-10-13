using System;

namespace IOTSoundReaderEmulator.Models
{
    public class SoundRecord
    {
        public int VenueId { get; set; }
        public int DeviceId { get; set; }
        public string Longitude { get; set; }
        public string Latitude { get; set; }
        public DateTime DateTime { get; set; }
        public decimal DecibelLevel { get; set; }
    }
}
