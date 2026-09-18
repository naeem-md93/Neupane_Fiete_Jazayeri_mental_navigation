import numpy as np


def myrgb(n, ratio1=None, ratio2=None):
    grays = np.linspace(0, 1, n)

    if ratio1 is None and ratio2 is None:
        h = np.column_stack((grays, grays, grays))
    elif ratio2 is None:
        h = np.column_stack((
            np.linspace(0, ratio1[0], n),
            np.linspace(0, ratio1[1], n),
            np.linspace(0, ratio1[2], n)
        ))
    else:
        h = np.column_stack((
            np.linspace(ratio1[0], ratio2[0], n),
            np.linspace(ratio1[1], ratio2[1], n),
            np.linspace(ratio1[2], ratio2[2], n)
        ))
    return h
