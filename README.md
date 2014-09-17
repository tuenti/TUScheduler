# TUScheduler

TUScheduler is a very simple iOS library that solves the problem of asynchronous testing in an elegant and robust way. Furthermore, TUScheduler allows you to decouple your code from the underlying concurrency API.

TUScheduler is inspired in the [Humble Object Pattern](http://xunitpatterns.com/Humble%20Object.html).

## The Problem with Async Testing

Asynchronous code is hard to test. This happens because, in order to validate it, the test have to stop and sit waiting for the async code to finish, and only then check if the behaviour was the expected.

### Polling

The most common approach is to use some kind of polling mechanism to periodically check if the async code finished executing:

``` objective-c
  NSTimeInterval pollingTime = 0.01;
  NSTimeInterval timeout = 2.0;
  NSDate *expiryDate = [NSDate dateWithTimeIntervalSinceNow:timeout];

  while(!testFinished && ([[NSDate date] compare:expiryDate] != NSOrderedDescending)) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:pollingTime]];
    OSMemoryBarrier();
  }
```

The test checks if the async code has finished (here represented by the `testFinished` flag). If it doesn't, the test sleeps for a very short amount of time, and then checks again. The test repeats this process until the expected condition is met, or the total waiting time surpasses the defined `timeout`.

The advantage of this approach over inactive waits is that you are only wasting at most `pollingTime` seconds. That is why most async testing frameworks use this technique (e.g. [Kiwi](https://github.com/kiwi-bdd/Kiwi), [GHUnit](https://github.com/gh-unit/gh-unit), [SenTestingKitAsync](https://github.com/nxtbgthng/SenTestingKitAsync)).

Apple is also providing a new native mechanism for async testing in Xcode 6 which allows to define expectations with timeouts for your tests using objects of class `XCTestExpectation`. Check the [docs](https://developer.apple.com/library/prerelease/ios/documentation/DeveloperTools/Conceptual/testing_with_xcode/testing_3_writing_test_classes/testing_3_writing_test_classes.html#//apple_ref/doc/uid/TP40014132-CH4-SW6) or have a look on `XCTestCase+AsynchronousTesting.h` file for more info.

### Timeouts and Continuous Integration

Polling techniques are usually enough in simple environments. However, there is a critical problem associated with them: how to choose the correct `timeout` value.

If this value is too tight, the test suite could very easily fail due to overloaded machines, or other special circumstances. On the other hand, very high timeout values could lead the whole suite to take a huge amount of time in case several tests time out simultaneously.

These two problems -which are relatively unimportant in small projects-, can significantly slow down a company or organization that relies on a Continuous Integration environment, in which integration of branches is done independently by different teams using an automated deployment pipeline.

#### A Trivial Example

Have a look on the following code snippet:

``` objective-c
- (void)loadContactsWithCompletion:(void(^)(NSArray *contacts))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSArray *contacts = [self incrediblySlowMethodToLoadContacts];
    completion(contacts);
  });
}
```

How can we choose an appropriate `timeout` for testing this method? There is no way to know how long it would take to execute `incrediblySlowMethodToLoadContacts`. The only option in this case is to estimate a reasonable timeout by trial and error, which leaves the tests time enough to get back from `incrediblySlowMethodToLoadContacts` and pass.

This estimated timeout is typically adjusted to work fine during normal deployment cycles, but there is no way to ensure that it would be enough in crunch times, when many teams are trying to integrate their branches, and build servers are overloaded. If a build fails in one of those days due to a very tight timeout, that means putting the branch back at the end of the integration queue, and start again all the build process, which would slow down the branch owners for sure, but very probably other teams as well (or even the whole company).


### TUScheduler Approach and the Humble Object pattern

TUScheduler is an alternative to the Polling approach. It is inspired in the [Humble Object Pattern](http://xunitpatterns.com/Humble%20Object.html). The idea is to extract all the hard-to-test code (the async behavior) from your business logic into a Humble Object (TUScheduler), so you can test your business logic separately, just as if it were fully synchronous. The Humble Object must be a very thin concurrency layer, so simple that it doesn't even need to be tested.

When a class needs to perform any asynchronous job, instead of directly posting this job using any of the available concurrency APIs (GCD, `NSOperations`, etc.), it will delegate this responsibility into a TUScheduler. The scheduler could be provided as a parameter or injected into the class during initialization.

When running tests, the class will be injected with an special *fake* scheduler, called the `TUFullySynchronousScheduler`. This scheduler is not concurrent at all, it just immediately executes all the jobs sent to it in a pure synchronous way. This way, tests can focus on testing the business logic without having to care about timeouts or concurrency management.

Does this affect in some way the quality of our tests? The answer is no. This little scheduling trick should be completely safe: the essence of concurrent programming is to separate *what* have to be done from *when* it is done, so the class should not be making any assumption on *when* the scheduled jobs are being executed, and the associated tests should be just as valid no matter if the jobs are synchronous or asynchronous. In fact, if a piece of code is in some way dependant on *when* the async jobs are done, then it is more than probably exposed to race conditions and other synchronization problems.

Furthermore, the use of TUScheduler also brings a very nice side-effect: classes are not coupled to a particular concurrency API, so you can always adopt a new one, only by changing a few lines of code.


## Using TUScheduler

Let's go back to the previous example:

``` objective-c
@implementation ContactLoader
- (void)loadContactsWithCompletion:(void(^)(NSArray *contacts))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSArray *contacts = [self incrediblySlowMethodToLoadContacts];
    completion(contacts);
  });
}
@end
```
How can we test this component using TUScheduler?


### The Simple Way

We can change the implementation of the class to receive a `TUScheduler` on creation. The `loadContactsWithCompletion:` method now delegates on the scheduler to perform the async

``` objective-c
@implementation ContactLoader
- (instancetype)initWithScheduler:(id<TUScheduler>)scheduler {
  if (self = [super init]) {
    _scheduler = scheduler;
  }
  return self;
}

- (void)loadContactsWithCompletion:(void(^)(NSArray * contacts))completion {
  [self.scheduler scheduleAsync:^{
    NSArray * contacts = [self incrediblySlowMethodToLoadContacts];
    completion(contacts);
  }];
}
@end
```

TUScheduler provides two different families of schedulers, based on GCD and `NSOperation` respectively. You can inject whichever you prefer:

```objective-c
id<TUScheduler> scheduler = [TUGCDScheduler serialSchedulerWithName:@"com.tuenti.GCD.Serial"];
ContactLoader *contactLoader = [[ContactLoader alloc] initWithScheduler:scheduler];
```

Now writing tests for this component is completely trivial:

``` objective-c
- (void)testLoadContactsWithCompletion_callsCompletionBlock {
  // given
  id<TUScheduler> scheduler = [[TUFullySynchronousScheduler alloc] initWithName:@"com.tuenti.FullySync"];
  ContactLoader *contactLoader = [[ContactLoader alloc] initWithScheduler:scheduler];

  // when
  __block BOOL called = NO;
  [contactLoader loadContactsWithCompletion:^(NSArray *contacts) {
    called = YES;
  }];

  // then
  assertThatBool(called, is(equalToBool(YES)));
}
```
The execution of the block would be completely synchronous, so no wait times, polling or timeouts. Just check the behaviour is the expected, and isolate the hard-to-test logic inside the scheduler.


### The Clean Way

Classes should be responsible of managing their concurrency mechanisms privately. It is very weird if the class that creates `ContactLoader` is responsible of deciding whether the concurrency mechanism is serial or concurrent, or what should be its name. Furthermore, some classes could need several schedulers to work (e.g. a serial one to keep an internal collection synchronized and a concurrent one to post heavy background tasks).

The solution is to use the abstract factory `TUSchedulerFactory`. The factory is injected during initialization, and then the class can use it to create as many schedulers as it needs, configuring them internally:

``` objective-c
- (instancetype)initWithSchedulerFactory:(id<TUSchedulerFactory>)schedulerFactory {
  if (self = [super init]) {
    _serialScheduler = [schedulerFactory serialSchedulerWithName:@"com.tuenti.Serial"];
    _concurrentScheduler = [schedulerFactory concurrentSchedulerWithName:@"com.tuenti.Concurrent"];
  }
  return self;
}
```

The creator of the class decides which concrete factory to inject depending on the desired family of schedulers:

``` objective-c
id <TUSchedulerFactory> factory = [[TUOperationQueueSchedulerFactory alloc] init];
ContactLoader *contactLoader = [[ContactLoader alloc] initWithSchedulerFactory:factory];
```

Again, a special factory is injected in tests, one which will always provide fully synchronous schedulers:

``` objective-c
- (void)testLoadContactsWithCompletion_callsCompletionBlock {
  // given
  id <TUSchedulerFactory> factory = [[TUFullySynchronousSchedulerFactory alloc] init];
  ContactLoader *contactLoader = [[ContactLoader alloc] initWithSchedulerFactory:factory];

  // when
  __block BOOL called = NO;
  [contactLoader loadContactsWithCompletion:^(NSArray *contacts) {
    called = YES;
  }];

  // then
  assertThatBool(called, is(equalToBool(YES)));
}
```

### Available Schedulers

TUScheduler library comes with three concrete factories:

1. **TUGCDSchedulerFactory** - Creates GCD based schedulers.
2. **TUOperationQueueSchedulerFactory** - creates schedulers based on NSOperation API.
3. **TUFullySynchronousSchedulerFactory** - creates fully synchronous schedulers.

Each TUSchedulerFactory can be used to generate three types of TUSchedulers:

1. **Serial Schedulers** - execute jobs serially in FIFO order.
2. **Concurrent Schedulers** - execute jobs concurrently.
2. **Main Thread Schedulers** - used to post jobs in the main thread.

Each TUScheduler can be used to post two types of jobs:

1. **scheduleAsync:** - schedules an asynchronous job.
2. **scheduleSync:** - schedules a synchronous job.


## Test Coverage

TUScheduler is designed to be extremely simple (only six classes, two protocols, and very few lines of code). That is the spirit behind Humble Object: the extracted logic must be so simple that it is not even need to test it at all. Even though, TUScheduler comes with a suite of unit tests that enforces the contract of the `<TUScheduler>` protocol in both concrete implementations `TUGCDScheduler` and `TUOperationQueueScheduler`.

These tests uses the special helper class `TUAsyncTestSentinel`, which implements a Polling algorithm to test the concurrent behaviour of schedulers. This way, users of TUScheduler can focus on testing their business logic, knowing that the concurrency management is tested elsewhere, and which is more important: only once.

As a side effect, the hard and unstable tests are all concentrated in the same test suite, so in case there are problems with the builds, we know exactly which tests we should quarantine. In fact, TUScheduler is so simple, that one could even completely ignore the tests. Visual inspection should be more than enough to spot a bug in such a simple piece of code.


## How to Install

#### Using cocoapods:


1. Add the following line to your Podfile:  `pod 'TUScheduler', :git => 'https://github.com/tuenti/TUScheduler'`
2. ``pod install``

#### Manually:

1. Clone the project, or download zipped version.
2. Add all the files under TUScheduler/Source to your project.
3. Look at the Requirements section if you are not using ARC.


## Requirements

TUScheduler should work in any relatively recent iOS/Mac version, but we have only tested it in iOS 7.0 and OS X 10.9.

TUScheduler uses ARC, so if you use it in a non-ARC project, and you are not
using CocoaPods, you will need to use `-fobjc-arc` compiler flag on every
TUScheduler source file.

To set a compiler flag in Xcode, go to your desired target and select the
“Build Phases” tab. Select all TUScheduler source files, press Enter,
add `-fobjc-arc` and then “Done” to enable ARC for TUScheduler.


## Collaborate

Please, feel free to collaborate with new ideas and proposals. Send your pull requests or write us a few words: [ios@tuenti.com](mailto:ios@tuenti.com)


## Credits & Contact

TUScheduler was created by iOS team at [Tuenti Technologies S.L.](http://github.com/tuenti). You can follow Tuenti engineering team on Twitter [@tuentieng](http://twitter.com/tuentieng).

## License

TUScheduler is available under the Apache License, Version 2.0. See LICENSE file for more info.
