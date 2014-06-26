//
//  PLPartyTime.m
//  PLPartyTime
//
//  Created by Peter Livesey on 3/1/14.
//  Copyright (c) 2014 Peter Livesey. All rights reserved.
//

#import "PLPartyTime.h"

@interface PLPartyTime () <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

// Public Properties
@property (nonatomic, readwrite) BOOL connected;
@property (nonatomic, readwrite) BOOL acceptingGuests;
@property (nonatomic, readwrite, strong) NSString *serviceType;

// External Properties
@property (nonatomic, strong) MCSession* session;
@property (nonatomic, strong) MCPeerID* peerID;

// Internal Properties
@property (nonatomic, strong) MCNearbyServiceAdvertiser* advertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser* browser;

@end

@implementation PLPartyTime

#pragma mark - Life Cycle
- (instancetype)initWithServiceType:(NSString*)serviceType
                            session:(MCSession*)session
                             peerID:(MCPeerID*)peerID
{
    NSParameterAssert(serviceType);
    NSParameterAssert(session);
    NSParameterAssert(peerID);

    self = [super init];
    if (self) {
        self.session = session;
        self.peerID = peerID;
        self.serviceType = serviceType;
    }
    return self;
}

- (void)dealloc
{
  // Will clean up the session and browsers properly
  [self leaveParty];
}

#pragma mark - Membership

- (void)joinParty
{
  // If we're already joined, then don't try again. This causes crashes.
  if (!self.acceptingGuests)
  {
    // Simultaneously advertise and browse at the same time
    [self.advertiser startAdvertisingPeer];
    [self.browser startBrowsingForPeers];
    
    self.connected = YES;
    self.acceptingGuests = YES;
  }
}

- (void)stopAcceptingGuests
{
  if (self.acceptingGuests)
  {
    [self.advertiser stopAdvertisingPeer];
    [self.browser stopBrowsingForPeers];
    self.acceptingGuests = NO;
  }
}

- (void)leaveParty
{
    [self stopAcceptingGuests];
    //    [self.session disconnect];
    // Must nil out these because if we try to reconnect, we need to recreate them
    // Else it fails to connect
    self.advertiser = nil;
    self.browser = nil;
    self.connected = NO;
}

#pragma mark - Properties

- (MCNearbyServiceAdvertiser*)advertiser
{
    if (!_advertiser) {
        NSAssert(self.serviceType, @"No service type. You must initialize this class using the custom intializers.");
        _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID
                                                        discoveryInfo:nil
                                                          serviceType:self.serviceType];
        _advertiser.delegate = self;
    }
    return _advertiser;
}

- (MCNearbyServiceBrowser*)browser
{
    if (!_browser) {
        NSAssert(self.serviceType, @"No service type. You must initialize this class using the custom intializers.");
        _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID
                                                    serviceType:self.serviceType];
        _browser.delegate = self;
    }
    return _browser;
}

#pragma mark - Advertiser Delegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID
       withContext:(NSData *)context
 invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
  // Only accept invitations with IDs lower than the current host
  // If both people accept invitations, then connections are lost
  // However, this should always be the case since we only send invites in one direction
  if ([peerID.displayName compare:self.peerID.displayName] == NSOrderedDescending)
  {
    invitationHandler(YES, self.session);
  }
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
  [self.delegate partyTime:self failedToJoinParty:error];
}

#pragma mark - Browser Delegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
  // Whenever we find a peer, let's just send them an invitation
  // But only send invites one way
  // TODO: What if display names are the same?
  // TODO: Make timeout configurable
  if ([peerID.displayName compare:self.peerID.displayName] == NSOrderedAscending)
  {
    NSLog(@"Sending invite: Self: %@", self.peerID.displayName);
    [browser invitePeer:peerID
              toSession:self.session
            withContext:nil
                timeout:10];
  }
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
  // Ignore this. We don't need it.
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
  [self.delegate partyTime:self failedToJoinParty:error];
}


@end
