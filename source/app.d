import std.stdio;

import derelict.sdl2.sdl;

import gl_utils;

void main() {
    init();
    bool running = true;
    auto t = 0;
    float x = 0;
    float y = 0;
    while (running) {

        // Handle input
        SDL_Event e;
        while (SDL_PollEvent(&e)) {
            switch (e.type) {
                case SDL_KEYDOWN:
                    switch (e.key.keysym.sym) {
                        case SDLK_q:
                            running = false;
                            break;
                        default:
                            break;
                    }
                    break;
                case SDL_QUIT:
                    running = false;
                    break;
                default:
                    break;
            }
        }

        import std.math;
        push_tri([-1,-1,-.5,-.5,0,-1],[0,1,0]);
        
        push_rect([-1,-1],[1,1]);

        // Render ring for the edge of the field
        push_circle([0,0], .91, [1,1,1]);
        push_circle([0,0], .90, [0,0,0]);
        push_circle([0,0], .89, [1,1,1]);

        push_circle([.25*sin(t/10.0),0], .125, [0,0,0]);
        push_circle([0,.25*cos(t/10.0)], .125, [0,0,0]);
        t++;
        render();

    }
    destroy();
}
