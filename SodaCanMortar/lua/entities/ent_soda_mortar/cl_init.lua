include("shared.lua")

---------VARIABLES---------

ENT.projectileList = {} -- A list of projectiles we're doing logic on.
---------FUNCTIONS---------

function ENT:Draw()
    self:DrawModel()
end

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

function ENT:OnRemove()
    if self.barrel then
        self.barrel:Remove()
    end
end

function ENT:ProjectileLogic()
    for key, projectileData in pairs(self.projectileList) do
        local can = projectileData.can
        local target = projectileData.target
        local startTime = projectileData.startTime
        local endTime = projectileData.endTime
        local elapsedTime = CurTime() - startTime
        local elapsedEndTime = endTime - CurTime()
        if CurTime() < endTime then
            can:SetPos(LerpVector(elapsedTime/elapsedEndTime, self:GetPos() + Vector(0,0,20), target:GetPos()))
        else
            table.remove(self.projectileList(key))
        end
        
    end
end

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