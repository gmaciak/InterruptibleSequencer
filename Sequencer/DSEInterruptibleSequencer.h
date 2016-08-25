//
//  InterruptibleSequencer.h
//  InterruptibleSequencer
//
//  Created by Grzegorz Maciak on 24.10.2014.
//  Copyright (c) 2014 Grzegorz Maciak. All rights reserved.
//

#import "Sequencer.h"

typedef void(^SequencerInterruptTestCompletion)(BOOL shouldInterrupt);
typedef void(^SequencerInterruptTest)(id result, SequencerInterruptTestCompletion completion);

@protocol DSEInterruptibleSequencerDelegate;

@interface DSEInterruptibleSequencer : Sequencer

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
- (BOOL)interruptibleSequencer:(DSEInterruptibleSequencer*)sequencer shouldInterrupt:(id)result;
- (void)interruptibleSequencer:(DSEInterruptibleSequencer*)sequencer interrupted:(id)result;
- (void)interruptibleSequencer:(DSEInterruptibleSequencer*)sequencer didFinishWithResult:(id)result;
@end

FOUNDATION_EXPORT NSString* const DSEInterruptibleSequencerDidFinishNotification;
FOUNDATION_EXPORT NSString* const DSEInterruptibleSequencerInterruptedNotification;

FOUNDATION_EXPORT NSString* const DSEInterruptibleSequencerUserInfoSequencerIdKey;
FOUNDATION_EXPORT NSString* const DSEInterruptibleSequencerUserInfoResultKey;
