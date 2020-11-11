include("shared.lua")

---------VARIABLES---------
ENT.projectileList = {} -- A list of projectiles we're doing logic on.
ENT.barrelOffset = nil --The angle that the barrel will be offset by.
ENT.force = 100 -- The amount of force that the cannon uses to launch the cans. Will predict how long it takes to fly, and the amount of height it gets.
---------FUNCTIONS---------

--Simple draw method.
function ENT:Draw()
    self:DrawModel()
end

--What do we want this mortar to do on startup?
function ENT:Initialize()
    self.barrel = ents.CreateClientProp("prop_physics")
    self.barrel:SetModel("models/props_phx/construct/metal_plate_curve360x2.mdl")
    self.barrel:SetModelScale(0.08) 
    self.barrel:PhysicsInit(SOLID_NONE)
    self.barrel:SetMoveType(MOVETYPE_NONE)
    self.barrel:SetSolid(SOLID_NONE)
    self.barrel:SetPos(self:GetPos() + Vector(0,0,8))
    self.barrel:Spawn()
    self.barrel:Activate()
end

--On remove, get rid of the barrel. I would do this using ENTITY:DeleteOnRemove, but this is serverside only as far as I can tell.
function ENT:OnRemove()
    if self.barrel then
        self.barrel:Remove()
    end
end

--The logic that we're using the calculate where the can will be going. Iterates through the mortar's list of projectiles it has airborne.
function ENT:ProjectileLogic()
    for key, projectileData in pairs(self.projectileList) do
        local can = projectileData.can
        local beginPos = projectileData.beginPos
        local targetPos = projectileData.targetPos
        local startTime = projectileData.startTime
        local endTime = projectileData.endTime
        local airTime = projectileData.airTime
        local maxHeight = projectileData.maxHeight
        local elapsedTime = CurTime() - startTime
        local elapsedEndTime = endTime - CurTime()
        if CurTime() < endTime then
            can:SetPos(LerpVector(elapsedTime/airTime, beginPos, targetPos))
            local canPos = can:GetPos()
            can:SetPos(Vector(canPos.x, canPos.y, beginPos.z + (maxHeight * math.sin((elapsedTime/airTime) * math.pi))))
        else
            local effectData = EffectData()
            effectData:SetOrigin(can:GetPos())
            effectData:SetMagnitude(10)
            effectData:SetScale(1)
            util.Effect("Explosion", effectData)
            can:Remove()
            table.remove(self.projectileList, key)
        end
        
    end
end

--Tick based function, will run every frame (I think?) (Correction: Called every frame on the client, every tick on server.)
function ENT:Think()
    self:ProjectileLogic()
    if self.barrel then
        self.barrel:SetPos(self:GetPos() + Vector(0,0,8))
    end
end

--When we get a network message, create a can and make it do this stuff.
net.Receive("jCanShot", function(len, ply)

    local can = ents.CreateClientProp("prop_physics")
    local mortar = net.ReadEntity()
    local target = net.ReadEntity()
    local beginPos = mortar:GetPos() + Vector(0,0,20)
    local targetPos = Vector(target:GetPos().x, target:GetPos().y, beginPos.z) -- We don't want their y on this.

    local startTime = CurTime() 
    local angle = mortar:SolveAngle(target)
    if !angle then print("Failed") return end -- If the angle is unsolvable, it will return false. If it catches a false, then end.
    local airTime = mortar:CalculateAirTime(angle, beginPos:Distance(targetPos))
    local endTime = airTime + CurTime()
    local maxHeight = mortar:CalculateMaxHeight(angle)
    can:SetModel("models/props_junk/PopCan01a.mdl")
    can:SetPos(mortar:GetPos() + Vector(0, 0, 20))
    can:SetMoveType(MOVETYPE_NONE)
    can:Spawn()
    SafeRemoveEntityDelayed(can, 20)

    table.insert(mortar.projectileList, {
        can = can,
        beginPos = beginPos,
        targetPos = targetPos,
        startTime = startTime,
        endTime = endTime,
        maxHeight = maxHeight,
        airTime = airTime
    })

end)