//
//  MenuLayer.m
//  SwipeCocos2DDemo
//
//  Created by Jon Manning on 30/08/12.
//  Copyright 2012 Secret Lab. All rights reserved.
//

#import "MenuLayer.h"
#import "GameLayer.h"

@interface MenuLayer () {
    // "Spaceships" label
    CCLabelTTF* label;
}

@end

@implementation MenuLayer

// Returns a CCScene containing this layer.
+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	MenuLayer *layer = [MenuLayer node];
	[scene addChild: layer];
	return scene;
}

// Create and set up the "Spaceships" label.
- (id)init
{
    self = [super init];
    if (self) {
		label = [CCLabelTTF labelWithString:@"Spaceships!" fontName:@"Helvetica" fontSize:64];
		[self addChild: label];
        self.isTouchEnabled = YES;
    }
    return self;
}

// When the scene is ready to show, position the label
// in the middle of the screen.
- (void)onEnter {
    [super onEnter];
    CGSize size = [[CCDirector sharedDirector] winSize];
    label.position =  ccp( size.width /2 , size.height/2 );
}

// ##10.4: Move to game scene on touch
- (void)ccTouchesBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [[CCDirector sharedDirector] pushScene:[GameLayer scene]];
}

@end
