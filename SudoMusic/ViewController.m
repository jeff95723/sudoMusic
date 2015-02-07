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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSURL *filePath = self.selectedURL;
    AFHTTPRequestOperation *op = [manager POST:@"http://10.0.0.37:8000/" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL URLWithString:@"http://peterxia.com/fuck451.pdf"] name:@"file" error:nil];
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
    NSString *fileExt = [TSLibraryImport extensionForAssetURL:self.selectedURL];
    NSLog(@"file ext: %@", fileExt);
    self.saveButton.enabled = YES;
    self.selectedSong = [NSData dataWithContentsOfURL:songAsset.URL];
    
    
    //Now that you have this, either just write the asset (or part of) to disk, access the asset directly, send the written asset to another device etc
    self.songname.text = songTitle;
    self.artistname.text = artist;
    
//    NSURL *toURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@-%@"]]
    
//    [self.importHelper importAsset:<#(NSURL *)#> toURL:<#(NSURL *)#> completionBlock:^(TSLibraryImport *import) {
//        <#code#>
//    }];
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