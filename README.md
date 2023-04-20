# MiniHUD

An X-Plane plugin that shows a small instrument panel for flying
without seeing the cockpit.

Sometimes I like to fly from the external view, or on a small laptop
screen where the cockpit instruments are very hard to read. I created
the MiniHUD to make X-Plane usable in these situations.

![External Screenshot](external%20screenshot.png)
![Internal Screenshot](internal%20screenshot.png)

From left to right, the plugin shows:

1. An airspeed indicator with the usual V-speed zones
2. a trim/control indicator of aileron/elevator/rudder trims as white
   bars, and current control input as thicker white lines (useful if
   you move your rudder with buttons instead of pedals)
3. engine indicators for Throttle, Prop, and Mixture (drag to change)
4. a flaps indicator (drag to change)
5. an altitude indicator and vertical speed gauge
6. a compass, with a wind speed/direction barb

The UI is meant to be minimal, so as to get out of your way while
flying. The functionality is somewhat similar to "Scenic Flyer", but
works on Mac and Linux. In design, it is somewhat similar to Microsoft
Flight Simulator 2020's instrument overlay.

### Configuration

You can drag and drop the MiniHUD to a different place on the screen.

Bind a button to miniHUD → show/hide miniHUD to switch the HUD on or
off.

### Installation

Unzip the MiniHUD directory to X-Plane/Resources/Plugins. Your X-Plane
directory should now contain

<pre>
📂 X-Plane 12
└ 📂 Resources
  └ 📂 plugins
    └ 📂 MiniHUD
      ├ 📁 64
      ├ 📁 data
      ├ 📁 liblinux
      └ 📄 README.md</pre>

### Compatibility

MiniHUD works in X-Plane 11 and 12, on Windows, macOS (Intel+ARM), and Linux.

### License

MiniHUD  
Copyright (C) 2023 Bastian Bechtold

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

See <https://www.gnu.org/licenses/> for a full copy of the GNU General
Public License.
