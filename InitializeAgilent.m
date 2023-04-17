function InitializeAgilent(fagi)
%Set desired configuration.
% This is similar to pressing the buttons on the Agilent
fprintf(fagi,'FUNCTION PULSE'); % Put the tool in pulse mode.
fprintf(fagi,'BURST:STATE ON'); %  Make it burst so that we send only 1 pulse.
fprintf(fagi,'BURST:MODE:TRIGGERED'); % Make it triggered and not gated (see manual for info)
fprintf(fagi,'BURST:NCYCLES:1'); % Send only 1 pulse
fprintf(fagi,'TRIGGER:SOURCE:BUS'); %Use the USB bus as trigger 
fprintf(fagi,'VOLTAGE:HIGH 4'); % use between 3.3 and 5 volts to make the transistor conductive
fprintf(fagi,'VOLTAGE:LOW 0'); % Set it to 0 so that the transistor is turned off
fprintf(fagi,'OUTPUT:LOAD 50'); % set output load to 50 ohms - the device has a 50 ohm impedance and assumes a 50 ohm load
fprintf(fagi,['pulse:transition',' ',num2str(200E-9)]); % slowish rise and decay time for the gate to minimize oscilations
    % and ringing
    % Addition of increase pulse transition time on 2023 04 17
% Out transistor will have from gate to base way more than that so the
% actual voltage will likely be double. Check what voltage you need gate to
% source in order to have the current you want through your heater and then
% back calculate the voltage you need to tell the function agilent to send.
% 
pause(3);
end