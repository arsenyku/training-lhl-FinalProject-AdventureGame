//
//  UIBezierPath+UIBezierPath_OvalSegment.m
//  AdventureGame
//
//  Created by asu on 2015-10-10.
//  Copyright © 2015 Apportable. All rights reserved.
//


#import "UIBezierPath+OvalSegment.h"

@implementation UIBezierPath (OvalSegment)

+ (NSArray *)pointsArrayForOvalInRect:(CGRect)rect startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle angleStep:(CGFloat)angleStep {
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat xRadius = CGRectGetWidth(rect)/2.0f;
    CGFloat yRadius = CGRectGetHeight(rect)/2.0f;
    
    NSMutableArray *ellipsePoints = [[NSMutableArray alloc] init];
    
    CGPoint firstEllipsePoint = [self ellipsePointForAngle:startAngle withCenter:center xRadius:xRadius yRadius:yRadius];
    [ellipsePoints addObject:[NSValue valueWithCGPoint:firstEllipsePoint]];
    
    for (CGFloat angle = startAngle + angleStep; angle < endAngle; angle += angleStep) {
        CGPoint ellipsePoint = [self ellipsePointForAngle:angle withCenter:center xRadius:xRadius yRadius:yRadius];
        [ellipsePoints addObject:[NSValue valueWithCGPoint:ellipsePoint]];
    }
    
    CGPoint lastEllipsePoint = [self ellipsePointForAngle:endAngle withCenter:center xRadius:xRadius yRadius:yRadius];
    [ellipsePoints addObject:[NSValue valueWithCGPoint:lastEllipsePoint]];
    
    return ellipsePoints;
}

+ (UIBezierPath *)bezierPathWithOvalInRect:(CGRect)rect startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle angleStep:(CGFloat)angleStep {
    UIBezierPath *result = [[UIBezierPath alloc] init];
    
    NSArray *points = [UIBezierPath pointsArrayForOvalInRect:rect startAngle:startAngle endAngle:endAngle angleStep:angleStep];

    if (points == nil || [points count] < 1)
        return result;

    CGPoint point = [points[0] CGPointValue];
    [result moveToPoint:point];
    
    for (int i = 1; i < [points count]; i++){
        point = [points[i] CGPointValue];
        [result addLineToPoint:point];
    }
    
    return result;
}

//+ (UIBezierPath *)bezierPathWithOvalInRect:(CGRect)rect startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle angleStep:(CGFloat)angleStep {
//    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
//    CGFloat xRadius = CGRectGetWidth(rect)/2.0f;
//    CGFloat yRadius = CGRectGetHeight(rect)/2.0f;
//    
//    UIBezierPath *ellipseSegment = [UIBezierPath new];
//    
//    CGPoint firstEllipsePoint = [self ellipsePointForAngle:startAngle withCenter:center xRadius:xRadius yRadius:yRadius];
//    [ellipseSegment moveToPoint:firstEllipsePoint];
//    
//    for (CGFloat angle = startAngle + angleStep; angle < endAngle; angle += angleStep) {
//        CGPoint ellipsePoint = [self ellipsePointForAngle:angle withCenter:center xRadius:xRadius yRadius:yRadius];
//        [ellipseSegment addLineToPoint:ellipsePoint];
//    }
//    
//    CGPoint lastEllipsePoint = [self ellipsePointForAngle:endAngle withCenter:center xRadius:xRadius yRadius:yRadius];
//    [ellipseSegment addLineToPoint:lastEllipsePoint];
//    
//    return ellipseSegment;
//}

+ (UIBezierPath *)bezierPathWithOvalInRect:(CGRect)rect startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    return [UIBezierPath bezierPathWithOvalInRect:rect startAngle:startAngle endAngle:endAngle angleStep:M_PI/20.0f];
}

+ (CGPoint)ellipsePointForAngle:(CGFloat)angle withCenter:(CGPoint)center xRadius:(CGFloat)xRadius yRadius:(CGFloat)yRadius {
    CGFloat x = center.x + xRadius * cosf(angle);
    CGFloat y = center.y - yRadius * sinf(angle);
    return CGPointMake(x, y);
}

@end