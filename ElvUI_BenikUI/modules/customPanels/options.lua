local BUI, E, _, V, P, G = unpack(select(2, ...))
local L = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale or 'enUS');
local BP = BUI:GetModule('customPanels');

local tinsert = table.insert

local PanelSetup = {
	['name'] = "",
}

local deleteName = ""

local strataValues = {
	["BACKGROUND"] = "BACKGROUND",
	["LOW"] = "LOW",
	["MEDIUM"] = "MEDIUM",
	["HIGH"] = "HIGH",
	["DIALOG"] = "DIALOG",
	["TOOLTIP"] = "TOOLTIP",
}

local function panelsTable()
	E.Options.args.benikui.args.panels = {
		type = "group",
		name = E.NewSign..L["Custom Panels"],
		order = 31,
		childGroups = "select",
		args = {
			createButton = {
				order = 1,
				name = L["Create"],
				type = 'execute',
				func = function()
					if E.global.benikui.CustomPanels.createButton == true then
						E.global.benikui.CustomPanels.createButton = false
					else
						E.global.benikui.CustomPanels.createButton = true
					end
				end,
			},
			spacer1 = {
				order = 2,
				type = 'description',
				name = '',
			},
			name = {
				order = 3,
				type = 'input',
				width = 'double',
				name = L["Name"],
				desc = L["Type a unique name for the new panel. \n|cff00c0faNote: 'BenikUI_' will be added at the beginning, to ensure uniqueness|r"],
				hidden = function() return not E.global.benikui.CustomPanels.createButton end,
				get = function(info) return PanelSetup.name end,
				set = function(info, textName)
					local name = 'BenikUI_'..textName
					for object in pairs(E.db.benikui.panels) do
						if object:lower() == name:lower() then
							E.PopupDialogs["BUI_Panel_Name"].text = (format(L["The Custom Panel name |cff00c0fa%s|r already exists. Please choose another one."], name))
							E:StaticPopup_Show("BUI_Panel_Name")
							return
						end
					end
					PanelSetup.name = textName
				end,
			},
			spacer2 = {
				order = 4,
				type = 'description',
				name = '',
			},
			add = {
				order = 5,
				name = ADD,
				type = 'execute',
				disabled = function() return PanelSetup.name == "" end,
				hidden = function() return not E.global.benikui.CustomPanels.createButton end,
				func = function()
					E.PopupDialogs["BUI_Add_Panel"].text = (format(L["Your new Custom Panel named |cff00c0fa%s|r is ready to be created.\n|cff00c0faNote: This action will require a reload.|r\nContinue?"], 'BenikUI_'..PanelSetup.name))
					E:StaticPopup_Show("BUI_Add_Panel")
				end,
			},
			spacer3 = {
				order = 6,
				type = 'description',
				name = '',
			},
		},
	}
	
	for panelname in pairs(E.db.benikui.panels) do
		E.Options.args.benikui.args.panels.args[panelname] = {
			order = 1,
			name = panelname,
			type = 'group',
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = ENABLE,
					width = 'full',
					get = function(info) return E.db.benikui.panels[panelname].enable end,
					set = function(info, value) E.db.benikui.panels[panelname].enable = value; BP:SetupPanels() end,
				},
				transparency = {
					order = 2,
					name = L['Panel Transparency'],
					type = 'toggle',
					get = function() return E.db.benikui.panels[panelname].transparency end,
					set = function(info, value) E.db.benikui.panels[panelname].transparency = value; BP:SetupPanels() end,
				},
				style = {
					order = 3,
					name = L['BenikUI Style'],
					type = 'toggle',
					disabled = function() return E.db.benikui.general.benikuiStyle ~= true end,
					get = function() return E.db.benikui.panels[panelname].style end,
					set = function(info, value) E.db.benikui.panels[panelname].style = value; BP:SetupPanels() end,
				},
				shadow = {
					order = 4,
					name = L['Shadow'],
					type = 'toggle',
					disabled = function() return not BUI.ShadowMode end,
					get = function() return E.db.benikui.panels[panelname].shadow end,
					set = function(info, value) E.db.benikui.panels[panelname].shadow = value; BP:SetupPanels() end,
				},
				spacer1 = {
					order = 10,
					type = 'description',
					name = '',
				},
				width = {
					order = 11,
					type = "range",
					name = L['Width'],
					min = 50, max = E.screenwidth, step = 1,
					get = function(info, value) return E.db.benikui.panels[panelname].width end,
					set = function(info, value) E.db.benikui.panels[panelname].width = value; BP:Resize() end,
				},
				height = {
					order = 12,
					type = "range",
					name = L['Height'],
					min = 10, max = E.screenheight, step = 1,
					get = function(info, value) return E.db.benikui.panels[panelname].height end,
					set = function(info, value) E.db.benikui.panels[panelname].height = value; BP:Resize() end,
				},
				strata = {
					order = 13,
					type = 'select',
					name = L["Frame Strata"],
					get = function(info) return E.db.benikui.panels[panelname].strata end,
					set = function(info, value) E.db.benikui.panels[panelname].strata = value; BP:SetupPanels() end,
					values = strataValues,
				},
				spacer2 = {
					order = 20,
					type = 'description',
					name = '',
				},
				petHide = {
					order = 21,
					name = L["Hide in Pet Battle"],
					type = 'toggle',
					get = function() return E.db.benikui.panels[panelname].petHide end,
					set = function(info, value) E.db.benikui.panels[panelname].petHide = value; BP:RegisterHide() end,
				},
				combatHide = {
					order = 22,
					name = L["Hide In Combat"],
					type = 'toggle',
					get = function() return E.db.benikui.panels[panelname].combatHide end,
					set = function(info, value) E.db.benikui.panels[panelname].combatHide = value; end,
				},
				vehicleHide = {
					order = 23,
					name = L["Hide In Vehicle"],
					type = 'toggle',
					get = function() return E.db.benikui.panels[panelname].vehicleHide end,
					set = function(info, value) E.db.benikui.panels[panelname].vehicleHide = value; end,
				},
				spacer3 = {
					order = 30,
					type = 'description',
					name = '',
				},
				tooltip = {
					order = 31,
					name = L["Name Tooltip"],
					desc = L["Enable tooltip to reveal the panel name"],
					type = 'toggle',
					get = function() return E.db.benikui.panels[panelname].tooltip end,
					set = function(info, value) E.db.benikui.panels[panelname].tooltip = value; end,
				},
				spacer4 = {
					order = 40,
					type = 'header',
					name = '',
				},
				delete = {
					order = 41,
					name = DELETE,
					type = 'execute',
					func = function()
						deleteName = panelname
						E.PopupDialogs["BUI_Panel_Delete"].OnAccept = function() BP:DeletePanel(panelname) end
						E.PopupDialogs["BUI_Panel_Delete"].text = (format(L["This will delete the Custom Panel named |cff00c0fa%s|r. This action will require a reload.\nContinue?"], deleteName))
						E:StaticPopup_Show("BUI_Panel_Delete")
					end,
				},
			},
		}
	end
end
tinsert(BUI.Config, panelsTable)

E.PopupDialogs["BUI_Add_Panel"] = {
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() BP:InsertPanel(PanelSetup.name); E.global.benikui.CustomPanels.createButton = false; ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
}

E.PopupDialogs["BUI_Panel_Delete"] = {
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
}

E.PopupDialogs["BUI_Panel_Name"] = {
	button1 = OKAY,
	OnAccept = E.noop,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
}