# Haven
Find safety and comfort near you

## Note about IOS
While the app _should_ work on IOS, I don't own any apple devices and wasn't able to build or test it.

# How to setup the API Key

1. Create a `.env` file in the root of the project and add the following (Without the asterisks):
```
MAPS_API_KEY=*YOUR_API_KEY*
```

2. Execute `flutter pub run build_runner build` in the root of the project

## Android Setup
Add the following to your `android/local.properties` (Again, without the asterisks):
```
mapsApiKey=*YOUR_API_KEY*
```
**Note:** If the `local.properties` doesn't exist, you may need to run `flutter pub get` first


Both of these changes can be commited safely without the api key being commited to the repo. **The same cannot be said for the IOS Setup!**

## IOS Setup
Replace `MAPS_API_KEY` in the `ios/Runner/AppDelegate.swift` file with your Api Key


**WARNING: DO NOT COMMIT THIS CHANGE, OR ELSE YOUR API KEY WILL BE STORED IN THE REPO!!**