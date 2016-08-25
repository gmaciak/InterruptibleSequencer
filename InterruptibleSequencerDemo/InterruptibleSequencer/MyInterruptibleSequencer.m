//
//  MyInterruptibleSequencer.m
//  InterruptibleSequencer
//
//  Created by Grzegorz Maciak on 24.08.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import "MyInterruptibleSequencer.h"

@implementation MyInterruptibleSequencer

- (void)dealloc {
    NSLog(@"Sequencer with id:%@ DEALLOCATED.",self.identifier);
}

@end
