//
//  MainView.h
//  Astroids
//
//  Created by Robert Carter on 8/23/12.
//  Copyright (c) 2012 Robert Carter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameViewController.h"
#import "EnemyShip.h"

// The implementation of this protocol by a controller will keep the controller informed of interesting game events
// such as when the player dies, when the player has destroyed enough enemies/gained enough points to advance to the next level, etc.
@protocol GameViewEventDelegate <NSObject>
@required
- (void)playerHit;
- (void)playerDied;
- (void)enemyDestroyed;
- (void)asteroidDestroyed;
@end

@interface GameView : UIView
{
    id <GameViewEventDelegate> delegate;
}

@property (nonatomic) id delegate;  // GameViewController is the delegate for GameViewEventDelegate protocol
@property (nonatomic) int playerScore;
@property (nonatomic) int playerHitPoints;

- (id)initWithFrame:(CGRect)frame andShipType:(ShipType)shipType;
- (void)startCollisionDetectionLoop;
- (void)updateView;
- (void)addAsteroid;
- (void)addEnemyShipOfType:(EnemyShipType)type;
- (void)addChainOfEnemyShips;
- (void)nextLevel:(GameLevel)level;
- (void)stopCollisionDetection;
- (void)stopGame;
@end
