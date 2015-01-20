


net.Receive("BotWittyMessage", function (len)

	local Bot = net.ReadEntity()
	local Message = net.ReadString()
	
	BotSendMessage(Bot,Message)

end)


function BotSendMessage(bot,message)

	local NameColor = team.GetColor(bot:Team())
	local TextColor = Color(255,255,255,255)

	chat.AddText(NameColor,bot:Nick() .. ": ",TextColor,message)
	
end

