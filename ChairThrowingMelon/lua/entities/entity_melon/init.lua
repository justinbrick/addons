AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-------------VARIABLES--------------
ENT.range = 1000
ENT.voiceLines = {
    "vo/npc/male01/gethellout.wav",
    "vo/npc/male01/runforyourlife01.wav",
    "vo/npc/male01/thehacks01.wav",
    "vo/npc/male01/moan01.wav"
}

-------------FUNCTIONS--------------

-- Initialization Function to get physics and model drawing up and going.
function ENT:Initialize()
    print("Initializing Melon!")
    self:SetModel("models/props_junk/watermelon01.mdl")
    self:PhysicsInit(SOLID_VPHYSICS) -- We might need to change this, depending on how I want the melon to function.
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)    

    self.timer = util.Timer(5)
    self.pointToHover = self:GetPos() + Vector(0,0,50)
    self.lastPos = self:GetPos()
    
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then 
        phys:EnableGravity(false)
    end
end

--Simple spawn function to place the melon where we need it, or where we're looking.
function ENT:SpawnFunction(ply, trace, classname)
    if !trace.HitWorld then return end
    local melon = ents.Create(classname)
    melon:SetPos(trace.HitPos + Vector(0,0,20))
    melon:Spawn()

    return melon
end

--What logic do we want to add to the melon?
function ENT:Think()
    local phys = self:GetPhysicsObject() -- Get the physics object to move this around.
    local vector = (self.pointToHover - phys:GetPos()) * 30
    if phys:GetAngleVelocity().z < 1000 then
        phys:AddAngleVelocity(Vector(0,0,50))
    end
    phys:ApplyForceCenter(vector + vector - self.lastPos) --We're using a delta to smoothen out the movement, otherwise it would be wild. 
    self.lastPos = vector
    
    if self.timer:Elapsed() then
        self.timer:Start(5)
        self:FindPlayers()
    end

end

function ENT:FindPlayers() --Function for finding players then adding
    local rangeSqr = self.range * self.range
    local inRange = false

    for i,player in ipairs(player.GetAll()) do
        if self:GetPos():DistToSqr(player:GetPos()) <= rangeSqr then
            local trace = util.TraceLine({
                start = self:WorldSpaceCenter(),
                endpos = player:EyePos(),
                filter = {self}
            })
            if trace.HitWorld then return end
            inRange = true
            self:ThrowChair(player)
        end
    end

    if inRange then
        local soundVariable = table.Random(self.voiceLines, 100)
        self:EmitSound(soundVariable)
    end
end

function ENT:ThrowChair(player)
    local difference = (player:EyePos() - self:WorldSpaceCenter()):GetNormalized()
    local chair = ents.Create("prop_physics")

    chair:SetModel("models/nova/chair_plastic01.mdl")
    chair:SetPos(self:WorldSpaceCenter() + difference * 40)

    chair:Spawn()
    chair:Activate()
    local phys = chair:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:SetVelocity(difference * 1000 * phys:GetMass())
    end
    SafeRemoveEntityDelayed(chair, 20)
end
