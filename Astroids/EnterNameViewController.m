//
//  EnterNameViewController.m
//  Astroids
//
//  Created by Robert Carter on 9/18/12.
//  Copyright (c) 2012 Robert Carter. All rights reserved.
//

#import "EnterNameViewController.h"
#import "ScoreViewController.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreImage/CoreImage.h>

@interface EnterNameViewController() <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    BOOL keyboardVisible;
    CGPoint offset;
}
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *selectImageButton;
@property (strong, nonatomic) UIImage *playerImage;
@property (strong, nonatomic) NSString *playerName;
@end

@implementation EnterNameViewController
@synthesize percentLabel;
@synthesize scrollview;
@synthesize nameTextField;
@synthesize selectImageButton;

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.selectImageButton.clipsToBounds = YES;
    self.selectImageButton.contentEdgeInsets = UIEdgeInsetsMake(1, 10, 1, 10);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:)
                                                 name: UIKeyboardDidHideNotification object:nil];
    
    //  Setup content size
    scrollview.contentSize = CGSizeMake(320, 460);
    [self.nameTextField setDelegate:self];
    keyboardVisible = NO;
    
    //  Hide progress label
    self.percentLabel.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    [self setSelectImageButton:nil];
    [self setScrollview:nil];
    [self setNameTextField:nil];
    [self setNameTextField:nil];
    [self setPercentLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)keyboardDidShow:(NSNotification *)notif
{
    if (keyboardVisible)
        return;
         
    //  Get the size of the keyboard
 
    NSDictionary *info = [notif userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    //  Save the current location so we can restore the UIControls when the keyboard is dismissed
    offset = scrollview.contentOffset;
    
    //  Resize the scroll view to make room for the keyboard
    CGRect viewFrame = scrollview.frame;
    viewFrame.size.height -= keyboardSize.height;
    scrollview.frame = viewFrame;
    
    
    CGRect nameFieldRect = [self.nameTextField frame];
    nameFieldRect.origin.y += 10;
    
    [scrollview scrollRectToVisible:nameFieldRect animated:YES];
    
    keyboardVisible = YES;
}

- (void)keyboardDidHide:(NSNotification *)notif
{
    if (!keyboardVisible)
        return;
 
    self.selectImageButton.enabled = YES;
    
    //  Reset the frame scroll view to its original value
    scrollview.frame = CGRectMake(0, 0, 320, 460);
    scrollview.contentOffset = offset;
    keyboardVisible = NO;
}

- (IBAction)addImage
{
    offset = scrollview.contentOffset;
    
    UIImagePickerController *imagePicker = [UIImagePickerController new];
  
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    // Set picker's media type
    imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString*)kUTTypeImage];
    
    // Set the picker's delegate
    imagePicker.delegate = self;
    
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *capturedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    self.playerImage = capturedImage;
    
    [self.selectImageButton setImage:self.playerImage forState:UIControlStateNormal];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.playerName = textField.text;
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)submitPressed:(id)sender
{
    //  Show progress label
    self.percentLabel.hidden = NO;
    
    //  Push image and name to parse in the background
    if ( (self.playerImage) && ([self.playerName length] != 0) ) {
        // send name and iamge to parse in one object

        NSString *photoName = [self.playerName stringByAppendingString:@".jpeg"];

        //  Create a graphics manipulation context from the captured image
        UIGraphicsBeginImageContext(self.playerImage.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //  Rotate the capturedImage 90 degrees clockwise
        CGContextRotateCTM(context, M_PI/2.0);
        [self.playerImage drawAtPoint:CGPointMake(0,0)];
        UIGraphicsGetImageFromCurrentImageContext();
        //  Release the context
        UIGraphicsEndImageContext();
        
        // Save image data to parse
//        UIImage *imageUpload = self.playerImage;
//        NSData *imageData = UIImageJPEGRepresentation(imageUpload, 1.0);
//        PFFile *parseImageFile = [PFFile fileWithName:photoName data:imageData];
//        [parseImageFile saveInBackground];
//        
//        // Associate image data with another database item "UserPhotos"
//        PFObject *userData = [PFObject objectWithClassName:@"PlayerData"];
//        [userData setObject:self.playerName forKey:@"playerName"];
//        [userData setObject:[NSNumber numberWithInt:self.playerScore ]forKey:@"playerScore"];
//        [userData setObject:parseImageFile forKey:@"imageFile"];
//
//        //  Save name, score, and image ref to Parse
//        [userData saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        
//            ScoreViewController *scoreController = [ScoreViewController new];
//            [self presentModalViewController:scoreController animated:YES];
//            
//        }];

        UIImage *imageUpload = self.playerImage;
        NSData *imageData = UIImageJPEGRepresentation(imageUpload, 1.0);
        PFFile *parseImageFile = [PFFile fileWithName:photoName data:imageData];

        //  Save player image
        [parseImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            PFObject *userData = [PFObject objectWithClassName:@"PlayerData"];
            [userData setObject:self.playerName forKey:@"playerName"];
            [userData setObject:[NSNumber numberWithInt:self.playerScore ]forKey:@"playerScore"];
            [userData setObject:parseImageFile forKey:@"imageFile"];
            
            //  Save name, score, and image relational pointer to Parse
            [userData saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                ScoreViewController *scoreController = [ScoreViewController new];
                [self presentModalViewController:scoreController animated:YES];
                
            }];
        } progressBlock:^(int percentDone) {
            NSString *percentText = @"%";
            NSString *percentNumber = [NSString stringWithFormat:@"%d",percentDone];
            percentText = [percentText stringByAppendingString:percentNumber];
            self.percentLabel.text = percentText;
        }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Please enter your name and add a photo"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
