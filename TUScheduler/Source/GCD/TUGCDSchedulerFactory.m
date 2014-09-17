//
//  TUGCDSchedulerFactory.m
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

#import "TUGCDSchedulerFactory.h"

#import "TUGCDScheduler.h"

@implementation TUGCDSchedulerFactory

- (id<TUScheduler>)serialSchedulerWithName:(NSString *)name
{
	return [TUGCDScheduler serialSchedulerWithName:name];
}

- (id<TUScheduler>)concurrentSchedulerWithName:(NSString *)name
{
	return [TUGCDScheduler concurrentSchedulerWithName:name];
}

- (id<TUScheduler>)mainThreadScheduler
{
	dispatch_queue_t mainQueue = dispatch_get_main_queue();
	return [[TUGCDScheduler alloc] initWithDispatchQueue:mainQueue];
}

@end
