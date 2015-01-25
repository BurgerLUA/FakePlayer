if SERVER then
	function ControlNextBot(ply,ucmd)

		if ply:IsBot() then

			ucmd:ClearMovement()
			ucmd:ClearButtons()
			
			if ply.TargetEnt ~= nil then
			
				local speed = 460
			
				local sin = math.sin(CurTime())
				local cos = math.cos(CurTime())
				local tan = math.tan(CurTime())
				
				local distance = ply:GetPos():Distance(ply.TargetEnt:GetPos())
				local SWEP = ply:GetActiveWeapon()
				
				if not IsValid(SWEP) then return end

				if distance < 2000 then
				
					if SWEP:Clip1() == 0 then
					
						ucmd:SetButtons(IN_SPEED)
						ucmd:SetSideMove( (speed*tan*5) )
						ucmd:SetForwardMove(  (speed*cos*5) )
				
					else
				
						if SWEP.Primary.Cone > 0.04 then 
							ucmd:SetForwardMove( (speed*tan*0.5) + (speed*0.5) )
							ucmd:SetSideMove(ply:GetMaxSpeed()*sin)
						else
							ucmd:SetButtons(IN_DUCK)
						end
						
					end
						
					
				else
					ucmd:SetButtons(IN_SPEED)
					ucmd:SetForwardMove( speed )
				end
				
			else
			
				local speed = 300
			
				ucmd:SetForwardMove(speed)
				
				BotMoveToPos( ply, ply:GetPos() + Vector(math.Rand(-500,500),math.Rand(-500,500),math.Rand(-500,500)) )
				
			end
			
			
		end

	end

	hook.Add("StartCommand","NextBot Players StartCommand", ControlNextBot)
end





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








