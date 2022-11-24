# audio_picker

A Flutter plugin for Android and iOS to pick local Audio files. This supports choosing Audio files from the Music App in iOS, and from the File Explorer in Android.

## Introduction
This plugin opens a picker to get the absolute path of Audio files from your phone.
If you ever wanted to play songs in your app, or upload audio files to your server, this plugin helps you get the **absolute path** of the audio file that you select.

## Android
Add the following line in your AndroidManifest.xml 

    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>


## iOS
Add the following line in your Info.plist 

    <key>NSAppleMusicUsageDescription</key>
    <string>Explain why your app uses music</string>

In the case of iOS, it exports the audio file that you choose from the Music App.

## Usage
    var path = await AudioPicker.pickAudio();

That's it ! You now have the absolute path of the audio file that you selected.

<img src="https://firebasestorage.googleapis.com/v0/b/electionapp-24b60.appspot.com/o/IMG_3477.PNG?alt=media&token=8eec8fc9-0358-42de-8209-ae09413cbb3d" width="280" height="610"> <img src="https://firebasestorage.googleapis.com/v0/b/electionapp-24b60.appspot.com/o/IMG_67F45460A1AD-1.jpeg?alt=media&token=65172f34-70d6-43f0-9c5a-18aab250d43e" width="280" height="610">
<img src="https://firebasestorage.googleapis.com/v0/b/electionapp-24b60.appspot.com/o/Screenshot_2019-10-27-00-53-48-63.png?alt=media&token=255a4494-2f7e-4994-8390-e0c051db8ee6" width="280" height="610">

Note : In the case of iOS, since we are retrieving the file from the Music App, the export operation may take a few seconds to complete. Hence it's advisable to show a loading indicator to the user while the `await` call executes.
Also note that DRM protected files won't return a path, and instead will return `null` as the path.

## Upcoming features - 
* Retrieve metadata of the audio file (Name, Duration, etc)
* Multiselect audio files
* Filter based on file extension

Pull Requests and feature requests are welcome !

## LICENSE
```
MIT License

Copyright (c) 2017 ChiragShenoy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

