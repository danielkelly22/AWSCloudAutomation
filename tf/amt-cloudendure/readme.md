# CloudEndure


## General Notes
This documentation is slightly overloaded with drtest-specific instructions, 
as well as service-specific instructions (amtrustfinancial.com).
However, the general concepts are applicable, and the overall documentation
strategy is still in-flux. Therefore in the interest of time and deadlines, 
this PR will move forward regardless.

## Related Documentation:
  * [amt-network-setup](../amt-network-setup/README.md)
  * [SystemsMarkdownDocs/Architecture/DR/cloudendure](https://dev.azure.com/amtrust/Amtrust/_git/SystemsMarkdownDocs?path=%2FArchitecture%2FDR%2Fcloudendure.md&version=master&_a=contents)


## IAM
The CloudEndure user needs a boilerplate policy per the docs. I really wanted to restrict it such that only specific
VPC's are visible. This would prevent us from performing a DR test restore to a production network by accident.
Preventing this type of mistake is important, because such an action could have catastrophic affects to some services. 

However, the condition keys required for this level of control don't seem to be supported by IAM for EC2.


## Things Left in TODO
  * The jump host launch and config is currently manual.
  * Use a read-only account for accessing the production webconfigs, as a precaution. 
    Or better-yet, get them from a backup, or from an artifact.
  * Adding blackhole routes on the TGW is currently manual.

## DR Test Concepts
restore a DC
use that DC for auth and DNS inside the isolated subnet
use a jump host to reach into the isolated subnet.


## Shared Jump Host
The jump host is a windows box that gets multi-homed on the isolated DR test network, and the production network.
The jump host cannot be fully configured until a DC is restored into the drtest environment, because the jump host
needs to point at the restored DC for DNS.

However, the jump host is required for configuring the restored DC. So there's a bit of a chicken-and-egg situation.

1. launch a new windows ec2 instance in the 'jump-host' subnet.
   1. Security groups:
      1. `drtest-isolated-restored-machines`
      1. `drtest-jump-host`
   1. Name: `drtest-jump-shared`
1. Configure per the following:
   1. Networking
      1. Attach a new ENI to the instance that is connected to the isolated subnet.
      1. Start -> Run -> "Control Netconnections" ->
         Rename the NICs to "private" (jump-host subnet), and "isolated" (drtest isolated subnet).
      1. Change the IP's from DHCP to static, using the respective IP's that AWS has assigned.
      1. Remove default gateway the isolated subnet's nic.
      1. Ensure that no dns servers are configured for the private subnet's nic. 
         This is critical, because otherwise, you may connect to production resources by accident 
         when attempting to connect to drtest resources. This could end badly. And when I say "badly", 
         think: "I deleted a bunch of domain controllers" or "I erased a bunch of web configs".
  1. Install chocolatey
  1. Install the following apps:
      1. googlechrome
      1. vscode
      1. wireshark
      1. sql-server-management-studio
      1. 7zip
      1. mremoteng
      1. nmap
      1. pstools
      1. wintail

Once the DC is restored, we will need to come back to the jump host and do the following:
1. Change the DNS server for the isolated subnet's NIC to point to the IP of the restored DC.
1. Ensure that the isolated subnet's NIC has no default gateway configured.


## Domain Controller
  1. Restore the DC to the isolated subnet.
  1. Have a domain admin RDP to the DC from the jump-host and create a _new_ enterprise 
     admin account named `drtest_admin`. Ensure that this user does not exist in the 
     production environment. This is an important safety precaution in case mistakes were 
     made in any previous steps.
     The rest of this process would be extremely destructive to production AD, and having 
     a brand-new account gives some additional peace of mind.
  1. Ensure that `drtest_admin` is added to the following AD security groups:
     1. Domain Admins
     1. Database Admins
     1. Enterprise Admins
  1. RDP to the restored DC via its isolated subnet IP address as `drtest_admin`.
     (not via hostname -- again, as a precaution).
  1. Delete all the existing DNS forwarders on the restored DC's DNS server.
  1. Add a new DNS forwarder: "169.254.168.253" (the aws internal default).
  1. Register the schema mgmt dll via `regsvr32 schmmgmt.dll`.
  1. Sieze all fsmo roles via ntdsutil.
  1. install the dfsn service on the DC.

Additional AD prep needs completed on a second jump host that will live 
inside the isolated drtest subnet. Technically this can be completed using RSAT
on the first jump host, but it is more dangerous, since we could accidentally 
connect to production instead.


## Isolated Admin Host
  1. Launch a new Windows instance, with a single ENI, attached to the drtest isolated subnet.
     1. Security groups: `drtest-isolated-restored-machines`
     1. Name: `drtest-admin-isolated`
  1. Join to the domain.
  1. Install RSAT via `Get-WindowsCapability -Name RSAT* | Add-WindowsCapability`
     

## Additional AD Prep
  1. RDP to `drtest-admin-isolated`.
  1. Delete all Domain Controllers out of AD other than the one we restored using ADUC.
  1. Clean up SRV records for all other DC's: (NS, A, CNAME, SRV, etc.)


## File Servers
Perform this procedure twice. Once for each name:
  1. clepstafsi01

Procedure as follows:
  1. Launch a new Windows instance, with a single ENI, attached to the drtest isolated subnet.
     1. Security groups: `drtest-isolated-restored-machines`
     1. Name: `clenas01`
     1. Storage: 100GB
  1. Join to the domain.
     1. remove the existing AD object from AD
     1. join the domain; reboot
     1. rename to clenas01; reboot
     1. move to the correct OU:\
     1. `get-adcomputer clenas01 | Move-ADObject -TargetPath "OU=PROD,OU=Servers,OU=IT,DC=amtrustservices,DC=com"`
     1. Update A record on the DC for this machine, because it's static.


## SQL Servers

### clepdbafsi01

The SQL Server's data volumes were not copied over by cloudendure by default. This can likely be fixed
by using the `--force-volumes` option for `installer_win.exe`. In the meantime, we need to restore
them from CommVault backups.

  1. Expand the D:\ volume via AWS and then DiskPart, as needed.
  1. From the shared jump host, copy the SQL backups from CommVault:\
     ```powershell
     $restore_share_ip = # get this from Luke
     $clepdbafsi01_drtest_ip = '<IP Address for drtest isolated clepdbafsi01>'
     $restore_src_path = # get this from Luke
     $dst_path = '\d$\restored\'
     if($restore_share_ip -like "10.98.69*" -or $clepdbafsi01_drtest_ip -notlike "10.98.69*"){
         write-error "You are copying in the wrong direction. Stop and ask for help before you break prod."
     } else {
        $full_src = '\\' + $restore_share_ip + $restore_src_path
        $full_dst = '\\' + $clepdbafsi01_drtest_ip + $dst_path
        robocopy $full_src $full_dst /ZB /E /DCOPY:T
     }
     ```
  1. RDP to the drtest IP for clepdbafsi01.
  1. On the D drive, erase all the mountpoint links and recreate them as regular folders.
     For every 'log' dir, create a subdir 'log'. For the others, create a subdir 'data'.
  1. Run the following commands to repair the master databases, so that the SQL Service can start:
     ```powershell
     cd "C:\Program Files\Microsoft SQL Server\130\Setup Bootstrap\SQLServer2016"
     ./setup.exe /ACTION=REBUILDDATABASE /INSTANCENAME=MSSQLSERVER /SQLSYSADMINACCOUNTS="amtrustservices\database admins"
     ```
  1. Start the SQL service.
  1. Run the following commands to restore the DB's:\
     ```powershell
     sqlcmd -E -S clepdbafsi01 -Q "RESTORE DATABASE Amtrustfinancial_prod FROM DISK='D:\restored\Amtrustfinancial_prod_1_Full_Tue_Dec_15_23_11_09_2020.bak',DISK='D:\restored\Amtrustfinancial_prod_2_Full_Tue_Dec_15_23_11_09_2020.bak'"
     sqlcmd -E -S clepdbafsi01 -Q "RESTORE DATABASE Amtrustfinancial_prod2 FROM DISK='D:\restored\Amtrustfinancial_prod2_1_Full_Tue_Dec_15_23_12_07_2020.bak',DISK='D:\restored\Amtrustfinancial_prod2_2_Full_Tue_Dec_15_23_12_07_2020.bak'"
     ```

If either command fails, it's probably because the folder structure in D:\ needs pre-created. The logs for setup.exe 
are at `C:\Program Files\Microsoft SQL Server\130\Setup Bootstrap\Log`.


## IIS Web Configs and Data


### clepstafsi01

On the jump host, run the following:
  1. `net use \\<IP Address for production clepstafsi01>\web_configs$ /user:amtrustgroup\a12345`
  1. `net use \\<IP Address for drtest isolated clepstafsi01>\c$ /user:amtrustgroup\drtest_admin`
  1. ```powershell
     $clepstafsi01_prod_ip = '<IP Address for production clepstafsi01>'
     $clepstafsi01_drtest_ip = '<IP Address for drtest isolated clepstafsi01>'
     $src_path = '\WebConfigs$\AmtrustFinancial.com\CMS'
     $dst_path = '\c$\shares\webconfigs\AmtrustFinancial.com\CMS'
     if($clepstafsi01_prod_ip -like "10.98.69*" -or $clepstafsi01_drtest_ip -notlike "10.98.69*"){
         write-error "You are copying in the wrong direction. Stop and ask for help before you break prod."
     } else {
        $full_src = '\\' + $clepstafsi01_prod_ip + $src_path
        $full_dst = '\\' + $clepstafsi01_drtest_ip + $dst_path
        robocopy $full_src $full_dst /ZB /E /DCOPY:T
     }
     ```
  1. RDP to the drtest isolated clepstafsi01 via IP.
  1. Create the web_config$ share.\
     `new-smbshare -path 'C:\shares\WebConfigs' -name 'WebConfigs$'`
  1. Grant appropriate permissions to the share and files.


### clepwafsi01
  1. Create a new zone in DNS on the restored DC named 'amtrustfinancial.com'
  1. Create an A for this zone, with the value of clepwadsi01's drtest IP.
  1. Reboot clepwafsi01.
  1. RDP clepwafsi01 (use the drtest isolated IP)
  1. Verify that the Kentico service has started.
  1. Verify amtrustfinancial.com site is listed in IIS Manager, and expandable so that folders can be seen. 


### Kentico
  1. Login to Kentico as an admin, from drtest-admin-isolated.
  1. Have an existing Kentico admin create a new account named `drtest_admin`.
  1. Login to the production Kentico box directly from your workstation, and 
     ensure that there is no account named `drtest_admin`, and then close the 
     production Kentico window.
  1. Back on the drtest isolated Kentico, edit the 'contact us' form and remove
     the recaptcha section. The recaptcha code cannot reach the google web API's,
     and will therefore fail upon submission.
