clc;
clear all;
img_folder = '';
lbl_folder = '';
final_img_folder = '';
final_lbl_folder = '';

mkdir(final_img_folder); mkdir(final_lbl_folder);

direc = dir(img_folder);
direclbl = dir(lbl_folder);

img_list = extractfield(direc(3:end),'name')';
lbl_list = extractfield(direclbl(3:end),'name')';

img_path = extractfield(direc(3:end),'folder')';
lbl_path = extractfield(direclbl(3:end),'folder')';

Filepath = img_list;
Lblpath = lbl_list;

table = cell(length(img_list)+3,4);
table{1,1} = 'file name';
table{1,2} = 'width';
table{1,3} = 'length';
table{1,4} = 'width overlap';
table{1,5} = 'height overlap';
table{1,6} = 'numofpatcheswide'
table{1,7} = 'numofpatchesheight'
for f = 1:length(img_list)
    temp1 = strcat(img_path{f},'\');
    temp = strcat(temp1,img_list{f});
    Filepath{f} = temp;
end

for fl = 1:length(lbl_list)
    temp1 = strcat(lbl_path{fl},'\');
    temp = strcat(temp1,lbl_list{fl});
    Lblpath{fl} = temp;
end

for ii = 1:length(Filepath)

Nameoffile = img_list{ii}((1:end-4));
table{ii+1,1} = Nameoffile;
img = imread(Filepath{ii});
img = im2gray(img);
lbl = imread(Lblpath{ii});
lbl = im2gray(lbl);
[m,n] = size(img);
strwidth = int2str(n);
table{ii+1,2} = strwidth;
strlength = int2str(m);
table{ii+1,3} = strlength;
% the width stride calculating 
% the number of patches of the width
wnum = ceil(n/256);
extrawidth = wnum * 256 - n;
%the overlapping width
wstride = extrawidth/(wnum - 1);
table{ii+1,4} = wstride;
wpoint = [1];
for i = 1:wnum-1
    wpoint = [wpoint i*(256-wstride)+1];
end

% the height stride calculating 
% the number of patches of the width
hnum = ceil(m/256);
extraheight = hnum * 256 - m;
%the overlapping width
hstride = extraheight/(hnum - 1);
table{ii+1,5} = hstride;
hpoint = [1];
table{ii+1,6} = wnum;
table{ii+1,7} = hnum;
for i = 1:hnum-1
    hpoint = [hpoint i*(256-hstride)+1];
end
%start cropping
for h1 = 1 : length(hpoint)
     for w1 = 1 : length(wpoint)
         temoname2 = strcat('_',int2str(h1),int2str(w1));
         temoname3 = strcat(Nameoffile,temoname2);
         filename2 = strcat(temoname3,'.bmp');
         filename3 = strcat(final_img_folder,filename2);   
         filename4 = strcat(final_lbl_folder,filename2);  
         imwrite(imcrop(img,[wpoint(w1),hpoint(h1),255,255]),filename3);
         imwrite(imcrop(lbl,[wpoint(w1),hpoint(h1),255,255]),filename4);
     end
end

end
 %output cell table for future reconstruction
writecell(table,'reconstruction_data.xls');






