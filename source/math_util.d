import std.math;

real sigmoid(real x) {
    return 1 / (1 + exp(-x));
}
