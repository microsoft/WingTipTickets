using System;

namespace Tenant.Mvc.Core.Models
{
    public class Product
    {
        #region - Properties -

        public Int64 Id;

        public string Name;

        public string Description;

        public string Title1;

        public string Title2;

        public int TitlesCount;

        public int Price;

        public int PlayCount { get; set; }

        #endregion
    }
}
