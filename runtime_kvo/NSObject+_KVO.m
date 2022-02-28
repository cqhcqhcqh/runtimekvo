//
//  NSObject+_KVO.m
//  runtime_kvo
//
//  Created by caitou on 2022/2/28.
//

#import "NSObject+_KVO.h"
#import <objc/runtime.h>
#import <objc/message.h>

static void *kPGKVOAssociatedObservers = &kPGKVOAssociatedObservers;

@implementation NSObject (_KVO)

- (void)vs_addObserver:(NSObject *)observer
                forKey:(NSString *)key
             withBlock:(VSObservingBlock)change {
    SEL setterSelector = NSSelectorFromString(key);
    Method method = class_getInstanceMethod([self class], setterSelector);
    if (!method) {
        
    }
    
    Class cls = object_getClass(self);
    NSString *clsName = NSStringFromClass(cls);
    
    if (![clsName hasPrefix:@"VS_"]) {
        cls = [self makeKvoClassWithOriginalClassName:clsName];
        object_setClass(self, cls);
    }
    
//    if (![self hasSelector:setterSelector]) {
        const char *types = method_getTypeEncoding(setterMethod);
        class_addMethod(cls, setterSelector, (IMP)kvo_setter, types);
//    }
    
    VSObservationInfo *info = [[VSObservationInfo alloc] initWithObserver:observer key:key block:change];
    NSMutableArray *observers = objc_getAssociatedObject(self, kPGKVOAssociatedObservers);
    if (!observers) {
        observer = [NSMutableArray array];
        objc_setAssociatedObject(self, kPGKVOAssociatedObservers, observer, OBJC_ASSOCIATION_RETAIN);
    }
    [observers addObject:info];
}

- (Class)makeKvoClassWithOriginalClassName:(NSString *)origClassName {
    NSString *kvoClassName = [@"VS_" stringByAppendingString:origClassName];
    Class cls = NSClassFromString(kvoClassName);
    if (cls) {
        return cls;
    }
    
    /// 创建一个类
    Class originalClass = object_getClass(self);
    /// 第一个参数是 superclass (The class to use as the new class's superclass, or Nil to create a new root class)
    /// 类名字（The string to use as the new class's name. The string will be copied)
    Class KVOClass = objc_allocateClassPair(originalClass,
                                            kvoClassName.UTF8String,
                                            0);
    Method classMethod = class_getInstanceMethod(originalClass, @selector(class));
    const char *types = method_getTypeEncoding(classMethod);
    class_addMethod(KVOClass, @selector(class), (IMP)kvo_class, types);
    objc_registerClassPair(KVOClass);
    return KVOClass;
    
}

Class kvo_class(id object, SEL selector, ...) {
    return [object class];
}

/// 重写 KVO 创建类的 setter 方法
static void kvo_setter(id self, SEL _cmd, id newValue) {
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *getterName = getterForSetter(setterName);
    
    // willChangeValueForKey:方法
    [self willChangeValueForKey:getterName];
    
    if (!getterName) {
        return;
    }
    
    id oldValue = [self valueForKey:getterName];
    
    if (oldValue == newValue) {
        return;
    }
    
    struct objc_super superclass = {
      .receiver = self,
      .super_class = class_getSuperclass(object_getClass(self))
    };
    
    void (*objc_msgSendSuperCasted)(void *, SEL, id) = (void *)objc_msgSendSuper;
    
    /// 调用父类原来的setter方法
    objc_msgSendSuperCasted(&superclass, _cmd, newValue);
    
    // didChangeValueForKey:方法
    [self didChangeValueForKey:getterName];
    
    // look up observers and call the blocks
    NSMutableArray *observers = objc_getAssociatedObject(self, kPGKVOAssociatedObservers);
    for (VSObservationInfo *each in observers) {
        if ([each.key isEqualToString:getterName]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                each.block(self, getterName, oldValue, newValue);
                [each.observer observeValueForKeyPath:getterName ofObject:self change:change context:nil];
            });
        }
    }
}

NSString *getterForSetter(NSString *name) {
    return name;
}
@end

@implementation VSObservationInfo

@end
