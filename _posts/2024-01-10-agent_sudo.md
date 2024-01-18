---
layout: post
title: Agent Sudo
categories: [CyberSecurity, CTF]
tags: [thm, easy, nmap, gobuster, hydra, exiftool, xxd, binwalk, zip2john, JohnTheRipper, 7z, Cyberchef, steghide]
---
## Task 1: Author Note
Welcome to another THM exclusive CTF room. Your task is simple, capture the flags just like the other CTF room. Have Fun!

If you are stuck inside the black hole, post on the forum or ask in the TryHackMe discord.

## Task 2: Enumerate
Enumerate the machine and get all the important information

### Questions

Q1 How many opens Ports?
```
3
```
Q2 How you redirect yourself to a secret page?
```
user-agent
```
Q3 What is the agent name?
```
chris
```
### MyWalk

Beginning with an **nmap** scan, and save the results on nmap/initial for future reference:

```bash
nmap -T4 -sC -sV -Pn -oN nmap/initial 10.10.188.70
```

Now I try to get the Q2 answer, using **gobuster**:


```bash
gobuster dir --url http://10.10.26.150 -w //usr/share/wordlists/dirb/common.txt | tee gobuster.txt
```

No secret page revealed...  
Hint: Answer format: xxxx-xxxxx  
visiting the page we got:

```
Dear agents,
Use your own codename as user-agent to access the site.

From,
Agent R

```
it seems Q2 is "user-agent"

The hint for Q3:  
"You might face problem on using Firefox. Try 'user agent switcher' plugin with user agent: C"  
So, let's install user agent switcher plugin, and set the user agent as "C". After reloading the page I got:
```
Attention chris,

Do you still remember our deal? Please tell agent J about the stuff ASAP. Also, change your god damn password, is weak!


From,

Agent R
```
Now we know the Q3
