#import "CDZPinger.h"
#import "SimplePing.h"

@interface CDZPinger () <SimplePingDelegate>

@property (nonatomic, strong) SimplePing *simplePing;
@property (nonatomic, copy) NSString *domainOrIp;

@property (nonatomic, assign) BOOL pingingDesired;

@property (nonatomic, strong) NSDate *pingStartTime;
@property (nonatomic, strong, readonly) NSMutableArray *lastPingTimes;

@end

@implementation CDZPinger

@synthesize lastPingTimes = _lastPingTimes;

- (id)initWithHost:(NSString *)domainOrIp
{
    self = [super init];
    if (self) {
        self.simplePing.delegate = self;
        self.domainOrIp = domainOrIp;
        self.averageNumberOfPings = 8;
        self.pingWaitTime = 1.0;
    }
    return self;
}

- (void)startPinging
{
    if (!self.pingingDesired && !self.simplePing) {
        self.pingingDesired = YES;
        self.simplePing = [SimplePing simplePingWithHostName:self.domainOrIp];
        self.simplePing.delegate = self;
        [self.simplePing start];
    }
}

- (void)stopPinging
{
    self.pingingDesired = NO;
    [self.simplePing stop];
    self.simplePing = nil;
}

- (void)receivedError:(NSError *)error {
    [self stopPinging];

    id delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(pinger:didEncounterError:)]) {
        [delegate pinger:self didEncounterError:error];
    }
}

- (void)receivedPingWithTime:(NSTimeInterval)time {
    if (self.pingingDesired) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.pingWaitTime * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self sendPing];
        });
    }

    [self addPingTimeToRecord:time];
    __block NSTimeInterval totalTime = 0.0;
    __block NSUInteger timeCount = 0;
    [self.lastPingTimes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        totalTime += [obj doubleValue];
        timeCount++;
    }];
    NSTimeInterval averageTime = totalTime/(double)timeCount;

    dispatch_async(dispatch_get_main_queue(), ^{
        id delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(pinger:didUpdateWithAverageSeconds:)]) {
            [delegate pinger:self didUpdateWithAverageSeconds:averageTime];
        }
    });
}

- (void)sendPing
{
    [self.simplePing sendPingWithData:nil];
}

- (void)addPingTimeToRecord:(NSTimeInterval)time
{
    while (self.lastPingTimes.count >= self.averageNumberOfPings) {
        [self.lastPingTimes removeObjectAtIndex:0];
    }
    [self.lastPingTimes addObject:@(time)];
}

#pragma mark SimplePingDelegate methods

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
{
    if (self.pingingDesired) [self sendPing];
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet
{
    self.pingStartTime = [NSDate date];

    NSLog(@"#%u sent", (unsigned int) OSSwapBigToHostInt16(((const ICMPHeader *) [packet bytes])->sequenceNumber));
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet
{
    NSTimeInterval pingTime = [[NSDate date] timeIntervalSinceDate:self.pingStartTime];
    [self receivedPingWithTime:pingTime];

    NSLog(@"#%u received", (unsigned int) OSSwapBigToHostInt16([SimplePing icmpInPacket:packet]->sequenceNumber) );
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
{
    [self receivedError:error];
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error
{
    [self receivedError:error];
}

#pragma mark Property overrides

- (NSMutableArray *)lastPingTimes
{
    if (!_lastPingTimes) {
        _lastPingTimes = [NSMutableArray array];
    }
    return _lastPingTimes;
}

@end
