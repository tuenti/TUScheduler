//
//  TUFullySynchronousScheduler.h
//
//  Copyright (c) 2014 Tuenti Technologies S.L. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import "TUScheduler.h"

/**
 @abstract Fully Synchronous Scheduler meant to be used in tests
 @discussion
    Just executes the scheduled jobs immediately, and in the thread used by the caller. The idea is to execute all the
 	testing code synchronously in the main thread.
 */
@interface TUFullySynchronousScheduler : NSObject <TUScheduler>

- (instancetype)initWithName:(NSString *)name;

@end
