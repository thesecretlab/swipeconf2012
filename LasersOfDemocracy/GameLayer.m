//
//  GameLayer.m
//  LasersOfDemocracy
//
//  Created by Jon Manning on 30/08/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"

@interface GameLayer () {
    CCSprite* player;
    
    // ##7.2 Add enemies array
    NSMutableArray* enemies;
    
    // ##10 Add label
    CCLabelTTF* scoreLabel;
    NSUInteger score;
}

@end

@implementation GameLayer

// ##1: Add scene method
+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	GameLayer *layer = [GameLayer node];
	[scene addChild: layer];
	return scene;
}

// ##4: Add player sprite

- (void)onEnter {
    [super onEnter];
    CGSize windowSize = [[CCDirector sharedDirector] winSize];
    
    player = [CCSprite spriteWithFile:@"Player.png"];
    [self addChild:player];
    
    player.anchorPoint = ccp(0.5,0.5);
    
    player.position = ccp(windowSize.width / 2, windowSize.height / 2);
    
    self.isTouchEnabled = YES;
    
    // ##7: Schedule enemies
    [self schedule:@selector(addEnemy:) interval:0.5];
    
    // ##7.3 Set up enemies array
    enemies = [[NSMutableArray array] retain];
    
    // ##9: Add collision detection
    [self scheduleUpdate];
    
    // ##10.1 Add score label
    score = 0;
    scoreLabel = [[CCLabelTTF alloc] initWithString:@"Score: 0" fontName:@"Helvetica" fontSize:18];
    scoreLabel.horizontalAlignment = kCCTextAlignmentLeft;
    scoreLabel.anchorPoint = ccp(0,1);
    scoreLabel.position = ccp(10, windowSize.height - 10);
    
    // ##10.2 Update score
    [self schedule:@selector(updateScore:) interval:1.0];
    [self addChild:scoreLabel];
    
}

// ##10.3 Update score
- (void) updateScore:(ccTime)deltaTime {
    if (player != nil) {
        score += 10;
        scoreLabel.string = [NSString stringWithFormat:@"Score: %i", score];
    }
}

// ##7.1: Add schedule methods
- (void) addEnemy:(ccTime)deltaTime {
    NSLog(@"Adding an enemy!");
    
    // ##8: Create rocks
    int rockNumber = (random() % 2) + 1; // random number between 1 and 2
    NSString* imageName = [NSString stringWithFormat:@"Rock%i.png", rockNumber];
    
    CCSprite* rock = [CCSprite spriteWithFile:imageName];
    
    [self addChild:rock];
    CGSize windowSize = [[CCDirector sharedDirector] winSize];
    CGPoint position = ccp(random() % (int)windowSize.width, random() % (int)windowSize.height);
    rock.position = position;
    [enemies addObject:rock];
    
    // ##8.1: Move around
    CGPoint velocity = ccp(random() % 200 - 100, random() % 200 - 100);
    id moveAction = [CCRepeatForever actionWithAction:[CCMoveBy actionWithDuration:1 position:velocity]];
    [rock runAction:moveAction];
    
    // ##8.2: Fade in
    rock.opacity = 0;
    id fadeInAction = [CCFadeIn actionWithDuration:0.5];
    [rock runAction:fadeInAction];
    
    // ##8.3: Rotate
    CGFloat angle = (random() % 2000 / 1000.0f - 1.0f) * 180.0;
    id rotationAction = [CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:5 angle:angle]];
    [rock runAction:rotationAction];
    
    // ##8.4: Disappear after 5 seconds
    id disappearAction = [CCSequence actionWithArray:@[[CCDelayTime actionWithDuration:5.0], [CCFadeOut actionWithDuration:0.5], [CCCallBlockN actionWithBlock:^(CCNode *node) {
        NSLog(@"Removing rock!");
        [node removeFromParentAndCleanup:YES];
        [enemies removeObject:node];
    }]]];
    
    [rock runAction:disappearAction];
    
    
    
}

// ##9.1: Update method
-(void) update:(ccTime)deltaTime {
    
    // Inset the collision box a bit to give the player some leeway
    CGRect playerCollisionBox = CGRectInset(player.boundingBox, 10, 10);
    
    for (CCSprite* rock in enemies) {
        if (CGRectIntersectsRect(rock.boundingBox, playerCollisionBox)) {
            NSLog(@"!!!! PLAYER HIT!");
            [player removeFromParentAndCleanup:YES];
            player = nil;
            
            // ##11.0
            // Wait 2 seconds and return to the previous screen
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[CCDirector sharedDirector] popScene];
            });
            
        }        
    }
}

// ##5: Add touch method
- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
    UITouch* touch = [touches anyObject];
    NSLog(@"Touch began! %@", NSStringFromCGPoint([touch locationInView:touch.view]));
    
    
    // ##6: Move player sprite on touch
    
    [player stopAllActions];
    
    CGPoint position = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
    CGPoint currentPosition = [player position];
    
    CGFloat distance = ccpDistance(position, currentPosition);
    
    CGFloat speed = 100;
    CGFloat time = distance / speed;
    
    id moveAction = [CCMoveTo actionWithDuration:time position:position];
    [player runAction:moveAction];
    
}

@end
