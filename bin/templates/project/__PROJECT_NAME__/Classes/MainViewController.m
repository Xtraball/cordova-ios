/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  MainViewController.h
//  __PROJECT_NAME__
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "MainViewController.h"
//import remoteControls
#import "RemoteControls.h"
#import "CDVCommon.h"

@implementation MainViewController

@synthesize previewerInfo, previewerAppDomain, previewerAppKey, webViewInfo;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    // View defaults to full size.  If you want to customize the view's size, or its subviews (e.g. webView),
    // you can do so here.

    if(previewerInfo) {
        [self.navigationController setNavigationBarHidden:YES];
    }

    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    // Do any additional setup after loading the view from its nib.
    [[RemoteControls remoteControls] setWebView:self.webView];

    previewerInfo = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Previewer"];

    if(previewerInfo) {
        [[webViewInfo layer] setCornerRadius:5.00f];
        [[webViewInfo layer] setBackgroundColor:[getLightWhiteColor() CGColor]];

        webViewInfo.textColor = getWhiteColor();
        webViewInfo.text = [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(@"Tap twice to go back to apps list.", nil)];
        [webViewInfo sizeToFit];
        webViewInfo.frame = CGRectMake(webViewInfo.frame.origin.x,
                                       webViewInfo.frame.origin.y,
                                       webViewInfo.frame.size.width + 10,
                                       webViewInfo.frame.size.height + 5);

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        tap.numberOfTapsRequired = 2;
        tap.delegate = self;

        [self.webView addGestureRecognizer:tap];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    // Turn off remote control event delivery
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    [[RemoteControls remoteControls] receiveRemoteEvent:receivedEvent];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

/* Comment out the block below to over-ride */

/*
- (UIWebView*) newCordovaViewWithFrame:(CGRect)bounds
{
    return[super newCordovaViewWithFrame:bounds];
}
*/

#pragma mark UIWebDelegate implementation

- (void)webViewDidFinishLoad:(UIWebView*)theWebView
{
    // Black base color for background matches the native apps
    theWebView.backgroundColor = [UIColor blackColor];

    webViewInfo.hidden = NO;
    [self performSelector:@selector(hideWebViewInfo) withObject:nil afterDelay:5.0];

    return [super webViewDidFinishLoad:theWebView];
}

/* Comment out the block below to over-ride */

- (void) webViewDidStartLoad:(UIWebView*)theWebView
{
    if(previewerInfo && ![previewerAppDomain isEqualToString:@""] && ![previewerAppKey isEqualToString:@""]) {
        NSLog(@"previewerAppDomain: %@", previewerAppDomain);
        NSString *jsSetIdentifier = [[NSString alloc] initWithFormat:@"DOMAIN = '%@'; APP_KEY = '%@'; var BASE_PATH = '/' + APP_KEY;", previewerAppDomain, previewerAppKey];
        [theWebView stringByEvaluatingJavaScriptFromString:jsSetIdentifier];

        previewerAppDomain = @"";
        previewerAppKey = @"";
    }

    return [super webViewDidStartLoad:theWebView];
}

/*
- (void) webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error
{
    return [super webView:theWebView didFailLoadWithError:error];
}

- (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    return [super webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType];
}
*/

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)tapAction:(id)ignored {
    [self closeApplication];
}

- (void)hideWebViewInfo {
    [UIView animateWithDuration:0.3 animations:^{
        webViewInfo.alpha = 0;
    } completion: ^(BOOL finished) {
        webViewInfo.hidden = YES;
    }];
}

- (void)closeApplication {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

@implementation MainCommandDelegate

/* To override the methods, uncomment the line in the init function(s)
   in MainViewController.m
 */

#pragma mark CDVCommandDelegate implementation

- (id)getCommandInstance:(NSString*)className
{
    return [super getCommandInstance:className];
}

- (NSString*)pathForResource:(NSString*)resourcepath
{
    return [super pathForResource:resourcepath];
}

@end

@implementation MainCommandQueue

/* To override, uncomment the line in the init function(s)
   in MainViewController.m
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}

@end
