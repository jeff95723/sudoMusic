//
//  ViewController.m
//  SudoMusic
//
//  Created by Jeffrey Liu on 2/6/15.
//  Copyright (c) 2015 Jeffrey Liu. All rights reserved.
//


#import "ViewController.h"

@interface ViewController ()
@property MPMediaPickerController *picker;
@property NSData* selectedSong;
@property NSURL* selectedURL;
@property NSURL* toURL;
@property TSLibraryImport *importHelper;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *songname;
@property (weak, nonatomic) IBOutlet UILabel *artistname;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.saveButton.enabled = NO;
    self.songname.text = @"None.";
    self.artistname.text = @"None.";
    [self.saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)addMusicPressed:(id)sender {
    if (!self.picker) {
        self.picker = [[MPMediaPickerController alloc]
                       initWithMediaTypes:MPMediaTypeMusic];
        self.picker.prompt = NSLocalizedString(@"Fuck me", NULL);
        self.picker.allowsPickingMultipleItems = NO;
        self.picker.delegate = self;
    }
    
    if (!self.importHelper) {
        self.importHelper = [[TSLibraryImport alloc] init];
    }
    
    
    
    [self presentViewController:self.picker animated:YES completion:nil];
}

- (void)saveButtonPressed {
    
    NSLog(@"Saving start.");
//    NSURL *yourURL = [NSURL URLWithString:@"http://10.0.0.37:8000/"];
//    NSMutableURLRequest *yourRequest = [NSMutableURLRequest requestWithURL:yourURL
//                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                           timeoutInterval:60.0];
//    //Set request to post
//    [yourRequest setHTTPMethod:@"POST"];
//    
//    //Set content type
//    [yourRequest setValue:@"audio/x-m4a" forHTTPHeaderField:@"Content-Type"];
//    [yourRequest setValue:@"file" forHTTPHeaderField:@"name"];
//    
//    // set data
//    [yourRequest setHTTPBody:[NSData dataWithContentsOfURL:self.toURL]];
//    
//    
//    // create connection and set delegate if needed
//    NSURLConnection *yourConnection = [[NSURLConnection alloc] initWithRequest:yourRequest
//                                                                      delegate:self
//                                                              startImmediately:YES];
//    NSLog(@"Saving finished.");
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSURL *filePath = self.toURL;
    AFHTTPRequestOperation *op = [manager POST:@"http://10.0.0.36:8000/" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileURL:self.toURL name:@"file" error:nil];
        [formData appendPartWithFileData:[NSData dataWithContentsOfURL:self.toURL] name:@"file" fileName:@"yourass.m4a" mimeType:@"audio/x-m4a"];
//        [formData appendPartWithFileURL:filePath name:@"file" fileName:@"haha.m4a" mimeType:@"audio/x-m4a" error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [op start];
}



- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    MPMediaItem *theChosenSong = [[mediaItemCollection items]objectAtIndex:0];
    NSString *songTitle = [theChosenSong valueForProperty:MPMediaItemPropertyTitle];
    NSString *artist = [theChosenSong valueForProperty:MPMediaItemPropertyArtist];
    NSString *album = [theChosenSong valueForProperty:MPMediaItemPropertyAlbumTitle];
    
    
    //then just get the assetURL
    NSURL *assetURL = [theChosenSong valueForProperty:MPMediaItemPropertyAssetURL];
    AVURLAsset  *songAsset  = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    self.selectedURL = songAsset.URL;
    self.saveButton.enabled = YES;
    self.selectedSong = [NSData dataWithContentsOfURL:songAsset.URL];
    NSString *fileExt = [TSLibraryImport extensionForAssetURL:self.selectedURL];
    NSLog(@"URL: %@", fileExt);
    
    
    
    //Now that you have this, either just write the asset (or part of) to disk, access the asset directly, send the written asset to another device etc
    self.songname.text = songTitle;
    self.artistname.text = artist;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.toURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@-%@.%@", documentsDirectory,songTitle, artist, fileExt]];
    
    [self.importHelper importAsset:self.selectedURL toURL:self.toURL completionBlock:^(TSLibraryImport *import) {
        NSData* data = [NSData dataWithContentsOfURL:self.toURL];
        NSLog(@"%@", self.toURL.absoluteString);
        NSLog(@"I got a file with length: %lu", (unsigned long)data.length);
    }];
    NSLog(@"Songtitle: %@", songTitle);
    NSLog(@"Artist: %@", artist);
    NSLog(@"NSURL: %@", songAsset.URL);
    NSLog(@"Selected data length: %lu", (unsigned long)_selectedSong.length);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end