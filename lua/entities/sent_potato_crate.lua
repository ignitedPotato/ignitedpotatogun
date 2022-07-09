if (not IsMounted("portal2")) then return end

AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Potato Crate"
ENT.Category = "ignitedPotato"
ENT.Information = "A crate. With potatoes."

ENT.Spawnable = true
ENT.AdminOnly = false

ENT.Potato = Model("models/npcs/potatos/world_model/potatos_wmodel.mdl")
ENT.Crate = Model("models/items/item_item_crate.mdl")

function ENT:ShootPotato()
    if (CLIENT) then return end

    local pos = self:GetPos()
    local aimvec = Angle(-90, 0, 0):Forward()

    local ent = ents.Create("prop_physics")
    if (not ent:IsValid()) then return end

    ent:SetModel(self.Potato)
    ent:SetPos(pos)

    ent:SetAngles(Angle())
    ent:Spawn()
    ent:Ignite(10, 100)

    local phys = ent:GetPhysicsObject()
    if (not IsValid(phys)) then
        ent:Remove()
        return
    end

    aimvec:Mul(10000)
    aimvec:Add(VectorRand(-1000, 1000))
    phys:ApplyForceCenter(aimvec)

    timer.Simple(15, function()
        if ent and ent:IsValid() then
            local effectdata = EffectData()
            effectdata:SetOrigin(ent:GetPos())
            effectdata:SetMagnitude(8)
            effectdata:SetScale(1)
            effectdata:SetRadius(16)
            util.Effect("balloon_pop", effectdata)
            ent:Remove()
        end
    end)
end

function ENT:Initialize()
    self:SetModel(self.Crate)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    if (SERVER) then self:PhysicsInit(SOLID_VPHYSICS) end
    self:PhysWake()
end

function ENT:SpawnFunction(ply, tr, ClassName)
    if (CLIENT) then return end
    if (not tr.Hit) then return end

    local SpawnPos = tr.HitPos + tr.HitNormal * 10
    local oobTr = util.TraceLine({
        start = tr.HitPos,
        endpos = SpawnPos,
        mask = MASK_SOLID_BRUSHONLY
    })
    if (oobTr.Hit) then
        SpawnPos = oobTr.HitPos + oobTr.HitNormal *
                       (tr.HitPos:Distance(oobTr.HitPos) / 2)
    end

    local ent = ents.Create(ClassName)
    if (not IsValid(ent)) then return false end

    ent:SetPos(SpawnPos)
    ent:SetHealth(40)

    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:OnTakeDamage(dmginfo)
    self:TakePhysicsDamage(dmginfo)
    self:SetHealth(self:Health() - dmginfo:GetDamage())
    if self:Health() <= 0 then
        self:PrecacheGibs()
        self:GibBreakClient(Angle(-90, 0, 0):Forward() * 100)
        self:Remove()

        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("ThumperDust", effectdata)
        util.Effect("Explosion", effectdata)

        for i = 1, 20 do self:ShootPotato() end
    end
end
