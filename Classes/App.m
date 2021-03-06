#import "App.h"

#import "NSURL+L0URLParsing.h"

@implementation App

NSString *defaultPath = @"/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl";

-(void)awakeFromNib {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    path = [d objectForKey:@"path"];

    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

-(void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    if (nil == path) path = defaultPath;

    // txmt://open/?url=file://~/.bash_profile&line=11&column=2
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];

    if (url && [[url host] isEqualToString:@"open"]) {
        NSDictionary *params = [url dictionaryByDecodingQueryString];
        NSString* file  = [params objectForKey:@"file"];

        if (file) {
            NSString *line = [params objectForKey:@"line"];

            if (file) {
                NSTask *task = [[NSTask alloc] init];
                [task setLaunchPath:path];
                NSString* filePath = [NSString stringWithFormat:@"%@", file, [line integerValue]];
                NSString* command = [NSString stringWithFormat:@"show_overlay {\"overlay\": \"goto\", \"text\":\"%@\"}", filePath];
                [task setArguments:[NSArray arrayWithObjects:@"--command", command , nil]];
                [task launch];
                [task release];
            }
        }
    }

//    if (![prefPanel isVisible]) {
//        [NSApp terminate:self];
//    }
}

-(IBAction)showPrefPanel:(id)sender {
    if (path) {
        [textField setStringValue:path];
    } else {
        [textField setStringValue:defaultPath];
    }
    [prefPanel makeKeyAndOrderFront:nil];
}

-(IBAction)applyChange:(id)sender {
    path = [textField stringValue];

    if (path) {
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        [d setObject:path forKey:@"path"];
    }

    [prefPanel orderOut:nil];
}

@end
