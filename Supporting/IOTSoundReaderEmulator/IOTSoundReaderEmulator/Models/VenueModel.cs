namespace IOTSoundReaderEmulator.Models
{
    public class VenueModel
    {
        #region - Properties -

        public int VenueId { get; set; }
        public string VenueName { get; set; }
        public string CityName { get; set; }
        public decimal Longitude { get; set; }
        public decimal Latitude { get; set; }

        #endregion
    }
}
