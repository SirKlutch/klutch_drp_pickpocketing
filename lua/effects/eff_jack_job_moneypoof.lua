--[[---------------------------------------------------------
   Init( data table )
---------------------------------------------------------]]
function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	self.Position.z = self.Position.z + 4
	self.TimeLeft = CurTime() + 1
	self.GAlpha = 254
	self.DerpAlpha = 254
	self.GSize = 200
	self.CloudHeight = 1 * 2.5
	self.Refract = 0
	self.Size = 48
	self.SplodeDist = 2000
	self.BlastSpeed = 6000
	self.lastThink = 0
	self.MinSplodeTime = CurTime() + self.CloudHeight / self.BlastSpeed
	self.MaxSplodeTime = CurTime() + 6
	self.GroundPos = self.Position - Vector(0, 0, self.CloudHeight)
	local Pos = self.Position
	self.smokeparticles = {}
	self.Emitter = ParticleEmitter(Pos)
	--local spawnpos = Pos
	local Scayul = 1
	self.Scayul = Scayul
	local Dir = data:GetNormal()
	--local AddVel = Vector(0, 0, 0)

	for k = 0, 7 * Scayul do
		local particle = self.Emitter:Add("mat_jack_job_dollar" .. math.random(1, 2), Pos)
		particle:SetVelocity(VectorRand() * math.Rand(1, 100) * Scayul + Vector(0, 0, 60) + Dir * 90 * math.Rand(.1, 1))
		particle:SetAirResistance(200)
		particle:SetGravity(VectorRand() * math.Rand(0, 100) + Vector(0, 0, -400))
		particle:SetDieTime(math.Rand(10, 20) * Scayul)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		local Size = 4
		particle:SetStartSize(Size)
		particle:SetEndSize(Size)
		particle:SetRoll(math.Rand(-2, 2))
		particle:SetRollDelta(math.Rand(-3, 3))
		local Col = math.random(185, 245)
		particle:SetColor(Col, Col, Col)
		particle:SetLighting(false) -- why is cluaparticle lighting so shitty? why garry
		particle:SetCollide(true)
	end

	self.Emitter:Finish()
end

--[[---------------------------------------------------------
   THINK
---------------------------------------------------------]]
function EFFECT:Think()
	return false
end

--[[---------------------------------------------------------
   Draw the effect
---------------------------------------------------------]]
function EFFECT:Render()
end