% 2016/10/17
%Liu Yakun 

clc;
clear;
close all;
% �״�ƽ̨����
C = 3e8; %����
Fc = 5.3e9;%��Ƶ
lambda = C / Fc;%����
Vr = 150;%�����ٶ�
%theta_rc = 0 / 180 * pi; %����б�ӽ�
H = 5000;%���и߶�
La = 4;
%R0 = 2e4;%


%��������
Y0 = 1e4;%��������Y��
R0 = sqrt(H^2 + Y0^2);%���ߵ������������б��
delta_x = 400;
delta_y = 150;
Beta = atan(H / Y0);% �������������

theta = lambda / La;%�������
Lsar = theta * R0;%�ϳɿ׾�����
Tsar = Lsar / Vr;%�ϳɿ׾�ʱ��

% ��ʱ�����
Tr = 2.5e-6;
Kr = 20e12;
alpha_Fsr = 1.2;%  �����������
Fs_org = alpha_Fsr * Kr * Tr;%������ԭʼ������
Ts_org = 1 / Fs_org;
Rmin = sqrt((Y0 - delta_y)^2 + H^2);%���б��
Rmax = sqrt((Y0 + delta_y)^2 + H^2 + (Lsar/2)^2);%��Զб��
sample_time = 2 * (Rmax - Rmin) / C + Tr;%�������ʱ�䳤��
Nr_org = sample_time / Ts_org;% ������������� 
Nr = 2^nextpow2(Nr_org);
Ts = sample_time / Nr;% ���º�Ĳ������
Tf_org = [-Nr / 2:(Nr / 2 -1)] * Ts;%����Ϊ0�Ĳ���ʱ������
Tf = Tf_org + 2 * R0 / C;% ���������ʱ�����
% Tf = linspace(2 * Rmin / C - Tr/2,2 * Rmax / C + Tr / 2,Nr);%��ʱ�����ʱ������ ��������Ϊ0
Rf = Tf * C / 2;%б������

% ��ʱ�����
alpha_Fsa = 1.25;
Ka = -2 * Vr^2 / lambda /R0;%��λ����Ƶ��
PRF_org = alpha_Fsa * Ka * Tsar;%ԭʼPRF
Na_org = (delta_x + Lsar) / Vr * PRF_org;%��λ�������
Na = 2^nextpow2(Na_org);%Ϊ����FFT ���µ�
PRF = (delta_x + Lsar) / Vr / Na;%���յ�PRF
Ts = linspace(-Lsar / 2 / Vr,(delta_x + Lsar / 2) / Vr,Na);
Ra = Ts * Vr;

Targets = [ 0  -100   1
            200 0     2
            0   100   2
           -200 0  1];


echo = echo_creation(C,H,Y0,lambda,Lsar,Kr,Tr,Tf,Ra,Targets);

x = Ra;
y = Y0 + Tf_org * C / 2 /cos(Beta);
figure;
[xx,yy] = meshgrid(x,y);
mesh(xx,yy,abs(echo));

