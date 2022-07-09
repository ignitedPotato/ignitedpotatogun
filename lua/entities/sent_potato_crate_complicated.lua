AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Potato Crate Complicated"
ENT.Category = "ignitedPotato"
ENT.Information = "A crate. With potatoes."

ENT.Spawnable = true
ENT.AdminOnly = false

Potato = Model("models/npcs/potatos/world_model/potatos_wmodel.mdl")

c = 0

function ENT:ShootPotato(crate)
    if (CLIENT) then return end

    local pos = crate:GetPos()
    local aimvec = Angle(-90, 0, 0):Forward()

    local ent = ents.Create("prop_physics")
    if (not ent:IsValid()) then return end

    ent:SetModel(Potato)
    ent:SetPos(crate:GetPos())

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

    local ent = ents.Create("item_item_crate")
    if (not IsValid(ent)) then return false end

    ent:SetPos(SpawnPos)
    ent:SetName("potato_crate" .. c)

    ent:SetKeyValue("CrateAppearance", 0)
    ent:SetKeyValue("ItemClass", "item_dynamic_ressuply")
    ent:SetKeyValue("ItemCount", 5)
    ent:SetKeyValue("ExplodeRadius", 200)
    ent:SetKeyValue("ExplodeDamage", 20)

    if (table.IsEmpty(ents.FindByName("potato_crate_triggerhook"))) then
        local MapLua = ents.Create("lua_run")
        MapLua:SetName("potato_crate_triggerhook")
        MapLua:Spawn()
    end

    local curr_c = c
    hook.Add("OnBreakPotatoCrate" .. c, "potato_crate_break_hook" .. c,
             function()
        for i = 1, 20 do self:ShootPotato(ent) end
        hook.Remove("OnBreakPotatoCrate" .. curr_c,
                    "potato_crate_break_hook" .. curr_c)
        return true
    end)

    ent:Fire("AddOutput",
             "OnBreak potato_crate_triggerhook:RunPassedCode:hook.Run('OnBreakPotatoCrate" ..
                 c .. "'):0:-1")
    c = c + 1

    ent:Spawn()
    ent:Activate()

    return ent
end

