using System;
using System.Collections.Generic;
using System.Configuration;
using System.Windows;
using ElasticPoolLoadGenerator.Forms;
using ElasticPoolLoadGenerator.Helpers;
using ElasticPoolLoadGenerator.Models;
using Microsoft.Practices.EnterpriseLibrary.TransientFaultHandling;

namespace ElasticPoolLoadGenerator
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);

            // Get Values
            var primaryDatabase = ConfigHelper.PrimaryDatabase;
            var secondaryDatabase = ConfigHelper.SecondaryDatabase;
            var username = ConfigHelper.Username;
            var password = ConfigHelper.Password;
            var batchSize = ConfigHelper.BatchSize;


            // Create empty model
            var viewModel = new MainViewModel("", primaryDatabase, secondaryDatabase, username, password, batchSize);

            // Display the Main Form
            var main = new MainWindow()
            {
                DataContext = viewModel,
            };

            main.Show();
        }
    }
}
