To export in development mode:

1. Archive as a Development-signed application in the Xcode Organizer
2. Generate the installer package
```bash
productbuild --component HackWindsOSX.app /Applications HackWindsOSX.pkg --sign "3rd Party Mac Developer Installer"
```
3. Install the package
```bash 
sudo installer -store -pkg HackWindsOSX.pkg -target /
```

## More to come later 
