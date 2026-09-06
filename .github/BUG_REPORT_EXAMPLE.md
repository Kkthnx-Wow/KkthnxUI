# Example Bug Report

Here is what a good KkthnxUI bug report looks like. The more of this you can fill
in, the faster the problem gets found and fixed. Fill out the real bug report the
same way when you open an issue.

---

**What happened**
The player castbar shows the wrong colour. A normal cast that I can interrupt fills
up silver instead of gold.

**Steps to reproduce**
1. Log in on a mage
2. Target a training dummy in the city
3. Cast Frostbolt and watch the castbar fill

**What you expected**
A normal, interruptible cast should be gold. Silver is only meant for casts you
cannot interrupt, like a protected boss cast.

**Error text**
No Lua error. The cast works, the colour is just wrong.

**Screenshots**
A screenshot of the silver castbar, next to the target castbar showing the correct
gold, so the difference is clear.

**Your setup**
- Game version: Retail
- Patch: 11.0.5
- KkthnxUI version: 11.0.0
- Still happens with only KkthnxUI enabled? yes

**Anything else**
It started after the last update. Target and focus castbars look right, only the
player one is affected. It happens on every character I tried.

---

## Why each part helps

- **What happened** and **What you expected** together show the difference between
  what you see and what should happen.
- **Steps to reproduce** let the problem be seen firsthand, which is the fastest
  way to fix it.
- **Error text** points straight at the code when there is a Lua error. Turn error
  display on with `/console scriptErrors 1` before reproducing the bug.
- **Your setup** rules out version and addon conflicts. Testing with only KkthnxUI
  enabled tells us whether another addon is involved.
