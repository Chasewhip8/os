# OpenCode over the tailnet

The PC exposes its existing OpenCode 2 server through a private Tailscale Serve
HTTPS address:

```text
Remote OpenCode client
  → https://nixos.tail93a561.ts.net:443
    → Tailscale Serve
      → http://127.0.0.1:4096
        → chase's OpenCode user service
```

The PC must be awake and Chase must have an active login session. OpenCode runs
under the existing user service with lingering disabled. The system-level proxy
can run before login; it returns an upstream error while OpenCode is unavailable.

## Configuration

- `hosts/pc/default.nix` enables `local.features.tailscale.serve` and takes the
  upstream port from the Home Manager OpenCode service configuration.
- `hosts/pc/home.nix` binds OpenCode to `127.0.0.1`.
- `system/nixos/tailscale.nix` owns `tailscale-serve-local.service`. It waits for
  Tailscale connectivity, then runs Serve in the foreground so stopping the unit
  removes its route. Systemd restarts the process if the daemon connection closes.

The proxy owns this node's Tailscale Serve port 443. Inspect
`tailscale serve status --json` before setup: another Serve route on that port
needs to be resolved first.

## One-time setup

Run these steps on the PC when ready to activate the configuration.

1. Sign into the intended tailnet:

   ```sh
   sudo tailscale up
   tailscale status
   ```

   Complete the browser sign-in when prompted. The remote device must also join
   that tailnet. In the Tailscale admin console, review access rules so only the
   intended users/devices can reach this PC on TCP port 443. OpenCode can execute
   commands and access files as Chase, so treat its credentials as machine access.

2. Enable MagicDNS and HTTPS certificates in the tailnet's DNS settings. Tailscale
   documents this at <https://tailscale.com/kb/1153/enabling-https>. Certificate
   issuance publishes the machine's full DNS name in certificate transparency
   logs.

3. Review the pending repository changes, then apply the PC configuration:

   ```sh
   sudo nixos-rebuild switch --flake /home/chase/.nixconf#pc
   ```

   A rebuild applies all pending configuration changes. The proxy can also be
   activated before sign-in: it waits without blocking system activation. If
   HTTPS still needs consent, its journal can contain a Tailscale setup URL.

4. Check both services and find the HTTPS address:

   ```sh
   systemctl --user status opencode2
   systemctl status tailscale-serve-local
   journalctl -u tailscale-serve-local -n 50 --no-pager
   tailscale serve status --json
   ```

   The proxy being `active` means its process is running; it may still be waiting
   for Tailscale sign-in or HTTPS setup. The JSON status should contain a
   `Foreground` entry with HTTPS on port 443 and a `Web` handler proxying `/` to
   `http://127.0.0.1:4096`. The journal prints the HTTPS URL once ready.

   Tailscale 1.102.3's plain `tailscale serve status` omits foreground routes and
   can print `No serve config` while this proxy is working. Use the JSON output
   and the HTTP checks below to verify it.

5. Display the existing OpenCode pairing credentials with the tailnet address:

   ```sh
   opencode2 pair --url https://nixos.tail93a561.ts.net
   ```

   Keep the password private. OpenCode 2.0.2 supports `--url`, which sets the
   address in both the printed credentials and the QR code. Without this flag,
   pairing displays the local listening address. `service set hostname` controls
   the listening hostname; the Nix service already specifies `127.0.0.1`.

## Connect from another computer

Use a compatible OpenCode V2 client, preferably the same release as the PC. The
current flake selects OpenCode 2.0.2 and Tailscale 1.102.3. The packaged CLI remains
available as `opencode2`.

### Terminal

OpenCode's explicit server connection reads the password from
`OPENCODE_PASSWORD`. The following Bash command prompts without putting the
password in shell history and scopes it to the client process tree. If the
machine's DNS name changes, use the new URL from the proxy journal:

```sh
bash -c '
  read -r -s -p "OpenCode server password: " OPENCODE_PASSWORD || exit 1
  printf "\n"
  export OPENCODE_PASSWORD
  exec opencode2 --server "$1"
' bash https://nixos.tail93a561.ts.net
```

Use the password shown by `opencode2 pair` on the PC. A remote session works with
the PC's directories and tools; select a project directory on the PC.

The V2 CLI documentation covers `--server`; password environment handling was
corroborated against the installed binary and current V2 source because the
documentation omits that detail:
<https://opencode.ai/v2/docs/cli/>.

### Desktop

A compatible V2 desktop build provides **Settings → Servers → Add server**. Enter
the HTTPS address and pairing password, then select that server. This workflow
was checked in current V2 source; it has not been verified against an installed
desktop client. The terminal connection above is the primary setup path.

## Verify remote access

From the other tailnet device, test that the route reaches OpenCode and requires
authentication:

```sh
curl -sS -o /dev/null -w '%{http_code}\n' \
  https://nixos.tail93a561.ts.net/api/health
```

Expect `401`. Then check authenticated health; curl prompts for the password:

```sh
curl --fail --show-error --user opencode \
  https://nixos.tail93a561.ts.net/api/health
```

Finally connect the OpenCode client and confirm it can open an existing PC
session. Native terminal clients do not require a CORS configuration change.

## Operations

If you previously saved the HTTPS URL using `opencode2 service set hostname`,
remove that override. Unsetting it stops OpenCode; restart the Nix-managed user
service to restore its configured listener:

```sh
opencode2 service unset hostname
systemctl --user restart opencode2
```

```sh
# Stop or start the private HTTPS proxy.
sudo systemctl stop tailscale-serve-local
sudo systemctl start tailscale-serve-local

# Recreate the route after a Tailscale profile or machine-name change.
sudo systemctl restart tailscale-serve-local
```

For permanent removal, set `local.features.tailscale.serve.enable = false` in the
PC configuration and rebuild. The foreground mapping is removed when the unit
stops. Manage this route through the unit; manual background Serve commands on
the same port conflict with its ownership.

Troubleshooting:

- **Plain status says `No serve config`:** use `tailscale serve status --json`
  and inspect `Foreground`; the plain status output omits this unit's route.
- **Waiting for connectivity:** check `tailscale status` and complete sign-in.
- **Waiting for HTTPS or a certificate error:** check tailnet DNS/HTTPS settings
  and the proxy journal.
- **Remote timeout:** check both devices' Tailscale status and tailnet access
  rules for the PC's TCP port 443.
- **HTTP 401:** the server is reachable but the pairing password is missing or
  incorrect.
- **HTTP 502:** check that the PC login session and `opencode2` user service are
  active and that OpenCode is listening on the configured loopback port.

Tailscale Serve reference: <https://tailscale.com/kb/1242/tailscale-serve>.
OpenCode pairing reference: <https://opencode.ai/v2/docs/cli/web/>.
