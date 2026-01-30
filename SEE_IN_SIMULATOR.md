# See the App in the Simulator

One script to set up Xcode, build the app, boot the Simulator, and launch FightCityTickets so you can see how it looks.

## Run this on your Mac (in Terminal)

```bash
cd /Users/rentamac/Downloads/FIGHTCITYos-main
./Scripts/see-in-simulator.sh
```

**What it does:**

1. Installs **Homebrew** if needed  
2. Installs **XcodeGen** and **SwiftLint**  
3. Checks **Xcode Command Line Tools** (prompts `xcode-select --install` if missing)  
4. Generates **FightCityTickets.xcodeproj**  
5. **Builds** the app for the iPhone Simulator  
6. **Opens Simulator**, installs the app, and **launches** it  
7. **Opens the project in Xcode** so you can set your Team and run again (⌘R)

**First time:** If you’re asked to install the **Command Line Developer Tools**, accept, wait for the install to finish, then run the script again.

**In Xcode:** Choose your **Team** under **Signing & Capabilities**, then press **⌘R** to run on Simulator or your iPhone.

---

See **FINALIZE_AND_TEST.md** and **MAC_DAY_CHECKLIST.md** for the full flow.
