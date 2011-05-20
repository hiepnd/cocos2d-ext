//
//  Stencil.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 5/7/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "Stencil.h"


@implementation Stencil

- (void) draw{
	//ccDrawCircle(ccp(0,0), 50, 0, 20, FALSE);
	
	CGPoint center = ccp(0,0);
	BOOL drawLineToCenter = NO;
	float r = 50;
	int segs = 20;
	float a = 0;
	
	int additionalSegment = 1;
	if (drawLineToCenter)
		additionalSegment++;
	
	const float coef = 2.0f * (float)M_PI/segs;
	
	GLfloat *vertices = calloc( sizeof(GLfloat)*2*(segs+2), 1);
	if( ! vertices )
		return;
	
	for(NSUInteger i=0;i<=segs;i++)
	{
		float rads = i*coef;
		GLfloat j = r * cosf(rads + a) + center.x;
		GLfloat k = r * sinf(rads + a) + center.y;
		
		vertices[i*2] = j * CC_CONTENT_SCALE_FACTOR();
		vertices[i*2+1] =k * CC_CONTENT_SCALE_FACTOR();
	}
	vertices[(segs+1)*2] = center.x * CC_CONTENT_SCALE_FACTOR();
	vertices[(segs+1)*2+1] = center.y * CC_CONTENT_SCALE_FACTOR();
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	//1
	//glClearStencil(0);
    glEnable(GL_STENCIL_TEST);
	
    // Clear color and stencil buffer
    //glClear(GL_STENCIL_BUFFER_BIT);
	
    // All drawing commands fail the stencil test, and are not
    // drawn, but increment the value in the stencil buffer.
    glStencilFunc(GL_EQUAL, 0x1, 0x1);
	glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
	//end 1
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);	
	glColor4f(1., 1., 1., 1.);
	//glDrawArrays(GL_LINE_STRIP, 0, segs+additionalSegment);
	glDrawArrays(GL_TRIANGLE_FAN, 0, segs);
	
	
	//2
	glStencilFunc(GL_EQUAL, 0x0, 0x1);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
	//end 2
	
	glColor4f(0, 0, 0, 1);
	ccDrawCircle(ccp(0,-30), 70, 0, 60, 0);
	
	// restore default state
	
	glDisable(GL_STENCIL_TEST);
	
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);	

	
	free( vertices );
	
	//[CCParticleSystemQuad particleWithFile:@""];
	
	/*
	double dRadius = 0.1; // Initial radius of spiral
    double dAngle;        // Looping variable
	
    // Clear blue window
    glClearColor(0.0f, 0.0f, 1.0f, 0.0f);
	
    // Use 0 for clear stencil, enable stencil test
    glClearStencil(0);
    glEnable(GL_STENCIL_TEST);
	
    // Clear color and stencil buffer
    glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	
    // All drawing commands fail the stencil test, and are not
    // drawn, but increment the value in the stencil buffer.
    glStencilFunc(GL_NEVER, 0x0, 0x0);
    glStencilOp(GL_INCR, GL_INCR, GL_INCR);
	
    // Spiral pattern will create stencil pattern
    // Draw the spiral pattern with white lines. We
    // make the lines  white to demonstrate that the
    // stencil function prevents them from being drawn
    glColor4f(1.0f, 1.0f, 1.0f,0.0f);
    glBegin(GL_LINE_STRIP);
	for(dAngle = 0; dAngle < 400.0; dAngle += 0.1)
	{
		glVertex2d(dRadius * cos(dAngle), dRadius * sin(dAngle));
		dRadius *= 1.002;
	}
    glEnd();
	
    // Now, allow drawing, except where the stencil pattern is 0x1
    // and do not make any further changes to the stencil buffer
    glStencilFunc(GL_NOTEQUAL, 0x1, 0x1);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
	
    // Now draw red bouncing square
    // (x and y) are modified by a timer function
    //glColor3f(0.0f, 1.0f, 0.0f);
    //glRectf(x, y, x + rsize, y - rsize);
	*/
}
@end
