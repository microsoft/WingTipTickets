using System;

namespace ElasticPoolLoadGenerator.Interfaces
{
    public interface IDatabaseLoader
    {
        bool IsSleeping { get; set; }
        event EventHandler NotifyDoneSleeping;

        void Start();
        void Stop();
        void Continue();
    }
}