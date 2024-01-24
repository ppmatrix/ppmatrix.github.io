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
nmap -sV -vv --script vuln 10.10.198.214
```
{: .nolineno }

I saw port 80 and port 8080 open so visited both pages.
Visiting the IP:80 webpage shows a person image, looking at the image name, we get the Q1 answer.  
On the 8080 port we can see the following:

![Steel Mountain](./assets/steelmountain2.png)
