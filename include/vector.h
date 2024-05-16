#pragma once

typedef float Vector3f[3];

void vec3_add(Vector3f a, Vector3f b, Vector3f dest);

void vec3_sub(Vector3f a, Vector3f b, Vector3f dest);

float vec3_dot(Vector3f a, Vector3f b);

void vec3_cross(Vector3f a, Vector3f b, Vector3f dest);

void vec3_normalize(Vector3f a);
