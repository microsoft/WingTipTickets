using System.Collections.Generic;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Interfaces.Tenant
{
    public interface ICityRepository : IBaseRepository
    {
        List<CityModel> GetCities();
        CityModel GetCityById(int cityId);
        CityModel GetCityByName(string cityName);
        CityModel AddNewCity(string cityName, string cityDescription = "", string cityState = "");
    }
}