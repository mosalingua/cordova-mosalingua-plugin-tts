# Cordova Mosalingua Text-to-Speech Plugin

## Platforms

iOS 7+  

## Installation

```sh
cordova plugin add cordova-mosalingua-plugin-tts
```

## Usage

```javascript
// make sure your the code gets executed only after `deviceready`.

    // basic usage
    TTS
        .speak('hello, world!',function () {
            alert('success');
        }, function (error) {
            alert(error);
        });

    // or with more options
    TTS
        .speak('hello, world!', {locale: 'en-GB',rate: 0.75, volume: 1.0},
            function () {
            alert('success');
        }, function (error) {
            alert(error);
        });
```
