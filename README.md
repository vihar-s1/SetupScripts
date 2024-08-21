# SetupScripts

## mac-os

![Version](https://img.shields.io/badge/Version-2.0.0-green.svg)

Bash script(s) to install/update homebrew, and then using homebrew, install other formulas and casks.
- v-2.0.0 contains additional changes for configuring git lfs, disabling elasticseach ML capabilities, import terminal profile and configure bash terminal

## kali-linux

![Version](https://img.shields.io/badge/version-1.0.0-green.svg)

- Bash scripts to setup kali linux by installing *anonsurf* and updating apt packages.
- contains additional scripts to setup persistence and encrypted persistence on kali linux usb boot with custom partition start and endpoints.

> NOTE: the script is not yet tested and so may contain some bugs that need to be fixed.

## Add New Tools

- To add new tools to the list of existing `formulas` and `casks`, go to the [latest tools branch](https://github.com/vihar-s1/setupScripts/tree/tools/new-tools-02) and create a new PR for that branch.
- The `tools/new-tools-*` branch will be merged in the main branch once sufficient changes are present. A new `tools/new-tools-*` branch will created after that.
- Branch naming convention
  - `tools/cask/<tool name>` if adding to *casks*
  - `tools/formula/<tool name>` if adding to *formulas*
  - `tools/tap/<tap name>` if only the *taps* list is changed
