close all
clear all


folder_name = uigetdir;

% simulation paramter for SofiStack1
w0 = 3; % radius of emitter image
bg = 1; % background
blink = 1-exp(-0.1); % blink probability
rr = -50:50; % image size
nframes = 5e4; % number of movie frames
executeOnCluster=true; %run simulation on cluster or local
bld = false; % whether to show image movie or not
nparticles = 30; % number of emitters per structure
sofiSimOut  = SofiSimMap( nparticles,w0,bg,blink,rr,nframes,executeOnCluster );%let the simulation run on cluster or local
fullPathToFile = fullfile(folder_name, 'SofiSimulation1.mat');
save(fullPathToFile,'sofiSimOut','w0','bg','blink','rr','nframes','nparticles');

% simulation paramter for SofiStack2
w0 = 3; % radius of emitter image
bg = 1; % background
blink = 1-exp(-0.1); % blink probability 
rr = -50:50; % image size
nframes = 5e2; % number of movie frames
executeOnCluster=true; %run simulation on cluster or local
bld = false; % whether to show image movie or not
nparticles = 30; % number of emitters per structure
sofiSimOut  = SofiSimMap( nparticles,w0,bg,blink,rr,nframes,executeOnCluster );%let the simulation run on cluster or local
fullPathToFile = fullfile(folder_name, 'SofiSimulation2.mat');
save(fullPathToFile,'sofiSimOut','w0','bg','blink','rr','nframes','nparticles');

