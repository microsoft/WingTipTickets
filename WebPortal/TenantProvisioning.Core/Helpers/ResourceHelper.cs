using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace TenantProvisioning.Core.Helpers
{
    public static class ResourceHelper
    {
        public static string ServerPath { get; set; }

        public static string ReadText(string filepath)
        {
            var combinedPath = Path.Combine(ServerPath, filepath);

            return File.ReadAllText(combinedPath);
        }

        public static byte[] ReadBytes(string filepath)
        {
            var combinedPath = Path.Combine(ServerPath, filepath);

            return File.ReadAllBytes(combinedPath);
        }

        public static List<string> ListFiles(string filepath)
        {
            var combinedPath = Path.Combine(ServerPath, filepath);

            return Directory.GetFiles(combinedPath).ToList();
        }
    }
}
