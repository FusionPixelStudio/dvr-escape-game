# Davinci Resolve Video Games

![Image of Davinci Resolve Escape Room Gameplay](./imgs/Screenshot%202025-01-16%20193010.png "The Escape Game")

![GitHub contributors](https://img.shields.io/github/contributors/FusionPixelStudio/dvr-escape-game) [![GitHub issues](https://img.shields.io/github/issues-raw/FusionPixelStudio/dvr-escape-game)](https://github.com/FusionPixelStudio/dvr-escape-game/issues) ![GitHub stars](https://img.shields.io/github/stars/FusionPixelStudio/dvr-escape-game?style=social) ![GitHub closed issues](https://img.shields.io/github/issues-closed-raw/FusionPixelStudio/dvr-escape-game) ![GitHub pull requests](https://img.shields.io/github/issues-pr/FusionPixelStudio/dvr-escape-game) [![GitHub release (latest by date)](https://img.shields.io/github/v/release/FusionPixelStudio/dvr-escape-game)](https://github.com/FusionPixelStudio/dvr-escape-game/releases) ![GitHub commit activity](https://img.shields.io/github/commit-activity/m/FusionPixelStudio/dvr-escape-game) [![GitHub license](https://img.shields.io/github/license/FusionPixelStudio/dvr-escape-game)](https://github.com/FusionPixelStudio/dvr-escape-game)

## Description

DVR-Escape-Game is an Open Source Project with improving and discovering more about the Davinci Resolve/Fusion Scripting API in mind. Starting as just a small escape room game by [Asher Roland](https://www.youtube.com/@asherroland) with the goal of starting the conversation and showcasing the less used features of the API.

The idea behind this open source project is to build on the original script and for other to build their own games with the information from the original. See our [Contributing Guide](CONTRIBUTING.md) for details about how to contribute.

## Installation

You can install the game into your `Scripts/Utility/` folder by downloading the folder `Asher Roland 1000 Subs` from releases and unzipping the files. Then, without moving any files out from where they are, you can drag the `The DVR Escape Game.lua` file into Fusion. It will install itself and let you know it has finished. You should now see it under `Workflow/Scripts/Asher Roland 1000 Subs/The DVR Escape Game` in Davinci Resolve's menu.

## Playing the Game

This game must be played in a Fusion Comp with at least a MediaOut node. The best way to achieve this is to drag a "fusion composition" from the Effects panel on the edit page and enter the comp from there. Now launch the script from: `Workflow/Scripts/Asher Roland 1000 Subs/The DVR Escape Game`

After launching the game, you will be greeted with the game loading in piece by piece then the textbox will popup with instructions on how to play and your objective.

![Image of Davinci Resolve Escape Room Intro](./imgs/Screenshot%202025-01-16%20194604.png "The Escape Game Intro")

## Important Notes

Users with **FREE** Davinci Resolve 19.1 and after will be unable to play this game because of changes by Blackmagic Design to what is available to the free users of Resolve by removing the ability to access the Scripting UI System. The only way to get around this is to install an earlier version of Davinci Resolve to restore the UI access.

Users on certain Mac systems will have difficulty playing the game. The hotkeys to move around and interact with objects will be not usable and you will be required to move with the UI buttons to the left of the screen. In some systems you may not even be able to interact with objects.

This game has not been tested on any Linux Systems.

## Support Channels

There are two places to reach out to communicate with the other contributors or to just see what the progress is behind the scenes.

[Discord](https://discord.gg/muSmraywrp) for general communication
[GitHub issues](https://github.com/FusionPixelStudio/dvr-escape-game/issues) for serious bug reporting

## Contributing

Please read our [Contributing Guide](CONTRIBUTING.md) for details about how to contribute and add dev branches.

## Contributors

<a href="https://github.com/FusionPixelStudio/dvr-escape-game/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=FusionPixelStudio/dvr-escape-game" />
</a>
