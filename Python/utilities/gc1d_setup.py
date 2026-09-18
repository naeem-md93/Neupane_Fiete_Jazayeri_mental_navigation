import numpy as np


class NNStruct:
    def __init__(self):
        pass


def mex_hat(NN, A_ext, s_exc, A_inh, s_inh):
    z = np.arange(-NN.N / 2, NN.N / 2)
    NN.mexHat = A_ext * np.exp(-s_exc * z**2) - A_inh * np.exp(-s_inh * z**2)
    NN.mexHat = np.roll(NN.mexHat, int(NN.N / 2 - 1))
    return NN


def synapses(NN):
    NN.W_RR = np.zeros((NN.N, NN.N))
    NN.W_LL = np.zeros((NN.N, NN.N))
    NN.W_RL = np.zeros((NN.N, NN.N))
    NN.W_LR = np.zeros((NN.N, NN.N))

    for i in range(NN.N):
        NN.W_RR[i, :] = np.roll(NN.mexHat, i)       # Right neurons to Right neurons
        NN.W_LL[i, :] = np.roll(NN.mexHat, i + 2)    # Left neurons to Left neurons
        NN.W_RL[i, :] = np.roll(NN.mexHat, i + 1)    # Left neurons to Right neurons
        NN.W_LR[i, :] = np.roll(NN.mexHat, i + 1)    # Right neurons to Left neurons
    return NN


def gc1d_setup():
    NN = NNStruct()
    NN.N = 364

    # Center Surround mexican hat connectivity profile
    A_ext = 1000
    s_exc = 1.05 / 100
    A_inh = 1000
    s_inh = 1.00 / 100
    NN = mex_hat(NN, A_ext, s_exc, A_inh, s_inh)

    # synaptic weights (shifts currently hard coded)
    NN = synapses(NN)

    # global excitatory input
    NN.beta_0 = 100
    NN.FF_global = NN.beta_0 * np.ones((NN.N, 1))

    # velocity drive parameters
    NN.beta_vel = 1     # velocity gain

    # topographically organized phase preference
    NN.x_prefs = np.arange(1, NN.N + 1) / NN.N

    return NN
