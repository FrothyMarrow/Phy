#include "vector.h"

#include <math.h>
#include <stdio.h>

void vec3_add(Vector3f a, Vector3f b, Vector3f dest) {
  dest[0] = a[0] + b[0];
  dest[1] = a[1] + b[1];
  dest[2] = a[2] + b[2];
}

void vec3_sub(Vector3f a, Vector3f b, Vector3f dest) {
  dest[0] = a[0] - b[0];
  dest[1] = a[1] - b[1];
  dest[2] = a[2] - b[2];
}

void vec3_cross(Vector3f a, Vector3f b, Vector3f dest) {
  dest[0] = a[1] * b[2] - a[2] * b[1];
  dest[1] = a[2] * b[0] - a[0] * b[2];
  dest[2] = a[0] * b[1] - a[1] * b[0];
}

float vec3_dot(Vector3f a, Vector3f b) {
  return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
}

void vec3_normalize(Vector3f a) {
  float length = sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]);
  a[0] /= length;
  a[1] /= length;
  a[2] /= length;
}