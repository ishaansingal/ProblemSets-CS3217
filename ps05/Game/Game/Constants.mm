//
//  Constants.m
//  Game
//
//  Created by Ishaan Singal on 30/1/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Constants.h"

NSString *const kBackgroundImageName = @"background.png";
NSString *const kGroundImageName = @"ground.png";
NSString *const kBreathImageName = @"windblow.png";
NSString *const kBreathExpiredImagesName = @"wind-disperse.png";

NSString *const kWolfBlowImagesName = @"wolfs.png";
NSString *const kWolfSuckImagesName = @"windsuck.png";
NSString *const kWolfDieImagesName = @"wolfdie.png";
NSString *const kWolfDeadImageName = @"deadwolf.png";

NSString *const kArrowImageName = @"direction-arrowOrig.png";
NSString *const kRedArrowImageName = @"direction-arorw-selected";
NSString *const kBreathBarImageName = @"breath-bar.png";

NSString *const kWolfImageName = @"defaultWolf.png";
NSString *const kPigImageName = @"pig.png";
NSString *const kPigCryImageName = @"pig2.png";
NSString *const kPigDiedSmokeImagesName = @"pig-die-smoke.png";

NSString *const kWoodImageName = @"wood.png";
NSString *const kIronImageName = @"iron.png";
NSString *const kStrawImageName = @"straw.png";
NSString *const kStoneImageName = @"stone.png";

NSString *const kHeartImageName = @"heart.png";
NSString *const kScoreImageName = @"score.png";
NSString *const kFontImageName = @"font.png";
NSString *const kNumFontImageName = @"numFont.png";

double const kViewHeight = 768;
double const kViewWidth = 1024;

double const kGameareaHeight = 630;
double const kGameareaWidth = 1600;

double const kGroundHeight = 100;
double const kGroundWidth = 1600;

double const kBackGroundHeight = 480;
double const kBackGroundWidth = 1600;

double const kDefaultPigWidth = 88;
double const kDefaultPigHeight = 88;

double const kDefaultWolfWidth = 185;
double const kDefaultWolfHeight = 150;

double const kDefaultBlockWidth = 30;
double const kDefaultBlockHeight = 130;


double const kPaletteHeight = 77;
double const kPaletteWidth = 1024;

double const kPalettePigOriginX = 90;
double const kPalettePigOriginY = 9;
double const kPalettePigWidth = 55;
double const kPalettePigHeight = 55;

double const kPaletteWolfWidth = 70;
double const kPaletteWolfHeight = 55;
double const kPaletteWolfOriginX = 12;
double const kPaletteWolfOriginY = 9;

double const kPaletteBlockOriginX = 170;
double const kPaletteBlockOriginY = 9;
double const kPaletteBlockHeight = 55;
double const kPaletteBlockWidth = 55;

double const kBreathRadius = 40;

//original size is 434 X 74, so take the ratio accordingly
double const kDefaultArrowWidth = 293;
double const kDefaultArrowHeight = 50;

double const kDefaultBreathBarHeight = 20;
double const kDefaultBreathBarWidth = 0;

double const kScaleMax = 1.6;
double const kScaleMin = 0.8;
int const kPowerMultiplier = 30;
double const kPixelToMeterRatio = 25;
double const kTimeStep = 0.016;

int const kFontStartIndex = 0;
int const kFontEndIndex = 95;

int const kFontNumStartIndex = 14;
int const kFontNumEndIndex = 23;

int const kPigMaxHealth = 1500;
int const kPigCryHealth = 1000;

int const kStrawMaxHealth = 1000;
int const kWoodMaxHealth = 2500;
int const kStoneMaxHealth = 4000;
int const kIronMaxHealth = 10000;