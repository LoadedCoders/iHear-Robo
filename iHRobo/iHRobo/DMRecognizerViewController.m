//
//  DMRecognizerViewController.m
//  DMRecognizer
//
// Copyright 2010, Nuance Communications Inc. All rights reserved.
//
// Nuance Communications, Inc. provides this document without representation 
// or warranty of any kind. The information in this document is subject to 
// change without notice and does not represent a commitment by Nuance 
// Communications, Inc. The software and/or databases described in this 
// document are furnished under a license agreement and may be used or 
// copied only in accordance with the terms of such license agreement.  
// Without limiting the rights under copyright reserved herein, and except 
// as permitted by such license agreement, no part of this document may be 
// reproduced or transmitted in any form or by any means, including, without 
// limitation, electronic, mechanical, photocopying, recording, or otherwise, 
// or transferred to information storage and retrieval systems, without the 
// prior written permission of Nuance Communications, Inc.
// 
// Nuance, the Nuance logo, Nuance Recognizer, and Nuance Vocalizer are 
// trademarks or registered trademarks of Nuance Communications, Inc. or its 
// affiliates in the United States and/or other countries. All other 
// trademarks referenced herein are the property of their respective owners.
//

#import "DMRecognizerViewController.h"


#define WELCOME_MES 0
#define ECHO_MSG 1
#define WARNING_MES 2

#define READ_TIMEOUT 150.0
#define READ_TIMEOUT_EXTENTION 10.0

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
#define PORT 1234

const unsigned char SpeechKitApplicationKey[] = {0xcd, 0xb5, 0x4a, 0x7f, 0x8b, 0x18, 0xc3, 0x4e, 0xe1, 0x5a, 0xbe, 0xae, 0x85, 0xea, 0x7c, 0xcb, 0xec, 0x6a, 0x8e, 0x18, 0x07, 0xf9, 0x69, 0x6d, 0x5c, 0x8e, 0x06, 0x49, 0x40, 0x74, 0x26, 0x0e, 0x29, 0x71, 0x8d, 0xb4, 0x89, 0x50, 0x02, 0x6a, 0xaa, 0xc1, 0x19, 0x2f, 0xab, 0x95, 0xfa, 0x98, 0x00, 0x88, 0xb0, 0x07, 0x81, 0x19, 0x74, 0xdd, 0xa7, 0x7a, 0x27, 0xe8, 0xef, 0x4d, 0xf6, 0x18};


@interface DMRecognizerViewController(){
    
}

@end

@implementation DMRecognizerViewController


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    socketQueue = dispatch_queue_create("socketQueue", NULL);
    listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    
    // Setup an array to store all accepted client connections
    connectedSockets = [[NSMutableArray alloc]initWithCapacity:1];
    
    isRunning = NO;
    
    NSLog(@"Ip Address is : %@", [self getIPAddress]);

	
    [SpeechKit setupWithID:@"NMDPTRIAL_pradyumnadoddala_gmail_com20151013142247"
                      host:@"sslsandbox.nmdp.nuancemobility.net"
                      port:443
                    useSSL:YES
                  delegate:nil];
    
	// Set earcons to play
	SKEarcon* earconStart	= [SKEarcon earconWithName:@"earcon_listening.wav"];
	SKEarcon* earconStop	= [SKEarcon earconWithName:@"earcon_done_listening.wav"];
	SKEarcon* earconCancel	= [SKEarcon earconWithName:@"earcon_cancel.wav"];
	
	[SpeechKit setEarcon:earconStart forType:SKStartRecordingEarconType];
	[SpeechKit setEarcon:earconStop forType:SKStopRecordingEarconType];
	[SpeechKit setEarcon:earconCancel forType:SKCancelRecordingEarconType];
    
    
    // For Textview
    [_textView setScrollEnabled:YES];
    [_textView setUserInteractionEnabled:YES];
    _textView.delegate =self;
    [self.view addSubview:_textView];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark - Text View delegates

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:
(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    return YES;
}
-(void)textViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"Did begin editing");
    [textView resignFirstResponder];
}
-(void)textViewDidChange:(UITextView *)textView{
    NSLog(@"Did Change");
    
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"Did End editing");
    
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    NSLog(@"Ur here");
    [textView resignFirstResponder];
    return YES;
}

 //reassigning the keyboard by touching on screens
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - 
#pragma mark Send to Spark button

- (IBAction)SendtoSpark:(id)sender {
    
    NSString *msg = self.searchBox.text;
    NSLog(@"message is %@",msg);
    NSData *dataout = [msg dataUsingEncoding:NSASCIIStringEncoding];
    [listenSocket writeData:dataout withTimeout:-1 tag:0];
    //[listenSocket writeData:data  withTimeout:-1 tag:theTag];
    [self speakText:@"Sending data to spark"];
    
}

#pragma mark -
#pragma mark Actions

- (IBAction)recordButtonAction: (id)sender {
    [self.searchBox resignFirstResponder];
    
    if (transactionState == TS_RECORDING) {
        [self.voiceSearch stopRecording];
    }
    else if (transactionState == TS_IDLE) {
        SKEndOfSpeechDetection detectionType;
        NSString* recoType;
        NSString* langType;
        
        transactionState = TS_INITIAL;
        
        detectionType = SKShortEndOfSpeechDetection; /* Searches tend to be short utterances free of pauses. */
        recoType = SKSearchRecognizerType; /* Optimize recognition performance for search text. */
        
//        if (recognitionType.selectedSegmentIndex == 0) {
//            /* 'Search' is selected */
//            detectionType = SKShortEndOfSpeechDetection; /* Searches tend to be short utterances free of pauses. */
//            recoType = SKSearchRecognizerType; /* Optimize recognition performance for search text. */
//        }
//        else if (recognitionType.selectedSegmentIndex == 1){
//            /* 'Dictation' is selected */
//            detectionType = SKLongEndOfSpeechDetection; /* Dictations tend to be long utterances that may include short pauses. */
//            recoType = SKDictationRecognizerType; /* Optimize recognition performance for dictation or message text. */
//        } else {
//            /* 'TV' is selected */
//            detectionType = SKLongEndOfSpeechDetection; /* Dictations tend to be long utterances that may include short pauses. */
//            recoType = SKTvRecognizerType; /* Optimize recognition performance for dictation or message text. */
//        }
		
        langType = @"en_US";
        
//		switch (languageType.selectedSegmentIndex) {
//			case 0:
//				langType = @"en_US";
//				break;
//			case 1:
//				langType = @"en_GB";
//				break;
//			case 2:
//				langType = @"fr_FR";
//				break;
//			case 3:
//				langType = @"de_DE";
//				break;
//			default:
//				langType = @"en_US";
//				break;
//		}
        /* Nuance can also create a custom recognition type optimized for your application if neither search nor dictation are appropriate. */
        
        NSLog(@"Recognizing type:'%@' Language Code: '%@' using end-of-speech detection:%d.", recoType, langType, detectionType);

        if (_voiceSearch) {
            _voiceSearch = nil;
        }
		
        _voiceSearch = [[SKRecognizer alloc] initWithType:recoType
                                               detection:detectionType
                                                language:langType 
                                                delegate:self];
    }
}

#pragma mark -
#pragma mark VU Meter

- (void)setVUMeterWidth:(float)width {
    if (width < 0)
        width = 0;
    
    CGRect frame = _vuMeter.frame;
    frame.size.width = width+10;
    _vuMeter.frame = frame;
}

- (void)updateVUMeter {
    float width = (90+_voiceSearch.audioLevel)*5/2;
    
    [self setVUMeterWidth:width];    
    [self performSelector:@selector(updateVUMeter) withObject:nil afterDelay:0.05];
}

#pragma mark -
#pragma mark SpeechKitDelegate methods

- (void) audioSessionReleased {
    NSLog(@"audio session released");
}

- (void) destroyed {
    // Debug - Uncomment this code and fill in your app ID below, and set
    // the Main Window nib to MainWindow_Debug (in DMRecognizer-Info.plist)
    // if you need the ability to change servers in DMRecognizer
    //
    //[SpeechKit setupWithID:INSERT_YOUR_APPLICATION_ID_HERE
    //                  host:INSERT_YOUR_HOST_ADDRESS_HERE
    //                  port:INSERT_YOUR_HOST_PORT_HERE[[portBox text] intValue]
    //                useSSL:NO
    //              delegate:self];
    //
	// Set earcons to play
	//SKEarcon* earconStart	= [SKEarcon earconWithName:@"earcon_listening.wav"];
	//SKEarcon* earconStop	= [SKEarcon earconWithName:@"earcon_done_listening.wav"];
	//SKEarcon* earconCancel	= [SKEarcon earconWithName:@"earcon_cancel.wav"];
	//
	//[SpeechKit setEarcon:earconStart forType:SKStartRecordingEarconType];
	//[SpeechKit setEarcon:earconStop forType:SKStopRecordingEarconType];
	//[SpeechKit setEarcon:earconCancel forType:SKCancelRecordingEarconType];    
}

#pragma mark -
#pragma mark SKRecognizerDelegate methods

- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
{
    NSLog(@"Recording started.");
    
    transactionState = TS_RECORDING;
    [self.recordButton setTitle:@"Recording..." forState:UIControlStateNormal];
    [self performSelector:@selector(updateVUMeter) withObject:nil afterDelay:0.05];
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
{
    NSLog(@"Recording finished.");

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateVUMeter) object:nil];
    [self setVUMeterWidth:0.];
    transactionState = TS_PROCESSING;
    [self.recordButton setTitle:@"Processing..." forState:UIControlStateNormal];
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results
{
    NSLog(@"Got results.");
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id 

    long numOfResults = [results.results count];
    
    transactionState = TS_IDLE;
    [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
    
    if (numOfResults > 0)
        self.searchBox.text = [results firstResult];
    
	if (numOfResults > 1) 
		NSLog(@"%@", [[results.results subarrayWithRange:NSMakeRange(1, numOfResults-1)] componentsJoinedByString:@"\n"]);
    
    if (results.suggestion){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Suggestion"
                                                                       message:results.suggestion
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }

	_voiceSearch = nil;
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion
{
    NSLog(@"Got error.");
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id 
    
    transactionState = TS_IDLE;
    [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
    
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:[error localizedDescription]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    if (suggestion) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Suggestion"
                                                                       message:suggestion
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
	_voiceSearch = nil;
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.searchBox)
    {
        [self.searchBox resignFirstResponder];
    }
    return YES;
}


#pragma mark -
#pragma mark Ipaddress

- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}


#pragma mark -
#pragma mark Socket

- (void)toggleSocketState
{
    if(!isRunning)
    {
        NSError *error = nil;
        if(![listenSocket acceptOnPort:PORT error:&error])
        {
            [self log:FORMAT(@"Error starting server: %@", error)];
            return;
        }
        
        [self log:FORMAT(@"Echo server started on port %hu", [listenSocket localPort])];
        isRunning = YES;
    }
    else
    {
        // Stop accepting connections
        [listenSocket disconnect];
        
        // Stop any client connections
        @synchronized(connectedSockets)
        {
            NSUInteger i;
            for (i = 0; i < [connectedSockets count]; i++)
            {
                // Call disconnect on the socket,
                // which will invoke the socketDidDisconnect: method,
                // which will remove the socket from the list.
                [[connectedSockets objectAtIndex:i] disconnect];
            }
        }
        
        [self log:@"Stopped Echo server"];
        isRunning = false;
    }
}


- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    // This method is executed on the socketQueue (not the main thread)
    
    if (tag == ECHO_MSG)
    {
        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:100 tag:0];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    NSLog(@"== didReadData %@ ==", sock.description);
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self log:msg];
    _textView.text = msg;
    //[self speakText:msg];
    [sock readDataWithTimeout:READ_TIMEOUT tag:0];
}

/**
 * This method is called if a read has timed out.
 * It allows us to optionally extend the timeout.
 * We use this method to issue a warning to the user prior to disconnecting them.
 **/
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    if (elapsed <= READ_TIMEOUT)
    {
        NSString *warningMsg = @"Are you still there?\r\n";
        NSData *warningData = [warningMsg dataUsingEncoding:NSUTF8StringEncoding];
        
        [sock writeData:warningData withTimeout:-1 tag:WARNING_MES];
        
        return READ_TIMEOUT_EXTENTION;
    }
    
    return 0.0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (sock != listenSocket)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                [self log:FORMAT(@"Client Disconnected")];
            }
        });
        
        @synchronized(connectedSockets)
        {
            [connectedSockets removeObject:sock];
        }
    }
}

- (void)log:(NSString *)msg {
    NSLog(@"%@", msg);
}

- (NSString *)direction:(NSString *)message {
    
    return @"";
}


#pragma mark -
#pragma mark -text to speech function

- (void)speakText:(NSString*)text {
    NSLog(@"in speakText");
    NSString *cmd = [text uppercaseString];
    if (_synthesizer == nil) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate = self;
    }
    
    AVSpeechUtterance *utterence = [[AVSpeechUtterance alloc] initWithString:cmd];
    utterence.rate = _speed;
    
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    [utterence setVoice:voice];
    
    [_synthesizer speakUtterance:utterence];
    
}


@end
