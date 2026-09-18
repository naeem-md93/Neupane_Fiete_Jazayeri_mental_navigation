import numpy as np
from scipy.stats import multivariate_normal


def get_gpfr(fr, xx):
    binwidth = xx[4] - xx[3]
    tau = 100 * binwidth
    sigm = 1

    numtr = fr.shape[0]
    gpmean = np.nanmean(fr) + np.zeros(len(xx))

    kernel_fun = np.zeros((len(xx), len(xx)))
    for tii in range(len(xx)):
        for tjj in range(len(xx)):
            ti = xx[tii]
            tj = xx[tjj]
            kernel_fun[tii, tjj] = sigm**2 * np.exp(-(ti - tj)**2 / (2 * tau**2))

    gpfr = multivariate_normal.rvs(mean=gpmean, cov=kernel_fun, size=numtr)
    return gpfr, kernel_fun
