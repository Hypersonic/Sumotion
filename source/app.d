import std.stdio;

import derelict.sdl2.sdl;
import derelict.opengl3.gl;

import world;
import player;

import gl_utils;

void main() {
    init();
    bool running = true;
    auto t = 0;

    World world = new World;
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
                            world.p1.up = true;
                            break;
                        case SDLK_s:
                            world.p1.down = true;
                            break;
                        case SDLK_d:
                            world.p1.right = true;
                            break;
                        case SDLK_a:
                            world.p1.left = true;
                            break;
                        case SDLK_UP:
                            world.p2.up = true;
                            break;
                        case SDLK_DOWN:
                            world.p2.down = true;
                            break;
                        case SDLK_LEFT:
                            world.p2.left = true;
                            break;
                        case SDLK_RIGHT:
                            world.p2.right = true;
                            break;
                        default:
                            break;
                    }
                    break;
                case SDL_KEYUP:
                    switch (e.key.keysym.sym) {
                        case SDLK_w:
                            world.p1.up = false;
                            break;
                        case SDLK_s:
                            world.p1.down = false;
                            break;
                        case SDLK_d:
                            world.p1.right = false;
                            break;
                        case SDLK_a:
                            world.p1.left = false;
                            break;
                        case SDLK_UP:
                            world.p2.up = false;
                            break;
                        case SDLK_DOWN:
                            world.p2.down = false;
                            break;
                        case SDLK_LEFT:
                            world.p2.left = false;
                            break;
                        case SDLK_RIGHT:
                            world.p2.right = false;
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

        world.step();
        
        // Wipe the screen with a rectangle
        push_rect([-1,-1],[1,1]);

        // Render ring for the edge of the field
        push_circle([0,0], world.arena_rad+.01, [1,1,1]);
        push_circle([0,0], world.arena_rad    , [0,0,0]);
        push_circle([0,0], world.arena_rad-.01, [1,1,1]);

        // Render the players
        GLfloat[3] blue_team_color = [0, .4, 1];
        GLfloat[3] red_team_color  = [.8, .1, 0];
        push_circle([world.p1.x, world.p1.y], world.p1.r, blue_team_color);
        push_circle([world.p2.x, world.p2.y], world.p2.r,  red_team_color);

        t++;
        render();

    }
    destroy();
}
