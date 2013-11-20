//
//  GameViewController+GameViewControllerExtension.m
//  Game
//
//  Created by Ishaan Singal on 2/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GameViewControllerExtension.h"
#import <QuartzCore/QuartzCore.h>

@interface GameViewControllerExtension
- (void)addSubviewInUIView:(UIImageView *)givenView withGameState:(GameObjectState)state;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)saveToFile:(NSString *)fileName;
- (void)loadFromFile:(NSString *)fileName ;
- (void)loadWolfFromFile:(GameModel*) givenWolf;
- (void)loadPigFromFile:(GameModel*) givenPig;
- (void)loadBlocksFromFile:(NSArray*) givenArray;
- (void)dismissActionSheet:(id)sender;

@end

@implementation GameViewController (GameViewControllerExtension)

- (IBAction)buttonPressed:(id)sender {
    NSString *buttonName = [sender titleForState:UIControlStateNormal];
    if ([buttonName isEqualToString:@"Save"]) {
        [self save];
    }
    else  if ([buttonName isEqualToString:@"Load"]) {
        [self load];
    }
    else  if ([buttonName isEqualToString:@"Reset"]) {
        [self reset];
    }
}

- (void)save {
// REQUIRES: game in designer mode
// EFFECTS: game objects are saved
    [self.savePopup show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle=[alertView buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"Cancel"]) {
        return;
    }
    else {
        NSString* inputFileName = [[alertView textFieldAtIndex:0] text];
        [self saveToFile: inputFileName];
        [alertView textFieldAtIndex:0].text = nil;
    }
}

- (void)saveToFile:(NSString *)fileName {
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.currentWolf.modelObj forKey:@"wolfObj"];
    [archiver encodeObject:self.currentPig.modelObj forKey:@"pigObj"];
    [archiver encodeObject:((GameBlocks*)self.currentBlock).allBlocks forKey:@"allBlocks"];
    [archiver finishEncoding];
    NSArray* documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString* documentString = [documentsFolder objectAtIndex:0];
    NSString* fileLocation = [NSString stringWithFormat:@"%@/%@", documentString, fileName];
    BOOL result = [data writeToFile: fileLocation atomically:YES];
    if (result) {
        NSString* alertMessage = @"File successfully saved!";
        UIAlertView* saveconfirm = [[UIAlertView alloc] initWithTitle:nil
                                                              message:alertMessage
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
        [saveconfirm show];
    }
    else {
        NSString* alertMessage = @"Sorry, the file could not be saved! Please try again!";
        UIAlertView* errorSave = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:alertMessage
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
        [errorSave show];
    }
}


- (void)load {
// MODIFIES: self (game objects)
// REQUIRES: game in designer mode
// EFFECTS: game objects are loaded
    [self.gamearea setAlpha: 0.8];

    NSArray* documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString* documentString = [documentsFolder objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:documentString error:nil];

    if ([dirContents count] != 0) {
        self.fileNames = [[NSArray alloc]initWithArray:dirContents];
        [self.actionsheet showInView:[[UIApplication sharedApplication] keyWindow]];
    }
    else {
        NSString* alertMessage = @"Sorry, there are no save files";
        UIAlertView* errorSave = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                            message:alertMessage
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [errorSave show];
    }
}


-(void)loadFromFile:(NSString *)fileName {
    [self reset];
    
    NSArray* documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString* documentString = [documentsFolder objectAtIndex:0];
    NSString* fileLocation = [NSString stringWithFormat:@"%@/%@", documentString, fileName];
    NSData *data = [NSData dataWithContentsOfFile:fileLocation];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id obj = [unarchiver decodeObjectForKey:@"wolfObj"];
    id obj2 = [unarchiver decodeObjectForKey:@"pigObj"];
    id obj3 = [unarchiver decodeObjectForKey:@"allBlocks"];
    [unarchiver finishDecoding];
        
    GameModel* tempwolf = (GameModel*)obj;
    Pig* tempPig =(Pig*)obj2;
    NSArray* tempBlocks = (NSArray*)obj3;

    if (tempwolf != nil) {
        [self loadWolfFromFile:tempwolf];
    }
    if (tempPig != nil) {
        [self loadPigFromFile:tempPig];
    }
    if (tempBlocks != nil) {
        [self loadBlocksFromFile: tempBlocks];
    }
}


-(void)loadWolfFromFile:(GameModel*) givenWolf {
    [self.currentWolf.imageView removeFromSuperview];
    if (givenWolf.currentState == kInPalette) {
        [self loadPaletteWolf];
    }
    else {
        self.currentWolf = [[GameWolf alloc]initWithWolf:givenWolf];
        [self.gamearea addSubview:self.currentWolf.imageView];
    }
    return;
}

-(void)loadPigFromFile:(GameModel*) givenPig {
    [self.currentPig.imageView removeFromSuperview];
    if (givenPig.currentState == kInPalette) {
        [self loadPalettePig];
    }
    else {
        self.currentPig = [[GamePig alloc]initWithPig:givenPig];
        [self.gamearea addSubview:self.currentPig.imageView];
    }
    return;
}

-(void)loadBlocksFromFile:(NSArray*) givenArray {
    [self.currentBlock.imageView removeFromSuperview];
    self.currentBlock = [[GameBlocks alloc]initAllBlocksWithArray:givenArray];
    for (NSDictionary* eachBlock in ((GameBlocks*)self.currentBlock).allBlocks) {
        Blocks* thisBlock = [eachBlock objectForKey:@"block"];
        UIImageView* thisBlockImageView = [eachBlock objectForKey:@"blockImage"];
        if (thisBlock.currentState == kInPalette) {
            [self.paletteArea addSubview:thisBlockImageView];
        }
        else {
            [self.gamearea addSubview:thisBlockImageView];
        }
    }
    return;
}

//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
//{
//    NSString *filename  = [self.fileNames objectAtIndex:[pickerView selectedRowInComponent:0]];
//    [self loadFromFile:filename];
//}

- (void)dismissActionSheet:(id)sender{
    [self.gamearea setAlpha: 1];
    NSString *buttonName = ((UIBarButtonItem*)sender).title;
    if ([buttonName isEqualToString:@"Load"]) {
        NSString *filename  = [self.fileNames objectAtIndex:[self.picker selectedRowInComponent:0]];
        [self loadFromFile:filename];
    }
    [self.actionsheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)reset {
// MODIFIES: self (game objects)
// REQUIRES: game in designer mode
// EFFECTS: current game objects are deleted and palette contains all objects
    [self.currentWolf removeGameObj];
    [self.currentPig removeGameObj];
    [self.currentBlock removeGameObj];
    [self loadPalette];
}

@end
