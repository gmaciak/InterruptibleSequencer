//
//  ViewController.m
//  InterruptibleSequencer
//
//  Created by Grzegorz Maciak on 24.08.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import "ViewController.h"
#import "MyInterruptibleSequencer.h"

@interface ViewController () <DSEInterruptibleSequencerDelegate> {
    BOOL interruptible;
}

@end

@implementation ViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DSEInterruptibleSequencerInterruptedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DSEInterruptibleSequencerDidFinishNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(10, 30, 300, 30);
    [button setTitle:@"Start sequence" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(startSequence) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(10, 70, 300, 30);
    [button setTitle:@"Start sequence with notifications enabled" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(startSequenceWithNotifications) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(10, 110, 300, 30);
    [button setTitle:@"Start sequence with delegate" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(startSequenceWithDelegate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UISwitch *interruptibleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button.frame), CGRectGetMinY(button.frame), 0, 0)];
    [interruptibleSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:interruptibleSwitch];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSequencerInterrupted:) name:DSEInterruptibleSequencerInterruptedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSequenceCompleted:) name:DSEInterruptibleSequencerDidFinishNotification object:nil];
}

#pragma mark - Actions

- (void)onSwitch:(UISwitch*)sender {
    interruptible = sender.isOn;
}

- (void)startSequence {
    InterruptibleSequencer *sequencer = [[MyInterruptibleSequencer alloc] init];
    sequencer.identifier = @"sequencer_with_blocks";
    
    // input data which will be forwarded between the steps as a 'result' parameter
    NSMutableDictionary* input = [NSMutableDictionary dictionaryWithCapacity:1];
    input[@"ShouldInterrupt"] = @NO;
    
    // interrupt text
    sequencer.interruptTest = ^(id result, SequencerInterruptTestCompletion completion) {
        
        if ([result[@"ShouldInterrupt"] boolValue]) {
            [self showShouldInterruptAlert:completion];
        }else{
            completion(NO);
        }
    };
    
    // block to invoke when sequence is interrupted
    sequencer.interruptedBlock = ^(id nextRresult){
        [self showInterruptedAlertWithTitle:@"Block"];
    };
    
    // setps
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        NSLog(@"Sequencer with blocks setp 1 DONE.");
        
        // set interrupt flag
        result[@"ShouldInterrupt"] = @YES;
        
        // go to next step (if invocation of completion block is missing
        // here is the point where sequencer stops and is removed)
        // mark the following line as comment ane look at the console log to check it out
        completion(result);
    }];
    
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        NSLog(@"Sequencer with blocks setp 2 DONE.");
        completion(result);
    }];
    
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        NSLog(@"Sequencer with blocks setp 3 DONE.");
        completion(result);
    }];
    
    // last step
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        
        // show alert, there is no finish block because it is not needed
        [self showFinishedAlertWithTitle:@"Done."];
        
        NSLog(@"Sequencer with blocks setp 4 (last) DONE.");
        
        // following line is required in case you use DSEInterruptibleSequencerDidFinishNotification notification
//        completion(result);
    }];
    
    [sequencer runWithResult:input];
}

- (void)startSequenceWithNotifications {
    InterruptibleSequencer *sequencer = [[MyInterruptibleSequencer alloc] init];
    sequencer.identifier = @"sequencer_with_notifications";
    
    // you need to enable notifications of the sequencer if you want to handle them
    sequencer.enableNotifications = YES;
    
    // input data which will be forwarded between the steps as a 'result' parameter
    NSMutableDictionary* input = [NSMutableDictionary dictionaryWithCapacity:1];
    input[@"ShouldInterrupt"] = @NO;
    
    // interrupt text
    sequencer.interruptTest = ^(id result, SequencerInterruptTestCompletion completion) {
        
        if ([result[@"ShouldInterrupt"] boolValue]) {
            [self showShouldInterruptAlert:completion];
        }else{
            completion(NO);
        }
    };
    
    // setps
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        NSLog(@"Sequencer with notifications setp 1 DONE.");
        
        // set interrupt flag
        result[@"ShouldInterrupt"] = @YES;
        
        // go to next step (if you omit invocation of completion block, here is the point where sequencer stops and is removed)
        // mark the following line as comment ane look at the console log to check it out
        completion(result);
    }];
    
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        NSLog(@"Sequencer with notifications setp 2 DONE.");
        completion(result);
    }];
    
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        NSLog(@"Sequencer with notifications setp 3 DONE.");
        completion(result);
    }];
    
    // last step
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        NSLog(@"Sequencer with notifications setp 4 (last) DONE.");
        
        // !!!: following line is required in case you use DSEInterruptibleSequencerDidFinishNotification notification
        completion(result);
    }];
    
    [sequencer runWithResult:input];
}

- (void)startSequenceWithDelegate {
    InterruptibleSequencer *sequencer = [[MyInterruptibleSequencer alloc] init];
    sequencer.identifier = @"sequencer_with_notifications";
    
    // you need to set delegate of the sequencer
    sequencer.delegate = self;
    
    // input data which will be forwarded between the steps as a 'result' parameter
    NSMutableDictionary* input = [NSMutableDictionary dictionaryWithCapacity:1];
    input[@"ShouldInterrupt"] = @NO;
    
    // interrupt text is not used if delegate method `-interruptibleSequencer:shouldInterrupt:` is implemented,
    // but you can still fire the test with `-testForInterruptWithResult:complete:` if you need
//    sequencer.interruptTest = ^(id result, SequencerInterruptTestCompletion completion) {
//        
//        if ([result[@"ShouldInterrupt"] boolValue]) {
//            [self showShouldInterruptAlert:completion];
//        }else{
//            completion(NO);
//        }
//    };
    
    // setps
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        NSLog(@"Sequencer with delegate setp 1 DONE.");
        
        // set interrupt flag
        result[@"ShouldInterrupt"] = @(interruptible);
        
        // go to next step (if you omit invocation of completion block, here is the point where sequencer stops and is removed)
        // mark the following line as comment ane look at the console log to check it out
        completion(result);
    }];
    
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        NSLog(@"Sequencer with delegate setp 2 DONE.");
        completion(result);
    }];
    
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        NSLog(@"Sequencer with delegate setp 3 DONE.");
        completion(result);
    }];
    
    // last step
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        NSLog(@"Sequencer with delegate setp 4 (last) DONE.");
        
        // !!!: following line is required if you want to inform the delegate that the sequence is finished
        completion(result);
    }];
    
    [sequencer runWithResult:input];
}

- (void)onSequencerInterrupted:(NSNotification*)notification {
    [self showInterruptedAlertWithTitle:@"Notification"];
}

- (void)onSequenceCompleted:(NSNotification*)notification {
    [self showFinishedAlertWithTitle:@"Notification"];
}

- (void)showShouldInterruptAlert:(SequencerInterruptTestCompletion)completion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Interrupt" message:@"Do you want to break the task?" preferredStyle:UIAlertControllerStyleAlert];
    
    // actions
    [alert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                completion(YES);
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action) {
                                                completion(NO);
                                            }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showInterruptedAlertWithTitle:(NSString*)title {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"Sequencer has been stopped." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showFinishedAlertWithTitle:(NSString*)title {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"Sequence completed." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - DSEInterruptibleSequencerDelegate

- (BOOL)interruptibleSequencer:(InterruptibleSequencer *)sequencer shouldInterrupt:(id)result {
    return [result[@"ShouldInterrupt"] boolValue];
}

- (void)interruptibleSequencer:(InterruptibleSequencer *)sequencer interrupted:(id)result {
    [self showInterruptedAlertWithTitle:@"Delegate"];
}

- (void)interruptibleSequencer:(InterruptibleSequencer *)sequencer didFinishWithResult:(id)result {
    [self showFinishedAlertWithTitle:@"Delegate"];
}

@end



