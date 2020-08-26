function  [Piezo1LargeMovementTimeInSec,Piezo2LargeMovementTimeInSec,Piezo1DataIn2000HzNormalized,Piezo2DataIn2000HzNormalized]...
        =AnalyzePiezoSensorsData_6_6_2017(Piezo1DataIn2000Hz,Piezo2DataIn2000Hz,StartTriggerTimeInSec,LargeMovementsLowThresholdInPercent,LargeMovementsMinimalIntervalInSec)

%%%%%%%%% Removing baseling, which are voltages under the frequency of 1Hz
%%%%%%%%% Taking the data after the Trigger only
   Piezo1DataIn2000Hz=Piezo1DataIn2000Hz(round(StartTriggerTimeInSec*2000):end);
   Piezo2DataIn2000Hz=Piezo2DataIn2000Hz(round(StartTriggerTimeInSec*2000):end);
   [bLow,aLow] = butter(3,0.001);
   [bHigh,aHigh] = butter(3,0.1);
   Piezo1FilteredUpTo10Hz=filtfilt(bLow,aLow,Piezo1DataIn2000Hz);
   Piezo2FilteredUpTo10Hz=filtfilt(bLow,aLow,Piezo2DataIn2000Hz);
   Piezo1FilteredUpTo100Hz=filtfilt(bHigh,aHigh,Piezo1DataIn2000Hz);
   Piezo2FilteredUpTo100Hz=filtfilt(bHigh,aHigh,Piezo2DataIn2000Hz);
   Piezo1DataIn2000Hz=Piezo1FilteredUpTo100Hz-Piezo1FilteredUpTo10Hz;
   Piezo2DataIn2000Hz=Piezo2FilteredUpTo100Hz-Piezo2FilteredUpTo10Hz;
   Piezo1DataIn2000HzForNormalization=Piezo1DataIn2000Hz;
   Piezo2DataIn2000HzForNormalization=Piezo2DataIn2000Hz;
   Piezo1DataIn2000Hz=abs(diff(Piezo1DataIn2000Hz));
   Piezo2DataIn2000Hz=abs(diff(Piezo2DataIn2000Hz));  
   MaxPiezo1Response=max(Piezo1DataIn2000Hz);
   MaxPiezo2Response=max(Piezo2DataIn2000Hz);
  
%%%%%%%% Extracting large movements from the data

   Piezo1LargeMovementTimeInSec=find(Piezo1DataIn2000Hz>(MaxPiezo1Response*LargeMovementsLowThresholdInPercent/100) | Piezo1DataIn2000Hz<-(MaxPiezo1Response*LargeMovementsLowThresholdInPercent/100));
   Piezo2LargeMovementTimeInSec=find(Piezo2DataIn2000Hz>(MaxPiezo2Response*LargeMovementsLowThresholdInPercent/100) | Piezo2DataIn2000Hz<-(MaxPiezo2Response*LargeMovementsLowThresholdInPercent/100));

%%%%%%%%%%%%%%%   Removing duplication of medium and large movements, resulting from the same movement epoke

  if ~isempty(Piezo1LargeMovementTimeInSec)
     Piezo1LargeTemp=[];
     Piezo1LargeTemp=[Piezo1LargeTemp, Piezo1LargeMovementTimeInSec(1)];
     for i=2:length(Piezo1LargeMovementTimeInSec)
        if Piezo1LargeMovementTimeInSec(i)-Piezo1LargeMovementTimeInSec(i-1)>LargeMovementsMinimalIntervalInSec*2000   %%% A new movement is after X sec (2000samples) has passed
           Piezo1LargeTemp=[Piezo1LargeTemp,Piezo1LargeMovementTimeInSec(i)];
        end
     end
     Piezo1LargeMovementTimeInSec=Piezo1LargeTemp;
  end
  
  if ~isempty(Piezo2LargeMovementTimeInSec)
     Piezo2LargeTemp=[];
     Piezo2LargeTemp=[Piezo2LargeTemp, Piezo2LargeMovementTimeInSec(1)];
     for i=2:length(Piezo2LargeMovementTimeInSec)
        if Piezo2LargeMovementTimeInSec(i)-Piezo2LargeMovementTimeInSec(i-1)>LargeMovementsMinimalIntervalInSec*2000   %%% A new movement is after X sec (2000samples) has passed
           Piezo2LargeTemp=[Piezo2LargeTemp,Piezo2LargeMovementTimeInSec(i)];
        end
     end
     Piezo2LargeMovementTimeInSec=Piezo2LargeTemp;
  end
  
  %%%%%%%%% Convert to time in Sec
  Piezo1LargeMovementTimeInSec=Piezo1LargeMovementTimeInSec/2000;
  Piezo2LargeMovementTimeInSec=Piezo2LargeMovementTimeInSec/2000;
  Piezo1DataIn2000HzNormalized=abs(Piezo1DataIn2000HzForNormalization)/max(abs(Piezo1DataIn2000HzForNormalization));
  Piezo2DataIn2000HzNormalized=abs(Piezo2DataIn2000HzForNormalization)/max(abs(Piezo2DataIn2000HzForNormalization));
     
   
end

