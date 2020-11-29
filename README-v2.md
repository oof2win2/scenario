# This is a README for the scenario, but for devs on how to configure simple stuff/where stuff is

# TODO:

- Fix the 'Servers' menu to show only the servers we have enabled
- Fix the whole main GUI
- Make sure roles & perms are auto assigned & work
- probably some more stuff

# Info GUI

`locale/<lang>/gui.cfg` - The general descriptions for stuff

## Welcome

`Tab({'readme.welcome-tab'}, {'readme.welcome-tooltip'}` @ `modules/gui/readme.lua` - the 'Welcome' menu and some settings
`locale/<lang>/gui.cfg` - long descriptions are there

## Rules

`locale/<lang>/gui.cfg` - all rules are there

## Commands

## Servers

To make servers work dynamically, feed the info over RCON in the format `/c game.ext.servers = servers`, makes it 'dynamic' - `servers` should be as following:

```
['eu-01'] = {
  id = "eu-01",
  name = "ExpGaming S1 - Public",
  short_name = "S1 Public",
  welcome = "Welcome to one of our public reset servers; we aim to make large bases and expansive train network. Science production and rockets are the primary goal.",
  description = "This is our 48 hour reset experimental server.",
  reset = "what ever date format we had before",
  branch = "master",
  version = "0.17.68",
  address = "player.explosivegaming.nl:portHere"
},
```

Other option (in main GUI) is to change the for loop `for i = 1, 4 do` at `modules/gui/readme.lua:~232`

You can edit server descriptions in `locale/<lang>/gui.cfg`

## Backers

Change default server roles in `config/expcore/roles.lua: Roles.override_player_roles{..}`. Roles should be in the format of `["oof2win2"]={"Administrator","Moderator", "Member"}`. You can also change times of auto role in the same file
