# CDZPinger

Easy-to-use ICMP ping for iOS - just create a CDZPinger and you delegate gets a callback every second with the average ping time.

## Usage

Add the dependency to your `Podfile`:

```ruby
platform :ios
pod 'CDZPinger'
...
```

Run `pod install` to install the dependencies.

Then `#import "CDZPinger.h"` and:

```objc
CDZPinger *pinger = [[CDZPinger alloc] initWithHost:@"google.com"];
// be sure to keep a strong reference to this, maybe in a property somewhere

pinger.delegate = self;
// assuming this object is your delegate
```

In your delegate:

```objc
#pragma mark CDZPingerDelegate

- (void)pinger:(CDZPinger *)pinger didUpdateWithAverageSeconds:(NSTimeInterval)seconds
{
    NSLog([NSString stringWithFormat:@"Received ping; average time %.f ms", seconds*1000]);
}
```

## Requirements

`CDZPinger` requires iOS 5.x+. It might work on iOS 4, but I haven't tested it.

There's also some chance it'll work on OS X, but again, I haven't tested it there either.

## License

[MIT License](http://http://opensource.org/licenses/mit-license.php). See LICENSE for the full details.

## Author

Chris Dzombak, with ICMP ping code from Apple sample code.

* chris@chrisdzombak.net
* [chris.dzombak.name](http://chris.dzombak.name)
* [twitter: @cdzombak](http://twitter.com/cdzombak)
* [ADN: @dzombak](https://alpha.app.net/dzombak/)
