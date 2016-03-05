using DataCleaner.Properties;

namespace DataCleaner
{
    class GenerateCustomerFile : FileGenerator
    {
        public GenerateCustomerFile()
        {
            Description = "Customer";
            FileName = "DimCustomer.txt";
            LoadDataFromResource(Resources.DimCustomer);
        }
    }
}


