--Basic SWEP Setup

SWEP.PrintName = "Quicksilver"
SWEP.Author = "POTATO#9375"
SWEP.Instructions = "Left click to slow down time."
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

--Function firing upon left click.
function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 1) --We want a 1 second delay between firing.
    print("Primary Fire!")
end

--Function firing upon right click.
function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 1) --TODO: Change timer based on what I want this function to do.
end

--The main function we'll use to "slow" time.
function SWEP:SlowTime()

end
