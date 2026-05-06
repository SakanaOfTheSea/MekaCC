-- mek.lua  (single-file bundle of CC-Mekanism-ATM9)
--
-- Сделано Бобрами  ;)
-- (CC:Tweaked monitors render only an 8-bit ASCII font, so on the screen the
--  credit appears transliterated as "Sdelano Bobrami" in the header.)
--
-- Usage on every computer:
--   pastebin get <PASTE_ID> startup
--   reboot
--   -- on first boot you'll see the role/name picker.
--
-- Commands:
--   mek setup           -- re-run setup (role + friendly name)
--   mek <role>          -- one-shot run without saving
--   roles: display | induction | fission | turbine | boiler | fusion
--
-- Energy conversion notes:
--   Mekanism's CC peripherals return energy in JOULES. Forge Energy (FE) is
--   the unit shown in Mekanism GUIs. Conversion: 1 FE = 2.5 J -> J*0.4 = FE.
--   This is configurable in /cfg/units.cfg (`joulesToFE`) in case you change
--   Mekanism's energy ratio in the server config.

------------------------------------------------------------
-- Language / labels (English)
------------------------------------------------------------
local L = {
    headerTitle = "Mek-ATM9 SCADA",
    credit      = "Sdelano Bobrami",  -- Сделано Бобрами
    okFooter    = "All systems nominal",
    waiting     = "Waiting for hosts to broadcast...",
    sevLabels   = { [0] = "OK", [1] = "NOTICE", [2] = "WARN", [3] = "CRITICAL" },
    tabs = {
        overview = "Overview", induction = "Induction", fission = "Fission",
        turbine = "Turbine", boiler = "Boiler", fusion = "Fusion",
        history = "History", scram = "SCRAM",
    },
    roleLabel = {
        induction = "INDUCTION", fission = "FISSION",
        turbine = "TURBINE", boiler = "BOILER", fusion = "FUSION",
    },
    setupTitle    = "=== mek :: setup ===",
    pickRole      = "Pick role number: ",
    invalidChoice = "Invalid choice.",
    askName       = "Friendly name (e.g. 'Main Matrix'): ",
    askComputerLabel = "Computer label (Enter to skip): ",
    saved         = "Saved. Rebooting...",
    -- Common values
    stored      = "Stored",
    capacity    = "Capacity",
    fill        = "Fill",
    input       = "Input",
    output      = "Output",
    net         = "Net",
    cells       = "Cells",
    providers   = "Providers",
    transferCap = "Xfer cap",
    -- Fission
    status   = "Status",
    temp     = "Temp",
    damage   = "Damage",
    burn     = "Burn",
    setBurn  = "Set burn",
    maxBurn  = "Max burn",
    burnPct  = "Burn %",
    coolant  = "Coolant",      -- input coolant tank fill
    waste    = "Waste",        -- waste tank fill
    fuel     = "Fuel",         -- fuel tank fill
    heated   = "Out buf",      -- heated coolant OUTPUT buffer (steam / hot sodium)
    envLoss  = "Env loss",
    heatRate = "Heat rate",
    boilEff  = "Boil eff.",
    statusActive   = "ONLINE",
    statusDisabled = "OFFLINE",
    chartNow = "Now",
    chartMin = "Min",
    chartMax = "Max",
    -- Turbine
    out         = "Output",
    maxOut      = "Max out",
    energyPct   = "Energy",
    steam       = "Steam",
    dispersers  = "Dispersers",
    vents       = "Vents",
    condensers  = "Condensers",
    prodLabel   = "Prod",
    -- Boiler
    boil      = "Boil",
    maxBoil   = "Max boil",
    water     = "Water",
    cooled    = "Cooled",
    -- Fusion
    plasma    = "Plasma",
    caseTemp  = "Case",
    inject    = "Inject",
    production= "Production",
    deuterium = "Deuterium",
    tritium   = "Tritium",
    dtFuel    = "DT fuel",
    -- Charts
    chartStored = "Stored energy",
    chartTemp   = "Temperature",
    chartProd   = "Production rate",
    chartBoil   = "Boil rate",
    chartPlasma = "Plasma temperature",
    -- Alerts
    alerts        = "Alerts:",
    autoScram     = "AUTO-SCRAM: ",
    latched       = "Latched SCRAM (manual reset required)",
    peripheralErr = "Peripheral error -> SCRAM",
    -- Status messages
    matrixFull   = "Matrix nearly full",
    matrixEmpty  = "Matrix nearly empty",
    steamHigh    = "Steam buffer almost full",
    steamFull    = "Steam buffer full",
    boilerWaterLow = "Boiler water low",
    -- Online messages
    onlineFmt    = "[%s] host '%s' online",
    displayOnline= "Display online. Tabs: ",
    renderErr    = "Render error: ",
    cmdsHelp     = "commands: reset | scram | activate | quit",
    latchedCleared = "Latched SCRAM cleared.",
    scramIssued  = "SCRAM issued.",
    activateIssued = "Activate issued.",
    -- Controls / SCRAM tab
    btnRun       = " RUN ",
    btnScram     = " SCRAM ",
    btnBurnUp    = " B+ ",
    btnBurnDn    = " B- ",
    btnBurnUpBig = " B++ ",
    btnBurnDnBig = " B-- ",
    btnIgnite    = " IGNITE ",
    btnInjUp     = " INJ+ ",
    btnInjDn     = " INJ- ",
    btnReset     = " RESET ",
    btnTestScram = " TEST SCRAM ",
    btnTestAlarm = " TEST ALARM ",
    btnTestChat  = " TEST CHAT ",
    btnAck       = " ACK ",
    btnEnable    = " ON  ",
    btnDisable   = " OFF ",
    btnPlus      = " + ",
    btnMinus     = " - ",
    scramTitle   = "SCRAM rule configuration",
    scramHint    = "Tap ON/OFF to toggle a rule. Tap +/- to adjust trip threshold.",
    scramRule    = "Rule",
    scramTrip    = "Trip",
    scramLast    = "Last trip",
    scramNone    = "No fission or fusion hosts connected.",
    scramLatched = "LATCHED",
    controlsOff  = "Controls disabled (display.cfg allowControl=false)",
}

local Llong = {
    stored = "Stored Energy", capacity = "Total Capacity", fill = "Fill Level",
    input = "Input Rate", output = "Output Rate", net = "Net Flow",
    transferCap = "Transfer Cap", providers = "Providers",
    temp = "Temperature", damage = "Damage", coolant = "Coolant",
    waste = "Waste", fuel = "Fuel", heated = "Output Buffer",
    burn = "Burn Rate", setBurn = "Burn Setpoint", maxBurn = "Max Burn Rate",
    burnPct = "Burn Percent", envLoss = "Environmental Loss",
    heatRate = "Heating Rate", boilEff = "Boil Efficiency",
    energyPct = "Energy Stored", steam = "Steam Buffer",
    boil = "Boil Rate", maxBoil = "Max Boil Rate", cooled = "Cooled Tank",
    plasma = "Plasma Temperature", caseTemp = "Case Temperature",
    inject = "Injection Rate", production = "Power Output",
    deuterium = "Deuterium", tritium = "Tritium", dtFuel = "D-T Fuel",
    out = "Power Output", maxOut = "Max Output",
    chartNow = "Current", chartMin = "Minimum", chartMax = "Maximum",
}

------------------------------------------------------------
-- Units config: Mekanism returns energy in Joules; we display in FE.
------------------------------------------------------------
local function loadUnits()
    local path = "/cfg/units.cfg"
    if not fs.exists(path) then
        if not fs.exists("/cfg") then fs.makeDir("/cfg") end
        local f = fs.open(path, "w")
        f.write("return " .. textutils.serialize({
            -- Mekanism default conversion: 1 FE = 2.5 J  =>  multiply J by 0.4 to get FE.
            -- If your server-side mekanism config changes this ratio, edit here.
            joulesToFE = 0.4,
            -- Display unit suffix (just a label).
            energyUnit = "FE",
            rateUnit   = "FE/t",
        }))
        f.close()
    end
    local ok, cfg = pcall(dofile, path)
    if not ok or type(cfg) ~= "table" then
        return { joulesToFE = 0.4, energyUnit = "FE", rateUnit = "FE/t" }
    end
    return cfg
end
local UNITS = loadUnits()

------------------------------------------------------------
-- protocol
------------------------------------------------------------
local protocol = {}
protocol.PROTOCOL = "mek-atm9"
protocol.VERSION  = 2

function protocol.telemetry(role, host, displayName, data, sev, msgs)
    return { v=2, kind="telemetry", role=role, host=host, displayName=displayName,
             ts=os.epoch("utc"), severity=sev or 0, messages=msgs or {}, data=data or {} }
end
function protocol.command(target, action, args)
    return { v=2, kind="command", target=target, action=action, args=args or {}, ts=os.epoch("utc") }
end
function protocol.openModem()
    for _, side in ipairs(peripheral.getNames()) do
        if peripheral.getType(side) == "modem" then
            local m = peripheral.wrap(side)
            if m.isWireless and m.isWireless() then
                if not rednet.isOpen(side) then rednet.open(side) end
                return side
            end
        end
    end
    for _, side in ipairs(peripheral.getNames()) do
        if peripheral.getType(side) == "modem" then
            if not rednet.isOpen(side) then rednet.open(side) end
            return side
        end
    end
    error("No modem attached. Place a wireless/ender modem on the computer.")
end

------------------------------------------------------------
-- util
------------------------------------------------------------
local util = {}
local SI = { "", "k", "M", "G", "T", "P", "E" }
function util.fmtSI(n, unit, digits)
    n = tonumber(n) or 0; digits = digits or 2; unit = unit or ""
    local sign = n < 0 and "-" or ""; n = math.abs(n)
    local i = 1
    while n >= 1000 and i < #SI do n = n / 1000; i = i + 1 end
    return string.format("%s%." .. digits .. "f %s%s", sign, n, SI[i], unit)
end

-- Mekanism returns Joules; convert to FE for display.
function util.toFE(joules) return (tonumber(joules) or 0) * UNITS.joulesToFE end
function util.fmtEnergy(joules) return util.fmtSI(util.toFE(joules), UNITS.energyUnit) end
function util.fmtRate(joules)   return util.fmtSI(util.toFE(joules), UNITS.rateUnit) end

function util.fmtPercent(p, d) return string.format("%." .. (d or 1) .. "f%%", tonumber(p) or 0) end
function util.fmtTemp(k)    return string.format("%.1f K", tonumber(k) or 0) end
function util.fmtDuration(secs)
    secs = math.floor(tonumber(secs) or 0)
    if secs < 60 then return secs .. "s" end
    if secs < 3600 then return string.format("%dm%02ds", math.floor(secs/60), secs%60) end
    if secs < 86400 then return string.format("%dh%02dm", math.floor(secs/3600), math.floor((secs%3600)/60)) end
    return string.format("%dd%02dh", math.floor(secs/86400), math.floor((secs%86400)/3600))
end
function util.clamp(x, lo, hi) if x < lo then return lo elseif x > hi then return hi end; return x end
function util.colorForPercent(p, lo, hi)
    lo = lo or 25; hi = hi or 75
    if p >= hi then return colors.red elseif p >= lo then return colors.yellow end
    return colors.lime
end
function util.colorForLevel(p, lo, crit)
    lo = lo or 30; crit = crit or 10
    if p <= crit then return colors.red elseif p <= lo then return colors.yellow end
    return colors.lime
end
function util.safe(fn, ...) local ok, v = pcall(fn, ...); if ok then return v end end

-- Mekanism's fissionReactor.getStatus() returns a BOOLEAN (true=active).
-- Fusion reactor returns a string. Normalise both to a friendly label.
function util.fmtStatus(v, activeLabel, disabledLabel)
    activeLabel   = activeLabel   or "ACTIVE"
    disabledLabel = disabledLabel or "DISABLED"
    if v == true  then return activeLabel end
    if v == false then return disabledLabel end
    if type(v) == "string" and #v > 0 then return v:upper() end
    return "?"
end
function util.loadConfig(path, defaults)
    if not fs.exists(path) then
        local dir = fs.getDir(path)
        if dir ~= "" and not fs.exists(dir) then fs.makeDir(dir) end
        local f = fs.open(path, "w"); f.write("return " .. textutils.serialize(defaults)); f.close()
        return defaults
    end
    local ok, cfg = pcall(dofile, path)
    if not ok or type(cfg) ~= "table" then return defaults end
    for k, v in pairs(defaults) do if cfg[k] == nil then cfg[k] = v end end
    return cfg
end
function util.saveConfig(path, cfg)
    local dir = fs.getDir(path)
    if dir ~= "" and not fs.exists(dir) then fs.makeDir(dir) end
    -- Write to a temp file first, then rename. This way a partial write on a full
    -- disk does not corrupt the existing config (which would brick the next boot).
    local data = "return " .. textutils.serialize(cfg)
    local tmp = path .. ".tmp"
    local f = fs.open(tmp, "w"); if not f then return false end
    local ok, err = pcall(function() f.write(data) end)
    f.close()
    if not ok then
        pcall(fs.delete, tmp)
        print(("[saveConfig] write failed for %s: %s (free=%s)")
            :format(path, tostring(err), tostring(fs.getFreeSpace("/"))))
        return false
    end
    pcall(fs.delete, path)
    local rok = pcall(fs.move, tmp, path)
    if not rok then pcall(fs.delete, tmp); return false end
    return true
end
-- Discover available alarm sounds. Returns list of { name=, path=nil|string }, default first.
function util.listAlarms()
    local out = { { name = "default", path = nil } }
    local seen = { default = true }
    for _, dir in ipairs({ "/sounds", "/disk/sounds", "/disk" }) do
        if fs.exists(dir) and fs.isDir(dir) then
            for _, f in ipairs(fs.list(dir)) do
                if type(f) == "string" and f:match("%.dfpwm$") and not fs.isDir(fs.combine(dir, f)) then
                    local name = f:gsub("%.dfpwm$", "")
                    if not seen[name] then
                        seen[name] = true
                        table.insert(out, { name = name, path = fs.combine(dir, f) })
                    end
                end
            end
        end
    end
    return out
end
function util.resolveAlarm(name)
    local list = util.listAlarms()
    for _, a in ipairs(list) do if a.name == name then return a, list end end
    return list[1], list
end
function util.cycleAlarm(name)
    local list = util.listAlarms()
    local idx = 1
    for i, a in ipairs(list) do if a.name == name then idx = i; break end end
    idx = (idx % #list) + 1
    return list[idx].name, list[idx], list
end
function util.readDisplayName(role, fallback)
    local p = "/cfg/displayname.cfg"
    if fs.exists(p) then
        local f = fs.open(p, "r"); local s = f.readAll() or ""; f.close()
        s = s:gsub("%s+$", "")
        if #s > 0 then return s end
    end
    return fallback
end

------------------------------------------------------------
-- ringbuffer
------------------------------------------------------------
local Ring = {}; Ring.__index = Ring
function Ring.new(cap) return setmetatable({ cap=cap, n=0, i=1, buf={} }, Ring) end
function Ring:push(v) self.buf[self.i]=v; self.i=(self.i % self.cap)+1; if self.n<self.cap then self.n=self.n+1 end end
function Ring:values()
    local out = {}
    if self.n < self.cap then
        for k = 1, self.n do out[k] = self.buf[k] end
    else
        local idx = self.i
        for k = 1, self.cap do out[k] = self.buf[idx]; idx = (idx % self.cap) + 1 end
    end
    return out
end

------------------------------------------------------------
-- widgets
------------------------------------------------------------
local W = {}
function W.fillRect(d, x, y, w, h, bg)
    local line = string.rep(" ", w); d.setBackgroundColor(bg or colors.black)
    for i = 0, h - 1 do d.setCursorPos(x, y + i); d.write(line) end
end
function W.border(d, x, y, w, h, fg, bg, title)
    d.setTextColor(fg or colors.white); d.setBackgroundColor(bg or colors.black)
    d.setCursorPos(x, y); d.write("\151" .. string.rep("\140", w - 2) .. "\148")
    d.setCursorPos(x, y + h - 1); d.write("\141" .. string.rep("\140", w - 2) .. "\142")
    for i = 1, h - 2 do
        d.setCursorPos(x, y + i); d.write("\149")
        d.setCursorPos(x + w - 1, y + i); d.write("\149")
    end
    if title then
        local maxLen = w - 4
        if #title > maxLen then title = title:sub(1, maxLen) end
        d.setCursorPos(x + 2, y); d.write(" " .. title .. " ")
    end
end
function W.vBar(d, x, y, h, val, max, fc, bc)
    fc = fc or colors.lime; bc = bc or colors.gray
    local frac = (max and max > 0) and util.clamp(val / max, 0, 1) or 0
    local filled = math.floor(frac * h + 0.5)
    for i = 0, h - 1 do
        d.setCursorPos(x, y + (h - 1 - i))
        d.setBackgroundColor(i < filled and fc or bc); d.write(" ")
    end
    d.setBackgroundColor(colors.black)
end
function W.sparkline(d, x, y, w, h, values, color)
    color = color or colors.cyan
    local n = #values; if n == 0 then return end
    local lo, hi = math.huge, -math.huge
    for _, v in ipairs(values) do if v < lo then lo = v end; if v > hi then hi = v end end
    if hi <= lo then hi = lo + 1 end
    local start = math.max(1, n - w + 1)
    W.fillRect(d, x, y, w, h, colors.black)
    for i = 0, w - 1 do
        local idx = start + i
        if idx <= n then
            local frac = (values[idx] - lo) / (hi - lo)
            local filled = math.floor(frac * h + 0.5)
            for row = 0, h - 1 do
                if (h - 1 - row) < filled then
                    d.setCursorPos(x + i, y + row)
                    d.setBackgroundColor(color); d.write(" ")
                end
            end
        end
    end
    d.setBackgroundColor(colors.black)
end
function W.centerText(d, x, y, w, t, fg, bg)
    d.setTextColor(fg or colors.white); d.setBackgroundColor(bg or colors.black)
    local pad = math.max(0, math.floor((w - #t) / 2))
    d.setCursorPos(x + pad, y); d.write(t)
end
function W.kv(d, x, y, w, k, v, vc)
    d.setBackgroundColor(colors.black); d.setTextColor(colors.lightGray)
    d.setCursorPos(x, y); d.write(k)
    d.setTextColor(vc or colors.white); local s = tostring(v)
    d.setCursorPos(x + w - #s, y); d.write(s)
end

------------------------------------------------------------
-- HOSTS
------------------------------------------------------------
local function hostInduction()
    local cfg = util.loadConfig("/cfg/induction.cfg", {
        pollInterval=0.5, broadcastEvery=1, hostName="induction-1",
        warnFullPct=95, warnLowPct=5,
    })
    local dn = util.readDisplayName("induction", cfg.hostName)
    protocol.openModem()
    local port = findPeripheralRetry("inductionPort")
    -- NOTE: getEnergy/getMaxEnergy/getLastInput/getLastOutput/getTransferCap return JOULES.
    --       Display layer converts via util.toFE. We store raw J in `data` so the display
    --       (single source of truth) does the conversion.
    local function poll()
        local energy    = util.safe(port.getEnergy)        or 0
        local maxEnergy = util.safe(port.getMaxEnergy)     or 1
        local pct       = util.safe(port.getEnergyFilledPercentage)
        if pct == nil then pct = (energy / maxEnergy) * 100
        elseif pct <= 1 then pct = pct * 100 end
        local input  = util.safe(port.getLastInput)  or 0
        local output = util.safe(port.getLastOutput) or 0
        local cells  = util.safe(port.getInstalledCells) or 0
        local provs  = util.safe(port.getInstalledProviders) or 0
        local cap    = util.safe(port.getTransferCap) or 0
        local sev, msgs = 0, {}
        if pct >= cfg.warnFullPct then sev=1; msgs={ L.matrixFull }
        elseif pct <= cfg.warnLowPct then sev=2; msgs={ L.matrixEmpty } end
        return { energy=energy, maxEnergy=maxEnergy, pct=pct, input=input, output=output,
                 cells=cells, providers=provs, transferCap=cap, net=input - output }, sev, msgs
    end
    print((L.onlineFmt):format("induction", dn))
    local function pollLoop()
        local tick = 0
        while true do
            local ok, data, sev, msgs = pcall(poll)
            if not ok then sev, msgs, data = 2, { "Peripheral error: " .. tostring(data) }, {} end
            tick = tick + 1
            if tick % cfg.broadcastEvery == 0 then
                rednet.broadcast(protocol.telemetry("induction", cfg.hostName, dn, data, sev, msgs), protocol.PROTOCOL)
            end
            sleep(cfg.pollInterval)
        end
    end
    parallel.waitForAny(pollLoop, makeCmdListener(cfg))
end

local FISSION_RULE_DEFAULTS = {
    { id="temp",    enabled=true, op=">", field="temp",    threshold=1200, label="Temp",    unit="K", latch=false, step=20 },
    { id="damage",  enabled=true, op=">", field="damage",  threshold=50,   label="Damage",  unit="%", latch=true,  step=5  },
    { id="coolant", enabled=true, op="<", field="coolPct", threshold=10,   label="Coolant", unit="%", latch=false, step=5  },
    { id="waste",   enabled=true, op=">", field="wastePct",threshold=90,   label="Waste",   unit="%", latch=false, step=5  },
}
local FUSION_RULE_DEFAULTS = {
    { id="plasma", enabled=true, op=">", field="plasmaTemp", threshold=1.0e9, label="Plasma", unit="K", latch=false, step=5e7 },
    { id="case",   enabled=true, op=">", field="caseTemp",   threshold=1.0e8, label="Case",   unit="K", latch=false, step=5e6 },
    { id="water",  enabled=true, op="<", field="waterPct",   threshold=10,    label="Water",  unit="%", latch=false, step=5   },
}
local function evalRules(rules, s)
    -- SAFETY GATE: only evaluate trip rules when the reactor is actually running.
    -- When status==false (off) or status==nil (peripheral not yet ready, e.g. just after
    -- a server reboot) we MUST NOT scram on default-zero readings (coolant=0, fuel=0).
    if s.status ~= true then return nil end
    for _, ru in ipairs(rules) do
        if ru.enabled then
            local v = s[ru.field]
            if type(v) == "number" then
                local trip = (ru.op == ">" and v > ru.threshold) or (ru.op == "<" and v < ru.threshold)
                if trip then return ru, ("%s %s %s%s (%s%s)"):format(ru.label, ru.op, tostring(ru.threshold), ru.unit or "", string.format("%.1f", v), ru.unit or "") end
            end
        end
    end
    return nil
end
local function saveScramCfg(path, rules)
    local f = fs.open(path, "w"); if not f then return end
    f.writeLine("return {"); f.writeLine("  rules = {")
    for _, ru in ipairs(rules) do
        f.writeLine(("    { id=%q, enabled=%s, op=%q, field=%q, threshold=%s, label=%q, unit=%q, latch=%s, step=%s },"):format(
            ru.id, tostring(ru.enabled), ru.op, ru.field, tostring(ru.threshold), ru.label, ru.unit or "",
            tostring(ru.latch), tostring(ru.step or 1)))
    end
    f.writeLine("  },"); f.writeLine("}"); f.close()
end
local function deepCopyRules(src)
    local out = {}; for i, ru in ipairs(src) do
        out[i] = { id=ru.id, enabled=ru.enabled, op=ru.op, field=ru.field, threshold=ru.threshold, label=ru.label, unit=ru.unit, latch=ru.latch, step=ru.step or 1 }
    end; return out
end

-- Find a peripheral by type name, retrying every 2s instead of failing hard. After
-- a server restart the wired-modem network can take a few seconds to re-attach all
-- peripherals; without this hosts would error() and stay dead until manually
-- rebooted, which is exactly the failure mode we are trying to fix.
local function findPeripheralRetry(typeName)
    local p = peripheral.find(typeName)
    if p then return p end
    print(("[host] peripheral '%s' not found yet, retrying every 2s..."):format(typeName))
    while not p do
        sleep(2)
        p = peripheral.find(typeName)
    end
    print(("[host] peripheral '%s' attached, continuing."):format(typeName))
    return p
end

-- Universal command listener used by every host loop. Handles reboot uniformly so
-- the display can recover stuck hosts; per-role actions are forwarded to extra(msg).
local function makeCmdListener(cfg, extra)
    return function()
        while true do
            local _, msg = rednet.receive(protocol.PROTOCOL)
            if type(msg) == "table" and msg.kind == "command" and msg.target == cfg.hostName then
                if msg.action == "reboot" then
                    print("[host] reboot command received -> os.reboot()")
                    sleep(0.2)  -- let the print flush; broadcast already sent.
                    os.reboot()
                elseif msg.action == "ping" then
                    -- no-op, just keeps the host responsive in tests
                elseif extra then
                    pcall(extra, msg)
                end
            end
        end
    end
end

-- Shared audio player. Returns { queue=fn, loop=fn } for use in parallel.waitForAny.
local function makeAudioPlayer(speaker)
    local q = {}
    local function queue(path) if path then table.insert(q, path); os.queueEvent("audio_play_request") end end
    local function loop()
        local ok, dfpwm = pcall(require, "cc.audio.dfpwm")
        if not ok or not speaker then
            while true do os.pullEvent("audio_play_request") end
        end
        while true do
            if #q == 0 then os.pullEvent("audio_play_request") end
            local path = table.remove(q, 1)
            if path and fs.exists(path) then
                local decoder = dfpwm.make_decoder()
                local h = fs.open(path, "rb")
                if h then
                    while true do
                        local chunk = h.read(16 * 1024)
                        if not chunk then break end
                        local audio = decoder(chunk)
                        while not speaker.playAudio(audio, 3) do
                            os.pullEvent("speaker_audio_empty")
                        end
                    end
                    h.close()
                end
            end
        end
    end
    return { queue = queue, loop = loop }
end

local function hostFission()
    local cfg = util.loadConfig("/cfg/fission.cfg", {
        pollInterval=0.5, broadcastEvery=1, hostName="fission-1", alarmName="default",
    })
    local SCRAM_PATH = "/cfg/scram.cfg"
    local scramCfg = util.loadConfig(SCRAM_PATH, { rules = deepCopyRules(FISSION_RULE_DEFAULTS) })
    if type(scramCfg.rules) ~= "table" or #scramCfg.rules == 0 then scramCfg.rules = deepCopyRules(FISSION_RULE_DEFAULTS) end
    local dn = util.readDisplayName("fission", cfg.hostName)
    protocol.openModem()
    local r = findPeripheralRetry("fissionReactorLogicAdapter")
    local speaker = peripheral.find("speaker")
    local audio = makeAudioPlayer(speaker)
    local function playAlarm()
        if not speaker then return end
        local resolved = util.resolveAlarm(cfg.alarmName)
        if resolved.path then audio.queue(resolved.path)
        else pcall(speaker.playSound, "minecraft:block.beacon.deactivate", 3, 0.5) end
    end
    local latched, lastTrip = false, nil
    local function pct(v) if v and v <= 1 then return v*100 end; return v or 0 end
    local function readState()
        local s = {
            status=util.safe(r.getStatus),
            temp=util.safe(r.getTemperature) or 0,
            damage=util.safe(r.getDamagePercent) or 0,
            burn=util.safe(r.getBurnRate) or 0,
            actBurn=util.safe(r.getActualBurnRate) or 0,
            maxBurn=util.safe(r.getMaxBurnRate) or 0,
            coolPct=pct(util.safe(r.getCoolantFilledPercentage)),
            heatPct=pct(util.safe(r.getHeatedCoolantFilledPercentage)),
            fuelPct=pct(util.safe(r.getFuelFilledPercentage)),
            wastePct=pct(util.safe(r.getWasteFilledPercentage)),
            -- Extra metrics (may be nil on older Mekanism builds)
            envLoss=util.safe(r.getEnvironmentalLoss) or 0,        -- heat lost to environment
            heatRate=util.safe(r.getHeatingRate) or 0,             -- mB/t coolant heated
            boilEff=util.safe(r.getBoilEfficiency),                -- 0..1 thermal efficiency
            fuel=util.safe(r.getFuel) or 0,
            fuelCap=util.safe(r.getFuelCapacity) or 0,
            waste=util.safe(r.getWaste) or 0,
            wasteCap=util.safe(r.getWasteCapacity) or 0,
            coolant=util.safe(r.getCoolant) or 0,
            coolantCap=util.safe(r.getCoolantCapacity) or 0,
        }
        if s.damage and s.damage <= 1 then s.damage = s.damage * 100 end
        return s
    end
    local function evaluate(s)
        local sev, msgs = 0, {}
        local trip, why = evalRules(scramCfg.rules, s)
        if trip then
            sev = 3; lastTrip = { rule=trip.id, why=why, ts=os.epoch("utc") }
            if trip.latch then latched = true end
            table.insert(msgs, L.autoScram .. why); pcall(r.scram)
            playAlarm()
        elseif latched then sev = 3; table.insert(msgs, L.latched); pcall(r.scram) end
        s.scramCfg = scramCfg.rules; s.lastTrip = lastTrip; s.latched = latched
        return sev, msgs
    end
    local function pollLoop()
        print((L.onlineFmt):format("fission", dn))
        local tick = 0
        while true do
            local ok, s = pcall(readState); local sev, msgs
            if not ok then pcall(r.scram); sev, msgs, s = 3, { L.peripheralErr }, {}
            else sev, msgs = evaluate(s) end
            tick = tick + 1
            if tick % cfg.broadcastEvery == 0 then
                rednet.broadcast(protocol.telemetry("fission", cfg.hostName, dn, s, sev, msgs), protocol.PROTOCOL)
            end
            sleep(cfg.pollInterval)
        end
    end
    local function rednetLoop()
        while true do
            local _, msg = rednet.receive(protocol.PROTOCOL)
            if type(msg) == "table" and msg.kind == "command" and msg.target == cfg.hostName then
                if msg.action == "reboot" then
                    print("[fission] reboot cmd received -> os.reboot()"); sleep(0.2); os.reboot()
                elseif msg.action == "scram" then pcall(r.scram); print("[fission] scram cmd received")
                elseif msg.action == "activate" and not latched then pcall(r.activate); print("[fission] activate cmd received")
                elseif msg.action == "setBurnRate" then
                    local x = tonumber(msg.args and msg.args.rate)
                    if x then
                        local maxB = util.safe(r.getMaxBurnRate) or x
                        if x > maxB then
                            print(("[fission] setBurnRate %s mB/t requested but max is %s, clamping"):format(tostring(x), tostring(maxB)))
                            x = maxB
                        end
                        if x < 0 then x = 0 end
                        pcall(r.setBurnRate, x); print(("[fission] setBurnRate %s mB/t"):format(tostring(x)))
                    end
                elseif msg.action == "reset" then latched = false; lastTrip = nil; print("[fission] reset (latch cleared)")
                elseif msg.action == "testScram" then
                    pcall(r.scram); lastTrip = { rule="test", why="Manual test", ts=os.epoch("utc") }
                    playAlarm()
                elseif msg.action == "updateScramCfg" and type(msg.args) == "table" and type(msg.args.rules) == "table" then
                    scramCfg.rules = msg.args.rules; saveScramCfg(SCRAM_PATH, scramCfg.rules)
                elseif msg.action == "setAlarm" and type(msg.args) == "table" and type(msg.args.name) == "string" then
                    cfg.alarmName = msg.args.name; util.saveConfig("/cfg/fission.cfg", cfg)
                end
            end
        end
    end
    local function termLoop()
        while true do
            write("> "); local line = read()
            if line == "reset" then latched=false; print(L.latchedCleared)
            elseif line == "scram" then pcall(r.scram); print(L.scramIssued)
            elseif line == "activate" then pcall(r.activate); print(L.activateIssued)
            elseif line == "quit" then return
            else print(L.cmdsHelp) end
        end
    end
    parallel.waitForAny(pollLoop, rednetLoop, termLoop, audio.loop)
end

local function hostTurbine()
    local cfg = util.loadConfig("/cfg/turbine.cfg", { pollInterval=0.5, broadcastEvery=1, hostName="turbine-1", warnSteamHigh=95 })
    local dn = util.readDisplayName("turbine", cfg.hostName)
    protocol.openModem()
    local t = findPeripheralRetry("turbineValve")
    local function pct(v) if v and v <= 1 then return v*100 end; return v or 0 end
    print((L.onlineFmt):format("turbine", dn))
    local function pollLoop()
        local tick = 0
        while true do
            -- All energy fields below are JOULES; converted to FE on the display layer.
            local ok, s = pcall(function()
                return {
                    energy=util.safe(t.getEnergy) or 0, maxEnergy=util.safe(t.getMaxEnergy) or 1,
                    energyPct=pct(util.safe(t.getEnergyFilledPercentage)),
                    prod=util.safe(t.getProductionRate) or 0, maxProd=util.safe(t.getMaxProduction) or 0,
                    steam=util.safe(t.getSteam) or 0, steamPct=pct(util.safe(t.getSteamFilledPercentage)),
                    flowRate=util.safe(t.getLastSteamInputRate) or 0,
                    dispersers=util.safe(t.getDispersers) or 0,
                    vents=util.safe(t.getVents) or 0,
                    condensers=util.safe(t.getCondensers) or 0,
                }
            end)
            local sev, msgs = 0, {}
            if not ok then sev, msgs, s = 2, { "Peripheral error: " .. tostring(s) }, {}
            elseif s.steamPct >= 99 then sev, msgs = 2, { L.steamFull or "Steam buffer full" }
            elseif s.steamPct > cfg.warnSteamHigh then sev, msgs = 2, { L.steamHigh } end
            tick = tick + 1
            if tick % cfg.broadcastEvery == 0 then
                rednet.broadcast(protocol.telemetry("turbine", cfg.hostName, dn, s, sev, msgs), protocol.PROTOCOL)
            end
            sleep(cfg.pollInterval)
        end
    end
    parallel.waitForAny(pollLoop, makeCmdListener(cfg))
end

local function hostBoiler()
    local cfg = util.loadConfig("/cfg/boiler.cfg", { pollInterval=0.5, broadcastEvery=1, hostName="boiler-1", warnWaterLow=15 })
    local dn = util.readDisplayName("boiler", cfg.hostName)
    protocol.openModem()
    local b = findPeripheralRetry("boilerValve")
    local function pct(v) if v and v <= 1 then return v*100 end; return v or 0 end
    print((L.onlineFmt):format("boiler", dn))
    local function pollLoop()
        local tick = 0
        while true do
            local ok, s = pcall(function()
                return {
                    temp=util.safe(b.getTemperature) or 0,
                    boilRate=util.safe(b.getBoilRate) or 0, maxBoilRate=util.safe(b.getMaxBoilRate) or 0,
                    water=util.safe(b.getWater) or 0, waterPct=pct(util.safe(b.getWaterFilledPercentage)),
                    steam=util.safe(b.getSteam) or 0, steamPct=pct(util.safe(b.getSteamFilledPercentage)),
                    heated=util.safe(b.getHeatedCoolant) or 0, heatedPct=pct(util.safe(b.getHeatedCoolantFilledPercentage)),
                    cooledPct=pct(util.safe(b.getCooledCoolantFilledPercentage)),
                }
            end)
            local sev, msgs = 0, {}
            if not ok then sev, msgs, s = 2, { "Peripheral error: " .. tostring(s) }, {}
            elseif s.waterPct < cfg.warnWaterLow then sev, msgs = 2, { L.boilerWaterLow } end
            tick = tick + 1
            if tick % cfg.broadcastEvery == 0 then
                rednet.broadcast(protocol.telemetry("boiler", cfg.hostName, dn, s, sev, msgs), protocol.PROTOCOL)
            end
            sleep(cfg.pollInterval)
        end
    end
    parallel.waitForAny(pollLoop, makeCmdListener(cfg))
end

local function hostFusion()
    local cfg = util.loadConfig("/cfg/fusion.cfg", {
        pollInterval=0.5, broadcastEvery=1, hostName="fusion-1", warnFraction=0.85, alarmName="default",
    })
    local SCRAM_PATH = "/cfg/scram.cfg"
    local scramCfg = util.loadConfig(SCRAM_PATH, { rules = deepCopyRules(FUSION_RULE_DEFAULTS) })
    if type(scramCfg.rules) ~= "table" or #scramCfg.rules == 0 then scramCfg.rules = deepCopyRules(FUSION_RULE_DEFAULTS) end
    local dn = util.readDisplayName("fusion", cfg.hostName)
    protocol.openModem()
    local r = findPeripheralRetry("fusionReactorLogicAdapter")
    local speaker = peripheral.find("speaker")
    local audio = makeAudioPlayer(speaker)
    local function playAlarm()
        if not speaker then return end
        local resolved = util.resolveAlarm(cfg.alarmName)
        if resolved.path then audio.queue(resolved.path)
        else pcall(speaker.playSound, "minecraft:block.beacon.deactivate", 3, 0.5) end
    end
    local lastTrip = nil
    local function pct(v) if v and v <= 1 then return v*100 end; return v or 0 end
    local function readf()
        return {
            status=util.safe(r.getStatus),
            plasmaTemp=util.safe(r.getPlasmaTemperature) or 0,
            caseTemp=util.safe(r.getCaseTemperature) or 0,
            injection=util.safe(r.getInjectionRate) or 0,
            prod=util.safe(r.getProductionRate) or 0,  -- Joules/t
            deuteriumPct=pct(util.safe(r.getDeuteriumFilledPercentage)),
            tritiumPct=pct(util.safe(r.getTritiumFilledPercentage)),
            dtFuelPct=pct(util.safe(r.getDTFuelFilledPercentage)),
            waterPct=pct(util.safe(r.getWaterFilledPercentage)),
            steamPct=pct(util.safe(r.getSteamFilledPercentage)),
        }
    end
    local function eval(s)
        local sev, msgs = 0, {}
        local trip, why = evalRules(scramCfg.rules, s)
        if trip then
            sev = 3; lastTrip = { rule=trip.id, why=why, ts=os.epoch("utc") }
            table.insert(msgs, L.autoScram .. why); pcall(r.scram)
            playAlarm()
        end
        s.scramCfg = scramCfg.rules; s.lastTrip = lastTrip
        return sev, msgs
    end
    local function pollLoop()
        print((L.onlineFmt):format("fusion", dn))
        local tick = 0
        while true do
            local ok, s = pcall(readf); local sev, msgs
            if not ok then pcall(r.scram); sev, msgs, s = 3, { L.peripheralErr }, {}
            else sev, msgs = eval(s) end
            tick = tick + 1
            if tick % cfg.broadcastEvery == 0 then
                rednet.broadcast(protocol.telemetry("fusion", cfg.hostName, dn, s, sev, msgs), protocol.PROTOCOL)
            end
            sleep(cfg.pollInterval)
        end
    end
    local function rednetLoop()
        while true do
            local _, msg = rednet.receive(protocol.PROTOCOL)
            if type(msg) == "table" and msg.kind == "command" and msg.target == cfg.hostName then
                if msg.action == "reboot" then
                    print("[fusion] reboot cmd received -> os.reboot()"); sleep(0.2); os.reboot()
                elseif msg.action == "scram" then pcall(r.scram)
                elseif msg.action == "activate" then pcall(r.activate)
                elseif msg.action == "setInjectionRate" then local x=tonumber(msg.args and msg.args.rate); if x then pcall(r.setInjectionRate, x) end
                elseif msg.action == "reset" then lastTrip = nil
                elseif msg.action == "testScram" then
                    pcall(r.scram); lastTrip = { rule="test", why="Manual test", ts=os.epoch("utc") }
                    playAlarm()
                elseif msg.action == "updateScramCfg" and type(msg.args) == "table" and type(msg.args.rules) == "table" then
                    scramCfg.rules = msg.args.rules; saveScramCfg(SCRAM_PATH, scramCfg.rules)
                elseif msg.action == "setAlarm" and type(msg.args) == "table" and type(msg.args.name) == "string" then
                    cfg.alarmName = msg.args.name; util.saveConfig("/cfg/fusion.cfg", cfg)
                end
            end
        end
    end
    parallel.waitForAny(pollLoop, rednetLoop, audio.loop)
end

------------------------------------------------------------
-- DISPLAY
------------------------------------------------------------
local PANEL_METRICS = {
    -- induction
    { role="induction", field="energy",     label="Stored",       fmt="energy",  color=colors.cyan    },
    { role="induction", field="pct",        label="Fill %",       fmt="percent", color=colors.cyan    },
    { role="induction", field="input",      label="Input",        fmt="rate",    color=colors.lime    },
    { role="induction", field="output",     label="Output",       fmt="rate",    color=colors.orange  },
    { role="induction", field="net",        label="Net Flow",     fmt="rate",    color=colors.lime    },
    -- fission
    { role="fission",   field="temp",       label="Fission Temp", fmt="temp",    color=colors.orange  },
    { role="fission",   field="damage",     label="Damage %",     fmt="percent", color=colors.red     },
    { role="fission",   field="actBurn",    label="Burn Rate",    fmt="mbpt",    color=colors.cyan    },
    { role="fission",   field="coolPct",    label="Coolant %",    fmt="percent", color=colors.cyan    },
    { role="fission",   field="wastePct",   label="Waste %",      fmt="percent", color=colors.yellow  },
    { role="fission",   field="fuelPct",    label="Fuel %",       fmt="percent", color=colors.lime    },
    -- turbine
    { role="turbine",   field="prod",       label="Turbine Out",  fmt="rate",    color=colors.lime    },
    { role="turbine",   field="energyPct",  label="Buffer %",     fmt="percent", color=colors.cyan    },
    { role="turbine",   field="steamPct",   label="Steam %",      fmt="percent", color=colors.white   },
    -- boiler
    { role="boiler",    field="temp",       label="Boiler Temp",  fmt="temp",    color=colors.orange  },
    { role="boiler",    field="boilRate",   label="Boil Rate",    fmt="mbpt",    color=colors.orange  },
    { role="boiler",    field="waterPct",   label="Water %",      fmt="percent", color=colors.cyan    },
    -- fusion
    { role="fusion",    field="plasmaTemp", label="Plasma Temp",  fmt="temp",    color=colors.magenta },
    { role="fusion",    field="caseTemp",   label="Case Temp",    fmt="temp",    color=colors.orange  },
    { role="fusion",    field="dtFuelPct",  label="D-T Fuel %",   fmt="percent", color=colors.lime    },
    { role="fusion",    field="prod",       label="Fusion Out",   fmt="rate",    color=colors.lime    },
}

-- Subnautica-style PA voice lines. RU-only (per operator preference).
-- See VOICE_LINES.md for the full catalog and trigger conditions.
-- Each entry: { id, category, sev (1=info/2=warn/3=critical), ru = phrase }.
-- The audio file must be placed at "/voice/<id>.dfpwm" on the display PC.
-- If the file is missing, the line still fires the chat notification (when enabled).
local VOICE_LINES = {
    -- Induction matrix
    { id="matrix_full",            category="induction", sev=1, ru="Индукционная матрица полностью заряжена." },
    { id="matrix_high_95",         category="induction", sev=1, ru="Индукционная матрица заряжена на девяносто пять процентов." },
    { id="matrix_low_25",          category="induction", sev=1, ru="Внимание: индукционная матрица ниже двадцати пяти процентов." },
    { id="matrix_low_10",          category="induction", sev=2, ru="Осторожно: индукционная матрица в критическом состоянии, осталось десять процентов." },
    { id="matrix_empty",           category="induction", sev=3, ru="Индукционная матрица истощена." },
    { id="matrix_input_lost",      category="induction", sev=2, ru="Прекращена подача энергии в индукционную матрицу." },
    { id="matrix_output_overload", category="induction", sev=2, ru="Выходная мощность индукционной матрицы близка к пределу передачи." },
    { id="matrix_net_negative",    category="induction", sev=1, ru="Чистый энергобаланс отрицательный." },
    { id="matrix_net_positive",    category="induction", sev=1, ru="Чистый энергобаланс восстановлен." },
    -- Fission reactor
    { id="fission_started",        category="fission",   sev=1, ru="Реактор деления включён." },
    { id="fission_stopped",        category="fission",   sev=1, ru="Реактор деления выключен." },
    { id="fission_scram_auto",     category="fission",   sev=3, ru="Аварийное отключение активировано. Реактор останавливается." },
    { id="fission_scram_manual",   category="fission",   sev=2, ru="Ручное аварийное отключение принято." },
    { id="fission_temp_warn",      category="fission",   sev=2, ru="Внимание: высокая температура реактора." },
    { id="fission_temp_crit",      category="fission",   sev=3, ru="Критическая температура реактора." },
    { id="fission_damage_warn",    category="fission",   sev=2, ru="Обнаружены повреждения корпуса реактора." },
    { id="fission_damage_crit",    category="fission",   sev=3, ru="Критическое повреждение реактора, приближается порог отключения." },
    { id="fission_coolant_low",    category="fission",   sev=2, ru="Низкий уровень теплоносителя." },
    { id="fission_coolant_crit",   category="fission",   sev=3, ru="Критическое падение теплоносителя." },
    { id="fission_fuel_low",       category="fission",   sev=2, ru="Низкий запас делящегося топлива." },
    { id="fission_fuel_crit",      category="fission",   sev=2, ru="Критическое падение запаса топлива." },
    { id="fission_waste_60",       category="fission",   sev=1, ru="Внимание: хранилище отходов заполнено на шестьдесят процентов." },
    { id="fission_waste_80",       category="fission",   sev=2, ru="Внимание: хранилище отходов заполнено на восемьдесят процентов." },
    { id="fission_waste_full",     category="fission",   sev=3, ru="Критическое заполнение отходов, неминуемо аварийное отключение." },
    { id="fission_burn_max",       category="fission",   sev=1, ru="Реактор работает на максимальной мощности." },
    { id="fission_burn_zero",      category="fission",   sev=1, ru="Реактор работает на нулевой мощности." },
    { id="fission_latched",        category="fission",   sev=2, ru="Аварийная блокировка реактора. Требуется ручной сброс." },
    { id="fission_fuel_autostop",  category="fission",   sev=2, ru="Внимание! Количество топлива ядерного реактора ниже критической отметки. Производится отключение всех реакторных систем до стабилизации состояния." },
    -- Turbine
    { id="turbine_steam_high",     category="turbine",   sev=2, ru="Паровой буфер турбины близок к заполнению." },
    { id="turbine_steam_full",     category="turbine",   sev=3, ru="Критическое заполнение парового буфера турбины." },
    { id="turbine_energy_full",    category="turbine",   sev=1, ru="Энергобуфер турбины полон." },
    { id="turbine_low_output",     category="turbine",   sev=2, ru="Выходная мощность турбины ниже десяти процентов от максимума." },
    { id="turbine_offline",        category="turbine",   sev=2, ru="Связь с турбиной потеряна." },
    { id="turbine_back_online",    category="turbine",   sev=1, ru="Связь с турбиной восстановлена." },
    -- Boiler
    { id="boiler_water_low",       category="boiler",    sev=2, ru="Низкий уровень воды в бойлере." },
    { id="boiler_water_crit",      category="boiler",    sev=3, ru="Критическое падение уровня воды в бойлере." },
    { id="boiler_steam_full",      category="boiler",    sev=2, ru="Паровой буфер бойлера близок к заполнению." },
    { id="boiler_heated_full",     category="boiler",    sev=2, ru="Буфер нагретого теплоносителя бойлера близок к заполнению." },
    { id="boiler_temp_high",       category="boiler",    sev=2, ru="Высокая температура бойлера." },
    -- Fusion
    { id="fusion_ignited",         category="fusion",    sev=1, ru="Термоядерный реактор активирован." },
    { id="fusion_offline",         category="fusion",    sev=1, ru="Термоядерный реактор остановлен." },
    { id="fusion_scram_auto",      category="fusion",    sev=3, ru="Аварийное отключение термоядерного реактора." },
    { id="fusion_plasma_warn",     category="fusion",    sev=2, ru="Высокая температура плазмы." },
    { id="fusion_plasma_crit",     category="fusion",    sev=3, ru="Критическая температура плазмы." },
    { id="fusion_case_warn",       category="fusion",    sev=2, ru="Высокая температура корпуса." },
    { id="fusion_dt_low",          category="fusion",    sev=2, ru="Низкий запас дейтерий-тритиевого топлива." },
    { id="fusion_water_low",       category="fusion",    sev=2, ru="Низкий уровень воды термоядерного реактора." },
    -- System / network
    { id="system_startup",         category="system",    sev=1, ru="Система мониторинга включена." },
    { id="system_host_lost",       category="system",    sev=2, ru="Потеряна связь с устройством." },
    { id="system_host_back",       category="system",    sev=1, ru="Связь с устройством восстановлена." },
    { id="system_host_reboot",     category="system",    sev=2, ru="Узел не отвечает. Отправлена команда перезагрузки." },
    { id="system_host_reboot_ok", category="system",    sev=1, ru="Узел перезагружен и снова на связи." },
    { id="system_host_reboot_fail",category="system",    sev=3, ru="Узел не отвечает после перезагрузки. Требуется ручная проверка." },
    { id="system_host_reboot_manual",category="system",  sev=1, ru="Перезагрузка узла отправлена оператором." },
    { id="system_auto_throttle",   category="system",    sev=1, ru="Скорость деления автоматически изменена." },
    { id="system_auto_restart",    category="system",    sev=2, ru="Автоматический перезапуск активирован." },
    { id="system_alarm_test",      category="system",    sev=1, ru="Тест системы оповещения." },
    -- Test / easter eggs
    { id="test_voice",             category="test",      sev=1, ru="Проверка системы оповещения, все системы в норме." },
    { id="easter_overcharge",      category="test",      sev=1, ru="Похоже, у нас полно энергии. Самое время заварить кофе." },
}

local VOICE_BY_ID = {}; for _, ln in ipairs(VOICE_LINES) do VOICE_BY_ID[ln.id] = ln end
local VOICE_CATEGORIES = { "induction", "fission", "turbine", "boiler", "fusion", "system", "test" }

local function display()
    local cfg = util.loadConfig("/cfg/display.cfg", {
        monitorScale=0.5, refreshHz=5, sparkPoints=120, speakerOnWarn=true,
        allowControl=true, wideThreshold=60, narrowThreshold=50, stackedThreshold=30,
        burnStep=2, burnStepBig=10, injectionStep=2,
        alarmName="default",
        profile="full",
        soloRole="fission", soloHost="fission-1",
        panelRole="induction", panelHost="induction-1", panelField="energy",
        panelLabel="", panelColor="lime", panelScale=1.5,
        -- system SCRAM rules
        scramOnMatrixFull=true, matrixFullThreshold=99.8,
        warnOnMatrixLow=true,  matrixLowThreshold=10.0,
        -- chat notifications (uses Advanced Peripherals chatBox if present, or HTTP webhook)
        chatNotify=false, chatPrefix="[MEK]", chatMinSeverity=2, webhookUrl="",
        -- (fissionPresets removed -- use B+/B- to adjust burn rate manually)
        -- auto burn-rate throttle (P-controller toward target storage %)
        autoThrottle=false, throttleTarget=80, throttleEvery=5, throttleStep=0.5, throttleSlack=1,
        -- auto-restart after SCRAM (re-activate fission once storage drops below target)
        autoRestart=false, autoRestartBelow=85, autoRestartDelay=30,
        -- auto-stop reactor when fuel is just above the SCRAM-rule crit (default 5%)
        lowFuelAutoStop=false, lowFuelStopThreshold=6,
        -- remote reboot of silent hosts. The display broadcasts a `reboot` command
        -- after `autoRebootSilent` seconds without telemetry, then waits another
        -- `autoRebootSilent` seconds. If the host is still silent, it gives up
        -- (one attempt only) and plays system_host_reboot_fail. autoReboot=false
        -- disables the automatic attempt; manual reboot from the UI still works.
        autoReboot=true, autoRebootSilent=120,
        rebootPanelOpen=false, rebootPage=1, rebootPerPage=8,
        -- production history (CSV log + History tab). Default keep lowered from
        -- 1440 to 720 -- with five hosts at 60s intervals, 1440 rows is ~580 KB
        -- which is enough to fill a CC computer's disk and lock the operator out
        -- of the cfg writes that toggling buttons trigger.
        historyEnabled=true, historyEvery=60, historyKeep=720,
        -- forecast on overview cards (time-to-empty / time-to-full)
        forecastEnabled=true,
        -- induction I/O smoothing (EMA): hides single-tick spikes in input/output.
        -- alpha = how much weight to give the new sample. 0.1 = very smooth/laggy,
        -- 0.5 = lightly smoothed. Set smoothInduction=false to disable.
        smoothInduction=true, smoothAlpha=0.25,
        -- named burn-rate presets per fission reactor (mB/t)  [REMOVED -- presets are gone]
        -- fissionPresets unused; kept here only as a doc breadcrumb.
        -- voice / PA system (Subnautica-style). RU only.
        voiceFolder="/voice/ru/", voicePanelOpen=false, voicePage=1, voicePerPage=8,
        voiceDefaultVolume=2.5, voiceDefaultCooldown=60,
        voice={},  -- per-line: { enabled, volume, cooldown }; auto-populated from VOICE_LINES
    })
    protocol.openModem()
    local mon = peripheral.find("monitor")
    if not mon then error("No monitor attached to the wired modem network.") end
    mon.setTextScale(cfg.profile == "panel" and (cfg.panelScale or 1.5) or cfg.monitorScale)
    mon.setBackgroundColor(colors.black); mon.clear()
    -- Adaptive labels: pick long labels on wide monitors.
    local _W0 = ({mon.getSize()})[1]
    local IS_WIDE = _W0 >= cfg.wideThreshold
    local IS_NARROW = _W0 < (cfg.narrowThreshold or 50)
    local STACKED   = _W0 < (cfg.stackedThreshold or 30)
    if IS_WIDE then
        for k, v in pairs(Llong) do L[k] = v end
    end
    local speaker = peripheral.find("speaker")
    if speaker then print("[display] speaker attached: " .. (peripheral.getName(speaker) or "?"))
    else print("[display] WARNING: no speaker on display PC -- TEST ALARM and warn beeps will be silent.") end
    local hosts = {}
    local function key(role, h) return role .. "/" .. h end
    local function getOrCreate(role, h)
        local k = key(role, h)
        if not hosts[k] then
            hosts[k] = { role=role, hostName=h, displayName=h, last={}, sev=0, msgs={},
                         ringMain=Ring.new(cfg.sparkPoints), seen=os.epoch("utc") }
        end
        return hosts[k]
    end
    local function listByRole(role)
        local out = {}
        for _, h in pairs(hosts) do if h.role == role then table.insert(out, h) end end
        table.sort(out, function(a, b) return (a.displayName or a.hostName) < (b.displayName or b.hostName) end)
        return out
    end
    local function listScramCapable()
        local out = {}
        for _, h in pairs(hosts) do if h.role == "fission" or h.role == "fusion" then table.insert(out, h) end end
        table.sort(out, function(a, b) return (a.displayName or a.hostName) < (b.displayName or b.hostName) end)
        return out
    end
    local TAB_ORDER = { "overview", "induction", "fission", "turbine", "boiler", "fusion", "history", "scram" }
    local activeTab = "overview"
    local selectedHost = {}  -- role -> hostName
    -- Remote-reboot tracking. key = role/host, value = { stage="sent"|"failed", at=epoch_ms }.
    -- Populated by rebootLoop when it broadcasts a reboot command, cleared in the
    -- rednet handler when telemetry resumes.
    local rebootState = {}
    local tabRects = {}
    local btnRects = {}  -- per-render touch buttons
    local SEV_COLORS = { [0]=colors.lime, [1]=colors.cyan, [2]=colors.yellow, [3]=colors.red }
    local function btn(x, y, label, kind, ctx, fg, bg)
        mon.setBackgroundColor(bg or colors.gray); mon.setTextColor(fg or colors.white)
        mon.setCursorPos(x, y); mon.write(label)
        btnRects[#btnRects + 1] = { x=x, y=y, w=#label, h=1, kind=kind, ctx=ctx }
        return x + #label + 1
    end
    local function sendCmd(target, action, args)
        rednet.broadcast(protocol.command(target, action, args or {}), protocol.PROTOCOL)
    end
    local alarmUntil = 0
    local audioQueue = {}
    local function queueAudio(path) table.insert(audioQueue, path); os.queueEvent("audio_play_request") end
    local function findAlarmFile()
        local resolved = util.resolveAlarm(cfg.alarmName)
        return resolved and resolved.path or nil
    end
    local function playTestAlarm()
        if speaker then
            local resolved = util.resolveAlarm(cfg.alarmName)
            if resolved.path then
                queueAudio(resolved.path)
                print("[display] TEST ALARM '" .. resolved.name .. "' queued: " .. resolved.path)
            else
                local ok = pcall(speaker.playSound, "minecraft:block.bell.use", 3, 1.0)
                if not ok then pcall(speaker.playSound, "minecraft:block.note.bell", 3, 1.0) end
                print("[display] TEST ALARM: built-in 'default' sound.")
            end
        else
            print("[display] TEST ALARM requested but no speaker attached.")
        end
        alarmUntil = os.epoch("utc") + 3000
    end
    local function cycleAlarmName()
        local newName = util.cycleAlarm(cfg.alarmName)
        cfg.alarmName = newName
        util.saveConfig("/cfg/display.cfg", cfg)
        -- propagate to all SCRAM-capable hosts so reactor PCs use the same siren
        for _, h in pairs(hosts) do
            if h.role == "fission" or h.role == "fusion" then
                sendCmd(h.hostName, "setAlarm", { name = newName })
            end
        end
        print("[display] alarm sound -> " .. newName)
    end

    -- Chat / webhook notifications --------------------------------------------------
    local chatBox = peripheral.find("chatBox")
    if chatBox then print("[display] chatBox attached -- chat notifications will use it.")
    else print("[display] no chatBox peripheral found (Advanced Peripherals); chat lines will only print to terminal unless webhookUrl is set.") end
    local lastNotifyKey = {}
    local function notify(sev, kind, message, force)
        -- `force` bypasses the chatNotify on/off and chatMinSeverity gates.
        -- Used by TEST CHAT and TEST SCRAM so the operator can verify wiring even
        -- when chat notifications are otherwise disabled.
        if not force then
            if not cfg.chatNotify then
                print("[notify] suppressed (chatNotify=false): " .. tostring(message))
                return
            end
            if (sev or 0) < (cfg.chatMinSeverity or 2) then
                print(("[notify] suppressed (sev %d < min %d): %s"):format(sev or 0, cfg.chatMinSeverity or 2, tostring(message)))
                return
            end
        end
        local now = os.epoch("utc")
        local k = (kind or "msg") .. ":" .. tostring(message)
        if not force and lastNotifyKey[k] and now - lastNotifyKey[k] < 30000 then
            print("[notify] suppressed (dedupe 30s): " .. tostring(message))
            return
        end
        lastNotifyKey[k] = now
        local prefix = cfg.chatPrefix or "[MEK]"
        local full = prefix .. " " .. tostring(message)
        local sentVia = {}
        if chatBox and chatBox.sendMessage then
            local ok, err = pcall(chatBox.sendMessage, tostring(message), prefix)
            if ok then table.insert(sentVia, "chatBox")
            else print("[notify] chatBox error: " .. tostring(err)) end
        end
        if cfg.webhookUrl and #cfg.webhookUrl > 0 and http and http.post then
            local ok, err = pcall(http.post, cfg.webhookUrl,
                textutils.serializeJSON({ content = full }),
                { ["Content-Type"] = "application/json" })
            if ok then table.insert(sentVia, "webhook") else print("[notify] webhook error: " .. tostring(err)) end
        end
        if #sentVia == 0 then
            print("[notify] NO TRANSPORTS! " .. full .. " (attach a chatBox or set cfg.webhookUrl)")
        else
            print(("[notify -> %s] %s"):format(table.concat(sentVia, "+"), full))
        end
    end

    -- ==================================================================
    -- Voice / PA system (Subnautica-style)
    -- ==================================================================
    -- cfg.voice[id] is auto-populated from the VOICE_LINES catalog. By default
    -- only severity-3 (CRITICAL) lines are enabled; everything else is opt-in.
    do
        local changed = false
        -- Migrate older saved cfg that pointed at /voice/ to the new /voice/ru/ default.
        if not cfg.voiceFolder or cfg.voiceFolder == "/voice/" then
            cfg.voiceFolder = "/voice/ru/"; changed = true
        end
        -- Migrate the old auto-throttle deadband: previously defaulted to 5, which
        -- means a target of 90% had a 85-95 inactive band and burn would never adjust
        -- when storage hovered around the target. New default is 1 for tight tracking.
        if (cfg.throttleSlack or 0) >= 3 then cfg.throttleSlack = 1; changed = true end
        -- Migrate old historyKeep=1440 default which can fill the disk on small CC
        -- partitions. Anything > 720 gets capped; users who explicitly want more
        -- can re-set it manually.
        if (cfg.historyKeep or 0) > 720 then cfg.historyKeep = 720; changed = true end
        -- Always start with collapsible panels closed, regardless of saved state.
        -- After a server restart the SCRAM tab should not greet the operator with
        -- a long expanded list; they can re-open whichever panel they want.
        if cfg.voicePanelOpen ~= false then cfg.voicePanelOpen = false end
        if cfg.rebootPanelOpen ~= false then cfg.rebootPanelOpen = false end
        cfg.voice = cfg.voice or {}
        for _, ln in ipairs(VOICE_LINES) do
            if not cfg.voice[ln.id] then
                cfg.voice[ln.id] = {
                    enabled  = (ln.sev == 3),
                    volume   = cfg.voiceDefaultVolume or 2.5,
                    cooldown = cfg.voiceDefaultCooldown or 60,
                }
                changed = true
            end
        end
        if changed then util.saveConfig("/cfg/display.cfg", cfg) end
    end
    local lastVoicePlayed = {}  -- id -> epoch ms
    -- Per-host net flow state: hostKey -> { sign=-1|0|1, since=epoch_ms, announced=bool, lastReminder=epoch_ms }
    -- Used to debounce "matrix net negative/positive" voice lines: requires the sign
    -- to be held for `netHoldMs` before announcing, and re-announces "still negative"
    -- every `netRemindMs` while sustained.
    local netState = {}
    local NET_HOLD_MS    = 30 * 1000          -- must hold for 30s before announcing
    local NET_REMIND_MS  = 10 * 60 * 1000     -- repeat reminder every 10 min if still negative
    local function voicePath(id) return (cfg.voiceFolder or "/voice/ru/") .. id .. ".dfpwm" end
    local function playVoice(id, contextSuffix, force)
        local ln = VOICE_BY_ID[id]; if not ln then print("[voice] unknown id: " .. tostring(id)); return end
        local v = (cfg.voice and cfg.voice[id]) or {}
        if not force and not v.enabled then
            if cfg.voiceDebug then print("[voice] gated (disabled): " .. id) end
            return
        end
        local now = os.epoch("utc")
        local cd = (v.cooldown or 60) * 1000
        if not force and lastVoicePlayed[id] and (now - lastVoicePlayed[id]) < cd then
            if cfg.voiceDebug then
                local left = math.floor((cd - (now - lastVoicePlayed[id])) / 1000)
                print(("[voice] gated (cooldown %ds left): %s"):format(left, id))
            end
            return
        end
        lastVoicePlayed[id] = now
        -- Queue audio (skip if no file). Sev 3 preempts sev<3 entries already in the queue.
        local file = voicePath(id)
        if speaker and fs.exists(file) then
            if ln.sev == 3 then
                local kept = {}
                for _, item in ipairs(audioQueue) do
                    if type(item) == "table" and (item.sev or 1) >= 3 then table.insert(kept, item) end
                end
                audioQueue = kept
            end
            table.insert(audioQueue, { path=file, vol=v.volume or cfg.voiceDefaultVolume or 2.5, sev=ln.sev, id=id })
            os.queueEvent("audio_play_request")
        else
            print("[voice] (no audio file) " .. file .. " (speaker=" .. tostring(speaker ~= nil) .. ")")
        end
        -- Audio IS the notification: do not echo Cyrillic to chat / terminal (CC font cannot render it).
        print("[voice " .. ln.sev .. "] " .. id)
    end
    -- Trigger evaluator: compares previous and new telemetry for one host and
    -- queues whichever voice lines apply. Called from rednetLoop after the host
    -- entry has been updated.
    local function evalVoiceTriggers(role, hostName, prev, now_, prevSev, newSev)
        prev = prev or {}; now_ = now_ or {}
        if cfg.voiceDebug then
            print(("[voice/eval] %s/%s sev %d->%d"):format(role or "?", hostName or "?", prevSev or 0, newSev or 0))
        end
        local function rose(field, threshold) return (prev[field] or 0) < threshold and (now_[field] or 0) >= threshold end
        local function fell(field, threshold) return (prev[field] or 1e30) > threshold and (now_[field] or 0) <= threshold end
        if role == "induction" then
            if rose("pct", 100) then playVoice("matrix_full") end
            if rose("pct", 95) and (now_.pct or 0) < 100 then playVoice("matrix_high_95") end
            if fell("pct", 25) and (now_.pct or 0) > 10 then playVoice("matrix_low_25") end
            if fell("pct", 10) and (now_.pct or 0) > 1 then playVoice("matrix_low_10") end
            if fell("pct", 1)  then playVoice("matrix_empty") end
            if (prev.input or 0) > 0 and (now_.input or 0) == 0 and (now_.pct or 0) < 90 then
                playVoice("matrix_input_lost")
            end
            if (now_.transferCap or 0) > 0 and (now_.output or 0) >= 0.95 * (now_.transferCap or 1) then
                playVoice("matrix_output_overload")
            end
            local prevNet = (prev.input or 0) - (prev.output or 0)
            local nowNet  = (now_.input or 0) - (now_.output or 0)
            -- Debounced sign tracking: require the sign to be held for NET_HOLD_MS
            -- before announcing, and remind every NET_REMIND_MS while sustained.
            local nowSign = (nowNet < 0) and -1 or (nowNet > 0 and 1 or 0)
            local nk = "induction/" .. (hostName or "?")
            local st = netState[nk] or { sign=nowSign, since=os.epoch("utc"), announced=false, lastReminder=0, lastAnnouncedSign=0 }
            local nowMs = os.epoch("utc")
            if st.sign ~= nowSign then
                -- Sign just flipped; reset the hold timer.
                st.sign = nowSign; st.since = nowMs; st.announced = false
            else
                local held = nowMs - st.since
                if not st.announced and held >= NET_HOLD_MS then
                    st.announced = true; st.lastReminder = nowMs
                    if nowSign < 0 then
                        playVoice("matrix_net_negative")
                        st.lastAnnouncedSign = -1
                    elseif nowSign > 0 and (st.lastAnnouncedSign or 0) < 0 then
                        playVoice("matrix_net_positive")
                        st.lastAnnouncedSign = 1
                    end
                elseif st.announced and nowSign < 0 and (nowMs - (st.lastReminder or 0)) >= NET_REMIND_MS then
                    st.lastReminder = nowMs
                    -- Force-bypass cooldown so the 10-minute reminder is reliable.
                    if lastVoicePlayed then lastVoicePlayed["matrix_net_negative"] = nil end
                    playVoice("matrix_net_negative")
                end
            end
            netState[nk] = st
        elseif role == "fission" then
            if prev.status == false and now_.status == true  then playVoice("fission_started") end
            if prev.status == true  and now_.status == false then playVoice("fission_stopped") end
            if (now_.lastTrip and (not prev.lastTrip or prev.lastTrip.ts ~= now_.lastTrip.ts))
                and now_.lastTrip.rule ~= "test" then
                playVoice("fission_scram_auto", "Причина: " .. (now_.lastTrip.why or "?"))
            end
            if rose("temp", 1020)   then playVoice("fission_temp_warn") end
            if rose("temp", 1140)   then playVoice("fission_temp_crit") end
            if rose("damage", 25)   then playVoice("fission_damage_warn") end
            if rose("damage", 42)   then playVoice("fission_damage_crit") end
            if fell("coolPct", 30)  then playVoice("fission_coolant_low") end
            if fell("coolPct", 15)  then playVoice("fission_coolant_crit") end
            if fell("fuelPct", 25)  then playVoice("fission_fuel_low") end
            if fell("fuelPct", 5)   then playVoice("fission_fuel_crit") end
            if rose("wastePct", 60) then playVoice("fission_waste_60") end
            if rose("wastePct", 80) then playVoice("fission_waste_80") end
            if rose("wastePct", 95) then playVoice("fission_waste_full") end
            if (prev.burn or 0) ~= (now_.burn or 0) and (now_.maxBurn or 0) > 0 then
                if (now_.burn or 0) >= (now_.maxBurn or 0) then playVoice("fission_burn_max") end
                if (now_.burn or 1) == 0 and now_.status == true then playVoice("fission_burn_zero") end
            end
            if not prev.latched and now_.latched then playVoice("fission_latched") end
        elseif role == "turbine" then
            if rose("steamPct", 95) and (now_.steamPct or 0) < 99 then playVoice("turbine_steam_high") end
            if rose("steamPct", 99) then playVoice("turbine_steam_full") end
            if rose("energyPct", 99) then playVoice("turbine_energy_full") end
            if (now_.maxProd or 0) > 0 and (now_.prod or 0) < 0.10 * now_.maxProd
                and (prev.prod or 0) >= 0.10 * (prev.maxProd or 1) then
                playVoice("turbine_low_output")
            end
        elseif role == "boiler" then
            if fell("waterPct", 25) then playVoice("boiler_water_low") end
            if fell("waterPct", 10) then playVoice("boiler_water_crit") end
            if rose("steamPct", 95) then playVoice("boiler_steam_full") end
            if rose("heatedPct", 95) then playVoice("boiler_heated_full") end
            if rose("temp", 1100) then playVoice("boiler_temp_high") end
        elseif role == "fusion" then
            if prev.status == false and now_.status == true  then playVoice("fusion_ignited") end
            if prev.status == true  and now_.status == false then playVoice("fusion_offline") end
            if (now_.lastTrip and (not prev.lastTrip or prev.lastTrip.ts ~= now_.lastTrip.ts))
                and now_.lastTrip.rule ~= "test" then
                playVoice("fusion_scram_auto")
            end
            if rose("plasmaTemp", 0.85e9) then playVoice("fusion_plasma_warn") end
            if rose("plasmaTemp", 0.95e9) then playVoice("fusion_plasma_crit") end
            if rose("caseTemp",   0.85e8) then playVoice("fusion_case_warn") end
            if fell("dtFuelPct",  25)     then playVoice("fusion_dt_low") end
            if fell("waterPct",   20)     then playVoice("fusion_water_low") end
        end
    end

    -- Energy-balance forecast --------------------------------------------------------
    local function forecastText(d)
        if not d or not d.maxEnergy or d.maxEnergy <= 0 then return nil end
        local net = (d.input or 0) - (d.output or 0)
        if math.abs(net) < 1 then return nil end
        local secs
        if net > 0 then
            secs = ((d.maxEnergy - (d.energy or 0)) / net)
            if secs <= 0 or secs > 7 * 86400 then return nil end
            return ("Full in %s"):format(util.fmtDuration and util.fmtDuration(secs) or string.format("%.1fm", secs/60)), colors.lime
        else
            secs = ((d.energy or 0) / -net)
            if secs <= 0 or secs > 7 * 86400 then return nil end
            return ("Empty in %s"):format(util.fmtDuration and util.fmtDuration(secs) or string.format("%.1fm", secs/60)), colors.orange
        end
    end

    -- Production history (CSV) -------------------------------------------------------
    local HISTORY_PATH = "/log/history.csv"
    local function ensureHistoryFile()
        if not fs.exists("/log") then fs.makeDir("/log") end
        if not fs.exists(HISTORY_PATH) then
            local f = fs.open(HISTORY_PATH, "w")
            f.writeLine("ts,role,host,energy,maxEnergy,input,output,prod,temp,damage")
            f.close()
        end
    end
    local function trimHistoryFile(maxLines)
        if not fs.exists(HISTORY_PATH) then return end
        local lines = {}
        local f = fs.open(HISTORY_PATH, "r")
        while true do local l = f.readLine(); if not l then break end; lines[#lines+1] = l end
        f.close()
        if #lines <= maxLines + 1 then return end
        local keep = { lines[1] }
        for i = #lines - maxLines + 1, #lines do keep[#keep+1] = lines[i] end
        local f2 = fs.open(HISTORY_PATH, "w")
        for _, l in ipairs(keep) do f2.writeLine(l) end
        f2.close()
    end
    local function logHistorySnapshot()
        if not cfg.historyEnabled then return end
        ensureHistoryFile()
        -- Trim BEFORE appending so a near-full disk doesn't get pushed over the
        -- edge by a 600-byte burst write. Also bail out early if free space looks
        -- dangerously low so the next display.cfg save still succeeds.
        pcall(trimHistoryFile, cfg.historyKeep or 720)
        local free = fs.getFreeSpace("/") or 0
        if free < 4096 then
            print(("[history] skipping snapshot, free=%dB low"):format(free))
            return
        end
        local f = fs.open(HISTORY_PATH, "a"); if not f then return end
        local ts = os.epoch("utc")
        local writeOk = true
        for _, h in pairs(hosts) do
            local d = h.last or {}
            local ok = pcall(f.writeLine, ("%d,%s,%s,%s,%s,%s,%s,%s,%s,%s"):format(
                ts, h.role, h.hostName,
                tostring(d.energy or ""), tostring(d.maxEnergy or ""),
                tostring(d.input or ""), tostring(d.output or ""),
                tostring(d.prod or ""), tostring(d.temp or ""), tostring(d.damage or "")
            ))
            if not ok then writeOk = false; break end
        end
        f.close()
        if not writeOk then
            print("[history] write failed (disk full?), aggressive trim")
            pcall(trimHistoryFile, math.floor((cfg.historyKeep or 720) / 2))
        end
    end
    local function readHistoryTail(maxRows)
        if not fs.exists(HISTORY_PATH) then return {} end
        local rows = {}
        local f = fs.open(HISTORY_PATH, "r"); if not f then return rows end
        local _ = f.readLine() -- skip header
        while true do
            local l = f.readLine(); if not l then break end
            -- Split on commas preserving empty fields. (gmatch "[^,]+" would skip blanks
            -- and shift columns, dropping rows without prod/temp/damage.)
            local parts, cur, i = {}, "", 1
            while i <= #l do
                local ch = l:sub(i, i)
                if ch == "," then parts[#parts+1] = cur; cur = ""
                else cur = cur .. ch end
                i = i + 1
            end
            parts[#parts+1] = cur
            if #parts >= 4 and tonumber(parts[1]) and parts[2] and parts[3] then
                rows[#rows+1] = {
                    ts=tonumber(parts[1]), role=parts[2], host=parts[3],
                    energy=tonumber(parts[4]), maxEnergy=tonumber(parts[5]),
                    input=tonumber(parts[6]), output=tonumber(parts[7]), prod=tonumber(parts[8]),
                    temp=tonumber(parts[9]), damage=tonumber(parts[10]),
                }
            end
        end
        f.close()
        if #rows > maxRows then
            local out = {}
            for i = #rows - maxRows + 1, #rows do out[#out+1] = rows[i] end
            return out
        end
        return rows
    end

    -- Auto burn-rate throttle (P-controller) -----------------------------------------
    local function autoThrottleTick()
        if not cfg.autoThrottle then return end
        local indH
        for _, h in pairs(hosts) do if h.role == "induction" then indH = h; break end end
        if not indH or not indH.last then
            if cfg.throttleDebug then print("[throttle] no induction host yet") end
            return
        end
        local pct = indH.last.pct or 0
        local target = cfg.throttleTarget or 80
        -- Default slack 2 keeps a small deadband around target so we don't oscillate
        -- on noise. We also clamp by distance to extremes so target=99 doesn't sit in
        -- a permanently-active deadband that overshoots into matrix-full territory.
        local slack = math.max(1, math.min(cfg.throttleSlack or 2, 100 - target, target))
        local err = target - pct  -- positive => storage below target => need more burn
        -- Magnitude-scaled step: bigger gap -> bigger correction (1.0..5.0x base step).
        local baseStep = cfg.throttleStep or 0.5
        local scale = math.min(5.0, math.max(1.0, math.abs(err) / 10))
        if math.abs(err) < slack then
            if cfg.throttleDebug then
                print(("[throttle] pct=%.1f target=%d slack=%d -> within deadband, no action"):format(pct, target, slack))
            end
            return
        end
        -- Positive err means storage below target -> increase burn (step > 0).
        -- Negative err means storage above target -> decrease burn (step < 0).
        local step = baseStep * scale * (err > 0 and 1 or -1)
        local touched = 0
        for _, h in pairs(hosts) do
            if h.role == "fission" and h.last and h.last.status == true then
                local cur = h.last.burn or 0
                local mx  = h.last.maxBurn or 0
                local newRate = math.max(0, math.min(mx, cur + step))
                if math.abs(newRate - cur) >= 0.01 then
                    sendCmd(h.hostName, "setBurnRate", { rate=newRate })
                    touched = touched + 1
                    pcall(playVoice, "system_auto_throttle", string.format("%.2f mB/t", newRate))
                    if cfg.throttleDebug then
                        print(("[throttle] %s pct=%.1f err=%+.1f -> burn %.2f -> %.2f"):format(
                            h.hostName, pct, err, cur, newRate))
                    end
                end
            end
        end
        if cfg.throttleDebug and touched == 0 then
            print(("[throttle] pct=%.1f err=%+.1f step=%+.2f but no online fission to adjust"):format(pct, err, step))
        end
    end

    -- Auto-restart after SCRAM -------------------------------------------------------
    local lastRestartAt = {}
    local function autoRestartTick()
        if not cfg.autoRestart then return end
        -- Only restart while storage well below threshold
        local indH
        for _, h in pairs(hosts) do if h.role == "induction" then indH = h; break end end
        local pct = indH and indH.last and indH.last.pct or 0
        if pct >= (cfg.autoRestartBelow or 85) then return end
        local now = os.epoch("utc")
        for _, h in pairs(hosts) do
            if h.role == "fission" and h.last and h.last.status == false and not h.last.latched then
                -- Health gate: refuse to bring a reactor back online if any subsystem
                -- still looks bad. Otherwise we'd just immediately re-trigger SCRAM.
                local d  = h.last
                local fp = d.fuelPct  or 0
                local cp = d.coolPct  or 0
                local wp = d.wastePct or 100
                local dmg = d.damage  or 100
                -- Need fuel healthily above the auto-stop threshold (with margin),
                -- coolant clearly above the SCRAM-rule low (default 10%) with margin,
                -- waste below the SCRAM-rule high (default 90%) with margin,
                -- and damage well below the SCRAM-rule limit.
                local fuelOK   = fp >= ((cfg.lowFuelStopThreshold or 6) + 10)
                local coolOK   = cp >= 25
                local wasteOK  = wp <= 75
                local damageOK = dmg <= 25
                if fuelOK and coolOK and wasteOK and damageOK then
                    local last = lastRestartAt[h.hostName] or 0
                    if now - last >= ((cfg.autoRestartDelay or 30) * 1000) then
                        lastRestartAt[h.hostName] = now
                        sendCmd(h.hostName, "activate")
                        pcall(playVoice, "system_auto_restart", h.displayName or h.hostName)
                        notify(1, "auto-restart", "Auto-restart " .. (h.displayName or h.hostName))
                    end
                end
            end
        end
    end

    -- Low-fuel auto-stop -------------------------------------------------------------
    -- When fuel drops to just above the SCRAM-rule crit threshold, scram the reactor
    -- preemptively so it stops the burn cleanly with margin to spare. One scram per
    -- host with a 30s cooldown to avoid spamming.
    local lastFuelStopAt = {}
    local function lowFuelStopTick()
        if not cfg.lowFuelAutoStop then return end
        local thr = cfg.lowFuelStopThreshold or 6
        local now = os.epoch("utc")
        for _, h in pairs(hosts) do
            if h.role == "fission" and h.last and h.last.status == true then
                local fp = h.last.fuelPct or 100
                if fp <= thr then
                    local last = lastFuelStopAt[h.hostName] or 0
                    if now - last >= 30000 then
                        lastFuelStopAt[h.hostName] = now
                        sendCmd(h.hostName, "scram")
                        pcall(playVoice, "fission_fuel_autostop", h.displayName or h.hostName)
                        notify(2, "low-fuel-stop", "Low-fuel auto-stop on " .. (h.displayName or h.hostName))
                    end
                end
            end
        end
    end

    local TAB_SHORT = { overview="Ovr", induction="Ind", fission="Fis", turbine="Tur", boiler="Boi", fusion="Fus", history="Hst", scram="SCR" }
    local function drawHeader(W_, H_)
        W.fillRect(mon, 1, 1, W_, 1, colors.blue)
        mon.setTextColor(colors.white); mon.setBackgroundColor(colors.blue)
        local title = IS_NARROW and "MEK" or L.headerTitle
        mon.setCursorPos(2, 1); mon.write(title)
        local clock = textutils.formatTime(os.time(), true)
        mon.setCursorPos(W_ - #clock, 1); mon.write(clock)
        if not IS_NARROW then
            local credit = L.credit
            local creditX = math.floor((W_ - #credit) / 2)
            if creditX > #L.headerTitle + 4 and creditX + #credit < W_ - #clock - 2 then
                mon.setCursorPos(creditX, 1); mon.setTextColor(colors.yellow); mon.write(credit)
            end
        end
        tabRects = {}
        if IS_NARROW then
            -- Two-row short-label tab strip (rows 2 and 3)
            W.fillRect(mon, 1, 2, W_, 2, colors.gray)
            local x, y = 2, 2
            for _, name in ipairs(TAB_ORDER) do
                local label = " " .. (TAB_SHORT[name] or name:sub(1,3)) .. " "
                if x + #label > W_ + 1 then x = 2; y = y + 1 end
                if y > 3 then break end
                local active = (name == activeTab)
                mon.setBackgroundColor(active and colors.cyan or colors.gray)
                mon.setTextColor(active and colors.black or colors.white)
                mon.setCursorPos(x, y); mon.write(label)
                tabRects[#tabRects + 1] = { x=x, y=y, w=#label, name=name }
                x = x + #label + 1
            end
        else
            W.fillRect(mon, 1, 2, W_, 1, colors.gray)
            local x = 2
            for _, name in ipairs(TAB_ORDER) do
                local label = " " .. (L.tabs[name] or name) .. " "
                local active = (name == activeTab)
                mon.setBackgroundColor(active and colors.cyan or colors.gray)
                mon.setTextColor(active and colors.black or colors.white)
                mon.setCursorPos(x, 2); mon.write(label)
                tabRects[#tabRects + 1] = { x=x, y=2, w=#label, name=name }
                x = x + #label + 1
            end
        end
    end
    local function drawFooter(W_, H_)
        local worst, host, msg = 0, nil, nil
        for _, h in pairs(hosts) do
            if h.sev > worst then worst, host, msg = h.sev, (h.displayName or h.hostName), h.msgs and h.msgs[1] or "" end
        end
        -- 2-row colored band gives the footer text breathing room above it.
        W.fillRect(mon, 1, H_ - 1, W_, 2, SEV_COLORS[worst])
        mon.setTextColor(colors.black); mon.setBackgroundColor(SEV_COLORS[worst])
        mon.setCursorPos(2, H_)
        if worst == 0 then mon.write(L.okFooter)
        else mon.write(("[%s] %s: %s"):format(L.sevLabels[worst], host or "?", msg or "")) end
    end
    local function drawCard(x, y, w, h, ho)
        local title = (L.roleLabel[ho.role] or ho.role:upper()) .. " " .. (ho.displayName or ho.hostName)
        W.border(mon, x, y, w, h, colors.lightGray, colors.black, title)
        mon.setCursorPos(x + w - 3, y); mon.setBackgroundColor(colors.black)
        mon.setTextColor(SEV_COLORS[ho.sev]); mon.write("\7")
        local d = ho.last or {}; local row = y + 2
        local function ln(k, v, c) W.kv(mon, x + 2, row, w - 4, k, v, c); row = row + 1 end
        if ho.role == "induction" then
            ln(L.stored, util.fmtEnergy(d.energy or 0))
            ln(L.fill,   util.fmtPercent(d.pct or 0), util.colorForPercent(d.pct or 0))
            ln(L.input,  util.fmtRate(d.input or 0),  colors.lime)
            ln(L.output, util.fmtRate(d.output or 0), colors.orange)
            ln(L.net,    util.fmtRate(d.net or 0), (d.net or 0) >= 0 and colors.lime or colors.red)
            if cfg.forecastEnabled then
                local txt, col = forecastText(d)
                if txt then ln("ETA", txt, col) end
            end
        elseif ho.role == "fission" then
            ln(L.status, util.fmtStatus(d.status, L.statusActive, L.statusDisabled),
                d.status == true and colors.lime or colors.lightGray)
            ln(L.temp,   util.fmtTemp(d.temp or 0))
            ln(L.damage, util.fmtPercent(d.damage or 0), util.colorForPercent(d.damage or 0, 25, 50))
            local burnPct = (d.maxBurn and d.maxBurn > 0) and ((d.actBurn or 0) / d.maxBurn * 100) or 0
            ln(L.burnPct, util.fmtPercent(burnPct), colors.cyan)
            ln(L.coolant,util.fmtPercent(d.coolPct or 0), util.colorForLevel(d.coolPct or 0))
            ln(L.waste,  util.fmtPercent(d.wastePct or 0))
        elseif ho.role == "turbine" then
            ln(L.out, util.fmtRate(d.prod or 0), colors.lime)
            ln(L.maxOut, util.fmtRate(d.maxProd or 0))
            ln(L.energyPct, util.fmtPercent(d.energyPct or 0))
            ln(L.steam,  util.fmtPercent(d.steamPct or 0))
        elseif ho.role == "boiler" then
            ln(L.temp,  util.fmtTemp(d.temp or 0))
            ln(L.boil,  ("%d / %d"):format(d.boilRate or 0, d.maxBoilRate or 0))
            ln(L.water, util.fmtPercent(d.waterPct or 0), util.colorForLevel(d.waterPct or 0))
            ln(L.steam, util.fmtPercent(d.steamPct or 0))
            ln(L.heated,util.fmtPercent(d.heatedPct or 0))
        elseif ho.role == "fusion" then
            ln(L.status, util.fmtStatus(d.status))
            ln(L.plasma, util.fmtTemp(d.plasmaTemp or 0))
            ln(L.caseTemp, util.fmtTemp(d.caseTemp or 0))
            ln(L.inject, tostring(d.injection or 0).." mB/t")
            ln(L.out,    util.fmtRate(d.prod or 0), colors.lime)
            ln(L.dtFuel, util.fmtPercent(d.dtFuelPct or 0))
        end
    end
    local overviewPage = 1
    local function drawOverview(W_, H_)
        local all = {}
        for _, h in pairs(hosts) do table.insert(all, h) end
        table.sort(all, function(a, b)
            if a.role ~= b.role then return a.role < b.role end
            return (a.displayName or a.hostName) < (b.displayName or b.hostName)
        end)
        if #all == 0 then
            W.centerText(mon, 1, math.floor(H_ / 2), W_, L.waiting, colors.lightGray); return
        end
        local cw, ch = 26, 10
        local cols = math.max(1, math.floor((W_ - 2) / (cw + 1)))
        local rows = math.max(1, math.floor((H_ - 6) / (ch + 1)))
        local perPage = cols * rows
        local pages = math.max(1, math.ceil(#all / perPage))
        if overviewPage > pages then overviewPage = pages end
        if overviewPage < 1 then overviewPage = 1 end
        local startIdx = (overviewPage - 1) * perPage + 1
        local endIdx = math.min(#all, startIdx + perPage - 1)
        for i = startIdx, endIdx do
            local k = i - startIdx
            local col = k % cols
            local row = math.floor(k / cols)
            local x = 2 + col * (cw + 1)
            local y = 4 + row * (ch + 1)
            drawCard(x, y, cw, ch, all[i])
        end
        if pages > 1 then
            mon.setBackgroundColor(colors.black); mon.setTextColor(colors.lightGray)
            local label = ("Page %d/%d  (%d hosts)"):format(overviewPage, pages, #all)
            mon.setCursorPos(math.floor((W_ - #label) / 2), H_ - 3); mon.write(label)
            btn(2,      H_ - 3, " < ", "ovPrev", {}, colors.white, colors.gray)
            btn(W_ - 4, H_ - 3, " > ", "ovNext", {}, colors.white, colors.gray)
        end
    end
    local function drawDetail(role, W_, H_)
        local list = listByRole(role)
        if #list == 0 then
            W.centerText(mon, 1, math.floor(H_ / 2), W_, L.waiting, colors.lightGray); return
        end
        -- Pick selected host (default = first); validate against current list.
        local sel = selectedHost[role]
        local hIdx = 1
        for i, ho in ipairs(list) do if ho.hostName == sel then hIdx = i; break end end
        local h = list[hIdx]; selectedHost[role] = h.hostName
        local d = h.last or {}
        mon.setBackgroundColor(colors.black)
        local titleY = IS_NARROW and 5 or 4
        local titleText = (L.roleLabel[role] or role:upper()) .. " :: " .. (h.displayName or h.hostName)
        if #list > 1 then titleText = titleText .. ("  [%d/%d]"):format(hIdx, #list) end
        W.centerText(mon, 1, titleY, W_, titleText, SEV_COLORS[h.sev])
        -- Always show prev/next arrows on detail tabs so operators see they CAN cycle
        -- (greyed out and inactive when there's only one host of this role).
        do
            local arrowFg = (#list > 1) and colors.white or colors.gray
            local arrowBg = (#list > 1) and colors.gray  or colors.black
            if #list > 1 then
                btn(2,      titleY, " < ", "selPrev", { role=role }, arrowFg, arrowBg)
                btn(W_ - 4, titleY, " > ", "selNext", { role=role }, arrowFg, arrowBg)
            else
                mon.setBackgroundColor(arrowBg); mon.setTextColor(arrowFg)
                mon.setCursorPos(2,      titleY); mon.write(" < ")
                mon.setCursorPos(W_ - 4, titleY); mon.write(" > ")
                mon.setBackgroundColor(colors.black)
            end
        end
        -- Reserve space for vertical gauges on the left, then place sparkline/kv to the right.
        local GW0 = STACKED and 1 or (IS_NARROW and 2 or (IS_WIDE and 4 or 3))
        local gOff = STACKED and {1, 4, 7, 10, 13} or (IS_NARROW and {2, 7, 12, 17, 22} or {2, 10, 18, 26, 34})
        -- Number of gauges this role draws (drives where the right column begins).
        local gaugeCount = ({ induction=3, fission=5, turbine=3, boiler=4, fusion=4 })[role] or 4
        local gaugeRight = 3 + gOff[gaugeCount] + GW0
        local sparkX, sparkW, sparkTitleY, sparkY, sparkH
        local rightX, rightW, kvDefaultY
        if STACKED then
            -- Single-column stacked layout (very narrow, e.g. 2x3 portrait): gauges (top) > sparkline (mid) > kv (bottom)
            sparkX = 2; sparkW = math.max(2, W_ - 2)
            sparkTitleY = 16; sparkY = 17; sparkH = 3
            rightX = 2; rightW = math.max(2, W_ - 2)
            kvDefaultY = sparkY + sparkH + 1
        elseif IS_WIDE and (W_ - gaugeRight) >= 48 then
            -- True 3-column: gauges | sparkline | kv list
            local rem = W_ - gaugeRight - 3
            sparkX = gaugeRight + 2
            sparkW = math.floor(rem / 2)
            rightX = sparkX + sparkW + 2
            rightW = W_ - rightX - 1
            sparkTitleY = 6; sparkY = 7; sparkH = 6
            kvDefaultY = 6
        else
            -- 2-column: gauges | (spark stacked above kv)
            sparkX = math.max(math.floor(W_/2) + 1, gaugeRight + 2)
            sparkW = W_ - sparkX - 1
            rightX = sparkX; rightW = sparkW
            sparkTitleY = 6; sparkY = 7; sparkH = 6
            kvDefaultY = 14
        end
        local THREE_COL = (rightX ~= sparkX) and not STACKED
        local function spark(values, color, title, fmt)
            mon.setBackgroundColor(colors.black); mon.setTextColor(colors.white)
            mon.setCursorPos(sparkX, sparkTitleY); mon.write(title)
            W.sparkline(mon, sparkX, sparkY, sparkW, sparkH, values, color)
        end
        local function sparkStats(values, fmt)
            local vmin, vmax = math.huge, -math.huge
            for _, v in ipairs(values) do
                if v < vmin then vmin = v end
                if v > vmax then vmax = v end
            end
            if vmin == math.huge then vmin = 0; vmax = 0 end
            local cur = values[#values] or 0
            fmt = fmt or function(v) return string.format("%.1f", v) end
            return fmt(cur), fmt(vmin), fmt(vmax)
        end
        local function kvList(rows)
            local y = kvDefaultY
            local maxY = IS_NARROW and (H_ - 4) or (H_ - 4)
            for _, r in ipairs(rows) do
                if y > maxY then break end
                W.kv(mon, rightX, y, rightW, r[1], r[2], r[3] or colors.white); y = y + 1
            end
        end
        local gx, gy, gh
        if STACKED then
            gx, gy, gh = 2, 6, 8
        else
            gx, gy, gh = 3, 7, H_ - 13  -- leave room for: labels(1) + gap(1) + buttons(1) + gap(1) + footer(2)
        end
        local GW = GW0                      -- gauge bar width (chars)
        local function vg(x, label, val, max, color)
            for i = 0, GW - 1 do W.vBar(mon, x + i, gy, gh, val, max, color) end
            mon.setBackgroundColor(colors.black); mon.setTextColor(colors.lightGray)
            -- Center label horizontally under the gauge bar (works for any GW / label length).
            local lx = x + math.floor((GW - #label) / 2)
            mon.setCursorPos(lx, gy + gh + 1); mon.write(label)
        end
        if role == "induction" then
            vg(gx + gOff[1], "Fill", d.pct or 0,    100, util.colorForPercent(d.pct or 0))
            vg(gx + gOff[2], "In",   d.input or 0,  d.transferCap or 1, util.colorForPercent((d.transferCap or 0) > 0 and ((d.input or 0) / (d.transferCap or 1)) * 100 or 0, 75, 95))
            vg(gx + gOff[3], "Out",  d.output or 0, d.transferCap or 1, util.colorForPercent((d.transferCap or 0) > 0 and ((d.output or 0) / (d.transferCap or 1)) * 100 or 0, 75, 95))
            -- Sparkline values are in J on the wire, but visually rescaled anyway.
            local efmt = function(v) return util.fmtEnergy(v) end
            spark(h.ringMain:values(), colors.cyan, L.chartStored, efmt)
            local nowS, minS, maxS = sparkStats(h.ringMain:values(), efmt)
            local rows = {
                { L.chartNow, nowS, colors.cyan }, { L.chartMin, minS }, { L.chartMax, maxS },
                { L.stored,    util.fmtEnergy(d.energy or 0) },
                { L.capacity,  util.fmtEnergy(d.maxEnergy or 0) },
                { L.fill,      util.fmtPercent(d.pct or 0), util.colorForPercent(d.pct or 0) },
                { L.input,     util.fmtRate(d.input or 0), colors.lime },
                { L.output,    util.fmtRate(d.output or 0), colors.orange },
                { L.net,       util.fmtRate(d.net or 0), (d.net or 0) >= 0 and colors.lime or colors.red },
            }
            -- ETA: how long until matrix is full or empty at the current net rate.
            do
                local fc, col = forecastText(d)
                if fc then table.insert(rows, { "ETA", fc, col or colors.lightGray })
                else table.insert(rows, { "ETA", "stable", colors.lightGray }) end
            end
            table.insert(rows, { L.cells,     tostring(d.cells or 0) })
            table.insert(rows, { L.providers, tostring(d.providers or 0) })
            table.insert(rows, { L.transferCap, util.fmtRate(d.transferCap or 0) })
            kvList(rows)
        elseif role == "fission" then
            vg(gx + gOff[1], "Temp",    d.temp or 0,     1500, util.colorForPercent((d.temp or 0)/15, 75, 95))
            vg(gx + gOff[2], "Damage",  d.damage or 0,   100,  util.colorForPercent(d.damage or 0, 25, 50))
            vg(gx + gOff[3], "Coolant", d.coolPct or 0,  100,  util.colorForLevel(d.coolPct or 0))
            vg(gx + gOff[4], "Waste",   d.wastePct or 0, 100,  util.colorForPercent(d.wastePct or 0))
            vg(gx + gOff[5], "Fuel",    d.fuelPct or 0,  100,  util.colorForLevel(d.fuelPct or 0))
            local burnPct = (d.maxBurn and d.maxBurn > 0) and ((d.actBurn or 0) / d.maxBurn * 100) or 0
            local tfmt = function(v) return string.format("%.0fK", v) end
            spark(h.ringMain:values(), colors.orange, L.chartTemp, tfmt)
            local nowS, minS, maxS = sparkStats(h.ringMain:values(), tfmt)
            local rows = {
                { L.status,  util.fmtStatus(d.status, L.statusActive, L.statusDisabled),
                    d.status == true and colors.lime or colors.lightGray },
                { L.chartNow, nowS, colors.orange }, { L.chartMin, minS }, { L.chartMax, maxS },
                { L.burnPct, util.fmtPercent(burnPct), colors.cyan },
                { L.burn,    ("%.2f mB/t"):format(d.actBurn or 0), colors.cyan },
                { L.setBurn, ("%.2f mB/t"):format(d.burn or 0) },
                { L.maxBurn, ("%.2f mB/t"):format(d.maxBurn or 0) },
                { L.heated,  util.fmtPercent(d.heatPct or 0) },
                { L.envLoss, ("%.2f K/t"):format(d.envLoss or 0) },
                { L.heatRate,("%d mB/t"):format(d.heatRate or 0) },
            }
            if d.boilEff then
                table.insert(rows, { L.boilEff, util.fmtPercent((d.boilEff or 0) * 100) })
            end
            kvList(rows)
        elseif role == "turbine" then
            vg(gx + gOff[1], "Buffer", d.energyPct or 0, 100, util.colorForPercent(d.energyPct or 0, 75, 95))
            vg(gx + gOff[2], "Steam",  d.steamPct or 0,  100, util.colorForPercent(d.steamPct or 0))
            vg(gx + gOff[3], "Prod",   d.prod or 0,     d.maxProd or 1, util.colorForLevel((d.maxProd or 0) > 0 and ((d.prod or 0) / (d.maxProd or 1)) * 100 or 100, 50, 10))
            local rfmt = function(v) return util.fmtRate(v) end
            spark(h.ringMain:values(), colors.lime, L.chartProd, rfmt)
            local nowS, minS, maxS = sparkStats(h.ringMain:values(), rfmt)
            kvList({
                { L.chartNow, nowS, colors.lime }, { L.chartMin, minS }, { L.chartMax, maxS },
                { L.out,        util.fmtRate(d.prod or 0), colors.lime },
                { L.maxOut,     util.fmtRate(d.maxProd or 0) },
                { L.steam,      util.fmtPercent(d.steamPct or 0) },
                { L.energyPct,  util.fmtPercent(d.energyPct or 0) },
                { L.dispersers, tostring(d.dispersers or 0) },
                { L.vents,      tostring(d.vents or 0) },
                { L.condensers, tostring(d.condensers or 0) },
            })
        elseif role == "boiler" then
            vg(gx + gOff[1], "Water",  d.waterPct or 0,  100, util.colorForLevel(d.waterPct or 0))
            vg(gx + gOff[2], "Steam",  d.steamPct or 0,  100, util.colorForPercent(d.steamPct or 0, 75, 95))
            vg(gx + gOff[3], "Heated", d.heatedPct or 0, 100, util.colorForPercent(d.heatedPct or 0, 75, 95))
            vg(gx + gOff[4], "Cooled", d.cooledPct or 0, 100, util.colorForLevel(d.cooledPct or 0))
            local bfmt = function(v) return string.format("%.0fmB/t", v) end
            spark(h.ringMain:values(), colors.orange, L.chartBoil, bfmt)
            local nowS, minS, maxS = sparkStats(h.ringMain:values(), bfmt)
            kvList({
                { L.chartNow, nowS, colors.orange }, { L.chartMin, minS }, { L.chartMax, maxS },
                { L.temp,    util.fmtTemp(d.temp or 0), colors.orange },
                { L.boil,    ("%d mB/t"):format(d.boilRate or 0), colors.cyan },
                { L.maxBoil, ("%d mB/t"):format(d.maxBoilRate or 0) },
                { L.water,   util.fmtPercent(d.waterPct or 0) },
                { L.steam,   util.fmtPercent(d.steamPct or 0) },
                { L.heated,  util.fmtPercent(d.heatedPct or 0) },
                { L.cooled,  util.fmtPercent(d.cooledPct or 0) },
            })
        elseif role == "fusion" then
            local plasmaPct = math.min(100, (d.plasmaTemp or 0) / 1.0e7)
            local casePct   = math.min(100, (d.caseTemp   or 0) / 1.0e6)
            vg(gx + gOff[1], "Plasma", plasmaPct, 100, util.colorForPercent(plasmaPct, 70, 90))
            vg(gx + gOff[2], "Case",   casePct,   100, util.colorForPercent(casePct,   70, 90))
            vg(gx + gOff[3], "Fuel",   d.dtFuelPct or 0, 100, util.colorForLevel(d.dtFuelPct or 0))
            vg(gx + gOff[4], "Water",  d.waterPct  or 0, 100, util.colorForLevel(d.waterPct  or 0))
            local pfmt = function(v) return string.format("%.0fK", v) end
            spark(h.ringMain:values(), colors.magenta, L.chartPlasma, pfmt)
            local nowS, minS, maxS = sparkStats(h.ringMain:values(), pfmt)
            kvList({
                { L.chartNow, nowS, colors.magenta }, { L.chartMin, minS }, { L.chartMax, maxS },
                { L.status,     util.fmtStatus(d.status) },
                { L.plasma,     util.fmtTemp(d.plasmaTemp or 0), colors.magenta },
                { L.caseTemp,   util.fmtTemp(d.caseTemp or 0), colors.orange },
                { L.inject,     tostring(d.injection or 0).." mB/t", colors.cyan },
                { L.production, util.fmtRate(d.prod or 0), colors.lime },
                { L.deuterium,  util.fmtPercent(d.deuteriumPct or 0) },
                { L.tritium,    util.fmtPercent(d.tritiumPct or 0) },
                { L.dtFuel,     util.fmtPercent(d.dtFuelPct or 0) },
            })
        end
        if h.msgs and #h.msgs > 0 and not STACKED then
            mon.setCursorPos(rightX, H_ - 4); mon.setTextColor(colors.yellow)
            mon.setBackgroundColor(colors.black); mon.write(L.alerts)
            for i = 1, math.min(2, #h.msgs) do
                mon.setCursorPos(rightX, H_ - 4 + i)
                mon.setTextColor(SEV_COLORS[h.sev]); mon.write("- " .. h.msgs[i])
            end
        end
        -- Control button row at bottom-left (under gauges, above footer)
        if cfg.allowControl and (role == "fission" or role == "fusion") then
            local bx, by = 3, H_ - 3
            if role == "fission" then
                bx = btn(bx, by, L.btnRun,    "cmd", { target=h.hostName, action="activate" }, colors.white, colors.green)
                bx = btn(bx, by, L.btnScram,  "cmd", { target=h.hostName, action="scram" },    colors.white, colors.red)
                -- B-- / B- / B+ / B++ : step by burnStep and burnStepBig respectively.
                bx = btn(bx, by, L.btnBurnDnBig, "burn", { target=h.hostName, delta=-cfg.burnStepBig, current=d.burn or 0, max=d.maxBurn or 0 }, colors.white, colors.gray)
                bx = btn(bx, by, L.btnBurnDn,    "burn", { target=h.hostName, delta=-cfg.burnStep,    current=d.burn or 0, max=d.maxBurn or 0 }, colors.white, colors.gray)
                bx = btn(bx, by, L.btnBurnUp,    "burn", { target=h.hostName, delta= cfg.burnStep,    current=d.burn or 0, max=d.maxBurn or 0 }, colors.white, colors.gray)
                bx = btn(bx, by, L.btnBurnUpBig, "burn", { target=h.hostName, delta= cfg.burnStepBig, current=d.burn or 0, max=d.maxBurn or 0 }, colors.white, colors.gray)
                bx = btn(bx, by, L.btnReset,  "cmd", { target=h.hostName, action="reset" },    colors.white, colors.blue)
            else
                bx = btn(bx, by, L.btnIgnite, "cmd", { target=h.hostName, action="activate" }, colors.white, colors.green)
                bx = btn(bx, by, L.btnScram,  "cmd", { target=h.hostName, action="scram" },    colors.white, colors.red)
                bx = btn(bx, by, L.btnInjDn,  "inj", { target=h.hostName, delta=-cfg.injectionStep, current=d.injection or 0 }, colors.white, colors.gray)
                bx = btn(bx, by, L.btnInjUp,  "inj", { target=h.hostName, delta= cfg.injectionStep, current=d.injection or 0 }, colors.white, colors.gray)
                bx = btn(bx, by, L.btnReset,  "cmd", { target=h.hostName, action="reset" },    colors.white, colors.blue)
            end
        elseif (role == "fission" or role == "fusion") then
            mon.setCursorPos(3, H_ - 3); mon.setBackgroundColor(colors.black); mon.setTextColor(colors.lightGray); mon.write(L.controlsOff)
        end
    end
    local function drawScram(W_, H_)
        local list = listScramCapable()
        mon.setBackgroundColor(colors.black); mon.setTextColor(colors.white)
        W.centerText(mon, 1, 4, W_, L.scramTitle, colors.white)
        W.centerText(mon, 1, 5, W_, L.scramHint, colors.lightGray)
        -- Alarm sound cycle bar
        local alarmLabel = " Alarm: " .. tostring(cfg.alarmName or "default") .. " "
        local ax = 2
        ax = btn(ax, 6, alarmLabel, "alarmCycle", {}, colors.white, colors.gray)
        ax = btn(ax, 6, " Test sound ", "alarm", {}, colors.white, colors.orange)
        -- System rules: each row = [ON/OFF] toggle + cyan-highlighted value + [-] [+] + plain English description
        local function sysRow(yRow, isOn, kindOn, valueStr, kindAdj, description)
            local mx = 2
            local toggleLabel = isOn and " [ON ] " or " [OFF] "
            mx = btn(mx, yRow, toggleLabel, kindOn, {}, colors.white,
                isOn and colors.green or colors.gray)
            -- Cyan-on-black bracketed value to make it visually obvious it is editable
            mon.setBackgroundColor(colors.black); mon.setTextColor(colors.yellow)
            local valLabel = (" [%s] "):format(valueStr or "?")
            local valLabelPadded = valLabel .. string.rep(" ", math.max(0, 12 - #valLabel))
            mon.setCursorPos(mx, yRow); mon.write(valLabelPadded)
            mx = mx + #valLabelPadded
            mx = btn(mx, yRow, " - ", kindAdj, { dir=-1 }, colors.white, colors.gray)
            mx = btn(mx, yRow, " + ", kindAdj, { dir=1 }, colors.white, colors.gray)
            mon.setBackgroundColor(colors.black); mon.setTextColor(colors.lightGray)
            mon.setCursorPos(mx + 1, yRow); mon.write(description or "")
        end
        sysRow(7,  cfg.scramOnMatrixFull, "matrixToggle",
            string.format("%.1f%%", cfg.matrixFullThreshold or 99.8),
            "matrixAdj", "SCRAM all fission when storage exceeds this")
        sysRow(8,  cfg.warnOnMatrixLow, "lowToggle",
            string.format("%.0f%%", cfg.matrixLowThreshold or 10),
            "lowAdj", "Warn when storage drops below this")
        sysRow(9,  cfg.autoThrottle, "throttleToggle",
            tostring(cfg.throttleTarget or 80) .. "%",
            "throttleAdj", "Auto-adjust burn to keep storage near this")
        sysRow(10, cfg.autoRestart, "restartToggle",
            tostring(cfg.autoRestartBelow or 85) .. "%",
            "restartAdj", "Auto-restart fission when storage below this")
        sysRow(11, cfg.lowFuelAutoStop, "lowFuelToggle",
            tostring(cfg.lowFuelStopThreshold or 6) .. "%",
            "lowFuelAdj", "Auto-stop fission when fuel drops to this")
        local sevName = ({ [1]="NOTICE+", [2]="WARN+", [3]="CRIT" })[cfg.chatMinSeverity or 2] or "?"
        sysRow(12, cfg.chatNotify, "chatToggle",
            sevName,
            "chatAdj", "Chat / webhook notify at or above this severity")
        -- Voice lines panel (collapsible)
        local row = 13
        do
            local nActive, nTotal = 0, #VOICE_LINES
            for _, vl in ipairs(VOICE_LINES) do
                local vc = (cfg.voice and cfg.voice[vl.id]) or {}
                if vc.enabled then nActive = nActive + 1 end
            end
            local arrow = cfg.voicePanelOpen and "\31" or "\16" -- down / right
            local hx = 2
            hx = btn(hx, row, (" %s Voice "):format(arrow), "voiceTogglePanel", {},
                colors.white, cfg.voicePanelOpen and colors.purple or colors.gray)
            mon.setBackgroundColor(colors.black); mon.setTextColor(colors.lightGray)
            mon.setCursorPos(hx + 1, row); mon.write(("(%d/%d active)"):format(nActive, nTotal))
            row = row + 1
        end
        if cfg.voicePanelOpen then
            local perPage = cfg.voicePerPage or 8
            local total = #VOICE_LINES
            local pages = math.max(1, math.ceil(total / perPage))
            if (cfg.voicePage or 1) > pages then cfg.voicePage = pages end
            if (cfg.voicePage or 1) < 1 then cfg.voicePage = 1 end
            local pg = cfg.voicePage or 1
            local startIdx = (pg - 1) * perPage + 1
            local endIdx = math.min(total, startIdx + perPage - 1)
            for i = startIdx, endIdx do
                local vl = VOICE_LINES[i]
                local vc = (cfg.voice and cfg.voice[vl.id]) or {}
                local enabled = vc.enabled and true or false
                local volV = vc.volume or cfg.voiceDefaultVolume or 2.5
                local vx = 2
                vx = btn(vx, row, enabled and " ON " or " OFF", "voiceToggleLine",
                    { id=vl.id }, colors.white, enabled and colors.green or colors.gray)
                vx = btn(vx, row, " - ", "voiceVolAdj", { id=vl.id, dir=-1 }, colors.white, colors.gray)
                mon.setBackgroundColor(colors.black); mon.setTextColor(colors.yellow)
                local volStr = (" %.1f "):format(volV)
                mon.setCursorPos(vx, row); mon.write(volStr); vx = vx + #volStr
                vx = btn(vx, row, " + ", "voiceVolAdj", { id=vl.id, dir=1 }, colors.white, colors.gray)
                vx = btn(vx, row, " \16 ", "voicePreview", { id=vl.id }, colors.white, colors.cyan)
                local sevCol = SEV_COLORS[vl.sev] or colors.white
                mon.setBackgroundColor(colors.black); mon.setTextColor(sevCol)
                mon.setCursorPos(vx + 1, row); mon.write(vl.id:sub(1, 28))
                mon.setTextColor(colors.lightGray)
                local pos = vx + 1 + 28 + 1
                if pos < W_ - 2 then
                    -- CC:Tweaked monitor font cannot render Cyrillic; show category tag instead.
                    local tag = ("[%s sev%d]"):format(vl.category or "?", vl.sev or 0)
                    mon.setCursorPos(pos, row); mon.write(tag:sub(1, math.max(0, W_ - pos - 1)))
                end
                row = row + 1
            end
            -- Pagination row
            local px = 2
            px = btn(px, row, " < ", "voicePagePrev", {}, colors.white, colors.gray)
            mon.setBackgroundColor(colors.black); mon.setTextColor(colors.white)
            local lab = ("Page %d/%d"):format(pg, pages)
            mon.setCursorPos(px + 1, row); mon.write(lab); px = px + #lab + 2
            px = btn(px, row, " > ", "voicePageNext", {}, colors.white, colors.gray)
            row = row + 1
        end
        -- Reboot panel (collapsible). Lists every known host with a manual reboot
        -- button + a header-bar "Reboot all" button. Auto-reboot toggle/timeout sit
        -- on the header for quick access.
        do
            local arrow = cfg.rebootPanelOpen and "\31" or "\16"
            local hx = 2
            hx = btn(hx, row, (" %s Reboot "):format(arrow), "rebootTogglePanel", {},
                colors.white, cfg.rebootPanelOpen and colors.purple or colors.gray)
            -- Auto-reboot toggle + silence threshold inline on the header
            local autoLabel = cfg.autoReboot and " AUTO ON " or " AUTO OFF"
            hx = btn(hx, row, autoLabel, "rebootAutoToggle", {}, colors.white,
                cfg.autoReboot and colors.green or colors.gray)
            hx = btn(hx, row, " - ", "rebootSilentAdj", { dir=-1 }, colors.white, colors.gray)
            mon.setBackgroundColor(colors.black); mon.setTextColor(colors.yellow)
            local sStr = (" %ds "):format(cfg.autoRebootSilent or 120)
            mon.setCursorPos(hx, row); mon.write(sStr); hx = hx + #sStr
            hx = btn(hx, row, " + ", "rebootSilentAdj", { dir=1 }, colors.white, colors.gray)
            hx = btn(hx, row, " Reboot ALL ", "rebootAll", {}, colors.white, colors.red)
            row = row + 1
        end
        if cfg.rebootPanelOpen then
            -- Build a stable host list (sorted by role then name) so paging is consistent.
            local hostList = {}
            for _, h in pairs(hosts) do hostList[#hostList+1] = h end
            table.sort(hostList, function(a,b)
                if a.role ~= b.role then return a.role < b.role end
                return (a.hostName or "") < (b.hostName or "")
            end)
            local perPage = cfg.rebootPerPage or 8
            local total = #hostList
            local pages = math.max(1, math.ceil(math.max(1,total) / perPage))
            if (cfg.rebootPage or 1) > pages then cfg.rebootPage = pages end
            if (cfg.rebootPage or 1) < 1 then cfg.rebootPage = 1 end
            local pg = cfg.rebootPage or 1
            local startIdx = (pg - 1) * perPage + 1
            local endIdx = math.min(total, startIdx + perPage - 1)
            if total == 0 then
                mon.setBackgroundColor(colors.black); mon.setTextColor(colors.lightGray)
                mon.setCursorPos(2, row); mon.write("No hosts seen yet.")
                row = row + 1
            else
                local now = os.epoch("utc")
                for i = startIdx, endIdx do
                    local h = hostList[i]
                    local rx = 2
                    rx = btn(rx, row, " Reboot ", "rebootHost",
                        { target=h.hostName, host=h.displayName or h.hostName, role=h.role },
                        colors.white, colors.red)
                    -- Status indicator
                    local age = h.seen and ((now - h.seen) / 1000) or 9999
                    local rs = (rebootState and rebootState[h.role .. "/" .. h.hostName]) or nil
                    local statusTxt, statusCol
                    if rs and rs.stage == "sent" then
                        statusTxt = ("REBOOTING %ds"):format(math.floor((now - rs.at)/1000))
                        statusCol = colors.yellow
                    elseif rs and rs.stage == "failed" then
                        statusTxt = "REBOOT FAILED"
                        statusCol = colors.red
                    elseif h.online == false or age > 30 then
                        statusTxt = ("OFFLINE %ds"):format(math.floor(age))
                        statusCol = colors.red
                    else
                        statusTxt = ("OK %ds"):format(math.floor(age))
                        statusCol = colors.lime
                    end
                    mon.setBackgroundColor(colors.black); mon.setTextColor(SEV_COLORS[h.sev or 0] or colors.white)
                    mon.setCursorPos(rx + 1, row); mon.write((h.role or "?") .. ":" .. (h.displayName or h.hostName or "?"))
                    mon.setTextColor(statusCol)
                    local sx = math.max(rx + 18, W_ - #statusTxt - 1)
                    if sx > rx + 1 then
                        mon.setCursorPos(sx, row); mon.write(statusTxt)
                    end
                    row = row + 1
                end
            end
            local px = 2
            px = btn(px, row, " < ", "rebootPagePrev", {}, colors.white, colors.gray)
            mon.setBackgroundColor(colors.black); mon.setTextColor(colors.white)
            local lab = ("Page %d/%d"):format(pg, pages)
            mon.setCursorPos(px + 1, row); mon.write(lab); px = px + #lab + 2
            px = btn(px, row, " > ", "rebootPageNext", {}, colors.white, colors.gray)
            row = row + 1
        end
        local y = row
        if #list == 0 then
            W.centerText(mon, 1, math.max(y + 1, math.floor(H_/2)), W_, L.scramNone, colors.lightGray); return
        end
        for _, h in ipairs(list) do
            local d = h.last or {}
            local title = (L.roleLabel[h.role] or h.role) .. " :: " .. (h.displayName or h.hostName)
            mon.setBackgroundColor(colors.black); mon.setTextColor(SEV_COLORS[h.sev])
            mon.setCursorPos(2, y); mon.write(title)
            -- right-side test/reset buttons. Test SCRAM also fires a chat notification
            -- so you can verify the chat / webhook hookup at the same time.
            local rx = W_ - #L.btnTestScram - #L.btnTestAlarm - #L.btnTestChat - #L.btnReset - 6
            rx = btn(rx, y, L.btnTestScram, "testScram", { target=h.hostName, host=h.displayName or h.hostName, role=h.role }, colors.white, colors.red)
            rx = btn(rx, y, L.btnTestAlarm, "alarm", {}, colors.white, colors.orange)
            rx = btn(rx, y, L.btnTestChat,  "testChat", { host=h.displayName or h.hostName, role=h.role }, colors.white, colors.purple)
            rx = btn(rx, y, L.btnReset,     "cmd", { target=h.hostName, action="reset" }, colors.white, colors.blue)
            y = y + 1
            local trip = d.lastTrip
            mon.setBackgroundColor(colors.black); mon.setTextColor(colors.lightGray)
            mon.setCursorPos(4, y)
            if trip then mon.write(L.scramLast .. ": " .. tostring(trip.why or "?"))
            else mon.write(L.scramLast .. ": -") end
            if d.latched then
                mon.setTextColor(colors.red); mon.setCursorPos(W_ - #L.scramLatched - 2, y); mon.write(L.scramLatched)
            end
            y = y + 1
            local rules = d.scramCfg
            if type(rules) == "table" then
                for idx, ru in ipairs(rules) do
                    if y >= H_ - 2 then break end
                    mon.setBackgroundColor(colors.black); mon.setTextColor(colors.white)
                    mon.setCursorPos(4, y); mon.write(("%-10s"):format(ru.label or ru.id))
                    -- enable/disable button
                    local bx = 16
                    bx = btn(bx, y, ru.enabled and L.btnEnable or L.btnDisable, "ruleToggle",
                        { target=h.hostName, role=h.role, ruleIdx=idx }, colors.white,
                        ru.enabled and colors.green or colors.gray)
                    -- threshold and +/- buttons
                    local thrStr = ("%s %s%s"):format(ru.op, tostring(ru.threshold), ru.unit or "")
                    mon.setBackgroundColor(colors.black); mon.setTextColor(colors.cyan)
                    mon.setCursorPos(bx, y); mon.write(("%-14s"):format(thrStr))
                    bx = bx + 14
                    bx = btn(bx, y, L.btnMinus, "ruleAdj", { target=h.hostName, role=h.role, ruleIdx=idx, dir=-1 }, colors.white, colors.gray)
                    bx = btn(bx, y, L.btnPlus,  "ruleAdj", { target=h.hostName, role=h.role, ruleIdx=idx, dir= 1 }, colors.white, colors.gray)
                    -- live value
                    local v = d[ru.field]
                    if type(v) == "number" then
                        mon.setBackgroundColor(colors.black)
                        local tripped = (ru.op == ">" and v > ru.threshold) or (ru.op == "<" and v < ru.threshold)
                        mon.setTextColor(tripped and colors.red or colors.lightGray)
                        mon.setCursorPos(bx, y); mon.write(("now %s%s"):format(string.format("%.1f", v), ru.unit or ""))
                    end
                    y = y + 1
                end
            end
            y = y + 1
            if y >= H_ - 2 then break end
        end
    end
    local function drawHistory(W_, H_)
        mon.setBackgroundColor(colors.black); mon.setTextColor(colors.white)
        W.centerText(mon, 1, 4, W_, "Production History", colors.white)
        W.centerText(mon, 1, 5, W_, ("logs every %ds, kept %d rows"):format(
            cfg.historyEvery or 60, cfg.historyKeep or 1440), colors.lightGray)
        local rows = readHistoryTail(720)
        if #rows == 0 then
            W.centerText(mon, 1, math.floor(H_/2), W_, "No history yet. Logging starts after first interval.", colors.lightGray)
            return
        end
        -- Aggregate per-host: latest value, totals over window
        local agg = {}
        for _, r in ipairs(rows) do
            local k = r.role .. "/" .. r.host
            local a = agg[k] or { role=r.role, host=r.host, samples=0, sumIn=0, sumOut=0, sumProd=0,
                                   firstE=nil, lastE=nil, firstTs=r.ts, lastTs=r.ts, lastInput=0, lastOutput=0, lastProd=0 }
            if r.energy then if not a.firstE then a.firstE = r.energy end; a.lastE = r.energy end
            a.sumIn   = a.sumIn   + (r.input  or 0)
            a.sumOut  = a.sumOut  + (r.output or 0)
            a.sumProd = a.sumProd + (r.prod   or 0)
            a.lastInput  = r.input  or a.lastInput
            a.lastOutput = r.output or a.lastOutput
            a.lastProd   = r.prod   or a.lastProd
            a.samples = a.samples + 1
            a.lastTs = r.ts
            agg[k] = a
        end
        local list = {}
        for _, a in pairs(agg) do list[#list+1] = a end
        table.sort(list, function(x, y) if x.role ~= y.role then return x.role < y.role end; return x.host < y.host end)
        -- Compact rate formatters: shared SI prefix per pair, suffix carried in header.
        local function pickPrefix(maxAbs)
            local i, n = 1, maxAbs
            while n >= 1000 and i < #SI do n = n / 1000; i = i + 1 end
            return SI[i], math.pow and math.pow(1000, i-1) or (1000 ^ (i-1))
        end
        local function fmtPair(aV, bV)
            local af = util.toFE(aV or 0); local bf = util.toFE(bV or 0)
            local p, div = pickPrefix(math.max(math.abs(af), math.abs(bf), 1))
            return string.format("%.2f/%.2f %s", af/div, bf/div, p)
        end
        local function fmtOne(v)
            local f = util.toFE(v or 0)
            local p, div = pickPrefix(math.max(math.abs(f), 1))
            return string.format("%.2f %s", f/div, p)
        end
        local function fmtDiff(dE)
            local f = util.toFE(math.abs(dE or 0))
            local p, div = pickPrefix(math.max(f, 1))
            return string.format("%s%.2f %s", (dE or 0) < 0 and "-" or "+", f/div, p)
        end
        local y = 7
        if W_ >= 60 then
            -- Wide layout: single row per host
            local headers = ("%-18s %-15s %-10s %-10s %-12s"):format(
                "Host", "Now I/O FE/t", "Avg-I FE/t", "Avg-O FE/t", "Stored \xC4 FE")
            mon.setBackgroundColor(colors.black); mon.setTextColor(colors.cyan)
            mon.setCursorPos(2, y); mon.write(headers:sub(1, W_ - 2))
            y = y + 1
            for _, a in ipairs(list) do
                if y > H_ - 3 then break end
                local now    = fmtPair(a.lastInput, a.lastOutput)
                local avgIn  = fmtOne(a.sumIn  / math.max(1, a.samples))
                local avgOut = fmtOne(a.sumOut / math.max(1, a.samples))
                local diff = ""
                if a.firstE and a.lastE then diff = fmtDiff(a.lastE - a.firstE) end
                local line = ("%-18s %-15s %-10s %-10s %-12s"):format(
                    (a.role .. ":" .. a.host):sub(1, 18), now, avgIn, avgOut, diff)
                mon.setBackgroundColor(colors.black); mon.setTextColor(colors.white)
                mon.setCursorPos(2, y); mon.write(line:sub(1, W_ - 2))
                y = y + 1
            end
        else
            -- Narrow layout: 2 lines per host (label/values).
            mon.setBackgroundColor(colors.black); mon.setTextColor(colors.cyan)
            mon.setCursorPos(2, y); mon.write(("rates FE/t  storage \xC4 FE"):sub(1, W_ - 2))
            y = y + 1
            for _, a in ipairs(list) do
                if y > H_ - 3 then break end
                local title = (a.role .. ":" .. a.host):sub(1, W_ - 2)
                mon.setBackgroundColor(colors.black); mon.setTextColor(colors.white)
                mon.setCursorPos(2, y); mon.write(title); y = y + 1
                if y > H_ - 3 then break end
                local now    = fmtPair(a.lastInput, a.lastOutput)
                local avgIn  = fmtOne(a.sumIn  / math.max(1, a.samples))
                local avgOut = fmtOne(a.sumOut / math.max(1, a.samples))
                local diff = ""
                if a.firstE and a.lastE then diff = fmtDiff(a.lastE - a.firstE) end
                local line = ("now %s  avg %s/%s  %s"):format(now, avgIn, avgOut, diff)
                mon.setTextColor(colors.lightGray)
                mon.setCursorPos(4, y); mon.write(line:sub(1, W_ - 4))
                y = y + 1
            end
        end
        -- Sparkline of induction storage over the window (if available)
        local indSeries = {}
        for _, r in ipairs(rows) do
            if r.role == "induction" and r.energy then indSeries[#indSeries+1] = r.energy end
        end
        if #indSeries >= 2 and y < H_ - 4 then
            mon.setBackgroundColor(colors.black); mon.setTextColor(colors.cyan)
            mon.setCursorPos(2, y + 1); mon.write("Stored (induction):")
            W.sparkline(mon, 2, y + 2, math.max(2, W_ - 4), math.max(2, H_ - y - 5), indSeries, colors.cyan)
        end
    end
    local function fmtMetric(fmt, v)
        if fmt == "energy"  then return util.fmtEnergy(v or 0)
        elseif fmt == "rate"    then return util.fmtRate(v or 0)
        elseif fmt == "percent" then return util.fmtPercent(v or 0)
        elseif fmt == "temp"    then return util.fmtTemp(v or 0)
        elseif fmt == "mbpt"    then return string.format("%.2f mB/t", v or 0) end
        return tostring(v or 0)
    end
    local function findPanelMetric(role, field)
        for _, m in ipairs(PANEL_METRICS) do
            if m.role == role and m.field == field then return m end
        end
        return { role=role, field=field, label=(role or "?").."."..(field or "?"), fmt="raw", color=colors.lime }
    end
    local function drawPanel(W_, H_)
        local m = findPanelMetric(cfg.panelRole, cfg.panelField)
        local label = (cfg.panelLabel and #cfg.panelLabel > 0) and cfg.panelLabel or m.label
        local k = key(cfg.panelRole or "", cfg.panelHost or "")
        local h = hosts[k]
        local valStr, color
        if not h or not h.last then
            valStr = "--"; color = colors.lightGray
        else
            valStr = fmtMetric(m.fmt, h.last[cfg.panelField])
            local sev = h.sev or 0
            color = sev >= 2 and SEV_COLORS[sev] or m.color
        end
        -- Top-aligned: row 1 label, row 3 big value, row 5 companion (optional)
        W.centerText(mon, 1, 1, W_, label, colors.lightGray)
        local valY = math.min(3, math.max(2, math.floor(H_ * 0.35)))
        W.centerText(mon, 1, valY, W_, valStr, color)
        -- Companion line for induction I/O so panels show Input + Output together
        if h and h.last and cfg.panelRole == "induction" then
            local d = h.last
            local pair
            if cfg.panelField == "input" then pair = "Out " .. util.fmtRate(d.output or 0)
            elseif cfg.panelField == "output" then pair = "In " .. util.fmtRate(d.input or 0)
            elseif cfg.panelField == "net" then pair = ("In %s  Out %s"):format(util.fmtRate(d.input or 0), util.fmtRate(d.output or 0))
            elseif cfg.panelField == "energy" or cfg.panelField == "pct" then pair = ("In %s  Out %s"):format(util.fmtRate(d.input or 0), util.fmtRate(d.output or 0))
            end
            if pair and (valY + 2) <= (H_ - 2) then
                W.centerText(mon, 1, valY + 2, W_, pair, colors.white)
            end
        end
        -- Mini sparkline a couple of rows above the bottom (leaves a row for hostname)
        if h and h.ringMain and H_ >= 5 then
            W.sparkline(mon, 2, H_ - 1, math.max(2, W_ - 2), 1, h.ringMain:values(), m.color)
        end
        -- Host name (or diagnostic) at the very bottom
        local hostLabel = (h and (h.displayName or h.hostName)) or cfg.panelHost or "?"
        if not h then
            local seen = {}
            for _, ho in pairs(hosts) do if ho.role == cfg.panelRole then seen[#seen + 1] = ho.hostName end end
            if #seen > 0 then
                hostLabel = "no '" .. (cfg.panelHost or "?") .. "' (have: " .. table.concat(seen, ",") .. ")"
            else
                hostLabel = "no telemetry from " .. (cfg.panelRole or "?")
            end
        end
        mon.setBackgroundColor(colors.black); mon.setTextColor(colors.gray)
        mon.setCursorPos(2, H_); mon.write(hostLabel:sub(1, math.max(1, W_ - 2)))
    end
    local function render()
        local W_, H_ = mon.getSize()
        mon.setBackgroundColor(colors.black); mon.clear()
        btnRects = {}
        if cfg.profile == "panel" then
            drawPanel(W_, H_); return
        end
        if cfg.profile == "solo" then
            local r = cfg.soloRole or "fission"
            if cfg.soloHost and #cfg.soloHost > 0 then selectedHost[r] = cfg.soloHost end
            drawDetail(r, W_, H_)
            drawFooter(W_, H_); return
        end
        drawHeader(W_, H_)
        if activeTab == "overview" then drawOverview(W_, H_)
        elseif activeTab == "scram" then drawScram(W_, H_)
        elseif activeTab == "history" then drawHistory(W_, H_)
        else drawDetail(activeTab, W_, H_) end
        drawFooter(W_, H_)
    end
    local function sparkValue(role, d)
        if role == "induction" then return d.energy or 0
        elseif role == "fission" then return d.temp or 0
        elseif role == "turbine" then return d.prod or 0
        elseif role == "boiler"  then return d.boilRate or 0
        elseif role == "fusion"  then return d.plasmaTemp or 0 end
        return 0
    end
    local lastAlarmSev = 0          -- legacy global, kept so existing references still resolve
    local hostAlarmSev = {}         -- per-host previous sev so the bell only rings on a real rising edge
    local localScramCfg = {}  -- key=role/host -> editable copy of host scram rules
    local lastMatrixScramAt = 0
    local function rednetLoop()
    local function rednetLoop()
        while true do
            local _, msg = rednet.receive(protocol.PROTOCOL)
            if type(msg) == "table" and msg.kind == "telemetry" then
                local h = getOrCreate(msg.role, msg.host)
                local prevData = h.last or {}
                local prevSev  = h.sev or 0
                local wasOnline = h.online
                local firstSeen = (h.bootstrapped ~= true)
                h.last = msg.data or {}; h.sev = msg.severity or 0
                h.msgs = msg.messages or {}; h.seen = os.epoch("utc")
                h.online = true
                if msg.displayName and #msg.displayName > 0 then h.displayName = msg.displayName end
                -- EMA smoothing for induction I/O so display rates don't pulse with
                -- single-tick fluctuations from Mekanism's getLastInput/Output.
                if msg.role == "induction" and cfg.smoothInduction ~= false then
                    local a = cfg.smoothAlpha or 0.25
                    local rawIn  = h.last.input  or 0
                    local rawOut = h.last.output or 0
                    h.smInput  = h.smInput  and (h.smInput  + a * (rawIn  - h.smInput )) or rawIn
                    h.smOutput = h.smOutput and (h.smOutput + a * (rawOut - h.smOutput)) or rawOut
                    h.last.rawInput  = rawIn
                    h.last.rawOutput = rawOut
                    h.last.input  = h.smInput
                    h.last.output = h.smOutput
                    h.last.net    = h.smInput - h.smOutput
                end
                -- Recovery line if this host was previously marked offline by janitorLoop.
                if wasOnline == false then
                    -- If a remote reboot was in flight, announce success and clear state.
                    local rkey = msg.role .. "/" .. msg.host
                    if rebootState[rkey] and rebootState[rkey].stage == "sent" then
                        pcall(playVoice, "system_host_reboot_ok", h.displayName or msg.host)
                        rebootState[rkey] = nil
                    else
                        pcall(playVoice, "system_host_back", h.displayName or msg.host)
                    end
                    if msg.role == "turbine" then pcall(playVoice, "turbine_back_online", h.displayName or msg.host) end
                end
                -- Drop local scram-cfg cache so we always edit against latest host state.
                localScramCfg[msg.role .. "/" .. msg.host] = nil
                h.ringMain:push(sparkValue(msg.role, h.last))
                -- Bell ringer: ring once when THIS host crosses up into sev>=2 (or escalates 2->3).
                -- Previously this used a single global `lastAlarmSev`, which got reset to 0 by any
                -- other host's normal-sev telemetry, causing a ding on every subsequent turbine
                -- alarm telemetry ("Steam buffer almost full" repeating despite the notify dedupe).
                local prevHostSev = hostAlarmSev[msg.host] or 0
                if cfg.speakerOnWarn and speaker and h.sev >= 2 and h.sev > prevHostSev then
                    speaker.playSound(h.sev == 3 and "minecraft:block.beacon.deactivate" or "minecraft:block.note_block.bell", 3, 0.5)
                end
                hostAlarmSev[msg.host] = h.sev
                lastAlarmSev = h.sev
                -- Voice triggers (PA system) -- skip the very first telemetry from a host:
                -- prev is empty so every threshold "edge" would fire spuriously (e.g.
                -- fission_burn_max when reactor is off but setpoint stuck at max).
                if not firstSeen then
                    pcall(evalVoiceTriggers, msg.role, msg.host, prevData, h.last, prevSev, h.sev)
                else
                    h.bootstrapped = true
                    if cfg.voiceDebug then print("[voice/eval] bootstrap " .. msg.role .. "/" .. msg.host) end
                end
                -- System rule: auto-SCRAM all fission reactors when induction matrix is (nearly) full.
                if cfg.scramOnMatrixFull and msg.role == "induction" then
                    local pct = h.last.pct or 0
                    if pct >= (cfg.matrixFullThreshold or 99.8) then
                        local now = os.epoch("utc")
                        if now - lastMatrixScramAt > 5000 then
                            lastMatrixScramAt = now
                            local n = 0
                            for _, ho in pairs(hosts) do
                                if ho.role == "fission" then sendCmd(ho.hostName, "scram"); n = n + 1 end
                            end
                            print(("[display] AUTO-SCRAM: matrix %.1f%% >= %.1f%% (sent to %d fission host(s))"):format(pct, cfg.matrixFullThreshold or 99.8, n))
                            local resolved = util.resolveAlarm(cfg.alarmName)
                            if speaker and resolved and resolved.path then queueAudio(resolved.path) end
                            notify(3, "matrix-full", ("AUTO-SCRAM: matrix %.1f%% (>=%g%%)"):format(pct, cfg.matrixFullThreshold or 99.8))
                        end
                    end
                end
                -- Graceful low-storage warning (notify only, no SCRAM)
                if cfg.warnOnMatrixLow and msg.role == "induction" then
                    local pct = h.last.pct or 0
                    if pct <= (cfg.matrixLowThreshold or 10) then
                        notify(2, "matrix-low", ("Storage low: %.1f%%"):format(pct))
                    end
                end
                -- Severity escalation chat notify (high-severity host events)
                if h.sev >= (cfg.chatMinSeverity or 2) and h.msgs and h.msgs[1] then
                    notify(h.sev, msg.role .. ":" .. msg.host,
                        ("[%s] %s: %s"):format(L.sevLabels[h.sev] or "?", h.displayName or h.hostName, h.msgs[1]))
                end
            end
        end
    end
    local function renderLoop()
        while true do
            local ok, err = pcall(render)
            if not ok then
                mon.setBackgroundColor(colors.black); mon.clear()
                mon.setTextColor(colors.red); mon.setCursorPos(2, 2); mon.write(L.renderErr .. tostring(err))
            end
            sleep(1 / cfg.refreshHz)
        end
    end
    -- Local mirror of last seen scram cfg per host (for editing before sending)
    local function getLocalRules(ho)
        local k = ho.role .. "/" .. ho.hostName
        if not localScramCfg[k] and type(ho.last and ho.last.scramCfg) == "table" then
            local copy = {}
            for i, ru in ipairs(ho.last.scramCfg) do
                copy[i] = { id=ru.id, enabled=ru.enabled, op=ru.op, field=ru.field, threshold=ru.threshold, label=ru.label, unit=ru.unit, latch=ru.latch, step=ru.step or 1 }
            end
            localScramCfg[k] = copy
        end
        return localScramCfg[k]
    end
    local function findHost(role, hostName)
        return hosts[role .. "/" .. hostName]
    end
    local function thresholdStep(ru)
        if ru.step and ru.step > 0 then return ru.step end
        local t = ru.threshold or 0
        if t >= 1e6 then return t * 0.05 end
        if t >= 100 then return 10 end
        if t >= 10  then return 1 end
        return 0.5
    end
    local function inputLoop()
        while true do
            local ev, _, x, y = os.pullEvent()
            if ev == "monitor_touch" then
                local handled = false
                for _, r in ipairs(tabRects) do
                    if y == r.y and x >= r.x and x < r.x + r.w then activeTab = r.name; handled = true; break end
                end
                if not handled then
                    for _, b in ipairs(btnRects) do
                        if y == b.y and x >= b.x and x < b.x + b.w then
                            local k = b.kind; local c = b.ctx or {}
                            if k == "cmd" then
                                sendCmd(c.target, c.action, {})
                                if c.action == "scram" then pcall(playVoice, "fission_scram_manual", c.target) end
                            elseif k == "burn" then
                                local newRate = math.max(0, math.min(c.max or 1e6, (c.current or 0) + (c.delta or 0)))
                                sendCmd(c.target, "setBurnRate", { rate=newRate })
                            elseif k == "inj" then
                                local newRate = math.max(0, (c.current or 0) + (c.delta or 0))
                                sendCmd(c.target, "setInjectionRate", { rate=newRate })
                            elseif k == "alarm" then
                                playTestAlarm()
                                pcall(playVoice, "system_alarm_test")
                            elseif k == "alarmCycle" then
                                cycleAlarmName()
                            elseif k == "matrixToggle" then
                                cfg.scramOnMatrixFull = not cfg.scramOnMatrixFull
                                util.saveConfig("/cfg/display.cfg", cfg)
                                print("[display] scramOnMatrixFull -> " .. tostring(cfg.scramOnMatrixFull))
                            elseif k == "matrixAdj" then
                                local step = (c.dir or 1) * 0.1
                                cfg.matrixFullThreshold = math.max(50, math.min(100, (cfg.matrixFullThreshold or 99.8) + step))
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "lowToggle" then
                                cfg.warnOnMatrixLow = not cfg.warnOnMatrixLow
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "lowAdj" then
                                local step = (c.dir or 1) * 1
                                cfg.matrixLowThreshold = math.max(0, math.min(50, (cfg.matrixLowThreshold or 10) + step))
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "throttleToggle" then
                                cfg.autoThrottle = not cfg.autoThrottle
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "throttleAdj" then
                                local step = (c.dir or 1) * 5
                                cfg.throttleTarget = math.max(20, math.min(98, (cfg.throttleTarget or 80) + step))
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "restartToggle" then
                                cfg.autoRestart = not cfg.autoRestart
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "restartAdj" then
                                local step = (c.dir or 1) * 5
                                cfg.autoRestartBelow = math.max(20, math.min(95, (cfg.autoRestartBelow or 85) + step))
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "lowFuelToggle" then
                                cfg.lowFuelAutoStop = not cfg.lowFuelAutoStop
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "lowFuelAdj" then
                                local step = (c.dir or 1) * 1
                                cfg.lowFuelStopThreshold = math.max(1, math.min(30, (cfg.lowFuelStopThreshold or 6) + step))
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "chatToggle" then
                                cfg.chatNotify = not cfg.chatNotify
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "chatAdj" then
                                local step = (c.dir or 1) * 1
                                cfg.chatMinSeverity = math.max(1, math.min(3, (cfg.chatMinSeverity or 2) + step))
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "voiceTogglePanel" then
                                cfg.voicePanelOpen = not cfg.voicePanelOpen
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "voiceToggleLine" then
                                cfg.voice = cfg.voice or {}
                                cfg.voice[c.id] = cfg.voice[c.id] or {}
                                cfg.voice[c.id].enabled = not cfg.voice[c.id].enabled
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "voiceVolAdj" then
                                cfg.voice = cfg.voice or {}
                                cfg.voice[c.id] = cfg.voice[c.id] or {}
                                local v = cfg.voice[c.id].volume or cfg.voiceDefaultVolume or 2.5
                                v = math.max(0.5, math.min(3.0, v + (c.dir or 1) * 0.5))
                                cfg.voice[c.id].volume = v
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "voicePreview" then
                                if lastVoicePlayed then lastVoicePlayed[c.id] = nil end
                                pcall(playVoice, c.id, "preview", true)
                            elseif k == "voicePagePrev" then
                                local total = #VOICE_LINES
                                local perPage = cfg.voicePerPage or 8
                                local pages = math.max(1, math.ceil(total / perPage))
                                cfg.voicePage = ((cfg.voicePage or 1) - 2) % pages + 1
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "voicePageNext" then
                                local total = #VOICE_LINES
                                local perPage = cfg.voicePerPage or 8
                                local pages = math.max(1, math.ceil(total / perPage))
                                cfg.voicePage = ((cfg.voicePage or 1)) % pages + 1
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "rebootTogglePanel" then
                                cfg.rebootPanelOpen = not cfg.rebootPanelOpen
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "rebootAutoToggle" then
                                cfg.autoReboot = not cfg.autoReboot
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "rebootSilentAdj" then
                                local step = (c.dir or 1) * 30
                                cfg.autoRebootSilent = math.max(30, math.min(900, (cfg.autoRebootSilent or 120) + step))
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "rebootHost" then
                                sendCmd(c.target, "reboot", {})
                                pcall(playVoice, "system_host_reboot_manual", c.host or c.target)
                                local rkey = (c.role or "?") .. "/" .. c.target
                                rebootState[rkey] = { stage="sent", at=os.epoch("utc"), manual=true }
                                notify(1, "reboot:"..c.target, "Reboot sent to " .. (c.host or c.target))
                            elseif k == "rebootAll" then
                                local n = 0
                                for _, ho in pairs(hosts) do
                                    sendCmd(ho.hostName, "reboot", {})
                                    rebootState[ho.role .. "/" .. ho.hostName] = { stage="sent", at=os.epoch("utc"), manual=true }
                                    n = n + 1
                                end
                                pcall(playVoice, "system_host_reboot_manual", "all hosts")
                                notify(2, "reboot:all", ("Reboot sent to %d host(s)"):format(n))
                            elseif k == "rebootPagePrev" then
                                local total = 0; for _ in pairs(hosts) do total = total + 1 end
                                local perPage = cfg.rebootPerPage or 8
                                local pages = math.max(1, math.ceil(math.max(1,total) / perPage))
                                cfg.rebootPage = ((cfg.rebootPage or 1) - 2) % pages + 1
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "rebootPageNext" then
                                local total = 0; for _ in pairs(hosts) do total = total + 1 end
                                local perPage = cfg.rebootPerPage or 8
                                local pages = math.max(1, math.ceil(math.max(1,total) / perPage))
                                cfg.rebootPage = ((cfg.rebootPage or 1)) % pages + 1
                                util.saveConfig("/cfg/display.cfg", cfg)
                            elseif k == "testScram" then
                                -- Manual SCRAM test: trip the reactor AND force a chat
                                -- notification (bypassing on/off + min-severity gates).
                                sendCmd(c.target, "testScram", {})
                                pcall(playVoice, "fission_scram_manual", c.host or c.target)
                                notify(3, "test:scram",
                                    ("TEST SCRAM triggered on %s '%s'"):format(c.role or "reactor", c.host or c.target or "?"),
                                    true)
                            elseif k == "testChat" then
                                notify(2, "test:chat",
                                    ("Chat-notify test from display PC (%s '%s')"):format(c.role or "-", c.host or "-"),
                                    true)
                                print("[display] TEST CHAT requested.")
                            elseif k == "preset" then
                                -- Presets removed; left as a no-op to ignore stale clicks.
                                print("[display] preset click ignored (presets removed)")
                            elseif k == "selPrev" or k == "selNext" then
                                local list = listByRole(c.role)
                                if #list > 1 then
                                    local cur = selectedHost[c.role]
                                    local idx = 1
                                    for i, ho in ipairs(list) do if ho.hostName == cur then idx = i; break end end
                                    local dir = (k == "selPrev") and -1 or 1
                                    idx = ((idx - 1 + dir) % #list) + 1
                                    selectedHost[c.role] = list[idx].hostName
                                end
                            elseif k == "ovPrev" then overviewPage = overviewPage - 1
                            elseif k == "ovNext" then overviewPage = overviewPage + 1
                            elseif k == "ruleToggle" then
                                local ho = findHost(c.role, c.target); if ho then
                                    local rules = getLocalRules(ho)
                                    if rules and rules[c.ruleIdx] then
                                        rules[c.ruleIdx].enabled = not rules[c.ruleIdx].enabled
                                        sendCmd(c.target, "updateScramCfg", { rules=rules })
                                    end
                                end
                            elseif k == "ruleAdj" then
                                local ho = findHost(c.role, c.target); if ho then
                                    local rules = getLocalRules(ho)
                                    if rules and rules[c.ruleIdx] then
                                        local ru = rules[c.ruleIdx]
                                        ru.threshold = math.max(0, (ru.threshold or 0) + (c.dir or 1) * thresholdStep(ru))
                                        sendCmd(c.target, "updateScramCfg", { rules=rules })
                                    end
                                end
                            end
                            break
                        end
                    end
                end
            end
        end
    end
    local function janitorLoop()
        while true do
            sleep(10)
            local now = os.epoch("utc")
            for k, h in pairs(hosts) do
                if now - h.seen > 30000 then
                    if h.online ~= false then
                        h.online = false
                        pcall(playVoice, "system_host_lost", (h.displayName or h.hostName or k))
                        if h.role == "turbine" then
                            pcall(playVoice, "turbine_offline", h.displayName or h.hostName or k)
                        end
                    end
                    -- Hard-prune hosts that have been offline for over 5 minutes.
                    if now - h.seen > 5 * 60 * 1000 then hosts[k] = nil end
                end
            end
        end
    end
    local function audioLoop()
        local ok, dfpwm = pcall(require, "cc.audio.dfpwm")
        if not ok then
            print("[display] cc.audio.dfpwm not available -- DFPWM playback disabled.")
            while true do os.pullEvent("audio_play_request") end
        end
        while true do
            if #audioQueue == 0 then os.pullEvent("audio_play_request") end
            local item = table.remove(audioQueue, 1)
            -- Items can be plain string paths (legacy alarm) or tables {path, vol, sev, id}.
            local path, vol, id
            if type(item) == "string" then path, vol, id = item, 3.0, "alarm"
            elseif type(item) == "table" then path, vol, id = item.path, item.vol or 2.5, item.id or "?"
            end
            if not path then
                print("[audio] dropped: nil path")
            elseif not speaker then
                print("[audio] dropped: no speaker peripheral (" .. tostring(id) .. " " .. tostring(path) .. ")")
            elseif not fs.exists(path) then
                print("[audio] dropped: missing file " .. path)
            else
                if cfg.voiceDebug then print(("[audio] playing %s vol=%.2f path=%s"):format(tostring(id), vol or 0, path)) end
                local decoder = dfpwm.make_decoder()
                local h = fs.open(path, "rb")
                if h then
                    while true do
                        local chunk = h.read(16 * 1024)
                        if not chunk then break end
                        local audio = decoder(chunk)
                        while not speaker.playAudio(audio, vol) do
                            os.pullEvent("speaker_audio_empty")
                        end
                    end
                    h.close()
                    if cfg.voiceDebug then print("[audio] done " .. tostring(id)) end
                else
                    print("[audio] dropped: fs.open failed " .. path)
                end
            end
        end
    end
    local function throttleLoop()
        while true do sleep(cfg.throttleEvery or 5); pcall(autoThrottleTick) end
    end
    local function restartLoop()
        while true do sleep(5); pcall(autoRestartTick) end
    end
    local function lowFuelStopLoop()
        while true do sleep(5); pcall(lowFuelStopTick) end
    end
    -- Auto-reboot silent hosts. After autoRebootSilent seconds without telemetry,
    -- broadcast a reboot command (one attempt). After another autoRebootSilent
    -- seconds, if the host is still silent, mark it failed and play the
    -- system_host_reboot_fail voice line. The host comes back -> the rednet handler
    -- announces success and clears state.
    local function rebootTick()
        if not cfg.autoReboot then return end
        local silentMs = (cfg.autoRebootSilent or 120) * 1000
        local now = os.epoch("utc")
        for k, h in pairs(hosts) do
            local age = now - (h.seen or 0)
            local rs = rebootState[k]
            if not rs then
                if age >= silentMs then
                    -- First attempt: send reboot.
                    rebootState[k] = { stage="sent", at=now, manual=false }
                    sendCmd(h.hostName, "reboot", {})
                    pcall(playVoice, "system_host_reboot", h.displayName or h.hostName)
                    notify(2, "reboot-auto:"..h.hostName,
                        ("Auto-reboot %s after %ds silence"):format(h.displayName or h.hostName, math.floor(age/1000)))
                end
            elseif rs.stage == "sent" then
                if (now - rs.at) >= silentMs then
                    -- One-shot: do not retry. Mark failed, alert.
                    rs.stage = "failed"
                    pcall(playVoice, "system_host_reboot_fail", h.displayName or h.hostName)
                    notify(3, "reboot-fail:"..h.hostName,
                        ("Auto-reboot FAILED on %s; manual check required"):format(h.displayName or h.hostName))
                end
            end
        end
    end
    local function rebootLoop()
        while true do sleep(5); pcall(rebootTick) end
    end
    local function historyLoop()
        sleep(5) -- give hosts a moment to broadcast first telemetry, then snapshot once
        pcall(logHistorySnapshot)
        while true do sleep(cfg.historyEvery or 60); pcall(logHistorySnapshot) end
    end
    -- Startup status sweep: ~1s after boot, walk every known host and voice
    -- whichever current-state lines best summarize each one. One-shot, then idles.
    local function startupStatusSweep()
        sleep(1)
        for _, h in pairs(hosts) do
            local d = h.last or {}; local role = h.role
            if role == "induction" then
                local pct = d.pct or 0
                if pct >= 100 then pcall(playVoice, "matrix_full")
                elseif pct >= 95 then pcall(playVoice, "matrix_high_95")
                elseif pct <= 1  then pcall(playVoice, "matrix_empty")
                elseif pct <= 10 then pcall(playVoice, "matrix_low_10")
                elseif pct <= 25 then pcall(playVoice, "matrix_low_25") end
                local net = (d.input or 0) - (d.output or 0)
                if net < 0 then pcall(playVoice, "matrix_net_negative") end
            elseif role == "fission" then
                if d.status == true then pcall(playVoice, "fission_started")
                else pcall(playVoice, "fission_stopped") end
                if d.latched then pcall(playVoice, "fission_latched") end
                if (d.damage or 0) >= 42 then pcall(playVoice, "fission_damage_crit")
                elseif (d.damage or 0) >= 25 then pcall(playVoice, "fission_damage_warn") end
                if (d.coolPct or 100) <= 15 then pcall(playVoice, "fission_coolant_crit")
                elseif (d.coolPct or 100) <= 30 then pcall(playVoice, "fission_coolant_low") end
                if (d.fuelPct or 100) <= 5 then pcall(playVoice, "fission_fuel_crit")
                elseif (d.fuelPct or 100) <= 25 then pcall(playVoice, "fission_fuel_low") end
                if (d.wastePct or 0) >= 95 then pcall(playVoice, "fission_waste_full")
                elseif (d.wastePct or 0) >= 80 then pcall(playVoice, "fission_waste_80")
                elseif (d.wastePct or 0) >= 60 then pcall(playVoice, "fission_waste_60") end
            elseif role == "turbine" then
                if (d.steamPct or 0) >= 99 then pcall(playVoice, "turbine_steam_full")
                elseif (d.steamPct or 0) >= 95 then pcall(playVoice, "turbine_steam_high") end
                if (d.energyPct or 0) >= 99 then pcall(playVoice, "turbine_energy_full") end
            elseif role == "boiler" then
                if (d.waterPct or 100) <= 10 then pcall(playVoice, "boiler_water_crit")
                elseif (d.waterPct or 100) <= 25 then pcall(playVoice, "boiler_water_low") end
                if (d.steamPct or 0) >= 95 then pcall(playVoice, "boiler_steam_full") end
                if (d.heatedPct or 0) >= 95 then pcall(playVoice, "boiler_heated_full") end
            elseif role == "fusion" then
                if d.status == true then pcall(playVoice, "fusion_ignited")
                else pcall(playVoice, "fusion_offline") end
            end
        end
        while true do sleep(3600) end -- idle forever; parallel.waitForAny exits on any return
    end
    local function voiceTermLoop()
        while true do
            io.write("voice> "); local line = read()
            if not line or #line == 0 then
                -- nothing
            else
                local args = {}
                for tok in line:gmatch("%S+") do args[#args+1] = tok end
                local cmd = args[1]
                if cmd == "list" then
                    for _, vl in ipairs(VOICE_LINES) do
                        local vc = (cfg.voice and cfg.voice[vl.id]) or {}
                        print(("[%s] %s sev=%d %s vol=%.1f"):format(
                            vc.enabled and "X" or " ", vl.id, vl.sev,
                            vl.category, vc.volume or cfg.voiceDefaultVolume or 2.5))
                    end
                elseif cmd == "on" or cmd == "off" then
                    cfg.voice = cfg.voice or {}; cfg.voice[args[2] or ""] = cfg.voice[args[2] or ""] or {}
                    cfg.voice[args[2] or ""].enabled = (cmd == "on")
                    util.saveConfig("/cfg/display.cfg", cfg); print("OK")
                elseif cmd == "play" then
                    if lastVoicePlayed then lastVoicePlayed[args[2] or ""] = nil end
                    playVoice(args[2] or "", "term", true)
                elseif cmd == "vol" then
                    cfg.voice = cfg.voice or {}; cfg.voice[args[2] or ""] = cfg.voice[args[2] or ""] or {}
                    cfg.voice[args[2] or ""].volume = tonumber(args[3]) or 2.5
                    util.saveConfig("/cfg/display.cfg", cfg); print("OK")
                elseif cmd == "cooldown" then
                    cfg.voice = cfg.voice or {}; cfg.voice[args[2] or ""] = cfg.voice[args[2] or ""] or {}
                    cfg.voice[args[2] or ""].cooldown = tonumber(args[3]) or 60
                    util.saveConfig("/cfg/display.cfg", cfg); print("OK")
                elseif cmd == "path" then
                    print((cfg.voiceFolder or "/voice/ru/") .. (args[2] or "") .. ".dfpwm")
                elseif cmd == "debug" then
                    cfg.voiceDebug = (args[2] == "on")
                    util.saveConfig("/cfg/display.cfg", cfg)
                    print("[voice] debug=" .. tostring(cfg.voiceDebug))
                else
                    print("voice cmds: list | on <id> | off <id> | play <id> | vol <id> <n> | cooldown <id> <s> | path <id> | debug on/off")
                end
            end
        end
    end
    print(L.displayOnline .. table.concat(TAB_ORDER, ", "))
    pcall(playVoice, "system_startup", "boot", true)
    parallel.waitForAny(rednetLoop, renderLoop, inputLoop, janitorLoop, audioLoop, throttleLoop, restartLoop, lowFuelStopLoop, rebootLoop, historyLoop, voiceTermLoop, startupStatusSweep)
end

------------------------------------------------------------
-- ROLE ROUTER + SETUP
------------------------------------------------------------
local ROLES = {
    display = display,
    induction = hostInduction,
    fission = hostFission,
    turbine = hostTurbine,
    boiler = hostBoiler,
    fusion = hostFusion,
}
local ROLE_LIST = { "display", "induction", "fission", "turbine", "boiler", "fusion" }

local function readSavedRole()
    if not fs.exists("/cfg/role.cfg") then return nil end
    local f = fs.open("/cfg/role.cfg", "r"); local s = f.readAll() or ""; f.close()
    return s:gsub("%s+$", "")
end

local function doSetup()
    term.clear(); term.setCursorPos(1, 1)
    print(L.setupTitle)
    print()
    for i, r in ipairs(ROLE_LIST) do print(("  [%d] %s"):format(i, r)) end
    print()
    write(L.pickRole)
    local n = tonumber(read())
    if not n or not ROLE_LIST[n] then print(L.invalidChoice); return end
    local role = ROLE_LIST[n]
    if not fs.exists("/cfg") then fs.makeDir("/cfg") end
    local f = fs.open("/cfg/role.cfg", "w"); f.write(role); f.close()

    write(L.askName)
    local dn = read()
    if dn and #dn > 0 then
        local f2 = fs.open("/cfg/displayname.cfg", "w"); f2.write(dn); f2.close()
    end

    write(L.askComputerLabel)
    local lbl = read()
    if lbl and #lbl > 0 then os.setComputerLabel(lbl) end

    -- Display-only profile wizard
    if role == "display" then
        local cur = util.loadConfig("/cfg/display.cfg", {
            monitorScale=0.5, refreshHz=5, sparkPoints=120, speakerOnWarn=true,
            allowControl=true, wideThreshold=60, burnStep=1, burnStepBig=10, injectionStep=2,
            alarmName="default",
            profile="full",
            soloRole="fission", soloHost="fission-1",
            panelRole="induction", panelHost="induction-1", panelField="energy",
            panelLabel="", panelColor="lime", panelScale=1.5,
        })
        print()
        print("Display profile:")
        print("  [1] Full     -- all tabs (overview / induction / fission / ... / SCRAM)")
        print("  [2] Solo     -- one reactor / system, full detail (good for 3x2)")
        print("  [3] Panel    -- single big metric (good for 1x1 wall tile)")
        write("Pick profile [1-3, default 1]: ")
        local pn = tonumber(read() or "")
        local profile = "full"
        if pn == 2 then profile = "solo"
        elseif pn == 3 then profile = "panel" end
        cur.profile = profile

        if profile == "solo" then
            print()
            print("Pick the role this display will show:")
            local soloOpts = { "induction", "fission", "turbine", "boiler", "fusion" }
            for i, r in ipairs(soloOpts) do print(("  [%d] %s"):format(i, r)) end
            write("Role [1-" .. #soloOpts .. "]: ")
            local rn = tonumber(read() or "")
            if rn and soloOpts[rn] then cur.soloRole = soloOpts[rn] end
            write("Host name (e.g. " .. cur.soloRole .. "-1): ")
            local hn = read()
            if hn and #hn > 0 then cur.soloHost = hn end
        elseif profile == "panel" then
            print()
            print("Pick a metric to display:")
            for i, m in ipairs(PANEL_METRICS) do
                print(("  [%2d] %-7s  %s"):format(i, m.role, m.label))
            end
            write("Metric [1-" .. #PANEL_METRICS .. "]: ")
            local mn = tonumber(read() or "")
            local m = PANEL_METRICS[mn] or PANEL_METRICS[1]
            cur.panelRole = m.role
            cur.panelField = m.field
            write("Host name (e.g. " .. m.role .. "-1): ")
            local hn = read()
            if hn and #hn > 0 then cur.panelHost = hn end
            write("Custom label (blank = '" .. m.label .. "'): ")
            local cl = read()
            cur.panelLabel = cl or ""
            write("Text scale [0.5..5, default 1.5]: ")
            local sc = tonumber(read() or "")
            if sc and sc >= 0.5 and sc <= 5 then cur.panelScale = sc end
        end

        util.saveConfig("/cfg/display.cfg", cur)
        print()
        print("Display profile saved: " .. profile)
    end

    print(); print(L.saved); sleep(1.5); os.reboot()
end

local args = { ... }
local cmd = args[1]
if cmd == "setup" then
    doSetup()
elseif cmd and ROLES[cmd] then
    ROLES[cmd]()
else
    local role = readSavedRole()
    if role and ROLES[role] then
        print("[mek] role = " .. role); sleep(0.3); ROLES[role]()
    else
        doSetup()
    end
end
