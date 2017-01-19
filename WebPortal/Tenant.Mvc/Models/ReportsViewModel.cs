using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;
using Microsoft.PowerBI.Api.V1.Models;
using Newtonsoft.Json;

namespace Tenant.Mvc.Models
{
    public class ReportsViewModel
    {
        #region - Properties -

        public SelectList Reports { get; set; }
        public Guid SelectedReportId { get; set; }

        public Report Report { get; set; }
        public string AccessToken { get; set; }

        #endregion
    }
}