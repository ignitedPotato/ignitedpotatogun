
print("[ignitedPotato] Checking portal2 ...")
if (not IsMounted("portal2")) then
    print("[ignitedPotato] portal2 not loaded! Disabling weapon.")
    return
else
    print("[ignitedPotato] portal2 ok! Continuing ...")
end

AddCSLuaFile()

SWEP.PrintName = "ignitedPotato Gun"
SWEP.Author = "ignitedPotato"
SWEP.Category = "ignitedPotato"
SWEP.Instructions = "Left mouse to fire a flaming potato!"
SWEP.Purpose = "A gun. That shoots ignited potatoes."

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 2
SWEP.SlotPos = 5
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false
SWEP.DrawWeaponInfoBox = false

SWEP.ShootSound = Sound("weapons/grenade_launcher1.wav")
SWEP.EmptySound = Sound("weapons/wpn_denyselect.wav")
SWEP.Potato = Model("models/npcs/potatos/world_model/potatos_wmodel.mdl")

function SWEP:Initialize()
    self:SetHoldType("smg")
end

function SWEP:Reload() end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.5)

    local owner = self:GetOwner()
    if (not owner:IsValid()) then return end

    self:EmitSound(self.ShootSound)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

    if (CLIENT) then return end

    local ent = ents.Create("prop_physics")
    if (not ent:IsValid()) then return end

    ent:SetModel(self.Potato)

    local aimvec = owner:GetAimVector()
    local pos = aimvec * 16

    pos:Add(owner:EyePos())
    ent:SetPos(pos)

    ent:SetAngles(owner:EyeAngles())
    ent:Spawn()
    ent:Ignite(10, 100)

    local phys = ent:GetPhysicsObject()
    if (not IsValid(phys)) then
        ent:Remove()
        return
    end

    aimvec:Mul(10000)
    aimvec:Add(VectorRand(-10, 10))
    phys:ApplyForceCenter(aimvec)

    cleanup.Add(self.Owner, "props", ent)

    undo.Create("Thrown_Potato")
    undo.AddEntity(ent)
    undo.SetPlayer(owner)
    undo.SetCustomUndoText("Removed a hot potato")
    undo.Finish()

    timer.Simple(15, function() if ent and ent:IsValid() then ent:Remove() end end)

end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self:EmitSound(self.EmptySound)
end

function SWEP:ShouldDropOnDie() return false end

print("[ignitedPotato] Ready.")
