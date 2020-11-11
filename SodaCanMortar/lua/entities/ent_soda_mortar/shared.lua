ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.Spawnable = true
ENT.PrintName = "Soda Can Mortar"
ENT.Author = "POTATO#9375"
ENT.Purpose = "Get bombarded by a limitless supply of explosive soda cans."
ENT.Instructions = "Place Mortar. Die."

--Find the angle to position the cannon towards, in order to make it look like it's shooting the can.
--Equation: arctan(f^2+sqrt(f^4-g(gx^2 + 2f^2*y)))
function ENT:SolveAngle(player)
    local selfPos = self:GetPos() 
    local playerPos = player:GetPos()
    local difference = playerPos - selfPos
    local distance = Vector(selfPos.x, selfPos.y, 0):Distance(Vector(playerPos.x, playerPos.y, 0))
    local gravity = 9.81
    local force = self.force
    local force2 = force*force -- We're turning these into their equivalents to make this code a bit easier to read.
    local force4 = force*force*force*force
    local sqrt = force4-gravity*(gravity*distance*distance + 2*force2*(difference.z))
    if sqrt<0 then return false end
    sqrt = math.sqrt(sqrt)
    local result = math.atan2(force2 + sqrt, gravity * distance)
    if !(result == result) then
        result = math.atan2(force2 - sqrt, gravity * distance)
        
        result = !(result == result) and false or result
    end 
    print("Angle:", result*(180/math.pi))
    return result
end

--Calculate the amount of time that the can will be in the air.
-- X component = force*time*cos(angle);
-- time = x component/(force*cos(angle))
function ENT:CalculateAirTime(angle, distance)
    print(distance/(self.force * math.cos(angle))/2)
    return (distance / (self.force * math.cos(angle)))/8
end

--Calculate the max height that the can will travel, use for a sine wave.
-- 0 = velocity - 4.9t; (basically, finding where velocity equals 0)
-- t = velocity/(gravity/2)
-- y = velocity*t - 1/2at^2
function ENT:CalculateMaxHeight(angle) 
    local gravity = 9.81
    local velocity = self.force * math.sin(angle)
    local time = velocity/gravity
    print("Time 2: ", time)
    local time2 = time * time
    local maxHeight = velocity*time - (gravity/2)*time2
    print("Max height:", maxHeight)
    return maxHeight
end

--Use the formula for max range based on difference in the Z axis, and then return if it's within range.
function ENT:PlayerInRange(player)
    local zDiff = player:GetPos().z - self:GetPos().z
    local maxRange = ((self.velocity * math.cos(math.rad(45)))/9.81) * (self.velocity*math.sin(math.rad(45))+math.sqrt(math.pow(self.velocity, 2) * math.pow(math.sin(math.rad(45)), 2) + 2 * 9.81 * zDiff))
    return self:GetHorizontalDistanceSqr(player) < maxRange * maxRange
end