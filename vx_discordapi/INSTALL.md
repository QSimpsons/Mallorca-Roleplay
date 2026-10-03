# vx_discordapi + vx_lib join fix

## Warning this fixes

```
[script:vx_discordapi] Warning: [natives] TRIGGER_CLIENT_EVENT_INTERNAL:
client 1 is not the same as the target 65536.
This happens when the oldId from the playerJoining event is used. Use source instead.
```

Cause: `vx_lib` loads into consuming resources. `vx.addCommand` registered a
`playerJoining` handler that named the first argument `source`, but that argument
is the temporary connecting id (`oldId`, often `65536`). Chat suggestions were
sent to the wrong target.

## Install

1. Replace `resources/[your]/vx_lib/modules/addCommand/server.lua` with the fixed file from this repo (or update the whole `vx_lib` folder).
2. Ensure `vx_discordapi` is present and started **after** `vx_lib`.
3. In `server.cfg`:

```cfg
set discordToken "YOUR_BOT_TOKEN"
set discordGuildId "YOUR_GUILD_ID"
ensure vx_lib
ensure vx_discordapi
```

4. Restart the server (or `ensure vx_lib` then `ensure vx_discordapi`).

## Security

Do **not** hardcode the Discord bot token in `config.server.lua`. If a token was
ever committed or shared in a zip, regenerate it in the Discord Developer Portal.
