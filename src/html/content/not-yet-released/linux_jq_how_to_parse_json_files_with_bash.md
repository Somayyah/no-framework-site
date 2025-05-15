---
title: "Linux || jq || How to parse JSON files with bash"
date: 2024-11-15
description: Using jq to parse JSON in BASH scripts
type: "post"
tags: ["linux", "unix", "commands", "how-to", "technology", "explain-like-i'm-five", "hacks"]
---

In this post, we’ll explore how to parse JSON files with the jq tool, and demonstrate how to use it to print each quote from a JSON file with cowsay.

## Prerequisites

Make sure you have cowsay and jq installed. If not, follow the steps below to install them:

```bash
## On Ubuntu / Debian

sudo apt update
sudo apt install cowsay
sudo apt install jq

## On Fedora

sudo dnf install cowsay
sudo dnf install jq

## On CentOS/RHEL

sudo yum install epel-release
sudo yum install cowsay
sudo yum install jq

## On Arch Linux

sudo pacman -S cowsay
sudo pacman -S jq
```

Also you can install the quotes file from here which we will use to test the command jq:

https://gist.githubusercontent.com/nasrulhazim/54b659e43b1035215cd0ba1d4577ee80/raw/e3c6895ce42069f0ee7e991229064f167fe8ccdc/quotes.json

Now let's begin.

## What is JSON

[JSON](https://www.rfc-editor.org/rfc/rfc8259) stands for JavaScript Object Notation, is a lightweight format for storing and transporting data, often used when data is sent from a server to a web page. Here is an example:

```json
{
  "name": "John Doe",
  "age": 30,
  "email": "johndoe@example.com",
  "address": {
    "street": "123 Main St",
    "city": "Anytown",
    "state": "CA",
    "zip": "12345"
  },
  "isActive": true,
  "tags": ["developer", "blogger", "gamer"]
}
```

We notice that data follows key / value pairing, so the value of "name" is "John Doe" for example. Many languages support JSON via different libraries, one of which is [jq](https://jqlang.github.io/jq/manual/).

## Accessing JSON Objects and Keys

Let's take a look at the quotes JSON file:

```json
{
    "quotes": [
        {
            "quote": "Life isn’t about getting and having, it’s about giving and being.",
            "author": "Kevin Kruse"
        },
        {
            "quote": "Whatever the mind of man can conceive and believe, it can achieve.",
            "author": "Napoleon Hill"
        },
        {
            "quote": "Strive not to be a success, but rather to be of value.",
            "author": "Albert Einstein"
        },
        {
            "quote": "Two roads diverged in a wood, and I—I took the one less traveled by, And that has made all the difference.",
            "author": "Robert Frost"
        },
        {
            "quote": "I attribute my success to this: I never gave or took any excuse.",
            "author": "Florence Nightingale"
        },
        {
            "quote": "You miss 100% of the shots you don’t take.",
            "author": "Wayne Gretzky"
        },
        {
            "quote": "I’ve missed more than 9000 shots in my career. I’ve lost almost 300 games. 26 times I’ve been trusted to take the game winning shot and missed. I’ve failed over and over and over again in my life. And that is why I succeed.",
            "author": "Michael Jordan"
        },
        {
            "quote": "The most difficult thing is the decision to act, the rest is merely tenacity.",
            "author": "Amelia Earhart"
        },
        {
            "quote": "Every strike brings me closer to the next home run.",
            "author": "Babe Ruth"
        },
        {
            "quote": "Definiteness of purpose is the starting point of all achievement.",
            "author": "W. Clement Stone"
        }
        ....
    ]
}
```

We have the object Quotes which is an array of objects, each object contains:
+ "quote": the text of the quote.
+ "author": the person who said or is attributed with the quote.

To access each key we can use below notation:

JSON.quotes[n].quote

where n is the index which starts with 0, so below output should be:

JSON.quotes[0].quote = "Life isn’t about getting and having, it’s about giving and being."

Similarly to access the author of the second quote n would be 1 since we start counting from 0:

JSON.quotes[1].author = "Napoleon Hill"

After understanding how to access a key within an object we will use this method with jq command.

## JQ general syntax

The command's general syntax is as follows:

```bash
jq [options...] filter [files...]
```

