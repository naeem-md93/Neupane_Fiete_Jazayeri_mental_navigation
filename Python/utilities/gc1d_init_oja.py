import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import norm
from scipy.linalg import toeplitz


def createbump(d, width, amp):
    z = np.arange(-d/2, d/2)
    kernel = norm.pdf(z, 0, width)
    kernel = amp * kernel / np.max(kernel)
    return kernel

def gc1d_init_oja(n_module, lm_module, lm_phase, onlineplots, lr):
    class Params:
        pass
    class Out:
        pass
    
    params = Params()
    out = Out()
    
    params.vis2mental = 500000
    a = 20
    params.lr = lr
    params.a = a
    params.n_module = n_module
    params.lm_module = lm_module
    params.lm_phase = lm_phase
    params.num_neurons = 360
    
    width = params.num_neurons
    total_n = n_module * width
    
    scale = np.zeros(n_module)
    ec = []
    for i in range(n_module):
        scale[i] = 1.1**(i + 1 - n_module/2.0)
        grid = createbump(width, a * scale[i], 1)
        ec.append({'module': toeplitz(grid)})
        
    w_ec2lm = np.random.randn(width, n_module) / total_n
    out.init_w = w_ec2lm.copy()
    out.ec = ec
    params.scale = scale
    tti = 0
    
    idx = np.atleast_1d(lm_phase) / 360.0 * width
    grid = createbump(width, a, 1)
    lm_ext = np.roll(grid, int(idx[0]))
    
    for ii in range(1, len(idx)):
        lm_ext = lm_ext + np.roll(grid, int(idx[ii]))
        
    t = 0
    eta = lr
    out.vis2mental_vec = []
    out.weights = []
    
    thisphase = np.zeros((width, n_module))
    ti = np.zeros(n_module, dtype=int)

    while t < 1000000:
        t += 1
        lm_int = 0.0
        for i in range(n_module):
            ti[i] = int(round(t / scale[i]))
            thisphase[:, i] = ec[i]['module'][:, (ti[i] - 1) % width]
            lm_int = lm_int + np.dot(w_ec2lm[:, i], thisphase[:, i])

        i_ext = lm_ext[(ti[lm_module - 1] - 1) % width]

        if t < params.vis2mental:
            lm_s = i_ext + lm_int
        else:
            lm_s = lm_int

        # Oja's rule: w = w + eta * s * (phase - s * w), with lm_s a scalar
        # broadcasting the same update across all modules (columns of w_ec2lm)
        w_ec2lm = w_ec2lm + eta * lm_s * (thisphase - lm_s * w_ec2lm)

        w_ec2lm = w_ec2lm - np.mean(w_ec2lm, axis=0)
        
        if t % 2000 == 0:
            print(t)
            if onlineplots == 1:
                plt.clf()
                plt.imshow(w_ec2lm, aspect='auto')
                plt.plot(lm_module - 1, idx, 'k.', markersize=20)
                plt.xticks(range(n_module), np.round(100 * scale) / 100.0)
                plt.xlabel('Spatial scale (a.u.)')
                plt.ylabel('Phase (deg)')
                plt.pause(0.01)
            
            if t < params.vis2mental:
                out.vis2mental_vec.append(0)
            else:
                out.vis2mental_vec.append(1)
            
            out.weights.append(w_ec2lm.copy())
            tti += 1
            
    out.weights = np.array(out.weights)
    return out, params
