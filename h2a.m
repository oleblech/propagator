function [a] = h2a(h,e,mu)
% convert h to a
a = h^2 / ((1-e^2) * mu);
end