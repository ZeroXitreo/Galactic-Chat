local component = {}
component.dependencies = {"theme"}
component.title = "Chat"
component.firstInsert = true
component.chatQuotes = {
	"Yes m'lord?",
	"Work work",
	"Need more lumber",
	"That building isn't ready yet",
	"Yo ho",
	"Santa isn't real",
	"DoritosLocosTaco",
	"That spell isn't ready yet",
	"I need to target something first",
	"Well played",
	"Type here...",
	"Insert your text...",
	"Benedict Cumberbatch",
	"Brendadirk Cramplescrunch",
	"Scamble scamble scamble...",
	"Are you even reading these?",
	"I love you",
	"You are a pirate!",
	"Stonks",
	"Modern solutions require modern problems",
	"[object Object]",
	"NULL",
	"nil",
}

function component:Constructor()
	/*function galactic.registry.Player:IsTyping()
	end*/

	if LocalPlayer():IsValid() then
		self:Initialize()
	end

	function chat.GetChatBoxSize()
		return self.container:GetSize()
	end
	
	function chat.GetChatBoxPos()
		//PrintTable(baseclass.Get(self))
		return self.container:GetPos()
	end

	function chat.AddText(...)
		local args = {...}
		local textArgs = {}
		table.insert(textArgs, galactic.theme.colors.text)
		
		if not self.firstInsert then
			self:AppendStringToChat("\n")
		else
			self.firstInsert = false
		end

		for _, obj in pairs( args ) do
			if IsColor(obj) then // Color
				self:AppendColorToChat(obj)
				table.insert(textArgs, obj)
			elseif isstring(obj) then // string
				self:AppendStringToChat(obj)
				table.insert(textArgs, obj)
			elseif obj:IsPlayer() then // Player
				self:AppendColorToChat(GAMEMODE:GetTeamColor(obj))
				self:AppendStringToChat(obj:Nick())
				table.insert(textArgs, GAMEMODE:GetTeamColor(obj))
				table.insert(textArgs, obj:Nick())
			else // any
				self:AppendStringToChat(tostring(obj))
				table.insert(textArgs, tostring(obj))
			end
		end

		table.insert(textArgs, "\n")
		MsgC(unpack(textArgs))
	end
end

function component:Initialize()
	if galactic.chatPanel then galactic.chatPanel:Remove() end

	self.container = vgui.Create("EditablePanel")
	galactic.chatPanel = self.container

	self.container.fade = self.container:Add("RichText")
	self.container.fade:Dock(FILL)
	self.container.fade:DockMargin(galactic.theme.rem / 2, galactic.theme.rem / 2, galactic.theme.rem / 2, galactic.theme.rem / 2)
	self.container.fade:DockPadding(0, 10, 0, 0)
	self.container.fade:SetAllowNonAsciiCharacters(true)
	self.container.fade:SetVerticalScrollbarEnabled(false)
	self.container.fade.Paint = function(pnl, w, h)
		pnl:SetFontInternal("GalacticDefault")
	end

	self.container.chat = self.container:Add("Panel")
	self.container.chat:Dock(FILL)
	self.container.chat:SetAlpha(0)
	self.container.chat.Paint = function(pnl, w, h)
		draw.RoundedBoxEx(galactic.theme.round, 0, 0, w, h, galactic.theme.colors.blockFaint, true, true, false, false)
	end

	self.container.chat.context = self.container.chat:Add("RichText")
	self.container.chat.context:Dock(FILL)
	self.container.chat.context:DockMargin(galactic.theme.rem / 2, galactic.theme.rem / 2, galactic.theme.rem / 2, galactic.theme.rem / 2)
	self.container.chat.context:SetAllowNonAsciiCharacters(true)
	self.container.chat.context.Paint = function(pnl, w, h)
		pnl:SetFontInternal("GalacticDefault")
	end

	self.container.field = self.container:Add("Panel")
	self.container.field:Dock(BOTTOM)
	self.container.field:DockPadding(galactic.theme.rem / 2, galactic.theme.rem / 2, galactic.theme.rem / 2, galactic.theme.rem / 2)
	self.container.field:SetHeight(galactic.theme.rem * 3)
	self.container.field:SetAlpha(0)
	self.container.field.Paint = function(pnl, w, h)
		draw.RoundedBoxEx(galactic.theme.round, 0, 0, w, h, galactic.theme.colors.block, false, false, true, true)
	end

	self.container.field.entry = self.container.field:Add("DTextEntry")
	self.container.field.entry:Dock(FILL)
	self.container.field.entry:SetAllowNonAsciiCharacters(true)
	self.container.field.entry:SetFont("GalacticDefault")
	self.container.field.entry:SetPlaceholderText("")
	self.container.field.entry.Paint = function(pnl, w, h)
		pnl:DrawTextEntryText(galactic.theme.colors.text, galactic.theme.colors.textFaint, galactic.theme.colors.text)
		if pnl:GetValue() == "" then
			if pnl:GetPlaceholderText() == "" then
				pnl:SetPlaceholderText(self.chatQuotes[math.random(#self.chatQuotes)])
			end
			draw.SimpleText(pnl:GetPlaceholderText(), pnl:GetFont(), 3, galactic.theme.rem, galactic.theme.colors.textFaint, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
		else
			pnl:SetPlaceholderText("")
		end
	end
	self.container.field.entry.OnTextChanged = function(pnl)
		hook.Run("ChatTextChanged", pnl:GetText() or "")
	end
	self.container.field.entry.OnKeyCodeTyped = function(pnl, code)
		if code == KEY_ESCAPE then
			self:CloseChatbox()
		elseif code == KEY_ENTER then
			if string.Trim(pnl:GetText()) != "" then
				LocalPlayer():ConCommand(string.format("say %s", pnl:GetText()))
			end
			self:CloseChatbox()
		elseif code == KEY_TAB then
			pnl:SetText(hook.Run("OnChatTab", pnl:GetText()))
			pnl:SetCaretPos(string.len(pnl:GetText()))
			return true
		end
	end
end

function component:AppendStringToChat(str)
	self.container.chat.context:AppendText(str)
	self.container.fade:AppendText(str)
	self.container.fade:InsertFade(10, 2.5)
end

function component:AppendColorToChat(col)
	self.container.chat.context:InsertColorChange(col.r, col.g, col.b, col.a)
	self.container.fade:InsertColorChange(col.r, col.g, col.b, col.a)
end

function component:ChatText(index, name, text, type)
	chat.AddText(galactic.theme.colors.green, text)
end

function component:OnPlayerChat(ply, text, teamChat, isDead)
	local textArgs = {}

	if isDead then
		table.insert(textArgs, galactic.theme.colors.red)
		table.insert(textArgs, "*DEAD* ")
	end

	if teamChat then
		table.insert(textArgs, galactic.theme.colors.green)
		table.insert(textArgs, "(TEAM) ")
	end

	if ply:IsValid() then
		table.insert(textArgs, ply)
	else
		table.insert(textArgs, galactic.theme.colors.blue)
		table.insert(textArgs, "Console")
	end
	
	table.insert(textArgs, galactic.theme.colors.text)
	table.insert(textArgs, string.format(": %s", text))

	chat.AddText(unpack(textArgs))

	return true
end

function component:StartChat(isTeamChat)
	self.container:MakePopup()
	self.container.field.entry:RequestFocus()
	self.container.chat:AlphaTo(255, .2)
	self.container.field:AlphaTo(255, .2)
end

function component:CloseChatbox()
		self.container:SetMouseInputEnabled(false)
		self.container:SetKeyboardInputEnabled(false)
		// Clear the text entry
		gamemode.Call("ChatTextChanged", "")

		// More stuff
		self.container.field.entry:SetText("")
		self.container.chat.context:GotoTextEnd()
		
		self.container.chat:AlphaTo(0, .2)
		self.container.field:AlphaTo(0, .2)
		self.container.field.entry:SetPlaceholderText("")
		chat.Close()
end

function component:HUDShouldDraw(name)
	if name == "CHudChat" then
		return false
	end
end

function component:HUDPaint()
	local w = galactic.theme.rem * 29
	local h = galactic.theme.rem * 15
	local x = galactic.theme.rem
	local y = ScrH() - h - galactic.theme.rem * 11.5

	if galactic.BottomLeftHeight then
		y = ScrH() - h - galactic.BottomLeftHeight - galactic.theme.rem
	end

	self.container:SetPos(x, y)
	self.container:SetSize(w, h)
end

galactic:Register(component)
