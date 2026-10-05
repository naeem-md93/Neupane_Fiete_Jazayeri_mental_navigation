% Neupane, Fiete, Jazayeri 2024 mental navigation paper 
% Fig 2 plot reproduction

%Download preprocessed Fig2 data from this link into your local folder:
% https://www.dropbox.com/scl/fo/2y2cfmb4txb14ue6ltjto/AFmH8za6FRBwt11Vr4YWHoA?rlkey=3wq69gdselb50py6fchltvwia&dl=0

%Download preprocessed tensor data from this link into your local folder:
% https://www.dropbox.com/scl/fo/nw6zals6ayf0w7vszysbl/h?rlkey=e4c8ee6rr9iv7k218ybym6e1b&dl=0

%for questions or further data/code access contact sujayanyaupane@gmail.com
%=============================================================================

%Fig2: nav_fig2_periodicity

clear

%constants and parameters:
cp.area='EC';
%change the data location to your local folder:
cp.savedir_='/data_figs'; 
% mkdir([cp.savedir_ '/Fig2']); %if the folder doesn't exist, make one and download data there
cp.datafolder=[cp.savedir_ '/Fig2/data'];
cp.tensordatafolder=['/Users/Sujay/Dropbox (MIT)/physiology_data_for_sharing/' cp.area]; %change this folder to your local folder you downloaded tensor data

cp.save_example_figures=0; %set to 1 to save figures
cp.save_plot_data_for_publication =0; %set 1 to save plotted data as required by the journal
cp.example_neuron_animal='amadeus'; %'mahler'
cp.example_neuron_fr=[5 2; 1 13];%Fig 2a eg neurons in the paper- sess5:amadeus08292019_a_neur2 and sess1:amadeus08152019_a_neur13
cp.example_neuron_raster=[5 49];%Fig 2b
cp.example_neuron_underover=33;
cp.example_neuron_motorresp=[3 20; 5 28];%Fig S13 monkey A session 3 neur 20 and monkey A session 5 neur 28
cp.example_neuron_fanofac=[1 5 22 1;2  1 2 -1];%Fig S11 monkey A(=1) session 5 neur 22 dir 1 and monkey M(=2) session 1 neur 2 dir -1

cp.lowfr_thres=.005; %to remove unstable neuron's trials with 0 spikes; set this value to a negative number to see that all results hold even without this trial thresholding
cp.mintrial = 15; %to exclude neurons with less than minimum trials in long distance conditions to avid spurious periodicity resulting from Poisson noise. This happens if some neurons go silent in the middle of a session.
cp.trialfraction=3; %trials divided into tertiles a/c to timing error to compare periodicity of undershoot and overshoot trials
cp.under_over_dist=3;%conditions of dist3 was tested for periodicity vs udershoot overshoot timing error across top and bottom tertiles
cp.gausswin=.2;
cp.gaussstd=.1;
cp.seq=12; %which sequence? 1 or 2 or 12 (=combined)
cp.suffix = '';%'_neglowfr_thres';

%periodicity and talk modulation parameters:
%periodicity parameters:
cp.spontdur_iti_thres=4.3;% inter-trial spont activity to compute periodicity on if ITI duration is longer than this threshold
cp.cutoff_acg =.5;        % time window to truncate from joystick offset to remove motor preparator response on periodicity calculation
cp.maxlag=2400;           % lag in ms to compute periodicity (autocorrelation) over
cp.dist_trials_periodicity = 3; %pool trials greater than or equal to this distance


%task modulation parameters:
cp.timerange = [-1 -.4];        %time range re. joystick offset to compute distance modulation over
cp.mintrials_taskmodulation=6;  %minimum trial threshold to exclude neurons
cp.dist_trials_mod = 2;         %include trials greater than or equal to this distance
cp.checkpsthplots=0;            %debug variable to check psth plots
cp.savetaskmodfig=0;


%ramp parameters:
cp.mintp_ramp = 2; %min tp in sec

%motor response parameters:
cp.minimnumtp_motor=1.5;
cp.motor_window=[-.4 -.1];
cp.mnav_window=[-1 -.6 ];

%fanofactor paramters
cp.fanoaccmaxlag=1.6;
cp.gridnessat=[.65 .25];
cp.fanofac_JScutoff=2.3; 

cp.geteyehand=1;
%% Fig2a: single neuron examples of psth
% mkdir([cp.savedir_ '/Fig2']); %if the folder doesn't exist, make one and download data there

savefigs=cp.save_example_figures;
params.savedata=cp.savedir_;
params.savedir_area=cp.savedir_;
params.hcol=myrgb(5,[1 0 0],[0 0 1]);
params.animal=cp.example_neuron_animal;
params.area=cp.area;
allneur=0;%1 for all neurons, 0 for specified neurons, -1 for eye and hand 

for nn=1:size(cp.example_neuron_fr,1)
    params.neur=cp.example_neuron_fr(nn,2);
    params.ss=cp.example_neuron_fr(nn,1);

    % load data:
    [params,data]=load_data_single_neuron(params,allneur,cp);

    %plot scaled psth mental:
    if cp.seq==12
        trials= find(params.dir_condition==1 & params.trial_type==3 & params.seqq<3 & params.attempt==1 );
    else
        trials= find(params.dir_condition==1 & params.trial_type==3 & params.seqq==cp.seq & params.attempt==1  );
    end
    [hpsth,params.maxx,icfc2,T]=plot_scaled_psth(data,params,trials);
    if savefigs==1
        cd(params.savedata)
        hpsth.Renderer='Painters';
        saveas(hpsth,['Fig2a_' params.animal '_' params.area '_sess' num2str(params.ss) '_neur' num2str(params.neur) '_seq' num2str(cp.seq)],'epsc')


    end
    if cp.save_plot_data_for_publication==1
        cd(params.savedata)
        if nn==1
            writetable(T,'Fig2.xlsx','Sheet','fig_2a')
        else
            writetable(T,'Fig2.xlsx','Sheet','fig_2a','Range','J1')
        end
    end

end

%% FigS13: single neuron examples of motor response 

savefigs=cp.save_example_figures;
params.savedata=cp.savedir_;
params.savedir_area=cp.savedir_;
params.hcol=myrgb(5,[1 0 0],[0 0 1]);
params.animal=cp.example_neuron_animal;
params.area=cp.area;
allneur=0;%1 for all neurons, 0 for specified neurons, -1 for eye and hand 
cp.save_plot_data_for_publication=1;
for nn=1:size(cp.example_neuron_motorresp,1)
    params.neur=cp.example_neuron_motorresp(nn,2);
    params.ss=cp.example_neuron_motorresp(nn,1);

    % load data:
    [params,data]=load_data_single_neuron(params,allneur,cp);

    %plot scaled psth mental:
    if cp.seq==12
        trials= find(params.dir_condition==1 & params.trial_type==3 & params.seqq<3 & params.attempt==1 );
    else
        trials= find(params.dir_condition==1 & params.trial_type==3 & params.seqq==cp.seq & params.attempt==1  );
    end
    [hpsth,params.maxx,icfc2,T]=plot_scaled_psth(data,params,trials);
    if savefigs==1
        cd(params.savedata)
        hpsth.Renderer='Painters';
        saveas(hpsth,['Fig2a_' params.animal '_' params.area '_sess' num2str(params.ss) '_neur' num2str(params.neur) '_seq' num2str(cp.seq)],'epsc')


    end
    if cp.save_plot_data_for_publication==1
        cd(params.savedata)
        if nn==1
            writetable(T,'FigS13.xlsx','Sheet','fig_S13a')
        else
            writetable(T,'FigS13.xlsx','Sheet','fig_S13a','Range','J1')
        end
    end

end


%% Fig2bc: plot raster and ACG mental example neuron:
%monkey A neuron#49 session#5 trials = validtrials based on GMM
params.maxx=5;
params.neur=cp.example_neuron_raster(2);
params.ss=cp.example_neuron_raster(1);
allneur=0;
params.animal=cp.example_neuron_animal;
params.area=cp.area;

% load data:
[params,data]=load_data_single_neuron(params,allneur,cp);

[hfig,T]=plot_raster_acg(data,params,cp);
sgtitle([ params.animal ' ' params.area ' sess' num2str(params.ss) ' neur' num2str(params.neur) ' seq' num2str(cp.seq)])

if savefigs==1
    cd(cp.savedir_)
    hfig.Renderer='Painters';
    saveas(hfig,['Fig2bc_' params.animal '_' params.area '_sess' num2str(params.ss) '_neur' num2str(params.neur) '_seq' num2str(cp.seq)],'epsc')
    close all
end

writetable(T.Tacg,'Fig2.xlsx','Sheet','fig2c_left_acg');
writetable(T.Tpi,'Fig2.xlsx','Sheet','fig2c_right_PI')
acgtrxtr=T.Tacgtrxtr';
writematrix(acgtrxtr,'Fig2.xlsx','Sheet','fig2c_left_acg_trxtr')


%% FigS5c: plot single neuron e.g. under over periodicity w.r.t. timing error DONE seq 12, 1, 2
cp.egneuron_trialfraction=8; %e.g. neuron was plotted for dist4and 5 and error was divided into 8 bins instead of tertiles
params.neur=cp.example_neuron_underover;
[params,data]=load_data_single_neuron(params,allneur,cp);
T=plot_periodicity_wrt_error(data,params,cp);
if savefigs==1
    cd(cp.savedir_)
    hf=gcf;
    hf.Renderer='Painters';
    saveas(hf,['FigS5c_' params.animal '_' params.area '_sess' num2str(params.ss) '_neur' num2str(params.neur) '_seq' num2str(cp.seq)],'epsc')
    close all
end
if cp.save_plot_data_for_publication==1
    cd(params.savedir_area);
    writetable(T.Tautocorr,'FigS5.xlsx','Sheet','fig_S5c')
    writetable(T.TPI,'FigS5.xlsx','Sheet','fig_S5c','Range','D1')

end
%% Fig2e: plot single neuron bump phase w.r.t jotstick onset/offset:

[hoff,hon,T]=plot_raster_bump_phase(data,params,cp);
if savefig==1
    cd(params.savedata)
    hoff.Renderer='Painters';
    saveas(hoff,['Fig2e_' params.animal '_' params.area '_sess' num2str(params.ss) '_neur' num2str(params.neur) '_seq' num2str(cp.seq)],'epsc')
    close all

    writetable(T,'Fig2.xlsx','Sheet','fig_2e')

end

%% Fig2f and S5ab: bump phase across neurons:
%compute bump phase if not done so:

params.area=cp.area;
params.savedata=cp.datafolder;
params.savefig=0;
params.savephasedataflag=0;

if params.savephasedataflag==1
    params.animal='amadeus';
    seq=12;compute_save_bump_phase_stats(params,seq,cp)
    seq=1;compute_save_bump_phase_stats(params,seq,cp)
    seq=2;compute_save_bump_phase_stats(params,seq,cp)

    params.animal='mahler';
    seq=12;compute_save_bump_phase_stats(params,seq,cp)

end

% seq=1;
% hh1=plot_bump_phase_allneurons (params,seq,cp);
cp.suffix='';
seq=12;
[hh12,T]=plot_bump_phase_allneurons (params,seq,cp);
 

if params.savefig==1

    cd (cp.savedir_)
    hh12.Renderer='Painters';
    saveas(hh12,['Fig2fS5' '_' params.area  '_seq12'],'epsc');
    hh1.Renderer='Painters';
    saveas(hh1,['Fig2fS5' '_' params.area  '_seq1'],'epsc');

        writetable(T.Tboth,'Fig2.xlsx','Sheet','fig_2f')
        writetable(T.Thistedges,'Fig2.xlsx','Sheet','fig_2f','Range','F1')

        writetable(T.Tamadeus,'FigS5.xlsx','Sheet','fig_S5a')
        writetable(T.Thistedges,'FigS5.xlsx','Sheet','fig_S5a','Range','F1')

         writetable(T.Tmahler,'FigS5.xlsx','Sheet','fig_S5b')
        writetable(T.Thistedges,'FigS5.xlsx','Sheet','fig_S5b','Range','F1')
end


%% single trial autocorrelation and periodicity index across neurons

params.area=cp.area;
params.savedata=cp.datafolder;
params.savedataflag=0;
savefigs=0;
%compute periodicity index and task modulation parameters if not already done:
if params.savedataflag==1
    params.get_periodicity_modulation=1;
    params.get_task_modulation=1;
    params.get_ramp=1;
    params.get_motor_resp=1;

    params.animal = 'mahler';
    seq=12;get_periodicty_task_modulation(params,seq,cp);

    params.animal = 'amadeus';
    seq=12;get_periodicty_task_modulation(params,seq,cp);
    seq=1;get_periodicty_task_modulation(params,seq,cp);
    seq=2;get_periodicty_task_modulation(params,seq,cp);



end

%% single session P.I histogram:

params.area=cp.area;
params.savedata=cp.savedir_;
params.savefigs=0;
params.nSTD=2;
cp.mintrial=35; %test for 15 and 35 or any other value for minimun trial exclusion criteria
seq=12;
params.ss=1;
params.direction=1;
params.animal = 'mahler';
[h2dm,tabm]=get_single_session_PI(params,seq,cp);

params.ss=5;
params.direction=2;
params.animal = 'amadeus';
seq=12;
[h2da,taba]=get_single_session_PI(params,seq,cp);
% seq=1;
% h2daseq1=get_single_session_PI(params,seq,cp);
% seq=2;
% h2daseq2=get_single_session_PI(params,seq,cp);

if params.savefigs==1
    h2da.Renderer='Painters';
    h2dm.Renderer='Painters';

    cd(params.savedata)
    saveas(h2da,['Fig2d_' 'amadeus' '_' params.area '_periodicity_session' num2str(5) '_mintrial' num2str(cp.mintrial)],'epsc');
    saveas(h2dm,['Fig2d_' 'mahler' '_' params.area '_periodicity_session' num2str(1) '_mintrial' num2str(cp.mintrial)],'epsc');

    h2daseq1.Renderer='Painters';
    h2daseq2.Renderer='Painters';
    saveas(h2daseq1,['Fig2d_' 'amadeus' '_' params.area '_periodicity_session' num2str(5) 'seq1' '_mintrial' num2str(cp.mintrial)],'epsc');
    saveas(h2daseq2,['Fig2d_' 'amadeus' '_' params.area '_periodicity_session' num2str(5) 'seq2' '_mintrial' num2str(cp.mintrial)],'epsc');

    writetable(taba.session_id,'Fig2.xlsx','Sheet','fig_2d')
    writetable(taba.all_neurons,'Fig2.xlsx','Sheet','fig_2d','Range','B1')
    writetable(taba.periodic_neurons,'Fig2.xlsx','Sheet','fig_2d','Range','C1')
    writetable(taba.histogram_edges,'Fig2.xlsx','Sheet','fig_2d','Range','D1')

    writetable(tabm.session_id,'Fig2.xlsx','Sheet','fig_2d','Range','G1')
    writetable(tabm.all_neurons,'Fig2.xlsx','Sheet','fig_2d','Range','H1')
    writetable(tabm.periodic_neurons,'Fig2.xlsx','Sheet','fig_2d','Range','I1')
    writetable(tabm.histogram_edges,'Fig2.xlsx','Sheet','fig_2d','Range','J1')

end

%%  across sessions P.I histogram and PI at 650ms in mental vs err trials and ITI:

params.area=cp.area;
params.savedata=cp.savedir_;
params.savefig=0;
params.savedataflag=0;
params.nSTD=2;

for dirr= [1 2]
    params.direction=dirr;

     
    params.animal = 'amadeus';
    seq=12;
    [hseq12, Ta]=get_overall_PI(params,seq,cp);
%     seq=1;
%     hseq1=get_overall_PI(params,seq,cp);
%     seq=2;
%     hseq2=get_overall_PI(params,seq,cp);

   params.animal = 'mahler';
    seq=12;
    [mseq12, Tm]=get_overall_PI(params,seq,cp);



    if params.savefig==1

        cd (params.savedata)
        hseq12.Renderer='Painters';
        saveas(hseq12,['FigS3_amadeus' '_' params.area  '_dir' num2str(params.direction) '_seq12' cp.suffix],'epsc');
        hseq1.Renderer='Painters';
        saveas(hseq1,['FigS3_amadeus'   '_' params.area  '_dir' num2str(params.direction) '_seq1' cp.suffix],'epsc');
        hseq2.Renderer='Painters';
        saveas(hseq2,['FigS3_amadeus'   '_' params.area  '_dir' num2str(params.direction) '_seq2' cp.suffix],'epsc');

        mseq12.Renderer='Painters';
        saveas(mseq12,['FigS3_mahler'   '_' params.area  '_dir' num2str(params.direction) cp.suffix],'epsc');

        if dirr==1
            writetable(Ta.Ta,'FigS3.xlsx','Sheet','fig_S3a')
            writetable(Ta.Ta_histedges,'FigS3.xlsx','Sheet','fig_S3a','Range','C1')

            writetable(Tm.Ta,'FigS3.xlsx','Sheet','fig_S3a','Range', 'F1')
            writetable(Tm.Ta_histedges,'FigS3.xlsx','Sheet','fig_S3a','Range','H1')

            writetable(Ta.Tb,'FigS3.xlsx','Sheet','fig_S3bb')
            writetable(Tm.Tb,'FigS3.xlsx','Sheet','fig_S3bb','Range','E1')

            writetable(Ta.Tc,'FigS3.xlsx','Sheet','fig_S3cc')
            writetable(Tm.Tc,'FigS3.xlsx','Sheet','fig_S3cc','Range','E1')


        else
            writetable(Ta.Ta,'FigS3.xlsx','Sheet','fig_S3a','Range','K1')
            writetable(Ta.Ta_histedges,'FigS3.xlsx','Sheet','fig_S3a','Range','M1')

            writetable(Tm.Ta,'FigS3.xlsx','Sheet','fig_S3a','Range', 'P1')
            writetable(Tm.Ta_histedges,'FigS3.xlsx','Sheet','fig_S3a','Range','R1')

            writetable(Ta.Tb,'FigS3.xlsx','Sheet','fig_S3bb','Range','I1')
            writetable(Tm.Tb,'FigS3.xlsx','Sheet','fig_S3bb','Range','M1')

            writetable(Ta.Tc,'FigS3.xlsx','Sheet','fig_S3cc','Range','I1')
            writetable(Tm.Tc,'FigS3.xlsx','Sheet','fig_S3cc','Range','M1')


        end


    end

    %     close all

end
%% ramp, periodic neurons left vs right direction
params.savefig=0;
trxtrreg=0;
params.animal='mahler';seqid=cp.seq;
disp (['=========' params.animal '=========: '])
count_ramp_periodicity_leftright(params,trxtrreg,seqid,cp)

params.animal='amadeus';seqid=cp.seq;
disp (['=========' params.animal '=========: '])
count_ramp_periodicity_leftright(params,trxtrreg,seqid,cp)

%% test for motor-activity for non-periodic neurons
% Qasim et al 2019 type cells

param.area=cp.area;
param.animal = 'amadeus';
param.savedata=cp.datafolder;
direction=1;
mintr=15;
clc
cd(param.savedata)
load([param.animal '_' param.area '_allNeurons_gridness_dir' num2str(direction) '_seq12' cp.suffix],'sessions_all','neurons_all','gridness_mall','num_trials_mall','motor_resp_all','params')

nongridcells = (gridness_mall<=params.gridness_thres_pc_abov_mean &  num_trials_mall>mintr);% & gridness_.gridness_max_periodicity<1000 & gridness_.gridness_max_periodicity>220);
motorcells=(motor_resp_all==1 &  num_trials_mall>mintr);
motor_nongird = motorcells==1 & nongridcells==1;

disp([params.animal ' area ' params.area '% of motor nonperiodic neurons=' num2str(100*length(find(motor_nongird))/length(find(nongridcells))) ...
    '(' num2str(length(find(motor_nongird))) '/' num2str(length(find(nongridcells))) ')'])

disp([params.animal ' area ' params.area '% of overall motor neurons=' num2str(100*length(find(motorcells))/length((motorcells))) ...
    '(' num2str(length(find(motorcells))) '/' num2str(length((motorcells))) ')'])


%% binomial test for proportion of cells 99/614 for A and 74/864 for M

pvalA = 1 - binocdf(99,614,.05)
pvalM = 1 - binocdf(74,864,.05)

%% FigS4: plot eye and hand signal and PI index: to do: copy code over here from nav_fig2_periodicity_eyehand.m
%monkey A sess5
params.maxx=20;
params.ss=cp.example_neuron_raster(1);
savefigs=cp.save_example_figures;
params.savedata=cp.savedir_;
params.savedir_area=cp.savedir_;
params.hcol=myrgb(5,[1 0 0],[0 0 1]);
params.animal=cp.example_neuron_animal;
params.area=cp.area;
allneur=-1; %1 for all neurons, 0 for specified neurons, -1 for eye and hand 


% load data:
[params,data]=load_data_single_neuron(params,allneur,cp);

[hfig,T]=plot_eyehand_acg(data,params,cp);
sgtitle([ params.animal ' ' params.area ' sess' num2str(params.ss) ' eye_hand'])

if savefigs==1
    cd(params.savedata)
    hfig.Renderer='Painters';
    saveas(hfig,['FigS4_' params.animal '_' params.area '_sess' num2str(params.ss) '_eyehand'],'epsc')
    close all
end


%% get undershoot and overshoot periodicity across all sessions and neurons

params.area=cp.area;
params.savedataflag=1;
if params.savedataflag==1
    %compute periodicity for under an overshoot trials for periodic
    %neurons:
    params.animal='amadeus';
    seq=12;
    get_periodicity_under_over_conditioned_by_distance(params,seq,cp);
    seq=1;
    get_periodicity_under_over_conditioned_by_distance(params,seq,cp);
    params.animal='mahler';
    seq=12;
    get_periodicity_under_over_conditioned_by_distance(params,seq,cp);

end


%% Fig S5d: plot over under periodicity conditioned on distance 

savefigures=0;
params.area=cp.area;
params.animal = 'mahler';
cd(cp.datafolder)
if isempty(cp.suffix)
    load([params.animal '_' params.area '_periodicity_underover_dist345_separatedTHRD'],'underoverP');
else
    load([params.animal '_' params.area '_periodicity_underover_dist345_separatedTHRD_seq12' cp.suffix],'underoverP');

end

joystick='on';nn=[];sess=[];
figure('Position',[  744         247        1070         802]);
for dist=cp.under_over_dist
    under_r=[];over_r=[];under_l=[];over_l=[];under=[];over=[];
    for ss=1:length(underoverP)
        switch joystick
            case 'on'
                try
                    under_r=[under_r; underoverP{ss}.underPr(:,dist)];
                    over_r=[over_r; underoverP{ss}.overPr(:,dist)];
                    nn=[nn 1:length(underoverP{ss}.underPr(:,dist))];
                    sess=[sess; ss*ones(length(underoverP{ss}.underPr(:,dist)),1)];
                    under_l=[under_l; underoverP{ss}.underPl(:,dist)];
                    over_l=[over_l; underoverP{ss}.overPl(:,dist)];

                    under=[under; underoverP{ss}.underP(:,dist)];
                    over=[over; underoverP{ss}.overP(:,dist)];
                catch;end

            case 'off'
                try
                    under_r=[under_r; underoverP{ss}.underProff(:,dist)];
                    over_r=[over_r; underoverP{ss}.overProff(:,dist)];

                    under_l=[under_l; underoverP{ss}.underPloff(:,dist)];
                    over_l=[over_l; underoverP{ss}.overPloff(:,dist)];

                    under=[under; underoverP{ss}.underPoff(:,dist)];
                    over=[over; underoverP{ss}.overPoff(:,dist)];
                catch;end
        end

    end
    p_thres=1000;
    g=under_r>p_thres | isnan(under_r) | over_r>p_thres | isnan(over_r) | under_r==0 | over_r==0;
    under_r(g)=[];
    over_r(g)=[];
    nn(g)=[];sess(g)=[];

    g=under_l>p_thres | isnan(under_l) | over_l>p_thres | isnan(over_l) |under_l==0 | over_l==0;
    under_l(g)=[];
    over_l(g)=[];

    g=under>p_thres | isnan(under) | over>p_thres | isnan(over) | under==0 | over==0;
    under(g)=[];
    over(g)=[];

    subplot(2,2,2);
    scatter(under_r, over_r,20,'o','Filled');hold on; plot([0 1200],[0 1200],'-k');
    addline(650); addline(650,'h');
    xlabel 'periodicity undershoot trials'; ylabel 'periodicity overshoot trials';
    set(gca,'Xtick',0:325:1200,'Ytick',0:325:1200,'FontSize',20);
    [p,h,stats] = ranksum(under_r,over_r);axis square
    title(['Dir right:ranksum(' num2str(length(under_r))  ')= ' num2str(stats.zval) ',p=' num2str(p) ])


    subplot(2,2,1);
    scatter(under_l, over_l,20,'o','Filled');hold on; plot([0 1200],[0 1200],'-k');
    addline(650); addline(650,'h');
    xlabel 'periodicity undershoot trials'; ylabel 'periodicity overshoot trials';
    set(gca,'Xtick',0:325:1200,'Ytick',0:325:1200,'FontSize',20);
    [p,h,stats] = ranksum(under_l,over_l);axis square
    title(['Dir left:ranksum(' num2str(length(under_l))  ')= ' num2str(stats.zval) ',p=' num2str(p) ])

    subplot(2,2,3);
    scatter(under, over,20,'o','Filled');hold on; plot([0 1200],[0 1200],'-k');
    addline(650); addline(650,'h');
    xlabel 'periodicity undershoot trials'; ylabel 'periodicity overshoot trials';
    set(gca,'Xtick',0:325:1200,'Ytick',0:325:1200,'FontSize',20);
    [p,h,stats] = ranksum(under,over);axis square
    title(['Dir merged: ranksum(' num2str(length(under))  ')= ' num2str(stats.zval) ',p=' num2str(p) ])

    subplot(2,2,4);
    histogram(under_r-over_r,-500:60:500);title 'Dir right'
    addline(nanmean(under_r-over_r),'color','r');

    periodicity_undershoot=under_r;
    periodicity_overshoot=over_r;
    periodicity_difference = under_r-over_r;
    animal_id = repmat([params.animal ' dist' num2str(cp.under_over_dist)],[length(periodicity_undershoot) 1]);
    T.Tdscatter = table(animal_id,periodicity_undershoot,periodicity_overshoot,periodicity_difference);


    hist_edges=-500:60:500;hist_edges=hist_edges';
    T.Tdhisto = table(hist_edges);
   
    if strcmp(params.animal(1),'a')

        writetable(T.Tdscatter,'FigS5.xlsx','Sheet','fig_S5d_left')
        writetable(T.Tdhisto,'FigS5.xlsx','Sheet','fig_S5d_left','Range','F1')
    else
        writetable(T.Tdscatter,'FigS5.xlsx','Sheet','fig_S5d_right')
        writetable(T.Tdhisto,'FigS5.xlsx','Sheet','fig_S5d_right','Range','F1')
    end

end
addline(0,'color','k');
xlabel 'periodicity difference'; ylabel '# periodic neurons'; set(gca,'FontSize',20);
sgtitle([params.animal ' ' params.area ' under over periodicity dist3 joystick' joystick])
if savefigures==1
    hf=gcf;
    hf.Renderer='Painters';
    cd(cp.savedir_)
    saveas(hf,['FigS5d_' params.animal '_' params.area '_under_over_periodicitydist3_joystick' joystick cp.suffix 'revised'],'epsc');
end

%% Fig S11 plot example neurons for fano factor 

params.area='EC';
params.savedata=[cp.savedir_ '/Fig4/data'];
params.fanoaccmaxlag=cp.fanoaccmaxlag; %seconds: max lag to compute fano factor autocorrelations at
gridnessat=cp.gridnessat;
params.aftoff=cp.fanofac_JScutoff;


params.animal='amadeus';

figure('Position',[   1029          56        1008         983]);
clear fano data
params.ss=cp.example_neuron_fanofac(1,2);
allneur=0;
params.neur=cp.example_neuron_fanofac(1,3);
plt=1;
[params,data]=load_data_single_neuron(params,allneur,cp);
dir=cp.example_neuron_fanofac(1,4);
[hf,T]=plot_fanofactor_exampleneuron(data,params,dir,plt,gridnessat,cp);
cd(params.savedata)
writetable(T.Tspk_fano,'FigS11.xlsx','Sheet','fig_S11a');
writetable(T.Tacg,'FigS11.xlsx','Sheet','fig_S11b');
saveas(hf,[params.filename '_dir' num2str(dir) '_cutoff' num2str(params.aftoff*10) '_Fano_fac_neur' num2str(params.neur)],'epsc');

%%
params.animal='mahler';

figure('Position',[   1029          56        1008         983]);
clear fano data
params.ss=cp.example_neuron_fanofac(2,2);
params.neur=cp.example_neuron_fanofac(2,3);
plt=1;
[params,data]=load_data_single_neuron(params,allneur,cp);
dir=cp.example_neuron_fanofac(2,4);
[hm,T]=plot_fanofactor_exampleneuron(data,params,dir,plt,gridnessat,cp);
cd(params.savedata)
writetable(T.Tspk_fano,'FigS11.xlsx','Sheet','fig_S11d');
writetable(T.Tacg,'FigS11.xlsx','Sheet','fig_S11e');
saveas(hm,[params.filename '_dir' num2str(dir) '_cutoff' num2str(params.aftoff*10) '_Fano_fac_neur' num2str(params.neur)],'epsc');

 

%% get fano factor for all neurons
% clear
params.animal='amadeus';
params.area='EC';
params.savedata=[cp.savedir_ '/Fig4/data'];
pltforsession=0;
allneur=1;
fanoaccmaxlag=cp.fanoaccmaxlag; 
gridnessat=cp.gridnessat; 
cutoff=cp.fanofac_JScutoff; 

load([cp.datafolder '/sessions/' ...
    params.animal '_' params.area '_sessions.mat'], 'sessions')

% figure('Position',[   1029          56        1008         983]);
    clear fano data
    for ss=[1:length(sessions)]
        if ss==pltforsession, plt=1; else, plt=0;end
        params.ss=ss;
        [params,data]=load_data_single_neuron(params,allneur,cp);

        params.fanoaccmaxlag=fanoaccmaxlag; %seconds: max lag to compute fano factor autocorrelations at
        params.aftoff=cutoff;
        clf; dir=1;
        fano{ss,dir}=plot_fanofactor(data,params,dir,plt,gridnessat);

        clf; dir=2;
        fano{ss,dir}=plot_fanofactor(data,params,dir,plt,gridnessat);

        cd(params.savedata)
        save([params.animal '_' params.area '_fanofac_bb_cutoff' num2str(params.aftoff*1000) 'ms_poissonNull_gridnessat' num2str(gridnessat(1)*1000) '_range_' num2str(gridnessat(2)*1000) '.mat'],'fano','params');
        disp([sessions{ss} '_' params.area '_fanofac_bb_cutoff' num2str(params.aftoff*1000) 'mspoissonNull_gridnessat' num2str(gridnessat(1)*1000) '_range_' num2str(gridnessat(2)*1000) '.mat is saved====']);
    end


%% functions
%== single neuron fano factor, reviewer's suggestion

function [hf,T]=plot_fanofactor_exampleneuron(data,params,dir,plt,gridnessat_range,cp)

xx=params.edges;
xxoff=params.edgesoff;
bef=0;
aftoff=params.aftoff;
fanoaccmaxlag = params.fanoaccmaxlag;
xtikson = bef:.65:3.25;
cutoff=.2;
binwidth=200;
slide=30;
fano=[];
nn=1;
gridnessat=gridnessat_range(1);
PIrange = gridnessat_range(2);

    params.lowfr_trials = (mean(squeeze(data.data_tensor_joyoff(1,params.edgesoff>-2 & params.edgesoff<0,:)),1)<cp.lowfr_thres)';
    trials_ = find(abs(params.tp)>=aftoff & params.dir_condition==dir & params.trial_type==3 & params.seqq<3 & params.attempt==1 & params.lowfr_trials==0);

    tt = xx>-binwidth/1000 & xx<0;


    tp_=abs(params.tp(trials_));
    aft= aftoff-cutoff;

    tt = xx>=bef & xx<aft;
    timet=xx(tt);
    timet=timet(1:slide:end);
    ttoff = xxoff>-aft & xxoff<=-bef;
    timetoff=xxoff(ttoff);
    timetoff=timetoff(1:slide:end);
    timet=timet(1:length(1:slide:length(find(tt))-binwidth));
    timetoff=timetoff(1:length(1:slide:length(find(ttoff))-binwidth));
    bb=100;
    clear sc sc_poi scoff_poi scoff
    dat=squeeze(data.data_tensor_joyon(1,tt,trials_));

    % NULL: pass mean spike count through a Poisson process 100 times and compute fanofactor
    [sc_poitemp, spktimes, psth]=genSpikes(1/1000,nanmean(dat,2)',aft,bb);
    sc_poitemp=sc_poitemp';

    tti=1;
    for ttt=1:slide:length(dat)-binwidth
        sc(:,tti)=1/1000*sum(dat(ttt:ttt+binwidth,:),1);%/basesc(nn);
        sc_poi(:,tti)=sum(sc_poitemp(ttt:ttt+binwidth,:),1);
        tti=tti+1;
    end



    dat=squeeze(data.data_tensor_joyoff(1,ttoff,trials_));
    % NULL: pass mean spike count through a Poisson process 100 times and compute fanofactor
    [sc_poitemp, spktimes, psth]=genSpikes(1/1000,nanmean(dat,2)',aft,bb);
    sc_poitemp=sc_poitemp';

    tti=1;
    for ttt=1:slide:length(dat)-binwidth
        scoff(:,tti)=1/1000*sum(dat(ttt:ttt+binwidth,:),1);%/basesc(nn);
        scoff_poi(:,tti)=sum(sc_poitemp(ttt:ttt+binwidth,:),1);
        tti=tti+1;
    end

    tempff= bootstrp(bb,@(x) var(x,1)./mean(x,1),sc);
    tempffoff= bootstrp(bb,@(x) var(x,1)./mean(x,1),scoff);
    temppoi= bootstrp(bb,@(x) var(x,1)./mean(x,1),sc_poi);
    temppoioff= bootstrp(bb,@(x) var(x,1)./mean(x,1),scoff_poi);

    acc_maxlag = find(timet>fanoaccmaxlag,1);
    fano.acg_maxlag=acc_maxlag;
    fano.ffacgtimet=linspace(-fanoaccmaxlag,fanoaccmaxlag,acc_maxlag*2+1);

    gridlag=find(fano.ffacgtimet>0,1):find(fano.ffacgtimet>1.2,1);
    fano.gridlags=fano.ffacgtimet(gridlag);



    id325=find(fano.ffacgtimet>(gridnessat*.5),1);id325=id325-1:id325+1;
    id650=find(fano.ffacgtimet>gridnessat,1);id650=id650-1:id650+1;
    id975=find(fano.ffacgtimet>(gridnessat*1.5),1);id975=id975-1:id975+1;


    for tr=1:size(temppoi,1)
        temptr=temppoi(tr,:);
        mdl = fitlm(1:length(timetoff),temptr); %choose where exactly to estimate ramp from
        ffdetrended=temptr-mdl.Coefficients.Estimate(2)*(1:length(timet));
        acgtr= xcorr(ffdetrended-nanmean(ffdetrended),acc_maxlag,'coeff');
        on.NULLgridness(tr)=nanmean(acgtr(id650)) - .5*nanmean(acgtr(id325)) - .5*nanmean(acgtr(id975));
        on.acgpoi(tr,:)= acgtr;

        for tlag = 1:length(gridlag)
            temp = corrcoef(acgtr,circshift(acgtr,round(tlag)))-corrcoef(acgtr,circshift(acgtr,round(.5*tlag)));
            ff_pi_tlagpoi(tlag,tr)=temp(2);
        end
        [~, periodicity] = max(ff_pi_tlagpoi(:,tr));
        on.ff_periodicitypoi(tr) = fano.gridlags(periodicity);

        temptr=temppoioff(tr,:);
        mdl = fitlm(1:length(timetoff),temptr); %choose where exactly to estimate ramp from
        ffdetrended=temptr-mdl.Coefficients.Estimate(2)*(1:length(timet));
        acgtr= xcorr(ffdetrended-nanmean(ffdetrended),acc_maxlag,'coeff');
        off.NULLgridness(tr)=nanmean(acgtr(id650)) - .5*nanmean(acgtr(id325)) - .5*nanmean(acgtr(id975));
        off.acgpoi(tr,:)= acgtr;
        for tlag = 1:length(gridlag)
            temp = corrcoef(acgtr,circshift(acgtr,round(tlag)))-corrcoef(acgtr,circshift(acgtr,round(.5*tlag)));
            ff_pi_tlagpoioff(tlag,tr)=temp(2);
        end
        [~, periodicity] = max(ff_pi_tlagpoioff(:,tr));
        off.ff_periodicitypoi(tr) = fano.gridlags(periodicity);

        temptr=tempff(tr,:);
        mdl = fitlm(1:length(timetoff),temptr); %choose where exactly to estimate ramp from
        ffdetrended=temptr-mdl.Coefficients.Estimate(2)*(1:length(timet));
        acgtr= xcorr(ffdetrended-nanmean(ffdetrended),acc_maxlag,'coeff');
        on.gridness(tr)=nanmean(acgtr(id650)) - .5*nanmean(acgtr(id325)) - .5*nanmean(acgtr(id975));
        on.acg(tr,:)= acgtr;

        for tlag = 1:length(gridlag)
            temp = corrcoef(acgtr,circshift(acgtr,round(tlag)))-corrcoef(acgtr,circshift(acgtr,round(.5*tlag)));
            ff_pi_tlagon(tlag,tr)=temp(2);
        end
        [~, periodicity] = max(ff_pi_tlagon(:,tr));
        on.ff_periodicity(tr) = fano.gridlags(periodicity);


        temptr=tempffoff(tr,:);
        mdl = fitlm(1:length(timetoff),temptr); %choose where exactly to estimate ramp from
        ffdetrended=temptr-mdl.Coefficients.Estimate(2)*(1:length(timet));
        acgtr= xcorr(ffdetrended-nanmean(ffdetrended),acc_maxlag,'coeff');
        off.gridness(tr)=nanmean(acgtr(id650)) - .5*nanmean(acgtr(id325)) - .5*nanmean(acgtr(id975));
        off.acg(tr,:)= acgtr;
        for tlag = 1:length(gridlag)
            temp = corrcoef(acgtr,circshift(acgtr,round(tlag)))-corrcoef(acgtr,circshift(acgtr,round(.5*tlag)));
            ff_pi_tlagoff(tlag,tr)=temp(2);
        end
        [~, periodicity] = max(ff_pi_tlagoff(:,tr));
        off.ff_periodicity(tr) = fano.gridlags(periodicity);



    end


    fano.on.ffgridness650(nn)=ttest2(on.NULLgridness,on.gridness,'Tail','left','Alpha',0.01,'Vartype','unequal');
    fano.off.ffgridness650(nn)=ttest2(off.NULLgridness,off.gridness,'Tail','left','Alpha',0.01,'Vartype','unequal');

    gridnesstest = find(fano.gridlags>(gridnessat-PIrange) & fano.gridlags<(gridnessat+PIrange));
    fano.on.ffgridness_range_pval(nn,:)=nan(1,length(1:gridnesstest(end)));
    fano.off.ffgridness_range_pval(nn,:)=nan(1,length(1:gridnesstest(end)));
    for tlag = gridnesstest
        nullon=ff_pi_tlagpoi(tlag,:);
        dataon=ff_pi_tlagon(tlag,:);
        [ ffgridnessrangeon(tlag) fano.on.ffgridness_range_pval(nn,tlag)]=ttest2(nullon,dataon,'Tail','left','Alpha',0.0001/length(gridnesstest),'Vartype','unequal');

        nullon=ff_pi_tlagpoioff(tlag,:);
        dataon=ff_pi_tlagoff(tlag,:);
        [ ffgridnessrangeoff(tlag) fano.off.ffgridness_range_pval(nn,tlag)]=ttest2(nullon,dataon,'Tail','left','Alpha',0.0001/length(gridnesstest),'Vartype','unequal');

    end

    fano.on.ffgridnessrange(nn)= any(ffgridnessrangeon);
    fano.off.ffgridnessrange(nn)= any(ffgridnessrangeoff) ;


    on.ff_periodicitypoi( on.ff_periodicitypoi>1.1)=[];
    on.ff_periodicity( on.ff_periodicity>1.1)=[];
    off.ff_periodicitypoi( off.ff_periodicitypoi>1.1)=[];
    off.ff_periodicity( off.ff_periodicity>1.1)=[];

    if length(on.ff_periodicitypoi)>30 && length(on.ff_periodicity)>30
        fano.on.periodicity_kstest(nn)=kstest2( on.ff_periodicitypoi, on.ff_periodicity,'Alpha',.05);
        fano.on.modeperiodicity(nn)=mode(on.ff_periodicity);
        fano.on.modeperiodicityNULL(nn)=mode(on.ff_periodicitypoi);
    else
        fano.on.periodicity_kstest(nn)=0;
        fano.on.modeperiodicity(nn)=0;
        fano.on.modeperiodicityNULL(nn)=0;
    end

    if length(off.ff_periodicitypoi)>30 && length(off.ff_periodicity)>30
        fano.off.periodicity_kstest(nn)=kstest2( off.ff_periodicitypoi, off.ff_periodicity,'Alpha',.05);
        fano.off.modeperiodicity(nn)=mode(off.ff_periodicity);
        fano.off.modeperiodicityNULL(nn)=mode(off.ff_periodicitypoi);
    else
        fano.off.periodicity_kstest(nn)=0;
        fano.off.modeperiodicity(nn)=0;
        fano.off.modeperiodicityNULL(nn)=0;
    end

    [sortedtp,sortid] = sort(tp_);
    if plt
        subplot(4,2,1);
        imagesc(timet,1:size(sc,1),sc(sortid,:));xlim([bef 3.5])
        xlabel time(s); ylabel 'trials';
        set(gca,'XTick',sort(xtikson),'FontSize',15);addline(xtikson);grid on; hold on;
        plot(sortedtp,1:size(sc,1),'.r');

        subplot(4,2,3);
        plot(timet,nanmean(sc,1),'-r','LineWidth',2);xlim([bef 3.5])
        xlabel time(s); ylabel 'spk count';
        set(gca,'XTick',sort(xtikson),'FontSize',15);addline(xtikson);grid on
       

        subplot(4,2,5);
        plotpatchstd(timet,nanmean(tempff,1),nanstd(tempff,[],1),[1 0 0],.5,2);xlim([bef 3.5]);hold on
        plotpatchstd(timet,nanmean(temppoi,1),nanstd(temppoi,[],1),[.7 .7 .7],.5,2);
        xlabel 'Time(s) re. JS onset'; ylabel 'Fano fac';
        set(gca,'XTick',sort(xtikson),'FontSize',15);addline(xtikson);
        legend('on','','NULL','')
        
        time_JSonset = timet';
        spike_count_JSonset = nanmean(sc,1)';
        
        fanofac_JSonset = nanmean(tempff,1)';
        fanofac_JSonset_std = nanstd(tempff,[],1)';
        fanofac_JSonset_poissonNULL = nanmean(temppoi,1)';
        fanofac_JSonset_poissonNULL_std = nanstd(temppoi,[],1)';

    

        subplot(4,2,7);
        plotpatchstd(fano.ffacgtimet,mean( on.acg,1),std( on.acg,[],1),[1 0 0],.5,2);hold on
        plotpatchstd(fano.ffacgtimet,mean( on.acgpoi,1),std( on.acgpoi,[],1),[.7 .7 .7],.5,2);hold on
        title(['period=' num2str(fano.on.modeperiodicity(nn)) ', KS=' num2str( fano.on.periodicity_kstest(nn)) ',PI650=' num2str( fano.on.ffgridness650(nn))])
        xlabel lag(s); ylabel 'corrcoeff';
        set(gca,'XTick',sort(xtikson),'FontSize',15);addline(xtikson);grid on
        
        lags_ACG = fano.ffacgtimet';
        ACG_fanofac_JSonset = mean( on.acg,1)';
        ACG_fanofac_JSonset_std = std( on.acg,[],1)';
        ACG_fanofac_JSonset_poissonNULL = mean( on.acg,1)';
        ACG_fanofac_JSonset_poissonNULL_std = std( on.acg,[],1)';

      

        subplot(4,2,2);
        imagesc(timetoff,1:size(scoff,1),scoff);xlim([-3.5 -bef])
        xlabel time(s); ylabel 'trials';
        set(gca,'XTick',sort(flip(-xtikson)),'FontSize',15);addline(flip(-xtikson));grid on; hold on;
        plot(-sortedtp,1:size(sc,1),'.r');

        subplot(4,2,4);
        plot(timetoff,nanmean(scoff,1),'-r','LineWidth',2);xlim([-3.5 -bef])
        xlabel time(s); ylabel 'spk count';
        set(gca,'XTick',sort(flip(-xtikson)),'FontSize',15);addline(flip(-xtikson));grid on

        subplot(4,2,6);
        plotpatchstd(timetoff,nanmean(tempffoff,1),nanstd(tempffoff,[],1),[1 0 0],.5,2);xlim([-3.5 -bef]);hold on
        plotpatchstd(timetoff,nanmean(temppoioff,1),nanstd(temppoioff,[],1),[.7 .7 .7],.5,2);
        xlabel 'Time(s) re. JS onset'; ylabel 'Fano fac';
        set(gca,'XTick',sort(flip(-xtikson)),'FontSize',15);addline(-xtikson);
        legend('off','','NULL','')

        time_JSoffset = timetoff';
        spike_count_JSoffset = nanmean(scoff,1)';

        fanofac_JSoffset = nanmean(tempffoff,1)';
        fanofac_JSoffset_std = nanstd(tempffoff,[],1)';
        fanofac_JSoffset_poissonNULL = nanmean(temppoioff,1)';
        fanofac_JSoffset_poissonNULL_std = nanstd(temppoioff,[],1)';

        T.Tspk_fano = table(time_JSonset,spike_count_JSonset,fanofac_JSonset,fanofac_JSonset_std,...
            fanofac_JSonset_poissonNULL,fanofac_JSonset_poissonNULL_std,...
            time_JSoffset,spike_count_JSoffset,fanofac_JSoffset,fanofac_JSoffset_std,...
            fanofac_JSoffset_poissonNULL,fanofac_JSoffset_poissonNULL_std);


        subplot(4,2,8);
        plotpatchstd(fano.ffacgtimet,mean( off.acg,1),std( off.acg,[],1),[1 0 0],.5,2);hold on
        plotpatchstd(fano.ffacgtimet,mean( off.acgpoi,1),std( off.acgpoi,[],1),[.7 .7 .7],.5,2);hold on
        title(['period=' num2str(fano.off.modeperiodicity(nn)) ', KS=' num2str( fano.off.periodicity_kstest(nn)) ',PI650=' num2str( fano.off.ffgridness650(nn))])
        xlabel lag(s); ylabel 'corrcoeff';
        set(gca,'XTick',sort(xtikson),'FontSize',15);addline(xtikson);grid on

        ACG_fanofac_JSoffset = mean( off.acg,1)';
        ACG_fanofac_JSoffset_std = std( off.acg,[],1)';
        ACG_fanofac_JSoffset_poissonNULL = mean( off.acg,1)';
        ACG_fanofac_JSoffset_poissonNULL_std = std( off.acg,[],1)';

        T.Tacg = table(lags_ACG,ACG_fanofac_JSonset,ACG_fanofac_JSonset_std,...
            ACG_fanofac_JSonset_poissonNULL,ACG_fanofac_JSonset_poissonNULL_std,...
            ACG_fanofac_JSoffset,ACG_fanofac_JSoffset_std,...
            ACG_fanofac_JSoffset_poissonNULL,ACG_fanofac_JSoffset_poissonNULL_std);


        sgtitle([params.filename ' dir' num2str(dir) ' fano fac neur' num2str(nn)]);


        hf=gcf;
        hf.Renderer='Painters';
        
        
    end

end

function [fano]=plot_fanofactor(data,params,dir,plt,gridnessat_range)

if dir==2,dir=-1;end
xx=params.edges;
xxoff=params.edgesoff;
bef=0;
aftoff=params.aftoff;
fanoaccmaxlag = params.fanoaccmaxlag;
xtikson = bef:.65:3.25;
cutoff=.2;
binwidth=200;
slide=30;
fano=[];
gridnessat=gridnessat_range(1);
PIrange = gridnessat_range(2);
for nn=1:params.numneur

    params.lowfr_trials = (mean(squeeze(data.data_tensor_joyoff(nn,params.edgesoff>-2 & params.edgesoff<0,:)),1)<.005)';
    trials_ = find(abs(params.tp)>=aftoff & params.dir_condition==dir & params.trial_type==3 & params.seqq<3 & params.attempt==1 & params.lowfr_trials==0);
    if length(trials_)<12,continue;end

    tt = xx>-binwidth/1000 & xx<0;


    tp_=abs(params.tp(trials_));
    aft= aftoff-cutoff;

    tt = xx>=bef & xx<aft;
    timet=xx(tt);
    timet=timet(1:slide:end);
    ttoff = xxoff>-aft & xxoff<=-bef;
    timetoff=xxoff(ttoff);
    timetoff=timetoff(1:slide:end);
    timet=timet(1:length(1:slide:length(find(tt))-binwidth));
    timetoff=timetoff(1:length(1:slide:length(find(ttoff))-binwidth));
    bb=100;
    clear sc sc_poi scoff_poi scoff
    dat=squeeze(data.data_tensor_joyon(nn,tt,trials_));

    % NULL: pass mean spike count through a Poisson process 100 times and compute fanofactor
    [sc_poitemp, spktimes, psth]=genSpikes(1/1000,nanmean(dat,2)',aft,bb);
    sc_poitemp=sc_poitemp';

    tti=1;
    for ttt=1:slide:length(dat)-binwidth
        sc(:,tti)=1/1000*sum(dat(ttt:ttt+binwidth,:),1);%/basesc(nn);
        sc_poi(:,tti)=sum(sc_poitemp(ttt:ttt+binwidth,:),1);
        tti=tti+1;
    end



    dat=squeeze(data.data_tensor_joyoff(nn,ttoff,trials_));
    % NULL: pass mean spike count through a Poisson process 100 times and compute fanofactor
    [sc_poitemp, spktimes, psth]=genSpikes(1/1000,nanmean(dat,2)',aft,bb);
    sc_poitemp=sc_poitemp';

    tti=1;
    for ttt=1:slide:length(dat)-binwidth
        scoff(:,tti)=1/1000*sum(dat(ttt:ttt+binwidth,:),1);%/basesc(nn);
        scoff_poi(:,tti)=sum(sc_poitemp(ttt:ttt+binwidth,:),1);
        tti=tti+1;
    end

    tempff= bootstrp(bb,@(x) var(x,1)./mean(x,1),sc);
    tempffoff= bootstrp(bb,@(x) var(x,1)./mean(x,1),scoff);
    temppoi= bootstrp(bb,@(x) var(x,1)./mean(x,1),sc_poi);
    temppoioff= bootstrp(bb,@(x) var(x,1)./mean(x,1),scoff_poi);

    acc_maxlag = find(timet>fanoaccmaxlag,1);
    fano.acg_maxlag=acc_maxlag;
    fano.ffacgtimet=linspace(-fanoaccmaxlag,fanoaccmaxlag,acc_maxlag*2+1);

    gridlag=find(fano.ffacgtimet>0,1):find(fano.ffacgtimet>1.2,1);
    fano.gridlags=fano.ffacgtimet(gridlag);



    id325=find(fano.ffacgtimet>(gridnessat*.5),1);id325=id325-1:id325+1;
    id650=find(fano.ffacgtimet>gridnessat,1);id650=id650-1:id650+1;
    id975=find(fano.ffacgtimet>(gridnessat*1.5),1);id975=id975-1:id975+1;


    for tr=1:size(temppoi,1)
        temptr=temppoi(tr,:);
        mdl = fitlm(1:length(timetoff),temptr); %choose where exactly to estimate ramp from
        ffdetrended=temptr-mdl.Coefficients.Estimate(2)*(1:length(timet));
        acgtr= xcorr(ffdetrended-nanmean(ffdetrended),acc_maxlag,'coeff');
        on.NULLgridness(tr)=nanmean(acgtr(id650)) - .5*nanmean(acgtr(id325)) - .5*nanmean(acgtr(id975));
        on.acgpoi(tr,:)= acgtr;

        for tlag = 1:length(gridlag)
            temp = corrcoef(acgtr,circshift(acgtr,round(tlag)))-corrcoef(acgtr,circshift(acgtr,round(.5*tlag)));
            ff_pi_tlagpoi(tlag,tr)=temp(2);
        end
        [~, periodicity] = max(ff_pi_tlagpoi(:,tr));
        on.ff_periodicitypoi(tr) = fano.gridlags(periodicity);

        temptr=temppoioff(tr,:);
        mdl = fitlm(1:length(timetoff),temptr); %choose where exactly to estimate ramp from
        ffdetrended=temptr-mdl.Coefficients.Estimate(2)*(1:length(timet));
        acgtr= xcorr(ffdetrended-nanmean(ffdetrended),acc_maxlag,'coeff');
        off.NULLgridness(tr)=nanmean(acgtr(id650)) - .5*nanmean(acgtr(id325)) - .5*nanmean(acgtr(id975));
        off.acgpoi(tr,:)= acgtr;
        for tlag = 1:length(gridlag)
            temp = corrcoef(acgtr,circshift(acgtr,round(tlag)))-corrcoef(acgtr,circshift(acgtr,round(.5*tlag)));
            ff_pi_tlagpoioff(tlag,tr)=temp(2);
        end
        [~, periodicity] = max(ff_pi_tlagpoioff(:,tr));
        off.ff_periodicitypoi(tr) = fano.gridlags(periodicity);

        temptr=tempff(tr,:);
        mdl = fitlm(1:length(timetoff),temptr); %choose where exactly to estimate ramp from
        ffdetrended=temptr-mdl.Coefficients.Estimate(2)*(1:length(timet));
        acgtr= xcorr(ffdetrended-nanmean(ffdetrended),acc_maxlag,'coeff');
        on.gridness(tr)=nanmean(acgtr(id650)) - .5*nanmean(acgtr(id325)) - .5*nanmean(acgtr(id975));
        on.acg(tr,:)= acgtr;

        for tlag = 1:length(gridlag)
            temp = corrcoef(acgtr,circshift(acgtr,round(tlag)))-corrcoef(acgtr,circshift(acgtr,round(.5*tlag)));
            ff_pi_tlagon(tlag,tr)=temp(2);
        end
        [~, periodicity] = max(ff_pi_tlagon(:,tr));
        on.ff_periodicity(tr) = fano.gridlags(periodicity);


        temptr=tempffoff(tr,:);
        mdl = fitlm(1:length(timetoff),temptr); %choose where exactly to estimate ramp from
        ffdetrended=temptr-mdl.Coefficients.Estimate(2)*(1:length(timet));
        acgtr= xcorr(ffdetrended-nanmean(ffdetrended),acc_maxlag,'coeff');
        off.gridness(tr)=nanmean(acgtr(id650)) - .5*nanmean(acgtr(id325)) - .5*nanmean(acgtr(id975));
        off.acg(tr,:)= acgtr;
        for tlag = 1:length(gridlag)
            temp = corrcoef(acgtr,circshift(acgtr,round(tlag)))-corrcoef(acgtr,circshift(acgtr,round(.5*tlag)));
            ff_pi_tlagoff(tlag,tr)=temp(2);
        end
        [~, periodicity] = max(ff_pi_tlagoff(:,tr));
        off.ff_periodicity(tr) = fano.gridlags(periodicity);



    end


    fano.on.ffgridness650(nn)=ttest2(on.NULLgridness,on.gridness,'Tail','left','Alpha',0.01,'Vartype','unequal');
    fano.off.ffgridness650(nn)=ttest2(off.NULLgridness,off.gridness,'Tail','left','Alpha',0.01,'Vartype','unequal');

    gridnesstest = find(fano.gridlags>(gridnessat-PIrange) & fano.gridlags<(gridnessat+PIrange));
    fano.on.ffgridness_range_pval(nn,:)=nan(1,length(1:gridnesstest(end)));
    fano.off.ffgridness_range_pval(nn,:)=nan(1,length(1:gridnesstest(end)));
    for tlag = gridnesstest
        nullon=ff_pi_tlagpoi(tlag,:);
        dataon=ff_pi_tlagon(tlag,:);
        [ ffgridnessrangeon(tlag) fano.on.ffgridness_range_pval(nn,tlag)]=ttest2(nullon,dataon,'Tail','left','Alpha',0.0001/length(gridnesstest),'Vartype','unequal');

        nullon=ff_pi_tlagpoioff(tlag,:);
        dataon=ff_pi_tlagoff(tlag,:);
        [ ffgridnessrangeoff(tlag) fano.off.ffgridness_range_pval(nn,tlag)]=ttest2(nullon,dataon,'Tail','left','Alpha',0.0001/length(gridnesstest),'Vartype','unequal');

    end

    fano.on.ffgridnessrange(nn)= any(ffgridnessrangeon);
    fano.off.ffgridnessrange(nn)= any(ffgridnessrangeoff) ;


    on.ff_periodicitypoi( on.ff_periodicitypoi>1.1)=[];
    on.ff_periodicity( on.ff_periodicity>1.1)=[];
    off.ff_periodicitypoi( off.ff_periodicitypoi>1.1)=[];
    off.ff_periodicity( off.ff_periodicity>1.1)=[];

    if length(on.ff_periodicitypoi)>30 && length(on.ff_periodicity)>30
        fano.on.periodicity_kstest(nn)=kstest2( on.ff_periodicitypoi, on.ff_periodicity,'Alpha',.05);
        fano.on.modeperiodicity(nn)=mode(on.ff_periodicity);
        fano.on.modeperiodicityNULL(nn)=mode(on.ff_periodicitypoi);
    else
        fano.on.periodicity_kstest(nn)=0;
        fano.on.modeperiodicity(nn)=0;
        fano.on.modeperiodicityNULL(nn)=0;
    end

    if length(off.ff_periodicitypoi)>30 && length(off.ff_periodicity)>30
        fano.off.periodicity_kstest(nn)=kstest2( off.ff_periodicitypoi, off.ff_periodicity,'Alpha',.05);
        fano.off.modeperiodicity(nn)=mode(off.ff_periodicity);
        fano.off.modeperiodicityNULL(nn)=mode(off.ff_periodicitypoi);
    else
        fano.off.periodicity_kstest(nn)=0;
        fano.off.modeperiodicity(nn)=0;
        fano.off.modeperiodicityNULL(nn)=0;
    end

    [sortedtp,sortid] = sort(tp_);
    if plt
        subplot(4,2,1);
        imagesc(timet,1:size(sc,1),sc(sortid,:));xlim([bef 3.5])
        xlabel time(s); ylabel 'trials';
        set(gca,'XTick',sort(xtikson),'FontSize',15);addline(xtikson);grid on; hold on;
        plot(sortedtp,1:size(sc,1),'.r');

        subplot(4,2,3);
        plot(timet,nanmean(sc,1),'-r','LineWidth',2);xlim([bef 3.5])
        xlabel time(s); ylabel 'spk count';
        set(gca,'XTick',sort(xtikson),'FontSize',15);addline(xtikson);grid on


        subplot(4,2,5);
        plotpatchstd(timet,nanmean(tempff,1),nanstd(tempff,[],1),[1 0 0],.5,2);xlim([bef 3.5]);hold on
        plotpatchstd(timet,nanmean(temppoi,1),nanstd(temppoi,[],1),[.7 .7 .7],.5,2);
        xlabel 'Time(s) re. JS onset'; ylabel 'Fano fac';
        set(gca,'XTick',sort(xtikson),'FontSize',15);addline(xtikson);
        legend('on','','NULL','')

        subplot(4,2,7);

        plotpatchstd(fano.ffacgtimet,mean( on.acg,1),std( on.acg,[],1),[1 0 0],.5,2);hold on
        plotpatchstd(fano.ffacgtimet,mean( on.acgpoi,1),std( on.acgpoi,[],1),[.7 .7 .7],.5,2);hold on
        title(['period=' num2str(fano.on.modeperiodicity(nn)) ', KS=' num2str( fano.on.periodicity_kstest(nn)) ',PI650=' num2str( fano.on.ffgridness650(nn))])
        xlabel lag(s); ylabel 'corrcoeff';
        set(gca,'XTick',sort(xtikson),'FontSize',15);addline(xtikson);grid on





        subplot(4,2,2);
        imagesc(timetoff,1:size(scoff,1),scoff);xlim([-3.5 -bef])
        xlabel time(s); ylabel 'trials';
        set(gca,'XTick',sort(flip(-xtikson)),'FontSize',15);addline(flip(-xtikson));grid on; hold on;
        plot(-sortedtp,1:size(sc,1),'.r');

        subplot(4,2,4);
        plot(timetoff,nanmean(scoff,1),'-r','LineWidth',2);xlim([-3.5 -bef])
        xlabel time(s); ylabel 'spk count';
        set(gca,'XTick',sort(flip(-xtikson)),'FontSize',15);addline(flip(-xtikson));grid on

        subplot(4,2,6);
        plotpatchstd(timetoff,nanmean(tempffoff,1),nanstd(tempffoff,[],1),[1 0 0],.5,2);xlim([-3.5 -bef]);hold on
        plotpatchstd(timetoff,nanmean(temppoioff,1),nanstd(temppoioff,[],1),[.7 .7 .7],.5,2);
        xlabel 'Time(s) re. JS onset'; ylabel 'Fano fac';
        set(gca,'XTick',sort(flip(-xtikson)),'FontSize',15);addline(-xtikson);
        legend('off','','NULL','')


        subplot(4,2,8);
        plotpatchstd(fano.ffacgtimet,mean( off.acg,1),std( off.acg,[],1),[1 0 0],.5,2);hold on
        plotpatchstd(fano.ffacgtimet,mean( off.acgpoi,1),std( off.acgpoi,[],1),[.7 .7 .7],.5,2);hold on
        title(['period=' num2str(fano.off.modeperiodicity(nn)) ', KS=' num2str( fano.off.periodicity_kstest(nn)) ',PI650=' num2str( fano.off.ffgridness650(nn))])
        xlabel lag(s); ylabel 'corrcoeff';
        set(gca,'XTick',sort(xtikson),'FontSize',15);addline(xtikson);grid on

        sgtitle([params.filename ' dir' num2str(dir) ' fano fac neur' num2str(nn)]);


        hf=gcf;
        hf.Renderer='Painters';
        cd(cp.datafolder);
        saveas(hf,[params.filename '_dir' num2str(dir) '_cutoff' num2str(aftoff*10) '_Fano_fac_neur' num2str(nn)],'epsc');
        clf
    end

end
fano.gridnessat=gridnessat;


end

function [fano]=plot_population_fanofactor(data,params,dir,plt,gridnessat_range)

if dir==2,dir=-1;end
xx=params.edges;
xxoff=params.edgesoff;
bef=0;
aftoff=params.aftoff;
fanoaccmaxlag = params.fanoaccmaxlag;
xtikson = bef:.65:3.25;
cutoff=.2;
binwidth=200;
slide=30;
fano=[];
gridnessat=gridnessat_range(1);
PIrange = gridnessat_range(2);
for nn=[1:params.numneur]

    params.lowfr_trials = (mean(squeeze(data.data_tensor_joyoff(nn,params.edgesoff>-2 & params.edgesoff<0,:)),1)<.005)';
    trials_ = find(abs(params.tp)>=aftoff & params.dir_condition==dir & params.trial_type==3 & params.seqq<3 & params.attempt==1 & params.lowfr_trials==0);
    if length(trials_)<12,continue;end

    tt = xx>-binwidth/1000 & xx<0;


    tp_=abs(params.tp(trials_));
    aft= aftoff-cutoff;

    tt = xx>=bef & xx<aft;
    timet=xx(tt);
    timet=timet(1:slide:end);
    ttoff = xxoff>-aft & xxoff<=-bef;
    timetoff=xxoff(ttoff);
    timetoff=timetoff(1:slide:end);
    timet=timet(1:length(1:slide:length(find(tt))-binwidth));
    timetoff=timetoff(1:length(1:slide:length(find(ttoff))-binwidth));
    bb=100;
    clear sc sc_poi scoff_poi scoff
    dat=squeeze(data.data_tensor_joyon(nn,tt,trials_));

    % NULL: pass mean spike count through a Poisson process 100 times and compute fanofactor
    [sc_poitemp, spktimes, psth]=genSpikes(1/1000,nanmean(dat,2)',aft,bb);
    sc_poitemp=sc_poitemp';

    tti=1;
    for ttt=1:slide:length(dat)-binwidth
        sc(:,tti)=1/1000*sum(dat(ttt:ttt+binwidth,:),1);%/basesc(nn);
        sc_poi(:,tti)=sum(sc_poitemp(ttt:ttt+binwidth,:),1);
        tti=tti+1;
    end



    dat=squeeze(data.data_tensor_joyoff(nn,ttoff,trials_));
    % NULL: pass mean spike count through a Poisson process 100 times and compute fanofactor
    [sc_poitemp, spktimes, psth]=genSpikes(1/1000,nanmean(dat,2)',aft,bb);
    sc_poitemp=sc_poitemp';

    tti=1;
    for ttt=1:slide:length(dat)-binwidth
        scoff(:,tti)=1/1000*sum(dat(ttt:ttt+binwidth,:),1);%/basesc(nn);
        scoff_poi(:,tti)=sum(sc_poitemp(ttt:ttt+binwidth,:),1);
        tti=tti+1;
    end

    tempff= bootstrp(bb,@(x) var(x,1)./mean(x,1),sc);
    tempffoff= bootstrp(bb,@(x) var(x,1)./mean(x,1),scoff);
    temppoi= bootstrp(bb,@(x) var(x,1)./mean(x,1),sc_poi);
    temppoioff= bootstrp(bb,@(x) var(x,1)./mean(x,1),scoff_poi);

    acc_maxlag = find(timet>fanoaccmaxlag,1);
    fano.acg_maxlag=acc_maxlag;
    fano.ffacgtimet=linspace(-fanoaccmaxlag,fanoaccmaxlag,acc_maxlag*2+1);

    gridlag=find(fano.ffacgtimet>0,1):find(fano.ffacgtimet>1.2,1);
    fano.gridlags=fano.ffacgtimet(gridlag);



    id325=find(fano.ffacgtimet>(gridnessat*.5),1);id325=id325-1:id325+1;
    id650=find(fano.ffacgtimet>gridnessat,1);id650=id650-1:id650+1;
    id975=find(fano.ffacgtimet>(gridnessat*1.5),1);id975=id975-1:id975+1;


    for tr=1:size(temppoi,1)
        temptr=temppoi(tr,:);
        mdl = fitlm(1:length(timetoff),temptr); %choose where exactly to estimate ramp from
        ffdetrended=temptr-mdl.Coefficients.Estimate(2)*(1:length(timet));
        acgtr= xcorr(ffdetrended-nanmean(ffdetrended),acc_maxlag,'coeff');
        on.NULLgridness(tr)=nanmean(acgtr(id650)) - .5*nanmean(acgtr(id325)) - .5*nanmean(acgtr(id975));
        on.acgpoi(tr,:)= acgtr;

        for tlag = 1:length(gridlag)
            temp = corrcoef(acgtr,circshift(acgtr,round(tlag)))-corrcoef(acgtr,circshift(acgtr,round(.5*tlag)));
            ff_pi_tlagpoi(tlag,tr)=temp(2);
        end
        [~, periodicity] = max(ff_pi_tlagpoi(:,tr));
        on.ff_periodicitypoi(tr) = fano.gridlags(periodicity);

        temptr=temppoioff(tr,:);
        mdl = fitlm(1:length(timetoff),temptr); %choose where exactly to estimate ramp from
        ffdetrended=temptr-mdl.Coefficients.Estimate(2)*(1:length(timet));
        acgtr= xcorr(ffdetrended-nanmean(ffdetrended),acc_maxlag,'coeff');
        off.NULLgridness(tr)=nanmean(acgtr(id650)) - .5*nanmean(acgtr(id325)) - .5*nanmean(acgtr(id975));
        off.acgpoi(tr,:)= acgtr;
        for tlag = 1:length(gridlag)
            temp = corrcoef(acgtr,circshift(acgtr,round(tlag)))-corrcoef(acgtr,circshift(acgtr,round(.5*tlag)));
            ff_pi_tlagpoioff(tlag,tr)=temp(2);
        end
        [~, periodicity] = max(ff_pi_tlagpoioff(:,tr));
        off.ff_periodicitypoi(tr) = fano.gridlags(periodicity);

        temptr=tempff(tr,:);
        mdl = fitlm(1:length(timetoff),temptr); %choose where exactly to estimate ramp from
        ffdetrended=temptr-mdl.Coefficients.Estimate(2)*(1:length(timet));
        acgtr= xcorr(ffdetrended-nanmean(ffdetrended),acc_maxlag,'coeff');
        on.gridness(tr)=nanmean(acgtr(id650)) - .5*nanmean(acgtr(id325)) - .5*nanmean(acgtr(id975));
        on.acg(tr,:)= acgtr;

        for tlag = 1:length(gridlag)
            temp = corrcoef(acgtr,circshift(acgtr,round(tlag)))-corrcoef(acgtr,circshift(acgtr,round(.5*tlag)));
            ff_pi_tlagon(tlag,tr)=temp(2);
        end
        [~, periodicity] = max(ff_pi_tlagon(:,tr));
        on.ff_periodicity(tr) = fano.gridlags(periodicity);


        temptr=tempffoff(tr,:);
        mdl = fitlm(1:length(timetoff),temptr); %choose where exactly to estimate ramp from
        ffdetrended=temptr-mdl.Coefficients.Estimate(2)*(1:length(timet));
        acgtr= xcorr(ffdetrended-nanmean(ffdetrended),acc_maxlag,'coeff');
        off.gridness(tr)=nanmean(acgtr(id650)) - .5*nanmean(acgtr(id325)) - .5*nanmean(acgtr(id975));
        off.acg(tr,:)= acgtr;
        for tlag = 1:length(gridlag)
            temp = corrcoef(acgtr,circshift(acgtr,round(tlag)))-corrcoef(acgtr,circshift(acgtr,round(.5*tlag)));
            ff_pi_tlagoff(tlag,tr)=temp(2);
        end
        [~, periodicity] = max(ff_pi_tlagoff(:,tr));
        off.ff_periodicity(tr) = fano.gridlags(periodicity);



    end


    fano.on.ffgridness650(nn)=ttest2(on.NULLgridness,on.gridness,'Tail','left','Alpha',0.01,'Vartype','unequal');
    fano.off.ffgridness650(nn)=ttest2(off.NULLgridness,off.gridness,'Tail','left','Alpha',0.01,'Vartype','unequal');

    gridnesstest = find(fano.gridlags>(gridnessat-PIrange) & fano.gridlags<(gridnessat+PIrange));
    fano.on.ffgridness_range_pval(nn,:)=nan(1,length(1:gridnesstest(end)));
    fano.off.ffgridness_range_pval(nn,:)=nan(1,length(1:gridnesstest(end)));
    for tlag = gridnesstest
        nullon=ff_pi_tlagpoi(tlag,:);
        dataon=ff_pi_tlagon(tlag,:);
        [ ffgridnessrangeon(tlag) fano.on.ffgridness_range_pval(nn,tlag)]=ttest2(nullon,dataon,'Tail','left','Alpha',0.0001/length(gridnesstest),'Vartype','unequal');

        nullon=ff_pi_tlagpoioff(tlag,:);
        dataon=ff_pi_tlagoff(tlag,:);
        [ ffgridnessrangeoff(tlag) fano.off.ffgridness_range_pval(nn,tlag)]=ttest2(nullon,dataon,'Tail','left','Alpha',0.0001/length(gridnesstest),'Vartype','unequal');

    end

    fano.on.ffgridnessrange(nn)= any(ffgridnessrangeon);
    fano.off.ffgridnessrange(nn)= any(ffgridnessrangeoff) ;


    on.ff_periodicitypoi( on.ff_periodicitypoi>1.1)=[];
    on.ff_periodicity( on.ff_periodicity>1.1)=[];
    off.ff_periodicitypoi( off.ff_periodicitypoi>1.1)=[];
    off.ff_periodicity( off.ff_periodicity>1.1)=[];

    if length(on.ff_periodicitypoi)>30 && length(on.ff_periodicity)>30
        fano.on.periodicity_kstest(nn)=kstest2( on.ff_periodicitypoi, on.ff_periodicity,'Alpha',.05);
        fano.on.modeperiodicity(nn)=mode(on.ff_periodicity);
        fano.on.modeperiodicityNULL(nn)=mode(on.ff_periodicitypoi);
    else
        fano.on.periodicity_kstest(nn)=0;
        fano.on.modeperiodicity(nn)=0;
        fano.on.modeperiodicityNULL(nn)=0;
    end

    if length(off.ff_periodicitypoi)>30 && length(off.ff_periodicity)>30
        fano.off.periodicity_kstest(nn)=kstest2( off.ff_periodicitypoi, off.ff_periodicity,'Alpha',.05);
        fano.off.modeperiodicity(nn)=mode(off.ff_periodicity);
        fano.off.modeperiodicityNULL(nn)=mode(off.ff_periodicitypoi);
    else
        fano.off.periodicity_kstest(nn)=0;
        fano.off.modeperiodicity(nn)=0;
        fano.off.modeperiodicityNULL(nn)=0;
    end

    [sortedtp,sortid] = sort(tp_);
    if plt
        subplot(4,2,1);
        imagesc(timet,1:size(sc,1),sc(sortid,:));xlim([bef 3.5])
        xlabel time(s); ylabel 'trials';
        set(gca,'XTick',sort(xtikson),'FontSize',15);addline(xtikson);grid on; hold on;
        plot(sortedtp,1:size(sc,1),'.r');

        subplot(4,2,3);
        plot(timet,nanmean(sc,1),'-r','LineWidth',2);xlim([bef 3.5])
        xlabel time(s); ylabel 'spk count';
        set(gca,'XTick',sort(xtikson),'FontSize',15);addline(xtikson);grid on


        subplot(4,2,5);
        plotpatchstd(timet,nanmean(tempff,1),nanstd(tempff,[],1),[1 0 0],.5,2);xlim([bef 3.5]);hold on
        plotpatchstd(timet,nanmean(temppoi,1),nanstd(temppoi,[],1),[.7 .7 .7],.5,2);
        xlabel 'Time(s) re. JS onset'; ylabel 'Fano fac';
        set(gca,'XTick',sort(xtikson),'FontSize',15);addline(xtikson);
        legend('on','','NULL','')

        subplot(4,2,7);

        plotpatchstd(fano.ffacgtimet,mean( on.acg,1),std( on.acg,[],1),[1 0 0],.5,2);hold on
        plotpatchstd(fano.ffacgtimet,mean( on.acgpoi,1),std( on.acgpoi,[],1),[.7 .7 .7],.5,2);hold on
        title(['period=' num2str(fano.on.modeperiodicity(nn)) ', KS=' num2str( fano.on.periodicity_kstest(nn)) ',PI650=' num2str( fano.on.ffgridness650(nn))])
        xlabel lag(s); ylabel 'corrcoeff';
        set(gca,'XTick',sort(xtikson),'FontSize',15);addline(xtikson);grid on





        subplot(4,2,2);
        imagesc(timetoff,1:size(scoff,1),scoff);xlim([-3.5 -bef])
        xlabel time(s); ylabel 'trials';
        set(gca,'XTick',sort(flip(-xtikson)),'FontSize',15);addline(flip(-xtikson));grid on; hold on;
        plot(-sortedtp,1:size(sc,1),'.r');

        subplot(4,2,4);
        plot(timetoff,nanmean(scoff,1),'-r','LineWidth',2);xlim([-3.5 -bef])
        xlabel time(s); ylabel 'spk count';
        set(gca,'XTick',sort(flip(-xtikson)),'FontSize',15);addline(flip(-xtikson));grid on

        subplot(4,2,6);
        plotpatchstd(timetoff,nanmean(tempffoff,1),nanstd(tempffoff,[],1),[1 0 0],.5,2);xlim([-3.5 -bef]);hold on
        plotpatchstd(timetoff,nanmean(temppoioff,1),nanstd(temppoioff,[],1),[.7 .7 .7],.5,2);
        xlabel 'Time(s) re. JS onset'; ylabel 'Fano fac';
        set(gca,'XTick',sort(flip(-xtikson)),'FontSize',15);addline(-xtikson);
        legend('off','','NULL','')


        subplot(4,2,8);
        plotpatchstd(fano.ffacgtimet,mean( off.acg,1),std( off.acg,[],1),[1 0 0],.5,2);hold on
        plotpatchstd(fano.ffacgtimet,mean( off.acgpoi,1),std( off.acgpoi,[],1),[.7 .7 .7],.5,2);hold on
        title(['period=' num2str(fano.off.modeperiodicity(nn)) ', KS=' num2str( fano.off.periodicity_kstest(nn)) ',PI650=' num2str( fano.off.ffgridness650(nn))])
        xlabel lag(s); ylabel 'corrcoeff';
        set(gca,'XTick',sort(xtikson),'FontSize',15);addline(xtikson);grid on

        sgtitle([params.filename ' dir' num2str(dir) ' fano fac neur' num2str(nn)]);


        hf=gcf;
        hf.Renderer='Painters';
        cd(cp.datafolder);
        saveas(hf,[params.filename '_dir' num2str(dir) '_cutoff' num2str(aftoff*10) '_Fano_fac_neur' num2str(nn)],'epsc');
        clf
    end

end
fano.gridnessat=gridnessat;


end


function [fano]=get_fanofactorat650(data,params,dir)
%%
nn=params.neur;
xx=params.edges;
aftoff=params.aftoff;
times = .65/2:.65/2:2;


params.lowfr_trials = (mean(squeeze(data.data_tensor_joyoff(nn,params.edgesoff>-2 & params.edgesoff<0,:)),1)<.0005)';
trials_ = find(abs(params.tp)>=aftoff & params.dir_condition==dir & params.trial_type==3 & params.seqq<3 & params.attempt==1 & params.lowfr_trials==0);
if length(trials_)<12,fano=[];return;end

clear sc spkcount scoff
%    spkcount=nan(length(timet),length(trials_));
dat=squeeze(data.data_tensor_joyon(nn,:,trials_));
for tii=1:length(times)
    tt = xx>(times(tii)-.1) & xx<(times(tii)+.1);
    spkcount=1/1000*sum(dat(tt,:),1);

    fano.ffboot(tii,:)=bootstrp(100,@(x) var(x)/mean(x),spkcount);

end

fano.times=times;


end



function [spiketrain, spktimes, psth] = genSpikes(binwidth, fr, trialLength, nTrials)

%generate poisson spike train and spike times
%firing rate (fr) can be a constant number (homogenous poisson process)
%OR fr can be time varying (inhomogenous poisson process)
%with same length as triaLength sampled at at binwidth
%Sujaya Neupane
%Feb 2021
%adapted from David Heeger's handout and Vincent Prevost's code
%https://www.cns.nyu.edu/~david/handouts/poisson.pdf
%https://github.com/vncntprvst/tools/blob/master/poissonTutorial.m


if (nargin < 4)
    nTrials = 1;
end
if length(fr)==1
    disp 'Simulating homogenous poisson process...'
else
    %     disp 'Simulating inhomogenous poisson process...'
end

gaussian_size=200;
gauss_kern = fspecial('gaussian',[1 gaussian_size],100);

if any(fr<0), fr=fr+abs(min(fr(:)));disp 'rectifying neg FR with min(FR)'; end
times = [0:binwidth:trialLength];times=times(1:length(fr));
spiketrain = zeros(nTrials, length(times));
spktimes=cell(1,nTrials);
for train = 1:nTrials
    vt = rand(size(times));
    if any(size(fr)==1)
        spiketrain(train, :) = (fr*binwidth) > vt;
    else
        spiketrain(train, :) = (fr(train,:)*binwidth) > vt;
    end
    spktimes{train}=find(spiketrain(train, :))*binwidth;

    temp=conv(histcounts(spktimes{train},times)/binwidth,gauss_kern,'valid');
    psth(train,:)=temp;

end
end


%== single neuron periodicity w.r.t timing error e.g. neuron, reviwer's suggestion
function T=plot_periodicity_wrt_error(data,params,cp)

seqid=cp.seq;
dir=1;
xx=params.edges_rev;
cd([cp.savedir_ '/Fig2/data']);
load('gp_sim_gridnessGP100ms_detrended.mat')
nSTD=2;
params.gridlag=gridlag;
params.null_gridness=gp_95pcnull_gridness;
params.null_gridness_tlag_abovemean_bb=gridness_tlag_abovemean_bb;
params.gridness_thres_pc_abov_mean =  max(mean(params.null_gridness_tlag_abovemean_bb,1)+nSTD*std(params.null_gridness_tlag_abovemean_bb,[],1));%0.1576;%.3276; %2 STD FDR. This number comes from simulation of 1000 Gaussian Process smooth time courses.
params.null_pc_above_mean_gridness=pc_above_mean_gridness;
xtikson = 0:.65:3.25;

params.lowfr_trials = (mean(squeeze(data.data_tensor_joyoff(1,params.edgesoff>-2 & params.edgesoff<0,:)),1)<=cp.lowfr_thres)';

if seqid==12
    trials_ = find(params.seqq<3 & params.dist_conditions>3 & params.dir_condition==dir & params.trial_type==3 &  params.attempt==1 & params.lowfr_trials==0);
else
    trials_ = find(params.seqq==seqid & params.dist_conditions>3 & params.dir_condition==dir & params.trial_type==3 & params.attempt==1 & params.lowfr_trials==0);
end

data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data.data_tensor_joyon(1,:,trials_))','same');
data_tensor_smoothedon=data_tensor_smoothed(:,params.window_edge_effect);


[tperr,tpsort]=sort(abs(params.tp(trials_)) - abs(params.ta(trials_)) );

%S5c raster currently has trials sorted by tp 
% [tperr,tpsort]=sort(abs(params.tp(trials_)));  

tp_=abs(params.tp(trials_));
tp_=tp_(tpsort);

tempon=data_tensor_smoothedon(tpsort,:);

figure;

subplot(2,2,1);
imagesc(xx,1:length(trials_),tempon);caxis([0 10]);hold on
xlim([0 4]);set(gca,'XTick',sort(xtikson),'FontSize',15);
xlabel time(s); ylabel trials;addline(xtikson);
scatter(tp_,1:length(tp_),'.r')

qrt_tr=round(length(tperr)/cp.egneuron_trialfraction);
yy_under=tempon(1:qrt_tr,:);
yy_over=tempon(end-qrt_tr:end,:);

[xxc,yycu,piu]=get_acg_PI(yy_under,tp_(1:qrt_tr),params.gridlag,xx);
[~,uid]=max(piu);
underP=gridlag(uid);
[xxc,yyco,pio]=get_acg_PI(yy_under,tp_(end-qrt_tr:end),params.gridlag,xx);
[~,oid]=max(pio);
overP=gridlag(oid);

subplot(2,2,2);
plot(xx,mean(yy_under,1),'-b');hold on;
plot(xx,mean(yy_over,1),'-r');hold on;
set(gca,'XTick',sort(xtikson),'FontSize',15);
grid on; xlabel time(s); ylabel spk/s;xlim([0 4])

subplot(2,2,3);
plot(xxc/1000,nanmean(yycu,1),'-b','LineWidth',2);hold on
plot(xxc/1000,nanmean(yyco,1),'-r','LineWidth',2);hold on
ylim([-1 1])
set(gca,'XTick',sort(xtikson),'FontSize',15);
grid on; title 'ACG'; xlabel lag(s); ylabel 'acg coeff'
legend('under','over');

subplot(2,2,4);hold off
plot(params.gridlag/1000,params.null_gridness,'--k','LineWidth',2);grid on; hold on

plot(gridlag/1000,piu,'-b','LineWidth',2);hold on; addline(underP/1000,'color','b');
plot(gridlag/1000,pio,'-r','LineWidth',2);grid on;addline(overP/1000,'color','r');
addline(xtikson(1:2));addline(0','h');
ylim([-1 1])
xlabel periodicity(sec);ylabel P.I.;
set(gca,'XTick',sort(xtikson),'FontSize',15);
sgtitle([params.filename ' dir' num2str(dir) ' over under neur' num2str(params.neur)]);

nhp_neuron_id = repmat([params.filename ' neur ' num2str(params.neur)   ],[length(tp_), 1]);
T.Tp_err= table(nhp_neuron_id,tp_,tperr);

autocorr_undershoot = nanmean(yycu,1)';
autocorr_overshoot = nanmean(yyco,1)';
lags=xxc'/1000; 
nhp_neuron_id = repmat([params.filename ' neur ' num2str(params.neur)   ],[length(lags), 1]);
T.Tautocorr = table(nhp_neuron_id,lags,autocorr_undershoot,autocorr_overshoot);

PI_undershoot = piu';
PI_overshoot = pio';
PI_lags=params.gridlag'/1000; 
nhp_neuron_id = repmat([params.filename ' neur ' num2str(params.neur)   ],[length(PI_lags), 1]);
T.TPI = table(nhp_neuron_id,PI_lags,PI_undershoot,PI_overshoot);


end

%== single neuron bump phase w.r.t timing error, reviewer's suggestion
function get_bumps_under_over_conditioned_by_distance(params)
distances_pooled=params.distances_pooled;
load([ cp.datafolder '/gp_sim_gridnessGP100ms_detrended.mat'])
nSTD=2;
params.gridlag=gridlag;
params.null_gridness=gp_95pcnull_gridness;
params.null_gridness_tlag_abovemean_bb=gridness_tlag_abovemean_bb;
params.gridness_thres_pc_abov_mean =  max(mean(params.null_gridness_tlag_abovemean_bb,1)+nSTD*std(params.null_gridness_tlag_abovemean_bb,[],1));%0.1576;%.3276; %2 STD FDR. This number comes from simulation of 1000 Gaussian Process smooth time courses.
params.null_pc_above_mean_gridness=pc_above_mean_gridness;


load([cp.datafolder 'sessions/' ...
    params.animal '_' params.area '_sessions.mat'], 'sessions')


params.mtt_folder= cp.tensordatafolder;


mintr=15;
load([cp.datafolder '/'...
    params.animal '_' params.area '_periodicity_js_leftright_dist345_seq12.mat'], 'gridness')

underoverBump = cell(length(sessions),1);

for ss=1:length(sessions)
    params.filename=sessions{ss};
    clear data_tensor_joyoff

    cd ([params.mtt_folder '/' params.filename '.mwk'])

    varlist=matfile([sessions{ss} '_neur_tensor_joyoff']);
    cond_label=varlist.cond_label;
    cond_matrix=varlist.cond_matrix;
    for ii=1:length(cond_label)
        eval(['params.' cond_label{ii} '=cond_matrix(:,strcmp(cond_label, cond_label{ii} ));']);
    end
    params.dist_conditions = abs(params.target-params.curr);
    params.dir_condition = sign(params.ta);


    if strcmp(params.animal,'mahler') && strcmp(params.area,'7a')
        numneuron=1:mahler_NP_within_session_neurons(ss);
        data_tensor = varlist.neur_tensor_joyoff(numneuron,:,:);
    else
        data_tensor = varlist.neur_tensor_joyoff(:,:,:);
        numneuron = 1:size(varlist,'neur_tensor_joyoff',1);
    end

    temp=varlist.joyoff;
    params.binwidth=temp.binwidth;
    params.bef=temp.bef;
    params.aft=temp.aft;
    params.edges=temp.edges;

    params.smooth='gauss'; %or 'boxcar'
    params.gauss_smooth=.2; %   smoothing window for psth
    params.gauss_std = .1;   %   std of gaussian filter if gaussian
    params.gauss_smoothing_kern = fspecial('gaussian',[1 params.gauss_smooth/params.binwidth],params.gauss_std/params.binwidth);
    %to remove edge effect of filters, take extra 2*gaussian_filter_size and remove those time points after filtering
    params.window_edge_effect = params.gauss_smooth*2/params.binwidth:(length(params.edges)-params.gauss_smooth*2/params.binwidth);
    params.edges_rev = params.edges(params.window_edge_effect);

    gridness_=gridness{ss,1};
    if isempty(gridness_) || ~isfield(gridness_,'pc_above_mean_gridness'),disp 'no gridness for this session'; return;end
    grid_cells1=find(gridness_.pc_above_mean_gridness>params.gridness_thres_pc_abov_mean &  gridness_.num_trials_mve(:,1)'>mintr);% & gridness_.gridness_max_periodicity<1000 & gridness_.gridness_max_periodicity>220);

    gridness_=gridness{ss,2};
    grid_cells2=find(gridness_.pc_above_mean_gridness>params.gridness_thres_pc_abov_mean &  gridness_.num_trials_mve(:,1)'>mintr);% & gridness_.gridness_max_periodicity<1000 & gridness_.gridness_max_periodicity>220);

    grid_cells = unique([grid_cells1 grid_cells2]);

    underoverBump{ss}.underbumps=cell(size(data_tensor,1),1);
    underoverBump{ss}.overbumps=cell(size(data_tensor,1),1);
    underoverBump{ss}.underbumpsl=cell(size(data_tensor,1),1);
    underoverBump{ss}.overbumpsl=cell(size(data_tensor,1),1);
    underoverBump{ss}.underbumpsr=cell(size(data_tensor,1),1);
    underoverBump{ss}.overbumpsr=cell(size(data_tensor,1),1);

    if size(data_tensor,3)<length(params.tp)
        data_tensor(:,:,end+1)=0;
    end

    xx=params.edges_rev;
    for nn=grid_cells

        params.lowfr_trials = (mean(squeeze(data_tensor(nn,params.edges>0 & params.edges<1,:)),1)<.0005)';

        trials_u=[];trials_o=[];
        for dist=distances_pooled
            trials_ = find(params.dist_conditions==dist & params.trial_type==3 & params.seqq<3 & params.attempt==1 & params.lowfr_trials==0);
            [tperr,tpsort]=sort(abs(params.tp(trials_)) - abs(params.ta(trials_)) );
            trials_ = trials_(tpsort);
            if length(trials_)<6 || length(trials_)<6
                continue;
            end
            qrt_tr=round(length(tpsort)/4);
            trials_u = [trials_u; trials_(1:qrt_tr)];
            trials_o = [trials_o; trials_(end-qrt_tr:end)];
        end

        if length(trials_u)<15 || length(trials_o)<15
            continue;
        end

        data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor(nn,:,trials_u))','same');
        yy_under=data_tensor_smoothed(:,params.window_edge_effect);

        data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor(nn,:,trials_o))','same');
        yy_over=data_tensor_smoothed(:,params.window_edge_effect);

        tp_u=abs(params.tp(trials_u));
        tp_o=abs(params.tp(trials_o));

        underBump=get_bumps_underover(yy_under,tp_u,xx);
        underoverBump{ss}.underbumps{nn}= underBump;

        overBump=get_bumps_underover(yy_over,tp_o,xx);
        underoverBump{ss}.overbumps{nn}= overBump;


        % left trials
        trials_u=[];trials_o=[];
        dir=1;
        for dist=distances_pooled
            trials_ = find(params.dir_condition==dir & params.dist_conditions==dist & params.trial_type==3 & params.seqq<3 & params.attempt==1 & params.lowfr_trials==0);
            [tperr,tpsort]=sort(abs(params.tp(trials_)) - abs(params.ta(trials_)) );
            trials_ = trials_(tpsort);
            if length(trials_)<6 || length(trials_)<6
                continue;
            end
            qrt_tr=round(length(tpsort)/4);
            trials_u = [trials_u; trials_(1:qrt_tr)];
            trials_o = [trials_o; trials_(end-qrt_tr:end)];
        end

        if length(trials_u)<15 || length(trials_o)<15
            continue;
        end

        data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor(nn,:,trials_u))','same');
        yy_under=data_tensor_smoothed(:,params.window_edge_effect);

        data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor(nn,:,trials_o))','same');
        yy_over=data_tensor_smoothed(:,params.window_edge_effect);

        tp_u=abs(params.tp(trials_u));
        tp_o=abs(params.tp(trials_o));

        underBump=get_bumps_underover(yy_under,tp_u,xx);
        underoverBump{ss}.underbumpsl{nn}= underBump;

        overBump=get_bumps_underover(yy_over,tp_o,xx);
        underoverBump{ss}.overbumpsl{nn}= overBump;



        % right trials
        trials_u=[];trials_o=[];
        dir=-1;
        for dist=distances_pooled
            trials_ = find(params.dir_condition==dir & params.dist_conditions==dist & params.trial_type==3 & params.seqq<3 & params.attempt==1 & params.lowfr_trials==0);
            [tperr,tpsort]=sort(abs(params.tp(trials_)) - abs(params.ta(trials_)) );
            trials_ = trials_(tpsort);
            if length(trials_)<6 || length(trials_)<6
                continue;
            end
            qrt_tr=round(length(tpsort)/4);
            trials_u = [trials_u; trials_(1:qrt_tr)];
            trials_o = [trials_o; trials_(end-qrt_tr:end)];
        end

        if length(trials_u)<15 || length(trials_o)<15
            continue;
        end

        data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor(nn,:,trials_u))','same');
        yy_under=data_tensor_smoothed(:,params.window_edge_effect);

        data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor(nn,:,trials_o))','same');
        yy_over=data_tensor_smoothed(:,params.window_edge_effect);

        tp_u=abs(params.tp(trials_u));
        tp_o=abs(params.tp(trials_o));

        underBump=get_bumps_underover(yy_under,tp_u,xx);
        underoverBump{ss}.underbumpsr{nn}= underBump;

        overBump=get_bumps_underover(yy_over,tp_o,xx);
        underoverBump{ss}.overbumpsr{nn}= overBump;



        [ss nn]


    end

    cd(params.savedata)
    save([params.animal '_' params.area '_bumpphase_underover_dist45_conditioned.mat' ],'underoverBump','params' );
    disp(['===' params.animal '_' params.area '_bumpphase_underover_dist45_conditioned.mat saved===session' num2str(ss) ]  );


end

end

function out=get_bumps_underover(yy,tp_,xx)

offset=.1;
bumpphase_window=1;
btrp=100;

lastpeakbb_=nan(btrp,3);
lastpeakbbsh_=nan(btrp,3);

lastpeakbb_ipi=nan(btrp,3);
lastpeakbbsh_ipi=nan(btrp,3);

for bb=1:btrp
    trials_bb=randperm(length(tp_),ceil(length(tp_)/3));
    tempyy=mean(yy(trials_bb,:),1);
    [lastpeakbb_(bb,:),lastpeakbb_ipi(bb,:)]= get_max_local_peaks_bump(tempyy,xx,[-bumpphase_window -offset]);

    for tr=1:length(trials_bb)
        p=circshift(1:size(yy,2),randi(size(yy,2)));
        tempshuf(tr,:)=   yy(trials_bb(tr),p);
    end
    tempyysh=mean(tempshuf,1);
    [lastpeakbbsh_(bb,:),lastpeakbbsh_ipi(bb,:)]= get_max_local_peaks_bump(tempyysh,xx,[-bumpphase_window -offset]);

end

lastpeak_=nan(length(tp_),3);
lastpeaksh_=nan(length(tp_),3);
lastpeak_ipi=lastpeak_;
lastpeaksh_ipi=lastpeaksh_;

for tr=1:length(tp_)
    tempyy= yy(tr,:) ;
    [lastpeak_(tr,:),lastpeak_ipi(tr,:)]= get_max_local_peaks_bump(tempyy,xx,[-bumpphase_window -offset]);

    shiftedtimes=circshift(1:size(yy,2),randi(size(yy,2)));
    tempyyshuf =   yy(tr,shiftedtimes);
    [lastpeaksh_(tr,:),lastpeaksh_ipi(tr,:)]= get_max_local_peaks_bump(tempyyshuf,xx,[-bumpphase_window -offset]);
end

out.lastpeak=lastpeak_  ;
out.lastpeaksh=lastpeaksh_  ;

out.lastpeakbb=lastpeakbb_  ;
out.lastpeakbbsh=lastpeakbbsh_  ;


try [h,out.pvalbb(1),out.kstatsbb(1)]=kstest2(out.lastpeakbb(:,1),out.lastpeakbbsh(:,1),'Alpha',.05);catch,end
try [h,out.pvalbb(2),out.kstatsbb(2)]=kstest2(out.lastpeakbb(:,2),out.lastpeakbbsh(:,2),'Alpha',.05);catch,end
try [h,out.pvalbb(3),out.kstatsbb(3)]=kstest2(out.lastpeakbb(:,3),out.lastpeakbbsh(:,3),'Alpha',.05);catch,end

try [h,out.pval(1),out.kstats(1)]=kstest2(out.lastpeak(:,1),out.lastpeaksh(:,1),'Alpha',.05);catch,end
try [h,out.pval(2),out.kstats(2)]=kstest2(out.lastpeak(:,2),out.lastpeaksh(:,2),'Alpha',.05);catch,end
try [h,out.pval(3),out.kstats(3)]=kstest2(out.lastpeak(:,3),out.lastpeaksh(:,3),'Alpha',.05);catch,end


out.mode_peakbb(1,:)=[mode(out.lastpeakbb(:,1)) mode(out.lastpeakbbsh(:,1)) ];
out.mode_peakbb(2,:)=[mode(out.lastpeakbb(:,2)) mode(out.lastpeakbbsh(:,2)) ];
out.mode_peakbb(3,:)=[mode(out.lastpeakbb(:,3)) mode(out.lastpeakbbsh(:,3)) ];

out.mode_peakbb(4,:)=[mode(out.lastpeak(:,1)) mode(out.lastpeaksh(:,1)) ];
out.mode_peakbb(5,:)=[mode(out.lastpeak(:,2)) mode(out.lastpeaksh(:,2)) ];
out.mode_peakbb(6,:)=[mode(out.lastpeak(:,3)) mode(out.lastpeaksh(:,3)) ];

lastpeak=lastpeak_ipi;
lastpeaksh=lastpeaksh_ipi;
lastpeakbb=lastpeakbb_ipi;
lastpeakbbsh=lastpeakbbsh_ipi;


try [h,out.pvalbbipi(1),out.kstatsbbipi(1)]=kstest2(lastpeakbb(:,1),lastpeakbbsh(:,1),'Alpha',.05);catch,end
try [h,out.pvalbbipi(2),out.kstatsbbipi(2)]=kstest2(lastpeakbb(:,2),lastpeakbbsh(:,2),'Alpha',.05);catch,end
try [h,out.pvalbbipi(3),out.kstatsbbipi(3)]=kstest2(lastpeakbb(:,3),lastpeakbbsh(:,3),'Alpha',.05);catch,end


try [h,out.pvalipi(1),out.kstatsipi(1)]=kstest2(lastpeak(:,1),lastpeaksh(:,1),'Alpha',.05);catch,end
try [h,out.pvalipi(2),out.kstatsipi(2)]=kstest2(lastpeak(:,2),lastpeaksh(:,2),'Alpha',.05);catch,end
try [h,out.pvalipi(3),out.kstatsipi(3)]=kstest2(lastpeak(:,3),lastpeaksh(:,3),'Alpha',.05);catch,end

out.mode_peakbbipi(1,:)=[mode(lastpeakbb(:,1)) mode(lastpeakbbsh(:,1)) ];
out.mode_peakbbipi(2,:)=[mode(lastpeakbb(:,2)) mode(lastpeakbbsh(:,2)) ];
out.mode_peakbbipi(3,:)=[mode(lastpeakbb(:,3)) mode(lastpeakbbsh(:,3)) ];

out.mode_peakbbipi(4,:)=[mode(lastpeak(:,1)) mode(lastpeaksh(:,1)) ];
out.mode_peakbbipi(5,:)=[mode(lastpeak(:,2)) mode(lastpeaksh(:,2)) ];
out.mode_peakbbipi(6,:)=[mode(lastpeak(:,3)) mode(lastpeaksh(:,3)) ];

out.lastpeakipi=lastpeak_ipi;
out.lastpeakshipi=lastpeaksh_ipi;
out.lastpeakbbipi=lastpeakbb_ipi;
out.lastpeakbbshipi=lastpeakbbsh_ipi;


end

%== single neuron periodicity w.r.t timing error pop, reviewer's suggestion
function get_periodicity_under_over(params,seq,cp)

load([cp.datafolder '/gp_sim_gridnessGP100ms_detrended.mat'])
nSTD=2;
params.gridlag=gridlag;
params.null_gridness=gp_95pcnull_gridness;
params.null_gridness_tlag_abovemean_bb=gridness_tlag_abovemean_bb;
params.gridness_thres_pc_abov_mean =  max(mean(params.null_gridness_tlag_abovemean_bb,1)+nSTD*std(params.null_gridness_tlag_abovemean_bb,[],1));%0.1576;%.3276; %2 STD FDR. This number comes from simulation of 1000 Gaussian Process smooth time courses.
params.null_pc_above_mean_gridness=pc_above_mean_gridness;

load([cp.datafolder '/sessions/' ...
    params.animal '_' params.area '_sessions.mat'], 'sessions')


params.mtt_folder= cp.tensordatafolder;

mintr=15;
load([cp.datafolder '/'...
    params.animal '_' params.area '_periodicity_js_leftright_dist345_seq' num2str(seq) '.mat'], 'gridness')

underoverP = cell(length(sessions),1);

for ss=1:length(sessions)
    params.filename=sessions{ss};
    clear data_tensor_joyoff

    cd ([params.mtt_folder '/' params.filename '.mwk'])

    varlist=matfile([sessions{ss} '_neur_tensor_joyon']);
    cond_label=varlist.cond_label;
    cond_matrix=varlist.cond_matrix;
    for ii=1:length(cond_label)
        eval(['params.' cond_label{ii} '=cond_matrix(:,strcmp(cond_label, cond_label{ii} ));']);
    end
    params.dist_conditions = abs(params.target-params.curr);
    params.dir_condition = sign(params.ta);


    if strcmp(params.animal,'mahler') && strcmp(params.area,'7a')
        numneuron=1:mahler_NP_within_session_neurons(ss);
        data_tensor = varlist.neur_tensor_joyon(numneuron,:,:);
    else
        data_tensor = varlist.neur_tensor_joyon(:,:,:);
        numneuron = 1:size(varlist,'neur_tensor_joyon',1);
    end

    temp=varlist.joyon;
    params.binwidth=temp.binwidth;
    params.bef=temp.bef;
    params.aft=temp.aft;
    params.edges=temp.edges;

    params.smooth='gauss'; %or 'boxcar'
    params.gauss_smooth=.2; %   smoothing window for psth
    params.gauss_std = .1;   %   std of gaussian filter if gaussian
    params.gauss_smoothing_kern = fspecial('gaussian',[1 params.gauss_smooth/params.binwidth],params.gauss_std/params.binwidth);
    %to remove edge effect of filters, take extra 2*gaussian_filter_size and remove those time points after filtering
    params.window_edge_effect = params.gauss_smooth*2/params.binwidth:(length(params.edges)-params.gauss_smooth*2/params.binwidth);
    params.edges_rev = params.edges(params.window_edge_effect);

    gridness_=gridness{ss,1};
    if isempty(gridness_) || ~isfield(gridness_,'pc_above_mean_gridness'),disp 'no gridness for this session'; return;end
    grid_cells1=find(gridness_.pc_above_mean_gridness>params.gridness_thres_pc_abov_mean &  gridness_.num_trials_mve(:,1)'>mintr);% & gridness_.gridness_max_periodicity<1000 & gridness_.gridness_max_periodicity>220);

    gridness_=gridness{ss,2};
    grid_cells2=find(gridness_.pc_above_mean_gridness>params.gridness_thres_pc_abov_mean &  gridness_.num_trials_mve(:,1)'>mintr);% & gridness_.gridness_max_periodicity<1000 & gridness_.gridness_max_periodicity>220);

    grid_cells = unique([grid_cells1 grid_cells2]);

    underoverP{ss}.underPr=nan(size(data_tensor,1),1);underoverP{ss}.overPr=nan(size(data_tensor,1),1);
    underoverP{ss}.underPl=nan(size(data_tensor,1),1);underoverP{ss}.overPl=nan(size(data_tensor,1),1);
    underoverP{ss}.underP=nan(size(data_tensor,1),1);underoverP{ss}.overP=nan(size(data_tensor,1),1);
    if size(data_tensor,3)<length(params.tp)
        data_tensor(:,:,end+1)=0;

    end


    for nn=grid_cells

        params.lowfr_trials = (mean(squeeze(data_tensor(nn,params.edges>0 & params.edges<1,:)),1)<.0005)';


        xx=params.edges_rev;


        dir=1;
        trials_l = find(params.dist_conditions>3 & params.dir_condition==dir & params.trial_type==3 & params.seqq<3 & params.attempt==1 & params.lowfr_trials==0);
        dir=-1;
        trials_r = find(params.dist_conditions>3 & params.dir_condition==dir & params.trial_type==3 & params.seqq<3 & params.attempt==1 & params.lowfr_trials==0);

        if length(trials_l)<6 || length(trials_r)<6
            continue;
        end

        data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor(nn,:,trials_l))','same');
        data_tensor_smoothedonl=data_tensor_smoothed(:,params.window_edge_effect);

        data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor(nn,:,trials_r))','same');
        data_tensor_smoothedonr=data_tensor_smoothed(:,params.window_edge_effect);

        %left
        [tperr,tpsort]=sort(abs(params.tp(trials_l)) - abs(params.ta(trials_l)) );
        tp_=abs(params.tp(trials_l));
        tp_l=tp_(tpsort);

        tempon=data_tensor_smoothedonl(tpsort,:);

        qrt_tr=round(length(tp_l)/4);

        yy_under=tempon(1:qrt_tr,:);
        [xxc,yycu,piu]=get_acg_PI(yy_under,tp_l(1:qrt_tr),params.gridlag,xx);
        [~,uid]=max(piu(1:100));
        underoverP{ss}.underPl(nn)=gridlag(uid);

        yy_over=tempon(end-qrt_tr:end,:);
        [xxc,yyco,pio]=get_acg_PI(yy_over,tp_l(end-qrt_tr:end),params.gridlag,xx);
        [~,oid]=max(pio(1:100));
        underoverP{ss}.overPl(nn)=gridlag(oid);




        %right
        [tperr,tpsort]=sort(abs(params.tp(trials_r)) - abs(params.ta(trials_r)) );
        tp_=abs(params.tp(trials_r));
        tp_r=tp_(tpsort);

        tempon=data_tensor_smoothedonr(tpsort,:);

        qrt_tr=round(length(tp_r)/4);

        yy_under=tempon(1:qrt_tr,:);
        [xxc,yycu,piu]=get_acg_PI(yy_under,tp_r(1:qrt_tr),params.gridlag,xx);
        [~,uid]=max(piu(1:100));
        underoverP{ss}.underPr(nn)=gridlag(uid);

        yy_over=tempon(end-qrt_tr:end,:);
        [xxc,yyco,pio]=get_acg_PI(yy_over,tp_r(end-qrt_tr:end),params.gridlag,xx);
        [~,oid]=max(pio(1:100));
        underoverP{ss}.overPr(nn)=gridlag(oid);


        %both direction merged
        trials_ = find(params.dist_conditions>3 & params.trial_type==3 & params.seqq<3 & params.attempt==1 & params.lowfr_trials==0);

        data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor(nn,:,trials_))','same');
        data_tensor_smoothedon=data_tensor_smoothed(:,params.window_edge_effect);


        %left
        [tperr,tpsort]=sort(abs(params.tp(trials_)) - abs(params.ta(trials_)) );
        tp_=abs(params.tp(trials_));
        tp_=tp_(tpsort);

        tempon=data_tensor_smoothedon(tpsort,:);

        qrt_tr=round(length(tp_)/4);

        yy_under=tempon(1:qrt_tr,:);
        [xxc,yycu,piu]=get_acg_PI(yy_under,tp_(1:qrt_tr),params.gridlag,xx);
        [~,uid]=max(piu);
        underoverP{ss}.underP(nn)=gridlag(uid);

        yy_over=tempon(end-qrt_tr:end,:);
        [xxc,yyco,pio]=get_acg_PI(yy_over,tp_(end-qrt_tr:end),params.gridlag,xx);
        [~,oid]=max(pio);
        underoverP{ss}.overP(nn)=gridlag(oid);


    end

    cd(params.savedata)
    save([params.animal '_' params.area '_periodicity_underover_dist345.mat' ],'underoverP','params' );
    disp(['===' params.animal '_' params.area '_periodicity_underover_dist345.mat saved===session' num2str(ss) ]  );


end

end
function get_periodicity_under_over_conditioned_by_distance(params,seqid,cp)
%compare periodicity for under and overshoot trials for dist2,3,4,5
%separately

cd([cp.savedir_ '/Fig2/data']);
load('gp_sim_gridnessGP100ms_detrended.mat')
nSTD=2;
params.gridlag=gridlag;
params.null_gridness=gp_95pcnull_gridness;
params.null_gridness_tlag_abovemean_bb=gridness_tlag_abovemean_bb;
params.gridness_thres_pc_abov_mean =  max(mean(params.null_gridness_tlag_abovemean_bb,1)+nSTD*std(params.null_gridness_tlag_abovemean_bb,[],1));%0.1576;%.3276; %2 STD FDR. This number comes from simulation of 1000 Gaussian Process smooth time courses.
params.null_pc_above_mean_gridness=pc_above_mean_gridness;


load([cp.datafolder '/sessions/' ...
    params.animal '_' params.area '_sessions.mat'], 'sessions')

params.mtt_folder=cp.tensordatafolder;
if strcmp(params.area,'7a') && params.animal(1)=='m'
    cd([cp.savedir_ '/Fig2/data']);
    load('mahler_7a_numneurons.mat','mahler_NP_within_session_neurons')
end


trialfraction=cp.trialfraction;
mintr=cp.mintrial;

cd([cp.savedir_ '/Fig2/data']);
load([params.animal '_' params.area '_periodicity_js_leftright_dist345' '.mat'], 'gridness')

underoverP = cell(length(sessions),1);
for ss=1:length(sessions)
    params.filename=sessions{ss};
    clear data_tensor_joyoff

    cd ([params.mtt_folder '/' params.filename '.mwk'])

    varlist=matfile([sessions{ss} '_neur_tensor_joyon']);
    varlistoff=matfile([sessions{ss} '_neur_tensor_joyoff']);
    cond_label=varlist.cond_label;
    cond_matrix=varlist.cond_matrix;
    for ii=1:length(cond_label)
        eval(['params.' cond_label{ii} '=cond_matrix(:,strcmp(cond_label, cond_label{ii} ));']);
    end
    params.dist_conditions = abs(params.target-params.curr);
    params.dir_condition = sign(params.ta);


    if strcmp(params.animal,'mahler') && strcmp(params.area,'7a')
        numneuron=1:mahler_NP_within_session_neurons(ss);
        data_tensor = varlist.neur_tensor_joyon(numneuron,:,:);
        data_tensoroff = varlistoff.neur_tensor_joyoff(numneuron,:,:);
    else
        data_tensor = varlist.neur_tensor_joyon(:,:,:);
        data_tensoroff = varlistoff.neur_tensor_joyoff(:,:,:);
        numneuron = 1:size(varlist,'neur_tensor_joyon',1);
    end

    temp=varlist.joyon;
    params.binwidth=temp.binwidth;
    params.bef=temp.bef;
    params.aft=temp.aft;
    params.edges=temp.edges;
    tempoff=varlistoff.joyoff;
    params.edgesoff=tempoff.edges;

    params.smooth='gauss'; %or 'boxcar'
    params.gauss_smooth=.2; %   smoothing window for psth
    params.gauss_std = .1;   %   std of gaussian filter if gaussian
    params.gauss_smoothing_kern = fspecial('gaussian',[1 params.gauss_smooth/params.binwidth],params.gauss_std/params.binwidth);
    %to remove edge effect of filters, take extra 2*gaussian_filter_size and remove those time points after filtering
    params.window_edge_effect = params.gauss_smooth*2/params.binwidth:(length(params.edges)-params.gauss_smooth*2/params.binwidth);
    params.edges_rev = params.edges(params.window_edge_effect);
    params.edges_revoff = params.edgesoff(params.window_edge_effect);

    gridness_=gridness{ss,1};
    if isempty(gridness_) || ~isfield(gridness_,'pc_above_mean_gridness'),disp 'no gridness for this session'; continue;end
    grid_cells1=find(gridness_.pc_above_mean_gridness>params.gridness_thres_pc_abov_mean &  gridness_.num_trials_mve(:,1)'>mintr);%
    underoverP{ss}.gridnessleft = gridness_.pc_above_mean_gridness;
    gridness_l=gridness{ss,2};
    if isempty(gridness_) || ~isfield(gridness_,'pc_above_mean_gridness')
        grid_cells2=[];    underoverP{ss}.gridnessright=[];

    else
        grid_cells2=find(gridness_.pc_above_mean_gridness>params.gridness_thres_pc_abov_mean &  gridness_.num_trials_mve(:,1)'>mintr);%
        underoverP{ss}.gridnessright=gridness_.pc_above_mean_gridness;

    end

    grid_cells = unique([grid_cells1 grid_cells2]);
    underoverP{ss}.gridness=nan(size(data_tensor,1),2);
    underoverP{ss}.gridcellsleft=grid_cells1;
    underoverP{ss}.gridcellsright=grid_cells2;
    underoverP{ss}.gridcells=grid_cells;
    underoverP{ss}.mintrials=mintr;
    underoverP{ss}.underPr=nan(size(data_tensor,1),1);underoverP{ss}.overPr=nan(size(data_tensor,1),1);
    underoverP{ss}.underPl=nan(size(data_tensor,1),1);underoverP{ss}.overPl=nan(size(data_tensor,1),1);
    underoverP{ss}.underP=nan(size(data_tensor,1),1);underoverP{ss}.overP=nan(size(data_tensor,1),1);

    underoverP{ss}.underProff=nan(size(data_tensor,1),1);underoverP{ss}.overProff=nan(size(data_tensor,1),1);
    underoverP{ss}.underPloff=nan(size(data_tensor,1),1);underoverP{ss}.overPloff=nan(size(data_tensor,1),1);
    underoverP{ss}.underPoff=nan(size(data_tensor,1),1);underoverP{ss}.overPoff=nan(size(data_tensor,1),1);

    if size(data_tensor,3)<length(params.tp)
        data_tensor(:,:,end+1)=0;

    end

    xx=params.edges_rev; xxoff=params.edges_revoff;
    for nn=grid_cells

        params.lowfr_trials = (mean(squeeze(data_tensor(nn,params.edges>0 & params.edges<1,:)),1)<cp.lowfr_thres)';

        %         dir both merged:

        for dist=2:5
            if seqid==12
                trials_ = find(params.dist_conditions==dist & params.trial_type==3 & params.seqq<3 & params.attempt==1 & params.lowfr_trials==0);

            else
                trials_ = find(params.dist_conditions==dist & params.trial_type==3 & params.seqq==seqid & params.attempt==1 & params.lowfr_trials==0);

            end


            [tperr,tpsort]=sort(abs(params.tp(trials_)) - abs(params.ta(trials_)) );
            trials_ = trials_(tpsort);
            if length(trials_)<mintr
                continue;
            end
            qrt_tr=round(length(tpsort)/trialfraction);
            trials_u = [  trials_(1:qrt_tr)];
            trials_o = [  trials_(end-qrt_tr:end)];



            data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor(nn,:,trials_u))','same');
            yy_under=data_tensor_smoothed(:,params.window_edge_effect);

            data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor(nn,:,trials_o))','same');
            yy_over=data_tensor_smoothed(:,params.window_edge_effect);

            data_tensor_smoothedoff=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensoroff(nn,:,trials_u))','same');
            yy_underoff=data_tensor_smoothedoff(:,params.window_edge_effect);

            data_tensor_smoothedoff=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensoroff(nn,:,trials_o))','same');
            yy_overoff=data_tensor_smoothedoff(:,params.window_edge_effect);


            tp_u=abs(params.tp(trials_u));
            tp_o=abs(params.tp(trials_o));

            [xxc,yycu,piu]=get_acg_PI(yy_under,tp_u,params.gridlag,xx);
            [~,uid]=max(piu(1:100));
            underoverP{ss}.underP(nn,dist)=gridlag(uid);

            [xxc,yyco,pio]=get_acg_PI(yy_over,tp_o,params.gridlag,xx);
            [~,oid]=max(pio(1:100));
            underoverP{ss}.overP(nn,dist)=gridlag(oid);


            [xxc,yycu,piu]=get_acg_PI_offset(yy_underoff,tp_u,params.gridlag,xxoff);
            [~,uid]=max(piu(1:100));
            underoverP{ss}.underPoff(nn,dist)=gridlag(uid);

            [xxc,yyco,pio]=get_acg_PI_offset(yy_overoff,tp_o,params.gridlag,xxoff);
            [~,oid]=max(pio(1:100));
            underoverP{ss}.overPoff(nn,dist)=gridlag(oid);

        end

        %         dir left:
        dir=1;
        trials_u=[];trials_o=[];
        for dist=2:5
            if seqid==12

                trials_ = find(params.dir_condition==dir & params.dist_conditions==dist & params.trial_type==3 & params.seqq<3 & params.attempt==1 & params.lowfr_trials==0);
            else
                trials_ = find(params.dir_condition==dir & params.dist_conditions==dist & params.trial_type==3 & params.seqq==seqid & params.attempt==1 & params.lowfr_trials==0);

            end

            [tperr,tpsort]=sort(abs(params.tp(trials_)) - abs(params.ta(trials_)) );
            trials_ = trials_(tpsort);
            if length(trials_)<mintr
                continue;
            end
            qrt_tr=round(length(tpsort)/trialfraction);
            trials_u = [  trials_(1:qrt_tr)];
            trials_o = [  trials_(end-qrt_tr:end)];




            data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor(nn,:,trials_u))','same');
            yy_under=data_tensor_smoothed(:,params.window_edge_effect);

            data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor(nn,:,trials_o))','same');
            yy_over=data_tensor_smoothed(:,params.window_edge_effect);

            data_tensor_smoothedoff=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensoroff(nn,:,trials_u))','same');
            yy_underoff=data_tensor_smoothedoff(:,params.window_edge_effect);

            data_tensor_smoothedoff=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensoroff(nn,:,trials_o))','same');
            yy_overoff=data_tensor_smoothedoff(:,params.window_edge_effect);


            tp_u=abs(params.tp(trials_u));
            tp_o=abs(params.tp(trials_o));

            [xxc,yycu,piu]=get_acg_PI(yy_under,tp_u,params.gridlag,xx);
            [~,uid]=max(piu(1:100));
            underoverP{ss}.underPl(nn,dist)=gridlag(uid);

            [xxc,yyco,pio]=get_acg_PI(yy_over,tp_o,params.gridlag,xx);
            [~,oid]=max(pio(1:100));
            underoverP{ss}.overPl(nn,dist)=gridlag(oid);

            [xxc,yycuoff,piuoff]=get_acg_PI_offset(yy_underoff,tp_u,params.gridlag,xxoff);
            [~,uid]=max(piuoff(1:100));
            underoverP{ss}.underPloff(nn,dist)=gridlag(uid);

            [xxc,yycooff,piooff]=get_acg_PI_offset(yy_overoff,tp_o,params.gridlag,xxoff);
            [~,oid]=max(piooff(1:100));
            underoverP{ss}.overPloff(nn,dist)=gridlag(oid);

            %make plots here of raster, FR, ACG and PI to test the under/over
            %periodicity:
            %          h1=figure('Position',[46   165   872   884]);
            %          subplot(3,2,1); plot(xx,mean(yy_under,1));hold on; plot(xx,mean(yy_over,1));set(gca,'Xtick',0:.65:3,'FontSize',10);grid on
            %          legend('under','over');
            %          subplot(3,2,3); plot(xxc/1000,nanmean(yycu,1));hold on; plot(xxc/1000,nanmean(yyco,1));set(gca,'Xtick',0:.65:3.25,'FontSize',10);grid on
            %          subplot(3,2,5); plot(gridlag/1000,piu);hold on; plot(gridlag/1000,pio);set(gca,'Xtick',0:.65:3,'FontSize',10);grid on
            %           title([underoverP{ss}.underPl(nn,dist)  underoverP{ss}.overPl(nn,dist)])
            %
            %           subplot(3,2,2); plot(xxoff,mean(yy_underoff,1));hold on; plot(xxoff,mean(yy_overoff,1));set(gca,'Xtick',-3.25:.65:0,'FontSize',10);grid on
            %          subplot(3,2,4); plot(xxc/1000,nanmean(yycuoff,1));hold on; plot(xxc/1000,nanmean(yycooff,1));set(gca,'Xtick',0:.65:3.25,'FontSize',10);grid on
            %          subplot(3,2,6); plot(gridlag/1000,piuoff);hold on; plot(gridlag/1000,piooff);set(gca,'Xtick',0:.65:3,'FontSize',10);grid on
            %           title([underoverP{ss}.underPloff(nn,dist)  underoverP{ss}.overPloff(nn,dist)])
            %          sgtitle([params.filename ' neur' num2str(nn) ' DIR: left Dist' num2str(dist)])

        end

        %         dir right:
        dir=-1;

        for dist=2:5
            if seqid==12

                trials_ = find(params.dir_condition==dir & params.dist_conditions==dist & params.trial_type==3 & params.seqq<3 & params.attempt==1 & params.lowfr_trials==0);
            else
                trials_ = find(params.dir_condition==dir & params.dist_conditions==dist & params.trial_type==3 & params.seqq==seqid & params.attempt==1 & params.lowfr_trials==0);

            end
            [tperr,tpsort]=sort(abs(params.tp(trials_)) - abs(params.ta(trials_)) );
            trials_ = trials_(tpsort);
            if length(trials_)<mintr
                continue;
            end
            qrt_tr=round(length(tpsort)/trialfraction);
            trials_u = [  trials_(1:qrt_tr)];
            trials_o = [  trials_(end-qrt_tr:end)];



            data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor(nn,:,trials_u))','same');
            yy_under=data_tensor_smoothed(:,params.window_edge_effect);

            data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor(nn,:,trials_o))','same');
            yy_over=data_tensor_smoothed(:,params.window_edge_effect);

            data_tensor_smoothedoff=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensoroff(nn,:,trials_u))','same');
            yy_underoff=data_tensor_smoothedoff(:,params.window_edge_effect);

            data_tensor_smoothedoff=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensoroff(nn,:,trials_o))','same');
            yy_overoff=data_tensor_smoothedoff(:,params.window_edge_effect);


            tp_u=abs(params.tp(trials_u));
            tp_o=abs(params.tp(trials_o));

            [xxc,yycu,piu]=get_acg_PI(yy_under,tp_u,params.gridlag,xx);
            [~,uid]=max(piu(1:100));
            underoverP{ss}.underPr(nn,dist)=gridlag(uid);

            [xxc,yyco,pio]=get_acg_PI(yy_over,tp_o,params.gridlag,xx);
            [~,oid]=max(pio(1:100));
            underoverP{ss}.overPr(nn,dist)=gridlag(oid);

            [xxc,yycuoff,piuoff]=get_acg_PI_offset(yy_underoff,tp_u,params.gridlag,xxoff);
            [~,uid]=max(piuoff(1:100));
            underoverP{ss}.underProff(nn,dist)=gridlag(uid);

            [xxc,yycooff,piooff]=get_acg_PI_offset(yy_overoff,tp_o,params.gridlag,xxoff);
            [~,oid]=max(piooff(1:100));
            underoverP{ss}.overProff(nn,dist)=gridlag(oid);


            %make plots here of raster, FR, ACG and PI to test the under/over
            %periodicity:
            %              h2=figure('Position',[ 1053         162         872         884]);
            %              subplot(3,2,1); plot(xx,mean(yy_under,1));hold on; plot(xx,mean(yy_over,1));set(gca,'Xtick',0:.65:3,'FontSize',10);grid on
            %              legend('under','over');
            %              subplot(3,2,3); plot(xxc/1000,nanmean(yycu,1));hold on; plot(xxc/1000,nanmean(yyco,1));set(gca,'Xtick',0:.65:3,'FontSize',10);grid on
            %              subplot(3,2,5); plot(gridlag/1000,piu);hold on; plot(gridlag/1000,pio);set(gca,'Xtick',0:.65:3,'FontSize',10);grid on
            %              title([underoverP{ss}.underPr(nn,dist)  underoverP{ss}.overPr(nn,dist)])
            %
            %              subplot(3,2,2); plot(xxoff,mean(yy_underoff,1));hold on; plot(xxoff,mean(yy_overoff,1));set(gca,'Xtick',-3.25:.65:0,'FontSize',10);grid on
            %              subplot(3,2,4); plot(xxc/1000,nanmean(yycuoff,1));hold on; plot(xxc/1000,nanmean(yycooff,1));set(gca,'Xtick',0:.65:3.25,'FontSize',10);grid on
            %              subplot(3,2,6); plot(gridlag/1000,piuoff);hold on; plot(gridlag/1000,piooff);set(gca,'Xtick',0:.65:3,'FontSize',10);grid on
            %              title([underoverP{ss}.underProff(nn,dist)  underoverP{ss}.overProff(nn,dist)])
            %
            %              sgtitle([params.filename ' neur' num2str(nn) ' DIR: right Dist' num2str(dist)])
            %


        end

    end
    params.trialfraction=trialfraction;
    cd(cp.datafolder)
    save([params.animal '_' params.area '_periodicity_underover_dist345_separatedTHRD_seq' num2str(seqid) cp.suffix '.mat' ],'underoverP','params' ,'cp');
    disp(['===' sessions{ss} '_' params.area '_periodicity_underover_dist345_separatedTHRD_seq' num2str(seqid) cp.suffix '.mat saved===session' num2str(ss) ]  );


end

end


function [xxc,yyc,gridness_tlag]=get_acg_PI(yy,tp_,gridlag,xx)


acc_maxlag=2400;
clear yyc
for tr=1:size(yy,1)
    temp=yy(tr,:);
    fr = temp(xx>.1 & xx<(tp_(tr)-.4));
    mdl = fitlm(1:length(fr(10:end-200)),fr(10:end-200)); %choose where exactly to estimate ramp from
    fr=fr-mdl.Coefficients.Estimate(2)*(1:length(fr));
    yyc(tr,:)= xcorr(fr-mean(fr),acc_maxlag,'coeff');
end
xxc=-acc_maxlag:acc_maxlag;

x=nanmean(yyc,1);
ii=1;
for tlag = gridlag
    temp = corrcoef(x,circshift(x,round(tlag)))-corrcoef(x,circshift(x,round(.5*tlag)));
    gridness_tlag(ii)=temp(2);ii=ii+1;
end

end

function [xxc,yyc,gridness_tlag]=get_acg_PI_offset(yy,tp_,gridlag,xx)


acc_maxlag=2400;
clear yyc
for tr=1:size(yy,1)
    temp=yy(tr,:);
    fr = temp(xx<-.4 & xx>(-tp_(tr)+.1));
    mdl = fitlm(1:length(fr(10:end-200)),fr(10:end-200)); %choose where exactly to estimate ramp from
    fr=fr-mdl.Coefficients.Estimate(2)*(1:length(fr));
    yyc(tr,:)= xcorr(fr-mean(fr),acc_maxlag,'coeff');
end
xxc=-acc_maxlag:acc_maxlag;

x=nanmean(yyc,1);
ii=1;
for tlag = gridlag
    temp = corrcoef(x,circshift(x,round(tlag)))-corrcoef(x,circshift(x,round(.5*tlag)));
    gridness_tlag(ii)=temp(2);ii=ii+1;
end

end




%===functions for plotting single neuron psth===:
function [hpsth,maxx,icfc2,T]=plot_scaled_psth(data,params, trials)

num_tpbins=5;
scaling_binwidth=0.04;%sec

if length(trials)<10  %unstable neurons if there aren't enough trials
    disp([params.filename num2str(neur) ' skipped. Too unstable neuron'])
    return;
end

tpp=abs(params.tp(trials));
taa=abs(params.dist_conditions(trials));

%smooth FR:
data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data.data_tensor_joyon(1,:,trials))','same');
psth_on=data_tensor_smoothed(:,params.window_edge_effect);

data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data.data_tensor_joyoff(1,:,trials))','same');
psth_off=data_tensor_smoothed(:,params.window_edge_effect);

%get median tps for scaling
for dd=1:num_tpbins

    tr=find(taa==dd);
    tptemp = tpp(tr);

    icfc2.median_time_scaling(dd)=median(tptemp);%
    icfc2.edges_on_scaled{dd} = 0:scaling_binwidth:icfc2.median_time_scaling(dd);
    icfc2.edges_off_scaled{dd} = -icfc2.median_time_scaling(dd):scaling_binwidth:0;
    num_scaling_bins(dd) = length(icfc2.edges_on_scaled{dd})+1;
    num_scaling_binsoff(dd) = length(icfc2.edges_off_scaled{dd})+1;


end
neur=params.neur;

% get psth for each tpbin with scaling:
clear frtemp_scaled frtemp_scaledoff frmean_scaled frmean_scaledoff frsem_scaled frsem_scaledoff numtrials
for dd=1:num_tpbins

    tr=find(taa==dd);
    if length(tr)<5
        icfc2.frmean_scaled_allneurons{dd}(neur,:)=nan(1,length(0:scaling_binwidth:icfc2.median_time_scaling(dd)));
        icfc2.frmean_scaled_allneuronsoff{dd}(neur,:)=nan(1,length(0:scaling_binwidth:icfc2.median_time_scaling(dd)));
        icfc2.numtrials(neur,dd)=0;

        continue;
    end
    tptemp = tpp(tr);



    %   psth scaling:
    for tri=1:length(tr)
        ttscaling=params.edges_rev>0 & params.edges_rev<tptemp(tri);
        edgs_true = params.edges_rev(ttscaling);
        edgs_scaled = linspace(0,tptemp(tri),num_scaling_bins(dd));
        frtemp = psth_on(tr(tri),ttscaling);
        for scaledbin = 1:length(edgs_scaled)-1
            frtemp_scaled{dd}(tri,scaledbin)=mean(frtemp(edgs_true>(edgs_scaled(scaledbin)) & edgs_true<(edgs_scaled(scaledbin+1))));
        end

        ttscalingoff=params.edges_revoff>-tptemp(tri) & params.edges_revoff<0;
        edgs_trueoff = params.edges_revoff(ttscalingoff);
        edgs_scaledoff = linspace(-tptemp(tri),0,num_scaling_binsoff(dd));
        frtemp = psth_off(tr(tri),ttscalingoff);
        for scaledbin = 1:length(edgs_scaledoff)-1
            frtemp_scaledoff{dd}(tri,scaledbin)=mean(frtemp(edgs_trueoff>(edgs_scaledoff(scaledbin)) & edgs_trueoff<(edgs_scaledoff(scaledbin+1))));
        end
    end

    icfc2.frmean_scaled_allneurons{dd}(neur,:)=nanmean(frtemp_scaled{dd},1)';
    icfc2.frmean_scaled_allneuronsoff{dd}(neur,:)=nanmean(frtemp_scaledoff{dd},1)';
    icfc2.frsem_scaled_allneurons{dd}(neur,:)=nanstd(frtemp_scaled{dd},[],1)/sqrt(size(frtemp_scaled{dd},1))';
    icfc2.frsem_scaled_allneuronsoff{dd}(neur,:)=nanstd(frtemp_scaledoff{dd},[],1)/sqrt(size(frtemp_scaledoff{dd},1))';
    icfc2.numtrials(neur,dd)=size(frtemp_scaled{dd},1);


end
icfc2.fron_scaled{neur}=frtemp_scaled;
icfc2.froff_scaled{neur}=frtemp_scaledoff;


nn=neur;
xtikson = 0:.65:3.25;
xtiksoff = -3.25:.65:0;
hcol=params.hcol;
maxx=eps;


[hpsth,T]=plot_psth_rsq(icfc2.edges_on_scaled,icfc2.edges_off_scaled,icfc2, hcol,params);

sgtitle([params.filename ' neur ' num2str(params.neur)   ])


end


function [hpsth,T]=plot_psth_rsq(edges_on_scaled,edges_off_scaled,icfc2,hcol,params)

hpsth=figure('Position',[ 1000         612         878         725]);
for dd=1:5
    frmean_scaled{dd} = icfc2.frmean_scaled_allneurons{dd}(params.neur,:);
    frmean_scaledoff{dd} = icfc2.frmean_scaled_allneuronsoff{dd}(params.neur,:);
    frsem_scaled{dd} = icfc2.frsem_scaled_allneurons{dd}(params.neur,:);
    frsem_scaledoff{dd} = icfc2.frsem_scaled_allneuronsoff{dd}(params.neur,:);


end
xtikson = 0:.65:3.25;
xtiksoff = -3.25:.65:0;
dist_onset=[];time_JS_onset=[];firing_rate=[];firing_rate_SEM=[];
dist_offset=[];time_JS_offset=[];firing_rate_offset=[];firing_rate_SEM_offset=[];

for dd=1:length(frmean_scaled)
    eval(['time_x_dist' num2str(dd) '=edges_on_scaled{dd};'])
    eval(['meanFR_dist' num2str(dd) '=frmean_scaled{dd};'])
    eval(['semFR_dist' num2str(dd) '=frsem_scaled{dd};'])

    eval(['time_x_dist_JSoffset' num2str(dd) '=edges_off_scaled{dd};'])
    eval(['meanFR_dist_JSoffset' num2str(dd) '=frmean_scaledoff{dd};'])
    eval(['semFR_dist_JSoffset' num2str(dd) '=frsem_scaledoff{dd};'])


    subplot(2,2,1);plotpatchstd(edges_on_scaled{dd},frmean_scaled{dd},frsem_scaled{dd},hcol(dd,:),.25,2);
    subplot(2,2,2);plotpatchstd(edges_off_scaled{dd},frmean_scaledoff{dd},frsem_scaledoff{dd},hcol(dd,:),.25,2);

    %sanity check:
    eval(['xx=time_x_dist' num2str(dd)  ';'])
    eval(['yy=meanFR_dist' num2str(dd)  ';'])
    eval(['yysem=semFR_dist' num2str(dd)  ';'])
    subplot(2,2,3);plotpatchstd(xx,yy,yysem,hcol(dd,:),.25,2);
    dist_onset = [dist_onset; dd*ones(length(xx),1)];
    time_JS_onset=[time_JS_onset; xx(:)];
    firing_rate=[firing_rate;yy(:)];
    firing_rate_SEM=[firing_rate_SEM; yysem(:)];


    eval(['xx=time_x_dist_JSoffset' num2str(dd)  ';'])
    eval(['yy=meanFR_dist_JSoffset' num2str(dd)  ';'])
    eval(['yysem=semFR_dist_JSoffset' num2str(dd)  ';'])
    subplot(2,2,4);plotpatchstd(edges_off_scaled{dd},frmean_scaledoff{dd},frsem_scaledoff{dd},hcol(dd,:),.25,2);


    dist_offset = [dist_offset; dd*ones(length(xx),1)];
    time_JS_offset=[time_JS_offset; xx(:)];
    firing_rate_offset=[firing_rate_offset;yy(:)];
    firing_rate_SEM_offset=[firing_rate_SEM_offset; yysem(:)];

end
subplot(2,2,1);set(gca,'FontSize',15,'XTick',xtikson);grid on; title 'scaled FR';xlim([0 3.25])
xlabel 'Time re. JS onset(s)';ylabel spk/s
subplot(2,2,2);set(gca,'FontSize',15,'XTick',xtiksoff);grid on; xlim([-3.25 0])
xlabel 'Time re. JS offset(s)';


%save_data_for_paper

nhp_neuron_id = repmat([params.filename ' neur ' num2str(params.neur)   ],[length(dist_onset), 1]);
dist=dist_onset;
T = table(nhp_neuron_id,dist,time_JS_onset,firing_rate, firing_rate_SEM,...
    time_JS_offset,firing_rate_offset,firing_rate_SEM_offset);



end


function [params,data]= load_data_single_neuron(params,allneur,cp)

cd([cp.savedir_ '/Fig2/data/sessions']);
load([params.animal '_' params.area '_sessions.mat'], 'sessions')

params.mtt_folder=cp.tensordatafolder;
if strcmp(params.area,'7a') && params.animal(1)=='m'
    cd([cp.savedir_ '/Fig2/data']);
    load('mahler_7a_numneurons.mat','mahler_NP_within_session_neurons')
end


params.filename=sessions{params.ss};

cd ([params.mtt_folder '/' params.filename '.mwk'])
varlist=matfile([sessions{params.ss} '_neur_tensor_joyon']);
cond_label=varlist.cond_label;
cond_matrix=varlist.cond_matrix;
for ii=1:length(cond_label)
    eval(['params.' cond_label{ii} '=cond_matrix(:,strcmp(cond_label, cond_label{ii} ));']);
end
temp=varlist.joyon;
params.edges = temp.edges;
params.binwidth = temp.binwidth;

params.dist_conditions = abs(params.target-params.curr);
params.dir_condition = sign(params.ta);

params.smooth='gauss'; %or 'boxcar'
params.gauss_smooth=cp.gausswin; %   smoothing window for psth
params.gauss_std = cp.gaussstd;   %   std of gaussian filter if gaussian
params.gauss_smoothing_kern = fspecial('gaussian',[1 params.gauss_smooth/params.binwidth],params.gauss_std/params.binwidth);
%to remove edge effect of filters, take extra 2*gaussian_filter_size and remove those time points after filtering
params.window_edge_effect = params.gauss_smooth*2/params.binwidth:(length(params.edges)-params.gauss_smooth*2/params.binwidth);
params.edges_rev = params.edges(params.window_edge_effect);

varlist_off=matfile([sessions{params.ss} '_neur_tensor_joyoff']);

if allneur==1
    data.data_tensor_joyon = varlist.neur_tensor_joyon(:,:,:);
    data.data_tensor_joyoff = varlist_off.neur_tensor_joyoff(:,:,:);
elseif allneur==0
    data.data_tensor_joyon = varlist.neur_tensor_joyon(params.neur,:,:);
    data.data_tensor_joyoff = varlist_off.neur_tensor_joyoff(params.neur,:,:);
else
    disp 'getting eye and joystick data...'

    data.eyex_joyon = varlist.eyex_tensor_joyon;
    data.eyey_joyon = varlist.eyey_tensor_joyon;
    data.eyet_joyon = varlist.joyon_edges_eyet;
    data.hand_joyon = varlist.hand_tensor_joyon;

    data.eyex_joyoff = varlist_off.eyex_tensor_joyoff;
    data.eyey_joyoff = varlist_off.eyey_tensor_joyoff;
    data.eyet_joyoff = varlist_off.joyoff_edges_eyet;
    data.hand_joyoff = varlist_off.hand_tensor_joyoff;
end

joyoff=varlist_off.joyoff;
params.edgesoff=joyoff.edges;
params.edges_revoff=joyoff.edges(params.window_edge_effect);
params.numneur=size(varlist.neur_tensor_joyon,1);

if ~cp.geteyehand
    if size(data.data_tensor_joyon,3)<length(params.ta)

        data.data_tensor_joyon(:,:,end+1)=0;
        data.data_tensor_joyoff(:,:,end+1)=0;

    end
end

end

%=== single neuron bump phase w.r.t. jotstick on/off
function [hoff,hon,T]=plot_raster_bump_phase(data,params,cp)
seqid=cp.seq;
dir=-1;
xxoff=params.edges_revoff;
xxon=params.edges_rev;
params.lowfr_trials = (mean(squeeze(data.data_tensor_joyoff(1,params.edgesoff>-1 & params.edgesoff<0,:)),1)<=cp.lowfr_thres)';

if seqid==12
    trials_ = find(params.seqq<3 & params.dist_conditions>3  & params.dir_condition==dir & params.trial_type==3  & params.validtrials_mm==1 & params.lowfr_trials==0);
else
    trials_ = find(params.seqq==seqid & params.dist_conditions>3  & params.dir_condition==dir & params.trial_type==3  & params.attempt==1 & params.lowfr_trials==0);

end

data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data.data_tensor_joyoff(1,:,trials_))','same');
data_tensor_smoothedoff=data_tensor_smoothed(:,params.window_edge_effect);
data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data.data_tensor_joyon(1,:,trials_))','same');
data_tensor_smoothedon=data_tensor_smoothed(:,params.window_edge_effect);
[tp_,tpsort]=sort(abs(params.tp(trials_)));
temp=data_tensor_smoothedoff(tpsort,:);
tempon=data_tensor_smoothedon(tpsort,:);





% bootstraped histogram of last peak loc compared to shuffled (circshifted) NULL
offset=.1;
offseton=.3;
bumpphase_window=1;
btrp=1000;

lastpeakbb=nan(btrp,3);firstpeakbb=lastpeakbb;
lastpeakbbsh=nan(btrp,3);firstpeakbbsh=lastpeakbbsh;

for bb=1:btrp
    trials_bb=randperm(length(trials_),ceil(length(trials_)/3));
    tempyy=mean(temp(trials_bb,:),1);
    tempyyon=mean(tempon(trials_bb,:),1);

    [lastpeakbb(bb,:)]= get_max_local_peaks(tempyy,xxoff,[-bumpphase_window -offset]);
    [firstpeakbb(bb,:)]= get_max_local_peaks(tempyyon,xxon,[offseton bumpphase_window]);


    for tr=1:length(trials_bb)
        p=circshift(1:size(temp,2),randi(size(temp,2)));
        %          p=randperm(size(temp,2));
        tempshuf(tr,:)=   temp(trials_bb(tr),p);
        tempshufon(tr,:)=   tempon(trials_bb(tr),p);
    end
    tempyysh=mean(tempshuf,1);
    tempyyshon=mean(tempshufon,1);



    [lastpeakbbsh(bb,:)]= get_max_local_peaks(tempyysh,xxoff,[-bumpphase_window -offset]);
    [firstpeakbbsh(bb,:)]= get_max_local_peaks(tempyyshon,xxon,[offseton bumpphase_window]);


end

lastpeak=nan(length(trials_),3);firstpeak=lastpeak;
lastpeaksh=nan(length(trials_),3);firstpeaksh=lastpeaksh;

for tr=1:length(trials_)
    tempyy= temp(tr,:) ;
    tempyyon= tempon(tr,:) ;

    lastpeak(tr,:)= get_max_local_peaks(tempyy,xxoff,[-bumpphase_window -offset]);
    firstpeak(tr,:)= get_max_local_peaks(tempyyon,xxon,[offseton bumpphase_window]);


    shiftedtimes=circshift(1:size(temp,2),randi(size(temp,2)));
    %      shiftedtimes=randperm(size(temp,2));
    tempyyshuf =   temp(tr,shiftedtimes);
    tempyyonshuf =   tempon(tr,shiftedtimes);
    lastpeaksh(tr,:)= get_max_local_peaks(tempyyshuf,xxoff,[-bumpphase_window -offset]);
    firstpeaksh(tr,:)= get_max_local_peaks(tempyyonshuf,xxon,[offseton bumpphase_window]);

end


[h,pval(1),kstats(1)]=kstest2(lastpeakbb(:,1),lastpeakbbsh(:,1),'Alpha',.05);
[h,pval(2),kstats(2)]=kstest2(lastpeakbb(:,2),lastpeakbbsh(:,2),'Alpha',.05);
[h,pval(3),kstats(3)]=kstest2(lastpeakbb(:,3),lastpeakbbsh(:,3),'Alpha',.05);

[h1,pval1(1),kstats1(1)]=kstest2(firstpeakbb(:,1),firstpeakbbsh(:,1),'Alpha',.05);
[h1,pval1(2),kstats1(2)]=kstest2(firstpeakbb(:,2),firstpeakbbsh(:,2),'Alpha',.05);
[h1,pval1(3),kstats1(3)]=kstest2(firstpeakbb(:,3),firstpeakbbsh(:,3),'Alpha',.05);


mode_peakbb(1,:)=[mode(lastpeakbb(:,1)) mode(lastpeakbbsh(:,1)) ];
mode_peakbb(2,:)=[mode(lastpeakbb(:,2)) mode(lastpeakbbsh(:,2)) ];
mode_peakbb(3,:)=[mode(lastpeakbb(:,3)) mode(lastpeakbbsh(:,3)) ];
mode_peakbb1(1,:)=[mode(firstpeakbb(:,1)) mode(firstpeakbbsh(:,1)) ];
mode_peakbb1(2,:)=[mode(firstpeakbb(:,2)) mode(firstpeakbbsh(:,2)) ];
mode_peakbb1(3,:)=[mode(firstpeakbb(:,3)) mode(firstpeakbbsh(:,3)) ];


ttl=find(xxoff>-3.5 & xxoff<.5);
yy_peak1=mean(temp(:,ttl),1);
hoff=figure('Position',[ 1234         453         676         553]);
subplot(4,2,1);plot(xxoff(ttl),yy_peak1);hold on;
set(gca,'Xtick',-3.25:.65:0);grid on; addline(-3.25:.65:0);
xlim([-3.5 .5]);ylabel spk/s; xlabel 'Time re. joystick offset'

subplot(4,2,2);imagesc(xxoff(ttl),1:length(trials_),temp(:,ttl));hold on;
set(gca,'Xtick',-3.25:.65:0);grid on; addline(-3.25:.65:0);
scatter(-tp_,1:length(trials_),15,'or','Filled')
xlim([-3.5 .5]);xlabel 'Time re. joystick offset'; ylabel trials
caxis([0 10])

subplot(4,2,4);histogram(lastpeakbb(:,1),[-4:.15:0],'Normalization','probability');hold on; set(gca,'Xtick',-.65*4:.65:0);grid on;  hold on;
histogram(lastpeakbbsh(:,1),[-4:.1:0],'Normalization','probability','FaceAlpha',.5); xlim([-3.5 .5]);%ylim([0 500]);
title (['mode perd= ' num2str(mode_peakbb(1,1)) 's, ' num2str(mode_peakbb(1,2)) 's (shf)'])
ylabel #Bootstrp

subplot(4,2,6);histogram(lastpeakbb(:,2),[-4:.15:0],'Normalization','probability');hold on; set(gca,'Xtick',-.65*4:.65:0);grid on;  hold on;
histogram(lastpeakbbsh(:,2),[-4:.1:0],'FaceAlpha',.5,'Normalization','probability'); xlim([-3.5 .5]);%ylim([0 500]);
title (['mode perd= ' num2str(mode_peakbb(2,1)) 's, ' num2str(mode_peakbb(2,2)) 's (shf)'])
ylabel #Bootstrp

subplot(4,2,8);histogram(lastpeakbb(:,3),[-4:.15:0],'Normalization','probability');hold on; set(gca,'Xtick',-.65*4:.65:0);grid on;  hold on;
histogram(lastpeakbbsh(:,3),[-4:.1:0],'FaceAlpha',.5,'Normalization','probability'); xlim([-3.5 .5]);
title (['mode perd= ' num2str(mode_peakbb(3,1)) 's, ' num2str(mode_peakbb(3,2)) 's (shf)'])
ylabel #Bootstrp

ylimm=round(length(lastpeak)/50)*10;
subplot(4,2,3);histogram(lastpeak(:,1),[-4:.15:0],'Normalization','probability');hold on; set(gca,'Xtick',-.65*4:.65:0);grid on;  hold on;xlim([-3.5 .5]);
histogram(lastpeaksh(:,1),[-4:.1:0],'FaceAlpha',.5,'Normalization','probability');

%data for writing to exel sheet: 
nhp_neuron_id = repmat([params.filename ' neur ' num2str(params.neur)   ],[length(lastpeakbb), 1]);
first_peak = lastpeakbb(:,1);second_peak = lastpeakbb(:,2);third_peak = lastpeakbb(:,3);
first_peak_shuf = lastpeakbbsh(:,1);second_peak_shuf = lastpeakbbsh(:,2);third_peak_shuf = lastpeakbbsh(:,3);
T = table(nhp_neuron_id,first_peak,second_peak,third_peak,first_peak_shuf,...
    second_peak_shuf,third_peak_shuf);


title(['kstest,p=' num2str(pval(1))]);
xlim([-3.5 .5]);
xlabel 'Last peak phase'
ylabel #
legend('data','shuf','Location','northwest')

subplot(4,2,5);histogram(lastpeak(:,2),[-4:.15:0],'Normalization','probability');hold on; set(gca,'Xtick',-.65*4:.65:0);grid on;xlim([-3.5 .5]);
histogram(lastpeaksh(:,2),[-4:.1:0],'FaceAlpha',.5,'Normalization','probability');
title(['kstest,p=' num2str(pval(2))]);%ylim([0 ylimm]);
xlim([-3.5 .5]);
xlabel '2nd last peak phase'
ylabel #

subplot(4,2,7);histogram(lastpeak(:,3),[-4:.15:0],'Normalization','probability');hold on; set(gca,'Xtick',-.65*4:.65:0);grid on;xlim([-3.5 .5]);
histogram(lastpeaksh(:,3),[-4:.1:0],'FaceAlpha',.5,'Normalization','probability');
title(['kstest,p=' num2str(pval(3))]);
xlim([-3.5 .5]);
xlabel '3rd last peak phase'
ylabel #
sgtitle([params.filename ' neur' num2str(params.neur) ' peak locations OFFSET']);






%onset
ttl=find(xxon>-.5 & xxon<3.5);
yy_peak1=mean(tempon(:,ttl),1);
hon=figure('Position',[451   496   676   553]);
subplot(4,2,1);plot(xxon(ttl),yy_peak1);hold on;
set(gca,'Xtick',0:.65:3.25);grid on; addline(0:.65:3.25);
xlim([-.5 3.5]);ylabel spk/s; xlabel 'Time re. joystick onset'

subplot(4,2,2);imagesc(xxon(ttl),1:length(trials_),tempon(:,ttl));hold on;
set(gca,'Xtick',0:.65:3.25);grid on; addline(0:.65:3.25);
scatter(tp_,1:length(trials_),15,'or','Filled')
xlim([-.5 3.5]);xlabel 'Time re. joystick onset'; ylabel trials
caxis([0 10])

subplot(4,2,4);histogram(firstpeakbb(:,1),[0:.15:4],'Normalization','probability');hold on; set(gca,'Xtick',0:.65:4*.65);grid on;  hold on;
histogram(firstpeakbbsh(:,1),[0:.1:4],'FaceAlpha',.5,'Normalization','probability'); xlim([-.5 3.5]);
ylabel '#Bootstrps'
title (['mode perd= ' num2str(mode_peakbb1(1,1)) 's, ' num2str(mode_peakbb1(1,2)) 's (shf)'])

subplot(4,2,6);histogram(firstpeakbb(:,2),[0:.15:4],'Normalization','probability');hold on; set(gca,'Xtick',0:.65:4*.65);grid on;  hold on;
histogram(firstpeakbbsh(:,2),[0:.1:4],'FaceAlpha',.5,'Normalization','probability'); xlim([-.5 3.5]);
ylabel '#Bootstrps'
title (['mode perd= ' num2str(mode_peakbb1(2,1)) 's, ' num2str(mode_peakbb1(2,2)) 's (shf)'])

subplot(4,2,8);histogram(firstpeakbb(:,3),[0:.15:4],'Normalization','probability');hold on; set(gca,'Xtick',0:.65:4*.65);grid on;  hold on;
histogram(firstpeakbbsh(:,3),[0:.1:4],'FaceAlpha',.5,'Normalization','probability'); xlim([-.5 3.5]);
ylabel '#Bootstrps'
title (['mode perd= ' num2str(mode_peakbb1(3,1)) 's, ' num2str(mode_peakbb1(3,2)) 's (shf)'])

subplot(4,2,3);histogram(firstpeak(:,1),[0:.15:4],'Normalization','probability');hold on; set(gca,'Xtick',0:.65:4*.65);grid on;  hold on;xlim([-.5 3.5]);
histogram(firstpeaksh(:,1),[0:.1:4],'FaceAlpha',.5,'Normalization','probability');

title(['kstest,p=' num2str(pval1(1))]); xlim([-.5 3.5]);
xlabel 'First peak phase'
ylabel #trials
legend('data','shuf','Location','northeast')

subplot(4,2,5);histogram(firstpeak(:,2),[0:.15:4],'Normalization','probability');hold on; set(gca,'Xtick',0:.65:4*.65);grid on;xlim([-.5 3.5]);
histogram(firstpeaksh(:,2),[0:.1:4],'FaceAlpha',.5,'Normalization','probability');
title(['kstest,p=' num2str(pval1(2))]); xlim([-.5 3.5]);
xlabel '2nd peak phase'
ylabel #trials

subplot(4,2,7);histogram(firstpeak(:,3),[0:.15:4],'Normalization','probability');hold on; set(gca,'Xtick',0:.65:4*.65);grid on;xlim([-.5 3.5]);
histogram(firstpeaksh(:,3),[0:.1:4],'FaceAlpha',.5,'Normalization','probability');
title(['kstest,p=' num2str(pval1(3))]); xlim([-.5 3.5]);
xlabel '3rd peak phase'
ylabel #trials
sgtitle([params.filename ' neur' num2str(params.neur) ' peak locations ONSET']);


end



function [maxlocalpeak]= get_max_local_peaks(fr,xx,rangeori)
range=rangeori;
ttt = xx>range(1) & xx<range(2)  ;
xxt = xx(ttt);
tempyy=fr(ttt);

tempyy=(tempyy-min(tempyy))/max(eps,(max(tempyy)-min(tempyy)));

[pks,peak1_phase]=findpeaks(tempyy,xxt,'MinPeakProminence',.05 );

if isempty(peak1_phase)
    maxlocalpeak(1:3)=nan;
else
    [~,maxid]=max(pks);
    maxlocalpeak(1)=  peak1_phase(maxid);

    range=rangeori+maxlocalpeak(1);
    ttt = xx>range(1) & xx<range(2)  ;
    xxt = xx(ttt);
    tempyy=fr(ttt);
    tempyy=(tempyy-min(tempyy))/max(eps,(max(tempyy)-min(tempyy)));
    [pks,peak1_phase]=findpeaks(tempyy,xxt,'MinPeakProminence',.05 );

    if isempty(peak1_phase)
        maxlocalpeak(2:3)=nan;
    else
        [~,maxid]=max(pks);
        maxlocalpeak(2)=  peak1_phase(maxid);

        range=rangeori+maxlocalpeak(2);
        ttt = xx>range(1) & xx<range(2)  ;
        xxt = xx(ttt);
        tempyy=fr(ttt);
        tempyy=(tempyy-min(tempyy))/max(eps,(max(tempyy)-min(tempyy)));
        [pks,peak1_phase]=findpeaks(tempyy,xxt,'MinPeakProminence',.05 );


        if isempty(peak1_phase)
            maxlocalpeak(3)=nan;
        else
            [~,maxid]=max(pks);
            maxlocalpeak(3)=  peak1_phase(maxid);
        end

    end

end

end

%=== single neuron raster and ACG
function [hf,T]=plot_raster_acg(data,params,cp)

hf=figure('Position',[ 19          76        2030         561]);

xtikson = .65:2*.65:3.25;
xtiksoff = -3.25:.65:0;
time_start=-.65;
time_stop=3.25+.65;
tt = find(params.edges_rev>time_start & params.edges_rev<time_stop);
ttoff = find(params.edges_revoff<-time_start & params.edges_revoff>-time_stop);
xx=params.edges_rev(tt);
xxoff=params.edges_revoff(ttoff);
%Null gridness:
cd([cp.savedir_ '/Fig2/data']);
load('gp_sim_gridnessGP100ms_detrended.mat')


params.lowfr_trials = (mean(squeeze(data.data_tensor_joyoff(1,params.edgesoff>-.85 & params.edgesoff<0,:)),1)<=cp.lowfr_thres)';
if cp.seq==12
    trials = find(params.seqq<3 & params.dist_conditions>3 & params.dir_condition==1 & params.validtrials_mm==1 & params.trial_type==3  & params.lowfr_trials==0);
    trialsdir2 = find(params.seqq<3 & params.dist_conditions>3 & params.dir_condition==-1 & params.validtrials_mm==1 & params.trial_type==3  & params.lowfr_trials==0);
else
    trials = find(params.seqq==cp.seq & params.dist_conditions>3 & params.dir_condition==1 & params.validtrials_mm==1 & params.trial_type==3  & params.lowfr_trials==0);
    trialsdir2 = find(params.seqq==cp.seq & params.dist_conditions>3 & params.dir_condition==-1 & params.validtrials_mm==1 & params.trial_type==3  & params.lowfr_trials==0);
end

tp_=abs(params.tp(trials));
[tp_,tpsort] = sort(tp_,'ascend');
temp=conv2(1,params.gauss_smoothing_kern,squeeze(data.data_tensor_joyon(1,:,trials))','same');
temp=temp(tpsort,params.window_edge_effect);
tempoff=conv2(1,params.gauss_smoothing_kern,squeeze(data.data_tensor_joyoff(1,:,trials))','same');
tempoff=tempoff(tpsort,params.window_edge_effect);
psth_ = temp(:,tt);
psth_off = tempoff(:,ttoff);

subplot(2,4,1);
imagesc(xx,1:size(psth_,1),psth_);caxis([0 params.maxx])
ylabel trials; set(gca,'XTick',sort(xtikson),'FontSize',15);hold on;
scatter(tp_,1:length(tp_),25,'or');
addline(sort(xtikson));xlabel time(sec); colorbar;
xlabel 'Time re. jotstick onset(sec)'; ylabel trials;
addline([0 3.25],'color','k');

subplot(2,4,2);
imagesc(xxoff,1:size(psth_off,1),psth_off);caxis([0 params.maxx])
ylabel trials; set(gca,'XTick',sort(xtiksoff),'FontSize',15);hold on;
scatter(-tp_,1:length(tp_),25,'or');
addline(sort(xtiksoff));xlabel time(sec); colorbar;
xlabel 'Time re. jotstick offset(sec)'
ylabel trials;
addline([-3.25 0],'color','k');

acc_maxlag=2400;
clear yyc
yy=psth_;
for tr=1:size(yy,1)
    temp=yy(tr,:);
    fr = temp(xx>0 & xx<tp_(tr));
    mdl = fitlm(1:length(fr(10:end-200)),fr(10:end-200)); %choose where exactly to estimate ramp from
    fr=fr-mdl.Coefficients.Estimate(2)*(1:length(fr));
    yyc(tr,:)= xcorr(fr-mean(fr),acc_maxlag,'coeff');
    subplot(2,4,5);
    tempcc= xcorr(fr-mean(fr),'coeff');
    plot(linspace(-tp_(tr),tp_(tr),length(tempcc)),tempcc,'color',[.75 .75 .75]);hold on
    xlabel lag(sec); ylabel ACG
end
xxc=-acc_maxlag:acc_maxlag;
plot(xxc/1000,nanmean(yyc,1),'-r','LineWidth',2);
ylim([-1 1]);xlim([-3.25 3.25])
set(gca,'XTick',sort(xtikson),'FontSize',15);
grid on; title 'dist 4 and 5 dir 1'


subplot(2,4,6);hold off
plot(gridlag/1000,gp_95pcnull_gridness,'--k','LineWidth',2);grid on; hold on
x=nanmean(yyc,1);
clear gridness_tlag
ii=1;
for tlag = gridlag
    temp = corrcoef(x,circshift(x,round(tlag)))-corrcoef(x,circshift(x,round(.5*tlag)));
    gridness_tlag(ii)=temp(2);ii=ii+1;
end
plot(gridlag/1000,gridness_tlag,'-r','LineWidth',2);grid on;addline(xtikson(1:2));addline(0','h');
xlabel periodicity(sec);ylabel gridness; ylim([-1 1])
set(gca,'XTick',sort(xtikson),'FontSize',15);


trials = trialsdir2;
tp_=abs(params.tp(trials));
[tp_,tpsort] = sort(tp_,'ascend');
temp=conv2(1,params.gauss_smoothing_kern,squeeze(data.data_tensor_joyon(1,:,trials))','same');
temp=temp(tpsort,params.window_edge_effect);
tempoff=conv2(1,params.gauss_smoothing_kern,squeeze(data.data_tensor_joyoff(1,:,trials))','same');
tempoff=tempoff(tpsort,params.window_edge_effect);
psth_ = temp(:,tt);
psth_off = tempoff(:,ttoff);

subplot(2,4,3);
imagesc(xx,1:size(psth_,1),psth_);caxis([0 params.maxx])
ylabel trials; set(gca,'XTick',sort(xtikson),'FontSize',15);hold on;
scatter(tp_,1:length(tp_),25,'or');
addline(sort(xtikson));xlabel time(sec); colorbar;
xlabel 'Time re. jotstick onset(sec)'; ylabel trials;
addline([0 3.25],'color','k');

subplot(2,4,4);
imagesc(xxoff,1:size(psth_off,1),psth_off);caxis([0 params.maxx])
ylabel trials; set(gca,'XTick',sort(xtiksoff),'FontSize',15);hold on;
scatter(-tp_,1:length(tp_),25,'or');
addline(sort(xtiksoff));xlabel time(sec); colorbar;
xlabel 'Time re. jotstick offset(sec)'
ylabel trials;
addline([-3.25 0],'color','k');


%write direction right data to excel sheet for the paper - not needed for
%image data
% nhp_neuron_id = repmat([params.filename ' neur ' num2str(params.neur)   ],[length(tp_), 1]);
% T = table(nhp_neuron_id,tp_);
% if cp.save_example_figures==1
%     cd(params.savedir_area);
%     writetable(T,'Fig2.xlsx','Sheet','fig_2b')
%     writematrix([xx; psth_],'Fig2.xlsx','Sheet','fig_2b','Range','E1')
%     writematrix([xxoff;psth_off],'Fig2.xlsx','Sheet','fig_2b','Range','E95')
% end

acc_maxlag=2400;
clear yyc
yy=psth_;
for tr=1:size(yy,1)
    temp=yy(tr,:);
    fr = temp(xx>0 & xx<tp_(tr));
    mdl = fitlm(1:length(fr(10:end-200)),fr(10:end-200)); %choose where exactly to estimate ramp from
    fr=fr-mdl.Coefficients.Estimate(2)*(1:length(fr));
    yyc(tr,:)= xcorr(fr-mean(fr),acc_maxlag,'coeff');
    subplot(2,4,7);
    tempcc= xcorr(fr-mean(fr),'coeff');
    plot(linspace(-tp_(tr),tp_(tr),length(tempcc)),tempcc,'color',[.75 .75 .75]);hold on
    xlabel lag(sec); ylabel ACG
end
xxc=-acc_maxlag:acc_maxlag;
plot(xxc/1000,nanmean(yyc,1),'-r','LineWidth',2);
ylim([-1 1]);xlim([-3.25 3.25])
set(gca,'XTick',sort(xtikson),'FontSize',15);
grid on; title 'dist 4 and 5 dir 2'


subplot(2,4,8);hold off
plot(gridlag/1000,gp_95pcnull_gridness,'--k','LineWidth',2);grid on; hold on
x=nanmean(yyc,1);
clear gridness_tlag
ii=1;
for tlag = gridlag
    temp = corrcoef(x,circshift(x,round(tlag)))-corrcoef(x,circshift(x,round(.5*tlag)));
    gridness_tlag(ii)=temp(2);ii=ii+1;
end
plot(gridlag/1000,gridness_tlag,'-r','LineWidth',2);grid on;addline(xtikson(1:2));addline(0','h');
xlabel periodicity(sec);ylabel gridness; ylim([-1 1])
set(gca,'XTick',sort(xtikson),'FontSize',15);

lags = (xxc/1000)';
meanacg = (nanmean(yyc,1))';
PI_lags = gridlag'/1000;
PI = gridness_tlag';
PI_GP_NULL=gp_95pcnull_gridness';
T.Tacg=table(lags,meanacg); 
T.Tpi = table(PI_lags,PI,PI_GP_NULL);
T.Tacgtrxtr = yyc;

end

%% plot eye hand signal, periodcity and PI index

function [hf,T]=plot_eyehand_acg(data_tensor,params,cp)

params.tiks=-.65:.65:3.25;
params.bef=.65;
params.aft=.65;
whicheye='eyex';

params.smooth='gauss'; %or 'boxcar'
params.gauss_smooth=.3; % 100ms smoothing window for psth
params.gauss_std = .1;   % 50 ms std of gaussian filter if gaussian
params.gauss_smoothing_kern = fspecial('gaussian',[1 params.gauss_smooth/params.binwidth],params.gauss_std/params.binwidth);
params.beff=params.bef+params.gauss_smooth*2; %to remove edge effect of filters, take extra 2*gaussian_filter_size and remove those time points after filtering
params.aftt=params.aft+params.gauss_smooth*2;
params.window_edge_effect = params.gauss_smooth*2/params.binwidth:(length(params.edges)-params.gauss_smooth*2/params.binwidth);
params.edges_rev = params.edges(params.window_edge_effect);
params.edges_revoff = params.edgesoff(params.window_edge_effect);
hcol=myrgb(5,[1 0 0]);

for direction=[ 1 -1]
    clear xx psth_ temp
        h=figure('Position',[ 744   107   938   942]);

    for dist=1:5
%         trials = find(params.binid==dist & params.dir_condition==direction & params.trial_type==3 & params.seqq<3 & params.validtrials_mm==1);
        trials = find(params.dist_conditions==dist & params.dir_condition==direction & params.trial_type==3 & params.seqq<3 & params.validtrials_mm==1);

        tp_=abs(params.tp(trials));
        [tp_,tpsort] = sort(tp_);
        time_start=-.65;
        tp_min=dist*.65+.65;
        
        
        temp=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor.eyex_joyon(:,trials))','same');
        temp=temp(tpsort,params.window_edge_effect);
        
        tempoff=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor.eyex_joyoff(:,trials))','same');
        tempoff=tempoff(tpsort,params.window_edge_effect);
        
        
        tt = find(params.edges_rev>time_start & params.edges_rev<tp_min);
        
        ttoff = find(params.edges_revoff<-time_start & params.edges_revoff>-tp_min);
        
        
        
        
        xx=params.edges_rev(tt);
        xxoff=params.edges_revoff(ttoff);
        psth_ = temp(:,tt);
        psth_off = tempoff(:,ttoff);
        
        
        
        
        if dist==4
            subplot(3,3,1+3*(double(direction==-1)));
            imagesc(xx,1:size(psth_,1),psth_);
            ylabel trials; set(gca,'XTick',sort(params.tiks),'FontSize',15);hold on;
            plot(tp_,1:length(tp_),'or');
            yyaxis right;plot(xx,mean(psth_,1),'-','color',hcol(dist,:),'LineWidth',1.5);
            %         ylim([0 20])
            addline(sort(params.tiks));xlabel time(sec); colorbar;title (['dist4 dir' num2str(direction)])
        end
        subplot(3,3,2+3*(double(direction==-1)));
        plot(xx,mean(psth_,1),'color',hcol(dist,:),'LineWidth', 1.5);hold on;
        
        subplot(3,3,3+3*(double(direction==-1)));
        plot(xxoff,mean(psth_off,1),'color',hcol(dist,:),'LineWidth', 1.5);hold on;
        
        
        
        
    end
    
    subplot(3,3,2+3*(double(direction==-1)));
    xlim([-inf inf]);ylim([-inf inf])
    set(gca,'XTick',sort(params.tiks),'FontSize',15);
    xlabel 'Time re. jotstick onset(sec)'; ylabel(whicheye);
    addline([0 3.25],'color','k');
    grid on
    
    subplot(3,3,3+ 3*(double(direction==-1)));
    xlim([-inf inf]);ylim([-inf inf])
    xlabel 'Time re. jotstick offset(sec)'
    set(gca,'XTick',sort(-params.tiks),'FontSize',15);
    ylabel(whicheye);
    addline([-3.25 0],'color','k');
    grid on
    
end
end

function [hh,T]=plot_bump_phase_allneurons (param,seqid,cp)
% plot mode peak phase across neurons for EC for each animal and merge across animals

hh=figure('Position',[ 744   445   601   604]);
animal = 'mahler';
whichbump = [1 2 3]; %bootstrapped phase=[1 2 3] or trial-wise phase=[4 5 6]
direction=1;
min_trials=15;
histedgeson = 0:.15:3.25;
histedges = -3.25:.15:0;
p2p_alpha=.05; %plot with alpha threshold at .1 to visualize phase distribution with lesser strict criterion

area=param.area;
cd (param.savedata)
eval(['load ' animal '_' area '_bump_phase_dir' num2str(direction) '_wrt_peak_or_event_seq12' cp.suffix '.mat'])
eval(['load ' animal '_' area '_allNeurons_gridness_dir' num2str(direction) '_seq12' cp.suffix '.mat'])
phase=bump_phase_firstlast;
try eval('params = null; clear null'),catch; end
mode_peak=[]; mode_peak1=[];num_neurons=0;num_behav_periodic_neurons=0;
for ss=1:length(phase)

    idx = find(sessions_all==ss);
    gridness_temp=gridness_mall(idx);
    numtrials_temp=num_trials_mall(idx);
    periodic_cells=find(gridness_temp>params.gridness_thres_pc_abov_mean & numtrials_temp>min_trials);

    goodneur= find(phase{ss}.kstats(:,1)~=0 & phase{ss}.kstats(:,2)~=0 & phase{ss}.kstats(:,3)~=0 & phase{ss}.pval(:,1)<p2p_alpha)';


    goodneur = intersect(periodic_cells,goodneur);
    num_neurons = num_neurons+length(periodic_cells);
    num_behav_periodic_neurons=num_behav_periodic_neurons+length(goodneur);

    mode_peak = [mode_peak; phase{ss}.mode_peakbb(goodneur,:,1)];
    mode_peak1 = [mode_peak1; phase{ss}.mode_peakbb1(goodneur,:,1)];

end



subplot(3,2,1)
histogram(mode_peak(:,whichbump(1)),histedges);hold on
histogram(mode_peak(:,whichbump(2)),histedges); hold on;
histogram(mode_peak(:,whichbump(3)),histedges);
set(gca,'XTick',-3.25:.65:0);
addline([-1.95 -1.3 -.65],'color','k');
grid on; title (['OFFSET: Mahler  '])

%data for writing to exel sheet: 
animal_id = repmat( animal  ,[length(mode_peak), 1]);
first_peak = mode_peak(:,whichbump(1));
second_peak = mode_peak(:,whichbump(2));
third_peak = mode_peak(:,whichbump(3));
T.Tmahler = table(animal_id,first_peak,second_peak,third_peak);

subplot(3,2,2);
histogram(mode_peak1(:,whichbump(1)),histedgeson);hold on
histogram(mode_peak1(:,whichbump(2)),histedgeson); hold on;
histogram(mode_peak1(:,whichbump(3)),histedgeson);
set(gca,'XTick',0:.65:3.25);
addline([.65 1.3 1.95],'color','k');
grid on; title (['ONSET: Mahler  '  ])



animal = 'amadeus';
direction=2;
if seqid==12
    eval(['load ' animal '_' area '_bump_phase_dir' num2str(direction) '_wrt_peak_or_event_seq' num2str(seqid) cp.suffix '.mat'])
else
    eval(['load ' animal '_' area '_bump_phase_dir' num2str(direction) '_wrt_peak_or_event_seq' num2str(seqid) cp.suffix '.mat'])
end
eval(['load ' animal '_' area '_allNeurons_gridness_dir' num2str(direction) '_seq' num2str(seqid) cp.suffix '.mat'])
phase=bump_phase_firstlast;
mode_peak_ama=[]; mode_peak1_ama=[];num_neurons_ama=0;num_behav_periodic_neurons_ama=0;

for ss=1:length(phase)

    idx = find(sessions_all==ss);
    gridness_temp=gridness_mall(idx);
    numtrials_temp=num_trials_mall(idx);
    periodic_cells=find(gridness_temp>params.gridness_thres_pc_abov_mean & numtrials_temp>min_trials);

    if isempty(phase{ss}),continue;end
    goodneur= find(phase{ss}.kstats(:,1)~=0 & phase{ss}.kstats(:,2)~=0 & phase{ss}.kstats(:,3)~=0 & phase{ss}.pval(:,1)<p2p_alpha)';



    goodneur = intersect(periodic_cells,goodneur);
    num_behav_periodic_neurons_ama=num_behav_periodic_neurons_ama+length(goodneur);


    mode_peak = [mode_peak; phase{ss}.mode_peakbb(goodneur,:,1)];
    mode_peak1 = [mode_peak1; phase{ss}.mode_peakbb1(goodneur,:,1)];

    mode_peak_ama = [mode_peak_ama; phase{ss}.mode_peakbb(goodneur,:,1)];
    mode_peak1_ama = [mode_peak1_ama; phase{ss}.mode_peakbb1(goodneur,:,1)];


end



subplot(3,2,3)
histogram(mode_peak_ama(:,whichbump(1)),histedges);hold on
histogram(mode_peak_ama(:,whichbump(2)),histedges); hold on;
histogram(mode_peak_ama(:,whichbump(3)),histedges);
set(gca,'XTick',-3.25:.65:0);
addline([-1.95 -1.3 -.65],'color','k');
grid on; title ('EC peak phase wrt OFFSET: Amadeus  '  )

%data for writing to exel sheet: amadeus
animal_id = repmat( animal  ,[length(mode_peak_ama), 1]);
first_peak = mode_peak_ama(:,whichbump(1));
second_peak = mode_peak_ama(:,whichbump(2));
third_peak = mode_peak_ama(:,whichbump(3));
T.Tamadeus = table(animal_id,first_peak,second_peak,third_peak);

subplot(3,2,4);
histogram(mode_peak1_ama(:,whichbump(1)),histedgeson);hold on
histogram(mode_peak1_ama(:,whichbump(2)),histedgeson); hold on;
histogram(mode_peak1_ama(:,whichbump(3)),histedgeson);
set(gca,'XTick',0:.65:3.25);
addline([.65 1.3 1.95],'color','k');
grid on; title (['EC last peak phase wrt ONSET: Amadeus  '  ])


subplot(3,2,5)
histogram(mode_peak(:,whichbump(1)),histedges);hold on
histogram(mode_peak(:,whichbump(2)),histedges); hold on;
histogram(mode_peak(:,whichbump(3)),histedges);
set(gca,'XTick',-3.25:.65:0);
addline([-1.95 -1.3 -.65],'color','k');
grid on; title 'both animals peak phase wrt OFFSET'

%data for writing to exel sheet: both animals
animal_id = repmat( 'both'  ,[length(mode_peak), 1]);
first_peak = mode_peak(:,whichbump(1));
second_peak = mode_peak(:,whichbump(2));
third_peak = mode_peak(:,whichbump(3));
T.Tboth = table(animal_id,first_peak,second_peak,third_peak);
histogram_edges=histedges';
T.Thistedges = table(histogram_edges);

subplot(3,2,6);
histogram(mode_peak1(:,whichbump(1)),histedgeson);hold on
histogram(mode_peak1(:,whichbump(2)),histedgeson); hold on;
histogram(mode_peak1(:,whichbump(3)),histedgeson);
set(gca,'XTick',0:.65:3.25);
addline([.65 1.3 1.95],'color','k');
grid on; title 'both animals last peak phase wrt ONSET'


sgtitle(['Bump phase w.r.t. joystick on and off seq' num2str(seqid)])


end

%===main function to to prep for computing periodicity and task modulation====:
function get_periodicty_task_modulation (params,seqid,cp)

%single neuron analyses: periodicity and task modulation for all neurons
%saves periodicity


%periodicity parameters:
params.spontdur_iti_thres=cp.spontdur_iti_thres;%seconds
params.cutoff_acg =cp.cutoff_acg;
params.maxlag=cp.maxlag;
params.dist_trials_periodicity = cp.dist_trials_periodicity; %include trials greater than or equal to this distance

%task modulation parameters:
params.timerange = cp.timerange; %re. joystick offset
params.mintrials_taskmodulation=cp.mintrials_taskmodulation;
params.dist_trials_mod = cp.dist_trials_mod; %include trials greater than or equal to this distance
params.checkpsthplots=cp.checkpsthplots;
params.savetaskmodfig= cp.savetaskmodfig;

%ramp parameters:
params.mintp_ramp=cp.mintp_ramp;

%motor resp parameters:
params.minimnumtp_motor=cp.minimnumtp_motor;
params.motor_window=cp.motor_window;
params.mnav_window=cp.mnav_window;


if params.checkpsthplots
    h1=figure;
end

load([cp.datafolder '/sessions/' ...
    params.animal '_' params.area '_sessions.mat'], 'sessions')

params.mtt_folder=cp.tensordatafolder;
if strcmp(params.area,'7a') && params.animal(1)=='m'
    cd([cp.savedir_ '/Fig2/data']);
    load('mahler_7a_numneurons.mat','mahler_NP_within_session_neurons')
end

gridlag=100:10:1600;
params.gridlag=gridlag;

for ss=1:length(sessions)
    params.filename=sessions{ss};
    clear data_tensor_joyoff data_tensor_stim1on

    cd ([params.mtt_folder '/' params.filename '.mwk']);

    varlist=matfile([sessions{ss} '_neur_tensor_joyon']);
    cond_label=varlist.cond_label;
    cond_matrix=varlist.cond_matrix;
    for ii=1:length(cond_label)
        eval(['params.' cond_label{ii} '=cond_matrix(:,strcmp(cond_label, cond_label{ii} ));']);
    end
    params.dist_conditions = abs(params.target-params.curr);
    params.dir_condition = sign(params.ta);


    if strcmp(params.animal,'mahler') && strcmp(params.area,'7a')
        numneuron=1:mahler_NP_within_session_neurons(ss);
        if params.get_periodicity_modulation==1 || params.get_ramp==1 || params.get_motor_resp==1,data_tensor = varlist.neur_tensor_joyon(numneuron,:,:);end
    else
        if params.get_periodicity_modulation==1 || params.get_ramp==1 || params.get_motor_resp==1, data_tensor = varlist.neur_tensor_joyon(:,:,:);end
        numneuron = 1:size(varlist,'neur_tensor_joyon',1);
    end

    temp=varlist.joyon;
    params.binwidth=temp.binwidth;
    params.bef=temp.bef;
    params.aft=temp.aft;
    params.edges=temp.edges;

    params.smooth='gauss'; %or 'boxcar'
    params.gauss_smooth=.2; %   smoothing window for psth
    params.gauss_std = .1;   %   std of gaussian filter if gaussian
    params.gauss_smoothing_kern = fspecial('gaussian',[1 params.gauss_smooth/params.binwidth],params.gauss_std/params.binwidth);
    %to remove edge effect of filters, take extra 2*gaussian_filter_size and remove those time points after filtering
    params.window_edge_effect = params.gauss_smooth*2/params.binwidth:(length(params.edges)-params.gauss_smooth*2/params.binwidth);
    params.edges_rev = params.edges(params.window_edge_effect);

    if seqid==12
        g = find(params.trial_type==3 & params.seqq<3 & params.validtrials_mm==1);
    else
        g = find(params.trial_type==3 & params.seqq==seqid & params.validtrials_mm==1);
    end
    if isempty(g),continue;end


    %gridness:
    if params.get_periodicity_modulation==1

        cd ([params.mtt_folder '/' params.filename '.mwk'])

        varlist=matfile([sessions{ss} '_neur_tensor_spont']);
        data_tensor_spont = varlist.neur_tensor_spont(numneuron,:,:);
        spont_duration = varlist.spont_duration;
        params.spont = varlist.spont;
        params.spont.window_edge_effect = params.gauss_smooth*2/params.binwidth:(length(params.spont.edges)-params.gauss_smooth*2/params.binwidth);
        params.spont.edges_rev = params.spont.edges(params.spont.window_edge_effect);


        params.dir=1;
        gridness{ss,1} = get_gridness(params,data_tensor,data_tensor_spont,spont_duration,seqid,cp);
        params.dir=-1;
        gridness{ss,2} = get_gridness(params,data_tensor,data_tensor_spont,spont_duration,seqid,cp);

        cd(cp.datafolder)
        save([params.animal '_' params.area '_periodicity_js_leftright_dist345_seq' num2str(seqid) cp.suffix '.mat' ],'gridness','params' );
        disp(['===' params.animal '_' params.area '_periodicity_js_leftright_dist345_seq' num2str(seqid) cp.suffix '.mat saved===' ]  );
    end



    %task modulation
    if params.get_task_modulation==1
        cd ([params.mtt_folder '/' params.filename '.mwk'])

        clear data_tensor_on data_tensor_spont
        varlist_off=matfile([sessions{ss} '_neur_tensor_joyoff']);
        data_tensor_joyoff = varlist_off.neur_tensor_joyoff(numneuron,:,:);
        joyoff=varlist_off.joyoff;
        params.window_edge_effect = params.gauss_smooth*2/params.binwidth:(length(joyoff.edges)-params.gauss_smooth*2/params.binwidth);
        params.edges_revoff=joyoff.edges(params.window_edge_effect);


        varlist_stim=matfile([sessions{ss} '_neur_tensor_stim1on']);
        data_tensor_stim1on = varlist_stim.neur_tensor_stim1on(numneuron,:,:);
        stim1onedges = varlist_stim.stim1on;
        params.window_edge_effect_stim1on = params.gauss_smooth*2/params.binwidth:(length(stim1onedges.edges)-params.gauss_smooth*2/params.binwidth);
        params.edges_revstim1on = stim1onedges.edges(params.window_edge_effect_stim1on);
        params.tt_prestim_base = (params.edges_revstim1on>-abs(diff(params.timerange)) & params.edges_revstim1on<0);


        task_mod{ss} = get_task_modulation(params,data_tensor_joyoff,data_tensor_stim1on,seqid,cp);

        cd(cp.datafolder)
        save([params.animal '_' params.area '_task_modulation_dist_seq' num2str(seqid) cp.suffix '.mat' ],'task_mod','params' );
        disp(['===' params.animal '_' params.area '_task_modulation_dist_seq' num2str(seqid) cp.suffix '.mat saved===' ]  );

    end



    if params.get_ramp==1


        params.dir=1;
        rampy{ss,1} = get_rampy(params,data_tensor,seqid,cp);
        params.dir=-1;
        rampy{ss,2} = get_rampy(params,data_tensor,seqid,cp);

        cd(cp.datafolder)
        save([params.animal '_' params.area '_ramp_js_leftright_dist345_seq' num2str(seqid) cp.suffix '.mat' ],'rampy','params' );
        disp(['===' sessions{ss} ' ' params.area '_rampy_js_leftright_dist345_seq' num2str(seqid) cp.suffix '.mat saved===' ]  );

    end


    if params.get_motor_resp==1
        ss

        params.dir=1;
        motor_resp{ss,1} = get_motor_response(params,data_tensor,seqid,cp);
        params.dir=-1;
        motor_resp{ss,2} = get_motor_response(params,data_tensor,seqid,cp);

        cd(cp.datafolder)
        save([params.animal '_' params.area '_motor_resp_js_leftright_dist345_seq' num2str(seqid) cp.suffix '.mat' ],'motor_resp','params' );
        disp(['===' sessions{ss} ' ' params.area '_motor_resp_js_leftright_dist345_seq' num2str(seqid) cp.suffix '.mat saved===' ]  );

    end

end

disp(['======all done==='  params.animal '_' params.area '_dist_mod_seq' num2str(seqid) cp.suffix '.mat saved']);

disp(['===' params.animal '_' params.area ' periodicity calculation ALL DONE for seq' num2str(seqid) cp.suffix '==='])

end


% functions for getting periodicity for each neuron:
function p=get_gridness(params,data_tensor,data_tensor_spont,spont_duration,seqid,cp)

% for each neuron:

if seqid==12
    params.gridness_trials= find(params.dir_condition'==params.dir & params.attempt'==1 & abs(params.dist_conditions')>=params.dist_trials_periodicity & params.trial_type'==3 & ...
        params.seqq'<3 & abs(params.tp')>1);%pool trials across directions and dist>=3 for ACG gridness calculation

    params.gridness_failed_trials= find(params.dir_condition'==params.dir & params.succ'==0 & abs(params.dist_conditions')>=params.dist_trials_periodicity & params.trial_type'==3 & ...
        params.seqq'<3 & abs(params.tp')>1.8);%pool error trials

    params.gridness_visual_trials= find(params.dir_condition'==params.dir & params.attempt'==1 & abs(params.dist_conditions')>=params.dist_trials_periodicity & params.trial_type'<3 & ...
        params.seqq'<3 & abs(params.tp')>1);%pool trials across directions and dist>=3 and visual trials

else
    params.gridness_trials= find(params.dir_condition'==params.dir & params.attempt'==1 & abs(params.dist_conditions')>=params.dist_trials_periodicity & params.trial_type'==3 & ...
        params.seqq'==seqid & abs(params.tp')>1);%pool trials across directions and dist>=3 for ACG gridness calculation

    params.gridness_failed_trials= find(params.dir_condition'==params.dir & params.succ'==0 & abs(params.dist_conditions')>=params.dist_trials_periodicity & params.trial_type'==3 & ...
        params.seqq'==seqid & abs(params.tp')>1.8);%pool error trials

    params.gridness_visual_trials= find(params.dir_condition'==params.dir & params.attempt'==1 & abs(params.dist_conditions')>=params.dist_trials_periodicity & params.trial_type'<3 & ...
        params.seqq'==seqid & abs(params.tp')>1);%pool trials across directions and dist>=3 and visual trials

end
params.gridness_spont_trials= find(spont_duration>params.spontdur_iti_thres);%pool trials from iti when iti dur is > threshold (~4sec)

time_end_median=median(abs(params.tp(params.gridness_trials)));

time_start_medians = -params.spontdur_iti_thres;
time_end_medians = -params.spontdur_iti_thres+time_end_median;

% time_end_minpeak1=min(abs(params.tp(params.gridness_trials)))-.65;
p.trial_info_labels={'trialid' 'dist_conditions' 'dit_conditions' 'meanFR' 'trend_trxtr' 'pval of trend' 'min_trxtr' 'max_trxtr' };
p.trial_info = -99*ones(size(data_tensor,1),length(params.gridness_trials),8);
p.trial_infov= -99*ones(size(data_tensor,1),length(params.gridness_visual_trials),8);
p.trial_infoe= -99*ones(size(data_tensor,1),length(params.gridness_failed_trials),8);
p.trial_infos= -99*ones(size(data_tensor,1),length(params.gridness_spont_trials),8);
if isempty(params.gridness_trials),return;end
for nn=1:size(data_tensor,1)
    tic
    %MENTAL trials
    yycorr = nan(length(params.gridness_trials),params.maxlag*2+1);
    for tr=1:length(params.gridness_trials)
        trialid = params.gridness_trials(tr);

        %FR:truncated by tp-500ms for ACG and trend
        spktr=squeeze(data_tensor(nn,:,trialid));
        temp=conv(spktr,params.gauss_smoothing_kern,'same');
        temp=temp(params.window_edge_effect);
        time_end=abs(params.tp(trialid))-params.cutoff_acg ;

        tt = find(params.edges_rev>0 & params.edges_rev<time_end);

        yy=temp(tt);
        xx=params.edges_rev(tt);

        meanFR= mean(yy);
        %trend trxtr
        mdl=fitlm(xx,yy);
        trend_trxtr=mdl.Coefficients.Estimate(2);
        min_trxtr=min(yy);
        max_trxtr=max(yy);

        %ACG: on detrended 500ms truncated FR
        yy=yy-mdl.Coefficients.Estimate(2)*xx;
        yycorr(tr,:)=xcorr(yy-mean(yy),params.maxlag,'coeff');

        %record trialid, meanFR, # spikes, trend, min/max FR, periodicity
        p.trial_info(nn,tr,:)=[trialid params.dist_conditions(trialid) params.dir_condition(trialid) meanFR trend_trxtr mdl.Coefficients.pValue(2) min_trxtr max_trxtr];
    end

    %MENTAL gridness: average ACG over dist 4-5,
    highFR_trials=squeeze(p.trial_info(nn,:,4))>.05;
    p.num_trials_mve(nn,1)=length(find(highFR_trials));

    if length(find(highFR_trials))>5

        x = nanmean(yycorr(highFR_trials,:),1);
        p.acg(nn,:)=x;iil=1;
        for tlag = params.gridlag
            temp = corrcoef(x,circshift(x,round(tlag)))-corrcoef(x,circshift(x,round(.5*tlag)));
            p.gridness_tlag(nn,iil)=temp(2);
            iil=iil+1;
        end

        [p.gridness_max(nn), period]=  max(squeeze(p.gridness_tlag(nn,:)));
        p.gridness_max_periodicity(nn) = params.gridlag(period);
        p.pc_above_mean_gridness(nn)=p.gridness_max(nn)-mean(p.gridness_tlag(nn,find(p.gridness_tlag(nn,:)>0,1):end ));
    else

        p.gridness_max(nn) = -99;
        p.gridness_max_periodicity(nn) = -99;
        p.pc_above_mean_gridness(nn)=-99;
        p.acg(nn,:)=-99*ones(1,params.maxlag*2+1);
        p.gridness_tlag(nn,:) = -99*params.gridlag./params.gridlag;
    end

    %VISUAL trials
    yycorrv = nan(length(params.gridness_visual_trials),params.maxlag*2+1);
    for tr=1:length(params.gridness_visual_trials)
        trialid = params.gridness_visual_trials(tr);

        %FR:truncated by tp-500ms for ACG and trend
        spktr=squeeze(data_tensor(nn,:,trialid));
        temp=conv(spktr,params.gauss_smoothing_kern,'same');
        temp=temp(params.window_edge_effect);
        time_end=abs(params.tp(trialid))-params.cutoff_acg ;
        tt = find(params.edges_rev>0 & params.edges_rev<time_end);

        yy=temp(tt);
        xx=params.edges_rev(tt);

        meanFR= mean(yy);
        %trend trxtr
        mdl=fitlm(xx,yy);
        trend_trxtr=mdl.Coefficients.Estimate(2);
        min_trxtr=min(yy);
        max_trxtr=max(yy);

        %ACG: on detrended 500ms truncated FR
        yy=yy-mdl.Coefficients.Estimate(2)*xx;

        yycorrv(tr,:)=xcorr(yy-mean(yy),params.maxlag,'coeff');


        %record trialid, meanFR, # spikes, trend, min/max FR, periodicity
        p.trial_infov(nn,tr,:)=[trialid params.dist_conditions(trialid) params.dir_condition(trialid) meanFR trend_trxtr mdl.Coefficients.pValue(2) min_trxtr max_trxtr];

    end


    %VISUAL gridness: average ACG over dist 4-5,
    highFR_trials=squeeze(p.trial_infov(nn,:,4))>.05;
    p.num_trials_mve(nn,2)=length(find(highFR_trials));

    if length(find(highFR_trials))>5

        x = nanmean(yycorrv(highFR_trials,:),1);
        p.acgv(nn,:)=x;
        iil=1;
        for tlag = params.gridlag
            temp = corrcoef(x,circshift(x,round(tlag)))-corrcoef(x,circshift(x,round(.5*tlag)));
            p.gridness_tlagv(nn,iil)=temp(2);
            iil=iil+1;
        end
        [p.gridness_maxv(nn), period]=  max(squeeze(p.gridness_tlagv(nn,:)));
        p.gridness_max_periodicityv(nn) = params.gridlag(period);
        p.pc_above_mean_gridnessv(nn)=p.gridness_maxv(nn)-mean(p.gridness_tlagv(nn,find(p.gridness_tlagv(nn,:)>0,1):end ));
    else
        p.gridness_maxv(nn) = -99;
        p.gridness_max_periodicityv(nn) = -99;
        p.pc_above_mean_gridnessv(nn)=-99;
        p.acgv(nn,:)=-99*ones(1,params.maxlag*2+1);
        p.gridness_tlagv(nn,:) = -99*params.gridlag./params.gridlag;
    end

    %ERROR trials
    yycorre = nan(length(params.gridness_failed_trials),params.maxlag*2+1);
    for tr=1:length(params.gridness_failed_trials)
        trialid = params.gridness_failed_trials(tr);

        %FR:truncated by tp-500ms for ACG and trend
        spktr=squeeze(data_tensor(nn,:,trialid));
        temp=conv(spktr,params.gauss_smoothing_kern,'same');
        temp=temp(params.window_edge_effect);
        time_end=abs(params.tp(trialid))-params.cutoff_acg ;
        tt = find(params.edges_rev>0 & params.edges_rev<time_end);

        yy=temp(tt);
        xx=params.edges_rev(tt);

        meanFR= mean(yy);
        %trend trxtr
        mdl=fitlm(xx,yy);
        trend_trxtr=mdl.Coefficients.Estimate(2);
        min_trxtr=min(yy);
        max_trxtr=max(yy);

        %ACG: on detrended 500ms truncated FR
        yy=yy-mdl.Coefficients.Estimate(2)*xx;

        yycorre(tr,:)=xcorr(yy-mean(yy),params.maxlag,'coeff');

        %record trialid, meanFR, # spikes, trend, min/max FR, periodicity
        p.trial_infoe(nn,tr,:)=[trialid params.dist_conditions(trialid) params.dir_condition(trialid) meanFR trend_trxtr mdl.Coefficients.pValue(2) min_trxtr max_trxtr];

    end

    %ERROR gridness: average ACG over dist 3-5,
    highFR_trials=squeeze(p.trial_infoe(nn,:,4))>.05;
    p.num_trials_mve(nn,3)=length(find(highFR_trials));

    if length(find(highFR_trials))>5
        x = nanmean(yycorre(highFR_trials,:),1);
        p.acge(nn,:)=x;iil=1;
        for tlag = params.gridlag
            temp = corrcoef(x,circshift(x,round(tlag)))-corrcoef(x,circshift(x,round(.5*tlag)));
            p.gridness_tlage(nn,iil)=temp(2);
            iil=iil+1;
        end
        [p.gridness_maxe(nn), period]=  max(squeeze(p.gridness_tlage(nn,:)));
        p.gridness_max_periodicitye(nn) = params.gridlag(period);
        p.pc_above_mean_gridnesse(nn)=p.gridness_maxe(nn)-mean(p.gridness_tlage(nn,find(p.gridness_tlage(nn,:)>0,1):end ));
    else
        p.gridness_maxe(nn) = -99;
        p.gridness_max_periodicitye(nn) = -99;
        p.pc_above_mean_gridnesse(nn)=-99;
        p.acge(nn,:)=-99*ones(1,params.maxlag*2+1);
        p.gridness_tlage(nn,:) = -99*params.gridlag./params.gridlag;
    end



    %SPONT trials
    %to remove edge effect of filters, take extra 2*gaussian_filter_size and remove those time points after filtering

    tt = find(params.spont.edges_rev>time_start_medians & params.spont.edges_rev<time_end_medians);
    yycorrs = nan(length(params.gridness_spont_trials),params.maxlag*2+1);
    for tr=1:length(params.gridness_spont_trials)
        trialid = params.gridness_spont_trials(tr);

        %FR:truncated by tp-500ms for ACG and trend
        spktr=squeeze(data_tensor_spont(nn,:,trialid));
        temp=conv(spktr,params.gauss_smoothing_kern,'same');
        temp=temp(params.spont.window_edge_effect);



        yy=temp(tt);
        xx=params.spont.edges_rev(tt);

        meanFR= mean(yy);
        %trend trxtr
        mdl=fitlm(xx,yy);
        trend_trxtr=mdl.Coefficients.Estimate(2);
        min_trxtr=min(yy);
        max_trxtr=max(yy);

        %ACG: on detrended 500ms truncated FR
        yy=yy-mdl.Coefficients.Estimate(2)*xx;

        yycorrs(tr,:)=xcorr(yy-mean(yy),params.maxlag,'coeff');

        %record trialid, meanFR, # spikes, trend, min/max FR, periodicity
        p.trial_infos(nn,tr,:)=[trialid params.dist_conditions(trialid) params.dir_condition(trialid) meanFR trend_trxtr mdl.Coefficients.pValue(2) min_trxtr max_trxtr];

    end

    %SPONT gridness: average ACG over dist 3-5,
    highFR_trials=squeeze(p.trial_infos(nn,:,4))>.05;
    p.num_trials_mvs(nn,4)=length(find(highFR_trials));

    if length(find(highFR_trials))>5

        x = nanmean(yycorrs(highFR_trials,:),1);
        p.acgs(nn,:)=x;iil=1;
        for tlag = params.gridlag
            temp = corrcoef(x,circshift(x,round(tlag)))-corrcoef(x,circshift(x,round(.5*tlag)));
            p.gridness_tlags(nn,iil)=temp(2);
            iil=iil+1;
        end
        [p.gridness_maxs(nn), period]=  max(squeeze(p.gridness_tlags(nn,:)));
        p.gridness_max_periodicitys(nn) = params.gridlag(period);
        p.pc_above_mean_gridnesss(nn)=p.gridness_maxs(nn)-mean(p.gridness_tlags(nn,find(p.gridness_tlags(nn,:)>0,1):end ));


    else
        p.gridness_maxs(nn) = -99;
        p.gridness_max_periodicitys(nn) = -99;
        p.pc_above_mean_gridnesss(nn)=-99;
        p.acgs(nn,:)=-99*ones(1,params.maxlag*2+1);
        p.gridness_tlags(nn,:) = -99*params.gridlag./params.gridlag;

    end
    toc
    disp([params.filename ' neuron' num2str(nn) '''s gridness computed for seq' num2str(seqid)])

end

end

% functions for getting periodicity for each neuron:
function p=get_motor_response(params,data_tensor,seqid,cp)

% for each neuron:
if seqid==12
    params.motor_trials= find(params.dir_condition'==params.dir & params.attempt'==1 & abs(params.dist_conditions')>=params.dist_trials_periodicity & params.trial_type'==3 & ...
        params.seqq'<3 & abs(params.tp')>params.minimnumtp_motor);%pool trials across directions and dist>=3
else
    params.motor_trials= find(params.dir_condition'==params.dir & params.attempt'==1 & abs(params.dist_conditions')>=params.dist_trials_periodicity & params.trial_type'==3 & ...
        params.seqq'==seqid & abs(params.tp')>params.minimnumtp_motor);%pool trials across directions and dist>=3
end
if length(params.motor_trials)<params.mintrials_taskmodulation,p=[];return;end

p.motor_window=params.motor_window;%[-.4 -.1];
p.mnav_window = params.mnav_window;%[-1 -.6 ];

temp=data_tensor(:,:,params.motor_trials);

for tr=1:length(params.motor_trials)

    time_end=abs(params.tp(params.motor_trials(tr)));

    tt_mnav = find(params.edges>(time_end+p.mnav_window(1)) & params.edges<(time_end + p.mnav_window(2)));
    tt_motor = find(params.edges>(time_end+p.motor_window(1)) & params.edges<(time_end + p.motor_window(2)));

    fr_mnav(:,tr)=squeeze(mean(temp(:,tt_mnav,tr),2));
    fr_motor(:,tr)=squeeze(mean(temp(:,tt_motor,tr),2));

end

for nn=1:size(fr_mnav,1)
    nn
    mnav=bootstrp(200,@mean,fr_mnav(nn,:));
    motor=bootstrp(200,@mean,fr_motor(nn,:));

    [p.motor_resp_ttest(nn),p.motor_resp_pval(nn)]=ttest2(mnav,motor,'Alpha',.0001);


end


end


% functions for getting ramp for each neuron:
function p=get_rampy(params,data_tensor,seqid,cp)

params.minimnumtp=params.mintp_ramp;
% for each neuron:
if seqid==12

    params.rampy_trials= find(params.dir_condition'==params.dir & params.attempt'==1 & abs(params.dist_conditions')>=params.dist_trials_periodicity & params.trial_type'==3 & ...
        params.seqq'<3 & abs(params.tp')>params.minimnumtp);%pool trials across directions and dist>=3 for ACG gridness calculation

    params.rampy_failed_trials= find(params.dir_condition'==params.dir & params.succ'==0 & abs(params.dist_conditions')>=params.dist_trials_periodicity & params.trial_type'==3 & ...
        params.seqq'<3 & abs(params.tp')>params.minimnumtp);%pool error trials

    params.rampy_visual_trials= find(params.dir_condition'==params.dir & params.attempt'==1 & abs(params.dist_conditions')>=params.dist_trials_periodicity & params.trial_type'<3 & ...
        params.seqq'<3 & abs(params.tp')>params.minimnumtp);%pool trials across directions and dist>=3 and visual trials
else
    params.rampy_trials= find(params.dir_condition'==params.dir & params.attempt'==1 & abs(params.dist_conditions')>=params.dist_trials_periodicity & params.trial_type'==3 & ...
        params.seqq'==seqid & abs(params.tp')>params.minimnumtp);%pool trials across directions and dist>=3 for ACG gridness calculation

    params.rampy_failed_trials= find(params.dir_condition'==params.dir & params.succ'==0 & abs(params.dist_conditions')>=params.dist_trials_periodicity & params.trial_type'==3 & ...
        params.seqq'==seqid & abs(params.tp')>params.minimnumtp);%pool error trials

    params.rampy_visual_trials= find(params.dir_condition'==params.dir & params.attempt'==1 & abs(params.dist_conditions')>=params.dist_trials_periodicity & params.trial_type'<3 & ...
        params.seqq'==seqid & abs(params.tp')>params.minimnumtp);%pool trials across directions and dist>=3 and visual trials

end
if isempty(params.rampy_trials),p=[];return;end

time_end=params.minimnumtp-params.cutoff_acg ;
tt = find(params.edges>.5 & params.edges<time_end);
xx=params.edges(tt);
temp=data_tensor(:,tt,:);
binwidth=50;
xxi = xx(1:binwidth:length(tt)-binwidth)-.25;
for nn=1:size(data_tensor,1)
    tii=1;clear spktr
    for tti=1:binwidth:length(tt)-binwidth
        spktr(:,tii)=mean(temp(nn,tti:tti+binwidth,params.rampy_trials),2);
        tii=tii+1;
    end

    spktr(mean(spktr,2)<cp.lowfr_thres,:)=[]; %remove no spike trials
    xx = repmat(xxi,[size(spktr,1) 1]);
    mdl=fitlm(xx(:),spktr(:));

    p.slope(nn)=mdl.Coefficients.Estimate(2);
    p.Rsq(nn)=mdl.Rsquared.Ordinary;
    p.pval(nn)=mdl.Coefficients.pValue(2);



    %VISUAL trials
    tii=1;clear spktr
    for tti=1:binwidth:length(tt)-binwidth

        spktr(:,tii)=mean(temp(nn,tti:tti+binwidth,params.rampy_visual_trials),2);
        tii=tii+1;
    end

    spktr(mean(spktr,2)<cp.lowfr_thres,:)=[]; %remove no spike trials
    xx = repmat(xxi,[size(spktr,1) 1]);
    mdl=fitlm(xx(:),spktr(:));
    p.slopev(nn)=mdl.Coefficients.Estimate(2);
    p.Rsqv(nn)=mdl.Rsquared.Ordinary;
    p.pvalv(nn)=mdl.Coefficients.pValue(2);



    %     %ERROR trials
    tii=1;clear spktr
    for tti=1:binwidth:length(tt)-binwidth

        spktr(:,tii)=mean(temp(nn,tti:tti+binwidth,params.rampy_failed_trials),2);
        tii=tii+1;
    end
    spktr(mean(spktr,2)<cp.lowfr_thres,:)=[]; %remove no spike trials
    xx = repmat(xxi,[size(spktr,1) 1]);
    mdl=fitlm(xx(:),spktr(:));
    p.slopee(nn)=mdl.Coefficients.Estimate(2);
    p.Rsqe(nn)=mdl.Rsquared.Ordinary;
    p.pvale(nn)=mdl.Coefficients.pValue(2);

end
p.binwidth=binwidth;
end

% functions for getting task modulation for each neuron:
function t=get_task_modulation(params,data_tensor_joyoff,data_tensor_stim1on,seqid,cp)
tic
params.mintrials=params.mintrials_taskmodulation;
t.task_mod_ttest=nan(size(data_tensor_joyoff,1),4);
t.dist_mod_linreg=nan(size(data_tensor_joyoff,1),3);
for neur=1:size(data_tensor_joyoff,1)

    data_tensor_smoothedoff=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor_joyoff(neur,:,:))','same');
    data_tensor_smoothedoff=data_tensor_smoothedoff(:,params.window_edge_effect);

    data_tensor_smoothedstim=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor_stim1on(neur,:,:))','same');
    data_tensor_smoothedstim=data_tensor_smoothedstim(:,params.window_edge_effect_stim1on);


    if size(data_tensor_smoothedoff,1)<length(params.tp)
        data_tensor_smoothedoff(end+1,:)=0;
        data_tensor_smoothedstim(end+1,:)=0;

    end


    ttoff = find(params.edges_revoff>-2 & params.edges_revoff<.2);%this is just for plotting and debugging
    xxoff=params.edges_revoff(ttoff);
    ttoff_lg = find(params.edges_revoff>params.timerange(1) & params.edges_revoff<params.timerange(2));
    xxoff_lg=params.edges_revoff(ttoff_lg);
    temp=data_tensor_smoothedoff(:,ttoff_lg);
    lowfr_trials = (mean(temp(:,xxoff_lg>params.timerange(1) & xxoff_lg<params.timerange(2)),2)<cp.lowfr_thres);

    if seqid==12
        g = find(abs(params.tp)>1 & params.dist_conditions>2 & params.trial_type==3 & params.seqq<3 ...
            & params.validtrials_mm==1 & lowfr_trials==0);
    else
        g = find(abs(params.tp)>1 & params.dist_conditions>2 & params.trial_type==3 & params.seqq==seqid ...
            & params.validtrials_mm==1 & lowfr_trials==0);
    end

    if isempty(g),continue;end

    spkr = data_tensor_smoothedoff(g,ttoff_lg);
    spkr_plot = data_tensor_smoothedoff(g,ttoff);


    %linear regression
    tpedges=linspace(min(abs(params.tp(g))),max(abs(params.tp(g))),15);
    [params.binid,newta]=discretize(abs(params.tp(g)),tpedges);
    binnedtp = (newta(1:end-1)+newta(2:end))/2;
    hcol = myrgb(length(binnedtp),[1 0 0]);
    clear dist_tr resp numtrials
    for binn = unique(params.binid)'
        dist_tr{binn}=find(params.binid==binn);
        resp(binn) = mean(mean(spkr(dist_tr{binn},:),1),2);
        numtrials(binn)=length(dist_tr{binn});
        if length(dist_tr{binn})<=params.mintrials,continue;end
        if params.checkpsthplots
            subplot(2,2,1)
            plot(xxoff,mean(spkr_plot(dist_tr{binn},:),1),'color',hcol(binn,:));hold on
        end
    end
    dist_tr(numtrials<=params.mintrials)=[];
    resp(numtrials<=params.mintrials)=[];

    binnedtp(numtrials<=params.mintrials)=[];

    if length(resp)<4
        t.dist_mod_linreg(neur,:) = [eps inf 0]; continue;
    else

        mdl = fitlm(1:length(resp), resp);
        [pval,F,d] = coefTest(mdl);
        t.dist_mod_linreg(neur,:) = [F pval pval<.05];


        if params.checkpsthplots
            subplot(2,2,1)

            xlabel 'time(s) re. JS offset'; ylabel spk/s
            title(neur);addline(params.timerange);
            subplot(2,2,3)
            plot(binnedtp,resp,'-o');
            ylabel 'spk/s'
            xlabel tpbins
            title (['Fstat= ' num2str(F) 'pval= ' num2str(pval)])

        end
    end

    %baseline ttest
    spkr_nav = mean(data_tensor_smoothedoff(g,ttoff_lg),2);
    spkr_base = mean(data_tensor_smoothedstim(g,params.tt_prestim_base),2);
    [~,pttest,~,stats]=ttest(spkr_base, spkr_nav);
    t.task_mod_ttest(neur,:) = [stats.tstat stats.df pttest pttest<.05];

    if params.checkpsthplots
        subplot(2,2,2)

        scatter(spkr_base,spkr_nav,50,'.'); hold on;
        plot([0 max([spkr_nav;spkr_base])],[0 max([spkr_nav;spkr_base])],'-k');
        axis([0 max([spkr_nav;spkr_base]) 0 max([spkr_nav;spkr_base])]);grid on
        xlabel 'baseline fr'; ylabel 'nav fr'

        title (['ttest baseline= ' num2str(stats.tstat) 'pval= ' num2str(pttest)])
        %             pause
        if params.savetaskmodfig==1
            cd(cp.datafolder)
            saveas(gcf,[params.filename '_' params.area '_task_mod_neur_' num2str(neur) '.png']);
        end
        clf
    end
    disp([params.filename ' neuron' num2str(neur) '''s task modulation computed for seq' num2str(seqid)])
    toc
end


end


%====periodicity stats
function [hh,tab]=get_single_session_PI(param,seqid,cp)
nSTD=param.nSTD;
direction=param.direction;
mintr=cp.mintrial; %mintril=35 used for fig 2d
if seqid==12
    load([cp.datafolder '/'...
        param.animal '_' param.area '_periodicity_js_leftright_dist345_seq12' cp.suffix '.mat'], 'gridness','params')
else
    load([cp.datafolder '/'...
        param.animal '_' param.area '_periodicity_js_leftright_dist345_seq' num2str(seqid) cp.suffix '.mat'], 'gridness','params')
end
longer_gridlag=params.gridlag;

load([cp.datafolder '/sessions/'...
    param.animal '_' param.area '_sessions.mat'], 'sessions')

cd(cp.datafolder);
load('gp_sim_gridnessGP100ms_detrended.mat')


params.gridlag=gridlag;
params.null_gridness=gp_95pcnull_gridness;
params.null_gridness_tlag_abovemean_bb=gridness_tlag_abovemean_bb;
params.gridness_thres_pc_abov_mean =  max(mean(params.null_gridness_tlag_abovemean_bb,1)+nSTD*std(params.null_gridness_tlag_abovemean_bb,[],1));%0.1576;%.3276; %2 STD FDR. This number comes from simulation of 1000 Gaussian Process smooth time courses.
params.null_pc_above_mean_gridness=pc_above_mean_gridness;

ss=param.ss;
gridness_=gridness{ss,direction};
if isempty(gridness_) || ~isfield(gridness_,'pc_above_mean_gridness'),disp 'no gridness for this session'; return;end
grid_cells=find(gridness_.pc_above_mean_gridness>params.gridness_thres_pc_abov_mean &  gridness_.num_trials_mve(:,1)'>mintr);% & gridness_.gridness_max_periodicity<1000 & gridness_.gridness_max_periodicity>220);
nongrid_cells=find(  gridness_.num_trials_mve(:,1)'>-mintr);% & gridness_.gridness_max_periodicity<1000 & gridness_.gridness_max_periodicity>220);

hh=figure;
histogram(gridness_.gridness_max_periodicity(nongrid_cells)/1000,0:.05:1.3);hold on
histogram(gridness_.gridness_max_periodicity(grid_cells)/1000,0:.05:1.3);title(sessions{ss})
xlabel 'periodicity'
ylabel '# of neurons'
set(gca,'XTick',0:.65:1.3);grid on
title ( [sessions{ss} ' periodic cells ' num2str(round(100*length(grid_cells) / (length(nongrid_cells)),2)) '%(' num2str(length(grid_cells)) '/' num2str(length(nongrid_cells)) ')'])

%data for writing to exel sheet: 
all_neurons = gridness_.gridness_max_periodicity(nongrid_cells)'/1000; 
periodic_neurons = gridness_.gridness_max_periodicity(grid_cells)'/1000; 
histogram_edges = 0:.05:1.3; histogram_edges=histogram_edges(:);
session_id = repmat(sessions{ss},[length(all_neurons),1]);

tab.all_neurons = table(all_neurons);
tab.periodic_neurons = table(periodic_neurons);
tab.histogram_edges = table(histogram_edges);
tab.session_id = table(session_id);


end

function [ha,T]=get_overall_PI (param,seqid,cp)

nSTD=param.nSTD;
direction=param.direction;
cd(cp.datafolder)
if seqid==12
    load([...
        param.animal '_' param.area '_periodicity_js_leftright_dist345_seq12' cp.suffix '.mat'], 'gridness','params')
    load([...
        param.animal '_' param.area '_motor_resp_js_leftright_dist345_seq12' cp.suffix '.mat'], 'motor_resp')
else
    load([...
        param.animal '_' param.area '_periodicity_js_leftright_dist345_seq' num2str(seqid)  cp.suffix '.mat'], 'gridness','params')
    load([...
        param.animal '_' param.area '_motor_resp_js_leftright_dist345_seq' num2str(seqid)  cp.suffix '.mat'], 'motor_resp')
end

longer_gridlag=params.gridlag;
load([ cp.datafolder '/sessions/'...
    param.animal '_' param.area '_sessions.mat'], 'sessions')

load(['gp_sim_gridnessGP100ms_detrended.mat'])



params.gridlag=gridlag;
params.null_gridness=gp_95pcnull_gridness;
params.null_gridness_tlag_abovemean_bb=gridness_tlag_abovemean_bb;
params.gridness_thres_pc_abov_mean =  max(mean(params.null_gridness_tlag_abovemean_bb,1)+nSTD*std(params.null_gridness_tlag_abovemean_bb,[],1));%0.1576;%.3276; %2 STD FDR. This number comes from simulation of 1000 Gaussian Process smooth time courses.
params.null_pc_above_mean_gridness=pc_above_mean_gridness;

mintr=15;
xylim=.5;
gridness_m=[];gridness_v=[]; gridness_e=[];gridness_s=[];gridness_mall=[];gridness_vall=[]; gridness_eall=[];gridness_sall=[];
gridness_pm=[];gridness_pv=[]; gridness_pe=[];gridness_ps=[]; gridness_pmall=[];gridness_pvall=[]; gridness_peall=[];gridness_psall=[];
gridness_rm=[];gridness_rv=[]; gridness_re=[];gridness_rs=[];gridness_rmall=[];gridness_rvall=[]; gridness_reall=[];gridness_rsall=[];
gridness_mv=[];gridness_me=[];gridness_ms=[];
binned_gridness=[];binned_periodicity=[];binned_ramp=[];binned_rampall=[];
gridness_s_only=[];gridness_v_only=[]; gridness_e_only=[];
gridness_s_onlym=[];gridness_v_onlym=[]; gridness_e_onlym=[];
gridness_ps_only=[];gridness_pv_only=[]; gridness_pe_only=[];
gridness_ps_onlym=[];gridness_pv_onlym=[]; gridness_pe_onlym=[];
gridcells_m=[];gridcells_v=[];gridcells_s=[];gridcells_e=[];
sessions_m=[];sessions_v=[];sessions_e=[];sessions_s=[];
sessions_all=[];
neurons_all=[];
num_trials_mall=[];num_trials_vall=[];
num_trials_eall=[];
idx650=find(longer_gridlag==650);
PI_mental=[];PI_ITI=[];PI_err=[];

motor_resp_all=[];

hs=figure;
for ss=1:length(gridness)
    gridness_=gridness{ss,direction};
    if isempty(gridness_) || ~isfield(gridness_,'pc_above_mean_gridness'),continue;end
    grid_cells=find(gridness_.pc_above_mean_gridness>params.gridness_thres_pc_abov_mean &  gridness_.num_trials_mve(:,1)'>mintr);% & gridness_.gridness_max_periodicity<1000 & gridness_.gridness_max_periodicity>220);

    grid_cellsv=find(gridness_.pc_above_mean_gridnessv>params.gridness_thres_pc_abov_mean  &  gridness_.num_trials_mve(:,2)'>mintr);% & gridness_.gridness_max_periodicity<1000 & gridness_.gridness_max_periodicity>220);

    grid_cellse=find(gridness_.pc_above_mean_gridnesse>params.gridness_thres_pc_abov_mean  &  gridness_.num_trials_mve(:,3)'>mintr);% & gridness_.gridness_max_periodicity<1000 & gridness_.gridness_max_periodicity>220);
    try,if length(gridness_.pc_above_mean_gridnesss)<length(gridness_.pc_above_mean_gridnessvs), gridness_.pc_above_mean_gridnesss= gridness_.pc_above_mean_gridnessvs;end,catch;end
    grid_cellss=find(gridness_.pc_above_mean_gridnesss>params.gridness_thres_pc_abov_mean  &  gridness_.num_trials_mve(:,1)'>mintr);% & gridness_.gridness_max_periodicity<1000 & gridness_.gridness_max_periodicity>220);

    subplot(ceil(sqrt(length(gridness))),ceil(sqrt(length(gridness))),ss);
    histogram(gridness_.gridness_max_periodicity/1000,20);hold on
    histogram(gridness_.gridness_max_periodicity(grid_cells)/1000,20);title(sessions{ss})

    num_trials_mall =[num_trials_mall gridness_.num_trials_mve(:,1)'];
    num_trials_vall =[num_trials_vall gridness_.num_trials_mve(:,2)'];
    num_trials_eall =[num_trials_eall gridness_.num_trials_mve(:,3)'];

    grid_cells_all{ss}=[ss*ones(size(grid_cells));grid_cells;gridness_.pc_above_mean_gridness(grid_cells);gridness_.gridness_max_periodicity(grid_cells)/1000];
    grid_cells_allv{ss}=[ss*ones(size(grid_cellsv));grid_cellsv;gridness_.pc_above_mean_gridnessv(grid_cellsv);gridness_.gridness_max_periodicityv(grid_cellsv)/1000];
    grid_cells_alle{ss}=[ss*ones(size(grid_cellse));grid_cellse;gridness_.pc_above_mean_gridnesse(grid_cellse);gridness_.gridness_max_periodicitye(grid_cellse)/1000];
    grid_cells_alls{ss}=[ss*ones(size(grid_cellss));grid_cellss;gridness_.pc_above_mean_gridnesss(grid_cellss);gridness_.gridness_max_periodicitys(grid_cellss)/1000];

    gridness_m=[gridness_m gridness_.pc_above_mean_gridness(grid_cells)];
    gridness_v=[gridness_v gridness_.pc_above_mean_gridnessv(grid_cells)];
    gridness_e=[gridness_e gridness_.pc_above_mean_gridnesse(grid_cells)];
    gridness_s=[gridness_s gridness_.pc_above_mean_gridnesss(grid_cells)];

    sessions_m=[sessions_m ss*ones(1,length(grid_cells))];
    sessions_v=[sessions_v ss*ones(1,length(grid_cellsv))];
    sessions_e=[sessions_e ss*ones(1,length(grid_cellse))];
    sessions_s=[sessions_s ss*ones(1,length(grid_cellss))];


    gridcells_m=[ gridcells_m  grid_cells];
    gridcells_v=[ gridcells_v  grid_cellsv];
    gridcells_e=[ gridcells_e  grid_cellse];
    gridcells_s=[ gridcells_s  grid_cellss];


    sessions_all = [sessions_all ss*ones(1,length(gridness_.pc_above_mean_gridness))];
    neurons_all = [neurons_all 1:length(gridness_.pc_above_mean_gridness);];
    gridness_mall=[gridness_mall gridness_.pc_above_mean_gridness ];
    gridness_vall=[gridness_vall gridness_.pc_above_mean_gridnessv ];
    gridness_eall=[gridness_eall gridness_.pc_above_mean_gridnesse ];
    gridness_sall=[gridness_sall gridness_.pc_above_mean_gridnesss ];

    gridness_mv = [gridness_mv ismember(grid_cells,grid_cellsv)];
    gridness_me = [gridness_me ismember(grid_cells,grid_cellse)];
    gridness_ms = [gridness_ms ismember(grid_cells,grid_cellss)];

    gridness_v_only = [gridness_v_only gridness_.pc_above_mean_gridnessv(grid_cellsv(~ismember(grid_cellsv,grid_cells)))];
    gridness_e_only = [gridness_e_only gridness_.pc_above_mean_gridnesse(grid_cellse(~ismember(grid_cellse,grid_cells)))];
    gridness_s_only = [gridness_s_only gridness_.pc_above_mean_gridnesss(grid_cellss(~ismember(grid_cellss,grid_cells)))];
    gridness_v_onlym = [gridness_v_onlym gridness_.pc_above_mean_gridness(grid_cellsv(~ismember(grid_cellsv,grid_cells)))];
    gridness_e_onlym = [gridness_e_onlym gridness_.pc_above_mean_gridness(grid_cellse(~ismember(grid_cellse,grid_cells)))];
    gridness_s_onlym = [gridness_s_onlym gridness_.pc_above_mean_gridness(grid_cellss(~ismember(grid_cellss,grid_cells)))];


    gridness_pm=[gridness_pm gridness_.gridness_max_periodicity(grid_cells)/1000];
    gridness_pv=[gridness_pv gridness_.gridness_max_periodicityv(grid_cells)/1000];
    gridness_pe=[gridness_pe gridness_.gridness_max_periodicitye(grid_cells)/1000];
    gridness_ps=[gridness_ps gridness_.gridness_max_periodicitys(grid_cells)/1000];

    gridness_pmall=[gridness_pmall gridness_.gridness_max_periodicity/1000];
    gridness_pvall=[gridness_pvall gridness_.gridness_max_periodicityv/1000];
    gridness_peall=[gridness_peall gridness_.gridness_max_periodicitye/1000];
    gridness_psall=[gridness_psall gridness_.gridness_max_periodicitys/1000];

    gridness_pv_only = [gridness_pv_only gridness_.gridness_max_periodicityv(grid_cellsv(~ismember(grid_cellsv,grid_cells)))/1000];
    gridness_pe_only = [gridness_pe_only gridness_.gridness_max_periodicitye(grid_cellse(~ismember(grid_cellse,grid_cells)))/1000];
    gridness_ps_only = [gridness_ps_only gridness_.gridness_max_periodicitys(grid_cellss(~ismember(grid_cellss,grid_cells)))/1000];
    gridness_pv_onlym = [gridness_pv_onlym gridness_.gridness_max_periodicity(grid_cellsv(~ismember(grid_cellsv,grid_cells)))/1000];
    gridness_pe_onlym = [gridness_pe_onlym gridness_.gridness_max_periodicity(grid_cellse(~ismember(grid_cellse,grid_cells)))/1000];
    gridness_ps_onlym = [gridness_ps_onlym gridness_.gridness_max_periodicity(grid_cellss(~ismember(grid_cellss,grid_cells)))/1000];

    %find gridness at 650ms in mental vs ITI:
    clear gridness_tlag_abovemean gridness_tlags_abovemean gridness_tlage_abovemean
    for nn=1:size(gridness_.gridness_tlag,1)
        gridness_tlag_abovemean(nn,:) = gridness_.gridness_tlag(nn,:) - mean(gridness_.gridness_tlag(nn,find(gridness_.gridness_tlag(nn,:)>0,1):end ));
        gridness_tlags_abovemean(nn,:) = gridness_.gridness_tlags(nn,:) - mean(gridness_.gridness_tlags(nn,find(gridness_.gridness_tlags(nn,:)>0,1):end ));
        gridness_tlage_abovemean(nn,:) = gridness_.gridness_tlage(nn,:) - mean(gridness_.gridness_tlage(nn,find(gridness_.gridness_tlage(nn,:)>0,1):end ));
    end

    PI_mental=[PI_mental; gridness_tlag_abovemean(grid_cells,idx650)];
    PI_ITI=[PI_ITI; gridness_tlags_abovemean(grid_cells,idx650)];
    PI_err=[PI_err; gridness_tlage_abovemean(grid_cells,idx650)];

    %get cells with motor response
    if isempty(motor_resp{ss,direction}),motor_resp{ss,direction}.motor_resp_ttest=nan;end
    motor_resp_all=[ motor_resp_all motor_resp{ss,direction}.motor_resp_ttest];
end
idx650_discard=PI_mental<params.gridness_thres_pc_abov_mean;
PI_mental(idx650_discard)=[];
PI_ITI(idx650_discard)=[];
PI_err(idx650_discard)=[];

ha=figure('Position',[   744         170        1145         879]);

[h,pval,ci,stats]=ttest(PI_mental,PI_ITI,'tail','right');
disp(['one tailed paired t-test of PI at .65s for periodic neurons during mental vs ITI epoch'])
disp(['t(' num2str(stats.df) ')= ' num2str(stats.tstat) ', pval=' num2str(pval)])
subplot(2,2,1);scatter(PI_mental,PI_ITI,'ob','Filled');hold on;plot([-.5 1],[-.5 1],'-k');grid on;xlabel mental; ylabel ITI;
title ([params.animal ' ' params.area '# neurons=' num2str(length(PI_ITI)) ' t(' num2str(stats.df) ')= ' num2str(stats.tstat) ', pval=' num2str(pval)])
addline(params.gridness_thres_pc_abov_mean);addline(params.gridness_thres_pc_abov_mean,'h');
set(gca,'FontSize',15);axis square

if direction==1,direc = ' JS  left';else, direc = ' JS  right';end
animal_id_direction = repmat([params.animal direc],[length(PI_mental) 1]);
T.Tb = table(animal_id_direction,PI_mental,PI_ITI);

subplot(2,2,2);histogram(gridness_pm,0:.05:2); addline(median(gridness_pm),'color','r');
xlabel 'Periodicity'; ylabel '# of neurons'
title ([params.animal ' ' params.area '# neurons=' num2str(length(gridness_pm))])
set(gca,'FontSize',15,'XTick',0:.65:1.95);grid on;xlim([0 1.95])

animal_id_direction_ = repmat([params.animal direc],[length(gridness_pm) 1]);
periodicity = gridness_pm';
T.Ta = table(animal_id_direction_,periodicity);
hist_edges=0:.05:2;hist_edges=hist_edges';
animal_id_direction_ = repmat([params.animal direc],[length(hist_edges) 1]);
T.Ta_histedges = table(animal_id_direction_,hist_edges);


[h,pval,ci,stats]=ttest(PI_mental,PI_err,'tail','right');
disp(['one tailed paired t-test of PI at .65s for periodic neurons during mental vs err trials'])
disp(['t(' num2str(stats.df) ')= ' num2str(stats.tstat) ', pval=' num2str(pval)])
subplot(2,2,3);scatter(PI_mental,PI_err,'ok','Filled');hold on;plot([-.5 1],[-.5 1],'-k');grid on;xlabel 'mental succ trials'; ylabel 'mental err trials';
title ([params.animal ' ' params.area '# neurons=' num2str(length(PI_err)) ' t(' num2str(stats.df) ')= ' num2str(stats.tstat) ', pval=' num2str(pval)])
addline(params.gridness_thres_pc_abov_mean);addline(params.gridness_thres_pc_abov_mean,'h');
set(gca,'FontSize',15);axis square
PI_mental(isnan(PI_err))=[];
PI_err(isnan(PI_err))=[];
animal_id_direction_ = repmat([params.animal direc],[length(PI_mental) 1]);
T.Tc = table(animal_id_direction_,PI_mental,PI_err);



if param.savedataflag==1
    cd (cp.datafolder)
    save([params.animal '_' params.area '_allNeurons_gridness_dir' num2str(direction) '_seq' num2str(seqid) cp.suffix],...
        'gridness_pm','gridness_pmall','gridness_mall','gridness_m',...
        'gridness_ps','gridness_psall','gridness_sall','gridness_s',...
        'gridness_pv','gridness_pvall','gridness_vall','gridness_v',...
        'gridness_pe','gridness_peall','gridness_eall','gridness_e',...
        'gridcells_m','gridcells_e','gridcells_v','gridcells_s',...
        'sessions_m','sessions_v','sessions_e','sessions_s',...
        'sessions_all','neurons_all','params','num_trials_mall','num_trials_vall','num_trials_eall',...
        'motor_resp_all','cp')
end

end

function count_ramp_periodicity_leftright (param,trxtrreg,seqid,cp)
cd(cp.datafolder)
load([param.animal '_' param.area '_periodicity_js_leftright_dist345_seq' num2str(seqid) cp.suffix '.mat'], 'gridness','params')
load([param.animal '_' param.area '_ramp_js_leftright_dist345_seq' num2str(seqid) cp.suffix '.mat'], 'rampy')

load([cp.datafolder '/sessions/' ...
    param.animal '_' param.area '_sessions.mat'], 'sessions')

load(['gp_sim_gridnessGP100ms_detrended.mat'])
nSTD=2;
params.gridlag=gridlag;
params.null_gridness=gp_95pcnull_gridness;
params.null_gridness_tlag_abovemean_bb=gridness_tlag_abovemean_bb;
params.gridness_thres_pc_abov_mean =  max(mean(params.null_gridness_tlag_abovemean_bb,1)+nSTD*std(params.null_gridness_tlag_abovemean_bb,[],1));%0.1576;%.3276; %2 STD FDR. This number comes from simulation of 1000 Gaussian Process smooth time courses.
params.null_pc_above_mean_gridness=pc_above_mean_gridness;

mintr=15;
gridness_pml=[];
gridness_pmr=[];
ramp_ml=[];
ramp_mr=[];
ramp_valuesr=[];ramp_valuesl=[];

for ss=1:length(gridness)
    direction=1;
    gridness_=gridness{ss,direction};
    if isempty(gridness_) || ~isfield(gridness_,'pc_above_mean_gridness'),continue;end
    grid_cells=(gridness_.pc_above_mean_gridness>params.gridness_thres_pc_abov_mean &  gridness_.num_trials_mve(:,1)'>mintr);% & gridness_.gridness_max_periodicity<1000 & gridness_.gridness_max_periodicity>220);
    gridness_pml=[gridness_pml grid_cells];

    clear ramp_cells ramp_slope
    for nn=1:size(gridness_.trial_info,1)
        gg=squeeze(gridness_.trial_info(nn,:,5));
        ramp_cells(nn)=ttest(gg,0,'Alpha',.0001);
        ramp_slope(nn)=mean(gg);

        if trxtrreg==0
            ramp_ml=[ramp_ml rampy{ss,direction}.pval(nn)<.001];
            ramp_valuesl=[ramp_valuesl rampy{ss,direction}.slope(nn)];
        end

    end
    if trxtrreg==1
        ramp_ml=[ramp_ml ramp_cells];
        ramp_valuesl=[ramp_valuesl ramp_slope];
    end



    direction=2;
    gridness_=gridness{ss,direction};
    if isempty(gridness_) || ~isfield(gridness_,'pc_above_mean_gridness'),continue;end
    grid_cells=(gridness_.pc_above_mean_gridness>params.gridness_thres_pc_abov_mean &  gridness_.num_trials_mve(:,1)'>mintr);% & gridness_.gridness_max_periodicity<1000 & gridness_.gridness_max_periodicity>220);
    gridness_pmr=[gridness_pmr grid_cells];

    clear ramp_cells ramp_slope
    for nn=1:size(gridness_.trial_info,1)
        gg=squeeze(gridness_.trial_info(nn,:,5));
        ramp_cells(nn)=ttest(gg,0,'Alpha',.0001);
        ramp_slope(nn)=mean(gg);
        if trxtrreg==0
            ramp_mr=[ramp_mr rampy{ss,direction}.pval(nn)<.001];
            ramp_valuesr=[ramp_valuesr rampy{ss,direction}.slope(nn)];
        end
    end
    if trxtrreg==1
        ramp_mr=[ramp_mr ramp_cells];
        ramp_valuesr=[ramp_valuesr ramp_slope];
    end



end
nn=length(ramp_mr);
nnr=length(find(ramp_mr==1 | ramp_ml==1));
nnp=length(find(gridness_pmr==1 | gridness_pml==1));

%ramp and periodicity left vs right vs both
disp(['total neurons: ' num2str(nn)])
disp(['ramp left only: ' num2str(    length(find(ramp_mr==0 & ramp_ml==1))    ) ' neurons' num2str(length(find(ramp_mr==0 & ramp_ml==1))/nnr*100) ' %'])
disp(['ramp right only: ' num2str(    length(find(ramp_mr==1 & ramp_ml==0))    ) ' neurons' num2str(length(find(ramp_mr==1 & ramp_ml==0))/nnr*100) ' %'])
disp(['ramp both: ' num2str(    length(find(ramp_mr==1 & ramp_ml==1))    ) ' neurons' num2str(length(find(ramp_mr==1 & ramp_ml==1))/nnr*100) ' %'])
disp(['ramp total: ' num2str(    length(find(ramp_mr==1 | ramp_ml==1))    ) ' neurons'])

disp(['periodic left only: ' num2str(    length(find(gridness_pmr==0 & gridness_pml==1))    ) ' neurons' num2str(length(find(gridness_pmr==0 & gridness_pml==1))/nnp*100) ' %'])
disp(['periodic right only: ' num2str(    length(find(gridness_pmr==1 & gridness_pml==0))    ) ' neurons' num2str(length(find(gridness_pmr==1 & gridness_pml==0))/nnp*100) ' %'])
disp(['periodic both: ' num2str(    length(find(gridness_pmr==1 & gridness_pml==1))    ) ' neurons' num2str(length(find(gridness_pmr==1 & gridness_pml==1))/nnp*100) ' %'])
disp(['periodic total: ' num2str(    length(find(gridness_pmr==1 | gridness_pml==1))    ) ' neurons'])

% ramping down vs up
disp(['ramp right dir: ' num2str(length(find(ramp_mr==1)))])
disp(['ramp down: ' num2str(length(find(ramp_valuesr(ramp_mr==1)<0))) ' ramp up: ' num2str(length(find(ramp_valuesr(ramp_mr==1)>0))) ])
100*length(find(ramp_valuesr(ramp_mr==1)<0))/length(find(ramp_mr==1))

disp(['ramp left dir: ' num2str(length(find(ramp_ml==1)))])
disp(['ramp down: ' num2str(length(find(ramp_valuesl(ramp_ml==1)<0))) ' ramp up: ' num2str(length(find(ramp_valuesl(ramp_ml==1)>0))) ])
100*length(find(ramp_valuesl(ramp_ml==1)<0))/length(find(ramp_ml==1))

% ramping and peridic
disp(['ramp  right only: ' num2str(    length(find(ramp_mr==1 & gridness_pmr==0))    ) ' neurons' ])
disp(['periodic right only: ' num2str(   length(find(ramp_mr==0 & gridness_pmr==1))    ) ' neurons' ])
disp(['ramp and periodic right both: ' num2str(   length(find(ramp_mr==1 & gridness_pmr==1))    ) ' neurons' ])

disp(['ramp  left only: ' num2str(    length(find(ramp_ml==1 & gridness_pml==0))    ) ' neurons' ])
disp(['periodic left only: ' num2str(   length(find(ramp_ml==0 & gridness_pml==1))    ) ' neurons' ])
disp(['ramp and periodic left both: ' num2str(   length(find(ramp_ml==1 & gridness_pml==1))    ) ' neurons' ])

end



%=== compute bump phase stats
function compute_save_bump_phase_stats (params,seqid,cp)

% compute peak location w.r.t to offset and 2nd last peak w.r.t. last peak
% and 3rd last peak w.r.t 2nd last peak

params.direction=2;
behav_bump_compute(params,seqid,cp);

params.direction=1;
behav_bump_compute(params,seqid,cp);

end

function behav_bump_compute(params,seqid,cp)


params.savedir_area=params.savedata;%%['/Users/' whichimac '/Dropbox (MIT)/MJ & SN/nav_paper/misc/final_figs'];
if params.direction==2,params.dir=-1; else params.dir=1;end

load([cp.datafolder '/sessions/' ...
    params.animal '_' params.area '_sessions.mat'], 'sessions')

params.mtt_folder=cp.tensordatafolder;
if strcmp(params.area,'7a') && params.animal(1)=='m'
    cd([cp.datafolder]);
    load('mahler_7a_numneurons.mat','mahler_NP_within_session_neurons')
end

for ss=1:length(sessions)

    params.filename=sessions{ss};

    cd ([params.mtt_folder '/' params.filename '.mwk'])
    varlist=matfile([sessions{ss} '_neur_tensor_joyon']);
    cond_label=varlist.cond_label;
    cond_matrix=varlist.cond_matrix;
    for ii=1:length(cond_label)
        eval(['params.' cond_label{ii} '=cond_matrix(:,strcmp(cond_label, cond_label{ii} ));']);
    end
    temp=varlist.joyon;
    params.edges = temp.edges;
    params.binwidth = temp.binwidth;

    params.dist_conditions = abs(params.target-params.curr);
    params.dir_condition = sign(params.ta);

    params.smooth='gauss'; %or 'boxcar'
    params.gauss_smooth=.2; %   smoothing window for psth
    params.gauss_std = .1;   %   std of gaussian filter if gaussian
    params.gauss_smoothing_kern = fspecial('gaussian',[1 params.gauss_smooth/params.binwidth],params.gauss_std/params.binwidth);
    %to remove edge effect of filters, take extra 2*gaussian_filter_size and remove those time points after filtering
    params.window_edge_effect = params.gauss_smooth*2/params.binwidth:(length(params.edges)-params.gauss_smooth*2/params.binwidth);
    params.edges_rev = params.edges(params.window_edge_effect);


    if strcmp(params.animal,'mahler') && strcmp(params.area,'7a')  %for NP data, remove lowFR neurons from the outset
        numneuron=1:mahler_NP_within_session_neurons(ss);
    else
        numneuron = 1:size(varlist,'neur_tensor_joyon',1);
    end

    varlist_off=matfile([sessions{ss} '_neur_tensor_joyoff']);
    data_tensor_joyoff = varlist_off.neur_tensor_joyoff(numneuron,:,:);
    joyoff=varlist_off.joyoff;
    params.edges_revoff=joyoff.edges(params.window_edge_effect);

    data_tensor_joyon = varlist.neur_tensor_joyon(numneuron,:,:);

    if size(data_tensor_joyoff,3)<length(params.ta)
        data_tensor_joyoff(:,:,end+1)=0;
        data_tensor_joyon(:,:,end+1)=0;
    end

    params.mintrials_thres=25;

    %
    clear phase
    for neur= 1:size(data_tensor_joyoff,1)

        lowfr_trials = (mean(squeeze(data_tensor_joyoff(neur,joyoff.edges>-1.5 & joyoff.edges<-.5,:)),1)<cp.lowfr_thres)';

        if seqid==12
            trials_ = find(params.dist_conditions>3  & params.dir_condition==params.dir & params.trial_type==3 & params.seqq<3 & params.validtrials_mm==1 & lowfr_trials==0);

        else
            trials_ = find(params.dist_conditions>3  & params.dir_condition==params.dir & params.trial_type==3 & params.seqq==seqid & params.validtrials_mm==1 & lowfr_trials==0);

        end


        if length(trials_)<params.mintrials_thres, phase=[];continue;end
        try
            [phase.pvalbb1(neur,:),phase.kstatsbb1(neur,:),phase.mode_peakbb1(neur,:,:),...
                phase.pvalbb(neur,:),phase.kstatsbb(neur,:),phase.mode_peakbb(neur,:,:),...
                phase.pval1(neur,:),phase.kstatb1(neur,:),...
                phase.pval(neur,:),phase.kstats(neur,:),...
                phase.pvalbb1ipi(neur,:),phase.kstatsbb1ipi(neur,:),phase.mode_peakbb1ipi(neur,:,:),...
                phase.pvalbbipi(neur,:),phase.kstatsbbipi(neur,:),phase.mode_peakbbipi(neur,:,:),...
                phase.pval1ipi(neur,:),phase.kstatb1ipi(neur,:),...
                phase.pvalipi(neur,:),phase.kstatsipi(neur,:)]=get_bump_phase(params,squeeze(data_tensor_joyoff(neur,:,:)),...
                squeeze(data_tensor_joyon(neur,:,:)),lowfr_trials);
            disp([params.filename ' neur' num2str(neur)])

        catch
            disp(['bad neur == ' params.filename ' neur' num2str(neur) '==low trials'  ])

        end

        disp([params.filename ' neur' num2str(neur) 'seq' num2str(seqid) ' bump phase computed '  cp.suffix])

    end
    bump_phase_firstlast{ss}=phase;
    cd(cp.datafolder)
    try
        save([params.animal '_' params.area '_bump_phase_dir' num2str(params.direction) '_wrt_peak_or_event_seq' num2str(seqid) cp.suffix '.mat'],'bump_phase_firstlast','-append')
    catch
        save([params.animal '_' params.area '_bump_phase_dir' num2str(params.direction) '_wrt_peak_or_event_seq' num2str(seqid) cp.suffix '.mat'],'bump_phase_firstlast')
    end
    disp(['=======' params.filename  'seq' num2str(seqid) cp.suffix ' bump phase computed and saved ========='  ])

end

end


function [pvalbb1, kstatsbb1, mode_peakbb1,pvalbb, kstatsbb, mode_peakbb,...
    pval1, kstats1,pval, kstats,...
    pvalbb1ipi, kstatsbb1ipi, mode_peakbb1ipi,pvalbbipi, kstatsbbipi, mode_peakbbipi,...
    pval1ipi, kstats1ipi,pvalipi, kstatsipi]=get_bump_phase(params, data_tensor_joyoff,data_tensor_joyon,lowfr_trials)

xxoff=params.edges_revoff;
xxon=params.edges_rev;

trials_ = find(params.dist_conditions>3  & params.dir_condition==params.dir & params.trial_type==3 & params.seqq<3 & params.validtrials_mm==1 & lowfr_trials==0);
data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor_joyoff(:,trials_))','same');
data_tensor_smoothedoff=data_tensor_smoothed(:,params.window_edge_effect);
data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor_joyon(:,trials_))','same');
data_tensor_smoothedon=data_tensor_smoothed(:,params.window_edge_effect);

[~,tpsort]=sort(abs(params.tp(trials_)));
temp=data_tensor_smoothedoff(tpsort,:);
tempon=data_tensor_smoothedon(tpsort,:);





% bootstraped histogram of last peak loc compared to shuffled (circshifted) NULL
offset=.1;
offseton=.1;
bumpphase_window=1;
btrp=1000;

lastpeakbb_=nan(btrp,3);firstpeakbb_=lastpeakbb_;
lastpeakbbsh_=nan(btrp,3);firstpeakbbsh_=lastpeakbbsh_;

lastpeakbb_ipi=nan(btrp,3);firstpeakbb_ipi=lastpeakbb_ipi;
lastpeakbbsh_ipi=nan(btrp,3);firstpeakbbsh_ipi=lastpeakbbsh_ipi;

for bb=1:btrp
    trials_bb=randperm(length(trials_),ceil(length(trials_)/3));
    tempyy=mean(temp(trials_bb,:),1);
    tempyyon=mean(tempon(trials_bb,:),1);


    [lastpeakbb_(bb,:),lastpeakbb_ipi(bb,:)]= get_max_local_peaks_bump(tempyy,xxoff,[-bumpphase_window -offset]);
    [firstpeakbb_(bb,:),firstpeakbb_ipi(bb,:)]= get_max_local_peaks_bump(tempyyon,xxon,[offseton bumpphase_window]);


    for tr=1:length(trials_bb)
        p=circshift(1:size(temp,2),randi(size(temp,2)));
        %          p=randperm(size(temp,2));
        tempshuf(tr,:)=   temp(trials_bb(tr),p);
        tempshufon(tr,:)=   tempon(trials_bb(tr),p);
    end
    tempyysh=mean(tempshuf,1);
    tempyyshon=mean(tempshufon,1);




    [lastpeakbbsh_(bb,:),lastpeakbbsh_ipi(bb,:)]= get_max_local_peaks_bump(tempyysh,xxoff,[-bumpphase_window -offset]);
    [firstpeakbbsh_(bb,:),firstpeakbbsh_ipi(bb,:)]= get_max_local_peaks_bump(tempyyshon,xxon,[offseton bumpphase_window]);


end

lastpeak_=nan(length(trials_),3);firstpeak_=lastpeak_;
lastpeaksh_=nan(length(trials_),3);firstpeaksh_=lastpeaksh_;
lastpeak_ipi=lastpeak_;firstpeak_ipi=firstpeak_;
lastpeaksh_ipi=lastpeaksh_;firstpeaksh_ipi=firstpeaksh_;

for tr=1:length(trials_)
    tempyy= temp(tr,:) ;
    tempyyon= tempon(tr,:) ;

    [lastpeak_(tr,:),lastpeak_ipi(tr,:)]= get_max_local_peaks_bump(tempyy,xxoff,[-bumpphase_window -offset]);
    [firstpeak_(tr,:),firstpeak_ipi(tr,:)]= get_max_local_peaks_bump(tempyyon,xxon,[offseton bumpphase_window]);


    shiftedtimes=circshift(1:size(temp,2),randi(size(temp,2)));
    %      shiftedtimes=randperm(size(temp,2));
    tempyyshuf =   temp(tr,shiftedtimes);
    tempyyonshuf =   tempon(tr,shiftedtimes);
    [lastpeaksh_(tr,:),lastpeaksh_ipi(tr,:)]= get_max_local_peaks_bump(tempyyshuf,xxoff,[-bumpphase_window -offset]);
    [firstpeaksh_(tr,:),firstpeaksh_ipi(tr,:)]= get_max_local_peaks_bump(tempyyonshuf,xxon,[offseton bumpphase_window]);

end

lastpeak=lastpeak_  ;
firstpeak=firstpeak_  ;
lastpeaksh=lastpeaksh_  ;
firstpeaksh=firstpeaksh_  ;
lastpeakbb=lastpeakbb_  ;
firstpeakbb=firstpeakbb_  ;
lastpeakbbsh=lastpeakbbsh_  ;
firstpeakbbsh=firstpeakbbsh_  ;


[h,pvalbb(1),kstatsbb(1)]=kstest2(lastpeakbb(:,1),lastpeakbbsh(:,1),'Alpha',.05);
[h,pvalbb(2),kstatsbb(2)]=kstest2(lastpeakbb(:,2),lastpeakbbsh(:,2),'Alpha',.05);
[h,pvalbb(3),kstatsbb(3)]=kstest2(lastpeakbb(:,3),lastpeakbbsh(:,3),'Alpha',.05);

[h1,pvalbb1(1),kstatsbb1(1)]=kstest2(firstpeakbb(:,1),firstpeakbbsh(:,1),'Alpha',.05);
[h1,pvalbb1(2),kstatsbb1(2)]=kstest2(firstpeakbb(:,2),firstpeakbbsh(:,2),'Alpha',.05);
[h1,pvalbb1(3),kstatsbb1(3)]=kstest2(firstpeakbb(:,3),firstpeakbbsh(:,3),'Alpha',.05);

[h,pval(1),kstats(1)]=kstest2(lastpeak(:,1),lastpeaksh(:,1),'Alpha',.05);
[h,pval(2),kstats(2)]=kstest2(lastpeak(:,2),lastpeaksh(:,2),'Alpha',.05);
[h,pval(3),kstats(3)]=kstest2(lastpeak(:,3),lastpeaksh(:,3),'Alpha',.05);

[h1,pval1(1),kstats1(1)]=kstest2(firstpeak(:,1),firstpeaksh(:,1),'Alpha',.05);
[h1,pval1(2),kstats1(2)]=kstest2(firstpeak(:,2),firstpeaksh(:,2),'Alpha',.05);
[h1,pval1(3),kstats1(3)]=kstest2(firstpeak(:,3),firstpeaksh(:,3),'Alpha',.05);


mode_peakbb(1,:)=[mode(lastpeakbb(:,1)) mode(lastpeakbbsh(:,1)) ];
mode_peakbb(2,:)=[mode(lastpeakbb(:,2)) mode(lastpeakbbsh(:,2)) ];
mode_peakbb(3,:)=[mode(lastpeakbb(:,3)) mode(lastpeakbbsh(:,3)) ];
mode_peakbb1(1,:)=[mode(firstpeakbb(:,1)) mode(firstpeakbbsh(:,1)) ];
mode_peakbb1(2,:)=[mode(firstpeakbb(:,2)) mode(firstpeakbbsh(:,2)) ];
mode_peakbb1(3,:)=[mode(firstpeakbb(:,3)) mode(firstpeakbbsh(:,3)) ];

mode_peakbb(4,:)=[mode(lastpeak(:,1)) mode(lastpeaksh(:,1)) ];
mode_peakbb(5,:)=[mode(lastpeak(:,2)) mode(lastpeaksh(:,2)) ];
mode_peakbb(6,:)=[mode(lastpeak(:,3)) mode(lastpeaksh(:,3)) ];
mode_peakbb1(4,:)=[mode(firstpeak(:,1)) mode(firstpeaksh(:,1)) ];
mode_peakbb1(5,:)=[mode(firstpeak(:,2)) mode(firstpeaksh(:,2)) ];
mode_peakbb1(6,:)=[mode(firstpeak(:,3)) mode(firstpeaksh(:,3)) ];


lastpeak=lastpeak_ipi;
firstpeak=firstpeak_ipi;
lastpeaksh=lastpeaksh_ipi;
firstpeaksh=firstpeaksh_ipi;
lastpeakbb=lastpeakbb_ipi;
firstpeakbb=firstpeakbb_ipi;
lastpeakbbsh=lastpeakbbsh_ipi;
firstpeakbbsh=firstpeakbbsh_ipi;


[h,pvalbbipi(1),kstatsbbipi(1)]=kstest2(lastpeakbb(:,1),lastpeakbbsh(:,1),'Alpha',.05);
[h,pvalbbipi(2),kstatsbbipi(2)]=kstest2(lastpeakbb(:,2),lastpeakbbsh(:,2),'Alpha',.05);
[h,pvalbbipi(3),kstatsbbipi(3)]=kstest2(lastpeakbb(:,3),lastpeakbbsh(:,3),'Alpha',.05);

[h1,pvalbb1ipi(1),kstatsbb1ipi(1)]=kstest2(firstpeakbb(:,1),firstpeakbbsh(:,1),'Alpha',.05);
[h1,pvalbb1ipi(2),kstatsbb1ipi(2)]=kstest2(firstpeakbb(:,2),firstpeakbbsh(:,2),'Alpha',.05);
[h1,pvalbb1ipi(3),kstatsbb1ipi(3)]=kstest2(firstpeakbb(:,3),firstpeakbbsh(:,3),'Alpha',.05);

[h,pvalipi(1),kstatsipi(1)]=kstest2(lastpeak(:,1),lastpeaksh(:,1),'Alpha',.05);
[h,pvalipi(2),kstatsipi(2)]=kstest2(lastpeak(:,2),lastpeaksh(:,2),'Alpha',.05);
[h,pvalipi(3),kstatsipi(3)]=kstest2(lastpeak(:,3),lastpeaksh(:,3),'Alpha',.05);

[h1,pval1ipi(1),kstats1ipi(1)]=kstest2(firstpeak(:,1),firstpeaksh(:,1),'Alpha',.05);
[h1,pval1ipi(2),kstats1ipi(2)]=kstest2(firstpeak(:,2),firstpeaksh(:,2),'Alpha',.05);
[h1,pval1ipi(3),kstats1ipi(3)]=kstest2(firstpeak(:,3),firstpeaksh(:,3),'Alpha',.05);


mode_peakbbipi(1,:)=[mode(lastpeakbb(:,1)) mode(lastpeakbbsh(:,1)) ];
mode_peakbbipi(2,:)=[mode(lastpeakbb(:,2)) mode(lastpeakbbsh(:,2)) ];
mode_peakbbipi(3,:)=[mode(lastpeakbb(:,3)) mode(lastpeakbbsh(:,3)) ];
mode_peakbb1ipi(1,:)=[mode(firstpeakbb(:,1)) mode(firstpeakbbsh(:,1)) ];
mode_peakbb1ipi(2,:)=[mode(firstpeakbb(:,2)) mode(firstpeakbbsh(:,2)) ];
mode_peakbb1ipi(3,:)=[mode(firstpeakbb(:,3)) mode(firstpeakbbsh(:,3)) ];

mode_peakbbipi(4,:)=[mode(lastpeak(:,1)) mode(lastpeaksh(:,1)) ];
mode_peakbbipi(5,:)=[mode(lastpeak(:,2)) mode(lastpeaksh(:,2)) ];
mode_peakbbipi(6,:)=[mode(lastpeak(:,3)) mode(lastpeaksh(:,3)) ];
mode_peakbb1ipi(4,:)=[mode(firstpeak(:,1)) mode(firstpeaksh(:,1)) ];
mode_peakbb1ipi(5,:)=[mode(firstpeak(:,2)) mode(firstpeaksh(:,2)) ];
mode_peakbb1ipi(6,:)=[mode(firstpeak(:,3)) mode(firstpeaksh(:,3)) ];


end


function [maxlocalpeak,maxlocalpeakipi]= get_max_local_peaks_bump(fr,xx,rangeori)

ttt = xx>rangeori(1) & xx<rangeori(2)  ;
xxt = xx(ttt);
tempyy=fr(ttt);

tempyy=(tempyy-min(tempyy))/max(eps,(max(tempyy)-min(tempyy)));

[pks,peak1_phase]=findpeaks(tempyy,xxt,'MinPeakProminence',.05 );

if isempty(peak1_phase)
    maxlocalpeak(1:3)=nan;
    maxlocalpeakipi(1:3)=nan;
else
    [~,maxid]=max(pks);
    maxlocalpeak(1)=  peak1_phase(maxid);
    maxlocalpeakipi=maxlocalpeak;

    range=rangeori+maxlocalpeak(1);
    ttt = xx>range(1) & xx<range(2)  ;
    xxt = xx(ttt);
    tempyy=fr(ttt);
    tempyy=(tempyy-min(tempyy))/max(eps,(max(tempyy)-min(tempyy)));
    [pks,peak1_phase]=findpeaks(tempyy,xxt,'MinPeakProminence',.05 );

    if isempty(peak1_phase)
        maxlocalpeak(2:3)=nan;
        maxlocalpeakipi(2:3)=nan;
    else
        [~,maxid]=max(pks);
        maxlocalpeak(2)=  peak1_phase(maxid);
        maxlocalpeakipi=maxlocalpeak;
        maxlocalpeakipi(2)=maxlocalpeak(2)-maxlocalpeak(1);

        range=rangeori+maxlocalpeak(2);
        ttt = xx>range(1) & xx<range(2)  ;
        xxt = xx(ttt);
        tempyy=fr(ttt);
        tempyy=(tempyy-min(tempyy))/max(eps,(max(tempyy)-min(tempyy)));
        [pks,peak1_phase]=findpeaks(tempyy,xxt,'MinPeakProminence',.05 );


        if isempty(peak1_phase)
            maxlocalpeak(3)=nan;
            maxlocalpeakipi(3)=nan;
        else
            [~,maxid]=max(pks);
            maxlocalpeak(3)=  peak1_phase(maxid);
            maxlocalpeakipi(3)=maxlocalpeak(3)-maxlocalpeak(2);
        end

    end


end

end

