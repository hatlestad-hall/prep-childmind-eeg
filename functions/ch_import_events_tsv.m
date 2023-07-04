function event = ch_import_events_tsv( tsvpath, srate )

tsvtbl = readtable( tsvpath, 'FileType', 'text', 'ReadVariableNames', true, 'Delimiter', 'tab' );

for i = 1 : height( tsvtbl )
    event( i ).type     = char( tsvtbl{ i, 'type' } );
    event( i ).latency  = tsvtbl{ i, 'sample' };
    event( i ).duration = tsvtbl{ i, 'duration' } * srate;
    event( i ).urevent  = i;
end
    
end