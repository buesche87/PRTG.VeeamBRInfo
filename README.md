# PRTG.VeeamBRInfo

This is a PRTG Sensor that checks license information of Veeam Backup & Replication.

The XML part is meant to be scheduled on the host where executed the script creates a PRTG formatted XML-file in ```C:\Temp\VeeamResults```

## Scheduled task

Execute

```powerhsell.exe```

Parameter

```-NoLogo -NonInteractive -ExecutionPolicy Bypass -File "C:\Script\VeeamBRInfo-XML.ps1"```

## PRTG-Sensor

This script opens a PS-Drive, retrieves the content of the xml and imports it to PRTG.

The PRTG-Part is copied to the EXEXML folder in the PRTG installation directory under Custom Sensors. 

On the PRTG Webinterface create a new exe/script advanced sensor with the following parameters

```-HostName '%host' -UserName '%windowsdomain\%windowsuser' -Password '%windowspassword'```
