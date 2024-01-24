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

> "answer1"

### MyWalk



```bash
nmap -T4 -sC -sV -Pn -oN nmap/initial 10.10.40.46
```
{: .nolineno }

