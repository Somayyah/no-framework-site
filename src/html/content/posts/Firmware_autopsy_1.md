---
title: "Firmware Autopsy - 1 || Dissecting a white Bluetooth Earbud"
date: 2025-04-22 
description: Understanding what's going on
type: "post"  
tags: ["assembly", "security", "reverse-engineering", "how-to", "technology", "bluetooth", "hardware"]
---

I bought cheap knockoff Bluetooth earbuds. At first, they worked fine, but now they take multiple attempts to connect and the charging indicator only shows 20%, despite my phone reading them as fully charged. So I decided to get their money's worth and use them as an exercise, who knows, maybe I'll fix them.

<br>

Here are they before I rip them open:

<br>![My earbuds](/images/image2-min_2_11zon.webp)<br>

I start by first opening them, there's a pinhole so I'm assuming I can just insert like a pin or maybe an earring post into it:
<br><br>
![Image showing pinhole in the earbuds](/images/pinhole.webp)
<br><br>

But it didn't work so I opened it with a knife instead:
<br><br>
![Bluetooth earbuds from the inside](/images/bluetooth_earbud_from_the_inside.webp)
<br><br>


I take a brief look and there's a big chip and a small one. The big chip doesn't have any marking on it, it has 16 pins and 8 on each side, I connected the earbuds back to the charger, and guess what? They now charge properly! The reading is no longer stuck on 20%.
<br><br>


I repositioned the battary with the padding that has adhesive on it then gently reassembled the earbuds, now they are working. The reading is going up and the voice is clear.
<br><br>


I conclude this was a success. Although I'm a bit upset I didn't dive deaper but it's ok as I have another pair of crappy earbuds. The next takes too long to connect and when it does, the right side disconnects for no reason after few minutes, like it goes "turning off..". It worked fine but suddenly started misbehaving.
<br><br>


I'll check that one in the next post
<br>
<br>
