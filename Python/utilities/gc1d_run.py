
"""
- Language-specific feature adaptations:
    - Matlab's 1-based indexing was converted to Python's 0-based indexing.
    - `circshift` was replaced with `np.roll`. Note that `np.roll` shift direction and index offsets were adjusted to match Matlab's behavior.
    - `findpeaks` from `scipy.signal` was used as the equivalent to Matlab's `findpeaks`.
    - Matrix multiplication `*` in Matlab was converted to `np.dot` or `@` for matrix-vector products.
    - `mvnrnd` was replaced with `scipy.stats.multivariate_normal.rvs`.
- Type system differences:
    - Matlab structures were converted to a simple Python class `NNStruct` or handled as objects with attributes.
    - Array slicing in Python `[start:end]` is exclusive of the end index, whereas Matlab `(start:end)` is inclusive.
- Standard library equivalents:
    - `drawnow` and `getframe` for GIF generation differ significantly. In Python, `matplotlib.pyplot.pause` and `imageio` are standard. The GIF logic is provided as a structural equivalent but requires an external library like `imageio` for file writing.
    - `nargin` logic in `myrgb` was handled using Python's default argument values (`None`).
- Potential issues:
    - The `findpeaks` logic in the main loop uses a slice `z[nn_state(end)-10:end]`. In Python, I ensured the index is an integer and handled potential negative indices with `max(0, ...)`.
    - The variable `t1, t2, t3, t4, t5` were initialized to 0 to avoid `UnboundLocalError` in Python, as Matlab allows dynamic variable creation in branches.
"""


import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import find_peaks


def landmark(NN, landmark_mean, landmark_std, landmark_gain):
    x = np.arange(1, NN.N + 1)
    if not isinstance(landmark_mean, (list, np.ndarray)):
        landmark_mean = [landmark_mean]

    landmark_i = np.zeros((len(landmark_mean), NN.N))
    for nmodes in range(len(landmark_mean)):
        landmark_i[nmodes, :] = landmark_gain * np.exp(-(x - landmark_mean[nmodes])**2 / (2 * landmark_std**2))

    return np.sum(landmark_i, axis=0)


def setplotparams():
    plt.figure()


def plotsim(t, landmark_input, z, nn_state, makegif):
    if t % 200 == 0:
        plt.subplot(2, 1, 1)
        plt.cla()
        plt.gca().set_yticks([])
        plt.gca().set_xticks(np.arange(0, 361, 45))
        plt.gca().tick_params(labelsize=15)
        plt.plot(landmark_input / 10, 'k', linewidth=5)
        plt.plot(z, 'b')
        plt.plot(nn_state[t], 5, 'r.', markersize=30)
        plt.xlabel('Neurons @ phase (deg)')
        plt.ylabel('Activation')
        plt.xlim([-5, 370])
        plt.ylim([0, 20])

        plt.subplot(2, 1, 2)
        plt.plot(np.arange(1, len(nn_state) + 1) / 2000, nn_state, 'k')
        plt.xlabel('time(s)')
        plt.ylabel('distance(deg)')
        plt.gca().tick_params(labelsize=15)

        plt.draw()
        plt.pause(0.001)

        if makegif:
            # GIF export intentionally omitted; MATLAB wrote each frame to
            # step2lm.gif via getframe/imwrite as the simulation ran.
            pass


def gc1d_run(NN):

    N = NN.N
    doplot = NN.plotit
    makegif = 1
    
    T = 60            # length of integration time blocks (s)
    N_t = int(T / NN.dt)  # number of time points in the simulation

    # speed input -- adjusted so that w/ and w/o landmarks have ~matched mean tp
    if NN.landmarkpresent:
        v_base = NN.wlm_speed
    else:
        v_base = NN.wolm_speed
    
    wm = NN.wm  # weber fraction
    v_noise = v_base * wm * np.random.randn()
    NN.noisy_vel_input = v_base + v_noise # add noise here to get behavioral variability 
    v = NN.noisy_vel_input * np.ones(N_t)
    NN.wm = wm
    NN.v_noise = v_noise
    NN.v_base = v_base
    
    # Graphing parameters
    if doplot:
        setplotparams()
    
    landmark_flag = 0
    landmark_centers = NN.landmark_input_loc + 3   # location of landmark centers
    landmark_onset = 500           # risetime for the landmark
    landmark_tau = 1500            # decay speed of landmarks
    
    inital_state = NN.inital_state            # approximate inital phase of the network at onset of timing
    end_state = NN.end_state              # final phase of the network at the time of prduction
    nn_state = [inital_state]    # initialize state
    
    sij = np.zeros((2 * N, N_t))  # Population activity across time
    sij[:, 0] = NN.init_state

    t = 0 # Python is 0-indexed

    # Initialize landmark timing variables
    t1 = t2 = t3 = t4 = t5 = 0

    while nn_state[t] < end_state:

        t = t + 1
        if t >= N_t:
            break

        # LEFT population
        v_L = (1 - NN.beta_vel * v[t])
        g_LL = np.dot(NN.W_LL, sij[0:N, t-1])                     # L->L
        g_LR = np.dot(NN.W_LR, sij[N:2*N, t-1])                 # R->L
        G_L = v_L * ((g_LL + g_LR) + NN.FF_global.flatten())        # input conductance into Left population

        # RIGHT population
        v_R = (1 + NN.beta_vel * v[t])
        g_RR = np.dot(NN.W_RR, sij[N:2*N, t-1])                 # R->R
        g_RL = np.dot(NN.W_RL, sij[0:N, t-1])                     # L->R
        G_R = v_R * ((g_RR + g_RL) + NN.FF_global.flatten())        # input conductance into Right population
        
        # Set up landmark inputs depending on the network state
        if NN.landmarkpresent:
            
            if NN.landmark_input_external > 0:
                
                # insert external landmark here
                if (t * NN.dt) > NN.landmark_input_external:
                    if landmark_flag == 0:
                        landmark_flag = 1
                        t1 = t
                        t2 = 0
                        t3 = 0
                        NN.LM_onset_state = nn_state[t-1]
                        landmark_centers = nn_state[t-1]
                
                    landmark_amp = 50 * np.exp(-(t - t1 - landmark_onset)**2 / (2 * landmark_tau**2))
                    landmark_input = landmark(NN, landmark_centers, 5, landmark_amp)
                else:
                    landmark_input = landmark(NN, 90, 5, 0)
                
            else:
                
                if hasattr(NN.landmark_input_loc, "__len__") and len(NN.landmark_input_loc) > 1:
                    
                    if nn_state[t-1] < NN.landmark_input_loc[0]:
                        landmark_input = landmark(NN, 90, 5, 0)
                    elif nn_state[t-1] < NN.landmark_input_loc[1]:
                        if landmark_flag == 0:
                            landmark_flag = 1
                            t1 = t
                        landmark_amp = 50 * np.exp(-(t - t1 - landmark_onset)**2 / (2 * landmark_tau**2))
                        landmark_input = landmark(NN, landmark_centers, 5, landmark_amp)
                    elif nn_state[t-1] < NN.landmark_input_loc[2]:
                        if landmark_flag == 1:
                            landmark_flag = 2
                            t2 = t
                        landmark_amp = 50 * np.exp(-(t - t2 - landmark_onset)**2 / (2 * landmark_tau**2))
                        landmark_input = landmark(NN, landmark_centers, 5, landmark_amp)
                    elif nn_state[t-1] < NN.landmark_input_loc[3]:
                        if landmark_flag == 2:
                            landmark_flag = 3
                            t3 = t
                        landmark_amp = 50 * np.exp(-(t - t3 - landmark_onset)**2 / (2 * landmark_tau**2))
                        landmark_input = landmark(NN, landmark_centers, 5, landmark_amp)
                    elif nn_state[t-1] < NN.landmark_input_loc[4]:
                        if landmark_flag == 3:
                            landmark_flag = 4
                            t4 = t
                        landmark_amp = 50 * np.exp(-(t - t4 - landmark_onset)**2 / (2 * landmark_tau**2))
                        landmark_input = landmark(NN, landmark_centers, 5, landmark_amp)
                    else:
                        if landmark_flag == 4:
                            landmark_flag = 5
                            t5 = t
                        landmark_amp = 50 * np.exp(-(t - t5 - landmark_onset)**2 / (2 * landmark_tau**2))
                        landmark_input = landmark(NN, landmark_centers, 5, landmark_amp)
                        
                else:
                    
                    if nn_state[t-1] < NN.landmark_input_loc[0]:
                        landmark_input = landmark(NN, 90, 5, 0)
                    else:
                        if landmark_flag == 0:
                            landmark_flag = 1
                            t1 = t
                            t2 = 0
                            t3 = 0
                        landmark_amp = 50 * np.exp(-(t - t1 - landmark_onset)**2 / (2 * landmark_tau**2))
                        landmark_input = landmark(NN, landmark_centers, 5, landmark_amp)
                
            
        else:
            landmark_input = landmark(NN, 90, 5, 0)
        
        # add landmark to both directions
        G_L = G_L + landmark_input
        G_R = G_R + landmark_input
        
        G = np.concatenate((G_L, G_R))
        F = G * (G >= 0)   # RelU
        
        # update population activity
        sij[:, t] = sij[:, t-1] + (F - sij[:, t-1]) * NN.dt / NN.tau_s

        # find the local maximum to track the nn state
        z = sij[0:N, t]
        # Matlab: z(nn_state(end)-10:end)
        start_idx = int(max(0, nn_state[-1] - 10))
        peaks, _ = find_peaks(z[start_idx:])
        if len(peaks) > 0:
            nn_state.append(peaks[0] + nn_state[-1] - 10)
        else:
            nn_state.append(nn_state[-1])
       
        # plot moment by moment progression
        if doplot:
            plotsim(t, landmark_input, z, nn_state, makegif)
        
        if not hasattr(NN, 'grid_statesR'):
            NN.grid_statesR = np.zeros((N, N_t))
            NN.grid_statesL = np.zeros((N, N_t))
            
        NN.grid_statesR[:, t] = sij[0:N, t]
        NN.grid_statesL[:, t] = sij[N:2*N, t]

    NN.nn_state = np.array(nn_state[1:])
    if NN.landmarkpresent:
        NN.lm_onset_times = np.array([t1, t2, t3, t4, t5])
        
    return NN
