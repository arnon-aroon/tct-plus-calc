# TCT Plus Calc

Thai Chuay Thai Plus 60/40 co-pay calculator for the 2026 scheme period.

## What it does

Calculates the patient co-pay amount under the Thai Chuay Thai Plus scheme where the government covers 60% and the patient pays 40% of eligible medical expenses.

## Scheme Dates

**Active period: June 1 – September 30, 2026**

## Download (Android)

**[Download APK — v0.1.1](https://github.com/arnon-aroon/tct-plus-calc/releases/download/v0.1.1/app-release.apk)**

To sideload: enable *Install unknown apps* on your device, then open the downloaded APK and tap Install.

## Related

- Tracker issue: [TCT-1](/TCT/issues/TCT-1)

## Getting Started

```sh
flutter run
```

Targets: iOS, Android.

## Running iOS from source

**Requirements:**
- macOS with Xcode 15.0 or later
- CocoaPods 1.14.0 or later (`gem install cocoapods`)
- Flutter 3.10.0 or later

**Steps:**

```sh
# Clone the repo
git clone https://github.com/arnon-aroon/tct-plus-calc.git
cd tct-plus-calc

# Install dependencies
flutter pub get
cd ios && pod install && cd ..

# Run on a connected device or simulator
flutter run
```

To target a specific simulator:

```sh
flutter devices          # list available devices
flutter run -d <device-id>
```

**Troubleshooting:**
- If CocoaPods fails, try `pod repo update` then `pod install` again.
- Xcode must have the iOS SDK installed (Xcode → Settings → Platforms → iOS).
