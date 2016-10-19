% 2016/10/17
%Liu Yakun 

clc;
clear;
close all;

% �״�ƽ̨����
C = 3e8; %����
Fc = 5e9;%��Ƶ
lambda = C / Fc;%����
Vr = 150;%�����ٶ�
%theta_rc = 0 / 180 * pi; %����б�ӽ�
H = 5000;%���и߶�
La = 4;
%R0 = 2e4;%


%��������
Y0 = 10000;%��������Y��
R0 = sqrt(H^2 + Y0^2);%���ߵ������������б��
Length_X = 300;
Length_Y = 800;
Beta = atan(Y0 / H);% �������������
scene_center = [0,Y0];

theta = lambda / La;%�������
Lsar = theta * R0;%�ϳɿ׾�����
Tsar = Lsar / Vr;%�ϳɿ׾�ʱ��

% ��ʱ�����
Tr = 2.5e-6;
Kr = 20e12;
alpha_Fsr = 1.2;%  �����������
Fs_org = alpha_Fsr * Kr * Tr;%������ԭʼ������
Ts_org = 1 / Fs_org;
Rmin = sqrt((Y0 - Length_Y/2)^2 + H^2);%���б��
Rmax = sqrt((Y0 + Length_Y/2)^2 + H^2 + (Lsar/2)^2);%��Զб��
sample_time = 2 * (Rmax - Rmin) / C + Tr;%�������ʱ�䳤��
Nr_org = sample_time / Ts_org;% ������������� 
Nr = 2^nextpow2(Nr_org);
Ts = sample_time / Nr;% ���º�Ĳ������
% Tf_org = [-Nr / 2:(Nr / 2 -1)] * Ts;%����Ϊ0�Ĳ���ʱ������
% Tf = Tf_org + 2 * R0 / C;% ���������ʱ�����
Tf = linspace(2 * Rmin / C,2 * Rmax / C + Tr,Nr);%��ʱ�����ʱ������
Rf = Tf * C / 2;%б������

% ��ʱ�����
alpha_Fsa = 1.25;
Ka = -2 * Vr^2 / lambda /R0;%��λ����Ƶ��
PRF_org = alpha_Fsa * Ka * Tsar;%ԭʼPRF
Na_org = (Length_X + Lsar) / Vr * PRF_org;%��λ�������
Na = 2^nextpow2(Na_org);%Ϊ����FFT ���µ�
PRF = (Length_X + Lsar) / Vr / Na;%���յ�PRF
Ts = linspace(-Lsar / 2 / Vr,(Length_X + Lsar / 2) / Vr,Na);
Ra = Ts * Vr;

Targets = [ 0  -100   1
            200 0     1
            0   100   1
           -200  0    1];
nTargets = size(Targets,1);
Targets(:,1:2) = Targets(:,1:2) + ones(nTargets,1) * scene_center;

%�������
echo = echo_creation(C,H,Y0,lambda,Lsar,Kr,Tr,Tf,Ra,Targets);

x = Y0 + (Tf * C / 2 - R0) / sin(Beta);
y = Ra;
% mesh(abs(echo));

%����ѹ��
t = Tf - 2 * Rmin / C; 
signal_ref = exp(1i * Kr * t.^2) .* (t > 0 & t < Tr);
signal_compressed = pulse_compression(echo,signal_ref,Na);

% mesh(abs(signal_compressed));
colormap(gray);
imagesc(x,y,255-abs(signal_compressed));
