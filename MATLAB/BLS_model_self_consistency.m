% Neupane, Fiete, Jazayeri 2024 mnav paper 
% Bayesian model of timing variability with and without landmark reset (named as counter vs non-counter in this code, named as mental navigation vs path integration in the paper)
% For questions or further data/code access contact sujayanyaupane@gmail.com
%====================================================================================================================

clear
ts_=repmat(.65:.65:3.25,[1 100]);
modelparams=[.15 .2 .01];
savefolder=('/Users/Sujay/Dropbox (MIT)/MJ & SN/nav_paper/Nature_revision 1/matlab code/data_figs');
mdl_filenames=get_mdl_names() ;
for bb=1:100
    for modelgen = [1 2]
        
        eval(['[tp_gen,  gen_model_type]=' mdl_filenames{modelgen} '(ts_,modelparams,[],[]);'])
        for modelfit = [1 2]
            eval(['[~,mdl_fit_out{modelgen,modelfit,bb}]=' mdl_filenames{modelfit} '(ts_,[],tp_gen,gen_model_type,savefolder);'])
            mse(modelgen,modelfit,bb)=mdl_fit_out{modelgen,modelfit,bb}.mse_bias_var;
            negloglik(modelgen,modelfit,bb)=mdl_fit_out{modelgen,modelfit,bb}.negloglik;
            bic(modelgen,modelfit,bb)=mdl_fit_out{modelgen,modelfit,bb}.bic;
            w_model(modelgen,modelfit,:,bb)=mdl_fit_out{modelgen,modelfit,bb}.w;
            close (gcf)
        end
    end
end
%%
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

subplot(3,3,3);
histogram(mse(2,1,:),0:.05:.7); hold on 
histogram(mse(2,2,:),0:.05:.7); set(gca,'FontSize',15);
title 'gen model: timing'
legend('counting','timing')
xlabel MSE



subplot(3,3,5);
histogram(w_model(1,1,2,:),.1:.01:.4); hold on 
histogram(w_model(1,2,2,:),.1:.01:.4); set(gca,'FontSize',15);
addline(modelparams(2),'color','k');
title 'gen model: counting'
legend('counting','timing','')
xlabel wp

subplot(3,3,6);
histogram(w_model(2,1,2,:),.1:.01:.4); hold on 
histogram(w_model(2,2,2,:),.1:.01:.4);set(gca,'FontSize',15);
addline(modelparams(2),'color','k');
title 'gen model: timing'
legend('counting','timing','')
xlabel wp 




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
saveas(hsim,'model_identifiability_100simulations','epsc');
save('model_identifiability_simulation.mat','mdl_fit_out','modelparams');
%% functions


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


