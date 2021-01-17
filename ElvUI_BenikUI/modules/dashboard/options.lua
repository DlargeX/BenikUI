local BUI, E, _, V, P, G = unpack(select(2, ...))
local L = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale or 'enUS');
local BUID = BUI:GetModule('Dashboards');

local tinsert, pairs, ipairs, gsub, unpack, format, tostring = table.insert, pairs, ipairs, gsub, unpack, string.format, tostring
local GetProfessions, GetProfessionInfo = GetProfessions, GetProfessionInfo
local GetFactionInfoByID = GetFactionInfoByID
local BreakUpLargeNumbers = BreakUpLargeNumbers

local PROFESSIONS_ARCHAEOLOGY, PROFESSIONS_MISSING_PROFESSION, TOKENS = PROFESSIONS_ARCHAEOLOGY, PROFESSIONS_MISSING_PROFESSION, TOKENS
local TRADE_SKILLS = TRADE_SKILLS

-- GLOBALS: AceGUIWidgetLSMlists, hooksecurefunc

local boards = {"FPS", "MS", "Durability", "Bags", "Volume"}

local function UpdateSystemOptions()
	for _, boardname in pairs(boards) do
		local optionOrder = 1
		E.Options.args.benikui.args.dashboards.args.system.args.chooseSystem.args[boardname] = {
			order = optionOrder + 1,
			type = 'toggle',
			name = boardname,
			desc = L['Enable/Disable ']..boardname,
			get = function(info) return E.db.dashboards.system.chooseSystem[boardname] end,
			set = function(info, value) E.db.dashboards.system.chooseSystem[boardname] = value; E:StaticPopup_Show('PRIVATE_RL'); end,
		}
	end

	E.Options.args.benikui.args.dashboards.args.system.args.latency = {
		order = 10,
		type = "select",
		name = L['Latency (MS)'],
		values = {
			[1] = L.HOME,
			[2] = L.WORLD,
		},
		disabled = function() return not E.db.dashboards.system.chooseSystem.MS end,
		get = function(info) return E.db.dashboards.system.latency end,
		set = function(info, value) E.db.dashboards.system.latency = value; E:StaticPopup_Show('PRIVATE_RL'); end,
	}
end

local function UpdateTokenOptions()
	for i, info in ipairs(BUI.CurrencyList) do
		local optionOrder = 1
		local name, id = unpack(info)
		if not info[2] then
			E.Options.args.benikui.args.dashboards.args.tokens.args[tostring(i)] = {
				order = i,
				type = 'group',
				name = name,
				args = {
				},
			}
		elseif info[3] then
			local tname, amount, icon = BUID:GetTokenInfo(id)
			if tname then
				E.Options.args.benikui.args.dashboards.args.tokens.args[tostring(info[3])].args[tostring(i)] = {
					order = optionOrder + 2,
					type = 'toggle',
					name = (icon and '|T'..icon..':18|t '..tname) or tname,
					desc = format('%s %s\n\n|cffffff00%s: %s|r', L['Enable/Disable'], tname, L['Amount'], BreakUpLargeNumbers(amount)),
					get = function(info) return E.private.dashboards.tokens.chooseTokens[id] end,
					set = function(info, value) E.private.dashboards.tokens.chooseTokens[id] = value; BUID:UpdateTokens(); BUID:UpdateTokenSettings(); end,
				}
			end
		end
	end
end

local function UpdateProfessionOptions()
	local prof1, prof2, archy, fishing, cooking = GetProfessions()
	local optionOrder = 1
	if (prof1 or prof2 or archy or fishing or cooking) then
		E.Options.args.benikui.args.dashboards.args.professions.args.choosePofessions = {
			order = 50,
			type = 'group',
			guiInline = true,
			name = L['Select Professions'],
			disabled = function() return not E.db.dashboards.professions.enableProfessions end,
			args = {
			},
		}
		local proftable = { GetProfessions() }
		for _, id in pairs(proftable) do
			local pname, icon = GetProfessionInfo(id)
			if pname then
				E.Options.args.benikui.args.dashboards.args.professions.args.choosePofessions.args[pname] = {
					order = optionOrder + 1,
					type = 'toggle',
					name = '|T'..icon..':18|t '..pname,
					desc = format('%s %s', L['Enable/Disable'], pname),
					get = function(info) return E.private.dashboards.professions.choosePofessions[id] end,
					set = function(info, value) E.private.dashboards.professions.choosePofessions[id] = value; BUID:UpdateProfessions(); BUID:UpdateProfessionSettings(); end,
				}
			end
		end
	else
		E.Options.args.benikui.args.dashboards.args.professions.args.choosePofessions = {
			order = 50,
			type = 'group',
			guiInline = true,
			name = L['Select Professions'],
			disabled = function() return not E.db.dashboards.professions.enableProfessions end,
			args = {
				noprof = {
					order = 1,
					type = 'description',
					name = PROFESSIONS_MISSING_PROFESSION,
				},
			},
		}
	end
end

local function UpdateReputationOptions()
	local optionOrder = 30

	for i, info in ipairs(BUI.ReputationsList) do
		local optionOrder = 1
		local name, factionID, headerIndex, isHeader, hasRep, isChild = unpack(info)

		if isHeader and not (hasRep or isChild) then
			E.Options.args.benikui.args.dashboards.args.reputations.args[tostring(headerIndex)] = {
				order = optionOrder + 1,
				type = 'group',
				name = name,
				args = {
				},
			}
		else
			E.Options.args.benikui.args.dashboards.args.reputations.args[tostring(headerIndex)].args[tostring(i)] = {
				order = optionOrder + 2,
				type = 'toggle',
				name = name,
				desc = format('%s %s', L['Enable/Disable'], name),
				disabled = function() return not E.db.dashboards.reputations.enableReputations end,
				get = function(info) return E.private.dashboards.reputations.chooseReputations[factionID] end,
				set = function(info, value) E.private.dashboards.reputations.chooseReputations[factionID] = value; BUID:UpdateReputations(); BUID:UpdateReputationSettings(); end,
			}
		end
	end
end

local function dashboardsTable()
	E.Options.args.benikui.args.dashboards = {
		order = 60,
		type = 'group',
		name = BUI:cOption(L['Dashboards'], "orange"),
		args = {
			dashColor = {
				order = 1,
				type = 'group',
				name = L.COLOR,
				guiInline = true,
				args = {
					barColor = {
						type = "select",
						order = 1,
						name = L['Bar Color'],
						values = {
							[1] = L.CLASS_COLORS,
							[2] = L.CUSTOM,
						},
						get = function(info) return E.db.dashboards[ info[#info] ] end,
						set = function(info, value) E.db.dashboards[ info[#info] ] = value;
							if E.db.dashboards.professions.enableProfessions then BUID:UpdateProfessionSettings(); end
							if E.db.dashboards.tokens.enableTokens then BUID:UpdateTokenSettings(); end
							if E.db.dashboards.system.enableSystem then BUID:UpdateSystemSettings(); end
							if E.db.dashboards.reputations.enableReputations then BUID:UpdateReputationSettings(); end
						end,
					},
					customBarColor = {
						order = 2,
						type = "color",
						name = COLOR_PICKER,
						disabled = function() return E.db.dashboards.barColor == 1 end,
						get = function(info)
							local t = E.db.dashboards[ info[#info] ]
							local d = P.dashboards[info[#info]]
							return t.r, t.g, t.b, t.a, d.r, d.g, d.b
						end,
						set = function(info, r, g, b, a)
							E.db.dashboards[ info[#info] ] = {}
							local t = E.db.dashboards[ info[#info] ]
							t.r, t.g, t.b, t.a = r, g, b, a
							if E.db.dashboards.professions.enableProfessions then BUID:UpdateProfessionSettings(); end
							if E.db.dashboards.tokens.enableTokens then BUID:UpdateTokenSettings(); end
							if E.db.dashboards.system.enableSystem then BUID:UpdateSystemSettings(); end
							if E.db.dashboards.reputations.enableReputations then BUID:UpdateReputationSettings(); end
						end,
					},
					spacer = {
						order = 3,
						type = 'header',
						name = '',
					},
					textColor = {
						order = 4,
						type = "select",
						name = L['Text Color'],
						values = {
							[1] = L.CLASS_COLORS,
							[2] = L.CUSTOM,
						},
						get = function(info) return E.db.dashboards[ info[#info] ] end,
						set = function(info, value) E.db.dashboards[ info[#info] ] = value;
							if E.db.dashboards.professions.enableProfessions then BUID:UpdateProfessionSettings(); end
							if E.db.dashboards.tokens.enableTokens then BUID:UpdateTokenSettings(); end
							if E.db.dashboards.system.enableSystem then BUID:UpdateSystemSettings(); end
							if E.db.dashboards.reputations.enableReputations then BUID:UpdateReputationSettings(); end
						end,
					},
					customTextColor = {
						order = 5,
						type = "color",
						name = L.COLOR_PICKER,
						disabled = function() return E.db.dashboards.textColor == 1 end,
						get = function(info)
							local t = E.db.dashboards[ info[#info] ]
							local d = P.dashboards[info[#info]]
							return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
						set = function(info, r, g, b, a)
							E.db.dashboards[ info[#info] ] = {}
							local t = E.db.dashboards[ info[#info] ]
							t.r, t.g, t.b, t.a = r, g, b, a
							if E.db.dashboards.professions.enableProfessions then BUID:UpdateProfessionSettings(); end
							if E.db.dashboards.tokens.enableTokens then BUID:UpdateTokenSettings(); end
							if E.db.dashboards.system.enableSystem then BUID:UpdateSystemSettings(); end
							if E.db.dashboards.reputations.enableReputations then BUID:UpdateReputationSettings(); end
						end,
					},
				},
			},
			dashfont = {
				order = 2,
				type = 'group',
				name = L['Fonts'],
				guiInline = true,
				disabled = function() return not E.db.dashboards.system.enableSystem and not E.db.dashboards.tokens.enableTokens and not E.db.dashboards.professions.enableProfessions end,
				get = function(info) return E.db.dashboards.dashfont[ info[#info] ] end,
				set = function(info, value) E.db.dashboards.dashfont[ info[#info] ] = value;
					if E.db.dashboards.professions.enableProfessions then BUID:UpdateProfessionSettings(); end
					if E.db.dashboards.tokens.enableTokens then BUID:UpdateTokenSettings(); end
					if E.db.dashboards.system.enableSystem then BUID:UpdateSystemSettings(); end
					if E.db.dashboards.reputations.enableReputations then BUID:UpdateReputationSettings(); end
				end,
				args = {
					useDTfont = {
						order = 1,
						name = L['Use DataTexts font'],
						type = 'toggle',
						width = 'full',
					},
					dbfont = {
						type = 'select', dialogControl = 'LSM30_Font',
						order = 2,
						name = L['Font'],
						desc = L['Choose font for all dashboards.'],
						disabled = function() return E.db.dashboards.dashfont.useDTfont end,
						values = AceGUIWidgetLSMlists.font,
					},
					dbfontsize = {
						order = 3,
						name = L.FONT_SIZE,
						desc = L['Set the font size.'],
						disabled = function() return E.db.dashboards.dashfont.useDTfont end,
						type = 'range',
						min = 6, max = 22, step = 1,
					},
					dbfontflags = {
						order = 4,
						name = L['Font Outline'],
						disabled = function() return E.db.dashboards.dashfont.useDTfont end,
						type = 'select',
						values = {
							['NONE'] = L['None'],
							['OUTLINE'] = 'OUTLINE',
							['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
							['THICKOUTLINE'] = 'THICKOUTLINE',
						},
					},
				},
			},
			system = {
				order = 3,
				type = 'group',
				name = L['System'],
				args = {
					enableSystem = {
						order = 1,
						type = 'toggle',
						name = L["Enable"],
						width = 'full',
						desc = L['Enable the System Dashboard.'],
						get = function(info) return E.db.dashboards.system.enableSystem end,
						set = function(info, value) E.db.dashboards.system.enableSystem = value; E:StaticPopup_Show('PRIVATE_RL'); end,
					},
					width = {
						order = 2,
						type = 'range',
						name = L['Width'],
						desc = L['Change the System Dashboard width.'],
						min = 120, max = 520, step = 1,
						disabled = function() return not E.db.dashboards.system.enableSystem end,
						get = function(info) return E.db.dashboards.system.width end,
						set = function(info, value) E.db.dashboards.system.width = value; BUID:UpdateHolderDimensions(BUI_SystemDashboard, 'system', BUI.SystemDB); BUID:UpdateSystemSettings(); end,
					},
					layoutOptions = {
						order = 3,
						type = 'multiselect',
						name = L['Layout'],
						disabled = function() return not E.db.dashboards.system.enableSystem end,
						get = function(_, key) return E.db.dashboards.system[key] end,
						set = function(_, key, value) E.db.dashboards.system[key] = value; BUID:ToggleStyle(BUI_SystemDashboard, 'system') BUID:ToggleTransparency(BUI_SystemDashboard, 'system') end,
						values = {
							style = L['BenikUI Style'],
							transparency = L['Panel Transparency'],
							backdrop = L['Backdrop'],
						}
					},
					combat = {
						order = 4,
						name = L['Combat Fade'],
						desc = L['Show/Hide System Dashboard when in combat'],
						type = 'toggle',
						disabled = function() return not E.db.dashboards.system.enableSystem end,
						get = function(info) return E.db.dashboards.system.combat end,
						set = function(info, value) E.db.dashboards.system.combat = value; BUID:EnableDisableCombat(BUI_SystemDashboard, 'system'); end,
					},
					mouseover = {
						order = 5,
						name = L['Mouse Over'],
						desc = L['The frame is not shown unless you mouse over the frame.'],
						type = 'toggle',
						disabled = function() return not E.db.dashboards.system.enableSystem end,
						get = function(info) return E.db.dashboards.system.mouseover end,
						set = function(info, value) E.db.dashboards.system.mouseover = value; E:StaticPopup_Show('PRIVATE_RL'); end,
					},
					spacer = {
						order = 10,
						type = 'header',
						name = '',
					},
					chooseSystem = {
						order = 20,
						type = 'group',
						guiInline = true,
						name = L['Select System Board'],
						disabled = function() return not E.db.dashboards.system.enableSystem end,
						args = {
						},
					},
				},
			},
			tokens = {
				order = 4,
				type = 'group',
				name = TOKENS,
				childGroups = 'select',
				args = {
					enableTokens = {
						order = 1,
						type = 'toggle',
						name = L["Enable"],
						width = 'full',
						desc = L['Enable the Tokens Dashboard.'],
						get = function(info) return E.db.dashboards.tokens.enableTokens end,
						set = function(info, value) E.db.dashboards.tokens.enableTokens = value; E:StaticPopup_Show('PRIVATE_RL'); end,
					},
					width = {
						order = 2,
						type = 'range',
						name = L['Width'],
						desc = L['Change the Tokens Dashboard width.'],
						min = 120, max = 520, step = 1,
						disabled = function() return not E.db.dashboards.tokens.enableTokens end,
						get = function(info) return E.db.dashboards.tokens.width end,
						set = function(info, value) E.db.dashboards.tokens.width = value; BUID:UpdateHolderDimensions(BUI_TokensDashboard, 'tokens', BUI.TokensDB); BUID:UpdateTokenSettings(); end,
					},
					layoutOptions = {
						order = 3,
						type = 'multiselect',
						name = L['Layout'],
						disabled = function() return not E.db.dashboards.tokens.enableTokens end,
						get = function(_, key) return E.db.dashboards.tokens[key] end,
						set = function(_, key, value) E.db.dashboards.tokens[key] = value; BUID:ToggleStyle(BUI_TokensDashboard, 'tokens') BUID:ToggleTransparency(BUI_TokensDashboard, 'tokens') end,
						values = {
							style = L['BenikUI Style'],
							transparency = L['Panel Transparency'],
							backdrop = L['Backdrop'],
						}
					},
					zeroamount = {
						order = 4,
						name = L['Show zero amount tokens'],
						desc = L['Show the token, even if the amount is 0'],
						type = 'toggle',
						disabled = function() return not E.db.dashboards.tokens.enableTokens end,
						get = function(info) return E.db.dashboards.tokens.zeroamount end,
						set = function(info, value) E.db.dashboards.tokens.zeroamount = value; BUID:UpdateTokens(); BUID:UpdateTokenSettings(); end,
					},
					weekly = {
						order = 5,
						name = L['Show Weekly max'],
						desc = L['Show Weekly max tokens instead of total max'],
						type = 'toggle',
						disabled = function() return not E.db.dashboards.tokens.enableTokens end,
						get = function(info) return E.db.dashboards.tokens.weekly end,
						set = function(info, value) E.db.dashboards.tokens.weekly = value; BUID:UpdateTokens(); BUID:UpdateTokenSettings(); end,
					},
					combat = {
						order = 6,
						name = L['Combat Fade'],
						desc = L['Show/Hide Tokens Dashboard when in combat'],
						type = 'toggle',
						disabled = function() return not E.db.dashboards.tokens.enableTokens end,
						get = function(info) return E.db.dashboards.tokens.combat end,
						set = function(info, value) E.db.dashboards.tokens.combat = value; BUID:EnableDisableCombat(BUI_TokensDashboard, 'tokens'); end,
					},
					mouseover = {
						order = 7,
						name = L['Mouse Over'],
						desc = L['The frame is not shown unless you mouse over the frame.'],
						type = 'toggle',
						disabled = function() return not E.db.dashboards.tokens.enableTokens end,
						get = function(info) return E.db.dashboards.tokens.mouseover end,
						set = function(info, value) E.db.dashboards.tokens.mouseover = value; BUID:UpdateTokens(); BUID:UpdateTokenSettings(); end,
					},
					tooltip = {
						order = 8,
						name = L['Tooltip'],
						desc = L['Show/Hide Tooltips'],
						type = 'toggle',
						disabled = function() return not E.db.dashboards.tokens.enableTokens end,
						get = function(info) return E.db.dashboards.tokens.tooltip end,
						set = function(info, value) E.db.dashboards.tokens.tooltip = value; BUID:UpdateTokens(); BUID:UpdateTokenSettings(); end,
					},
					spacer = {
						order = 11,
						type = 'header',
						name = '',
					},
				},
			},
			professions = {
				order = 5,
				type = 'group',
				name = TRADE_SKILLS,
				args = {
					enableProfessions = {
						order = 1,
						type = 'toggle',
						name = L["Enable"],
						width = 'full',
						desc = L['Enable the Professions Dashboard.'],
						get = function(info) return E.db.dashboards.professions.enableProfessions end,
						set = function(info, value) E.db.dashboards.professions.enableProfessions = value; E:StaticPopup_Show('PRIVATE_RL'); end,
					},
					width = {
						order = 2,
						type = 'range',
						name = L['Width'],
						desc = L['Change the Professions Dashboard width.'],
						min = 120, max = 520, step = 1,
						disabled = function() return not E.db.dashboards.professions.enableProfessions end,
						get = function(info) return E.db.dashboards.professions.width end,
						set = function(info, value) E.db.dashboards.professions.width = value; BUID:UpdateHolderDimensions(BUI_ProfessionsDashboard, 'professions', BUI.ProfessionsDB); BUID:UpdateProfessionSettings(); end,
					},
					layoutOptions = {
						order = 3,
						type = 'multiselect',
						name = L['Layout'],
						disabled = function() return not E.db.dashboards.professions.enableProfessions end,
						get = function(_, key) return E.db.dashboards.professions[key] end,
						set = function(_, key, value) E.db.dashboards.professions[key] = value; BUID:ToggleStyle(BUI_ProfessionsDashboard, 'professions') BUID:ToggleTransparency(BUI_ProfessionsDashboard, 'professions') end,
						values = {
							style = L['BenikUI Style'],
							transparency = L['Panel Transparency'],
							backdrop = L['Backdrop'],
						}
					},
					capped = {
						order = 4,
						name = L['Filter Capped'],
						desc = L['Show/Hide Professions that are skill capped'],
						type = 'toggle',
						disabled = function() return not E.db.dashboards.professions.enableProfessions end,
						get = function(info) return E.db.dashboards.professions.capped end,
						set = function(info, value) E.db.dashboards.professions.capped = value; BUID:UpdateProfessions(); BUID:UpdateProfessionSettings(); end,
					},
					combat = {
						order = 5,
						name = L['Combat Fade'],
						desc = L['Show/Hide Professions Dashboard when in combat'],
						type = 'toggle',
						disabled = function() return not E.db.dashboards.professions.enableProfessions end,
						get = function(info) return E.db.dashboards.professions.combat end,
						set = function(info, value) E.db.dashboards.professions.combat = value; BUID:EnableDisableCombat(BUI_ProfessionsDashboard, 'professions'); end,
					},
					mouseover = {
						order = 6,
						name = L['Mouse Over'],
						desc = L['The frame is not shown unless you mouse over the frame.'],
						type = 'toggle',
						disabled = function() return not E.db.dashboards.professions.enableProfessions end,
						get = function(info) return E.db.dashboards.professions.mouseover end,
						set = function(info, value) E.db.dashboards.professions.mouseover = value; BUID:UpdateProfessions(); BUID:UpdateProfessionSettings(); end,
					},
					spacer = {
						order = 9,
						type = 'header',
						name = '',
					},
				},
			},
			reputations = {
				order = 6,
				type = 'group',
				name = REPUTATION,
				childGroups = 'select',
				args = {
					enableReputations = {
						order = 1,
						type = 'toggle',
						name = L["Enable"],
						width = 'full',
						desc = L['Enable the Professions Dashboard.'],
						get = function(info) return E.db.dashboards.reputations[ info[#info] ] end,
						set = function(info, value) E.db.dashboards.reputations[ info[#info] ] = value; E:StaticPopup_Show('PRIVATE_RL'); end,
					},
					width = {
						order = 2,
						type = 'range',
						name = L['Width'],
						desc = L['Change the Professions Dashboard width.'],
						min = 120, max = 520, step = 1,
						disabled = function() return not E.db.dashboards.reputations.enableReputations end,
						get = function(info) return E.db.dashboards.reputations[ info[#info] ] end,
						set = function(info, value) E.db.dashboards.reputations[ info[#info] ] = value; BUID:UpdateHolderDimensions(BUI_ReputationsDashboard, 'reputations', BUI.FactionsDB); BUID:UpdateReputationSettings(); BUID:UpdateReputations(); end,
					},
					textAlign ={
						order = 3,
						name = L['Text Alignment'],
						type = 'select',
						values = {
							['CENTER'] = L['Center'],
							['LEFT'] = L['Left'],
							['RIGHT'] = L['Right'],
						},
						disabled = function() return not E.db.dashboards.reputations.enableReputations end,
						get = function(info) return E.db.dashboards.reputations[ info[#info] ] end,
						set = function(info, value) E.db.dashboards.reputations[ info[#info] ] = value; BUID:UpdateReputations(); end,
					},
					layoutOptions = {
						order = 5,
						type = 'multiselect',
						name = L['Layout'],
						disabled = function() return not E.db.dashboards.reputations.enableReputations end,
						get = function(_, key) return E.db.dashboards.reputations[key] end,
						set = function(_, key, value) E.db.dashboards.reputations[key] = value; BUID:ToggleStyle(BUI_ReputationsDashboard, 'reputations') BUID:ToggleTransparency(BUI_ReputationsDashboard, 'reputations') end,
						values = {
							style = L['BenikUI Style'],
							transparency = L['Panel Transparency'],
							backdrop = L['Backdrop'],
						}
					},
					factionColors = {
						order = 6,
						type = 'multiselect',
						name = L['Faction Colors'],
						disabled = function() return not E.db.dashboards.reputations.enableReputations end,
						get = function(_, key) return E.db.dashboards.reputations[key] end,
						set = function(_, key, value) E.db.dashboards.reputations[key] = value; BUID:UpdateReputations(); BUID:UpdateReputationSettings(); end,
						values = {
							barFactionColors = L['Use Faction Colors on Bars'],
							textFactionColors = L['Use Faction Colors on Text'],
						}
					},
					combat = {
						order = 7,
						name = L['Hide In Combat'],
						desc = L['Show/Hide Reputations Dashboard when in combat'],
						type = 'toggle',
						disabled = function() return not E.db.dashboards.reputations.enableReputations end,
						get = function(info) return E.db.dashboards.reputations[ info[#info] ] end,
						set = function(info, value) E.db.dashboards.reputations[ info[#info] ] = value; BUID:EnableDisableCombat(BUI_ReputationsDashboard, 'reputations'); end,
					},
					mouseover = {
						order = 8,
						name = L['Mouse Over'],
						desc = L['The frame is not shown unless you mouse over the frame.'],
						type = 'toggle',
						disabled = function() return not E.db.dashboards.reputations.enableReputations end,
						get = function(info) return E.db.dashboards.reputations[ info[#info] ] end,
						set = function(info, value) E.db.dashboards.reputations[ info[#info] ] = value; BUID:UpdateReputations(); BUID:UpdateReputationSettings(); end,
					},
					tooltip = {
						order = 9,
						name = L['Tooltip'],
						type = 'toggle',
						disabled = function() return not E.db.dashboards.reputations.enableReputations end,
						get = function(info) return E.db.dashboards.reputations[ info[#info] ] end,
						set = function(info, value) E.db.dashboards.reputations[ info[#info] ] = value; BUID:UpdateReputations(); end,
					},
					spacer = {
						order = 20,
						type = 'header',
						name = '',
					},
				},
			},
		},
	}
	-- update the options, when ElvUI Config fires
	hooksecurefunc(E, "ToggleOptionsUI", UpdateTokenOptions)
	hooksecurefunc(E, "ToggleOptionsUI", UpdateProfessionOptions)
	hooksecurefunc(E, "ToggleOptionsUI", UpdateReputationOptions)
end

tinsert(BUI.Config, dashboardsTable)
tinsert(BUI.Config, UpdateSystemOptions)
tinsert(BUI.Config, UpdateTokenOptions)
tinsert(BUI.Config, UpdateProfessionOptions)
tinsert(BUI.Config, UpdateReputationOptions)
