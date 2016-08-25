#import "DSEInterruptibleSequencer.h"

@interface Sequencer (ProtectedInterface)
- (void)runNextStepWithResult:(id)result;
@end

@implementation DSEInterruptibleSequencer

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
