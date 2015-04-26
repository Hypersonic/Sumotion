import std.stdio;

import derelict.sdl2.sdl;
import derelict.opengl3.gl;

// Storage for our window
SDL_Window* window;
// Rendering context
SDL_GLContext context;
// Window width and heightk
int width = 640,
    height = 480;


// Internal buffer of triangles to be rendered on the next rendering pass
GLfloat[] tri_buffer;

/*
 * Initialize graphics stuff, like a window to draw on and such
 * Returns true when succesful, false if there was an error.
 */
bool init() {
    // Load Derelict
    DerelictSDL2.load();
    DerelictGL.load();

    // Init SDL
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        writeln("Error Initializing SDL: ", SDL_GetError());
        return false;
    }

    // Enable double buffering
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1); 

    // Create our window, store it in our window variable
    window = SDL_CreateWindow("Sumotion",
            SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
            width, height,
            SDL_WINDOW_OPENGL | SDL_WINDOW_INPUT_FOCUS);

    if (!window) {
        writeln("Couldn't create window: ", SDL_GetError());
        return false;
    }

    // Create our rendering context
    context = SDL_GL_CreateContext(window);
    SDL_GL_SetSwapInterval(1);

    // Clear our screen
    glClearColor(0, 0, 0, 0);
    glViewport(0, 0, width, height);

    return true;
}

void destroy() {
    SDL_GL_DeleteContext(context);
    SDL_DestroyWindow(window);
    SDL_Quit();
}


void render() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


    // TODO: Render all triangles in tri_buffer here
    for (int i = 0; i < tri_buffer.length; i+=6) {
        glBegin(GL_TRIANGLES);
            glVertex3f(tri_buffer[i  ], tri_buffer[i+1], 0);
            glVertex3f(tri_buffer[i+2], tri_buffer[i+3], 0);
            glVertex3f(tri_buffer[i+4], tri_buffer[i+5], 0);
        glEnd();
    }
    
    tri_buffer.length = 0; // clear tri_buffer

    SDL_GL_SwapWindow(window);
}
void push_tri(GLfloat[6] indecies) {
    foreach (index; indecies) {
        tri_buffer ~= index;
    }
}
