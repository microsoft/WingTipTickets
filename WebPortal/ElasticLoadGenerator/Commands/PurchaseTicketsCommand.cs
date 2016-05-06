using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Windows.Input;
using ElasticPoolLoadGenerator.Components;
using ElasticPoolLoadGenerator.Helpers;
using ElasticPoolLoadGenerator.Interfaces;
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
                _model.DatabaseLoaders.ForEach(l => l.Start());
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
                _model.DatabaseLoaders.ForEach(l => l.Stop());
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
            _model.DatabaseLoaders = new List<IDatabaseLoader>();

            Type loaderType = null;
            DataTable data = null;

            if (_model.IsDualDatabaseLoad)
            {
                var qty = _model.BulkPurchaseQty + (_model.BulkPurchaseQty / 3);

                data = DatabaseHelper.BuildBatchData(qty);
                loaderType = typeof(DualDatabaseLoader);
            }
            else
            {
                var qty = _model.BulkPurchaseQty;
                
                data = DatabaseHelper.BuildBatchData(qty);
                loaderType = typeof(SingleDatabaseLoader);
            }

            for (var i = 0; i < ConfigHelper.Loaders; i++)
            {
                var loader = (IDatabaseLoader)Activator.CreateInstance(loaderType, _model, data);
                loader.NotifyDoneSleeping += LoaderDoneSleeping;

                _model.DatabaseLoaders.Add(loader);
            }
        }

        void LoaderDoneSleeping(object sender, EventArgs e)
        {
            if (_model.DatabaseLoaders.All(l => !l.IsSleeping))
            {
                _model.DatabaseLoaders.ForEach(l => l.Continue());
            }
        }

        #endregion

        
    }
}
