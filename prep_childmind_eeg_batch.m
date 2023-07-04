
% PREP_CHILDMIND_EEG_BATCH preprocesses all *.mat located in a directory, and places the
% output in a new directory. The preprocessing parameters are defined in
% the batch script and passed as input argument to the preprocessing function, "s1_prep_childmind_eeg".


% The pipeline contains the following preprocessing procedures:
%  - Removal of line noise
%  - High-pass filtering
%  - Low-pass filtering
%  - Interpolation of bad channels
%  - Rereference to (new) average reference
%
% The pipeline is modular, and the individual modules may be switched on or off independently.
% Some parameters are modifiable at the top of the batch script, whereas other are "hardcoded"
% in the preprocessing function. The default parameters should be considered conservative.
%
% Note that bad channels are interpolated, and are marked as such in the output *_channels.tsv file.
%
% Requires EEGLAB and plugins Zapline plus.

% Copyright (C) 2023, Christoffer Hatlestad-Hall

% cleaning procedures to enable
cfg.prep.enable.modavgref  = 'yes';
cfg.prep.enable.linenoise  = 'yes';
cfg.prep.enable.hp_filt    = 'yes';
cfg.prep.enable.lp_filt    = 'yes';
cfg.prep.enable.avgref     = 'yes';

% cleaning procedures parameters
cfg.prep.hp_filt     = 1;           % Hz
cfg.prep.lp_filt     = 45;          % Hz

% input and output directory
inp_dir  = 'H:/child_mind_data_resting_state';
out_dir  = 'H:/child_mind_data_resting_state_preprocessed';

% get a list of all the raw datafiles
fprintf( '\n   fetching list of all raw EEG files (*.mat)...\n' );
files  = dir( sprintf( '%s/*.mat', inp_dir ) );
fprintf( '   files found: %i\n', length( files ) );

% create a cell array to record bad channels
all_bad_chans.setname    = [];
all_bad_chans.bad_chans  = [];
fb                       = 0;

% loop the raw data files
for f  = 1 : numel( files )
    
    fprintf( '\n   current file:   %s\n\n\n', files( f ).name );
    
    % check if the file exists in the output folder
    [ ~, fname ]  = fileparts( files( f ).name );
    if exist( sprintf( '%s/%s.set', out_dir, fname ), 'file' ) == 2
        continue
    end

    % preprocess and clean the data file
    fprintf( '\n   preprocessing and cleaning...\n\n' );
    try
    [ EEG, bad_chans ]            = s1_prep_childmind_eeg( sprintf( '%s/%s', files( f ).folder, files( f ).name ), cfg.prep );
    if isempty( EEG )
        continue
    end
    catch
        continue
    end
    fb  = fb + 1;
    all_bad_chans( fb ).setname    = EEG.setname;     %#ok<SAGROW>
    all_bad_chans( fb ).bad_chans  = bad_chans;       %#ok<SAGROW> 
    save( sprintf( '%s/all_bad_chans.mat', out_dir ), 'all_bad_chans' );
    pop_saveset( EEG, sprintf( '%s/%s', out_dir, EEG.setname ) );
    
end
