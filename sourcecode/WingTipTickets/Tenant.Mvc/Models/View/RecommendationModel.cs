using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tenant.Mvc.Models.View
{
    public class RecommendationModel
    {
        public RecommendationModel(string recommendationSiteUrl)
        {
            RecommendationSiteUrl = recommendationSiteUrl;
        }

        public string RecommendationSiteUrl { get; private set; }

    }
}