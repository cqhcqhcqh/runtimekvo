//
//  Person.h
//  runtime_kvo
//
//  Created by caitou on 2022/2/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@end

@interface Student : Person

@end

@interface Teacher : Person

@end

@interface Account : NSObject

@property (nonatomic, assign) double balance;

@end
NS_ASSUME_NONNULL_END
