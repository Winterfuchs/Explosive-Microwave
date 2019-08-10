if SERVER then
	AddCSLuaFile()
	resource.AddFile ("materials/vgui/ttt/icon_micriwave.vmt")
	resource.AddFile ("materials/vgui/ttt/icon_microwave.vtf")
	resource.AddWorkshop( "514778608" )
end


SWEP.HoldType = "normal"


if CLIENT then
   SWEP.PrintName = "Explosive Microwave"
   SWEP.Slot = 6

   SWEP.ViewModelFOV = 10

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "A Microwave which explode if Innocents are\nclose to it."
   };

   SWEP.Icon = "vgui/ttt/icon_microwave"
end

SWEP.Base = "weapon_tttbase"

SWEP.ViewModel          = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel         = "models/props/cs_office/microwave.mdl"

SWEP.DrawCrosshair      = false
SWEP.Primary.ClipSize       = 1
SWEP.Primary.DefaultClip    = 1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo       = "none"
SWEP.Primary.Delay = 1.0

SWEP.Secondary.ClipSize     = 1
SWEP.Secondary.DefaultClip  = 1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 1.0

-- This is special equipment


SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR} -- only detectives can buy
SWEP.LimitedStock = true -- only buyable once
SWEP.WeaponID = AMMO_EXPMICROWAVE

SWEP.AllowDrop = true

SWEP.NoSights = true

function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() then
	return end
	
	 self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	 
	 self:CreateMicrowave()
	 
end

function SWEP:DrawWorldModel()

return false
end

function SWEP:CreateMicrowave()
if SERVER then
		
		local ply = self.Owner
		local micro = ents.Create("ttt_expmicrowave")
		if IsValid(micro) and IsValid(ply) then
			
			local vsrc = ply:GetShootPos()
			local vang = ply:GetAimVector()
			local vvel = ply:GetVelocity()
			local vthrow = vvel + vang * 100
			micro:SetPos(vsrc + vang * 10)
			micro:Spawn()
			micro:PhysWake()
			micro:SetThrower(ply)
			micro:SetNWEntity("owner", ply)
			
			local phys = micro:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(vthrow)
			end 
			self:Remove()
		end
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:OnDrop()
self:Remove()
end