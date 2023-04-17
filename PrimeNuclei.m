%Apply a battery of pulses to hit the nucleation regime and prime the PCM
%without necesarily promoting crystal growth;
%See reference: Orava, J. and Greer, A.L., 2017. Classical-nucleation-theory
%analysis of priming in chalcogenide phase-change memory. 
%Acta Materialia, 139, pp.226-235.
function PrimeNuclei(fgen,fkie, Current, period, width,tdelay)
  for i= 1:numel(Current)
    SendPulse(fgen,fkie, Current(i), period, width,tdelay);
    pause(tdelay*3+period*2);
  end
end