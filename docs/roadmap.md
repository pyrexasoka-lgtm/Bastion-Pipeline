# Roadmap

## Next (needs the owner)

1. Apply the branch ruleset (`scripts/apply-branch-protection.ps1`).
2. Close Dependabot pull request 16 if it does not close itself (`main` already has its change).
3. Promote the released digest and verify ArgoCD sync, drift healing and rollback.
4. Push the gate demo branches and record the red checks.
5. Optional: add `NVD_API_KEY` and a GitLab remote.
6. Capture the screenshots in [the screenshot plan](screenshots.md).

## Planned (deferred ideas)

- Admission-time signature verification with a Sigstore policy controller.
- Ephemeral Jenkins agents per build.
- Reproducible build comparison between two independent builds.
- Mutation testing for `scripts/oidc/verifier.py` and `update-signing/bastion_update/device.py`.
- Cloud federation with a real provider using the same OIDC claims.

## Not planned

- Real secure boot or a real HSM. These need hardware outside the project scope.
