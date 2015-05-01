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
                        case SDLK_e:
                            world.p1.crash_circle = true;
                            break;
                        case SDLK_i:
                            world.p2.up = true;
                            break;
                        case SDLK_k:
                            world.p2.down = true;
                            break;
                        case SDLK_j:
                            world.p2.left = true;
                            break;
                        case SDLK_l:
                            world.p2.right = true;
                            break;
                        case SDLK_o:
                            world.p2.crash_circle = true;
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
                        case SDLK_e:
                            world.p1.crash_circle = false;
                            break;
                        case SDLK_r:
                            world.p1.recent_presses++;
                            break;
                        case SDLK_i:
                            world.p2.up = false;
                            break;
                        case SDLK_k:
                            world.p2.down = false;
                            break;
                        case SDLK_h:
                            world.p2.left = false;
                            break;
                        case SDLK_l:
                            world.p2.right = false;
                            break;
                        case SDLK_o:
                            world.p2.crash_circle = false;
                            break;
                        case SDLK_p:
                            world.p2.recent_presses++;
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
        push_circle([0,0], world.arena_rad+.01, [1,1,1,1]);
        push_circle([0,0], world.arena_rad    , [0,0,0,1]);
        push_circle([0,0], world.arena_rad-.01, [1,1,1,1]);

        // Render the players
        GLfloat[4] blue_team_color = [0, .4, 1, 1];
        GLfloat[4] red_team_color  = [.8, .1, 0, 1];
        GLfloat[4] blue_team_aura_color = [0, .2, .6, .5];
        GLfloat[4] red_team_aura_color  = [.4, .05, 0, .5];
        push_circle([world.p1.x, world.p1.y], world.p1.mass, blue_team_aura_color);
        push_circle([world.p2.x, world.p2.y], world.p2.mass,  red_team_aura_color);
        push_circle([world.p1.x, world.p1.y], world.p1.r, blue_team_color);
        push_circle([world.p2.x, world.p2.y], world.p2.r,  red_team_color);



        // Check for losers
        if (world.outOfBounds(world.p2)) {
            writeln("p1 wins");
            running = false;
        } else if (world.outOfBounds(world.p1)) {
            writeln("p2 wins");
            running = false;
        }

        import std.math;
        {
            auto vec_len = 20;
            // Velocity vector, p1
            {
                auto theta = atan2(world.p1.env_vy+world.p1.ctrl_vy,
                        world.p1.env_vx+world.p1.ctrl_vx) + PI/2;
                push_tri([world.p1.x-cos(theta)*.01, world.p1.y-sin(theta)*.01,
                        world.p1.x+cos(theta)*.01, world.p1.y+sin(theta)*.01,
                        world.p1.x+(world.p1.env_vx+world.p1.ctrl_vx)*vec_len,
                        world.p1.y+(world.p1.env_vy+world.p1.ctrl_vy)*vec_len]);
            }
            // Env Velocity vector, p1
            {
                auto theta = atan2(world.p1.env_vy,
                        world.p1.env_vx) + PI/2;
                push_tri([world.p1.x-cos(theta)*.01, world.p1.y-sin(theta)*.01,
                        world.p1.x+cos(theta)*.01, world.p1.y+sin(theta)*.01,
                        world.p1.x+(world.p1.env_vx)*vec_len,
                        world.p1.y+(world.p1.env_vy)*vec_len],[0,1,0,1]);
            }
            // Velocity vector, p2
            {
                auto theta = atan2(world.p2.env_vy+world.p2.ctrl_vy,
                        world.p2.env_vx+world.p2.ctrl_vx) + PI/2;
                push_tri([world.p2.x-cos(theta)*.01, world.p2.y-sin(theta)*.01,
                        world.p2.x+cos(theta)*.01, world.p2.y+sin(theta)*.01,
                        world.p2.x+(world.p2.env_vx+world.p2.ctrl_vx)*vec_len,
                        world.p2.y+(world.p2.env_vy+world.p2.ctrl_vy)*vec_len]);
            }
            // Env Velocity vector, p2
            {
                auto theta = atan2(world.p2.env_vy,
                        world.p2.env_vx) + PI/2;
                push_tri([world.p2.x-cos(theta)*.01, world.p2.y-sin(theta)*.01,
                        world.p2.x+cos(theta)*.01, world.p2.y+sin(theta)*.01,
                        world.p2.x+(world.p2.env_vx)*vec_len,
                        world.p2.y+(world.p2.env_vy)*vec_len], [0,1,0,1]);
            }
        }

        t++;
        render();

    }
    destroy();
}
