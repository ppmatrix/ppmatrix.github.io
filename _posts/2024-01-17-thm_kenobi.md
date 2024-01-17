<style>
r { color: Red }
o { color: Orange }
g { color: Green }
</style>
---
layout: post
title: Kenobi
categories: [CyberSecurity]
tags: [CTF, thm, easy, nmap]
---
[room](https://tryhackme.com/room/kenobi)

<r>
This room will cover accessing a Samba share, manipulating a vulnerable version of proftpd to gain initial access and escalate your privileges to root via an SUID binary.
</r>

### Task 1: Deploy the vulnerable machine

#### Questions:

<o>
Q1. Make sure you're connected to our network and deploy the machine\
Q2. Scan the machine with nmap, how many ports are open?  
</o>

### MyWalk

<g>
As usual start with a nmap scan:
```bash
nmap -T4 -sC -sV -Pn -oN nmap/initial 10.10.226.246
```
Count number of open ports. Q2 done
</g> 

# TODOs:

- <r>TODO:</r> Important thing to do  
- <o>TODO:</o> Less important thing to do  
- <g>DONE:</g> Breath deeply and improve karma  