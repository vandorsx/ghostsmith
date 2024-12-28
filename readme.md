<img height="128" alt="MedgeGlow app icon" src="https://github.com/user-attachments/assets/d7812578-1e72-4320-9087-bd6662eabf35">

# ghostsmith

A barebones CLI tool for generating (and saving) custom Ghostty icons.

[Ghostty](https://ghostty.org), a cross-platform terminal emulator, allows for user-specified customization to its macOS app icon. While incredibly cool and unique, because the icon is compiled and applied at runtime, the customized icon is lost on application quit.

ghostsmith enables you to genereate the same customized icon and apply it in a more robust manner — using a tool like [Pictogram](https://pictogramapp.com) or the [native method](https://9to5mac.com/2021/11/08/change-mac-icons/).

The logic for generating an icon is ripped from Ghostty's source code, meaning it's possible to generate identical icons as configured in Ghostty.[^1]

[^1]: Theoretically. Report any issues if this is not the case.

## Using the ghostsmith CLI

1. Compile ghostsmith or download the pre-compiled latest release.
   1. To compile, an up-to-date version of Xcode is required.
   2. The pre-compiled release is unsigned.
2. Run ghostsmith with the required arguments.

### Available arguments

`--screen-color` accepts a comma separated list of 1 or more hex color values and/or defined colors
*(ex. `--screen-color "black,#ff9dfa"`)*

`--ghost-color` accepts a hex color value and/or defined color
*(ex. `--ghost-color X11Purple"`)*

`--frame` accepts one of the following options: `aluminum`, `beige`, `plastic`, `chrome`

The list of defined colors can be found [here](https://github.com/vandorsx/ghostsmith/blob/main/src/assets/rgb.txt)

## Credits

Ghostty is developed and maintained by Mitchell Hashimoto.\
Ghostty's app icon and its associated assets were designed by Michael Flarup.

ghostsmith carries forward Ghostty's MIT license and claims no further copyrights.
