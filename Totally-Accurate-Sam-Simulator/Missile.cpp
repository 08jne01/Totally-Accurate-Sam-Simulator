#include "Missile.h"

Missile::Missile() : position(10.0, 10.0, 10.0), velocity(12.0, 1000.0, 0.0), gravity(0.0, -9.81, 0.0), mass(3.0), timeStp(0.0166), direction(0.0, 1.0, 0.0), acceleration(0.0)
{

}

void Missile::update()
{

	velocity += 0.5f*timeStp*acceleration;
	acceleration = gravity + (forceDrag() + forceThrust())/(float)mass;
	//acceleration += navigation( LOS );
	velocity += 0.5f*timeStp*acceleration;
	position += timeStp * velocity + 0.5f*timeStp*timeStp*acceleration;



	//acceleration = gravity + forceDrag() / (float)mass;
	//velocity += acceleration * timeStp;
	//position += velocity * timeStp;



	if (position.y < 5.)

	{
		position.y = 5.0001;

		//if (velocity.y < 0.0001) velocity.y = 0.0;
		velocity.y = -velocity.y;
	}
}

glm::vec3 Missile::getPosition()

{
	return position;
}

glm::vec3 Missile::getDirection()
{
	return glm::normalize(velocity);
}

glm::vec3 Missile::forceThrust()
{
	constexpr float staticForce{ 50.0 };
	
	return staticForce * getDirection();
}

glm::vec3 Missile::forceDrag()
{
	double v{ glm::length(velocity) };
	//glm::vec3 normDir{ glm::normalize(direction) };
	glm::vec3 normVel = glm::normalize(velocity);
	double v2{ pow(v, 2) };
	constexpr double A{ 1 };
	constexpr double d{ 0.002 };
	double Fd = 0.0;
	//Fd = v2 * (glm::length(glm::cross(normDir, normVel)))*d + v2 * A*d;
	Fd = v2 * A*d;
	std::cout << v << std::endl;

	return -(float)Fd * normVel;
}

glm::vec3 Missile::navigation(glm::vec3 LOS)
{
	constexpr int N{ 3 };
	constexpr float Cc{ 9.81 };
	glm::vec3 losOld;
	glm::vec3 losNew{ glm::normalize(LOS) };
	glm::vec3 normVel{ glm::normalize(velocity) };
	float losAngle{ (std::acos(glm::dot(losNew, normVel) - glm::dot(losOld, normVel))) / timeStp };
	glm::vec3 latax{};
	glm::mat3 R{};
	glm::vec3 normN{ glm::cross(normVel, losNew) };
	R[0] = glm::vec3(pow(normN[0], 2), normN[0]*normN[1]-normN[2], normN[0]*normN[2]+normN[1]);
	R[1] = glm::vec3(normN[1] * normN[0] + normN[2], pow(normN[1], 2), normN[1] * normN[2] - normN[2]);
	R[2] = glm::vec3(normN[2] * normN[0] - normN[1], normN[2] * normN[1] + normN[0], pow(normN[2], 2));

	latax = R * normVel*(N * Cc * losAngle);

	return latax;
}