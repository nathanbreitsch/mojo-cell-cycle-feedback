from random import seed, rand
from tensor import Tensor
from python import Python
import math


alias N = 5000
alias NUM_CYCLES = 500
alias NUM_ITERS = NUM_CYCLES * N
alias EPSILON = 1e-5


fn sort(inout x: Tensor, n: Int):
    # couldn't get builting sort to work on tensor
    var i: Int = 1
    while i < n:
        var j = i
        while j > 0 and x[j - 1] > x[j]:
            let buff = x[j]
            x[j] = x[j - 1]
            x[j - 1] = buff
            j = j - 1
        i = i + 1


fn run_simulation(inout x: Tensor[DType.float64], r: Float64, s: Float64):
    for _ in range(NUM_ITERS):
        var x_idx0: Float64 = 0
        var idx0: Int = 0
        var x_idxr: Float64 = 0
        var idxr: Int = 0
        var x_idxs: Float64 = 0
        var idxs: Int = 0
        var s_count = 0
        for i in range(N):
            if x[i] < s:
                s_count += 1
                if x[i] > x_idxs:
                    x_idxs = x[i]
                    idxs = i
            elif x[i] < r:
                if x[i] > x_idxr:
                    x_idxr = x[i]
                    idxr = i
            else:
                if x[i] > x_idx0:
                    x_idx0 = x[i]
                    idx0 = i
        let speed = 1 - s_count / (N + EPSILON)
        let t0 = (1 - x_idx0) / speed
        let tr = r - x_idxr
        let ts = r - x_idxs

        let dt: Float64
        if t0 <= tr and t0 <= ts:
            dt = t0
        elif tr <= t0 and tr <= ts:
            dt = tr
        else:
            dt = ts

        for i in range(N):
            if x[i] < r:
                x[i] += dt
            else:
                x[i] += dt * speed

            if x[i] >= 1:
                x[i] -= 1


def visualize(x: Tensor[DType.float64], filename: String, title: String):
    plt = Python.import_module("matplotlib.pyplot")
    np = Python.import_module("numpy")
    numpy_array = np.zeros(N, np.float64)

    #
    for i in range(N):
        numpy_array.itemset(i, x[i])

    # no tuple unpacking i guess...
    plt.hist(numpy_array, 100)
    plt.xlabel("phase")
    plt.ylabel("count")
    plt.title(title)
    plt.savefig(filename)
    plt.close()


def main():
    seed()
    var x = rand[DType.float64](N)
    sort(x, N)
    visualize(x, "initial.svg", "Initial")
    run_simulation(x, 0.95, 0.1)
    for i in range(N):
        # offset to avoid "wraparound" case
        x[i] += 0.05
        if x[i] > 1:
            x[i] -= 1
    visualize(x, "final.png", "Final")
