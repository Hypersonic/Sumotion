import std.stdio;

import derelict.sdl2.sdl;

import gl_utils;

void main() {
    init();
    bool running = true;
    while (running) {

        // Handle input
        SDL_Event e;
        while (SDL_PollEvent(&e)) {
            switch (e.type) {
                case SDL_KEYDOWN:
                    break;
                case SDL_QUIT:
                    running = false;
                    break;
                default:
                    break;
            }
        }

        render();

    }
    destroy();
}
