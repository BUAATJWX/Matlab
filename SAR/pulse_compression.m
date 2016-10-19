function y = pulse_compression(signal_org,signal_ref,Na)

% signal_org  ���յ����ź�
%signal_ref �ο����ź�
%��λ���������

signal_Ra = fty(signal_org);
signal_REF = fty(signal_ref);

y = ifty(signal_Ra .* conj(ones(Na,1) * signal_REF));
