function res = hlp_sort_namevalues(varargin)
% Sort name-value pairs by name. 
% Sorted-NVPs = hlp_sort_namevalues(NVPs)
%
% Since the toolbox occasionally caches results of function calls,
% this is practical to uniformize arguments that lead to the same results, but look superficially different.
%
%                               Christian Kothe, Swartz Center for Computational Neuroscience, UCSD
%                               2010-03-28

% Copyright (C) Christian Kothe, SCCN, 2010, christian@sccn.ucsd.edu
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU
% General Public License as published by the Free Software Foundation; either version 2 of the
% License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
% even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with this program; if not,
% write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA

names = varargin(1:2:end);
[names, I] = sort(names); I=([I*2-1; I*2]); I=I(:); %#ok<ASGLU>
res = varargin(I);
