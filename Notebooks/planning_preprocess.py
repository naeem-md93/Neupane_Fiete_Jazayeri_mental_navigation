"""Bin the 1-ms EC spike tensors of one session into 10-ms counts and cache them.

Tensor values are rates (1000 = one spike in a 1-ms bin); we convert them to counts.
Reads the v7.3 (HDF5) tensors block by block so RAM stays low.
h5py layout: neur_tensor_<epoch> is (trials, time, neurons) = transposed MATLAB (neurons, time, trials).
"""
import sys
import h5py
import numpy as np
import os.path as osp

SESSION = sys.argv[1] if len(sys.argv) > 1 else "amadeus08292019_a"
DATA_PATH = f"/media/naeem_md93/DRIVE/MNAV/EC/{SESSION}.mwk/"
OUT = osp.join(osp.dirname(osp.abspath(__file__)), "cache", f"{SESSION}_binned10ms.npz")

BIN = 10  # ms
EPOCHS = {  # epoch: (start, stop) in seconds relative to the event
    "stim1on": (-1.0, 1.9),
    "gocueon": (-1.9, 1.9),
    "joyon": (-1.9, 1.0),
}
BLOCK = 100  # ms read per HDF5 call

out = {}
for ep, (t0, t1) in EPOCHS.items():
    f = h5py.File(osp.join(DATA_PATH, f"{SESSION}_neur_tensor_{ep}.mat"), "r")
    if ep == "stim1on":
        lab = ["".join(chr(c) for c in f[r][:].ravel()) for r in f["cond_label"][:, 0]]
        cm = f["cond_matrix"][:]
        for i, l in enumerate(lab):
            out["cond_" + l] = cm[i]
    edges = f[ep + "/edges"][:, 0]
    i0 = int(np.argmin(np.abs(edges - (t0 + 0.001))))
    i1 = i0 + int(round((t1 - t0) * 1000))
    ds = f["neur_tensor_" + ep]
    n_tr, _, n_neur = ds.shape
    nb = (i1 - i0) // BIN
    binned = np.zeros((n_tr, nb, n_neur), dtype=np.uint8)
    for b0 in range(i0, i1, BLOCK):
        blk = ds[:, b0:b0 + BLOCK, :] / 1000.0  # stored as spikes/s per 1-ms bin -> spike counts
        k = (b0 - i0) // BIN
        binned[:, k:k + BLOCK // BIN, :] = blk.reshape(n_tr, BLOCK // BIN, BIN, n_neur).sum(2).round()
        del blk
    # hand position (joystick) at the same resolution, for checking movement onset
    hand = f["hand_tensor_" + ep][:, i0:i1].reshape(n_tr, nb, BIN).mean(2).astype(np.float32)
    out[ep] = binned
    out[ep + "_t"] = edges[i0:i1].reshape(nb, BIN).mean(1) - 0.0005  # bin centres (s)
    out[ep + "_hand"] = hand
    f.close()
    print(ep, binned.shape, flush=True)

np.savez_compressed(OUT, **out)
print("saved", OUT)
