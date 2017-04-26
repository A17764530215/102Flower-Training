clc;clear;
clear all
close all
addpath('./hog_matlab/'); % ���·��
addpath('./hog_matlab/common/');
addpath('./hog_matlab/svm/');
addpath('./hog_matlab/svm/minFunc/');
tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �����򷽷�Ϊ��
% ��������ѵ����ʽ 
% ѵ������:[Y N ����] Ps: N �� (Flower_Num-1) ��
% ��ǩ����:[1 0 ����] Ps: 0 �� (Flower_Num-1) ��
% ���� ���� S V M Matlab ѵ���� ��ѵ���õ�ģ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����Ϊ������Ʋ���     ��Ҫ���õ�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Flag_Show_Picture=0;    % �����Ƿ���ʾͼƬ                1 ��ʾ 0 ����ʾ
Flag_Use_Random_Index=1;% �����Ƿ�ʹ���������            1 ʹ�� 0 ��ʹ��
Flag_Test_Detail=0;     % �Ƿ����ÿ������ͼƬ��ʶ��ϸ��   1 ��ʾ 0 ����ʾ
Flag_Use_Hog=0;         % �Ƿ�ʹ��Hog��ȡ��������         1 ʹ�� 0 ��ʹ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����Ϊ��ʼ�����ò���   ��Ҫ���õ� 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
File_Fofer_Path='E:\Flower\';   % �ļ���Ŀ¼ ֱ�Ӹ�����Ϳ����� �����ط���ȫ���øģ��Զ���
Original_Set='flower102\';% ����FlowerͼƬ Ŀ¼ 
Train_Set_Num=30;   % ѡ����Ϊѵ����ͼƬ����  ***�ص�������Ŀ
Test_Set_Num=20;    % ѡ����Ϊ����ͼƬ����  ***�ص�������Ŀ
Flower_Num=10;     % ѡ���ȡ��ͼƬ���������� ***�ص�������Ŀ
height=128;width=128;% ����������С�����Ե��� Խ��ʶ����Խ��
Picture_Cut_Size=400;% ͼƬ��ȡ��С�����Ե��� Ĭ��:400 
step=16;    % Hog �㷨 Cell �ָ��С
orient=9;   % ����ֱ��ͼ�ķ������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����Ϊ��ʼ�����㲿��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ��ʾ����
disp('���� S V M �㷨 ����:')
disp(['-->ѵ������Ϊ ',num2str(Flower_Num),' �ֲ�ͬ����Ļ���ͼƬ'])
disp(['-->ÿ�ֻ���ѡȡ ',num2str(Train_Set_Num),' ��ͼƬ��Ϊѵ����'])
disp(['-->ÿ�ֻ���ѡȡ ',num2str(Test_Set_Num),' ��ͼƬ��Ϊ���Լ�'])
disp(['-->���������߶�: ',num2str(height)])
disp(['-->�����������: ',num2str(width)])
disp(['-->ͼ���ȡ���(������): ',num2str(Picture_Cut_Size)])
if(Flag_Use_Hog==1)
    disp('***����ʹ��Hog������ȡ�㷨:')
    disp(['-->Hog ����: ',num2str(step)])
    disp(['-->Hog ֱ��ͼ����: ',num2str(orient)])
end
load([File_Fofer_Path,'imagelabels.mat']);% ��ȡͼƬ��ǩ(��Ӧÿ��ͼƬ�ķ���) �ļ���Ϊlabels PS�����Ϊ�ļ������ÿ��ͼƬ��һ����ţ�����һ������
%�����������
if (Flag_Use_Random_Index==1)
    disp('***ʹ�������ȡ')
    Random_Q=randperm(max(labels)); % ����102��������е�����
    Random_Index=Random_Q(1:Flower_Num); % ��֮�� ��ȡ ǰ Flower_Num ������ ����µ����飬���������ȡ 
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����Ϊѵ������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Original_Files = dir(fullfile([File_Fofer_Path,Original_Set],'*.jpg')); %��ȡFlower_NumflowerĿ¼��ַ
W=[];           % ��ʼ�� ͼƬ ����ѵ����
disp('ѵ�������ʼ����� ')
%% ѭ���õ�ͼ���ѵ����
fprintf('����ѵ����ͼƬ������:');
for flower_index=1:Flower_Num
    if (Flag_Use_Random_Index==1) % �ж��Ƿ�ʹ�������ȡ
        File_Index=find(labels==Random_Index(flower_index));    % ʹ�������ȡ�õ������Ȼ��õ���Ӧ������ֵ
    else
        File_Index=find(labels==flower_index);  % ��ʹ�������ȡ��ȡǰFlower_Num����𣬵õ�����ֵ
    end
    % ��Ҫ���� ѭ����ȡѵ��ͼƬ ����ѵ��
    for i = 1:Train_Set_Num
        flower_img_index=File_Index(i); % ��ȡͼƬ������ֵ
        img = imread(strcat([File_Fofer_Path,Original_Set],Original_Files(flower_img_index).name));%��ȡͼ��
        if(Flag_Use_Hog==0)
            img_gray = rgb2gray(img);%ת���ɻҶ�ͼ
            if(i==1 && Flag_Show_Picture==1) % �ж��Ƿ���ʾͼƬ
                figure;imshow(img_gray) %��ʾÿ�ֻ�������
            end
            [m,n] = size(img_gray); % �õ�ͼƬ��С
            m1 = round(m/2);n1=round(n/2);  % ��ͼ�����ĵ�
            img_midle = img_gray(m1-(Picture_Cut_Size/2-1):m1+(Picture_Cut_Size/2),n1-(Picture_Cut_Size/2-1):n1+(Picture_Cut_Size/2));%��ȡ�м�ͼ��
            img_resize = imresize(img_midle,[height,width]);%������С
            W(:,i,flower_index) = double(img_resize(:)); %�õ�ѵ������
        else
            % HOG ������ȡ��ʽ
            imh_hog_featureVec=HOG(img,height,width,Picture_Cut_Size,step,orient);
            W(:,i,flower_index)=imh_hog_featureVec';
        end
    end
    printIteration(flower_index);
end
fprintf('\n');
disp('ͼ��ѵ�������������� ')

%% S V M ѵ��  ���Ĳ���
fprintf('S V M ѵ�� ������:');
Y_Train =[ones(1,Train_Set_Num) -1*ones(1,Train_Set_Num*(Flower_Num-1))];    % ����ѵ�������ǩ (1 ��ʾ��ȷ  -1 ��ʾ����)
for A=1:Flower_Num % ѭ������ �����Աȵ�SVMѵ�����
    W_Train=W(:,:,A); %���� ���� ѵ����
    for B=1:Flower_Num
        if(A~=B)    % �����Լ����Լ��Աȣ���˳��Լ����Լ�֮����������������SVMѵ��
            W_Train=[W_Train W(:,:,B)];   % ��� ���� ѵ������ PS:�������Ϊÿ��ͼ�����������ͬ�в�ͬ��ͼ������
        end
    end
    SVM_Struct(A) = svmtrain(W_Train' ,Y_Train','Kernel_Function','quadratic');%���ֵ�A��͵�B�� quadratic��������ǹؼ�
    printIteration(A);
end
%W=0;    % ����ڴ�
%W_T=0;  % ����ڴ�
fprintf('\n');
disp('S V M ѵ����� ')

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����Ϊ���Բ���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
correct=0;  % �ܵ���ȷ����
Test_Num_ALL=0; % �ܲ���ͼƬ����
for flower_index=1:Flower_Num
    if (Flag_Use_Random_Index==1) % �ж��Ƿ�ʹ�������ȡ
        File_Index=find(labels==Random_Index(flower_index));    % ʹ�������ȡ�õ������Ȼ��õ���Ӧ������ֵ
    else
        File_Index=find(labels==flower_index);  % ��ʹ�������ȡ��ȡǰFlower_Num����𣬵õ�����ֵ
    end
    % �����ж��Ƿ񳬳�ͼƬ����ֵ ��ſ���һ�� ÿ�໨��ͼƬ����Ϊ40+ ����ѵ��ͼƬ���35��
    if((length(File_Index)-Train_Set_Num)<=Test_Set_Num) % ����𻨵ĳ�ѵ�����ͼƬ�����趨��Test_Set_Num����ͼƬ����ʱ
        Test_Set_End=length(File_Index); % ����ͼƬ�Ľ���������
        Test_Pic_Num=length(File_Index)-Train_Set_Num;  % ����ͼƬ��������
    else
        Test_Set_End=Test_Set_Num+Train_Set_Num;% ����ͼƬ�Ľ���������
        Test_Pic_Num=Test_Set_Num;% ����ͼƬ��������
    end
    Test_Num_ALL=Test_Num_ALL+Test_Pic_Num; % �ۼ��ܵĲ���ͼƬ����
    % ���ɲ��Ծ���
    W_Test = []; %ѵ������
    for i = (Train_Set_Num+1):Test_Set_End
        flower_img_index=File_Index(i);
        img = imread(strcat([File_Fofer_Path,Original_Set],Original_Files(flower_img_index).name));%��ȡͼ��
        if(Flag_Use_Hog==0)
            img_gray = rgb2gray(img);
            [m,n] = size(img_gray); % �õ�ͼƬ��С
            m1 = round(m/2);n1=round(n/2);  % ��ͼ�����ĵ�
            img_midle = img_gray(m1-(Picture_Cut_Size/2-1):m1+(Picture_Cut_Size/2),n1-(Picture_Cut_Size/2-1):n1+(Picture_Cut_Size/2));%��ȡ�м�ͼ��
            img_resize = imresize(img_midle,[height,width]);%������С
            W_Test =[W_Test double(img_resize(:))]; %ѵ������
        else
            % HOG ������ȡ��ʽ
            imh_hog_featureVec=HOG(img,height,width,Picture_Cut_Size,step,orient);
            W_Test=[W_Test imh_hog_featureVec'];
        end
    end
    SVM_Result = svmclassify(SVM_Struct(flower_index),W_Test');%������Ϊ��A�࣬С����Ϊ��B��
    SVM_Result=SVM_Result';
    result_Rate_T=length(find(SVM_Result==1))/(length(SVM_Result)); % ���� ÿ�������Ե�ʶ����ȷ��
    correct=correct+length(find(SVM_Result==1));
    if (Flag_Use_Random_Index==1)
        disp(['��',num2str(Random_Index(flower_index)),'�໨�Ĳ���ͼƬ�� ',num2str(Test_Pic_Num),' ��SVM����ʶ����Ϊ ',num2str(result_Rate_T*100),' %'])
    else
        disp(['��',num2str(flower_index),'�໨�Ĳ���ͼƬ�� ',num2str(Test_Pic_Num),' ��SVM����ʶ����Ϊ ',num2str(result_Rate_T*100),' %'])
    end
    if(Flag_Test_Detail==1) % �ж��Ƿ�������ϸ��
        disp(['ϸ�ڣ�',num2str(SVM_Result)])
    end
end
disp('S V M ������� ')
disp(' ')
%����ʶ����
result_Rate = correct/Test_Num_ALL; % ��ʶ����
disp(['S V M �㷨 ѵ�� ',num2str(Flower_Num),' �ֻ��ķ����������ʶ����Ϊ: ',num2str(result_Rate*100),' %'])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
toc % ����ʹ��ʱ�� ��ֹ���� �뿪ͷ�� tic ��Ӧ