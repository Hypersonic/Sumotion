import player;

class World {
    Player p1 = new Player;
    Player p2 = new Player;

    auto arena_rad = .9;

    const auto G = .00003; // Gravitational constant

    bool outOfBounds(Player guy) {
        return (arena_rad - guy.r) * (arena_rad - guy.r) < (guy.x*guy.x + guy.y*guy.y);
    }

    this() {
        p1.x -= .5;
        p2.x += .5;
    }

    void step() {
        import std.math;
        // Apply gravity to players
        {
            auto dx = p2.x - p1.x;
            auto dy = p2.y - p1.y;
            auto dist = sqrt(dx*dx+dy*dy);
            auto Fg = G * (p1.mass * p2.mass) / dist;

            auto theta = atan2(dy, dx);

            auto p1_range = p2.mass;
            if (p1_range >= dist) {
                p1.env_vx += Fg/p1.mass * cos(theta);
                p1.env_vy += Fg/p1.mass * sin(theta);
            }

            auto p2_range = p1.mass;
            if (p2_range >= dist) {
                p2.env_vx -= Fg/p2.mass * cos(theta);
                p2.env_vy -= Fg/p2.mass * sin(theta);
            }
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
        }


        // Collision detect between players
        auto dx = p2.x - p1.x;
        auto dy = p2.y - p1.y;
        auto dist_sq = dx*dx + dy*dy;
        if (dist_sq < (p1.r + p2.r)*(p1.r + p2.r)) {
            auto angle = atan2(dy, dx);
            // Midpoint x and y
            auto mid_x = (p1.x+p2.x)/2;
            auto mid_y = (p1.y+p2.y)/2;
            // Move them so they're tangent at whatever the angle between them was
            p1.x = mid_x - cos(angle) * p1.r;
            p1.y = mid_y - sin(angle) * p1.r;
            p2.x = mid_x + cos(angle) * p2.r;
            p2.y = mid_y + sin(angle) * p2.r;
        }
    }
}
