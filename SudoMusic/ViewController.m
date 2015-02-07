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

- (void)extractItemWithInfo:(NSDictionary *)info
{
    MPMediaItem *item = [info objectForKey:@"item"];
    NSIndexPath *indexPath = [info objectForKey:@"indexPath"];
    
    // Get raw PCM data from the track
    NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
    NSMutableData *data = [[NSMutableData alloc] init];
    
    const uint32_t sampleRate = 16000;
    const uint16_t bitDepth = 16;
    const uint16_t channels = 2;
    
    NSDictionary *opts = [NSDictionary dictionary];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:assetURL options:opts];
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:NULL];
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                              [NSNumber numberWithFloat:(float)sampleRate], AVSampleRateKey,
                              [NSNumber numberWithInt:bitDepth], AVLinearPCMBitDepthKey,
                              [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                              [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                              [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey, nil];
    
    AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc] initWithTrack:[[asset tracks] objectAtIndex:0] outputSettings:settings];
    [reader addOutput:output];
    [reader startReading];
    
    // read the samples from the asset and append them subsequently
    while ([reader status] != AVAssetReaderStatusCompleted) {
        CMSampleBufferRef buffer = [output copyNextSampleBuffer];
        if (buffer == NULL) continue;
        
        CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(buffer);
        size_t size = CMBlockBufferGetDataLength(blockBuffer);
        uint8_t *outBytes = malloc(size);
        CMBlockBufferCopyDataBytes(blockBuffer, 0, size, outBytes);
        CMSampleBufferInvalidate(buffer);
        CFRelease(buffer);
        [data appendBytes:outBytes length:size];
        free(outBytes);
    }
    
    // Encode the PCM data to FLAC
    uint32_t totalSamples = [data length] / (channels * bitDepth / 8);
    NSMutableData *flacData = [[NSMutableData alloc] init];
    
    // Create a FLAC encoder
    FLAC__StreamEncoder *encoder = FLAC__stream_encoder_new();
    if (encoder == NULL)
    {
        // handle error
    }
    
    // Set up the encoder
    FLAC__stream_encoder_set_verify(encoder, true);
    FLAC__stream_encoder_set_compression_level(encoder, 8);
    FLAC__stream_encoder_set_channels(encoder, channels);
    FLAC__stream_encoder_set_bits_per_sample(encoder, bitDepth);
    FLAC__stream_encoder_set_sample_rate(encoder, sampleRate);
    FLAC__stream_encoder_set_total_samples_estimate(encoder, totalSamples);
    
    // Initialize the encoder
    FLAC__stream_encoder_init_stream(encoder, FLAC_writeCallback, NULL, NULL, NULL, flacData);
    
    // Start encoding
    size_t left = totalSamples;
    const size_t buffsize = 1 << 16;
    FLAC__byte *buffer;
    static FLAC__int32 pcm[1 << 17];
    size_t need;
    size_t i;
    while (left > 0) {
        need = left > buffsize ? buffsize : left;
        
        buffer = (FLAC__byte *)[data bytes] + (totalSamples - left) * channels * bitDepth / 8;
        for (i = 0; i < need * channels; i++) {
            if (bitDepth == 16) {
                // 16 bps, signed little endian
                pcm[i] = *(int16_t *)(buffer + i * 2);
            } else {
                // 8 bps, unsigned
                pcm[i] = *(uint8_t *)(buffer + i);
            }
        }
        
        FLAC__bool succ = FLAC__stream_encoder_process_interleaved(encoder, pcm, need);
        if (succ == 0) {
            FLAC__stream_encoder_delete(encoder);
            // handle error
            return;
        }
        
        left -= need;
    }
    
    // Clean up
    FLAC__stream_encoder_finish(encoder);
    FLAC__stream_encoder_delete(encoder);
    [data release];
    
    NSString *fileName = [NSString stringWithFormat:@"%@ - %@.flac", [item valueForProperty:MPMediaItemPropertyAlbumTitle], [item valueForProperty:MPMediaItemPropertyAlbumArtist]];
    
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:fileName, @"fileName", flacData, @"attachment", indexPath, @"indexPath", nil];
    [flacData release];
    
    [self performSelectorOnMainThread:@selector(conversionDone:) withObject:result waitUntilDone:YES];
    
    [pool drain];
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