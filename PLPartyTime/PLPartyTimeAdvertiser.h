//
//  PLPartyTimeAdvertiser.h
//  PLPartyTimeAdvertiser
//
//  Created by Cristián Arenas on 7/1/14.
//  Copyright (c) 2014 Peter Livesey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol PLPartyTimeAdvertiserDelegate;

@interface PLPartyTimeAdvertiser : NSObject <MCNearbyServiceAdvertiserDelegate>

#pragma mark - Properties

/// Delegate for the PartyTime methods
@property (nonatomic, weak) id<PLPartyTimeAdvertiserDelegate> delegate;

#pragma mark - Initialization

- (instancetype)initWithSession:(MCSession*)session
                         peerID:(MCPeerID*)peerID;
@end

@protocol PLPartyTimeAdvertiserDelegate <NSObject>

- (void)partyTimeAdvertiser:(PLPartyTimeAdvertiser*)partyTimeAdvertiser
          failedToJoinParty:(NSError*)error;

@end
