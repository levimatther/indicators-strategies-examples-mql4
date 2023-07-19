//+------------------------------------------------------------------+
//|                                        FXPT_ExportHistoryCSV.mq4 |
//|                                         modified by fxprotrader |
//|                                     http://www.fxpro-trader.com" |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, fxprotrader"
#property link      "http://www.fxpro-trader.com"
// #property show_inputs
//-------- HISTORY----------------
// v1.0 Initial release(12162012)
//--------------------------------
//----
 int handle;
 
 //number of bars to export per Symbol
//  int maxBars = 6418;
extern int maxBars = 200;
 //test first on several pairs
// string Currencies[] = {"EURUSD","AUDUSD","GBPUSD","EURJPY","GBPJPY","USDCAD"};
string Currencies[] = {"GBPUSD"};
 
 
 // then add more in the same format
// string Currencies[] = {"EURUSD","GBPJPY","GBPUSD","EURGBP","USDCHF","USDJPY","AUDJPY","CHFJPY","CADJPY","GBPCAD","EURAUD","EURCAD","NZDUSD","NZDJPY"};
string dSymbol;
double Poin;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){
  
   if (Point==0.00001) Poin=0.0001;
   else {
      if (Point==0.001) Poin=0.01;
      else Poin=Point;
   }
  return(0);
  }
//+------------------------------------------------------------------+
//|  start function                                    |
//+------------------------------------------------------------------+
int start(){

 int count = ArraySize(Currencies);
 for (int ii=0; ii<count; ii++){
 dSymbol = Currencies[ii];   
 handle = FileOpen("Hist_"+dSymbol+"_"+Period()+".csv", FILE_BIN|FILE_WRITE);

if(handle < 1){
 Print("Err ", GetLastError());
return(0);
}
 WriteHeader();

for(int i = 0; i < maxBars - 1; i++){
 WriteDataRow(i);
}
 FileClose(handle);
}
 Alert("Done. "+maxBars+" bars generated "+TimeMonth(TimeLocal())+TimeDay(TimeLocal())+TimeYear(TimeLocal()) +"_"+TimeHour(TimeLocal())+TimeMinute(TimeLocal()));

return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteData(string txt){

   FileWriteString(handle, txt,StringLen(txt));

return;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteHeader(){

 WriteData("Symbol,");
 WriteData("Date,");
 WriteData("DayOfWeek,");
 WriteData("DayOfYear,");
 WriteData("Open,");
 WriteData("High,");
 WriteData("Low,");
 WriteData("Close,");
 WriteData("RSI5,RSI11,MOM3_c,CCI11_c,");
 WriteData("\n");
  
  return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteDataRow(int i){
 
 double  dSymTime, dSymOpen, dSymHigh, dSymLow, dSymClose, dSymVolume;
 int dDayofWk,dDayofYr,iDigits;
 dSymTime = (iTime(dSymbol,Period(),i));
 dDayofWk = (TimeDayOfWeek(dSymTime));
 dDayofYr = TimeDayOfYear(dSymTime);

 
 dSymOpen = (iOpen(dSymbol,Period(),i));

// if(TimeToStr(dSymTime, TIME_DATE)!= "1970."){
if(dSymOpen>0){
 WriteData(dSymbol+",");
 WriteData(TimeToStr(dSymTime, TIME_DATE|TIME_MINUTES)+",");
 
 iDigits=MarketInfo(Symbol(),MODE_DIGITS);
 dSymOpen = (iOpen(dSymbol,Period(),i));
 dSymHigh = (iHigh(dSymbol,Period(),i));
 dSymLow = (iLow(dSymbol,Period(),i));
 dSymClose = (iClose(dSymbol,Period(),i));
 dSymVolume = (iVolume(dSymbol,Period(),i));
 
//  int BarsInBox=8;
 
//  double PeriodHighest = High[iHighest(dSymbol,Period(),MODE_HIGH,BarsInBox+1,i)];
//  double PeriodLowest  =  Low[iLowest(dSymbol,Period(),MODE_LOW,BarsInBox+1,i)];
//  double PeriodRNG  =  (PeriodHighest-PeriodLowest)/Poin;
double RSI5_c  =  iRSI(NULL,0,5,PRICE_CLOSE,i);
double RSI5_p3  = iRSI(NULL,0,5,PRICE_CLOSE,i+3);
double MOM3_c  = iMomentum(NULL,0,21,PRICE_CLOSE,i);
double MOM3_p3  = iMomentum(NULL,0,21,PRICE_CLOSE,i+3);
double CCI11_c =  iCCI(NULL,0,5,PRICE_CLOSE,i);
double CCI11_p3 =  iCCI(NULL,0,5,PRICE_CLOSE,i+3);


 WriteData(dDayofWk+","+dDayofYr+",");
 WriteData(DoubleToStr(dSymOpen, iDigits)+",");
 WriteData(DoubleToStr(dSymHigh, iDigits)+",");
 WriteData(DoubleToStr(dSymLow, iDigits)+",");
//  WriteData(DoubleToStr(dSymClose, iDigits)+","+PeriodHighest+","+PeriodLowest+","+PeriodRNG);
 WriteData(DoubleToStr(dSymClose, iDigits)+","+DoubleToStr(RSI5_c,2)+","+DoubleToStr(RSI5_p3,2)+
 ","+DoubleToStr(MOM3_c,2)+","+DoubleToStr(MOM3_p3,2)+","+DoubleToStr(CCI11_c,2)+","+DoubleToStr(CCI11_p3,2)+",");
 WriteData("\n");
 }
 
 return;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetPeriodName(){

   switch(Period()){
     
       case PERIOD_D1:  return("Day");
       case PERIOD_H4:  return("4_Hour");
       case PERIOD_H1:  return("Hour");
       case PERIOD_M1:  return("Minute");
       case PERIOD_M15: return("15_Minute");
       case PERIOD_M30: return("30_Minute");
       case PERIOD_M5:  return("5_Minute");
       case PERIOD_MN1: return("Month");
       case PERIOD_W1:  return("Week");
     }
  }
