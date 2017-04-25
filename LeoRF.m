clc;clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����Ϊ���ɭ���㷨Ԥ������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmpi(computer,'PCWIN') | strcmpi(computer,'PCWIN64')
   compile_windows
else
   compile_linux
end
tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����Ϊ������Ʋ���     ��Ҫ���õ�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Flag_Show_Picture=0;    % �����Ƿ���ʾͼƬ                1 ��ʾ 0 ����ʾ
Flag_Use_Random_Index=1;% �����Ƿ�ʹ���������            1 ʹ�� 0 ��ʹ��
Flag_Test_Detail=0;     % �Ƿ����ÿ������ͼƬ��ʶ��ϸ��  1 ��ʾ 0 ����ʾ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����Ϊ��ʼ�����ò���   ��Ҫ���õ� 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
File_Fofer_Path='E:\Flower\';   % �ļ���Ŀ¼ ֱ�Ӹ�����Ϳ����� �����ط���ȫ���øģ��Զ���
Original_Set='flower102\';% ����FlowerͼƬ Ŀ¼ 
Train_Set_Num=10;   % ѡ����Ϊѵ����ͼƬ����  ***�ص�������Ŀ
Test_Set_Num=20;    % ѡ����Ϊ����ͼƬ����  ***�ص�������Ŀ
Flower_Num=10;     % ѡ���ȡ��ͼƬ���������� ***�ص�������Ŀ
RF_Tree=400;       % ���� ���ɭ���㷨�� ��������   ***�ص�������Ŀ
height=50;width=50;% ����������С�����Ե���
J_Rate=0.5;     % �ж��Ƿ�Ϊ��Ϊ��ʶ��ı��� �������Խ�� ��ȷ��Խ�� ***�ص�������Ŀ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����Ϊ��ʼ�����㲿��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��ʾ����
disp('���� ���ɭ�� �㷨 ����:')
disp(['-->ѵ������Ϊ ',num2str(Flower_Num),' �ֲ�ͬ����Ļ���ͼƬ'])
disp(['-->ÿ�ֻ���ѡȡ ',num2str(Train_Set_Num),' ��ͼƬ��Ϊѵ����'])
disp(['-->ÿ�ֻ���ѡȡ ',num2str(Test_Set_Num),' ��ͼƬ��Ϊ���Լ�'])
disp(['-->���ɭ����������: ',num2str(RF_Tree)])
disp(['-->���������߶�: ',num2str(height)])
disp(['-->�����������: ',num2str(width)])
disp(['-->�ж���ֵ: ',num2str(J_Rate),' (�ж��Ƿ���Ϊʶ����ȷ�ı���)'])
load([File_Fofer_Path,'imagelabels.mat']);% ��ȡͼƬ��ǩ(��Ӧÿ��ͼƬ�ķ���) �ļ���Ϊlabels PS�����Ϊ�ļ������ÿ��ͼƬ��һ����ţ�����һ������
%�����������
if (Flag_Use_Random_Index==1)
    disp('***ʹ�������ȡ')
    Random_Q=randperm(max(labels)); % ����102��������е�����
    Random_Index=Random_Q(1:Flower_Num); % ��֮�� ��ȡ ǰ Flower_Num ������ ����µ����飬���������ȡ 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����Ϊѵ������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Original_Files = dir(fullfile([File_Fofer_Path,Original_Set],'*.jpg')); %��ȡFlower_NumflowerĿ¼��ַ
w0 = zeros(height*width,Train_Set_Num);% ѵ������ ģ��
for n=1:Flower_Num
    W(:,:,n)=w0; % ѭ������ ��n�� ѵ������
end
w0 = 0; % ����ڴ�
disp('ѵ�������ʼ����� ')
% ѭ���õ�ͼ���ѵ����
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
        img_gray = rgb2gray(img);%ת���ɻҶ�ͼ
        if(i==1 && Flag_Show_Picture==1) % �ж��Ƿ���ʾͼƬ
            figure;imshow(img_gray) %��ʾÿ�ֻ�������
        end
        % ��������������ȡ ���и��õ�Ч��
        [m,n] = size(img_gray); % �õ�ͼƬ��С
        m1 = round(m/2);n1=round(n/2);  % ��ͼ�����ĵ�
        img_midle = img_gray(m1-199:m1+200,n1-199:n1+200);%��ȡ�м�ͼ��
        img_resize = imresize(img_midle,[height,width]);%������С
        %img_resize = imresize(img_gray,[height,width]);
        W(:,i,flower_index) = double(img_resize(:)); %�õ�ѵ������
    end
end
disp('ͼ��ѵ�������������� ')
% ���ɭ���㷨 ѵ��
Y =[ones(1,Train_Set_Num) -1*ones(1,Train_Set_Num)];    % ѵ��ʹ�õ�����
for A=1:Flower_Num % ѭ������ �����Աȵ�SVMѵ�����
    for B=1:Flower_Num
        W_T(:,:,A,B)=[W(:,:,A) W(:,:,B)];   % ���ɶԱȾ���: W_T(:,:,A,B) ���˾�����4ά���飬PS:���������һ������X(A,B),A,B ���������õ�����һ��С��2ά����
        if(A~=B)    % �����Լ����Լ��Աȣ���˳��Լ����Լ�֮����������������SVMѵ��
            %svmStruct(:,:,A,B) = svmtrain(W_T(:,:,A,B)',Y,'Kernel_Function','quadratic');%���ֵ�A��͵�B�� quadratic��������ǹؼ�
            RF_model(:,:,A,B) = classRF_train(W_T(:,:,A,B)',Y, RF_Tree);
        end
    end
end
%W=0;    % ����ڴ�
%W_T=0;  % ����ڴ�
disp('���ɭ�� ѵ����� ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����Ϊ���Բ���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
correct=0;  % �ܵ���ȷ����
correct_Temp=0; % ÿ�����ֱ����ȷ����
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
    if(Flag_Test_Detail==1) % �ж��Ƿ�������ϸ��
        result_T=zeros(1,Flower_Num); % ����Ϊ0
    end
    for i = (Train_Set_Num+1):Test_Set_End
        flower_img_index=File_Index(i);
        img = imread(strcat([File_Fofer_Path,Original_Set],Original_Files(flower_img_index).name));%��ȡͼ��
        img_gray = rgb2gray(img);
        % ��� ������ȡ�Ĳ���
        [m,n] = size(img_gray); % �õ�ͼƬ��С
        m1 = round(m/2);n1=round(n/2);  % ��ͼ�����ĵ�
        img_midle = img_gray(m1-199:m1+200,n1-199:n1+200);%��ȡ�м�ͼ��
        img_resize = imresize(img_midle,[height,width]);%������С
        %img_resize = imresize(img_gray,[height,width]);
        testy = double(img_resize(:)); %ѵ������
        for B=1:Flower_Num
            if(flower_index~=B)
                %result(flower_index,B) = svmclassify(svmStruct(:,:,flower_index,B),testy');%������Ϊ��A�࣬С����Ϊ��B��
                result(flower_index,B)  = classRF_predict(testy',RF_model(:,:,flower_index,B));
            else
                result(flower_index,B) =0;
            end
        end
        % �жϷ������ǣ����� (ʶ���/����) > �����趨����ֵ���� ����Ϊ��ʶ��� 
        % 100׼ȷʶ��Ļ� ���� J_Rate Ӧ����Ϊ 0.9 ���� 0.8
        if(length(find(result(flower_index,:)==1))/(length(result(flower_index,:))-1)>J_Rate)   % �ж��Ƿ�Ϊ��ȷʶ��
            correct=correct+1;  %��ͳ��
            correct_Temp=correct_Temp+1;%ÿ�����ͳ��
        end
        if(Flag_Test_Detail==1) % �ж��Ƿ�������ϸ��
            result(find( result<0 ))=0; % ֻ������ȷʶ���
            result_T=result(flower_index,:)+result_T; % �ۼ� ���Եõ�ÿ����������ʶ�����
        end
    end
    result_Rate_T = correct_Temp/Test_Pic_Num;  % ���� ÿ�������Ե�ʶ����ȷ��
    if (Flag_Use_Random_Index==1)
        disp(['��',num2str(Random_Index(flower_index)),'�໨�����ɭ���㷨ʶ����Ϊ ',num2str(result_Rate_T*100),' %'])
    else
        disp(['��',num2str(flower_index),'�໨�����ɭ���㷨ʶ����Ϊ ',num2str(result_Rate_T*100),' %'])
    end
    if(Flag_Test_Detail==1) % �ж��Ƿ�������ϸ��
        disp(['ϸ�ڣ�',num2str(result_T()/Test_Pic_Num)])
    end
    correct_Temp=0; % 
end
disp('���ɭ���㷨 ������� ')
disp(' ')
%����ʶ����
result_Rate = correct/Test_Num_ALL; % ��ʶ����
disp(['���ɭ�� �㷨 ��ʶ����Ϊ: ',num2str(result_Rate*100),' %'])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
toc % ����ʹ��ʱ�� ��ֹ���� �뿪ͷ�� tic ��Ӧ