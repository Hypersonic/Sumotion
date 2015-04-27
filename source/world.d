import player;

class World {
    Player p1 = new Player;
    Player p2 = new Player;

    auto arena_rad = .9;

    bool outOfBounds(Player guy) {
        return (arena_rad - guy.r) * (arena_rad - guy.r) < (guy.x*guy.x + guy.y*guy.y);
    }

    void step() {
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
    }
}
