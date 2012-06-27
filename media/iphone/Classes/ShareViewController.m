//
//  ShareViewController.m
//  NewsBlur
//
//  Created by Roy Yang on 6/21/12.
//  Copyright (c) 2012 NewsBlur. All rights reserved.
//

#import "ShareViewController.h"
#import "NewsBlurAppDelegate.h"
#import "StoryDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Utilities.h"
#import "JSON.h"
#import "ASIHTTPRequest.h"

@implementation ShareViewController
@synthesize facebookButton;
@synthesize twitterButton;
@synthesize submitButton;
@synthesize toolbarTitle;

@synthesize commentField;
@synthesize appDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    commentField.layer.borderWidth = 1.0f;
    commentField.layer.cornerRadius = 8;
    commentField.layer.borderColor = [[UIColor grayColor] CGColor];
    
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];    
    if ([userPreferences integerForKey:@"shareToFacebook"]){
        facebookButton.selected = YES;
    }
    if ([userPreferences integerForKey:@"shareToTwitter"]){
        twitterButton.selected = YES;
    }
}

- (void)viewDidUnload
{
    [self setCommentField:nil];
    [self setFacebookButton:nil];
    [self setTwitterButton:nil];
    [self setSubmitButton:nil];
    [self setToolbarTitle:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [appDelegate release];
    [commentField release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [facebookButton release];
    [twitterButton release];
    [submitButton release];
    [toolbarTitle release];
    [super dealloc];
}

- (IBAction)doCancelButton:(id)sender {
    [commentField resignFirstResponder];
    [appDelegate hideShareView];
}

- (IBAction)doToggleButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    if (button.selected) {
        button.selected = NO;
        if ([[button currentTitle] isEqualToString: @"Facebook"]) {
            [userPreferences setInteger:0 forKey:@"shareToFacebook"];
        } else if ([[button currentTitle] isEqualToString: @"Twitter"]) {
            [userPreferences setInteger:0 forKey:@"shareToTwitter"];
        }
    } else {
        button.selected = YES;
        if ([[button currentTitle] isEqualToString: @"Facebook"]) {
            [userPreferences setInteger:1 forKey:@"shareToFacebook"];
        } else if ([[button currentTitle] isEqualToString: @"Twitter"]) {
            [userPreferences setInteger:1 forKey:@"shareToTwitter"];
        }
    }
    [userPreferences synchronize];
}

- (void)setSiteInfo:(NSString *)userId setUsername:(NSString *)username {
    if (userId) {
        [submitButton setTitle:@"Reply"];
        [toolbarTitle setTitle:[NSString stringWithFormat:@"Reply to %@", username]];
        [submitButton setAction:(@selector(doReplyToComment:))];
    } else {
        [toolbarTitle setTitle:@"Post to Blurblog"];
        [submitButton setTitle:@"Post"];
        [submitButton setAction:(@selector(doShareThisStory:))];
    }

}

- (void)clearComments {
    self.commentField.text = nil;
}

- (IBAction)doShareThisStory:(id)sender {    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/social/share_story",
                           NEWSBLUR_URL];
    
    NSString *feedIdStr = [NSString stringWithFormat:@"%@", [appDelegate.activeStory objectForKey:@"story_feed_id"]];
    NSString *storyIdStr = [NSString stringWithFormat:@"%@", [appDelegate.activeStory objectForKey:@"id"]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:feedIdStr forKey:@"feed_id"]; 
    [request setPostValue:storyIdStr forKey:@"story_id"];

    NSString *comments = commentField.text;
    if ([comments length]) {
        [request setPostValue:comments forKey:@"comments"]; 
    }
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(finishAddComment:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request startAsynchronous];
}

- (IBAction)doReplyToComment:(id)sender {
    NSString *comments = commentField.text;
    if ([comments length] == 0) {
        NSLog(@"NO COMMENTS");
        return;
    }
    
    NSLog(@"REPLY TO COMMENT, %@", appDelegate.activeComment);
    NSString *urlString = [NSString stringWithFormat:@"http://%@/social/save_comment_reply",
                           NEWSBLUR_URL];
    
    NSString *feedIdStr = [NSString stringWithFormat:@"%@", [appDelegate.activeStory objectForKey:@"story_feed_id"]];
    NSString *storyIdStr = [NSString stringWithFormat:@"%@", [appDelegate.activeStory objectForKey:@"id"]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:feedIdStr forKey:@"story_feed_id"]; 
    [request setPostValue:storyIdStr forKey:@"story_id"];
    [request setPostValue:[appDelegate.activeComment objectForKey:@"user_id"] forKey:@"comment_user_id"];
    [request setPostValue:commentField.text forKey:@"reply_comments"]; 
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(finishAddComment:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request startAsynchronous];
}




- (void)finishAddComment:(ASIHTTPRequest *)request {
    NSLog(@"%@", [request responseString]);
    NSLog(@"Successfully added.");
    [commentField resignFirstResponder];
    [appDelegate hideShareView];
    
    NSString *responseString = [request responseString];
    NSDictionary *results = [[NSDictionary alloc] 
                             initWithDictionary:[responseString JSONValue]];
    appDelegate.activeStory = [results objectForKey:@"story"];
    [results release];
    self.commentField.text = nil;
    [appDelegate refreshComments];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: %@", error);
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect shareViewFrame = self.view.frame;
    CGRect storyDetailViewFrame = appDelegate.storyDetailViewController.view.frame;
    
    //NSLog(@"Keyboard y is %f", keyboardFrame.size.height);
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        shareViewFrame.origin.y = shareViewFrame.origin.y + keyboardFrame.size.height;
        storyDetailViewFrame.size.height = storyDetailViewFrame.size.height + keyboardFrame.size.height;
    } else {
        shareViewFrame.origin.y = shareViewFrame.origin.y + keyboardFrame.size.width;
        storyDetailViewFrame.size.height = storyDetailViewFrame.size.height + keyboardFrame.size.width;
    }

    [UIView animateWithDuration:duration 
                          delay:0 
                        options:UIViewAnimationOptionBeginFromCurrentState | curve 
                     animations:^{
        self.view.frame = shareViewFrame;
        appDelegate.storyDetailViewController.view.frame = storyDetailViewFrame;
    } completion:nil];
}

-(void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect shareViewFrame = self.view.frame;
    CGRect storyDetailViewFrame = appDelegate.storyDetailViewController.view.frame;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        shareViewFrame.origin.y = shareViewFrame.origin.y - keyboardFrame.size.height;
        storyDetailViewFrame.size.height = storyDetailViewFrame.size.height - keyboardFrame.size.height;
    } else {
        shareViewFrame.origin.y = shareViewFrame.origin.y - keyboardFrame.size.width;
        storyDetailViewFrame.size.height = storyDetailViewFrame.size.height - keyboardFrame.size.width;
    }
    
    [UIView animateWithDuration:duration 
                          delay:0 
                        options:UIViewAnimationOptionBeginFromCurrentState | curve 
                     animations:^{
                         self.view.frame = shareViewFrame;
                         appDelegate.storyDetailViewController.view.frame = storyDetailViewFrame;
                     } completion:nil];
}

@end