//+------------------------------------------------------------------+
//|                                               DoublecciWoody.mq4 |
//|
//+------------------------------------------------------------------+
#property copyright " DoublecciWoody."
#property link      "DoublecciWoody"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1  clrMediumSeaGreen   //Green
#property indicator_color2  clrRed   //SaddleBrown
#property indicator_color3  clrDarkGray
#property indicator_color4  clrGold
#property indicator_color5  clrDarkKhaki //White
#property indicator_color6  clrWhite  //Magenta
#property indicator_color7  clrDarkKhaki  //Gold  <<<<<<<<<<<<<<<<<<<<<<<<<<
#property indicator_level1  350
#property indicator_level2  250
#property indicator_level3  100
#property indicator_level4  0
#property indicator_level5  -100
#property indicator_level6  -250
#property indicator_level7  -350
//#property indicator_level8 -50

//---- input parameters
extern ENUM_TIMEFRAMES TimeFrame        = PERIOD_CURRENT; // Time frame to use
extern int             TrendCCI_Period  = 89;//14
extern int             EntryCCI_Period  = 21;//6
extern int             Trend_period     = 2;//6
extern int             CountBars        = 1000; 
extern bool            Zero_Cross_Alert = true;
extern int             LineSize1        = 2;
extern int             LineSize2        = 3;
extern int             LineSize3        = 2;//1
extern bool            ShowArrows       = false;
input bool             arrowsOnNewest   = true;               // Arrows drawn on newest bar of higher time frame bar?
extern string          arrowsIdentifier = "dcci Arrows1";
extern double          arrowsUpperGap   = 1.0;
extern double          arrowsLowerGap   = 1.0;
extern color           arrowsUpColor    = clrLimeGreen;
extern color           arrowsDnColor    = clrRed;
extern int             arrowsUpCode     = 241;
extern int             arrowsDnCode     = 242;
extern bool            Interpolate      = true;             // Interpolate in mtf mode

double TrendCCI[],EntryCCI[],CCITrendUp[],CCITrendDown[],CCINoTrend[],CCITimeBar[],ZeroLine[],trend[],count[];
int trendUp, trendDown;
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,TrendCCI_Period,EntryCCI_Period,Trend_period,CountBars,Zero_Cross_Alert,LineSize1,LineSize2,LineSize3,ShowArrows,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,_buff,_ind)

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()  {
   IndicatorBuffers(9);
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID,LineSize1);
   SetIndexBuffer(4, TrendCCI);
   SetIndexLabel(4, "TrendCCI");
   SetIndexStyle(0, DRAW_HISTOGRAM, 0,LineSize1);//2
   SetIndexBuffer(0, CCITrendUp);
   SetIndexStyle(1, DRAW_HISTOGRAM, 0,LineSize1);//2
   SetIndexBuffer(1, CCITrendDown);
   SetIndexStyle(2, DRAW_HISTOGRAM, 0,LineSize2);
   SetIndexBuffer(2, CCINoTrend);
   SetIndexStyle(3, DRAW_HISTOGRAM, 0,LineSize2);
   SetIndexBuffer(3, CCITimeBar);
   SetIndexStyle(5, DRAW_LINE, STYLE_SOLID,LineSize2);// 1 <<<<<<<<<<<<<<<<<<<<<<<<<<<
   SetIndexBuffer(5, EntryCCI);
   SetIndexLabel(5, "EntryCCI");
   SetIndexStyle(6, DRAW_LINE, STYLE_SOLID,LineSize3);
   SetIndexBuffer(6, ZeroLine);
   SetIndexBuffer(7, trend);  
   SetIndexBuffer(8, count); 
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+" ( TrendCCI: " + TrendCCI_Period + ", EntryCCI: " + EntryCCI_Period + ") ");   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   deleteArrows(); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {

   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(MathMin(Bars-counted_bars,CountBars),Bars-1); count[0] = limit;
         if (TimeFrame != _Period)
         {
            limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(9,0)*TimeFrame/_Period));
            for (i=limit;i>=0 && !_StopFlag; i--)
            {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     CCITrendUp[i]   = _mtfCall(0,y);
   	               CCITrendDown[i] = _mtfCall(1,y);
   	               CCINoTrend[i]   = _mtfCall(2,y);
                     CCITimeBar[i]   = _mtfCall(3,y);
                     TrendCCI[i]     = _mtfCall(4,y);
                     EntryCCI[i]     = _mtfCall(5,y);
                     ZeroLine[i]     = _mtfCall(6,y);
                     
                     //
                     //
                     //
                     //
                     //
                     
                      if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                      #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                      int n,k; datetime time = iTime(NULL,TimeFrame,y);
                         for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                         for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) 
                         {
                            _interpolate(TrendCCI);
                            _interpolate(EntryCCI);
                            if (CCITrendUp[i]  != 0) CCITrendUp[i+k]   = TrendCCI[i+k];
  	                         if (CCITrendDown[i]!= 0) CCITrendDown[i+k] = TrendCCI[i+k];
  	                         if (CCINoTrend[i]  != 0) CCINoTrend[i+k]   = TrendCCI[i+k];
  	                         if (CCITimeBar[i]  != 0) CCITimeBar[i+k]   = TrendCCI[i+k];
  	                      }
            }
   return(0);
   }

   //
   //
   //
   //
   //
   
   int trendCCI, entryCCI;
   static datetime prevtime = 0;
//---- check for possible errors
   
     SetIndexDrawBegin(0,Bars-CountBars);
     SetIndexDrawBegin(1,Bars-CountBars);
     SetIndexDrawBegin(2,Bars-CountBars);
     SetIndexDrawBegin(3,Bars-CountBars);
     SetIndexDrawBegin(4,Bars-CountBars);
     SetIndexDrawBegin(5,Bars-CountBars);
     SetIndexDrawBegin(6,Bars-CountBars);
   

      trendCCI = TrendCCI_Period;
      entryCCI = EntryCCI_Period;
   
   for(i = limit; i >= 0; i--) {
      CCINoTrend[i] = 0;
      CCITrendDown[i] = 0;
      CCITimeBar[i] = 0;
      CCITrendUp[i] = 0;
      ZeroLine[i] = 0;
      TrendCCI[i] = iCCI(NULL, 0, trendCCI, PRICE_TYPICAL, i);
      EntryCCI[i] = iCCI(NULL, 0, entryCCI, PRICE_TYPICAL, i);
      
      if(TrendCCI[i] > 0 && TrendCCI[i+1] < 0) {
         if (trendDown >  Trend_period) trendUp = 0;
      }
      if (TrendCCI[i] > 0) {
         if (trendUp <  Trend_period){
            CCINoTrend[i] = TrendCCI[i];
            trendUp++;
         }
         if (trendUp ==  Trend_period) {
            CCITimeBar[i] = TrendCCI[i];
            trendUp++;
         }
         if (trendUp >  Trend_period) {
            CCITrendUp[i] = TrendCCI[i];
         }
      }
      if(TrendCCI[i] < 0 && TrendCCI[i+1] > 0) {
         if (trendUp >  Trend_period) trendDown = 0;
      }
      if (TrendCCI[i] < 0) {
         
         if (trendDown <  Trend_period){
            CCINoTrend[i] = TrendCCI[i];
            trendDown++;
         }
         if (trendDown ==  Trend_period) {
            CCITimeBar[i] = TrendCCI[i];
            trendDown++;
         }
         if (trendDown >  Trend_period) {
            CCITrendDown[i] = TrendCCI[i];
         }
      }
      trend[i] = 0;
      if (EntryCCI[i]>ZeroLine[i]) trend[i] = 1;
      if (EntryCCI[i]<ZeroLine[i]) trend[i] =-1;
      
      //
      //
      //
      //
      //
            
      if (ShowArrows)
      {
         deleteArrow(Time[i]);
         if (trend[i] != trend[i+1])
         {
            if (trend[i] == 1)  drawArrow(i,arrowsUpColor,arrowsUpCode,false);
            if (trend[i] ==-1)  drawArrow(i,arrowsDnColor,arrowsDnCode, true);
         }
      } 
   }
   
   if (Zero_Cross_Alert == true) {
      if (prevtime == Time[0]) {
         return(0);
      }
      else {
         if(EntryCCI[0] < 0) {
            if((TrendCCI[0] < 0) && (TrendCCI[1] >= 0)) {
               Alert(Symbol(), " M", Period(), " Trend & Entry CCI Have both crossed below zero");
            }
         }
         else if(EntryCCI[0] > 0) {
            if((TrendCCI[0] > 0) && (TrendCCI[1] <= 0)) {
               Alert(Symbol(), " M", Period(), " Trend & Entry CCI Have both crossed above zero");
            }
         }
         prevtime = Time[0];
      }
   }
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //
      
      datetime time = Time[i]; if (arrowsOnNewest) time += _Period*60-1;      
      ObjectCreate(name,OBJ_ARROW,0,time,0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}

//
//
//
//
//

void deleteArrows()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}

//
//
//
//
//

void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}

//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}


      


