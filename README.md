EasyLoot
========

Addon for WoW 1.12 clients to simplify loot distribution.

Usage:
/loot <ITEMLINK>
/rr <ITEMLINK>

Argument for /rr is optional, argument for /loot is mandatory.

Changelog:
- added raid roll
- print item in /rw if leader or assist

for devs:
local variable updateInterval contains amount of seconds between two numbers of a countdown
local variable auctionCounterInit determines countdown length, change to (desired_length + 1)

Todo:
- Check if itemlink actually is an itemlink
- Discard multiple arguments
- Provide slash commands to configure updateInterval and auctionCounterInit
