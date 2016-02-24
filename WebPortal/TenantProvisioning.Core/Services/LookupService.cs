using System.Collections.Generic;
using System.Data;
using System.Linq;
using TenantProvisioning.Core.Models;
using TenantProvisioning.Core.Repositories;

namespace TenantProvisioning.Core.Services
{
    public class LookupService
    {
        #region - Public Methods -

        public List<LookupModel> FetchProvisioningOptions()
        {
            // Create repository
            var optionRepository = new ProvisioningOptionRepository();

            // FetchById the themes
            var themes = optionRepository.FetchAll();

            // Build the return model
            var list =
            (
                from DataRow row in themes.Rows
                select new LookupModel()
                {
                    Id = (int)row["ProvisioningOptionId"],
                    Code = row["Code"].ToString(),
                    Description = row["Description"].ToString()
                }
            ).ToList();

            return list;
        }

        public List<LookupModel> FetchThemes()
        {
            // Create repository
            var themeRepository = new ThemeRepository();

            // FetchById the themes
            var themes = themeRepository.FetchAll();

            // Build the return model
            var list =
            (
                from DataRow row in themes.Rows
                select new LookupModel()
                {
                    Id = (int)row["ThemeId"],
                    Code = row["Code"].ToString(),
                    Description = row["Description"].ToString(),
                    SiteName = row["SiteName"].ToString()
                }
            ).ToList();

            // Add empty item
            list.Insert(0, new LookupModel()
            {
                Id = null,
                Code = null,
                Description = "Site Theme"
            });

            return list;
        }

        #endregion
    }
}
