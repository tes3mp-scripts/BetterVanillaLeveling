A collection of popular improvements to vanilla leveling mechanics. Fixed attribute modifiers, level cap, rescaled base health, "natural" progression - gain attributes by increasing skills.

Requires [DataManager](https://github.com/tes3mp-scripts/DataManager)!

You can find the configuration file in `server/data/custom/__config_BetterVanillaLeveling.json`.
* `attributeModifier` modifier players have on level up for all attributes but luck. Should be from `1` to `5`.
* `luckModifier` modifier players have on level up for luck. Should be from `1` to `5`.
* `levelCap` limits the maximal allowed level. `100` is the default.
* `healthScale` sets health to `level * levelModifier + endurance * enduranceModifier + strength * strengthModifier`
  * `enabled` whether health scaling should change.
  * `enduranceModifier` endurance coefficient in the health scaling formula.
  * `strengthModifier` strength coefficient in the health scaling formula.
  * `levelModifier` level coefficient in the health scaling formula.
* `progression`
  * `enabled` whether "natural" progression should be enabled.
  * `threshold` how many skill increases are required for an attribute increase.
  * `attributePoints` by how many points does the attribute incraese after `threshold` is passed.
  * `message` message displayed when an attribute is increased this way.
  * `showInChat` if `true`, sends `message` in chat, otherwise shows a MessageBox