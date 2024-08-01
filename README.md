# SetupScripts

## setUpMac.sh

![Version](https://img.shields.io/badge/Version-2.0.0-green.svg)

Bash script to install/update homebrew, and then using homebrew, install other formulas and casks.
- v-2.0.0 contains additional changes for configuring git lfs, disabling elasticseach ML capabilities, import terminal profile and configure bash terminal

## setUpLinux.sh

![Version](https://img.shields.io/badge/version-0.0.1-red.svg)

Bash script to update package manager `apt` and install the tools and libraries in linux system.
The script is untested and has high chance of being filled with errors.

## Add New Tools

- To add new tools to the list of existing `formulas` and `casks`, go to the [latest tools branch](https://github.com/vihar-s1/setupScripts/tree/tools/new-tools-02) and create a new PR for that branch.
- The `tools/new-tools-*` branch will be merged in the main branch once sufficient changes are present. A new `tools/new-tools-*` branch will created after that.
- Branch naming convention
  - `tools/cask/<tool name>` if adding to *casks*
  - `tools/formula/<tool name>` if adding to *formulas*
  - `tools/tap/<tap name>` if only the *taps* list is changed
