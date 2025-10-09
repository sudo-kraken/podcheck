# Release Workflow

This workflow automatically creates GitHub releases when you push a version tag.

## How to Create a Release

1. **Update the version** in `podcheck.sh`:
   ```bash
   VERSION="v0.8.0"
   ```

2. **Commit your changes**:
   ```bash
   git add podcheck.sh
   git commit -m "chore: bump version to v0.8.0"
   git push
   ```

3. **Create and push a tag**:
   ```bash
   git tag v0.8.0
   git push origin v0.8.0
   ```

4. **The workflow will automatically**:
   - Generate a changelog using git-cliff
   - Create a draft release
   - Package the script and files into a tarball
   - Generate SHA256 and SHA512 checksums
   - Create SBOM (Software Bill of Materials) in CycloneDX format using Trivy
   - Sign all artifacts with Cosign (keyless signing via Sigstore)
   - Attest the SBOM
   - Verify all signatures and attestations
   - Upload everything to the release
   - Publish the release (remove draft status)
   - Send a Discord notification (if webhook configured)

## Release Artifacts

Each release includes:

- **`podcheck-vX.Y.Z.tar.gz`** - Complete package with script, configs, templates, and addons
- **`podcheck-vX.Y.Z.tar.gz.sha256`** - SHA256 checksum
- **`podcheck-vX.Y.Z.tar.gz.sha512`** - SHA512 checksum
- **`podcheck-vX.Y.Z.tar.gz.bundle`** - Cosign signature bundle for tarball
- **`podcheck-vX.Y.Z.sbom`** - SBOM in CycloneDX format (generated with Trivy)
- **`podcheck-vX.Y.Z.sbom.bundle`** - Cosign attestation bundle for SBOM

## Verifying Release Artifacts

### Verify Checksums

```bash
# Download the tarball and checksum
curl -LO https://github.com/sudo-kraken/podcheck/releases/download/v0.8.0/podcheck-v0.8.0.tar.gz
curl -LO https://github.com/sudo-kraken/podcheck/releases/download/v0.8.0/podcheck-v0.8.0.tar.gz.sha256

# Verify
sha256sum -c podcheck-v0.8.0.tar.gz.sha256
```

### Verify Signatures (requires Cosign)

```bash
# Install cosign
curl -LO https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
sudo install cosign-linux-amd64 /usr/local/bin/cosign

# Download artifacts
curl -LO https://github.com/sudo-kraken/podcheck/releases/download/v0.8.0/podcheck-v0.8.0.tar.gz
curl -LO https://github.com/sudo-kraken/podcheck/releases/download/v0.8.0/podcheck-v0.8.0.tar.gz.bundle

# Verify signature
cosign verify-blob \
  --bundle podcheck-v0.8.0.tar.gz.bundle \
  --certificate-identity "https://github.com/sudo-kraken/podcheck/.github/workflows/release.yml@refs/tags/v0.8.0" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  podcheck-v0.8.0.tar.gz
```

## Version Naming Convention

Follow semantic versioning:
- `v1.0.0` - Major release
- `v1.1.0` - Minor release (new features)
- `v1.1.1` - Patch release (bug fixes)
- `v1.0.0-beta.1` - Pre-release (won't trigger certain automations)

## Troubleshooting

### Workflow fails on tag push

- Ensure the tag matches `v*` pattern (e.g., `v1.0.0`)
- Check that `.github/cliff.toml` exists for changelog generation
- Verify all files referenced in the tar command exist

### Signature verification fails

- This is normal for older releases before Cosign was implemented
- New releases will have valid signatures

### Release not appearing

- Check the Actions tab for workflow status
- The release is created as draft first, then published after verification
- Check for any failed jobs in the workflow
