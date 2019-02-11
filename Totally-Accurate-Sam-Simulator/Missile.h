#pragma once
#include <glm/ext.hpp>
#include <iostream>

class Missile
{
public:
	Missile();
	glm::vec3 getPosition();
	glm::vec3 getDirection();
	void update();

private:
	glm::vec3 position, direction, velocity, acceleration, gravity, forceDrag(), forceThrust(), accleration, navigation(glm::vec3 LOS);
	double mass;
	float timeStp;
};