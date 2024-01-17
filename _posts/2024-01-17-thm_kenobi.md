---
layout: post
title: Kenobi
categories: [CyberSecurity]
tags: [CTF, thm, easy, nmap]
---
<style>
y { color: Yellow }
g { color: Green }
</style>

This [room](https://tryhackme.com/room/kenobi) will cover accessing a Samba share, manipulating a vulnerable version of proftpd to gain initial access and escalate your privileges to root via an SUID binary.
### Task 1: Deploy the vulnerable machine
#### Questions:
Q1. Make sure you're connected to our network and deploy the machine  
Q2. Scan the machine with nmap, how many ports are open?
### MyWalk
As usual start with a <y>nmap</y> scan:
```bash
nmap -T4 -sC -sV -Pn -oN nmap/initial 10.10.226.246
```
Count number of open ports. Q2 done

### Task 2: Enumerating Samba for shares
#### Questions:
Q1. Using nmap we can enumerate a machine for SMB shares.  
Nmap has the ability to run to automate a wide variety of networking tasks.   There is a script to enumerate shares!  
``````
nmap -p 445 --script=smb-enum-shares.nse,smb-enum-users.nse MACHINE_IP  
```  
SMB has two ports, 445 and 139.  
![image info](./assets/bkgVNy3.png)  
Using the nmap command above, how many shares have been found?  
end