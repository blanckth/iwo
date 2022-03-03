% Image Opimization With Invasive Weed Optimization Algorithm 
% Authur : Salar Muhammadi
% Clean Start
clc;
clear;
close all;
%%
%%%%%%%%
% IMAGE Source
image = 'image.PNG';
% RGB Array of The Image in double Value
RGBIMG = im2double(imread(image));
% Img Information
IMGINF = imfinfo(image);
%%%%%%%%
rng shuffle;

%figure
%imshow(RGBIMG);

[initss,IMGRS] = initSeedStructure(RGBIMG,IMGINF);

%figure
%imshow(IMGRS);

autoSeg = autoSegSeed(initss,IMGINF);

[autoSeg,IMGRS] = SegGrowing(autoSeg,RGBIMG,IMGINF,IMGRS);

figure
imshow(IMGRS);
%%
%%%% INITIALIZE PRIME LIST %%%%
function primeL = initPrimes(MaxNum)
MaxNum = floor(MaxNum);
if MaxNum < 2
    return
end
primeL(1) = 2;
if MaxNum == 2
    return
end
for x = 3:MaxNum
    isP = true;
    for p = 1:numel(primeL)
        if ~mod(x,primeL(p))
            isP = false;
            break
        end
    end
    if isP
        primeL(numel(primeL)+1) = x;
    end
end
end
%%
%%%% wether the Number is Prime or Not %%%%
function iP = isPrime(Num)

primes = initPrimes(floor(Num/2));
for p = 1:numel(primes)
    if ~mod(Num,primes(p))
        iP = false;
        return
    end
end
iP = true;
end
%%
%%%% Prime Multiples of a Number %%%%
function NumPrimes = NumberPs(Num)
NumPrimes(1).n = Num;
NumPrimes(1).c = 1;
if isPrime(Num)
    return
end
tmpNum = Num;
initP = initPrimes(floor(Num/2));
pc = numel(initP);
pinit = 1;
while tmpNum > 1
    for p = pinit:pc
        pr = initP(p);
        if ~mod(tmpNum,pr)
            tmpNum = tmpNum / pr;
            if NumPrimes(1).n == Num
                NumPrimes(1).n = pr;
                break
            end
            npn = numel(NumPrimes);
            exFind = false;
            for pR = 1:npn
                prr = NumPrimes(pR).n;
                if prr == pr
                    NumPrimes(pR).c = NumPrimes(pR).c + 1;
                    exFind = true;
                    break
                end
            end
            if ~exFind
                NumPrimes(npn+1).n = pr;
                NumPrimes(npn+1).c = 1;
            end
            break
        else
            pinit = p+1;
        end
    end
end
end
%%
%%%% Best Devider Decision %%%%
function bestDev = DevDec(Num)
numPrimes = NumberPs(Num);
numelp = numel(numPrimes);
nps = 0;
for np = 1 : numelp
    nps = nps + numPrimes(np).c;
end
tmpNps = nps;
n = 1;
while tmpNps > 1
    tmpNps = tmpNps / 2;
    if tmpNps > 1
        n = n + 1;
    end
end
bestDev = 1;
back = 0;
for m = 1:n
    nlp = numelp - back;
    while (~(numPrimes(nlp).c > 0)) && (back < (numelp -1))
        back = back + 1;
        nlp = numelp - back;
    end
    if numPrimes(nlp).c > 0
        bestDev = bestDev*numPrimes(nlp).n;
        numPrimes(nlp).c = numPrimes(nlp).c - 1;
    end
end
end

%%
%%%% Initial Structures and seeding process
function [iSS,IMGRS] = initSeedStructure(img,imgInfo)

widtH = imgInfo.Width;
heighT = imgInfo.Height;

stepMLvlX = DevDec(widtH);
stepX = widtH / stepMLvlX;
stepMLvlY = DevDec(heighT);
stepY = heighT / stepMLvlY;

IMGRS = ones(heighT,widtH,1);

ss = 1;

stepLvlX = 1;
stepLvlY = 1;

minX = (stepLvlX*stepX) + 1;
maxX = (stepLvlX + 1)*stepX;

minY = (stepLvlY*stepY) + 1;
maxY = (stepLvlY + 1)*stepY;

seeD(ss).posX = randi([minX,maxX],1);
seeD(ss).posY = randi([minY,maxY],1);
while seeD(ss).posY < (heighT-(stepY*2))
    while seeD(ss).posX < (widtH-stepX)
        grayVal = (img(seeD(ss).posY,seeD(ss).posX,1) + img(seeD(ss).posY,seeD(ss).posX,2) + img(seeD(ss).posY,seeD(ss).posX,3))/3;
        colVal = 0.1;
        if grayVal < colVal
            IMGRS(seeD(ss).posY,seeD(ss).posX)=0;
            ss = ss + 1;
        end
        stepLvlX = stepLvlX + 1;
        minX = (stepLvlX*stepX) + 1;
        maxX = (stepLvlX + 1)*stepX;
        
        seeD(ss).posX = randi([minX,maxX],1);
        seeD(ss).posY = randi([minY,maxY],1);
    end
    stepLvlY = stepLvlY + 1;
    stepLvlX = 1;
    
    minX = (stepLvlX*stepX) + 1;
    maxX = (stepLvlX + 1)*stepX;
    
    minY = (stepLvlY*stepY) + 1;
    maxY = (stepLvlY + 1)*stepY;
    
    seeD(ss).posX = randi([minX,maxX],1);
    seeD(ss).posY = randi([minY,maxY],1);
end
iSS = seeD;
end
%% AUTO SEGMENTATION
function autoSeg = autoSegSeed(iss,imgInfo)
autoSeg = {};
so = 3;
seedC = numel(iss);
for s = 1:seedC
    px = iss(s).posX;
    minx = px-so;
    if minx < 1
        minx = 0;
    end
    maxx = px+so;
    if maxx > imgInfo.Width
        maxx = imgInfo.Width;
    end
    py = iss(s).posY;
    miny = py-so;
    if miny < 1
        miny = 0;
    end
    maxy = py+so;
    if maxy > imgInfo.Height
        maxy = imgInfo.Height;
    end
    
    asn = numel(autoSeg);
    if ~asn
        autoSeg(1).seeds(1).posX = px;
        autoSeg(1).seeds(1).posY = py;
        autoSeg(1).MinX = minx;
        autoSeg(1).MaxX = maxx;
        autoSeg(1).MinY = miny;
        autoSeg(1).MaxY = maxy;
        continue
    end
    exF = false;
    for seg = 1:asn
        if (maxx >= autoSeg(seg).MinX) && (minx <= autoSeg(seg).MaxX)
            nas = numel(autoSeg(seg).seeds) + 1;
            autoSeg(seg).seeds(nas).posX = px;
            autoSeg(seg).seeds(nas).posY = py;
            exF = true;
            
            if minx < autoSeg(seg).MinX
                autoSeg(seg).MinX = minx;
            end
            if maxx > autoSeg(seg).MaxX
                autoSeg(seg).MaxX = maxx;
            end
            if miny < autoSeg(seg).MinY
                autoSeg(seg).MinY = miny;
            end
            if maxy > autoSeg(seg).MaxY
                autoSeg(seg).MaxY = maxy;
            end
            break
        end
    end
    if ~exF
        asn = numel(autoSeg)+1;
        autoSeg(asn).seeds(1).posX = px;
        autoSeg(asn).seeds(1).posY = py;
        autoSeg(asn).MinX = minx;
        autoSeg(asn).MaxX = maxx;
        autoSeg(asn).MinY = miny;
        autoSeg(asn).MaxY = maxy;
    end
end
end
%% REGION GROWING
function [autoSeg,IMGRS] = SegGrowing(autoSeg,img,imgInfo,IMGRS)
so =3;
for seg = 1 : numel(autoSeg)
    for iter = 1:66
        for sed = 1 : numel(autoSeg(seg).seeds)
            px = autoSeg(seg).seeds(sed).posX;
            py = autoSeg(seg).seeds(sed).posY;
            minx = px - so;
            if minx < 1
                minx = 1;
            end
            maxx = px + so;
            if maxx > imgInfo.Width
                maxx = imgInfo.Width;
            end
            miny = py - so;
            if miny < 1
                miny = 1;
            end
            maxy = py + so;
            if maxy > imgInfo.Height
                maxy = imgInfo.Height;
            end
            rndX = maxx - minx -1;
            rndY = maxy - miny -1;
            rndX = randi([1,rndX],1);
            rndY = randi([1,rndY],1);
            rndX = px + (rndX - (px - minx));
            rndY = py + (rndY - (py - miny));
            if ~IMGRS(rndY,rndX)
                continue
            end
            grayVal = (img(rndY,rndX,1) + img(rndY,rndX,2) + img(rndY,rndX,3))/3;
            colVal = 0.1;
            if grayVal < colVal
                IMGRS(rndY,rndX) = 0;
                %imshow(IMGRS);
                ns = numel(autoSeg(seg).seeds) + 1;
                autoSeg(seg).seeds(ns).posX = rndX;
                autoSeg(seg).seeds(ns).posY = rndY;
            end
        end
    end
end
end
