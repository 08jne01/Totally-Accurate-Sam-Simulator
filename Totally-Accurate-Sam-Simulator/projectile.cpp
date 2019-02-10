#include "projectile.h"

Projectile::Projectile() : position(0.0, 0.0, 0.0), velocity(1.0, 100.0, 0.0), gravity(0.0, -100, 0.0), mass(3.0), timeStp(0.01), direction(0.0, 1.0, 0.0)
{
	
}

void Projectile::update()
{
	acceleration = gravity + forceDrag() / (float)mass;
	velocity += acceleration * timeStp;
	position += velocity * timeStp;

	if (position.y < 0.0)

	{
		position.y = 0.1;
		velocity.y = -velocity.y;
	}
}

glm::vec3 Projectile::getPosition()

{
	return position;
}

glm::vec3 Projectile::getDirection()
{
	return glm::normalize(velocity);
}


glm::vec3 Projectile::forceDrag()
{
	double v{ glm::length(velocity) };
	//glm::vec3 normDir{ glm::normalize(direction) };
	glm::vec3 normVel = glm::normalize(velocity);
	double v2{ pow(v, 2) };
	constexpr double A{ 1 };
	constexpr double d{ 0.001 };
	double Fd = 0.0;
	//Fd = v2 * (glm::length(glm::cross(normDir, normVel)))*d + v2 * A*d;
	Fd = v2 * A*d;
	std::cout << v << std::endl;

	if (v < 0.0001)

	{
		return glm::vec3(0.0);
	}

	else

	{
		return -(float)Fd * normVel;
	}
}