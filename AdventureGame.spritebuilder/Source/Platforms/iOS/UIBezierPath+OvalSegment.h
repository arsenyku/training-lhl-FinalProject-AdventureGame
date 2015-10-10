//
//  UIBezierPath+UIBezierPath_OvalSegment.h
//  AdventureGame
//
//  Created by asu on 2015-10-10.
//  Copyright © 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIBezierPath (OvalSegment)

+ (UIBezierPath *)bezierPathWithOvalInRect:(CGRect)rect startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle;
+ (UIBezierPath *)bezierPathWithOvalInRect:(CGRect)rect startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle angleStep:(CGFloat)angleStep;
+ (NSArray *)pointsArrayForOvalInRect:(CGRect)rect startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle angleStep:(CGFloat)angleStep;

@end
