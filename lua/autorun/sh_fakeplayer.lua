if SERVER then
	function ControlNextBot(ply,ucmd)

		if ply:IsBot() then

			ucmd:ClearMovement()
			ucmd:ClearButtons()
			
			if ply.TargetEnt ~= nil then
			
				if not IsValid(ply.TargetEnt) then return
					ply.TargetEnt = nil
				end
			
				local speed = 200
			
				local sin = math.sin(CurTime())
				local cos = math.cos(CurTime())
				local tan = math.tan(CurTime())
				
				local distance = ply:GetPos():Distance(ply.TargetEnt:GetPos())

				if distance < 1000 then
					ucmd:SetForwardMove( (speed*tan*0.5) + (speed*0.5) )
					ucmd:SetSideMove(ply:GetMaxSpeed()*sin)
				else
					ucmd:SetForwardMove( speed*5 )
				end
				
			else
			
				local speed = 300
			
				ucmd:SetForwardMove(speed)
				
			end
			
			
		end

	end

	hook.Add("StartCommand","NextBot Players StartCommand", ControlNextBot)
end