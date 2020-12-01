<p align="center">
  <img alt="logo" src="https://cdn.discordapp.com/icons/548410604679856151/b69e6b33b328491ebbcbe050ff4de269.webp" width="120">
</p>
<h1 align="center">AwF Scenario Repository</h2>

## All-Weekend Factorio

All-Weekend Factorio (often AwF) is a server hosting community with a strong focus on Factorio and games that follow similar ideas. Our Factorio server are known for hosting large maps with the main goal of being a "mega base" which can produce as much as possible within our reset schedule. Although these servers tend to attract the more experienced players, our servers are open to everyone. You can find us through our [discord](https://awf.yt), or in the public games tab in Factorio (AwF Regular, AwF Core etc)

## Use and Installation

1. Download this git repo for the stable release

2. Extract the downloaded zip file from the branch you downloaded into Factorio's scenario directory:

   - Windows: `%appdata%\Factorio\scenarios`
   - Linux: `~/.factorio/scenarios`

3. Within the scenario you can find `./config/_file_loader.lua` which contains a list of all the modules that will be loaded by the scenario; simply comment out (or remove) features you do not want but note that some modules may load other modules as dependencies even when removed from the list.

4. More advanced users may want to play with the other configs files within `./config` but please be aware that some of the config files will require a basic understanding of lua while others may just be a list of values.

5. Once you have made any config changes that you wish to make open Factorio, select play, then start scenario (or host scenario from within multiplayer tab), and select the scenario which will be called `scenario-master` if you have downloaded the latest stable release and have not changed the folder name.

6. The scenario will now load all the selected modules and start the map, any errors or exceptions raised in the scenario should not cause a game/server crash, so if any features do not work as expected then it may be returning an error in the log.
   Please report these errors to [the issues page](issues).

## Contributing

All are welcome to make pull requests and issues for this scenario, if you are in any doubt, please ask someone in our discord. If you do not know lua and don't feel like learning you can always make a feature request. To find out what we already have please read our docs. Please keep in mind while making code changes:

- New features should have the branch names: `feature/feature-name`
- New features are merged into `dev` after it has been completed, this can be done through a pull request.
- After a number of features have been added a release branch is made: `release/X.Y.0`
- Bug fixes and localization can be made to the release branch with a pull request rather than into dev.
- A release is merged into `master` on the following friday after it is considered stable.
- Patches may be named `patch/X.Y.Z` and will be merged into `dev` and then `master` when appropriate.

The All-Weekend Factorio codebase is licensed under the [GNU General Public License v3.0](LICENSE)
[discord]: https://awf.yt

The original code for this scenario is from [Explosive Gaming](https://github.com/explosivegaming/scenario), we just adapted it to suit our needs and have some extra stuff we use
