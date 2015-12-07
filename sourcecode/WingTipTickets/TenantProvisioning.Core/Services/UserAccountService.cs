using TenantProvisioning.Core.Models;
using TenantProvisioning.Core.Repositories;

namespace TenantProvisioning.Core.Services
{
    public class UserAccountService
    {
        #region - Public Methods -

        public UserAccountModel FetchByUsername(string username)
        {
            // Create repository
            var userAccountRepository = new UserAccountRepository();

            // Find the user
            var user = userAccountRepository.Fetch(username);

            return user;
        }

        public void UpdatePersonalDetails(string username, string firstname, string lastname)
        {
            // Create repositories
            var userAccountRepository = new UserAccountRepository();

            // Create the UserAccount
            userAccountRepository.UpdatePesonalDetails(username, firstname, lastname);
        }

        public void UpdateCacheData(UserAccountModel domainModel)
        {
            // Create repositories
            var userAccountRepository = new UserAccountRepository();

            // Create the UserAccount
            userAccountRepository.UpdateCacheData(domainModel);
        }

        public int Create(CreateUserAccountModel domainModel)
        {
            // Create repositories
            var userAccountRepository = new UserAccountRepository();

            // Create the UserAccount
            var userAccountId = userAccountRepository.Insert(domainModel);

            return userAccountId;
        }

        #endregion
    }
}