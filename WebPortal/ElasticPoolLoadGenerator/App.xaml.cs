using System.Windows;
using ElasticPoolLoadGenerator.Forms;
using ElasticPoolLoadGenerator.Helpers;
using ElasticPoolLoadGenerator.Models;

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

            // Create empty model
            var viewModel = new MainViewModel("", ConfigHelper.PrimaryDatabase, ConfigHelper.SecondaryDatabase, ConfigHelper.Username, ConfigHelper.Password, ConfigHelper.BatchSize);

            // Display the Main Form
            var main = new MainWindow()
            {
                DataContext = viewModel
            };

            main.Show();
        }
    }
}
