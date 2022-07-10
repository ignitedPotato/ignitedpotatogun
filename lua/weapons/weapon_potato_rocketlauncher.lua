if (not IsMounted("portal2")) then return end

AddCSLuaFile()

SWEP.PrintName = "Potato Rocket Launcher"
SWEP.Author = "ignitedPotato"
SWEP.Category = "ignitedPotato"
SWEP.Instructions = "Left mouse to fire a rocket!"
SWEP.Purpose = "A rocket launcher. Rockets explode into potatoes."

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 4
SWEP.SlotPos = 5
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false
SWEP.DrawWeaponInfoBox = false

SWEP.ShootSound = Sound("Weapon_RPG.Single")
SWEP.WepSelectIcon = Material("ignitedpotato/potato.png")

SWEP.laser = nil
SWEP.laserbeam = nil

function SWEP:Initialize() self:SetHoldType("rpg") end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 1)
    self:ShootEffects()

    local owner = self:GetOwner()
    if (not owner:IsValid()) then return end

    self:EmitSound(self.ShootSound, 100, math.random(85, 100))

    if (CLIENT) then return end

    local ang = owner:EyeAngles()
    local vec = owner:GetAimVector()

    local ent = ents.Create("potato_rocket")
    ent:SetPos(owner:GetShootPos() + ang:Right() * 10 + owner:GetAimVector() *
                   35 - ang:Up())
    ent:SetAngles(self:LocalToWorldAngles(Angle()))
    ent:SetOwner(owner)
    ent:Spawn()

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then phys:EnableGravity(false) end
end

function SWEP:SecondaryAttack() end

function SWEP:Reload() end

function SWEP:Think()
    if (CLIENT) then return end

    if IsValid(self.laser) and IsValid(self.laserbeam) then
        local eyeTrace = self:GetOwner():GetEyeTrace()
        self.laser:SetPos(eyeTrace.HitPos)

        local ang = self.Owner:EyeAngles()
        self.laserbeam:SetPos(self.Owner:GetShootPos() + ang:Right() * 10 +
                                  self.Owner:GetAimVector() * 20 - ang:Up())
    else
        local rand = math.random(100000, 999999)

        self.laser = ents.Create("potato_laser")
        if IsValid(self.laser) then
            self.laser:SetOwner(self:GetOwner())
            self.laser:SetName("potato_laser_" .. rand)

            local eyeTrace = self:GetOwner():GetEyeTrace()
            self.laser:SetPos(eyeTrace.HitPos)

            self.laser:Spawn()
        end

        self.laserbeam = ents.Create("env_laser")
        if IsValid(self.laserbeam) then
            self.laserbeam:SetOwner(self:GetOwner())

            local ang = self.Owner:EyeAngles()
            self.laserbeam:SetPos(self.Owner:GetShootPos() + ang:Right() * 10 +
                                      self.Owner:GetAimVector() * 20 - ang:Up())

            self.laserbeam:SetKeyValue("LaserTarget", "potato_laser_" .. rand)

            self.laserbeam:SetKeyValue("width", 0.1)
            self.laserbeam:SetKeyValue("rendercolor", "255 0 0")
            self.laserbeam:SetKeyValue("texture", "sprites/laserbeam.spr")
            self.laserbeam:SetKeyValue("ClipStyle", 2)

            self.laserbeam:Spawn()
            self.laserbeam:Activate()
        end

    end
end

function SWEP:ShouldDropOnDie() return false end

function SWEP:DrawWeaponSelection(x, y, w, h, a)
    surface.SetDrawColor(255, 255, 255, a)
    surface.SetMaterial(self.WepSelectIcon)

    local size = math.min(w, h)
    surface.DrawTexturedRect(x + w / 2 - size / 2, y, size, size)
end

function SWEP:Holster()
    if (CLIENT) then return end
    if IsValid(self.laserbeam) then self.laserbeam:Remove() end
    if IsValid(self.laser) then self.laser:Remove() end
    return true
end

function SWEP:OnRemove() self:Holster() end

function SWEP:OnDrop() self:Holster() end
