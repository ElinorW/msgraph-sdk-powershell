### Example 1: Using the Update-MgBetaOrganizationSettingContactInsight Cmdlet
```powershell
Import-Module Microsoft.Graph.Beta.Identity.DirectoryManagement
$params = @{
	IsEnabledInOrganization = $true
	DisabledForGroup = "edbfe4fb-ec70-4300-928f-dbb2ae86c981"
}
Update-MgBetaOrganizationSettingContactInsight -OrganizationId $organizationId -BodyParameter $params
```
This example shows how to use the Update-MgBetaOrganizationSettingContactInsight Cmdlet.
To learn about permissions for this resource, see the [permissions reference](/graph/permissions-reference).
