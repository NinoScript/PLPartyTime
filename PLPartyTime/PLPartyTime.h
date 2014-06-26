//
//  PLPartyTime.h
//  PLPartyTime
//
//  Created by Peter Livesey on 3/1/14.
//  Copyright (c) 2014 Peter Livesey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol PLPartyTimeDelegate;

/**
 This is a light wrapper around the MultiPeer connectivity framework which quickly connects devices without having to send or receive invites. Here's the quick setup:

 Each device calls:
 
    PLPartyTime *partyTime = [[PLPartyTime alloc] initWithServiceType@"MyApp"];
    partyTime.delegate = self;
    [partyTime joinParty];

 Each device will get a callback when anyone connects or disconnects. Note that any device which joins the party with this service type will automatically join without sending or receiving invitations.

    - (void)partyTime:(PLPartyTime *)partyTime peer:(MCPeerID *)peer changedState:(MCSessionState)state currentPeers:(NSArray *)currentPeers;
 
 Then, anytime you want to send data, you can call a method to send to all connected users (peers) or an array of select peers.

    - (BOOL)sendData:(NSData *)data withMode:(MCSessionSendDataMode)mode error:(NSError **)error;
    - (BOOL)sendData:(NSData *)data toPeers:(NSArray *)peerIDs withMode:(MCSessionSendDataMode)mode error:(NSError **)error;

 The clients receiving data get the callback:

    - (void)partyTime:(PLPartyTime *)partyTime didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID;

 And that's it.
 There are a few more features of this library, but I'll let you read through the documentation to find those specifically. 
*/

@interface PLPartyTime : NSObject

#pragma mark - Properties

/// Delegate for the PartyTime methods
@property (nonatomic, weak) id<PLPartyTimeDelegate> delegate;

/// Query whether the client has joined the party
@property (nonatomic, readonly) BOOL connected;
/// Returns the serviceType which was passed in when the object was initialized.
@property (nonatomic, readonly, strong) NSString* serviceType;

#pragma mark - Initialization

/**
 Init method for this class.
 
 You must initialize this method with this method or:
 
    - (instancetype)initWithServiceType:(NSString *)serviceType displayName:(NSString *)displayName;
 
 Since you are not passing in a display name, it will default to:
 
    [UIDevice currentDevice].name]
 
 Which returns a string similar to: @"Peter's iPhone".
 
 @param serviceType The type of service to advertise. This should be a short text string that describes the app's networking protocol, in the same format as a Bonjour service type:
 
 1. Must be 1–15 characters long.
 2. Can contain only ASCII lowercase letters, numbers, and hyphens.
 
 This name should be easily distinguished from unrelated services. For example, a text chat app made by ABC company could use the service type abc-txtchat. For more details, read “Domain Naming Conventions”.
 */
//- (instancetype)initWithServiceType:(NSString*)serviceType;

/**
 Init method for this class.
 
 You must initialize this method with this method or:
 
    - (instancetype)initWithServiceType:(NSString *)serviceType displayName:(NSString *)displayName;
 
 @param serviceType The type of service to advertise. This should be a short text string that describes the app's networking protocol, in the same format as a Bonjour service type:
 
 1. Must be 1–15 characters long.
 2. Can contain only ASCII lowercase letters, numbers, and hyphens.
 
 This name should be easily distinguished from unrelated services. For example, a text chat app made by ABC company could use the service type abc-txtchat. For more details, read “Domain Naming Conventions”.
 
 @param displayName The display name which is sent to other clients in the party.
 */
- (instancetype)initWithServiceType:(NSString*)serviceType
                            session:(MCSession*)session
                             peerID:(MCPeerID*)peerID;

/**
 Call this method to join the party. It will automatically start searching for peers.
 
 When you sucessfully connect to another peer, you will receive a delegate callback to:
 
    - (void)partyTime:(PLPartyTime *)partyTime peer:(MCPeerID *)peer changedState:(MCSessionState)state currentPeers:(NSArray *)currentPeers;
 */
- (void)joinParty;

/**
 Call this method stop accepting invitations from peers. You will not disconnect from the party, but will not allow incoming connections.
 
 To start searching for peers again, call the joinParty method again.
 */
- (void)stopAcceptingGuests;

/**
 Call this method to disconnect from the party. You can reconnect at any time using the joinParty method.
 */
- (void)leaveParty;

@end

/**
 The delegate for the PLPartyTime class.
 
 Most of this is self documenting, so I'm going to leave documentation out right now...I'm a little tired of writing documentation for now.
 */
@protocol PLPartyTimeDelegate <NSObject>
- (void)partyTime:(PLPartyTime*)partyTime
    failedToJoinParty:(NSError*)error;
@end
