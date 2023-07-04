function [ EEG, bad_chans ] = s1_prep_childmind_eeg( eegpath, cfg )

% S1_PREP_CHILDMIND_EEG contains automated preprocessing procedures. See "prep_childmind_eeg_batch"
% for details.

% Copyright (C) 2023, Christoffer Hatlestad-Hall

% throw error if insufficient input
if nargin < 2
    error( 'requires two input arguments: filepath, cfg' );
end

% # # # # # # # # # # # # # # # # # # # # # # # #
% FOR DEVELOPMENT: set parameters (cfg)
% cfg.hp_filt     = 1;           % Hz
% cfg.lp_filt     = 45;          % Hz
% # # # # # # # # # # # # # # # # # # # # # # # #


% # # # # # # # # # # # # # # # # # # # # # # # #
% FOR DEVELOPMENT: read the datafile
% eegpath = 'H:/child_mind_data_resting_state/NDARET069PKN.mat';
% # # # # # # # # # # # # # # # # # # # # # # # #

% load the EEG from file
load( eegpath, 'EEG' );
EEG     = eeg_checkset( EEG );

% add standard channel location information to the data
loc_file   = 'channel_locations_childmind.sfp';
EEG        = pop_chanedit(EEG, 'lookup', loc_file ,'load', { loc_file, 'filetype', 'autodetect' } );

% find moderately robust reference
if strcmpi( cfg.enable.modavgref, 'yes' )
    itref_cfg.channels   = 1 : EEG.nbchan;
    itref_cfg.max_itr    = 40;
    itref_cfg.max_sd     = 75;
    itref_cfg.min_sd     = 1;
    itref_cfg.hp_filter  = 1;
    itref_cfg.lp_filter  = 100;
    [ EEG, bad_chans]    = ch_iterative_reref( EEG, itref_cfg );
    orig_chans           = EEG.chanlocs;
    EEG                  = pop_select( EEG, 'nochannel', bad_chans );
end

% if more than 30% of the channels are rejected, discard file
if length( bad_chans ) > 39
    EEG        = [ ];
    bad_chans  = [ ];
    return
end

% clean line noise with Zapline plus
if strcmpi( cfg.enable.linenoise, 'yes' )
    EEG  = pop_zapline_plus( EEG, 'plotResults', false, 'coarseFreqDetectPowerDiff', 3 );
end

% high-pass filter
if strcmpi( cfg.enable.hp_filt, 'yes' )
    EEG  = pop_eegfiltnew( EEG, cfg.hp_filt, [ ] );
end

% low-pass filter
if strcmpi( cfg.enable.lp_filt, 'yes' )
    EEG  = pop_eegfiltnew( EEG, [ ], cfg.lp_filt );
end

% remove all existing events
EEG  = pop_editeventvals( EEG, 'delete', 1 : numel( EEG.event ) );

% interpolate missing channels and save list of bad channels
EEG                     = pop_interp( EEG, orig_chans );
EEG.etc.bad_channels    = bad_chans;
all_chans               = { EEG.chanlocs.labels };
EEG.etc.bad_channels_l  = all_chans( bad_chans );

% rereference to average
if strcmpi( cfg.enable.avgref, 'yes' )
    EEG  = pop_reref( EEG, [] );
end

% set EEG set name
[ ~, setname ] = fileparts( eegpath );
EEG = pop_editset( EEG, 'setname', setname );

end