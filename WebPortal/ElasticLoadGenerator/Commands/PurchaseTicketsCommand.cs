using System;
using System.Windows.Input;
using ElasticPoolLoadGenerator.Components;
using ElasticPoolLoadGenerator.Models;

namespace ElasticPoolLoadGenerator.Commands
{
    public class PurchaseTicketsCommand : ICommand
    {
        #region - Fields -

        private readonly MainViewModel _model;

        #endregion

        #region - Constructors -

        public PurchaseTicketsCommand(MainViewModel model)
        {
            // Setup the Fields
            _model = model;
        }

        #endregion

        #region - Command Methods -

        public bool CanExecute(object parameter)
        {
            return
                !string.IsNullOrEmpty(_model.DatabaseServer) &&
                !string.IsNullOrEmpty(_model.PrimaryDatabase) &&
                !string.IsNullOrEmpty(_model.SecondaryDatabase) &&
                !string.IsNullOrEmpty(_model.Username) &&
                !string.IsNullOrEmpty(_model.Password) &&
                _model.ConcertId != 0 &&
                _model.TicketLevelId != 0 &&
                _model.CustomerId != 0 &&
                _model.BulkPurchaseQty > 0;
        }

        public void Execute(object parameter)
        {
            if (_model.StartText.Equals("Start"))
            {
                // Setup Workers
                CreateDatabaseLoader();

                // Update model
                _model.FieldsEnabled = false;
                _model.StartText = "Stop";
                _model.LoadingDatabase = "";

                // Start the loader
                _model.DatabaseLoader.Start();
            }
            else
            {
                // Update model
                _model.FieldsEnabled = true;
                _model.StartText = "Start";
                _model.LoadingDatabase = "";

                // Flip the CheckBox
                _model.IsDualDatabaseLoad = !_model.IsDualDatabaseLoad;

                // Stop the loader
                _model.DatabaseLoader.Stop();
            }
        }

        public event EventHandler CanExecuteChanged
        {
            add { CommandManager.RequerySuggested += value; }
            remove { CommandManager.RequerySuggested -= value; }
        }

        #endregion

        #region - Private Methods -

        public void CreateDatabaseLoader()
        {
            if (_model.IsDualDatabaseLoad)
            {
                _model.DatabaseLoader = new DualDatabaseLoader(_model);
            }
            else
            {
                _model.DatabaseLoader = new SingleDatabaseLoader(_model);
            }
        }

        #endregion

        
    }
}
