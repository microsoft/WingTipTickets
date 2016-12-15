using IOTSoundReaderEmulator.Models;

namespace IOTSoundReaderEmulator.Interfaces
{
    public interface ISender
    {
        void SendInfo(SoundRecord soundRecord);
    }
}
