if SERVER then
	AddCSLuaFile()
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
	--SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_hmcd_hands")
else
	SWEP.PrintName = "Pickpocketing Hands"
	SWEP.Slot = 0
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.ViewModelFOV = 60
	SWEP.BounceWeaponIcon = false
	local LastProg = 0

	function SWEP:DrawHUD()
		local Pick, Prog, W, H, Length = self:GetPickin(), self:GetProgress(), ScrW(), ScrH(), ScrW() * .6
		Prog = Lerp(FrameTime() * 30, LastProg, Prog)

		if ((Pick) and (Prog <= 100)) then
			draw.RoundedBox(3, W * .2 - 3, H * .9 - 3, Length + 6, H * .05 + 6, Color(0, 0, 0, 50))
			draw.RoundedBox(3, W * .2, H * .9, Length * (Prog / 100), H * .05, Color(0, 50, 200, 100))
		end

		LastProg = Prog
	end
end

SWEP.SwayScale = 3
SWEP.BobScale = 3
SWEP.Author = "Sir Klutch"
SWEP.Contact = "To take money from other player's pockets!"
SWEP.Purpose = "Pickpocketing"
SWEP.Instructions = "Left click to pickpocket player.\nMake sure they are not facing you!"
SWEP.Spawnable = false
SWEP.AdminOnly = true
--SWEP.Category = "Small Town (Weapons)"
SWEP.HoldType = "slam"
SWEP.ViewModel = "models/weapons/v_knife_t.mdl"
SWEP.WorldModel = "models/props_junk/cardboard_box004a.mdl"
SWEP.ViewModelFlip = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Victim = nil
SWEP.NextPick = 0

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Pickin")
	self:NetworkVar("Float", 0, "Progress")
end

function SWEP:PreDrawViewModel(vm, wep, ply)
	--vm:SetMaterial("engine/occlusionproxy") -- Hide that view model with hacky material
end

function SWEP:Initialize()
	self:SetHoldType("normal")
	self:SetPickin(false)
	self:SetProgress(0)
end

function SWEP:Deploy()
	if (CLIENT) then
		local vm = self.Owner:GetViewModel()
		vm:ManipulateBonePosition(33, Vector(0, 0, -20))
		vm:ManipulateBoneScale(1, Vector(.01, .01, .01))
	end

	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime() + .1)

	return true
end

function SWEP:Holster()
	if (self:GetPickin()) then
		return false
	end

	self:OnRemove()

	return true
end

function SWEP:SecondaryAttack()
	--
end

function SWEP:OnRemove()
	if (IsValid(self.Owner) and CLIENT and self.Owner:IsPlayer()) then
		local vm = self.Owner:GetViewModel()

		if (IsValid(vm)) then
			vm:SetMaterial("")

			for i = 0, 59 do
				vm:ManipulateBoneScale(i, Vector(1, 1, 1))
				vm:ManipulateBonePosition(i, Vector(0, 0, 0))
			end
		end
	end
end

function SWEP:Think()
	if (CLIENT) then
		return
	end

	if (self:GetPickin()) then
		local Ent, Pos = DRPPickPocket_WhomILookinAt(self)

		if ((Ent) and (Ent == self.Victim) and not (self:CanBeSeenBy(Ent))) then
			self:SetProgress(self:GetProgress() + DRPPickPocketConfig.PickSpeed * .75)

			if (self:GetProgress() >= 100) then
				self:SucceedPickin()
			end
		else
			self:FailPickin()
		end
	end

	self:NextThink(CurTime() + .1)

	return true
end

function SWEP:CanBeSeenBy(dude)
	local Me, Them = self.Owner:GetShootPos(), dude:GetShootPos()

	if (Me:Distance(Them) > DRPPickPocketConfig.WitnessDist * 52) then
		return false
	end

	if (util.TraceLine({
		start = Me,
		endpos = Them,
		filter = {self.Owner, dude}
	}).Hit) then
		return false
	end

	local TrueVec = (Me - Them):GetNormalized()
	local ApproachAngle = -math.deg(math.asin(TrueVec:DotProduct(dude:GetAimVector())))

	return ApproachAngle <= 0
end

function SWEP:PrimaryAttack()
	if (CLIENT) then
		return
	end

	if (self:GetPickin()) then
		return
	end

	if (self.NextPick > CurTime()) then
		self.Owner:PrintMessage(HUD_PRINTTALK, "Can't pickpocket yet. Try again in " .. math.Round(self.NextPick - CurTime()) .. " seconds.")
		self:SetNextPrimaryFire(CurTime() + 1)
		self:SetNextSecondaryFire(CurTime() + 1)

		return
	end

	local Ent, Pos = DRPPickPocket_WhomILookinAt(self)

	if ((Ent) and (IsValid(Ent)) and (Ent:IsPlayer()) and not (self:IsCop(Ent))) then
		if (self:CanBeSeenBy(Ent)) then
			self.Owner:PrintMessage(HUD_PRINTTALK, "Your victim can see you!")
		else
			self:StartPickin(Ent)
			self.NextPick = CurTime() + DRPPickPocketConfig.PickCoolDown
		end
	end

	self:SetNextPrimaryFire(CurTime() + .35)
	self:SetNextSecondaryFire(CurTime() + .35)
end

function SWEP:StartPickin(victim)
	self:SetHoldType("slam")
	self:SetPickin(true)
	self.Victim = victim
end

function SWEP:FailPickin()
	local VicName = "someone"

	if ((IsValid(self.Victim)) and (self.Victim:IsPlayer())) then
		self.Victim:PrintMessage(HUD_PRINTTALK, "Someone just tried to pick your pocket.")
		VicName = self.Victim:Nick()
	end

	sound.Play("snd_jack_job_pickpocket" .. math.random(1, 4) .. ".wav", self.Owner:GetShootPos(), 60, math.random(60, 80))
	self.Owner:PrintMessage(HUD_PRINTTALK, "Pickpocket attempt failed!")

	for k, cop in pairs(player.GetAll()) do
		if ((cop ~= self.Owner) and (cop:Alive()) and (self:IsCop(cop))) then
			if (self:CanBeSeenBy(cop)) then
				cop:PrintMessage(HUD_PRINTTALK, "You just witnessed " .. self.Owner:Nick() .. " trying to pickpocket " .. VicName)
			end
		end
	end

	self:SetPickin(false)
	self:SetProgress(0)
	self:SetHoldType("normal")
	self.Victim = nil
end

function SWEP:DoGrabAnim()
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	if (LocalPlayer() == self.Owner) then
		surface.PlaySound("snd_jack_job_smallkching.wav")
		local Eff = EffectData()
		Eff:SetOrigin(self.Owner:GetShootPos() + self.Owner:GetAimVector() * 35 - self.Owner:GetUp() * 10)
		util.Effect("eff_jack_job_moneypoof", Eff, true, true)
	end
end

function SWEP:SucceedPickin()
	sound.Play("snd_jack_job_pickpocket" .. math.random(1, 4) .. ".wav", self.Owner:GetShootPos(), 35, math.random(60, 80))
	self.Owner:PrintMessage(HUD_PRINTTALK, "Pickpocket attempt successful!")
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:CallOnClient("DoGrabAnim", "") -- ugh

	timer.Simple(.3, function()
		if (IsValid(self)) then
			self:SetHoldType("normal")
		end
	end)

	local Dude = self.Victim

	timer.Simple(DRPPickPocketConfig.AlertTime * math.Rand(.5, 1.5), function()
		if (IsValid(Dude)) then
			Dude:PrintMessage(HUD_PRINTTALK, "It feels as though you're missing some money.")
		end
	end)

	self:TransferCash(self.Victim)
	self:SetPickin(false)
	self:SetProgress(0)
	self.Victim = nil
end

function SWEP:TransferCash(vic)
	local RandAmt = math.Rand(DRPPickPocketConfig.MinCash, DRPPickPocketConfig.MaxCash)
	local Existing, StealAmt = vic:getDarkRPVar("money"), math.Round(vic:getDarkRPVar("money") * RandAmt)

	if (Existing <= 0) then
		self.Owner:PrintMessage(HUD_PRINTTALK, "The victim didn't have any money.")

		return
	end

	if (StealAmt > Existing) then
		StealAmt = Existing
	end

	vic:addMoney(-StealAmt)
	self.Owner:addMoney(StealAmt)
	self.Owner:PrintMessage(HUD_PRINTTALK, "Took $" .. StealAmt)
end

function SWEP:IsCop(ply)
	return table.HasValue(DRPPickPocketConfig.CopJobs, ply:getDarkRPVar("job"))
end

function SWEP:Reload()
	--
end

function SWEP:DrawWorldModel()
	-- no, do nothing
end

if (CLIENT) then
	local LastDown, LastForward = 0, 0

	function SWEP:GetViewModelPosition(pos, ang)
		local Down, Forward = 1, 5

		if not (self:GetPickin()) then
			Down = 5
			Forward = -1
		end

		if (self:GetProgress() > 90) then
			Forward = 20
		end

		Down = Lerp(FrameTime() * 2, LastDown, Down)
		Forward = Lerp(FrameTime() * 2, LastForward, Forward)
		pos = pos - ang:Up() * Down + ang:Forward() * Forward
		LastDown = Down
		LastForward = Forward

		return pos, ang
	end
end
--[[
	0	v_weapon.knife_Parent
	1	v_weapon.Knife_Handle
	2	v_weapon
	3	v_weapon.Hands_parent
	4	v_weapon.Root34
	5	v_weapon.Left_Arm
	6	v_weapon.eff16
	7	v_weapon.Root16
	8	v_weapon.Left_Hand
	9	v_weapon.eff2
	10	v_weapon.Root17
	11	v_weapon.Left_Thumb01
	12	v_weapon.Left_Thumb_02
	13	v_weapon.Left_Thumb03
	14	v_weapon.Root18
	15	v_weapon.Left_Pinky01
	16	v_weapon.Left_Pinky02
	17	v_weapon.Left_Pinky03
	18	v_weapon.Root19
	19	v_weapon.Left_Ring01
	20	v_weapon.Left_Ring02
	21	v_weapon.Left_Ring03
	22	v_weapon.Root20
	23	v_weapon.Left_Middle01
	24	v_weapon.Left_Middle02
	25	v_weapon.Left_Middle03
	26	v_weapon.Root21
	27	v_weapon.Left_Index01
	28	v_weapon.Left_Index02
	29	v_weapon.Left_Index03
	30	v_weapon.Root99
	31	v_weapon.L_wrist_helper
	32	v_weapon.Root36
	33	v_weapon.Right_Arm
	34	v_weapon.eff18
	35	v_weapon.Root23
	36	v_weapon.Right_Hand
	37	v_weapon.eff9
	38	v_weapon.Root24
	39	v_weapon.Right_Thumb01
	40	v_weapon.Right_Thumb02
	41	v_weapon.Right_Thumb03
	42	v_weapon.Root25
	43	v_weapon.Right_Index01
	44	v_weapon.Right_Index02
	45	v_weapon.Right_Index03
	46	v_weapon.Root26
	47	v_weapon.Right_Middle01
	48	v_weapon.Right_Middle02
	49	v_weapon.Right_Middle03
	50	v_weapon.Root27
	51	v_weapon.Right_Ring01
	52	v_weapon.Right_Ring02
	53	v_weapon.Right_Ring03
	54	v_weapon.Root28
	55	v_weapon.Right_Pinky01
	56	v_weapon.Right_Pinky02
	57	v_weapon.Right_Pinky03
	58	v_weapon.Root98
	59	v_weapon.R_wrist_helper
]]