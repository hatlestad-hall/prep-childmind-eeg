function [EEG, new_events_lat] = ch_insert_events (EEG, cfg )
%% About function/script

% Name:		ch_insert_events
% Version:	1.01

% Christoffer Hatlestad-Hall


% Date created:			19 Jan 2020
% Date last modified:	29 Jan 2020

% ------------------------------------------------------------------------------------------------------------------------------------------------ %

% SUMMARY:

% Function for inserting arbitrary events with regular intervals in a continuous EEG dataset.


% INPUT:

% EEG		|		struct		|		EEGLAB data structure.
% cfg		|		struct		|		Configuration struct. See below for details.

% Configuration struct content:
%		.event		|	The event marker to insert (string).
%		.seconds	|	The number of seconds between each new marker.
%		.lag		|	The first marker will be inserted this many seconds after 'begin'.
%		.begin		|	First sample of the EEG segment to work on (seconds after file start).
%		.end		|	End sample of the EEG segment to work on (seconds after file start).


% OUTPUT:

% EEG				|		struct		|		EEG struct with the added events.
% new_events_lat	|		array		|		The latencies (in seconds from file start) of the inserted events.

% ------------------------------------------------------------------------------------------------------------------------------------------------ %

%% Insert events

% Convert 'seconds', 'lag', 'begin' and 'end' to points.
s = cfg.seconds * EEG.srate;
l = cfg.lag * EEG.srate;
b = cfg.begin * EEG.srate;
e = cfg.end * EEG.srate;

% Compute lag-adjusted 'begin'.
b = b + l;

% Get number of existing event markers.
existing_events = length ( EEG.event );

% Calculate how many new events that will fit into given segment.
nb_new_events = floor ( ( e - b ) / s );
new_events_lat = zeros ( nb_new_events, 1 );

% Fill in EEG.event fields.
new_mult = 0;
for ne = 1 : nb_new_events
	new_events_lat( ne ) = b + ( s * new_mult );
	EEG.event( existing_events + ne ).latency = b + ( s * new_mult );
	EEG.event( existing_events + ne ).type = cfg.event;
	EEG.event( existing_events + ne ).urevent = [ ];
	if isfield ( EEG.event, 'duration' ), EEG.event( existing_events + ne ).duration = 0; end
	new_mult = new_mult + 1;
end

% Sort EEG.event struct: Ascending values of latency.
EEG.event = nestedSortStruct ( EEG.event, 'latency' );

end