<img height="128" alt="MedgeGlow app icon" src="https://github.com/user-attachments/assets/d7812578-1e72-4320-9087-bd6662eabf35">

# ghostsmith

A barebones CLI tool for saving custom generated Ghostty icons to file.

[Ghostty](https://ghostty.org), a cross-platform terminal emulator, allows for user-specified customization to its macOS app icon. While incredibly cool and unique, because customized icons are compiled and applied at runtime, they're lost on application quit — ghostsmith is for the very small subset of users who might be bothered by this.

ghostsmith enables you to generate the same customized icon and apply it in a more robust manner, using a tool like [Pictogram](https://pictogramapp.com) or the [native method](https://9to5mac.com/2021/11/08/change-mac-icons/).

The logic for generating an icon is largely ripped from Ghostty's source code, allowing for identical icons—as configured in Ghostty—to be generated.[^1]

[^1]: Theoretically. Report any issues if this is not the case.

## Using the ghostsmith CLI

1. Compile ghostsmith or download the pre-compiled [latest release](https://github.com/vandorsx/ghostsmith/releases/latest).
   1. To compile, an up-to-date version of Xcode should be used.
   2. The pre-compiled release is unsigned.[^2]
2. Run ghostsmith with the required arguments.

Upon running ghostsmith, your custom icon will be saved to the current working directory as `custom-icon.png`.

[^2]: Reference: ["Open a Mac app from an unknown developer"](https://support.apple.com/guide/mac-help/open-a-mac-app-from-an-unknown-developer-mh40616/mac)

### Available arguments

`--screen-color` accepts a comma separated list of 1 or more hex color values and/or defined colors
*(ex. `--screen-color "black,#ff9dfa"`)*

`--ghost-color` accepts a hex color value and/or defined color
*(ex. `--ghost-color X11Purple"`)*

`--frame` accepts one of the following options: `aluminum`, `beige`, `plastic`, `chrome`
\
\
The list of defined colors can be found [here](https://github.com/vandorsx/ghostsmith/blob/main/src/assets/rgb.txt).

## Credits

Ghostty is developed and maintained by Mitchell Hashimoto.\
Ghostty's app icon and its associated assets were designed by Michael Flarup.

ghostsmith carries forward Ghostty's MIT license and claims no further copyrights.
