//
//  PLPartyTimeBrowser.m
//  PLPartyTimeBrowser
//
//  Created by Cristián Arenas on 7/1/14.
//  Copyright (c) 2014 Peter Livesey. All rights reserved.
//

#import "PLPartyTimeBrowser.h"

@interface PLPartyTimeBrowser ()

@property (nonatomic, strong) MCSession* session;
@property (nonatomic, strong) MCPeerID* peerID;

@end

@implementation PLPartyTimeBrowser

#pragma mark - Life Cycle
- (instancetype)initWithSession:(MCSession*)session
                         peerID:(MCPeerID*)peerID
{
    NSParameterAssert(session);
    NSParameterAssert(peerID);

    self = [super init];
    if (self) {
        self.session = session;
        self.peerID = peerID;
    }
    return self;
}

#pragma mark - Browser Delegate

- (void)browser:(MCNearbyServiceBrowser*)browser foundPeer:(MCPeerID*)peerID withDiscoveryInfo:(NSDictionary*)info
{
    // Whenever we find a peer, let's just send them an invitation
    // But only send invites one way
    // TODO: What if display names are the same?
    // TODO: Make timeout configurable
    if ([peerID.displayName compare:self.peerID.displayName] == NSOrderedAscending) {
        NSLog(@"Sending invite: Self: %@", self.peerID.displayName);
        [browser invitePeer:peerID
                  toSession:self.session
                withContext:nil
                    timeout:10];
    }
}

- (void)browser:(MCNearbyServiceBrowser*)browser lostPeer:(MCPeerID*)peerID
{
    // Ignore this. We don't need it.
}

- (void)browser:(MCNearbyServiceBrowser*)browser didNotStartBrowsingForPeers:(NSError*)error
{
    [self.delegate partyTimeBrowser:self failedToJoinParty:error];
}

@end
