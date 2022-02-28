//
//  NSObject+_KVO.h
//  runtime_kvo
//
//  Created by caitou on 2022/2/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^VSObservingBlock)(id observedObject, NSString *observedKey, id oldvalue, id newvalue);

@interface NSObject (_KVO)
- (void)vs_addObserver:(NSObject *)observer
                forKey:(NSString *)key
             withBlock:(VSObservingBlock)change;
@end

@interface VSObservationInfo : NSObject
@property (nonatomic, strong) NSObject *observer;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) VSObservingBlock block;
- (instancetype)initWithObserver:(NSObject *)observer key:(NSString *)key block:(VSObservingBlock)block;
@end

NS_ASSUME_NONNULL_END
