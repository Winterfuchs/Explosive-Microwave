AddCSLuaFile()

ENT.Type = "anim"

AccessorFunc(ENT, "thrower", "Thrower")

function ENT:Initialize()
	self:SetHealth(200)
	self:SetModel("models/props/cs_office/microwave.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
   
   
	local phys = self:GetPhysicsObject()
      if IsValid(phys) then
         phys:SetMass(150)
      end
	  
	if SERVER then
      self.Entity:NextThink(CurTime() + 2.5)
	end
end


function ENT:Think()
	self:Explode()

	if not CLIENT then return end

	local client = LocalPlayer()

	-- this has to be here to be visible without the entity beeing rendered
	if TTT2 then
		-- do nothing until data is synced
		if not self.userdata then return end

		if client:GetTeam() == self.userdata.team then
			self:LightUp(self.userdata.color)
		end
	else
		local thrower = self:GetNWEntity("micowave_owner")

		if not IsValid(thrower) then return end

		if (client:IsTraitor() && thrower:IsTraitor()) then
			self:LightUp(Color(255,0,0,255))
		end
	end
end


function ENT:Draw()
	self:DrawModel()

	local client = LocalPlayer()

	if TTT2 then
		-- do nothing until data is synced
		if not self.userdata then return end

		if client:GetTeam() == self.userdata.team then
			self:DrawWarning(self.userdata.color)
			self:SetColor(self.userdata.color)
		else
			self:SetColor(Color(255,255,255,255))
		end
	else
		local thrower = self:GetNWEntity("micowave_owner")

		if not IsValid(thrower) then return end

		if (client:IsTraitor() && thrower:IsTraitor()) then
			self:DrawWarning(Color(255,0,0,255))
			self:SetColor(Color(255,0,0,255))
		end
	end
end


function ENT:DrawWarning(col)
	local Pos = self:GetPos()
	local Ang = self:GetAngles()
			
	Ang:RotateAroundAxis(Ang:Up(), CurTime()*80)
	Ang:RotateAroundAxis(Ang:Forward(), 90)

	dpos = self:GetPos()

	cam.Start3D2D(Pos + Vector(0,0, -60), Ang, 0.5)
	draw.SimpleTextOutlined("EXPLOSIVE MICROWAVE!", "Default", 0, -200, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 250))
	cam.End3D2D()

	Ang:RotateAroundAxis(Ang:Right(), 180)
	cam.Start3D2D(Pos + Vector(0,0, -60), Ang, 0.5)
	draw.SimpleTextOutlined("EXPLOSIVE MICROWAVE!", "Default", 0, -200, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 250))
	cam.End3D2D()
end


function ENT:LightUp(color)
	if CLIENT then
		if IsValid(self) then
			dlight = DynamicLight(self:EntIndex())

			dlight.r = color.r
			dlight.g = color.g
			dlight.b = color.b

			spos = self:GetPos()

			dlight.brightness = 5
			dlight.Decay = 1000
			dlight.Size = 256
			dlight.DieTime = CurTime() + 1
			dlight.Pos = spos + Vector(0,0,10)
		end
	end
end


function ENT:Explode()
	if SERVER then
		local expos = self:GetPos()
		local sphere = ents.FindInSphere(expos, 100)
		local thrower = self:GetThrower()
		local throwerRole = self:GetThrower():GetRole()

		for k, v in pairs(sphere) do
			if not v or not v:IsPlayer() then return end
			if v:IsSpec() then return end

			if TTT2 then
				if v:GetTeam() == self.userdata.team then return end
			else
				if v:IsTraitor() and thrower:IsTraitor() and v:GetRole() == throwerRole then return end
			end
			
			local tracedata = {};
			tracedata.start = v:GetShootPos();
			tracedata.endpos = self:GetPos() + Vector(0, 0, 20);
			tracedata.filter = v;
			local tr = util.TraceLine(tracedata);
			
			if tr.HitPos == tracedata.endpos then
				util.BlastDamage(self, self:GetThrower(), expos, 150, 200)

				effect = EffectData()
				effect:SetOrigin(expos)
				effect:SetStart(expos)

				util.Effect("Explosion", effect, true, true)
				self:Remove()
			end
		end
	end
end


function ENT:OnTakeDamage(damage)
	dmg = self:Health() - damage:GetDamage()
	self:SetHealth(dmg)

		if (self:Health() <= 0) then

		local pos = self:GetPos()

		local effect = EffectData()

		effect:SetStart(pos)
		effect:SetOrigin(pos)
		util.Effect("cball_explode", effect, true, true) 

		self:Remove()
	end
end