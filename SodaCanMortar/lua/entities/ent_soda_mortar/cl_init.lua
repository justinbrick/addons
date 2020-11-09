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
        local target = projectileData.target
        local startTime = projectileData.startTime
        local endTime = projectileData.endTime
        local elapsedTime = CurTime() - startTime
        local elapsedEndTime = endTime - CurTime()
        if CurTime() < endTime then
            can:SetPos(LerpVector(elapsedTime/10, self:GetPos() + Vector(0,0,20), target:EyePos()))
        else
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

--Calculate the amount of time that the can will be in the air.
function ENT:CalculateAirTime()

end

--Calculate the max height that the can will travel, use for a sine wave.
function ENT:CalculateMaxHeight() 

end

--Find the angle to position the cannon towards, in order to make it look like it's shooting the can.
function ENT:FindAngle()

end

--When we get a network message, create a can and make it do this stuff.
net.Receive("jCanShot", function(len, ply)

    local can = ents.CreateClientProp("prop_physics")
    local mortar = net.ReadEntity()
    local target = net.ReadEntity()
    local startTime = CurTime() 
    local endTime = CurTime() + 10
    can:SetModel("models/props_junk/PopCan01a.mdl")
    can:SetPos(mortar:GetPos() + Vector(0, 0, 20))
    can:SetMoveType(MOVETYPE_NONE)
    can:Spawn()

    table.insert(mortar.projectileList, {
        can = can,
        target = target,
        startTime = startTime,
        endTime = endTime
    })

end)