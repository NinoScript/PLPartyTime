//
//  PLPartyTimeBrowser.h
//  PLPartyTimeBrowser
//
//  Created by Cristián Arenas on 7/1/14.
//  Copyright (c) 2014 Peter Livesey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol PLPartyTimeBrowserDelegate;

@interface PLPartyTimeBrowser : NSObject <MCNearbyServiceBrowserDelegate>

#pragma mark - Properties

/// Delegate for the PartyTime methods
@property (nonatomic, weak) id<PLPartyTimeBrowserDelegate> delegate;

#pragma mark - Initialization

- (instancetype)initWithSession:(MCSession*)session
                         peerID:(MCPeerID*)peerID;
@end

@protocol PLPartyTimeBrowserDelegate <NSObject>

- (void)partyTimeBrowser:(PLPartyTimeBrowser*)partyTimeBrowser
       failedToJoinParty:(NSError*)error;

@end
