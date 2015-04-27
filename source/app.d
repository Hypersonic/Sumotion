import std.stdio;

import derelict.sdl2.sdl;
import derelict.opengl3.gl;

import player;

import gl_utils;

auto arena_rad = .9;

bool outOfBounds(Player guy) {
    return (arena_rad - guy.r) * (arena_rad - guy.r) < (guy.x*guy.x + guy.y*guy.y);
}

void main() {
    init();
    bool running = true;
    auto t = 0;

    Player guy = new Player;
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
            guy.ctrl_vy += .01;
        }
        if (guy.down) {
            guy.ctrl_vy -= .01;
        }
        if (guy.right) {
            guy.ctrl_vx += .01;
        }
        if (guy.left) {
            guy.ctrl_vx -= .01;
        }

        import std.math;

        auto len_sq = guy.ctrl_vx*guy.ctrl_vx + guy.ctrl_vy*guy.ctrl_vy; 
        // Normalize!
        if (len_sq > guy.max_speed*guy.max_speed) {
            guy.ctrl_vx *= guy.max_speed / sqrt(len_sq);
            guy.ctrl_vy *= guy.max_speed / sqrt(len_sq);
        }

        // Move, checking collisions and reseting velocity if needed
        guy.x += (guy.env_vx + guy.ctrl_vx);
        if (guy.outOfBounds()) {
            guy.x -= (guy.env_vx + guy.ctrl_vx);
            guy.ctrl_vx = 0;
        }
        guy.y += (guy.env_vy + guy.ctrl_vy);
        if (guy.outOfBounds()) {
            guy.y -= (guy.env_vy + guy.ctrl_vy);
            guy.ctrl_vy = 0;
        }

        // Apply friction
        guy.ctrl_vx *= guy.friction;
        guy.ctrl_vy *= guy.friction;
        
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
