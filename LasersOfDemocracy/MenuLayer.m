//
//  MenuLayer.m
//  LasersOfDemocracy
//
//  Created by Jon Manning on 30/08/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuLayer.h"
#import "GameLayer.h"

// ##10.2 Add label ivar
@interface MenuLayer () {
    CCLabelTTF* label;
}

@end

@implementation MenuLayer

// ##10.3 Add scene, init and onEnter methods
+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	MenuLayer *layer = [MenuLayer node];
	[scene addChild: layer];
	return scene;
}

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
