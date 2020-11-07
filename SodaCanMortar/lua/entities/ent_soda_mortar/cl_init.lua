include("shared.lua")

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

function ENT:Think()
    if self.barrel then
        self.barrel:SetPos(self:GetPos() + Vector(0,0,8))

    end
end

