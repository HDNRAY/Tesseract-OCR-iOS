//
//  G8ViewController.m
//  Template Framework Project
//
//  Created by Daniele on 14/10/13.
//  Copyright (c) 2013 Daniele Galiotto - www.g8production.com. All rights reserved.
//

#import "G8ViewController.h"

@interface G8ViewController ()
{

}

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation G8ViewController

/****README****/
/*
 Tessdata folder is into the template project..
 TesseractOCR.framework is linked into the template project under the Framework group. It's builded by the main project.

 If you are using iOS7 or greater, import libstdc++.6.0.9.dylib (not libstdc++)!!!!!

 Follow the readme at https://github.com/gali8/Tesseract-OCR-iOS for first step.
 */



- (void)viewDidLoad
{
    [super viewDidLoad];

    // language are used for recognition. Ex: eng. Tesseract will search for a eng.traineddata file in the dataPath directory; eng+ita will search for a eng.traineddata and ita.traineddata.

    //Like in the Template Framework Project:
    // Assumed that .traineddata files are in your "tessdata" folder and the folder is in the root of the project.
    // Assumed, that you added a folder references "tessdata" into your xCode project tree, with the ‘Create folder references for any added folders’ options set up in the «Add files to project» dialog.
    // Assumed that any .traineddata files is in the tessdata folder, like in the Template Framework Project

    //Create your tesseract using the initWithLanguage method:
    // Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"<strong>eng+ita</strong>"];

    // set up the delegate to recieve tesseract's callback
    // self should respond to TesseractDelegate and implement shouldCancelImageRecognitionForTesseract: method
    // to have an ability to recieve callback and interrupt Tesseract before it finishes

    self.operationQueue = [[NSOperationQueue alloc] init];
    [self recognizeSampleImage:nil];
}

-(void)recognizeImageWithTesseract:(UIImage *)image
{
    UIImage *bwImage = [image g8_blackAndWhite];

    [self.activityIndicator startAnimating];
    //only for test//
    self.imageToRecognize.image = bwImage;

    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] init];
    operation.tesseract.language = @"eng";
    operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeAutoOnly;
    //operation.tesseract.maximumRecognitionTime = 1.0;
    operation.delegate = self;

    //operation.tesseract.charWhitelist = @"01234"; //limit search
    //operation.tesseract.charBlacklist = @"56789";
    operation.tesseract.image = bwImage; //image to check

    //operation.tesseract.rect = CGRectMake(20, 20, 100, 100); //optional: set the rectangle to recognize text in the image

    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract) {
        NSString *recognizedText = tesseract.recognizedText;

        NSLog(@"%@", recognizedText);

        [self.activityIndicator stopAnimating];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tesseract OCR iOS"
                                                        message:recognizedText
                                                       delegate:nil
                                              cancelButtonTitle:@"Yeah!"
                                              otherButtonTitles:nil];
        [alert show];
    };

    [self.operationQueue addOperation:operation];
}

- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    NSLog(@"progress: %lu", (unsigned long)tesseract.progress);
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openCamera:(id)sender
{
    UIImagePickerController *imgPicker = [UIImagePickerController new];
    imgPicker.delegate = self;

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imgPicker animated:YES completion:nil];
    }
}

- (IBAction)recognizeSampleImage:(id)sender {
    [self recognizeImageWithTesseract:[UIImage imageNamed:@"image_sample.jpg"]];
}

#pragma mark - UIImagePickerController Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self recognizeImageWithTesseract:image];
}
@end
