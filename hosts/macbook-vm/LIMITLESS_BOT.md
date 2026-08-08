# Limitless Slack bot setup

This host runs a second OpenCode service as `limitless-bot`. The normal
`chase` service remains on `127.0.0.1:4096`; the bot service uses
`127.0.0.1:4097` and the persistent workspace at
`/home/limitless-bot/pay/workspace`.

The bot deliberately uses OrbStack's shared Docker engine. Docker membership
can bypass normal user-level filesystem restrictions and can control unrelated
OrbStack containers. Invite the Slack app only to private channels containing
trusted engineers.

## 1. Create runtime secrets

The current host agenix identity decrypts the files, but only `limitless-bot`
owns their decrypted runtime copies. Keep the identity itself operator-only.

Enter the OrbStack machine first; agenix is installed by its NixOS configuration:

```sh
orb -m nixos
cd /home/chase/.nixconf/secrets
chmod 600 ./identity
agenix -e limitless-bot-github-token.age -i ./identity
agenix -e limitless-bot-slack-environment.age -i ./identity
git add limitless-bot-github-token.age limitless-bot-slack-environment.age
```

`limitless-bot-github-token.age` contains only the dedicated GitHub PAT. The
PAT must be authorized for `Sphere-Laboratories/workspace` and the private
repositories referenced by its submodules.

`limitless-bot-slack-environment.age` uses systemd environment-file syntax:

```dotenv
SLACK_BOT_TOKEN=xoxb-...
SLACK_APP_TOKEN=xapp-...
```

Never place either value directly in a Nix file.

The encrypted `.age` files must be tracked before rebuilding from the
Git-backed flake; untracked files are otherwise absent from the flake source.

## 2. Apply the foundation configuration

Slack is intentionally disabled in `limitless-bot-home.nix` until
authentication and the checkout exist.

From the same OrbStack shell, rebuild:

```sh
orb -m nixos
sudo nixos-rebuild switch --flake /home/chase/.nixconf#macbook-vm
```

Verify the account and decrypted files:

```sh
id limitless-bot
loginctl show-user limitless-bot -p Linger
sudo -u limitless-bot test -r /run/agenix/limitless-bot-github-token
sudo -u limitless-bot test -r /run/agenix/limitless-bot-slack-environment
```

The bot must not belong to `wheel`; membership in `docker` is intentional.

## 3. Authenticate OpenCode

Provider authentication must be created as the bot user inside the VM.
Authentication performed by a Mac-side attached client does not configure the
server account.

```sh
sudo -iu limitless-bot
opencode auth login --provider openai
```

The resulting OpenCode credential remains in the bot's persistent home and is
not managed by Nix or agenix.

## 4. Clone the workspace

Still as `limitless-bot`:

```sh
mkdir -p ~/pay
git clone --recurse-submodules \
  https://github.com/Sphere-Laboratories/workspace.git \
  ~/pay/workspace

git -C ~/pay/workspace status --short
git -C ~/pay/workspace submodule status --recursive
gh auth status
```

This is an independent clean checkout. Do not copy the existing `chase`
workspace or its uncommitted state. Nix does not automatically pull, reset, or
otherwise update this checkout.

## 5. Smoke-test OpenCode and Docker

Set the user-manager environment when operating through `sudo`:

```sh
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

systemctl --user restart opencode
systemctl --user status opencode
curl --fail http://127.0.0.1:4097/global/health

docker version
docker run --rm --name gary-smoke hello-world
```

Attach for a direct model smoke test:

```sh
opencode attach http://127.0.0.1:4097 \
  --dir /home/limitless-bot/pay/workspace
```

Use a `gary-` prefix or an explicit ownership label for bot-created Docker
resources. Never run broad Docker prune or removal commands because the engine
is shared with the rest of OrbStack.

## 6. Enable Slack

In `limitless-bot-home.nix`, change:

```nix
programs.limitless.slack.enable = true;
```

Rebuild `macbook-vm` again. The service will use the workspace as its working
directory and will fail startup if Slack Socket Mode authentication cannot
connect.

The Slack app requires:

- Socket Mode and an app token with `connections:write`.
- The `app_mention` event subscription.
- Bot scopes `app_mentions:read`, `chat:write`, `channels:history`,
  `groups:history`, and `files:read`.
- Membership only in approved private channels.

Verify:

```sh
systemctl --user status opencode
journalctl --user -u opencode -n 200 --no-pager
test -s "$XDG_RUNTIME_DIR/limitless-slack-ready"
```

In Slack, verify a normal reply, `slack_status`, `@bot cancel`, an image
attachment, and a follow-up mention after restarting the service.

## Operations

After logging in as `limitless-bot` and exporting the user-manager variables above:

```sh
systemctl --user restart opencode
journalctl --user -u opencode -f
gary
```

The `gary` alias attaches to port 4097 from the current directory.

## Rollback

1. Remove the app from its Slack channels.
2. Set `programs.limitless.slack.enable = false` and rebuild while the bot
   account is still enabled.
3. Stop the bot's `opencode` user service using the user-manager environment
   from the operations section.
4. Set `local.features.limitlessBot.enable = false` in
   `hosts/macbook-vm/default.nix` and rebuild. This removes its Home Manager
   enrollment and declarative lingering.
5. Revoke the Slack tokens, GitHub PAT, and OpenAI authorization.
6. Remove only Docker resources positively identified as bot-owned.
7. Preserve `/home/limitless-bot` until its checkout and OpenCode state have
   been reviewed.
