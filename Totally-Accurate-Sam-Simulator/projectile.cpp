#include <glm/ext.hpp>
#include "projectile.h"

Projectile::Projectile() : position(0.0), velocity(0.0), gravity(0.0, 9.81, 0.0), mass(3.0), timeStp(60.0)
{
	
}

void Projectile::update()
{
	(gravity + forceDrag()) / (float)mass;
	acceleration*timeStp;
}

glm::vec3 Projectile::getDirection()
{
	return glm::normalize(velocity);
}


glm::vec3 Projectile::forceDrag()
{
	double v{ glm::length(velocity) };
	glm::vec3 normDir{ glm::normalize(direction) };
	glm::vec3 normVel{ glm::normalize(velocity) };
	double v2{ glm::pow(v, 2) };
	constexpr double A{ 0.5 };
	constexpr double d{ 0.8 };
	double Fd{ 0.0 };
	
	Fd = v2 * (glm::length(glm::cross(normDir, normVel)))*d + v2 * A*d;
	return (float)-Fd * normVel;
}