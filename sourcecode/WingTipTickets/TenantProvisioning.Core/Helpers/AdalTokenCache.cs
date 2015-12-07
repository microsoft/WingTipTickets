using System;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using TenantProvisioning.Core.Models;
using TenantProvisioning.Core.Services;

namespace TenantProvisioning.Core.Helpers
{
    public class AdalTokenCache : TokenCache
    {
        #region - Fields -

        private readonly string _userName;
        private readonly UserAccountService _userAccountService;
        private UserAccountModel _userAccount;

        #endregion

        #region - Constructors -

        public AdalTokenCache(string userName)
        {
            // associate the cache to the current user of the web app
            _userName = userName;
            _userAccountService = new UserAccountService();

            AfterAccess = AfterAccessNotification;
            BeforeAccess = BeforeAccessNotification;
            BeforeWrite = BeforeWriteNotification;

            // look up the entry in the DB
            _userAccount = _userAccountService.FetchByUsername(_userName);

            // place the entry in memory
            Deserialize((_userAccount == null) ? null : _userAccount.CachedData);
        }

        #endregion

        #region - Private Methods -

        private void BeforeAccessNotification(TokenCacheNotificationArgs args)
        {
            var account = _userAccountService.FetchByUsername(_userName);

            if (_userAccount == null)
            {
                // first time access
                _userAccount = account;
            }
            else
            {
                // if the in-memory copy is older than the persistent copy
                if (account != null && account.UpdateDate > _userAccount.UpdateDate)
                {
                    // read from from storage, update in-memory copy
                    _userAccount = account;
                }
            }

            Deserialize((_userAccount == null) ? null : _userAccount.CachedData);
        }

        private void AfterAccessNotification(TokenCacheNotificationArgs args)
        {
            // if state changed
            if (HasStateChanged)
            {
                // check for an existing entry
                _userAccount = _userAccountService.FetchByUsername(_userName);

                if (_userAccount == null)
                {
                    // Create the account
                    _userAccountService.Create(new CreateUserAccountModel()
                    {
                        Firstname = "",
                        Lastname = "",
                        Username = _userName,
                        CachedData = Serialize(),
                        UpdateDate = DateTime.Now
                    });
                }
                else
                {
                    // Update the account
                    _userAccount.CachedData = this.Serialize();
                    _userAccount.UpdateDate = DateTime.Now;

                    _userAccountService.UpdateCacheData(_userAccount);
                }

                HasStateChanged = false;
            }
        }

        private void BeforeWriteNotification(TokenCacheNotificationArgs args)
        {
            // if you want to ensure that no concurrent write take place, use this notification to place a lock on the entry
        }

        #endregion
    }
}