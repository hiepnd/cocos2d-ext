/*
 *  constant+macro.h
 *  ___PROJECTNAME___
 *
 *  Created by Ngo Duc Hiep on 3/10/11.
 *  Copyright 2011 PTT Solution., JSC. All rights reserved.
 *
 */

#define PHYSIC_ENABLED 1

#define PTM_RATIO 32.

#define PTM_POINT(p) b2Vec2((p).x / PTM_RATIO,(p).y / PTM_RATIO)
#define PTM_VALUE(p) (p) / PTM_RATIO

#define MTP_POINT(p) CGPointMake((p).x * PTM_RATIO,(p).y * PTM_RATIO)
#define MTP_VALUE(v) (v) * PTM_RATIO 

#define UIToGL(pos) [[CCDirector sharedDirector] convertToGL:pos]
#define GLToUI(pos) [[CCDirector sharedDirector] convertToUI:pos]

#define CC_SAFE_RELESE(object)				\
	[object release];						\
	object = nil;

#if PHYSIC_ENABLED
typedef enum {
	PHYSIC_INVALID,
	PHYSIC_BODY,
	PHYSIC_FIXTURE,
	PHYSIC_JOINT,
} PhysicEntityType;

typedef struct PhysicEntity{
	PhysicEntity(){
		type = PHYSIC_INVALID;
		entity = NULL;
	}
	
	PhysicEntity(void *entity, PhysicEntityType type){
		this->entity = entity;
		this->type = type;
	}
	
	PhysicEntity(PhysicEntityType type, void *entity){
		this->entity = entity;
		this->type = type;
	}
	
	void *entity;
	PhysicEntityType type;
} PhysicEntity;

#endif