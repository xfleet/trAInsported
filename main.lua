package.path = "Scripts/?.lua;" .. package.path


require("TSerial")
ai = require("ai")
console = require("console")
require("imageManipulation")
require("ui")
require("misc")
require("input")
quickHelp = require("quickHelp")
button = require("button")
menu = require("menu")
msgBox = require("msgBox")
tutorialBox = require("tutorialBox")
codeBox = require("codeBox")
map = require("map")
train = require("train")
functionQueue = require("functionQueue")
pSpeach = require("passengerSpeach")
passenger = require("passenger")
stats = require("statistics")
clouds = require("clouds")
loadingScreen = require("loadingScreen")
connection = require("connectionClient")
require("globals")
simulation = require("simulation")
statusMsg = require("statusMsg")
versionCheck = require("versionCheck")

numTrains = 0

version = "0.11"

DEBUG_OVERLAY = true

FONT_BUTTON = love.graphics.newFont( "UbuntuFont/Ubuntu-B.ttf", 19 )
FONT_BUTTON_SMALL = love.graphics.newFont( "UbuntuFont/Ubuntu-B.ttf", 16 )
FONT_STANDARD = love.graphics.newFont("UbuntuFont/Ubuntu-B.ttf", 15 )
FONT_STAT_HEADING = love.graphics.newFont( "UbuntuFont/Ubuntu-B.ttf",18 )
FONT_STAT_MSGBOX = love.graphics.newFont( "UbuntuFont/Ubuntu-M.ttf",17 )
FONT_CONSOLE = love.graphics.newFont( "UbuntuFont/Ubuntu-R.ttf", 13)
FONT_SMALL = love.graphics.newFont( "UbuntuFont/Ubuntu-B.ttf", 14)
FONT_COORDINATES = love.graphics.newFont( "UbuntuFont/Ubuntu-B.ttf", 25 )

FONT_CODE_PLAIN = love.graphics.newFont( "UbuntuFont/Ubuntu-M.ttf", 17 )
FONT_CODE_BOLD = love.graphics.newFont( "UbuntuFont/Ubuntu-B.ttf", 17 )
FONT_CODE_COMMENT = love.graphics.newFont( "UbuntuFont/Ubuntu-LI.ttf", 17 )

PLAYERCOLOUR1 = {r=255,g=50,b=50}
PLAYERCOLOUR2 = {r=64,g=64,b=250}
PLAYERCOLOUR3 = {r=255,g=200,b=64}
PLAYERCOLOUR4 = {r=0,g=255,b=0}

PLAYERCOLOUR1_CONSOLE = {r=255,g=200,b=200}
PLAYERCOLOUR2_CONSOLE = {r=200,g=200,b=255}
PLAYERCOLOUR3_CONSOLE = {r=255,g=220,b=100}
PLAYERCOLOUR4_CONSOLE = {r=200,g=255,b=200}

LOGO_IMG = love.graphics.newImage("Images/Logo.png")


time = 0
mouseLastX = 0
mouseLastY = 0
MAX_PAN = 500
camX, camY = 0,0
camZ = 0.7
mapMouseX, mapMouseY = 0,0

timeFactor = 1
curMap = false
showQuickHelp = false
showConsole = true
initialising = true

function love.load(args)

	for k, arg in pairs(args) do
		if arg == "-D" then
			print("Starting in dedicated Server mode!")
			print("TODO: start dedicated server here!")
			love.event.quit()
		end
	end


	initialising = true
	loadingScreen.reset()	
	love.graphics.setBackgroundColor(BG_R, BG_G, BG_B, 255)
	
	versionCheck.start()
end

function finishStartupProcess()
	console.init(love.graphics.getWidth(),love.graphics.getHeight()/2)
	
	SPEACH_BUBBLE_WIDTH = pSpeachBubble:getWidth()

	map.init()

	console.add("Loaded...")

	menu.init()
end


local floatPanX, floatPanY = 0,0	-- keep "floating" into the same direction for a little while...

function love.update(dt)
	-- ai.run()
	-- time = time + dt
	
	--mapMouseX, mapMouseY = coordinatesToMap(love.mouse.getPosition())
			
			
	if initialising then
		button.init()
		msgBox.init()
		loadingScreen.init()
		quickHelp.init()
		stats.init()
		tutorialBox.init()
		codeBox.init()
		statusMsg.init()
		pSpeach.init()
		
		if button.initialised() and msgBox.initialised() and loadingScreen.initialised()
				and quickHelp.initialised() and stats.initialised() and tutorialBox.initialised()
				and codeBox.initialised() and statusMsg.initialised() and pSpeach.initialised() then
			initialising = false
			finishStartupProcess()
		end
	else
	
		connection.handleConnection()
		functionQueue.run()
	
		if msgBox.moving then
			msgBox.handleClick()
		elseif codeBox.moving then
			codeBox.handleClick()
		elseif tutorialBox.moving then
			tutorialBox.handleClick()
		else
			button.calcMouseHover()
		end
		if mapImage then
			if simulationMap and not roundEnded then
				simulationMap.time = simulationMap.time + dt*timeFactor
				simulation.update(dt*timeFactor)
				if train.isRenderingImages() then
					train.renderTrainImage()
				end
			end
			if not roundEnded and not simulation.isRunning() then
				map.handleEvents(dt)
			end
	
			prevX = camX
			prevY = camY
			if panningView then
				x, y = love.mouse.getPosition()
				camX = clamp(camX - (mouseLastX-x)*0.75/camZ, -MAX_PAN, MAX_PAN)
				camY = clamp(camY - (mouseLastY-y)*0.75/camZ, -MAX_PAN, MAX_PAN)
				mouseLastX = x
				mouseLastY = y
			
				floatPanX = (camX - prevX)*40
				floatPanY = (camY - prevY)*40
				
			else
				if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
					camX = clamp(camX + 300*dt/camZ, -MAX_PAN, MAX_PAN)
				end
				if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
					camX = clamp(camX - 300*dt/camZ, -MAX_PAN, MAX_PAN)
				end 
				if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
					camY = clamp(camY + 300*dt/camZ, -MAX_PAN, MAX_PAN)
				end
				if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
					camY = clamp(camY - 300*dt/camZ, -MAX_PAN, MAX_PAN)
				end
				if love.keyboard.isDown("q") then
					camZ = clamp(camZ + dt*0.25, 0.1, 1)
					camX = clamp(camX, -MAX_PAN, MAX_PAN)
					camY = clamp(camY, -MAX_PAN, MAX_PAN)
				end
				if love.keyboard.isDown("e") then
					camZ = clamp(camZ - dt*0.25, 0.1, 1)
					camX = clamp(camX, -MAX_PAN, MAX_PAN)
					camY = clamp(camY, -MAX_PAN, MAX_PAN)
				end
			
				if camX ~= prevX or camY ~= prevY then
					floatPanX = (camX - prevX)*20
					floatPanY = (camY - prevY)*20
				end
			end
			if camX == prevX and camY == prevY then
				floatPanX = floatPanX*math.max(1 - dt*3, 0)
				floatPanY = floatPanY*math.max(1 - dt*3, 0)
				camX = clamp(camX + floatPanX*dt, -MAX_PAN, MAX_PAN)
				camY = clamp(camY + floatPanY*dt, -MAX_PAN, MAX_PAN)
			end
		elseif map.startupProcess() then
			if mapGenerateThread then
				err = mapGenerateThread:get("error")
				if err then
					print("Error in thread", err)
				end
				curMap = map.generate()
			elseif mapRenderThread then
				err = mapRenderThread:get("error")
				if err then
					print("Error in thread", err)
				end
				
				--if simulation.isRunning() then
					mapImage,mapShadowImage,mapObjectImage = map.render()
				--else
					--simulationMapImage,mapShadowImage,mapObjectImage = map.render()
				--end
			end
			if train.isRenderingImages() then
				train.renderTrainImage()
			end
			
			if not train.isRenderingImages() and not mapGenerateThread and not mapRenderThread then	-- done rendering everything!
				if not simulation.isRunning() then
					runMap()	-- start the map!
				else
					simulation.runMap()
				end
			end
		else
			if menu.isRenderingImages() then
				menu.renderTrainImages()
			end
		end
		
		
	
		if not roundEnded then
			train.moveAll()
			if curMap then
				curMap.time = curMap.time + dt*timeFactor
			end
		end
	end
	
end


function love.draw()

	if initialising then		--only runs once at startup, until all images are rendered.
		loadingScreen.render()
		return
	end

	-- love.graphics.rectangle("fill",50,50,300,300)
	dt = love.timer.getDelta()
	passedTime = dt*timeFactor
	
	if mapImage then
		if simulationMap then
			simulation.show(dt)
		else
			map.show()
		
			if showQuickHelp then quickHelp.show() end
			if showConsole then console.show() end
			
			stats.displayStatus()
		end
	else
		if not hideLogo then
			love.graphics.draw(LOGO_IMG, (love.graphics.getWidth()-LOGO_IMG:getWidth())/2, love.graphics.getHeight()-LOGO_IMG:getHeight()- 50)
		end
		if mapGenerateThread or mapRenderThread then -- or trainGenerateThreads > 0 then
			loadingScreen.render()
		else
			simulation.displayTimeUntilNextMatch(nil, dt)
		end
	end

	
	--love.graphics.setColor(255,255,255,50)
	--love.graphics.circle("fill", mapMouseX, mapMouseY, 20)
	--[[
	love.graphics.print("mouse x " .. mapMouseX, 10, 200)
	love.graphics.print("mouse y " .. mapMouseY, 10, 220)
	love.graphics.print("normal mouse x " .. love.mouse.getX(), 10, 240)
	love.graphics.print("normal mouse y " .. love.mouse.getY(), 10, 260)
	]]--
	
	if roundEnded and (curMap or simulationMap) and mapImage then stats.display(love.graphics.getWidth()/2-175, 40, dt) end
	
	
	button.show()
	
	tutorialBox.show()
	codeBox.show()
	if msgBox.isVisible() then
		msgBox.show()
	end
	
	menu.render()
	statusMsg.display(dt)
	
	if love.keyboard.isDown(" ") then
		love.graphics.setFont(FONT_CONSOLE)
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("FPS: " .. tostring(love.timer.getFPS( )), love.graphics.getWidth()-150, 5)
		love.graphics.print('RAM: ' .. collectgarbage('count'), love.graphics.getWidth()-150,20)
		love.graphics.print('X: ' .. camX, love.graphics.getWidth()-150,35)
		love.graphics.print('Y: ' .. camY, love.graphics.getWidth()-150,50)
		love.graphics.print('Z ' .. camZ, love.graphics.getWidth()-150,65)
		love.graphics.print('Passengers: ' .. MAX_NUM_PASSENGERS, love.graphics.getWidth()-150,80)
		love.graphics.print('Trains: ' .. numTrains, love.graphics.getWidth()-150,95)
		love.graphics.print('x ' .. timeFactor, love.graphics.getWidth()-150,110)
		if curMap then love.graphics.print('time ' .. curMap.time, love.graphics.getWidth()-150,125) end
		if roundEnded then
			love.graphics.print('roundEnded: true', love.graphics.getWidth()-150,140)
		else
			love.graphics.print('roundEnded: false', love.graphics.getWidth()-150,140)
		end
	end
	
end

function love.quit()
	print("Closing.")
end
