%% COMPUTE EOH AND BUILD A DESCRIPTOR 
% [eoh] = edgeOrientationHistogram(im)
%
% Extract the MPEG-7 "Edge Orientation Histogram" descriptor
% 
% Input image should be a single-band image, but if it's a multiband (e.g. RGB) image
% only the 1st band will be used.
% Compute 4 directional edges and 1 non-directional edge
% The output "eoh" is a 4x4x5 matrix
%
% The image is split into 4x4 non-overlapping rectangular regions
% In each region, a 1x5 edge orientation histogram is computed (horizontal, vertical,
% 2 diagonals and 1 non-directional)
%
function [eh] = ehd(im,t,s,v) % t= Canny threshold
                              % s= standard deviation Gaussian filter 
                              % v= verbose

f2 = zeros(3,3,5);
f2(:,:,1) = [1 2 1;0 0 0;-1 -2 -1];      % Horizontal
f2(:,:,2) = [-1 0 1;-2 0 2;-1 0 1];      % Vertical
f2(:,:,3) = [2 2 -1;2 -1 -1; -1 -1 -1];  % 45
f2(:,:,4) = [-1 2 2; -1 -1 2; -1 -1 -1]; % 135
f2(:,:,5) = [-1 0 1;0 0 0;1 0 -1];       % No orientation



ys = size(im,1); % Row
xs = size(im,2); % Column
ys=uint16(ys);
xs=uint16(xs);


if v==1
    figure()
    subplot(3,1,1)
    imshow(im);
    texto=sprintf('EOH: Original image %df x %dc',ys,xs);
    title(texto);
end

ys = size(im,1);
xs = size(im,2); 
ys=uint16(ys);
xs=uint16(xs);


im2 = zeros(ys,xs,5);
for i = 1:5
    im2(:,:,i) = abs(filter2(f2(:,:,i), im));    
end

[mmax, maxp] = max(im2,[],3);   % z maximums
im2 = maxp;
im2(mmax==0)=5;

% ime = edge(im, 'canny', t, s)+0;  % Parametrizada
% tam=size(ime);

if v==1
    subplot(3,1,3)
    imshow(ime)
    texto=sprintf('EOH: Canny Filter Threshold=%2.1f, Sigma=%2.1f) %df x %dc',t,s,tam(1,1),tam(1,2));
    title(texto)
end

%Use canny filter
% im2 = im2.*ime;


eoh = zeros(4,4,6);
for j = 1:4
    for i = 1:4
        clip = im2(round((j-1)*ys/4+1):round(j*ys/4),round((i-1)*xs/4+1):round(i*xs/4));
        eoh(j,i,:) = permute(hist(clip(:), 0:5), [1 3 2]);
    end
end

eoh = eoh(:,:,2:6);

%% Sub images
if v==1
    figure();
    subplot(8,4,1)
    imshow(ime(1:ys/4,1:xs/4))
    subplot(8,4,5)
    m=[eoh(1,1,1) eoh(1,1,2) eoh(1,1,3) eoh(1,1,4) eoh(1,1,5)]; % h v 45 135 n
    bar(m);
    title('EOH SubImage(1,1)');

    subplot(8,4,2)
    imshow(ime(1:ys/4,xs/4:2*xs/4))
    subplot(8,4,6)
    m=[eoh(1,2,1) eoh(1,2,2) eoh(1,2,3) eoh(1,2,4) eoh(1,2,5)];    % h v 45 135 n
    bar(m)
    title('EOH SubImage(1,2)');

    subplot(8,4,3)
    imshow(ime(1:ys/4,2*xs/4:3*xs/4))
    subplot(8,4,7)
    m=[eoh(1,3,1) eoh(1,3,2) eoh(1,3,3) eoh(1,3,4) eoh(1,3,5)];    % h v 45 135 n
    bar(m)
    title('EOH SubImage(1,3)');

    subplot(8,4,4)
    imshow(ime(1:ys/4,3*xs/4:4*xs/4))
    subplot(8,4,8)
    m=[eoh(1,4,1) eoh(1,4,2) eoh(1,4,3) eoh(1,4,4) eoh(1,4,5)];    % h v 45 135 n
    bar(m)
    title('EOH SubImage(1,4)');
    %% Sub-Images  (2,1) (2,2) (2,3) (2,4) 

    subplot(8,4,9)
    imshow(ime(ys/4:2*ys/4,1:xs/4))
    subplot(8,4,13)
    m=[eoh(2,1,1) eoh(2,1,2) eoh(2,1,3) eoh(2,1,4) eoh(2,1,5)]; % h v 45 135 n
    bar(m)

    subplot(8,4,10)
    imshow(ime(ys/4:2*ys/4,xs/4:2*xs/4))
    subplot(8,4,14)
    m=[eoh(2,2,1) eoh(2,2,2) eoh(2,2,3) eoh(2,2,4) eoh(2,2,5)];    % h v 45 135 n
    bar(m)

    subplot(8,4,11)
    imshow(ime(ys/4:2*ys/4,2*xs/4:3*xs/4))
    subplot(8,4,15)
    m=[eoh(2,3,1) eoh(2,3,2) eoh(2,3,3) eoh(2,3,4) eoh(2,3,5)];    % h v 45 135 n
    bar(m)

    subplot(8,4,12)
    imshow(ime(ys/4:2*ys/4,3*xs/4:4*xs/4))
    subplot(8,4,16)
    m=[eoh(2,4,1) eoh(2,4,2) eoh(2,4,3) eoh(2,4,4) eoh(2,4,5)];    % h v 45 135 n
    bar(m)

    %% Sub-Image  (3,1) (3,2) (3,3) (3,4) 

    subplot(8,4,17)
    imshow(ime(2*ys/4:3*ys/4,1:xs/4))
    subplot(8,4,21)
    m=[eoh(3,1,1) eoh(3,1,2) eoh(3,1,3) eoh(3,1,4) eoh(3,1,5)]; % h v 45 135 n
    bar(m)

    subplot(8,4,18)
    imshow(ime(2*ys/4:3*ys/4,xs/4:2*xs/4))
    subplot(8,4,22)
    m=[eoh(3,2,1) eoh(3,2,2) eoh(3,2,3) eoh(3,2,4) eoh(3,2,5)];    % h v 45 135 n
    bar(m)

    subplot(8,4,19)
    imshow(ime(2*ys/4:3*ys/4,2*xs/4:3*xs/4))
    subplot(8,4,23)
    m=[eoh(3,3,1) eoh(3,3,2) eoh(3,3,3) eoh(3,3,4) eoh(3,3,5)];    % h v 45 135 n
    bar(m)

    subplot(8,4,20)
    imshow(ime(2*ys/4:3*ys/4,3*xs/4:4*xs/4))
    subplot(8,4,24)
    m=[eoh(3,4,1) eoh(3,4,2) eoh(3,4,3) eoh(3,4,4) eoh(3,4,5)];    % h v 45 135 n
    bar(m)

    %% Sub-Images  (4,1) (4,2) (4,3) (4,4)

    subplot(8,4,25)
    imshow(ime(3*ys/4:4*ys/4,1:xs/4))
    subplot(8,4,29)
    m=[eoh(4,1,1) eoh(4,1,2) eoh(4,1,3) eoh(4,1,4) eoh(4,1,5)]; % h v 45 135 n
    bar(m)

    subplot(8,4,26)
    imshow(ime(3*ys/4:4*ys/4,xs/4:2*xs/4))
    subplot(8,4,30)
    m=[eoh(4,2,1) eoh(4,2,2) eoh(4,2,3) eoh(4,2,4) eoh(4,2,5)];    % h v 45 135 n
    bar(m)

    subplot(8,4,27)
    imshow(ime(3*ys/4:4*ys/4,2*xs/4:3*xs/4))
    subplot(8,4,31)
    m=[eoh(4,3,1) eoh(4,3,2) eoh(4,3,3) eoh(4,3,4) eoh(4,3,5)];    % h v 45 135 n
    bar(m)

    subplot(8,4,28)
    imshow(ime(3*ys/4:4*ys/4,3*xs/4:4*xs/4))
    subplot(8,4,32)
    m=[eoh(4,4,1) eoh(4,4,2) eoh(4,4,3) eoh(4,4,4) eoh(4,4,5)];    % h v 45 135 n
    bar(m)
end

%%  Build Descriptor

d1=[];
for i=1:4
    for j=1:4
        d1=[d1    eoh(i,j,1)  eoh(i,j,2) eoh(i,j,3) eoh(i,j,4) eoh(i,j,5)];
    end
end

d1=d1';

%% Normalization
tam1=size(d1);
norma=0;
for i=1:tam1(1,1)
    norma=norma+d1(i)*d1(i);
end
norma=sqrt(norma);
if norma ~= 0
    for i=1:tam1(1,1)
        d2(i)=d1(i)/norma;
    end
else
    d2=d1';
end
d2=d2';
%% Store
eh=[];
eh=[eh, d2];
               
                


    
