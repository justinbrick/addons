AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


-- Initialization Function to get physics and model drawing up and going.
function ENT:Initialize()
    print("Initializing Melon!")
    self:SetModel("models/props_junk/watermelon01.mdl")
    self:PhysicsInit(SOLID_VPHYSICS) -- We might need to change this, depending on how I want the melon to function.
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self.pointToHover = Vector(1,1,1)
    self.lastPos = Vector(1,1,1)
    self.firstTick = false

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then phys:Wake() end
end

--Simple spawn function to place the melon where we need it, or where we're looking.
function ENT:SpawnFunction(ply, trace)
    if !trace.HitWorld then return end
    local melon = ents.Create("entity_melon")
    melon:SetPos(trace.HitPos + Vector(0,0,20))
    melon:Spawn()
end

--What do we want the melon to do when we interact with it?
function ENT:Use()
    
end

--What logic do we want to add to the melon?
function ENT:Think()
    local phys = self:GetPhysicsObject() -- Get the physics object to move this around.
    if !self.firstTick then
        self.firstTick = true
        self.pointToHover = phys:GetPos() + Vector(0,0,100)
    end
    local vector = (self.pointToHover - phys:GetPos()) * 20
    phys:ApplyForceCenter(vector + vector - self.lastPos) --We're using a delta to smoothen out the movement, otherwise it would be wild. 
    self.lastPos = vector
end