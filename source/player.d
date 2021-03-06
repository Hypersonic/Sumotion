class Player {
    float x = 0, y = 0, r = .03, // x, y, radius
          env_vx = 0, env_vy = 0, // Environment controlled velocity
          ctrl_vx = 0, ctrl_vy = 0, // Player controlled velocity
          max_speed = .01, // Max control velocity
          friction = .9, // Friction to apply
          mass = .2, // Effective mass, changed by player input
          recent_presses = 0, mass_coefficient = 0;
    bool up, down, left, right, crash_circle; // Buttons pressed for directions
}
