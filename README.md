<p align="center"><img src="assets/icon.png" width="128" height="128" alt="AgentDNA icon"></p>

<h1 align="center">AgentDNA (Cursor Agent Booster)</h1>

<p align="center">Single-file Windows installer that puts a set of eight rule files into Cursor, so its agent works as a terse, non-interactive operator: no chat filler, no hanging commands, logs read in slices, task state kept on disk. With a dry run and rollback.</p>

<p align="center"><a href="https://github.com/milkycloud-dev/cursor-agent-booster/actions/workflows/release.yml"><img src="https://github.com/milkycloud-dev/cursor-agent-booster/actions/workflows/release.yml/badge.svg" alt="Release"></a></p>

<p align="center"><a href="#english">English</a> | <a href="#русский">Русский</a></p>

<a id="english"></a>

## English

### Why

A coding agent tuned for conversation spends tokens on pleasantries, reads a 2 GB log into its context, waits forever on a `[Y/n]` prompt and loses track of the task after a few dozen turns. The rules in this installer address those failure modes directly and keep the same behavior on every machine where Cursor is set up.

### What gets installed

| File | Rules |
|---|---|
| `identity-conflict-override.mdc` | role of an autonomous debugging and deployment operator; detailed prose only when answering a question, compressed output otherwise |
| `cognition.mdc` | each step tagged `[COGNITION: LOW]` or `[COGNITION: HIGH]`; re-read `CURRENT_TASK.md` after long sessions; never trust remembered line numbers |
| `exec-hangs.mdc` | non-interactive commands (`-y`, `BatchMode=yes`), `timeout 30s` on network calls, no `tail -f`, logs through `head`, `tail` or `grep`, deterministic parsing done by local scripts |
| `remote-ops.mdc` | dry run before destructive remote commands, resource check before heavy builds, config backups, no deletion of remote assets without a human confirm |
| `fix-code-docs.mdc` | diagnosis from logs and exit codes only, test first, descriptive names, English docstrings, stop after the third failed attempt |
| `plan-nav.mdc` | written plan and task status in `logs/`, small steps, summaries and indexes before full file reads |
| `compression-hooks.mdc` | compressed output, minified JSON, no brute force after a hook rejection, isolated sub-agents |
| `logs-chat-diet.mdc` | `logs/` folder with task, action, error, prompt and credential logs; short `Done: [step]` replies |

The full text of every rule is in `CursorAgentBooster.cmd`, section `Get-RulesBundle`.

### Usage

Windows 10 or 11 with PowerShell 5.1 or newer.

1. Download `CursorAgentBooster.cmd` from the latest release and run it.
2. Pick a language, then a mode:

| Mode | Action |
|---|---|
| 1 Install | writes the eight rules to `%USERPROFILE%\.cursor\rules\`, backs up existing `.mdc` files to `%USERPROFILE%\.cursor\rules-installer-backup\` first |
| 2 Test | dry run with `[TEST]` output, nothing written |
| 3 Rollback | restores the latest backup |

3. Restart Cursor.

Without the menu: `CursorAgentBooster.cmd test` or `CursorAgentBooster.cmd rollback`.

The file is a batch header with an embedded PowerShell script. The header checks PowerShell, writes the script to `%TEMP%`, runs it and deletes it. No network access, no downloads.

### Security note

The logging rule tells the agent to keep logins in `logs/credentials.log` in plain text inside the project. Add `logs/` to `.gitignore` and keep the folder out of shared drives, or remove that rule if you do not want it.

### Releases

A tag `v*` checks the embedded PowerShell for syntax errors on GitHub Actions and publishes `CursorAgentBooster.cmd` with the notes from [CHANGELOG.md](CHANGELOG.md).

### License

Proprietary, all rights reserved, from version 1.1.0. Running the official release file is allowed; see [LICENSE](LICENSE) for the full terms. Version 1.0 was published under the MIT license and keeps it.

<a id="русский"></a>

## Русский

### Зачем

Агент, настроенный на разговор, тратит токены на вежливость, читает в контекст лог на 2 ГБ, бесконечно ждёт ответа на `[Y/n]` и через несколько десятков ходов теряет задачу. Правила из установщика закрывают эти сбои напрямую и дают одинаковое поведение на каждой машине с Cursor.

### Что устанавливается

| Файл | Правила |
|---|---|
| `identity-conflict-override.mdc` | роль автономного оператора отладки и выкладки; подробный текст только в ответ на вопрос, в остальном сжатый вывод |
| `cognition.mdc` | каждый шаг помечается `[COGNITION: LOW]` или `[COGNITION: HIGH]`; после долгих сессий перечитывать `CURRENT_TASK.md`; не доверять номерам строк по памяти |
| `exec-hangs.mdc` | неинтерактивные команды (`-y`, `BatchMode=yes`), `timeout 30s` на сетевых вызовах, без `tail -f`, логи через `head`, `tail` или `grep`, детерминированный разбор локальными скриптами |
| `remote-ops.mdc` | пробный прогон перед разрушительными командами на сервере, проверка ресурсов перед тяжёлой сборкой, бэкап конфигов, удаление удалённых данных только с подтверждения человека |
| `fix-code-docs.mdc` | диагноз только по логам и кодам выхода, сначала тест, понятные имена, docstring на английском, остановка после третьей неудачи |
| `plan-nav.mdc` | письменный план и статус задачи в `logs/`, мелкие шаги, сводки и индексы до чтения файлов целиком |
| `compression-hooks.mdc` | сжатый вывод, минифицированный JSON, без повторов в лоб после отказа хука, изолированные субагенты |
| `logs-chat-diet.mdc` | папка `logs/` с журналами задачи, действий, ошибок, промптов и доступов; короткие ответы `Done: [step]` |

Полный текст каждого правила лежит в `CursorAgentBooster.cmd`, раздел `Get-RulesBundle`.

### Использование

Windows 10 или 11 с PowerShell 5.1 или новее.

1. Скачайте `CursorAgentBooster.cmd` из последнего релиза и запустите.
2. Выберите язык, затем режим:

| Режим | Действие |
|---|---|
| 1 Установить | пишет восемь правил в `%USERPROFILE%\.cursor\rules\`, перед этим сохраняет имеющиеся `.mdc` в `%USERPROFILE%\.cursor\rules-installer-backup\` |
| 2 Тест | пробный прогон с выводом `[TEST]`, ничего не пишется |
| 3 Откатить | восстанавливает последний бэкап |

3. Перезапустите Cursor.

Без меню: `CursorAgentBooster.cmd test` или `CursorAgentBooster.cmd rollback`.

Файл состоит из batch-заголовка и встроенного скрипта PowerShell. Заголовок проверяет PowerShell, кладёт скрипт в `%TEMP%`, запускает и удаляет. Без сети и без загрузок.

### Про безопасность

Правило о журналах велит агенту хранить логины в `logs/credentials.log` открытым текстом внутри проекта. Добавьте `logs/` в `.gitignore` и не держите папку на общих дисках, или уберите это правило, если оно не нужно.

### Релизы

Тег `v*` проверяет встроенный PowerShell на синтаксические ошибки в GitHub Actions и публикует `CursorAgentBooster.cmd` с описанием из [CHANGELOG.md](CHANGELOG.md).

### Лицензия

Проприетарная, все права защищены, начиная с версии 1.1.0. Запуск официального файла из релиза разрешён; полные условия в [LICENSE](LICENSE). Версия 1.0 вышла под лицензией MIT и остаётся под ней.
