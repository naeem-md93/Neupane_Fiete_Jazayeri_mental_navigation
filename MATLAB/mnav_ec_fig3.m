% Neupane, Fiete, Jazayeri 2024 mental navigation paper 
% Fig 3 plot reproduction

%Download preprocessed Fig3 data from this link into your local folder:
% https://www.dropbox.com/scl/fo/qfupier0tdh3sp65obpwj/AM0Qqc_8nZtjxpLqxJj3TWQ?rlkey=aly1gdfw8srj7sefzcp53a89r&dl=0

%Download preprocessed tensor data from this link into your local folder:
% https://www.dropbox.com/scl/fo/nw6zals6ayf0w7vszysbl/h?rlkey=e4c8ee6rr9iv7k218ybym6e1b&dl=0

%Download CAN model data here (this link is the same as in mnav_ec_fig4.m)
% https://www.dropbox.com/scl/fo/vu8cl45wmiixo4gxnuaug/AMFPqtj73cZPCzOnQn9bTZc?rlkey=irxfazoibvdk1jc3cui0neshg&dl=0
%for questions or further data/code access contact sujayanyaupane@gmail.com
%=============================================================================


%Fig3: mnav_fig3_distance_coding_and_CAN_dynamics
clear
cp.savedir_='/data_figs';

% mkdir([cp.savedir_ '/Fig3']); %if the folder doesn't exist, make one and download data there
cp.datafolder=[cp.savedir_ '/Fig3/data'];

cp.datafolder_fig2 = [cp.savedir_ '/Fig2/data']; %This m-file has one dependency on Fig2 gridness data.  

% mkdir([cp.savedir_ '/Fig4']); %if the folder doesn't exist, make one and download data there
cp.modeldatafolder = [cp.savedir_ '/Fig4/data'];


cp.tensordatafolder=['/Users/Sujay/Dropbox (MIT)/physiology_data_for_sharing/' cp.area]; %change this folder to your local folder you downloaded tensor data

%constants and parameters: 
cp.example_xcorr_sessionA='amadeus08292019_a';
cp.example_xcorr_sessionM='mahler04122021_a';
cp.example_seq=1;

%% prep data for dist/img onset/offset coding analysis:
 
params.area='EC';
params.animal = 'amadeus';
params.savedata=1;
params.tt_premov = [-.4 .25];
params.savedir_area=cp.savedir_; 
params.mtt_folder= cp.tensordatafolder; 

%added these functions from mnav_hc_distcode_and_TDR:
seq=12; 
get_save_icfc(params,seq,cp)
get_save_icfc_impairs(params,seq,cp) 


%% onset and offset distance coding
 
seq=12;
ttoff= 1:13;
tton = 1:13;
ttpre= 1:13;
mintrials=10;
recompute=0;

if recompute
    fr_ec_a=get_fr(mintrials,'EC',1:18,cp,'amadeus',params,seq);%add this function from mnav_hc_distcode_and_TDR:
    fr_ec_m=get_fr(mintrials,'EC',1:18,cp,'mahler',params,seq);
    cd(cp.datafolder)
    save(['mahler_amadeus_psth_Rsq_tdr_imgpairs_seq_' num2str(seq) '.mat'])
else
    cd(cp.datafolder)
    if seq==12
        load('mahler_amadeus_psth_Rsq_tdr_imgpairs.mat')
    else
        load([cp.datafolder '/mahler_amadeus_psth_Rsq_tdr_imgpairs_seq_' num2str(seq) '.mat'])
    end
end

% compute betas and plot 
honoff=figure ('Position',[  4         547        1298         319]);
hdistimg=figure ('Position',[346         103        1081         730]);
htdr=figure ('Position',[ 476   208   971   658]);
htdr_bar=figure ('Position',[ 476   208   971   658]);

num_bootstrap=50;
num_iterations = 1; %change this to 5 for sanity checking consistency over multiple runs
wod1=0;
animal='amadeus';

for ii=1:num_iterations
    switch animal
        case 'amadeus'
            fr_ec = fr_ec_a;
        case 'mahler'
            fr_ec = fr_ec_m;
    end

    if wod1==0, [pvc_EC,betarsq_EC]=fit_tdr_axis(fr_ec,tton,1,num_bootstrap);    filename_suffix = '_withd1';
    else,[pvc4_EC,betarsq4_EC]=fit_tdr_axis_wodist1(fr_ec,tton,1,num_bootstrap);    filename_suffix = '_wod1';
    end

    %sanity check:
    % plot dir1, seq1,2 for sanity check:
    pre_corr_win=[-.2 -.1];
    off_corr_win = [-.4 -.3];
    if wod1==0, [T]=plot_5iterations(pvc_EC,betarsq_EC,fr_ec,['EC ' animal], pre_corr_win,off_corr_win,honoff,hdistimg,htdr,htdr_bar,ii,num_bootstrap);
    else, [T]=plot_5iterations(pvc4_EC,betarsq4_EC,fr_ec,['EC ' animal], pre_corr_win,off_corr_win,honoff,hdistimg,htdr,htdr_bar,ii,num_bootstrap);end
end


cd(cp.datafolder)
sheet = ['fig3b_monk_' animal(1)];
writetable(T.R2all,['Fig3' filename_suffix '.xlsx'],'Sheet',sheet)
writetable(T.R2either,['Fig3' filename_suffix '.xlsx'],'Sheet',sheet,'Range','F1')
writetable(T.R2both,['Fig3' filename_suffix '.xlsx'],'Sheet',sheet,'Range','I1')
writetable(T.R2neither,['Fig3' filename_suffix '.xlsx'],'Sheet',sheet,'Range','L1')

sheet = ['fig3d_monk_' animal(1)];
writetable(T.projections_mean_std,['Fig3' filename_suffix '.xlsx'],'Sheet',sheet)
writetable(T.TDR_lienar_fit,['Fig3' filename_suffix '.xlsx'],'Sheet',sheet,'Range','A8')
writetable(T.onset_projections,['Fig3' filename_suffix '.xlsx'],'Sheet',sheet,'Range','G1')
writetable(T.offset_projections,['Fig3' filename_suffix '.xlsx'],'Sheet',sheet,'Range','M1')

if wod1==0
    sheet = ['figS6b_monk_' animal(1)];
    writetable(T.Fstat_start,['FigS6' filename_suffix '.xlsx'],'Sheet',sheet)
    writetable(T.histo_dist_start,['FigS6' filename_suffix '.xlsx'],'Sheet',sheet,'Range','F1')
    writetable(T.hist_edges,['FigS6' filename_suffix '.xlsx'],'Sheet',sheet,'Range','G1')

    sheet = ['figS6c_monk_' animal(1)];
    writetable(T.Fstat_target,['FigS6' filename_suffix '.xlsx'],'Sheet',sheet)
    writetable(T.histo_dist_target,['FigS6' filename_suffix '.xlsx'],'Sheet',sheet,'Range','F1')
    writetable(T.hist_edges,['FigS6' filename_suffix '.xlsx'],'Sheet',sheet,'Range','G1')
end

honoff.Renderer='Painters';
htdr.Renderer='Painters';
honhdistimgoff.Renderer='Painters';
cd(cp.datafolder)
saveas(honoff,['Fig3b_' animal '_onoff_scatter_seq' num2str(seq) filename_suffix],'epsc')
saveas(htdr,['Fig3d_' animal '_onoff_TDR_seq' num2str(seq) filename_suffix],'epsc')
saveas(htdr_bar,['Fig3d_' animal '_onoff_TDR_proj_barplot' num2str(seq) filename_suffix],'epsc')

if wod1==0
    saveas(hdistimg,['FigS6bc_'  animal '_dist_img_encode_seq' num2str(seq) filename_suffix],'epsc')
end


%% Fig S6a FR vs slope of FR 
%from saved data. To do: include code here to generate this data

animal = 'mahler';

load([cp.datafolder '/EC ' animal '_ramp_dist_comparison.mat'])

lim=10;
hinv=figure('Position',[476    48   623   818]);
signn = find(ramppon(:,1)<.05 | pon(:,1)<.05 )';
signnboth = find(ramppon(:,1)<.05 & pon(:,1)<.05 )';
signnramp = find(ramppon(:,1)<.05 & pon(:,1)>=.05 )';
signndist = find(ramppon(:,1)>=.05 & pon(:,1)<.05 )';
signnnone = find(ramppon(:,1)>=.05 & pon(:,1)>=.05 )';

subplot(2,2,1);
scatter(fon(signnboth,1),rampfon(signnboth,1),20,[0 0 0],'Filled');hold on;
scatter(fon(signnramp,1),rampfon(signnramp,1),20,[1 0 0],'Filled');
scatter(fon(signndist,1),rampfon(signndist,1),20,[0 0 1],'Filled');
scatter(fon(signnnone,1),rampfon(signnnone,1),10,[0.5 0.5 0.5],'Filled');

plot([0 lim],[0 lim],'-k');axis([0 lim 0 lim])
xlabel 'F-stat dist effect (mean FR)';grid on;axis square;
ylabel 'F-stat dist effect (slope)'
title (['onset, n=' num2str(length(signn))])
xx=fon(signn,1)-rampfon(signn,1);
[h,pval,~,stats]=ttest(xx);
subplot(2,2,3);
histogram(xx,[-lim:.5:lim]); addline(mean(xx),'color','r');  grid on;
title([stats.tstat stats.df pval])

signn = find(ramppoff(:,1)<.05 | poff(:,1)<.05 )';
signnboth = find(ramppoff(:,1)<.05 & poff(:,1)<.05 )';
signnramp = find(ramppoff(:,1)<.05 & poff(:,1)>=.05 )';
signndist = find(ramppoff(:,1)>=.05 & poff(:,1)<.05 )';
signnnone = find(ramppoff(:,1)>=.05 & poff(:,1)>=.05 )';

subplot(2,2,2);
scatter(foff(signnboth,1),rampfoff(signnboth,1),20,[0 0 0],'Filled');hold on;
scatter(foff(signnramp,1),rampfoff(signnramp,1),20,[1 0 0],'Filled');
scatter(foff(signndist,1),rampfoff(signndist,1),20,[0 0 1],'Filled');
scatter(foff(signnnone,1),rampfoff(signnnone,1),10,[0.5 0.5 0.5],'Filled');
plot([0 lim],[0 lim],'-k');axis([0 lim 0 lim])
xlabel 'F-stat dist effect (mean FR)';grid on;axis square;
ylabel 'F-stat dist effect (slope)'
title (['offset, n=' num2str(length(signn))])
xx=foff(signn,1)-rampfoff(signn,1);
[h,pval,~,stats]=ttest(xx);
subplot(2,2,4);
histogram(xx,[-lim:.5:lim]); addline(mean(xx),'color','r');  grid on;
title([stats.tstat stats.df pval])

sgtitle([animal ' dist coding by FR ramp vs FR mean']);


F_stat_dist_FR=foff(:,1);F_stat_dist_slopeofFR=rampfoff(:,1);
p_val_dist_FR=poff(:,1);p_val_dist_slopeofFR=ramppoff(:,1);

histo_FR_slopeofFR = xx;
hist_edges=(-lim:.5:lim)';


T.FR_vs_slopeifFR = table(F_stat_dist_FR, F_stat_dist_slopeofFR ,p_val_dist_FR, p_val_dist_slopeofFR);
T.histo_FR_slopeofFR = table(histo_FR_slopeofFR);
T.hist_edges = table(hist_edges);

cd(cp.datafolder);
writetable(T.FR_vs_slopeifFR,'FigS6.xlsx','Sheet',['fig_S6a_monk_' animal(1)])
writetable(T.histo_FR_slopeofFR,'FigS6.xlsx','Sheet',['fig_S6a_monk_' animal(1)],'Range','F1')
writetable(T.hist_edges,'FigS6.xlsx','Sheet',['fig_S6a_monk_' animal(1)],'Range','G1')

%% xcorr analysis to test CAN dynamics
%skip this if the xcorr data is downloaded
params.area='EC';
params.animal = 'amadeus';

params.savefig=0;
params.savedata=cp.datafolder; 
load([cp.datafolder '/' params.animal '_' params.area '_sessions.mat'], 'sessions')

params.mtt_folderspo=cp.tensordatafolder; 
cd(params.savedata)
for ss=5%[ 1:length(sessions)]
    params.filename=sessions{ss};
    
    
    %get xcorr for the session:
    xcorr_out_periodic = get_xcorr(params,sessions,ss,'periodic',cp);
%     xcorr_out_nonperiodic = get_xcorr(params,sessions,ss,'nonperiodic',cp);
    try
        xcorr_contexts{ss}=xcorr_out_periodic;
        xcorr_contexts_nonperiodic{ss}=[];%xcorr_out_nonperiodic;
    catch, continue;end
    cd(params.savedata)
    save([params.animal '_' params.area 'xcorr_top25_contexts.mat'],'xcorr_contexts','xcorr_contexts_nonperiodic')
    
end

%% plot xcorr across eopchs
%amadeus: periodic: sess5, nonperiodic sess4
%mahler periodic: sess1, nonperiodic sess5 (or sess3)

caxislim=[-.2 .2];
params.area='EC';
params.animal = 'mahler';
load([cp.datafolder '/' params.animal '_' params.area '_sessions.mat'], 'sessions')
ss_periodic=1; 
ss_nonperiodic=5;
save_excel_data=0;
cd(cp.datafolder)
load([params.animal '_' params.area 'xcorr_top25_contexts.mat'],'xcorr_contexts','xcorr_contexts_nonperiodic')

figure('Position',[  190         555        1416         494]);
xx=-xcorr_contexts{ss_periodic}.maxlag:xcorr_contexts{ss_periodic}.maxlag;

if all(isnan(xcorr_contexts{ss_periodic}.xycorr1(:)))
    [maxval,maxidx]= max(xcorr_contexts{ss_periodic}.xycorr2,[],2);
else
    [maxval,maxidx]= max(xcorr_contexts{ss_periodic}.xycorr1,[],2);
end

[~,sortid] = sort(maxidx);
maxval=maxval(sortid);
sortid(isnan(maxval))=[];


subplot(2,8,1);imagesc(xx,1:size(xcorr_contexts{ss_periodic}.xycorr1(sortid,:),1),xcorr_contexts{ss_periodic}.xycorr1(sortid,:));title seq1;addline([-650 0 650],'color','k');caxis(caxislim)
subplot(2,8,2);imagesc(xx,1:size(xcorr_contexts{ss_periodic}.xycorr1(sortid,:),1),xcorr_contexts{ss_periodic}.xycorr2(sortid,:)); title seq2;addline([-650 0 650],'color','k');caxis(caxislim)
subplot(2,8,3);imagesc(xx,1:size(xcorr_contexts{ss_periodic}.xycorr1(sortid,:),1),xcorr_contexts{ss_periodic}.xycorrs(sortid,:)); title ITI;addline([-650 0 650],'color','k');caxis(caxislim)
subplot(2,8,4);imagesc(xx,1:size(xcorr_contexts{ss_periodic}.xycorr1(sortid,:),1),xcorr_contexts{ss_periodic}.xycorrinf(sortid,:)); title inference;addline([-650 0 650],'color','k');caxis(caxislim)
subplot(2,8,5);imagesc(xx,1:size(xcorr_contexts{ss_periodic}.xycorr1(sortid,:),1),xcorr_contexts{ss_periodic}.xycorrerr(sortid,:)); title error;addline([-650 0 650],'color','k');caxis(caxislim)
subplot(2,8,6);imagesc(xx,1:size(xcorr_contexts{ss_periodic}.xycorr1(sortid,:),1),xcorr_contexts{ss_periodic}.xycorrl(sortid,:)); title left;addline([-650 0 650],'color','k');caxis(caxislim)
subplot(2,8,7);imagesc(xx,1:size(xcorr_contexts{ss_periodic}.xycorr1(sortid,:),1),xcorr_contexts{ss_periodic}.xycorrr(sortid,:)); title right;addline([-650 0 650],'color','k');caxis(caxislim)
subplot(2,8,8);imagesc(xx,1:size(xcorr_contexts{ss_periodic}.xycorr1(sortid,:),1),xcorr_contexts{ss_periodic}.xycorrv(sortid,:)); title visual;addline([-650 0 650],'color','k');caxis(caxislim)


if all(isnan(xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorr2(:)))
    [maxval,maxidx]= max(xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorr1,[],2);
else
    [maxval,maxidx]= max(xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorr2,[],2);
end
[~,sortidnp] = sort(maxidx);
maxval=maxval(sortidnp);
sortidnp(isnan(maxval))=[];

% subplot(2,8,9);imagesc(xx,1:size(xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorr1,1),xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorr1(sortidnp,:));addline([-650 0 650],'color','k');caxis(caxislim)
% subplot(2,8,10);imagesc(xx,1:size(xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorr1,1),xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorr2(sortidnp,:));addline([-650 0 650],'color','k');caxis(caxislim)
% subplot(2,8,11);imagesc(xx,1:size(xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorr1,1),xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorrs(sortidnp,:));addline([-650 0 650],'color','k');caxis(caxislim)
% subplot(2,8,12);imagesc(xx,1:size(xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorr1,1),xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorrinf(sortidnp,:));addline([-650 0 650],'color','k');caxis(caxislim)
% subplot(2,8,13);imagesc(xx,1:size(xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorr1,1),xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorrerr(sortidnp,:));addline([-650 0 650],'color','k');caxis(caxislim)
% subplot(2,8,14);imagesc(xx,1:size(xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorr1,1),xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorrl(sortidnp,:));addline([-650 0 650],'color','k');caxis(caxislim)
% subplot(2,8,15);imagesc(xx,1:size(xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorr1,1),xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorrr(sortidnp,:));addline([-650 0 650],'color','k');caxis(caxislim)
% subplot(2,8,16);imagesc(xx,1:size(xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorr1,1),xcorr_contexts_nonperiodic{ss_nonperiodic}.xycorrv(sortidnp,:));addline([-650 0 650],'color','k');caxis(caxislim)
hf=gcf;
hf.Renderer='Painters';
cd(cp.savedir_)
%  saveas(hf,['FigS7' sessions{ss_periodic} '_' params.area '_xcorr_contextstop25'],'epsc');


 lags=xx';
 xcorr_all_trials=xcorr_contexts{ss_periodic}.xycorr1(sortid,:)';
 xcorr_left_trials=xcorr_contexts{ss_periodic}.xycorrl(sortid,:)';
 xcorr_right_trials=xcorr_contexts{ss_periodic}.xycorrr(sortid,:)';
 xcorr_err_trials=xcorr_contexts{ss_periodic}.xycorrerr(sortid,:)';
 xcorr_ITI=xcorr_contexts{ss_periodic}.xycorrs(sortid,:)';
 xcorr_inference=xcorr_contexts{ss_periodic}.xycorrinf(sortid,:)';

 %image data isn't required to be uploaded as source data
% writematrix([lags  xcorr_all_trials],['FigS7_' params.animal '.xlsx'],'Sheet','fig_S7a')
% writematrix(  xcorr_left_trials,['FigS7_' params.animal '.xlsx'],'Sheet','fig_S7b')
% writematrix(  xcorr_right_trials,['FigS7_' params.animal '.xlsx'],'Sheet','fig_S7c')
% writematrix(  xcorr_err_trials,['FigS7_' params.animal '.xlsx'],'Sheet','fig_S7d')
% writematrix(  xcorr_ITI,['FigS7_' params.animal '.xlsx'],'Sheet','fig_S7e')
% writematrix(  xcorr_inference,['FigS7_' params.animal '.xlsx'],'Sheet','fig_S7f')


% plot xcorr correlation between contexts:
corrlim=1;
idx=find(xx>=-5 & xx<=5);
xcorr_=xcorr_contexts{ss_periodic};

xcorr_norm1=nanmean(xcorr_.xycorr1(sortid,idx),2);
xcorr_norm2=nanmean(xcorr_.xycorr2(sortid,idx),2);
xcorr_normspo=nanmean(xcorr_.xycorrs(sortid,idx),2);
xcorr_inf=nanmean(xcorr_.xycorrinf(sortid,idx),2);
xcorr_normerr=nanmean(xcorr_.xycorrerr(sortid,idx),2);


xcorr_np=xcorr_contexts_nonperiodic{ss_nonperiodic};

xcorr_norm1np=nanmean(xcorr_np.xycorr1(sortidnp,idx),2);
xcorr_norm2np=nanmean(xcorr_np.xycorr2(sortidnp,idx),2);
xcorr_normsponp=nanmean(xcorr_np.xycorrs(sortidnp,idx),2);
xcorr_infnp=nanmean(xcorr_np.xycorrinf(sortidnp,idx),2);
xcorr_normerrnp=nanmean(xcorr_np.xycorrerr(sortidnp,idx),2);
%
hp=figure;
subplot(2,2,1)
scatter(xcorr_norm1,xcorr_normspo,10,'ok','Filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
axis([-.5 corrlim -.5 corrlim]);hold on; plot([-.5 corrlim],[-.5 corrlim],'-k');
ylabel 'xcorr spont'; xlabel 'xcorr mnav'
set(gca,'XTick',-1:.5:1,'YTick',-1:.5:1,'FontSize',15);grid on
axis square

subplot(2,2,2)
scatter(xcorr_norm1,xcorr_inf,10,'ok','Filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
axis([-.5 corrlim -.5 corrlim]);hold on; plot([-.5 corrlim],[-.5 corrlim],'-k');
ylabel 'xcorr inf'; xlabel 'xcorr mnav'
set(gca,'XTick',-1:.5:1,'YTick',-1:.5:1,'FontSize',15);grid on
axis square
[rho,pval]=corr(xcorr_norm1,xcorr_inf);
title(['r(' num2str(length(xcorr_norm1)) ')=' num2str(rho) ',pval=' num2str(pval)])

subplot(2,2,3)
scatter(xcorr_norm1,xcorr_norm2,10,'ok','Filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
axis([-.5 corrlim -.5 corrlim]);hold on; plot([-.5 corrlim],[-.5 corrlim],'-k');
ylabel 'xcorr seq2'; xlabel 'xcorr mnav'
set(gca,'XTick',-1:.5:1,'YTick',-1:.5:1,'FontSize',15);grid on
axis square

subplot(2,2,4)
scatter(xcorr_norm1,xcorr_normerr,10,'ok','Filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
axis([-.5 corrlim -.5 corrlim]);hold on; plot([-.5 corrlim],[-.5 corrlim],'-k');
ylabel 'xcorr err trials'; xlabel 'xcorr mnav'
set(gca,'XTick',-1:.5:1,'YTick',-1:.5:1,'FontSize',15);grid on
axis square
sgtitle([sessions{ss_periodic} ' periodic neurons xcorr across contexts'])

xcorr_mnav=xcorr_norm1;
xcorr_inference=xcorr_inf;
xcorr_ITI=xcorr_normspo;
animal_id = repmat([params.animal],[length(xcorr_mnav) 1]);
T = table(animal_id,xcorr_mnav,xcorr_ITI,xcorr_inf);
if save_excel_data,writetable(T,['FigS7_' params.animal '.xlsx'],'Sheet','fig_S7g');end



hnp=figure;
subplot(2,2,1)
scatter(xcorr_norm1np,xcorr_normsponp,10,'ok','Filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
axis([-.5 corrlim -.5 corrlim]);hold on; plot([-.5 corrlim],[-.5 corrlim],'-k');
ylabel 'xcorr spont'; xlabel 'xcorr mnav'
set(gca,'XTick',-1:.5:1,'YTick',-1:.5:1,'FontSize',15);grid on
axis square

subplot(2,2,2)
scatter(xcorr_norm1np,xcorr_infnp,10,'ok','Filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
axis([-.5 corrlim -.5 corrlim]);hold on; plot([-.5 corrlim],[-.5 corrlim],'-k');
ylabel 'xcorr inf'; xlabel 'xcorr mnav'
set(gca,'XTick',-1:.5:1,'YTick',-1:.5:1,'FontSize',15);grid on
axis square
x=xcorr_norm1np(~isnan(xcorr_norm1np) & ~isnan(xcorr_infnp));y=xcorr_infnp(~isnan(xcorr_norm1np) & ~isnan(xcorr_infnp));
[rho,pval]=corr(x,y);
title(['r(' num2str(length(xcorr_norm1)) ')=' num2str(rho) ',pval=' num2str(pval)])


subplot(2,2,3)
scatter(xcorr_norm1np,xcorr_norm2np,10,'ok','Filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
axis([-.5 corrlim -.5 corrlim]);hold on; plot([-.5 corrlim],[-.5 corrlim],'-k');
ylabel 'xcorr seq2'; xlabel 'xcorr mnav'
set(gca,'XTick',-1:.5:1,'YTick',-1:.5:1,'FontSize',15);grid on
axis square

subplot(2,2,4)
scatter(xcorr_norm1np,xcorr_normerrnp,10,'ok','Filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
axis([-.5 corrlim -.5 corrlim]);hold on; plot([-.5 corrlim],[-.5 corrlim],'-k');
ylabel 'xcorr err trials'; xlabel 'xcorr mnav'
set(gca,'XTick',-1:.5:1,'YTick',-1:.5:1,'FontSize',15);grid on
axis square
sgtitle([sessions{ss_nonperiodic} ' non-periodic neurons xcorr across contexts'])

xcorr_mnav_nonperiodic=xcorr_norm1np;
xcorr_inference_nonperiodic=xcorr_infnp;
xcorr_ITI_nonperiodic=xcorr_normsponp;
animal_id = repmat([params.animal],[length(xcorr_mnav_nonperiodic) 1]);
T = table(animal_id,xcorr_mnav_nonperiodic,xcorr_ITI_nonperiodic,xcorr_inference_nonperiodic);
if save_excel_data, writetable(T,['FigS7_' params.animal '.xlsx'],'Sheet','fig_S7h');end


hp.Renderer='Painters';
hnp.Renderer='Painters';
cd(cp.datafolder)
% saveas(hp,['FigS7' sessions{ss_periodic} '_' params.area '_xcorr_scatter_contexts_periodictop25'],'epsc');
% saveas(hnp,['FigS7' sessions{ss_nonperiodic} '_' params.area '_xcorr_scatter_contexts_non_periodic'],'epsc');

[h,pval,~,stats]=ttest2(xcorr_norm1,xcorr_inf,'Tail','Right');


% to address third reviewer's comment: compute correlations at all time lags
allidx=find(xx>=-900 & xx<=900);
clear corr_nav_iti corr_nav_inf
for ii=1:length(allidx)

    xcorr_norm1alllags(:,ii)=nanmean(xcorr_.xycorr1(sortid,allidx(ii)),2);
    xcorr_normspoalllags(:,ii)=nanmean(xcorr_.xycorrs(sortid,allidx(ii)),2);
    xcorr_infalllags(:,ii)=nanmean(xcorr_.xycorrinf(sortid,allidx(ii)),2);

    [corr_nav_iti(ii),pvaliti(ii)]=corr(xcorr_norm1alllags(:,ii),xcorr_normspoalllags(:,ii));
    [corr_nav_inf(ii),pvalinf(ii)]=corr(xcorr_norm1alllags(:,ii),xcorr_infalllags(:,ii));

    

end
hcorrlags=figure('Position',[476   487   868   379]);
subplot(1,2,1);
plot(xx(allidx),corr_nav_iti);hold on
pxx=pvaliti;
pxx(pvaliti<.05/length(allidx))=1;pxx(pvaliti>=.05/length(allidx))=nan;%with Bonferroni correction
plot(xx(allidx),pxx,'or');
ylabel 'xcorr nav-ITI'; xlabel 'lag(s)';set(gca,'FontSize',15,'Xtick',[-650 0 650]);grid on


subplot(1,2,2);
plot(xx(allidx),corr_nav_inf);hold on;
pxx=pvalinf;
pxx(pvalinf<.05/length(allidx))=1;pxx(pvalinf>=.05/length(allidx))=nan;
plot(xx(allidx),pxx,'or')
ylabel 'xcorr nav-inference'; xlabel 'lag(s)';set(gca,'FontSize',15,'Xtick',[-650 0 650]);grid on
sgtitle([sessions{ss_periodic} ' xcorr correlation across lags'])


cd(cp.savedir_)
lags=xx(allidx)';
corr_mnav_ITI=corr_nav_iti';
corr_pval_mnav_ITI=pvaliti';
corr_mnav_inference=corr_nav_inf';
corr_pval_mnav_inference=pvalinf';
animal_id = repmat([params.animal],[length(corr_mnav_ITI) 1]);
T = table(animal_id,lags,corr_mnav_ITI,corr_pval_mnav_ITI,corr_mnav_inference,corr_pval_mnav_inference);
if save_excel_data,writetable(T,['FigS8_' params.animal '.xlsx'],'Sheet','fig_S8a');end

hcorrlags.Renderer='painters';
saveas(hcorrlags,['FigS8' sessions{ss_periodic} '_' params.area '_xcorr_across_lags_wBonferroni'],'epsc');


%% FigS8b
% reviewer's comment on 2nd review: comparing cell-cell xcorr phase distribution bertween CAN model and data

wmm=.08; %webber frac
sp=[42 35];%speed 42 and 35 for w/o and w LM models
filename=(['int_5lms_60deg_wm' num2str(wmm*100) '_vb' num2str(sp(1)) '_' num2str(sp(2)) '_run1']);
cd(cp.modeldatafolder)
load(filename)

suffix = 'wLM'; %'wLM';
if strcmp(suffix, 'woLM')
    NN=NNwo; 
else
    NN=NNw; 
end

nn_xcorr=35:345;45:285;105:135; %analyse a group of neurons whose phases span half of single landmark interval to avoid harmonics
maxlag=10000;     %lag to compute xcorr over
tt=(find(NN.nn_state>nn_xcorr(1),1)):1:(find(NN.nn_state>nn_xcorr(end),1));
xxi=-maxlag:maxlag;

hxcorr=figure('Position',[741    99   831   950]);

 clear xcorr_pair
ii=1;
for nn=nn_xcorr
    for mm=(nn+1):nn_xcorr(end)
        xcorr_pair(ii,:)=xcorr(NN.grid_statesR(nn,tt)',NN.grid_statesR(mm,tt)',maxlag,'coeff');
        [~,phase]=max(xcorr_pair(ii,:));
        peakphasepair(ii)=xxi(phase);
         

        ii=ii+1;
    end
    nn
end
  
subplot(3,3,2);
[maxval,maxidx]= max(xcorr_pair,[],2);
model_phase_distribution=xxi(maxidx);
histogram(model_phase_distribution,25)
[~,sortid] = sort(maxidx);
xlim([-10000 10000]);xlabel 'peak phase'; ylabel '#all cell pairs'
addline([-6500 6500],'color','k');
addline(0,'color','r');
set(gca,'XTick',[-6500 0 6500],'XTickLabel',[-.65 0 .65])
title 'Original Phase'

subplot(3,3,3);
imagesc(-maxlag:maxlag,1:ii-1,xcorr_pair(sortid,:));
addline(0,'color','r');
xlabel 'lag'; 
ylabel 'cell pairs'
addline([-6500 6500],'color','k');
title model
set(gca,'XTick',[-6500 0 6500],'XTickLabel',[-.65 0 .65])
caxis([-.1 .1])

subplot(3,3,1);
model_phase_distribution_ori=model_phase_distribution;
model_phase_distribution(model_phase_distribution<-6500/2)=model_phase_distribution(model_phase_distribution<-6500/2)+6500;
model_phase_distribution(model_phase_distribution>6500/2)=model_phase_distribution(model_phase_distribution>6500/2)-6500;
histogram(model_phase_distribution,25)
xlim([-10000 10000]);xlabel 'peak phase'; ylabel '#all cell pairs'
addline([-6500 6500],'color','k');
addline(0,'color','r');
set(gca,'XTick',[-6500 0 6500],'XTickLabel',[-.65 0 .65])
title 'Phase wrapped'
model_ph_wr=model_phase_distribution;

% neural data:
caxislim=[-.2 .2];
params.area='EC';
params.animal = 'amadeus';
cd(cp.datafolder)
load([params.animal '_' params.area 'xcorr_top25_contexts.mat'],'xcorr_contexts','xcorr_contexts_nonperiodic')
load([cp.datafolder '/' params.animal '_' params.area '_sessions.mat'], 'sessions')
ss=5;

xx=-xcorr_contexts{ss}.maxlag:xcorr_contexts{ss}.maxlag;
[maxval,maxidx]= max(xcorr_contexts{ss}.xycorr1,[],2);

[~,sortid] = sort(maxidx);
maxval=maxval(sortid);
sortid(isnan(maxval))=[];

subplot(3,3,6);imagesc(xx,1:size(xcorr_contexts{ss}.xycorrr(sortid,:),1),xcorr_contexts{ss}.xycorrr(sortid,:));
title ([params.animal ' data']);
addline([-650 650],'color','k');caxis([-.1 .1])
addline(0,'color','r');
set(gca,'XTick',[-650 0 650],'XTickLabel',[-.65 0 .65])

subplot(3,3,5);
[maxval,maxidx]= max(xcorr_contexts{ss}.xycorrr(sortid,:),[],2);
ama_phase_distribution=xx(maxidx);
histogram(ama_phase_distribution,25)
xlabel 'peak phase'; ylabel '#all cell pairs'
xlim([-1000 1000]);
addline([-650 650],'color','k');caxis([-.1 .1])
addline(0,'color','r');
set(gca,'XTick',[-650 0 650],'XTickLabel',[-.65 0 .65])

subplot(3,3,4);
model_phase_distribution=ama_phase_distribution;
model_phase_distribution(model_phase_distribution<-650/2)=model_phase_distribution(model_phase_distribution<-650/2)+650;
model_phase_distribution(model_phase_distribution>650/2)=model_phase_distribution(model_phase_distribution>650/2)-650;
histogram(model_phase_distribution,25)
xlabel 'peak phase'; ylabel '#all cell pairs'
xlim([-1000 1000]);
addline([-650 650],'color','k');caxis([-.1 .1])
addline(0,'color','r');
set(gca,'XTick',[-650 0 650],'XTickLabel',[-.65 0 .65])
ama_ph_wr=model_phase_distribution;


params.area='EC';
params.animal = 'mahler';
cd(cp.datafolder)
load([params.animal '_' params.area 'xcorr_top25_contexts.mat'],'xcorr_contexts','xcorr_contexts_nonperiodic')
load([cp.datafolder '/' params.animal '_' params.area '_sessions.mat'], 'sessions')
ss=1;

xx=-xcorr_contexts{ss}.maxlag:xcorr_contexts{ss}.maxlag;

    [maxval,maxidx]= max(xcorr_contexts{ss}.xycorr1,[],2);

[~,sortid] = sort(maxidx);
maxval=maxval(sortid);
sortid(isnan(maxval))=[];

subplot(3,3,9);imagesc(xx,1:size(xcorr_contexts{ss}.xycorr1(sortid,:),1),xcorr_contexts{ss}.xycorr1(sortid,:));
title ([params.animal ' data']);
addline([-650 650],'color','k');caxis([-.1 .1])
addline(0,'color','r');
set(gca,'XTick',[-650 0 650],'XTickLabel',[-.65 0 .65])

subplot(3,3,8);
[maxval,maxidx]= max(xcorr_contexts{ss}.xycorr1(sortid,:),[],2);
mahler_phase_distribution=xx(maxidx);
histogram(mahler_phase_distribution,25)
xlabel 'peak phase'; ylabel '#all cell pairs'
xlim([-1000 1000]);
addline([-650 650],'color','k');caxis([-.1 .1])
addline(0,'color','r');
set(gca,'XTick',[-650 0 650],'XTickLabel',[-.65 0 .65])

subplot(3,3,7);
model_phase_distribution=mahler_phase_distribution;
model_phase_distribution(model_phase_distribution<-650/2)=model_phase_distribution(model_phase_distribution<-650/2)+650;
model_phase_distribution(model_phase_distribution>650/2)=model_phase_distribution(model_phase_distribution>650/2)-650;
histogram(model_phase_distribution,25)
xlabel 'peak phase'; ylabel '#all cell pairs'
xlim([-1000 1000]);
addline([-650 650],'color','k');caxis([-.1 .1])
addline(0,'color','r');
set(gca,'XTick',[-650 0 650],'XTickLabel',[-.65 0 .65])
mahler_ph_wr=model_phase_distribution;

% [h,p,stats]=kstest2(mahler_ph_wr,model_ph_wr)
% [h,p,stats]=kstest2(ama_ph_wr,model_ph_wr)

cd(cp.savedir_)
sgtitle ('Model vs data xcorr comparison')
hxcorr.Renderer='Painters';
saveas(hxcorr,'FigS8_Model_vs_data xcorr_comparison_mostNeurons','epsc');

CAN_reset_model_xcorr_peak_phase=model_phase_distribution_ori'/10000;
T=table(CAN_reset_model_xcorr_peak_phase);
writetable(T,['FigS8.xlsx'],'Sheet','fig_S8x')

monkey_A_EC_xcorr_peak_phase=ama_phase_distribution'/1000;
T=table(monkey_A_EC_xcorr_peak_phase);
writetable(T,['FigS8.xlsx'],'Sheet','fig_S8x','Range','B1')

monkey_M_EC_xcorr_peak_phase=mahler_phase_distribution'/1000;
T=table(monkey_M_EC_xcorr_peak_phase);
writetable(T,['FigS8.xlsx'],'Sheet','fig_S8x','Range','C1')


%% functions:

%===functions for xcorr analysis and plots===:
function xcorr_out = get_xcorr(param,sessions,ss,celltype,cp)
nSTD=2;

load([cp.datafolder_fig2 '/'...
    params.animal '_' params.area '_periodicity_js_leftright_dist345_seq12.mat'], 'gridness','params')

cd(cp.datafolder_fig2);
load('gp_sim_gridnessGP100ms_detrended.mat')

params.gridlag=gridlag;
params.null_gridness=gp_95pcnull_gridness;
params.null_gridness_tlag_abovemean_bb=gridness_tlag_abovemean_bb;
params.gridness_thres_pc_abov_mean =  max(mean(params.null_gridness_tlag_abovemean_bb,1)+nSTD*std(params.null_gridness_tlag_abovemean_bb,[],1));%0.1576;%.3276; %2 STD FDR. This number comes from simulation of 1000 Gaussian Process smooth time courses.
params.null_pc_above_mean_gridness=pc_above_mean_gridness;


params.smooth='gauss'; %or 'boxcar'
params.gauss_smooth=.2; %   smoothing window for psth
params.gauss_std = .1;   %   std of gaussian filter if gaussian
params.gauss_smoothing_kern = fspecial('gaussian',[1 params.gauss_smooth/params.binwidth],params.gauss_std/params.binwidth);
params.beff=params.bef+params.gauss_smooth*2; %to remove edge effect of filters, take extra 2*gaussian_filter_size and remove those time points after filtering
params.aftt=params.aft+params.gauss_smooth*2;
params.window_edge_effect = params.gauss_smooth*2/params.binwidth:(length(params.edges)-params.gauss_smooth*2/params.binwidth);
params.edges_rev = params.edges(params.window_edge_effect);
maxlag=1200;



cd ([params.mtt_folder '/' param.filename '.mwk'])
varlist=matfile([sessions{ss} '_neur_tensor_joyon']);
cond_label=varlist.cond_label;
cond_matrix=varlist.cond_matrix;
for ii=1:length(cond_label)
    eval(['params.' cond_label{ii} '=cond_matrix(:,strcmp(cond_label, cond_label{ii} ));']);
end
params.dist_conditions = abs(params.target-params.curr);
params.dir_condition = sign(params.ta);
data_tensor = varlist.neur_tensor_joyon(:,:,:);
temp=varlist.joyon;
params.binwidth=temp.binwidth;
params.bef=temp.bef;
params.aft=temp.aft;
params.edges=temp.edges;
cd ([param.mtt_folderspo '/' param.filename '.mwk'])
varlist=matfile([sessions{ss} '_neur_tensor_spont']);
data_tensor_spont = varlist.neur_tensor_spont(:,:,:);
params.spont_duration = varlist.spont_duration;
params.spont = varlist.spont;
params.spont.window_edge_effect = params.gauss_smooth*2/params.binwidth:(length(params.spont.edges)-params.gauss_smooth*2/params.binwidth);
params.spont.edges_rev = params.spont.edges(params.spont.window_edge_effect);

varlist=matfile([sessions{ss} '_neur_tensor_stim1on']);
data_tensor_stim1on = varlist.neur_tensor_stim1on(:,:,:);
params.stim1on = varlist.stim1on;
stim1onedges = varlist.stim1on;
params.window_edge_effect_stim1on = params.gauss_smooth*2/params.binwidth:(length(stim1onedges.edges)-params.gauss_smooth*2/params.binwidth);
params.edges_revstim1on = stim1onedges.edges(params.window_edge_effect_stim1on);


% context_type
%trials for seq1:
trseq1= find(params.attempt'==1 & abs(params.dist_conditions')>3 & params.trial_type'==3 & params.seqq'==1 & abs(params.tp')>1);
%trials for seq2:
trseq2= find(params.attempt'==1 & abs(params.dist_conditions')>3 & params.trial_type'==3 & params.seqq'==2 & abs(params.tp')>1);
%trials for ITI:
spont_trials= find(params.spont_duration'>params.spontdur_iti_thres );%pool trials from iti when iti dur is > threshold (4sec)
%visual trials:
visual_trials = find(params.attempt'==1 & abs(params.dist_conditions')>3 & params.trial_type'<3 & params.seqq'<3 & abs(params.tp')>1);
%joystick left trials:
left_trials = find(params.attempt'==1 & params.dir_condition'==1 & abs(params.dist_conditions')>3 & params.trial_type'==3 & params.seqq'<3 & abs(params.tp')>1);
%joystick right trials:
right_trials = find(params.attempt'==1 & params.dir_condition'==-1 & abs(params.dist_conditions')>3 & params.trial_type'==3 & params.seqq'<3 & abs(params.tp')>1);
%error trials:
error_trials = find(params.attempt'>1 & abs(params.dist_conditions')>3 & params.trial_type'==3 & params.seqq'<3 & abs(params.tp')>1);

[gridness_sorted,sorted_gridcellsxcorr]=sort(gridness{ss,2}.pc_above_mean_gridness,'descend');

switch celltype
    case 'periodic'
%         sorted_gridcells=sorted_gridcellsxcorr(1:find(gridness_sorted<params.gridness_thres_pc_abov_mean,1)-1);
        sorted_gridcells=sorted_gridcellsxcorr(1:25);
    case 'nonperiodic'
        sorted_gridcells=sorted_gridcellsxcorr(find(gridness_sorted<params.gridness_thres_pc_abov_mean,1):end);
        
end

params.celltype=celltype;

ii=1;jj=1;
for nn=1:length(sorted_gridcells)
    for mm=(nn+1):length(sorted_gridcells)
        
        %seq1 trials
        trials1 = trseq1;
        spktr1=squeeze(data_tensor(sorted_gridcells(nn),:,trials1));
        spktr2=squeeze(data_tensor(sorted_gridcells(mm),:,trials1));
        trcount=1;
        tempxcorr1=nan(maxlag*2+1,max(1,length(trials1)));
        for tr=1:length(trials1)
            time_start=-0;
              time_end=abs(params.tp(trials1(tr)))-params.cutoff_acg ;
            tt = find(params.edges_rev>time_start & params.edges_rev<time_end);
            
            temp=conv(spktr1(:,tr),params.gauss_smoothing_kern,'same');
            temp=temp(params.window_edge_effect,:);
            xx1=temp(tt,:)';
            mdl=fitlm(1:length(xx1),xx1);
            xx1=xx1-mdl.Coefficients.Estimate(2)*(1:length(xx1));
            
            
            temp=conv(spktr2(:,tr),params.gauss_smoothing_kern,'same');
            temp=temp(params.window_edge_effect,:);
            xx2=temp(tt,:)';
            mdl=fitlm(1:length(xx2),xx2);
            xx2=xx2-mdl.Coefficients.Estimate(2)*(1:length(xx2));
            
            
            
            tempxcorr1(:,trcount)=xcorr(xx1-nanmean(xx1),xx2-nanmean(xx2),maxlag,'coeff');
            trcount=trcount+1;
            
        end
        xcorr_out.xycorr1(ii,:) = nanmean(tempxcorr1,2);
        
        %seq1 trials inference period
        trials1 = trseq1;
        spktr1=squeeze(data_tensor_stim1on(sorted_gridcells(nn),:,trials1));
        spktr2=squeeze(data_tensor_stim1on(sorted_gridcells(mm),:,trials1));
        trcount=1;
        tempxcorrinf=nan(maxlag*2+1,max(1,length(trials1)));
        for tr=1:length(trials1)
            time_start=-.2;
            time_end=1.2 ;
            tt = find(params.edges_revstim1on>time_start & params.edges_revstim1on<time_end);
            
            temp=conv(spktr1(:,tr),params.gauss_smoothing_kern,'same');
            temp=temp(params.window_edge_effect_stim1on,:);
            xx1=temp(tt,:)';
            mdl=fitlm(1:length(xx1),xx1);
            xx1=xx1-mdl.Coefficients.Estimate(2)*(1:length(xx1));
            
            
            temp=conv(spktr2(:,tr),params.gauss_smoothing_kern,'same');
            temp=temp(params.window_edge_effect_stim1on,:);
            xx2=temp(tt,:)';
            mdl=fitlm(1:length(xx2),xx2);
            xx2=xx2-mdl.Coefficients.Estimate(2)*(1:length(xx2));
            
            
            
            tempxcorrinf(:,trcount)=xcorr(xx1-nanmean(xx1),xx2-nanmean(xx2),maxlag,'coeff');
            trcount=trcount+1;
            
        end
        xcorr_out.xycorrinf(ii,:) = nanmean(tempxcorrinf,2);
        
        %seq2 trials
        trials2 = trseq2;
        spktr1=squeeze(data_tensor(sorted_gridcells(nn),:,trials2));
        spktr2=squeeze(data_tensor(sorted_gridcells(mm),:,trials2));
        trcount=1;
        tempxcorr2=nan(maxlag*2+1,max(1,length(trials2)));
        for tr=1:length(trials2)
            
            time_start=0;
            time_end=abs(params.tp(trials2(tr)))-params.cutoff_acg ;
            tt = find(params.edges_rev>time_start & params.edges_rev<time_end);
            
            temp=conv(spktr1(:,tr),params.gauss_smoothing_kern,'same');
            temp=temp(params.window_edge_effect,:);
            xx1=temp(tt,:)';
            mdl=fitlm(1:length(xx1),xx1);
            xx1=xx1-mdl.Coefficients.Estimate(2)*(1:length(xx1));
            
            
            temp=conv(spktr2(:,tr),params.gauss_smoothing_kern,'same');
            temp=temp(params.window_edge_effect,:);
            xx2=temp(tt,:)';
            mdl=fitlm(1:length(xx2),xx2);
            xx2=xx2-mdl.Coefficients.Estimate(2)*(1:length(xx2));
            
            
            tempxcorr2(:,trcount)=xcorr(xx1-nanmean(xx1),xx2-nanmean(xx2),maxlag,'coeff');
            trcount=trcount+1;
            
        end
        xcorr_out.xycorr2(ii,:) = nanmean(tempxcorr2,2);
        
        %ITI trials
        spktr1=squeeze(data_tensor_spont(sorted_gridcells(nn),:,spont_trials));
        spktr2=squeeze(data_tensor_spont(sorted_gridcells(mm),:,spont_trials));
        trcount=1;
        tempxcorrs=nan(maxlag*2+1,max(1,length(spont_trials)));
        for tr=1:length(spont_trials)
            
            
            time_start = -params.spontdur_iti_thres;
            time_end = -params.spontdur_iti_thres+3;
            
            tt = find(params.spont.edges_rev>time_start & params.spont.edges_rev<time_end);
            
            temp=conv(spktr1(:,tr),params.gauss_smoothing_kern,'same');
            temp=temp(params.spont.window_edge_effect,:);
            xx1=temp(tt,:)';
            mdl=fitlm(1:length(xx1),xx1);
            xx1=xx1-mdl.Coefficients.Estimate(2)*(1:length(xx1));
            
            
            temp=conv(spktr2(:,tr),params.gauss_smoothing_kern,'same');
            temp=temp(params.spont.window_edge_effect,:);
            xx2=temp(tt,:)';
            mdl=fitlm(1:length(xx2),xx2);
            xx2=xx2-mdl.Coefficients.Estimate(2)*(1:length(xx2));
            
            
            
            tempxcorrs(:,trcount)=xcorr(xx1-nanmean(xx1),xx2-nanmean(xx2),maxlag,'coeff');
            trcount=trcount+1;
            
        end
        xcorr_out.xycorrs(ii,:) = nanmean(tempxcorrs,2);
        
        %visual trials:
        trials2 = visual_trials;
        spktr1=squeeze(data_tensor(sorted_gridcells(nn),:,trials2));
        spktr2=squeeze(data_tensor(sorted_gridcells(mm),:,trials2));
        trcount=1;
        tempxcorrv=nan(maxlag*2+1,max(1,length(trials2)));
        for tr=1:length(trials2)
            
            time_start=0;
            time_end=abs(params.tp(trials2(tr)))-params.cutoff_acg ;
            tt = find(params.edges_rev>time_start & params.edges_rev<time_end);
            
            temp=conv(spktr1(:,tr),params.gauss_smoothing_kern,'same');
            temp=temp(params.window_edge_effect,:);
            xx1=temp(tt,:)';
            mdl=fitlm(1:length(xx1),xx1);
            xx1=xx1-mdl.Coefficients.Estimate(2)*(1:length(xx1));
            
            
            temp=conv(spktr2(:,tr),params.gauss_smoothing_kern,'same');
            temp=temp(params.window_edge_effect,:);
            xx2=temp(tt,:)';
            mdl=fitlm(1:length(xx2),xx2);
            xx2=xx2-mdl.Coefficients.Estimate(2)*(1:length(xx2));
            
            
            tempxcorrv(:,trcount)=xcorr(xx1-nanmean(xx1),xx2-nanmean(xx2),maxlag,'coeff');
            trcount=trcount+1;
            
        end
        xcorr_out.xycorrv(ii,:) = nanmean(tempxcorrv,2);
        
        %left trials marginalize across seq
        trials1 = left_trials;
        spktr1=squeeze(data_tensor(sorted_gridcells(nn),:,trials1));
        spktr2=squeeze(data_tensor(sorted_gridcells(mm),:,trials1));
        trcount=1;
        tempxcorrl=nan(maxlag*2+1,max(1,length(trials1)));
        for tr=1:length(trials1)
            time_start=0;
            time_end=abs(params.tp(trials1(tr)))-params.cutoff_acg ;
            tt = find(params.edges_rev>time_start & params.edges_rev<time_end);
            
            temp=conv(spktr1(:,tr),params.gauss_smoothing_kern,'same');
            temp=temp(params.window_edge_effect,:);
            xx1=temp(tt,:)';
            mdl=fitlm(1:length(xx1),xx1);
            xx1=xx1-mdl.Coefficients.Estimate(2)*(1:length(xx1));
            
            
            temp=conv(spktr2(:,tr),params.gauss_smoothing_kern,'same');
            temp=temp(params.window_edge_effect,:);
            xx2=temp(tt,:)';
            mdl=fitlm(1:length(xx2),xx2);
            xx2=xx2-mdl.Coefficients.Estimate(2)*(1:length(xx2));
            
            
            
            tempxcorrl(:,trcount)=xcorr(xx1-nanmean(xx1),xx2-nanmean(xx2),maxlag,'coeff');
            trcount=trcount+1;
            
        end
        xcorr_out.xycorrl(ii,:) = nanmean(tempxcorrl,2);
        
        %right trials marg across seq
        trials1 = right_trials;
        spktr1=squeeze(data_tensor(sorted_gridcells(nn),:,trials1));
        spktr2=squeeze(data_tensor(sorted_gridcells(mm),:,trials1));
        trcount=1;
        tempxcorrr=nan(maxlag*2+1,max(1,length(trials1)));
        for tr=1:length(trials1)
            time_start=0;
            time_end=abs(params.tp(trials1(tr)))-params.cutoff_acg ;
            tt = find(params.edges_rev>time_start & params.edges_rev<time_end);
            
            temp=conv(spktr1(:,tr),params.gauss_smoothing_kern,'same');
            temp=temp(params.window_edge_effect,:);
            xx1=temp(tt,:)';
            mdl=fitlm(1:length(xx1),xx1);
            xx1=xx1-mdl.Coefficients.Estimate(2)*(1:length(xx1));
            
            
            temp=conv(spktr2(:,tr),params.gauss_smoothing_kern,'same');
            temp=temp(params.window_edge_effect,:);
            xx2=temp(tt,:)';
            mdl=fitlm(1:length(xx2),xx2);
            xx2=xx2-mdl.Coefficients.Estimate(2)*(1:length(xx2));
            
            
            
            tempxcorrr(:,trcount)=xcorr(xx1-nanmean(xx1),xx2-nanmean(xx2),maxlag,'coeff');
            trcount=trcount+1;
            
        end
        xcorr_out.xycorrr(ii,:) = nanmean(tempxcorrr,2);
        
        %error trials
        trials1 = error_trials;
        spktr1=squeeze(data_tensor(sorted_gridcells(nn),:,trials1));
        spktr2=squeeze(data_tensor(sorted_gridcells(mm),:,trials1));
        trcount=1;
        tempxcorrerr=nan(maxlag*2+1,max(1,length(trials1)));
        for tr=1:length(trials1)
            time_start=0;
            time_end=abs(params.tp(trials1(tr)))-params.cutoff_acg ;
            tt = find(params.edges_rev>time_start & params.edges_rev<time_end);
            
            temp=conv(spktr1(:,tr),params.gauss_smoothing_kern,'same');
            temp=temp(params.window_edge_effect,:);
            xx1=temp(tt,:)';
            mdl=fitlm(1:length(xx1),xx1);
            xx1=xx1-mdl.Coefficients.Estimate(2)*(1:length(xx1));
            
            
            temp=conv(spktr2(:,tr),params.gauss_smoothing_kern,'same');
            temp=temp(params.window_edge_effect,:);
            xx2=temp(tt,:)';
            mdl=fitlm(1:length(xx2),xx2);
            xx2=xx2-mdl.Coefficients.Estimate(2)*(1:length(xx2));
            
            
            
            tempxcorrerr(:,trcount)=xcorr(xx1-nanmean(xx1),xx2-nanmean(xx2),maxlag,'coeff');
            trcount=trcount+1;
            
        end
        xcorr_out.xycorrerr(ii,:) = nanmean(tempxcorrerr,2);
        
        ii=ii+1
    end
end
xcorr_out.maxlag=maxlag;
xcorr_out.params=params;

end



function [T]=plot_5iterations(pvc,betasq,fr,titl,pre_corr_win,off_corr_win,honoff,hdistimg,htdr,htdr_bar,subplt,numbb)
rsqthres=0;

idx_pre = fr.edgespre>=pre_corr_win(1) & fr.edgespre<=pre_corr_win(2);
idx_off = fr.edgesoff>=off_corr_win(1) & fr.edgesoff<=off_corr_win(2);

for ch=1:size(betasq.betapre,1)


    temp=betasq.rsqpre(ch,idx_pre,:,1);temp=temp(:); temp((temp<-1) | isnan(temp))=[];
    rsqon(ch)=mean(temp);
    sigon(ch)= mean(temp)>rsqthres;


    temp=betasq.rsqoff(ch,idx_off,:,1);temp=temp(:); temp((temp<-1) | isnan(temp))=[];
    rsqoff(ch)=mean(temp);
    sigoff(ch)= mean(temp)>rsqthres;

    temp=betasq.rsqpre_sh(ch,idx_pre,:,1);temp=temp(:); temp((temp<-1) | isnan(temp))=[];
    rsqonsh(ch)=mean(temp);
    sigonsh(ch)= mean(temp)>rsqthres;

    temp=betasq.rsqoff_sh(ch,idx_off,:,1);temp=temp(:); temp((temp<-1) | isnan(temp))=[];
    rsqoffsh(ch)=mean(temp);
    sigoffsh(ch)= mean(temp)>rsqthres;


end
figure(honoff)
subplot(1,5,subplt);
idx_onoff=sigon==1 | sigoff==1;
% idx_onoff_periodic = (sigon==1 | sigoff==1) & periodic650==1;
scatter(rsqon(idx_onoff),rsqoff(idx_onoff),'ob','Filled');hold on;
% scatter(rsqon(idx_onoff_periodic),rsqoff(idx_onoff_periodic),'or','Filled');
scatter(rsqon(sigon==1 & sigoff==1),rsqoff(sigon==1 & sigoff==1),'ok','Filled');
scatter(rsqon(sigon==0 & sigoff==0),rsqoff(sigon==0 & sigoff==0),10,[.5 .5 .5],'Filled');
plot([-1 1],[-1 1],'-k');
title(titl);grid on;%axis([-.5 .5 -.5 .5])
xlabel 'onset'
ylabel 'offset rsq'

scatter(rsqonsh(sigoffsh==1),rsqoffsh(sigoffsh==1),70,'ob');hold on;
scatter(rsqonsh(sigonsh==1),rsqoffsh(sigonsh==1),70,'ob');
scatter(rsqonsh(sigonsh==1 & sigoffsh==1),rsqoffsh(sigonsh==1 & sigoffsh==1),70,'ok');
scatter(rsqonsh(sigonsh==0 & sigoffsh==0),rsqoffsh(sigonsh==0 & sigoffsh==0),15,[0 .5 .5],'Filled');
axis square

posR2_either_onset = rsqon(idx_onoff)';
posR2_either_offset = rsqoff(idx_onoff)';

posR2_both_onset = rsqon(sigon==1 & sigoff==1)';
posR2_both_offset = rsqoff(sigon==1 & sigoff==1)';

posR2_neither_onset = rsqon(sigon==0 & sigoff==0)';
posR2_neither_offset = rsqoff(sigon==0 & sigoff==0)';

rsqon=rsqon';rsqoff=rsqoff';
rsqon_shuffled=rsqonsh';rsqoff_shuffled=rsqoffsh';

T.R2all = table(rsqon, rsqoff ,rsqon_shuffled, rsqoff_shuffled);
% writetable(T,'Fig3.xlsx','Sheet','fig3b_left_monkA')

T.R2either = table(posR2_either_onset, posR2_either_offset);
% writetable(T,'Fig3.xlsx','Sheet','fig3b_left_monkA','Range','F1')

T.R2both = table(posR2_both_onset, posR2_both_offset);
% writetable(T,'Fig3.xlsx','Sheet','fig3b_left_monkA','Range','I1')

T.R2neither = table(posR2_neither_onset, posR2_neither_offset);
% writetable(T,'Fig3.xlsx','Sheet','fig3b_left_monkA','Range','L1')


if subplt==1
    %find distance invariance with n-way anova:
    neur_onordoff = find(sigoff==1 | sigon==1);
    neur_on = sigon==1;
    neur_off = sigoff==1;
    tton=1:13;

    n=1;
    for nn=1:length(fr.froffsetim)%neur_onordoff
        y=[];ymean=[];    yoff=[];ymeanoff=[];
        yramp=[];yramppval=[]; yrampoff=[];yramppvaloff=[];
        diron=[];diston=[];cimgon=[];timgon=[];condon=[];
        diroff=[];distoff=[];cimgoff=[];timgoff=[];condoff=[];
        dirmean=[];distmean=[];cimgmean=[];timgmean=[];condmean=[];

        frateoff=fr.froffsetim{nn};
        frateon=fr.frpreim{nn};

        %         frslopeoff=fr.froffset{nn};
        %         frslopeon=fr.fronset{nn};
        %         frslopeoff2=fr.froffset2{nn};
        %         frslopeon2=fr.fronset2{nn};

        skipneuron=0;
        for dd=1:30

            if isempty(frateoff),skipneuron=1;break;end

            temp=frateoff{dd};
            if isnan(temp),skipneuron=1;break;end
            temp=frateoff{dd}(:,end-tton(end-1):end-1);
            meanfroff{dd}=mean(temp(:,idx_off),2);


            yoff = [yoff; meanfroff{dd}];
            distoff = [distoff; fr.cond_ctd(dd,3)*ones(length(meanfroff{dd}),1)];
            diroff = [diroff; sign(fr.cond_ctd(dd,3))*ones(length(meanfroff{dd}),1)];
            cimgoff = [cimgoff; fr.cond_ctd(dd,1)*ones(length(meanfroff{dd}),1)];
            timgoff = [timgoff; fr.cond_ctd(dd,2)*ones(length(meanfroff{dd}),1)];
            condoff = [condoff; dd*ones(length(meanfroff{dd}),1)];

            ymeanoff = [ymeanoff; mean(meanfroff{dd}) ];


            temp=frateon{dd}(:,tton);
            meanfron{dd}=mean(temp(:,idx_off),2);



            y = [y; meanfron{dd}]; %predicted vaue is FR
            %             regressors:
            diston = [diston; fr.cond_ctd(dd,3)*ones(length(meanfron{dd}),1)];
            diron = [diron; sign(fr.cond_ctd(dd,3))*ones(length(meanfron{dd}),1)];
            cimgon = [cimgon; fr.cond_ctd(dd,1)*ones(length(meanfron{dd}),1)];
            timgon = [timgon; fr.cond_ctd(dd,2)*ones(length(meanfron{dd}),1)];
            condon = [condon; dd*ones(length(meanfron{dd}),1)];


            %mean over trials
            ymean = [ymean mean(meanfron{dd})];
            distmean = [distmean; fr.cond_ctd(dd,3)];
            dirmean = [dirmean; sign(fr.cond_ctd(dd,3))];
            cimgmean = [cimgmean; fr.cond_ctd(dd,1)];
            timgmean = [timgmean; fr.cond_ctd(dd,2)];
            condmean = [condmean; dd];

        end



        if skipneuron==1,continue;end


        [pval,tbl] = anovan(yoff,{abs(distoff),cimgoff,timgoff,diroff},'display','off');
        poff(n,:)=pval;
        foff(n,:)=cell2mat(tbl(2:5,6));

        [pval,tbl] = anovan(y,{abs(diston),cimgon,timgon,diron},'display','off');
        pon(n,:)=pval;
        fon(n,:)=cell2mat(tbl(2:5,6));




        n=n+1;

    end

    lim=25;
    figure(hdistimg)
    subplot(4,5,subplt);

    %offset:
    %start image vs dist
    signn = find(poff(:,1)<.05 | poff(:,2)<.05)';
    signnboth = find(poff(:,1)<.05 & poff(:,2)<.05 )';
    signnimg = find(poff(:,1)>=.05 & poff(:,2)<.05 )';
    signndist = find(poff(:,1)<.05 & poff(:,2)>=.05 )';
    signnnone = find(poff(:,1)>=.05 & poff(:,2)>=.05 )';

    scatter(foff(signnboth,1),foff(signnboth,2),20,[0 0 0],'Filled');hold on;
    scatter(foff(signnimg,1),foff(signnimg,2),20,[1 0 0],'Filled');
    scatter(foff(signndist,1),foff(signndist,2),20,[0 0 1],'Filled');
    scatter(foff(signnnone,1),foff(signnnone,2),10,[0.5 0.5 0.5],'Filled');
    %     scatter(foff(signn,1),foff(signn,2),20,'Filled');hold on; %dist only
    plot([0 lim],[0 lim],'-k');axis([0 lim 0 lim])
    xlabel 'F-stat dist encoding';grid on;axis square;
    ylabel 'F-stat start landmark encoding'
    title (['offset, n=' num2str(length(signn))])
    xx=foff(signn,1)-foff(signn,2);
    [h,pval]=ttest(xx);
    subplot(4,5,subplt+5);
    histogram(xx,[-lim/2:1:lim/2]);addline(0);
    title(pval)

    F_stat_dist=foff(:,1);F_stat_start_LM=foff(:,2);F_stat_target_LM=foff(:,3);
    p_val_dist=poff(:,1);p_val_start_LM=poff(:,2);p_val_target_LM=poff(:,3);
    
    histo_dist_start = xx;
    hist_edges=(-lim/2:1:lim/2)';


T.Fstat_start = table(F_stat_dist, F_stat_start_LM ,p_val_dist, p_val_start_LM);
T.histo_dist_start = table(histo_dist_start);
T.hist_edges = table(hist_edges); 



    %offset: target image vs dist
    signn = find(poff(:,1)<.05 | poff(:,3)<.05)';
    subplot(4,5,subplt+10);
    signnboth = find(poff(:,1)<.05 & poff(:,3)<.05 )';
    signnimg = find(poff(:,1)>=.05 & poff(:,3)<.05 )';
    signndist = find(poff(:,1)<.05 & poff(:,3)>=.05 )';
    signnnone = find(poff(:,1)>=.05 & poff(:,3)>=.05 )';

    scatter(foff(signnboth,1),foff(signnboth,3),20,[0 0 0],'Filled');hold on;
    scatter(foff(signnimg,1),foff(signnimg,3),20,[1 0 0],'Filled');
    scatter(foff(signndist,1),foff(signndist,3),20,[0 0 1],'Filled');
    scatter(foff(signnnone,1),foff(signnnone,3),10,[0.5 0.5 0.5],'Filled');
    %     scatter(foff(signn,1),foff(signn,3),20,'Filled');hold on; plot([0 lim],[0 lim],'-k');axis([0 lim 0 lim])
    plot([0 lim],[0 lim],'-k');axis([0 lim 0 lim])
    xlabel 'F-stat dist encoding';grid on;axis square;
    ylabel 'F-stat target landmark encoding'
    title (['offset, n=' num2str(length(signn))])
    xx=foff(signn,1)-foff(signn,3);
    [h,pval]=ttest(xx);
    subplot(4,5,subplt+15);
    histogram(xx,[-lim/2:1:lim/2]);addline(0);
    title(pval)

    F_stat_target_LM=foff(:,3);
    p_val_target_LM=poff(:,3);
    histo_dist_target = xx;


    T.Fstat_target = table(F_stat_dist, F_stat_target_LM ,p_val_dist, p_val_target_LM);
    T.histo_dist_target = table(histo_dist_target);

%     writetable(T.Fstat_start,'FigS6.xlsx','Sheet','figS6b_top_monkA')
%     writetable(T.histo_dist_start,'FigS6.xlsx','Sheet','figS6b_top_monkA','Range','F1')
%     writetable(T.hist_edges,'FigS6.xlsx','Sheet','figS6b_top_monkA','Range','G1')
% 
%      writetable(T.Fstat_target,'FigS6.xlsx','Sheet','figS6c_top_monkA')
%     writetable(T.histo_dist_target,'FigS6.xlsx','Sheet','figS6c_top_monkA','Range','F1')
%     writetable(T.hist_edges,'FigS6.xlsx','Sheet','figS6c_top_monkA','Range','G1')
end

%  plot_tdr2(pvc,fr,subplt,titl,tton,pre_corr_win,off_corr_win,h1,h2,numbb)
hcol = myrgb(5,[1 0 0]);

idx_pre = fr.edgespre>=pre_corr_win(1) & fr.edgespre<=pre_corr_win(2);
idx_off = fr.edgesoff>=off_corr_win(1) & fr.edgesoff<=off_corr_win(2);

num_dist = size(pvc.pvcpre,2);
for dd=1:num_dist

    pre_val(dd,:)=squeeze(mean(pvc.pvcpre(idx_pre,dd,:),1));
    off_val(dd,:)=squeeze(mean(pvc.pvcoff(idx_off,dd,:),1));
end

figure(htdr)

subplot(2,5,subplt);
plot(1:num_dist,pre_val(:,:)','-','LineWidth',.3,'color',[.5 .5 .5]); grid on;hold on
errorbar(1:num_dist,mean(pre_val(:,:),2),std(pre_val(:,:),[],2)/sqrt(1),'-ok','LineWidth',1.5);  hold on;axis square
title(titl);set(gca,'XTick',1:5); xlim([0 6]);
ylabel onset

subplot(2,5,subplt+5);
plot(1:num_dist,off_val(:,:)','-','LineWidth',.3,'color',[.5 .5 .5]); grid on;hold on
errorbar(1:num_dist,mean(off_val(:,:),2),std(off_val(:,:),[],2)/sqrt(1),'-or','LineWidth',1.5);  hold on;axis square
title(titl);set(gca,'XTick',1:5); xlim([0 6]);
ylabel offset

T.onset_projections=[];
T.offset_projections=[];
for dd=1:num_dist
    eval(['onset_proj_dist' num2str(dd) '=pre_val(dd,:)'';']);
    eval(['offset_proj_dist' num2str(dd) '=off_val(dd,:)'';']);
    eval(['T.onset_projections = [T.onset_projections table(onset_proj_dist' num2str(dd) ')];'])
    eval(['T.offset_projections = [T.offset_projections table(offset_proj_dist' num2str(dd) ')];'])
end

onset_mean_proj=mean(pre_val(:,:),2);
onset_std_proj=std(pre_val(:,:),[],2);

offset_mean_proj=mean(off_val(:,:),2);
offset_std_proj=std(off_val(:,:),[],2);
img_distance = (1:num_dist)';

T.projections_mean_std = table(img_distance,onset_mean_proj,onset_std_proj,offset_mean_proj,offset_std_proj);


pre_off = cell(1,numbb);
for bb=1:numbb
    for dd=1:num_dist
        pre_off{bb}=[pre_off{bb}; [dd pre_val(dd,bb) off_val(dd,bb)]];
    end
    mdl=fitlm((1:num_dist)',pre_val(:,bb)');
    pre_corr(bb)=mdl.Rsquared.Adjusted;
    mdl=fitlm((1:num_dist)',off_val(:,bb));
    off_corr(bb)=mdl.Rsquared.Adjusted;
end

[pval,h,stats]=ranksum(pre_corr,off_corr,'method','approximate');
title (['z=' num2str(stats.zval) ', p=' num2str(pval)]);


figure(htdr_bar); 
bar(1:2,[mean(pre_corr) mean(off_corr)]); hold on
errorbar(1:2,[mean(pre_corr) mean(off_corr)],[std(pre_corr) std(off_corr)],'-ok','LineWidth',2);
[pval,h,stats]=ranksum(pre_corr,off_corr);
title ([titl(1:4) ', z=' num2str(stats.zval) ', p=' num2str(pval)]);set(gca,'Xtick',1:2,'XTickLabel',{'premov','offset'}); ylim([0 1.2])
ylabel 'Rsq'

epoch = {'onset';'offset'};
mean_linfit_R2 = [mean(pre_corr); mean(off_corr)];
std_linfit_R2 = [std(pre_corr); std(off_corr)];

T.TDR_lienar_fit = table(epoch,mean_linfit_R2,std_linfit_R2);
end

function [pvc_,betarsq_]=fit_tdr_axis(fr,tton,dir,numbb)
clear pvcpre pvcoffset pvconset
for bb=1:numbb
    ritpre = cell(1,length(fr.ssn)); Fabsdist=ritpre;ritonset=ritpre;ritoffset=ritpre;
    ritpretest = cell(1,length(fr.ssn)); Fabsdisttest=ritpre;ritonsettest=ritpre;ritoffsettest=ritpre;

    clear Xx_train_pre Xx_test_pre Xx_train_onset Xx_test_offset Xx_train_offset Xx_test_onset
    for nn=1:length(fr.ssn)
        for dd=1:5
            % if nn==255 && dd==2
            %     disp 'debug'
            % end
            switch dir
                case 1
                    numtr=fr.numtr(dd,nn);
                    numtr_smallest=min(fr.numtr(1:5,nn));

                    tr=randsample(numtr,numtr_smallest);
                    test=tr(1:floor(numtr_smallest/2));
                    train=tr((1+floor(numtr_smallest/2)):end);


                    ritpre{nn} = [ritpre{nn}; fr.frpre{nn}{dd}(train,tton)];
                    ritonset{nn} = [ritonset{nn}; fr.fronset{nn}{dd}(train,tton)];
                    ritoffset{nn} = [ritoffset{nn}; fr.froffset{nn}{dd}(train,end-tton(end):end-1)];
                    Fabsdist{nn} = [Fabsdist{nn}  dd*ones(1,length(train))];%distance regressor

                    ritpretest{nn} = [ritpretest{nn}; fr.frpre{nn}{dd}(test,tton)];
                    ritonsettest{nn} = [ritonsettest{nn}; fr.fronset{nn}{dd}(test,tton)];
                    ritoffsettest{nn} = [ritoffsettest{nn}; fr.froffset{nn}{dd}(test,end-tton(end):end-1)];
                    Fabsdisttest{nn} = [Fabsdisttest{nn}  dd*ones(1,length(test))];%distance regressor


                    Xx_train_pre(nn,:,dd)=mean(fr.frpre{nn}{dd}(train,tton),1);
                    Xx_test_pre(nn,:,dd)=mean(fr.frpre{nn}{dd}(test,tton),1);

                    Xx_train_onset(nn,:,dd)=mean(fr.fronset{nn}{dd}(train,tton),1);
                    Xx_test_onset(nn,:,dd)=mean(fr.fronset{nn}{dd}(test,tton),1);

                    Xx_train_offset(nn,:,dd)=mean(fr.froffset{nn}{dd}(train,end-tton(end):end-1),1);
                    Xx_test_offset(nn,:,dd)=mean(fr.froffset{nn}{dd}(test,end-tton(end):end-1),1);

                    Xx_slope_offset(nn,:,dd)=mean(fr.froffset{nn}{dd}(:,end-tton(end):end-4),1);%take -550 to 350ms before js offset
                    Xx_slope_onset(nn,:,dd)=mean(fr.fronset{nn}{dd}(:,4:tton(end),1),1);%take 100 to 450ms after js onset

                case 2
                    numtr=fr.numtr2(dd,nn);
                    tr=1:numtr;
                    train=randperm(numtr,ceil(numtr/2));
                    test = tr(~ismember(tr,train));


                    ritpre{nn} = [ritpre{nn}; fr.frpre2{nn}{dd}(train,tton)];
                    ritonset{nn} = [ritonset{nn}; fr.fronset2{nn}{dd}(train,tton)];
                    ritoffset{nn} = [ritoffset{nn}; fr.froffset2{nn}{dd}(train,end-tton(end):end-1)];
                    Fabsdist{nn} = [Fabsdist{nn}  dd*ones(1,length(train))];%distance regressor

                    %                     ritpretest{nn} = [ritpretest{nn}; fr.frpre2{nn}{dd}(test,tton)];
                    %                     ritonsettest{nn} = [ritonsettest{nn}; fr.fronset2{nn}{dd}(test,tton)];
                    %                     ritoffsettest{nn} = [ritoffsettest{nn}; fr.froffset2{nn}{dd}(test,end-tton(end):end-1)];
                    %                     Fabsdisttest{nn} = [Fabsdisttest{nn}  dd*ones(1,length(test))];%distance regressor


                    Xx_train_pre(nn,:,dd)=mean(fr.frpre2{nn}{dd}(train,tton),1);
                    Xx_test_pre(nn,:,dd)=mean(fr.frpre2{nn}{dd}(test,tton),1);

                    Xx_train_onset(nn,:,dd)=mean(fr.fronset2{nn}{dd}(train,tton),1);
                    Xx_test_onset(nn,:,dd)=mean(fr.fronset2{nn}{dd}(test,tton),1);

                    Xx_train_offset(nn,:,dd)=mean(fr.froffset2{nn}{dd}(train,end-tton(end):end-1),1);
                    Xx_test_offset(nn,:,dd)=mean(fr.froffset2{nn}{dd}(test,end-tton(end):end-1),1);



            end
        end
    end

    meanfrpre = mean([Xx_train_pre(:,:) Xx_test_pre(:,:)],2);
    Xx_train_pre = Xx_train_pre(:,:)  - repmat(meanfrpre,[1 5*length(tton)]);
    Xx_test_pre = Xx_test_pre(:,:)  - repmat(meanfrpre,[1 5*length(tton)]);

    meanfron = mean([Xx_train_onset(:,:) Xx_test_onset(:,:)],2);
    Xx_train_onset = Xx_train_onset(:,:)  - repmat(meanfron,[1 5*length(tton)]);
    Xx_test_onset = Xx_test_onset(:,:)  - repmat(meanfron,[1 5*length(tton)]);

    meanfroff = mean([Xx_train_offset(:,:) Xx_test_offset(:,:)],2);
    Xx_train_offset = Xx_train_offset(:,:)  - repmat(meanfroff,[1 5*length(tton)]);
    Xx_test_offset = Xx_test_offset(:,:)  - repmat(meanfroff,[1 5*length(tton)]);



    %denoising data matrix using top PCs:
    [coeff,~,~,~,explained,~] = pca(Xx_train_pre');toppc=find(cumsum(explained)>80,1);
    Dpre = coeff(:,1:toppc)*coeff(:,1:toppc)';

    [coeff,~,~,~,explained,~] = pca(Xx_train_onset');toppc=find(cumsum(explained)>80,1);
    Donset = coeff(:,1:toppc)*coeff(:,1:toppc)';

    [coeff,~,~,~,explained,~] = pca(Xx_train_offset');toppc=find(cumsum(explained)>80,1);
    Doffset = coeff(:,1:toppc)*coeff(:,1:toppc)';

    clear Betapre Betaoffset Betaonset
    %get regression betas for each neuron and time point
    for time=1:size(ritpre{1},2)
        for  ch=1:length(ritpre)
            %design matrices for different regression models:
            F = [Fabsdist{ch};ones(1,length(Fabsdist{ch}))];%dist and direction
            Betapre(ch,time,:) = inv(F*F')*F*(ritpre{ch}(:,time)-meanfrpre(ch));%linear regression
            Betaonset(ch,time,:) = inv(F*F')*F*(ritonset{ch}(:,time) - meanfron(ch));%linear regression
            Betaoffset(ch,time,:) = inv(F*F')*F*(ritoffset{ch}(:,time) - meanfroff(ch));%linear regression


            frtrain = reshape(Xx_train_pre(ch,:),[13 5]);
            frtest = reshape(Xx_test_pre(ch,:),[13 5]);

            [betarsq_.betapre(ch,time,bb,:), betarsq_.rsqpre(ch,time,bb), betarsq_.rsqpre_sh(ch,time,bb)] ...
                =get_xval_vaf(frtrain(time,:),frtest(time,:));

            frtrain = reshape(Xx_train_offset(ch,:),[13 5]);
            frtest = reshape(Xx_test_offset(ch,:),[13 5]);

            [betarsq_.betaoff(ch,time,bb,:), betarsq_.rsqoff(ch,time,bb), betarsq_.rsqoff_sh(ch,time,bb)] ...
                =get_xval_vaf(frtrain(time,:),frtest(time,:));


        end
    end

    Bpcapre = Dpre*Betapre(:,:,1); %denoise with topPC PCs
    Bpcaonset = Donset*Betaonset(:,:,1);
    Bpcaoffset = Doffset*Betaoffset(:,:,1);


    % Find time point where each regression coefficient has maximum norm

    clear bnormpre bnormoffset bnormonset
    for tt=1:9
        bnormpre(tt) = norm(Bpcapre(:,tt));
        bnormonset(tt) = norm(Bpcaonset(:,tt));
        bnormoffset(tt) = norm(Bpcaoffset(:,tt));
    end
    [~,maxt]=max(bnormpre);Bmaxpre=Bpcapre(:,maxt);
    [~,maxt]=max(bnormonset);Bmaxonset=Bpcaonset(:,maxt);
    [~,maxt]=max(bnormoffset);Bmaxoffset=Bpcaoffset(:,maxt);



    %project average population activity of test data set onto orthogonal axes of regression
    pvcpre(:,:,bb) = reshape(Bmaxpre'*Xx_test_pre,[length(tton) 5]);
    pvconset(:,:,bb) = reshape(Bmaxonset'*Xx_test_onset,[length(tton) 5]);
    pvcoffset(:,:,bb) = reshape(Bmaxoffset'*Xx_test_offset,[length(tton) 5]);

    bb
end

pvc_.pvcpre=pvcpre;
pvc_.pvcon=pvconset;
pvc_.pvcoff=pvcoffset;


end

function [beta_, rsqxval_, rsqxval_sh]=get_xval_vaf(frtrain,frtest)%(Ftrain,frtrain,Ftest,frtest)

beta_= [1:length(frtrain); ones(1,length(frtrain))]'\frtrain';

frtesthat = beta_'*[1:length(frtrain); ones(1,length(frtrain))];

sse = sum((frtest-frtesthat).^2);
sstot= sum((frtest-mean(frtest)).^2);
ssm = sum((frtesthat'-mean(frtest)).^2);
rsqxval_ = 1 - sse/sstot;
fstat_ = (ssm/(2-1))/(sse/(length(frtest)-2));

randomized_regre=0;
while (randomized_regre==0)
    regressor=randperm(length(frtrain));
    if ~all(regressor==1:length(frtrain)), randomized_regre=1;end
end

beta_sh= [regressor; ones(1,length(frtrain))]'\frtrain';

frtesthat_sh = beta_'*[regressor; ones(1,length(frtrain))];

sse = sum((frtest-frtesthat_sh).^2);
sstot= sum((frtest-mean(frtest)).^2);
ssm = sum((frtesthat_sh'-mean(frtest)).^2);
rsqxval_sh = 1 - sse/sstot;
fstat_sh = (ssm/(2-1))/(sse/(length(frtest)-2));

end


function [pvc_,betarsq_]=fit_tdr_axis_wodist1(fr,tton,dir,numbb)
clear pvcpre pvcoffset pvconset
for bb=1:numbb
    ritpre = cell(1,length(fr.ssn)); Fabsdist=ritpre;ritonset=ritpre;ritoffset=ritpre;
    clear Xx_train_pre Xx_test_pre Xx_train_onset Xx_test_offset Xx_train_offset Xx_test_onset
    for nn=1:length(fr.ssn)
        ddi=0;
        for dd=2:5
            ddi=ddi+1;

            switch dir

                case 1
                    %                     numtr=fr.numtr(dd,nn);
                    %                     tr=1:numtr;
                    %                     train=randperm(numtr,ceil(numtr/2));
                    %                     test = tr(~ismember(tr,train));

                    numtr=fr.numtr(dd,nn);
                    numtr_smallest=min(fr.numtr(2:5,nn));

                    tr=randsample(numtr,numtr_smallest);
                    test=tr(1:floor(numtr_smallest/2));
                    train=tr((1+floor(numtr_smallest/2)):end);


                    ritpre{nn} = [ritpre{nn}; fr.frpre{nn}{dd}(train,tton)];
                    ritonset{nn} = [ritonset{nn}; fr.fronset{nn}{dd}(train,tton)];
                    ritoffset{nn} = [ritoffset{nn}; fr.froffset{nn}{dd}(train,end-tton(end):end-1)];
                    Fabsdist{nn} = [Fabsdist{nn}  dd*ones(1,length(train))];%distance regressor


                    Xx_train_pre(nn,:,ddi)=mean(fr.frpre{nn}{dd}(train,tton),1);
                    Xx_test_pre(nn,:,ddi)=mean(fr.frpre{nn}{dd}(test,tton),1);

                    Xx_train_onset(nn,:,ddi)=mean(fr.fronset{nn}{dd}(train,tton),1);
                    Xx_test_onset(nn,:,ddi)=mean(fr.fronset{nn}{dd}(test,tton),1);

                    Xx_train_offset(nn,:,ddi)=mean(fr.froffset{nn}{dd}(train,end-tton(end):end-1),1);
                    Xx_test_offset(nn,:,ddi)=mean(fr.froffset{nn}{dd}(test,end-tton(end):end-1),1);

                case 2

                    numtr=fr.numtr2(dd,nn);
                    tr=1:numtr;
                    train=randperm(numtr,ceil(numtr/2));
                    test = tr(~ismember(tr,train));


                    ritpre{nn} = [ritpre{nn}; fr.frpre2{nn}{dd}(train,tton)];
                    ritonset{nn} = [ritonset{nn}; fr.fronset2{nn}{dd}(train,tton)];
                    ritoffset{nn} = [ritoffset{nn}; fr.froffset2{nn}{dd}(train,end-tton(end):end-1)];
                    Fabsdist{nn} = [Fabsdist{nn}  dd*ones(1,length(train))];%distance regressor


                    Xx_train_pre(nn,:,ddi)=mean(fr.frpre2{nn}{dd}(train,tton),1);
                    Xx_test_pre(nn,:,ddi)=mean(fr.frpre2{nn}{dd}(test,tton),1);

                    Xx_train_onset(nn,:,ddi)=mean(fr.fronset2{nn}{dd}(train,tton),1);
                    Xx_test_onset(nn,:,ddi)=mean(fr.fronset2{nn}{dd}(test,tton),1);

                    Xx_train_offset(nn,:,ddi)=mean(fr.froffset2{nn}{dd}(train,end-tton(end):end-1),1);
                    Xx_test_offset(nn,:,ddi)=mean(fr.froffset2{nn}{dd}(test,end-tton(end):end-1),1);

            end

        end
    end

    meanfrpre = mean([Xx_train_pre(:,:) Xx_test_pre(:,:)],2);
    Xx_train_pre = Xx_train_pre(:,:)  - repmat(meanfrpre,[1 ddi*length(tton)]);
    Xx_test_pre = Xx_test_pre(:,:)  - repmat(meanfrpre,[1 ddi*length(tton)]);

    meanfron = mean([Xx_train_onset(:,:) Xx_test_onset(:,:)],2);
    Xx_train_onset = Xx_train_onset(:,:)  - repmat(meanfron,[1 ddi*length(tton)]);
    Xx_test_onset = Xx_test_onset(:,:)  - repmat(meanfron,[1 ddi*length(tton)]);

    meanfroff = mean([Xx_train_offset(:,:) Xx_test_offset(:,:)],2);
    Xx_train_offset = Xx_train_offset(:,:)  - repmat(meanfroff,[1 ddi*length(tton)]);
    Xx_test_offset = Xx_test_offset(:,:)  - repmat(meanfroff,[1 ddi*length(tton)]);


    %denoising data matrix using top PCs:
    [coeff,~,~,~,explained,~] = pca(Xx_train_pre');toppc=find(cumsum(explained)>80,1);
    Dpre = coeff(:,1:toppc)*coeff(:,1:toppc)';

    [coeff,~,~,~,explained,~] = pca(Xx_train_onset');toppc=find(cumsum(explained)>80,1);
    Donset = coeff(:,1:toppc)*coeff(:,1:toppc)';

    [coeff,~,~,~,explained,~] = pca(Xx_train_offset');toppc=find(cumsum(explained)>80,1);
    Doffset = coeff(:,1:toppc)*coeff(:,1:toppc)';

    clear Betapre Betaoffset Betaonset
    %get regression betas for each neuron and time point
    for time=1:size(ritpre{1},2)
        for  ch=1:length(ritpre)
            %design matrices for different regression models:
            F = [Fabsdist{ch};ones(1,length(Fabsdist{ch}))];%dist and direction
            Betapre(ch,time,:) = inv(F*F')*F*(ritpre{ch}(:,time)-meanfrpre(ch));%linear regression
            Betaonset(ch,time,:) = inv(F*F')*F*(ritonset{ch}(:,time)-meanfron(ch));%linear regression
            Betaoffset(ch,time,:) = inv(F*F')*F*(ritoffset{ch}(:,time)-meanfroff(ch));%linear regression



            frtrain = reshape(Xx_train_pre(ch,:),[13 4]);
            frtest = reshape(Xx_test_pre(ch,:),[13 4]);

            [betarsq_.betapre(ch,time,bb,:), betarsq_.rsqpre(ch,time,bb), betarsq_.rsqpre_sh(ch,time,bb)] ...
                =get_xval_vaf(frtrain(time,:),frtest(time,:));

            frtrain = reshape(Xx_train_offset(ch,:),[13 4]);
            frtest = reshape(Xx_test_offset(ch,:),[13 4]);

            [betarsq_.betaoff(ch,time,bb,:), betarsq_.rsqoff(ch,time,bb), betarsq_.rsqoff_sh(ch,time,bb)] ...
                =get_xval_vaf(frtrain(time,:),frtest(time,:));

        end
    end

    Bpcapre = Dpre*Betapre(:,:,1); %denoise with topPC PCs
    Bpcaonset = Donset*Betaonset(:,:,1);
    Bpcaoffset = Doffset*Betaoffset(:,:,1);


    % Find time point where each regression coefficient has maximum norm

    clear bnormpre bnormoffset bnormonset
    for tt=1:9
        bnormpre(tt) = norm(Bpcapre(:,tt));
        bnormonset(tt) = norm(Bpcaonset(:,tt));
        bnormoffset(tt) = norm(Bpcaoffset(:,tt));
    end
    [~,maxt]=max(bnormpre);Bmaxpre=Bpcapre(:,maxt);
    [~,maxt]=max(bnormonset);Bmaxonset=Bpcaonset(:,maxt);
    [~,maxt]=max(bnormoffset);Bmaxoffset=Bpcaoffset(:,maxt);



    %project average population activity of test data set onto orthogonal axes of regression
    pvcpre(:,:,bb) = reshape(Bmaxpre'*Xx_test_pre,[length(tton) ddi]);
    pvconset(:,:,bb) = reshape(Bmaxonset'*Xx_test_onset,[length(tton) ddi]);
    pvcoffset(:,:,bb) = reshape(Bmaxoffset'*Xx_test_offset,[length(tton) ddi]);
    bb
end

pvc_.pvcpre=pvcpre;
pvc_.pvcon=pvconset;
pvc_.pvcoff=pvcoffset;
end


%===get fr for betas and TDR
function [fr] =get_fr(mintrials,area,cp,animal,param,tt,seq)
frpre=[];frpre2=[];
fronset=[];fronset2=[];
froffset=[]; froffset2=[];
tr=[];tr2=[];ssn=[];trim=[];ssnim=[];
neurons=[];periodic=[];periodic2=[];periodic_numtrials=[];periodic_numtrials2=[];
neuronsim=[];
PI_650=[]; PI_6502=[];
frpreim=[ ];
froffsetim=[ ];
fronsetim=[ ];
frstim1on=[];tpim=[];

load([cp.datafolder '/' params.animal '_' params.area '_sessions.mat'], 'sessions')


cd([param.savedata(1:end-9) '/data/'])
load([animal '_' area '_periodicity_js_leftright_dist345.mat'], 'gridness','params')
longer_gridlag=params.gridlag;
idx650=find(longer_gridlag==650);

if area=='7a'
    switch animal
        case 'mahler'
            sessions=sessions(1:end-1);
        case 'amadeus'
            sessions=sessions(1:2);
    end
elseif area=='EC'
    switch animal
        case 'mahler'
        case 'amadeus'
            sessions=sessions(1:end-1);
    end
end

for ss=1:length(sessions)
    cd(param.savedata)

    if seq==12 
        load([sessions{ss} '_icfc_final_seq12'   '.mat'],'icfc2');

        icfc=icfc2;

        load([sessions{ss} '_icfc_final_impairs_seq12'   '.mat'],'icfc2')

        icfcim=icfc2;
    else 
        load([sessions{ss} '_icfc_final_seq' num2str(seq) '.mat'],'icfc2')

        icfc=icfc2;

        load([sessions{ss} '_icfc_woscaling_impairs_seq' num2str(seq) '.mat'],'icfc2')

        icfcim=icfc2;
    end
    
    if ~isfield(icfc,'fron_scaled')
        continue;
    else
        if ss==1
        fr.edgeson=icfc.edges_on_scaled{1}(tt);
        fr.edgesoff=icfc.edges_off_scaled{1}(tt);
        fr.edgeson_entireTrial=icfc.edges_on_scaled;
        fr.edgesoff_entireTrial=icfc.edges_off_scaled;
        fr.edgespre=icfc.edges_premov(tt);
        fr.cond_ctd=icfcim.cond_ctd;
        fr.edgesstim1on=icfc2.edges_stim1on(1:end-1);
        if exist(icfc2.edges_joyon)
            fr.edges_joyon=icfc2.edges_joyon(1:end-1);
            fr.edges_joyoff=icfc2.edges_joyoff(1:end-1);
        end
        end

    end
    clear modnn modnn2 modnnim
    for neur=1:length(icfc.fron_scaled)
        if length(icfc.fron_scaled{neur})<5, numtrials(neur,:)=0;
        else
            numtrials(neur,:)=[size(icfc.fron_scaled{neur}{1},1) size(icfc.fron_scaled{neur}{2},1) size(icfc.fron_scaled{neur}{3},1) size(icfc.fron_scaled{neur}{4},1) size(icfc.fron_scaled{neur}{5},1)];
        end
        if length(icfc.fron_scaled2{neur})<5, numtrials2(neur,:)=0;
        else
            numtrials2(neur,:)=[size(icfc.fron_scaled2{neur}{1},1) size(icfc.fron_scaled2{neur}{2},1) size(icfc.fron_scaled2{neur}{3},1) size(icfc.fron_scaled2{neur}{4},1) size(icfc.fron_scaled2{neur}{5},1)];
        end
        if any(numtrials2(neur,:)<mintrials), modnn2(neur)=0; else modnn2(neur)=1;end
        if any(numtrials(neur,:)<mintrials), modnn(neur)=0; else modnn(neur)=1;end
    end
    for neur=1:length(icfcim.fron_scaled)

        if length(icfcim.fron_scaled{neur})<30, numtrialsim(neur,:)=0;
        else
            for ii=1:30,numtrialsim(neur,ii)=size(icfcim.fron_scaled{neur}{ii},1) ;end
        end

        if any(numtrialsim(neur,:)<mintrials), modnnim(neur)=0; else modnnim(neur)=1;end

    end


    nn = find(modnn==1 & modnn2==1);
    nnim = find(modnnim==1);

    frpre=[frpre icfc.fr_premov(nn)];
    frpre2=[frpre2 icfc.fr_premov2(nn)];
    fronset=[fronset icfc.fron_scaled(nn)];
    fronset2=[fronset2 icfc.fron_scaled2(nn)];
    froffset=[froffset icfc.froff_scaled(nn)];
    froffset2=[froffset2 icfc.froff_scaled2(nn)];

    frpreim=[frpreim icfcim.fr_premov(nnim )];
    froffsetim=[froffsetim icfcim.froff_scaled(nnim)];
    fronsetim=[fronsetim icfcim.fron_scaled(nnim)];

    frstim1on=[frstim1on icfcim.fr_stim1on(nnim)];


    tr = [tr numtrials(nn,:)'];
    tr2 = [tr2 numtrials2(nn,:)'];
    trim = [trim numtrialsim(nnim,:)'];
    tpim = [tpim; icfcim.tp(nnim,:)];

    ssn = [ssn ss*ones(1,length(nn))];
    ssnim = [ssnim ss*ones(1,length(nnim))];

    neurons = [neurons nn];
    neuronsim = [neuronsim nnim];

    periodic = [periodic gridness{ss,1}.pc_above_mean_gridness(nn)];
    periodic2=[periodic2 gridness{ss,2}.pc_above_mean_gridness(nn)];

    periodic_numtrials = [periodic_numtrials gridness{ss,1}.num_trials_mve(nn,1)'];
    periodic_numtrials2=[periodic_numtrials2 gridness{ss,2}.num_trials_mve(nn,1)'];


    clear gridness_tlag_abovemean gridness_tlag_abovemean2
    for nni=1:size(gridness{ss,1}.gridness_tlag,1)
        gridness_tlag_abovemean(nni,:) = gridness{ss,1}.gridness_tlag(nni,:) - mean(gridness{ss,1}.gridness_tlag(nni,find(gridness{ss,1}.gridness_tlag(nni,:)>0,1):end ));
    end
    for nni=1:size(gridness{ss,2}.gridness_tlag,1)
        gridness_tlag_abovemean2(nni,:) = gridness{ss,2}.gridness_tlag(nni,:) - mean(gridness{ss,2}.gridness_tlag(nni,find(gridness{ss,2}.gridness_tlag(nni,:)>0,1):end ));
    end

    PI_650=[PI_650 gridness_tlag_abovemean(nn,idx650)'];
    PI_6502=[PI_6502 gridness_tlag_abovemean2(nn,idx650)'];

    ss
end
fr.neurons = neurons;fr.neuronsim = neuronsim;
fr.periodic=periodic;
fr.periodic_numtrials=periodic_numtrials;
fr.periodic2=periodic2;
fr.periodic_numtrials2=periodic_numtrials2;
fr.PI_650=PI_650;
fr.PI_6502=PI_6502;

fr.ssn=ssn;fr.ssnim=ssnim;
fr.numtr=tr;
fr.numtr2=tr2;fr.numtrim=trim;
fr.tpim = tpim; 
fr.frpre=frpre;
fr.fronset=fronset;
fr.froffset=froffset;
fr.frpre2=frpre2;
fr.fronset2=fronset2;
fr.froffset2=froffset2;

fr.frpreim=frpreim;
fr.fronsetim=fronsetim;
fr.froffsetim=froffsetim;

fr.frstim1on=frstim1on;
end


function get_save_icfc_impairs(params,seq,cp)


cd(params.savedir_area)


%load experimental session information
load([cp.datafolder '/' params.animal '_' params.area '_sessions.mat'], 'sessions')



%for each session
for ss=1:length(sessions)
    clear icfc2 cond_ctd cond_dist
    tic
    params.filename=sessions{ss};

    %load task variables for that session
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

    %load neural data:
    if strcmp(params.animal,'mahler') && strcmp(params.area,'7a')  %for NP data, remove lowFR neurons from the outset
        numneuron=1:mahler_NP_within_session_neurons(ss);
    else
        numneuron = 1:size(varlist,'neur_tensor_joyon',1);
    end

    data_tensor_joyon = varlist.neur_tensor_joyon(numneuron,:,:);


    varlist_off=matfile([sessions{ss} '_neur_tensor_joyoff']);
    data_tensor_joyoff = varlist_off.neur_tensor_joyoff(numneuron,:,:);
    joyoff=varlist_off.joyoff;
    params.edges_revoff=joyoff.edges(params.window_edge_effect);

    varlist_stim1on=matfile([sessions{ss} '_neur_tensor_stim1on']);
    data_tensor_stim1on = varlist_stim1on.neur_tensor_stim1on(numneuron,:,:);
    stim1on=varlist_stim1on.stim1on;
    params.edges_stim1on = stim1on.edges';


    ttwin = params.edges_stim1on>-1;
    params.edges_stim1on=params.edges_stim1on(ttwin)';
    data_tensor_stim1on= data_tensor_stim1on(:,ttwin,:);

    params.window_edge_effect_stim1on = params.gauss_smooth*2/params.binwidth:(length(params.edges_stim1on)-params.gauss_smooth*2/params.binwidth);

    params.edges_stim1on=params.edges_stim1on(params.window_edge_effect_stim1on);

    if size(data_tensor_joyon,3)<length(params.ta)

        data_tensor_joyon(:,:,end+1)=0;
        data_tensor_joyoff(:,:,end+1)=0;
        data_tensor_stim1on(:,:,end+1)=0;
    end

    %===============================%===============================%===============================
    % single neuron scaled psths
    %===============================%===============================%===============================

    num_conditions=30;
    scaling_binwidth=0.04;%sec
    trial_inclusion = '1attempt';% '1attempt' or 'Gmixturemodel'


    xtikson = 0:.65:3.25;
    xtiksoff = -3.25:.65:0;
    onset_cutoff=0;
    offset_cutoff=0;

    clear frmean_scaled_allneurons frmean_scaled_allneuronsoff frmean_scaled_allneurons2 frmean_scaled_allneuronsoff2
    nn=0;
    for neur=1:size(data_tensor_joyon,1)%[3 4 19 30]%[1 2 7 9 24 33]%
        nn=nn+1;
        %find low FR trials to remove:
        lowfr_trials = (mean(squeeze(data_tensor_joyon(nn,params.edges>-.5 & params.edges<.5,:)),1)<.05)';

        %get relevant trials:
        switch trial_inclusion
            case '1attempt'
                if seq==12
                    trials= find( params.trial_type==3 & params.seqq<3 & params.attempt==1 & lowfr_trials==0);
                    
                else
                    trials= find( params.trial_type==3 & params.seqq==seq & params.attempt==1 & lowfr_trials==0);
                    
                end
                
            case 'Gmixturemodel'
                trials= find(params.dir_condition==params.direction & params.trial_type==3 & params.seqq<3 & params.validtrials_mm==1 & lowfr_trials==0);
        end
        if length(trials)<50 %unstable neurons if there aren't enough trials
            disp([params.filename num2str(neur) ' skipped. Too unstable neuron'])
            icfc2.numtrials(neur,1:30)=nan;

            continue;
        end
        icfc2.alltrials=trials;
        tpp=abs(params.tp(trials));
        taa=abs(params.dist_conditions(trials));
        curr = params.curr(trials);
        targ = params.target(trials);

        kk=1;cond=0*taa;
        for cc=1:6
            for tt=1:6
                if cc==tt, continue;end

                idx = curr==cc & targ==tt;
                cond_ctd(kk,:)=[cc tt tt-cc];
                cond(idx)=kk;
                cond_dist(idx)=abs(tt-cc);
                kk=kk+1;

            end
        end

        %smooth FR:
        data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor_joyon(neur,:,trials))','same');
        psth_on=data_tensor_smoothed(:,params.window_edge_effect);


        data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor_joyoff(neur,:,trials))','same');
        psth_off=data_tensor_smoothed(:,params.window_edge_effect);

         data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor_stim1on(neur,:,trials))','same');
        psth_stim1on=data_tensor_smoothed(:,params.window_edge_effect_stim1on);

        %get median tps for scaling: median over common distance 
        if nn==1

            for dd=1:num_conditions

               
                tptemp_dist=tpp(cond_dist==abs(cond_ctd(dd,3)));


                icfc2.median_time_scaling(dd)=median(tptemp_dist);%
                icfc2.edges_on_scaled{dd} = 0:scaling_binwidth:icfc2.median_time_scaling(dd);
                icfc2.edges_off_scaled{dd} = -icfc2.median_time_scaling(dd):scaling_binwidth:0;
                num_scaling_bins(dd) = length(icfc2.edges_on_scaled{dd})+1;
                num_scaling_binsoff(dd) = length(icfc2.edges_off_scaled{dd})+1;
                

            end
            icfc2.cond=cond; icfc2.cond_ctd=cond_ctd;

        end

        % get psth for each tpbin with scaling:
        clear frtemp_stimon frtemp_scaled frtemp_scaledoff frmean_scaled frmean_scaledoff frsem_scaled frsem_scaledoff numtrials frtemp_premov
        for dd=1:num_conditions

            tr=find(cond==dd);
            icfc2.trials{dd}=icfc2.alltrials(tr);
            if length(tr)<5
          
                icfc2.numtrials(neur,dd)=0;

                frtemp_scaled{dd}=nan;frtemp_scaledoff{dd}=nan;frtemp_premov{dd}=nan;
                frtemp_stimon{dd}=nan;
                continue;
            end
            tptemp = tpp(tr);
            icfc2.tp{dd}=tptemp;

            %pre_move psth binned at 'scalingbinwidth':
            ttpre=params.edges_rev>=params.tt_premov(1) & params.edges_rev<=params.tt_premov(2);
            edgspremov_true = params.edges_rev(ttpre);
            icfc2.edges_premov = params.tt_premov(1):scaling_binwidth:params.tt_premov(2);

            frtemp = psth_on(tr,ttpre);
            for scaledbin = 1:length(icfc2.edges_premov)-1
                frtemp_premov{dd}(:,scaledbin)=mean(frtemp(:,edgspremov_true>(icfc2.edges_premov(scaledbin)) & edgspremov_true<(icfc2.edges_premov(scaledbin+1))),2);
            end

            icfc2.edges_stim1on = params.edges_stim1on(1):scaling_binwidth:params.edges_stim1on(end);
            edgsstim1on_true = params.edges_stim1on;
             frtemp = psth_stim1on(tr,:);
            for scaledbin = 1:length(icfc2.edges_stim1on)-1
                frtemp_stimon{dd}(:,scaledbin)=mean(frtemp(:,edgsstim1on_true>=(icfc2.edges_stim1on(scaledbin)) & edgsstim1on_true<(icfc2.edges_stim1on(scaledbin+1))),2);
            end
           
            % psth scaling:
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

            %             icfc2.frmean_scaled_allneurons{dd}(neur,:)=nanmean(frtemp_scaled{dd},1)';
            %             icfc2.frmean_scaled_allneuronsoff{dd}(neur,:)=nanmean(frtemp_scaledoff{dd},1)';
            %             icfc2.frsem_scaled_allneurons{dd}(neur,:)=nanstd(frtemp_scaled{dd},[],1)/sqrt(size(frtemp_scaled{dd},1))';
            %             icfc2.frsem_scaled_allneuronsoff{dd}(neur,:)=nanstd(frtemp_scaledoff{dd},[],1)/sqrt(size(frtemp_scaledoff{dd},1))';
            icfc2.numtrials(neur,dd)=size(frtemp_scaled{dd},1);


        end

        icfc2.edges_premov=icfc2.edges_premov(1:end-1);
        icfc2.fron_scaled{neur}=frtemp_scaled;

        icfc2.froff_scaled{neur}=frtemp_scaledoff;

        icfc2.fr_premov{neur}=frtemp_premov;
        icfc2.fr_stim1on{neur}=frtemp_stimon;

        disp([params.filename num2str(neur)])


    end %neurons

    close all

    if params.savedata==1
        cd(params.savedir_area)
        save([params.filename '_icfc_final_impairs_seq' num2str(seq) '.mat'],'icfc2','params')
    end

    toc
end %sessions



end

 
function get_save_icfc(params,seq,cp)


cd(params.savedir_area)


%load experimental session information
load([cp.datafolder '/' params.animal '_' params.area '_sessions.mat'], 'sessions')


%for each session
for ss=1:length(sessions)
    clear icfc2
    tic
    params.filename=sessions{ss}

    %load task variables for that session
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

    %load neural data:
    if strcmp(params.animal,'mahler') && strcmp(params.area,'7a')  %for NP data, remove lowFR neurons from the outset
        numneuron=1:mahler_NP_within_session_neurons(ss);
    else
        numneuron = 1:size(varlist,'neur_tensor_joyon',1);
    end

    data_tensor_joyon = varlist.neur_tensor_joyon(numneuron,:,:);
    varlist_off=matfile([sessions{ss} '_neur_tensor_joyoff']);
    data_tensor_joyoff = varlist_off.neur_tensor_joyoff(numneuron,:,:);
    joyoff=varlist_off.joyoff;
    params.edges_revoff=joyoff.edges(params.window_edge_effect);


    if size(data_tensor_joyon,3)<length(params.ta)

        data_tensor_joyon(:,:,end+1)=0;
        data_tensor_joyoff(:,:,end+1)=0;

    end

    %===============================%===============================%===============================
    % single neuron scaled psths
    %===============================%===============================%===============================

    num_tpbins=5;
    scaling_binwidth=0.04;%sec
    trial_inclusion = '1attempt';% '1attempt' or 'Gmixturemodel'


    xtikson = 0:.65:3.25;
    xtiksoff = -3.25:.65:0;
    onset_cutoff=0;
    offset_cutoff=0;

    clear frmean_scaled_allneurons frmean_scaled_allneuronsoff frmean_scaled_allneurons2 frmean_scaled_allneuronsoff2
    nn=0;
    for neur=1:size(data_tensor_joyon,1)%[3 4 19 30]%[1 2 7 9 24 33]%
        nn=nn+1;
        %find low FR trials to remove:
        lowfr_trials = (mean(squeeze(data_tensor_joyoff(nn,joyoff.edges>-2 & joyoff.edges<0,:)),1)<.5)';

        %get relevant trials:
        switch trial_inclusion
            case '1attempt'
                if seq==12
                    trials= find(params.dir_condition==1 & params.trial_type==3 & params.seqq<3 & params.attempt==1 & lowfr_trials==0);
                    trialsdir2= find(params.dir_condition==-1 & params.trial_type==3 & params.seqq<3 & params.attempt==1 & lowfr_trials==0);
  
                else
                    trials= find(params.dir_condition==1 & params.trial_type==3 & params.seqq==seq & params.attempt==1 & lowfr_trials==0);
                    trialsdir2= find(params.dir_condition==-1 & params.trial_type==3 & params.seqq==seq & params.attempt==1 & lowfr_trials==0);
                end
            case 'Gmixturemodel'
                trials= find(params.dir_condition==params.direction & params.trial_type==3 & params.seqq<3 & params.validtrials_mm==1 & lowfr_trials==0);
        end
        if length(trials)<50 || length(trialsdir2)<50 %unstable neurons if there aren't enough trials
            disp([params.filename num2str(neur) ' skipped. Too unstable neuron'])
            icfc2.numtrials2(neur,1:5)=nan;
            icfc2.numtrials(neur,1:5)=nan;

            continue;
        end
        tpp=abs(params.tp(trials));
        taa=abs(params.dist_conditions(trials));
        tpp2=abs(params.tp(trialsdir2));
        taa2=abs(params.dist_conditions(trialsdir2));

        %smooth FR:
        data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor_joyon(neur,:,trials))','same');
        psth_on=data_tensor_smoothed(:,params.window_edge_effect);
        data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor_joyon(neur,:,trialsdir2))','same');
        psth_on2=data_tensor_smoothed(:,params.window_edge_effect);


        data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor_joyoff(neur,:,trials))','same');
        psth_off=data_tensor_smoothed(:,params.window_edge_effect);
        data_tensor_smoothed=conv2(1,params.gauss_smoothing_kern,squeeze(data_tensor_joyoff(neur,:,trialsdir2))','same');
        psth_off2=data_tensor_smoothed(:,params.window_edge_effect);

        %get median tps for scaling
        if nn==1 || ~isfield(icfc2,'median_time_scaling')
            for dd=1:num_tpbins

                tr=find(taa==dd);tr2=find(taa2==dd);
                tptemp = tpp(tr);tptemp2 = tpp2(tr2);

                icfc2.median_time_scaling(dd)=median(tptemp);%
                icfc2.edges_on_scaled{dd} = 0:scaling_binwidth:icfc2.median_time_scaling(dd);
                icfc2.edges_off_scaled{dd} = -icfc2.median_time_scaling(dd):scaling_binwidth:0;
                num_scaling_bins(dd) = length(icfc2.edges_on_scaled{dd})+1;
                num_scaling_binsoff(dd) = length(icfc2.edges_off_scaled{dd})+1;

                icfc2.median_time_scaling2(dd)=median(tptemp2);%
                icfc2.edges_on_scaled2{dd} = 0:scaling_binwidth:icfc2.median_time_scaling2(dd);
                icfc2.edges_off_scaled2{dd} = -icfc2.median_time_scaling2(dd):scaling_binwidth:0;
                num_scaling_bins2(dd) = length(icfc2.edges_on_scaled2{dd})+1;
                num_scaling_binsoff2(dd) = length(icfc2.edges_off_scaled2{dd})+1;

            end


        end

        % get psth for each tpbin with scaling:
        clear frtemp_scaled frtemp_scaledoff frmean_scaled frmean_scaledoff frsem_scaled frsem_scaledoff numtrials frtemp_premov
        clear frtemp_scaled2 frtemp_scaledoff2 frmean_scaled2 frmean_scaledoff2 frsem_scaled2 frsem_scaledoff2 numtrials2 frtemp_premov2
        for dd=1:num_tpbins

            tr=find(taa==dd);tr2=find(taa2==dd);
            if length(tr)<5 || length(tr2)<5
%                 try
                icfc2.frmean_scaled_allneurons{dd}(neur,:)=nan(1,length(0:scaling_binwidth:icfc2.median_time_scaling(dd)));
%                 catch
%                     disp ''
%                 end
                icfc2.frmean_scaled_allneuronsoff{dd}(neur,:)=nan(1,length(0:scaling_binwidth:icfc2.median_time_scaling(dd)));
                icfc2.numtrials(neur,dd)=0;

                icfc2.frmean_scaled_allneurons2{dd}(neur,:)=nan(1,length(0:scaling_binwidth:icfc2.median_time_scaling2(dd)));
                icfc2.frmean_scaled_allneuronsoff2{dd}(neur,:)=nan(1,length(0:scaling_binwidth:icfc2.median_time_scaling2(dd)));
                icfc2.numtrials2(neur,dd)=0;
                frtemp_scaled{dd}=nan;frtemp_scaledoff{dd}=nan;frtemp_scaled2{dd}=nan;frtemp_scaledoff2{dd}=nan;

                continue;
            end
            tptemp = tpp(tr);tptemp2 = tpp2(tr2);


            %pre_move psth binned at 'scalingbinwidth':
            ttpre=params.edges_rev>=params.tt_premov(1) & params.edges_rev<=params.tt_premov(2);
            edgspremov_true = params.edges_rev(ttpre);
            icfc2.edges_premov = params.tt_premov(1):scaling_binwidth:params.tt_premov(2);

            frtemp = psth_on(tr,ttpre);
            frtemp2 = psth_on2(tr2,ttpre);
            for scaledbin = 1:length(icfc2.edges_premov)-1
                frtemp_premov{dd}(:,scaledbin)=mean(frtemp(:,edgspremov_true>(icfc2.edges_premov(scaledbin)) & edgspremov_true<(icfc2.edges_premov(scaledbin+1))),2);
                frtemp_premov2{dd}(:,scaledbin)=mean(frtemp2(:,edgspremov_true>(icfc2.edges_premov(scaledbin)) & edgspremov_true<(icfc2.edges_premov(scaledbin+1))),2);
            end
            icfc2.frmean_premov_allneurons{dd}(neur,:) = nanmean(frtemp_premov{dd},1);
            icfc2.frmean_premov_allneurons2{dd}(neur,:) = nanmean(frtemp_premov2{dd},1);
            icfc2.frsem_premov_allneurons{dd}(neur,:) = nanstd(frtemp_premov{dd},[],1)/sqrt(size(frtemp_premov{dd},1));
            icfc2.frsem_premov_allneurons2{dd}(neur,:) = nanstd(frtemp_premov2{dd},[],1)/sqrt(size(frtemp_premov2{dd},1));

            %direction joystick left psth scaling:
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
           
            %direction joystick right psth scaling:
            for tri=1:length(tr2)
                ttscaling=params.edges_rev>0 & params.edges_rev<tptemp2(tri);
                edgs_true = params.edges_rev(ttscaling);
                edgs_scaled = linspace(0,tptemp2(tri),num_scaling_bins2(dd));
                frtemp = psth_on2(tr2(tri),ttscaling);
                for scaledbin = 1:length(edgs_scaled)-1
                    frtemp_scaled2{dd}(tri,scaledbin)=mean(frtemp(edgs_true>(edgs_scaled(scaledbin)) & edgs_true<(edgs_scaled(scaledbin+1))));
                end

                ttscalingoff=params.edges_revoff>-tptemp2(tri) & params.edges_revoff<0;
                edgs_trueoff = params.edges_revoff(ttscalingoff);
                edgs_scaledoff = linspace(-tptemp2(tri),0,num_scaling_binsoff2(dd));
                frtemp = psth_off2(tr2(tri),ttscalingoff);
                for scaledbin = 1:length(edgs_scaledoff)-1
                    frtemp_scaledoff2{dd}(tri,scaledbin)=mean(frtemp(edgs_trueoff>(edgs_scaledoff(scaledbin)) & edgs_trueoff<(edgs_scaledoff(scaledbin+1))));
                end
            end


            icfc2.frmean_scaled_allneurons2{dd}(neur,:)=nanmean(frtemp_scaled2{dd},1)';
            icfc2.frmean_scaled_allneuronsoff2{dd}(neur,:)=nanmean(frtemp_scaledoff2{dd},1)';
            icfc2.frsem_scaled_allneurons2{dd}(neur,:)=nanstd(frtemp_scaled2{dd},[],1)/sqrt(size(frtemp_scaled2{dd},1))';
            icfc2.frsem_scaled_allneuronsoff2{dd}(neur,:)=nanstd(frtemp_scaledoff2{dd},[],1)/sqrt(size(frtemp_scaled2{dd},1))';
            icfc2.numtrials2(neur,dd)=size(frtemp_scaledoff2{dd},1);

        end

        icfc2.edges_premov=icfc2.edges_premov(1:end-1);
        icfc2.fron_scaled{neur}=frtemp_scaled;
        icfc2.fron_scaled2{neur}=frtemp_scaled2;

        icfc2.froff_scaled{neur}=frtemp_scaledoff;
        icfc2.froff_scaled2{neur}=frtemp_scaledoff2;

        icfc2.fr_premov{neur}=frtemp_premov;
        icfc2.fr_premov2{neur}=frtemp_premov2;

        use4dist=0;numdd=5;
        if any(icfc2.numtrials(neur,1:4)<5)%unstable neurons if there aren't enough trials on any of the tp bins
            icfc.rsqbb_allneurons(neur,:,:)=nan;
            icfc.rsqoffbb_allneurons(neur,:,:)=nan;

            icfc.betabb_allneurons(neur,:,:)=nan;
            icfc.betaoffbb_allneurons(neur,:,:)=nan;
            disp([params.filename num2str(neur) ' skipped. Too few trials'])

        else

            if (icfc2.numtrials(neur,5)<5)%use only 4 dist if fifth one has no trials

                use4dist=1;
                numdd=4;

            end
            icfc2.numdd(nn)=numdd;

        disp([params.filename num2str(neur)])

        end


    end %neurons

    close all

    if params.savedata==1
        cd(params.savedir_area)
        save([params.filename '_icfc_final_seq' num2str(seq) '.mat'],'icfc2','params')
    end

    toc
end %sessions



end
