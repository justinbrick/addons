AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

-----------VARIABLES------------
ENT.range = 3000 * 3000
ENT.velocity = 100
ENT.projectileList = {} -- A list of current projectiles that have been shot.

util.AddNetworkString("jCanShot")

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

        for _,player in pairs(player.GetAll()) do
            if self:GetHorizontalDistanceSqr(player) <= self.range then
                self:ShootCan(player)
            end
        end
    end
end

function ENT:ShootCan(player)
    if !self:PlayerInRange(player) then return end
    net.Start("jCanShot")
    net.WriteEntity(self) --The specific mortar that's shooting.
    net.WriteEntity(player) --The player
    net.Broadcast()
end

--Use the formula for max range based on difference in the Z axis, and then return if it's within range.
function ENT:PlayerInRange(player)
    local zDiff = self:GetPos().z - player:GetPos().z
    local maxRange = ((self.velocity * math.cos(45))/9.8) * (self.velocity*math.sin(45)+math.sqrt(math.pow(self.velocity, 2) * math.pow(math.sin(45), 2) + 2 * 9.8 * zDiff))
    return self:GetHorizontalDistanceSqr(player) < maxRange * maxRange
end

--Get the distance between this entity and a specific player on the X plane only.
function ENT:GetHorizontalDistanceSqr(player)
    local x1, y1 = self:GetPos().x, self:GetPos().y
    local x2, y2 = player:GetPos().x, player:GetPos().y
    return (math.pow(x2-x1, 2) + math.pow(y2-y1, 2))
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
