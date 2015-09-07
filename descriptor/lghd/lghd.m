function [eh] = pcehd(new_eo) 

ys = size(new_eo{1,1},1); % Row
xs = size(new_eo{1,1},2); % Column
ys=uint16(ys);
xs=uint16(xs);

im2 = zeros(ys, xs, 6);

im2(:,:,1) = abs(new_eo{1,1});     
im2(:,:,2) = abs(new_eo{1,2});     
im2(:,:,3) = abs(new_eo{1,3});     
im2(:,:,4) = abs(new_eo{1,4});     
im2(:,:,5) = abs(new_eo{1,5});          
im2(:,:,6) = abs(new_eo{1,6});       

[mmax, maxp] = max(im2,[],3);   % z maximums
im2 = maxp;
maxp(mmax==0)= 7;

eoh = zeros(4,4,6);
for j = 1:4
    for i = 1:4
        clip = im2(round((j-1)*ys/4+1):round(j*ys/4),round((i-1)*xs/4+1):round(i*xs/4));
        eoh(j,i,:) = permute(hist(clip(:), 1:6), [1 3 2]);
    end
end


%%  Build Descriptor

d1=[];
for i=1:4
    for j=1:4
        d1=[d1    eoh(i,j,1)  eoh(i,j,2) eoh(i,j,3) eoh(i,j,4) eoh(i,j,5) eoh(i,j,6)];
    end
end

d1=d1';
%% Normalization

if norm(d1) ~= 0
   d1 = d1 /norm(d1);
end
eh = d1;               



    
