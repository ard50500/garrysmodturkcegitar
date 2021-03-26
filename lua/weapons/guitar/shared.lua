if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
	
	util.AddNetworkString("hens_guitarTab")
	util.AddNetworkString("hens_guitarPlaySong")
end

if CLIENT then
	SWEP.DrawCrosshair = false
	SWEP.PrintName = "Turkçe Akustik Gitar"
end

SWEP.Base = "weapon_base"

SWEP.PrintName			= "Turkce Gitar"
SWEP.Slot						= 2
SWEP.SlotPos				= 4
SWEP.DrawAmmo			= false
SWEP.ViewModel			= "models/weapons/tayley/v_guitar.mdl"
SWEP.HoldType 				= "slam"
SWEP.ViewModelFOV 		= 70
SWEP.ViewModelFlip 		= false
SWEP.WorldModel 			= "models/hens_guitar/marauder_guitar.mdl"
-- Other settings
SWEP.Weight					= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom	= false
SWEP.Spawnable			= true
SWEP.AdminSpawnable	= true

-- SWEP info
SWEP.Author			= "Nokta"
SWEP.Category 		= "Nokta"
SWEP.Instructions	= "Sag Tik Basarak Muzik Degistirebilirsiniz."

-- Primary fire settings
SWEP.Primary.Damage					= -1
SWEP.Primary.NumShots				= -1
SWEP.Primary.Delay						= 2
SWEP.Primary.ClipSize					= -1
SWEP.Primary.DefaultClip				= 0
SWEP.Primary.Tracer						= -1
SWEP.Primary.Force						= -1
SWEP.Primary.TakeAmmoPerBullet	= false
SWEP.Primary.Automatic				= false
SWEP.Primary.Ammo						= "none"

SWEP.ReloadTimer							= 1

local songsTbl = {
	[1] = {"Ankaranin Baglari", "weapons/guitar/ankara.mp3"},
	[2] = {"Bakiyorsun Oyle Yine Magrur", "weapons/guitar/ogle.mp3"},
 [3] = {"Bara Bara Bere", "weapons/guitar/barabere.mp3"},
    [4] = {"Bordo Mavi Bereliler", "weapons/guitar/bordo.mp3"},
    [5] = {"Bozkurt Sarkisi", "weapons/guitar/bozkurt.mp3"},
    [6] = {"Bilal Goregen Bum Bum", "weapons/guitar/bumbum.mp3"},
    [7] = {"Cendere Yuruyusu Muzigi", "weapons/guitar/cendere.mp3"},
    [8] = {"Dul Dul Muzigi", "weapons/guitar/duldul.mp3"},
    [9] = {"Magazin Muzigi", "weapons/guitar/magazin.mp3"},
    [10] = {"Noel Dayi Sarkisi", "weapons/guitar/noel.mp3"},
    [11] = {"Oglumun Tabancasi", "weapons/guitar/tabanca.mp3"},
    [12] = {"Saz Mix", "weapons/guitar/sazmix.mp3"},
    [13] = {"Tori Gari Sarkisi", "weapons/guitar/torigari.mp3"},
    [14] = {"Varsa Sekerin Patlayalim", "weapons/guitar/varsa.mp3"},
    [15] = {"Yarim", "weapons/guitar/yarim.mp3"},
    [16] = {"Zurna Sarkisi", "weapons/guitar/zurna.mp3"},
	[17] = {"Serdar Ortac Ben Adam Olmam", "weapons/guitar/serdar.mp3"},
	[18] = {"2pac ft Muslum Gurses", "weapons/guitar/2pac.mp3"},
	[19] = {"Cansever Uzum", "weapons/guitar/cansever.mp3"},
	[20] = {"Corona Sarkisi", "weapons/guitar/corona.mp3"},
	[21] = {"Beamer Boi", "weapons/guitar/beamer.mp3"},
	[22] = {"Uzi Makina", "weapons/guitar/uzi.mp3"},
	[23] = {"Yenidena", "weapons/guitar/yeniden.mp3"},


}

if CLIENT then

	SWEP.WepSelectIcon = surface.GetTextureID("vgui/selection/guitar_ico")
	function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
		x = x + wide / 2
		y = y + tall / 2

		tall = tall * 0.75

		x = x - tall / 2
		y = y - tall / 2 - 10

		surface.SetDrawColor(255, 255, 255, alpha)
		surface.SetTexture(self.WepSelectIcon)

		surface.DrawTexturedRect(x, y, tall, tall)
	end
	
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Holster()
	self.Weapon:EmitSound(Sound("ambient/machines/squeak_2.wav"))
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	self.Weapon:EmitSound(Sound("ambient/machines/squeak_2.wav"), 50, math.random(85,100), 1, CHAN_SWEP)
	
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	if SERVER then
		local songChoice = math.random(1, #songsTbl)
		self.Weapon:SetNWBool("guitar_isPlaying", true)
		self.Weapon:SetNWInt("guitar_songNum", songChoice)
	end
	timer.Simple(0.5, function()
		local song = songsTbl[self.Weapon:GetNWInt("guitar_songNum")][2]
		if(song == nil) then
			song = ""
		end
		self.Weapon:EmitSound(song, 80, 100, 1, CHAN_SWEP)
	end)
end

function SWEP:SecondaryAttack()
	local ply = self.Owner
	if SERVER then
		net.Start("hens_guitarTab")
		net.Send(ply)
	end
	return false
end

function SWEP:Think()
end

function SWEP:Reload()
	if(self.Weapon:GetNextSecondaryFire() <= CurTime() ) then
		self.Weapon:SetNextSecondaryFire(CurTime() + self.ReloadTimer)
		self.Weapon:SetNWBool("guitar_isPlaying", false)
		self.Weapon:EmitSound(Sound("ambient/machines/squeak_2.wav"), 50, math.random(85,100), 1, CHAN_SWEP)
		return false
	end
end

function SWEP:Deploy()
	self:SetWeaponHoldType(self.HoldType)
	return true
end

SWEP.RenderGroup = RENDERGROUP_BOTH

function SWEP:DrawWorldModelTranslucent()
	self:DrawModel()
	
	if self.time == nil then self.time = 0 end
	surface.SetFont("Trebuchet24")
	local tag = "Suan Caliyor  ... " 
	if(self.Weapon:GetNWInt("guitar_songNum") ~= 0) then
		songName = songsTbl[self.Weapon:GetNWInt("guitar_songNum")][1]
		tag = "Suan Caliyor ... "  .. songName
	end
	local textwidth = surface.GetTextSize(tag)
	
	if LocalPlayer():GetPos():Distance(self:GetPos()) < 550 then
		if(self.Weapon:GetNWBool("guitar_isPlaying") == false) then return end 
		local alpha = (LocalPlayer():GetPos():Distance(self:GetPos()) / 100.0)
		alpha = math.Clamp(2.5 - alpha, 0 ,1)
		local a = Angle(0,0,0)
		a:RotateAroundAxis(Vector(1,0,0),90)
		a.y = LocalPlayer():GetAngles().y - 90
		cam.Start3D2D(self:GetPos() + Vector(0,0,45 + (math.sin(self.time*0.5)*2)), a , 0.15)
			draw.SimpleText(tag,"Trebuchet24", -textwidth*0.5,0,Color(205,225,255,255*alpha) , 0 , 1)
		cam.End3D2D()
	end
	
	self.time = self.time + FrameTime()
end

net.Receive("hens_guitarPlaySong", function(len, ply)
	local songNum = net.ReadFloat()
	
	local wep = ply:GetActiveWeapon()
	if(wep:GetClass() == "guitar") then
		wep:SetNWBool("guitar_isPlaying", true)
		wep:SetNWInt("guitar_songNum", songNum)
		wep:EmitSound( songsTbl[songNum][2], 80, 100, 1, CHAN_SWEP)
		
	end
end)

// DERMA STUFF

if CLIENT then

	local PANEL = {}

	function PANEL:Init()
		local w = ScrW()*0.15
		local h = ScrH()*0.4
		self:SetSize(w, h)
		self:SetPos(ScrW()*0.75, ScrH()/2 - (h/2))
		
		self:MakePopup()
		self:SetDeleteOnClose(true)
		self:SetDraggable(true)
		self:ShowCloseButton(true)
		self:SetTitle("")
		
		self.Paint = function(_, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 225))
		end
		
		self.MusicOptions = vgui.Create("hens_Guitar:DScroll", self)

	end

	vgui.Register("hens_Guitar:Menu", PANEL, "DFrame")

	net.Receive("hens_guitarTab", function()
		if(IsValid(guitPanel)) then return end
		guitPanel = vgui.Create("hens_Guitar:Menu")
	end)
	
	// MUSIC
	local PANEL = {}
	
	function PANEL:Init()
		local x,y = self:GetParent():GetSize()
		self:SetSize(x, y + 60)
		self:SetPos(0, 30)
		
		--Modify Scroll Bar--
		local sbar = self:GetVBar()
		sbar:SetHideButtons(true)
		sbar.Paint = function(_, w, h)
			draw.RoundedBox(0, 0, 0, (w/2), h, Color(0, 0, 0, 225))
		end
		
		sbar.btnGrip.Paint = function(_, w, h)
			draw.RoundedBox(0, 0, 0, (w/2), h, Color(255, 255, 255, 255))
		end
		
		self.Paint = function(_, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
		end
		
		for k, v in ipairs(songsTbl) do
			local btn = self:Add("DButton")
			btn:Dock(TOP)
			btn:DockMargin(10, 0, 10, 10)
			btn:SetSize(0, 25)
			btn:SetText("")
			btn.HoverLerp = 0
			btn.Paint = function(_, w, h)
				if btn:IsHovered() then
					btn.HoverLerp = Lerp( FrameTime() * 10, btn.HoverLerp, 1 )
				else
					btn.HoverLerp = Lerp( FrameTime() * 3, btn.HoverLerp, 0.1)
				end
				draw.RoundedBox(0, 0, 0, w, h, Color(50,50,50,255*btn.HoverLerp))
				draw.SimpleText(v[1], "Trebuchet18", w/2, 2, Color(255,255,255, 255), 1, 0)
			end
			
			btn.PaintOver = function(_, w, h)
				surface.SetDrawColor(Color(255, 255, 255, 125), 1, 1)
				surface.DrawOutlinedRect(0, 0, w, h)
			end
			
			btn.DoClick = function()
				local wep = LocalPlayer():GetActiveWeapon()
				if(wep ~= nil or IsValid(wep)) then
					LocalPlayer():EmitSound(Sound("ambient/machines/squeak_2.wav") )
					wep:EmitSound( v[2], 100, 100, 1, CHAN_SWEP )
				end
				net.Start("hens_guitarPlaySong")
					net.WriteFloat(k)
				net.SendToServer()
				
				self:GetParent():Close()
			end

		end
		
		self:Dock(FILL)
		self:DockMargin(0, 0, 0, 10)
	end

	vgui.Register("hens_Guitar:DScroll", PANEL, "DScrollPanel")
end