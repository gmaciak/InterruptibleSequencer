InterruptibleSequencer
=========

InterruptibleSequencer is an extension of an iOS library for asynchronous flow control which I found very useful in my work.

It alows to break the sequence after each step.
You may ask the user about confirmation and depending on the decision break the sequence or continue.

You can find an example of code below.
For more details and cases I recommand to clone the repository and run the demo application on iOS.

```objc
DSEInterruptibleSequencer *sequencer = [[MyInterruptibleSequencer alloc] init];
sequencer.identifier = @"sequencer_with_blocks";

// input data which will be forwarded between the steps as a 'result' parameter
NSMutableDictionary* input = [NSMutableDictionary dictionaryWithCapacity:1];
input[@"ShouldInterrupt"] = @NO;

// interrupt text
sequencer.interruptTest = ^(id result, SequencerInterruptTestCompletion completion) {
    
    if ([result[@"ShouldInterrupt"] boolValue]) {
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
    }else{
        completion(NO);
    }
};

// block to invoke when sequence is interrupted
sequencer.interruptedBlock = ^(id nextRresult){
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Interrupted" message:@"Sequencer has been stopped." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Done" message:@"Sequence completed." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
    NSLog(@"Sequencer with blocks setp 4 (last) DONE.");
    
    // following line is required in case you use DSEInterruptibleSequencerDidFinishNotification notification
    // or if you want to inform the delegate that the sequence is finished
    //completion(result);
}];

[sequencer runWithResult:input];
```

Original "Sequencer"
=========

For details about orginal Sequencer lib please see https://github.com/berzniz/Sequencer


## License

This code is distributed under the terms and conditions of the MIT license:

Copyright (c) 2016 Grzegorz Maciak

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
