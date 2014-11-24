//
//  MetroListView.m
//  MetroInfo
//
//  Created by Jackie Zhang on 14/11/24.
//  Copyright (c) 2014年 Jackie Zhang. All rights reserved.
//

#import "MetroListView.h"
@interface MetroListView()
@property (nonatomic, assign) CGPoint beginPoint;
@end

@implementation MetroListView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    if (allTouches.count == 1)
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        self.beginPoint = [touch locationInView:self];
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    if (allTouches.count == 1)
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint currentPoint = [touch locationInView:self];
        CGRect frame = self.frame;
        frame.origin.x = currentPoint.x - self.beginPoint.x;
        frame.origin.y = currentPoint.y - self.beginPoint.y;
        self.frame = frame;
    }

}
@end
