AddCSLuaFile()

sound.Add({
    name = "rocketfly",
    channel = "CHAN_STATIC",
    volume = 0.65,
    level = 100,
    pitch = {110, 125},
    sound = {"weapons/rpg/rocket1.wav"}
})

ENT.Potato = Model("models/npcs/potatos/world_model/potatos_wmodel.mdl")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Spawnable = false
ENT.exploded = false

ENT.laser = nil
ENT.trail = nil

function ENT:ShootPotato(pos, ang)
    if (CLIENT) then return end

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

    ang:Mul(5000)
    ang:Add(VectorRand(-1000, 1000))
    phys:ApplyForceCenter(ang)

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
    self:SetModel("models/weapons/w_missile_launch.mdl")

    self:SetMoveType(MOVETYPE_FLY)

    self:SetSolid(SOLID_VPHYSICS)

    if (SERVER) then
        self:PhysicsInit(SOLID_VPHYSICS)

        self.trail = ents.Create("env_rockettrail")
        self.trail:SetPos(self:GetPos() - self:GetForward() * 10)
        self.trail:SetAngles(self:GetAngles())
        self.trail:SetParent(self)
        self.trail:Spawn()
    end
    self:PhysWake()

    if (CLIENT) then
        self:EmitSound("rocketfly")
        CreateParticleSystem(self, "Rocket_Smoke", PATTACH_ABSORIGIN_FOLLOW, 0,
                             -self:GetForward() * 15)
    end
end

function ENT:PhysicsCollide(data, phys)
    if (CLIENT) then return end

    if self.exploded then return end
    if (data.HitEntity:GetClass() == self:GetClass()) or
        (data.HitEntity == self:GetOwner()) then
        return
    else
        util.Decal("Scorch", data.HitPos + data.HitNormal,
                   data.HitPos - data.HitNormal)

        local ply = self:GetOwner()
        if not IsValid(ply) then ply = self end

        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("Explosion", effectdata)
        util.Effect("ThumperDust", effectdata)

        util.ScreenShake(self:GetPos(), 5, 5, 1, 1000)

        self:StopSound("rocketfly")
        if IsValid(self) then self:Remove() end

        self.exploded = true

        for i = 1, 5 do self:ShootPotato(self:GetPos(), -data.HitNormal) end
    end
end

function ENT:Think()
    if (CLIENT) then return end
    if self.exploded then return end

    if IsValid(self.laser) then
        local phys = self:GetPhysicsObject()

        if IsValid(phys) then
            local aimvec = self.laser:GetPos() - self:GetPos()
            phys:ApplyForceCenter(aimvec:GetNormal() * 1000)
            self:SetAngles(aimvec:Angle())
        end
    end

end
