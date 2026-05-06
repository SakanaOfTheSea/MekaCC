# CC-Mekanism-ATM9

A modern CC:Tweaked monitoring & control suite for **Mekanism** on the **All The Mods 9** modpack (Minecraft 1.20.1, CC:Tweaked 1.115.x, Mekanism 10.5.x).

Built fresh in 2026 with:

- **Basalt 2** GUI for a polished 3×2 monitor wall.
- **Rednet over ender modems** between rooms — minimal cable runs.
- Per-machine **host PCs** that read peripherals locally and broadcast telemetry.
- A central **display PC** with the main dashboard.
- **Auto-SCRAM** safety logic on each reactor host.
- Configurable thresholds, time-series sparklines, and speaker alarms.

---

## Architecture

```
 ┌─────────────────────────┐         ┌─────────────────────────┐
 │  Induction Matrix Room  │         │     Fission Room         │
 │  ┌──────────┐ wired     │         │  ┌──────────┐ wired      │
 │  │induction │──modem────│ Host PC │  │fission   │──modem──── │ Host PC
 │  │  port    │  network  │ + small │  │logic adp │  network   │ + small
 │  └──────────┘           │ monitor │  └──────────┘            │ monitor
 │  ender modem ───────────┘         │  ender modem ────────────┘
 └─────────────┬───────────┘         └─────────────┬────────────┘
               │                                   │
               │            rednet (channel)       │
               └─────────────────┬─────────────────┘
                                 │
                       ┌─────────▼──────────┐
                       │   Display PC       │   3×2 advanced monitor wall
                       │   ender modem      │   (Basalt 2 dashboard)
                       └────────────────────┘
```

Each host = 1 computer + 1 wired modem to the Mekanism logic adapter / port + 1 ender modem (top) + (optional) small advanced monitor on the side for local readout.

The display PC = 1 computer + 1 ender modem + 6 advanced monitors arranged 3 wide × 2 tall.

---

## Supported subsystems

| Role        | Peripheral type                  | Auto-SCRAM | Notes                                   |
|-------------|----------------------------------|:----------:|-----------------------------------------|
| induction   | `inductionPort`                  |     —      | Energy storage + I/O                    |
| fission     | `fissionReactorLogicAdapter`     |     ✅     | Temp, damage, fuel, waste, burn rate    |
| turbine     | `turbineValve`                   |     —      | Steam in, energy out, flow              |
| boiler      | `boilerValve`                    |     —      | Heat, water, steam, cooled coolant      |
| fusion      | `fusionReactorLogicAdapter`      |     ✅     | Plasma/case temp, D/T, injection rate   |

---

## Install

On every CC:Tweaked computer (host **or** display) run:

```
wget run https://raw.githubusercontent.com/<your-fork>/CC-Mekanism-ATM9/main/install.lua
```

…or for local/offline copy the whole folder to the computer's root via the world save (`saves/<world>/computercraft/computer/<id>/`).

After install, run `setup` once and pick the role for that computer:

```
> setup
[1] display    [2] induction
[3] fission    [4] turbine
[5] boiler     [6] fusion
Pick role:
```

The setup writes `/cfg/role.cfg` and reboots. The `startup.lua` then auto-launches the right script.

---

## Configuration

Per-machine thresholds live in `/cfg/<role>.cfg` (auto-created with safe defaults on first run). Edit and reboot the host. Example for fission:

```lua
return {
  -- Auto-SCRAM thresholds
  maxTemp        = 1200,    -- K
  maxDamage      = 50,      -- %
  minCoolant     = 10,      -- %
  maxWaste       = 90,      -- %
  -- Telemetry
  pollInterval   = 0.5,     -- seconds between peripheral reads
  broadcastEvery = 1,       -- broadcast every N polls
  -- Rednet
  protocol       = "mek-atm9",
  hostName       = "fission-1",
}
```

The display PC reads `/cfg/display.cfg` for monitor side names and refresh rate.

---

## Folder layout

```
CC-Mekanism-ATM9/
├─ install.lua                 # bootstrapper (downloads/copies all files)
├─ setup.lua                   # role picker
├─ startup.lua                 # role router
├─ config/                     # default cfgs copied to /cfg on first run
│   ├─ display.cfg
│   ├─ induction.cfg
│   ├─ fission.cfg
│   ├─ turbine.cfg
│   ├─ boiler.cfg
│   └─ fusion.cfg
├─ common/
│   ├─ protocol.lua             # rednet message schema
│   ├─ util.lua                 # FE/J/temp formatters
│   ├─ ringbuffer.lua           # sparkline data
│   └─ basalt_widgets.lua       # gauge + sparkline custom widgets
├─ hosts/
│   ├─ induction.lua
│   ├─ fission.lua
│   ├─ turbine.lua
│   ├─ boiler.lua
│   └─ fusion.lua
└─ display/
    ├─ main.lua
    └─ panels/
        ├─ overview.lua
        ├─ induction.lua
        ├─ fission.lua
        ├─ turbine.lua
        ├─ boiler.lua
        └─ fusion.lua
```

---

## Safety notes

- The fission and fusion hosts run their **safety loop locally** so a network outage cannot defeat auto-SCRAM.
- Auto-SCRAM is fail-safe: if any peripheral read errors, the reactor is scrammed.
- Damage > `maxDamage` triggers a **latched** SCRAM that requires manual reset (`reset` command in the host's terminal).
- Audible alarms (any attached `speaker`) play at WARN and CRITICAL severities.

---

## Versions tested

- CC:Tweaked **1.115.1**
- Mekanism **10.5.20** (ATM9 v0.3.0+)
- Basalt **2.x** (auto-installed by `install.lua`)
