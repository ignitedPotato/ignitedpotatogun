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

    ent.laser = self.laser

    ent:Spawn()

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then phys:EnableGravity(false) end
end

function SWEP:SecondaryAttack() end

function SWEP:Reload() end

function SWEP:Think()
    if (CLIENT) then return end

    if IsValid(self.laser) then
        local eyeTrace = self:GetOwner():GetEyeTrace()
        self.laser:SetPos(eyeTrace.HitPos + eyeTrace.HitNormal * 2)
    else
        local rand = math.random(100000, 999999)

        self.laser = ents.Create("env_sprite")
        if IsValid(self.laser) then
            self.laser:SetOwner(self:GetOwner())

            self.laser:SetKeyValue("model", "sprites/redglow1.vmt")
            self.laser:SetKeyValue("scale", 0.1)
            self.laser:SetKeyValue("rendermode", 5)

            local eyeTrace = self:GetOwner():GetEyeTrace()
            self.laser:SetPos(eyeTrace.HitPos + eyeTrace.HitNormal * 2)

            self.laser:Spawn()
            self.laser:Activate()
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
    if IsValid(self.laser) then self.laser:Remove() end
    return true
end

function SWEP:OnRemove() self:Holster() end

function SWEP:OnDrop() self:Holster() end
