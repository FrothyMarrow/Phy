#define GL_SILENCE_DEPRECATION
#define GLFW_INCLUDE_GLCOREARB

#include "vector.h"

#include <GLFW/glfw3.h>

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define DEG_TO_RAD M_PI / 180

#define WIDTH 800
#define HEIGHT 600

void glfwErrorCallback(int errorCode, const char *description);

void glfwKeyCallback(GLFWwindow *window, int key, int scancode, int action,
                     int mods);

unsigned int createShader(const char *filename, GLenum shaderType);

unsigned int createShaderProgram(unsigned int vertexShader,
                                 unsigned int fragmentShader);

void createProjection(float fovy, float aspectRatio, float front, float back,
                      float *dest);

void lookAt(Vector3f from, Vector3f to, Vector3f up, float *dest);

int main(void) {
  if (!glfwInit()) {
    printf("Failed to intialize GLFW!\n");
    return 1;
  }

  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
  glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

  glfwSetErrorCallback(glfwErrorCallback);

  GLFWwindow *window = glfwCreateWindow(WIDTH, HEIGHT, "Phy", NULL, NULL);

  glfwMakeContextCurrent(window);

  glfwSetKeyCallback(window, glfwKeyCallback);

  if (!window) {
    printf("Failed to create GLFW window!\n");
    glfwTerminate();
    return 1;
  }

  float vertices[] = {
      // clang-format off
      -0.5f, -0.5f, -0.5f,
      0.5f, -0.5f, -0.5f,
      0.5f,  0.5f, -0.5f,
      -0.5f,  0.5f, -0.5f,
      -0.5f, -0.5f,  0.5f,
      0.5f, -0.5f,  0.5f,
      0.5f,  0.5f,  0.5f,
      -0.5f,  0.5f,  0.5f,
 
      -0.5f,  0.5f, -0.5f,
      -0.5f, -0.5f, -0.5f,
      -0.5f, -0.5f,  0.5f,
      -0.5f,  0.5f,  0.5f,
      0.5f, -0.5f, -0.5f,
      0.5f,  0.5f, -0.5f,
      0.5f,  0.5f,  0.5f,
      0.5f, -0.5f,  0.5f,
 
      -0.5f, -0.5f, -0.5f,
      0.5f, -0.5f, -0.5f,
      0.5f, -0.5f,  0.5f,
      -0.5f, -0.5f,  0.5f,
      0.5f,  0.5f, -0.5f,
      -0.5f,  0.5f, -0.5f,
      -0.5f,  0.5f,  0.5f,
      0.5f,  0.5f,  0.5f,
      // clang-format on
  };

  unsigned int indices[] = {
      // clang-format off
      0, 3, 2,
      2, 1, 0,
      4, 5, 6,
      6, 7 ,4,

      11, 8, 9,
      9, 10, 11,
      12, 13, 14,
      14, 15, 12,

      16, 17, 18,
      18, 19, 16,
      20, 21, 22,
      22, 23, 20
      // clang-format on
  };

  unsigned int vertexArray = 0;
  glGenVertexArrays(1, &vertexArray);

  glBindVertexArray(vertexArray);

  unsigned int vertexBuffer = 0;
  glGenBuffers(1, &vertexBuffer);

  glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *)0);
  glEnableVertexAttribArray(0);

  unsigned int elementBuffer = 0;
  glGenBuffers(1, &elementBuffer);

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementBuffer);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices,
               GL_STATIC_DRAW);

  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindVertexArray(0);

  unsigned int vertexShader =
      createShader("./shader/vertex.glsl", GL_VERTEX_SHADER);
  unsigned int fragmentShader =
      createShader("./shader/fragment.glsl", GL_FRAGMENT_SHADER);

  unsigned int shaderProgram =
      createShaderProgram(vertexShader, fragmentShader);

  glUseProgram(shaderProgram);
  glBindVertexArray(vertexArray);

  glEnable(GL_DEPTH_TEST);

  Vector3f from = {0, 0, 1};

  glfwSetWindowUserPointer(window, from);

  while (!glfwWindowShouldClose(window)) {
    glfwPollEvents();

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearColor(1.0f, 0.0f, 0.0f, 1.0f);

    int uProjection = glGetUniformLocation(shaderProgram, "uProjection");

    float projection[16] = {0};
    createProjection(90, (float)WIDTH / HEIGHT, 0.1f, 10.0f, projection);

    glUniformMatrix4fv(uProjection, 1, GL_FALSE, projection);

    int uView = glGetUniformLocation(shaderProgram, "uView");

    float view[16] = {0};
    Vector3f to = {from[0], from[1], from[2] - 1};
    Vector3f up = {0.0f, 1.0f, 0.0f};
    lookAt(from, to, up, view);

    glUniformMatrix4fv(uView, 1, GL_FALSE, view);

    glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_INT, 0);

    glfwSwapBuffers(window);
  }

  glDeleteBuffers(1, &vertexBuffer);
  glDeleteVertexArrays(1, &vertexArray);
  glDeleteShader(vertexShader);
  glDeleteShader(fragmentShader);
  glDeleteProgram(shaderProgram);

  glfwDestroyWindow(window);
  glfwTerminate();

  return 0;
}

void glfwErrorCallback(int errorCode, const char *description) {
  printf("GLFW Error: %d, %s\n", errorCode, description);
}

void glfwKeyCallback(GLFWwindow *window, int key, int scancode, int action,
                     int mods) {

  if (action != GLFW_PRESS && action != GLFW_REPEAT)
    return;

  Vector3f *from = (Vector3f *)glfwGetWindowUserPointer(window);
  float delta = 0.1f;

  switch (key) {
  case GLFW_KEY_UP:
    from[0][1] += delta;
    break;
  case GLFW_KEY_DOWN:
    from[0][1] += -delta;
    break;
  case GLFW_KEY_RIGHT:
    from[0][0] += delta;
    break;
  case GLFW_KEY_LEFT:
    from[0][0] += -delta;
    break;
  case GLFW_KEY_SPACE:
    from[0][2] += delta;
    break;
  case GLFW_KEY_LEFT_CONTROL:
    from[0][2] += -delta;
    break;
  }
}

unsigned int createShader(const char *filename, GLenum shaderType) {
  FILE *file = fopen(filename, "r");

  if (!file) {
    printf("Failed to open file: %s\n", filename);
    return 0;
  }

  fseek(file, 0, SEEK_END);
  long filesize = ftell(file);
  fseek(file, 0, SEEK_SET);

  char *shaderSource = malloc(filesize + 1);
  fread(shaderSource, filesize, 1, file);

  shaderSource[filesize] = '\0';

  fclose(file);

  unsigned int shader = 0;
  shader = glCreateShader(shaderType);

  glShaderSource(shader, 1, (const char **)&shaderSource, NULL);
  glCompileShader(shader);

  free(shaderSource);

  int shaderCompiled = 0;
  glGetShaderiv(shader, GL_COMPILE_STATUS, &shaderCompiled);

  if (!shaderCompiled) {
    printf("Shader compilation failed\n");
    return 0;
  }

  return shader;
}

unsigned int createShaderProgram(unsigned int vertexShader,
                                 unsigned int fragmentShader) {
  unsigned int shaderProgram;
  shaderProgram = glCreateProgram();

  glAttachShader(shaderProgram, vertexShader);
  glAttachShader(shaderProgram, fragmentShader);
  glLinkProgram(shaderProgram);

  int shaderProgramLinked = 0;
  glGetProgramiv(shaderProgram, GL_LINK_STATUS, &shaderProgramLinked);

  if (!shaderProgramLinked) {
    printf("Shader program linking failed");
    return 0;
  }

  return shaderProgram;
}

void createProjection(float fovy, float aspectRatio, float front, float back,
                      float *dest) {
  float tangent = tan(fovy / 2 * DEG_TO_RAD);
  float top = front * tangent;
  float right = top * aspectRatio;

  dest[0] = front / right;
  dest[5] = front / top;
  dest[10] = -(back + front) / (back - front);
  dest[11] = -1;
  dest[14] = -(2 * back * front) / (back - front);
  dest[15] = 0;
}

void lookAt(Vector3f from, Vector3f to, Vector3f up, float *dest) {
  Vector3f forward = {0};
  vec3_sub(from, to, forward);
  vec3_normalize(forward);

  Vector3f left = {0};
  vec3_cross(up, forward, left);
  vec3_normalize(left);

  Vector3f actualUp = {0};
  vec3_cross(forward, left, actualUp);
  dest[0] = left[0];
  dest[4] = left[1];
  dest[8] = left[2];
  dest[1] = up[0];
  dest[5] = up[1];
  dest[9] = up[2];
  dest[2] = forward[0];
  dest[6] = forward[1];
  dest[10] = forward[2];

  dest[12] = -vec3_dot(left, from);
  dest[13] = -vec3_dot(actualUp, from);
  dest[14] = -vec3_dot(forward, from);
  dest[15] = 1;
}
