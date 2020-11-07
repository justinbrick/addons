AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

-----------VARIABLES------------
ENT.range = 3000 * 3000


-----------FUNCTIONS------------

--What we want the entity to do on startup.
function ENT:Initialize()
    self:SetModel("models/props_phx/construct/metal_dome360.mdl")
    self:SetModelScale(0.2)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:Activate()
    self.timer = util.Timer(5)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

--What do we want to put in the mortar logic?
function ENT:Think()
    if self.timer:Elapsed() then
        self.timer:Start(5)

        for k,v in pairs(player.GetAll()) do
            if self:GetPos():DistToSqr(v:GetPos()) <= self.range then
                self:ShootCan(player)
            end
        end
    end
end

function ENT:ShootCan(player)
    local can = ents.Create("prop_physics")
    can:SetModel("models/props_junk/PopCan01a.mdl")
    can:SetMoveType(MOVETYPE_NONE)
    can:SetSolid(SOLID_VPHYSICS)
    can:SetPos(self:GetPos() + Vector(0,0,10))
    can:Spawn()
    can:Activate()

    

end

function ENT:SpawnFunction(player, trace, classname)
    if !trace.HitWorld then return end
    local mortar = ents.Create(classname)
    mortar:SetPos(trace.HitPos + Vector(0,0,2))
    mortar:Spawn()
    
    return mortar
end

--What do we want the mortar to do upon use?
function ENT:Use()

end
