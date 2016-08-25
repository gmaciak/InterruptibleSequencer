//
//  InterruptibleSequencer.h
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

#import "Sequencer.h"

typedef void(^SequencerInterruptTestCompletion)(BOOL shouldInterrupt);
typedef void(^SequencerInterruptTest)(id result, SequencerInterruptTestCompletion completion);

@protocol DSEInterruptibleSequencerDelegate;

@interface InterruptibleSequencer : Sequencer

@property(nonatomic,copy) NSString* identifier;
@property(nonatomic,assign) id<DSEInterruptibleSequencerDelegate> delegate;
@property(nonatomic,assign) BOOL enableNotifications;
@property(nonatomic,copy) SequencerInterruptTest interruptTest; // used if delegate method `-interruptibleSequencer:shouldInterrupt:` is not implemented
@property(nonatomic,copy) SequencerCompletion interruptedBlock;


/** Starts sequencer with initial result value which will be passed to first step as a `result` param
 
 @param resultObject Initial value of the result passing through the steps. For example mutable array or dictionary which collects results of all steps.
 */
- (void)runWithResult:(id)resultObject;

/** Invokes interruptTest block.
 
 Delegate has geater priority than block.
 When delegate has implemented `-interruptibleSequencer:shouldInterrupt:` method the interruptTest block is not used but you can still invoke the test with the following method.
 */
- (void)testForInterruptWithResult:(id)result complete:(SequencerInterruptTestCompletion)complete;

@end

@protocol DSEInterruptibleSequencerDelegate <NSObject>
@optional
- (BOOL)interruptibleSequencer:(InterruptibleSequencer*)sequencer shouldInterrupt:(id)result;
- (void)interruptibleSequencer:(InterruptibleSequencer*)sequencer interrupted:(id)result;
- (void)interruptibleSequencer:(InterruptibleSequencer*)sequencer didFinishWithResult:(id)result;
@end

FOUNDATION_EXPORT NSString* const DSEInterruptibleSequencerDidFinishNotification;
FOUNDATION_EXPORT NSString* const DSEInterruptibleSequencerInterruptedNotification;

FOUNDATION_EXPORT NSString* const DSEInterruptibleSequencerUserInfoSequencerIdKey;
FOUNDATION_EXPORT NSString* const DSEInterruptibleSequencerUserInfoResultKey;
