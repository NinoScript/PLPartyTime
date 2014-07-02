//
//  PLPartyTime.m
//  PLPartyTime
//
//  Created by Peter Livesey on 3/1/14.
//  Copyright (c) 2014 Peter Livesey. All rights reserved.
//

#import "PLPartyTime.h"
#import "PLPartyTimeAdvertiser.h"
#import "PLPartyTimeBrowser.h"

@interface PLPartyTime () <PLPartyTimeAdvertiserDelegate, PLPartyTimeBrowserDelegate>

// Public Properties
@property (nonatomic, readwrite) BOOL connected;
@property (nonatomic, readwrite) BOOL acceptingGuests;

// External Properties
@property (nonatomic, strong) NSString* serviceType;
@property (nonatomic, strong) MCSession* session;
@property (nonatomic, strong) MCPeerID* peerID;

// Internal Properties
@property (nonatomic, strong) PLPartyTimeAdvertiser* partyTimeAdvertiser;
@property (nonatomic, strong) MCNearbyServiceAdvertiser* advertiser;
@property (nonatomic, strong) PLPartyTimeBrowser* partyTimeBrowser;
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
        self.serviceType = serviceType;
        self.session = session;
        self.peerID = peerID;

        self.partyTimeAdvertiser = [[PLPartyTimeAdvertiser alloc] initWithSession:self.session
                                                                           peerID:self.peerID];

        self.partyTimeBrowser = [[PLPartyTimeBrowser alloc] initWithSession:self.session
                                                                     peerID:self.peerID];
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
    if (!self.acceptingGuests) {
        // Simultaneously advertise and browse at the same time
        [self.advertiser startAdvertisingPeer];
        [self.browser startBrowsingForPeers];

        self.connected = YES;
        self.acceptingGuests = YES;
    }
}

- (void)stopAcceptingGuests
{
    if (self.acceptingGuests) {
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
        _advertiser.delegate = self.partyTimeAdvertiser;
    }
    return _advertiser;
}

- (MCNearbyServiceBrowser*)browser
{
    if (!_browser) {
        NSAssert(self.serviceType, @"No service type. You must initialize this class using the custom intializers.");
        _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID
                                                    serviceType:self.serviceType];
        _browser.delegate = self.partyTimeBrowser;
    }
    return _browser;
}

#pragma mark - PartyTimeAdvertiser Delegate

- (void)partyTimeAdvertiser:(PLPartyTimeAdvertiser*)partyTimeAdvertiser
          failedToJoinParty:(NSError*)error
{
    [self.delegate partyTime:self failedToJoinParty:error];
}

#pragma mark - PartyTimeAdvertiser Delegate

- (void)partyTimeBrowser:(PLPartyTimeBrowser*)partyTimeBrowser
       failedToJoinParty:(NSError*)error
{
    [self.delegate partyTime:self failedToJoinParty:error];
}

@end
