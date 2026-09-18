"""
- **addline**: Matlab's `line` and `plot` handle multiple lines differently than Matplotlib. I used `plt.plot` with `nan` columns to simulate the behavior of plotting multiple disjoint segments in one call.
"""

import numpy as np
import matplotlib.pyplot as plt

def addline(strips, orient=None, *args):
    """
    Simple Way to add vertical or horizontal lines to a plot.
    """
    # Convert strips to numpy array if it isn't
    strips = np.atleast_1d(strips)
    
    varargin = list(args)
    
    # To keep compatibility with older versions
    if orient is not None:
        if isinstance(orient, str):
            if not all(c in 'vh' for c in orient):
                varargin.insert(0, orient)
                orient = 'v'
        else:
            # If orient is not a string, it might be the start of varargin
            varargin.insert(0, orient)
            orient = 'v'
    else:
        orient = 'v'

    colour = None
    pattern = None
    width = None

    i = 0
    while i < len(varargin) - 1:
        key = varargin[i]
        val = varargin[i+1]
        if isinstance(key, str):
            if key.lower() == 'color':
                colour = val
            elif key.lower() == 'linestyle':
                pattern = val
            elif key.lower() == 'linewidth':
                width = val
            elif key.lower() == 'orientation':
                if val == 0:
                    orient = 'v'
                elif val == 1:
                    orient = 'h'
            else:
                print(f'This function takes "satfire", "threshold", and "show" as arguments. None of this {key} nonsense')
        i += 2

    # Set Defaults
    if colour is None:
        colour = [0.5, 0.5, 0.5]
    elif isinstance(colour, str) and colour == 'auto':
        # Matlab 'lines' equivalent
        prop_cycle = plt.rcParams['axes.prop_cycle']
        colors = prop_cycle.by_key()['color']
        colour = [colors[i % len(colors)] for i in range(len(strips))]

    # Get full orientation vector
    if len(orient) == 1:
        orient = orient * len(strips)
    elif len(orient) != len(strips):
        print('Warning: Wrong number of line orientations provided for line vector. Lines will not be plotted')
        return -1

    if pattern is None:
        pattern = '-'
    
    if width is None:
        width = 1

    # Actual program
    ax = plt.gca()
    xlim = ax.get_xlim()
    ylim = ax.get_ylim()

    xtags = np.full((2, len(strips)), np.nan)
    ytags = np.full((2, len(strips)), np.nan)

    orient_arr = np.array(list(orient))
    
    v_idx = np.where(orient_arr == 'v')[0]
    if v_idx.size > 0:
        xtags[:, v_idx] = np.tile(strips[v_idx], (2, 1))
        ytags[:, v_idx] = np.tile(np.array([[ylim[0]], [ylim[1]]]), (1, len(v_idx)))

    h_idx = np.where(orient_arr == 'h')[0]
    if h_idx.size > 0:
        xtags[:, h_idx] = np.tile(np.array([[xlim[0]], [xlim[1]]]), (1, len(h_idx)))
        ytags[:, h_idx] = np.tile(strips[h_idx], (2, 1))

    h = plt.plot(xtags, ytags, color=colour, linestyle=pattern, linewidth=width)
    
    ax.set_xlim(xlim)
    ax.set_ylim(ylim)
    
    return h

