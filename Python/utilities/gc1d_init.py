import numpy as np


def landmark(NN, landmark_mean, landmark_std, landmark_gain):
    x = np.arange(1, NN.N + 1)
    landmark_input = np.exp(-(x - landmark_mean)**2 / (2 * landmark_std**2))
    landmark_input = landmark_input / np.max(landmark_input)
    landmark_input = landmark_gain * landmark_input
    return landmark_input


def gc1d_init(NN):
    N = NN.N
    NN.dt = 1.0 / 2000.0
    NN.tau_s = 40.0 / 1000.0

    T = 10
    N_t = int(T / NN.dt)

    v_base = 0
    weber_frac = 0.01
    v_noise = weber_frac * np.random.randn()
    v = (v_base + v_noise) * np.ones(N_t)

    landmark_input = landmark(NN, 0, 30, 3)
    sij = np.zeros((2 * N, N_t))

    for t in range(1, N_t):
        # LEFT population
        v_L = (1 - NN.beta_vel * v[t])
        g_LL = NN.W_LL @ sij[0:N, t-1]
        g_LR = NN.W_LR @ sij[N:2*N, t-1]
        G_L = v_L * ((g_LL + g_LR) + NN.FF_global.flatten())

        # RIGHT population
        v_R = (1 + NN.beta_vel * v[t])
        g_RR = NN.W_RR @ sij[N:2*N, t-1]
        g_RL = NN.W_RL @ sij[0:N, t-1]
        G_R = v_R * ((g_RR + g_RL) + NN.FF_global.flatten())

        G_L = G_L + landmark_input
        G_R = G_R + landmark_input

        G = np.concatenate([G_L, G_R])
        F = G * (G >= 0)

        sij[:, t] = sij[:, t-1] + (F - sij[:, t-1]) * NN.dt / NN.tau_s

    NN.init_state = sij[:, -1]
    return NN
