#define GL_SILENCE_DEPRECATION
#define GLFW_INCLUDE_GLCOREARB

#include <GLFW/glfw3.h>

#include <stdio.h>
#include <stdlib.h>

void glfwErrorCallback(int errorCode, const char *description);

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

  const char *vertexShaderSource = "#version 330 core\n"
                                   "layout (location = 0) in vec3 aPos;\n"
                                   "void main()\n"
                                   "{\n"
                                   "    gl_Position = vec4(aPos, 1.0);\n"
                                   "}\0";

  unsigned int vertexShader = 0;
  vertexShader = glCreateShader(GL_VERTEX_SHADER);

  glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
  glCompileShader(vertexShader);

  int vertexShaderCompiled = 0;
  glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &vertexShaderCompiled);

  if (!vertexShaderCompiled) {
    printf("Vertex shader compilation failed\n");
  }

  const char *fragmentShaderSource =
      "#version 330 core\n"
      "out vec4 FragColor;\n"
      "void main()\n"
      "{\n"
      "    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n"
      "}\0";

  unsigned int fragmentShader = 0;
  fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);

  glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
  glCompileShader(fragmentShader);

  int fragmentShaderCompiled = 0;
  glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &fragmentShaderCompiled);

  if (!fragmentShaderCompiled) {
    printf("Fragment shader compilation failed\n");
  }

  unsigned int shaderProgram;
  shaderProgram = glCreateProgram();

  glAttachShader(shaderProgram, vertexShader);
  glAttachShader(shaderProgram, fragmentShader);
  glLinkProgram(shaderProgram);

  int shaderProgramLinked = 0;
  glGetProgramiv(shaderProgram, GL_LINK_STATUS, &shaderProgramLinked);

  if (!shaderProgramLinked) {
    printf("Shader program linking failed");
  }

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
