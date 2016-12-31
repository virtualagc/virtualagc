# AGC Assembly
[![Travis]](https://travis-ci.org/wopian/agc-assembly)
[![GitHub Release]](https://github.com/wopian/agc-assembly/releases)
[![VS Code Version]](https://marketplace.visualstudio.com/items?itemName=wopian.agc-assembly)
[![VS Code Installs]](https://marketplace.visualstudio.com/items?itemName=wopian.agc-assembly)
[![Github All Releases]](https://github.com/wopian/agc-assembly/releases)
[![David]](https://david-dm.org/wopian/agc-assembly?type=dev)

[Travis]:https://img.shields.io/travis/wopian/agc-assembly.svg?style=flat-square
[GitHub Release]:https://img.shields.io/github/release/wopian/agc-assembly.svg?style=flat-square
[GitHub All Releases]:https://img.shields.io/github/downloads/wopian/agc-assembly/total.svg?style=flat-square
[VS Code Version]:http://vsmarketplacebadge.apphb.com/version/wopian.agc-assembly.svg?style=flat-square
[VS Code Installs]:http://vsmarketplacebadge.apphb.com/installs/wopian.agc-assembly.svg?style=flat-square
[David]:https://img.shields.io/david/dev/wopian/agc-assembly.svg?style=flat-square

[Visual Studio Code][0] syntax-highlighting for [Apollo Guidance Computer (AGC)][1] assembly [source code][2].

Based on [AGC Assembly][3] for Sublime Text.

## Languages

- `agc` - AGC (Command Module and Lunar Module) assembly language
- `ags` - AGS (Lunar Module Abort Guidance System) assembly language
- `argus` - ARGUS H800 Assembly Language
- `binsource` - AGC core rope memory binary source files

## Installation

### [Marketplace][6]

- Launch VS Code Quick Open (Ctrl+P)
- Input `ext install agc-assembly`
- Reload VS Code

### Sideloading

#### From Source

- Download the [latest release](https://github.com/wopian/agc-assembly/releases)
- Extract the zip into:
    - **Windows** `%HOMEPATH%/.vscode/extensions`
    - **Mac** `~/.vscode/extensions`
    - **Linux** `~/.vscode/extensions`
- Reload VS Code

#### From VSIX

- Download the VSIX binary from the [latest release](https://github.com/wopian/agc-assembly/releases)
- Launch VS Code Command Palette (F1)
- Input `install vsix`
- Navigate to VSIX binary
- Reload VS Code

## Suggested Settings

Current [VirtualAGC][1] project conventions are to use hard tabs every 8 columns when entering source.

### AGC, AGS & Binsource
```json
{
    "editor.detectIndentation": false,
    "editor.insertSpaces": false,
    "editor.tabCompletion": false,
    "editor.tabSize": 8,
    "editor.trimAutoWhitespace": true,
    "editor.useTabStops": true,
    "editor.wordSeparators": " 	",
    "files.trimTrailingWhitespace": true
}
```
### Argus
```json
{
    "editor.detectIndentation": false,
    "editor.insertSpaces": true,
    "editor.rulers": [1, 8, 19, 32, 46, 60, 75, 80, 120],
    "editor.tabCompletion": false,
    "editor.tabSize": 8,
    "editor.trimAutoWhitespace": true,
    "editor.useTabStops": true,
    "files.trimTrailingWhitespace": true
}
```

## Contributing

Pull requests are welcome.

- Install [Node.js][4] v7.x.x or above
- Install [npm][5] v4.x.x or above
- Install package dependencies:
```
$ npm i
```
- Make your changes in the `.yaml-tmLanguage` files—**DO NOT** modify `.tmLanguage` files
- Build your changes:
```
$ npm start
```

## Known Issues

## Releases
## 0.1.3 - 2016-12-30
### Changed
- Rewrote source code in TypeScript
- Merged `languages` back into `syntax`

### Added
- Barebones helper for AGC

### 0.1.2 - 2016-12-29
#### Fixed
- Typo causing AGS and Argus to fail

### 0.1.1 - 2016-12-29
#### Added
- Missing comment definitions

#### Changed
- Moved language test files to samples
- Moved images into `./images`
- Moved build script into `./src`

#### Fixed
- Argus language tokenizer failure

### 0.1.0 - 2016-12-29
#### Changed
- Reorganised source files

### 0.0.3 - 2016-12-29
#### Added
- Remainder of documentation
- Package icon

#### Fixed
- Typo in settings

[0]:https://code.visualstudio.com/
[1]:http://www.ibiblio.org/apollo/
[2]:https://github.com/rburkey2005/virtualagc
[3]:https://github.com/jimlawton/AGC-Assembly
[4]:https://nodejs.org/en/
[5]:https://www.npmjs.com/
[6]:https://marketplace.visualstudio.com/items?itemName=wopian.agc-assembly