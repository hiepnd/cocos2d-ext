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