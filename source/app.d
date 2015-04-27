import std.stdio;

import derelict.sdl2.sdl;
import derelict.opengl3.gl;

import gl_utils;

struct Guy {
    float x = 0,y = 0, r = .1;
    bool up,down,left,right;
}

auto arena_rad = .9;

bool outOfBounds(Guy guy) {
    return (arena_rad - guy.r) * (arena_rad - guy.r) < (guy.x*guy.x + guy.y*guy.y);
}

void main() {
    init();
    bool running = true;
    auto t = 0;

    Guy guy;
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
                        case SDLK_w:
                            guy.up = true;
                            break;
                        case SDLK_s:
                            guy.down = true;
                            break;
                        case SDLK_d:
                            guy.right = true;
                            break;
                        case SDLK_a:
                            guy.left = true;
                            break;
                        default:
                            break;
                    }
                    break;
                case SDL_KEYUP:
                    switch (e.key.keysym.sym) {
                        case SDLK_w:
                            guy.up = false;
                            break;
                        case SDLK_s:
                            guy.down = false;
                            break;
                        case SDLK_d:
                            guy.right = false;
                            break;
                        case SDLK_a:
                            guy.left = false;
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

        if (guy.up) {
            guy.y += .01;
            if (guy.outOfBounds()) {
                guy.y -= .01;
            }
        }
        if (guy.down) {
            guy.y -= .01;
            if (guy.outOfBounds()) {
                guy.y += .01;
            }
        }
        if (guy.right) {
            guy.x += .01;
            if (guy.outOfBounds()) {
                guy.x -= .01;
            }
        }
        if (guy.left) {
            guy.x -= .01;
            if (guy.outOfBounds()) {
                guy.x += .01;
            }
        }

        import std.math;
        
        push_rect([-1,-1],[1,1]);

        push_tri([-1,-1,-.5,-.5,0,-1],[0,1,0]);

        // Render ring for the edge of the field
        push_circle([0,0], arena_rad+.01, [1,1,1]);
        push_circle([0,0], arena_rad    , [0,0,0]);
        push_circle([0,0], arena_rad-.01, [1,1,1]);


        push_circle([.25*sin(t/10.0),0], .125, [0,0,0]);
        push_circle([0,.25*cos(t/10.0)], .125, [0,0,0]);

        GLfloat[3] blue_team_color = [0, .4, 1];
        GLfloat[3] red_team_color  = [.8, .1, 0];
        push_circle([guy.x, guy.y], guy.r, red_team_color);

        t++;
        render();

    }
    destroy();
}
