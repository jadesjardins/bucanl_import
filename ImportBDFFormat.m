% FFTPower() - Performs Fast Fourier Tranformations on continuous or
% segmented data.
%
% Usage:
%   >>  EEG = FFTPower( EEG, FFTChs );
% Inputs:
%   EEG     - EEG dataset.
%   FFTChs  - Channels on which to perform FFT.
%    
% Outputs:
%   EEG     - EEG dataset.
%
% See also: 
%   POP_FFTPower, EEGLAB 

% Copyright (C) <2006>  <James Desjardins> <Brock University>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


function EEG = ImportBDFFormat(EEG, FileName, FilePath)

if nargin < 1
	help ImportBDFFormat;
	return;
end;	

eval(['fidBDF = fopen(''' FilePath FileName ''', ''r'' );'])

try EEG = eeg_emptyset;
catch, end

% Header
hdr.fileformat = fread(fidBDF, 8, '*char')';
hdr.subjectid = fread(fidBDF, 80, '*char')';
hdr.recordid = fread(fidBDF, 80, '*char')';
hdr.startdate = fread(fidBDF, 8, '*char')';
hdr.starttime = fread(fidBDF, 8, '*char')';
hdr.hdrnbytes = str2num(fread(fidBDF, 8, '*char')');
hdr.dataformat = fread(fidBDF, 44, '*char')';
hdr.nblocks = str2num(fread(fidBDF, 8, '*char')')
hdr.blockdur = str2num(fread(fidBDF, 8, '*char')')
hdr.nchannels = str2num(fread(fidBDF, 4, '*char')')

% Channel headers
hdr.labels = cellstr(fread(fidBDF, [16 hdr.nchannels], '*char')');
[EEG.chanlocs(1:hdr.nchannels).labels] = deal(hdr.labels{:});
hdr.type = cellstr(fread(fidBDF, [80 hdr.nchannels], '*char')');
hdr.unit = cellstr(fread(fidBDF, [8 hdr.nchannels], '*char')');
hdr.physmin = str2num(fread(fidBDF, [8 hdr.nchannels], '*char')');
hdr.physmax = str2num(fread(fidBDF, [8 hdr.nchannels], '*char')');
hdr.digmin = str2num(fread(fidBDF, [8 hdr.nchannels], '*char')');
hdr.digmax = str2num(fread(fidBDF, [8 hdr.nchannels], '*char')');
hdr.gain = (hdr.physmax - hdr.physmin) ./ (hdr.digmax - hdr.digmin);
hdr.filter = cellstr(fread(fidBDF, [80 hdr.nchannels], '*char')');
hdr.nsamples = str2num(fread(fidBDF, [8 hdr.nchannels], '*char')')
hdr.reserved = cellstr(fread(fidBDF, [32 hdr.nchannels], '*char')');

if length(unique(hdr.nsamples)) == 1
    hdr.nsamples = unique(hdr.nsamples);
else
    error('Different number of samples per channel.')
end
EEG.srate = hdr.nsamples / hdr.blockdur;
EEG.xmin = 0;
EEG.xmax = hdr.nblocks * hdr.blockdur * 1000;
EEG.trials = 1;
EEG.ref = 'common';

% Allocate memory (essential!)
%EEG.data = zeros(hdr.nchannels, hdr.nsamples * hdr.nblocks, 'single');

eval(['m = memmapfile(''' FilePath FileName ''');']);
m.Format = {'uint16', [hdr.nchannels (hdr.nblocks*hdr.nsamples)] 'x'}
EEG.data=m.Data(1).x;

return

h = waitbar(0, 'Reading bdf file: 0% done');
tic

for block = 0:hdr.nblocks - 1
    buf = fread(fidBDF, [3, hdr.nsamples * hdr.nchannels], '*uint8');
    EEG.data(1:hdr.nchannels, hdr.nsamples * block + 1:hdr.nsamples * block + hdr.nsamples) = ...
        reshape(single(buf(1, :)) + 256 * single(buf(2, :)) + 65536 * single(buf(3, :)) - 131072 * single(bitand(buf(3, :), 128)), ...
        hdr.nsamples, hdr.nchannels)';
     if (block + 1) == ceil(floor((block + 1) / (hdr.nblocks / 100)) * (hdr.nblocks / 100))
         p = (block + 1) / hdr.nblocks;
         t = toc;
         waitbar(p, h, ['Reading bdf file: ' num2str(round(p * 100)) '% done, ' num2str(round((1 - p) / p * t)) ' s left']);
     end
end

toc
% close(h);

for chan = 1:hdr.nchannels
    EEG.data(chan, :) = hdr.gain(chan) * EEG.data(chan, :);
end

toc

fclose(fidBDF);
