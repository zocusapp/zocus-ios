# Zocus iOS

## Summary

Zocus gives you remote control of the Zoom and Focus of your DSLR Camera Lens. Move the two touchscreen sliders and control the Zoom or Focus of your Lens - wirelessly. The App works via Bluetooth to drive the 3D Printable Zocus Rig to control the Lens. Download the part files, code and guide at Zocus.co.uk

The Rig was designed as part of a BBC Documentary about designers helping people with disabilities - in this case how to operate a Camera Lens with limited dexterity in your hands. However, the App and Rig has been popular with filmmakers and photographers alike. Customise it to suit your creative needs.

Features include:
- Wide Zoom/Focus sweep (90 degrees rotation).
- High Torque.
- Allows calibration and saves pre-set lenses.
- Able to design your own lens attachments.
- Open Source code, component files and instructions.

## Screenshot

![](https://github.com/zocusapp/zocus-ios/blob/master/screenshot.png?raw=true)

## Requirements

* [Xcode](https://developer.apple.com/xcode/download/)
* [Cocoapods](https://cocoapods.org/)

## Installation Instructions

1. Download the [source code](https://github.com/zocusapp/zocus-ios)

  `$ git clone git@github.com:zocusapp/zocus-ios.git`

2. Install [cocoapods](https://cocoapods.org/)
	
  `$ cd ./Zocus/zocus-ios && pod install`

3. Open "Zocus.xcworkspace" in Xcode

4. Open Xcode's Preferences > Accounts and add your Apple ID

5. In Xcode's sidebar select "Zocus" and go to Targets > Zocus > General > Identity and add a word to the end of the Bundle Identifier to make it unique. Also select your Apple ID in Signing > Team

6. Connect your iPad or iPhone and select it in Xcode's Product menu > Destination

7. Press CMD+R or Product > Run to install Zocus

## License

zocus-ios is available under the GPLv3 License
