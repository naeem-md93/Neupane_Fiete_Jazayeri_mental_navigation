# Neupane, Fiete, Jazayeri 2024 mnav paper
# CAN grid cell model simulations with and without landmarks
# For questions or further data/code access contact sujayanyaupane@gmail.com
# =============================================================================

import os
import sys
import time
import pickle

import numpy as np
import matplotlib.pyplot as plt

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), 'utilities'))

from gc1d_setup import gc1d_setup
from gc1d_init import gc1d_init
from gc1d_run import gc1d_run

# set up the network architecture
NN = gc1d_setup()
# initialize the dynamics
NN = gc1d_init(NN)
NN.plotit = 1
NN.num_sim = 50
NN.inital_state = 30            # approximate inital phase of the network at onset of timing
NN.end_state = 360
NN.landmark_input_loc = np.arange(60, 301, 60)  # memorized internal landmark at particualr network state (phase)
NN.wolm_speed = .35
NN.wlm_speed = .42
NN.wm = .05  # 0.08
filename = f"int_5lms_60deg_wm{NN.wm*100:g}_vb{NN.wlm_speed*100:g}_{NN.wolm_speed*1000:g}"

NN.landmark_input_external = 0  # external landmark at a particular time (set to 0 for using internal landmark)
# simulate
if NN.plotit:
    fig1 = plt.figure(figsize=(10, 6))

traj_wint = [None] * NN.num_sim
wint_noisy_vel_input = np.zeros(NN.num_sim)
wint_wm = np.zeros(NN.num_sim)
wint_v_noise = np.zeros(NN.num_sim)
wint_v_base = np.zeros(NN.num_sim)
win_gridstater = [None] * NN.num_sim
wint_gridstatel = [None] * NN.num_sim

start_time_total = time.time()
for isim in range(NN.num_sim):
    tic = time.time()
    NN.landmarkpresent = 1
    NN = gc1d_run(NN)

    traj_wint[isim] = NN.nn_state
    wint_noisy_vel_input[isim] = NN.noisy_vel_input
    wint_wm[isim] = NN.wm
    wint_v_noise[isim] = NN.v_noise
    wint_v_base[isim] = NN.v_base
    win_gridstater[isim] = NN.grid_statesR
    wint_gridstatel[isim] = NN.grid_statesL
    print(f"int lm rep{isim + 1} sim{isim + 1}")
    print(f"Elapsed time is {time.time() - tic:.6f} seconds.")

RT_wint = np.array([len(t) for t in traj_wint])
if NN.plotit:
    plt.title('Internal landmark')
    plt.gca().tick_params(labelsize=15)
print(f"Total elapsed time for internal landmark: {time.time() - start_time_total:.6f} seconds.")
NNw = NN

start_time_total_wolm = time.time()
if NN.plotit:
    fig2 = plt.figure(figsize=(10, 6))

traj_wolm = [None] * NN.num_sim
wolm_noisy_vel_input = np.zeros(NN.num_sim)
wolm_wm = np.zeros(NN.num_sim)
wolm_v_noise = np.zeros(NN.num_sim)
wolm_v_base = np.zeros(NN.num_sim)
wolm_gridstater = [None] * NN.num_sim
wolm_gridstatel = [None] * NN.num_sim

for isim in range(NN.num_sim):
    NN.landmarkpresent = 0
    tic = time.time()
    NN = gc1d_run(NN)
    traj_wolm[isim] = NN.nn_state
    wolm_noisy_vel_input[isim] = NN.noisy_vel_input
    wolm_wm[isim] = NN.wm
    wolm_v_noise[isim] = NN.v_noise
    wolm_v_base[isim] = NN.v_base
    wolm_gridstater[isim] = NN.grid_statesR
    wolm_gridstatel[isim] = NN.grid_statesL
    # Matlab's original loop prints 'irep' here, an undefined variable in
    # that scope (a pre-existing bug in gc_CAN_model_simulation.m); we print
    # the loop index instead, matching what the sim index prints.
    print(f"no lm rep{isim + 1} sim{isim + 1}")
    print(f"Elapsed time is {time.time() - tic:.6f} seconds.")

RT_wolm = np.array([len(t) for t in traj_wolm])
if NN.plotit:
    plt.title('No landmark')
    plt.gca().tick_params(labelsize=15)
print(f"Total elapsed time for no landmark: {time.time() - start_time_total_wolm:.6f} seconds.")
NNwo = NN
del NN

# save(filename) %save all variables
workspace = {
    'NNw': vars(NNw),
    'NNwo': vars(NNwo),
    'traj_wint': traj_wint,
    'wint_noisy_vel_input': wint_noisy_vel_input,
    'wint_wm': wint_wm,
    'wint_v_noise': wint_v_noise,
    'wint_v_base': wint_v_base,
    'win_gridstater': win_gridstater,
    'wint_gridstatel': wint_gridstatel,
    'RT_wint': RT_wint,
    'traj_wolm': traj_wolm,
    'wolm_noisy_vel_input': wolm_noisy_vel_input,
    'wolm_wm': wolm_wm,
    'wolm_v_noise': wolm_v_noise,
    'wolm_v_base': wolm_v_base,
    'wolm_gridstater': wolm_gridstater,
    'wolm_gridstatel': wolm_gridstatel,
    'RT_wolm': RT_wolm,
    'filename': filename,
}

with open(f"{filename}.pkl", 'wb') as f:
    pickle.dump(workspace, f)
