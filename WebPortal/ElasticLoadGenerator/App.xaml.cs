using System.Windows;
using ElasticLoadGenerator.Forms;
using ElasticLoadGenerator.Helpers;
using ElasticLoadGenerator.Models;

namespace ElasticLoadGenerator
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
