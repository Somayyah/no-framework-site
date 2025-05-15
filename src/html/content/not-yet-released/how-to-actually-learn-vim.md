---
title: "How to actually learn VIM"
date: 2025-01-15  
description: As a newbie 
type: "post"  
tags: ["vim", "how-to", "technology", "linux"]
---

Mastering VIM for me is all about showing off and non of that ergonomic benefits, although I may have to take it into consideration as I barely survived my last [RSI attack](https://my.clevelandclinic.org/health/diseases/17424-repetitive-strain-injury).

In this post I will provide tips on how to actually progress with VIM / neovim from a complete beginner to somewhat decent user. 

For reference here are my [monkeyType] stats a year ago:

<br>![MonkeyType stats a year ago, showing WPM to be only 49 and supbar accuracy](/images/monkeytype.webp)<br>

I could barely achieve 50 WPM on a good day, and here is me fighting with VIM motions:

<>

A year later I achieved 123 WPM which is decent for me, and here is me after transitioning completely to neovim as an editor, no longer using VSCode:
<>

<br>Based on the above I think I'm qualified to provide my wisdom in this matter.

## Step #1 : Stop Looking at the Keyboard

Seriously, let your fingertips find their way. It’s okay to make mistakes at first—just focus on accuracy rather than speed. A great way to improve is by practicing on typing websites like Monkeytype. Reading fast can help too; I didn’t break past 45 WPM for the longest time until I started focusing on reading speed. Now I type at 83–110 WPM, which works for me.

Avoid rigid typing techniques like placing you fingers on specific keys. Everyone has their own rhythm and way to type, and forcing yourself into a specific method can feel awkward or even painful. Since most of my work is at night and I'm forced to work in the dark I find that it has aided me in becoming faster and more effecient. Focus on mastering special characters, numbers and switching between capital and small letters as you will need this skill for later.

To practice typing speed you can use websites likey [MonkeyType]()
## Step #2 : Use vanilla VIM at first

Master basic skills first like navigation and searching, otherwise you'll be dissapointed in yourself. For that I recommend you to test VIM in your favorite text editor first, for example I started with VSCode VIM extention and forced myself to use it. You can also use vimtutor as an introduction.

Stick to VIM motions for navigation, never use the arrow keys and practice things like moving multi-lines, searching a word, using line numbers ... etc.

## Step #3 : Learn Through Doing not Memorizing

Let's say you want to copy a section or a code block, instead of going into visual mode try to figure out the key combination first, same thing with doing repetitive tasks, can you automate them with a macro? this may seem tedious at first but with practice they become a second nature and you can actually move to the next step. There are many online forums to learn from and others who are trying to learn too so don't be shy to ask questions.

## Step #4 : Neovim

You now have a good grasp of VIM's fundamentals, so you're ready to use the terminal itself as your text editor, by now you're confident in your skills and you should be since you've earned it.

However for the next level I recommend using [Neovim](https://neovim.io/) instead of VIM. Although VIM is extendable but it uses [vimscript](https://learnvimscriptthehardway.stevelosh.com/) which isn't too loved, so instead we can use "neovim" which uses [LUA](https://www.lua.org/) language in it's configuration which is simple and fun. Neovim is extendable and my favorite is setup of [NvChad](https://nvchad.com/docs/quickstart/install/).

You can extend NeoVim or VIM with advanced features like file navigation, lenters, LSPs... etc, the sky is the limit and in the next function you can humbly brag about how tired you are because Neovim is making you so productive that you cannot sleep anymore.