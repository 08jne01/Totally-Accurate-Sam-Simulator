#pragma once
#include <glm/ext.hpp>
#include <iostream>

class Projectile
{
	public:
		Projectile();
		glm::vec3 getPosition();
		glm::vec3 getDirection();
		void update();
		
	private:
		glm::vec3 position, direction, velocity, acceleration, gravity, forceDrag();
		double mass;
		float timeStp;
};