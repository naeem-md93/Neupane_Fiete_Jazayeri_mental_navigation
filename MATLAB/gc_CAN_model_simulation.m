
% Neupane, Fiete, Jazayeri 2024 mnav paper 
% CAN grid cell model simulations with and without landmarks
% For questions or further data/code access contact sujayanyaupane@gmail.com
%=============================================================================


clear

%set up the network architecture
clear NN traj_wint traj_extlm traj_wolm RT_wolm RT_wint
NN = gc1d_setup;
%initialize the dynamics
NN = gc1d_init(NN);
NN.plotit=1;
NN.num_sim=50;
NN.inital_state=30;            %approximate inital phase of the network at onset of timing
NN.end_state=360;
NN.landmark_input_loc=60:60:300 ; %memorized internal landmark at particualr network state (phase)
NN.wolm_speed=.35; 
NN.wlm_speed=.42; 
NN.wm=.05;%0.08;
filename =['int_5lms_60deg_wm' num2str(NN.wm*100) '_vb' num2str( NN.wlm_speed*100) '_' num2str( NN.wolm_speed*1000)];


NN.landmark_input_external = 0; %external landmark at a particular time (set to 0 for using internal landmark)
%simulate
if NN.plotit
    scrsz = get(0,'ScreenSize');
    figure('Position',[10 scrsz(4)/2 scrsz(3)*(1/3) scrsz(4)/1.5])
end

for isim=1:NN.num_sim
    tic
    NN.landmarkpresent = 1;
    NN = gc1d_run(NN);


    traj_wint{isim}=NN.nn_state;
    wint_noisy_vel_input(isim) = NN.noisy_vel_input;
    wint_wm(isim)=NN.wm ;
    wint_v_noise(isim)=NN.v_noise;
    wint_v_base(isim)=NN.v_base;
    win_gridstater{isim}=NN.grid_statesR;
    wint_gridstatel{isim}=NN.grid_statesL;
    disp (['int lm rep' num2str(isim) ' sim' num2str(isim)])
    toc
end
RT_wint = cellfun(@length,traj_wint);
if NN.plotit
    title 'Internal landmark'
    set(gca,'FontSize',15);
end
toc
NNw=NN;


tic
if NN.plotit
    scrsz = get(0,'ScreenSize');
    figure('Position',[10 scrsz(4)/2 scrsz(3)*(1/3) scrsz(4)/1.5])
end

for isim=1:NN.num_sim
    NN.landmarkpresent = 0;
    tic
    NN = gc1d_run(NN);
    traj_wolm{isim}=NN.nn_state;
    wolm_noisy_vel_input(isim) = NN.noisy_vel_input;
    wolm_wm(isim)=NN.wm ;
    wolm_v_noise(isim)=NN.v_noise;
    wolm_v_base(isim)=NN.v_base;
    wolm_gridstater{isim}=NN.grid_statesR;
    wolm_gridstatel{isim}=NN.grid_statesL;
    disp (['no lm rep' num2str(irep) ' sim' num2str(isim)])
    toc
end
RT_wolm = cellfun(@length,traj_wolm);
if NN.plotit
    title 'No landmark'
    set(gca,'FontSize',15);
end
toc
NNwo=NN;
clear NN
save(filename) %save all variables
