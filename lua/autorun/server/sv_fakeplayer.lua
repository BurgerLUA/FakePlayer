local CSSWeaponsTable = {}

function GenerateWeapons()

	for k,v in pairs(weapons.GetList()) do

		if v.Base == "weapon_cs_base" then
		
			if v.WeaponType	~= "Free" then
				table.Add(CSSWeaponsTable,{v.ClassName})
				
				--print("Adding Weapon " .. v.ClassName)
			end
				
		end
			
	end

end

GenerateWeapons() -- for script refreshing

function CreateFakePlayer(ply, cmd, args, argStr)
	
	GenerateWeapons()

	if #player.GetAll() == game.MaxPlayers() then 
		
		print("Failed to create Nextbot: No free slots available")
	
	return end
	
	if argStr ~= "" then
	
		local NameTaken = false
	
		for k,v in pairs(player.GetAll()) do
			
			if v:Nick() == angStr then
				NameTaken = true
			end
		
		end
		
		if NameTaken then
		
			print("Failed to create Nextbot: Name already taken.")
		
		else
		
			player.CreateNextBot( argStr )
			
		end
	
	else
	
		local BotCount = 1
	
		for k,v in pairs(player.GetAll()) do
			if v:IsBot() then
				BotCount = BotCount + 1
			end
		end
	
		local Name = "NextBot" .. BotCount
		
		player.CreateNextBot( Name )

	end
	

end

concommand.Add("nextbot",CreateFakePlayer)


function AssignPlayerModel(ply)

	local PlayerList = table.GetKeys( player_manager.AllValidModels() )
	
	ply.PlayerModel = player_manager.TranslatePlayerModel(PlayerList[math.random(1,#PlayerList)])
	ply.PlayerColor = (VectorRand() + Vector(1,1,1)) / 2
	
	
end

hook.Add("PlayerInitialSpawn","NextBot Player Playermodels",AssignPlayerModel)



function BotsWithGuns(ply)
	
	if ply:IsBot() then
	
		timer.Simple(0, function()

			ply:StripWeapons()
			
			local Choice = CSSWeaponsTable[ math.random(1,#CSSWeaponsTable) ]
			
			if Choice then
				ply:Give(Choice)
			end
			
			
			ply:SetModel(ply.PlayerModel)
			ply:SetPlayerColor(ply.PlayerColor)

		end)
		
	end
	
end

hook.Add("PlayerSpawn", "Bots with Guns", BotsWithGuns)

function SpawnLater(ply)

	if ply:IsBot() then 
		timer.Create(ply:Nick() .. "_spawn", 3, 1, function()
		
			if Class then
			
				if ply.ClassNumberTo == 1 then
					local choice = math.random(2,#Class)
					--print("UMMMMMMMMMM")
					BotClass( ply, choice )
				elseif math.random(1,100) >= 90 then
					local choice = math.random(2,#Class)
					BotClass( ply, choice )
				else
					ply:Spawn()
				end
				
				
			else
				ply:Spawn()
			end
			
		end)
	end
	

end

hook.Add("PlayerDeath","Respawn Bots",SpawnLater)

function BotCheckDamage(victim,attacker)
	
	if victim:IsBot() then
	
		if victim.TargetEnt ~= nil then
			if victim:GetPos():Distance(attacker:GetPos()) < victim:GetPos():Distance(victim.TargetEnt:GetPos()) then
				BotLookAtPos(victim,attacker:GetPos() + attacker:OBBCenter() )
			end
		else
			BotLookAtPos(victim,attacker:GetPos() + attacker:OBBCenter() )
			victim.TargetEnt = attacker
		end
		
	end
	
	return true

end

hook.Add("PlayerShouldTakeDamage","NextBot Players ScalePlayerDamage",BotCheckDamage)

local NextTick = 0

function BotThink()

	BotRandomMessage()
	
	for k,v in pairs(player.GetBots()) do

		BotSearchAndDestroy(v)	
		
	end
	
end

hook.Add("Think","NextBot Players Think",BotThink)

function BotSearchAndDestroy(ply)

	if not ply:Alive() then return end
	if not IsValid(ply:GetActiveWeapon()) then return end
	if not ply:GetActiveWeapon():IsScripted() then return end

	if not ply.HasVariables then
		ply.TargetEnt = nil
		ply.SearchDelay = 0
		ply.ShootDelay = 0
		ply.HasVariables = true
		ply.ChangeTargetDelay = 0
		ply.ChangeCount = 0
	end
		
	if ply.TargetEnt == nil then

		if ply.SearchDelay < CurTime() then
		
			local data = {}
			
			data.start = ply:GetPos() + Vector(0,0,5)
			data.endpos = ply:GetPos() + Angle(0,ply:GetAngles().y,0):Forward()*100 + Vector(0,0,5)
			data.filter = ply

			local Trace = util.TraceLine(data)
		
			local Bump = Trace.StartPos:Distance(ply:GetEyeTrace().HitPos)


		
			if Bump < 100 and Trace.HitNormal.z < 1 then
				ply:SetEyeAngles(Angle(0,ply:EyeAngles().y,0) + Angle(0,180 + math.Rand(-45,45),0) )
			end
		
			ply.TargetEnt = BotFindTarget(ply)
			ply.SearchDelay = CurTime() + 0.25
			
		else
		
			ply:SetEyeAngles( Angle(0,ply:EyeAngles().y,0) + Angle(0,math.Rand(-18,18),0 ) )
		
		end
		
		
		
	else
	
		if not IsValid(ply.TargetEnt) then
			ply.TargetEnt = nil
			return 
		end
	
		--local pos = ply.TargetEnt:GetPos() + ply.TargetEnt:OBBCenter()
		local pos = ply.TargetEnt:GetShootPos()
		
		
		BotLookAtPos(ply,pos)
		
		
		if ply.ChangeTargetDelay < CurTime() then
		
			if ply:GetEyeTrace().Entity ~= ply.TargetEnt then
				ply.ChangeCount = ply.ChangeCount + 1
			else
				ply.ChangeCount = 0
			end
			
			if ply.ChangeCount >= 3 then 
				ply.TargetEnt = nil
				ply.ChangeCount = 0
			end
			
			
			
			ply.ChangeTargetDelay = CurTime() + 1
			
		end
		
		

		
		if ply:GetActiveWeapon():Ammo1() <= ply:GetActiveWeapon():Clip1() then
			ply:SetAmmo(ply:GetActiveWeapon():Clip1(), ply:GetActiveWeapon().Primary.Ammo)
		end
		
		if IsValid(ply.TargetEnt) then
			if ply.TargetEnt:Health() > 0 then
				
				ply:LagCompensation( true )
				local eyetrace = ply:GetEyeTrace()
				ply:LagCompensation( false )
				
				if eyetrace.Entity == ply.TargetEnt then
				
					if ply.ShootDelay <= CurTime() then
					
						if ply:GetActiveWeapon():Clip1() > 0 then
						
							if ply:GetActiveWeapon().CoolDown < 1 then
							
								ply:GetActiveWeapon():PrimaryAttack()
								
								if ply:GetActiveWeapon().Primary.Automatic == true then
									ply.ShootDelay = CurTime() + ply:GetActiveWeapon().Primary.Delay
								else
									ply.ShootDelay = CurTime() + math.max(ply:GetActiveWeapon().Primary.Delay,(1/math.Rand(6,7)))
								end
								
							end

						else
						
							ply:GetActiveWeapon():Reload()
							
						end
						
					end

				elseif eyetrace.Entity:IsPlayer() and eyetrace.Entity ~= ply.TargetEnt then
				
					ply.TargetEnt = eyetrace.Entity
					
				end
				
			else

				ply.TargetEnt = nil
				
			end
			
		end

	end

end

function BotFindTarget(bot)

		return CheckLOS(bot,90,10000)
		
	--[[
	local EnemyList = {}

	local ConeEnts = ents.FindInCone(bot:GetShootPos(),bot:EyeAngles():Forward(),20000, 180)

	if #ConeEnts == 0 then return nil end
	
	for k,v in pairs(ConeEnts) do
		
		if v:IsPlayer() and v ~= bot then	
			if v:Alive() == true then

				local data = {}
				data.start = bot:EyePos()
				--data.endpos = v:GetPos() + Vector(0,0,v:OBBCenter().z*1.5*math.min( 0.75,math.sin(CurTime()) ))
				data.endpos = v:EyePos()
				data.filter = bot
				--data.mask = MASK_BLOCKLOS_AND_NPCS
				
				bot:LagCompensation( true )
				local trace = util.TraceLine(data)
				bot:LagCompensation( false )
				
				if IsValid(trace.Entity) then
				
					if trace.Entity == v then 
						print("BOT: You're going to die " .. v:Nick() .. "!")
						EnemyList[v] = v:GetPos():Distance(bot:EyePos())
					end
					
				end
			end
		end

	end
	
	EnemyList = table.SortByKey(EnemyList,true)
	
	return EnemyList[1]
	--]]
	
end

function CheckLOS(bot,fov,distance)

	local EnemyList = {}

	for k,v in pairs(player.GetAll()) do
	
		if v ~= bot then
	
			if v:GetPos():Distance(bot:GetPos()) < distance then
			
				-- https://www.youtube.com/watch?v=4O_px0hW7Ds
				
				local BotVector = bot:GetAimVector() --bot:EyeAngles():Forward()
				local BotPos = bot:EyePos()
				local TargetPos = v:GetPos() + v:OBBCenter()
				local DotProduct = BotVector:DotProduct( (TargetPos - BotPos):GetNormalized() )

				
				local Degree = math.deg(math.acos(DotProduct))
				

				
				if Degree < fov/2 then
				
					if v:Alive() then
				
						local data = {}
						data.start = bot:EyePos()
						data.endpos = v:EyePos() + bot:GetAimVector()*10
						data.filter = bot
						--data.mask = MASK_BLOCKLOS_AND_NPCS
						
						bot:LagCompensation( true )
						local trace = util.TraceLine(data)
						bot:LagCompensation( false )
						
						if IsValid(trace.Entity) then
							if trace.Entity == v then 
								EnemyList[v] = v:GetPos():Distance(bot:EyePos())
							end
						end
						
					end
				
				end
		
			end
			
		end

	end

	EnemyList = table.SortByKey(EnemyList,true)
	
	return EnemyList[1]


end




function BotLookAtPos(bot,pos)

	local Main = (pos - bot:GetShootPos() ):Angle()
			
	local P = math.NormalizeAngle(Main.p)
	local Y = math.NormalizeAngle(Main.y)
	local R = 0
		
	bot:SetEyeAngles(Angle(P,Y,R))
	
end

local MessageDelay = 60
local NextMessageTime = 0 + MessageDelay

local Messages = {
				"yeah k dude",
				"do you like lockers",
				"do you like oblivion mods",
				"would you guys like to read my toy story fanfiction",
				"I swear to god if I get another image like that I am going to fucking unfriend you",
				"i have class",
				"#player your videos are incredibly unfunny please stop making them",
				"MY ASSHOLE MY ASSHOLE",
				"i don't want to play anymore",
				"all hail the flaming donut of greatness",
				"FUCKING SKY NINJAS",
				"*SNIFFFFFFFFFFFFFFFFFFF*",
				"PROLAPSEDDDDDDD ANUSSSSSSSSSSS",
				"my favorite band is dubstep",
				"FUCK MEXICO",
				"you're into scat, #player",
				"Oh my god, #player, you're such a little cunt.",
				"yiff me baby, yiff me real hard",
				"You acted like a straight-up bitch, #player, when I whipped out my fat cock and slapped it on your fuckin forehead.",
				"lets play dota",
				"hey this game is just like dota",
				"my fursona is clifford the big red dog eternally taking a selfie",
				"ALRIGHT TUMBLRS BEEN DOWN FOR 2 HOURS AND IM ON MY PERIOD",
				"ey b0ss",
				"gibe de pusi b0ss",
				"why am i not growing a pussy crop right now",
				"it's just taco bell, what could possible go wrong?",
				"I saw a cat get murdered in the street and I got an erection.",
				"NYEEEEEEEEEEES",
				}



function BotGreetings(ply)

	local Table1 = player.GetBots()
	
	table.RemoveByValue(Table1,ply)
	
	if #Table1 > 0 then
	
		local Bot = Table1[math.random(1,#Table1)]
		local Text = "WELCOME TO THE RICE FIELDS MOTHERFUCKER"
		
		BotSendMessage(Bot,Text)
		
	end

end

hook.Add("PlayerInitialSpawn","Bot Greetings",BotGreetings)


function BotRandomMessage()

	if NextMessageTime < CurTime() then
	
		local Table1 = player.GetBots()
		
		
	
		if #Table1 > 0 then

			local Bot = Table1[math.random(1,#Table1)]
			
			local Text = Messages[math.random(1,#Messages)]
			
			

			BotSendMessage(Bot,Text)

		end
		
		NextMessageTime = CurTime() + MessageDelay
		
	end
	
	

end


function BotSendMessage(Bot,Text)

	local Table2 = player.GetHumans()
	local Human = Table2[math.random(1,#Table2)]
	
	Text = string.Replace(Text,"#player",Human:Nick())

	net.Start("BotWittyMessage")
		net.WriteEntity(Bot)
		net.WriteString(Text)
	net.Broadcast()
	
end

util.AddNetworkString( "BotWittyMessage" )










