% Neupane, Fiete, Jazayeri 2024 mental navigation paper 
% Fig 1 plot reproduction
%Download preprocessed data from this link into your local folder:
% https://www.dropbox.com/scl/fo/4fn7pq3e51waklclon9cp/AHJT9QgsHVa0bPKLtxxtY0c?rlkey=jrhi0p7mltze1axt7x6aqhvdj&dl=0
%for questions or further data/code access contact sujayanyaupane@gmail.com
%=============================================================================


%Fig1: nav_fig1_behavior
clear
cp.savedir_='/data_figs'; 
% mkdir([cp.savedir_ '/Fig1']); %if the folder doesn't exist, make one and download data there


%constants and parameters:
cp.example_mnav_sessionA='amadeus08272019_a';
cp.example_mnav_sessionM='mahler03262021_a';
cp.example_nts_sessionA='amadeus08292019_a';
cp.example_nts_sessionM='mahler03282021_a';
cp.example_seq=1;

cp.generalization_seq_a=1; %gen test on seq2 in monkey A was disrupted due to e-phys recording
cp.generalization_seq_m=2; %gen test on seq1 in monkey M was disrupted due to 2018 December break
cp.mintrial_in_session=400; %min successful mnav trials for a session to be included in performance distribution plot (Fig 1c)
cp.num_generalizationtest_sessions=6; %number of generalization test sessions to plot

%% get example session data plots Fig 1b and S1

savefig=0;
data_folder=[cp.savedir_ '/Fig1'];
tatplm=get_tatp(data_folder,cp,savefig,'amadeus');
tatplm=get_tatp(data_folder,cp,savefig,'mahler');

%% get generalization plots and distribution of regression slopes across all sessions

savefig=0;

% seq=1;
% get_generalization_plots('mahler_exp',mtt_folder,cp,savefig,seq)
seq=2;
get_generalization_plots('mahler_exp',cp,savefig,seq)


seq=1;
get_generalization_plots('amadeus_exp',cp,savefig,seq)
% seq=2;
% get_generalization_plots('amadeus_exp',mtt_folder,cp,savefig,seq)



%% functions


function get_generalization_plots(filename,cp,savefig,sequence)
plotgen=1;
cd([cp.savedir_ '/Fig1'])
load( filename)

if exist(['fig1ce_data_' filename(1:end-4) '_seq' num2str(sequence) '.mat'])
    load (['fig1ce_data_' filename(1:end-4) '_seq' num2str(sequence) '.mat'])
else

    %Dear user, this part of code has been run beforehand to generate the files above (e.g. fig1ce_data_). 
    %The code is for processing raw behavioral data to generate
    %performance data. It requires session-wise data from many months of
    %training. Please let me know if you'd like to access the raw training
    %data and I can share them. 
    switch filename(1)
        case 'a'
            mttfolder='/Users/Sujay/Dropbox (MIT)/mtt_data/';
            if sequence==cp.generalization_seq_a, plotgen=1;end
            eval(['expid=[' filename(1) '_expid_seq' num2str(sequence) ';' filename(1) '_expid_seq12;' filename(1) '_expid_seq4];']);
        case 'm'
            mttfolder='/Users/Sujay/Dropbox (MIT)/mtt_data_mahler/';
            if sequence==cp.generalization_seq_m, plotgen=1;end
            eval(['expid=[' filename(1) '_expid_seq' num2str(sequence) ';' filename(1) '_expid_seq12;' filename(1) '_expid_seq4;' filename(1) '_expid_seq124];']);
    end
    eval(['expallpairs = ' filename(1) '_expid_seq12;']);


    tx=[];ty=[];
    vtx=[];vty=[];
    kk=1;vkk=1;goodexpidx=[];vgoodexpidx=[];allpairsstart=0;
    for exp =  1:size(expid,1)
        expid(exp,:)
        if  filename(1)=='m'
            cd ([mttfolder '/' expid(exp,:) '.mwk']);
            load ([expid(exp,:) '.mat']);
        else
            try
                cd ([mttfolder '/' expid(exp,:) '.mwk']);
                try
                    load (['concat_' expid(exp,1:end-2) '.mat']);
                catch
                    load ([expid(exp,:) '.mat']);end
            catch
                cd ([mttfolder '/' expid(exp,1:end-2)]);
                load (['concat_' expid(exp,1:end-2) '.mat'])
            end
        end


        clear set
        if strcmp(expid(exp,:),expallpairs(1,:))
            allpairsstart=1;
        end
        if allpairsstart==0
            seqq=sequence*ones(size(tp));
        end

        g = find(mask==1 & abs(tp)<10 & seqq==sequence);
        temp=fitlm( abs(ta(g)),abs(tp(g))); %abs(tp)
        regreslope(exp,1)=temp.Coefficients.Estimate(2);

        temp=fitlm( (ta(g)),(tp(g)));  %with direction
        regreslope(exp,2)=temp.Coefficients.Estimate(2);
        regres_adjrsq(exp,2)=temp.Rsquared.Adjusted;


        g = find(mask<1 & abs(tp)<10 & seqq==sequence);
        temp=fitlm( abs(ta(g)),abs(tp(g))); %abs(tp) visual trials
        vregreslope(exp,1)=temp.Coefficients.Estimate(2);
        temp=fitlm( (ta(g)),(tp(g)));  %with direction visual trials
        vregreslope(exp,2)=temp.Coefficients.Estimate(2);


        seen(exp) = ~isempty(find(unique(ta)==3.25)) && length(unique(ta))<10;
        unseen(exp) = ~isempty(find(unique(ta)==-3.25));
        allpairs(exp) = length(unique(ta))==10;
        mtr(exp)=length(find(mask==1 & seqq==sequence));
        vtr(exp)=length(find(mask<1 & seqq==sequence));

        goodsession(exp)=length(find(ta(mask==1  & attempt<2 & seqq==sequence)))>cp.mintrial_in_session;
        vgoodsession(exp)=length(find(ta(mask<1  & attempt<2 & seqq==sequence)))>cp.mintrial_in_session;



    end

end


mnavtr = find(regreslope(:,2)~=0,1); %find first mnav session after nts training
switchtr=find(unseen,1); %find first unseen pair session after training on seen pairs

%find the first mnav session with all pairs:
temp=find(allpairs);
temp=temp(temp>switchtr);
switchallapirs=temp(1);

if plotgen==1
    figure;
    plot(regreslope([mnavtr:switchtr-1],2),'-ob');hold on;   title ([ filename(1:end-4) ': regression slope'])
    plot(regreslope([switchtr:switchtr+cp.num_generalizationtest_sessions],2),'-or');grid on %plot first 7 generalization sessions
    xlabel sessions
    ylabel 'performance (regression slope)'
    legend('train pairs','test pairs');clear set
    set(gca,'FontSize',15)

    
    if savefig
        hr=gcf;
        hr.Renderer='Painters';
        cd(cp.savedir_)
        saveas(hr,['Fig1e_' filename(1:end-4) '_generalization_seq' num2str(sequence)],'epsc')


        regression_slope_training = regreslope([mnavtr:switchtr-1],2);
        regression_slope_test = regreslope([switchtr:switchtr+cp.num_generalizationtest_sessions],2);

        trainid = [ones(length(regression_slope_training),1); zeros(length(regression_slope_test),1) ];
        regression_slope = [regression_slope_training;regression_slope_test];
        nhp_id = repmat(filename(1),[length(trainid), 1]);
        T = table(nhp_id,trainid,regression_slope);
        switch animal
            case 'amadeus'
                writetable(T,'Fig1.xlsx','Sheet','fig_1e')
            case 'mahler'
                writetable(T,'Fig1.xlsx','Sheet','fig_1e','Range','E1')

        end


    end
end

%mental test trials regre slope distribution across sessions
figure;
regretemp=regreslope([switchtr:end],2);
goodsesstemp=goodsession([switchtr:end])';
regretemp(  goodsesstemp==0)=[];
histogram(regretemp,-1:.05:1,'Normalization','Probability');ylim([0 .3])
xlabel 'Regression slope'; ylabel 'Pr'; title ([filename(1:5) ' ' num2str(length(regretemp)) ' sessions']);
set(gca,'FontSize',15,'YTick',0:.05:.3)

if savefig
    hr=gcf;
    hr.Renderer='Painters';
    cd(cp.savedir_)
    saveas(hr,['Fig1c_' filename(1:end-4) '_regressionSlopes_seq'  num2str(sequence)],'epsc')
    save(['fig1ce_data_' filename(1:end-4) '_seq' num2str(sequence) '.mat'],'filename','expid','expallpairs','sequence','regreslope','vregreslope','seen','unseen','allpairs','mtr','vtr','goodsession','vgoodsession')


        regression_slope_distribution = regretemp;
        nhp_id = repmat(filename(1),[length(regression_slope_distribution), 1]);
        T = table(nhp_id,regression_slope_distribution);
        switch animal
            case 'amadeus'
                writetable(T,'Fig1.xlsx','Sheet','fig_1c')
            case 'mahler'
                writetable(T,'Fig1.xlsx','Sheet','fig_1c','Range','E1')

        end


end




end


function [tatplm]=get_tatp(mtt_folder,cp,savefig,animal)

whichseq=cp.example_seq;

if animal(1)=='a',file_mworks=cp.example_mnav_sessionA;
else, file_mworks=cp.example_mnav_sessionM; end

try cd (mtt_folder)
    load([file_mworks '.mat']);
catch
    disp (['Session: ' file_mworks ' data missing. Preprocess it first.'])
    tatplm=[];
    return
end
clear set

hsave=figure;
randthick=.25;
g=  (mask==1 & seqq==whichseq & tp<99 & abs(tp)>.01 & trial_type==3  & validtrials_mm==1   );
gg=  (mask==1 & seqq==whichseq & tp<99 & abs(tp)>.01 & trial_type==3 & validtrials_mm==0);
ggg= g==1 | gg==1;
taa = unique(ta(g));
jitter=rand(1,length(ta))*randthick;
scatter(ta(ggg)+jitter(ggg),tp(ggg),15,'ok','Filled');hold on
% scatter(ta(gg)+jitter(gg),tp(gg),15,[.5 .5 .5],'Filled');hold on
scatter(ta(g)+jitter(g),tp(g),15,'or','Filled');hold on

plot([-6 6],[-6 6],'--k');grid on;
xlabel ta(sec); ylabel tp(sec);axis square

set(gca,'FontSize', 15);
set(gca,'XTick',taa(1:3:end)+randthick/2,'XTickLabel',taa(1:3:end));
set(gca,'YTick',taa(1:3:end)+randthick/2,'YTickLabel',taa(1:3:end));
axis([-5 5 -5 5])


tatplm = fitlm(ta(g),tp(g));
xx=[-5 5];
yy=tatplm.Coefficients.Estimate(2)*xx+tatplm.Coefficients.Estimate(1);
plot(xx,yy,'-r','LineWidth',2)

tatplmall = fitlm(ta(ggg),tp(ggg));
xx=[-5 5];
yy=tatplmall.Coefficients.Estimate(2)*xx+tatplmall.Coefficients.Estimate(1);
plot(xx,yy,'-k','LineWidth',2)

title(['\color{red} t_p =' num2str(round(tatplm.Coefficients.Estimate(2),2)) '*t_a + ' num2str(round(tatplm.Coefficients.Estimate(1),2))...
    ', \color{black} t_p =' num2str(round(tatplmall.Coefficients.Estimate(2),2)) '*t_a + ' num2str(round(tatplmall.Coefficients.Estimate(1),2))])

if savefig
    cd (cp.savedir_)
    saveas(gcf,['Fig1b' file_mworks '_example_mnav'],'epsc');

    va_mnav = ta(ggg)';
    vp_mnav = tp(ggg)';
    nhp_id = repmat(file_mworks(1),[length(va_mnav), 1]);
    T = table(nhp_id,va_mnav,vp_mnav);
%     switch animal
%         case 'amadeus'
%             writetable(T,'Fig1.xlsx','Sheet','fig_1b')
%         case 'mahler'
%             writetable(T,'Fig1.xlsx','Sheet','fig_1b,'Range','E1')
%     end
end



%visual trials plot

if animal(1)=='a',file_mworks=cp.example_nts_sessionA;
else, file_mworks=cp.example_nts_sessionM; end

try cd ([mtt_folder])
    load([file_mworks '.mat']);
catch
    disp (['preprocess ' file_mworks ' first'])
    tatplm=[];
    return
end
clear set

g=  ( seqq<3 & trial_type<3 & tp<4 & abs(tp)>.01);
gg=g;
if isempty(find(g, 1)), disp 'no visual trials on this session'

else

    figure;

    taa = unique(ta(g));
    jitter=rand(1,length(ta))*randthick;

    scatter(ta(g)+jitter(g),tp(g),15,'ok','Filled');hold on

    plot([-6 6],[-6 6],'--k');grid on;
    xlabel ta(sec); ylabel tp(sec);axis square

    set(gca,'FontSize', 15);
    set(gca,'XTick',taa(1:3:end)+randthick/2,'XTickLabel',taa(1:3:end));
    set(gca,'YTick',taa(1:3:end)+randthick/2,'YTickLabel',taa(1:3:end));
    axis([-5 5 -5 5])

    tatplm = fitlm(ta(g),tp(g));
    xx=[-5 5];
    yy=tatplm.Coefficients.Estimate(2)*xx+tatplm.Coefficients.Estimate(1);
    plot(xx,yy,'-r','LineWidth',2)

    title(['t_p =' num2str(round(tatplm.Coefficients.Estimate(2),2)) '*t_a + ' num2str(round(tatplm.Coefficients.Estimate(1),2))])


    if savefig
        cd (cp.savedir_)
        saveas(gcf,['FigS1b' file_mworks '_example_NTS'],'epsc');

        va_nts = ta(g)';
        vp_nts = tp(g)';
        nhp_id = repmat(file_mworks(1),[length(va_nts), 1]);
        T = table(nhp_id,va_nts,vp_nts);
        switch animal
            case 'amadeus'
                writetable(T,'FigS1.xlsx','Sheet','fig_S1')
            case 'mahler'
                writetable(T,'FigS1.xlsx','Sheet','fig_S1','Range','E1')

        end
    end



end



end
