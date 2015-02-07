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
}

- (IBAction)addMusicPressed:(id)sender {
    if (!self.picker) {
        self.picker = [[MPMediaPickerController alloc]
                       initWithMediaTypes:MPMediaTypeMusic];
        self.picker.prompt = NSLocalizedString(@"Fuck me", NULL);
        self.picker.allowsPickingMultipleItems = NO;
        self.picker.delegate = self;
    }
    
    [self presentViewController:self.picker animated:YES completion:nil];
    
    NSLog(@"fuck you.");
}


- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    MPMediaItem *theChosenSong = [[mediaItemCollection items]objectAtIndex:0];
    NSString *songTitle = [theChosenSong valueForProperty:MPMediaItemPropertyTitle];
    NSString *artist = [theChosenSong valueForProperty:MPMediaItemPropertyArtist];
    
    //then just get the assetURL
    NSURL *assetURL = [theChosenSong valueForProperty:MPMediaItemPropertyAssetURL];
    AVURLAsset  *songAsset  = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    self.selectedSong = [NSData dataWithContentsOfURL:songAsset.URL];
    self.saveButton.enabled = YES;
    
    //Now that you have this, either just write the asset (or part of) to disk, access the asset directly, send the written asset to another device etc
    self.songname.text = songTitle;
    self.artistname.text = artist;
    NSLog(@"Songtitle: %@", songTitle);
    NSLog(@"Artist: %@", artist);
    NSLog(@"NSURL: %@", songAsset.URL);
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