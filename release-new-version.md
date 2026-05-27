
## For Maintainers: Releasing a New Version

### Prerequisites

- Bash shell (Git Bash, WSL, or similar on Windows)
- `curl` command available
- `shasum` or `sha256sum` command available

### Adding a New Version

Use the helper script `add-version.sh` to add a new version:

```bash
./add-version.sh --version x.xx.x
```

For example:

```bash
./add-version.sh --version 0.48.0
```

This will:
1. Download the Windows binary from the specified GitHub release
2. Calculate the SHA256 checksum
3. Create a versioned manifest file (`bucket/galasactl@x.xx.x.json`)
4. Update the latest version manifest file (`bucket/galasactl.json`)

### Publishing the Update

After running the script:

```bash
git add bucket/
git commit -m "Add galasactl version x.xx.x"
git push
```

Users will receive the update the next time they run `scoop update`.

### Installing Specific Versions

Once versioned manifests are published, users can install specific versions:

```powershell
# Install latest
scoop install galasactl

# Install specific version
scoop install galasactl@0.48.0
```

## Comparison with Homebrew

This Scoop bucket follows the same pattern as the [Galasa Homebrew tap](https://github.com/galasa-dev/homebrew-tap):

| Feature | Homebrew (macOS) | Scoop (Windows) |
|---------|------------------|-----------------|
| Repository | `homebrew-tap` | `scoop-bucket` |
| Latest manifest | `Casks/g/galasactl.rb` | `bucket/galasactl.json` |
| Versioned manifest | `Casks/g/galasactl@0.48.0.rb` | `bucket/galasactl@0.48.0.json` |
| Update script | `add-version.sh` | `add-version.sh` |
| Install latest | `brew install galasactl` | `scoop install galasactl` |
| Install specific | `brew install galasactl@0.48.0` | `scoop install galasactl@0.48.0` |
| Update command | `brew upgrade galasactl` | `scoop update galasactl` |

## Resources

- [Galasa Documentation](https://galasa.dev)
- [Scoop Documentation](https://scoop.sh/)
- [Creating Scoop Manifests](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests)
