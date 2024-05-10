#define GL_SILENCE_DEPRECATION
#define GLFW_INCLUDE_GLCOREARB

#include <GLFW/glfw3.h>

#include <stdio.h>
#include <stdlib.h>

void glfwErrorCallback(int errorCode, const char *description);

unsigned int createShader(const char *filename, GLenum shaderType);

unsigned int createShaderProgram(unsigned int vertexShader,
                                 unsigned int fragmentShader);

int main(void) {
  glfwInit();

  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
  glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

  glfwSetErrorCallback(glfwErrorCallback);

  GLFWwindow *window = glfwCreateWindow(800, 600, "Phy", NULL, NULL);

  glfwMakeContextCurrent(window);

  if (window == NULL) {
    printf("Failed to create GLFW window!\n");
    exit(1);
  }

  const float vertices[] = {
      0.0f, 0.5f, 0.0f, -0.5f, -0.5f, -0.0f, 0.5f, -0.5f, 0.0f,
  };

  unsigned int vertexBuffer = 0;
  glGenBuffers(1, &vertexBuffer);

  unsigned int vertexArray = 0;
  glGenVertexArrays(1, &vertexArray);
  glBindVertexArray(vertexArray);

  glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *)0);
  glEnableVertexAttribArray(0);

  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindVertexArray(0);

  unsigned int vertexShader =
      createShader("../shader/vertex.glsl", GL_VERTEX_SHADER);
  unsigned int fragmentShader =
      createShader("../shader/fragment.glsl", GL_FRAGMENT_SHADER);

  unsigned int shaderProgram =
      createShaderProgram(vertexShader, fragmentShader);

  glUseProgram(shaderProgram);
  glBindVertexArray(vertexArray);

  while (!glfwWindowShouldClose(window)) {
    glfwPollEvents();

    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(0.1f, 0.1f, 0.1f, 1.0f);

    glDrawArrays(GL_TRIANGLES, 0, 3);

    glfwSwapBuffers(window);
  }

  return 0;
}

void glfwErrorCallback(int errorCode, const char *description) {
  printf("GLFW Error: %d, %s\n", errorCode, description);
}

unsigned int createShader(const char *filename, GLenum shaderType) {
  FILE *file = fopen(filename, "r");

  if (!file) {
    printf("Failed to open file: %s", filename);
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
    printf("Fragment shader compilation failed\n");
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
