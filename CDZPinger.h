#import <Foundation/Foundation.h>

@protocol CDZPingerDelegate;

@interface CDZPinger : NSObject

@property (nonatomic, weak) id<CDZPingerDelegate> delegate;
@property (nonatomic, copy, readonly) NSString *domainOrIp;

/**
 * Number of pings to average. Defaults to 6.
 */
@property (nonatomic, assign) NSUInteger averageNumberOfPings;

/**
 * Seconds to wait in between pings. Defaults to 1.0.
 */
@property (nonatomic, assign) NSTimeInterval pingWaitTime;

/**
 * Designated initializer.
 *
 * @param domainOrIp Domain name or IPv4 address to ping
 */
- (id)initWithHost:(NSString *)domainOrIp;

/**
 * Tell the pinger to begin pinging when it's ready.
 */
- (void)startPinging;

/**
 * Tell the pinger to stop pinging and clean up.
 */
- (void)stopPinging;

@end

@protocol CDZPingerDelegate <NSObject>

/**
 * Called every time the pinger receives a ping back from the server.
 *
 * @param pinger This CDZPinger object
 * @param seconds The average ping time, in seconds
 */
- (void)pinger:(CDZPinger *)pinger didUpdateWithAverageSeconds:(NSTimeInterval)seconds;

@optional

/**
 * Reports a ping error.
 *
 * Note: The pinger stops running after any error is encountered.
 *
 * @param pinger This CDZPinger object
 * @param error The NSError that was encountered
 */
- (void)pinger:(CDZPinger *)pinger didEncounterError:(NSError *)error;

@end
