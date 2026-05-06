# Voice Lines Catalog (Subnautica-style PA)

This document lists every voice line the SCADA system can play. Each line is a `.dfpwm` file the operator records, and each is independently toggleable in the display config (or via a terminal command).

> File path convention (English): `/voice/en/<id>.dfpwm`
> File path convention (Russian): `/voice/ru/<id>.dfpwm`
> Currently selected language: `cfg.voiceLanguage = "en" | "ru"` (default `"en"`).
> All lines fall back silently to printing `[voice] <id>` to the terminal if the audio file is missing.

Every line has:
- **`id`** — unique key used in the cfg + voice command.
- **`category`** — used for the collapsible groups in the display settings panel.
- **`severity`** — drives the auto-play color/priority and which speakers play it (display-only vs broadcast to host speakers).
- **`trigger`** — what condition fires it.
- **`cooldown`** — minimum seconds between repeats of the same line (default 60 s).
- **`enabledByDefault`** — whether the operator has to opt-in.
- **`en` / `ru`** — recommended phrasing in each language (you record whatever you want; these are guides).

Severity levels (same as alarm severity):
- `1 = INFO` — neutral status announcements (greenish tone).
- `2 = WARN` — actionable but not urgent (yellow tone).
- `3 = CRITICAL` — immediate operator attention required (red, plays alongside SCRAM siren).

---

## 1. Induction Matrix

| id | sev | trigger | en | ru |
|----|----|---------|----|----|
| `matrix_full`            | 1 | `pct >= 100` | "Induction matrix fully charged." | "Индукционная матрица полностью заряжена." |
| `matrix_high_95`         | 1 | `pct >= 95` (and `< 100`) | "Induction matrix at ninety-five percent." | "Индукционная матрица заряжена на девяносто пять процентов." |
| `matrix_low_25`          | 1 | `pct <= 25` | "Warning: induction matrix below twenty-five percent." | "Внимание: заряд индукционной матрицы ниже двадцати пяти процентов." |
| `matrix_low_10`          | 2 | `pct <= 10` | "Caution: induction matrix critical, ten percent remaining." | "Осторожно: индукционная матрица в критическом состоянии, осталось десять процентов заряда." |
| `matrix_empty`           | 3 | `pct <= 1` | "Induction matrix depleted." | "Внимание: Индукционная матрица истощена." |
| `matrix_input_lost`      | 2 | `input==0 for 30s while pct<90` | "No power input detected to induction matrix." | "Внимание: Прекращена подача энергии в индукционную матрицу." |
| `matrix_output_overload` | 2 | `output >= 95% transferCap` | "Induction matrix output approaching transfer cap." | "Внимание: Выходная мощность индукционной матрицы близка к пределу передачи." |
| `matrix_net_negative`    | 1 | `net < 0 for 60s` (consumption > production) | "Net energy balance negative." | "Внимание: Энергобаланс индукционной матрицы отрицательный." |
| `matrix_net_positive`    | 1 | `net > 0 after being negative for >5 min` | "Net energy balance restored." | "Внимание: Энергобаланс индукционной матрицы восстановлен." |

---

## 2. Fission Reactor

| id | sev | trigger | en | ru |
|----|----|---------|----|----|
| `fission_started`       | 1 | reactor goes `status=true` | "Fission reactor online." | "Ядерный реактор активен." |
| `fission_stopped`       | 1 | reactor goes `status=false` (manual) | "Fission reactor offline." | "Ядерный реактор отключён." |
| `fission_scram_auto`    | 3 | auto-SCRAM trip | "Auto SCRAM triggered. Reactor shutdown initiated." | "Внимание! Аварийное отключение реактора. Реактор останавливается." |
| `fission_scram_manual`  | 2 | operator clicks SCRAM | "Manual SCRAM acknowledged." | "Ручное аварийное отключение принято." |
| `fission_temp_warn`     | 2 | `temp > 0.85 * maxTemp rule` | "Caution: reactor temperature high." | "Внимание: высокая температура реактора." |
| `fission_temp_crit`     | 3 | `temp > 0.95 * maxTemp rule` | "Critical: reactor temperature near limit." | "Угроза: Критическая температура реактора." |
| `fission_damage_warn`   | 2 | `damage > 0.5 * maxDamage rule` | "Reactor structural damage detected." | "Внимание:Обнаружены повреждения корпуса реактора." |
| `fission_damage_crit`   | 3 | `damage > 0.85 * maxDamage rule` | "Critical: reactor damage approaching shutdown threshold." | "Угроза! Критическое повреждение реактора, вскоре будет произведено аварийное отключение." |
| `fission_coolant_low`   | 2 | `coolPct < 30` | "Warning: Reactor coolant level low." | "Внимание: Низкий уровень теплоносителя реактора." |
| `fission_coolant_crit`  | 3 | `coolPct < 15` | "Critical: reactor coolant depleted." | "Угроза! Критическое падение уровня теплоносителя реактора." |
| `fission_fuel_low`      | 2 | `fuelPct < 25` | "Fissile fuel low." | "Внимание: Низкий запас ядерного топлива." |
| `fission_fuel_crit`     | 2 | `fuelPct < 5` | "Critical: fissile fuel almost exhausted." | "Угроза! Критическое падение запаса ядерного топлива." |
| `fission_waste_60`      | 1 | `wastePct >= 60` | "Notice: waste storage at sixty percent." | "Внимание: хранилище отходов заполнено на шестьдесят процентов." |
| `fission_waste_80`      | 2 | `wastePct >= 80` | "Warning: waste storage at eighty percent." | "Внимание: хранилище отходов заполнено на восемьдесят процентов." |
| `fission_waste_full`    | 3 | `wastePct >= 95` | "Critical: waste storage almost full. SCRAM imminent." | "Угроза!Критическое заполнение отходов, неминуемо аварийное отключение." |
| `fission_burn_max`      | 1 | operator sets `burn = maxBurn` | "Reactor at maximum burn rate." | "Реактор работает на максимальной мощности." |
| `fission_burn_zero`     | 1 | operator sets `burn = 0` while online | "Reactor idling at zero burn rate." | "Реактор работает на нулевой мощности." |
| `fission_latched`       | 2 | latched SCRAM persists | "Reactor SCRAM latched. Manual reset required." | "Аварийная блокировка реактора. Требуется ручной сброс." |
| `fission_fuel_autostop` | 2 | `lowFuelAutoStop` triggers preemptive SCRAM near fuel-crit | "Low fuel reserve. Reactor automatically shut down." | "Внимание: Запас ядерного топлива упал ниже критической отметки. Производится автоматическое отключение реакторных систем до стабилизации состояния. Возможно требуется вмешательство персонала." |

---

## 3. Industrial Turbine

| id | sev | trigger | en | ru |
|----|----|---------|----|----|
| `turbine_steam_high`    | 2 | `steamPct > 95` | "Turbine steam buffer near full." | "Внимание: Паровой буфер турбины близок к заполнению." |
| `turbine_steam_full`    | 3 | `steamPct >= 99` | "Critical: turbine steam buffer full, venting required." | "Угроза! Критическое заполнение парового буфера турбины." |
| `turbine_energy_full`   | 1 | `energyPct >= 99` | "Turbine energy buffer full." | "Внимание: Энергобуфер турбины полон." |
| `turbine_low_output`    | 2 | `prod < 0.10 * maxProd for 60s` while reactor on | "Turbine output below ten percent of maximum." | "Внимание: Выходная мощность турбины ниже десяти процентов от максимума." |
| `turbine_offline`       | 2 | host disconnected for 30s | "Turbine telemetry lost." | "Внимание: Связь с турбиной потеряна." |
| `turbine_back_online`   | 1 | host reconnects | "Turbine telemetry restored." | "Внимание: Связь с турбиной восстановлена." |

---

## 4. Boiler

| id | sev | trigger | en | ru |
|----|----|---------|----|----|
| `boiler_water_low`      | 2 | `waterPct < 25` | "Boiler water low." | "Внимание:Низкий уровень воды в бойлере." |
| `boiler_water_crit`     | 3 | `waterPct < 10` | "Critical: boiler water depleted." | "Угроза: Критическое падение уровня воды в бойлере." |
| `boiler_steam_full`     | 2 | `steamPct >= 95` | "Boiler steam buffer near full." | "Внимание: Паровой буфер бойлера близок к заполнению." |
| `boiler_heated_full`    | 2 | `heatedPct >= 95` | "Boiler heated coolant buffer near full." | "Внимание: Буфер нагретого теплоносителя бойлера близок к заполнению." |
| `boiler_temp_high`      | 2 | `temp > 1100` | "Boiler temperature high." | "Внимание: температура бойлера достигла 1100 градусов по кельвину." |

---

## 5. Fusion Reactor

| id | sev | trigger | en | ru |
|----|----|---------|----|----|
| `fusion_ignited`        | 1 | `status` goes online | "Fusion reactor ignited." | "Термоядерный реактор активирован." |
| `fusion_offline`        | 1 | `status` goes offline | "Fusion reactor offline." | "Термоядерный реактор остановлен." |
| `fusion_scram_auto`     | 3 | auto-SCRAM | "Fusion auto-SCRAM triggered." | "Внимание: Аварийное отключение термоядерного реактора." |
| `fusion_plasma_warn`    | 2 | `plasmaTemp > 0.85 * limit` | "Plasma temperature high." | "Температура плазмы на пределе." |
| `fusion_plasma_crit`    | 3 | `plasmaTemp > 0.95 * limit` | "Critical: plasma temperature near limit." | "Угроза! Критическая температура плазмы." |
| `fusion_case_warn`      | 2 | `caseTemp > 0.85 * limit` | "Containment case temperature high." | "Внимание: температура корпуса термоядерного реактора на пределе." |
| `fusion_dt_low`         | 2 | `dtFuelPct < 25` | "Deuterium-tritium fuel low." | "Внимание:Низкий запас дейтерий-тритиевого топлива." |
| `fusion_water_low`      | 2 | `waterPct < 20` | "Fusion reactor water level low." | "Внимание: Низкий уровень воды термоядерного реактора." |

---

## 6. System / Network

| id | sev | trigger | en | ru |
|----|----|---------|----|----|
| `system_startup`        | 1 | display PC boots | "SCADA system online." | "Система мониторинга включена." |
| `system_host_lost`      | 2 | any host stale > 30s | "Host telemetry lost: <name>." | "Потеряна связь с указанным устройством." |
| `system_host_back`      | 1 | host telemetry resumes | "Host reconnected: <name>." | "Связь восстановлена для указанного устройства." |
| `system_host_reboot`    | 2 | auto-reboot fires after `autoRebootSilent` seconds of silence | "Host unresponsive. Sending reboot command." | "Внимание: Один из узлов не отвечает. Отправлена команда перезагрузки." |
| `system_host_reboot_ok` | 1 | host returns after a remote reboot | "Host rebooted and back online." | "Узел перезагружен и снова на связи." |
| `system_host_reboot_fail` | 3 | host still silent after one reboot attempt | "Host did not respond to reboot. Manual check required." | "Внимание: Узел не отвечает после перезагрузки. Требуется ручная проверка." |
| `system_host_reboot_manual` | 1 | operator pressed Reboot button | "Operator-issued reboot dispatched." | "Выполнена перезагрузка узла оператором." |
| `system_auto_throttle`  | 1 | auto-throttle adjusts burn rate | "Burn rate auto-adjusted to <N> millibuckets per tick." | "Скорость деления автоматически изменена до <N> миллибаккетов на тик." |
| `system_auto_restart`   | 2 | auto-restart fires | "Auto-restart engaged on <name>." | "Автоматический перезапуск активирован для указанного устройства." |
| `system_alarm_test`     | 1 | TEST ALARM button | "Alarm test." | "Произведён тест системы оповещения." |

> Lines with `<name>` placeholders accept a host display-name. The audio file plays first, then the display PC's terminal logs the full substituted message.

---

## 7. Test / Easter-egg lines (optional)

| id | sev | trigger | en | ru |
|----|----|---------|----|----|
| `test_voice`            | 1 | TEST VOICE button | "Voice synthesis test, all systems nominal." | "Проверка системы оповещения. Для полного отчёта обратитесь к компьютеру." |
| `easter_overcharge`     | 1 | `pct >= 100` for 24h continuous | "Looks like we have plenty of power. Have a coffee." | "Похоже, у нас полно энергии. Самое время заварить кофе." |

---

## Implementation checklist (what the script will do)

1. **Auto-detection**: on display startup, scan `/voice/<lang>/` for `*.dfpwm` files. Lines whose audio is missing remain togglable but only print to terminal until the file is added.
2. **Per-line toggle**: `cfg.voice = { matrix_full=true, fission_scram_auto=true, ... }` saved in `/cfg/display.cfg`. Defaults follow `enabledByDefault` (TBD per question 1 below).
3. **Cooldowns**: per-line `lastPlayed` timestamp; default 60 s, configurable via `cfg.voiceCooldowns = { fission_temp_warn = 30 }`.
4. **Routing**: severity ≥ 2 also broadcast over rednet so host speakers (fission/fusion/relay) play the same line in their machine rooms. Severity 1 plays only on display PC.
5. **Settings UI**: collapsible "Voice Lines" subsection inside the SCRAM tab, paginated by category. Each row shows `[ON/OFF] <id>  <preview text>  [▶ Test]`.
6. **Terminal command**: `voice list`, `voice on <id>`, `voice off <id>`, `voice play <id>`, `voice lang en|ru`, `voice cooldown <id> <secs>`.
7. **Recording helper**: `voice rec <id>` prints exactly the file path you should drop the `.dfpwm` into.
