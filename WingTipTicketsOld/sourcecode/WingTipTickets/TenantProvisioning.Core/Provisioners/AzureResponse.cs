using System.Xml.Linq;

namespace TenantProvisioning.Core.Tasks
{
    class AzureResponse
    {
        public XDocument Xml { get; set; }

        public string RequestId { get; set; }
    }
}