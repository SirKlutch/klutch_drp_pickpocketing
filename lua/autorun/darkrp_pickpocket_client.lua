AddCSLuaFile()

if (CLIENT) then
	hook.Add("PrePlayerDraw", "DRPPickPocket", function(ply)
		local Set = false

		if (ply:Alive()) then
			local Wep = ply:GetActiveWeapon()

			if ((Wep) and (Wep:GetClass() == "weapon_pickpocket") and (Wep:GetPickin())) then
				Set = true
				ply.DRPPickPocketPoseSet = true
				ply:SetPoseParameter("aim_pitch", 81)
				ply:SetPoseParameter("head_pitch", -60)
				ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Finger0"), Angle(30, 30, 0))
				ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Finger02"), Angle(0, 30, 0))
				ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Hand"), Angle(30, -30, 0))
			end
		end

		if ((not (Set)) and (ply.DRPPickPocketPoseSet)) then
			ply.DRPPickPocketPoseSet = false
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Finger0"), Angle(0, 0, 0))
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Finger02"), Angle(0, 0, 0))
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Hand"), Angle(0, 0, 0))
		end
	end)
end
--[[
	0	ValveBiped.Bip01_Pelvis
	1	ValveBiped.Bip01_Spine
	2	ValveBiped.Bip01_Spine1
	3	ValveBiped.Bip01_Spine2
	4	ValveBiped.Bip01_Spine4
	5	ValveBiped.Bip01_Neck1
	6	ValveBiped.Bip01_Head1
	7	ValveBiped.forward
	8	ValveBiped.Bip01_R_Clavicle
	9	ValveBiped.Bip01_R_UpperArm
	10	ValveBiped.Bip01_R_Forearm
	11	ValveBiped.Bip01_R_Hand
	12	ValveBiped.Anim_Attachment_RH
	13	ValveBiped.Bip01_L_Clavicle
	14	ValveBiped.Bip01_L_UpperArm
	15	ValveBiped.Bip01_L_Forearm
	16	ValveBiped.Bip01_L_Hand
	17	ValveBiped.Anim_Attachment_LH
	18	ValveBiped.Bip01_R_Thigh
	19	ValveBiped.Bip01_R_Calf
	20	ValveBiped.Bip01_R_Foot
	21	ValveBiped.Bip01_R_Toe0
	22	ValveBiped.Bip01_L_Thigh
	23	ValveBiped.Bip01_L_Calf
	24	ValveBiped.Bip01_L_Foot
	25	ValveBiped.Bip01_L_Toe0
	26	__INVALIDBONE__
	27	__INVALIDBONE__
	28	__INVALIDBONE__
	29	__INVALIDBONE__
	30	__INVALIDBONE__
	31	__INVALIDBONE__
	32	ValveBiped.Bip01_L_Finger2
	33	ValveBiped.Bip01_L_Finger21
	34	ValveBiped.Bip01_L_Finger22
	35	ValveBiped.Bip01_L_Finger1
	36	ValveBiped.Bip01_L_Finger11
	37	ValveBiped.Bip01_L_Finger12
	38	ValveBiped.Bip01_L_Finger0
	39	ValveBiped.Bip01_L_Finger01
	40	ValveBiped.Bip01_L_Finger02
	41	__INVALIDBONE__
	42	__INVALIDBONE__
	43	__INVALIDBONE__
	44	__INVALIDBONE__
	45	__INVALIDBONE__
	46	__INVALIDBONE__
	47	ValveBiped.Bip01_R_Finger2
	48	ValveBiped.Bip01_R_Finger21
	49	ValveBiped.Bip01_R_Finger22
	50	ValveBiped.Bip01_R_Finger1
	51	ValveBiped.Bip01_R_Finger11
	52	ValveBiped.Bip01_R_Finger12
	53	ValveBiped.Bip01_R_Finger0
	54	ValveBiped.Bip01_R_Finger01
	55	ValveBiped.Bip01_R_Finger02
	56	ValveBiped.Bip01_L_Elbow
	57	ValveBiped.Bip01_L_Ulna
	58	ValveBiped.Bip01_R_Ulna
	59	ValveBiped.Bip01_R_Shoulder
	60	ValveBiped.Bip01_L_Shoulder
	61	ValveBiped.Bip01_R_Trapezius
	62	ValveBiped.Bip01_R_Wrist
	63	ValveBiped.Bip01_R_Bicep
	64	ValveBiped.Bip01_L_Bicep
	65	ValveBiped.Bip01_L_Trapezius
	66	ValveBiped.Bip01_L_Wrist
	67	ValveBiped.Bip01_R_Elbow
]]
