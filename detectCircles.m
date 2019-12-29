%This function implements a Hough Transform circle detector that takes an 
%input image and a fixed radius, and returns the centers of any detected 
%circles of about that size.
%im is the input image, radius specifies the size of circle we are looking 
%for, and useGradient is a flag that allows the user to optionally exploit 
%the gradient direction measured at the edge points.
%The output centers is an N x 2 matrix in which each row lists the (x,y) 
%position of a detected circles’ center.

function [ centers ] = detectCircles( im, radius, useGradient)

img = rgb2gray(im);
bw = edge(img, 'Canny');
imshow(bw);
impixelinfo;
title('Given image');
H = zeros(size(bw,1),size(bw,2),radius);
[rows columns] = find(bw);
I = horzcat(rows, columns);
max = 0;
centers = [];
r = radius;

if useGradient == 1
    [Gmag,Gdir] = imgradient(bw);
    
    for i = 1:length(I)
            
            x= I(i,1);
            y= I(i,2);
            
            
            g = Gdir(x,y);
          
            g = double(g)*0.01745329;
            a = x - r*cos(g);
            b = y + r*sin(g);
            a = round(a);
            b= round(b);
            if (a<1) | (a>size(bw,1))
                continue
            end
            if b<1 | (b>size(bw,2))
                continue
            end
            H(a,b,r) = H(a,b,r) + 1;
            if max < H(a,b,r)
                max = H(a,b,r);
                centers = [a b];
            end
    end
else
    for i = 1:length(I)
        for g = -pi:0.1:pi
            x= I(i,1);
            y= I(i,2);
            a = x - r*cos(g);
            b = y + r*sin(g);
            a = round(a);
            b= round(b);
            if (a<1) | (a>size(bw,1))
                continue
            end
            if b<1 | (b>size(bw,2))
                continue
            end
            H(a,b,r) = H(a,b,r) + 1;
            if max < H(a,b,r)
                max = H(a,b,r);
                centers = [a b];
            end
        end
    end
end

dis = H(:,:,r);
dis = uint8(dis);
figure;
imagesc(dis);
title('Accumulator array');
prc100 = prctile(dis(:),100);
prc99 = prctile(dis(:),99);
prec= double(prc99)/double(prc100);

if prec < 0.42
        others = round(max-0.1*max);
        center2 = [];
        for i = 1:size(H,1)
            for j= 1:size(H,2)
                if H(i,j,r) >= others
                    center2 = [center2; [i j]];
                end
            end
        end
        col1 = center2(:,1);
        col2 = center2(:,2);
        centers = [col2, col1];
        figure;
        imshow(bw);
        impixelinfo;
        a=(['Detected circles of radius ',num2str(r)]);
        title(a);
        for i = 1:length(center2)
            hold on
            plot(center2(i,2),center2(i,1),'r*');
            th = 0:pi/50:2*pi;
            yunit = r*cos(th) + center2(i,1);
            xunit = r*sin(th) + center2(i,2);
            plot(xunit, yunit,'b*');
            hold off
        end
else
        figure;
        imshow(bw);
        title('No circles detected');
        centers = [];
end

end

