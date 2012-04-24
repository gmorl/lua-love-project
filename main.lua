function love.load()
    level = {}
    level.powerups = {}
    level.endPoint = 465
    level.rounds = {}

    hero = {} 
    hero.x = 300
    hero.y = 450
    hero.width = 30
    hero.height = 15
    hero.speed = 75
    hero.shots = {}
    hero.damage = 20
    hero.score = 0

    enemies = {}

    for i=0,7 do
        enemy = {}
        enemy.width = 40
        enemy.height = 20
        enemy.x = i * (enemy.width + 60) + 100
        enemy.y = enemy.height + 100
        enemy.health = 100
        enemy.speed = 0.2
        enemy.deathbonus = 30
        table.insert(enemies, enemy)
    end
end

function love.keyreleased(key)
    if (key == " ") then
        shoot()
    end
end

function love.update(deltaTime)
    tryCreateRound(deltaTime)
    tryCreatePowerup(deltaTime)
    tryActivatePowerups(deltaTime)

    for i,enemy in ipairs(enemies) do
        if enemy.y > level.endPoint then 
            hero.speed = 0
        else
            enemy.y = enemy.y + (enemy.speed + deltaTime)

            --remove enemy from table if health is less than 0.
            if enemy.health <= 0 then
                table.remove(enemies, i)
                hero.score = hero.score + enemy.deathbonus
            end             
   
            if love.keyboard.isDown("left") then
                hero.x = hero.x - hero.speed*deltaTime
            elseif love.keyboard.isDown("right") then
                hero.x = hero.x + hero.speed*deltaTime
            end

            local deadShots = {}

            for i,shot in pairs(hero.shots) do
                shot.y = shot.y - (deltaTime * shot.speed)        
                if shot.y < 0 then          
                    table.insert(deadShots, i)
                end

                for enemyIndex,enemy in ipairs(enemies) do
                    if CheckCollision(shot.x,shot.y,shot.width,shot.height,enemy.x,enemy.y,enemy.width,enemy.height) then
                        table.insert(deadShots, i)
                        enemy.health = enemy.health - hero.damage 
                        hero.score = hero.score + hero.damage
                    end
                end
            end
            -- remove dead shots from hero.shots
            for i,shotIndex in ipairs(deadShots) do
                table.remove(hero.shots, shotIndex)
            end
        end
    end
end

function love.draw()
    love.graphics.setColor(255,255,255,255)

    love.graphics.setColor(0,255,0,255)
    love.graphics.rectangle("fill", 0, 465, 800, 150)

    love.graphics.setColor(255,255,0,255)
    love.graphics.rectangle("fill", hero.x, hero.y, hero.width, hero.height)

    love.graphics.setColor(255,255,255,255)
    for i,v in ipairs(hero.shots) do
        love.graphics.rectangle("fill", v.x, v.y, 2, 5)
    end

    for i,v in ipairs(enemies) do
        love.graphics.setColor(0,255,255,255)
        love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
    
        --put bar above enemy target, decrease with greater damage
        love.graphics.setColor(255,0,100,255)    
        love.graphics.rectangle("fill", v.x, v.y - (1/4 * v.height), v.width * (v.health / 100), (1/2 * v.height))
    end

    --draw powerup box
    for name,powerup in pairs(level.powerups) do
        if not powerup.active then
            love.graphics.setColor(100,100,100,255)
            love.graphics.rectangle("fill", powerup.x, powerup.y, powerup.width, powerup.height)
        end
    end

    drawScore()

end

function shoot()
    local shot = {}
    shot.x = hero.x+hero.width/2
    shot.y = hero.y
    shot.width = 2
    shot.height = 5

    if level.powerups.speedshot and level.powerups.speedshot.active then
        shot.speed = 200
    else
        shot.speed = 25
    end

    table.insert(hero.shots, shot)
end

function CheckCollision(box1x, box1y, box1w, box1h, box2x, box2y, box2w, box2h)
    if box1x > box2x + box2w - 1 or
       box1y > box2y + box2h - 1 or
       box2x > box1x + box1w - 1 or
       box2y > box1y + box1h - 1 
    then
        return false
    else
        return true
    end
end

function tryCreatePowerup()
    math.randomseed(os.time())
    if math.random(100) < 99 then
        if not level.powerups.speedshot then
            createPowerup()
        end
    end
end

function createPowerup(deltaTime)
    name = "speedshot"
    powerup = {}
    powerup.x = 50
    powerup.y = 0
    powerup.width = 10
    powerup.height = 5
    math.randomseed(os.time())
    powerup.speed = math.random(0.85, 2)
    powerup.active = false
    level.powerups[name] = powerup
end

function tryActivatePowerups(deltaTime)
    for name,powerup in pairs(level.powerups) do
        if powerup.y > level.endPoint then 
            level.powerups[name] = nil
        elseif CheckCollision(hero.x, hero.y, hero.width, hero.height, powerup.x, powerup.y, powerup.width, powerup.height) then
            powerup.active = true
        elseif not powerup.active then
            powerup.y = powerup.y + (powerup.speed + deltaTime)
        end
    end
end
  
function drawScore()
    love.graphics.setFont(24)
    love.graphics.print(hero.score, 120, 50)
    love.graphics.print("Score = ", 20, 50)
end

function tryCreateRound(deltaTime)
    if i,enemy in ipairs(enemies) <= 0 then
        createNewRound()    
    end
end

function createNewRound(deltaTime)

end
