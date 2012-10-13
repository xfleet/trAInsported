trAInsported
=====================
This is a list of all functions that your AI should use. The first part lists the events which you should define. If you define them correctly, then the game will call them if certain events happen. For example, if you define function ai.init() then this function will be called when the round starts. When you define function ai.chooseDirection() then this function will be called when a train comes to a junction and wants to know which way to go.  
The first part lists functions that you can call in your code.


#Callback Events#

###function ai.init(map, money)###
This event is called, at the beginning of the round. The current map is passed to it, so you can analize it, get it ready for pathfinding and search it for important junctions, Hotspots, shortest paths etc.  
**Passed Arguments:**

- map: A 2D representation of the current map. "map" has a field map.width and a field map.height to check the size of the map. It also holds information about what's on the map, which is stored by x and y coordinates. For example, to see what's at the position x=3, y=5, you only have to check map[3][5]. A map field can be filled with: "C" (Connected Rail), "H" (House), "S" (Hotspot)
- money: The amount of money that you currently have. You can use this to check how many trains you may buy (one train costs 25 credits).

**Example**

		function ai.init(map, money)
	
			-- go through the entire map and search for all hotspots:
			for x = 1, map.width, 1 do
				for y = 1, map.height, 1 do
					if map[x][y] == "S" then	-- if the field at [x][y] is "S" then print the coordinates on the screen:
						print("Hotspot found at: " .. x .. ", " .. y .. "!")
					end
				end
			end
	
			buyTrain(random(map.width), random(map.height))		-- place train at random position
		end
		
###function ai.chooseDirection(train, possibleDirections)###

**Passed Arguments**

- train: a Lua table representing the train. It has the fields:
	- train.ID (an ID representing the train - number)
	- train.name (the name of the train - string)
	- train.tileX (x-position of the tile the train is on - number)
	- train.tileY (y-position of the tile the train is on - number)
	- train.passenger (name of the passenger who's currently on the train, if any)
- possibleDirections: a Lua table showing the directions which the train can choose from. One of these directions should be returned by the function, to make the train go that way. The table's indieces are the direction ("N","S","E","W") and if the value at the index is true, then this direction is one that the train can move in.

**Returns**

- The function should return a string holding one of the directions which are stored in possibleDirections ("N", "S", "E", "W" are the possible values). If a wrong value is returned, or nothing is returned then the game will automatically try the directions in the following order: N, S, E, W

**Example**

		function ai.chooseDirection(train, possibleDirections)
		
			-- let train 1 go South if possible
			if train.ID == 1 then
				if possibleDirection["S"] == true then
					return "S"
				end
			end
			
			-- let all trains go North if possible
			if possibleDirections["N"] == true then
				return "N"
			end
			
			-- if the above directions were not possible, the let the game choose a direction (i.e. choose nothing)
		end

###function ai.blocked(train, possibleDirections, prevDirection)###
Called after a train was blocked by another train and can't move in that direction. By returning the prevDirection, you can keep trying to go in the same direction. However, you should not try to keep moving in the same direction forever, because then trains could block each other for the rest of the match.  
**Passed Arguments**

- train: same as above (see ai.chooseDirection)
- possibleDirections: a Lua table showing the directions which the train can choose from. One of these directions should be returned by the function, to make the train go that way. The table's indieces are the direction ("N","S","E","W") and if the value at the index is true, then this direction is one that the train can move in.
- prevDirection: the direction that the train previously tried to move in, but was blocked.

**Returns**

- The function should return a string holding one of the directions which are stored in possibleDirections ("N", "S", "E", "W" are the possible values). If a wrong value is returned, or nothing is returned then the game will automatically try the directions in the following order: N, S, E, W

**Example**

		function ai.blocked(train, possibleDirections, prevDirection)
			if prevDirection == "N" then		-- if i've tried North before, then try South, then East, then West
				if possibleDirections["S"] == true then
					return "S"
				elseif possibleDirections["E"] == true then
					return "E"
				elseif possibleDirections["W"] == true then
					return "W"
				else return "N"
				end
			elseif prevDirection == "S" then
				if possibleDirections["E"] == true then
					return "E"
				elseif possibleDirections["W"] == true then
					return "W"
				elseif possibleDirections["N"] == true then
					return "N"
				else return "S"
				end
			elseif prevDirection == "E" then
				if possibleDirections["W"] == true then
					return "W"
				elseif possibleDirections["N"] == true then
					return "N"
				elseif possibleDirections["S"] == true then
					return "S"
				else return "E"
				end
			else
				if possibleDirections["N"] == true then
					return "N"
				elseif possibleDirections["S"] == true then
					return "S"
				elseif possibleDirections["E"] == true then
					return "E"
				else return "W"
				end
			end
		end


###function ai.foundPassengers(train, passengers)###
This function is called when a train arrives at a position where passengers are waiting to be picked up. If one of the passengers in the list is returned, then this passenger is picked up (but only if the train does not have a passenger at the moment). If you want to pick up a passenger but you're already trainsporting another passenger, you can drop of the current passenger using the function 'dropPassenger'.  
**Passed Arguments:**

- train: the train which has arrived at a position where passengers are waiting. Same as above (see ai.chooseDirection)
- passengers: List of passengers which are at this position.

**Returns:**

- Passenger name: The name of a passenger in the list who is to be picked up.

**Example:**

		function ai.foundPassengers(train, passengers)
			return passengers[1]
		end
		
###function ai.foundDestination(train)###
This function is called when a train which is carrying a passenger arrives at the position where the passenger wants to go. This way, you can drop off the passenger by calling 'dropPassenger'.  
**Passed Arguments**

- train: same as above (see ai.chooseDirection)

**Returns:**

- nothing

**Example:**

		function ai.foundDestination(train)
			print("Dropping of my passenger @ " .. train.tileX .. ", " .. train.tileY)
			dropPassenger(train)
		end
		
###function ai.enoughMoney(money)###
Whenever the player earns money, the game checks if the player now has enough money to buy a new train. If that is the case, then this function is called so that the player can decide whether to buy a new train by calling buyTrain() and if so, where to place it.  
**Passed Arguments**

- money: The amount of money you now have.

**Returns:**

- nothing

**Example:**

		rememberMap = nil

		function ai.enoughMoney(money)
			x = random(rememberMap.width)	-- important! this only works because the map was stored in the global "rememberap" in ai.init()
			y = random(rememberMap.height)
			while money >= 25 do		-- 25c is cost of one train
				buyTrain(x, y)
				money = money - 25
			end
		end
		
		function ai.init(map, money)
			rememberMap = map
			buyTrain(random(map.width), random(map.height))
		end

###function ai.newPassenger(name, x, y, destX, destY)###
Will be called whenever a new passenger spawns on the map, or if a passenger has been dropped off at a place that was not his destination.  
**Passed Arguments:**

- name: name of the passenger. If the passenger is a VIP, then "[VIP]" is appended to his name.
- x, y: the x and y positions of the tile on which the passenger is standing.
- destX, destY: the x and y position of the tile to which the passenger would like to be transported. As soon as you drop him/her of at this position, you will get paid.

**Returns:**

- nothing

**Example**

		passengerList = {}	-- create an empty list to save the passengers in
		function ai.newPassenger(name, x, y, destX, destY)
		
			-- create a new table which holds the info about the new passenger:
			local passenger = {x=x, y=y, destX=destX, destY=destY}
			
			-- save the passenger into the global list, to "remember" him for later use.
			-- use the name as an index to easily find the passenger later on.
			passengerList[name] = passenger
		end

###function ai.passengerBoarded(train, passenger)###
Will be called whenever a train of another player has taken a passenger aboard. You can use this function to make sure your trains no longer try to go to that passenger, if that was their plan.  
Note: This function is NOT called when one of your own trains take a passenger aboard!  
**Passed Arguments:**

- train: the train which has taken the passenger in. (Same as for chooseDirection)
- passenger: name of the passenger which has boarded a train.

**Returns:**

- nothing

**Example**

		passengerList = {}	-- create an empty list to save the passengers in
		function ai.newPassenger(name, x, y, destX, destY)
		
			-- create a new table which holds the info about the new passenger:
			local passenger = {x=x, y=y, destX=destX, destY=destY}
			
			-- save the passenger into the global list, to "remember" him for later use.
			-- use the name as an index to easily find the passenger later on.
			passengerList[name] = passenger
		end
		
		function ai.passengerBoarded(train, passenger)
			-- set the entry in the passengerList for the passenger to nil. This is the accepted way of "deleting" the entry in Lua.
			passengerList[passenger] = nil
		end


#Available Functions#
You can define your own functions inside your code.  
This is a list of functions that are already specified and which you can call at any time. Be careful not to overuse them - they all take some time to compute and your code will be aborted if it takes too long!

###print(...)###
Prints the given objects to the ingame-console (make sure it's visible by pressing 'C' in the game!)  
**Arguments:**

- ... List of objects to print

**Returns:**

- nothing

**Example:**
  
		print("Sheldon likes trains!")


###pairs(tbl)###
The standard Lua pairs value. See a Lua documentation for more examples.  
**Arguments:**

- tbl: The Table through which you want to iterate

**Returns:**

- Iterator over the key, value pairs in the table.

**Example:**

		for k, value in pairs(map) do
			print(k, value)
		end



###type(variable)###
Returns the type of the given variable.  
**Arguments:**

- variable: variable of which you want to know the type

**Returns:**

- Type of variable. Possible Types are: "string", "number", "table", "userdata"

**Example:**

		if type(myValue) == "number" then
			print("my Value is a number!")
		elseif type(myValue) == "string" then
			print("my Value is a string!")
		else
			print("my Value is neither a number, nor a string. It's of type " .. type(myValue))
		end

  
###pcall(chunk, args)###
Will safely execute the code given by chunk (can be a function). This way, you can run code which might raise an error or be not working, without loosing control. In case there's an error in the code, you can safely handle the exception.  
**Arguments:**

- chunk: code to run, usually the name of the function
- args: any arguments that should be passed to the chunk

**Returns:**

- ok: true if the chunk ran without errors, false otherwise
- result: data returned by the chunk if it ran correctly. Otherwise, result holds the error message.

**Example:**

		function foo( argument )
			... -- do stuff in here
		end
		bar = 1
		ok, result = pcall(foo, bar)	-- call the function "foo" with the argument "bar"
		if not ok then
			print("Error in 'foo': " .. result)
		end

###error(msg)###
Throws an error. If the function in which the error is thrown is called using pcall, then the pcall will return this error as its error message. Otherwise, the error is printed in the ingame console.
  
**Arguments:**

- msg: any error message or error code.

**Example:**

		-- absolutely useless code (but works)
		function foo( b )
			a = 1
			while a < 100 do
				if b > a then
					error("b is greater than a!")
				end
				a = a + 1
			end
		end
		
		ok, msg = pcall(foo, 10)
		if not ok then
			print("Error: " .. msg)
		end
		
###table###
You also have access to all of Lua's table-functions: table.sort, table.insert, table.remove etc. See a Lua Documentation for details.


###dropPassenger(train)###
Will drop of the passenger of the train at its current position.

###buyTrain(x, y, dir)###
Will try to buy a train and place it at the position [X][Y]. If there's no rail at the given position, the game will place the train at the rail closest to [X][Y]. If the rail is blocked, the game waits until the blocking trains have left the rail. This means the train WILL be bought, but might be placed at a different position or go in a different direction than what you anticipate.

**Arguments:**

- x (The x-coordinate of the position at which to place the train)
- y (The y-coordinate of the position)
- dir (The direction in which the train should go. If an invalid direction is passed (or if it's 'nil') then the game tries to use default directions in the following order: North, South, East, West.

**Example:**

		function ai.init(map, money)
			while money > 25 do		-- check if I still have enough money to buy a train?
				money = money - 25	-- 25 is the standard cost for a train
				
				xPos = random(map.width)
				yPos = random(map.height)
				
				randomDir = random(4)
				if randomDir == 1 then
					buyTrain(xPos, yPos, "N")	-- try to buy a train, place it at the position and make it go North.
				elseif randomDir == 2
					buyTrain(xPos, yPos, "S")	-- try to buy a train, place it at the position and make it go South.
				elseif randomDir == 3
					buyTrain(xPos, yPos, "E")	-- try to buy a train, place it at the position and make it go South.
				elseif randomDir == 4
					buyTrain(xPos, yPos, "W")	-- try to buy a train, place it at the position and make it go South.
				else
					buyTrain(xPos, yPos)	-- don't care what direction to go in.
				end
			end
		end


