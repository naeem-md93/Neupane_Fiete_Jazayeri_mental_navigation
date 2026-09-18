"""
- **Language-specific adaptations**: 
    - Matlab's `fitlm` was replaced with a custom helper function using `scipy.stats.linregress` to maintain the same interface (`Coefficients.Estimate`).
    - Matlab's `load` and `save` were replaced with `scipy.io.loadmat` and `savemat`. `squeeze_me=True` is used to simplify array access.
    - Matlab's `eval` for dynamic variable construction was replaced with dictionary lookups and `f-strings`.
    - Matlab's `table` and `writetable` were replaced with `pandas.DataFrame` and `pd.ExcelWriter`.
- **Type system differences**: Matlab uses 1-based indexing; Python uses 0-based. All loops and slice ranges were adjusted accordingly (e.g., `1:size(expid,1)` becomes `range(num_exps)`).
- **Standard library equivalents**: 
    - `os.chdir` and `os.path.join` handle directory navigation.
    - `matplotlib.pyplot` handles all plotting functionality.
    - `numpy` handles array operations and logical masking.
- **Error handling**: `try-except` blocks were preserved to handle missing files, mimicking the original logic.
- **Naming**: Identifiers like `regreslope`, `vregreslope`, `goodsession` were kept as is, while `cp` was implemented as a class to hold parameters.
- **Excel Writing**: The `Range` parameter in Matlab's `writetable` was mapped to `startcol` in Pandas `to_excel`.
- **Plotting**: `scatter` and `plot` calls were mapped to Matplotlib equivalents. `Normalization='Probability'` in Matlab's `histogram` was implemented using `weights` in Matplotlib's `hist`.

"""



import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy import stats
from scipy.io import loadmat, savemat

class ConfigParams:
    def __init__(self):
        self.datadir = "/home/naeem_md93/Projects/Neupane_Fiete_Jazayeri_mental_navigation-main/data/Fig1/"
        self.savedir_ = '/home/naeem_md93/Projects/Neupane_Fiete_Jazayeri_mental_navigation-main/data_figs'
        self.example_mnav_sessionA = 'amadeus08272019_a'
        self.example_mnav_sessionM = 'mahler03262021_a'
        self.example_nts_sessionA = 'amadeus08292019_a'
        self.example_nts_sessionM = 'mahler03282021_a'
        self.example_seq = 1
        self.generalization_seq_a = 1
        self.generalization_seq_m = 2
        self.mintrial_in_session = 400
        self.num_generalizationtest_sessions = 6

def fitlm(x, y):
    """Helper to mimic Matlab's fitlm for simple linear regression."""
    slope, intercept, r_value, p_value, std_err = stats.linregress(x, y)
    # Adjusted R-squared calculation
    n = len(x)
    adj_r_squared = 1 - (1 - r_value**2) * (n - 1) / (n - 2) if n > 2 else 0
    
    class FitResult:
        def __init__(self, slope, intercept, adj_r_squared):
            self.Coefficients = type('obj', (object,), {'Estimate': [intercept, slope]})
            self.Rsquared = type('obj', (object,), {'Adjusted': adj_r_squared})
            
    return FitResult(slope, intercept, adj_r_squared)

def get_generalization_plots(filename, cp, savefig, sequence):
    plotgen = 1
    os.chdir(os.path.join(cp.savedir_, 'Fig1'))
    
    # Load main data file
    data = loadmat(cp.datadir + "/" + filename + '.mat', squeeze_me=True)
    # Extract variables from loaded mat into local scope
    globals().update({k: v for k, v in data.items() if not k.startswith('__')})
    
    processed_filename = f"fig1ce_data_{filename[:-4]}_seq{sequence}.mat"
    
    if os.path.exists(cp.datadir + "/" + processed_filename):
        proc_data = loadmat(cp.datadir + "/" +processed_filename, squeeze_me=True)
        # Extract variables
        regreslope = proc_data['regreslope']
        vregreslope = proc_data['vregreslope']
        seen = proc_data['seen']
        unseen = proc_data['unseen']
        allpairs = proc_data['allpairs']
        mtr = proc_data['mtr']
        vtr = proc_data['vtr']
        # Matlab stores logicals as uint8 in .mat files; cast explicitly so
        # boolean-mask indexing (regretemp[goodsesstemp]) filters correctly
        # instead of being interpreted as integer fancy indexing.
        goodsession = proc_data['goodsession'].astype(bool)
        vgoodsession = proc_data['vgoodsession'].astype(bool)
        expid = proc_data['expid']
        expallpairs = proc_data['expallpairs']
    else:
        # Processing raw behavioral data
        animal_char = filename[0]
        if animal_char == 'a':
            mttfolder = '/Users/Sujay/Dropbox (MIT)/mtt_data/'
            if sequence == cp.generalization_seq_a:
                plotgen = 1
            # Mimic eval logic for expid
            expid_seq = data[f"{animal_char}_expid_seq{sequence}"]
            expid_seq12 = data[f"{animal_char}_expid_seq12"]
            expid_seq4 = data[f"{animal_char}_expid_seq4"]
            expid = np.vstack([expid_seq, expid_seq12, expid_seq4])
        elif animal_char == 'm':
            mttfolder = '/Users/Sujay/Dropbox (MIT)/mtt_data_mahler/'
            if sequence == cp.generalization_seq_m:
                plotgen = 1
            expid_seq = data[f"{animal_char}_expid_seq{sequence}"]
            expid_seq12 = data[f"{animal_char}_expid_seq12"]
            expid_seq4 = data[f"{animal_char}_expid_seq4"]
            expid_seq124 = data[f"{animal_char}_expid_seq124"]
            expid = np.vstack([expid_seq, expid_seq12, expid_seq4, expid_seq124])
            
        expallpairs = data[f"{animal_char}_expid_seq12"]
        
        num_exps = expid.shape[0]
        regreslope = np.zeros((num_exps, 2))
        regres_adjrsq = np.zeros((num_exps, 2))
        vregreslope = np.zeros((num_exps, 2))
        seen = np.zeros(num_exps, dtype=bool)
        unseen = np.zeros(num_exps, dtype=bool)
        allpairs = np.zeros(num_exps, dtype=bool)
        mtr = np.zeros(num_exps)
        vtr = np.zeros(num_exps)
        goodsession = np.zeros(num_exps, dtype=bool)
        vgoodsession = np.zeros(num_exps, dtype=bool)
        
        allpairsstart = 0
        for exp in range(num_exps):
            current_expid = expid[exp, :].strip()
            print(current_expid)
            
            session_data_path = ""
            if animal_char == 'm':
                session_data_path = os.path.join(mttfolder, current_expid + '.mwk', current_expid + '.mat')
            else:
                path1 = os.path.join(mttfolder, current_expid + '.mwk', f"concat_{current_expid[:-2]}.mat")
                path2 = os.path.join(mttfolder, current_expid + '.mwk', current_expid + '.mat')
                path3 = os.path.join(mttfolder, current_expid[:-2], f"concat_{current_expid[:-2]}.mat")
                if os.path.exists(path1): session_data_path = path1
                elif os.path.exists(path2): session_data_path = path2
                else: session_data_path = path3
            
            sess = loadmat(session_data_path, squeeze_me=True)
            tp = sess['tp']
            ta = sess['ta']
            mask = sess['mask']
            attempt = sess['attempt']
            
            if current_expid == expallpairs[0, :].strip():
                allpairsstart = 1
            
            if allpairsstart == 0:
                seqq = np.full(tp.shape, sequence)
            else:
                seqq = sess['seqq']

            # Mental trials
            g = np.where((mask == 1) & (np.abs(tp) < 10) & (seqq == sequence))[0]
            if len(g) > 1:
                temp = fitlm(np.abs(ta[g]), np.abs(tp[g]))
                regreslope[exp, 0] = temp.Coefficients.Estimate[1]
                
                temp = fitlm(ta[g], tp[g])
                regreslope[exp, 1] = temp.Coefficients.Estimate[1]
                regres_adjrsq[exp, 1] = temp.Rsquared.Adjusted

            # Visual trials
            gv = np.where((mask < 1) & (np.abs(tp) < 10) & (seqq == sequence))[0]
            if len(gv) > 1:
                temp = fitlm(np.abs(ta[gv]), np.abs(tp[gv]))
                vregreslope[exp, 0] = temp.Coefficients.Estimate[1]
                temp = fitlm(ta[gv], tp[gv])
                vregreslope[exp, 1] = temp.Coefficients.Estimate[1]

            unique_ta = np.unique(ta)
            seen[exp] = (3.25 in unique_ta) and (len(unique_ta) < 10)
            unseen[exp] = (-3.25 in unique_ta)
            allpairs[exp] = (len(unique_ta) == 10)
            mtr[exp] = np.sum((mask == 1) & (seqq == sequence))
            vtr[exp] = np.sum((mask < 1) & (seqq == sequence))
            
            goodsession[exp] = np.sum((mask == 1) & (attempt < 2) & (seqq == sequence)) > cp.mintrial_in_session
            vgoodsession[exp] = np.sum((mask < 1) & (attempt < 2) & (seqq == sequence)) > cp.mintrial_in_session

    mnavtr = np.where(regreslope[:, 1] != 0)[0][0]
    switchtr = np.where(unseen)[0][0]
    
    temp_idx = np.where(allpairs)[0]
    switchallapirs = temp_idx[temp_idx > switchtr][0]

    if plotgen == 1:
        plt.figure()
        train_range = np.arange(mnavtr, switchtr)
        test_range = np.arange(switchtr, switchtr + cp.num_generalizationtest_sessions + 1)
        
        plt.plot(train_range - mnavtr, regreslope[train_range, 1], '-ob', label='train pairs')
        plt.plot(test_range - mnavtr, regreslope[test_range, 1], '-or', label='test pairs')
        plt.grid(True)
        plt.title(f"{filename[:-4]}: regression slope")
        plt.xlabel('sessions')
        plt.ylabel('performance (regression slope)')
        plt.legend()
        plt.tick_params(labelsize=15)
        
        if savefig:
            plt.savefig(os.path.join(cp.savedir_, f"Fig1e_{filename[:-4]}_generalization_seq{sequence}.eps"), format='eps')
            
            regression_slope_training = regreslope[train_range, 1]
            regression_slope_test = regreslope[test_range, 1]
            
            trainid = np.concatenate([np.ones(len(regression_slope_training)), np.zeros(len(regression_slope_test))])
            regression_slope = np.concatenate([regression_slope_training, regression_slope_test])
            nhp_id = np.full(len(trainid), filename[0])
            
            df = pd.DataFrame({'nhp_id': nhp_id, 'trainid': trainid, 'regression_slope': regression_slope})
            animal_name = 'amadeus' if filename.startswith('amadeus') else 'mahler'
            
            excel_path = os.path.join(cp.savedir_, 'Fig1.xlsx')
            if os.path.exists(excel_path):
                writer_kwargs = dict(mode='a', if_sheet_exists='overlay')
            else:
                writer_kwargs = dict(mode='w')
1            with pd.ExcelWriter(excel_path, engine='openpyxl', **writer_kwargs) as writer:
                startcol = 0 if animal_name == 'amadeus' else 4
                df.to_excel(writer, sheet_name='fig_1e', index=False, startcol=startcol)

    # Regression slope distribution
    plt.figure()
    regretemp = regreslope[switchtr:, 1]
    goodsesstemp = goodsession[switchtr:]
    regretemp = regretemp[goodsesstemp]
    
    plt.hist(regretemp, bins=np.arange(-1, 1.05, 0.05), weights=np.ones(len(regretemp)) / len(regretemp))
    plt.ylim([0, 0.3])
    plt.xlabel('Regression slope')
    plt.ylabel('Pr')
    plt.title(f"{filename[:5]} {len(regretemp)} sessions")
    plt.tick_params(labelsize=15)
    plt.yticks(np.arange(0, 0.35, 0.05))

    if savefig:
        plt.savefig(os.path.join(cp.savedir_, f"Fig1c_{filename[:-4]}_regressionSlopes_seq{sequence}.eps"), format='eps')
        savemat(processed_filename, {
            'filename': filename, 'expid': expid, 'expallpairs': expallpairs, 
            'sequence': sequence, 'regreslope': regreslope, 'vregreslope': vregreslope,
            'seen': seen, 'unseen': unseen, 'allpairs': allpairs, 'mtr': mtr, 'vtr': vtr,
            'goodsession': goodsession, 'vgoodsession': vgoodsession
        })
        
        nhp_id = np.full(len(regretemp), filename[0])
        df_dist = pd.DataFrame({'nhp_id': nhp_id, 'regression_slope_distribution': regretemp})
        animal_name = 'amadeus' if filename.startswith('amadeus') else 'mahler'
        
        excel_path = os.path.join(cp.savedir_, 'Fig1.xlsx')
        if os.path.exists(excel_path):
            writer_kwargs = dict(mode='a', if_sheet_exists='overlay')
        else:
            writer_kwargs = dict(mode='w')
        with pd.ExcelWriter(excel_path, engine='openpyxl', **writer_kwargs) as writer:
            startcol = 0 if animal_name == 'amadeus' else 4
            df_dist.to_excel(writer, sheet_name='fig_1c', index=False, startcol=startcol)

def get_tatp(mtt_folder, cp, savefig, animal):
    whichseq = cp.example_seq
    if animal[0] == 'a':
        file_mworks = cp.example_mnav_sessionA
    else:
        file_mworks = cp.example_mnav_sessionM

    try:
        os.chdir(mtt_folder)
        data = loadmat(file_mworks + '.mat', squeeze_me=True)
        # Extract variables
        mask = data['mask']
        seqq = data['seqq']
        tp = data['tp']
        ta = data['ta']
        trial_type = data['trial_type']
        validtrials_mm = data['validtrials_mm']
    except Exception as e:
        print(f"Session: {file_mworks} data missing. Preprocess it first. | {repr(e)}")
        return None

    plt.figure()
    randthick = 0.25
    g = (mask == 1) & (seqq == whichseq) & (tp < 99) & (np.abs(tp) > 0.01) & (trial_type == 3) & (validtrials_mm == 1)
    gg = (mask == 1) & (seqq == whichseq) & (tp < 99) & (np.abs(tp) > 0.01) & (trial_type == 3) & (validtrials_mm == 0)
    ggg = g | gg
    
    taa = np.unique(ta[g])
    jitter = np.random.rand(len(ta)) * randthick
    
    plt.scatter(ta[ggg] + jitter[ggg], tp[ggg], 15, c='k', marker='o')
    plt.scatter(ta[g] + jitter[g], tp[g], 15, c='r', marker='o')
    
    plt.plot([-6, 6], [-6, 6], '--k')
    plt.grid(True)
    plt.xlabel('ta(sec)')
    plt.ylabel('tp(sec)')
    plt.gca().set_aspect('equal', adjustable='box')
    plt.tick_params(labelsize=15)
    
    plt.xticks(taa[::3] + randthick/2, taa[::3])
    plt.yticks(taa[::3] + randthick/2, taa[::3])
    plt.axis([-5, 5, -5, 5])

    tatplm = fitlm(ta[g], tp[g])
    xx = np.array([-5, 5])
    yy = tatplm.Coefficients.Estimate[1] * xx + tatplm.Coefficients.Estimate[0]
    plt.plot(xx, yy, '-r', linewidth=2)

    tatplmall = fitlm(ta[ggg], tp[ggg])
    yy_all = tatplmall.Coefficients.Estimate[1] * xx + tatplmall.Coefficients.Estimate[0]
    plt.plot(xx, yy_all, '-k', linewidth=2)

    plt.title(f"tp = {round(tatplm.Coefficients.Estimate[1], 2)}*ta + {round(tatplm.Coefficients.Estimate[0], 2)}, "
              f"tp = {round(tatplmall.Coefficients.Estimate[1], 2)}*ta + {round(tatplmall.Coefficients.Estimate[0], 2)}")

    if savefig:
        os.chdir(cp.savedir_)
        plt.savefig(f"Fig1b{file_mworks}_example_mnav.eps", format='eps')
        plt.savefig(f"Fig1b{file_mworks}_example_mnav.png", format='png')

        va_mnav = ta[ggg]
        vp_mnav = tp[ggg]
        nhp_id = np.full(len(va_mnav), file_mworks[0])
        df = pd.DataFrame({'nhp_id': nhp_id, 'va_mnav': va_mnav, 'vp_mnav': vp_mnav})
        # Excel writing logic commented in original

    # Visual trials plot
    if animal[0] == 'a':
        file_mworks = cp.example_nts_sessionA
    else:
        file_mworks = cp.example_nts_sessionM

    try:
        os.chdir(mtt_folder)
        data_v = loadmat(file_mworks + '.mat', squeeze_me=True)
        mask_v = data_v['mask']
        seqq_v = data_v['seqq']
        tp_v = data_v['tp']
        ta_v = data_v['ta']
        trial_type_v = data_v['trial_type']
    except Exception:
        print(f"preprocess {file_mworks} first")
        return None

    g_v = (seqq_v < 3) & (trial_type_v < 3) & (tp_v < 4) & (np.abs(tp_v) > 0.01)
    
    if not np.any(g_v):
        print('no visual trials on this session')
    else:
        plt.figure()
        taa_v = np.unique(ta_v[g_v])
        jitter_v = np.random.rand(len(ta_v)) * randthick
        
        plt.scatter(ta_v[g_v] + jitter_v[g_v], tp_v[g_v], 15, c='k', marker='o')
        plt.plot([-6, 6], [-6, 6], '--k')
        plt.grid(True)
        plt.xlabel('ta(sec)')
        plt.ylabel('tp(sec)')
        plt.gca().set_aspect('equal', adjustable='box')
        plt.tick_params(labelsize=15)
        
        plt.xticks(taa_v[::3] + randthick/2, taa_v[::3])
        plt.yticks(taa_v[::3] + randthick/2, taa_v[::3])
        plt.axis([-5, 5, -5, 5])

        tatplm_v = fitlm(ta_v[g_v], tp_v[g_v])
        yy_v = tatplm_v.Coefficients.Estimate[1] * xx + tatplm_v.Coefficients.Estimate[0]
        plt.plot(xx, yy_v, '-r', linewidth=2)
        plt.title(f"tp = {round(tatplm_v.Coefficients.Estimate[1], 2)}*ta + {round(tatplm_v.Coefficients.Estimate[0], 2)}")

        if savefig:
            os.chdir(cp.savedir_)
            plt.savefig(f"FigS1b{file_mworks}_example_NTS.eps", format='eps')
            
            va_nts = ta_v[g_v]
            vp_nts = tp_v[g_v]
            nhp_id = np.full(len(va_nts), file_mworks[0])
            df_nts = pd.DataFrame({'nhp_id': nhp_id, 'va_nts': va_nts, 'vp_nts': vp_nts})
            
            excel_path = os.path.join(cp.savedir_, 'FigS1.xlsx')
            if os.path.exists(excel_path):
                writer_kwargs = dict(mode='a', if_sheet_exists='overlay')
            else:
                writer_kwargs = dict(mode='w')
            with pd.ExcelWriter(excel_path, engine='openpyxl', **writer_kwargs) as writer:
                startcol = 0 if animal == 'amadeus' else 4
                df_nts.to_excel(writer, sheet_name='fig_S1', index=False, startcol=startcol)

    return tatplm

# Main execution block
if __name__ == "__main__":
    cp = ConfigParams()
    # mkdir logic
    if not os.path.exists(os.path.join(cp.savedir_, 'Fig1')):
        os.makedirs(os.path.join(cp.savedir_, 'Fig1'), exist_ok=True)

    # Fig 1b and S1
    savefig = 1
    tatplm_a = get_tatp(cp.datadir, cp, savefig, 'amadeus')
    tatplm_m = get_tatp(cp.datadir, cp, savefig, 'mahler')

    # Generalization plots
    savefig = 1
    get_generalization_plots('mahler_exp', cp, savefig, 2)
    get_generalization_plots('/amadeus_exp', cp, savefig, 1)
