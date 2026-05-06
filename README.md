# CC-Mekanism-ATM9

A single-file CC:Tweaked SCADA suite for **Mekanism** on **All The Mods 9** (Minecraft 1.20.1, CC:Tweaked 1.115.x, Mekanism 10.5.x).

One `mek.lua` runs on every computer. A tiny `/cfg/role.cfg` decides whether that computer becomes a host (induction / fission / turbine / boiler / fusion) or the central display.

Features:

- Live dashboard on a multi-monitor wall (auto-adapts to wide / narrow / stacked layouts).
- Per-host auto-SCRAM rules with editable thresholds from the display.
- Auto burn-rate throttle (P-controller) targeting a configurable matrix %.
- Auto-restart after SCRAM once subsystems are healthy again.
- Auto-stop reactor on low fuel before the SCRAM-rule trip fires.
- Voice PA with DFPWM playback (Russian, ~50 lines), have to be dropped into `/voice/ru/` on each computer separately for now.
- Remote reboot of silent hosts (manual + automatic after N seconds of silence).
- CSV history log + History tab with paired FE/t in/out figures.
- Optional chat notifications via 'Advanced Peripherals' chatBox.
- EMA smoothing on induction I/O so rates don't pulse with single-tick spikes.

---

## Architecture

```
  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
  │ induction-1  │     │  fission-1   │     │  turbine-1   │  ...
  │  host PC     │     │  host PC     │     │  host PC     │
  │  + wired mod │     │  + wired mod │     │  + wired mod │
  │  + ender mod │     │  + ender mod │     │  + ender mod │
  └──────┬───────┘     └──────┬───────┘     └──────┬───────┘
         │                    │                    │
         └──────── rednet ender-modem channel ─────┘
                              │
                       ┌──────▼───────┐
                       │  display PC  │   monitor wall (2x3, 3x2, etc.)
                       │ + ender mod  │   + speaker (alarms + voice PA)
                       │ + monitor    │   + chatBox (optional)
                       └──────────────┘
```

Each **host PC**:
- One CC:Tweaked computer.
- One wired modem touching the Mekanism logic adapter / valve.
- One ender modem on top for the rednet network.
- Optional speaker for local alarms.

The **display PC**:
- One computer.
- One ender modem on top.
- One advanced monitor (any size; 4×3 monitor blocks works well).
- Speaker for alarms + voice PA (recommended).
- Optional chatBox for in-game notifications.

---

## Install

```
wget https://raw.githubusercontent.com/SakanaOfTheSea/MekaCC/main/mek.lua startup
reboot
```

To update later, run the same `wget` command.

After the first reboot the script asks which role this computer should run and writes `/cfg/role.cfg`. Subsequent reboots launch that role automatically. Remove cfg/ folder via  `rm cfg` and  `reboot` to pick a different role/reset.

---

## Hardware checklist per role

| Role        | Required peripherals                          | Notes |
|-------------|-----------------------------------------------|-------|
| `induction` | `inductionPort` via wired modem               | Reads energy, in/out, transfer cap. |
| `fission`   | `fissionReactorLogicAdapter` via wired modem  | Auto-SCRAM rules editable from the display. |
| `turbine`   | `turbineValve` via wired modem                | Steam buffer alarms. |
| `boiler`    | `boilerValve` via wired modem                 | Water-low alarm. |
| `fusion`    | `fusionReactorLogicAdapter` via wired modem   | Auto-SCRAM rules; injection rate control. |
| `display`   | `monitor` + `speaker` (recommended). Optional `chatBox`. | Reads `/cfg/display.cfg`. |

All hosts also need an **ender modem** for rednet to reach the display. They poll their peripheral every ~0.5 s and broadcast telemetry; the display aggregates everything. The display computer also controls different events, all of which can be disabled in the SCRAM tab of the display if you want to have multiple monitors running but only one controlling events.

---

## Configuration

Each role keeps a small `/cfg/<role>.cfg` that the script auto-creates with sensible defaults. Edit and reboot to apply.

The most useful display knobs (in `/cfg/display.cfg`):

```lua
return {
  monitorScale=0.5, refreshHz=5,
  -- safety
  scramOnMatrixFull=true, matrixFullThreshold=99.8,
  warnOnMatrixLow=true,  matrixLowThreshold=10.0,
  -- auto burn-rate throttle (P-controller)
  autoThrottle=false, throttleTarget=80, throttleStep=0.5, throttleSlack=1,
  -- auto-restart fission after SCRAM, once subsystems are healthy
  autoRestart=false, autoRestartBelow=85, autoRestartDelay=30,
  -- preemptive low-fuel stop
  lowFuelAutoStop=false, lowFuelStopThreshold=6,
  -- automatic reboot of silent hosts (single attempt)
  autoReboot=true, autoRebootSilent=120,
  -- voice PA
  voiceFolder="/voice/ru/", voiceDefaultVolume=2.5, voiceDefaultCooldown=60,
  -- chat / webhook notifications (Advanced Peripherals chatBox or HTTP)
  chatNotify=false, chatPrefix="[MEK]", chatMinSeverity=2, webhookUrl="",
  -- production history (CSV log)
  historyEnabled=true, historyEvery=60, historyKeep=720,
}
```

Most knobs also have toggles + adjusters on the SCRAM tab so you can tweak from the monitor without touching files.

---

## Voice PA system

The display PC plays voice lines through an attached speaker. Files live in `/voice/ru/<id>.dfpwm` and play on rising-edge events (status changes, severity escalation, auto-throttle adjustments, host lost / back, manual SCRAM, reboot announcements, etc.).

Each line has an editable on/off switch, volume, and cooldown — all in the **Voice** collapsible panel on the SCRAM tab. By default only severity-3 (CRITICAL) lines are enabled; everything else is opt-in.

The full catalog of triggers and Russian text lives in [VOICE_LINES.md](VOICE_LINES.md).

### Generating audio

The reference voice files were generated with **[ElevenLabs](https://elevenlabs.io/)** using a single Russian voice. To produce your own:

1. Generate one MP3/WAV per line. (If you were to use elevenlabs, the voice used for current lines is 'Dieter - Strict and Robotic', model - Eleven v3) The filename must match the line `id` in `VOICE_LINES.md` (e.g. `fission_burn_max.mp3`).
2. Convert to DFPWM with any DFPWM encoder (I used https://music.madefor.cc/ to do just that, as it has a simple interface, so you can just drop multiple mp3 files and voila).
3. Drop the `.dfpwm` files into the display PC's `/voice/ru/` folder.

Missing files are silently skipped, so partial coverage is fine — text-only lines just won't play but the chat / monitor notifications still happen.

> **Audio credit:** the DFPWM voice lines bundled in this repository (if any) were generated with ElevenLabs' free plan. Per ElevenLabs' free-tier terms, attribution is required when the audio is used publicly. If you fork this repo and bundle the audio, keep this notice.

---

## Remote reboot

Wired-modem peripherals sometimes don't reattach immediately after a server restart, leaving a host's `peripheral.find` returning `nil`. The script mitigates this two ways:

1. **Retrying peripheral discovery**: hosts retry every 2 s indefinitely instead of `error()`-ing out.
2. **Universal command listener**: every host listens for a `reboot` command on rednet. The display can dispatch one from the **Reboot** panel on the SCRAM tab — per-host or `Reboot ALL`.

If `cfg.autoReboot=true`, the display will auto-reboot a host after `cfg.autoRebootSilent` seconds (default 120 s) with no telemetry. One attempt only — if the host is still silent after another `autoRebootSilent` seconds, it plays `system_host_reboot_fail` and gives up. This avoids reboot loops on a genuinely broken peripheral.

---

## Disk space

CC:Tweaked computers default to a 1 MB partition. The display PC's CSV log is the most likely thing to fill it, though limited to 720 lines for 12h of history right now. You can increase partition size via CC:Tweaked's config (computercraft-server.toml or computercraft-client.toml, line -  `computer_space_limit = 10000000` 10 MB value in bytes). 

If a computer is wedged "out of space":

```
delete /log/history.csv
delete /startup.bak           -- if it exists
list /
```

Or raise the per-computer limit in your server config (`computercraft-server.toml` → `computer_space_limit`).

---

## Safety notes

- Fission and fusion hosts run their auto-SCRAM loop **locally**, so a network outage cannot defeat them.
- Auto-SCRAM is fail-safe: any peripheral read error trips a SCRAM.
- Damage > threshold triggers a **latched** SCRAM that requires manual reset (`reset` command in the host's terminal).
- All "auto" features (throttle, restart, low-fuel stop, reboot) default to **off** and require explicit opt-in from the SCRAM tab or the cfg file.

---

## Versions tested

- CC:Tweaked **1.115.x**
- Mekanism **10.5.20** on ATM9 v0.3.0+
- Minecraft 1.20.1, Forge

---

## Contributing

Issues and PRs welcome. The whole thing is a single Lua file (`mek.lua`) for easy distribution; if you split it into modules locally, please don't PR the split — keep the single-file release.

---

## Credits

- **[ElevenLabs](https://elevenlabs.io/)** — voice generation (free tier).
- **CC:Tweaked** by SquidDev — the platform that makes any of this possible.
- **Mekanism** by aidancbrady and contributors — the mod being monitored.

---

## License

MIT.