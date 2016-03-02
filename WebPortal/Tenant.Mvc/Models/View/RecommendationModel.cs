namespace Tenant.Mvc.Models.View
{
    public class RecommendationModel
    {
        #region - Properties -

        public string RecommendationSiteUrl { get; private set; }

        #endregion

        #region - Constructors -

        public RecommendationModel(string recommendationSiteUrl)
        {
            RecommendationSiteUrl = recommendationSiteUrl;
        }

        #endregion
    }
}