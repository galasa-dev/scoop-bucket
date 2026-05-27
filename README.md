# Galasa Scoop Bucket

This repository contains Scoop manifests for the Galasa Command-Line interface (galasactl) for Windows.

## Copyright

Copyright contributors to the Galasa project  
SPDX-License-Identifier: EPL-2.0

## Prerequisites

Before installing galasactl, you need to have Scoop installed on your Windows system.

### Installing Scoop

If you don't have Scoop installed, you can install it by running the following command in PowerShell:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

For more information about Scoop, visit the [official Scoop website](https://scoop.sh/).

## How do I install galasactl?

To install galasactl on the latest version:

```powershell
scoop bucket add galasa https://github.com/galasa-dev/scoop-bucket
scoop install galasactl
```

## Updating galasactl

To update to the latest version:

```powershell
scoop update galasactl
```

## Uninstalling galasactl

To remove galasactl:

```powershell
scoop uninstall galasactl
```

## Supported Architecture

The Galasa Command-Line interface supports:
- Windows x86_64 (64-bit)
