# Hermes Agent on Samsung S25 Ultra (Termux)

Hermes is a companion runtime, not embedded inside the Flutter APK. Keep the core app functional when Hermes is stopped or offline.

## Install
1. Install the official Termux build from F-Droid or the Termux GitHub releases. Do not mix Termux add-ons from different signing sources.
2. Open Termux and run the documented Termux installer:

```bash
# Refresh packages and install Hermes prerequisites.
pkg update
pkg upgrade
pkg install -y git python clang rust make pkg-config libffi openssl nodejs ripgrep ffmpeg

# Download Hermes source with its submodules.
git clone --recurse-submodules https://github.com/NousResearch/hermes-agent.git
cd hermes-agent

# Prepare Android-specific Python environment.
python -m venv venv
source venv/bin/activate
export ANDROID_API_LEVEL="$(getprop ro.build.version.sdk)"
python -m pip install --upgrade pip setuptools wheel

# Install only the documented Termux extra, not [all].
python -m pip install -e '.[termux]' -c constraints-termux.txt
ln -sf "$PWD/venv/bin/hermes" "$PREFIX/bin/hermes"

# Verify the installation and configure one model provider.
hermes version
hermes doctor
hermes setup
```

## Run
```bash
# Start the Hermes terminal agent.
hermes

# Optional gateway process; Android may suspend background apps.
hermes gateway run
```

## Android caveats
- Termux background processes can be killed by Android power management.
- Battery optimization exemptions and `termux-wake-lock` may help but do not guarantee persistent execution.
- Docker terminal isolation, browser automation, and some voice dependencies are not part of the tested Termux path.
- Hermes may use a configured provider; it is not automatically a local model. Configure a local endpoint or provider deliberately if you want local inference.
- Do not expose the gateway to the public internet. Pair the app and gateway with explicit authentication and a tool allow-list.
