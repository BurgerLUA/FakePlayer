if SERVER then
	function ControlNextBot(ply,ucmd)

		if ply:IsBot() then

			ucmd:ClearMovement()
			ucmd:ClearButtons()
			
			if not ply.NextNavTick then
				ply.NextNavTick = 0
			end

			if not ply.NavTarget then
				ply.NavTarget = nil
			end

			--[[
			
			if ply.NextNavTick <= CurTime() then
			
				if ply:Alive() then
				
					--if ply.NavTarget == nil then
						
						
						local NavTable = navmesh.Find( ply:GetPos(), 1000, 10, 10 )

						PrintTable(NavTable)
						
						ply.NavTarget = NavTable[math.random(1,#NavTable)]
						
						print(ply.Navtarget)
						
						
						if ply.NavTarget ~= nil then
							
							local TargetPos = ( ply.NavTarget:GetCorner(0) + ply.NavTarget:GetCorner(2) ) / 2
							
							
							
							

							print("ASS")
							--CalculateMovement(ply,TargetPos)
						end
					
						
						
					--end
				
				end

				ply.NextNavTick = CurTime() + 3
			
			end

			--]]
			
			if ply.TargetEnt ~= nil then
			
				local speed = 460
			
				local sin = math.sin(CurTime())
				local cos = math.cos(CurTime())
				local tan = math.tan(CurTime())
				
				local distance = ply:GetPos():Distance(ply.TargetEnt:GetPos())
				local SWEP = ply:GetActiveWeapon()
				
				if not IsValid(SWEP) then return end
				if not SWEP:IsScripted() then return end
				if SWEP.Primary.Cone == nil then return end
				
				
				if SWEP.Primary.Cone ~= 0 then
					
					if distance < 2000 then
					
						if SWEP:Clip1() == 0 then
						
							ucmd:SetButtons(IN_SPEED)
							ucmd:SetSideMove( (speed*tan*5) )
							ucmd:SetForwardMove(  (speed*cos*5) )
					
						else
					
							if SWEP.Primary.Cone > 0.04 then 
								ucmd:SetForwardMove( speed )
								ucmd:SetSideMove(ply:GetMaxSpeed()*tan)
							else
								ucmd:SetButtons(IN_DUCK)
							end
							
						end
							
						
					else
					
						ucmd:SetButtons(IN_SPEED)
						ucmd:SetForwardMove( speed )
						ucmd:SetSideMove(ply:GetMaxSpeed()*tan)
						
					end
					
				else
				
					ucmd:SetButtons(IN_DUCK)

				end
				
			else
			
				local speed = 300
				
				ucmd:SetForwardMove(speed)
					
				
			end
			
		end

	end

	hook.Add("StartCommand","NextBot Players StartCommand", ControlNextBot)
end



function IsBotSituationValid(bot,targetpos)
	
	if not bot then return false end
	if not targetpos then return false end
	if not bot:Alive() then return false end
	--if bot:GetPos():Distance(targetpos) <= 50 then  return false end
	
	return true

end


function CalculateMovement(bot,targetpos)

--[[
	local BotAng = Angle(0,bot:EyeAngles().y,0)
	local BotPos = bot:GetPos()
	
	local NewVector, NewAngle = WorldToLocal(targetpos,Angle(0,0,0),BotPos,BotAng)
	
	print(NewVector)
	--]]
	
	local PlayerPos = bot:GetPos()
	local TargetPos = targetpos
	
	print( ( PlayerPos - TargetPos ):GetNormalized() )

	print( ( PlayerPos - TargetPos ):Angle():Right() )
					
	
	
end






--[[
function BotMoveToPos( bot, pos )

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( 300 )
	path:SetGoalTolerance( 20 )
	path:Compute( bot, pos )

	--print("Computing...")
	
	if not path:IsValid() then return "failed" end

	print("VALID")
	
	repeat
	
		path:Update( self )

		--if ( options.draw ) then
			path:Draw()
			print("Drawing?")
		--end

		--coroutine.yield()

	until not path:IsValid()

	return "ok"

end
--]]







