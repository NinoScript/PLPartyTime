//
//  PLPartyTimeAdvertiser.m
//  PLPartyTimeAdvertiser
//
//  Created by Cristián Arenas on 7/1/14.
//  Copyright (c) 2014 Peter Livesey. All rights reserved.
//

#import "PLPartyTimeAdvertiser.h"

@interface PLPartyTimeAdvertiser ()

@property (nonatomic, strong) MCSession* session;
@property (nonatomic, strong) MCPeerID* peerID;

@end

@implementation PLPartyTimeAdvertiser

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

#pragma mark - Advertiser Delegate

- (void)advertiser:(MCNearbyServiceAdvertiser*)advertiser
    didReceiveInvitationFromPeer:(MCPeerID*)peerID
                     withContext:(NSData*)context
               invitationHandler:(void (^)(BOOL accept, MCSession* session))invitationHandler
{
    // Only accept invitations with IDs lower than the current host
    // If both people accept invitations, then connections are lost
    // However, this should always be the case since we only send invites in one direction
    if ([peerID.displayName compare:self.peerID.displayName] == NSOrderedDescending) {
        invitationHandler(YES, self.session);
    }
}

- (void)advertiser:(MCNearbyServiceAdvertiser*)advertiser didNotStartAdvertisingPeer:(NSError*)error
{
    [self.delegate partyTimeAdvertiser:self failedToJoinParty:error];
}

@end
