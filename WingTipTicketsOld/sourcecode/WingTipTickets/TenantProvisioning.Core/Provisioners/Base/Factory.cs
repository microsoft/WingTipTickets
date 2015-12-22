using System;
using System.Collections.Generic;
using TenantProvisioning.Core.Helpers;
using TenantProvisioning.Core.Models;
using TenantProvisioning.Core.Provisioners.Day2;
using TenantProvisioning.Core.Repositories;

namespace TenantProvisioning.Core.Provisioners.Base
{
    static class Factory
    {
        #region - Private Methods -

        private static BaseProvisioner CreatePipelineComponent(ProvisioningPipelineTask task, ProvisioningParameters provisioningParameters)
        {
            switch (task.TaskCode)
            {
                // Shared Components
                case Provisioner.Shared_ResourceGroup: return new Shared.ResourceGroup(task.Id, task.Position, task.GroupNo, task.WaitForCompletion);
                case Provisioner.Shared_SqlServerSchema: return new Shared.SqlSchemaDeployment(task.Id, task.Position, task.GroupNo, task.WaitForCompletion);
                case Provisioner.Shared_SqlServerPopulate: return new Shared.SqlSchemaPopulator(task.Id, task.Position, task.GroupNo, task.WaitForCompletion);
                case Provisioner.Shared_SearchService: return new Shared.SearchService(task.Id, task.Position, task.GroupNo, task.WaitForCompletion);
                case Provisioner.Shared_WebHostingPlan: return new Shared.WebHostingPlanCreator(task.Id, task.Position, task.GroupNo, task.WaitForCompletion);
                case Provisioner.Shared_Website: return new Shared.WebSiteCreator(task.Id, task.Position, task.GroupNo, task.WaitForCompletion);
                case Provisioner.Shared_TrafficManager: return new Shared.TrafficManagerProfile(task.Id, task.Position, task.GroupNo, task.WaitForCompletion);
                case Provisioner.Shared_SqlAuditing: return new Shared.SqlAuditing(task.Id, task.Position, task.GroupNo, task.WaitForCompletion);
                case Provisioner.Shared_DocumentDb: return new Shared.DocumentDb(task.Id, task.Position, task.GroupNo, task.WaitForCompletion);

                // Day 1 Components
                case Provisioner.Day1_StorageAccount: return new StorageAccountCreator(task.Id, task.Position, task.GroupNo, task.WaitForCompletion);
                case Provisioner.Day1_SqlServer: return new Day1.SqlDatabase(task.Id, task.Position, task.GroupNo, task.WaitForCompletion);
                case Provisioner.Day1_WebsiteDeployment: return new Day1.WebSiteDeployment(task.Id, task.Position, task.GroupNo, task.WaitForCompletion);

                // Day 2 Components
                case Provisioner.Day2_StorageAccount: return new StorageAccountCreator(task.Id, task.Position, task.GroupNo, task.WaitForCompletion);
                case Provisioner.Day2_SqlServer: return new Day2.SqlDatabase(task.Id, task.Position, task.GroupNo, task.WaitForCompletion);
                case Provisioner.Day2_WebsiteDeployment: return new Day2.WebSiteDeployment(task.Id, task.Position, task.GroupNo, task.WaitForCompletion);
                
                case Provisioner.Day2_DataFactory: return new Day2.DataFactory111(task.Id, task.Position, task.GroupNo, task.WaitForCompletion);

                default:
                    return null;
            }
        }

        #endregion

        #region - Public Methods -

        public static List<BaseProvisioner> CreatePipeline(int provisioningOptionId, ProvisioningParameters provisioningParameters)
        {
            // FetchById components and their execution order for option (Standand/Premium)
            var provisioningPipelineRepository = new ProvisioningPipelineRepository();
            var tasks = provisioningPipelineRepository.FetchPipelineTasks(provisioningOptionId);

            // Create the Pipeline components based on their unique codes
            var pipeline = new List<BaseProvisioner>();

            tasks.ForEach(t => pipeline.Add(CreatePipelineComponent(t, provisioningParameters)));

            return pipeline;
        }

        #endregion
    }
}
