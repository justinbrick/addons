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
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.ViewModel = "" --We don't want a view model or a world model for this.
SWEP.WorldModel = "" 

--The attack hooks are fired on server realm, as it's predicted.
--Function firing upon left click.

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 1) --We want a 1 second delay between firing.
    self:SlowTime() -- Run the slowtime function.
end

--Function firing upon right click.
function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 1) --TODO: Change timer based on what I want this function to do.
    self:ResumeTime()
end

--[[
    NOTE:
    Due to the fact that you can't necessarily "slow" time down for everything except players, what you can do instead is slow down the animations and walkspeed of
    all the entities on the map, and along with that you can slow down the physics time.
    CORRECTION: You can't slow down the speed of NPC's themselves. I have no way of making the NPC's go into slow mode.
    For the physics timescale, there's no built in functions in the API for this, but there is a console command called "phys_timescale", which is what I'll use as a
    replacement instead to slow down the physics of objects.
]]

--The main function we'll use to "slow" time.
function SWEP:SlowTime()
    
    if SERVER then
        RunConsoleCommand("phys_timescale", 0.025)
    end

end

--This'll be the function we use to resume time back to what it normally is.
function SWEP:ResumeTime()

    if SERVER then
        RunConsoleCommand("phys_timescale", 1)
    end
    

end
