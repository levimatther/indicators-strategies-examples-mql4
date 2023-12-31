//+------------------------------------------------------------------+
//|                                            !jl_ZigZag_Custom.mq4 |
//|                            Copyright © September 2021, jeanlouie |
//|                                   www.forexfactory.com/jeanlouie |
//|                               www.mql5.com/en/users/jeanlouie_ff |
//+------------------------------------------------------------------+

#property strict
#property indicator_chart_window
#property description "kishore2616"
#property version   "1.52"
#property indicator_buffers 64


#property indicator_type14 DRAW_ARROW
#property indicator_color14 Blue
#property indicator_width14 2
#property indicator_type15 DRAW_ARROW
#property indicator_color15 Blue
#property indicator_width15 2
#property indicator_type16 DRAW_ARROW
#property indicator_color16 Green
#property indicator_width16 2
#property indicator_type17 DRAW_ARROW
#property indicator_color17 Green
#property indicator_width17 2

#property indicator_type18 DRAW_ARROW
#property indicator_color18 Red
#property indicator_width18 2
#property indicator_type19 DRAW_ARROW
#property indicator_color19 Red
#property indicator_width19 2
#property indicator_type20 DRAW_ARROW
#property indicator_color20 Orange
#property indicator_width20 2
#property indicator_type21 DRAW_ARROW
#property indicator_color21 Orange
#property indicator_width21 2

#property indicator_type22 DRAW_ARROW
#property indicator_color22 Blue
#property indicator_width22 2
#property indicator_type23 DRAW_ARROW
#property indicator_color23 Red
#property indicator_width23 2


#property indicator_type25 DRAW_ARROW
#property indicator_color25 Blue
#property indicator_width25 2
#property indicator_type26 DRAW_ARROW
#property indicator_color26 Red
#property indicator_width26 2


#property indicator_type28 DRAW_ARROW
#property indicator_color28 Blue
#property indicator_width28 2
#property indicator_type29 DRAW_ARROW
#property indicator_color29 Red
#property indicator_width29 2

#property indicator_type31 DRAW_ARROW
#property indicator_color31 Blue
#property indicator_width31 2
#property indicator_type32 DRAW_ARROW
#property indicator_color32 Red
#property indicator_width32 2



struct MyObject
  {
   datetime          StartTime;
   datetime          ExpiryTime;
   int               Type;
  };



MyObject MyObjects[];


input bool ShowObjects = true;

input ENUM_TIMEFRAMES tf = PERIOD_CURRENT;      //TF

input int InpDepth=7;                          // Depth
input int InpDeviation=6;                       // Deviation
input int InpBackstep=5;                        // Backstep

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input bool zz_hl = false;                        //Base on HL (F=close)

input int Recent_Zigzag=12;//Recent Zigzag
input int Imbalance=5;


//-------------------------------------------------------------------------------
input int ZigZagBasedOnEntries_Percent = -1; //ZigZagBasedOnEntries_Percent(neg means not active)
input bool ZigZagBasedOnDivergence = false;
input int RSI_Period = 14;
input int PrevZZ_RSILevel_Buy = 65;
input int PrevZZ_RSILevel_Sell = 35;
input int    ADR_Period = 5;//ADR Period
input string oset = "Old Settings";
//---------------------------UPTO MarketShift------------------------------------
input int HistoryDays=15;//History Days
input bool   Enable_ADR_Swing = true;//Enable ADR Swing
input double Main_Swing_ADR_Percent = 3.5;//Main Swing ADR %
input double Sub_Swing_ADR_Percent  = 2.5;//Sub Swing ADR %
input bool Enable_Arrows=true;//Enable Arrows
input ENUM_TIMEFRAMES RSI_TF = PERIOD_M15;//RSI Filter Time Frame
input double Buy_Level_Type1  = 65;//Buy Level For Type1
input double Sell_Level_Type1 = 35;//Sell Level For Type1
input double Buy_Level_Type2  = 50;//Buy Level For Type2
input double Sell_Level_Type2 = 50;//Sell Level For Type2

bool   Show_Range_Calculations = false;//Show Range Calculation
bool Enable_Sub_Swings=true;//Enable Sub Swings
double ADR_Filter_Sub_Range = 5;//ADR% needed to filter Sub Swing Range Scenes: 5% (step1)
double ADR_Filter_Sub_Range_Swing = 5;//ADR% extend for Sub Swing Range Swings: 5%
bool Enable_Main_Swings=true;//Enable Main Swings
double ADR_Filter_Main_Range = 7.5;//ADR% needed to filter Main Swing Range Scenes: 5% (step1)
double ADR_Filter_Main_Range_Swing = 7.5;//ADR% extend for Main Swing Range Swings: 5%


input bool   Show_Range_Calculations_U = true;//Show Range Calculation U
input bool Enable_Sub_Swings_U=true;//Enable Sub Swings U
input double ADR_Filter_Sub_Range_U = 5;//ADR% needed to filter Sub Swing Range Scenes: 5% (step1) U
input double ADR_Filter_Sub_Range_Swing_U = 5;//ADR% extend for Sub Swing Range Swings: 5% U
input bool Enable_Main_Swings_U=true;//Enable Main Swings U
input double ADR_Filter_Main_Range_U = 7.5;//ADR% needed to filter Main Swing Range Scenes: 5% (step1) U
input double ADR_Filter_Main_Range_Swing_U = 5;//ADR% extend for Main Swing Range Swings: 5% U


//-------------------------------------------------------------------------------
input string note_s = "";                       //Styling
input int line_w = 2;                           //__ line width
input color line_clr_up = clrDodgerBlue;        //__ __ ZZ up
input color line_clr_dn = clrRed;               //__ __ ZZ down
input int text_fs = 12;                         //__ text font size
input color text_clr_hh = clrDodgerBlue;        //__ __ HH color
input color text_clr_lh = clrRed;         //__ __ LH color
input color text_clr_ll = clrRed;               //__ __ LL color
input color text_clr_hl = clrDodgerBlue;            //__ __ HL color
input bool text_show_time = true;               //__ __ show time

input string note_alert = "";                   //Alert
input bool alert_hh = false;                     //__ HH on
input bool alert_lh = false;                     //__ LH on
input bool alert_ll = false;                     //__ LL on
input bool alert_hl = false;                     //__ HL on
input bool alert_print=false;                   //__ print
input bool alert_pop=false;                     //__ popup
input bool alert_push=false;                    //__ push
input bool alert_email=false;                   //__ email
input bool alert_sound = false;                 //__ sound
input string alert_sname = "Alert2.wav";        //__ __ file name
input bool Enable_Range_Alert=false;
input int RSI_Period1 = 14;
input int PrevZZ_RSILevel_Buy1 = 65;
input int PrevZZ_RSILevel_Sell1 = 35;
input bool EnableSingleValidity=true;//Enable Single Validity
input double Single_Validity_Candles = 18;//Single Validity Candles
input bool EnableDoubleValidity=true;//Enable Double Validity
input double Double_Validity_Candles = 24;//Double Validity Candles
input double Sub_Range_Validity_Candles = 12;//Sub Range Validity Candles
input double Main_Range_Validity_Candles = 18;//Main Range Validity Candles


double ExtZigzagBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];

double b_hh[];
double b_lh[];
double b_ll[];
double b_hl[];


double ExtZigzagBuffer1[];
double ExtHighBuffer1[];
double ExtLowBuffer1[];

double b_hh1[];
double b_lh1[];
double b_ll1[];
double b_hl1[];


double b_mainswing[];
double b_subswing[];
double b_mainswing_diff[];
double b_subswing_diff[];
double ADR[];


double BuyArrow[];
double EndBuyArrow[];
double BuyArrow2[];
double EndBuyArrow2[];

double SellArrow[];
double EndSellArrow[];
double SellArrow2[];
double EndSellArrow2[];



double SubBuyArrowBreak[];
double SubSellArrowBreak[];
double SubValidEntry[];

double MainBuyArrowBreak[];
double MainSellArrowBreak[];
double MainValidEntry[];

double SubBuyArrowBreakU[];
double SubSellArrowBreakU[];
double SubValidEntryU[];

double MainBuyArrowBreakU[];
double MainSellArrowBreakU[];
double MainValidEntryU[];


double SubBuyBreakU[];
double SubSellBreakU[];

double MainBuyBreakU[];
double MainSellBreakU[];


double TimeOccurBuffer[];

double TimeOccurBuffer1[];

double BuyValid[];
double SellValid[];
double RangeValid[];

double BuyStruct[];
double SellStruct[];

double SingleValidity[];
double DoubleValidity[];

double SubRangeFormedValidity[];
double MainRangeFormedValidity[];
double TotalRangeFormedValidity[];
double TotalBreakValidity[];

double BuySum[];
double BuyWeightage[];
double SellSum[];
double SellWeightage[];

double Swing[];

double ZigZagBuf[];
double ImbalanceBuf[];
double ZigZagValidBuf[];

//--- globals
int    ExtLevel=3;
int    ExtLevel1=3;
bool alert_on;

string iname;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_mtf(ENUM_TIMEFRAMES _tf, int _buff, int _shift)
  {
   return(iCustom(_Symbol,_tf,iname,PERIOD_CURRENT,InpDepth,InpDeviation,InpBackstep,zz_hl,_buff,_shift));
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

datetime RangeTime;
datetime RangeTime1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   ObjectsDeleteAll(0,"zz");

   if(alert_print||alert_pop||alert_push||alert_email||alert_sound)
      alert_on=true;
   else
      alert_on=false;

   iname = WindowExpertName();

   if(InpBackstep>=InpDepth)
     {
      Print("Backstep cannot be greater or equal to Depth");
      return(INIT_FAILED);
     }




//--- 2 additional buffers
   IndicatorBuffers(46);
//---- drawing settings
   SetIndexStyle(4,DRAW_NONE);
//---- indicator buffers
   SetIndexBuffer(4,ExtZigzagBuffer);
   SetIndexLabel(4,"ZZ("+string(InpDepth)+","+string(InpDeviation)+","+string(InpBackstep)+")");
   if(tf!=PERIOD_CURRENT && tf!=_Period)
      SetIndexLabel(4,"ZZ("+string(InpDepth)+","+string(InpDeviation)+","+string(InpBackstep)+")"+StringSubstr(EnumToString(tf),7,0));
   SetIndexBuffer(11,ExtHighBuffer,INDICATOR_CALCULATIONS);
   SetIndexLabel(11,"ZZ High");
   SetIndexBuffer(12,ExtLowBuffer,INDICATOR_CALCULATIONS);
   SetIndexLabel(12,"ZZ Low");
   SetIndexStyle(12,DRAW_NONE);
   SetIndexStyle(11,DRAW_NONE);
   SetIndexEmptyValue(4,0.0);
   SetIndexBuffer(5,TimeOccurBuffer);
   SetIndexLabel(5,"TimeOccur");
   SetIndexStyle(5,DRAW_NONE);
   SetIndexEmptyValue(5,EMPTY_VALUE);
   SetIndexBuffer(0,b_hh);
   SetIndexLabel(0,"HH");
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexBuffer(1,b_lh);
   SetIndexLabel(1,"LH");
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexBuffer(2,b_ll);
   SetIndexLabel(2,"LL");
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexBuffer(3,b_hl);
   SetIndexLabel(3,"HL");
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexBuffer(6,ADR);
   SetIndexLabel(6,"ADR Pips");
   SetIndexEmptyValue(6,EMPTY_VALUE);
   SetIndexBuffer(7,b_mainswing);
   SetIndexLabel(7,"Main Swing");
   SetIndexEmptyValue(7,EMPTY_VALUE);
   SetIndexBuffer(8,b_subswing);
   SetIndexLabel(8,"Sub Swing");
   SetIndexEmptyValue(8,EMPTY_VALUE);
   SetIndexBuffer(9,b_mainswing_diff);
   SetIndexLabel(9,"Main Swing Diff");
   SetIndexEmptyValue(9,EMPTY_VALUE);
   SetIndexBuffer(10,b_subswing_diff);
   SetIndexLabel(10,"Sub Swing Diff");
   SetIndexEmptyValue(10,EMPTY_VALUE);

   SetIndexBuffer(13,BuyArrow);
   SetIndexLabel(13,"Buy Type 1");
   SetIndexArrow(13,233);
   SetIndexEmptyValue(13,EMPTY_VALUE);

   SetIndexBuffer(14,EndBuyArrow);
   SetIndexLabel(14,"End Buy Type 1");
   SetIndexArrow(14,252);
   SetIndexEmptyValue(14,0);

   SetIndexBuffer(15,BuyArrow2);
   SetIndexLabel(15,"Buy Type 2");
   SetIndexArrow(15,233);
   SetIndexEmptyValue(15,EMPTY_VALUE);

   SetIndexBuffer(16,EndBuyArrow2);
   SetIndexLabel(16,"End Buy Type 2");
   SetIndexArrow(16,252);
   SetIndexEmptyValue(16,0);

   SetIndexBuffer(17,SellArrow);
   SetIndexLabel(17,"Sell Type 1");
   SetIndexArrow(17,234);
   SetIndexEmptyValue(17,EMPTY_VALUE);

   SetIndexBuffer(18,EndSellArrow);
   SetIndexLabel(18,"End Sell Type 1");
   SetIndexArrow(18,251);
   SetIndexEmptyValue(18,0);

   SetIndexBuffer(19,SellArrow2);
   SetIndexLabel(19,"Sell Type 2");
   SetIndexArrow(19,234);
   SetIndexEmptyValue(19,EMPTY_VALUE);

   SetIndexBuffer(20,EndSellArrow2);
   SetIndexLabel(20,"End Sell Type 2");
   SetIndexArrow(20,251);
   SetIndexEmptyValue(20,0);


   SetIndexBuffer(21,SubBuyArrowBreak);
   SetIndexArrow(21,233);
   SetIndexLabel(21,"Sub Break Buy");
   SetIndexEmptyValue(21,EMPTY_VALUE);

   SetIndexBuffer(22,SubSellArrowBreak);
   SetIndexArrow(22,234);
   SetIndexLabel(22,"Sub Break Sell");
   SetIndexEmptyValue(22,EMPTY_VALUE);

   SetIndexBuffer(23,SubValidEntry);
   SetIndexLabel(23,"Sub Valid Entry");
   SetIndexEmptyValue(23,EMPTY_VALUE);
   SetIndexStyle(23,DRAW_NONE);

   SetIndexBuffer(24,MainBuyArrowBreak);
   SetIndexArrow(24,233);
   SetIndexLabel(24,"Main Break Buy");
   SetIndexEmptyValue(24,EMPTY_VALUE);

   SetIndexBuffer(25,MainSellArrowBreak);
   SetIndexArrow(25,234);
   SetIndexLabel(25,"Main Break Sell");
   SetIndexEmptyValue(25,EMPTY_VALUE);

   SetIndexBuffer(26,MainValidEntry);
   SetIndexLabel(26,"Main Valid Entry");
   SetIndexEmptyValue(26,EMPTY_VALUE);
   SetIndexStyle(26,DRAW_NONE);


   SetIndexBuffer(27,SubBuyArrowBreakU);
   SetIndexArrow(27,233);
   SetIndexLabel(27,"U Sub Break Buy");
   SetIndexEmptyValue(27,EMPTY_VALUE);

   SetIndexBuffer(28,SubSellArrowBreakU);
   SetIndexArrow(28,234);
   SetIndexLabel(28,"U Sub Break Sell");
   SetIndexEmptyValue(28,EMPTY_VALUE);

   SetIndexBuffer(29,SubValidEntryU);
   SetIndexLabel(29,"U Sub Valid Entry");
   SetIndexEmptyValue(29,EMPTY_VALUE);
   SetIndexStyle(29,DRAW_NONE);

   SetIndexBuffer(30,MainBuyArrowBreakU);
   SetIndexArrow(30,233);
   SetIndexLabel(30,"U Main Break Buy");
   SetIndexEmptyValue(30,EMPTY_VALUE);

   SetIndexBuffer(31,MainSellArrowBreakU);
   SetIndexArrow(31,234);
   SetIndexLabel(31,"U Main Break Sell");
   SetIndexEmptyValue(31,EMPTY_VALUE);

   SetIndexBuffer(32,MainValidEntryU);
   SetIndexLabel(32,"U Main Valid Entry");
   SetIndexEmptyValue(32,EMPTY_VALUE);
   SetIndexStyle(32,DRAW_NONE);



   SetIndexStyle(37,DRAW_NONE);
//---- indicator buffers
   SetIndexBuffer(37,ExtZigzagBuffer1);
   SetIndexLabel(37,"ZZ("+string(InpDepth)+","+string(InpDeviation)+","+string(InpBackstep)+")");
   if(tf!=PERIOD_CURRENT && tf!=_Period)
      SetIndexLabel(37,"ZZ("+string(InpDepth)+","+string(InpDeviation)+","+string(InpBackstep)+")"+StringSubstr(EnumToString(tf),7,0));

   SetIndexEmptyValue(37,0.0);

   SetIndexBuffer(39,ExtHighBuffer1,INDICATOR_CALCULATIONS);
   SetIndexLabel(39,"ZZ High");
   SetIndexBuffer(40,ExtLowBuffer1,INDICATOR_CALCULATIONS);
   SetIndexLabel(40,"ZZ Low");
   SetIndexStyle(39,DRAW_NONE);
   SetIndexStyle(40,DRAW_NONE);


   SetIndexBuffer(38,TimeOccurBuffer1);
   SetIndexLabel(38,"TimeOccur");
   SetIndexStyle(38,DRAW_NONE);
   SetIndexEmptyValue(38,EMPTY_VALUE);

   SetIndexBuffer(33,b_hh1);
   SetIndexLabel(33,"HH");
   SetIndexEmptyValue(33,EMPTY_VALUE);

   SetIndexBuffer(34,b_lh1);
   SetIndexLabel(34,"LH");
   SetIndexEmptyValue(34,EMPTY_VALUE);

   SetIndexBuffer(35,b_ll1);
   SetIndexLabel(35,"LL");
   SetIndexEmptyValue(35,EMPTY_VALUE);

   SetIndexBuffer(36,b_hl1);
   SetIndexLabel(36,"HL");
   SetIndexEmptyValue(36,EMPTY_VALUE);

   SetIndexBuffer(41,BuyValid);
   SetIndexLabel(41,"Buy Valid");
   SetIndexEmptyValue(41,EMPTY_VALUE);
   SetIndexStyle(41,DRAW_NONE);

   SetIndexBuffer(42,SellValid);
   SetIndexLabel(42,"Sell Valid");
   SetIndexEmptyValue(42,EMPTY_VALUE);
   SetIndexStyle(42,DRAW_NONE);

   SetIndexBuffer(43,RangeValid);
   SetIndexLabel(43,"Range Valid");
   SetIndexEmptyValue(43,EMPTY_VALUE);
   SetIndexStyle(43,DRAW_NONE);


   SetIndexBuffer(44,BuyStruct);
   SetIndexLabel(44,"Buy Struct");
   SetIndexEmptyValue(44,EMPTY_VALUE);
   SetIndexStyle(44,DRAW_NONE);

   SetIndexBuffer(45,SellStruct);
   SetIndexLabel(45,"Sell Struct");
   SetIndexEmptyValue(45,EMPTY_VALUE);
   SetIndexStyle(45,DRAW_NONE);



   SetIndexBuffer(46,SubBuyBreakU);
   SetIndexEmptyValue(46,EMPTY_VALUE);
   SetIndexStyle(46,DRAW_NONE);

   SetIndexBuffer(47,SubSellBreakU);
   SetIndexEmptyValue(47,EMPTY_VALUE);
   SetIndexStyle(47,DRAW_NONE);

   SetIndexBuffer(48,MainBuyBreakU);
   SetIndexEmptyValue(48,EMPTY_VALUE);
   SetIndexStyle(48,DRAW_NONE);

   SetIndexBuffer(49,MainSellBreakU);
   SetIndexEmptyValue(49,EMPTY_VALUE);
   SetIndexStyle(49,DRAW_NONE);

   SetIndexBuffer(50,SingleValidity);
   SetIndexLabel(50,"Single Validity");
   SetIndexEmptyValue(50,EMPTY_VALUE);
   SetIndexStyle(50,DRAW_NONE);

   SetIndexBuffer(51,DoubleValidity);
   SetIndexLabel(51,"Double Validity");
   SetIndexEmptyValue(51,EMPTY_VALUE);
   SetIndexStyle(51,DRAW_NONE);


   SetIndexBuffer(52,SubRangeFormedValidity);
   SetIndexLabel(52,"Sub Range Formed Validity");
   SetIndexEmptyValue(52,0);
   SetIndexStyle(52,DRAW_NONE);

   SetIndexBuffer(53,MainRangeFormedValidity);
   SetIndexLabel(53,"Main Range Formed Validity");
   SetIndexEmptyValue(53,0);
   SetIndexStyle(53,DRAW_NONE);


   SetIndexBuffer(54,TotalRangeFormedValidity);
   SetIndexLabel(54,"Total Range Formed Validity");
   SetIndexEmptyValue(54,0);
   SetIndexStyle(54,DRAW_NONE);

   SetIndexBuffer(55,TotalBreakValidity);
   SetIndexLabel(55,"Total Break Validity");
   SetIndexEmptyValue(55,0);
   SetIndexStyle(55,DRAW_NONE);


   SetIndexBuffer(56,BuySum);
   SetIndexLabel(56,"Buy Sum");
   SetIndexEmptyValue(56,0);
   SetIndexStyle(56,DRAW_NONE);

   SetIndexBuffer(57,BuyWeightage);
   SetIndexLabel(57,"Buy Weightage");
   SetIndexEmptyValue(57,0);
   SetIndexStyle(57,DRAW_NONE);


   SetIndexBuffer(58,SellSum);
   SetIndexLabel(58,"Sell Sum");
   SetIndexEmptyValue(58,0);
   SetIndexStyle(58,DRAW_NONE);

   SetIndexBuffer(59,SellWeightage);
   SetIndexLabel(59,"Sell Weightage");
   SetIndexEmptyValue(59,0);
   SetIndexStyle(59,DRAW_NONE);


   SetIndexBuffer(60,Swing);
   SetIndexLabel(60,"Swing");
   SetIndexEmptyValue(60,0);
   SetIndexStyle(60,DRAW_NONE);


   SetIndexBuffer(61,ZigZagBuf);
   SetIndexLabel(61,"Recent ZigZag");
   SetIndexEmptyValue(61,0);
   SetIndexStyle(61,DRAW_NONE);

   SetIndexBuffer(62,ImbalanceBuf);
   SetIndexLabel(62,"Imbalance");
   SetIndexEmptyValue(62,0);
   SetIndexStyle(62,DRAW_NONE);

   SetIndexBuffer(63,ZigZagValidBuf);
   SetIndexLabel(63,"ZigZag Valid");
   SetIndexEmptyValue(63,0);
   SetIndexStyle(63,DRAW_NONE);

//---- indicator short name
   IndicatorShortName("ZigZag("+string(InpDepth)+","+string(InpDeviation)+","+string(InpBackstep)+")");
//---- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int c=0;
int dbl=1;
int sngl=1;
int SubRange1=1;
int MainRange1=1;
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {

   int    i,limit,counterZ,whatlookfor=0;
   int    back,pos,lasthighpos=0,lastlowpos=0;
   double extremum;
   double curlow=0.0,curhigh=0.0,lasthigh=0.0,lastlow=0.0;

   if(tf==0 || tf==_Period)
     {
      //--- first calculations
      if(prev_calculated==0)
        {

         int minutes= HistoryDays*1440;
         limit= minutes/Period();

         if(limit>=Bars)
           {
            limit=Bars-InpDepth;
           }
        }
      else
        {

         //--- find first extremum in the depth ExtLevel or 100 last bars
         i=counterZ=0;
         while(counterZ<ExtLevel1 && i<100)
           {
            if(ExtZigzagBuffer[i]!=0.0)
               counterZ++;
            i++;
           }
         //--- no extremum found - recounting all from begin
         if(counterZ==0)
            limit=InitializeAll();
         else
           {
            //--- set start position to found extremum position
            limit=i-1;
            //--- what kind of extremum?
            if(ExtLowBuffer[i]!=0.0)
              {
               //--- low extremum
               curlow=ExtLowBuffer[i];
               //--- will look for the next high extremum
               whatlookfor=1;
              }
            else
              {
               //--- high extremum
               curhigh=ExtHighBuffer[i];
               //--- will look for the next low extremum
               whatlookfor=-1;
              }
            //--- clear the rest data
            for(i=limit-1; i>=0; i--)
              {
               ExtZigzagBuffer[i]=0.0;
               ExtLowBuffer[i]=0.0;
               ExtHighBuffer[i]=0.0;
              }
           }

        }

      //--- main loop
      for(i=limit; i>=1; i--)
        {
         //--- find lowest low in depth of bars
         if(zz_hl)
            extremum=low[iLowest(NULL,0,MODE_LOW,InpDepth,i)];
         if(!zz_hl)
            extremum=close[iLowest(NULL,0,MODE_CLOSE,InpDepth,i)];
         //--- this lowest has been found previously
         if(extremum==lastlow)
            extremum=0.0;
         else
           {
            //--- new last low
            lastlow=extremum;
            //--- discard extremum if current low is too high
            if((zz_hl && low[i]-extremum>InpDeviation*Point) || (!zz_hl && close[i]-extremum>InpDeviation*Point))
               extremum=0.0;
            else
              {
               //--- clear previous extremums in backstep bars
               for(back=1; back<=InpBackstep; back++)
                 {
                  pos=i+back;
                  if(ExtLowBuffer[pos]!=0 && ExtLowBuffer[pos]>extremum)
                     ExtLowBuffer[pos]=0.0;
                 }
              }
           }
         //--- found extremum is current low
         if((zz_hl && low[i]==extremum) || (!zz_hl && close[i]==extremum))
            ExtLowBuffer[i]=extremum;
         else
            ExtLowBuffer[i]=0.0;

         //--- find highest high in depth of bars
         if(zz_hl)
            extremum=high[iHighest(NULL,0,MODE_HIGH,InpDepth,i)];
         if(!zz_hl)
            extremum=close[iHighest(NULL,0,MODE_CLOSE,InpDepth,i)];
         //--- this highest has been found previously
         if(extremum==lasthigh)
            extremum=0.0;
         else
           {
            //--- new last high
            lasthigh=extremum;
            //--- discard extremum if current high is too low
            if((zz_hl && extremum-high[i]>InpDeviation*Point) || (!zz_hl && extremum-close[i]>InpDeviation*Point))
               extremum=0.0;
            else
              {
               //--- clear previous extremums in backstep bars
               for(back=1; back<=InpBackstep; back++)
                 {
                  pos=i+back;
                  if(ExtHighBuffer[pos]!=0 && ExtHighBuffer[pos]<extremum)
                     ExtHighBuffer[pos]=0.0;
                 }
              }
           }
         //--- found extremum is current high
         if((zz_hl && high[i]==extremum) || (!zz_hl && close[i]==extremum))
            ExtHighBuffer[i]=extremum;
         else
            ExtHighBuffer[i]=0.0;
        }
      //--- final cutting
      if(whatlookfor==0)
        {
         lastlow=0.0;
         lasthigh=0.0;
        }
      else
        {
         lastlow=curlow;
         lasthigh=curhigh;
        }
      for(i=limit; i>=0; i--)
        {
         switch(whatlookfor)
           {
            case 0: // look for peak or lawn
               if(lastlow==0.0 && lasthigh==0.0)
                 {
                  if(ExtHighBuffer[i]!=0.0)
                    {
                     lasthigh=High[i];
                     if(!zz_hl)
                        lasthigh=Close[i];
                     lasthighpos=i;
                     whatlookfor=-1;
                     ExtZigzagBuffer[i]=lasthigh;
                    }
                  if(ExtLowBuffer[i]!=0.0)
                    {
                     lastlow=Low[i];
                     if(!zz_hl)
                        lastlow=Close[i];
                     lastlowpos=i;
                     whatlookfor=1;
                     ExtZigzagBuffer[i]=lastlow;
                    }
                 }
               break;
            case 1: // look for peak
               if(ExtLowBuffer[i]!=0.0 && ExtLowBuffer[i]<lastlow && ExtHighBuffer[i]==0.0)
                 {
                  ExtZigzagBuffer[lastlowpos]=0.0;
                  lastlowpos=i;
                  lastlow=ExtLowBuffer[i];
                  ExtZigzagBuffer[i]=lastlow;
                 }
               if(ExtHighBuffer[i]!=0.0 && ExtLowBuffer[i]==0.0)
                 {
                  lasthigh=ExtHighBuffer[i];
                  lasthighpos=i;
                  ExtZigzagBuffer[i]=lasthigh;
                  whatlookfor=-1;
                 }
               break;
            case -1: // look for lawn
               if(ExtHighBuffer[i]!=0.0 && ExtHighBuffer[i]>lasthigh && ExtLowBuffer[i]==0.0)
                 {
                  ExtZigzagBuffer[lasthighpos]=0.0;
                  lasthighpos=i;
                  lasthigh=ExtHighBuffer[i];
                  ExtZigzagBuffer[i]=lasthigh;
                 }
               if(ExtLowBuffer[i]!=0.0 && ExtHighBuffer[i]==0.0)
                 {
                  lastlow=ExtLowBuffer[i];
                  lastlowpos=i;
                  ExtZigzagBuffer[i]=lastlow;
                  whatlookfor=1;
                 }
               break;
           }
        }
      //--- done

     }//tf
   else
     {
      int limit_tf = MathMax(Bars-1-prev_calculated,MathMin(Bars-1,InpBackstep*5*MathMax(1,tf/_Period)));

      for(int z=limit_tf; z>=0; z--)
        {

         static int itf_prev;
         int itf = iBarShift(_Symbol,tf,Time[z],false);
         if(itf<0)
            continue;

         if(itf_prev!=itf)
           {
            itf_prev=itf;
            ExtZigzagBuffer[z] = get_mtf(tf,4,itf);
           }
         else
           {
            ExtZigzagBuffer[z] = 0;
           }
        }

     }


   int swing_limit=0;
   if(IndicatorCounted()==0)
     {
      swing_limit=Bars;
     }
   else
     {
      swing_limit = 3;
     }
   int swing_counter=0;
   int end_i = 0;

   for(i=0; i<Bars-1; i++)
     {
      if(ExtZigzagBuffer[i]!=0 && swing_counter==0)
        {
         swing_counter++;
        }
      else
         if(ExtZigzagBuffer[i]!=0 && swing_counter==1)
           {
            end_i=i;
            break;
           }
     }

   int limit2 = MathMax(Bars-1-prev_calculated,end_i);
   for(i=limit2; i>=end_i; i--)
     {
      static double prev_h, prev_h_High, prev_h_Low, prev_h_rsi;
      static double prev_l, prev_l_High, prev_l_Low, prev_l_rsi;
      static double zzlast;
      static bool prev_l_LL = false, prev_h_HH = false;

      if(i==Bars-1)
        {
         prev_h = Open[i];
         prev_h_High = Open[i];
         prev_h_Low = Open[i];
         prev_h_rsi=0;
         prev_l = Open[i];
         prev_l_High = Open[i];
         prev_l_Low = Open[i];
         prev_l_rsi=0;
         zzlast = Open[i];
         prev_l_LL = false;
         prev_h_HH = false;
        }

      double zz = ExtZigzagBuffer[i];
      static double zz_prev;
      if(zz!=0)
        {
         zz_prev = zz;
         string use_text = "na";
         color use_clr = clrGray;
         double use_price = 0;

         double check_high = iHigh(_Symbol,tf,iBarShift(_Symbol,tf,Time[i]));
         double check_low = iLow(_Symbol,tf,iBarShift(_Symbol,tf,Time[i]));
         double check_close = iClose(_Symbol,tf,iBarShift(_Symbol,tf,Time[i]));

         double rsi = RSI_BufferValue(iBarShift(_Symbol,tf,Time[i]));

         if((zz_hl && zz==check_high) || (!zz_hl && zz==check_close && check_close>zzlast))
           {
            zzlast = check_close;
            use_clr = clrDodgerBlue;
            if(zz>prev_h
               && (ZigZagBasedOnEntries_Percent < 0 || prev_h_HH || zz > prev_h_High+ZigZagBasedOnEntries_Percent*0.01*(prev_h_High-prev_h_Low))
               && (!ZigZagBasedOnDivergence || !(prev_h_rsi > PrevZZ_RSILevel_Buy && rsi < prev_h_rsi))
              )
              {
               // Print(Time[i]+" "+ check_close +" "+ "HH");
               prev_h=zz;
               prev_h_High=check_high;
               prev_h_Low=check_low;
               prev_h_rsi = rsi;
               prev_h_HH = true;

               b_hh[i] = zz_hl ? check_high:check_close;
               use_text = "HH";
               if(text_show_time && prev_calculated>0)
                 {
                  TimeOccurBuffer[i] = StringToTime(TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
                  use_text +=" "+TimeToString(TimeCurrent(),TIME_MINUTES);
                 }
               TextCreate(0,"zz"+"HH"+TimeToString(Time[i]),0,Time[i],check_high,use_text,"Arial Bold",text_fs,text_clr_hh,0,ANCHOR_LOWER);
              }
            else
              {
               //Print(Time[i]+" "+ check_close +" "+ "LH");
               prev_h=zz;
               prev_h_High=check_high;
               prev_h_Low=check_low;
               prev_h_rsi = rsi;
               prev_h_HH = false;

               b_lh[i] = zz_hl ? check_high:check_close;
               use_text = "LH";
               if(text_show_time && prev_calculated>0)
                 {
                  TimeOccurBuffer[i] = StringToTime(TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
                  use_text+=" "+TimeToString(TimeCurrent(),TIME_MINUTES);
                 }
               TextCreate(0,"zz"+"LH"+TimeToString(Time[i]),0,Time[i],check_high,use_text,"Arial Bold",text_fs,text_clr_lh,0,ANCHOR_LOWER);
              }

            int c1=0;
            int c2=0;
            for(int k=i; k<Bars-1; k++)
              {
               if(ExtZigzagBuffer[k]!=0 && c1==0)
                 {
                  c1++;
                 }
               else
                  if(ExtZigzagBuffer[k]!=0 && c1==1)
                    {
                     c2=k;
                     break;
                    }
              }
            if(c1!=0 && c2!=0)
              {
               long t1 = iTime(_Symbol,tf,iBarShift(_Symbol,tf,Time[c2]));
               long t2 = iTime(_Symbol,tf,iBarShift(_Symbol,tf,Time[i]));
               double p1 = zz_hl ? iLow(_Symbol,tf,iBarShift(_Symbol,tf,Time[c2])):iClose(_Symbol,tf,iBarShift(_Symbol,tf,Time[c2]));
               double p2 = zz_hl ? check_high:check_close;
               TrendCreate(0,"zz tline h"+TimeToString(Time[i]),0,t1,p1,t2,p2,line_clr_up,STYLE_SOLID,line_w);
              }

           }//high found

         if((zz_hl && zz==check_low) || (!zz_hl && zz==check_close && check_close<zzlast))
           {
            zzlast = check_close;
            use_clr = clrRed;
            if(zz<prev_l
               && (ZigZagBasedOnEntries_Percent < 0 || prev_l_LL || zz < prev_l_Low-ZigZagBasedOnEntries_Percent*0.01*(prev_l_High-prev_l_Low))
               && (!ZigZagBasedOnDivergence || !(prev_l_rsi < PrevZZ_RSILevel_Sell && rsi > prev_l_rsi))
              )
              {
               prev_l=zz;
               prev_l_High=check_high;
               prev_l_Low=check_low;
               prev_l_rsi = rsi;
               prev_l_LL = true;

               b_ll[i] = zz_hl ? check_low:check_close;
               use_text = "LL";
               if(text_show_time && prev_calculated>0)
                 {
                  TimeOccurBuffer[i] = StringToTime(TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
                  use_text+=" "+TimeToString(TimeCurrent(),TIME_MINUTES);
                 }
               TextCreate(0,"zz"+"LL"+TimeToString(Time[i]),0,Time[i],check_low,use_text,"Arial Bold",text_fs,text_clr_ll,0,ANCHOR_UPPER);
              }
            else
              {
               prev_l=zz;
               prev_l_High=check_high;
               prev_l_Low=check_low;
               prev_l_rsi = rsi;
               prev_l_LL = false;

               b_hl[i] = zz_hl ? check_low:check_close;
               use_text = "HL";
               if(text_show_time && prev_calculated>0)
                 {
                  TimeOccurBuffer[i] = StringToTime(TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
                  use_text+=" "+TimeToString(TimeCurrent(),TIME_MINUTES);
                 }
               TextCreate(0,"zz"+"HL"+TimeToString(Time[i]),0,Time[i],check_low,use_text,"Arial Bold",text_fs,text_clr_hl,0,ANCHOR_UPPER);
              }

            int c1=0;
            int c2=0;
            for(int k=i; k<Bars-1; k++)
              {
               if(ExtZigzagBuffer[k]!=0 && c1==0)
                 {
                  c1++;
                 }
               else
                  if(ExtZigzagBuffer[k]!=0 && c1==1)
                    {
                     c2=k;
                     break;
                    }
              }
            if(c1!=0 && c2!=0)
              {
               long t1 = iTime(_Symbol,tf,iBarShift(_Symbol,tf,Time[c2]));
               long t2 = iTime(_Symbol,tf,iBarShift(_Symbol,tf,Time[i]));
               double p1 = zz_hl ? iHigh(_Symbol,tf,iBarShift(_Symbol,tf,Time[c2])):iClose(_Symbol,tf,iBarShift(_Symbol,tf,Time[c2]));
               double p2 = zz_hl ? check_low:check_close;
               TrendCreate(0,"zz tline l"+TimeToString(Time[i]),0,t1,p1,t2,p2,line_clr_dn,STYLE_SOLID,line_w);
              }
           }//low found

        }//zz found

     }//zz loop

//alert
   if(alert_on && prev_calculated>0 && new_bar())
     {
      for(int a=1; a<Bars-1; a++)
        {
         if(alert_hh && ObjectFind(0,"zz"+"HH"+TimeToString(Time[a]))==0)
           {
            alert_function(Time[a],"new HIGHER HIGH made");
            break;
           }
         if(alert_lh && ObjectFind(0,"zz"+"LH"+TimeToString(Time[a]))==0)
           {
            alert_function(Time[a],"new LOWER HIGH made");
            break;
           }
         if(alert_ll && ObjectFind(0,"zz"+"LL"+TimeToString(Time[a]))==0)
           {
            alert_function(Time[a],"new LOWER LOW made");
            break;
           }
         if(alert_hl && ObjectFind(0,"zz"+"HL"+TimeToString(Time[a]))==0)
           {
            alert_function(Time[a],"new HIGHER LOW made");
            break;
           }
        }
     }


   USwing(prev_calculated,time,open,high,low,close,tick_volume,volume,spread);


   int minutes= HistoryDays*1440;
   int limit3= minutes/Period();

   if(limit3>=Bars)
     {
      limit3=Bars-5;
     }

   for(i=limit3; i>=0; i--)
     {
      ADR[i] = GetADR(i);
     }


   if(Show_Range_Calculations_U)
     {

      RangeTime=Time[Bars-1];
      RangeTime1=Time[Bars-1];
      if(Enable_Main_Swings_U)
        {
         for(int j=limit3; j>=0; j--)
           {
            MainValidEntryU[j] = 1;
           }
        }

      if(Enable_Sub_Swings_U)
        {

         for(int j=limit3; j>=0; j--)
           {
            SubValidEntryU[j] = 1;
           }
        }




      bool LastOneWasHH = false;
      double LastHHPrice = 0;
      int    LastHHBar   = 0;

      bool LastOneWasLL = false;
      double LastLLPrice = 0;
      int    LastLLBar   = 0;

      bool LastOneWasLH = false;
      double LastLHPrice = 0;
      int    LastLHBar   = 0;

      bool LastOneWasHL = false;
      double LastHLPrice = 0;
      int    LastHLBar   = 0;


      for(int i=limit3; i>=0; i--)
        {
         double ADRPercent_Value = double(GetADR(i)*ADR_Filter_Sub_Range_U)/double(100);

         if(Enable_Sub_Swings_U)
           {
            //++++++++DRAW SELL SIGNAL+++++++++++
            if(b_hh1[i]!=EMPTY_VALUE)
              {
               LastOneWasHH = true;
               LastHHPrice = b_hh1[i];
               LastHHBar = i;
              }
            if(b_lh1[i]!=EMPTY_VALUE)
              {
               if(DiffPrice(Close[i],LastHHPrice)<ADRPercent_Value && LastOneWasHH==true)
                 {
                  // Print(DiffPrice(High[i],LastHHPrice)+" * "+ADRPercent_Value+" | "+Time[i] +" a" );
                  DrawRangeSubU(i,LastHHBar,OP_SELL,ADR_Filter_Sub_Range_Swing);
                 }
               LastOneWasHH = false;
               LastHHPrice = 0;
              }

            //++++++++++++++++++++++++++++++
            //++++++++DRAW BUY SIGNAL+++++++++++


            if(b_ll1[i]!=EMPTY_VALUE)
              {
               LastOneWasLL = true;
               LastLLPrice = b_ll1[i];
               LastLLBar = i;
              }
            if(b_hl1[i]!=EMPTY_VALUE)
              {
               if(DiffPrice(Close[i],LastLLPrice)<ADRPercent_Value && LastOneWasLL==true)
                 {
                  //Print(DiffPrice(High[i],LastHHPrice)+" * "+ADRPercent_Value+" | "+Time[i] +" b");
                  DrawRangeSubU(i,LastLLBar,OP_BUY,ADR_Filter_Sub_Range_Swing);
                 }
               LastOneWasLL = false;
               LastLLPrice = 0;
              }
           }

         if(Enable_Main_Swings_U)
           {
            //++++++++DRAW SELL SIGNAL+++++++++++
            if(b_lh1[i]!=EMPTY_VALUE)
              {
               LastOneWasLH = true;
               LastLHPrice = b_lh1[i];
               LastLHBar = i;
              }
            if(b_hh1[i]!=EMPTY_VALUE)
              {
               if(DiffPrice(Close[i],LastLHPrice)<ADRPercent_Value && LastOneWasLH==true)
                 {
                  //Print(DiffPrice(High[i],LastHHPrice)+" * "+ADRPercent_Value+" | "+Time[i]);
                  DrawRangeMainU(i,LastLHBar,OP_SELL,ADR_Filter_Main_Range_Swing_U);
                 }
               LastOneWasLH = false;
               LastLHPrice = 0;
              }

            //++++++++DRAW BUY SIGNAL+++++++++++

            if(b_hl1[i]!=EMPTY_VALUE)
              {
               LastOneWasHL = true;
               LastHLPrice = b_hl1[i];
               LastHLBar = i;
              }
            if(b_ll1[i]!=EMPTY_VALUE)
              {
               if(DiffPrice(Close[i],LastHLPrice)<ADRPercent_Value && LastOneWasHL==true)
                 {
                  //Print(DiffPrice(High[i],LastHHPrice)+" * "+ADRPercent_Value+" | "+Time[i]);
                  DrawRangeMainU(i,LastHLBar,OP_BUY,ADR_Filter_Main_Range_Swing_U);
                 }
               LastOneWasHL = false;
               LastHLPrice = 0;
              }
           }

        }

      if(Enable_Sub_Swings_U)
        {
         //  FillValidEntrySubU(limit3);
        }
      if(Enable_Main_Swings_U)
        {
         //FillValidEntryMainU(limit3);
        }
     }


   if(Enable_ADR_Swing)
     {
      //++++++++++++++++++++
      bool LastOneWasHH = false;
      double LastHHPrice = 0;

      int type=-1;
      double price=0.0;
      int type1=-1;
      double price1=0.0;


      for(i=limit3; i>=0; i--)
        {
         double ADRPercent_Value = double(GetADR(i))*(Main_Swing_ADR_Percent/double(100));
         double ADRPercent_Value1 = double(GetADR(i)*Sub_Swing_ADR_Percent)/double(100);
         b_mainswing[i] = ADRPercent_Value;
         b_subswing[i] = ADRPercent_Value1;


         //sub
         if(b_lh[i]!=EMPTY_VALUE)
           {
            bool changed=false;
            if(type!=-1 && type==2)
              {
               if(DiffPrice(Close[i],price)<ADRPercent_Value1)
                 {
                  b_hh[i]=b_lh[i];
                  ObjectSetString(ChartID(),"zzLH"+TimeToString(Time[i]),OBJPROP_TEXT,"HH");
                  b_subswing_diff[i]=DiffPrice(Close[i],price);
                  changed=true;
                  type=2;
                  price=b_lh[i];
                  b_lh[i]=EMPTY_VALUE;
                 }
              }

            if(changed==false)
              {
               b_subswing_diff[i]=DiffPrice(Close[i],price);
               type=1;
               price=b_lh[i];
              }
           }

         //main
         if(b_hh[i]!=EMPTY_VALUE)
           {

            bool changed=false;
            if(type!=-1 && type==1)
              {
               if(DiffPrice(Close[i],price)<ADRPercent_Value)
                 {
                  b_lh[i]=b_hh[i];
                  ObjectSetString(ChartID(),"zzHH"+TimeToString(Time[i]),OBJPROP_TEXT,"LH");
                  b_mainswing_diff[i]=DiffPrice(Close[i],price);
                  changed=true;
                  type=1;
                  price=b_hh[i];
                  b_hh[i]=EMPTY_VALUE;
                 }
              }

            if(changed==false)
              {
               b_mainswing_diff[i]=DiffPrice(Close[i],price);
               type=2;
               price=b_hh[i];
              }
           }

         //sub
         if(b_hl[i]!=EMPTY_VALUE)
           {
            bool changed=false;
            if(type1!=-1 && type1==4)
              {
               if(DiffPrice(Close[i],price1)<ADRPercent_Value1)
                 {
                  b_ll[i]=b_hl[i];
                  ObjectSetString(ChartID(),"zzHL"+TimeToString(Time[i]),OBJPROP_TEXT,"LL");
                  b_subswing_diff[i]=DiffPrice(Close[i],price1);
                  changed=true;
                  type1=4;
                  price1=b_hl[i];
                  b_hl[i]=EMPTY_VALUE;
                 }
              }
            if(changed==false)
              {
               b_subswing_diff[i]=DiffPrice(Close[i],price1);
               type1=3;
               price1=b_hl[i];
              }
           }

         //main
         if(b_ll[i]!=EMPTY_VALUE)
           {

            bool changed=false;
            if(type1!=-1 && type1==3)
              {
               if(DiffPrice(Close[i],price1)<ADRPercent_Value)
                 {
                  b_hl[i]=b_ll[i];
                  ObjectSetString(ChartID(),"zzLL"+TimeToString(Time[i]),OBJPROP_TEXT,"HL");
                  b_mainswing_diff[i]=DiffPrice(Close[i],price1);
                  changed=true;
                  type1=3;
                  price1=b_ll[i];
                  b_ll[i]=EMPTY_VALUE;
                 }
              }

            if(changed==false)
              {
               b_mainswing_diff[i]=DiffPrice(Close[i],price1);
               type1=4;
               price1=b_ll[i];
              }
           }
        }
     }



   if(Enable_Arrows)
     {
      //++++++++++++++++++Draw Arrows Type 1+++++++++++++++++++++
      bool LastOneWasLH = false;
      bool OpenBuyArrow = false;
      double LastLHPrice = 0;
      datetime LastLHTime = 0;


      bool LastOneWasHL = false;
      bool OpenSellArrow = false;
      double LastHLPrice = 0;
      datetime LastHLTime = 0;
      datetime LastLLTime = 0;

      datetime LastHHTime = 0;

      for(i=limit3; i>=0; i--)
        {
         if(b_hl[i]!=EMPTY_VALUE)
           {
            LastHLTime=Time[i];
           }
         if(b_ll[i]!=EMPTY_VALUE)
           {
            LastLLTime=Time[i];
           }

         if(b_lh[i]!=EMPTY_VALUE)
           {
            LastOneWasLH = true;
            LastLHPrice  = b_lh[i];
            LastLHTime=Time[i];
            if(OpenBuyArrow==true)
              {
               EndBuyArrow[i] = High[i];
               OpenBuyArrow   = false;
              }
           }

         if(b_hh[i]!=EMPTY_VALUE)
           {
            int b=i+1;
            while(b<Bars-2)
              {
               if(b_hh[b]!=EMPTY_VALUE)
                 {
                  LastHHTime=Time[b];
                  break;
                 }
               b++;
              }

            if(LastOneWasLH==true)
              {
               LastOneWasLH = false;
               if(IsRSIValid(i,1,OP_BUY))
                 {
                  BuyArrow[i] = High[i];
                  OpenBuyArrow = true;
                 }
               continue;
              }
            else
              {
               if((LastHHTime<LastHLTime && Time[i]>LastHLTime) || (LastHHTime<LastLLTime && Time[i]>LastLLTime))
                 {
                 }
               else
                 {
                  continue;
                 }
              }

            if(OpenBuyArrow==true)
              {
               EndBuyArrow[i] = High[i];

               OpenBuyArrow = false;

              }
           }

         if(OpenBuyArrow==true)
           {
            EndBuyArrow[i] = High[i];
           }

        }


      //++++++++++++++++++Draw Arrows Type 2+++++++++++++++++++++
      bool LLHolder  = false;
      bool HLHolder1 = false;
      bool HLHolder2 = false;
      OpenBuyArrow = false;

      for(i=limit3; i>=0; i--)
        {
         if(b_hh[i]!=EMPTY_VALUE && OpenBuyArrow==true)
           {
            OpenBuyArrow = false;
            EndBuyArrow2[i] = High[i];
           }
         if(OpenBuyArrow==true)
           {
            EndBuyArrow2[i] = High[i];
            if(b_lh[i]!=EMPTY_VALUE)
               OpenBuyArrow = false;
           }
         if(b_ll[i]!=EMPTY_VALUE)
           {
            LLHolder  = true;
            HLHolder1 = false;
            HLHolder2 = false;
           }
         //+++++++
         if(b_hl[i]!=EMPTY_VALUE)
           {
            if(LLHolder==true && HLHolder1==false && HLHolder2==false)
              {
               HLHolder1 = true;
               continue;
              }
            if(LLHolder==true && HLHolder1==true && HLHolder2==false)
              {
               if(IsRSIValid(i,2,OP_BUY))
                 {
                  BuyArrow2[i] = Low[i];
                  OpenBuyArrow = true;
                 }
               LLHolder  = false;
               HLHolder1 = false;
               HLHolder2 = false;
               continue;
              }
           }
         //+++++++
        }



      //++++++++++++++++++Draw Arrows Type 2+++++++++++++++++++++
      //+++SELL DRAWING++++
      //++++++++++++++++++Draw Arrows Type 1+++++++++++++++++++++


      datetime LastHHTime1=0;
      datetime LastHLTime2=0;
      datetime LastLHTime1=0;
      datetime LastLLTime2=0;

      for(i=limit3; i>=0; i--)
        {

         if(b_hh[i]!=EMPTY_VALUE)
           {
            LastHHTime1=Time[i];
           }
         if(b_lh[i]!=EMPTY_VALUE)
           {
            LastLHTime1=Time[i];
           }

         if(b_hl[i]!=EMPTY_VALUE)
           {
            LastOneWasHL = true;
            LastHLPrice  = b_hl[i];
            if(OpenSellArrow==true)
              {
               EndSellArrow[i] = Low[i];
               OpenSellArrow   = false;
              }
           }
         if(b_ll[i]!=EMPTY_VALUE)
           {

            int b=i+1;
            while(b<Bars-2)
              {
               if(b_ll[b]!=EMPTY_VALUE)
                 {
                  LastLLTime2=Time[b];
                  break;
                 }
               b++;
              }

            if(LastOneWasHL==true)
              {
               if(IsRSIValid(i,1,OP_SELL))
                 {
                  SellArrow[i] = Low[i];
                  OpenSellArrow = true;
                 }
               LastOneWasHL = false;
               continue;
              }
            else
              {
               if((LastLLTime2<LastLHTime1 && Time[i]>LastLHTime1) || (LastLLTime2<LastHHTime1 && Time[i]>LastHHTime1))
                 {
                 }
               else
                 {
                  continue;
                 }
              }


            if(OpenSellArrow==true)
              {
               EndSellArrow[i] = Low[i];
               OpenSellArrow   = false;
              }
           }
         if(OpenSellArrow==true)
           {
            EndSellArrow[i] = Low[i];
           }
        }
      //++++++++++++++++++Draw Arrows Type 2+++++++++++++++++++++
      bool HHHolder  = false;
      bool LHHolder1 = false;
      bool LHHolder2 = false;
      OpenSellArrow = false;
      for(i=limit3; i>=0; i--)
        {
         if(b_ll[i]!=EMPTY_VALUE && OpenSellArrow==true)
           {
            OpenSellArrow = false;
            EndSellArrow2[i] = Low[i];
           }
         if(OpenSellArrow==true)
           {
            EndSellArrow2[i] = Low[i];
            if(b_hl[i]!=EMPTY_VALUE)
               OpenSellArrow = false;
           }
         if(b_hh[i]!=EMPTY_VALUE)
           {
            HHHolder  = true;
            LHHolder1 = false;
            LHHolder2 = false;
           }
         //+++++++
         if(b_lh[i]!=EMPTY_VALUE)
           {
            if(HHHolder==true && LHHolder1==false && LHHolder2==false)
              {
               LHHolder1 = true;
               continue;
              }
            if(HHHolder==true && LHHolder1==true && LHHolder2==false)
              {
               if(IsRSIValid(i,2,OP_SELL))
                 {
                  SellArrow2[i] = High[i];
                  OpenSellArrow = true;
                 }
               HHHolder  = false;
               LHHolder1 = false;
               LHHolder2 = false;
               continue;
              }
           }
         //+++++++
        }

      //++++++++++++++++++Draw Arrows Type 2+++++++++++++++++++++
     }


   if(Show_Range_Calculations)
     {

      bool LastOneWasHH = false;
      double LastHHPrice = 0;
      int    LastHHBar   = 0;

      bool LastOneWasLL = false;
      double LastLLPrice = 0;
      int    LastLLBar   = 0;

      bool LastOneWasLH = false;
      double LastLHPrice = 0;
      int    LastLHBar   = 0;

      bool LastOneWasHL = false;
      double LastHLPrice = 0;
      int    LastHLBar   = 0;


      for(int i=limit3; i>=0; i--)
        {
         double ADRPercent_Value = double(GetADR(i)*ADR_Filter_Sub_Range)/double(100);

         if(Enable_Sub_Swings)
           {
            //++++++++DRAW SELL SIGNAL+++++++++++
            if(b_hh[i]!=EMPTY_VALUE)
              {
               LastOneWasHH = true;
               LastHHPrice = b_hh[i];
               LastHHBar = i;
              }
            if(b_lh[i]!=EMPTY_VALUE)
              {
               if(DiffPrice(Close[i],LastHHPrice)<ADRPercent_Value && LastOneWasHH==true)
                 {
                  //Print(DiffPrice(High[i],LastHHPrice)+" * "+ADRPercent_Value+" | "+Time[i]);
                  DrawRangeSub(i,LastHHBar,OP_SELL,ADR_Filter_Sub_Range_Swing);
                 }
               LastOneWasHH = false;
               LastHHPrice = 0;
              }

            //++++++++++++++++++++++++++++++
            //++++++++DRAW BUY SIGNAL+++++++++++


            if(b_ll[i]!=EMPTY_VALUE)
              {
               LastOneWasLL = true;
               LastLLPrice = b_ll[i];
               LastLLBar = i;
              }
            if(b_hl[i]!=EMPTY_VALUE)
              {
               if(DiffPrice(Close[i],LastLLPrice)<ADRPercent_Value && LastOneWasLL==true)
                 {
                  //Print(DiffPrice(High[i],LastHHPrice)+" * "+ADRPercent_Value+" | "+Time[i]);
                  DrawRangeSub(i,LastLLBar,OP_BUY,ADR_Filter_Sub_Range_Swing);
                 }
               LastOneWasLL = false;
               LastLLPrice = 0;
              }
           }

         if(Enable_Main_Swings)
           {

            //++++++++DRAW SELL SIGNAL+++++++++++
            if(b_lh[i]!=EMPTY_VALUE)
              {
               LastOneWasLH = true;
               LastLHPrice = b_lh[i];
               LastLHBar = i;
              }
            if(b_hh[i]!=EMPTY_VALUE)
              {
               if(DiffPrice(Close[i],LastLHPrice)<ADRPercent_Value && LastOneWasLH==true)
                 {
                  //Print(DiffPrice(High[i],LastHHPrice)+" * "+ADRPercent_Value+" | "+Time[i]);
                  DrawRangeMain(i,LastLHBar,OP_SELL,ADR_Filter_Main_Range_Swing);
                 }
               LastOneWasLH = false;
               LastLHPrice = 0;
              }

            //++++++++DRAW BUY SIGNAL+++++++++++

            if(b_hl[i]!=EMPTY_VALUE)
              {
               LastOneWasHL = true;
               LastHLPrice = b_ll[i];
               LastHLBar = i;
              }
            if(b_ll[i]!=EMPTY_VALUE)
              {
               if(DiffPrice(Close[i],LastHLPrice)<ADRPercent_Value && LastOneWasHL==true)
                 {
                  //Print(DiffPrice(High[i],LastHHPrice)+" * "+ADRPercent_Value+" | "+Time[i]);
                  DrawRangeMain(i,LastHLBar,OP_BUY,ADR_Filter_Main_Range_Swing);
                 }
               LastOneWasHL = false;
               LastHLPrice = 0;
              }
           }

        }

      if(Enable_Sub_Swings)
        {
         //  FillValidEntrySub(limit3);
        }
      if(Enable_Main_Swings)
        {
         // FillValidEntryMain(limit3);
        }
     }


//Print(Time[1]+" "+ MainValidEntryU[1]);

   for(int i=limit3; i>=0; i--)
     {
      BuyValid[i]= (EndBuyArrow[i]==0?0:1) +(EndBuyArrow2[i]==0?0:1);
      SellValid[i]= (EndSellArrow[i]==0?0:1) +(EndSellArrow2[i]==0?0:1);
      RangeValid[i]= ((MainValidEntryU[i]==EMPTY_VALUE || MainValidEntryU[i]==0.0)?0:1) +((SubValidEntryU[i]==EMPTY_VALUE || SubValidEntryU[i]==0.0)?0:1);
     }

     {
      bool LastOneWasHH = false;

      bool LastOneWasLL = false;

      bool LastOneWasLH = false;

      bool LastOneWasHL = false;


      int count=0;
      int loc=0;
      int count1=200;
      bool NewZZ=false;
      for(int i=limit3; i>=0; i--)
        {
         ZigZagValidBuf[i]=0;
         ImbalanceBuf[i]=0;
         ZigZagBuf[i]=0;
         Swing[i]=0;

         if(b_hh[i]!=EMPTY_VALUE)
           {
            if(count!=0)
              {
               count1=MathAbs(count-i);
              }

            count=i;
            Swing[i]=1;
            if(LastOneWasHH==false)
              {
               NewZZ=true;
               loc=i;
              }
            else
              {
               NewZZ=false;
              }

            LastOneWasHH = true;
            LastOneWasLL=false;
            LastOneWasLH=false;
            LastOneWasHL=false;
           }

         if(b_ll[i]!=EMPTY_VALUE)
           {

            if(count!=0)
              {
               count1=MathAbs(count-i);
              }

            count=i;
            Swing[i]=2;
            if(LastOneWasLL==false)
              {
               NewZZ=true;
               loc=i;
              }
            else
              {
               NewZZ=false;
              }

            LastOneWasHH = false;
            LastOneWasLL=true;
            LastOneWasLH=false;
            LastOneWasHL=false;
           }

         if(b_lh[i]!=EMPTY_VALUE)
           {
            if(count!=0)
              {
               count1=MathAbs(count-i);
              }

            count=i;
            Swing[i]=4;
            if(LastOneWasLH==false)
              {
               NewZZ=true;
               loc=i;
              }
            else
              {
               NewZZ=false;
              }
            LastOneWasHH = false;
            LastOneWasLL=false;
            LastOneWasLH=true;
            LastOneWasHL=false;
           }

         if(b_hl[i]!=EMPTY_VALUE)
           {
            if(count!=0)
              {
               count1=MathAbs(count-i);
              }

            count=i;
            Swing[i]=3;

            if(LastOneWasHL==false)
              {
               NewZZ=true;
               loc=i;
              }
            else
              {
               NewZZ=false;
              }
            LastOneWasHH = false;
            LastOneWasLL=false;
            LastOneWasLH=false;
            LastOneWasHL=true;
           }


         if(LastOneWasHH || LastOneWasHL)
           {
            BuyStruct[i]=1;
           }
         else
           {
            BuyStruct[i]=0;
           }

         if(LastOneWasLL || LastOneWasLH)
           {
            SellStruct[i]=1;
           }
         else
           {
            SellStruct[i]=0;
           }


         if(NewZZ)
           {
            if(count1<=Imbalance)
              {
               ImbalanceBuf[i]=1;
              }

            if(MathAbs(loc-i)<=Recent_Zigzag)
              {
               ZigZagBuf[i]=1;
              }
           }
         if(ZigZagBuf[i]==1 && ImbalanceBuf[i]==0)
           {
            ZigZagValidBuf[i]=1;
           }


        }
     }

   for(int i=limit3-1; i>=0; i--)
     {
      if(RangeValid[i]>=1)
        {
         if(EnableDoubleValidity)
           {
            if((MainBuyArrowBreakU[i]!=EMPTY_VALUE && SubBuyArrowBreakU[i]!=EMPTY_VALUE) || ((MainSellArrowBreakU[i]!=EMPTY_VALUE && SubSellArrowBreakU[i]!=EMPTY_VALUE)))
              {
               DoubleValidity[i]=1;
               dbl=1;
              }
           }
         if(EnableSingleValidity)
           {
            if((MainBuyArrowBreakU[i]!=EMPTY_VALUE || SubBuyArrowBreakU[i]!=EMPTY_VALUE) || ((MainSellArrowBreakU[i]!=EMPTY_VALUE || SubSellArrowBreakU[i]!=EMPTY_VALUE)))
              {
               SingleValidity[i]=1;
               sngl=1;
              }
           }
        }


      if(Swing[i]==0)
        {
         Swing[i]=Swing[i+1];
        }

      if(dbl<Double_Validity_Candles)
        {
         if(DoubleValidity[i+1]!=EMPTY_VALUE)
           {
            DoubleValidity[i]=1;
            dbl++;
           }
        }

      if(sngl<Single_Validity_Candles)
        {
         if(SingleValidity[i+1]!=EMPTY_VALUE)
           {
            SingleValidity[i]=1;
            sngl++;
           }
        }

      if(SubValidEntryU[i]==0 && SubValidEntryU[i+1]==1)
        {
         SubRangeFormedValidity[i]=1;
         SubRange1=1;
        }

      if(MainValidEntryU[i]==0 && MainValidEntryU[i+1]==1)
        {
         MainRangeFormedValidity[i]=1;
         MainRange1=1;
        }

      if(SubRange1<Sub_Range_Validity_Candles)
        {
         if(SubRangeFormedValidity[i+1]!=EMPTY_VALUE)
           {
            SubRangeFormedValidity[i]=1;
            SubRange1++;
           }
        }

      if(MainRange1<Main_Range_Validity_Candles)
        {
         if(MainRangeFormedValidity[i+1]!=EMPTY_VALUE)
           {
            MainRangeFormedValidity[i]=1;
            MainRange1++;
           }
        }

      TotalRangeFormedValidity[i]=MainRangeFormedValidity[i]+SubRangeFormedValidity[i];
      TotalBreakValidity[i]=((SingleValidity[i] ==EMPTY_VALUE || SingleValidity[i]==0)  ? 0 : 1) +((DoubleValidity[i] ==EMPTY_VALUE || DoubleValidity[i]==0)  ? 0 : 1);

      BuySum[i]=BuyValid[i]+BuyStruct[i]+RangeValid[i]+ TotalBreakValidity[i]+TotalRangeFormedValidity[i];
      BuyWeightage[i]=(BuyValid[i]*3)+(BuyStruct[i]*1)+(RangeValid[i]*2)+(TotalBreakValidity[i]*4)+(TotalRangeFormedValidity[i]*2);
      SellSum[i]=SellValid[i]+SellStruct[i]+SellValid[i]+ TotalBreakValidity[i]+TotalRangeFormedValidity[i];
      SellWeightage[i]=(SellValid[i]*3)+(SellStruct[i]*1)+(SellValid[i]*2)+(TotalBreakValidity[i]*4)+(TotalRangeFormedValidity[i]*2);

     }



   return(rates_total);
  }
//+------------------------------------------------------------------+
double DiffPrice(double price1, double price2)
  {
//---
//Print((price1 +" "+ price2) +" "+ (price1-price2) + " " + ((price1-price2)*MathPow(10,_Digits)));
   double D = (price1-price2)*PriceToPip(_Symbol);
   return(MathAbs(D));
//---
  }
//+------------------------------------------------------------------+
double GetADR(int bar)
  {
//---
   double avg = 0;
   double sum = 0;
   int DailyBar = iBarShift(Symbol(),PERIOD_D1,Time[bar]);
   double ATRValue = iATR(NULL, PERIOD_D1, 5, DailyBar+1);
   double Final_ADR = ATRValue*PriceToPip(_Symbol);
   /*for(int i=bar_day_num; i<bar_day_num+ADR_Period; i++)
    {
      double high_day = iHigh(Symbol(),PERIOD_D1,i);
      double low_day  = iLow(Symbol(),PERIOD_D1,i);
      sum += DiffPrice(high_day,low_day);
    }
   avg  =double(sum)/double(ADR_Period);*/
//---
   return(Final_ADR);
  }
//|                                                                  |
//+------------------------------------------------------------------+
int InitializeAll()
  {
   ArrayInitialize(ExtZigzagBuffer,0.0);
   ArrayInitialize(ExtHighBuffer,0.0);
   ArrayInitialize(ExtLowBuffer,0.0);
//--- first counting position
   return(Bars-InpDepth);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool new_bar()
  {
   static long t;
   if(t!=Time[0])
     {
      t=Time[0];
      return(true);
     }
   else
      return(false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool alert_function(datetime t, string what)
  {
   static datetime prev_time;
   static bool first_done;


   if(prev_time!=t)
     {
      prev_time = t;

      if(first_done)
        {
         string msg = _Symbol+", "+StringSubstr(EnumToString(ENUM_TIMEFRAMES(_Period)),7,0)+", "+what+" @"+TimeToString(t,TIME_DATE|TIME_MINUTES);
         if(alert_print)
            Print(msg);
         if(alert_pop)
            Alert(msg);
         if(alert_push)
            SendNotification(msg);
         if(alert_email)
            SendMail(msg,msg);
         if(alert_sound)
           {
            Print(msg);
            PlaySound(alert_sname);
           }
        }
      first_done = true;
     }

   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TrendCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="TrendLine",  // line name
                 const int             sub_window=0,      // subwindow index
                 datetime              time1=0,           // first point time
                 double                price1=0,          // first point price
                 datetime              time2=0,           // second point time
                 double                price2=0,          // second point price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            ray_right=false,   // line's continuation to the right
                 const bool            back=false,        // in the background
                 bool                  selectable=true,   //object can be selected
                 const bool            selection=false,   // higmaxight to move
                 const bool            hidden=false,      // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
   if(!ShowObjects)
      return(false);
//ResetLastError();
//if(!
   ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2);
//)
//  {
//   Print(__FUNCTION__,
//         ": failed to create \"Trend line\" object! Error code = ",GetLastError());
//   return(false);
//  }

   ObjectSet(name, OBJPROP_TIME1, time1);
   ObjectSet(name, OBJPROP_PRICE1, price1);
   ObjectSet(name, OBJPROP_TIME2, time2);
   ObjectSet(name, OBJPROP_PRICE2, price2);
   ObjectSet(name, OBJPROP_COLOR, clr);
   ObjectSet(name, OBJPROP_STYLE, style);
   ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSet(name, OBJPROP_BACK, back);
   ObjectSet(name, OBJPROP_RAY_RIGHT, ray_right);
   ObjectSet(name, OBJPROP_SELECTABLE, selectable);
   ObjectSet(name, OBJPROP_SELECTED,selection);
   ObjectSet(name, OBJPROP_HIDDEN, hidden);
   ObjectSet(name, OBJPROP_ZORDER, z_order);

   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TextCreate(long              chart_ID=0,               // chart's ID
                string            name="Text",              // object name
                int               sub_window=0,             // subwindow index
                datetime          time=0,                   // anchor point time
                double            price=0,                  // anchor point price
                string            text="Text",              // the text itself
                string            font="Arial",             // font
                int               font_size=10,             // font size
                color             clr=clrRed,               // color
                double            angle=0.0,                // text slope
                ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                bool              back=false,               // in the background
                bool              selectable=true,          //object can be selected
                bool              selection=false,          // higmaxight to move
                bool              hidden=false,             // hidden in the object list
                long              z_order=0)                // priority for mouse click
  {
   if(!ShowObjects)
      return(false);

   ResetLastError();
   ObjectCreate(chart_ID, name, OBJ_TEXT,sub_window, time, price);
   ObjectSetText(name, text,font_size,font,clr);
   ObjectSetInteger(0,name, OBJPROP_TIME, time);
   ObjectSetDouble(0,name, OBJPROP_PRICE, price);
   ObjectSet(name, OBJPROP_ANGLE, angle);
   ObjectSet(name, OBJPROP_ANCHOR, anchor);
   ObjectSet(name, OBJPROP_BACK, back);
   ObjectSet(name, OBJPROP_SELECTABLE, selectable);
   ObjectSet(name, OBJPROP_SELECTED,selection);
   ObjectSet(name, OBJPROP_HIDDEN, hidden);
   ObjectSet(name, OBJPROP_ZORDER, z_order);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,"zz");
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RSI_BufferValue(int shift)
  {
   return(iRSI(NULL,tf,RSI_Period,PRICE_CLOSE,shift));
  }


/*
v1.02 - Inputs changed
*/
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double PriceToPip(string symbol)
  {

   string         pipFactor[]  = {"BTCUSD","ETHUSD","JPY","XAG","SILVER","BRENT","WTI","XAU","GOLD","SP500","S&P","UK100","WS30","DAX30","DJ30","NAS100","CAC400","Index","AUDLFX", "CADLFX","CHFLFX", "EURLFX","GBPLFX", "NZDLFX", "USDLFX"};
   double         pipFactors[] = { 10,10,100,  100,  100,     100,    100,  10,   10,    10,     10,   1,      1,     1,      1,     1,       1, 1, 1000,1000,1000,1000,1000,1000,1000};

   for(int i=ArraySize(pipFactor)-1; i>=0; i--)
      if(StringFind(symbol,pipFactor[i],0)!=-1)
         return (pipFactors[i]);
   return(10000);

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool IsRSIValid(int bar, int type, int direction)
  {
//---
   double rsi = iRSI(Symbol(),RSI_TF,15,PRICE_CLOSE,bar);
   if(type==1)
     {
      if(direction==OP_BUY)
         if(rsi<Buy_Level_Type1)
            return(true);
      //+++
      if(direction==OP_SELL)
         if(rsi>Sell_Level_Type1)
            return(true);
     }
   if(type==2)
     {
      if(direction==OP_BUY)
         if(rsi<Buy_Level_Type2)
            return(true);
      //+++
      if(direction==OP_SELL)
         if(rsi>Sell_Level_Type2)
            return(true);
     }
//---
   return(false);
  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawRangeSub(int startbar, int bar2, int type, double interval_percent)
  {
//---
   color cl =clrRed;
   int highest = iHighest(Symbol(),PERIOD_CURRENT,MODE_CLOSE,MathAbs(startbar-bar2)+1,MathMin(startbar,bar2));
   int lowest  = iLowest(Symbol(),PERIOD_CURRENT,MODE_CLOSE,MathAbs(startbar-bar2)+1,MathMin(startbar,bar2));
   double Min = 0;//Low[iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,MathAbs(startbar-bar2)+1,MathMin(startbar,bar2))];
   double Max = 0;//High[iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,MathAbs(startbar-bar2)+1,MathMin(startbar,bar2))];
   double interval = double(ADR[startbar]*interval_percent)/double(100);
   if(type==OP_BUY)
     {
      Max = Close[highest]+interval*10*_Point;
      Min = Close[startbar]-interval*10*_Point;
     }
   if(type==OP_SELL)
     {
      Max = Close[startbar]+interval*10*_Point;
      Min = Close[lowest]-interval*10*_Point;
     }
   int endbar = 0;
   datetime arrowtime = Time[startbar];
   for(int i=startbar-1; i>=0; i--)
     {
      if(Close[i]<Min || Close[i]>Max)
        {
         endbar = i;
         if(Close[i]<Min)
           {
            SubSellArrowBreak[i] = High[i];
            arrowtime = Time[i];
           }
         if(Close[i]>Max)
           {
            SubBuyArrowBreak[i]  = Low[i];
            arrowtime = Time[i];
           }
         break;
        }
     }
   if(type==OP_BUY)
     {
      cl = clrBlue;
      //IndDrawVLine("Vline_"+TimeToString(arrowtime),Time[bar2],clrBlue);
      IndDrawTLine("zzHighRange_"+TimeToString(arrowtime),Time[highest],Close[highest]+interval*10*_Point,Time[endbar],Close[highest]+interval*10*_Point,false,cl);
      IndDrawTLine("zzLowRange_"+TimeToString(arrowtime),Time[startbar],Close[startbar]-interval*10*_Point,Time[endbar],Close[startbar]-interval*10*_Point,false,cl);
      //Print("Time : "+arrowtime+" | "+Time[startbar]+" | "+Time[bar2]);
     }
   if(type==OP_SELL)
     {
      cl = clrRed;
      //IndDrawVLine("Vline_"+TimeToString(arrowtime),Time[bar2],clrRed);
      IndDrawTLine("zzHighRange_"+TimeToString(arrowtime),Time[startbar],Close[startbar]+interval*10*_Point,Time[endbar],Close[startbar]+interval*10*_Point,false,cl);
      IndDrawTLine("zzLowRange_"+TimeToString(arrowtime),Time[lowest],Close[lowest]-interval*10*_Point,Time[endbar],Close[lowest]-interval*10*_Point,false,cl);
     }
//---
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawRangeMain(int startbar, int bar2, int type, double interval_percent)
  {
//---
   color cl =clrRed;
   int highest = iHighest(Symbol(),PERIOD_CURRENT,MODE_CLOSE,MathAbs(startbar-bar2)+1,MathMin(startbar,bar2));
   int lowest  = iLowest(Symbol(),PERIOD_CURRENT,MODE_CLOSE,MathAbs(startbar-bar2)+1,MathMin(startbar,bar2));
   double Min = 0;//Low[iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,MathAbs(startbar-bar2)+1,MathMin(startbar,bar2))];
   double Max = 0;//High[iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,MathAbs(startbar-bar2)+1,MathMin(startbar,bar2))];
   double interval = double(ADR[startbar]*interval_percent)/double(100);
   if(type==OP_BUY)
     {
      Max = Close[highest]+interval*10*_Point;
      Min = Close[startbar]-interval*10*_Point;
     }
   if(type==OP_SELL)
     {
      Max = Close[startbar]+interval*10*_Point;
      Min = Close[lowest]-interval*10*_Point;
     }
   int endbar = 0;
   datetime arrowtime = Time[startbar];
   for(int i=startbar-1; i>=0; i--)
     {
      if(Close[i]<Min || Close[i]>Max)
        {
         endbar = i;
         if(Close[i]<Min)
           {
            MainSellArrowBreak[i] = High[i];
            arrowtime = Time[i];
           }
         if(Close[i]>Max)
           {
            MainBuyArrowBreak[i]  = Low[i];
            arrowtime = Time[i];
           }
         break;
        }
     }
   if(type==OP_BUY)
     {
      cl = clrBlue;
      //IndDrawVLine("Vline_"+TimeToString(arrowtime),Time[bar2],clrBlue);
      IndDrawTLine("zzHighRangeMain_"+TimeToString(arrowtime),Time[highest],Close[highest]+interval*10*_Point,Time[endbar],Close[highest]+interval*10*_Point,false,cl);
      IndDrawTLine("zzLowRangeMain_"+TimeToString(arrowtime),Time[startbar],Close[startbar]-interval*10*_Point,Time[endbar],Close[startbar]-interval*10*_Point,false,cl);
      //Print("Time : "+arrowtime+" | "+Time[startbar]+" | "+Time[bar2]);
     }
   if(type==OP_SELL)
     {
      cl = clrRed;
      //IndDrawVLine("Vline_"+TimeToString(arrowtime),Time[bar2],clrRed);
      IndDrawTLine("zzHighRangeMain_"+TimeToString(arrowtime),Time[startbar],Close[startbar]+interval*10*_Point,Time[endbar],Close[startbar]+interval*10*_Point,false,cl);
      IndDrawTLine("zzLowRangeMain_"+TimeToString(arrowtime),Time[lowest],Close[lowest]-interval*10*_Point,Time[endbar],Close[lowest]-interval*10*_Point,false,cl);
     }
//---
  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawRangeSubU(int startbar, int bar2, int type, double interval_percent)
  {

//---
   color cl =clrRed;
   int highest = iHighest(Symbol(),PERIOD_CURRENT,MODE_CLOSE,MathAbs(startbar-bar2)+1,MathMin(startbar,bar2));
   int lowest  = iLowest(Symbol(),PERIOD_CURRENT,MODE_CLOSE,MathAbs(startbar-bar2)+1,MathMin(startbar,bar2));
   double Min = 0;//Low[iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,MathAbs(startbar-bar2)+1,MathMin(startbar,bar2))];
   double Max = 0;//High[iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,MathAbs(startbar-bar2)+1,MathMin(startbar,bar2))];
   double interval = double(ADR[startbar]*interval_percent)/double(100);
   if(type==OP_BUY)
     {
      Max = Close[highest]+interval*10*_Point;
      Min = Close[startbar]-interval*10*_Point;
     }
   if(type==OP_SELL)
     {
      Max = Close[startbar]+interval*10*_Point;
      Min = Close[lowest]-interval*10*_Point;
     }
   int endbar = 0;
   datetime arrowtime = Time[startbar];
   for(int i=startbar; i>=0; i--)
     {
      if(RangeTime1<Time[i])
        {
         RangeTime1=Time[i];
        }

      SubValidEntryU[i] = 0;
      if(Close[i]<Min || Close[i]>Max)
        {
         endbar = i;
         if(Close[i]<Min)
           {
            if(iRSI(Symbol(),0,RSI_Period1,PRICE_CLOSE,i)>PrevZZ_RSILevel_Sell1)
              {
               if(SubSellBreakU[i]==EMPTY_VALUE)
                 {
                  if(Enable_Range_Alert)
                    {
                     if(i==1)
                       {
                        SendNotification(Symbol()+" Sub Sell Break");
                       }
                    }
                  SubSellBreakU[i]=1;
                 }
              }
            SubSellArrowBreakU[i] = High[i];
            //arrowtime = Time[i];
           }
         if(Close[i]>Max)
           {
            if(iRSI(Symbol(),0,RSI_Period1,PRICE_CLOSE,i)<PrevZZ_RSILevel_Buy1)
              {
               if(SubBuyBreakU[i]==EMPTY_VALUE)
                 {
                  if(Enable_Range_Alert)
                    {
                     if(i==1)
                       {
                        SendNotification(Symbol()+" Sub Buy Break");
                       }
                    }
                  SubBuyBreakU[i]=1;
                 }
              }

            SubBuyArrowBreakU[i]  = Low[i];

            // arrowtime = Time[i];
           }
         if(RangeTime1==Time[i])
           {
            SubValidEntryU[i] = 1;
           }
         break;
        }
     }
   if(ShowObjects)
     {
      if(type==OP_BUY)
        {

         cl = clrBlue;
         //IndDrawVLine("Vline_"+TimeToString(arrowtime),Time[bar2],clrBlue);
         IndDrawTLine("zzHighRangeU_"+TimeToString(arrowtime),Time[highest],Close[highest]+interval*10*_Point,Time[endbar],Close[highest]+interval*10*_Point,false,cl);
         IndDrawTLine("zzLowRangeU_"+TimeToString(arrowtime),Time[startbar],Close[startbar]-interval*10*_Point,Time[endbar],Close[startbar]-interval*10*_Point,false,cl);
         //Print("Time : "+arrowtime+" | "+Time[startbar]+" | "+Time[bar2]);
        }
      if(type==OP_SELL)
        {
         cl = clrRed;
         //Print(lowest+" "+interval+" "+ (Close[lowest]-interval*10*_Point)+" "+ (Close[lowest]-interval*10*_Point));
         //IndDrawVLine("Vline_"+TimeToString(arrowtime),Time[bar2],clrRed);
         IndDrawTLine("zzHighRangeU_"+TimeToString(arrowtime),Time[startbar],Close[startbar]+interval*10*_Point,Time[endbar],Close[startbar]+interval*10*_Point,false,cl);
         IndDrawTLine("zzLowRangeU_"+TimeToString(arrowtime),Time[lowest],Close[lowest]-interval*10*_Point,Time[endbar],Close[lowest]-interval*10*_Point,false,cl);
        }
     }
//---
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawRangeMainU(int startbar, int bar2, int type, double interval_percent)
  {


//---
   color cl =clrRed;
   int highest = iHighest(Symbol(),PERIOD_CURRENT,MODE_CLOSE,MathAbs(startbar-bar2)+1,MathMin(startbar,bar2));
   int lowest  = iLowest(Symbol(),PERIOD_CURRENT,MODE_CLOSE,MathAbs(startbar-bar2)+1,MathMin(startbar,bar2));
   double Min = 0;//Low[iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,MathAbs(startbar-bar2)+1,MathMin(startbar,bar2))];
   double Max = 0;//High[iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,MathAbs(startbar-bar2)+1,MathMin(startbar,bar2))];
   double interval = double(ADR[startbar]*interval_percent)/double(100);
   if(type==OP_BUY)
     {
      Max = Close[highest]+interval*10*_Point;
      Min = Close[startbar]-interval*10*_Point;
     }
   if(type==OP_SELL)
     {
      Max = Close[startbar]+interval*10*_Point;
      Min = Close[lowest]-interval*10*_Point;
     }
   int endbar = 0;
   datetime arrowtime = Time[startbar];


   for(int i=startbar; i>=0; i--)
     {
      if(RangeTime<Time[i])
        {
         RangeTime=Time[i];
        }

      MainValidEntryU[i] = 0;
      if(Close[i]<Min || Close[i]>Max)
        {
         endbar = i;
         if(Close[i]<Min)
           {
            if(iRSI(Symbol(),0,RSI_Period1,PRICE_CLOSE,i)>PrevZZ_RSILevel_Sell1)
              {
               if(MainSellBreakU[i]==EMPTY_VALUE)
                 {
                  if(Enable_Range_Alert)
                    {
                     if(i==1)
                       {
                        SendNotification(Symbol()+" Main Sell Break");
                       }
                    }
                  MainSellBreakU[i]=1;
                 }
              }
            MainSellArrowBreakU[i] = High[i];

            //arrowtime = Time[i];
           }
         if(Close[i]>Max)
           {
            if(iRSI(Symbol(),0,RSI_Period1,PRICE_CLOSE,i)<PrevZZ_RSILevel_Buy1)
              {
               if(MainBuyBreakU[i]==EMPTY_VALUE)
                 {
                  if(Enable_Range_Alert)
                    {
                     if(i==1)
                       {
                        SendNotification(Symbol()+" Main Buy Break");
                       }
                    }
                  MainBuyBreakU[i]=1;
                 }
              }


            MainBuyArrowBreakU[i]  = Low[i];

            //arrowtime = Time[i];
           }

         if(RangeTime==Time[i])
           {
            MainValidEntryU[i] = 1;
           }
         break;
        }
     }
// Print(RangeTime);

   if(ShowObjects)
     {
      if(type==OP_BUY)
        {

         cl = clrBlue;
         //IndDrawVLine("Vline_"+TimeToString(arrowtime),Time[bar2],clrBlue);

         IndDrawTLine("zzHighRangeMainU_"+TimeToString(arrowtime),Time[highest],Close[highest]+interval*10*_Point,Time[endbar],Close[highest]+interval*10*_Point,false,cl);
         IndDrawTLine("zzLowRangeMainU_"+TimeToString(arrowtime),Time[startbar],Close[startbar]-interval*10*_Point,Time[endbar],Close[startbar]-interval*10*_Point,false,cl);

         //Print("Time : "+arrowtime+" | "+Time[startbar]+" | "+Time[bar2]);

        }
      if(type==OP_SELL)
        {
         //  Print("zzHighRangeMainU_"+TimeToString(arrowtime)+" "+ Time[startbar] +" "+ Time[endbar]);
         cl = clrRed;
         //IndDrawVLine("Vline_"+TimeToString(arrowtime),Time[bar2],clrRed);
         IndDrawTLine("zzHighRangeMainU_"+TimeToString(arrowtime),Time[startbar],Close[startbar]+interval*10*_Point,Time[endbar],Close[startbar]+interval*10*_Point,false,cl);
         IndDrawTLine("zzLowRangeMainU_"+TimeToString(arrowtime),Time[lowest],Close[lowest]-interval*10*_Point,Time[endbar],Close[lowest]-interval*10*_Point,false,cl);
        }
     }
//---
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FillValidEntrySubU(int bars)
  {

   int cnt= ObjectsTotal();

   for(int b=cnt; b>=0; b--)
     {
      string name= ObjectName(0,b);

      if(StringFind(name,"zzHighRangeU_")>-1)
        {
         datetime starttime = ObjectGetInteger(0,name,OBJPROP_TIME1);
         int      startbar  = iBarShift(Symbol(),PERIOD_CURRENT,starttime);
         datetime starttime1 = ObjectGetInteger(0,name,OBJPROP_TIME2);
         int      startbar1  = iBarShift(Symbol(),PERIOD_CURRENT,starttime1);

         for(int j=startbar; j>startbar1; j--)
           {
            SubValidEntryU[j] = 0;
           }

         if(TimeCurrent()-starttime1>604800)
           {
            ObjectDelete(0,name);
           }
        }

      if(StringFind(name,"zzLowRangeU_")>-1)
        {
         datetime starttime = ObjectGetInteger(0,name,OBJPROP_TIME1);
         int      startbar  = iBarShift(Symbol(),PERIOD_CURRENT,starttime);

         datetime starttime1 = ObjectGetInteger(0,name,OBJPROP_TIME2);
         int      startbar1  = iBarShift(Symbol(),PERIOD_CURRENT,starttime1);

         for(int j=startbar; j>startbar1; j--)
           {
            SubValidEntryU[j] = 0;
           }

         if(TimeCurrent()-starttime1>604800)
           {
            ObjectDelete(0,name);
           }
        }

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FillValidEntryMainU(int bars)
  {
//---

   int cnt= ObjectsTotal();

   for(int b=cnt; b>=0; b--)
     {
      string name= ObjectName(0,b);

      if(StringFind(name,"zzHighRangeMainU_")>-1)
        {

         datetime starttime = ObjectGetInteger(0,name,OBJPROP_TIME1);
         int      startbar  = iBarShift(Symbol(),PERIOD_CURRENT,starttime);
         datetime starttime1 = ObjectGetInteger(0,name,OBJPROP_TIME2);
         int      startbar1  = iBarShift(Symbol(),PERIOD_CURRENT,starttime1);

         for(int j=startbar; j>startbar1; j--)
           {
            MainValidEntryU[j] = 0;
           }


         if(TimeCurrent()-starttime1>604800)
           {
            ObjectDelete(0,name);
           }

        }
      //...

      if(StringFind(name,"zzLowRangeMainU_")>-1)
        {
         datetime starttime = ObjectGetInteger(0,name,OBJPROP_TIME1);
         int      startbar  = iBarShift(Symbol(),PERIOD_CURRENT,starttime);

         datetime starttime1 = ObjectGetInteger(0,name,OBJPROP_TIME2);
         int      startbar1  = iBarShift(Symbol(),PERIOD_CURRENT,starttime1);

         for(int j=startbar; j>startbar1; j--)
           {
            MainValidEntryU[j] = 0;
           }

         if(TimeCurrent()-starttime1>604800)
           {
            ObjectDelete(0,name);
           }
        }

      //...
     }

//---
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IndDrawTLine(string name, datetime time1, double price1, datetime time2, double price2, bool ray, color cl)
  {
//---
   if(ObjectFind(0,name)!=0)
     {
      bool res= ObjectCreate(0,name,OBJ_TREND,0,time1,price1,time2,price2);
      ObjectSet(name,OBJPROP_COLOR,cl);
      ObjectSet(name,OBJPROP_WIDTH,2);
      ObjectSet(name,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(name,OBJPROP_RAY,ray);
     }
   else
     {
      ObjectSet(name,OBJPROP_TIME2,time2);
     }

//---
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void USwing(int prev_calculated,
            const datetime &time[],
            const double &open[],
            const double &high[],
            const double &low[],
            const double &close[],
            const long& tick_volume[],
            const long& volume[],
            const int& spread[]
           )
  {
   int    i,limit,counterZ,whatlookfor=0;
   int    back,pos,lasthighpos=0,lastlowpos=0;
   double extremum;
   double curlow=0.0,curhigh=0.0,lasthigh=0.0,lastlow=0.0;

   if(tf==0 || tf==_Period)
     {
      //--- first calculations
      if(prev_calculated==0)
        {
         int minutes= HistoryDays*1440;
         limit= minutes/Period();

         if(limit>=Bars)
           {
            limit=Bars-InpDepth;
           }
        }
      else
        {

         //--- find first extremum in the depth ExtLevel or 100 last bars
         i=counterZ=0;
         while(counterZ<ExtLevel1 && i<100)
           {
            if(ExtZigzagBuffer1[i]!=0.0)
               counterZ++;
            i++;
           }
         //--- no extremum found - recounting all from begin
         if(counterZ==0)
            limit=InitializeAll();
         else
           {
            //--- set start position to found extremum position
            limit=i-1;
            //--- what kind of extremum?
            if(ExtLowBuffer1[i]!=0.0)
              {
               //--- low extremum
               curlow=ExtLowBuffer1[i];
               //--- will look for the next high extremum
               whatlookfor=1;
              }
            else
              {
               //--- high extremum
               curhigh=ExtHighBuffer1[i];
               //--- will look for the next low extremum
               whatlookfor=-1;
              }
            //--- clear the rest data
            for(i=limit-1; i>=0; i--)
              {
               ExtZigzagBuffer1[i]=0.0;
               ExtLowBuffer1[i]=0.0;
               ExtHighBuffer1[i]=0.0;
              }
           }

        }

      //--- main loop
      for(i=limit; i>=1; i--)
        {
         //--- find lowest low in depth of bars
         if(zz_hl)
            extremum=low[iLowest(NULL,0,MODE_LOW,InpDepth,i)];
         if(!zz_hl)
            extremum=close[iLowest(NULL,0,MODE_CLOSE,InpDepth,i)];
         //--- this lowest has been found previously
         if(extremum==lastlow)
            extremum=0.0;
         else
           {
            //--- new last low
            lastlow=extremum;
            //--- discard extremum if current low is too high
            if((zz_hl && low[i]-extremum>InpDeviation*Point) || (!zz_hl && close[i]-extremum>InpDeviation*Point))
               extremum=0.0;
            else
              {
               //--- clear previous extremums in backstep bars
               for(back=1; back<=InpBackstep; back++)
                 {
                  pos=i+back;
                  if(ExtLowBuffer1[pos]!=0 && ExtLowBuffer1[pos]>extremum)
                     ExtLowBuffer1[pos]=0.0;
                 }
              }
           }
         //--- found extremum is current low
         if((zz_hl && low[i]==extremum) || (!zz_hl && close[i]==extremum))
            ExtLowBuffer1[i]=extremum;
         else
            ExtLowBuffer1[i]=0.0;

         //--- find highest high in depth of bars
         if(zz_hl)
            extremum=high[iHighest(NULL,0,MODE_HIGH,InpDepth,i)];
         if(!zz_hl)
            extremum=close[iHighest(NULL,0,MODE_CLOSE,InpDepth,i)];
         //--- this highest has been found previously
         if(extremum==lasthigh)
            extremum=0.0;
         else
           {
            //--- new last high
            lasthigh=extremum;
            //--- discard extremum if current high is too low
            if((zz_hl && extremum-high[i]>InpDeviation*Point) || (!zz_hl && extremum-close[i]>InpDeviation*Point))
               extremum=0.0;
            else
              {
               //--- clear previous extremums in backstep bars
               for(back=1; back<=InpBackstep; back++)
                 {
                  pos=i+back;
                  if(ExtHighBuffer1[pos]!=0 && ExtHighBuffer1[pos]<extremum)
                     ExtHighBuffer1[pos]=0.0;
                 }
              }
           }
         //--- found extremum is current high
         if((zz_hl && high[i]==extremum) || (!zz_hl && close[i]==extremum))
            ExtHighBuffer1[i]=extremum;
         else
            ExtHighBuffer1[i]=0.0;
        }
      //--- final cutting
      if(whatlookfor==0)
        {
         lastlow=0.0;
         lasthigh=0.0;
        }
      else
        {
         lastlow=curlow;
         lasthigh=curhigh;
        }
      for(i=limit; i>=0; i--)
        {
         switch(whatlookfor)
           {
            case 0: // look for peak or lawn
               if(lastlow==0.0 && lasthigh==0.0)
                 {
                  if(ExtHighBuffer1[i]!=0.0)
                    {
                     lasthigh=High[i];
                     if(!zz_hl)
                        lasthigh=Close[i];
                     lasthighpos=i;
                     whatlookfor=-1;
                     ExtZigzagBuffer1[i]=lasthigh;
                    }
                  if(ExtLowBuffer1[i]!=0.0)
                    {
                     lastlow=Low[i];
                     if(!zz_hl)
                        lastlow=Close[i];
                     lastlowpos=i;
                     whatlookfor=1;
                     ExtZigzagBuffer1[i]=lastlow;
                    }
                 }
               break;
            case 1: // look for peak
               if(ExtLowBuffer1[i]!=0.0 && ExtLowBuffer1[i]<lastlow && ExtHighBuffer1[i]==0.0)
                 {
                  ExtZigzagBuffer1[lastlowpos]=0.0;
                  lastlowpos=i;
                  lastlow=ExtLowBuffer1[i];
                  ExtZigzagBuffer1[i]=lastlow;
                 }
               if(ExtHighBuffer1[i]!=0.0 && ExtLowBuffer1[i]==0.0)
                 {
                  lasthigh=ExtHighBuffer1[i];
                  lasthighpos=i;
                  ExtZigzagBuffer1[i]=lasthigh;
                  whatlookfor=-1;
                 }
               break;
            case -1: // look for lawn
               if(ExtHighBuffer1[i]!=0.0 && ExtHighBuffer1[i]>lasthigh && ExtLowBuffer1[i]==0.0)
                 {
                  ExtZigzagBuffer1[lasthighpos]=0.0;
                  lasthighpos=i;
                  lasthigh=ExtHighBuffer1[i];
                  ExtZigzagBuffer1[i]=lasthigh;
                 }
               if(ExtLowBuffer1[i]!=0.0 && ExtHighBuffer1[i]==0.0)
                 {
                  lastlow=ExtLowBuffer1[i];
                  lastlowpos=i;
                  ExtZigzagBuffer1[i]=lastlow;
                  whatlookfor=1;
                 }
               break;
           }
        }
      //--- done

     }//tf
   else
     {
      int limit_tf = MathMax(Bars-1-prev_calculated,MathMin(Bars-1,InpBackstep*5*MathMax(1,tf/_Period)));

      for(int z=limit_tf; z>=0; z--)
        {

         static int itf_prev;
         int itf = iBarShift(_Symbol,tf,Time[z],false);
         if(itf<0)
            continue;

         if(itf_prev!=itf)
           {
            itf_prev=itf;
            ExtZigzagBuffer1[z] = get_mtf(tf,4,itf);
           }
         else
           {
            ExtZigzagBuffer1[z] = 0;
           }
        }

     }


   int swing_limit=0;
   if(IndicatorCounted()==0)
     {
      swing_limit=Bars;
     }
   else
     {
      swing_limit = 3;
     }
   int swing_counter=0;
   int end_i = 0;

   for(i=0; i<Bars-1; i++)
     {
      if(ExtZigzagBuffer1[i]!=0 && swing_counter==0)
        {
         swing_counter++;
        }
      else
         if(ExtZigzagBuffer1[i]!=0 && swing_counter==1)
           {
            end_i=i;
            break;
           }
     }

   int limit2 = MathMax(Bars-1-prev_calculated,end_i);
   for(i=limit2; i>=end_i; i--)
     {
      static double prev_h1, prev_h_High1, prev_h_Low1, prev_h_rsi1;
      static double prev_l1, prev_l_High1, prev_l_Low1, prev_l_rsi1;
      static double zzlast1;
      static bool prev_l_LL1 = false, prev_h_HH1 = false;

      if(i==Bars-1)
        {
         prev_h1 = Open[i];
         prev_h_High1 = Open[i];
         prev_h_Low1 = Open[i];
         prev_h_rsi1=0;
         prev_l1 = Open[i];
         prev_l_High1 = Open[i];
         prev_l_Low1 = Open[i];
         prev_l_rsi1=0;
         zzlast1 = Open[i];
         prev_l_LL1 = false;
         prev_h_HH1 = false;
        }

      double zz = ExtZigzagBuffer1[i];
      static double zz_prev1;
      if(zz!=0)
        {
         zz_prev1 = zz;
         string use_text = "na";
         color use_clr = clrGray;
         double use_price = 0;

         double check_high = iHigh(_Symbol,tf,iBarShift(_Symbol,tf,Time[i]));
         double check_low = iLow(_Symbol,tf,iBarShift(_Symbol,tf,Time[i]));
         double check_close = iClose(_Symbol,tf,iBarShift(_Symbol,tf,Time[i]));

         double rsi = RSI_BufferValue(iBarShift(_Symbol,tf,Time[i]));

         if((zz_hl && zz==check_high) || (!zz_hl && zz==check_close && check_close>zzlast1))
           {
            zzlast1 = check_close;
            use_clr = clrDodgerBlue;
            if(zz>prev_h1
               && (ZigZagBasedOnEntries_Percent < 0 || prev_h_HH1 || zz > prev_h_High1+ZigZagBasedOnEntries_Percent*0.01*(prev_h_High1-prev_h_Low1))
               && (!ZigZagBasedOnDivergence || !(prev_h_rsi1 > PrevZZ_RSILevel_Buy && rsi < prev_h_rsi1))
              )
              {
               // Print(Time[i]+" "+ check_close +" "+ "HH");
               prev_h1=zz;
               prev_h_High1=check_high;
               prev_h_Low1=check_low;
               prev_h_rsi1 = rsi;
               prev_h_HH1 = true;

               b_hh1[i] = zz_hl ? check_high:check_close;
               if(text_show_time && prev_calculated>0)
                 {
                  TimeOccurBuffer1[i] = StringToTime(TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
                 }
              }
            else
              {
               //Print(Time[i]+" "+ check_close +" "+ "LH");
               prev_h1=zz;
               prev_h_High1=check_high;
               prev_h_Low1=check_low;
               prev_h_rsi1 = rsi;
               prev_h_HH1 = false;

               b_lh1[i] = zz_hl ? check_high:check_close;
               use_text = "LH";
               if(text_show_time && prev_calculated>0)
                 {
                  TimeOccurBuffer1[i] = StringToTime(TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
                 }
              }

            int c1=0;
            int c2=0;
            for(int k=i; k<Bars-1; k++)
              {
               if(ExtZigzagBuffer1[k]!=0 && c1==0)
                 {
                  c1++;
                 }
               else
                  if(ExtZigzagBuffer1[k]!=0 && c1==1)
                    {
                     c2=k;
                     break;
                    }
              }
            if(c1!=0 && c2!=0)
              {
               long t1 = iTime(_Symbol,tf,iBarShift(_Symbol,tf,Time[c2]));
               long t2 = iTime(_Symbol,tf,iBarShift(_Symbol,tf,Time[i]));
               double p1 = zz_hl ? iLow(_Symbol,tf,iBarShift(_Symbol,tf,Time[c2])):iClose(_Symbol,tf,iBarShift(_Symbol,tf,Time[c2]));
               double p2 = zz_hl ? check_high:check_close;
              }

           }//high found

         if((zz_hl && zz==check_low) || (!zz_hl && zz==check_close && check_close<zzlast1))
           {
            zzlast1 = check_close;
            use_clr = clrRed;
            if(zz<prev_l1
               && (ZigZagBasedOnEntries_Percent < 0 || prev_l_LL1 || zz < prev_l_Low1-ZigZagBasedOnEntries_Percent*0.01*(prev_l_High1-prev_l_Low1))
               && (!ZigZagBasedOnDivergence || !(prev_l_rsi1 < PrevZZ_RSILevel_Sell && rsi > prev_l_rsi1))
              )
              {
               prev_l1=zz;
               prev_l_High1=check_high;
               prev_l_Low1=check_low;
               prev_l_rsi1 = rsi;
               prev_l_LL1 = true;

               b_ll1[i] = zz_hl ? check_low:check_close;
               use_text = "LL";
               if(text_show_time && prev_calculated>0)
                 {
                  TimeOccurBuffer1[i] = StringToTime(TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
                 }
              }
            else
              {
               prev_l1=zz;
               prev_l_High1=check_high;
               prev_l_Low1=check_low;
               prev_l_rsi1 = rsi;
               prev_l_LL1 = false;

               b_hl1[i] = zz_hl ? check_low:check_close;
               use_text = "HL";
               if(text_show_time && prev_calculated>0)
                 {
                  TimeOccurBuffer1[i] = StringToTime(TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
                 }
              }

            int c1=0;
            int c2=0;
            for(int k=i; k<Bars-1; k++)
              {
               if(ExtZigzagBuffer1[k]!=0 && c1==0)
                 {
                  c1++;
                 }
               else
                  if(ExtZigzagBuffer1[k]!=0 && c1==1)
                    {
                     c2=k;
                     break;
                    }
              }
            if(c1!=0 && c2!=0)
              {
               long t1 = iTime(_Symbol,tf,iBarShift(_Symbol,tf,Time[c2]));
               long t2 = iTime(_Symbol,tf,iBarShift(_Symbol,tf,Time[i]));
               double p1 = zz_hl ? iHigh(_Symbol,tf,iBarShift(_Symbol,tf,Time[c2])):iClose(_Symbol,tf,iBarShift(_Symbol,tf,Time[c2]));
               double p2 = zz_hl ? check_low:check_close;
              }
           }//low found

        }//zz found

     }//zz loop


  }
//+------------------------------------------------------------------+
