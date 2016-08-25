//
//  InterruptibleSequencer.m
//  InterruptibleSequencer
//
//  Created by Grzegorz Maciak on 24.10.2014.
//  Copyright (c) 2016 Grzegorz Maciak. All rights reserved.
//

// This code is distributed under the terms and conditions of the MIT license:

// Copyright (c) 2016 Grzegorz Maciak
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "InterruptibleSequencer.h"

@interface Sequencer (ProtectedInterface)
- (void)runNextStepWithResult:(id)result;
@end

@implementation InterruptibleSequencer

#pragma mark - Initializing

#if ! __has_feature(objc_arc)
- (void)dealloc {
    self.delegate = nil;
    self.identifier = nil;
    self.interruptTest = nil;
    self.interruptedBlock = nil;
    [super dealloc];
}
#endif

#pragma mark - Lifecycle

- (void)runWithResult:(id)resultObject {
    [self runNextStepWithResult:resultObject];
}

- (void)runNextStepWithResult:(id)result {
    if ([steps count] <= 0) {
        if ([_delegate respondsToSelector:@selector(interruptibleSequencer:didFinishWithResult:)]) {
            [_delegate interruptibleSequencer:self didFinishWithResult:result];
        }
        if (_enableNotifications) {
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
            userInfo[DSEInterruptibleSequencerUserInfoSequencerIdKey] = self.identifier;
            userInfo[DSEInterruptibleSequencerUserInfoResultKey] = result;
            [[NSNotificationCenter defaultCenter] postNotificationName:DSEInterruptibleSequencerDidFinishNotification object:self userInfo:userInfo];
        }
        return;
    }
    if ([_delegate respondsToSelector:@selector(interruptibleSequencer:shouldInterrupt:)]) {
        BOOL shouldInterrupt = [_delegate interruptibleSequencer:self shouldInterrupt:result];
        [self shouldInterrupt:shouldInterrupt withResult:result];
    }else{
        [self testForInterruptWithResult:result complete:^(BOOL shouldInterrupt) {
            [self shouldInterrupt:shouldInterrupt withResult:result];
        }];
    }
}

- (void)shouldInterrupt:(BOOL)shouldInterrupt withResult:(id)result {
    if (!shouldInterrupt) {
        [super runNextStepWithResult:result];
    }else{
        if (self.interruptedBlock) {
            self.interruptedBlock(result);
        }
        if ([_delegate respondsToSelector:@selector(interruptibleSequencer:interrupted:)]) {
            [_delegate interruptibleSequencer:self interrupted:result];
        }
        if (_enableNotifications) {
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
            userInfo[DSEInterruptibleSequencerUserInfoSequencerIdKey] = self.identifier;
            userInfo[DSEInterruptibleSequencerUserInfoResultKey] = result;
            [[NSNotificationCenter defaultCenter] postNotificationName:DSEInterruptibleSequencerInterruptedNotification object:self userInfo:userInfo];
        }
    }
}

- (void)testForInterruptWithResult:(id)result complete:(SequencerInterruptTestCompletion)complete {
    if (self.interruptTest) {
        self.interruptTest(result, ^(BOOL shouldInterrupt) {
            complete(shouldInterrupt);
        });
    }
    else {
        complete(NO);
    }
}

@end

NSString* const DSEInterruptibleSequencerDidFinishNotification = @"DSEInterruptibleSequencerDidFinishNotification";
NSString* const DSEInterruptibleSequencerInterruptedNotification = @"DSEInterruptibleSequencerInterruptedNotification";

NSString* const DSEInterruptibleSequencerUserInfoSequencerIdKey = @"identifier";
NSString* const DSEInterruptibleSequencerUserInfoResultKey = @"result";
