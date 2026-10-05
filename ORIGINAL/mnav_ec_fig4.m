% Neupane, Fiete, Jazayeri 2024 mental navigation paper 
% Fig 4 plot reproduction

%Download preprocessed Fig4 data from this link into your local folder:
% https://www.dropbox.com/scl/fo/vu8cl45wmiixo4gxnuaug/AMFPqtj73cZPCzOnQn9bTZc?rlkey=irxfazoibvdk1jc3cui0neshg&dl=0
%for questions or further data/code access contact sujayanyaupane@gmail.com
%=============================================================================


%Fig4: mnav_fig4_CAN_model_Bayesian_model_Fanofa
clear
cp.savedir_='/Users/Sujay/Dropbox (MIT)/MJ & SN/nav_paper/Nature_revision 1/matlab code/data_figs'; %'/data_figs';

% mkdir([cp.savedir_ '/Fig4']); %if the folder doesn't exist, make one and download data there
cp.datafolder=[cp.savedir_ '/Fig4/data'];

cp.datafolder_fig2 = [cp.savedir_ '/Fig2/data']; %This m-file has one dependency on Fig2 gridness data.  

cp.tensordatafolder=['/Users/Sujay/Dropbox (MIT)/physiology_data_for_sharing/EC']; %change this folder to your local folder you downloaded tensor data

%% Hebbian learning with Oja's rule on a simplified model 

clear;close all
nModule=4;%20
lm_module=1:4;%1:20;
module_phases = 45:90:360; %[50 150 320];30:45:360;90; 
weights = nan(500,360,nModule,length(module_phases));
lr=0.0000002;

if length(lm_module)==1
    for mph = 1:length(module_phases)
        [out,params]=gc1d_init_oja(nModule, lm_module, module_phases(mph),1,lr);
        weights(:,:,:,mph)=out.weights;
        outs{mph}=out;
        mph
    end
    params.module_phases=module_phases;
    params.lm_module=lm_module;
    
     save(['Hebb_learn_sim_' num2str(nModule) 'mod_' num2str(length(module_phases)) 'phases_1e7lr_irrelugarLM'],'params','outs','weights')
    disp(['Hebb_learn_sim_' num2str(nModule) 'mod_' num2str(length(module_phases)) 'phases_1e7lr saved!!'])
    
else
    
    for mph = 1:length(lm_module)
        [out,params]=gc1d_init_oja(nModule, lm_module(mph), module_phases,1,lr);
        weights(:,:,:,mph)=out.weights;
        outs{mph}=out;
        module=mph
    end
    
    params.module_phases=module_phases;
    params.lm_module=lm_module;
    
     save(['Hebb_learn_sim_20mod_' num2str(nModule) 'mod_' num2str(length(module_phases)) 'phases_1e7lr_relugarLM'],'params','outs','weights')
    disp(['Hebb_learn_sim_20mod_' num2str(nModule) 'mod_' num2str(length(module_phases)) 'phases_1e7lr saved!!'])
end


%% CAN e.g. model simulation Fig 4c

linnonlinfit=0;
wmm=.08;%.05 %webber frac
sp=[42 35];%speed 42 and 35 for w/o and w LM models
[hsim,hvar,T] = get_simul_variance(wmm,sp,cp.datafolder,linnonlinfit);
% saveas(hsim,'Fig4c_model_simulation_w_wo_LM' ,'epsc')
% saveas(hvar,'Fig4d_var_reduction' ,'epsc')


%% Fig S9e other webber fractions 
wmm=.05; %webber frac
sp=[42 35];%speed 42 and 35 for w/o and w LM models
linnonlinfit=0;
[hsim,hvar,T] = get_simul_variance(wmm,sp,cp.datafolder,linnonlinfit);
cd(cp.datafolder);
% saveas(hsim,'FigS9e_wm5_moddel_simulation_w_wo_LM' ,'epsc')
% saveas(hvar,'FigS9e_wm5_var_reduction' ,'epsc')
% 
% writetable(T.meanstdRT,'FigS9.xlsx','Sheet','fig_S9f_left_downsampled_wm5','Range','A1')
% writetable(T.trajecwith,'FigS9.xlsx','Sheet','fig_S9f_left_downsampled_wm5','Range','A5')
% writetable(T.trajecwo,'FigS9.xlsx','Sheet','fig_S9f_left_downsampled_wm5','Range','A780')
% 
% writetable(T.meanstdRT_atbasetimes,'FigS9.xlsx','Sheet','fig_S9f_middle')
% writetable(T.meanstd_produced_RT_atbasetimes,'FigS9.xlsx','Sheet','fig_S9f_right')


wmm=.02; %webber frac
sp=[42 35];%speed 42 and 35 for w/o and w LM models
[hsim,hvar,T] = get_simul_variance(wmm,sp,cp.datafolder,linnonlinfit);
cd(cp.datafolder);
% saveas(hsim,'FigS9e_wm2_moddel_simulation_w_wo_LM' ,'epsc')
% saveas(hvar,'FigS9e_wm2_var_reduction' ,'epsc')
% 
% writetable(T.meanstdRT,'FigS9.xlsx','Sheet','fig_S9f_left_downsampled_wm2','Range','A1')
% writetable(T.trajecwith,'FigS9.xlsx','Sheet','fig_S9f_left_downsampled_wm2','Range','A5')
% writetable(T.trajecwo,'FigS9.xlsx','Sheet','fig_S9f_left_downsampled_wm2','Range','A745')
% 
% writetable(T.meanstdRT_atbasetimes,'FigS9.xlsx','Sheet','fig_S9f_middle','Range','A10')
% writetable(T.meanstd_produced_RT_atbasetimes,'FigS9.xlsx','Sheet','fig_S9f_right','Range','A10')

%% CAN model weights Fig 4b and S9b
cd(cp.datafolder);
load('Hebb_learn_sim_4mod_4phases_1e7lr.mat')
module_phases = 45:90:360;
lm_module=params.LM_module;
nModule = params.Nmodule;
lm_off = find(outs{1}.vis2mental,1); %transition time from visual to menatl
hcol = myrgb(length(module_phases),[1 0 0]);
hcolgray = myrgb(length(module_phases),[.5 .5 .5]);


hhebb=figure('Position',[ 33         629        1774         420]);
for mph = 1:length(module_phases)
    tti=1;
for trainingtime = [1 100:100:500]
    if mph==3
        subplot(2,6,tti)
        imagesc(squeeze(weights(trainingtime,:,:,mph)));hold on
        plot(params.LM_module,module_phases(3),'k.','MarkerSize',20);
        set(gca,'XTick',1:2:params.Nmodule, 'XTickLabel',round(100*params.scale(1:2:end))/100)
        xlabel('Spatial scale (a.u.)');
        ylabel('Phase (deg)');
        set(gca,'FontSize',15);colorbar 
        caxis([-5 5]/1000)
        if trainingtime<lm_off, title('visual')
        else, title('mental');end

        weights_LM3_vismental(:,:,tti)=squeeze(weights(trainingtime,:,:,mph));
    end
    
    
    subplot(2,6,tti+6)
    for modulenum=1:nModule
        a=squeeze(weights(trainingtime,:,modulenum,mph));
        a = (a-min(a))/(max(a)-min(a));
        
        if modulenum==lm_module
            polarplot(linspace(0,2*pi,360),a,'color',hcol(mph,:),'LineWidth',2);
            weights_module2(:,mph,tti)=a;
        else
            if mph==1
                polarplot(linspace(0,2*pi,360),a,'-k');
                weights_module1(:,modulenum,tti)=a;

            end
        end
        hold on;
    end
            title(trainingtime)

    tti=tti+1;
     
    
end
end
hhebb.Renderer='Painters';
cd(cp.datafolder);
% saveas(hhebb,'Fig4b_S9b_Hebb_weights_4mod_4phases_1e7lr_phasor','epsc')


weights_LM3_vismental = weights_LM3_vismental(:,:,[1 2 3 end]);
concat_matrix=[];
training_phase={'Early','middle','Late','wo_ext_input'};
for tti=1:4
    data=weights_LM3_vismental(:,:,tti);     
    data_cells=num2cell(data);     %Convert data to cell array
    col_header={'Module1','Module2','Module3','Module4'};     %Row cell array (for column labels)
    row_header(1:length(data),1)=training_phase(tti);     %Column cell array (for row labels)
    output_matrix=[{''} col_header; row_header data_cells];     %Join cell arrays
    concat_matrix = [concat_matrix output_matrix];
end
T=table(concat_matrix);
% writetable(T,'Fig4.xlsx','Sheet','fig_4b')


weights_module2 = weights_module2(:,:,[1 end]);
weights_module1 = weights_module1(:,:,[1 end]);
phase_xx=linspace(0,2*pi,360)'; 
concat_matrix=[]; 

training_phase={'initial','trained'};
for tti=1:2
    data=weights_module2(:,:,tti);     
    data_cells=num2cell(data);     %Convert data to cell array
    col_header={'model: LM@phase1','model: LM@phase2','model: LM@phase3','model: LM@phase4'};     %Row cell array (for column labels)
    row_header(1:length(data),1)=training_phase(tti);     %Column cell array (for row labels)
    output_matrix=[{''} col_header; row_header data_cells];     %Join cell arrays
    concat_matrix = [concat_matrix output_matrix];


end
concat_matrix{1}='neur_module=LM module=2';

for tti=1:2
    data=weights_module1(:,[1 3 4],tti);     
    data_cells=num2cell(data);     %Convert data to cell array
    col_header={'Module1','Module3','Module4'};     %Row cell array (for column labels)
    row_header(1:length(data),1)=training_phase(tti);     %Column cell array (for row labels)
    output_matrix=[{''} col_header; row_header data_cells];     %Join cell arrays
    concat_matrix = [concat_matrix output_matrix];


end
concat_matrix{1,11}='model: LM@phase1';
 
T=table(concat_matrix);
% writetable(T,'FigS9.xlsx','Sheet','fig_S9b_left')

%% CAN model weights S9c (20 modules)
cd(cp.datafolder)
load('Hebb_learn_sim_20mod_20mod_1phases_1e7lr.mat')
lm_phase=params.LM_phase;

for modules = 1:length(params.scale)
    temp=squeeze(weights(end,:,:,modules));
    [~,maxmod(:,modules)]=max(temp,[],2);
end

hhebb=figure;
plot(params.scale,params.scale(maxmod(lm_phase,:)),'-or','LineWidth',2); 
true_spatial_scale = params.scale';
learned_spatial_scale = params.scale(maxmod(lm_phase,:))';

xlabel 'true LM module'
ylabel 'learned LM module'
set(gca,'XTick',params.scale([1 10 15 20]),'XTickLabel',round(100*params.scale([1 10 15 20]))/100,'FontSize',15);
set(gca,'YTick',params.scale([1 10 15 20]),'YTickLabel',round(100*params.scale([1 10 15 20]))/100,'FontSize',15);
xlim([0 3]);axis square
hhebb.Renderer='Painters';grid on
cd(cp.datafolder)
% saveas(hhebb,'FigS9c_Hebb_weights_20modules_1e7lr_scatter','epsc')

hhebb=figure;
imagesc(squeeze(weights(end,:,:,15)));hold on
weights_module15 =squeeze(weights(end,:,:,15)); 

plot(15,params.module_phases,'k.','MarkerSize',20);
set(gca,'XTick',1:2:params.Nmodule, 'XTickLabel',round(100*params.scale(1:2:end))/100)
xlabel('Spatial scale (a.u.)');
ylabel('Phase (deg)');
set(gca,'FontSize',15);colorbar
caxis([-5 5]/1000)
hhebb.Renderer='Painters'; 
% saveas(hhebb,'FigS9c_Hebb_weights_20modules_1e7lr_15thmodule','epsc')

T=table(true_spatial_scale,learned_spatial_scale);
% writetable(T,'FigS9.xlsx','Sheet','fig_S9c_right')

% writematrix(weights_module15,'FigS9.xlsx','Sheet','fig_S9c_left')

%% CAN model weights Fig S9b, right (8 phases) 
cd(cp.datafolder)
load Hebb_learn_sim_4mod_8phases_1e7lr
module_phases = 30:45:360;
lm_module=params.LM_module;
nModule = params.Nmodule;
lm_off = find(outs{1}.vis2mental,1);
hcol = myrgb(length(module_phases),[1 0 0]);
hcolgray = myrgb(length(module_phases),[.5 .5 .5]);
hhebb=figure;
for mph = 1:length(module_phases)
    plot(squeeze(weights(:,module_phases(mph),lm_module,mph)),'color',hcol(mph,:));hold on
    plot(squeeze(weights(:,module_phases(mph),[1:lm_module-1 lm_module+1:nModule],mph)),'color',hcolgray(mph,:));hold on

    temp=squeeze(weights(end,:,:,mph));
    [~,maxphase(:,mph)]=max(temp,[],1);
end

plot(module_phases,maxphase(lm_module,:),'-or','LineWidth',2); hold on;
plot(module_phases,maxphase([1:lm_module-1 lm_module+1:nModule],:),'color',[.5,.5,.5]);
plot([0 400],[0 400],'--k','LineWidth',2);grid on;axis square
xlabel 'true LM phase'
ylabel 'learned LM phase'
set(gca,'XTick',module_phases(2:2:end),'YTick',module_phases(2:2:end),'FontSize',15);xlim([0 400])
cd(cp.datafolder);
hhebb.Renderer='Painters';grid on
% saveas(hhebb,'FigS9b_Hebb_weights_8phases_1e7lr','epsc')


true_module_phase = module_phases';
        eval(['learned_module_phase_by_appropriate_module' num2str(lm_module) '=maxphase(lm_module,:)'';']);
for moduleii=1:size(maxphase,1)
    if moduleii~=lm_module
        eval(['learned_module_phase_by_other_module' num2str(moduleii) '=maxphase(moduleii,:)'';']);
    end
end

T = table(true_module_phase,learned_module_phase_by_appropriate_module2,learned_module_phase_by_other_module1,...
    learned_module_phase_by_other_module3,learned_module_phase_by_other_module4);

% writetable(T,'FigS9.xlsx','Sheet','fig_S9b_right')


%% Fanofac CAN model Fig S9d
cd(cp.datafolder);
load ff_fr_dense_sampled_speed_wm2

wolm_speed=0;
sp=1;
binwidth=10;
len=2:binwidth:4e4;
maxlag=2000;
xx=-maxlag:maxlag;
xx1=xx(xx>0);
gridmax=1600;
gridlag=1:gridmax;

for    wlm_speed=speed_wlm(1:length(fano_speed))
    fanor=fano_speed{sp};
    meanfr =meanfr_speed{sp};
    clear pi_ffselect pi_frselect periodicity_ff periodicity_fr
    for select_units=1:364
        select_units
        frfanofac=nanmean(fanor(select_units,len),1);
        frmean=nanmean(meanfr(select_units,len),1);

        %detrend fanofac because var increases with time and this ramp masks
        %fanofac periodicity:
        mdl=fitlm(1:length(frfanofac),frfanofac);
        frfanofac=frfanofac-mdl.Coefficients.Estimate(2)*(1:length(frfanofac));

        %autocorr
        ffacg=xcorr(frfanofac ,maxlag,'coeff');
        meanacg=xcorr(frmean ,maxlag,'coeff');



        %periodicity FF select neurons
        clear gridness_tlag
        ii=1;x=ffacg(xx>0);
        for tlag = gridlag
            temp = corrcoef(x,circshift(x,round(tlag)))-corrcoef(x,circshift(x,round(.5*tlag)));
            gridness_tlag(ii)=temp(2);ii=ii+1;
        end
        pi_ffselect(select_units,:)=gridness_tlag;
        [~,periodicity] = max(gridness_tlag(gridlag<750));
        periodicity_ff(select_units)=gridlag(periodicity);
        acg_ff(select_units,:)=ffacg;

        %periodicity FR select neurons
        clear gridness_tlag
        ii=1;x=meanacg(xx>0);
        for tlag = gridlag
            temp = corrcoef(x,circshift(x,round(tlag)))-corrcoef(x,circshift(x,round(.5*tlag)));
            gridness_tlag(ii)=temp(2);ii=ii+1;
        end
        pi_frselect(select_units,:)=gridness_tlag;

        [~,periodicity] = max(gridness_tlag(gridlag<750));
        periodicity_fr(select_units)=gridlag(periodicity);
        acg_fr(select_units,:)=meanacg;

    end

    acg_speed_ff(sp,:,:)=acg_ff;
    acg_speed_fr(sp,:,:)=acg_fr;

    periodicity_speed_ff(sp,:)=periodicity_ff;
    periodicity_speed_fr(sp,:)=periodicity_fr;

    pi_speed_ff(sp,:,:)=pi_ffselect;
    pi_speed_fr(sp,:,:)=pi_frselect;

    
    sp=sp+1;
end



speed_wlm=speed_wlm(1:length(fano_speed));
figure('Position',[   476   117   950   749]);
hcol=myrgb(length(speed_wlm),[1 0 0]);

subplot(3,2,1)
imagesc(xx,1:364,squeeze(acg_speed_fr(end-5,:,:)));
set(gca,'XTick',0:650:3*650);
addline(0:650:3*650);
title 'FR acg at one speed'
set(gca,'FontSize',15);colorbar;caxis([-.25 1])

for sp=1:length(fano_speed)
    X=squeeze(mean(acg_speed_fr(sp,:,:),2));

    subplot(3,2,3)
    plot(xx,X,'color',hcol(sp,:));hold on;
    activation_acg(:,sp)=X;
    [~,locs]= findpeaks(X(xx>0),'MinPeakProminence',.1,'Annotate','extents');
    peakloc1fr(sp)=locs(1);

    peakloc2fr(sp)=locs(2);
    peaklocdifffr(sp)=locs(2)-locs(1);
sp
end
subplot(3,2,3)
set(gca,'XTick',0:650:3*650);
addline(0:650:3*650);
title ['FR: black=slowest speed']
xlabel lag(s)
ylabel 'acg coeff'
set(gca,'FontSize',15);

subplot(3,2,5)
plot(speed_wlm,peakloc2fr/2,'-or'); hold on
% plot(speed_wlm,peakloc1fr,'-xr');
% plot(speed_wlm,peaklocdifffr,'-*r')
activtiy_periodicity = peakloc2fr'/2;

set(gca,'FontSize',15);

xlabel speed
ylabel periodicity(s)
title FR
grid on
ylim([600 800]); 


subplot(3,2,2)
imagesc(xx,1:364,squeeze(acg_speed_ff(end-5,:,:)));
set(gca,'XTick',0:650:3*650);
addline(0:650:3*650);
title 'Fano acg at one speed'
set(gca,'FontSize',15);colorbar;caxis([-.25 1])


for sp=1:length(speed_wlm)
    X=squeeze(mean(acg_speed_ff(sp,:,:),2));

    subplot(3,2,4)
    plot(xx,X,'color',hcol(sp,:));hold on;
    fanofac_acg(:,sp)=X;

   [~,locs]= findpeaks(X(xx>0),'MinPeakProminence',.1,'Annotate','extents');

      peakloc1ff(sp)=locs(1);

   peakloc2ff(sp)=locs(2);
              peaklocdiffff(sp)=locs(2)-locs(1);
sp
speed_header{sp}=num2str(sp);
end
subplot(3,2,4)
set(gca,'XTick',0:650:3*650,'FontSize',15);
addline(0:650:3*650);
title 'FF: black=slowest speed'
xlabel lag(s); ylabel 'acg coeff'

subplot(3,2,6)
plot(speed_wlm,peakloc2ff/2,'-ob'); hold on
fanofac_periodicity = peakloc2ff'/2;

% plot(speed_wlm,peakloc1ff,'-xb');hold on
% plot(speed_wlm,peaklocdiffff,'-*b');hold on
xlabel speed
ylabel periodicity(s)
title FF
grid on;
ylim([600 800]); 
set(gca,'FontSize',15);
% legend('pkloc1','pkloc2')
% saveas(gcf,['FR vs fanofac periodicity at densely sampled speeds_wm2.png'])
hf=gcf;
hf.Renderer='painters';
cd(cp.datafolder);
% saveas(hf,'FigS9d_CAN_model_fanofactor_densely_sampled_speeds_wm2','epsc')

speed_input = speed_wlm';
T =table(speed_input,activtiy_periodicity,fanofac_periodicity);
% writetable(T,'FigS9.xlsx','Sheet','fig_S9d_right')


lags=xx';
data=activation_acg;
data_cells=num2cell(data);
speed_header=num2cell(1:sp);
output_matrix=[ {'lags-speed for activation ACG'} speed_header; num2cell(lags)  data_cells];
T=table(output_matrix);
% writetable(T,'FigS9.xlsx','Sheet','fig_S9d_middle')

data=fanofac_acg;
data_cells=num2cell(data);
output_matrix=[ {'lags-speed for fanofac ACG'} speed_header; num2cell(lags)  data_cells];
T=table(output_matrix);
% writetable(T,'FigS9.xlsx','Sheet','fig_S9d_middle','Range','Y1')


%% Fano factor EC neurons Fig 4h and S11
% SUPP S11c,d plot fano factor periodicitiy index for sig periodic fanofac: DONE seq12
param.animal='amadeus';
param.area='EC';
param.whichimac = 'Sujay';
param.getdata=cp.datafolder;
param.getgridnessdata=cp.datafolder_fig2; 
cd(param.getdata)
range=250; %250ms used in the paper, but results are the same for 350ms 
load([param.animal '_' param.area '_fanofac_bb_cutoff' num2str(2.3*1000) 'ms_poissonNull_gridnessat650_range_' num2str(range) '.mat'],'fano','params');
ylimm=.3;
mintr=15;
cd(param.getgridnessdata)
load([param.animal '_' param.area '_periodicity_js_leftright_dist345_seq12.mat'], 'gridness')
params.gridness_thres_pc_abov_mean=.1576;

fano_cells_periodicityl=[];nonfano_cells_periodicityl=[];
fano_cells_periodicityr=[];nonfano_cells_periodicityr=[];
fano_cells_periodicityloff=[];nonfano_cells_periodicityloff=[];
fano_cells_periodicityroff=[];nonfano_cells_periodicityroff=[];

for ss=1:size(gridness,1)
    
    gridness_=gridness{ss,1};
    if isempty(gridness_) || ~isfield(gridness_,'pc_above_mean_gridness'),disp 'no gridness for this session'; return;end
    grid_cells1=(gridness_.pc_above_mean_gridness>params.gridness_thres_pc_abov_mean &  gridness_.num_trials_mve(:,1)'>mintr);
    gridness_=gridness{ss,2};
    grid_cells2=(gridness_.pc_above_mean_gridness>params.gridness_thres_pc_abov_mean &  gridness_.num_trials_mve(:,1)'>mintr);
    grid_cells = or(grid_cells1,grid_cells2);%unique([grid_cells1 grid_cells2]);
    
    
    dir=1;
    if isfield(fano{ss,dir},'on')
        dd=length(grid_cells1)-length(fano{ss,dir}.on.ffgridness650);%append fanofac cells with 0s
        fano{ss,dir}.on.ffgridness650(end+1:end+dd)=0;
        fano{ss,dir}.on.periodicity_kstest(end+1:end+dd)=0;
        fano{ss,dir}.on.modeperiodicity(end+1:end+dd)=0;
        fano{ss,dir}.on.modeperiodicityNULL(end+1:end+dd)=0;
        
        ggl=fano{ss,dir}.on.ffgridness650==1 ; %grid_cells1==1;
        fano_cells_periodicityl=[fano_cells_periodicityl fano{ss,dir}.on.modeperiodicity(ggl)];
        nonfano_cells_periodicityl=[nonfano_cells_periodicityl  fano{ss,dir}.on.modeperiodicityNULL(ggl)];
        
        dd=length(grid_cells1)-length(fano{ss,dir}.off.ffgridness650);
        fano{ss,dir}.off.ffgridness650(end+1:end+dd)=0;
        fano{ss,dir}.off.periodicity_kstest(end+1:end+dd)=0;
        fano{ss,dir}.off.modeperiodicity(end+1:end+dd)=0;
        fano{ss,dir}.off.modeperiodicityNULL(end+1:end+dd)=0;
        
        ggl=fano{ss,dir}.off.ffgridness650==1 ; %grid_cells1==1;
        fano_cells_periodicityloff=[fano_cells_periodicityloff fano{ss,dir}.off.modeperiodicity(ggl)];
        nonfano_cells_periodicityloff=[nonfano_cells_periodicityloff  fano{ss,dir}.off.modeperiodicityNULL(ggl)];
        
    end
    
    
    dir=2;
    if isfield(fano{ss,dir},'on')
        dd=length(grid_cells1)-length(fano{ss,dir}.on.ffgridness650);
        fano{ss,dir}.on.ffgridness650(end+1:end+dd)=0;
        fano{ss,dir}.on.periodicity_kstest(end+1:end+dd)=0;
        fano{ss,dir}.on.modeperiodicity(end+1:end+dd)=0;
        fano{ss,dir}.on.modeperiodicityNULL(end+1:end+dd)=0;
        
        ggr=fano{ss,dir}.on.ffgridness650==1 ; %grid_cells1==1;
        fano_cells_periodicityr=[fano_cells_periodicityr fano{ss,dir}.on.modeperiodicity(ggr)];
        nonfano_cells_periodicityr=[nonfano_cells_periodicityr  fano{ss,dir}.on.modeperiodicityNULL(ggr)];
        
        dd=length(grid_cells1)-length(fano{ss,dir}.off.ffgridness650);
        fano{ss,dir}.off.ffgridness650(end+1:end+dd)=0;
        fano{ss,dir}.off.periodicity_kstest(end+1:end+dd)=0;
        fano{ss,dir}.off.modeperiodicity(end+1:end+dd)=0;
        fano{ss,dir}.off.modeperiodicityNULL(end+1:end+dd)=0;
        
        ggr=fano{ss,dir}.off.ffgridness650==1 ; %grid_cells1==1;
        fano_cells_periodicityroff=[fano_cells_periodicityroff fano{ss,dir}.off.modeperiodicity(ggr)];
        nonfano_cells_periodicityroff=[nonfano_cells_periodicityroff  fano{ss,dir}.off.modeperiodicityNULL(ggr)];
    end
    
end


nonfano_cells_periodicityr(nonfano_cells_periodicityr<.1)=[];
fano_cells_periodicityr(fano_cells_periodicityr<.1)=[];
nonfano_cells_periodicityl(nonfano_cells_periodicityl<.1)=[];
fano_cells_periodicityl(fano_cells_periodicityl<.1)=[];

nonfano_cells_periodicityroff(nonfano_cells_periodicityroff<.1)=[];
fano_cells_periodicityroff(fano_cells_periodicityroff<.1)=[];
nonfano_cells_periodicityloff(nonfano_cells_periodicityloff<.1)=[];
fano_cells_periodicityloff(fano_cells_periodicityloff<.1)=[];


figure
subplot(2,2,1);
histogram(fano_cells_periodicityl,0:.07:1.2,'normalization','probability' );hold on;
histogram(nonfano_cells_periodicityl,0:.07:1.2,'normalization','probability' )
set(gca,'Xtick',0:.65:1.200,'FontSize',10);
title (['onset DIR: Left #=' num2str(length(fano_cells_periodicityl))]); xlabel Periodicity; ylabel Probab
ylim([0 ylimm])
addline([.65-range .65 .65+range],'color','k');addline(nanmean(fano_cells_periodicityl),'color','r');grid on;

subplot(2,2,2);
histogram(fano_cells_periodicityr,0:.07:1.2,'normalization','probability' );hold on;
histogram(nonfano_cells_periodicityr,0:.07:1.2,'normalization','probability' )
set(gca,'Xtick',0:.65:1.200,'FontSize',10);
title (['onset DIR: Right #=' num2str(length(fano_cells_periodicityr))]); xlabel Periodicity; ylabel Probab
ylim([0 ylimm])
addline([.65-range .65 .65+range],'color','k');addline(nanmean(fano_cells_periodicityr),'color','r');grid on;
legend('data','NULL','','','','')

subplot(2,2,3);
histogram(fano_cells_periodicityloff,0:.07:1.2,'normalization','probability' );hold on;
histogram(nonfano_cells_periodicityloff,0:.07:1.2,'normalization','probability' )
set(gca,'Xtick',0:.65:1.200,'FontSize',10);
title (['offset DIR: Left #=' num2str(length(fano_cells_periodicityloff))]); xlabel Periodicity; ylabel Probab
ylim([0 ylimm])
addline([.65-range .65 .65+range],'color','k');addline(nanmean(fano_cells_periodicityloff),'color','r');grid on;

subplot(2,2,4);
histogram(fano_cells_periodicityroff,0:.07:1.2,'normalization','probability' );hold on;
histogram(nonfano_cells_periodicityroff,0:.07:1.2,'normalization','probability' )
set(gca,'Xtick',0:.65:1.200,'FontSize',10);
title (['offset DIR: Right #=' num2str(length(fano_cells_periodicityroff))]); xlabel Periodicity; ylabel Probab
ylim([0 ylimm])
addline([.65-range .65 .65+range],'color','k');addline(nanmean(fano_cells_periodicityroff),'color','r');grid on;
legend('data','NULL','','','','')

sgtitle([params.animal ' ' params.area ' fano fac pop'])
hf=gcf;
hf.Renderer='Painters';
cd(cp.datafolder)
% saveas(hf,['Supp_11d_' params.animal '_' params.area '_fanofac_pop_gridnessat650_range_' num2str(range)],'epsc');

switch params.animal
    case 'amadeus'
            sheet = 'fig_S11f';
    case 'mahler'
            sheet = 'fig_S11c';

end

histogram_edges=(0:.07:1.2)';
T=table(histogram_edges); 
% writetable(T,'FigS11.xlsx','Sheet',sheet)

fanofac_periodicity_JSleft=fano_cells_periodicityl';
T=table(fanofac_periodicity_JSleft); 
% writetable(T,'FigS11.xlsx','Sheet',sheet,'Range','B1')

fanofac_periodicity_JSleft_POISSON_NULL=nonfano_cells_periodicityl';
T=table(fanofac_periodicity_JSleft_POISSON_NULL); 
% writetable(T,'FigS11.xlsx','Sheet',sheet,'Range','C1')

fanofac_periodicity_JSright=fano_cells_periodicityr';
T=table(fanofac_periodicity_JSright); 
% writetable(T,'FigS11.xlsx','Sheet',sheet,'Range','D1')

fanofac_periodicity_JSright_POISSON_NULL=nonfano_cells_periodicityr';
T=table(fanofac_periodicity_JSright_POISSON_NULL); 
% writetable(T,'FigS11.xlsx','Sheet',sheet,'Range','E1')



%% Fig S10: Kinkabhwala et al eLife 2020 re-analysis

cd(cp.datafolder);
load('simultaneous_neurons_Kinkhabwala.mat')
fr=trxtrfiring_rate;
maxlag = 600*binwidth;
nni=1;dnni=1;
for ss=1:length(fr)
    
    for nn=1:numneur(ss)
        for mm=nn+1:numneur(ss)
            clear xcorr_regA xcorr_regB xcorr_zero_regA xcorr_zero_regB
            for run=1:length(fr{ss}.frvis{1}.time_regA_start)
                tt=fr{ss}.frvis{1}.binedges_sec;
                
                att = tt>fr{ss}.frvis{1}.time_regA_start(run) & tt<fr{ss}.frvis{1}.time_regA_end(run) ;
                btt = tt>fr{ss}.frvis{1}.time_regB_start(run) & tt<fr{ss}.frvis{1}.time_regB_end(run) ;
                %          wolmtt_equallength = tt>fr{ss}.frvis{1}.time_regB_start(run) & tt<fr{ss}.frvis{1}.time_regB_end(run) ;
                
                
                fr1=fr{ss}.frvis{nn}.spiketime_fr(run,att);
                fr2=fr{ss}.frvis{mm}.spiketime_fr(run,att);
                
                xcorr_regA(run,:)=xcorr(fr1-nanmean(fr1),fr2-nanmean(fr2),maxlag,'coeff');
                xcorr_zero_regA(run)=xcorr(fr1-nanmean(fr1),fr2-nanmean(fr2),0,'coeff');
                
                fr1=fr{ss}.frvis{nn}.spiketime_fr(run,btt);
                fr2=fr{ss}.frvis{mm}.spiketime_fr(run,btt);
                
                xcorr_regB(run,:)=xcorr(fr1-nanmean(fr1),fr2-nanmean(fr2),maxlag,'coeff');
                xcorr_zero_regB(run)=xcorr(fr1-nanmean(fr1),fr2-nanmean(fr2),0,'coeff');
                
                
                
               
            end
            
            xcorr_lags_regA(nni,:)=nanmean(xcorr_regA,1);
            xcorr_0_regA(nni)=nanmean(xcorr_zero_regA);
            
            
            xcorr_lags_regB(nni,:)=nanmean(xcorr_regB,1);
            xcorr_0_regB(nni)=nanmean(xcorr_zero_regB);
            
            
            sess(nni)=ss;
            neurid(nni,:)=[nn mm];
            nni=nni+1;
        end
    end
    
    
    for nn=1:numneur(ss)
        for mm=nn+1:numneur(ss)
            clear mxcorr_regA mxcorr_regB mxcorr_zero_regA mxcorr_zero_regB
            for run=1:length(fr{ss}.frdis{1}.time_regA_start)
                tt=fr{ss}.frdis{1}.binedges_sec;
                
                att = tt>fr{ss}.frdis{1}.time_regA_start(run) & tt<fr{ss}.frdis{1}.time_regA_end(run) ;
                btt = tt>fr{ss}.frdis{1}.time_regB_start(run) & tt<fr{ss}.frdis{1}.time_regB_end(run) ;
                %          wolmtt_equallength = tt>fr{ss}.frvis{1}.time_regB_start(run) & tt<fr{ss}.frvis{1}.time_regB_end(run) ;
                
                
                fr1=fr{ss}.frdis{nn}.spiketime_fr(run,att);
                fr2=fr{ss}.frdis{mm}.spiketime_fr(run,att);
                
                mxcorr_regA(run,:)=xcorr(fr1-nanmean(fr1),fr2-nanmean(fr2),maxlag,'coeff');
                mxcorr_zero_regA(run)=xcorr(fr1-nanmean(fr1),fr2-nanmean(fr2),0,'coeff');
                
                fr1=fr{ss}.frdis{nn}.spiketime_fr(run,btt);
                fr2=fr{ss}.frdis{mm}.spiketime_fr(run,btt);
                
                mxcorr_regB(run,:)=xcorr(fr1-nanmean(fr1),fr2-nanmean(fr2),maxlag,'coeff');
                mxcorr_zero_regB(run)=xcorr(fr1-nanmean(fr1),fr2-nanmean(fr2),0,'coeff');
                
                
                
               
            end
            
            mxcorr_lags_regA(dnni,:)=nanmean(mxcorr_regA,1);
            mxcorr_0_regA(dnni)=nanmean(mxcorr_zero_regA);
            
            
            mxcorr_lags_regB(dnni,:)=nanmean(mxcorr_regB,1);
            mxcorr_0_regB(dnni)=nanmean(mxcorr_zero_regB);
            
            
            dsess(dnni)=ss;
            dneurid(dnni,:)=[nn mm];
            dnni=dnni+1;
        end
    end
    
 
end

xxc=linspace(-maxlag/binwidth,maxlag/binwidth,size(xcorr_lags_regA,2))/1000;

figure('Position',[ 1386          90         638         959]);
% [maxx,sortid]=sort( max(xcorr_lags_regA,[],2),'descend' );
[maxx,sortid]=sort( xcorr_0_regB,'descend' );

subplot(3,2,1);
imagesc(xxc,1:length(sortid),xcorr_lags_regA(sortid,:));caxis([-.2 .2]);addline(0,'color','k');
xlabel lag(s); ylabel 'cell pairs'; title 'regA visual';set(gca,'FontSize',12); 
subplot(3,2,3);
imagesc(xxc,1:length(sortid),xcorr_lags_regB(sortid,:));caxis([-.2 .2]);addline(0,'color','k');
xlabel lag(s); ylabel 'cell pairs'; title 'regB visual: sorted by this';set(gca,'FontSize',12); 

subplot(3,2,5);
scatter(xcorr_0_regB,xcorr_0_regA,10,'ok','Filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);hold on;
plot([-.5 .5],[-.5 .5],'-k');grid on;axis([-.5 .5 -.5 .5]);set(gca,'FontSize',12); 
 xlabel 'xcorr coeff for regB visual' ; ylabel 'xcorr coeff for regA visual'

subplot(3,2,2);
imagesc(xxc,1:length(sortid),mxcorr_lags_regA(sortid,:));caxis([-.2 .2]);addline(0,'color','k');
xlabel lag(s); ylabel 'cell pairs'; title 'regA in regB occluded trials';set(gca,'FontSize',12); 

subplot(3,2,4);
imagesc(xxc,1:length(sortid),mxcorr_lags_regB(sortid,:));caxis([-.2 .2]);addline(0,'color','k');
xlabel lag(s); ylabel 'cell pairs'; title 'regB in reg B occluded trials';set(gca,'FontSize',12); 

subplot(3,2,6);
 scatter(xcorr_0_regB,mxcorr_0_regB,10,'ok','Filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);hold on;
plot([-.5 .5],[-.5 .5],'-k');grid on;axis([-.5 .5 -.5 .5]);set(gca,'FontSize',12); 
 xlabel 'xcorr coeff for regB visual' ; ylabel 'xcorr coeff for regB occluded'


 mcorr=bootstrp(100,@corr,xcorr_0_regB,mxcorr_0_regB);
 vcorr=bootstrp(100,@corr,xcorr_0_regB,xcorr_0_regA);
 
 [h,pval,~,stats]=ttest2(vcorr,mcorr,'Tail','right');
 title(['bstrp corr 2 samp ttest( ' num2str(stats.df) ')=' num2str(stats.tstat) ', p=' num2str(pval) ])

 sgtitle (['Kinkhabwala 2020 eLife visual cue cells xcorr analysis'])

 cd(cp.datafolder)
 hf=gcf;
 hf.Renderer = 'Painters';
%  saveas(hf,'FigS10_xcorr_analysis_AminaData','epsc');

 xcorr_regionB_visible = xcorr_0_regB';
 xcorr_regionA_visible = xcorr_0_regA';
 xcorr_regionB_invisible =mxcorr_0_regB';

 T =table(xcorr_regionB_visible,xcorr_regionA_visible, xcorr_regionB_invisible);

%  writetable(T,'FigS10.xlsx','Sheet','fig_S10c')

%% Fig S12 BLS model self-consistency: 

ts_=repmat(.65:.65:3.25,[1 100]);
modelparams=[.15 .2 .01];
savefolder=cp.datafolder;
mdl_filenames=get_mdl_names() ;
run_bls_models=0;

if run_bls_models==0,load([savefolder '/FigS12_model_identifiability_simulation.mat']);end

for bb=1:100
    for modelgen = [1 2]

        if run_bls_models==1,eval(['[tp_gen,  gen_model_type]=' mdl_filenames{modelgen} '(ts_,modelparams,[],[]);']);end
        for modelfit = [1 2]
            if run_bls_models==1, eval(['[~,mdl_fit_out{modelgen,modelfit,bb}]=' mdl_filenames{modelfit} '(ts_,[],tp_gen,gen_model_type,savefolder);']);end
            mse(modelgen,modelfit,bb)=mdl_fit_out{modelgen,modelfit,bb}.mse_bias_var;
            negloglik(modelgen,modelfit,bb)=mdl_fit_out{modelgen,modelfit,bb}.negloglik;
            bic(modelgen,modelfit,bb)=mdl_fit_out{modelgen,modelfit,bb}.bic;
            w_model(modelgen,modelfit,:,bb)=mdl_fit_out{modelgen,modelfit,bb}.w;
            close (gcf)
        end
    end
end



hsim=figure('Position',[ 93          56        1401         993]); 
subplot(3,3,1);
bar(1:2,mean(mse(:,1,:),3)); hold on ; set(gca,'FontSize',15);
errorbar(1:2,mean(mse(:,1,:),3),std(mse(:,1,:),[],3),'ok','LineWidth',2)
bar(4:5,mean(mse(:,2,:),3)); set(gca,'XTickLabel',{'counting','timing'})
errorbar(4:5,mean(mse(:,2,:),3),std(mse(:,2,:),[],3),'ok','LineWidth',2)
ylabel 'MSE (data-model)'; xlabel 'fitted models'
set(gca,'XTick',1:5,'XTickLabel',{'counting','timing','','counting','timing'})
legend('gen model: counting','','timing','','Location','NorthWest');

subplot(3,3,4);
bar(1:2,mean(bic(:,1,:),3)); hold on ; set(gca,'FontSize',15);
errorbar(1:2,mean(bic(:,1,:),3),std(bic(:,1,:),[],3),'ok','LineWidth',2)
bar(4:5,mean(bic(:,2,:),3)); set(gca,'XTickLabel',{'counting','timing'})
errorbar(4:5,mean(bic(:,2,:),3),std(bic(:,2,:),[],3),'ok','LineWidth',2)
ylabel 'BIC'; xlabel 'fitted models'
set(gca,'XTick',1:5,'XTickLabel',{'counting','timing','','counting','timing'})
 

subplot(3,3,2);
histogram(mse(1,1,:),0:.05:.7); hold on 
histogram(mse(1,2,:),0:.05:.7); set(gca,'FontSize',15);
title 'gen model: counting'
legend('counting','timing')
xlabel MSE
gen_model_with_reset_MSE_fitmodel_with_reset = squeeze(mse(1,1,:));
gen_model_with_reset_MSE_fitmodel_wo_reset = squeeze(mse(1,2,:));



subplot(3,3,3);
histogram(mse(2,1,:),0:.05:.7); hold on 
histogram(mse(2,2,:),0:.05:.7); set(gca,'FontSize',15);
title 'gen model: timing'
legend('counting','timing')
xlabel MSE
gen_model_wo_reset_MSE_fitmodel_with_reset = squeeze(mse(2,1,:));
gen_model_wo_reset_MSE_fitmodel_wo_reset = squeeze(mse(2,2,:));

subplot(3,3,5);
histogram(w_model(1,1,2,:),.1:.01:.4); hold on 
histogram(w_model(1,2,2,:),.1:.01:.4); set(gca,'FontSize',15);
addline(modelparams(2),'color','k');
title 'gen model: counting'
legend('counting','timing','')
xlabel wp
gen_model_with_reset_wp_fitmodel_with_reset = squeeze(w_model(1,1,2,:));
gen_model_with_reset_wp_fitmodel_wo_reset = squeeze(w_model(1,2,2,:));

subplot(3,3,6);
histogram(w_model(2,1,2,:),.1:.01:.4); hold on 
histogram(w_model(2,2,2,:),.1:.01:.4);set(gca,'FontSize',15);
addline(modelparams(2),'color','k');
title 'gen model: timing'
legend('counting','timing','')
xlabel wp 
gen_model_wo_reset_wp_fitmodel_with_reset = squeeze(w_model(2,1,2,:));
gen_model_wo_reset_wp_fitmodel_wo_reset = squeeze(w_model(2,2,2,:));



subplot(3,3,8);
histogram(w_model(1,1,1,:),.1:.01:.4); hold on 
histogram(w_model(1,2,1,:),.1:.01:.4); set(gca,'FontSize',15);
addline(modelparams(1),'color','k');
title 'gen model: counting'
legend('counting','timing','')
xlabel wm

subplot(3,3,9);
histogram(w_model(2,1,1,:),.1:.01:.4); hold on 
histogram(w_model(2,2,1,:),.1:.01:.4);set(gca,'FontSize',15);
addline(modelparams(1),'color','k');
title 'gen model: timing'
legend('counting','timing','')
xlabel wm 
 
cd(savefolder);
sgtitle ('Model simulation and identifiability')
hsim.Renderer='Painters';
% saveas(hsim,'FigS12_model_identifiability_100simulations','epsc');
% save('FigS12_model_identifiability_simulation.mat','mdl_fit_out','modelparams');

% save data for paper
T=table(gen_model_with_reset_MSE_fitmodel_with_reset,gen_model_with_reset_MSE_fitmodel_wo_reset, ...
    gen_model_wo_reset_MSE_fitmodel_with_reset,gen_model_wo_reset_MSE_fitmodel_wo_reset,...
    gen_model_with_reset_wp_fitmodel_with_reset,gen_model_with_reset_wp_fitmodel_wo_reset,...
   gen_model_wo_reset_wp_fitmodel_with_reset,gen_model_wo_reset_wp_fitmodel_wo_reset );

% writetable(T,'FigS12.xlsx')

%% Fig 4g get BLS modeling summary results

animal = 'amadeus';
% mdl_comp=get_bls_mdl_comparison(animal,cp);
animal = 'mahler';
mdl_comp=get_bls_mdl_comparison(animal,cp);



%% functions
function [hsim,hvar,T] = get_simul_variance(wmm,sp,datafolder,linnonlinfit)
base_time=.65:.65:3.25;
cd (datafolder);
load(['int_5lms_60deg_wm' num2str(wmm*100) '_vb' num2str(sp(1)) '_' num2str(sp(2)) '_run1'])

RTs_w = cellfun('length',traj_wint);
RTs_wo = cellfun('length',traj_wolm);

maxlengthw=max(RTs_w);
maxlengthwo=max(RTs_wo);

for isim=1:length(traj_wint)

    temp=traj_wint{isim};
    temp(end:maxlengthw)=nan;
    trajw_nanmat(isim,:)=temp;


    temp=traj_wolm{isim};
    temp(end:maxlengthwo)=nan;
    trajwo_nanmat(isim,:)=temp;

end

median_traj_w=nanmedian(trajw_nanmat,1);
tt=(1:maxlengthw)/20000;
tto=(1:maxlengthwo)/20000;

ii=1;
for base_t = base_time
    state_baset(ii)=median_traj_w(find(tt>base_t,1));
    ii=ii+1;
end


figure;
plot(tto,trajwo_nanmat,'k','LineWidth',1); hold on;
plot(tt,trajw_nanmat,'r','LineWidth',1);
 
plot(tto,median(trajwo_nanmat,1),'c','LineWidth',2); hold on;
plot(tt,median(trajw_nanmat,1),'m','LineWidth',2);

addline(state_baset,'h');
set(gca,'XTick',[.65:.65:3.25],'YTick',[0:45:390]);grid on


errorbar(mean(RTs_w)/20000,NN.end_state+5,std(RTs_w/20000)*2,'r','horizontal','LineWidth',3)
errorbar(mean(RTs_wo)/20000,NN.end_state+10,std(RTs_wo/20000)*2,'k','horizontal','LineWidth',3)
 
set(gca,'FontSize',15);
addline(mean(RTs_w)/20000,'color','r');
addline(mean(RTs_wo)/20000,'color','k');
 xlabel 'time(s)'
ylabel 'state(deg)'
hsim=gcf;
h2.Renderer='Painters';
filename=(['int 5lms 60deg wm' num2str(wmm*100) ' vb ' num2str(sp) ' simul']);
sgtitle(filename)

time_woReset = tto(1:100:end)';
trajectory_woReset = trajwo_nanmat(:,1:100:end)';
T.trajecwo=table(time_woReset,trajectory_woReset);

time_withReset = tt(1:100:end)';
trajectory_withReset = trajw_nanmat(:,1:100:end)';
T.trajecwith=table(time_withReset,trajectory_withReset);

meanRT_withReset=mean(RTs_w)/20000;
stdRT_withReset=std(RTs_w/20000); 
meanRT_woReset=mean(RTs_wo)/20000;
stdRT_woReset=std(RTs_wo/20000); 
T.meanstdRT = table(meanRT_withReset,stdRT_withReset,meanRT_woReset,stdRT_woReset);


% CAN model variance quanti Fig 4d 

for isim=1:length(traj_wint)
    for ii = 1:length(state_baset)
        rt_w(isim,ii)= find(traj_wint{isim}>=state_baset(ii),1)/20000;
    end
end

for ii=1:length(base_time)

    for isim=1:length(traj_wolm)

        rt_wo(isim,ii)= find(traj_wolm{isim}>=state_baset(ii),1)/20000;
    end

    rt_bootw(ii,:) = bootstrp(1000,@std,rt_w(:,ii));
    rt_bootwo(ii,:) = bootstrp(1000,@std,rt_wo(:,ii));

    rt_bootwmean(ii,:) = bootstrp(1000,@mean,rt_w(:,ii));
    rt_bootwomean(ii,:) = bootstrp(1000,@mean,rt_wo(:,ii));

end

figure('Position',[ 476   275   607   591]);
subplot 121
errorbar(base_time,mean(rt_bootwo,2),std(rt_bootwo,[],2),std(rt_bootwo,[],2),'-ok');grid on;hold on
errorbar(base_time,mean(rt_bootw,2),std(rt_bootw,[],2),std(rt_bootw,[],2),'-or');
set(gca,'XTick',base_time,'FontSize',15);xlim([0 .65*6])
xlabel 'base interval(s)'
ylabel 'std of produced time (s)'
subplot 122
errorbar(base_time,mean(rt_bootwomean,2),std(rt_bootwomean,[],2),std(rt_bootwomean,[],2),'-ok');grid on;hold on
errorbar(base_time,mean(rt_bootwmean,2),std(rt_bootwmean,[],2),std(rt_bootwmean,[],2),'-or');

set(gca,'XTick',base_time,'YTick',base_time,'FontSize',15);axis([0 .65*6 0 .65*6])
xlabel 'base interval(s)'
ylabel 'mean produced time(s)'
sgtitle(wmm)

hvar=gcf;
h2.Renderer='Painters';

sgtitle(filename)

%save data for paper: 
base_time=base_time';
meanRT_withReset=mean(rt_bootw,2);
stdRT_withReset=std(rt_bootw,[],2); 
meanRT_woReset=mean(rt_bootwo,2);
stdRT_woReset=std(rt_bootwo,[],2); 
T.meanstdRT_atbasetimes = table(base_time,meanRT_withReset,stdRT_withReset,meanRT_woReset,stdRT_woReset);

mean_produced_RT_withReset=mean(rt_bootwmean,2);
std_produced_RT_withReset=std(rt_bootwmean,[],2); 
mean_produced_RT_woReset=mean(rt_bootwomean,2);
std_produced_RT_woReset=std(rt_bootwomean,[],2); 
T.meanstd_produced_RT_atbasetimes = table(base_time,mean_produced_RT_withReset,std_produced_RT_withReset,...
    mean_produced_RT_woReset,std_produced_RT_woReset);


% quantification of variance reduction 
if linnonlinfit==1
    for bb=1:size(rt_bootwo,2)
        xdata= rt_bootwmean(:,bb);
        ydata= rt_bootw(:,bb);

        fun = @(x,xdata)x(1)*xdata.^x(2); %non linear function
        funlin = @(xlin,xdata)xlin(1)*xdata; %linear function

        x0 = [1/2,1/2];%initial conditions of params
        [x,resnorm(bb)] = lsqcurvefit(fun,x0,xdata,ydata); %LSQ nonlin curve fit
        exphat(bb) = x(2);
        [xlin(bb),resnormlin(bb)] = lsqcurvefit(funlin,1,xdata,ydata);%linear fit

    end
    [h,pval,ci,tstat]=ttest(exphat,1,'Tail','left');
    title(['left tailed ttest, t(' num2str(tstat.df) ')=' num2str(tstat.tstat) ', pval=' num2str(pval)  ])
    set(gca,'FontSize',15)
end

end

function [mdl_comp]=get_bls_mdl_comparison(animal,cp)

load([cp.datafolder '/Fig4g_' animal '_mse_data.mat']);

iisorted=[  2:4:16 3:4:16  4:4:16 1:4:16 17 18];

herr=figure('Position',[286         103        1603         954]);
hwp=figure('Position',[286         103        1603         954]);
kk=1;
for ii=iisorted
        figure(herr);
        bar(kk,mean(all_mse(:,ii)),'b');hold on
    plot(kk,all_mse(:,ii),'og');
        errorbar(kk,mean(all_mse(:,ii)),std(all_mse(:,ii))/sqrt(length(all_mse)),'ok');
    if kk<5, xlabels{kk}=mdl{ii}.type(1:11);
    elseif kk<13, xlabels{kk}=mdl{ii}.type(1:10);
    elseif kk==13 xlabels{kk}=mdl{ii}.type(1:7);
    elseif kk==14,xlabels{kk}=[mdl{ii}.type(1:7) ' joystick'];
    elseif kk==15,xlabels{kk}=[mdl{ii}.type(1:7) ' obs-act'];
    elseif kk==16,xlabels{kk}=[mdl{ii}.type(1:7) ' obs-act joystick'];
    elseif kk==17, xlabels{kk}=[mdl{ii}.type(1:7) ' ord-lik non-counter'];
    elseif kk==18, xlabels{kk}=[mdl{ii}.type(1:7) ' ord-lik counter@tp'];
    else %new model??'
    end
    figure(hwp);subplot(5,5,kk);
    histogram(all_wp(:,ii),0:.05:.7); title(xlabels{kk});xlim([0 .75]);ylim([0 40])
    addline(mean(all_wp(:,ii)),'color','k');xlabel wp; ylabel #sessions
    
    kk=kk+1;
end

figure(herr);
ylabel ('Model mse - Data mse')
set(gca,'Xtick',[1:18]);
set(gca,'XtickLabel',xlabels');
xtickangle(-45);
set(gca,'FontSize',20)
sgtitle([animal ' # of sessions ' num2str(length(all_mse))])
ylim([0 1])

% scatter plot of MSE for two models

mdl_h1=10; %timing model
mdl_h2=12; %counting@tp model
mdltype_h1 = mdl{mdl_h1}.type;
mdltype_h2 = mdl{mdl_h2}.type;
suffix = 'counter_at_tp_obsact';

mdl_comp.comparison = 'counter@tp(mdl4) vs non-counter(mdl2)';
[mdl_comp.h,mdl_comp.pval,mdl_comp.ci,mdl_comp.stats]=ttest2(all_mse(:,mdl_h1),all_mse(:,mdl_h2));



switch animal(1) %These numbers denote physiology sessions highlighted on the plots as red circles
    case 'a'
        ec_sess=[[34:37 43 44 45 49:54]];

    case 'm'
        ec_sess=[79:86 94 95 97 101 102];

end

figure('Position',[744   273   965   776]);
subplot(2,2,1);
histogram(all_mse(:,mdl_h1),15);hold on;
histogram(all_mse(:,mdl_h2),15);
xlabel mse; ylabel #sessions
legend('timing','counting')

subplot(2,2,3);
scatter(all_mse(:,mdl_h1),all_mse(:,mdl_h2),'ob','Filled'); 
xlabel 'timing MSE'; ylabel 'MNAV MSE';hold on
plot([0 3],[0 3],'-k');grid on
scatter(all_mse(ec_sess,mdl_h1),all_mse(ec_sess,mdl_h2),100,'or'); 

subplot(2,2,4);
scatter(all_mse(:,mdl_h1),all_mse(:,mdl_h2),'ob','Filled'); 
xlabel 'timing MSE'; ylabel 'MNAV MSE';hold on
plot([0 3],[0 3],'-k');grid on
 axis([0 1.5 0 1.5])
% scatter(all_mse(ec_sess,mdl_h1),all_mse(ec_sess,mdl_h2),100,'or'); 

subplot(2,2,2);
cdfplot(all_mse(:,mdl_h1));hold on;
cdfplot(all_mse(:,mdl_h2));
legend('timing','counting')
 xlabel mse; 
 hfinal=gcf;
 hfinal.Renderer='painters';
cd(cp.datafolder);
saveas(hfinal,['Fig4g_' animal(1:6) '_' num2str(length(all_mse)) '_sessions_mse_cdf'],'epsc');

MSE_model_without_reset=all_mse(:,mdl_h1);
MSE_model_with_reset=all_mse(:,mdl_h2);

animal_id = repmat(animal(1:6),[length(MSE_model_without_reset),1]);
T=table(animal_id,MSE_model_without_reset,MSE_model_with_reset);
writetable(T,'Fig4.xlsx','Sheet',['fig_4g_monk_' animal(1)])


[h,pval,~,stats]=ttest(MSE_model_without_reset(2:end),MSE_model_with_reset(2:end));

end

function [mdl]=get_mdl_names()

[mdl{1}]= 'bls_offset_counter_nonuniformPrior_self';
[mdl{2}]='bls_offset_noncounter_nonuniformPrior_self';
[mdl{3}]='bls_offset_counter_atm_nonuniformPrior_self';
[mdl{4}]='bls_offset_counter_atp_nonuniformPrior_self';
[mdl{5}]='bls_joystickoffset_counter_nonuniformPrior_self';
[mdl{6}]='bls_joystickoffset_noncounter_nonuniformPrior_self';
[mdl{7}]='bls_joystickoffset_counter_atm_nonuniformPrior_self';
[mdl{8}]='bls_joystickoffset_counter_atp_nonuniformPrior_self';

[mdl{9}]='bls_offset_counter_oa_nonuniformPrior_self';
[mdl{10}]= 'bls_offset_noncounter_oa_nonuniformPrior_self';
[mdl{11}]='bls_offset_counter_oa_atm_nonuniformPrior_self';
[mdl{12}]='bls_offset_counter_oa_atp_nonuniformPrior_self';
[mdl{13}]='bls_joystickoffset_counter_oa_nonuniformPrior_self';
[mdl{14}]='bls_joystickoffset_noncounter_oa_nonuniformPrior_self';
[mdl{15}]='bls_joystickoffset_counter_oa_atm_nonuniformPrior_self';
[mdl{16}]='bls_joystickoffset_counter_oa_atp_nonuniformPrior_self';


end