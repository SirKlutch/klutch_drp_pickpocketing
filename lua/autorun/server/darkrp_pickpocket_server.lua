DRPPickPocketConfig = DRPPickPocketConfig or {
	PickSpeed = 1, -- multiplier for how quickly pockets get picked
	MinCash = .05, -- minimum fraction of a player's wallet that you may get
	MaxCash = .10, -- maximum fraction of a player's wallet that you may get
	CopJobs = {"Civil Protection", "Civil Protection Chief", "Mayor"}, -- anyone with any of these job names will be immune to pickpocketing and will be chat-alerted if they witness a failed pickpocket attempt
	WitnessDist = 20, -- any cops within this many meters (and who have a clear LoS and who are looking in the right direction) will be alerted if they see a failed pickpocket attempt
	PickDist = 1, -- the pickpocket swep has a range of this many meters
	AlertTime = 10, -- on average how many seconds it takes for a picked person to realize he's been had
	PickCoolDown = 30, -- this many seconds must pass before can pick again
	WorkshopDownload == true -- setting to false will disable workshop download if you prefer to use FastDL.
}


resource.AddFile("sound/snd_jack_job_pickpocket1.wav")
resource.AddFile("sound/snd_jack_job_pickpocket2.wav")
resource.AddFile("sound/snd_jack_job_pickpocket3.wav")
resource.AddFile("sound/snd_jack_job_pickpocket4.wav")
resource.AddFile("sound/snd_jack_job_smallkching.wav")
resource.AddFile("sound/snd_jack_job_smallkching.wav")
resource.AddFile("materials/mat_jack_job_dollar1.vmt")
resource.AddFile("materials/mat_jack_job_dollar2.vmt")

if WorkshopDownload == true then
	resource.AddWorkshop("1285245130")	
end

function DRPPickPocket_WhomILookinAt(self)
	local ply = self.Owner
	local Tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * DRPPickPocketConfig.PickDist * 52, {ply})

	if (Tr.Hit) then
		return Tr.Entity, Tr.HitPos
	else
		return nil, nil
	end
end
--[[
	concommand.Add("test",function(ply,cmd,args)
		for i=0,10 do
			print(i,ply:GetPoseParameterName(i))
		end
	end)
	--]]
