---
layout: post
title: Kenobi
categories: [CyberSecurity]
tags: [CTF, thm, easy, nmap]
---
[room](https://tryhackme.com/room/kenobi)

<span style="color:#a4f8f6;">
This room will cover accessing a Samba share, manipulating a vulnerable version of proftpd to gain initial access and escalate your privileges to root via an SUID binary.
</span>

### Task 1: Deploy the vulnerable machine

#### Questions:

<span style="color:#f35d40;">

Q1. Make sure you're connected to our network and deploy the machine\
Q2. Scan the machine with nmap, how many ports are open?  
Q2. Scan the machine with nmap, how many ports are open?

</span>

### MyWalk

<span style="color:#fcf2a8;">

As usual start with a nmap scan:
```bash
nmap -T4 -sC -sV -Pn -oN nmap/initial 10.10.226.246
```
Count number of open ports. Q2 done

</span>