import std.stdio;

import derelict.sdl2.sdl;
import derelict.opengl3.gl;

// Storage for our window
SDL_Window* window;
// Rendering context
SDL_GLContext context;
// Window width and heightk
int width  = 720,
    height = 720;


// Internal buffer of triangles to be rendered on the next rendering pass
GLfloat[] tri_buffer;
// Internal buffer of colors corresponding to triangles in tri_buffer
GLfloat[] color_buffer;

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

    glEnable (GL_BLEND);
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    return true;
}

void destroy() {
    SDL_GL_DeleteContext(context);
    SDL_DestroyWindow(window);
    SDL_Quit();
}


void render() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


    // Render all triangles
    glBegin(GL_TRIANGLES);
    for (int i = 0, c = 0; i < tri_buffer.length; i+=6, c+=12) {
        glColor4f(color_buffer[c  ], color_buffer[c+1], color_buffer[c+2 ], color_buffer[c+3 ]);
        glVertex2f(tri_buffer[i  ], tri_buffer[i+1]);
        glColor4f(color_buffer[c+4], color_buffer[c+5], color_buffer[c+6 ], color_buffer[c+7 ]);
        glVertex2f(tri_buffer[i+2], tri_buffer[i+3]);
        glColor4f(color_buffer[c+8], color_buffer[c+9], color_buffer[c+10], color_buffer[c+11]);
        glVertex2f(tri_buffer[i+4], tri_buffer[i+5]);
    }
    glEnd();
    
    tri_buffer.length = 0; // clear tri_buffer
    color_buffer.length = 0; // clear color_buffer

    SDL_GL_SwapWindow(window);
}

// Push a triangle, specifying a color at every vertex
void push_tri(GLfloat[6] indecies, GLfloat[12] color) {
    foreach (index; indecies) {
        tri_buffer ~= index;
    }
    foreach (component; color) {
        color_buffer ~= component;
    }
}

// Push a triangle with the given color.
// Color defaults to [1, 1, 1], or white
void push_tri(GLfloat[6] indecies, GLfloat[4] color=[1,1,1,1]) {
    foreach (index; indecies) {
        tri_buffer ~= index;
    }
    foreach (i; 0..3) {
        foreach (component; color) {
            color_buffer ~= component;
        }
    }
}

// Push a rectangle
void push_rect(GLfloat[2] top_left, GLfloat[2] bottom_right, GLfloat[4] color=[1,1,1,1]) {
    push_tri([top_left[0], top_left[1],
              top_left[0], bottom_right[1],
              bottom_right[0], top_left[1]], color);
    push_tri([bottom_right[0], bottom_right[1],
              bottom_right[0], top_left[1],
              top_left[0], bottom_right[1]], color);
}

// Push some approximation of a circle
void push_circle(GLfloat[2] center, GLfloat radius, GLfloat[4] color=[1,1,1,1]) {
    import std.math;
    import std.conv;
    auto resolution = 32;
    foreach (i; 0 .. resolution) {
        auto theta       = ((i+.5  ) * 2 * PI) / resolution;
        auto theta_prime = ((i+.5+1) * 2 * PI) / resolution;
        GLfloat[6] tri = [
            center[0], center[1],
            center[0] + cos(theta      ).to!float*radius,
            center[1] + sin(theta      ).to!float*radius,
            center[0] + cos(theta_prime).to!float*radius,
            center[1] + sin(theta_prime).to!float*radius
            ];
        push_tri(tri, color);
    }
}
