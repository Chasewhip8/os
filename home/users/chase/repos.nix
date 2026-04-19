{ ... }:
{
  custom.repos = {
    enable = true;
    cloneMissingRepositories = false;
    roots = [
      "arcadia"
      "net"
      "pay"
      "personal"
      "symmetry"
    ];

    repositories = [
      {
        path = "arcadia/arcadia-wallet-gateway";
        remote = "git@github.com:Arcadia-Financial/arcadia-wallet-gateway.git";
      }

      {
        path = "net/agave-github-tracker";
        remote = "git@github.com:Sphere-Foundation/agave-github-tracker.git";
      }
      {
        path = "net/associated-badge-account";
        remote = "git@github.com:Sphere-Foundation/associated-badge-account.git";
      }
      {
        path = "net/badge";
        remote = "git@github.com:Sphere-Foundation/badge.git";
      }
      {
        path = "net/badge-provisioner";
        remote = "git@github.com:Sphere-Foundation/badge-provisioner.git";
      }
      {
        path = "net/badge-sdk";
        remote = "git@github.com:Sphere-Foundation/badge-sdk.git";
      }
      {
        path = "net/docs";
        remote = "git@github.com:Sphere-Foundation/docs.git";
      }
      {
        path = "net/documentation";
        remote = "git@github.com:Sphere-Foundation/documentation.git";
      }
      {
        path = "net/hyperlane-monorepo";
        remote = "git@github.com:Sphere-Foundation/hyperlane-monorepo.git";
      }
      {
        path = "net/indexer";
        remote = "git@github.com:Sphere-Foundation/indexer.git";
      }
      {
        path = "net/infrastructure";
        remote = "git@github.com:Sphere-Foundation/infrastructure.git";
      }
      {
        path = "net/kb";
        remote = "git@github.com:Sphere-Foundation/kb.git";
      }
      {
        path = "net/litepaper";
        remote = "git@github.com:Sphere-Foundation/litepaper.git";
      }
      {
        path = "net/loader-v3";
        remote = "git@github.com:Sphere-Foundation/loader-v3.git";
      }
      {
        path = "net/monetary-policy";
        remote = "git@github.com:Sphere-Foundation/monetary-policy.git";
      }
      {
        path = "net/platform";
        remote = "git@github.com:Sphere-Foundation/platform.git";
      }
      {
        path = "net/playground";
        remote = "git@github.com:Sphere-Foundation/playground.git";
      }
      {
        path = "net/program-whitelist";
        remote = "git@github.com:Sphere-Foundation/program-whitelist.git";
      }
      {
        path = "net/protocols";
        remote = "git@github.com:Sphere-Foundation/protocols.git";
      }
      {
        path = "net/relayer";
        remote = "git@github.com:Sphere-Foundation/relayer.git";
      }
      {
        path = "net/sphere-guard";
        remote = "git@github.com:Sphere-Foundation/sphere-guard.git";
      }
      {
        path = "net/spherenet-admin";
        remote = "git@github.com:Sphere-Foundation/spherenet-admin.git";
      }
      {
        path = "net/spherenet-authority";
        remote = "git@github.com:Sphere-Foundation/spherenet-authority.git";
      }
      {
        path = "net/spherenet-client";
        remote = "git@github.com:Sphere-Foundation/spherenet-client.git";
      }
      {
        path = "net/spherenet-explorer";
        remote = "git@github.com:Sphere-Foundation/spherenet-explorer.git";
      }
      {
        path = "net/spherenet-infra";
        remote = "git@github.com:Sphere-Foundation/spherenet-infra.git";
      }
      {
        path = "net/squads-v4";
        remote = "https://github.com/Sphere-Foundation/squads-v4.git";
      }
      {
        path = "net/stake";
        remote = "https://github.com/Sphere-Foundation/stake.git";
      }
      {
        path = "net/token";
        remote = "git@github.com:Sphere-Foundation/token.git";
      }
      {
        path = "net/token-2022";
        remote = "https://github.com/Sphere-Foundation/token-2022.git";
      }
      {
        path = "net/usd-issuer";
        remote = "git@github.com:Sphere-Foundation/usd-issuer.git";
      }
      {
        path = "net/validator-whitelist";
        remote = "git@github.com:Sphere-Foundation/validator-whitelist.git";
      }

      {
        path = "pay/canonical-onboarding-demo";
        remote = "git@github.com:Sphere-Laboratories/canonical-onboarding-demo.git";
      }
      {
        path = "pay/cc-engineering";
        remote = "git@github.com:Sphere-Laboratories/cc-engineering.git";
      }
      {
        path = "pay/claude-config";
        remote = "git@github.com:Sphere-Laboratories/claude-config.git";
      }
      {
        path = "pay/events";
        remote = "git@github.com:Sphere-Laboratories/events.git";
      }
      {
        path = "pay/infrastructure";
        remote = "git@github.com:Sphere-Laboratories/infrastructure.git";
      }
      {
        path = "pay/monolith";
        remote = "git@github.com:Sphere-Internal-Tools/monolith.git";
      }
      {
        path = "pay/notion-jira-tracker";
        remote = "git@github.com:Sphere-Laboratories/notion-jira-tracker.git";
      }
      {
        path = "pay/sequin-cdc";
        remote = "git@github.com:Sphere-Laboratories/sequin-cdc.git";
      }
      {
        path = "pay/sft-chain-transfer";
        remote = "git@github.com:Sphere-Laboratories/sft-chain-transfer.git";
      }
      {
        path = "pay/sft-dashboard-app";
        remote = "git@github.com:Sphere-Laboratories/sft-dashboard-app.git";
      }
      {
        path = "pay/sft-data-infrastructure";
        remote = "git@github.com:Sphere-Laboratories/sft-data-infrastructure.git";
      }
      {
        path = "pay/sft-data-science";
        remote = "git@github.com:Sphere-Laboratories/sft-data-science.git";
      }
      {
        path = "pay/sft-docs";
        remote = "git@github.com:Sphere-Laboratories/sft-docs.git";
      }
      {
        path = "pay/sft-frontend";
        remote = "git@github.com:Sphere-Laboratories/sft-frontend.git";
      }
      {
        path = "pay/sft-init";
        remote = "git@github.com:Sphere-Laboratories/sft-init.git";
      }
      {
        path = "pay/sft-jup-swap-qr-example";
        remote = "git@github.com:Sphere-Laboratories/sft-jup-swap-qr-example.git";
      }
      {
        path = "pay/sft-legacy";
        remote = "git@github.com:Sphere-Laboratories/sft-legacy.git";
      }
      {
        path = "pay/sft-liquidity-management";
        remote = "git@github.com:Sphere-Laboratories/sft-liquidity-management.git";
      }
      {
        path = "pay/sft-risk-and-compliance";
        remote = "git@github.com:Sphere-Laboratories/sft-risk-and-compliance.git";
      }
      {
        path = "pay/sft-take-home-task";
        remote = "git@github.com:Sphere-Laboratories/sft-take-home-task.git";
      }
      {
        path = "pay/sft-ui";
        remote = "git@github.com:Sphere-Laboratories/sft-ui.git";
      }
      {
        path = "pay/sft-www";
        remote = "git@github.com:Sphere-Laboratories/sft-www.git";
      }
      {
        path = "pay/sphere-data-platform";
        remote = "git@github.com:Sphere-Laboratories/sphere-data-platform.git";
      }
      {
        path = "pay/sphere-dataform";
        remote = "git@github.com:Sphere-Laboratories/sphere-dataform.git";
      }
      {
        path = "pay/sphere-observability";
        remote = "git@github.com:Sphere-Laboratories/sphere-observability.git";
      }
      {
        path = "pay/sphere-risk-service";
        remote = "git@github.com:Sphere-Laboratories/sphere-risk-service.git";
      }
      {
        path = "pay/sphere-vm";
        remote = "git@github.com:Sphere-Internal-Tools/sphere-vm.git";
      }
      {
        path = "pay/spheregpt";
        remote = "git@github.com:Sphere-Laboratories/spheregpt.git";
      }

      {
        path = "personal/abilities";
        remote = "git@github.com:Chasewhip8/abilities.git";
      }
      {
        path = "personal/os";
        remote = "git@github.com:Chasewhip8/os.git";
      }

      {
        path = "symmetry/bank-integration-sandbox";
        remote = "git@github.com:Sphere-Financial/bank-integration-sandbox.git";
      }
      {
        path = "symmetry/symmetry";
        remote = "git@github.com:Sphere-Financial/symmetry.git";
      }
      {
        path = "symmetry/titan-mexican-corridor";
        remote = "git@github.com:Sphere-Financial/titan-mexican-corridor.git";
      }
    ];
  };
}
