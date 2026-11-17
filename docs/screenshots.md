# Screenshots

Screenshots must show real executions. Images go in `docs/images/`.

## Captured

Headless Microsoft Edge captures of the public pages, taken 2026-11-17 without signing in.

| Image | Shows | Source |
| --- | --- | --- |
| [release-job-graph](images/release-job-graph.png) | Release `v0.2.0`: every job green, the job graph and the `production` approval by the owner | GitHub release run 43983071969 |
| [release-assets](images/release-assets.png) | Release `v0.2.0` page with the image digest and its nine assets | `releases/tag/v0.2.0` |
| [actions-overview](images/actions-overview.png) | Workflow runs on `main`, the tag and a Dependabot pull request | `actions` |

## Capture plan

| Image | Source | Status |
| --- | --- | --- |
| hardening-table, tests-green, cosign-verify, oidc-claims, softhsm-signing, firmware-sim, deployment-verification, secret-scan | Terminal output of the commands in each document | NOT VERIFIED |
| argocd-synced, argocd-drift-healed, jenkins-stages, zap-report, zap-juice-demo | Local web pages | NOT VERIFIED |
| code-scanning, sonarcloud-gate, gitleaks-blocked-pr, vuln-dependency-blocked-pr, gitlab-pipeline, windows-job-log, oidc-denied, readme-top | Public GitHub and GitLab pages after hosted runs (job logs and code scanning need a signed-in browser; the SonarCloud page does not render headless) | NOT VERIFIED |
| branch-ruleset, production-approval | Manual, steps below (the approval record of `v0.2.0` is visible in release-job-graph; the review dialog itself appears again with the next release) | NOT VERIFIED |

## Manual: branch-ruleset

1. Run `pwsh -File scripts/apply-branch-protection.ps1 -Apply` and confirm. The script verifies the ruleset after applying it.
2. Open `https://github.com/siiick-brain/Bastion-Pipeline/settings/rules`.
3. Open the `main-protection` ruleset.
4. Capture the page showing enforcement "Active", the target branch and the rules list (deletion, force push, linear history, pull request, required status checks).
5. Save as `docs/images/branch-ruleset.png`.

## Manual: production-approval

1. Open `https://github.com/siiick-brain/Bastion-Pipeline/settings/environments` and create the environment `production`.
2. Enable "Required reviewers", add `siiick-brain`, enable "Prevent self-review" only if a second reviewer exists. Restrict deployment branches to tags matching `v*.*.*`.
3. Push a release tag. When the `release` run reaches the `gate` job, GitHub shows "Review deployments".
4. Capture the review dialog with the environment name and the pending job.
5. Approve, wait for the gate summary, then save the capture as `docs/images/production-approval.png`.
