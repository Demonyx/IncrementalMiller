import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/ui"
import "CoreLibs/crank"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics
local revolutions = 0
local menu = true

function saveGameData()
    local gameData = {
        currentRevolutions = revolutions
    }
    playdate.datastore.write(gameData)
end

function playdate.gameWillTerminate()
    saveGameData()
end

function playdate.gameWillSleep()
    saveGameData()
end

function playdate.deviceWillLock()
    saveGameData()
end

local gameData = playdate.datastore.read()

function clearSaveData()
    playdate.stop()
    gfx.clear()
    gfx.drawText("Warning: This will reset all game progress.", 30, 120)
    gfx.drawText("Are you sure?", 30, 140)

    function playdate.AButtonDown()
        revolutions = 0
        gameData = {
            currentRevolutions = revolutions
        }
        playdate.datastore.write(gameData)
        playdate.start()
    end
        
    function playdate.BButtonDown()
        playdate.start()
    end
end

function gameSetup()
    local menu = playdate.getSystemMenu()
    local menuItem, error = menu:addMenuItem("New Game", clearSaveData)

    if gameData then
        revolutions = gameData.currentRevolutions
    end
  
end

gameSetup()

function startMenu()
    local current, pressed, released = playdate.getButtonState()
    
    if current ~= 0 or pressed ~= 0 or released ~= 0 then
        menu = false
    end

    return menu
end

local ticks = 0
function playdate.update()
    if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:draw()
    else
        gfx.clear()
    end

    if startMenu() then
        gfx.drawText("Press any button to continue", 100, 200)
        return
    end

    local bread = gfx.image.new("/images/bread.png")
    bread:draw(0,0)
    gfx.drawText(revolutions, 140, 120)


    local ticksPerRevolution = 6
    local crankTicks = playdate.getCrankTicks(ticksPerRevolution)

    ticks += math.abs(crankTicks)
    if ticks >= ticksPerRevolution then
        revolutions += 1
        ticks -= ticksPerRevolution
        bread:draw(0,0)
        gfx.drawText(revolutions, 140, 120)
    end


end