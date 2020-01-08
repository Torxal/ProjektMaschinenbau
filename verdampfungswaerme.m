function outputArg1 = verdampfungswaerme(inputArg1, inputArg2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%Wichtig! Gilt nur bei einem Betriebsdruck von 1 Bar
outputArg1 = 0; 
if inputArg1>=100
    outputArg1 = 2.26*10^(6);   
else 
    outputArg1 = 0; 
end

