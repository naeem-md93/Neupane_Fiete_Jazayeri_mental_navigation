# Neupane, Fiete, Jazayeri 2024 mnav paper
# Bayesian model of timing variability with and without landmark reset (named as counter vs non-counter in this code, named as mental navigation vs path integration in the paper)
# For questions or further data/code access contact sujayanyaupane@gmail.com
# ====================================================================================================================

import os
import sys

import numpy as np
import matplotlib.pyplot as plt
from scipy.io import savemat

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), 'utilities'))

from addline import addline
from bls_offset_counter_nonuniformPrior_self import bls_offset_counter_nonuniformPrior_self
from bls_offset_noncounter_nonuniformPrior_self import bls_offset_noncounter_nonuniformPrior_self


def get_mdl_names():
    # Only the first two models are implemented in Python/utilities so far;
    # the rest are placeholders for the remaining Matlab model variants.
    mdl = [None] * 16
    mdl[0] = bls_offset_counter_nonuniformPrior_self
    mdl[1] = bls_offset_noncounter_nonuniformPrior_self
    mdl[2] = 'bls_offset_counter_atm_nonuniformPrior_self'
    mdl[3] = 'bls_offset_counter_atp_nonuniformPrior_self'
    mdl[4] = 'bls_joystickoffset_counter_nonuniformPrior_self'
    mdl[5] = 'bls_joystickoffset_noncounter_nonuniformPrior_self'
    mdl[6] = 'bls_joystickoffset_counter_atm_nonuniformPrior_self'
    mdl[7] = 'bls_joystickoffset_counter_atp_nonuniformPrior_self'

    mdl[8] = 'bls_offset_counter_oa_nonuniformPrior_self'
    mdl[9] = 'bls_offset_noncounter_oa_nonuniformPrior_self'
    mdl[10] = 'bls_offset_counter_oa_atm_nonuniformPrior_self'
    mdl[11] = 'bls_offset_counter_oa_atp_nonuniformPrior_self'
    mdl[12] = 'bls_joystickoffset_counter_oa_nonuniformPrior_self'
    mdl[13] = 'bls_joystickoffset_noncounter_oa_nonuniformPrior_self'
    mdl[14] = 'bls_joystickoffset_counter_oa_atm_nonuniformPrior_self'
    mdl[15] = 'bls_joystickoffset_counter_oa_atp_nonuniformPrior_self'
    return mdl


ts_ = np.tile(np.arange(0.65, 3.25 + 0.65, 0.65), 100)
modelparams = np.array([0.15, 0.2, 0.01])
savefolder = '/Users/Sujay/Dropbox (MIT)/MJ & SN/nav_paper/Nature_revision 1/matlab code/data_figs'
mdl_filenames = get_mdl_names()

mse = np.zeros((2, 2, 100))
negloglik = np.zeros((2, 2, 100))
bic = np.zeros((2, 2, 100))
w_model = np.zeros((2, 2, 3, 100))
mdl_fit_out = np.empty((2, 2, 100), dtype=object)

for bb in range(100):
    for modelgen in range(2):
        tp_gen, gen_model_type = mdl_filenames[modelgen](ts_, modelparams, None, None, savefolder)

        for modelfit in range(2):
            _, mdl = mdl_filenames[modelfit](ts_, None, tp_gen, gen_model_type, savefolder)
            mdl_fit_out[modelgen, modelfit, bb] = mdl
            mse[modelgen, modelfit, bb] = mdl.mse_bias_var
            negloglik[modelgen, modelfit, bb] = mdl.negloglik
            bic[modelgen, modelfit, bb] = mdl.bic
            w_model[modelgen, modelfit, :, bb] = mdl.w
            plt.close('all')

# %%
hsim = plt.figure(figsize=(14.01, 9.93))

plt.subplot(3, 3, 1)
plt.bar([1, 2], np.mean(mse[:, 0, :], axis=1))
plt.errorbar([1, 2], np.mean(mse[:, 0, :], axis=1), np.std(mse[:, 0, :], axis=1), fmt='ok', linewidth=2)
plt.bar([4, 5], np.mean(mse[:, 1, :], axis=1))
plt.errorbar([4, 5], np.mean(mse[:, 1, :], axis=1), np.std(mse[:, 1, :], axis=1), fmt='ok', linewidth=2)
plt.ylabel('MSE (data-model)')
plt.xlabel('fitted models')
plt.xticks([1, 2, 3, 4, 5], ['counting', 'timing', '', 'counting', 'timing'])
plt.legend(['gen model: counting', '', 'timing', ''], loc='upper left')
plt.gca().tick_params(labelsize=15)

plt.subplot(3, 3, 4)
plt.bar([1, 2], np.mean(bic[:, 0, :], axis=1))
plt.errorbar([1, 2], np.mean(bic[:, 0, :], axis=1), np.std(bic[:, 0, :], axis=1), fmt='ok', linewidth=2)
plt.bar([4, 5], np.mean(bic[:, 1, :], axis=1))
plt.errorbar([4, 5], np.mean(bic[:, 1, :], axis=1), np.std(bic[:, 1, :], axis=1), fmt='ok', linewidth=2)
plt.ylabel('BIC')
plt.xlabel('fitted models')
plt.xticks([1, 2, 3, 4, 5], ['counting', 'timing', '', 'counting', 'timing'])
plt.gca().tick_params(labelsize=15)

plt.subplot(3, 3, 2)
plt.hist(mse[0, 0, :], bins=np.arange(0, 0.75, 0.05), alpha=0.5, label='counting')
plt.hist(mse[0, 1, :], bins=np.arange(0, 0.75, 0.05), alpha=0.5, label='timing')
plt.title('gen model: counting')
plt.legend()
plt.xlabel('MSE')
plt.gca().tick_params(labelsize=15)

plt.subplot(3, 3, 3)
plt.hist(mse[1, 0, :], bins=np.arange(0, 0.75, 0.05), alpha=0.5, label='counting')
plt.hist(mse[1, 1, :], bins=np.arange(0, 0.75, 0.05), alpha=0.5, label='timing')
plt.title('gen model: timing')
plt.legend()
plt.xlabel('MSE')
plt.gca().tick_params(labelsize=15)

plt.subplot(3, 3, 5)
plt.hist(w_model[0, 0, 1, :], bins=np.arange(0.1, 0.41, 0.01), alpha=0.5, label='counting')
plt.hist(w_model[0, 1, 1, :], bins=np.arange(0.1, 0.41, 0.01), alpha=0.5, label='timing')
addline(modelparams[1], 'color', 'k')
plt.title('gen model: counting')
plt.legend(['counting', 'timing', ''])
plt.xlabel('wp')
plt.gca().tick_params(labelsize=15)

plt.subplot(3, 3, 6)
plt.hist(w_model[1, 0, 1, :], bins=np.arange(0.1, 0.41, 0.01), alpha=0.5, label='counting')
plt.hist(w_model[1, 1, 1, :], bins=np.arange(0.1, 0.41, 0.01), alpha=0.5, label='timing')
addline(modelparams[1], 'color', 'k')
plt.title('gen model: timing')
plt.legend(['counting', 'timing', ''])
plt.xlabel('wp')
plt.gca().tick_params(labelsize=15)

plt.subplot(3, 3, 8)
plt.hist(w_model[0, 0, 0, :], bins=np.arange(0.1, 0.41, 0.01), alpha=0.5, label='counting')
plt.hist(w_model[0, 1, 0, :], bins=np.arange(0.1, 0.41, 0.01), alpha=0.5, label='timing')
addline(modelparams[0], 'color', 'k')
plt.title('gen model: counting')
plt.legend(['counting', 'timing', ''])
plt.xlabel('wm')
plt.gca().tick_params(labelsize=15)

plt.subplot(3, 3, 9)
plt.hist(w_model[1, 0, 0, :], bins=np.arange(0.1, 0.41, 0.01), alpha=0.5, label='counting')
plt.hist(w_model[1, 1, 0, :], bins=np.arange(0.1, 0.41, 0.01), alpha=0.5, label='timing')
addline(modelparams[0], 'color', 'k')
plt.title('gen model: timing')
plt.legend(['counting', 'timing', ''])
plt.xlabel('wm')
plt.gca().tick_params(labelsize=15)

plt.suptitle('Model simulation and identifiability')
if not os.path.exists(savefolder):
    os.makedirs(savefolder)
os.chdir(savefolder)

plt.savefig('model_identifiability_100simulations.eps', format='eps')

mdl_fit_out_struct = np.empty(mdl_fit_out.shape, dtype=object)
for idx in np.ndindex(mdl_fit_out.shape):
    mdl_fit_out_struct[idx] = vars(mdl_fit_out[idx])
savemat('model_identifiability_simulation.mat', {'mdl_fit_out': mdl_fit_out_struct, 'modelparams': modelparams})
