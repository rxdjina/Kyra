//
//  MusicSessionHandler.m
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/13/22.
//

#import "MusicSessionHandler.h"
#import "AppDelegate.h"

@implementation MusicSessionHandler

- (void)liveQuery:(PFQuery<PFObject *> *)query didRecieveEvent:(PFLiveQueryEvent *)event inClient:(PFLiveQueryClient *)client {
    
    NSLog(@"CREATED EVENT TYPE: %ld", (long)PFLiveQueryEventTypeCreated);
    NSLog(@"UPDATED EVENT TYPE: %ld", (long)PFLiveQueryEventTypeUpdated);
    NSLog(@"REMOVED EVENT TYPE: %ld", (long)PFLiveQueryEventTypeDeleted);
    NSLog(@"EVENT: %@", event);
    NSLog(@"EVENT TYPE: %ld", (long)event.type);
    NSLog(@"EVENT OBJECT: %@", event.object);
}

- (void)liveQuery:(PFQuery<PFObject *> *)query didSubscribeInClient:(PFLiveQueryClient *)client {
    NSLog(@"LIVE QUERY SUBSCRIBED");
}

- (void)liveQuery:(PFQuery<PFObject *> *)query didUnsubscribeInClient:(PFLiveQueryClient *)client {
    NSLog(@"LIVE QUERY UNSUBSCRIBED");
}

- (void)liveQuery:(PFQuery<PFObject *> *)query didEncounterError:(NSError *)error inClient:(PFLiveQueryClient *)client {
    NSLog(@"LIVE QUERY ERROR: %@", error.localizedDescription);
}

@end
