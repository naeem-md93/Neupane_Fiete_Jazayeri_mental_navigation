import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import fmin
from scipy.integrate import quad_vec
import os


def ptmts_counter(ts, tm, wm):
    wmts2 = (wm * np.sqrt(ts))**2
    x = (ts - tm)**2
    return 1.0 / np.sqrt(2 * np.pi * wmts2) * np.exp(-0.5 * x / wmts2)

def fbls_counter(ts, tm, wm):
    # ts is the (shared) prior support to integrate over; tm may be a scalar
    # or an array that broadcasts against ts (one measurement per trial).
    c = 0.5846
    m = -0.1026

    def numer_fun(t_s):
        return (c + m * t_s) * t_s * ptmts_counter(t_s, tm, wm)

    def denom_fun(t_s):
        return (c + m * t_s) * ptmts_counter(t_s, tm, wm)

    ts_min, ts_max = np.min(ts), np.max(ts)
    numer, _ = quad_vec(numer_fun, ts_min, ts_max)
    denom, _ = quad_vec(denom_fun, ts_min, ts_max)

    return numer / denom

def ptpte_counter(te, tp, wp):
    wpte2 = (wp * np.sqrt(te))**2
    x = (te - tp)**2
    return 1.0 / np.sqrt(2 * np.pi * wpte2) * np.exp(-0.5 * x / wpte2)

def ptp_counter(tp, ts, wm, wp, ints):
    # tp, ts: arrays of per-trial values (same length); ts also doubles as
    # the prior support that fbls_counter integrates over, matching
    # Matlab's integral(..., 'ArrayValued', true) broadcasting behavior.
    lower = 0
    upper = np.max(ints) * 2

    def fun(x):
        te = fbls_counter(ts, x, wm)
        return ptpte_counter(te, tp, wp) * ptmts_counter(ts, x, wm)

    p, _ = quad_vec(fun, lower, upper)
    return p

def neg_log_like_counter(params, ts_exp, tp_exp, ints):
    wm, wp, offset = params
    out = -np.sum(np.log(ptp_counter(tp_exp - offset, ts_exp, wm, wp, ints)))
    if wm < 0 or wp < 0:
        out = out + 1000
    return out

def bls_offset_counter_nonuniformPrior_self(ts, modelparams, tp, gen_model_type, savefolder):
    class Model:
        pass
    mdl = Model()
    mdl.type = 'counter'
    
    if tp is None or len(tp) == 0:
        wm, wp, offset = modelparams
        tm = np.random.normal(ts, wm * np.sqrt(ts))
        te = np.array([fbls_counter(ts, val, wm) for val in tm])
        tp_gen = np.random.normal(te, wp * np.sqrt(te)) + offset
        return tp_gen, None

    mdl.gen_model_type = gen_model_type
    ints = np.arange(np.min(ts), np.max(ts) + 0.1, 0.1)
    w_init = [0.5, 0.5, 0]
    
    wopt = fmin(neg_log_like_counter, w_init, args=(ts, tp, ints), disp=True)
    neglogL_opt = neg_log_like_counter(wopt, ts, tp, ints)
    
    mdl.aic = 2 * len(wopt) + 2 * neglogL_opt
    mdl.bic = np.log(len(ts)) * len(wopt) + 2 * neglogL_opt
    mdl.w = wopt
    mdl.negloglik = neglogL_opt

    wmopt, wpopt, w_offset = wopt
    tm = np.random.normal(ts, wmopt * np.sqrt(ts))
    te = np.array([fbls_counter(ts, val, wmopt) for val in tm])
    tp_gen = np.random.normal(te, wpopt * np.sqrt(te)) + w_offset

    unique_ts = np.unique(ts)
    n_unique = len(unique_ts)
    bias = np.zeros((n_unique, 2))
    varnc = np.zeros((n_unique, 2))
    
    tp_mean_data = np.zeros(n_unique)
    tp_mean_gen = np.zeros(n_unique)

    for idx, dd in enumerate(unique_ts):
        gd = np.where(ts == dd)[0]
        tp_mean_data[idx] = np.mean(tp[gd])
        tp_mean_gen[idx] = np.nanmean(tp_gen[gd])
        bias[idx, :] = [tp_mean_data[idx] - dd, tp_mean_gen[idx] - dd]
        varnc[idx, :] = [np.var(tp[gd]), np.var(tp_gen[gd])]

    mdl.bias_data = bias[:, 0]
    mdl.bias_model = bias[:, 1]
    mdl.var_data = varnc[:, 0]
    mdl.var_model = varnc[:, 1]

    plt.figure(figsize=(12, 8))
    plt.subplot(2, 2, 3)
    plt.plot(bias[:, 0], bias[:, 1], 'or')
    plt.plot(np.sqrt(varnc[:, 0]), np.sqrt(varnc[:, 1]), 'sk')
    plt.gca().set_aspect('equal')
    plt.plot([-0.8, 0.8], [-0.8, 0.8], '-k')
    plt.title('bias(circle) SD(square)')
    plt.axis([-1, 1, -1, 1])
    plt.xlabel('model')
    plt.ylabel('data')
    plt.grid(True)

    plt.subplot(2, 2, 1)
    plt.plot([0, 4], [0, 4], 'k--')
    jitt2 = -0.05 + 0.1 * np.random.rand(len(ts))
    plt.plot(ts + jitt2, tp_gen, '.g', markersize=5)
    h1, = plt.plot(unique_ts, tp_mean_data, 'r*')
    h2, = plt.plot(unique_ts, tp_mean_gen, 'bo', markersize=8)
    h3, = plt.plot(tm, te, 'b.', markersize=5)
    plt.title(mdl.type)
    plt.gca().set_aspect('equal')
    plt.axis([0, 4, 0, 4])
    plt.legend([h1, h2, h3], ['data', 'model', 'BLS(te)'], loc='upper left')
    plt.ylabel('produced interval: tp (sec)')
    plt.xlabel(str(wopt))
    plt.grid(True)

    ax_bias = plt.axes([0.55, 0.6, 0.1, 0.1])
    ax_bias.plot(unique_ts, bias[:, 0], '-*r')
    ax_bias.plot(unique_ts, bias[:, 1], '-ob')
    ax_bias.set_title('bias(tp)')
    ax_bias.grid(True)

    ax_sd = plt.axes([0.7, 0.6, 0.1, 0.1])
    ax_sd.plot(unique_ts, np.sqrt(varnc[:, 0]), '-*r')
    ax_sd.plot(unique_ts, np.sqrt(varnc[:, 1]), '-ob')
    ax_sd.set_title('SD(tp)')
    ax_sd.grid(True)

    mdl.mse = np.mean((tp - tp_gen)**2)
    mdl.mse_bias_var = np.abs(np.sum(bias[:, 0]**2 + varnc[:, 0]) - np.sum(bias[:, 1]**2 + varnc[:, 1]))

    if not os.path.exists(savefolder):
        os.makedirs(savefolder)
    plt.savefig(os.path.join(savefolder, f'BLS_model_{mdl.type}_gen_model_{mdl.gen_model_type}.png'))
    
    return tp_gen, mdl
