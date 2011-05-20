//
//  PhysicContext.mm
//  Penguins Destroyer
//
//  Created by Ngo Duc Hiep on 10/4/10.
//  Copyright 2010 PTT Solution., JSC. All rights reserved.
//

#include "PhysicContext.h"

#if PHYSIC_ENABLED

#import "PhysicUserData.h"

PhysicContext::PhysicContext(){
	b2Vec2 gravity(0.,-10.);
	world = new b2CcWorld(gravity, true);
	world->SetContinuousPhysics(false);
	world->SetContactListener(this);
	//destructionListener = new DestructionListener();
	//world->SetDestructionListener(destructionListener);
	//destructionListener->context = this;
	_staticBody = NULL;
}

PhysicContext::PhysicContext(ContextSettings settings){
	PhysicContext();
	this->settings = settings;
	//setupWorld();
}

PhysicContext::~PhysicContext(){
	//delete destructionListener;
	delete world;
}

void PhysicContext::setupWorld(){
	
}

void PhysicContext::step(ccTime dt){
	/** Reset contact counter before stepping */
	contactCount = 0;
	
	world->Step(dt, settings.velocityIterations, settings.positionIterations);
	
	/** Process collision  */
	
	for (int i = 0; i < contactCount; i++) {
		CollisionInfo *info = contactBuffer + i;
		if ([(info->uA).component isValid] && [(info->uA).component respondsToSelector:@selector(physicEntity:collideWith:info:)]) {
			[(info->uA).component physicEntity:info->uA collideWith:info->uB info:*info];
		}
		
		if ([(info->uB).component isValid] && [(info->uB).component respondsToSelector:@selector(physicEntity:collideWith:info:)]) {
			[(info->uB).component physicEntity:info->uB collideWith:info->uA info:*info];
		}
		
	}
	
	/** Update position & angle */
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		PhysicUserData *data = (PhysicUserData *) b->GetUserData();
		if (data != NULL && b->GetType() != b2_staticBody 
			&& [data.component isValid] 
			&& ![data.component isUpdateIgnored]
			&& [data.component respondsToSelector:@selector(physicBodyChanged:)]) {
			PhysicUserData *data = (PhysicUserData *) b->GetUserData();
			[data.component physicBodyChanged:data];
		}	
	}
}

b2CcWorld *PhysicContext::getWorld(){
	return world;
}


void PhysicContext::setGravity(b2Vec2 g){
	world->SetGravity(g);
}

b2Fixture *PhysicContext::query(b2Vec2 &pos){
	b2AABB aabb;
	b2Vec2 d;
	d.Set(0.001f, 0.001f);
	aabb.lowerBound = pos - d;
	aabb.upperBound = pos + d;
	
	// Query the world for overlapping shapes.
	QueryCallback callback(pos);
	world->QueryAABB(&callback, aabb);
		
	return callback.m_fixture;
}

#pragma mark PhysicContext - Manage entity 
b2Body *PhysicContext::createBody(b2BodyDef *def){
	return world->CreateBody(def);
}

b2Fixture *PhysicContext::createFixture(b2Body *parent, b2FixtureDef *def){
	return parent->CreateFixture(def);
}

b2Joint *PhysicContext::createJoint(b2JointDef *def){
	return world->CreateJoint(def);
}

b2Body *PhysicContext::createBody(b2BodyDef *def, NSObject<PhysicProtocol> *model){
	b2Body *body = this->createBody(def);
	this->setUserData(body, PHYSIC_BODY, model);
	return body;
}

b2Fixture *PhysicContext::createFixture(b2Body *parent, b2FixtureDef *def, NSObject<PhysicProtocol> *model){
	b2Fixture *fix = this->createFixture(parent, def);
	this->setUserData(fix, PHYSIC_FIXTURE, model);
	return fix;
}

b2Joint *PhysicContext::createJoint(b2JointDef *def, NSObject<PhysicProtocol> *model){
	b2Joint *joint = this->createJoint(def);
	this->setUserData(joint, PHYSIC_JOINT, model);
	return joint;
}

b2Body *PhysicContext::createBody(b2BodyDef *def, NSObject<PhysicProtocol> *model, NSString *key){
	b2Body *body = this->createBody(def);
	this->setUserData(body, PHYSIC_BODY, model, key);
	return body;
}

b2Fixture *PhysicContext::createFixture(b2Body *parent, b2FixtureDef *def, NSObject<PhysicProtocol> *model, NSString *key){
	b2Fixture *fix = this->createFixture(parent, def);
	this->setUserData(fix, PHYSIC_FIXTURE, model, key);
	return fix;
}

b2Joint *PhysicContext::createJoint(b2JointDef *def, NSObject<PhysicProtocol> *model, NSString *key){
	b2Joint *joint = this->createJoint(def);
	this->setUserData(joint, PHYSIC_JOINT, model, key);
	return joint;
}

void PhysicContext::destroyBody(b2Body *body){
	world->DestroyBody(body);
}

void PhysicContext::DestroyJoint(b2Joint *joint){
	world->DestroyJoint(joint);
}

void PhysicContext::explosion(b2Vec2 &b2TouchPosition, float maxDistance, float maxForce){
	CGFloat distance;
	CGFloat strength;
	float force;
	CGFloat angle;
	
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) 
	{
		b2Vec2 b2BodyPosition = b->GetWorldCenter();
		if (b->GetType() == b2_staticBody) {
			continue;
		}
		
		if(1) // Get sucked towards the mouse
		{
			// Get the distance, and cap it
			distance = b2Distance(b2BodyPosition, b2TouchPosition);
			if(distance > maxDistance){
				distance = maxDistance - 0.01; 
				continue;
			}
			// Get the strength
			//strength = distance / maxDistance; // Uncomment and reverse these two. and ones further away will get more force instead of less 
			strength = (maxDistance - distance) / maxDistance; // This makes it so that the closer something is - the stronger, instead of further
			force  = strength * maxForce;
			// Get the angle
			angle = atan2f(b2TouchPosition.y - b2BodyPosition.y, b2TouchPosition.x - b2BodyPosition.x);		
			//NSLog(@" distance:%0.2f,force:%0.2f", distance, force);
			// Apply an impulse to the body, using the angle
			b2Vec2 v = b2Vec2(- cosf(angle) * force, - sinf(angle) * force);
			CGPoint p = CGPointMake(v.x, v.y);
			//b->ApplyLinearImpulse(v, b->GetPosition());
			
			if (b->GetUserData() != NULL) {
				PhysicUserData *data = (PhysicUserData *) b->GetUserData();
				if ([data.component isValid]) {
					[data.component physicBody:data receivedImpulse:p];
				}
			}
			b->ApplyForce(v, b->GetWorldCenter());
		}
		else // To go towards the press, all we really change is the atanf function, and swap which goes first to reverse the angle
		{
			distance = b2Distance(b2BodyPosition, b2TouchPosition);
			if(distance > maxDistance) {
				distance = maxDistance - 0.01;
				continue;
			}
			// Normally if distance is max distance, it'll have the most strength, this makes it so the opposite is true - closer = stronger
			strength = (maxDistance - distance) / maxDistance; // This makes it so that the closer something is - the stronger, instead of further
			force = strength * maxForce;
			angle = atan2f(b2BodyPosition.y - b2TouchPosition.y, b2BodyPosition.x - b2TouchPosition.x);	
			b->ApplyLinearImpulse(b2Vec2(cosf(angle) * force, sinf(angle) * force), b->GetPosition());
		}
	}
}

void PhysicContext::setUserData(void *entity, PhysicEntityType type, NSObject<PhysicProtocol> *mode, NSString *key){
	PhysicUserData *data = [mode registerPhysic:key] ;
	data.type = type;
	data.entity = entity;
	switch (type) {
		case PHYSIC_BODY:
			((b2Body *)entity)->SetUserData(data);
			break;
			
		case PHYSIC_JOINT:
			((b2Joint *)entity)->SetUserData(data);
			break;
		
		case PHYSIC_FIXTURE:
			((b2Fixture *)entity)->SetUserData(data);
			break;
		
		default:
			break;
	}
}

void PhysicContext::setUserData(void *entity, PhysicEntityType type, NSObject<PhysicProtocol> *mode){
	this->setUserData(entity,type,mode,@"self");
}

/** Query entity, need a fast look up data structure & algorithm */
void *PhysicContext::entityWithUserData(void *userData, int *outType){
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() == userData) {
			*outType = PHYSIC_BODY;
			return b;
		}	
		for (b2Fixture *f = b->GetFixtureList(); f; f = f->GetNext()) {
			if (f->GetUserData() == userData) {
				*outType = PHYSIC_FIXTURE;
				return f;
			}
		}
	}
	for (b2Joint *j = world->GetJointList(); j; j = j->GetNext()) {
		if (j->GetUserData() == userData) {
			*outType = PHYSIC_JOINT;
			return j;
		}
	}
	
	return NULL;
}


#pragma mark PhysicContext - Contact Listener
void PhysicContext::BeginContact(b2Contact* contact){
	
}

void PhysicContext::EndContact(b2Contact* contact){
	
}

void PhysicContext::PreSolve(b2Contact* contact, const b2Manifold* oldManifold){
	const b2Manifold* manifold = contact->GetManifold();
	
	if (manifold->pointCount == 0)
	{
		return;
	}
	
	b2WorldManifold worldManifold;
	contact->GetWorldManifold(&worldManifold);
	b2PointState state1[2], state2[2];
	b2GetPointStates(state1, state2, oldManifold, contact->GetManifold());
	//NSLog(@"PreSolve: %d - %d",state2[0],b2_addState);
	if (state2[0] == b2_addState)
	{
		const b2Body* bodyA = contact->GetFixtureA()->GetBody();
		const b2Body* bodyB = contact->GetFixtureB()->GetBody();
		
		//No model attached -> return
		if (contact->GetFixtureA()->GetUserData() == NULL && bodyA->GetUserData() == NULL) {
			return;
		}
		
		if (contact->GetFixtureB()->GetUserData() == NULL && bodyB->GetUserData() == NULL) {
			return;
		}
		
		PhysicUserData *uA = (PhysicUserData *) (contact->GetFixtureA()->GetUserData() != NULL ? contact->GetFixtureA()->GetUserData() : bodyA->GetUserData());
		PhysicUserData *uB = (PhysicUserData *) (contact->GetFixtureB()->GetUserData() != NULL ? contact->GetFixtureB()->GetUserData() : bodyB->GetUserData());
		
		b2Vec2 point = worldManifold.points[0];
		b2Vec2 vA = bodyA->GetLinearVelocityFromWorldPoint(point);
		b2Vec2 vB = bodyB->GetLinearVelocityFromWorldPoint(point);
		float32 approachVelocity = b2Dot(vB - vA, worldManifold.normal);
		
		if (fabs(approachVelocity) > kVelocityThresold)
		{			
			CollisionInfo *info = contactBuffer + contactCount;
			info->uA = uA;
			info->uB = uB;
			info->fA = contact->GetFixtureA();
			info->fB = contact->GetFixtureB();
			info->velocity = approachVelocity;
			info->normal = manifold->localNormal;
			contactCount ++;
			if (contactCount >= kMaxContactBuffer) {
				NSLog(@"PhysicContext::PreSolve() - Contact buffer limit exceeds");
				return;
			}
		}
		
	}
}

void PhysicContext::PostSolve(const b2Contact* contact, const b2ContactImpulse* impulse){
	
}

#pragma mark BOMB
b2Body *PhysicContext::createBomb(b2Vec2 pos){
	b2BodyDef def;
	def.bullet = true;
	def.type = b2_dynamicBody;
	def.position = pos;
	b2Body *body = world->CreateBody(&def);
	
	b2CircleShape circle;
	circle.m_radius = 9 / 32.;
	body->CreateFixture(&circle, 1.);
	
	return body;
}

float PhysicContext::getTotalVelocity(){
	float v = 0.0;
	for (b2Body *b = world->GetBodyList(); b ;b = b->GetNext()) {
		if (b->GetType() == b2_dynamicBody && !b->IsFixedRotation()) {
			
			v += b->GetLinearVelocity().Length();
		}
	}
	
	return v;
}

b2Body *PhysicContext::staticBody(){
	if (_staticBody != NULL) {
		return _staticBody;
	}
	
	for (b2Body *b = world->GetBodyList(); b ;b = b->GetNext()) {
		if (b->GetType() == b2_staticBody) {
			_staticBody = b;
			break;
		}
	}
	
	if (_staticBody != NULL) {
		return _staticBody;
	}
	
	b2BodyDef def;
	def.type = b2_staticBody;
	def.position.Set(0,0);
	_staticBody = createBody(&def);
	b2CircleShape shape;
	shape.m_p = b2Vec2(-1,-1);
	shape.m_radius = .5;
	_staticBody->CreateFixture(&shape, .5);
	return _staticBody;
}

#pragma mark DestructionListener
void DestructionListener::SayGoodbye(b2Fixture* fixture){

}

void DestructionListener::SayGoodbye(b2Joint* joint){

}

#pragma mark QueryCallback
bool QueryCallback::ReportFixture(b2Fixture* fixture)
{
	b2Body* body = fixture->GetBody();
	if (body->GetType() == b2_dynamicBody)
	{
		bool inside = fixture->TestPoint(m_point);
		if (inside)
		{
			m_fixture = fixture;
			// We are done, terminate the query.
			return false;
		}
	}
	
	return true;
}

#pragma mark New World
/*
void b2CcWorld::DestroyBody(b2Body* body){
	
	if (body->GetUserData() != NULL) {
		PhysicUserData *data = (PhysicUserData *) body->GetUserData();
		[data.component unregisterPhysic:data.key];
	}
	b2Fixture *fix = body->GetFixtureList();
	for (; fix; fix = fix->GetNext()) {
		if (fix->GetUserData() != NULL) {
			PhysicUserData *data = (PhysicUserData *) fix->GetUserData();
			[data.component unregisterPhysic:data.key];
		}
	}
	 
	
	b2World::DestroyBody(body);
}
*/


void b2CcWorld::DestroyJoint(b2Joint* joint){
	PhysicUserData *data = (PhysicUserData *) joint->GetUserData();
	if (data) {
		if ([data.component respondsToSelector:@selector(attachedPhysicEntityDestroyed:)]) {
			[data.component attachedPhysicEntityDestroyed:data]; 
		}
	}
	b2World::DestroyJoint(joint);
}



void b2CcWorld::Merge(b2Body *parent, b2Body *child){
	
}

void b2CcWorld::Merge(b2Body *parent, b2Fixture *fixture){

}

#endif