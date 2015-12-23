using System;
using System.Linq;
using System.Security.Claims;
using System.Security.Policy;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Owin.Security;
using Microsoft.Owin.Security.Cookies;
using Microsoft.Owin.Security.OpenIdConnect;
using Owin;
using TenantProvisioning.Core.Helpers;

namespace TenantProvisioning.Mvc
{
    public partial class Startup
    {
        public void ConfigureAuth(IAppBuilder app)
        {
            var clientId = Settings.ProvisionerClient;
            var password = Settings.ProvisionerPassword;
            var authority = string.Format(Settings.LoginUri, "common");
            var azureResourceManagerIdentifier = Settings.ApiEndpointUri;

            // Set authentication types
            app.SetDefaultSignInAsAuthenticationType(CookieAuthenticationDefaults.AuthenticationType);
            app.UseCookieAuthentication(new CookieAuthenticationOptions());

            app.UseOpenIdConnectAuthentication(
                new OpenIdConnectAuthenticationOptions
                {
                    ClientId = clientId,
                    Authority = authority,

                    TokenValidationParameters = new System.IdentityModel.Tokens.TokenValidationParameters
                    {
                        ValidateIssuer = false,                       
                    },

                    Notifications = new OpenIdConnectAuthenticationNotifications()
                    {
                        RedirectToIdentityProvider = (context) =>
                        {
                            if (!context.Request.Path.ToString().Contains("Account"))
                            {
                                var redirectToSignUp = context.Request.Path.ToString().Contains("SignUp");

                                context.HandleResponse();
                                context.Response.Redirect(string.Format("Login?redirectToSignUp={0}", redirectToSignUp));
                            }
                            else
                            {
                                object obj;

                                if (context.OwinContext.Environment.TryGetValue("Authority", out obj))
                                {
                                    var auth = obj as string;

                                    if (auth != null)
                                    {
                                        context.ProtocolMessage.IssuerAddress = auth;
                                    }
                                }

                                if (context.OwinContext.Environment.TryGetValue("DomainHint", out obj))
                                {
                                    var domainHint = obj as string;

                                    if (domainHint != null)
                                    {
                                        context.ProtocolMessage.SetParameter("domain_hint", domainHint);
                                    }
                                }

                                context.ProtocolMessage.RedirectUri = HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Path);
                                context.ProtocolMessage.PostLogoutRedirectUri = new UrlHelper(HttpContext.Current.Request.RequestContext).Action("Index", "Home", null, HttpContext.Current.Request.Url.Scheme);
                                context.ProtocolMessage.Resource = azureResourceManagerIdentifier;
                            }

                            return Task.FromResult(0);
                        },

                        AuthorizationCodeReceived = (context) =>
                        {
                            var credential = new ClientCredential(clientId, password);
                            var tenantId = context.AuthenticationTicket.Identity.FindFirst("http://schemas.microsoft.com/identity/claims/tenantid").Value;
                            var signedInUserUniqueName = context.AuthenticationTicket.Identity.FindFirst(ClaimTypes.Name).Value.Split('#').Last();

                            var tokenCache = new AdalTokenCache(signedInUserUniqueName);
                            tokenCache.Clear();

                            var authContext = new AuthenticationContext(string.Format("https://login.windows.net/{0}", tenantId), tokenCache);
                            var result = authContext.AcquireTokenByAuthorizationCode(context.Code, new Uri(HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Path)), credential);

                            return Task.FromResult(0);
                        },

                        SecurityTokenValidated = (context) =>
                        {
                            var issuer = context.AuthenticationTicket.Identity.FindFirst("iss").Value;

                            if (!issuer.StartsWith("https://sts.windows.net/"))
                            {
                                throw new System.IdentityModel.Tokens.SecurityTokenValidationException();
                            }

                            return Task.FromResult(0);
                        }
                    }
                });
        }
    }
}