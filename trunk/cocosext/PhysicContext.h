/*
 * cocos2d+ext for iPhone
 *
 * Copyright (c) 2011 - Ngo Duc Hiep
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#ifndef __PHYSICCONTEXT_H__
#define __PHYSICCONTEXT_H__
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "constant+macro.h"

#if PHYSIC_ENABLED

#include <Box2D/Box2D.h>
#import "PhysicUserData.h"

const int   kMaxContactBuffer = 128;
const float kVelocityThresold = 1.0;

class DestructionListener;

typedef struct ContextSettings
{
	ContextSettings() :
	hz(60.0f),
	velocityIterations(8),
	positionIterations(1),
	drawShapes(1),
	drawJoints(1),
	drawAABBs(0),
	drawPairs(0),
	drawContactPoints(1),
	drawContactNormals(1),
	drawContactForces(1),
	drawFrictionForces(0),
	drawCOMs(0),
	drawStats(0),
	enableWarmStarting(1),
	enableContinuous(1),
	pause(0),
	singleStep(0)
	{}
	
	float32 hz;
	int32 velocityIterations;
	int32 positionIterations;
	int32 drawShapes ;
	int32 drawJoints;
	int32 drawAABBs;
	int32 drawPairs;
	int32 drawContactPoints;
	int32 drawContactNormals;
	int32 drawContactForces;
	int32 drawFrictionForces;
	int32 drawCOMs;
	int32 drawStats ;
	int32 enableWarmStarting;
	int32 enableContinuous;
	int32 pause;
	int32 singleStep;
} ContextSettings;

class QueryCallback : public b2QueryCallback
{
public:
	QueryCallback(const b2Vec2& point)
	{
		m_point = point;
		m_fixture = NULL;
	}
	
	bool ReportFixture(b2Fixture* fixture);
	
	b2Vec2 m_point;
	b2Fixture* m_fixture;
};

class b2CcWorld: public b2World{
public:
	b2CcWorld(b2Vec2 &g, bool b):b2World(g,b)
	{}
	void DestroyJoint(b2Joint* joint);
	void Merge(b2Body *parent, b2Body *child);
	void Merge(b2Body *parent, b2Fixture *fixture);
};

class PhysicContext : public b2ContactListener{
public:
	PhysicContext();
	PhysicContext(ContextSettings settings);
	~PhysicContext();
	b2CcWorld *getWorld();
	
	/** Step the world */
	void step(ccTime dt);
	
	void setupWorld();
	void setGravity(b2Vec2 g);
	
	b2Fixture *query(b2Vec2 &pos);
	
	/** Manage entity  */
	//b2CircleShape *createCircle();
	
	b2Body *createBody(b2BodyDef *def);
	b2Fixture *createFixture(b2Body *parent, b2FixtureDef *def);
	b2Joint *createJoint(b2JointDef *def);

	b2Body *createBody(b2BodyDef *def, NSObject<PhysicProtocol> *model);
	b2Fixture *createFixture(b2Body *parent, b2FixtureDef *def, NSObject<PhysicProtocol> *model);
	b2Joint *createJoint(b2JointDef *def, NSObject<PhysicProtocol> *model);
	
	b2Body *createBody(b2BodyDef *def, NSObject<PhysicProtocol> *model, NSString *key);
	b2Fixture *createFixture(b2Body *parent, b2FixtureDef *def, NSObject<PhysicProtocol> *model, NSString *key);
	b2Joint *createJoint(b2JointDef *def, NSObject<PhysicProtocol> *model, NSString *key);
	
	void destroyBody(b2Body *body);
	void DestroyJoint(b2Joint *joint);
	
	void explosion(b2Vec2 &pos, float radius, float force);
	
	/** User data */
	void setUserData(void *entity, PhysicEntityType type, NSObject<PhysicProtocol> *mode, NSString *key);
	void setUserData(void *entity, PhysicEntityType type, NSObject<PhysicProtocol> *mode);
	
	/** Query entity, need a fast look up data structure & algorithm */
	void *entityWithUserData(void *userData, int *outType);
	
		
	//** b2ContactListener methods */
	void BeginContact(b2Contact* contact);
	void EndContact(b2Contact* contact);
	void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
	void PostSolve(const b2Contact* contact, const b2ContactImpulse* impulse);
	
	b2Body *createBomb(b2Vec2 pos);
	float getTotalVelocity();
	
	//get a static body, usefull to create joint which has a static body
	b2Body *staticBody();
	
	/** Touch handler  */
	
	b2MouseJoint *m_mouseJoint;
	b2CcWorld *world;
protected:
	b2Body *_staticBody;
	DestructionListener *destructionListener;
	ContextSettings settings;
	int32 contactCount;
	CollisionInfo contactBuffer[kMaxContactBuffer];
};

class DestructionListener : public b2DestructionListener
{
public:
	void SayGoodbye(b2Fixture* fixture);
	void SayGoodbye(b2Joint* joint);
	
	PhysicContext* context;
	//ContextController *controller;
};

#endif
#endif