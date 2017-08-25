//
//  ViewController.m
//  RuntimeDemo
//
//  Created by zhangqi on 25/8/2017.
//  Copyright © 2017 zhangqi. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "People.h"
#import "Chinese.h"

@interface ViewController ()

@end

@implementation ViewController


/* 例、类、父类、元类关系结构的示例代码 */
- (void)testClass
{
    Chinese *ch = [[Chinese alloc] init];
    NSLog(@"获取Chinese对象ch所属的类是：%@,其父类是：%@",object_getClass(ch),class_getSuperclass(object_getClass(ch)));
    Class cls = objc_getMetaClass("Chinese");
    if (class_isMetaClass(cls)) {
        NSLog(@"是元类，元类是：%@, 元类的父类：%@, 元类的isa:%@",cls,class_getSuperclass(cls),object_getClass(cls));
    }else{
        NSLog(@"NO metaClass..");
    }
    
    
    People *peo = [[People alloc] init];
    NSLog(@"获取People对象peo所属的类是：%@,其父类是：%@",object_getClass(peo),class_getSuperclass(object_getClass(peo)));
    cls = objc_getMetaClass("People");
    if (class_isMetaClass(cls)) {
        NSLog(@"是元类，元类是：%@, 元类的父类：%@, 元类的isa:%@",cls,class_getSuperclass(cls),object_getClass(cls));
    }else{
        NSLog(@"NO metaClass..");
    }
    
    
    cls = objc_getMetaClass("UIView");
    if (class_isMetaClass(cls)) {
        NSLog(@"YES, %@, %@, %@", cls, class_getSuperclass(cls), object_getClass(cls)); // Print: YES, UIView, UIResponder, NSObject
    }
    else {
        NSLog(@"NO");
    }
    
    cls = objc_getMetaClass("NSObject");
    if (class_isMetaClass(cls)) {
        NSLog(@"YES, %@, %@, %@", cls, class_getSuperclass(cls), object_getClass(cls)); // Print: YES, NSObject, NSObject, NSObject
    }
    else {
        NSLog(@"NO");
    }
    
    
}


/* 动态操作类与实例的示例代码 */

int32_t testRuntimeMethodIMP(id self,SEL _cmd, NSDictionary *dict)
{
    NSLog(@"testRuntimeMethodIMP : %@",dict);
    
    return 99;
}

- (void)runtimeConstuct
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    
    // 创建并注册一个类，并往类中添加方法
    Class cls = objc_allocateClassPair(People.class, "RuntimeSubClass", 0);
    class_addMethod(cls, @selector(testRuntimeMethod), (IMP)testRuntimeMethodIMP, "i@:@");
    objc_registerClassPair(cls);
    
    
    // 2: Create instance of class, print some info about class and associated meta class.
    id sub = [[cls alloc] init];
    NSLog(@"%@, %@", object_getClass(sub), class_getSuperclass(object_getClass(sub))); // Print: RuntimeSubClass, SuperClass
    Class metaCls = objc_getMetaClass("RuntimeSubClass");
    if (class_isMetaClass(metaCls)) {
        NSLog(@"YES, %@, %@, %@", metaCls, class_getSuperclass(metaCls), object_getClass(metaCls)); // Print: YES, RuntimeSubClass, SuperClass, NSObject
    }
    else {
        NSLog(@"NO");
    }
    
    
    // 3: Methods of class.
    unsigned int outCount = 0;
    Method *methods = class_copyMethodList(cls, &outCount);
    for (int32_t i = 0; i < outCount; i++) {
        Method method = methods[i];
        NSLog(@"%@, %s", NSStringFromSelector(method_getName(method)), method_getTypeEncoding(method));
    }
    // Print: testRuntimeMethod, i@:@
    free(methods);
    
    
    // 4: Call method.
    int32_t result = (int) [sub performSelector:@selector(testRuntimeMethod) withObject:@{@"a":@"para_a", @"b":@"para_b"}];
    NSLog(@"%d", result); // Print: 99
    
    
    // 5: Destory instances and class.
    // Destroy instances of cls class before destroy cls class.
    sub = nil;
    // Do not call this function if instances of the cls class or any subclass exist.
    objc_disposeClassPair(cls);
    
#pragma clang diagnostic pop
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self runtimeConstuct];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
