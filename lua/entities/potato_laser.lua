AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Spawnable = false

function ENT:Initialize()
    if (CLIENT) then return end
    self:SetModel("models/dav0r/buttons/button.mdl")
    self:SetSkin(2)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
    self:PhysicsInit(SOLID_NONE)

    self:SetRenderMode(RENDERMODE_TRANSCOLOR)
    self:SetColor(Color(0, 0, 0, 0))

    local phys = self:GetPhysicsObject()

end

function ENT:Think() end

