clc;clear;
tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����Ϊѵ������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Files = dir(fullfile('D:\Flower\train\','*.jpg'));
LengthFiles = length(Files);

height=50;width=50;%����������С�����Ե���
w1 = zeros(height*width,LengthFiles/3);%��һ��ѵ������
w2 =  zeros(height*width,LengthFiles/3);%�ڶ���ѵ������
w3 =  zeros(height*width,LengthFiles/3);%������ѵ������

%��һ��ͼ��
for i = 1:LengthFiles/3
    img = imread(strcat('D:\Flower\train\',Files(i).name));%��ȡͼ��
    img1 = rgb2gray(img);%ת���ɻҶ�ͼ
    if i>=1 && i<=5
    figure;imshow(img1)
    end
    [m,n] = size(img1);
    m1 = round(m/2);n1=round(n/2);
    img11 = img1(m1-199:m1+200,n1-199:n1+200);%��ȡ�м�ͼ��

    img2 = imresize(img11,[height,width]);%������С
    w1(:,i) = double(img2(:)); %�õ�ѵ������
end
%�ڶ���ͼ��
for i = LengthFiles/3+1:2*LengthFiles/3
    img =imread(strcat('D:\Flower\train\',Files(i).name));
    img1 = rgb2gray(img);
    if i>=1 && i<=5
    figure;imshow(img1)
    end
    [m,n] = size(img1);
    m1 = round(m/2);n1=round(n/2);
    img11 = img1(m1-199:m1+200,n1-199:n1+200);
    img2 = imresize(img11,[height,width]);
    w2(:,i-LengthFiles/3) = double(img2(:)); 
end
%������ͼ��
for i =2*LengthFiles/3+1:LengthFiles
    img = imread(strcat('D:\Flower\train\',Files(i).name));
    img1 = rgb2gray(img);
    if i>=1 && i<=5
    figure;imshow(img1)
    end
    [m,n] = size(img1);
    m1 = round(m/2);n1=round(n/2);
    img11 = img1(m1-199:m1+200,n1-199:n1+200);
    img2 = imresize(img11,[height,width]);
    w3(:,i-2*LengthFiles/3) = double(img2(:)); 
end

%�����ѵ��
w12 = [w1 w2];
w13 = [w1 w3];
w23 = [w2 w3];
Y =[ones(1,LengthFiles/3) -1*ones(1,LengthFiles/3)];
svmStruct12 = svmtrain(w12',Y,'Kernel_Function','quadratic');%���ֵ�һ��͵ڶ���
svmStruct13 = svmtrain(w13',Y,'Kernel_Function','quadratic');%���ֵ�һ��͵�����
svmStruct23 = svmtrain(w23',Y,'Kernel_Function','quadratic');%���ֵڶ���͵ڶ���

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����Ϊ���Բ���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Files = dir(fullfile('D:\Flower\test\','*.jpg'));
LengthFiles = length(Files);
correct=0;
for i=1:30
    img = imread(strcat('D:\Flower\test\',Files(i).name));
    img1 = rgb2gray(img);
    [m,n] = size(img1);
    m1 = round(m/2);n1=round(n/2);
    img11 = img1(m1-199:m1+200,n1-199:n1+200);
    img2 = imresize(img11,[height,width]);
    testy = double(img2(:)); %ѵ������
    
    result12 = svmclassify(svmStruct12,testy');%������Ϊ��һ�࣬С����Ϊ�ڶ���
    result23 = svmclassify(svmStruct23,testy');%������Ϊ�ڶ��࣬С����Ϊ������
    result13 = svmclassify(svmStruct13,testy');%������Ϊ��һ�࣬С����Ϊ������

    
    if(result12>0&result13>0)
        correct=correct+1;  
   end
end
for i=31:60
    img = imread(strcat('D:\Flower\test\',Files(i).name));
    img1 = rgb2gray(img);
    img2 = imresize(img1,[height,width]);
    testy = double(img2(:)); 
    
    result12 = svmclassify(svmStruct12,testy');
    result23 = svmclassify(svmStruct23,testy');
    result13 = svmclassify(svmStruct13,testy');

    
     if(result12<0&result23>0)
           correct=correct+1;  
     
    end
end
for i=61:LengthFiles
    img = imread(strcat('D:\Flower\test\',Files(i).name));
    img1 = rgb2gray(img);
    img2 = imresize(img1,[height,width]);
    testy = double(img2(:)); 
    
    result12 = svmclassify(svmStruct12,testy');
    result23 = svmclassify(svmStruct23,testy');
    result13 = svmclassify(svmStruct13,testy');

    
    if(result13<0&result23<0)
        correct=correct+1;  
      
    end
end

%����ʶ����
result = correct/LengthFiles*2.5;
disp(['SVM����ʶ����Ϊ ',num2str(result)])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

toc





