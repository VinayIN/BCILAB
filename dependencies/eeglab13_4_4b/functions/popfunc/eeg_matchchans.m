% eeg_matchchans()  - find closest channels in a larger EEGLAB chanlocs structure
%                     to channels in a smaller chanlocs structure
% Usage:
%        >> [selchans,distances,selocs] = eeg_matchchans(BIGlocs,smalllocs,'noplot');
% Inputs:
%        BIGlocs    - larger (or equal-sized) EEG.chanlocs structure array
%        smalllocs  - smaller (or equal-sized) EEG.chanlocs structure array
% Optional inputs:
%        'noplot'   - [optional string 'noplot'] -> do not produce plots {default: 
%                     produce illustrative plots of the BIG and small locations}
% Outputs:
%        selchans   - indices of BIGlocs channels closest to the smalllocs channels
%        distances  - vector of distances between the selected BIGlocs and smalllocs chans
%        selocs     - EEG.chanlocs structure array containing nearest BIGlocs channels 
%                     to each smalllocs channel: 1, 2, 3,... n. This structure has
%                     two extra fields: 
%                                    bigchan  - original channel index in BIGlocs
%                                    bigdist  - distance between bigchan and smalllocs chan 
%                     ==> bigdist assumes both input locs have sph_radius 1.
%
% Author: Scott Makeig, SCCN/INC/UCSD, April 9, 2004

% Copyright (C) 2004 Scott Makeig, SCCN/INC/UCSD, smakeig@ucsd.edu
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

% History: began Jan 27, 2004 as selectchans.m(?) -sm

function [selchans,dists,selocs] = eeg_matchchans(bglocs,ltlocs,noplot)

if nargin < 2
  help eeg_matchchans
  return
end
no_plot = 0; % yes|no flag
if nargin > 2 & strcmp(lower(noplot),'noplot')
  no_plot = 1;
end

if ~isstruct(bglocs) | ~isstruct(ltlocs)
   help eeg_matchchans
end

ltchans = length(ltlocs);
bgchans = length(bglocs);
if ltchans > bgchans
  fprintf('BIGlocs chans (%d) < smalllocs chans (%d)\n',bgchans,ltchans);
  return
end
selchans = zeros(ltchans,1);
dists    = zeros(ltchans,1);
bd       = zeros(bgchans,1);
%
%%%%%%%%%%%%%%%%% Compute the distances %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
fprintf('BIG  ltl  Dist\n');
for c=1:ltchans
   for C=1:bgchans
      if ~isempty(ltlocs(c).X) & ~isempty(bglocs(C).X)
        bd(C) = sqrt((ltlocs(c).X/ltlocs(c).sph_radius - bglocs(C).X/bglocs(C).sph_radius)^2 + ...
                    (ltlocs(c).Y/ltlocs(c).sph_radius - bglocs(C).Y/bglocs(C).sph_radius)^2 + ...
                    (ltlocs(c).Z/ltlocs(c).sph_radius - bglocs(C).Z/bglocs(C).sph_radius)^2);
      end
   end
   %
   %%%%%%%%%%%%%%%%% Find the nearest BIGlocs channel %%%%%%%%%%%%%%%%%%%%%%%
   %
   [bd ix] = sort(bd); % find smallest distance c <-> C
   bglocs(1).bigchan = [];
   k=1;
   while ~isempty(bglocs(ix(k)).bigchan) & k<=bgchans % avoid empty channels
     k=k+1;
   end
   if k>bgchans
     fprintf('No match found for smalllocs channel %d - error!?\n',c);
     return % give up - should not reach here!
   end
   while k<length(ix)
     if c>1 & sum(ismember(ix(k),selchans(1:c-1)))>0 % avoid chans already chosen 
        k = k+1;
     else
        break
     end
   end
   if k==length(ix)
      fprintf('NO available nearby channel for littlechan %d - using %d\n',...
                  c,ix(k));
   end
   selchans(c) = ix(k); % note the nearest BIGlocs channel
   dists(c)    = bd(k); % note its distance
   bglocs(ix(k)).bigchan = selchans(c); % add this info to the output
   bglocs(ix(k)).bigdist = dists(c);
   fprintf('.bigchan %4d, c %4d, k %d, .bigdist  %3.2f\n',...
        bglocs(ix(k)).bigchan,c,k,bglocs(ix(k)).bigdist); % commandline printout
end; % c
selocs = bglocs(selchans); % return the selected BIGlocs struct array subset
%
%%%%%%%%%%%%%%%%% Plot the results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if ~no_plot
    figure;
    titlestring = sprintf('%d-channel subset closest to %d channel locations',ltchans,bgchans);
    tl=textsc(titlestring,'title');
    set(tl,'fontweight','bold');
    set(tl,'fontsize',15);
    sbplot(7,2,[3 13]);
    hist(dists,length(dists));
    title('Distances between corresponding channels');
    xlabel('Euclidian distance (sph. rad. 1)');
    ylabel('Number of channels');

    sbplot(7,5,[8,35]);
    topoplot(dists,selocs,'electrodes','numbers','style','both');
    title('Distances');
    clen = size(colormap,1);
    sbnull = sbplot(7,2,[10 12])
    cb=cbar;
    cbar(cb,[clen/2+1:clen]);
    set(sbnull,'visible','off')
    
    axcopy; % turn on axcopy
end
