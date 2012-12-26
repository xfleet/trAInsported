thisThread = love.thread.getThread()

package.path = "Scripts/?.lua;" .. package.path

require("mapUtils")
require("TSerial")

width = thisThread:demand("width")
height = thisThread:demand("height")
seed = thisThread:demand("seed")
tutorialMap = thisThread:get("tutorialMap")

if tutorialMap then
	tutorialMap = TSerial.unpack(tutorialMap)
	width = tutorialMap.width
	height = tutorialMap.height
end

math.randomseed(seed)
if not tutorialMap then curMap = {width=width, height=height, time=0} end
curMapOccupiedTiles = {}
curMapOccupiedExits = {}
curMapRailTypes = {}

thisThread:set("percentage", 0)

for i = 0,width+1 do
	if not tutorialMap then curMap[i] = {} end
	curMapRailTypes[i] = {}
	if i >= 1 and i <= width then 
		curMapOccupiedTiles[i] = {}
		curMapOccupiedExits[i] = {}
		for j = 1, height do
			curMapOccupiedTiles[i][j] = {}
			curMapOccupiedTiles[i][j].from = {}
			curMapOccupiedTiles[i][j].to = {}
		
			curMapOccupiedExits[i][j] = {}
		end
	end
end

if not tutorialMap then

	thisThread:set("status", "rails")
	thisThread:set("percentage", 10)
	generateRailRectangles()
	thisThread:set("percentage", 20)

	clearLargeJunctions()
	thisThread:set("percentage", 30)
	connectLooseEnds()
	thisThread:set("percentage", 40)
else
	curMap = tutorialMap
end

calculateRailTypes()
thisThread:set("percentage", 50)


if not tutorialMap then
	thisThread:set("status", "houses")
	placeHouses()
	thisThread:set("percentage", 60)

	thisThread:set("status", "hotspots")
	placeHotspots()
	thisThread:set("percentage", 70)
end

generateRailList()
thisThread:set("percentage", 90)

-- return the results to parent (main) thread:
thisThread:set("curMap", TSerial.pack(curMap))
thisThread:set("curMapRailTypes", TSerial.pack(curMapRailTypes))
thisThread:set("curMapOccupiedTiles", TSerial.pack(curMapOccupiedTiles))
thisThread:set("curMapOccupiedExits", TSerial.pack(curMapOccupiedExits))
thisThread:set("status", "done")


