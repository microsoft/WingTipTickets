<?xml version="1.0" encoding="utf-8"?>
<serviceModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" name="WingTipTickets.Azure" generation="1" functional="0" release="0" Id="4f1adc37-158e-462c-9979-a7165328a913" dslVersion="1.2.0.0" xmlns="http://schemas.microsoft.com/dsltools/RDSM">
  <groups>
    <group name="WingTipTickets.AzureGroup" generation="1" functional="0" release="0">
      <componentports>
        <inPort name="Tenant.Mvc:Endpoint1" protocol="http">
          <inToChannel>
            <lBChannelMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/LB:Tenant.Mvc:Endpoint1" />
          </inToChannel>
        </inPort>
        <inPort name="Tenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteForwarder.RdpInput" protocol="tcp">
          <inToChannel>
            <lBChannelMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/LB:Tenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteForwarder.RdpInput" />
          </inToChannel>
        </inPort>
      </componentports>
      <settings>
        <aCS name="Certificate|Tenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.PasswordEncryption" defaultValue="">
          <maps>
            <mapMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/MapCertificate|Tenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.PasswordEncryption" />
          </maps>
        </aCS>
        <aCS name="Tenant.Mvc:Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString" defaultValue="">
          <maps>
            <mapMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/MapTenant.Mvc:Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString" />
          </maps>
        </aCS>
        <aCS name="Tenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.AccountEncryptedPassword" defaultValue="">
          <maps>
            <mapMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/MapTenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.AccountEncryptedPassword" />
          </maps>
        </aCS>
        <aCS name="Tenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.AccountExpiration" defaultValue="">
          <maps>
            <mapMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/MapTenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.AccountExpiration" />
          </maps>
        </aCS>
        <aCS name="Tenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.AccountUsername" defaultValue="">
          <maps>
            <mapMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/MapTenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.AccountUsername" />
          </maps>
        </aCS>
        <aCS name="Tenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.Enabled" defaultValue="">
          <maps>
            <mapMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/MapTenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.Enabled" />
          </maps>
        </aCS>
        <aCS name="Tenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteForwarder.Enabled" defaultValue="">
          <maps>
            <mapMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/MapTenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteForwarder.Enabled" />
          </maps>
        </aCS>
        <aCS name="Tenant.MvcInstances" defaultValue="[1,1,1]">
          <maps>
            <mapMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/MapTenant.MvcInstances" />
          </maps>
        </aCS>
      </settings>
      <channels>
        <lBChannel name="LB:Tenant.Mvc:Endpoint1">
          <toPorts>
            <inPortMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/Tenant.Mvc/Endpoint1" />
          </toPorts>
        </lBChannel>
        <lBChannel name="LB:Tenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteForwarder.RdpInput">
          <toPorts>
            <inPortMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/Tenant.Mvc/Microsoft.WindowsAzure.Plugins.RemoteForwarder.RdpInput" />
          </toPorts>
        </lBChannel>
        <sFSwitchChannel name="SW:Tenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.Rdp">
          <toPorts>
            <inPortMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/Tenant.Mvc/Microsoft.WindowsAzure.Plugins.RemoteAccess.Rdp" />
          </toPorts>
        </sFSwitchChannel>
      </channels>
      <maps>
        <map name="MapCertificate|Tenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.PasswordEncryption" kind="Identity">
          <certificate>
            <certificateMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/Tenant.Mvc/Microsoft.WindowsAzure.Plugins.RemoteAccess.PasswordEncryption" />
          </certificate>
        </map>
        <map name="MapTenant.Mvc:Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString" kind="Identity">
          <setting>
            <aCSMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/Tenant.Mvc/Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString" />
          </setting>
        </map>
        <map name="MapTenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.AccountEncryptedPassword" kind="Identity">
          <setting>
            <aCSMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/Tenant.Mvc/Microsoft.WindowsAzure.Plugins.RemoteAccess.AccountEncryptedPassword" />
          </setting>
        </map>
        <map name="MapTenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.AccountExpiration" kind="Identity">
          <setting>
            <aCSMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/Tenant.Mvc/Microsoft.WindowsAzure.Plugins.RemoteAccess.AccountExpiration" />
          </setting>
        </map>
        <map name="MapTenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.AccountUsername" kind="Identity">
          <setting>
            <aCSMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/Tenant.Mvc/Microsoft.WindowsAzure.Plugins.RemoteAccess.AccountUsername" />
          </setting>
        </map>
        <map name="MapTenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.Enabled" kind="Identity">
          <setting>
            <aCSMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/Tenant.Mvc/Microsoft.WindowsAzure.Plugins.RemoteAccess.Enabled" />
          </setting>
        </map>
        <map name="MapTenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteForwarder.Enabled" kind="Identity">
          <setting>
            <aCSMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/Tenant.Mvc/Microsoft.WindowsAzure.Plugins.RemoteForwarder.Enabled" />
          </setting>
        </map>
        <map name="MapTenant.MvcInstances" kind="Identity">
          <setting>
            <sCSPolicyIDMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/Tenant.MvcInstances" />
          </setting>
        </map>
      </maps>
      <components>
        <groupHascomponents>
          <role name="Tenant.Mvc" generation="1" functional="0" release="0" software="C:\Users\developer\Source\Workspaces\WingTipTickets\Tenant.Azure\csx\Debug\roles\Tenant.Mvc" entryPoint="base\x64\WaHostBootstrapper.exe" parameters="base\x64\WaIISHost.exe " memIndex="-1" hostingEnvironment="frontendadmin" hostingEnvironmentVersion="2">
            <componentports>
              <inPort name="Endpoint1" protocol="http" portRanges="8080" />
              <inPort name="Microsoft.WindowsAzure.Plugins.RemoteForwarder.RdpInput" protocol="tcp" />
              <inPort name="Microsoft.WindowsAzure.Plugins.RemoteAccess.Rdp" protocol="tcp" portRanges="3389" />
              <outPort name="Tenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.Rdp" protocol="tcp">
                <outToChannel>
                  <sFSwitchChannelMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/SW:Tenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteAccess.Rdp" />
                </outToChannel>
              </outPort>
            </componentports>
            <settings>
              <aCS name="Microsoft.WindowsAzure.Plugins.Diagnostics.ConnectionString" defaultValue="" />
              <aCS name="Microsoft.WindowsAzure.Plugins.RemoteAccess.AccountEncryptedPassword" defaultValue="" />
              <aCS name="Microsoft.WindowsAzure.Plugins.RemoteAccess.AccountExpiration" defaultValue="" />
              <aCS name="Microsoft.WindowsAzure.Plugins.RemoteAccess.AccountUsername" defaultValue="" />
              <aCS name="Microsoft.WindowsAzure.Plugins.RemoteAccess.Enabled" defaultValue="" />
              <aCS name="Microsoft.WindowsAzure.Plugins.RemoteForwarder.Enabled" defaultValue="" />
              <aCS name="__ModelData" defaultValue="&lt;m role=&quot;Tenant.Mvc&quot; xmlns=&quot;urn:azure:m:v1&quot;&gt;&lt;r name=&quot;Tenant.Mvc&quot;&gt;&lt;e name=&quot;Endpoint1&quot; /&gt;&lt;e name=&quot;Microsoft.WindowsAzure.Plugins.RemoteAccess.Rdp&quot; /&gt;&lt;e name=&quot;Microsoft.WindowsAzure.Plugins.RemoteForwarder.RdpInput&quot; /&gt;&lt;/r&gt;&lt;/m&gt;" />
            </settings>
            <resourcereferences>
              <resourceReference name="DiagnosticStore" defaultAmount="[4096,4096,4096]" defaultSticky="true" kind="Directory" />
              <resourceReference name="EventStore" defaultAmount="[1000,1000,1000]" defaultSticky="false" kind="LogStore" />
            </resourcereferences>
            <storedcertificates>
              <storedCertificate name="Stored0Microsoft.WindowsAzure.Plugins.RemoteAccess.PasswordEncryption" certificateStore="My" certificateLocation="System">
                <certificate>
                  <certificateMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/Tenant.Mvc/Microsoft.WindowsAzure.Plugins.RemoteAccess.PasswordEncryption" />
                </certificate>
              </storedCertificate>
            </storedcertificates>
            <certificates>
              <certificate name="Microsoft.WindowsAzure.Plugins.RemoteAccess.PasswordEncryption" />
            </certificates>
          </role>
          <sCSPolicy>
            <sCSPolicyIDMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/Tenant.MvcInstances" />
            <sCSPolicyUpdateDomainMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/Tenant.MvcUpgradeDomains" />
            <sCSPolicyFaultDomainMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/Tenant.MvcFaultDomains" />
          </sCSPolicy>
        </groupHascomponents>
      </components>
      <sCSPolicy>
        <sCSPolicyUpdateDomain name="Tenant.MvcUpgradeDomains" defaultPolicy="[5,5,5]" />
        <sCSPolicyFaultDomain name="Tenant.MvcFaultDomains" defaultPolicy="[2,2,2]" />
        <sCSPolicyID name="Tenant.MvcInstances" defaultPolicy="[1,1,1]" />
      </sCSPolicy>
    </group>
  </groups>
  <implements>
    <implementation Id="91dd5a64-6329-4587-9feb-66972d1fcff8" ref="Microsoft.RedDog.Contract\ServiceContract\WingTipTickets.AzureContract@ServiceDefinition">
      <interfacereferences>
        <interfaceReference Id="048d7566-fae7-4828-b7bf-f84ffe8ad423" ref="Microsoft.RedDog.Contract\Interface\Tenant.Mvc:Endpoint1@ServiceDefinition">
          <inPort>
            <inPortMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/Tenant.Mvc:Endpoint1" />
          </inPort>
        </interfaceReference>
        <interfaceReference Id="0d183658-3b40-440e-a701-60e860db7301" ref="Microsoft.RedDog.Contract\Interface\Tenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteForwarder.RdpInput@ServiceDefinition">
          <inPort>
            <inPortMoniker name="/WingTipTickets.Azure/WingTipTickets.AzureGroup/Tenant.Mvc:Microsoft.WindowsAzure.Plugins.RemoteForwarder.RdpInput" />
          </inPort>
        </interfaceReference>
      </interfacereferences>
    </implementation>
  </implements>
</serviceModel>