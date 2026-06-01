# LiteLLM proxy — new-machine setup

LiteLLM proxy → Vertex AI (Gemini) for agentmemory + opencode agents.
Runs at `http://localhost:4000`, kept alive by launchd.

## 1. Install the binary (extras matter)

```bash
uv tool install "litellm[proxy,google]" --force --with prisma
```

- `[google]` → `google-cloud-aiplatform`; without it vertex calls fail with
  `ImportError: Google Cloud SDK not found`.
- `[proxy]` + `--with prisma` → DB / spend tracking; without prisma you get
  `ModuleNotFoundError: No module named 'prisma'`.

Any later reinstall MUST repeat the same extras, then re-run prisma generate (step 4).

## 2. Secrets (never committed)

```bash
mkdir -p ~/.config/litellm
cp config.yaml.example ~/.config/litellm/config.yaml      # then edit master_key
cp /path/to/vertex-sa.json ~/.config/litellm/vertex-sa.json
chmod 600 ~/.config/litellm/config.yaml ~/.config/litellm/vertex-sa.json
```

## 3. Postgres DB (only if you want spend tracking)

Needs a local postgres (e.g. `brew services start postgresql@16`).

```bash
createdb litellm
# adjust the user/host in config.yaml's database_url to match your postgres
# (this machine: passwordless trust auth as user `maxence`)
```

## 4. Generate prisma client + create tables

```bash
SP=~/.local/share/uv/tools/litellm/lib/python*/site-packages
BIN=~/.local/share/uv/tools/litellm/bin
export PATH="$BIN:$PATH"
export DATABASE_URL="postgresql://maxence@localhost:5432/litellm"
"$BIN/prisma" generate --schema "$SP"/litellm/proxy/schema.prisma
"$BIN/prisma" db push  --schema "$SP"/litellm/proxy/schema.prisma --accept-data-loss
```

## 5. launchd service

```bash
cp ai.litellm.plist ~/Library/LaunchAgents/ai.litellm.plist   # paths assume user `maxence`
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/ai.litellm.plist
launchctl kickstart -k gui/$(id -u)/ai.litellm                # restart after config changes
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:4000/health/liveliness  # expect 200
```

## Check spend

- UI: `http://localhost:4000/ui` (login = master_key)
- API: `GET /global/spend/report` or `/spend/logs` with `Authorization: Bearer <master_key>`
- SQL: `psql "$DATABASE_URL" -c 'select model,sum(spend) from "LiteLLM_SpendLogs" group by model;'`

`spend` = litellm's computed Vertex token cost (price map), not the actual GCP bill.

## Notes

- Benign boot warning `DATABASE_URL found in environment, but prisma package not
  found` can be ignored — writes work.
- `ai.litellm.plist` hardcodes `/Users/maxence` paths; edit them for a different user.
