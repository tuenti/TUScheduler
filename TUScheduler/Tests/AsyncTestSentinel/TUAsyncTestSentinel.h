//
//  TUAsyncTestSentinel.h
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

/**
 @class TUAsyncTestSentinel
 @discussion 
    This component performs an active wait until fulfillCondition is called or timeOut is reached. It is useful for 
    testing async code.
 @warning 
    Apple anounced a new API for async testing in Xcode 6. Consider using that API instead of this class in the future.
 */
@interface TUAsyncTestSentinel : NSObject

@property (nonatomic, readonly) BOOL condition;

/**
 @abstract The sentinel will wait until this method is called (or time is out)
 */
- (void)fulfillCondition;

/**
 @abstract Brings the condition to the initial state
 @discussion 
    Once fulfillCondition is called, all the successive calls to waitForCondition will not wait at all (because the 
    condition is already fulfilled). Use this method to reset a sentinel to the initial state, so waitForCondition will
    wait again for the next fulfillCondition call.
 */
- (void)resetCondition;

/**
 @abstract Make the sentinel to perform an active wait until fulfillCondition is called or time is out
 @warning 
    Once fulfillCondition is called, successive calls to this method will not wait at all, unless you call resetCondition 
    to bring the sentinel back to initial position
 */
- (void)waitForConditionWithTimeOut:(NSTimeInterval)timeout;

/**
 @abstract Make the sentinel to perform an active wait until fulfillCondition is called or time is out. Then execute the
 appropriate block.
 @warning 
    Once fulfillCondition is called, successive calls to this method will not wait at all, unless you call resetCondition
    to bring the sentinel back to initial position
 */
- (void)waitForConditionWithTimeOut:(NSTimeInterval)timeout
					   successBlock:(void(^)(void))successBlock
					   timeOutBlock:(void(^)(void))timeoutBlock;

@end
