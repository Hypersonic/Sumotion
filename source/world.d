import player;

class World {
    Player p1 = new Player;
    Player p2 = new Player;

    auto arena_rad = .9;

    const auto G = .0001; // Gravitational constant

    bool outOfBounds(Player guy) {
        return (arena_rad - guy.r) * (arena_rad - guy.r) < (guy.x*guy.x + guy.y*guy.y);
    }

    this() {
        p1.x -= .1;
        p2.x += .1;
    }

    void step() {
        import std.math;
        // Apply gravity to players
        {
            auto dx = p2.x - p1.x;
            auto dy = p2.y - p1.y;
            auto Fg = G * (p1.mass * p2.mass) / sqrt(dx*dx+dy*dy);

            auto theta = atan2(dy, dx);

            p1.env_vx += Fg/p1.mass * cos(theta);
            p1.env_vy += Fg/p1.mass * sin(theta);

            p2.env_vx -= Fg/p2.mass * cos(theta);
            p2.env_vy -= Fg/p2.mass * sin(theta);
        }
        // Step both players
        foreach (player; [p1, p2]) {
            if (player.up) {
                player.ctrl_vy += .01;
            }
            if (player.down) {
                player.ctrl_vy -= .01;
            }
            if (player.right) {
                player.ctrl_vx += .01;
            }
            if (player.left) {
                player.ctrl_vx -= .01;
            }

            import std.math;

            auto len_sq = player.ctrl_vx*player.ctrl_vx + player.ctrl_vy*player.ctrl_vy; 
            // Normalize!
            if (len_sq > player.max_speed*player.max_speed) {
                player.ctrl_vx *= player.max_speed / sqrt(len_sq);
                player.ctrl_vy *= player.max_speed / sqrt(len_sq);
            }

            // Move, checking collisions and reseting velocity if needed
            player.x += (player.env_vx + player.ctrl_vx);
            if (outOfBounds(player)) {
                player.x -= (player.env_vx + player.ctrl_vx);
                player.ctrl_vx = 0;
            }
            player.y += (player.env_vy + player.ctrl_vy);
            if (outOfBounds(player)) {
                player.y -= (player.env_vy + player.ctrl_vy);
                player.ctrl_vy = 0;
            }

            // Apply friction
            player.ctrl_vx *= player.friction;
            player.ctrl_vy *= player.friction;
            player.env_vx *= player.friction*1.1;
            player.env_vy *= player.friction*1.1;
        }


        // Collision detect between players
        auto dx = p2.x - p1.x;
        auto dy = p2.y - p1.y;
        auto dist_sq = dx*dx + dy*dy;
        if (dist_sq < (p1.r + p2.r)*(p1.r + p2.r)) {
            auto angle = atan2(dy, dx);
            p1.env_vx -= cos(angle) * .01;
            p1.env_vy -= sin(angle) * .01;
            p2.env_vx += cos(angle) * .01;
            p2.env_vy += sin(angle) * .01;
        }
    }
}
