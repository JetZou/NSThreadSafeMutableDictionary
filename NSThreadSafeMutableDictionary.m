//
//  NSThreadSafeMutableDictionary.m
//  YoluAddressBook
//
//  Created by Jet on 14-5-26.
//  Copyright (c) 2014年 Yolu. All rights reserved.
//

#import "NSThreadSafeMutableDictionary.h"
#import <libkern/OSAtomic.h>

@implementation NSThreadSafeMutableDictionary {
    OSSpinLock _lock;
    NSMutableDictionary *_dictionary; // Class Cluster!
}

- (instancetype)init
{
    return [self initWithCapacity:0];
}

- (id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys
{
    if ((self = [self initWithCapacity:objects.count])) {
        [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            _dictionary[keys[idx]] = obj;
        }];
    }
    return self;
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    if ((self = [super init])) {
        _dictionary = [[NSMutableDictionary alloc] initWithCapacity:capacity];
        _lock = OS_SPINLOCK_INIT;
    }
    return self;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    OSSpinLockLock(&_lock);
    _dictionary[aKey] = anObject;
    OSSpinLockUnlock(&_lock);
}

- (void)removeObjectForKey:(id)aKey {
    OSSpinLockLock(&_lock);
    [_dictionary removeObjectForKey:aKey];
    OSSpinLockUnlock(&_lock);
}

- (NSUInteger)count {
    OSSpinLockLock(&_lock);
    NSUInteger count = _dictionary.count;
    OSSpinLockUnlock(&_lock);
    return count;
}

- (id)objectForKey:(id)aKey {
    OSSpinLockLock(&_lock);
    id obj = _dictionary[aKey];
    OSSpinLockUnlock(&_lock);
    return obj;
}

- (NSEnumerator *)keyEnumerator {
    OSSpinLockLock(&_lock);
    NSEnumerator *keyEnumerator = [_dictionary keyEnumerator];
    OSSpinLockUnlock(&_lock);
    return keyEnumerator;
}

@end