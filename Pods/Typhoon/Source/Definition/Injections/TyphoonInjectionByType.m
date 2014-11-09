//
//  TyphoonInjectionByType.m
//  A-Typhoon
//
//  Created by Aleksey Garbarev on 12.03.14.
//  Copyright (c) 2014 Jasper Blues. All rights reserved.
//

#import "TyphoonInjectionByType.h"
#import "TyphoonComponentFactory.h"
#import "TyphoonDefinition+Infrastructure.h"
#import "TyphoonTypeDescriptor.h"
#import "TyphoonComponentFactory+InstanceBuilder.h"
#import "TyphoonDefinition.h"

@implementation TyphoonInjectionByType

#pragma mark - Overrides

- (id)copyWithZone:(NSZone *)zone
{
    TyphoonInjectionByType *copied = [[TyphoonInjectionByType alloc] init];
    [self copyBasePropertiesTo:copied];
    copied.explicitClassOrProtocol = self.explicitClassOrProtocol;
    return copied;
}

- (BOOL)isEqualToCustom:(id)injection
{
    return YES;
}

- (void)valueToInjectWithContext:(TyphoonInjectionContext *)context completion:(TyphoonInjectionValueBlock)result
{
    id classOrProtocol = self.explicitClassOrProtocol;

    if (!classOrProtocol) {
        classOrProtocol = context.destinationType.classOrProtocol;
    }
    
    if (!classOrProtocol) {
        if (self.type == TyphoonInjectionTypeProperty) {
            [NSException raise:NSInternalInconsistencyException format:@"Can't recognize type for property '%@' of class '%@'. Make sure that @property exists and has correct type.", self.propertyName, context.destinationInstanceClass];
        } else {
            [NSException raise:NSInternalInconsistencyException format:@"Only property injection support InjectionByType"];

        }
    }

    TyphoonDefinition *definition = [context.factory definitionForType:classOrProtocol];
    
    [context.factory resolveCircularDependency:definition.key args:context.args resolvedBlock:^(BOOL isCircular) {
        result([context.factory componentForKey:definition.key]);
    }];
}

- (NSUInteger)customHash
{
    return [self.explicitClassOrProtocol hash];
}

@end
