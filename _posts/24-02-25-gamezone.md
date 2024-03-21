---
layout: post
title: Game Zone
categories: [CyberSecurity, CTF]
tags: [thm, easy, nmap]
---

![Basic Pentesting](/assets/gamezone.jpeg){: .right }{: w="200" h="200" }

## Walkthrough
[https://tryhackme.com/room/gamezone](https://tryhackme.com/room/gamezone)

**Difficulty level:** Easy

This room will cover SQLi (exploiting this vulnerability manually and via SQLMap), cracking a users hashed password, using SSH tunnels to reveal a hidden service and using a metasploit payload to gain root privileges.

## Task 1: Deploy the vulnerable machine 

### Questions

Q1. Deploy the machine and access its web server.


> "No answer needed"

Q2. What is the name of the large cartoon avatar holding a sniper on the forum?

> "Agent 47"


### MyWalk

Just search google reverse image

## Task 2: Obtain access via SQLi 

In this task you will understand more about SQL (structured query language) and how you can potentially manipulate queries to communicate with the database.

### Questions

Q1. SQL is a standard language for storing, editing and retrieving data in databases. A query can look like so:

SELECT * FROM users WHERE username = :username AND password := password

In our GameZone machine, when you attempt to login, it will take your inputted values from your username and password, then insert them directly into the query above. If the query finds data, you'll be allowed to login otherwise it will display an error message.

Here is a potential place of vulnerability, as you can input your username as another SQL query. This will take the query write, place and execute it.



> "No answer needed"

Q2. Lets use what we've learnt above, to manipulate the query and login without any legitimate credentials.

If we have our username as admin and our password as: ' or 1=1 -- - it will insert this into the query and authenticate our session.

The SQL query that now gets executed on the web server is as follows:

SELECT * FROM users WHERE username = admin AND password := ' or 1=1 -- -

The extra SQL we inputted as our password has changed the above query to break the initial query and proceed (with the admin user) if 1==1, then comment the rest of the query to stop it breaking.


> "No answer needed"

Q3. GameZone doesn't have an admin user in the database, however you can still login without knowing any credentials using the inputted password data we used in the previous question.

Use ' or 1=1 -- - as your username and leave the password blank.

When you've logged in, what page do you get redirected to?

> ""

### MyWalk