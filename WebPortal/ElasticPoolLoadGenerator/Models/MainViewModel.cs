using System;
using System.ComponentModel;
using System.Windows.Input;
using ElasticPoolLoadGenerator.Commands;
using ElasticPoolLoadGenerator.Components;

namespace ElasticPoolLoadGenerator.Models
{
    public class MainViewModel : INotifyPropertyChanged
    {
        #region - Fields -

        private string _databaseServer;
        private string _primaryDatabase;
        private string _secondaryDatabase;
        private string _username;
        private string _password;

        private int _bulkPurchaseQty;
        private int _ticketsPurchased;
        private double _purchasesPerSecond;
        private int _progressValue;

        private string _loadingDatabase;
        private string _statusText;
        private string _startText;
        private bool _startEnabled;

        private TimeSpan _duration;

        #endregion

        #region - Properties -

        public DatabaseLoader DatabaseLoader { get; set; }
        public ICommand PurchaseTicketsCommand { get; set; }

        public string DatabaseServer
        {
            get { return _databaseServer; }
            set { SetValue(value, ref _databaseServer, "DatabaseServer"); }
        }

        public string PrimaryDatabase
        {
            get { return _primaryDatabase; }
            set { SetValue(value, ref _primaryDatabase, "PrimaryDatabase"); }
        }

        public string SecondaryDatabase
        {
            get { return _secondaryDatabase; }
            set { SetValue(value, ref _secondaryDatabase, "SecondaryDatabase"); }
        }

        public string Username
        {
            get { return _username; }
            set { SetValue(value, ref _username, "Username"); }
        }

        public string Password
        {
            get { return _password; }
            set { SetValue(value, ref _password, "Password"); }
        }

        public int BulkPurchaseQty
        {
            get { return _bulkPurchaseQty; }
            set { SetValue(value, ref _bulkPurchaseQty, "BulkPurchaseQty"); }
        }

        public int TicketsPurchased
        {
            get { return _ticketsPurchased; }
            set { SetValue(value, ref _ticketsPurchased, "TicketsPurchased"); }
        }

        public double PurchasesPerSecond
        {
            get { return _purchasesPerSecond; }
            set { SetValue(value, ref _purchasesPerSecond, "PurchasesPerSecond"); }
        }

        public int ProgressValue
        {
            get { return _progressValue; }
            set { SetValue(value, ref _progressValue, "ProgressValue"); }
        }

        public string LoadingDatabase
        {
            get { return _loadingDatabase; }
            set { SetValue(value, ref _loadingDatabase, "LoadingDatabase"); }
        }

        public string StatusText
        {
            get { return _statusText; }
            set { SetValue(value, ref _statusText, "StatusText"); }
        }

        public string StartText
        {
            get { return _startText; }
            set { SetValue(value, ref _startText, "StartText"); }
        }

        public bool StartEnabled
        {
            get { return _startEnabled; }
            set { SetValue(value, ref _startEnabled, "StartEnabled"); }
        }

        public TimeSpan Duration
        {
            get { return _duration; }
            set { SetValue(value, ref _duration, "Duration"); }
        }

        #endregion

        #region - Constructors -

        public MainViewModel(string databaseServer, string primaryDatabase, string secondaryDatabase, string username, string password, int bulkPurchaseQty)
        {
            // Setup Fields
            _databaseServer = databaseServer;
            _primaryDatabase = primaryDatabase;
            _secondaryDatabase = secondaryDatabase;
            _username = username;
            _password = password;

            _bulkPurchaseQty = bulkPurchaseQty;
            _ticketsPurchased = 0;
            _purchasesPerSecond = 0;
            _progressValue = 0;

            _duration = new TimeSpan();
            _statusText = "";
            _loadingDatabase = "";
            _startText = "Start";
            _startEnabled = true;

            // Setup Commands
            PurchaseTicketsCommand = new PurchaseTicketsCommand(this);

            // Setup Workers
            DatabaseLoader = new DatabaseLoader(this);
        }

        #endregion

        #region - Private Methods -

        private void SetValue<T>(T value, ref T field, string propertyName)
        {
            if (value.ToString() == field.ToString())
            {
                return;
            }

            field = value;

            OnPropertyChanged(propertyName);
        }

        #endregion

        #region - INotifyPropertyChanged Implementation -

        public event PropertyChangedEventHandler PropertyChanged;

        protected virtual void OnPropertyChanged(string propertyName)
        {
            if (PropertyChanged != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
            }
        }

        #endregion
    }
}
