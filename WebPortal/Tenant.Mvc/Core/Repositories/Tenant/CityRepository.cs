using System.Collections.Generic;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Repositories.Tenant
{
    public class CityRepository : BaseRepository, ICityRepository
    {
        #region - Implementation -

        public List<CityModel> GetCities()
        {
            return Context.Venues.GetCities();
        }

        public CityModel GetCityById(int cityId)
        {
            return Context.Venues.GetCityById(cityId);
        }

        public CityModel GetCityByName(string cityName)
        {
            return Context.Venues.GetCityByName(cityName);
        }

        public CityModel AddNewCity(string cityName, string cityDescription = "", string cityState = "")
        {
            return Context.Venues.AddNewCity(cityName, cityDescription, cityState);
        }

        #endregion
    }
}