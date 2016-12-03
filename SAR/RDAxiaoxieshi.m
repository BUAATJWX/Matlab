%2016/11/8
%Liu Yakun

clc,clear,close all;
C = 3e8;%����
% fc = 8e9;%�ز�Ƶ��
% lambda = C / fc;%����
lambda = 0.03;            %�����źŲ���
fc = C / lambda;          %�����ź�����Ƶ��
v = 200;%�״�ƽ̨�ٶ�
% h = 5000;
D = 5;%���߳���
theta = 45 / 180 * pi;%б�ӽ�
beta = lambda / D;%�������
yc = 41.7e3;%��������б��
xc = yc * tan(theta);%���״ﲨ�����Ĵ�Խ�������ĵ�ʱ�״�����Ϊ��0��0���㣬�������ĵ�ķ�λ������

wa = 100;%��λ����
wr = 100;%��������
xmin = xc - wa/2;%��λ��߽��
xmax = xc + wa/2;%��λ��߽��
ymin = yc - wr/2;%������߽��
ymax = yc + wr/2;%������߽��

rnear = ymin/cos(theta-beta/2);%���б��
rfar = ymax/cos(theta+beta/2);%��Զб��
rmid = (rnear + rfar) / 2;
a = 0.7;
b = 0.6;

targets = [xc + a*wa/2,yc + b*wr/2
           xc + a*wa/2,yc - b*wr/2
           xc - a*wa/2,yc + b*wr/2
           xc - a*wa/2,yc - b*wr/2
           xc         ,yc         ];


xbegin = xc - wa/2 - ymax*tan(theta+beta/2);%��ʼ���䳡���ķ�λ������
xend = xc + wa/2 - ymin*tan(theta - beta/2);%��������ʱ�ķ�λ������
xmid = (xbegin + xend) / 2;
ka = -2*v^2*cos(theta)^3/lambda/yc;%��λ���Ƶ��
% lsar = beta * yc / cos(theta);%�ϳɿ׾���
lsar = yc * (tan(theta + beta/2) - tan(theta - beta/2));%�ϳɿ׾���
tsar = lsar/v;%�ϳɿ׾�ʱ��
ba = abs(ka * tsar);%������Ƶ��
tr = 2e-6;%�������ʱ��
br = 50e6;%�������
kr = br / tr;%�������Ƶ��

% PRFmin = ba + 2*v*br*sin(theta)/C;
% PRFmax = 1/(2*tr+2*(rfar-rnear)/C);
% PRF = round(1.3 * ba);
% fs = round(1.2 * br);
alpha_slow = 1.3;%��λ���������
alpha_fast = 1.2;%�����������ϵ��
PRF = round(alpha_slow * ba);%��Ƶ
PRT = 1 / PRF;%�����ظ�����
Fs = alpha_fast * br;%�����������
Ts = 1 / Fs;%������������
Na = round((xend - xbegin)/v/PRT);%��λ���������
Na = 2^nextpow2(Na);%Ϊ��fft�����µ���
Nr = round((tr + 2*(rfar-rnear)/C)/Ts);%�������������
Nr = 2^nextpow2(Nr);%Ϊ��fft�����µ���
% PRF = Na / ((xend - xbegin)/v);
% fs = Nr / (tr + 2*(rfar-rnear)/C);
% tslow = linspace(xbegin/v,xend/v,Na);
ts = [-Na/2:Na/2 - 1]*PRT;%��λ����ʱ������
tf = [-Nr/2:Nr/2 - 1]*Ts + 2*rmid/C;%�����������
range = tf*C/2;%������




ntargets = size(targets,1);%��Ŀ�����
echo = zeros(Na,Nr);%��ʼ����Ŀ��
for i = 1:ntargets
    xi = targets(i,1);%��λ������
    yi = targets(i,2);%����������
    tci = ((xi - xc) - (yi - yc)*tan(theta)) / v;%�������Ĵ�Խʱ��
    rci = yi / cos(theta);%�������Ĵ�Խʱ��˲ʱб��
%     tsi = rci*(cos(theta)*tan(theta + beta/2) - sin(theta))/v;%������ʼ�����벨����������ʱ�̵ķ�λ��ʱ���
    tsi = yi * (tan(theta + beta/2 - tan(theta))) / v;
%     tei = rci*(sin(theta) - cos(theta)*tan(theta - beta/2))/v;%�������������벨����������ʱ�̵ķ�λ��ʱ���
    tei = yi * (tan(theta) - tan(theta - beta/2)) / v;
    ri = sqrt(yi^2 + (xi - v*ts).^2);%����ʱ���ڵ�˲ʱб��
    tau = 2 * ri / C;%��ʱ
    t = ones(Na,1)*tf - tau.'*ones(1,Nr);%t-tau����
    phase = pi*kr*t.^2 - 4*pi/lambda*(ri.'*ones(1,Nr));%��λ
    
    echo = echo + exp(1i*phase).* (abs(t)<tr/2) .* ((ts > (tci - tsi) & ts < (tci + tei))' * ones(1,Nr));
    
end
 
ff = linspace(-Fs/2,Fs/2,Nr);
% REF_R = exp(-1i * pi * ff.^2 / kr);
% signal_comp = ifty(fty(echo) .* (ones(Na,1) * REF_R));
fdoc = 2*v*sin(theta)/lambda;%����������Ƶ��
% mamb = round(fdoc / PRF);
% fdoc = fdoc - mamb * PRF;
t = tf - 2*rmid/C;%��ʽ������ƥ���˲��� ��fft֮��ȡ����
ref_r = exp(1i*pi*kr*t.^2) .* (abs(t) < tr/2);
signal_rfat = fty(echo) .* (ones(Na,1) * conj(fty(ref_r)));%.* (exp(-1i*pi*0.9*fdoc*ts).' * ones(1,Nr));
signal_comp = ifty(signal_rfat);%������ѹ֮����ź�
% signal_comp = signal_comp .* (exp(-1i*pi*fdoc*ts).' * ones(1,Nr));
signal_rtaf = ftx(signal_comp);
signal_rfaf = ftx(signal_rfat);%��ά�ź�
% signal_rtat = iftx(ifty(signal_rfaf));
% signal_rtaf = ftx(signal_comp);

% figure;
% subplot(211);
% imagesc(abs(signal_comp));
% subplot(212);
% imagesc(abs(signal_rtat));
fu = linspace(fdoc - PRF/2,fdoc + PRF/2,Na);%��λ��Ƶ��
d = sqrt(1 - (lambda * fu / 2 / v ).^2);
ksrc = 2*v^2*fc^3*d.^3/C/yc./fu.^2;
H_src = exp(-1i*pi*(ones(Na,1) * ff.^2)./(ksrc.' * ones(1,Nr)));
signal_src = ifty(signal_rfaf .* H_src);
% d = sqrt(1-(lambda*fdoc/2/v)^2);
% ksrc = 2*v^2*fc^3*d^3/C/yc/fdoc;
% ref_R = exp(1i*pi*(1/kr-1/ksrc)*ff.^2);
% signal_comp = ifty(fty(echo) .* (ones(Na,1) * ref_R));

% fu = linspace(fdoc + PRF/2,fdoc - PRF/2,Na);
% fa = fftshift(fu);
% fu = ka * ts;
% d = sqrt(1 - (lambda*fu/2/v).^2);
% ksrc = 2*v^2*fc^3*d.^3/C/yc/fdoc^2;
% km = kr/(1 - kr / ksrc);
% ref_r = exp(1i*pi*km*t.^2) .* (abs(t) < tr/2);
% signal_comp1 = ifty(fty(echo) .* (ones(Na,1) * conj(fty(ref_r))));
% t = tf - 2*rnear/C;
% ref_src = exp(1i*pi*ksrc*t.^2) .* (abs(t) < tr/2);
% H_src = exp(-1i*pi*(ones(Na,1) * ff.^2)./(ksrc.' * ones(1,Nr))); 
% H_src = fty(ref_src);
% H_src = exp(-1i * pi * yc * C / (2 * v^2 * fc^3) * ((fu.^2 ./ d.^3)' * ones(1,Nr)) .* f.^2);
% signal_src = ifty(signal_rfaf .* H_src);

% signal_RD = ftx(signal_comp);%������������ź�
signal_RD = signal_src;
% signal_rcmc = zeros(Na,Nr);%��ʼ��
% win = waitbar(0,'��������ֵ');
% for i = 1:Na
%     for j = 1:Nr
%         fai = fdoc + (i - Na/2) / Na * PRF;%��λ��Ƶ��
%         d = sqrt(1 - (lambda*fai/2/v)^2);%D
%         r0 = (yc + (j - Nr/2)*Ts*C/2)*cos(theta);%���б��
%         ksrc = 2*v^2*fc^3/C/r0*d^3/fai^2;%Ksrc
%         
%         rcm = r0*(1/d - 1);%rcmֵ ��Ӧ����
%         n_rcm = 2*rcm/C*Fs;%��Ӧ������
%         
%         delta_nrcm = n_rcm - floor(n_rcm);%С������
%         
%         if j + round(n_rcm) > Nr
%             signal_rcmc(i,j) = signal_RD(i,Nr/2);
%         else
%             if delta_nrcm >= 0.5
%                 signal_rcmc(i,j) = signal_RD(i,j+ceil(n_rcm));
%             else
%                 signal_rcmc(i,j) = signal_RD(i,j+floor(n_rcm));
%             end
%         end
%     end
%     waitbar(i/Na);
% end
% close(win);

win = waitbar(0,'sinc 8���ֵ');
corelen = 8;
signal_rcmc = zeros(Na,Nr);

for i = 1:Na
    for j = corelen:Nr
        fai = fdoc + (i - Na/2) / Na * PRF;%��λ��Ƶ��
        d = sqrt(1 - (lambda*fai/2/v)^2);%D
        r0 = (yc + (j - Nr/2)*Ts*C/2)*cos(theta);%���б��
%         ksrc = 2*v^2*fc^3/C/r0*d^3/fai^2;%Ksrc
        
        rcm = r0*(1/d - 1);%rcmֵ ��Ӧ����
        n_rcm = 2*rcm/C*Fs;%��Ӧ������
        
        delta_nrcm = n_rcm - floor(n_rcm);%С������
        
        for k = -corelen/2:corelen/2-1
            if n_rcm+k+j > Nr
                signal_rcmc(i,j) = signal_rcmc(i,j) + signal_RD(i,Nr) * sinc(k+n_rcm);
            else
                signal_rcmc(i,j) = signal_rcmc(i,j) + signal_RD(i,j+floor(n_rcm)+k) * sinc(k+delta_nrcm);
            end
        end
    end
       waitbar(i/Na);
end
close(win);

fu = linspace(fdoc - PRF/2,fdoc + PRF/2,Na);%��λ��Ƶ��
% f = fftshift(fu);
f = fu;
d = sqrt(1 - (lambda*f/2/v).^2); 
ref_A = exp(1i*4*pi/lambda*(ones(Na,1)*range) .* (d'*ones(1,Nr))) ;%��λ��ѹ�˲���
final_signal = iftx(signal_rcmc .* ref_A) .* (hamming(Na) * ones(1,Nr));

figure;
subplot(211);
imagesc(abs(echo));
xlabel('������');
ylabel('��λ��');
title('�ز��ź�');
subplot(212);
imagesc(abs(signal_comp));
xlabel('������');
ylabel('��λ��');
title('������ѹ֮����ź�');

figure;
subplot(211);
imagesc(abs(signal_RD));
xlabel('������');
ylabel('��λ��');
title('δ����RCMC����������ź�');
subplot(212);
imagesc(abs(signal_rcmc));
xlabel('������');
ylabel('��λ��');
title('RCMC֮��ľ���������ź�');

figure;
imagesc(abs(final_signal));
xlabel('������');
ylabel('��λ��');
title('���յĵ�Ŀ��');

figure;
mesh(abs(final_signal));
xlabel('������');
ylabel('��λ��');
title('���յĵ�Ŀ��');

figure;
plot(20*log10(abs(final_signal) / abs(max(max(final_signal)))));
title('��ֵ�԰��');