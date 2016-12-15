using System;
using System.Text;
using IOTSoundReaderEmulator.Interfaces;
using IOTSoundReaderEmulator.Models;
using Microsoft.ServiceBus.Messaging;
using Newtonsoft.Json;

namespace IOTSoundReaderEmulator.Senders
{
    public class EventHubSender : ISender
    {
        #region - Public Methods -

        public void SendInfo(SoundRecord soundRecord)
        {
            var eventHubClient = EventHubClient.CreateFromConnectionString(CloudConfiguration.EventHubConnString, CloudConfiguration.EventHubName);

            try
            {
                var jsonData = JsonConvert.SerializeObject(soundRecord);
                Console.WriteLine("{0} > Sending message to Event Hub: {1}", DateTime.Now, jsonData);
                eventHubClient.Send(new EventData(Encoding.UTF8.GetBytes(jsonData)));
            }
            catch (Exception exception)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("{0} > Exception: {1}", DateTime.Now, exception.Message);
                Console.ResetColor();
            }
        }

        #endregion
    }
}
