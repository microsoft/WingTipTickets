using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Windows.Input;
using ElasticPoolLoadGenerator.Commands;
using ElasticPoolLoadGenerator.Helpers;
using ElasticPoolLoadGenerator.Interfaces;

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

        private int _concertId;
        private int _ticketLevelId;
        private int _customerId;

        private int _bulkPurchaseQty;
        private int _ticketsPurchased;
        private double _purchasesPerSecond;
        private int _progressValue;

        private string _loadingDatabase;
        private string _statusText;
        private string _startText;
        private bool _fieldsEnabled;
        private bool _isDualDatabaseLoad;

        private TimeSpan _duration;
        private List<LookupViewModel> _concerts;
        private List<LookupViewModel> _ticketLevels;
        private List<LookupViewModel> _customers;


        #endregion


        #region - Miscelaneous Properties -

        public List<IDatabaseLoader> DatabaseLoaders { get; set; }

        public ICommand PurchaseTicketsCommand { get; set; }

        #endregion

        #region - Collection Properties -

        public List<LookupViewModel> Concerts
        {
            get { return _concerts; }
            set
            {
                if (_concerts != value)
                {
                    _concerts = value;
                    OnPropertyChanged("Concerts");
                }
            }
        }

        public List<LookupViewModel> TicketLevels
        {
            get { return _ticketLevels; }
            set
            {
                if (_ticketLevels != value)
                {
                    _ticketLevels = value;
                    OnPropertyChanged("TicketLevels");
                }
            }
        }

        public List<LookupViewModel> Customers
        {
            get { return _customers; }
            set
            {
                if (_customers != value)
                {
                    _customers = value;
                    OnPropertyChanged("Customers");
                }
            }
        }

        #endregion

        #region - Binding Properties -

        public string DatabaseServer
        {
            get { return _databaseServer; }
            set
            {
                SetValue(value, ref _databaseServer, "DatabaseServer");
                UpdateAllDropDowns();
            }
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

        public int ConcertId
        {
            get { return _concertId; }
            set
            {
                SetValue(value, ref _concertId, "ConcertId");
                UpdateConcertDropDown();
            }
        }

        public int TicketLevelId
        {
            get { return _ticketLevelId; }
            set { SetValue(value, ref _ticketLevelId, "TicketLevelId"); }
        }

        public int CustomerId
        {
            get { return _customerId; }
            set { SetValue(value, ref _customerId, "CustomerId"); }
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

        public bool FieldsEnabled
        {
            get { return  _fieldsEnabled; }
            set { SetValue(value, ref _fieldsEnabled, "FieldsEnabled"); }
        }

        public TimeSpan Duration
        {
            get { return _duration; }
            set { SetValue(value, ref _duration, "Duration"); }
        }

        public bool IsDualDatabaseLoad
        {
            get { return _isDualDatabaseLoad; }
            set { SetValue(value, ref _isDualDatabaseLoad, "IsDualDatabaseLoad"); }
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
            _fieldsEnabled = true;
            _isDualDatabaseLoad = false;

            // Setup Commands & Collections
            PurchaseTicketsCommand = new PurchaseTicketsCommand(this);

            _concerts = new List<LookupViewModel>();
            _ticketLevels = new List<LookupViewModel>();
            _customers = new List<LookupViewModel>();
        }

        #endregion


        #region - Private Methods -

        private void UpdateAllDropDowns()
        {
            try
            {
                // Create Connection string & Update drop downs
                var connectionString = DatabaseHelper.ConstructConnectionString(DatabaseServer, PrimaryDatabase, Username, Password);

                Concerts = DatabaseHelper.GetConcerts(connectionString);
                TicketLevels = DatabaseHelper.GetTicketLevels(connectionString, ConcertId);
                Customers = DatabaseHelper.GetCustomers(connectionString);
            }
            catch
            {
                LoadingDatabase = "Could not Connect!";
            }
        }

        private void UpdateConcertDropDown()
        {
            try
            {
                // Create Connection string & Update drop downs
                var connectionString = DatabaseHelper.ConstructConnectionString(DatabaseServer, PrimaryDatabase, Username, Password);

                TicketLevels = DatabaseHelper.GetTicketLevels(connectionString, ConcertId);
            }
            catch
            {
                LoadingDatabase = "Could not Connect!";
            }
        }

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
