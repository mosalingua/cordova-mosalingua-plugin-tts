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

#import <Cordova/CDV.h>
#import "CDVTTS.h"

@implementation CDVTTS

- (void)pluginInitialize {
    synthesizer = [AVSpeechSynthesizer new];
    synthesizer.delegate = self;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance*)utterance {
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    if (lastCallbackId) {
        [self.commandDelegate sendPluginResult:result callbackId:lastCallbackId];
        lastCallbackId = nil;
    } else {
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        callbackId = nil;
    }
    
    [[AVAudioSession sharedInstance] setActive:NO withOptions:0 error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient
                                     withOptions: 0 error: nil];
    [[AVAudioSession sharedInstance] setActive:YES withOptions: 0 error:nil];
    
}

- (void)speak:(CDVInvokedUrlCommand*)command {
    
    
    [self.commandDelegate runInBackground:^{
        NSDictionary* options = [command.arguments objectAtIndex:0];
        
        [[AVAudioSession sharedInstance] setActive:NO withOptions:0 error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient
                                         withOptions: 0 error: nil];
        [[AVAudioSession sharedInstance] setActive:YES withOptions: 0 error:nil];
        
        if (callbackId) {
            lastCallbackId = callbackId;
        }
        callbackId = command.callbackId;
        
        [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        
        NSString* text = [options objectForKey:@"text"];
        NSString* locale = [options objectForKey:@"locale"];
        double rate = [[options objectForKey:@"rate"] doubleValue];
        double volume = 1.0;
        
        if([options objectForKey:@"volume"] !=nil) {
            volume = [[options objectForKey:@"volume"] doubleValue];
        }
        double pitch = [[options objectForKey:@"pitch"] doubleValue];
        
        if (!locale || (id)locale == [NSNull null]) {
            locale = @"en-US";
        }
        
        NSArray *voices = [AVSpeechSynthesisVoice speechVoices];
        AVSpeechSynthesisVoice *voiceToUse = nil;
        for(AVSpeechSynthesisVoice *voice in voices) {
            
            if([voice.language isEqualToString:locale] && voice.identifier!= nil){
                voiceToUse = voice;
            }
        }
        
        if (!rate) {
            rate = 1.0;
        }
        
        if (!pitch) {
            pitch = 1.2;
        }
        
        AVSpeechUtterance* utterance = [[AVSpeechUtterance new] initWithString:text];
        utterance.voice = (voiceToUse != nil) ? voiceToUse : [AVSpeechSynthesisVoice voiceWithLanguage:locale];
        // Rate expression adjusted manually for a closer match to other platform.
        utterance.rate = (AVSpeechUtteranceMinimumSpeechRate * 1.5 + AVSpeechUtteranceDefaultSpeechRate) / 2.5 * rate * rate;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
            utterance.rate = utterance.rate * 2;
            // see http://stackoverflow.com/questions/26097725/avspeechuterrance-speed-in-ios-8
        }
        
        utterance.pitchMultiplier = pitch;
        utterance.volume = volume;
        
        [synthesizer speakUtterance:utterance];
        
    }];
    
}

- (void)stop:(CDVInvokedUrlCommand*)command {
    [synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

- (void)checkLanguage:(CDVInvokedUrlCommand *)command {
    NSArray *voices = [AVSpeechSynthesisVoice speechVoices];
    NSString *languages = @"";
    for (id voiceName in voices) {
        languages = [languages stringByAppendingString:@","];
        languages = [languages stringByAppendingString:[voiceName valueForKey:@"language"]];
    }
    if ([languages hasPrefix:@","] && [languages length] > 1) {
        languages = [languages substringFromIndex:1];
    }
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:languages];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end

