//
//  GameLayer.m
//  SwipeCocos2DDemo
//
//  Created by Jon Manning on 30/08/12.
//  Copyright 2012 Secret Lab. All rights reserved.
//

#import "GameLayer.h"

@interface GameLayer () {
    
    // The player
    CCSprite* player;
    
    // The list of all enemies
    NSMutableArray* enemies;
    
    // Score label 
    CCLabelTTF* scoreLabel;
    NSUInteger score;
}

@end

@implementation GameLayer

// Returns a CCScene containing this layer.
+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	GameLayer *layer = [GameLayer node];
	[scene addChild: layer];
	return scene;
}

// Creates and sets up the player, and schedule scoring, collision
// detection, and enemy creation

- (void)onEnter {
    [super onEnter];
    CGSize windowSize = [[CCDirector sharedDirector] winSize];
    
    player = [CCSprite spriteWithFile:@"Player.png"];
    [self addChild:player];
    
    player.anchorPoint = ccp(0.5,0.5);
    
    player.position = ccp(windowSize.width / 2, windowSize.height / 2);
    
    self.isTouchEnabled = YES;
    
    [self schedule:@selector(addEnemy:) interval:0.5];
    
    enemies = [[NSMutableArray array] retain];
    
    [self scheduleUpdate];
    
    score = 0;
    scoreLabel = [[CCLabelTTF alloc] initWithString:@"Score: 0" fontName:@"Helvetica" fontSize:18];
    scoreLabel.horizontalAlignment = kCCTextAlignmentLeft;
    scoreLabel.anchorPoint = ccp(0,1);
    scoreLabel.position = ccp(10, windowSize.height - 10);
    
    [self schedule:@selector(updateScore:) interval:1.0];
    [self addChild:scoreLabel];
    
}

// Update score
- (void) updateScore:(ccTime)deltaTime {
    if (player != nil) {
        score += 10;
        scoreLabel.string = [NSString stringWithFormat:@"Score: %i", score];
    }
}

// Add an enemy that moves, rotates, and eventually fades out
- (void) addEnemy:(ccTime)deltaTime {
    NSLog(@"Adding an enemy!");
    
    int rockNumber = (random() % 2) + 1; // random number between 1 and 2
    NSString* imageName = [NSString stringWithFormat:@"Rock%i.png", rockNumber];
    
    CCSprite* rock = [CCSprite spriteWithFile:imageName];
    
    [self addChild:rock];
    CGSize windowSize = [[CCDirector sharedDirector] winSize];
    
    do {
        CGPoint position = ccp(random() % (int)windowSize.width, random() % (int)windowSize.height);
        rock.position = position;
    } while (ccpDistance(player.position, rock.position) < 100);
    
    [enemies addObject:rock];

    CGPoint velocity = ccp(random() % 200 - 100, random() % 200 - 100);
    id moveAction = [CCRepeatForever actionWithAction:[CCMoveBy actionWithDuration:1 position:velocity]];
    [rock runAction:moveAction];
    
    rock.opacity = 0;
    id fadeInAction = [CCFadeIn actionWithDuration:0.5];
    [rock runAction:fadeInAction];
    
    CGFloat angle = (random() % 2000 / 1000.0f - 1.0f) * 180.0;
    id rotationAction = [CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:5 angle:angle]];
    [rock runAction:rotationAction];
    
    id disappearAction = [CCSequence actionWithArray:@[[CCDelayTime actionWithDuration:5.0], [CCFadeOut actionWithDuration:0.5], [CCCallBlockN actionWithBlock:^(CCNode *node) {
        NSLog(@"Removing rock!");
        [node removeFromParentAndCleanup:YES];
        [enemies removeObject:node];
    }]]];
    
    [rock runAction:disappearAction];
    
    
    
}

// Check for collisions
-(void) update:(ccTime)deltaTime {
    
    
    for (CCSprite* rock in enemies) {
        if (ccpDistance(player.position, rock.position) < 30) {
            NSLog(@"!!!! PLAYER HIT!");
            [player removeFromParentAndCleanup:YES];
            player = nil;
            
            // Wait 2 seconds and return to the previous screen
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[CCDirector sharedDirector] popScene];
            });
            
        }        
    }
}

// When the screen is touched, move the player to that point
- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
    UITouch* touch = [touches anyObject];
    NSLog(@"Touch began! %@", NSStringFromCGPoint([touch locationInView:touch.view]));
    
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
