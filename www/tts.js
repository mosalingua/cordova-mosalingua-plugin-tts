/*
    Based on original work from
    Cordova Text-to-Speech Plugin
    https://github.com/vilic/cordova-plugin-tts

    by VILIC VANE
    https://github.com/vilic

    Modified by Paulo Cristo
    cristo.paulo@gmail.com

    MIT License
 */
cordova.define("cordova-mosalingua-plugin-tts.tts", function(require, exports, module) {

    var TTS = {
      speak : function (text, opt, success, error) {
        var options = opt || {};

        if (typeof text == 'string') {
            options.text = text;
        } else {
            options = text;
        }

        cordova.exec(function () {
                success();
            }, function (reason) {
                error(reason);
            }, 'TTS', 'speak', [options]);
    },

    checkLanguage : function(success, error) {
        cordova.exec(success, error, 'TTS', 'checkLanguage', []);
    },

    stop : function() {
     cordova.exec(success, error, 'TTS', 'stop', []);
    }

};

module.exports = TTS;

});