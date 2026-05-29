How2MapVote:
1. Place define (if new) map in /code/datums/next_map.dm
2. Run `tools/build/build.js release` to build every map defined in the maps array in build.js
3. That's it

MANUALLY:
1. Go into vgstation.dme
2. Copy it to another file (like temp.dme)
3. Replace the #include "maps/tgstation.dm" with whatever map you want
4. Build the DMB
5. Go into /code/datums/next_map.dm, find or add your map (Add it to tools/build/build.js's maps variable if you want to compile it all in one go automatically)
6. Make a folder called whatever is set in your map's path variable
7. Move the built DMB into that folder
8. Rename it to vgstation13.dmb
9. That's it

Sucks at documentation award
|
V
To utilize the map voter:

1. Uncomment or put MAP_VOTING in config.txt
2. Compile the DMB's for each map you want to be voted on(requires a recompile on every update)
3. Put each map's DMB in a folder designated to the map's name in maps/voting/ eg MetaStation for Meta Station and Box for Box Station
4. At the natural end of a round the map will be voted upon.

TODO:

Maybe add a verb for admins to force another map using file browse.
Setup a script to easily mass compile the maps (hint hint nexy) <- FUCK YOU