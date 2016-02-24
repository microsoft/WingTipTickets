namespace TenantProvisioning.Core.Models
{
    public class ProvisioningPipelineTask
    {
        public int Id { get; set; }
		public string Position { get; set; }
		public int SequenceNo { get; set; }
        public int GroupNo { get; set; }
        public string TaskDescription { get; set; }
        public string TaskCode { get; set; }
        public bool WaitForCompletion { get; set; }
    }
}
