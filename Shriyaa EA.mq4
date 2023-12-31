//+------------------------------------------------------------------+
//|                                                  RIS Kishore.mq4 |
//|                              Copyright 2021, Radian Infosystems. |
//|                                 https://www.radianinfosystems.in |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Radian Infosystems."
#property link      "https://www.radianinfosystems.in"
#property version   "4.500"
#property strict

#define        WIDTH  1200     // Image width to call ChartScreenShot()
#define        HEIGHT 800     // Image height to call ChartScreenShot()


#import "MT4Connector.dll"
void Lock();
void Unlock();
bool FirstLock();
void FirstUnlock(bool first);
bool ConnectedLock();
void ConnectedUnlock(bool connected);
bool GetSignal(string &message);
bool RemoveSignal(string &message);
void Initialize();
bool IsCopierConnected();
void InternalGetLastErrorEdg(string &message);
#import

struct conf
  {
   bool              isLocked;
   datetime          confTime;
   datetime          MaxConfTime;
   string            confby;
   bool              isInformed;
   int               countValue;
  };
struct spread_pair
  {
   string            sym;
   double            spread_value;
   double            max_spread;
  };
enum MethodCandle
  {
   UseWick,//Candle Wick
   UseClose,//Candle Close
  };

enum signal_list
  {
   BUY=0,       //BUY ONLY
   SELL=1,      //SELL ONLY
   BOTH=2,      //BOTH Signal
  };
enum ENUM_ZLOGIC_MODE
  {
   LOGIC_A, //Logic A
   LOGIC_B, //Logic B
  };
enum ENUM_STRENGTH_CALC
  {
   SAME_STRENGTH, //Same Strength
   SUM_STRENGTH, //Sum Strength
  };
enum ENUM_ADR_TARGETS
  {
   ADR_TARGET, //ADR Target
   AWR_TARGET, //AWR Target
  };
enum ENUM_SHOW_SIGNALS
  {
   SHOW_BUY=0, //BUY ONLY
   SHOW_SELL=1, //SELL ONLY
   SHOW_BOTH=2, //BOTH Signals
//SHOW_BIAS=3, //Bias Signals
  };
enum ENUM_LOGIC_MODE
  {
   L1, //Logic #1
   L2, //Logic #2
   LBOTH, //BOTH
  };
enum risk_type
  {
   RiskEquity=0,       //Risk from Equity
   RiskAccBal=1,       //Risk from Account Balance
  };
enum Enum_LogicConfirmation
  {
   Confirmation1,
   Confirmation2,
   Confirmation3
  };
enum Enum_RSI_Type
  {
   RSI_Direct,
   RSI_Inverse
  };

enum direction
  {
   Buy=0,
   Sell=1,
   OverAll=2
  };
struct stc_swing_adr
  {
   string            cur;
   int               buyValid;
   int               sellValid;
  };

input string hint0="------------- File Folder Path -------------";//==========================
input string RootFolder = "Auto";//Root Folder(Add Suffix Number)
int FolderName = 1;//Numbered Folder
input bool EnableFileScanner = true;//Enable File Scanner
input bool ReadEADataFromFile = true;//Read EAData from file/server
string EADataFolder = "EAData";//EAData folder name
int EADataSubFolder = 1;//EAData Subfolder

input string hint1="------------- Global Settings -------------";//==========================
input string EAID1 = "RIS";//EA ID (Trade Comments)
string EAID = EAID1;//EA ID (Trade Comments)
input ENUM_SHOW_SIGNALS Signal_Mode = SHOW_BOTH;//Signal Mode
input string Start_Time = "01:00:00";//Start Time
input string End_Time = "22:00:00";//End Time
input int MagicNumber = 123;//Magic Number
ENUM_TIMEFRAMES TouchHTF = PERIOD_CURRENT; //Entry Candle Timeframe
input bool EnableScreenshot = false;//Make Screenshot of Entries
input int TradingDelay = 0;//Delay in opening trades

input string hint5="------------- Risk Settings -------------";//==========================
input risk_type RiskFrom = RiskAccBal;//Risk From
input double RiskPercent1 = 0.75;//Risk % from Balance/Equity
double RiskPercent =RiskPercent1;
bool IncreaseRiskOnLoss = false;//Increase Risk after StopLoss
double RiskIncreaseMultiplier = 1.25;//Risk Increase Factor
input bool RoundUpCalculatedLotToAccountMinLot = true;// Take Minimum Lots when Balance is Low
input bool EnableFundedAccount = false;//Enable funded account risk calc
input int FundedAccountBalance = 250;//Funded account balance to use

input string hint7="------------- Order Types -------------";//==========================
input bool EnableCandleStickOrder = true;//Enable Candle Stick Order
input bool EnableCandleLimitOrder = true;//Enable Candle Limit Order
input bool EnableCRCStage = true;//Enable CRC stage(only limit orders will be placed when true)

input string hint8="------------- CRC Stage Limit Orders Candle % -------------";//==========================
input int CRCStage_Zone1 = 100;//Stage 1 Limit Order in % of Candle
input int CRCStage_Zone2 = 75;//Stage 2 Limit Order in % of Candle

input string hint2="------------- Spread Settings -------------";//==========================
input bool Enable_CSVSpread = true;//Enable CSV Spread File
input string SpreadFileName = "Spread1";//Spread File Name
input double SymAvgSpreadValue = 0.6;//Average Spread in Pip
double AvgSpreadValue = 0.6;
double MaxSpreadValue = 0.6;
input double Spread_Multiplier = 2.0;//Spread Multiplier for SL
input double Spread_MultiplierAvg = 1.0;//Spread Multiplier for SL Above Average
input bool ApplySpreadToLimitEntry = true;//apply avg spread to limit entry
input int SpreadBuyPercent = 100;//percent of avg spread for buylimit adjustment
input int SpreadSellPercent = 100;//percent of avg spread for selllimit adjustment

input string hint4="------------- Equity Exit Levels -------------";//==========================
input bool EnableEquityExit = false;//Enable Equity Exit
input double EquityExit = 25;//Positive Exit %
input double EquityExitNeg = -80;//Negative Exit %
input double EquityStopTrading = 0.5;//Stop New Trade when Equity is less than x% to target

input string hint3="------------- Closing Trades -------------";//==========================
input bool EnableCAT = false;//Enable Close All Trades
input string Closing_Time = "22:00:00";//Closing Time
input int OrderExpiryTime = 120;//Pending Order Expiry Time in Minutes

input string hint9="------------- StopLoss Placement -------------";//==========================
int  CRC_NumOfDays = 5;//CRC Number of Days
input double CandleSLPercentStage1 = 1.25;//Limit SL Percentage Stage 1
input double CandleSLPercentStage2 = 0.625;//Limit SL Percentage Stage 2
input double CRCSLMultiplierStage1 = 0.6;//Candle SL % Stage 1
input double CRCSLMultiplierStage2 = 0.3;//Candle SL % Stage 2
input bool CheckSLValueByCRC = true;//Check Stoploss Maximum by CRC
input int StopLossCRC1 = 110;//Stoploss Maximum CRC
int StopLossCRC = StopLossCRC1;//Stoploss Maximum CRC

enum enm_sl_crc_action
  {
   sl_crc_no_trade,//Dont Open Trade
   sl_crc_use_crc,//Use CRC for sl
  };
input enm_sl_crc_action ActionOnSLCRC = sl_crc_use_crc;//Don’t Enter Trade/ Use Max CRC for SL

input string hint6="------------- Reward Settings -------------";//==========================
input double RewardPercent1 = 20;//Reward %
double RewardPercent = RewardPercent1;//Reward %
input double CommissionPerLot = 7.0;//Commission per 1 lot
input bool EnableADR_AWR_Target = false;//Enable ADR/AWR Target
input ENUM_ADR_TARGETS ADR_TargetMethod = ADR_TARGET;//Target Method
input int ADR_Target_Percent = 100;//ADR Target %
input int AWR_Target_Percent = 100;//AWR Target %

input string hint11="------------- Trade Management -------------";//==========================
input bool PendingToMarketAllowed= true;//Enter at market if market price over limit price
input bool AllowOppositeSignals = true;//Allow Opposite Direction Entry on Same Symbol
input bool Check_Dir_Separately = false;//Count of SL,TP,BE per direction
input int SL_Check = 4;//How many SL trades allowed
input int TP_Check = 2;//How many TP trades allowed
input int Breakeven_Check = 3;//How many Breakeven trades allowed
int CondCheck = 1;//How many Cond should Check
int CondCount = 0;//Condtion Count for MA,VSM,CSM
input int MaxLimitOrders = 3;//Maximum Total Limit Orders (per direction)
int MaxArrowLimitOrders = 2;//Maximum ZIZ Arrow Limit Orders
input bool CountRunningTradePerDirection = true;//Check Maximum Running Orders Per Direction
input int MaxRunningOrders = 1;//Maximum Running Orders per Direction/overall


input string hint19="------------- Limit Order & Running Order Stacking Conditions -------------";//==========================
input bool CheckEntryStacking = true;//Check Limit Order Stacking Conditions
int ADR_Period = 5;//ADR Period
input double MinDistanceBetweenOrdersInPercentOfADR = 6;//Min Distance Between Orders in ADR %
input int MinTimeBetweenOrdersInMinutes1 = 15;//Min Time Between Entries in Minutes
int MinTimeBetweenOrdersInMinutes = MinTimeBetweenOrdersInMinutes1;//Min Time Between Entries in Minutes
input int EntryStackingSuccessRate = 1;//No. of Conditions needed to satisfy

input string hint20="------------- Stoploss Stacking Conditions -------------";//==========================
input bool CheckStoplossStacking = true;//Check Stoploss Stacking Conditions
enum enm_sl_base_candle
  {
   sl_entry,//Entry Candle
   sl_exit,//Exit Candle
  };
input enm_sl_base_candle SLBaseCandle=sl_exit;//Check Stoploss Base Candle
input double MinSLDistanceInPercentOfADR = 5;//Min Distance Between Orders in ADR %
input int MinSLTimeInMinutes1 = 30;//Min Time Pass prev SL in Minutes
int MinSLTimeInMinutes = MinSLTimeInMinutes1;//Min Time Pass prev SL in Minutes
input int SL_Alternate = 0;//Max consecutive SL allowed per direction
input int StoplossStackingSuccessRate = 1;//No. of Conditions needed to satisfy

input string hint12="------------- Breakeven Settings -------------";//==========================
input bool EnableBreakEven = true;//Enable BreakEven
input double Breakeven_Start = 3;//Breakeven Start Level
input double Breakeven_Step = 0;//Breakeven Step Gap Level
bool AllowRiskFreeTrade = false;//Allow Risk Free Entry

input string hint21="------------- Zigzag Trailing Settings -------------";//==========================
input bool EnableZigzagTrailing = true;//Enable Enable Zigzag Trailing Stoploss
input ENUM_TIMEFRAMES ZigzagTrailTF = PERIOD_M5;//Zigzag Trailing SL TF
input bool ZigzagTrailUseLLHHOnly = true;//Use LL/HH only
input double ZigzagTrailGapPercentOfADR = 4;//Use ADR Extend %

input bool EnableZigzagTrailing2 = true;//Enable Enable Zigzag Trailing Stoploss
input ENUM_TIMEFRAMES ZigzagTrailTF2 = PERIOD_M15;//Zigzag Trailing SL TF
input bool ZigzagTrailUseLLHHOnly2 = false;//Use LL/HH only
input double ZigzagTrailGapPercentOfADR2 = 6;//Use ADR Extend %

string hint211="------------- Opposite Dir Supply&Demand Exit Settings -------------";//==========================
enum Enum_DirectionFilter
  {
   DirectionFilter_Buy,
   DirectionFilter_Sell,
   DirectionFilter_Both
  };
bool ExitOnPerfectSignal = false;//exit on s&d opposite perfect signal?
bool SDPerfectShowObjects = false;
Enum_DirectionFilter SDPerfectDirectionFilter = DirectionFilter_Both;
ENUM_TIMEFRAMES ExitOnPerfectTF = PERIOD_M15;//tf to read s&d perfect
int SDPerfectNumberOfDays = 4;
bool SDPerfectVolumeZone_Filter = false;
ENUM_TIMEFRAMES SDPerfectVolumeZone_Timeframe1 = PERIOD_H4; //VolumeZone_HTF
ENUM_TIMEFRAMES SDPerfectVolumeZone_Timeframe2 = PERIOD_M15; //VolumeZone_LTF
bool SDPerfectBreachLogicBasedOnEntries = true;
double SDPerfectBreachLogicBasedOnEntries_Percent = 25;
int SDPerfectNeededConditionsToConfirm = 3;//No, of cnditions to check

bool SDPerfectReadDataFromFile = true;//read s&d perfect from file
string SDPerfectFolderName = "EAData";//folder to read
input string SDPerfectFileName = "SD";//file name prefix
int SDPerfectFolderNumber = EADataSubFolder;//subfolder

input string hint10="------------- Candlesticks Settings -------------";//==========================
bool EnableEntryCandle = true;//Enable Entry Candle
input bool EnableTrendDirectionFilter = false;//Enable trend direction filter
bool CombineExplodeAndSDLiquidity = false;//Combine explode and Sully&Demand liquidity
int ExplodeAndSDLiquidityNeeded = 0;//Explode & Liquidity Sum Min Needed
int ExplodeAndSDLiquidityMinBoth = 0;//Minimum Needed in Both
bool EnableExplodeFilteration = false;//Enable Explode Filteration
bool EnableSDLiquidity = false;//Enable Supply&Demand Liquidity

string TDFSettings = "================ Entry Candle Trend Direction Filter Properties ================"; //=================
bool M1AEnabled = false;//method 1 A enabled?
bool M1BEnabled = false;//method 1 B enabled?
bool M2AEnabled = false;//method 2 A enabled?
bool M2BEnabled = false;//method 2 B enabled?
input bool M5PerfectDirectionEnabled = false;//M5 perfect direction enabled?
input bool M15PerfectDirectionEnabled = false;//M15 perfect direction enabled?
input int Segment2ValidityBars = 12;//trend direction filter validity bars

bool EnableMyCandle = true;//Enable My Candle
input double BodySize1_MC = 0.65;//Body size1 MC above this %

input string hint14="------------- Candle Range Check Settings -------------";//==========================
input bool EnableCRC = true;//Enable CRC Check
input double CRC_Multiplier = 35;// Multiplier
input double CRC_MultiplierMax = 45;// Multiplier Max

input string hint13="------------- Avoiding Trades -------------";//==========================
input bool AvoidBigCandles = true;//Avoid News Candle
input double BigCandleAdrPercent = 15;//% Of ADR to be considered as News Candle
input int SkipEntryOnBigCandleMinutes = 120;//Avoid Fake Validity Candles in Minutes


input string hint15="------------- ADR Trades Filter -------------";//==========================
bool ReadAdrFromFile = true;//Read data from file?
string AdrFolderName = "EAData";//folder name
input string AdrFileName = "ADR";//file prefix
int AdrFolderNumber = EADataSubFolder;//subfolder no
input bool EnableADR_AWR = true;//Enable ADR
input bool EnableNo_Today_Trade_Buffer = false;//Enable No Today Trade Buffer
input bool EnableBias_ADR = true;//Enable Bias ADR
input int ADR_NoTrade_Percent = 70;
input int AWR_NoTrade_Percent = 70;
input bool EnableBias_AWR = false;//Enable Bias AWR
input int ADR_NoTradeToday_Percent = 55;
input int AWR_NoTradeToday_Percent = 55;

input string hint151="------------- Swing ADR Trades Filter -------------";//==========================
input bool SwingAdrFilterEnabled = false;//Swing Adr filter enabled?
input bool ReadSwingAdrFromFile = true;//Read from file
string SwingAdrFolderName = "EAData";//folder name
int SwingAdrFolderNumber = EADataSubFolder;//subfolder no
input string SwingAdrFileName = "SADR";//file prefix
enum enm_sadr_mode
  {
   sa_direction,//Direction
   sa_both,//Both
  };
input enm_sadr_mode ValidationType = sa_direction;

input string hint152="------------- Swing ADR Currency Filter -------------";//==========================
input bool SwingAdrCurrencyEnabled = false;//Swing Adr currency enabled?
input int CurrencyRate1 = 3;
input int CurrencyRate2 = 3;


input string hint153="------------- Market Structure Filter -------------";//==========================
input ENUM_TIMEFRAMES ZigZag_TF=PERIOD_CURRENT;//ZigZag TF
input bool CZDCV=false;//Check Zigzag Directional Change Valid
input bool CSV=false;//Check Structure Valid


input string hint154="------------- Range Filter -------------";//==========================
input bool CZRV=false;//Check Zigzag Range Valid
input double ZRVN=1.0;//Zigzag Range Value Needed


stc_swing_adr swingAdr[];


input string Div33a        = "___ Range BreakValidity ___";//==========================
input bool EnableSingleValidity=false;//Enable Single Validity
input bool EnableDoubleValidity=false;//Enable Double Validity

input string Div34a        = "___ Explode Check Validity ___";//==========================
input bool EnableExplodeCheck=false;//Enable Explode Check
input double ExplodeValue=8;//Explode Value


input string Div34b        = "___ Logical Sum & Weightage Check ___";//==========================
input bool EnableLogicalSum=true;
input double SumGTE=5;
input double SumLT=5;
input bool EnableLogicalWeightage=true;
input double WeightageGTE=5;
input double WeightageLT=5;

input string Div34c        = "___ Zigzag Range Formation Check ___";//==========================
input bool Enable_Zigzag_Range_Formation_Check=true;
input int Range_Formation_Value=1;
input string Modify_Trade_Comments="XXX";

input string Div34d        = "___ Hedge comment change ___";//==========================
input bool ChangeHedgeComment=true;//Change Hedge Comment
input string HedgeComment="abc";//Hedge Comment

input string Div35a        = "___ Avoid Hedge Currency comment change ___";//==========================
input bool Avoid_Hedge_Currency_Filtration=true;//Avoid Hedge Currency Filtration
input string Avoid_Hedge_Currency_Filtration_Comment="EEE";//Avoid Hedge Comment

input string Div35b        = "___ Avoid Stacking Currency comment change ___";//==========================
input bool Avoid_Stacking_Directional_Positions_on_Currency=false;//Avoid Stacking Directional Positions on Currency
input string Avoid_Stacking_Directional_Positions_on_Currency_Comment="345";//Avoid Stacking Directional Comment

input string Div35c        = "___ Enable HTF - 1 Structure ___";//==========================
input bool Enable_HTF1_Structure_Filter=false;//Enable HTF1 Structure Filter
input ENUM_TIMEFRAMES HTF1_TF=PERIOD_H1;//HTF1 TF
input bool Enable_HLLH_entries_only=false;//Enable HL/LH entries only 1
input bool Enable_HHLL_entries_only=false;//Enable HH/LL entries only 1
bool ShowObjects1 = false;
ENUM_TIMEFRAMES tf1 = PERIOD_CURRENT;      //TF 1
input int InpDepth1=7;                          //Depth 1
input int InpDeviation1=6;                       //Deviation 1
input int InpBackstep1=5;                        //Backstep 1
input bool CheckZigZagValid_1=true;//Check ZigZag Valid HTF-1
bool zz_hl_1=false; //Base on HL (F=close) HTF-1
input int Recent_Zigzag_1=12; //Recent ZigZag HTF-1
input int Imbalance_1=6; //Imbalance HTF-1

input string Div35d        = "___ Enable HTF - 2 Structure ___";//==========================
input bool Enable_HTF2_Structure_Filter=false;//Enable HTF2 Structure Filter
input ENUM_TIMEFRAMES HTF2_TF=PERIOD_H4;//HTF2 TF
input bool Enable_HLLH_entries_only_2=false;//Enable HL/LH entries only 2
input bool Enable_HHLL_entries_only_2=false;//Enable HH/LL entries only 2
bool ShowObjects2 = false;
ENUM_TIMEFRAMES tf2 = PERIOD_CURRENT;      //TF 2
input int InpDepth2=7;                          //Depth 2
input int InpDeviation2=6;                       //Deviation 2
input int InpBackstep2=5;                        //Backstep 2
input bool CheckZigZagValid_2=true;//Check ZigZag Valid HTF-2
bool zz_hl_2=false; //Base on HL (F=close) HTF-2
input int Recent_Zigzag_2=12; //Recent ZigZag HTF-2
input int Imbalance_2=6; //Imbalance HTF-2

input string Div35e        = "___ Enable HTF - 3 Structure ___";//==========================
input bool Enable_HTF3_Structure_Filter=false;//Enable HTF3 Structure Filter
input ENUM_TIMEFRAMES HTF3_TF=PERIOD_D1;//HTF3 TF
input bool Enable_HLLH_entries_only_3=false;//Enable HL/LH entries only 3
input bool Enable_HHLL_entries_only_3=false;//Enable HH/LL entries only 3
bool ShowObjects3 = false;
ENUM_TIMEFRAMES tf3 = PERIOD_CURRENT;      //TF 3
input int InpDepth3=7;                          //Depth 3
input int InpDeviation3=6;                       //Deviation 3
input int InpBackstep3=5;                        //Backstep 3
input bool CheckZigZagValid_3=true;//Check ZigZag Valid HTF-3
bool zz_hl_3=false; //Base on HL (F=close) HTF-3
input int Recent_Zigzag_3=12; //Recent ZigZag HTF-3
input int Imbalance_3=6; //Imbalance HTF-3

input string hint18="------------- Text File Generation -------------";//==========================
input bool CreateTextFiles = false;//Create Text Files
input string TextFilesFolder = "Scalping";//Text Files Folder
input string TextFilesFolder_1 = "Scalping";//Additional Text Files Folder
input int TextFileValidityInMinutes = 5;//Text File Validity in Minutes
input int MaxFilesInFolder = 12;//Max Files In Folder
input int FolderNumbers = 5;//Number of Folders


string hint16="------------- Open Interest MyFxBook Sentiment -------------";//==========================
bool EnableDataIndicatorCalculation=false; //Enable Data Indicator Calculation
string ___BUY="";
double MinimumValueBuy=-80; //Minimum Value
double MaximumValueBuy=70; //Max Value
string ___SELL="";
double MinimumValueSell=-70;//Minimum Value
double MaximumValueSell=80; //Max Value
bool OverExtendedFilter = true;
int OverExtendedLevel = 80;

string hint17="------------- StopHunt CheckPoints -------------";//==========================
bool EnableStopHuntCheckForEntry = false;
bool EnableSHC_MarketShift       = false;  //Enable SHC Market Shift [1pt]
bool EnableSHC_Asian             = false;  //Enable SHC Asian [1pt]
bool EnableSHC_ADR               = false;  //Enable SHC ADR [1pt]
bool EnableSHC_LiqGrabTrig1      = false;  //Enable Liquidity Grab Trig1 [1pt]
bool EnableSHC_LiqGrabTrig2      = false;  //Enable Liquidity Grab Trig2 [3pt]
bool EnableSHC_SwingStopM1Trig1  = false;  //Enable SHC SwingStop M1 Trig1 [6pt]
bool EnableSHC_SwingStopM1Trig2  = false;  //Enable SHC SwingStop M1 Trig2 [8pt]
bool EnableSHC_SwingStopM2Trig1  = false;  //Enable SHC SwingStop M2 Trig1 [5pt]
bool EnableSHC_SwingStopM2Trig2  = false;  //Enable SHC SwingStop M2 Trig2 [7pt]
bool EnableSHC_SwingStopM3Trig1  = false;  //Enable SHC SwingStop M3 Trig1 [4pt]
bool EnableSHC_SwingStopM3Trig2  = false;  //Enable SHC SwingStop M3 Trig2 [6pt]
bool EnableSHC_SwingStopM4Trig1  = false;  //Enable SHC SwingStop M4 Trig1 [4pt]
bool EnableSHC_SwingStopM4Trig2  = false;  //Enable SHC SwingStop M4 Trig2 [6pt]
bool EnableSHC_SwingStopM5Trig1  = false;  //Enable SHC SwingStop M5 Trig1 [3pt]
bool EnableSHC_SwingStopM5Trig2  = false;  //Enable SHC SwingStop M5 Trig2 [5pt]
int SHC_Count                    = 0;     //SHC Count out of 56 pt

string hint22="------------- Read Entry Candle From File -------------";//==========================
bool ReadEntryCandleFromFile = true;//read from file?
string EntryCandleFolderName = "EAData";//common folder name
int EntryCandleSubFolderNumber = EADataSubFolder;//subfolder
string EntryCandleFileName = "EntryCandle";//file prefix
string allSymbols[28]= { "AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY" };
//--- input parameters
bool EnableAutoPilot          = false;       //Enable AutoPilot
bool EnableNewsFilter   = false;       //Enable News Filter
bool EnableKZZ           = false;       //Enable KZZ
bool EnableKZZPrevDay    = false;       //Enable KZZ Previous Day Check
bool EnableKZZ2          = false;       //Enable KZZ2

bool EnableTargetInd     = false;       //Enable Target Indicator
ENUM_TIMEFRAMES Target_TF = PERIOD_H1; //Target Timeframe
int TargetNumber        = 2;           //Target Number
bool EnableZIZ           = false;       //Enable Zone Inside Zone
bool EnableZoneTouch     = false;        //Enable Zone Touch

bool EnableManualTime  = false;       //Enable Manual Entry Time
datetime Manual_Entry_Time = (datetime)"2022.03.23 05:00:00";  //Manual Entry Start Time
datetime Manual_Exit_Time = (datetime)"2022.03.23 22:00:00";   //Manual Entry End Time
bool EnableManualEquityExit   = false;       //Enable Manual Equity Exit
double Manual_EquityExitPos   = 1030;        //Manual Equity Positive Exit in value
double Manual_EquityExitNeg   = 600;        //Manual Equity Negative Exit in value

string Div0a              = "--- ENTRY METHODS ---";
string Div0a1              = "*** LIMIT ORDERS ***";//.
bool EnableSSMLimitOrder = false;        //Enable SSM Limit Order
bool EnableMACLimitOrders = false;        //Enable MAC Limit Orders
bool EnableVolZoneLimitOrders  = false; //Enable Volume Zone Limit Orders
bool EnableLiqLimitOrders = false;        //Enable Liquidity MA Limit Orders
bool EnableRevLimitOrders = false;        //Enable Reversal Limit Orders
bool EnableSDLimitOrders = false;    //Enable S&D Limit Orders
bool EnableLGrabLimitOrders = false;        //Enable Liquidity Grab Limit Orders

ENUM_TIMEFRAMES PA1TF   = PERIOD_CURRENT; //PA1 Limit Order TF
bool EnablePA1LimitOrders = false;    //Enable PA1 Limit Orders

ENUM_TIMEFRAMES PA2TF   = PERIOD_CURRENT; //PA2 Limit Order TF
bool EnablePA2LimitOrders = false;    //Enable PA2 Limit Orders

ENUM_TIMEFRAMES WedgesTF   = PERIOD_CURRENT; //Wedges Limit Order TF
bool EnableWedgesLimitOrders = false;    //Enable Wedges Limit Orders
bool EnableWedgesProfitZone = false;     //Enable Wedges Limit Profit Zone

bool EnableRSIDLimitOrders = false; //Enable RSI Divergence Limit Orders

string Div0a2              = "*** TOUCH ORDERS ***";//.
bool EnableDirectZMTF     = false;        //Enable Direct ZMTF 4
bool EnableSSMTouchEntry = false;        //Enable SSM Touch Entry
bool EnableZMTFTouchEntry = false;        //Enable ZMTF Touch Entry
bool EnableMACEntry = false;        //Enable MACrossover Entry
bool EnableMACTouch = false;        //Enable MAC Touch
bool EnableVolZoneTouch  = false; //Enable Volume Zone Price Touch
bool EnableLiqTouch = false;        //Enable Liquidity Touch
bool EnableRevTouch = false;        //Enable Reversal Touch
bool EnableSDTouch = false;        //Enable S&D Touch
bool EnablePA1Touch = false;        //Enable PA1 Touch
bool EnablePA2Touch = false;        //Enable PA2 Touch
bool EnableWedgesTouch = false;        //Enable Wedges Touch
bool EnableVolZoneEpochTouch  = true; //Enable EntryCandle 157
bool EnableRSIDTouch = false; //Enable RSI Divergence Touch
bool EnableProfitZoneTouch = false; //Enable Profit Zone Touch
ENUM_TIMEFRAMES PZTF   = PERIOD_M15; //Profit Zone Touch TF
bool PZ_MA_Filter_LogicB    = false;       //PZ MA Filter LogicB
bool EnableLGrabArrowEntry = false;        //Enable Liquidity Grab Arrow Entry

string Div0a3              = "*** CANDLE TYPES ***";//.

//Method 1
string EC_Method1          = "___ METHOD 1 ___";
bool EnableECMethod1       = true;      //Enable EC Method 1
bool EnableECMethod2       = false;      //Enable EC Method 2

bool EnablePowerCandle = false;   //Enable Power Candle



string Div0c              = "*** CHECKPOINT ***";//.
bool EnableVolumeProof = false;        //Enable Volume Proof
bool EnableMarketShift = false;        //Enable Market Shift
int VolCondCount            = 0;          //Count VolProof, MarketShift out of 2 (Reversal false means 0)

string Div0b              = "--- CONFIRMATIONS ---";//.
bool EnableOverallConfirmation = false; //Enable Overall Confirmation for A,B,C
bool EnableDoubleConf         = false;  //Enable Double Confirmation Value [Asian]
int Max_Conf_Expiry           = 240;  //Max Confirmation Expiry in Minutes
int OverAllCount              = 0;     //Overall Confirmation Count

string Div0bz              = "*** A) TREND CONTINUATION INDICATOR  ***";//.
bool EnableLiqConfirmation  = false; //Enable MA Liquidity Confirmation
bool EnableAsianTriggerConf   = false;       //Enable Asian Session Trigger Confirmation
bool EnableLGrabConfirmation = false;        //Enable Liquidity Grab Confirmation

string Div0by              = "*** B) DUAL PURPOSE INDICATOR  ***";//.
bool EnableSSMConfirmation    = false; //Enable SSM Confirmation
bool EnableMACConfirmation    = false; //Enable MACross Confirmation
bool EnableSDConfirmation  = false; //Enable S&D Confirmation
bool EnableWedgesConfirmation = false; //Enable Wedges Confirmation
bool EnableMarketShiftConfirmation = false;        //Enable Market Shift Confirmation

string Div0bx              = "*** C) REVERSAL INDICATOR  ***";//.
bool EnableRevConfirmation  = false; //Enable Reversal MA Confirmation
bool EnableRSIDConfirmation = false; //Enable RSI Divergence Confirmation

bool EnablePA1Confirmation  = false; //Enable PA1 Confirmation
bool EnablePA2Confirmation  = false; //Enable PA2 Confirmation

string Div21              = "--- VOLUME ZONE ---";
bool EnableVolumeZone = false;
bool ShowEpochZones = false;
bool ShowPriceZones = false;
int VolZone_NumberOfDays = 5;
ENUM_TIMEFRAMES VolZone_HFT = PERIOD_H4; //Volume Zone HTF
ENUM_TIMEFRAMES VolZone_LFT = PERIOD_M15; //Volume Zone LTF


double ZoneBufferTPSL    = 15;          //Zone Buffer TP SL
double Buffer            = 0;         //Buffer Points
int MaxMinutes           = 0;     //Maximum Minutes from Init

bool RejectSamePattern   = false;        //Reject Same Pattern Entry
bool EnablePivot         = false;       //Enable Pivot Check
ENUM_TIMEFRAMES MajorTF  = PERIOD_D1;
ENUM_TIMEFRAMES MinorTF  = PERIOD_H4;

string Div2              = "=== ENGULFING SETTINGS ===";
bool EnableEngulfing     = false;       //Enable Engulfing
bool EnableEngulfingWick = true;       //Enable Engulfing Wick
double BodySize1         = 0.75;        //Body size1 above this %

string Div3              = "=== 3BAR SETTINGS ===";
bool Enable3Bar          = false;       //Enable 3 Bar Reversal
bool Enable3BarEnhance   = true;       //Enable 3 Bar Enhance
double BodySize1_3B      = 0.75;        //3B Body size1 above this %

string Div4              = "=== TWEEZER SETTINGS ===";
bool EnableTweezer       = false;       //Enable Tweezer
int RoomToTheLeft        = 6;          //Room To The Left
double AdjustmentLevel   = 0.1;          //Adjustment Level in %
int TweezerCondCheck     = 3;          //How many Tweezer Cond should Check

string Div5              = "=== MULTIPLE WICK SETTINGS ===";
bool EnableMultipleWick  = false;       //Enable Multiple Wick Rejection
double ShadowSize2       = 0.3;//Shadow size above this %

bool EnableThreeSoliders = false;       //Enable Three Soliders
bool EnablePiercing      = false;       //Enable Piercing Pattern
double BodySize1_PP      = 0.75;        //Body size1 PP above this %
string Div6a             = "--- ZIGZAG ---";
bool EnableZigZagMS      = false;       //Enable ZigZag MS
ENUM_TIMEFRAMES ZZ_TF1   = PERIOD_M5;      //TF
int ZZ_Depth1            = 7;                  // Depth
int ZZ_Deviation1        = 6;                   // Deviation
int ZZ_Backstep1         = 4;                   // Backstep
bool ZZ_HL1              = true;                //Base on HL (F=close)
bool EnableZigZagMS2     = false;       //Enable ZigZag MS 2
ENUM_TIMEFRAMES ZZ_TF2   = PERIOD_H1;      //TF2
int ZZ_Depth2            = 12;                  // Depth2
int ZZ_Deviation2        = 5;                   // Deviation2
int ZZ_Backstep2         = 3;                   // Backstep2
bool ZZ_HL2              = true;                //Base on HL (F=close)2
bool IsOR                = true;       //Enable IsOR

string Div6b             = "--- OBOS ---";
bool EnableOBOS          = false;       //Enable OBOS
int OBOS_Period          = 14;
ENUM_TIMEFRAMES OBOS_HTF  = PERIOD_CURRENT;
ENUM_APPLIED_PRICE OBOS_Price = PRICE_TYPICAL;
int OBOS_OB              = 70;          //OBOS OverBought Level
int OBOS_OS              = 30;          //OBOS OverSold Level
bool EnableOBOSSuperTrend    = true;       //Enable OBOS Super Trend
ENUM_TIMEFRAMES ST_OBOS_ConfirmationTF   = PERIOD_H4;    //ST OBOS Confirmation TF
int ST_OBOS_Period            = 10;         //ST Period
double ST_OBOS_Multiplier     = 3;           //ST Multiplier

string Div7              = "--- RSI ---";
bool EnableRSI           = false;       //Enable RSI
int RSI_Period           = 14;
ENUM_TIMEFRAMES RSI_TF1  = PERIOD_M1;
int RSI1_OverAS          = 55;          //RSI1 Above for Sell
int RSI1_OverBB          = 45;          //RSI1 Below for Buy
bool EnableRSI2          = false;       //Enable RSI2
ENUM_TIMEFRAMES RSI_TF2  = PERIOD_M1;
int RSI2_OverAS          = 55;          //RSI2 Above for Sell
int RSI2_OverBB          = 45;          //RSI2 Below for Buy
bool EnableRSI3          = false;       //Enable RSI3
ENUM_TIMEFRAMES RSI_TF3  = PERIOD_M1;
int RSI3_OverAS          = 55;          //RSI3 Above for Sell
int RSI3_OverBB          = 45;          //RSI3 Below for Buy

string Div8              = "--- CHOPPINESS ---";
bool EnableChoppiness    = false;       //Enable Choppiness Index
int CI_Period            = 14;
double CI_TriggerLevel   = 61.8;          //CI Trigger Level
ENUM_TIMEFRAMES CI_TF1   = PERIOD_M15;

string Div9              = "--- VORTEX ---";
bool EnableVortex        = false;       //Enable Vortex
int VI_Period            = 14;
ENUM_TIMEFRAMES VI_TF1   = PERIOD_M15;
double VI_TriggerLevel   = 1.1;          //VI Trigger Level
bool EnableVortexExit    = false;

string Div10              = "--- SUPER TREND ---";
bool EnableSuperTrend    = false;       //Enable Super Trend
ENUM_TIMEFRAMES ST_ConfirmationTF   = PERIOD_M15;    //ST Confirmation TF
int ST_Period            = 10;         //ST Period
double ST_Multiplier     = 2;           //ST Multiplier
bool EnableST_LowerTF        = false;      //Enable ST Lower TF
ENUM_TIMEFRAMES ST_LowerTF   = PERIOD_M15;   //ST Lower TF
int ST_LowerPeriod            = 8;         //ST Lower Period
double ST_LowerMultiplier     = 1.75;           //ST Lower Multiplier
bool EnableST_MiddleTF       = false;      //Enable ST Middle TF
ENUM_TIMEFRAMES ST_MiddleTF  = PERIOD_H1;    //ST Middle TF
int ST_MiddlePeriod            = 8;         //ST Middle Period
double ST_MiddleMultiplier     = 1.75;           //ST Middle Multiplier
bool EnableST_HigherTF       = false;      //Enable ST Higher TF
ENUM_TIMEFRAMES ST_HigherTF  = PERIOD_H4;    //ST Higher TF
int ST_HigherPeriod            = 8;         //ST Higher Period
double ST_HigherMultiplier     = 1.75;           //ST Higher Multiplier
bool EnableSTExit        = false;             //Enable Exit TF
ENUM_TIMEFRAMES ST_ExitTF   = PERIOD_M15;    //ST Exit TF
int ST_ExitPeriod            = 8;         //ST Exit Period
double ST_ExitMultiplier     = 1.75;           //ST Exit Multiplier

string Div11              = "--- MA ---";
bool EnableMA            = false;       //Enable MA
int MA_Period            = 9;          //MA Period
ENUM_APPLIED_PRICE MA_Price = PRICE_CLOSE;
ENUM_MA_METHOD MA_Method = MODE_EMA;
ENUM_TIMEFRAMES MA_TF1   = PERIOD_M1;
bool ConsiderOpen        = false;       //Consider Open
bool EnableMA2            = false;       //Enable MA2
int MA_Period2            = 20;          //MA Period2
ENUM_APPLIED_PRICE MA_Price2 = PRICE_CLOSE;
ENUM_MA_METHOD MA_Method2 = MODE_EMA;
ENUM_TIMEFRAMES MA_TF2   = PERIOD_M1;
bool ConsiderOpen2        = false;       //Consider Open2
bool EnableMACrossover   = false;       //Enable MA Crossover
ENUM_APPLIED_PRICE MA_CO_Price = PRICE_CLOSE;
ENUM_MA_METHOD MA_CO_Method = MODE_EMA;
ENUM_TIMEFRAMES MA_CO_TF1   = PERIOD_M1;
int MA_CO_Period1        = 20;          //MA Crossover Fast Period
int MA_CO_Period2        = 50;          //MA Crossover Slow Period
bool EnableMAArrow       = false;       //Enable MA Arrow

string Div11a              = "--- MA Arrow Dynamic ---";
bool EnableMAArrowDyn      = false;       //Enable MA Arrow Dynamic
bool EnableMADCI             = false;
int MAAD_CI_Period            = 14;
double MAAD_CI_TriggerLevel   = 61.8;          //MAAD CI Trigger Level
ENUM_TIMEFRAMES MAAD_CI_TF1   = PERIOD_M15;
bool EnableMADRSI             = false;
int MAAD_RSI_Period           = 14;
ENUM_TIMEFRAMES MAAD_RSI_TF1  = PERIOD_M1;
int MAAD_RSI1_OverAS          = 55;          //MAAD RSI1 Above for Sell
int MAAD_RSI1_OverBB          = 45;          //MAAD RSI1 Below for Buy


string Div12              = "--- RANGE CHECK  ---";
bool EnableRangeCheck    = false;       //Enable Range Check
int ATRPeriod            = 14;
double ATRMultiplier     = 25;
bool EnableReverseATR    = false;
double ATRSLMultiplier   = 1.75;           //ATR SL Multiplier
ENUM_TIMEFRAMES ATRSLTF  = PERIOD_M1;    //ATR SL Timeframe

bool EnableHighLowSL     = true;   //Enable High Low Candle for SL

string Div13              = "--- VOLUME ---";
bool EnableVolCheck      = false;       //Enable Volume Check
int VolPeriod            = 9;
double VolThreshold      = 1.1;
bool EnableVolMeter      = false;       //Enable Volume Meter
ENUM_SHOW_SIGNALS ShowVolDirection = SHOW_BOTH; //Show Vol Direction
ENUM_TIMEFRAMES VolTF1   = PERIOD_M15; //Timeframe TF1
int VSM_VolPeriod        = 14;
double VSM_VolThreshold  = 1.1;
ENUM_LOGIC_MODE VolLogic = LBOTH; //Vol Logic
bool EnableVTF2          = false; //Enable VT2
ENUM_TIMEFRAMES VTF2      = PERIOD_M30; // VTF2
bool EnableVTF3          = false; //Enable VTF3
ENUM_TIMEFRAMES VTF3      = PERIOD_H1; // VTF3
bool EnableVTF4          = false; //Enable VTF4
ENUM_TIMEFRAMES VTF4      = PERIOD_H1; // VTF4
bool ShowAll            = false; // Show All Currencies
int VolValueAboveBelow     = 3; //Vol Volume Above/Below
bool ShowLevel2 = true; //Show Level2
ENUM_TIMEFRAMES Level2TF = PERIOD_M5; //Level2 Timeframe

string Div14              = "--- CURRENCY STREGTH ---";
bool EnableCS             = false;       //Enable Currency Strength
bool ConsiderZero         = true;       //Consider Zero for Entry

//SHOW_ALL is now replaced because of not used
ENUM_SHOW_SIGNALS DisplayBuySell = SHOW_BOTH; //Display Buy/Sell Signals
int MAFast = 9; //MA Period Fast
int MASlow = 21; //MA Period Slow
ENUM_MA_METHOD MAType = MODE_EMA; //MA Type
ENUM_TIMEFRAMES TF1  = PERIOD_M15; // TF1
bool EnableMTF = false; //Enable MTF Strength
ENUM_TIMEFRAMES TF2  = PERIOD_M30; // TF2
bool EnableTF3 = false; //Enable TF3
ENUM_TIMEFRAMES TF3  = PERIOD_H1; // TF3
bool EnableTF4 = false; //Enable TF4
ENUM_TIMEFRAMES TF4  = PERIOD_H1; // TF4
ENUM_STRENGTH_CALC MtfStrengthCalc = SAME_STRENGTH; //MTF Strength Calculation
int ValueAboveBelow = 2; //Values Above/Below sStrength Level
int ValueAboveBelowMTF = 4; //Values Above/Below MTF Strength Level

string Div15              = "--- FCM ---";
bool EnableFCM            = false;       //Enable FCM
string FCM_TF1            = "Current time frame"; //FCM TF1
bool EnableFCM2           = false;       //Enable FCM2
string FCM_TF2            = "Current time frame"; //FCM TF2
int FCM_Method            = 3;
int FCM_Fast              = 3;          //FCM Fast
int FCM_Slow              = 5;          //FCM Slow
int FCM_Price             = 6;
double LevelUp2           = 0.7;
double LevelUp1           = 0.2;
double LevelDn1           = -0.2;
double LevelDn2           = -0.7;
int StartPos              = 85;
int ReRunTimeSec          = 10;
int mn_per                = 12;
int mn_fast               = 3;
int w_per                 = 9;
int w_fast                = 3;
int d_per                 = 5;
int d_fast                = 3;
int h4_per                = 16;
int h4_fast               = 5;
int h1_per                = 18;
int h1_fast               = 5;
int m30_per               = 16;
int m30_fast              = 2;
int m15_per               = 16;
int m15_fast              = 4;
int m5_per                = 10;
int m5_fast               = 3;
int m1_per                = 30;
int m1_fast               = 10;
bool Interpolate          = false;

struct stc_text_file
  {
   string            symbol;
   datetime          lastBuyFile;
   datetime          lastSellFile;
  };
string symbols[28]= { "EURUSD","GBPUSD","AUDUSD","USDJPY","USDCHF","USDCAD","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","GBPJPY","GBPCHF","NZDUSD","AUDCAD","AUDJPY","CHFJPY","AUDNZD","NZDJPY","NZDCAD","NZDCHF","GBPNZD","EURNZD","GBPCAD","GBPAUD","AUDCHF","CADCHF","CADJPY" };
datetime lastCandlePair[28]= {0};
stc_text_file textFiles[28];

string Div16              = "--- SSM & ZoneTouch ---";
bool EnableSSM      = false; //Enable SSM
int SSM_Trigger_Expiry     = 60; // SSM Trigger Expiry in Minutes

//confirmation
string Div16a              = "--- SSM Conf ---";
ENUM_TIMEFRAMES SSM_ConfTF    = PERIOD_M5; //SSM Confirmation Timeframe

bool EnableZOEManConf         = false; //Enable Zone Outside Entry Conf [Mandatory]
bool EnableChoppinessManConf  = false; //Enable Choppiness Conf [Mandatory]
int TotalCountCondConf        = 3; //Total SSM Conf Count Condition out of 5
double VolThresholdEntryConf  = 1; //Vol Threshold Entry Conf

//Entry
string Div16b                 = "--- SSM Entry ---";
bool EnableZOEMan             = false; //Enable Zone Outside Entry [Mandatory]
bool EnableChoppinessMan      = false; //Enable Choppiness [Mandatory]
int TotalCountCond            = 3; //Total SSM Count Condition out of 5
bool EnableZOE                = false; //Enable Zone Outside Entry
bool EnableAbsorption         = false; //Enable Absorption
ENUM_TIMEFRAMES Ab_TF         = PERIOD_CURRENT; //Absorption Timeframe
double Ab_BodySize            = 0.75;
double AbCandlePerct = 0.5;        //Candle below Close %
bool EnableVolCheckEntry      = true;       //Enable Volume Check Entry
int VolPeriodEntry            = 14;
double VolThresholdEntry      = 1;
bool EnableSSMChoppiness    = true;       //Enable Choppiness Index
int SSM_CI_Period            = 14;
double SSM_CI_TriggerLevel   = 60;          //SSM CI Trigger Level
ENUM_TIMEFRAMES SSM_CI_TF1   = PERIOD_CURRENT;    //SSM CI TF


bool EnableSSMStopOrder = false; //Enable SSM Stop Order
bool EnableSSMChrono      = false; //Enable SSM Chronological
bool EnableSSMCandle      = false; //Enable SSM Candlestick
int SSM_CandleValue     = 3; // SSM Candle Value
bool EnableSSMShiftCandle      = false; //Enable SSM Shift Candlestick
int SSM_ShiftCandleValue     = 3; // SSM Shift Candle Value
bool EnableSSMZoneMTF = false; //Enable SSM ZoneMTF
bool EnableSSMZoneTouch = false; //Enable SSM Zone Touch

bool ShowLastZone = false; //Show SSM Last Zone Only
ENUM_SHOW_SIGNALS ShowDirection = SHOW_BOTH; //Show Direction
ENUM_TIMEFRAMES SSM_TF1 = PERIOD_M5; //SSM Timeframe
bool EnableSSM_HTF          = false; //Enable SSM HTF
ENUM_TIMEFRAMES SSM_TF2 = PERIOD_H1; //Timeframe HTF
int SSM_InpDepth=7; // Depth
int SSM_InpDeviation=6; // Deviation
int SSM_InpBackstep=5; // Backstep
bool SSM_zz_hl = false; // Base on HL (F=close)
double Percentage1 = 100; //P1%
double Percentage2 = 110; //P2%
int SSM_ValueAboveBelow = 3; //SSM Values Above/Below
bool ExtraShiftZones = false; //Extra Shift Zones
bool SSM_EnableSuperTrend    = false;       //SSM Enable Super Trend
ENUM_TIMEFRAMES SSM_ST_ConfirmationTF   = PERIOD_H4;    //ST Confirmation TF
int SSM_ST_Period            = 10;         //ST Period
double SSM_ST_Multiplier     = 3;           //ST Multiplier
double BreachPercentage = 25; //Zonetouch Breach %
double ExtendPercentage = 12.5; //Zonetouch Extend %

string Div16c             = "--- SSM Exit ---";
bool EnableSSMExit = false; //Enable SSM Exit
ENUM_TIMEFRAMES SSM_ExitTF = PERIOD_CURRENT; //SSM Exit Timeframe
int TotalCountCondExit = 3; //Total Count Condition out of 5 Exit
bool EnableZOEManExit = false; //Enable Zone Outside Entry [Mandatory] Exit
bool EnableChoppinessManExit = false; //Enable Choppiness Exit [Mandatory]
bool EnableZoneTouchExit = true; //Enable Zone Touch Exit
bool EnableZOEExit = true; //Enable Zone Outside Entry  Exit
bool EnableAbsorptionExit = true; //Enable Absorption Exit
ENUM_TIMEFRAMES Ab_TF_Exit = PERIOD_CURRENT; //Absorption Timeframe Exit
double Ab_BodySize_Exit = 0.75;
double AbCandlePerct_Exit = 0.5;        //Candle below Close % Exit
bool EnableVolCheckExit      = true;       //Enable Volume Check Exit
int VolPeriod_Exit            = 14;
double VolThreshold_Exit      = 1.1;
int SSM_InpDepthExit=5; // Depth Exit
int SSM_InpDeviationExit=4; // Deviation Exit
int SSM_InpBackstepExit=3; // Backstep Exit
bool SSM_zz_hlExit = false; // Base on HL (F=close) Exit
double Percentage1Exit = 100; //P1% Exit
double Percentage2Exit = 110; //P2% Exit
int SSM_ValueAboveBelowExit = 3; //SSM Values Above/Below Exit
double BreachPercentageExit = 25; //Breach % Exit
double ExtendPercentageExit = 12.5; //Extend % Exit
bool EnableSSMVolumeZone = false;   //Enable SSM Volume Zone Exit
int SSMVolZone_NumberOfDays = 5;
ENUM_TIMEFRAMES SSMVolZone_HFT = PERIOD_D1; //Volume Zone HTF
ENUM_TIMEFRAMES SSMVolZone_LFT = PERIOD_H4; //Volume Zone LTF

string Div20c             = "--- Range Exit ---";
bool EnableRangeExit = false; //Enable Range Exit

double MWN1=3;//Minimum Weightage Needed
direction dir1=OverAll;//Direction
double SwingMinTrend1=12.50;//Trend Follow
double SwingMinShift1=10;//Market Shift
int CVBTF1=12; //Confirmation Validity Trend Follow Bars
int CVBMS1=24; //Confirmation Validity Market Shift Bars
int ZoneValidityBars1 = 24;// Zone Validity Bars
int MaxConfirmationArrow1 =5;//Max Confirmation Arrow per Day
ENUM_TIMEFRAMES RSITimeFrame1 = PERIOD_M15;//RSI Period
bool EnableCRC11 = true;//Enable CRC
string TrendReversalZone = "================ TrendReversal Zones Properties ================"; //=================
bool EnableTrendReversalZone = true;//Enable Trend Reversal ?
double SwingMinReversal = 10;//Minimum % of ADR needed
int SwingMaxBars = 16;//Maximum no of bars in swing
bool ValidateBothSwings = true;//Validation in Both swings ?
int CVBTR = 24;//Confirmation Validity for Trend Reversal
bool MidSwing_HH_LL = true;//Middle Swing Needs to be HH & LL ?
ENUM_TIMEFRAMES RangeIndicatorTimeFrame = PERIOD_M5;//Range Indicator TimeFrame

string Div18              = "--- ZONEMTF ---";
bool EnableZoneMTF       = false;        //Enable Zone MTF
bool EnableZMTF_ZOEMan = false; //Enable ZMTF Zone Outside Entry [Mandatory]
bool EnableZMTF_ChoppinessMan = true; //Enable ZMTF Choppiness [Mandatory]
int ZMTF_TotalCountCond = 0; //ZMTF Total Count Condition out of 5
bool EnableZMTF_ZoneTouch     = false;        //Enable ZMTF Zone Touch
ENUM_TIMEFRAMES ZMTF_TF1 = PERIOD_M1; //ZoneMTF Timeframe 1
ENUM_TIMEFRAMES ZMTF_TF2 = PERIOD_M5; //ZoneMTF Timeframe 2
ENUM_TIMEFRAMES ZMTF_TF3 = PERIOD_M15; //ZoneMTF Timeframe 3
ENUM_TIMEFRAMES ZMTF_TF4 = PERIOD_H1; //ZoneMTF Timeframe 4
double SumupValue = 3;     // Sum up Value
double LTFExtendPercentage = 12.5; //LTF Extend %
double MTFExtendPercentage = 12.5; //MTF Extend %
double HTFExtendPercentage = 12.5; //HTF Extend %
double STFExtendPercentage = 12.5; //STF Extend %
int ZMTF_MaxBars_Tf1 = 15000; //Max Bars TF1 ( 0 means infinite )
int ZMTF_MaxBars_Tf2 = 3000; //Max Bars TF2 ( 0 means infinite )
int ZMTF_MaxBars_Tf3 = 1000; //Max Bars TF3 ( 0 means infinite )
int ZMTF_MaxBars_Tf4 = 250; //Max Bars TF4 ( 0 means infinite )

string Div19              = "--- MAC Conf & Entry ---";
ENUM_TIMEFRAMES MAC_ConfTF    = PERIOD_M5; //MAC Confirmation Timeframe
bool EnableMACZigZagMan = false; //Enable MAC ZigZag [Mandatory]
bool EnableMACZOEMan = false; //Enable MAC Zone Outside Entry [Mandatory]
int MAC_TotalCountCond = 4; //MAC Total Count Condition out of 6
double MAC_VolThresholdConf = 1.0; //MAC Vol Threashold Confirmation
double MAC_VolThresholdEntry = 1.0; //MAC Vol Threashold Entry

string Div20              = "--- Asian Session ---";//==========================
bool EnableAsianSession   = false;       //Enable Asian Session only inside the AS Zone
bool EnableAsianTrigger   = false;       //Enable Asian Session Trigger
bool EnableOneDir =  false;//Enable Asian One Direction
ENUM_TIMEFRAMES Asian_TF = PERIOD_CURRENT; //Asian Session Timeframe
bool EnableAsianTarget = false;       //Enable Asian Session Target
int Asian_TargetNumber        = 1;   //Asian Target Number
string Asian_Last_Time         = "15:00:00"; //Asian Last Time


string Div21a              = "--- Volume Zone Confirmation ---";
bool EnableVolZoneConfirmation  = false; //Enable Volume Zone Confirmation
int VolZoneConf_NumberOfDays = 5;
ENUM_TIMEFRAMES VolZoneConf_HFT = PERIOD_H4; //Volume Zone HTF
ENUM_TIMEFRAMES VolZoneConf_LFT = PERIOD_M15; //Volume Zone LTF
bool BreachLogicBasedOnEntries = true;
double BreachLogicBasedOnEntries_Percent = 25;
ENUM_TIMEFRAMES VolZone_RSI_Timeframe = PERIOD_CURRENT;
ENUM_APPLIED_PRICE VolZone_RSI_AppliedPrice = PRICE_CLOSE;
uint VolZone_RSI_Period = 14;
bool VolZone_UseRSIFilter = false;
int VolZone_RSI_BuyLevel = 65;
int VolZone_RSI_SellLevel = 35;

string Div22              = "--- Liquidity MA ---";
ENUM_TIMEFRAMES Liq_ConfTF    = PERIOD_M5; //Liquidity MA Confirmation Timeframe
bool EnableLiqMajMAMan = false; //Enable Liquidity Major MA [Mandatory]
bool EnableLiqZigZagMan = false; //Enable Liquidity ZigZag [Mandatory]
bool EnableLiqZOEMan = false; //Enable Liq Zone Outside Entry [Mandatory]
int Liq_TotalCountCond = 4; //Liquidity MA Total Count Condition out of 6
double Liq_VolThreshold      = 1.0;

string Div23              = "--- Reversal MA ---";
ENUM_TIMEFRAMES Rev_ConfTF    = PERIOD_M5; //Reversal MA Confirmation Timeframe
bool EnableRevZOEMan = false; //Enable Rev Zone Outside Entry [Mandatory]
int RevMA_TotalCountCond = 3; //Reversal MA Total Count Condition out of 4
double RevMA_VolThreshold      = 1.0;

string Div25             = "--- Volume Proof ---";
bool ConsiderVolumeProofTiming = false;        //Consider Volume Proof Timing
int VolProof_NumberOfDays = 5;
bool LogicA = true;
Enum_LogicConfirmation Confirmation_LogicA = Confirmation1;
bool LogicB = true;
Enum_LogicConfirmation Confirmation_LogicB = Confirmation2;
Enum_RSI_Type RSI_Type = RSI_Direct;

bool VP_UseADRPipsFilter = true;
int VP_ADR_Period = 5;
int VP_ADR_MinRatio_Percent = 10;

bool VP_EnableMA            = true;       //Enable MA
int VP_MA_CO_Period1        = 20;          //VP MA Fast Period
int VP_MA_CO_Period2        = 50;          //VP MA Slow Period
ENUM_APPLIED_PRICE VP_MA_CO_Price = PRICE_CLOSE;
ENUM_MA_METHOD VP_MA_CO_Method = MODE_EMA;
ENUM_TIMEFRAMES VP_MA_TF1   = PERIOD_H1;
bool MA_Filter_LogicA    = true;       //VP MA Filter LogicA
bool MA_Filter_LogicB    = false;       //VP MA Filter LogicB

int VP_EC_Type1_ConfirmationMin = 180; //VP EC Type1 Confirmation Minute
int VP_EC_Type2_ConfirmationMin = 360; //VP EC Type2 Confirmation Minute


string Div26             = "--- Volume Proof Exit ---";
bool EnableVolumeProofExit = false;        //Enable Volume Proof Exit
bool LogicAexit = true;
Enum_LogicConfirmation Confirmation_LogicAexit = Confirmation3;
bool LogicBexit = true;
Enum_LogicConfirmation Confirmation_LogicBexit = Confirmation3;
Enum_RSI_Type RSI_TypeExit = RSI_Inverse;

bool VPE_UseADRPipsFilter = true;
int VPE_ADR_Period = 5;
int VPE_ADR_MinRatio_Percent = 10;

string Div27             = "--- RSI Divergence ---" ;
bool EnableRSIDZOEMan = false; //Enable RSID Zone Outside Entry [Mandatory]
bool Swing2_HH_LL = true;
bool Swing3_HH_LL = true;

string Div28       = "--- Power Candle ---";
bool EnablePCVolumeProof = false;        //Enable Power Candle Volume Proof
ENUM_TIMEFRAMES PC_ZZ_TF1   = PERIOD_M5;//PC Zigzag Timeframe
ENUM_TIMEFRAMES PC_CI_TF1   = PERIOD_M5;     //PC Choppiness TF
ENUM_TIMEFRAMES PC_PZTF   = PERIOD_M15;      //PC Profit Zone TF
bool PC_MA_Filter_LogicB    = true;       //PC MA Filter LogicB


string Div29       = "--- Market Shift ---";//==========================
bool EnableMarketShiftConfMan = false;        //Enable Market Shift Confirmation [Mandatory]
ENUM_TIMEFRAMES MS_RSI_Timeframe1 = PERIOD_M15;
ENUM_TIMEFRAMES MS_RSI_Timeframe2 = PERIOD_M5;
//int MS_ConfirmationValidInMinutes = 60;
//bool MS_TimingOn = false;
//string MS_TimingOn_StartTime = "1:00";
int MS_CountCondition      = 2; //MS Count Condition out of 3
//bool MS_PrevSwingMustBeHHorLL = true;

string Div30       = "--- Market Shift Exit ---";
bool EnableMarketShiftExit = false;        //Enable Market Shift Exit
int MS_CountConditionExit      = 3; //MS Count Condition Exit out of 3


string Div31        = "---- Liquidity Grab ---";
ENUM_TIMEFRAMES LG_ETF     = PERIOD_M5; //LG EntryTF
ENUM_TIMEFRAMES LG_HTF         = PERIOD_M15;//LG HigherTF
MethodCandle CandleMethod = UseClose;
int LG_ConfirmationValidInMinutes = 240;  //LG Trigger2 Conf Validity in Minutes
bool LG_NoTradeBuffer = false;   //LG No Trade Buffer

string Div32        = "---- Swing Stops ---";//==========================
bool EnableVolatileSwingFilteration = true;//Enable Volatile Swings Filtration:
bool EnableSwingSpeedFilteration = true;//Enable Swing Speed Filteration:
int NumberOfFiltersNeeded = 1;//Number of Filters needed
string Div32a        = "___ Swing Stops - Method 1 ___";//==========================
ENUM_TIMEFRAMES SS_M1_ETF     = PERIOD_M5; //SS M1 EntryTF
ENUM_TIMEFRAMES SS_M1_HTF         = PERIOD_M15;//SS M1 HigherTF
ENUM_TIMEFRAMES SS_M1_RSITF         = PERIOD_M5;//SS M1 RSI TF
ENUM_TIMEFRAMES SS_M1_RSITFE  = PERIOD_M5;//SS M1 RSI Entry TF
MethodCandle SS_M1_CandleMethod = UseWick;
int SS_M1_Trig1ScanValidInMinutes = 15;  //SS M1 Trigger1 Scanner Validity in Bars
int SS_M1_T1ConfirmationValidInMinutes = 30;  //SS M1 Trigger1 Conf Validity in Bars
int SS_M1_T2ConfirmationValidInMinutes = 45;  //SS M1 Trigger2 Conf Validity in Bars
int SS_M1_RefLineValidInMinutes = 90;  //SS M1 Reference Line Validity in Bars
//input bool SS_M1_NoTradeBuffer = false;   //SS M1 No Trade Buffer
bool SS_M1_UseHL_LH_Ref = true;   //SS M1 Use HL LH Ref Points
double SS_M1_ExtendPercentageRef = 15; //Reference Line Extend %
double SS_M1_ExtendPercentageDummy = 15; //Dummy Line Extend %
double SS_M1_ExtendPercentageEntry = 15; //Entry Line Extend %
bool SS_M1_EnableMarketShift  = false;  //Enable SS M1 Market Shift Filteration
int SS_M1_MS_CountCondition      = 1; //SS M1 MS Count Condition out of 3
bool SS_M1_MS_PrevSwingMan = false; //SS M1 Previous Swing [Mandatory]


string Div32b        = "___ Swing Stops - Method 2 ___";//==========================
ENUM_TIMEFRAMES SS_M2_ETF     = PERIOD_M5; //SS M2 EntryTF
ENUM_TIMEFRAMES SS_M2_HTF         = PERIOD_M5;//SS M2 HigherTF
ENUM_TIMEFRAMES SS_M2_RSITF         = PERIOD_M5;//SS M2 RSI TF
ENUM_TIMEFRAMES SS_M2_RSITFE  = PERIOD_M5;//SS M2 RSI Entry TF
MethodCandle SS_M2_CandleMethod = UseWick;
int SS_M2_Trig1ScanValidInMinutes = 15;  //SS M2 Trigger1 Scanner Validity in Bars
int SS_M2_T1ConfirmationValidInMinutes = 30;  //SS M2 Trigger1 Conf Validity in Bars
int SS_M2_T2ConfirmationValidInMinutes = 45;  //SS M2 Trigger2 Conf Validity in Bars
int SS_M2_RefLineValidInMinutes = 60;  //SS M2 Reference Line Validity in Bars
//input bool SS_M2_NoTradeBuffer = false;   //SS M2 No Trade Buffer
bool SS_M2_UseHL_LH_Ref = false;   //SS M2 Use HL LH Ref Points
double SS_M2_ExtendPercentageRef = 20; //Reference Line Extend %
double SS_M2_ExtendPercentageDummy = 20; //Dummy Line Extend %
double SS_M2_ExtendPercentageEntry = 20; //Entry Line Extend %
bool SS_M2_EnableMarketShift  = true;  //Enable SS M2 Market Shift Filteration
int SS_M2_MS_CountCondition      = 1; //SS M2 MS Count Condition out of 3
bool SS_M2_MS_PrevSwingMan = false; //SS M2 Previous Swing [Mandatory]


string Div32c        = "___ Swing Stops - Method 3 ___";//==========================
ENUM_TIMEFRAMES SS_M3_ETF     = PERIOD_M5; //SS M2 EntryTF
ENUM_TIMEFRAMES SS_M3_HTF         = PERIOD_M15;//SS M2 HigherTF
ENUM_TIMEFRAMES SS_M3_RSITF         = PERIOD_M5;//SS M2 RSI TF
ENUM_TIMEFRAMES SS_M3_RSITFE  = PERIOD_M5;//SS M2 RSI Entry TF
MethodCandle SS_M3_CandleMethod = UseWick;
int SS_M3_Trig1ScanValidInMinutes = 15;  //SS M2 Trigger1 Scanner Validity in Bars
int SS_M3_T1ConfirmationValidInMinutes = 30;  //SS M2 Trigger1 Conf Validity in Bars
int SS_M3_T2ConfirmationValidInMinutes = 45;  //SS M2 Trigger2 Conf Validity in Bars
int SS_M3_RefLineValidInMinutes = 60;  //SS M2 Reference Line Validity in Bars
//input bool SS_M3_NoTradeBuffer = false;   //SS M2 No Trade Buffer
bool SS_M3_UseHL_LH_Ref = false;   //SS M2 Use HL LH Ref Points
double SS_M3_ExtendPercentageRef = 15; //Reference Line Extend %
double SS_M3_ExtendPercentageDummy = 15; //Dummy Line Extend %
double SS_M3_ExtendPercentageEntry = 15; //Entry Line Extend %
bool SS_M3_EnableMarketShift  = false;  //Enable SS M2 Market Shift Filteration
int SS_M3_MS_CountCondition      = 1; //SS M2 MS Count Condition out of 3
bool SS_M3_MS_PrevSwingMan = false; //SS M2 Previous Swing [Mandatory]

string Div32bd        = "___ Swing Stops - Method 4 ___";//==========================
ENUM_TIMEFRAMES SS_M4_ETF     = PERIOD_M5; //SS M2 EntryTF
ENUM_TIMEFRAMES SS_M4_HTF         = PERIOD_M5;//SS M2 HigherTF
ENUM_TIMEFRAMES SS_M4_RSITF         = PERIOD_M5;//SS M2 RSI TF
ENUM_TIMEFRAMES SS_M4_RSITFE  = PERIOD_M5;//SS M2 RSI Entry TF
MethodCandle SS_M4_CandleMethod = UseWick;
int SS_M4_Trig1ScanValidInMinutes = 10;  //SS M2 Trigger1 Scanner Validity in Bars
int SS_M4_T1ConfirmationValidInMinutes = 15;  //SS M2 Trigger1 Conf Validity in Bars
int SS_M4_T2ConfirmationValidInMinutes = 30;  //SS M2 Trigger2 Conf Validity in Bars
int SS_M4_RefLineValidInMinutes = 45;  //SS M2 Reference Line Validity in Bars
//input bool SS_M4_NoTradeBuffer = false;   //SS M2 No Trade Buffer
bool SS_M4_UseHL_LH_Ref = true;   //SS M2 Use HL LH Ref Points
double SS_M4_ExtendPercentageRef = 20; //Reference Line Extend %
double SS_M4_ExtendPercentageDummy = 20; //Dummy Line Extend %
double SS_M4_ExtendPercentageEntry = 20; //Entry Line Extend %
bool SS_M4_EnableMarketShift  = false;  //Enable SS M2 Market Shift Filteration
int SS_M4_MS_CountCondition      = 1; //SS M2 MS Count Condition out of 3
bool SS_M4_MS_PrevSwingMan = false; //SS M2 Previous Swing [Mandatory]


string Div32e        = "___ Swing Stops - Method 5 ___";//==========================
ENUM_TIMEFRAMES SS_M5_ETF     = PERIOD_M5; //SS M5 EntryTF
ENUM_TIMEFRAMES SS_M5_HTF         = PERIOD_M5;//SS M5 HigherTF
ENUM_TIMEFRAMES SS_M5_RSITF         = PERIOD_M5;//SS M5 RSI TF
ENUM_TIMEFRAMES SS_M5_RSITFE  = PERIOD_M5;//SS M5 RSI Entry TF
MethodCandle SS_M5_CandleMethod = UseWick;
int SS_M5_Trig1ScanValidInMinutes = 5;  //SS M5 Trigger1 Scanner Validity in Bars
int SS_M5_T1ConfirmationValidInMinutes = 10;  //SS M5 Trigger1 Conf Validity in Bars
int SS_M5_T2ConfirmationValidInMinutes = 15;  //SS M5 Trigger2 Conf Validity in Bars
int SS_M5_RefLineValidInMinutes = 30;  //SS M5 Reference Line Validity in Bars
//input bool SS_M5_NoTradeBuffer = false;   //SS M5 No Trade Buffer
bool SS_M5_UseHL_LH_Ref = false;   //SS M5 Use HL LH Ref Points
double SS_M5_ExtendPercentageRef = 20; //Reference Line Extend %
double SS_M5_ExtendPercentageDummy = 20; //Dummy Line Extend %
double SS_M5_ExtendPercentageEntry = 20; //Entry Line Extend %
bool SS_M5_EnableMarketShift  = false;  //Enable SS M5 Market Shift Filteration
int SS_M5_MS_CountCondition      = 1; //SS M5 MS Count Condition out of 3
bool SS_M5_MS_PrevSwingMan = false; //SS M5 Previous Swing [Mandatory]



//================================================================================================================================
//bool PartialClosing = true;
input int MinBar = 100;
bool EnableStoploss = true;
//input double Stoploss = 100.0;
//input int Trailing_SL = 50;
int slip = 3;
//bool EnableMartingle = false;

//bool EnablePullback = true;


input string hint156="------------- Copy Trading Receiver -------------";//==========================

input bool  Enable_EA_as_Copytrading_Receiver=false;//Enable EA as Copytrading Receiver
input int Magic_Number_to_Copy=123;//Magic Number to Copy
input string Trade_Comments_to_Copy="AAA,BBB,CCC,DDD,EEE";//Trade Comments to Copy
input string Risk_Percentage_for_Trade_Comments="2,1.5,1.25,1,0.75";//Risk Percentage for Trade Comments
input string Stop_Loss_CRC_for_Trade_Comments="75,90,105,120,135";//Stop Loss CRC for Trade Comments
input string Reward_Percent_for_Trade_Comments="15,12,10,8,6";//Reward Percent for Trade Comments
input string Stop_Loss_Stacking_Time_for_Trade_Comments="10,15,20,25,30";//Stop Loss Stacking Time for Trade Comments
input string Limit_Order_Stacking_Time_for_Trade_Comments="5,10,15,20,25";//Limit Order Stacking Time for Trade Comments
input string Trade_Comments_for_Trade_Comments="AAA,BBB,CCC,DDD,EEE";//Trade Comments for Copy Orders




input string hint157="------------- Receiver Pair Selection -------------";//==========================

enum AllowedTypes
  {
   All,
   Buy1,//Buy
   Sell1,//Sell
   AllSADR,
   BuySADR,
   SellSADR,
   None
  };

input AllowedTypes AUDCAD_Allow=None;//AUDCAD
input AllowedTypes AUDCHF_Allow=None;//AUDCHF
input AllowedTypes AUDJPY_Allow=None;//AUDJPY
input AllowedTypes AUDNZD_Allow=None;//AUDNZD
input AllowedTypes AUDUSD_Allow=None;//AUDUSD
input AllowedTypes CADCHF_Allow=None;//CADCHF
input AllowedTypes CADJPY_Allow=None;//CADJPY
input AllowedTypes CHFJPY_Allow=None;//CHFJPY
input AllowedTypes EURAUD_Allow=None;//EURAUD
input AllowedTypes EURCAD_Allow=None;//EURCAD
input AllowedTypes EURCHF_Allow=None;//EURCHF
input AllowedTypes EURGBP_Allow=None;//EURGBP
input AllowedTypes EURJPY_Allow=None;//EURJPY
input AllowedTypes EURNZD_Allow=None;//EURNZD
input AllowedTypes EURUSD_Allow=None;//EURUSD
input AllowedTypes GBPAUD_Allow=None;//GBPAUD
input AllowedTypes GBPCAD_Allow=None;//GBPCAD
input AllowedTypes GBPCHF_Allow=None;//GBPCHF
input AllowedTypes GBPJPY_Allow=None;//GBPJPY
input AllowedTypes GBPNZD_Allow=None;//GBPNZD
input AllowedTypes GBPUSD_Allow=None;//GBPUSD
input AllowedTypes NZDCAD_Allow=None;//NZDCAD
input AllowedTypes NZDCHF_Allow=None;//NZDCHF
input AllowedTypes NZDJPY_Allow=None;//NZDJPY
input AllowedTypes NZDUSD_Allow=None;//NZDUSD
input AllowedTypes USDCAD_Allow=None;//USDCAD
input AllowedTypes USDCHF_Allow=None;//USDCHF
input AllowedTypes USDJPY_Allow=None;//USDJPY


struct cmnt
  {
   string            cmnt;
   double            pr;
   int               StopLossCRC2;
   double            RewardPercent2;
   int               StopLossStackingTime2;
   int               LimitOrderStackingTime2;
   string            CopyOrderComment2;
  };

cmnt CommentList[];


string trend="",cur_Signal="",EA_Name=EAID;
double Old_Price,tprofit,oprofit,lot_size,EntryPrice,tp;
int digits = 2,i_cond;
double tf_close,tf_open;
bool allow_trade = false,allow_grid_trade= false,allow_pullback_trade=false,allow_ssmlimit_trade=false,allow_zizlimit_trade=false,allow_candlelimit_trade=false,allow_alllimit_trade=false,allow_zonelimit_trade=false,allow_candleentry_trade=false;
bool allow_grid_exit = false;
datetime EntryTime,ExitTime,ClosingTime,tf_time0,AsianLastTime;
bool bcandle_found = false,scandle_found = false,cloud_touched=false;
double buy_above=1000000,sell_below=0;
int bet_count = 1;
int trade_count=1,SL_CandAnalyse=5;
double recentEP,buy_sl,sell_sl,tp_sl_range,OriginalSL=0,OriginalTP=0,Atr, AtrSL;
int TotalUnits = 100000;//(Digits==5) ? 100000 : (Digits == 3) ? 1000 : 0;
int iPlus = 1,line=0;

double b_buy_above,b_sell_below,b_mother_open,b_mother_close,s_buy_above,s_sell_below,s_mother_open,s_mother_close;
datetime mother_candle,b_mother_candle,s_mother_candle;
bool b_bar=false,s_bar=false;
double major_high,major_low,major_open,major_close,minor_close,major_PP,minor_high,minor_low,minor_open,minor_PP,minor_R1,minor_S1,major_R1,major_S1;
int total_cond = 3;
bool candlestick_confirmed=false,b_pcheck,s_pcheck,r1check=false,s1check=false;
bool bfcm_signal=true,sfcm_signal=true,bfcm_signal2=true,sfcm_signal2=true,b_engulf,s_engulf;
int bcond_Count,scond_Count;
bool bcond_Count_Check, scond_Count_Check,b_mw_begin,s_mw_begin;
double rsi1,rsi2,rsi3,maad_rsi,maad_ci,ci1,vi1,vi2, ma,ma2,ma1_co,ma2_co,ma1_coPrev,ma2_coPrev,ma1_co0,ma2_co0,ma1_coPrev0,ma2_coPrev0,zz1,zz2;
datetime b_mw_time,s_mw_time;
double b_mw_high,b_mw_low,s_mw_high,s_mw_low;
bool b_mw_pchk=false,s_mw_pchk=false,b_mw_vol=false,s_mw_vol=false;
bool b_mw = false,s_mw = false;
string whichPattern="";
double st1,st2,st1_et,st2_et,st1LF,st2LF,st1MF,st2MF,st1HF,st2HF,st1EF,st2EF,st12,st22,st1LF2,st2LF2,st1MF2,st2MF2,st1HF2,st2HF2,st1EF2,st2EF2;
bool isBreakeven=false,range_check,crcMax,checkNews=true,checkAsianBuy=true,checkAsianSell=true;
datetime InitTime,MaxTime,kzzTime,kzzTime2,obos_buyTime,obos_sellTime,ssm_zonetime,ssm_shiftConsTime,ssm_shiftAggrTime,ssm_shiftCandleTime,ziz_buytime,ziz_selltime,ziz_buytime2,ziz_selltime2,ziz_buytime3,ziz_selltime3,ssm_buysignaltime,ssm_sellsignaltime,ssm_conf_buysignaltime,ssm_conf_sellsignaltime,ssm_conf_shiftCandleTime,mac_consTime,mac_aggrTime,asianMaxTrigTime;
double crc,crc_max,cs_strength,vol_strength,kzz,kzz2,zz_lastSig1,zz_lastSig2,obos_buy,obos_sell,obos_signal,ssm_strength,ssm_buystrength,ssm_sellstrength,ssm_htf_trend,ssm_shiftAggr,ssm_shiftCons,ssm_shiftCandle;
int STChangeTo,STDirection,STonEntryTime,STBcount,STScount;
double fcm_usd,fcm_eur,fcm_gbp,fcm_chf,fcm_jpy,fcm_aud,fcm_cad,fcm_nzd;
double fcm_usd2,fcm_eur2,fcm_gbp2,fcm_chf2,fcm_jpy2,fcm_aud2,fcm_cad2,fcm_nzd2;
double EqOnInit,btargetind,stargetind,basiantarget,sasiantarget,ziz_signal,ziz_touchzone,ssm_touchzone,ssm_touchzoneHTF,zone_touch,zone_mtf_sum,mac_dir,mac_touch_dir,vz_touch_dir,liq_touch_dir,rev_touch_dir,asian_dir,sd_touch_dir,pa1_touch_dir,pa2_touch_dir,wedges_touch_dir,rsid_touch_dir,bpz_touch_dir,spz_touch_dir;
string cur_symbol="",cur_sigType="",confby="",cur_SS_Startime="",cur_magic_number="",cur_comment="";
int cur_digits=5;
double cur_point=0;
int cur_sigOPType = BOTH;
int cur_symbol_index=-1;
datetime cur_entryTime,cur_exitTime,ssm_limit_triggered,candle_limit_triggered,all_limit_triggered,last_limit_triggered,candle_entry_triggered,mac_buytime,mac_selltime,confTime,volconfTime,MaxConfTime,MaxVolConfTime,MaxTrigTime,LastEquityUpdateTime,asian_ztime;
bool  TimeCheck,conf_genTime,mac_bcheck,mac_scheck,ConfLocked=false,is_confLocked=false,isconfInformed=false,is_confReset=false,is_volconfLocked=false,is_volproofLocked=false,isvolconfInformed=false,is_marketshiftLocked=false,is_volconfReset=false,mac_touch_bcheck,mac_touch_scheck,liq_touch_bcheck,vz_touch_check,liq_touch_scheck,rev_touch_bcheck,rev_touch_scheck,sd_touch_check,pa1_touch_check,pa2_touch_check,wedges_touch_check,rsid_touch_bcheck,rsid_touch_scheck,pz_touch_bcheck,pz_touch_scheck;
int confBarShift=0;
bool bdirection_check,sdirection_check,bmac,smac,bpowcand,spowcand,bssm_htftouch=true,sssm_htftouch=true;
datetime vpTime,ecTypeTime,LastBarTime;
string ecName="";
double liqgrab_dir=0;
double ecdir,ecdir2;
struct stc_msg_symbol
  {
   string            symbol;
   string            msg;
   datetime          lastTime;
  };
stc_msg_symbol messageSymbolArray[];
conf OAConfArr[];

int MaxConfCount = 12,oldTCC=0;
string lbl="SHEA.", gbl;
bool targetHit=false;
double startBalance=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   RiskPercent =RiskPercent1;
   StopLossCRC=StopLossCRC1;
   RewardPercent=RewardPercent1;
   MinSLTimeInMinutes=MinSLTimeInMinutes1;
   MinTimeBetweenOrdersInMinutes=MinTimeBetweenOrdersInMinutes1;
   EAID=EAID1;
   EA_Name=EAID1;

   ArrayResize(CommentList,0);

   ArrayResize(swingAdr, 8);
   swingAdr[0].cur="USD";
   swingAdr[1].cur="EUR";
   swingAdr[2].cur="GBP";
   swingAdr[3].cur="AUD";
   swingAdr[4].cur="NZD";
   swingAdr[5].cur="CAD";
   swingAdr[6].cur="JPY";
   swingAdr[7].cur="CHF";

   SDPerfectReadDataFromFile = ReadEADataFromFile;//read s&d perfect from file
   SDPerfectFolderName = EADataFolder;//folder to read
   SDPerfectFolderNumber = EADataSubFolder;//subfolder

   ReadAdrFromFile = ReadEADataFromFile;//Read data from file?
   AdrFolderName = EADataFolder;//folder name
   AdrFolderNumber = EADataSubFolder;//subfolder no

   ReadEntryCandleFromFile = ReadEADataFromFile;//read from file?
   EntryCandleFolderName = EADataFolder;//common folder name
   EntryCandleSubFolderNumber = EADataSubFolder;//subfolder

   ArrayInitialize(lastCandlePair, 0);
   for(int i=0; i<ArraySize(symbols); i++)
     {
      textFiles[i].symbol=symbols[i];
      textFiles[i].lastBuyFile=0;
      textFiles[i].lastSellFile=0;
     }
   ArrayResize(messageSymbolArray, 0);
   InitTime = iTime(cur_symbol,PERIOD_M1,0);
   MaxTime = InitTime + MaxMinutes*60;
//EqOnInit = NormalizeDouble(AccountEquity(),2);
//Print("Equity On Init : "+(string)EqOnInit);
   startBalance=0;

   ArrayResize(OAConfArr,MaxConfCount);

//confTime = Time[0];
   cur_sigOPType = (IsTesting()) ? Signal_Mode : cur_sigOPType;
//---
   gbl=lbl+IntegerToString(MagicNumber)+".";
   if(IsTesting())
     {
      gbl="B."+gbl;
      GlobalVariablesDeleteAll(gbl);
     }
   targetHit=false;

   if(ReadAdrFromFile)
      FolderClean(AdrFolderName, FILE_COMMON);
   if(ReadEntryCandleFromFile)
      FolderClean(EntryCandleFolderName, FILE_COMMON);
   if(SDPerfectReadDataFromFile)
      FolderClean(SDPerfectFolderName, FILE_COMMON);


   string to_split=Trade_Comments_to_Copy;
   string sep=",";
   ushort u_sep;
   string result[];
   u_sep=StringGetCharacter(sep,0);

   string to_split1=Risk_Percentage_for_Trade_Comments;
   string sep1=",";
   ushort u_sep1;
   string result1[];
   string result2[];
   string result3[];
   string result4[];
   string result5[];
   string result6[];
   u_sep1=StringGetCharacter(sep1,0);

   StringSplit(to_split1,u_sep1,result1);
   to_split1=Stop_Loss_CRC_for_Trade_Comments;
   StringSplit(to_split1,u_sep1,result2);

   to_split1=Reward_Percent_for_Trade_Comments;
   StringSplit(to_split1,u_sep1,result3);

   to_split1=Stop_Loss_Stacking_Time_for_Trade_Comments;
   StringSplit(to_split1,u_sep1,result4);

   to_split1=Limit_Order_Stacking_Time_for_Trade_Comments;
   StringSplit(to_split1,u_sep1,result5);

   to_split1=Trade_Comments_for_Trade_Comments;
   StringSplit(to_split1,u_sep1,result6);

   int k=StringSplit(to_split,u_sep,result);
   if(k>0)
     {
      for(int i=0; i<k; i++)
        {
         int size= ArraySize(CommentList);
         ArrayResize(CommentList,size+1);
         CommentList[size].cmnt=result[i];
         CommentList[size].pr=result1[i];
         CommentList[size].StopLossCRC2=result2[i];
         CommentList[size].RewardPercent2=result3[i];
         CommentList[size].StopLossStackingTime2=result4[i];
         CommentList[size].LimitOrderStackingTime2=result5[i];
         CommentList[size].CopyOrderComment2=result6[i];

        }
     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   if(reason==REASON_REMOVE)
      GlobalVariablesDeleteAll(gbl);

  }
datetime dt5;
datetime dt6;
datetime dt7;
bool once=true;
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//int      MT4_Account_ID    = 339111;
//if(MT4_Account_ID!=AccountNumber())
//{
//   Comment("Contact MT4 Admin");
//   return;
//}

   /*
   if(once)
   {
   cur_symbol="EURCHF";
   cur_sigOPType=OP_SELL;


   int ticket=OrderSend("EURGBP",OP_SELL,0.01,Ask,3,0,0,EAID1,MagicNumber,0,clrGreen);
      if(ticket<0)
        {
         Print("OrderSend failed with error #",GetLastError());
        }
      else
         Print("OrderSend placed successfully");

      if(Avoid_Hedge_Currency_Filtration)
        {
         EAID=EAID1;
         EA_Name=EAID1;

         int ActiveBuyOrders = GetHedgeTradeCount("Active",OP_BUY);
         int ActiveSellOrders = GetHedgeTradeCount("Active",OP_SELL);


         if(cur_sigOPType==OP_BUY)
           {
            if(ActiveBuyOrders>=1)
              {
               EAID=Avoid_Hedge_Currency_Filtration_Comment;
               EA_Name=Avoid_Hedge_Currency_Filtration_Comment;
              }
           }
         if(cur_sigOPType==OP_SELL)
           {
             Print(ActiveSellOrders+" "+ ActiveBuyOrders);

            if(ActiveSellOrders>=1)
              {
               EAID=Avoid_Hedge_Currency_Filtration_Comment;
               EA_Name=Avoid_Hedge_Currency_Filtration_Comment;
              }
           }
        }


   ticket=OrderSend(cur_symbol,cur_sigOPType,0.01,Ask,3,0,0,EAID,MagicNumber,0,clrGreen);
      if(ticket<0)
        {
         Print("OrderSend failed with error #",GetLastError());
        }
      else
         Print("OrderSend placed successfully");



   once=false;
   }


   return;
   */

//#####in auto mode this should be calculated for each pair, it should not be here anymore!!!



   bdirection_check = (Signal_Mode==SHOW_BOTH || Signal_Mode==SHOW_BUY) ? true : false;
   sdirection_check = (Signal_Mode==SHOW_BOTH || Signal_Mode==SHOW_SELL) ? true : false;

   EntryTime=StrToTime((string)TimeYear(TimeCurrent())+"."+(string)TimeMonth(TimeCurrent())+"."+(string)TimeDay(TimeCurrent())+" "+Start_Time);
   ExitTime=StrToTime((string)TimeYear(TimeCurrent())+"."+(string)TimeMonth(TimeCurrent())+"."+(string)TimeDay(TimeCurrent())+" "+End_Time);
   ClosingTime=StrToTime((string)TimeYear(TimeCurrent())+"."+(string)TimeMonth(TimeCurrent())+"."+(string)TimeDay(TimeCurrent())+" "+Closing_Time);

//trade management functions
   if(startBalance==0)
     {
      startBalance=AccountBalance();
      //if (EnableFundedAccount && startBalance>FundedAccountBalance) startBalance=FundedAccountBalance;
      double fundedBalance=FundedAccountBalance;
      if(fundedBalance>AccountBalance())
         fundedBalance=AccountBalance();
      Print("start balance updated ("+Symbol()+") : "+DoubleToStr(startBalance,2)+" on "+TimeToString(Time[0]));
      Print("profit target is "+DoubleToString(EquityExit, 2)+"%, "+DoubleToString(startBalance+EquityExit*(EnableFundedAccount?fundedBalance:startBalance)/100, 2)+"$");
      Print("loss target is "+DoubleToString(EquityExitNeg, 2)+"%, "+DoubleToString(startBalance+EquityExitNeg*(EnableFundedAccount?fundedBalance:startBalance)/100, 2)+"$");
      targetHit=false;
     }

   if(EnableCAT)
     {
      if(Time[0]>=ClosingTime)
        {
         if(IsAnyOrderActive(-1)!=-1)
           {
            CloseAllOrders(-1);
            Print("All Position closed due to Closing Time on "+TimeToStr(ClosingTime));
           }
         return;
        }
     }

   if(EnableManualEquityExit)
     {
      if(targetHit)
         return;
      if(AccountEquity()>=Manual_EquityExitPos)
        {
         if(IsAnyOrderActive(-1)!=-1)
           {
            CloseAllOrders(-1);
            Print("all orders are closed on Manual_EquityExitPos hit");
           }
         targetHit=true;
         return;
        }
      if(AccountEquity()<=Manual_EquityExitNeg)
        {
         if(IsAnyOrderActive(-1)!=-1)
           {
            CloseAllOrders(-1);
            Print("all orders are closed on Manual_EquityExitNeg hit");
           }
         targetHit=true;
         return;
        }
     }

   if(EnableEquityExit)
     {
      if(targetHit)
         return;
      double fundedBalance=FundedAccountBalance;
      if(fundedBalance>AccountBalance())
         fundedBalance=AccountBalance();
      double EqTgt = ((EnableFundedAccount?fundedBalance:startBalance) * (EquityExit/100)) + startBalance;
      double EqSL  = ((EnableFundedAccount?fundedBalance:startBalance) * (EquityExitNeg/100)) + startBalance;
      if(AccountEquity()>=EqTgt)
        {
         if(IsAnyOrderActive(-1)!=-1)
           {
            CloseAllOrders(-1);
            Print("all orders are closed on profit target hit");
           }
         targetHit=true;
         return;
        }
      if(AccountEquity()<=EqSL)
        {
         if(IsAnyOrderActive(-1)!=-1)
           {
            CloseAllOrders(-1);
            Print("all orders are closed on loss target hit");
           }
         targetHit=true;
         return;
        }
     }

   CheckOrderExpiry();

   if(EnableBreakEven)
     {
      BreakEvenTrades();
     }

   if(EnableZigzagTrailing)
     {
      ZigzagTrailing();
     }

   if(EnableZigzagTrailing2)
     {
      ZigzagTrailing2();
     }

   if(ExitOnPerfectSignal)
     {
      CheckForExitPerfectSignal();
     }

   static int totalCloseTrades=0;
   static datetime lastTimeWritten=0;
   if(totalCloseTrades!=OrdersHistoryTotal())
     {
      totalCloseTrades=OrdersHistoryTotal();
      for(int i=OrdersHistoryTotal()-1; i>=0; i--)
         if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
            if(OrderMagicNumber()==MagicNumber && (OrderType()==OP_BUY || OrderType()==OP_SELL))
              {
               if(OrderCloseTime()<lastTimeWritten)
                  break;
               double isl=GlobalVariableGet(gbl+IntegerToString(OrderTicket())+".ISL");
               if(isl==0)
                  continue;
               if(OrderProfit()>0)
                 {
                  double rr=0;
                  if(OrderType()==OP_BUY)
                     rr=(OrderClosePrice()-OrderOpenPrice())/isl;
                  if(OrderType()==OP_SELL)
                     rr=(OrderOpenPrice()-OrderClosePrice())/isl;
                  Print("trade #"+IntegerToString(OrderTicket())+" on "+OrderSymbol()+" is closed with RR="+DoubleToString(rr, 2));
                 }
              }
      lastTimeWritten=TimeCurrent();
     }

   if(EnableFileScanner)
     {

      if(Enable_EA_as_Copytrading_Receiver==false)
        {
         cur_symbol = GetSymbolFromFileScanner();
        }
      else
        {
         cur_symbol = GetSymbolFromFileScannerReceiver();
        }

      //Print("*********"+cur_symbol);
     }
   else
     {
      cur_symbol = Symbol();
      cur_symbol_index = GetSymbolIndex(cur_symbol);
      cur_entryTime = EntryTime;
      cur_sigOPType = Signal_Mode;
      cur_SS_Startime = Start_Time;
      cur_digits=(int)SymbolInfoInteger(cur_symbol, SYMBOL_DIGITS);
      cur_point=SymbolInfoDouble(cur_symbol, SYMBOL_POINT);
      ecdir = 0;
      if(EnableEntryCandle)
        {
         if(ReadEntryCandleFromFile)
           {
            ecdir=ReadEntryCandleSignalFromFile();
           }
         else
           {
            ecdir=getEntryCandle(0,Signal_Mode,2,iPlus);
            if(EnableTrendDirectionFilter)
              {
               if(ecdir==1)
                 {
                  int buy=(int)getEntryCandle(0,Signal_Mode,33,iPlus);
                  if(buy==0)
                     ecdir=0;
                 }
               if(ecdir==-1)
                 {
                  int sell=(int)getEntryCandle(0,Signal_Mode,34,iPlus);
                  if(sell==0)
                     ecdir=0;
                 }
              }
           }
        }
      ecdir2 = (EnableECMethod2) ? getEntryCandleM2(0,Signal_Mode,2,iPlus) : 0;


     }


   Begin();

   if(dt7!=Time[0])
     {
      dt7=Time[0];
     }


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getRangeFormedValidity(int tf,int shift)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\ZigZag_Custom",false,54,shift);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getCZDCVB(int tf,int shift)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\ZigZag_Custom",false,41,shift);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getCZDCVS(int tf,int shift)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\ZigZag_Custom",false,42,shift);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getCZRV(int tf,int shift)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);

   return iCustom(cur_symbol,tf,"Kishore Fredrick\\ZigZag_Custom",false,43,shift);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getValiditySingle(int tf,int shift)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);

   return iCustom(cur_symbol,tf,"Kishore Fredrick\\ZigZag_Custom",false,50,shift);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getValidityDouble(int tf,int shift)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);

   return iCustom(cur_symbol,tf,"Kishore Fredrick\\ZigZag_Custom",false,51,shift);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getBuySum(int tf,int shift)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);

   return iCustom(cur_symbol,tf,"Kishore Fredrick\\ZigZag_Custom",false,56,shift);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getBuyWeightage(int tf,int shift)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);

   return iCustom(cur_symbol,tf,"Kishore Fredrick\\ZigZag_Custom",false,57,shift);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getSellSum(int tf,int shift)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);

   return iCustom(cur_symbol,tf,"Kishore Fredrick\\ZigZag_Custom",false,58,shift);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getSellWeightage(int tf,int shift)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);

   return iCustom(cur_symbol,tf,"Kishore Fredrick\\ZigZag_Custom",false,59,shift);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getExplodeValidity()
  {
   double explode=0;
   string stime=TimeToString(Time[0], TIME_MINUTES);
   StringReplace(stime, ":", "");
   string fileName="Explode"+"_"+cur_symbol+"_"+stime;

   message="GetSignal"+":"+fileName+":ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
   bool res= GetSignal(message);
   string to_split=message;
   if(to_split!="" && to_split!="No Signal")
     {
      string sp[];
      StringSplit(to_split, StringGetCharacter(",", 0), sp);
      if(ArraySize(sp)>=2)
        {
         if(sp[0]==cur_symbol)
           {
            explode=(int)StringToInteger(sp[1]);
           }
        }
     }

   return explode;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getCSVB(int tf,int shift)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\ZigZag_Custom",false,44,bs);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getCSVS(int tf,int shift)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\ZigZag_Custom",false,45,bs);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getZigZagValid_1()
  {
   return iCustom(cur_symbol,HTF1_TF,"Kishore Fredrick\\ZigZag_Custom",false,HTF1_TF,InpDepth1,InpDeviation1,InpBackstep1,zz_hl_1,Recent_Zigzag_1,Imbalance_1,63,0);
  }
  

double getZigZagValid_2()
  {
   return iCustom(cur_symbol,HTF2_TF,"Kishore Fredrick\\ZigZag_Custom",false,HTF2_TF,InpDepth2,InpDeviation2,InpBackstep2,zz_hl_2,Recent_Zigzag_2,Imbalance_2,63,0);
  }


double getZigZagValid_3()
  {
   return iCustom(cur_symbol,HTF3_TF,"Kishore Fredrick\\ZigZag_Custom",false,HTF3_TF,InpDepth3,InpDeviation3,InpBackstep3,zz_hl_3,Recent_Zigzag_3,Imbalance_3,63,0);
  }
  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool getCSVB1(int tf,int shift)
  {

   bool BuyValid=false;


   double vl= iCustom(cur_symbol,HTF1_TF,"Kishore Fredrick\\ZigZag_Custom",false,HTF1_TF,InpDepth1,InpDeviation1,InpBackstep1,60,0);
   if(dt7!=Time[0])
     {
      //  Print(cur_symbol + " buy v1: " + vl);
     }
//LL or HL
   if(vl==2 || vl==3)
     {
      BuyValid=true;
      if(Enable_HLLH_entries_only)
        {
         //LL
         if(vl==2)
           {
            BuyValid=false;
           }
        }
      if(Enable_HHLL_entries_only)
        {
         if(vl==3)
           {
            BuyValid=false;
           }
        }
     }


   return BuyValid;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool getCSVS1(int tf,int shift)
  {

   bool SellValid=false;

   double vl= iCustom(cur_symbol,HTF1_TF,"Kishore Fredrick\\ZigZag_Custom",false,HTF1_TF,InpDepth1,InpDeviation1,InpBackstep1,60,0);
   if(dt7!=Time[0])
     {
      //  Print(cur_symbol + " sell v1: " + vl);
     }
//HH or LH
   if(vl==1 || vl==4)
     {
      SellValid=true;

      if(Enable_HLLH_entries_only)
        {
         //HH
         if(vl==1)
           {
            SellValid=false;
           }
        }

      if(Enable_HHLL_entries_only)
        {
         //LH
         if(vl==4)
           {
            SellValid=false;
           }
        }
     }

   return SellValid;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getCSVB2(int tf,int shift)
  {

   bool BuyValid=false;

   double vl= iCustom(cur_symbol,HTF2_TF,"Kishore Fredrick\\ZigZag_Custom",false,HTF2_TF,InpDepth2,InpDeviation2,InpBackstep2,60,0);

//LL or HL
   if(vl==2 || vl==3)
     {
      BuyValid=true;

      if(Enable_HLLH_entries_only_2)
        {
         //LL
         if(vl==2)
           {
            BuyValid=false;
           }
        }
      if(Enable_HHLL_entries_only_2)
        {
         //HL
         if(vl==3)
           {
            BuyValid=false;
           }
        }
     }

   return BuyValid;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getCSVS2(int tf,int shift)
  {

   bool SellValid=false;

   double vl= iCustom(cur_symbol,HTF2_TF,"Kishore Fredrick\\ZigZag_Custom",false,HTF2_TF,InpDepth2,InpDeviation2,InpBackstep2,60,0);

//HH or LH
   if(vl==1 || vl==4)
     {
      SellValid=true;

      if(Enable_HLLH_entries_only_2)
        {
         //HH
         if(vl==1)
           {
            SellValid=false;
           }
        }

      if(Enable_HHLL_entries_only_2)
        {
         //LH
         if(vl==4)
           {
            SellValid=false;
           }
        }
     }

   return SellValid;

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getCSVB3(int tf,int shift)
  {

   bool BuyValid=false;


   double vl= iCustom(cur_symbol,HTF3_TF,"Kishore Fredrick\\ZigZag_Custom",false,HTF3_TF,InpDepth3,InpDeviation3,InpBackstep3,60,0);


//LL or HL
   if(vl==2 || vl==3)
     {
      BuyValid=true;

      if(Enable_HLLH_entries_only_3)
        {
         //LL
         if(vl==2)
           {
            BuyValid=false;
           }
        }

      if(Enable_HHLL_entries_only_3)
        {
         //HL
         if(vl==3)
           {
            BuyValid=false;
           }
        }
     }

   return BuyValid;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getCSVS3(int tf,int shift)
  {

   bool SellValid=false;

   double vl= iCustom(cur_symbol,HTF3_TF,"Kishore Fredrick\\ZigZag_Custom",false,HTF3_TF,InpDepth3,InpDeviation3,InpBackstep3,60,0);

//HH //LH
   if(vl==1 || vl==4)
     {
      SellValid=true;

      if(Enable_HLLH_entries_only_3)
        {
         //HH
         if(vl==1)
           {
            SellValid=false;
           }
        }

      if(Enable_HHLL_entries_only_3)
        {
         //LH
         if(vl==4)
           {
            SellValid=false;
           }
        }
     }

   return SellValid;

  }


string message;
//+------------------------------------------------------------------+
int ReadEntryCandleSignalFromFile()
  {
   int sig=0;
   int dir=0, explode=0, liquidity=0, buy=0, sell=0, m1abuy=0, m1asell=0, m1bbuy=0, m1bsell=0, m2abuy=0, m2asell=0, m2bbuy=0, m2bsell=0, m5pbuy=0, m5psell=0, m15pbuy=0, m15psell=0;
   string stime=TimeToString(Time[0], TIME_MINUTES);
   StringReplace(stime, ":", "");
   string fileName=EntryCandleFileName+"_"+cur_symbol+"_"+stime;
//Print(fileName);

   message="GetSignal"+":"+fileName+":ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
   bool res= GetSignal(message);
   string to_split=message;
   if(to_split!="" && to_split!="No Signal")
     {
      string sp[];
      StringSplit(to_split, StringGetCharacter(",", 0), sp);
      if(ArraySize(sp)>=6)
        {
         if(sp[0]==cur_symbol)
           {
            dir=(int)StringToInteger(sp[1]);
            explode=(int)StringToInteger(sp[2]);
            liquidity=(int)StringToInteger(sp[3]);
            buy=(int)StringToInteger(sp[4]);
            sell=(int)StringToInteger(sp[5]);
            m1abuy=(int)StringToInteger(sp[6]);
            m1asell=(int)StringToInteger(sp[7]);
            m1bbuy=(int)StringToInteger(sp[8]);
            m1bsell=(int)StringToInteger(sp[9]);
            m2abuy=(int)StringToInteger(sp[10]);
            m2asell=(int)StringToInteger(sp[11]);
            m2bbuy=(int)StringToInteger(sp[12]);
            m2bsell=(int)StringToInteger(sp[13]);
            m5pbuy=(int)StringToInteger(sp[14]);
            m5psell=(int)StringToInteger(sp[15]);
            m15pbuy=(int)StringToInteger(sp[16]);
            m15psell=(int)StringToInteger(sp[17]);
           }
        }
     }
//else Print(GetLastError());
   if(dir!=0)
     {
      int buy2=0, bmethod=0;
      if(M1AEnabled && m1abuy==1)
        {
         buy2=1;
         bmethod=1;
        }
      if(M1BEnabled && m1bbuy==1)
        {
         buy2=1;
         bmethod=2;
        }
      if(M2AEnabled && m2abuy==1)
        {
         buy2=1;
         bmethod=3;
        }
      if(M2BEnabled && m2bbuy==1)
        {
         buy2=1;
         bmethod=4;
        }
      if(M5PerfectDirectionEnabled && M15PerfectDirectionEnabled)
        {
         if(m5pbuy==0 && m15pbuy==0)
            buy2=0;
        }
      else
         if(M5PerfectDirectionEnabled)
           {
            if(m5pbuy==0)
               buy2=0;
           }
         else
            if(M15PerfectDirectionEnabled)
              {
               if(m15pbuy==0)
                  buy2=0;
              }
      if(!M1AEnabled && !M1BEnabled && !M2AEnabled && !M2BEnabled && ((M5PerfectDirectionEnabled && m5pbuy!=0) || (M15PerfectDirectionEnabled && m15pbuy!=0)))
        { buy2=1; if(m5pbuy!=0 && m15pbuy!=0) bmethod=5; else if(m5pbuy!=0) bmethod=6; else if(m15pbuy!=0) bmethod=7; }

      int sell2=0, smethod=0;
      if(M1AEnabled && m1asell==1)
        {
         sell2=1;
         smethod=1;
        }
      if(M1BEnabled && m1bsell==1)
        {
         sell2=1;
         smethod=2;
        }
      if(M2AEnabled && m2asell==1)
        {
         sell2=1;
         smethod=3;
        }
      if(M2BEnabled && m2bsell==1)
        {
         sell2=1;
         smethod=4;
        }
      if(M5PerfectDirectionEnabled && M15PerfectDirectionEnabled)
        {
         if(m5psell==0 && m15psell==0)
            sell2=0;
        }
      else
         if(M5PerfectDirectionEnabled)
           {
            if(m5psell==0)
               sell2=0;
           }
         else
            if(M15PerfectDirectionEnabled)
              {
               if(m15psell==0)
                  sell2=0;
              }
      if(!M1AEnabled && !M1BEnabled && !M2AEnabled && !M2BEnabled && ((M5PerfectDirectionEnabled && m5psell!=0) || (M15PerfectDirectionEnabled && m15psell!=0)))
        { sell2=1; if(m5psell!=0 && m15psell!=0) smethod=5; else if(m5psell!=0) smethod=6; else if(m15psell!=0) smethod=7; }

      if(EnableTrendDirectionFilter && buy2==1 && (datetime)GlobalVariableGet(gbl+cur_symbol+"S2BuyValid")<Time[0])
        {
         Print(cur_symbol+" is validated for "+(bmethod==1?"m1a":bmethod==2?"m1b":bmethod==3?"m2a":bmethod==4?"m2b":bmethod==5?"m5, m15 perfect":bmethod==6?"m5 perfect":"m15 perfect")+" buy on trend direction @"+TimeToString(Time[1])+" till "+TimeToString(Time[0]+Segment2ValidityBars*PeriodSeconds(0))+" for "+IntegerToString(Segment2ValidityBars)+" bars");
         GlobalVariableSet(gbl+cur_symbol+"S2BuyValid", Time[0]);
        }
      if(EnableTrendDirectionFilter && sell2==1 && (datetime)GlobalVariableGet(gbl+cur_symbol+"S2SellValid")<Time[0])
        {
         Print(cur_symbol+" is validated for "+(smethod==1?"m1a":smethod==2?"m1b":smethod==3?"m2a":smethod==4?"m2b":smethod==5?"m5, m15 perfect":smethod==6?"m5 perfect":"m15 perfect")+" sell on trend direction @"+TimeToString(Time[1])+" till "+TimeToString(Time[0]+Segment2ValidityBars*PeriodSeconds(0))+" for "+IntegerToString(Segment2ValidityBars)+" bars");
         GlobalVariableSet(gbl+cur_symbol+"S2SellValid", Time[0]);
        }
      bool buyValid=iBarShift(cur_symbol, 0, (datetime)GlobalVariableGet(gbl+cur_symbol+"S2BuyValid"))<=Segment2ValidityBars;
      bool sellValid=iBarShift(cur_symbol, 0, (datetime)GlobalVariableGet(gbl+cur_symbol+"S2SellValid"))<=Segment2ValidityBars;
      //Print("symbol="+cur_symbol+", explode="+IntegerToString(explode)+", liquidity="+IntegerToString(liquidity));
      if((!EnableExplodeFilteration || explode>=ExplodeAndSDLiquidityMinBoth) && (!EnableSDLiquidity || liquidity>=ExplodeAndSDLiquidityMinBoth) && (EnableExplodeFilteration?explode:0)+(EnableSDLiquidity?liquidity:0)>=ExplodeAndSDLiquidityNeeded)
         if(!EnableTrendDirectionFilter || (dir==1 && buyValid) || (dir==-1 && sellValid))
            sig=dir;
      //Print(cur_symbol, ", ", dir, ", ", sig, ", ", buy, ", ", sell);
     }
   return (sig);
  }
//+------------------------------------------------------------------+
int GetIndexOfFile(string symbol)
  {
   for(int i=0; i<ArraySize(allSymbols); i++)
     {
      if(allSymbols[i]==symbol)
        {
         if(i<=5)
            return (1);
         else
            if(i<=11)
               return (2);
            else
               if(i<=17)
                  return (3);
               else
                  if(i<=23)
                     return (4);
                  else
                     return (5);
        }
     }
   return (-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetSymbolIndex(string symbol)
  {
   for(int i=0; i<ArraySize(symbols); i++)
     {
      if(StringFind(symbol, symbols[i])!=-1)
         return (i);
     }
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Begin()
  {
   getCSVB1(ZigZag_TF,0);
   getCSVS1(ZigZag_TF,0);
   getCSVB2(ZigZag_TF,0);
   getCSVS2(ZigZag_TF,0);
   getCSVB3(ZigZag_TF,0);
   getCSVS3(ZigZag_TF,0);

// Print(cur_symbol+" Checking" +" "+getCSVS1(ZigZag_TF,0));
   datetime Expiry_Time       = StringToTime("2024.09.28 00:00");
   if(TimeCurrent()>Expiry_Time)
     {
      Comment("Contact Admin");
      return;
     }



   if(Enable_Zigzag_Range_Formation_Check)
     {
      //  EAID=EAID1;
      // EA_Name=EAID1;

      double vl= getRangeFormedValidity(ZigZag_TF,1);
      if(vl!=EMPTY_VALUE && getRangeFormedValidity(ZigZag_TF,1)>=Range_Formation_Value)
        {
         EAID=Modify_Trade_Comments;
         EA_Name=Modify_Trade_Comments;
        }
     }

   if(ChangeHedgeComment)
     {

      //  EAID=EAID1;
      // EA_Name=EAID1;

      int ActiveBuyOrders = GetTotalOrders("Active",OP_BUY);
      int ActiveSellOrders = GetTotalOrders("Active",OP_SELL);

      if(cur_sigOPType==OP_BUY)
        {
         if(ActiveSellOrders>=1)
           {
            EAID=HedgeComment;
            EA_Name=HedgeComment;
           }
        }
      if(cur_sigOPType==OP_SELL)
        {
         if(ActiveBuyOrders>=1)
           {
            EAID=HedgeComment;
            EA_Name=HedgeComment;
           }
        }
     }


   if(Avoid_Hedge_Currency_Filtration)
     {
      // EAID=EAID1;
      // EA_Name=EAID1;

      int ActiveBuyOrders = GetHedgeTradeCount("Active",OP_BUY);
      int ActiveSellOrders = GetHedgeTradeCount("Active",OP_SELL);

      if(cur_sigOPType==OP_BUY)
        {
         if(ActiveBuyOrders>=1)
           {
            EAID=Avoid_Hedge_Currency_Filtration_Comment;
            EA_Name=Avoid_Hedge_Currency_Filtration_Comment;
           }
        }
      if(cur_sigOPType==OP_SELL)
        {
         if(ActiveSellOrders>=1)
           {
            EAID=Avoid_Hedge_Currency_Filtration_Comment;
            EA_Name=Avoid_Hedge_Currency_Filtration_Comment;
           }
        }
     }

   if(Avoid_Stacking_Directional_Positions_on_Currency)
     {
      // EAID=EAID1;
      // EA_Name=EAID1;

      int ActiveBuyOrders = GetTradeCount("Active",OP_BUY);
      int ActiveSellOrders = GetTradeCount("Active",OP_SELL);

      if(cur_sigOPType==OP_BUY)
        {
         if(ActiveBuyOrders>=1)
           {
            EAID=Avoid_Stacking_Directional_Positions_on_Currency_Comment;
            EA_Name=Avoid_Stacking_Directional_Positions_on_Currency_Comment;
           }
        }
      if(cur_sigOPType==OP_SELL)
        {
         if(ActiveSellOrders>=1)
           {
            EAID=Avoid_Stacking_Directional_Positions_on_Currency_Comment;
            EA_Name=Avoid_Stacking_Directional_Positions_on_Currency_Comment;
           }
        }
     }


   GetSpreadVal(cur_symbol,AvgSpreadValue,MaxSpreadValue);
   bool ManualTC = (EnableManualTime && EnableFileScanner==false) ? (Time[0] >= Manual_Entry_Time && Time[0] < Manual_Exit_Time) : false;
   TimeCheck = (EnableManualTime) ? ManualTC : (Time[0] >= EntryTime && Time[0] < ExitTime);

   if(MaxMinutes!=0 && iTime(cur_symbol,PERIOD_M1,0)>MaxTime)
     {
      Comment("Maximum Time Reached, Re-Apply the EA");
      return;
     }

   Atr = 0;//iATR(cur_symbol,0,ATRPeriod,iPlus);

   if(EnableSSMExit || EnableVolumeProofExit || EnableMarketShiftExit)
     {
      CheckForExit();
     }

   if(EnableRangeExit)
     {
      int count=0;
      int b=0;
      while(b<100)
        {
         CheckForExit1();

         for(int i=0; i<OrdersTotal(); i++)
           {

            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
              {
               if(OrderMagicNumber()!=MagicNumber || OrderSymbol()!=cur_symbol)
                  continue;

               count++;
              }
           }

         if(count==0)
           {
            break;
           }

         b++;
        }
     }


   if(TimeCheck)
     {
      if(TradingDelay==0 || TimeCurrent()-Time[0]>=TradingDelay)
         CheckForEntry();
      //DisplayScreen();
      CheckForExit();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckForEntry()
  {

   double spread = (MarketInfo(cur_symbol,MODE_ASK) - MarketInfo(cur_symbol,MODE_BID));

   if(IsNewOrderAllowed() == false)
     {
      Print("Maximum Orders Reached on "+Symbol());
      return (0);
     }

   int totalBars = MathMin(Bars-1,MinBar);

//int b_last_order_shift = iBarShift(cur_symbol,0,GetLastOrderTime("BUY"));
//int s_last_order_shift = iBarShift(cur_symbol,0,GetLastOrderTime("SELL"));
   datetime b_last_order_time = GetLastOrderTime(OP_BUY);
   datetime s_last_order_time = GetLastOrderTime(OP_SELL);

//Finding and setting the Confirmation Time
   ConfLocked = FindConfirmationTime();
   conf_genTime = (EnableOverallConfirmation) ? (confTime >= cur_entryTime && confTime >= EntryTime) : true;

//Print("confTime="+confTime+" conf_genTime="+conf_genTime+" cur_entryTime="+cur_entryTime+" EntryTime="+EntryTime+" T="+Time[0]);


   if(EnableRSI)
     {
      int rsibs1 = (RSI_TF1==Period()) ? iPlus : iBarShift(cur_symbol,RSI_TF1,Time[iPlus])+1;
      rsi1 = iRSI(cur_symbol,RSI_TF1,RSI_Period,PRICE_CLOSE,rsibs1);
      if(EnableRSI2)
        {
         int rsibs2 = (RSI_TF2==Period() || Period()==0) ? iPlus : iBarShift(cur_symbol,RSI_TF2,Time[iPlus])+1;
         rsi2 = iRSI(cur_symbol,RSI_TF2,RSI_Period,PRICE_CLOSE,rsibs2);
        }
      if(EnableRSI3)
        {
         int rsibs3 = (RSI_TF3==Period() || Period()==0) ? iPlus : iBarShift(cur_symbol,RSI_TF3,Time[iPlus])+1;
         rsi3 = iRSI(cur_symbol,RSI_TF3,RSI_Period,PRICE_CLOSE,rsibs3);
        }
     }
   if(EnableChoppiness)
     {
      int cibs = (CI_TF1==Period()) ? iPlus : iBarShift(cur_symbol,CI_TF1,Time[iPlus])+1;
      ci1 = iCustom(cur_symbol,CI_TF1,"Kishore Fredrick\\Choppiness Index",CI_Period,totalBars,0,cibs);
     }
   if(EnableVortex)
     {
      int vibs = (VI_TF1==Period()) ? iPlus : iBarShift(cur_symbol,VI_TF1,Time[iPlus])+1;
      vi1 = iCustom(cur_symbol,VI_TF1,"Vortex_Indicator",VI_Period,0,vibs);
      vi2 = iCustom(cur_symbol,VI_TF1,"Vortex_Indicator",VI_Period,1,vibs);
     }
   if(EnableMA)
     {
      int mash = (MA_TF1==Period()) ? iPlus : iBarShift(cur_symbol,MA_TF1,Time[iPlus])+1;
      ma = iMA(cur_symbol,MA_TF1,MA_Period,0,MA_Method,MA_Price,mash);

      if(EnableMA2)
        {
         int mash2 = (MA_TF2==Period()) ? iPlus : iBarShift(cur_symbol,MA_TF2,Time[iPlus])+1;
         ma2 = iMA(cur_symbol,MA_TF2,MA_Period2,0,MA_Method2,MA_Price2,mash2);
        }
     }
   if(EnableMACrossover || EnableMAArrow || EnableMAArrowDyn)
     {
      int mash = (MA_CO_TF1==Period()) ? iPlus : iBarShift(cur_symbol,MA_CO_TF1,Time[iPlus])+1;
      ma1_co = iMA(cur_symbol,MA_CO_TF1,MA_CO_Period1,0,MA_CO_Method,MA_CO_Price,mash);
      ma2_co = iMA(cur_symbol,MA_CO_TF1,MA_CO_Period2,0,MA_CO_Method,MA_CO_Price,mash);
      ma1_coPrev = iMA(cur_symbol,MA_CO_TF1,MA_CO_Period1,0,MA_CO_Method,MA_CO_Price,mash+1);
      ma2_coPrev = iMA(cur_symbol,MA_CO_TF1,MA_CO_Period2,0,MA_CO_Method,MA_CO_Price,mash+1);

      if(EnableMAArrowDyn)
        {
         int mash0 = (MA_CO_TF1==Period()) ? 0 : iBarShift(cur_symbol,MA_CO_TF1,Time[0]);
         ma1_co0 = iMA(cur_symbol,MA_CO_TF1,MA_CO_Period1,0,MA_CO_Method,MA_CO_Price,mash0);
         ma2_co0 = iMA(cur_symbol,MA_CO_TF1,MA_CO_Period2,0,MA_CO_Method,MA_CO_Price,mash0);
         ma1_coPrev0 = iMA(cur_symbol,MA_CO_TF1,MA_CO_Period1,0,MA_CO_Method,MA_CO_Price,mash0+1);
         ma2_coPrev0 = iMA(cur_symbol,MA_CO_TF1,MA_CO_Period2,0,MA_CO_Method,MA_CO_Price,mash0+1);

         if(EnableMADRSI)
           {
            int rsibs1 = (MAAD_RSI_TF1==Period()) ? 0 : iBarShift(cur_symbol,MAAD_RSI_TF1,Time[0]);
            maad_rsi = iRSI(cur_symbol,MAAD_RSI_TF1,MAAD_RSI_Period,PRICE_CLOSE,rsibs1);
           }

         if(EnableMADCI)
           {
            int cibs = (MAAD_CI_TF1==Period()) ? 0 : iBarShift(cur_symbol,MAAD_CI_TF1,Time[0]);
            maad_ci = iCustom(cur_symbol,MAAD_CI_TF1,"Choppiness Index",MAAD_CI_Period,totalBars,0,cibs);
           }
        }
     }
   if(EnableKZZ)
     {
      //int zzbs1 = (ZZ_TF1==Period()) ? iPlus : iBarShift(cur_symbol,ZZ_TF1,Time[iPlus])+1;
      kzz = iCustom(cur_symbol,0,"Kishore Fredrick\\RIS Kishore ZigZag",2,iPlus);
      kzzTime = (datetime)iCustom(cur_symbol,0,"Kishore Fredrick\\RIS Kishore ZigZag",3,iPlus);

      if(EnableKZZ2)
        {
         kzz2 = iCustom(cur_symbol,0,"Kishore Fredrick\\RIS Kishore ZigZag2",2,iPlus);
         kzzTime2 = (datetime)iCustom(cur_symbol,0,"Kishore Fredrick\\RIS Kishore ZigZag2",3,iPlus);
        }
     }
   if(EnableZIZ)
     {
      ziz_signal = iCustom(cur_symbol,0,"Kishore Fredrick\\ZIZ_OBOS_v3",0,iPlus);
      ziz_buytime = (datetime)iCustom(cur_symbol,0,"Kishore Fredrick\\ZIZ_OBOS_v3",1,iPlus);
      ziz_selltime = (datetime)iCustom(cur_symbol,0,"Kishore Fredrick\\ZIZ_OBOS_v3",1,iPlus);
      ziz_touchzone = iCustom(cur_symbol,0,"Kishore Fredrick\\ZIZ_OBOS_v3",7,iPlus);
     }
   if(EnableZigZagMS)
     {
      int zzbs1 = (ZZ_TF1==Period()) ? iPlus : iBarShift(cur_symbol,ZZ_TF1,Time[iPlus])+1;
      zz_lastSig1 = iCustom(cur_symbol,ZZ_TF1,"Kishore Fredrick\\ZigZag_MS",ZZ_TF1,ZZ_Depth1,ZZ_Deviation1,ZZ_Backstep1,ZZ_HL1,false,false,4,zzbs1);

      if(EnableZigZagMS2)
        {
         int zzbs2 = (ZZ_TF2==Period()) ? iPlus : iBarShift(cur_symbol,ZZ_TF2,Time[iPlus])+1;
         zz_lastSig2 = iCustom(cur_symbol,ZZ_TF2,"Kishore Fredrick\\ZigZag_MS",ZZ_TF2,ZZ_Depth2,ZZ_Deviation2,ZZ_Backstep2,ZZ_HL2,false,false,4,zzbs2);
        }
     }
   if(EnableOBOS)
     {
      int oboshift = iBarShift(cur_symbol,0,kzzTime) + ST_OBOS_Period;
      obos_buy = iCustom(cur_symbol,0,"Kishore Fredrick\\RIS Kishore OBOS","",oboshift,OBOS_Period,OBOS_HTF,OBOS_Price,OBOS_OB,OBOS_OS,"",EnableOBOSSuperTrend,ST_OBOS_ConfirmationTF,ST_OBOS_Period,ST_OBOS_Multiplier,"",false,false,2,iPlus);
      obos_buyTime = (datetime)iCustom(cur_symbol,0,"Kishore Fredrick\\RIS Kishore OBOS","",oboshift,OBOS_Period,OBOS_HTF,OBOS_Price,OBOS_OB,OBOS_OS,"",EnableOBOSSuperTrend,ST_OBOS_ConfirmationTF,ST_OBOS_Period,ST_OBOS_Multiplier,"",false,false,3,iPlus);
      obos_sell = iCustom(cur_symbol,0,"Kishore Fredrick\\RIS Kishore OBOS","",oboshift,OBOS_Period,OBOS_HTF,OBOS_Price,OBOS_OB,OBOS_OS,"",EnableOBOSSuperTrend,ST_OBOS_ConfirmationTF,ST_OBOS_Period,ST_OBOS_Multiplier,"",false,false,4,iPlus);
      obos_sellTime = (datetime)iCustom(cur_symbol,0,"Kishore Fredrick\\RIS Kishore OBOS","",oboshift,OBOS_Period,OBOS_HTF,OBOS_Price,OBOS_OB,OBOS_OS,"",EnableOBOSSuperTrend,ST_OBOS_ConfirmationTF,ST_OBOS_Period,ST_OBOS_Multiplier,"",false,false,5,iPlus);
      //OT="+Time[oboshift]+"
      //Print("oboshift="+oboshift+"  obos_sell="+obos_sell+" obos_sellTime="+obos_sellTime+" kzzTime="+kzzTime);
      //obos_signal = (obos_buy!=EMPTY_VALUE) ? 1 : (obos_sell!=EMPTY_VALUE) ? -1 : obos_signal;
     }
   if(EnableCRC)
     {
      crc = getCRC(0,2,iPlus);
      crc_max = getCRCMax(0,2,iPlus);
     }
   if(EnableCS)
     {
      //FirstTimeframe,UseSecondTimeframe,SecondTimeframe,MA1,MAPeriod1,MAMethod1,MA2,MAPeriod2,MAMethod2,"",false,false,clrNONE,clrNONE,clrNONE,clrNONE
      //cs_strength = iCustom(cur_symbol,0,"Kishore Fredrick\\Currency_Strength_Dual_Logic_v1",8,iPlus);
      cs_strength = iCustom(cur_symbol,0,"Kishore Fredrick\\CSM_final_v6",MinBar,DisplayBuySell,"",MAFast,MASlow,MAType,TF1,"",EnableMTF,TF2,EnableTF3,TF3,EnableTF4,TF4,MtfStrengthCalc,ValueAboveBelow,ValueAboveBelowMTF,"",false,"",false,"",clrNONE,clrNONE,clrNONE,"",false,false,11,iPlus);
     }
   if(EnableVolMeter)
     {
      vol_strength = iCustom(cur_symbol,0,"Kishore Fredrick\\VSM_final_v8",MinBar,ShowVolDirection,"",VolTF1,VSM_VolPeriod,VSM_VolThreshold,ShowLevel2,Level2TF,"",VolLogic,"",EnableVTF2,VTF2,EnableVTF3,VTF3,EnableVTF4,VTF4,"",ShowAll,"",false,VolValueAboveBelow,"",clrNONE,clrNONE,clrNONE,clrNONE,"",false,false,12,iPlus);
      //if(i==5)
      //   Print("vol ="+vol_strength+" T="+Time[iPlus]);
     }
   if(EnableSuperTrend)
     {
      int stbs = (ST_ConfirmationTF==Period()) ? iPlus : iBarShift(cur_symbol,ST_ConfirmationTF,Time[iPlus])+1;
      int stbs2 = (ST_ConfirmationTF==Period()) ? iPlus+1 : iBarShift(cur_symbol,ST_ConfirmationTF,Time[iPlus])+2;
      st1 = iCustom(cur_symbol,ST_ConfirmationTF,"SuperTrend MTF","","",ST_Period,ST_Multiplier,ST_ConfirmationTF,false,2,stbs);
      st2 = iCustom(cur_symbol,ST_ConfirmationTF,"SuperTrend MTF","","",ST_Period,ST_Multiplier,ST_ConfirmationTF,false,1,stbs);
      st12 = iCustom(cur_symbol,ST_ConfirmationTF,"SuperTrend MTF","","",ST_Period,ST_Multiplier,ST_ConfirmationTF,false,2,stbs2);
      st22 = iCustom(cur_symbol,ST_ConfirmationTF,"SuperTrend MTF","","",ST_Period,ST_Multiplier,ST_ConfirmationTF,false,1,stbs2);
      STDirection = (st1!=EMPTY_VALUE) ? 1 : (st2!=EMPTY_VALUE) ? -1 : 0;

      if(EnableAutoPilot)
        {
         int et = iBarShift(cur_symbol,0,EntryTime);
         st1_et = iCustom(cur_symbol,ST_ConfirmationTF,"SuperTrend MTF","","",ST_Period,ST_Multiplier,ST_ConfirmationTF,false,2,et);
         st2_et = iCustom(cur_symbol,ST_ConfirmationTF,"SuperTrend MTF","","",ST_Period,ST_Multiplier,ST_ConfirmationTF,false,1,et);

         if(Time[1]==EntryTime)
           {
            if(st1_et!=EMPTY_VALUE && STBcount<=0)
              {
               STonEntryTime = 1;
               STBcount++;
              }
            else
               if(st2_et!=EMPTY_VALUE && STScount<=0)
                 {
                  STonEntryTime = -1;
                  STScount++;
                 }
            //Print("EntryTime="+EntryTime+" STonEntryTime="+STonEntryTime+" STBcount="+STBcount+" STScount="+STScount);
           }

         if(STDirection!=STonEntryTime && Time[1]>EntryTime)
           {
            if(STonEntryTime == 1)
              {
               STChangeTo = -1;
               STScount++;
              }
            else
               if(STonEntryTime == -1)
                 {
                  STChangeTo = 1;
                  STBcount++;
                 }
            //Print("Time="+Time[1]+" STChangeTo="+STChangeTo+" STDirection="+STDirection+" STonEntryTime="+STonEntryTime+" STBcount="+STBcount+" STScount="+STScount);
           }
        }

      if(EnableST_LowerTF)
        {
         int st2bs = (ST_LowerTF==Period()) ? iPlus : iBarShift(cur_symbol,ST_LowerTF,Time[iPlus])+1;
         int st2bs2 = (ST_LowerTF==Period()) ? iPlus+1 : iBarShift(cur_symbol,ST_LowerTF,Time[iPlus])+2;
         st1LF = iCustom(cur_symbol,ST_LowerTF,"SuperTrend MTF","","",ST_LowerPeriod,ST_LowerMultiplier,ST_LowerTF,false,2,st2bs);
         st2LF = iCustom(cur_symbol,ST_LowerTF,"SuperTrend MTF","","",ST_LowerPeriod,ST_LowerMultiplier,ST_LowerTF,false,1,st2bs);
         st1LF2 = iCustom(cur_symbol,ST_LowerTF,"SuperTrend MTF","","",ST_LowerPeriod,ST_LowerMultiplier,ST_LowerTF,false,2,st2bs2);
         st2LF2 = iCustom(cur_symbol,ST_LowerTF,"SuperTrend MTF","","",ST_LowerPeriod,ST_LowerMultiplier,ST_LowerTF,false,1,st2bs2);
        }
      if(EnableST_MiddleTF)
        {
         int st3bs = (ST_MiddleTF==Period()) ? iPlus : iBarShift(cur_symbol,ST_MiddleTF,Time[iPlus])+1;
         int st3bs2 = (ST_MiddleTF==Period()) ? iPlus+1 : iBarShift(cur_symbol,ST_MiddleTF,Time[iPlus])+2;
         st1MF = iCustom(cur_symbol,ST_MiddleTF,"SuperTrend MTF","","",ST_MiddlePeriod,ST_MiddleMultiplier,ST_MiddleTF,false,2,st3bs);
         st2MF = iCustom(cur_symbol,ST_MiddleTF,"SuperTrend MTF","","",ST_MiddlePeriod,ST_MiddleMultiplier,ST_MiddleTF,false,1,st3bs);
         st1MF2 = iCustom(cur_symbol,ST_MiddleTF,"SuperTrend MTF","","",ST_MiddlePeriod,ST_MiddleMultiplier,ST_MiddleTF,false,2,st3bs2);
         st2MF2 = iCustom(cur_symbol,ST_MiddleTF,"SuperTrend MTF","","",ST_MiddlePeriod,ST_MiddleMultiplier,ST_MiddleTF,false,1,st3bs2);
        }
      if(EnableST_HigherTF)
        {
         int st4bs = (ST_HigherTF==Period()) ? iPlus : iBarShift(cur_symbol,ST_HigherTF,Time[iPlus])+1;
         int st4bs2 = (ST_HigherTF==Period()) ? iPlus+1 : iBarShift(cur_symbol,ST_HigherTF,Time[iPlus])+2;
         st1HF = iCustom(cur_symbol,ST_HigherTF,"SuperTrend MTF","","",ST_HigherPeriod,ST_HigherMultiplier,ST_HigherTF,false,2,st4bs);
         st2HF = iCustom(cur_symbol,ST_HigherTF,"SuperTrend MTF","","",ST_HigherPeriod,ST_HigherMultiplier,ST_HigherTF,false,1,st4bs);
         st1HF2 = iCustom(cur_symbol,ST_HigherTF,"SuperTrend MTF","","",ST_HigherPeriod,ST_HigherMultiplier,ST_HigherTF,false,2,st4bs2);
         st2HF2 = iCustom(cur_symbol,ST_HigherTF,"SuperTrend MTF","","",ST_HigherPeriod,ST_HigherMultiplier,ST_HigherTF,false,1,st4bs2);
        }
      if(EnableSTExit)
        {
         int st5bs = (ST_ExitTF==Period()) ? iPlus : iBarShift(cur_symbol,ST_ExitTF,Time[iPlus])+1;
         int st5bs2 = (ST_ExitTF==Period()) ? iPlus+1 : iBarShift(cur_symbol,ST_ExitTF,Time[iPlus])+2;
         st1EF = iCustom(cur_symbol,ST_ExitTF,"SuperTrend MTF","","",ST_ExitPeriod,ST_ExitMultiplier,0,false,2,st5bs);
         st2EF = iCustom(cur_symbol,ST_ExitTF,"SuperTrend MTF","","",ST_ExitPeriod,ST_ExitMultiplier,0,false,1,st5bs);
         st1EF2 = iCustom(cur_symbol,ST_ExitTF,"SuperTrend MTF","","",ST_ExitPeriod,ST_ExitMultiplier,0,false,2,st5bs2);
         st2EF2 = iCustom(cur_symbol,ST_ExitTF,"SuperTrend MTF","","",ST_ExitPeriod,ST_ExitMultiplier,0,false,1,st5bs2);

         //
         //      if(Time[0]==StrToTime("2021.08.02 07:32"))
         //      Print("st5bs="+st5bs+" T="+Time[st5bs]+" st5bs2="+st5bs2+" T="+Time[st5bs2]+" st1EF2="+st1EF2+" st2EF2="+st2EF+" bs="+iBarShift(cur_symbol,ST_ExitTF,Time[iPlus]));
        }
     }
   if(EnableCS)
     {
      cs_strength = iCustom(cur_symbol,0,"Kishore Fredrick\\CSM_final_v6",MinBar,DisplayBuySell,"",MAFast,MASlow,MAType,TF1,"",EnableMTF,TF2,EnableTF3,TF3,EnableTF4,TF4,MtfStrengthCalc,ValueAboveBelow,ValueAboveBelowMTF,"",false,"",false,"",clrNONE,clrNONE,clrNONE,"",false,false,11,iPlus);
     }
   if(EnableSSM)
     {
      //bool ssmConfCheck = (EnableSSMConfirmation && ConfLocked) ? true : (EnableSSMConfirmation && ConfLocked==false) ? false : true;
      if(ConfLocked)
        {
         ssm_strength = getSSM(0,6,iPlus,confBarShift);
         //./found the issue, ShowSDZones is false that's y it is not adding the target into buffer
         ssm_zonetime = (datetime)getSSM(0,7,iPlus,confBarShift);

         ssm_shiftCons = getSSM(0,9,iPlus,confBarShift);
         ssm_shiftAggr = getSSM(0,10,iPlus,confBarShift);

         ssm_shiftCandle= getSSM(0,13,iPlus,confBarShift);
         ssm_shiftCandleTime = (datetime)getSSM(0,14,iPlus,confBarShift);

         ssm_buystrength = getSSM(0,4,iPlus,confBarShift);

         ssm_sellstrength = getSSM(0,5,iPlus,confBarShift);
         //instead of iPlus, call 0 for touch current candle
         ssm_touchzone = getSSM(TouchHTF,15,0,confBarShift);

         //Print("ssm_touchzone="+ssm_touchzone+" prv="+getSSM(0,15,1,confBarShift)+" pr2="+getSSM(0,15,2,confBarShift)+" confBarShift="+confBarShift+" T="+Time[0]);
         if(ssm_buystrength!=0)
           {
            ssm_buysignaltime= (datetime)getSSM(0,2,iPlus,confBarShift);
           }
         if(ssm_sellstrength!=0)
           {
            ssm_sellsignaltime = (datetime)getSSM(0,3,iPlus,confBarShift);
           }

         if(ssm_shiftCons!=0)
           {
            ssm_shiftConsTime = (datetime)getSSM(0,11,iPlus,confBarShift);
           }
         if(ssm_shiftAggr!=0)
           {
            ssm_shiftAggrTime = (datetime)getSSM(0,12,iPlus,confBarShift);
           }

         if(EnableSSM_HTF)
           {
            int ssmbs1 = (SSM_TF2==Period()) ? iPlus : iBarShift(cur_symbol,SSM_TF2,Time[iPlus]);
            ssm_htf_trend = getSSM(SSM_TF2,8,iPlus,confBarShift);
            //ssm_htf_zonetime = (datetime)iCustom(cur_symbol,0,"Kishore Fredrick\\RIS Kishore SSM",MinBar,ShowDirection,EnableZOE,"",SSM_TF2,SSM_InpDepth,SSM_InpDeviation,SSM_InpBackstep,SSM_zz_hl,Percentage1,Percentage2,SSM_ValueAboveBelow,"",SSM_EnableSuperTrend,SSM_ST_ConfirmationTF,SSM_ST_Period,SSM_ST_Multiplier,"",false,clrNONE,10,false,clrNONE,10,false,clrNONE,10,"",true,clrYellow,clrYellow,clrYellow,clrYellow,clrYellow,false,false,7,iPlus);
           }

         confBarShift = 0;// to set 0 for optimize, or else it will calculate everytime and takes too much time
         //Print("ssm_strength="+ssm_strength+" ssm_shiftCons="+ssm_shiftCons+" ssm_shiftAggr="+ssm_shiftAggr+" ssm_shiftAggrTime="+ssm_shiftAggrTime+" ssm_shiftConsTime="+ssm_shiftConsTime+" T="+Time[iPlus]);
        }
     }

   if(EnableTargetInd)
     {
      int bshift=0,sshift=0;
      if(TargetNumber==1)
        {
         bshift = 0;
         sshift=5;
        }
      else
         if(TargetNumber==2)
           {
            bshift = 1;
            sshift=6;
           }
         else
            if(TargetNumber==3)
              {
               bshift = 2;
               sshift=7;
              }
            else
               if(TargetNumber==4)
                 {
                  bshift = 3;
                  sshift = 8;
                 }
               else
                 {
                  bshift = 0;
                  sshift=5;
                 }

      int bs = (Target_TF==Period()) ? iPlus : iBarShift(cur_symbol,Target_TF,Time[iPlus]);
      btargetind = iCustom(cur_symbol,Target_TF,"Kishore Fredrick\\TargetsRSI_v6",bshift,bs);
      stargetind = iCustom(cur_symbol,Target_TF,"Kishore Fredrick\\TargetsRSI_v6",sshift,bs);
     }
   if(EnableZoneTouch)
     {
      zone_touch = iCustom(cur_symbol,0,"Kishore Fredrick\\RIS ZoneTouch",MinBar,"",cur_sigOPType,PERIOD_CURRENT,SSM_InpDepth,SSM_InpDeviation,SSM_InpBackstep,SSM_zz_hl,Percentage1,Percentage2,SSM_ValueAboveBelow,ExtraShiftZones,"",LOGIC_B,BreachPercentage,ExtendPercentage,"",false,clrAliceBlue,clrAliceBlue,0,0);//read current bar
     }
   if(EnableMACEntry)
     {
      //if(ConfLocked)
      //{
      mac_dir = getMAC(0,2,iPlus,0);

      if(mac_dir==1)
        {
         mac_buytime = (datetime)getMAC(0,3,iPlus,0);
         mac_bcheck = (EnableOverallConfirmation) ? (mac_buytime>=confTime && conf_genTime) : true;
         //Print("mac_bcheck="+mac_bcheck+" mac_dir="+mac_dir+" mac_buytime="+mac_buytime+" confTime="+confTime+" conf_genTime="+conf_genTime+" T="+Time[0]);
        }
      if(mac_dir==-1)
        {
         mac_selltime = (datetime)getMAC(0,4,iPlus,0);
         mac_scheck = (EnableOverallConfirmation) ? (mac_selltime>=confTime && conf_genTime) : true;

        }
      //}

     }
   if(EnableMACTouch)
     {
      if(ConfLocked)
        {
         mac_touch_dir = getMAC(TouchHTF,8,0,confBarShift);
         //Print("mac_touch_bcheck="+mac_touch_bcheck+" mac_touch_dir="+mac_touch_dir+" confTime="+confTime+" confBarShift="+confBarShift+" T="+Time[0]);

         if(mac_touch_dir==1)
           {
            datetime mac_touchtime = (datetime)getMAC(TouchHTF,9,0,confBarShift);
            mac_touch_bcheck = (EnableOverallConfirmation) ? (mac_touchtime>confTime && conf_genTime) : true;

           }
         if(mac_touch_dir==-1)
           {
            datetime mac_touchtime = (datetime)getMAC(TouchHTF,9,0,confBarShift);
            mac_touch_scheck = (EnableOverallConfirmation) ? (mac_touchtime>confTime && conf_genTime) : true;
            //Print("mac_scheck="+mac_scheck+" mac_dir="+mac_dir+" mac_selltime="+mac_selltime+" confTime="+confTime+" conf_genTime="+conf_genTime+" T="+Time[0]);
           }
        }
     }
   if(EnableVolZoneTouch)
     {
      if(ConfLocked)
        {
         double vz_bdir = (cur_sigOPType==OP_BUY) ? getVolZone(TouchHTF,19,0,confBarShift) : EMPTY_VALUE;
         double vz_sdir = (cur_sigOPType==OP_SELL) ? getVolZone(TouchHTF,20,0,confBarShift) : EMPTY_VALUE;

         vz_touch_dir = (vz_bdir!=EMPTY_VALUE) ? 1 : (vz_sdir!=EMPTY_VALUE) ? -1 : 0;
         //Print("vz_touch_dir="+vz_touch_dir+" vz_bdir="+vz_bdir+" vz_sdir="+vz_sdir+" T="+Time[0]);
         if(vz_touch_dir!=0)
           {
            vz_touch_check = (EnableOverallConfirmation) ? (vz_touch_dir!=0) : true;
           }

        }
     }
   if(EnableLiqTouch)
     {
      if(ConfLocked)
        {
         liq_touch_dir = getLiquidityMA(TouchHTF,8,0,confBarShift);
         //Print("mac_touch_bcheck="+mac_touch_bcheck+" mac_touch_dir="+mac_touch_dir+" confTime="+confTime+" confBarShift="+confBarShift+" T="+Time[0]);

         if(liq_touch_dir==1)
           {
            datetime liq_touchtime = (datetime)getLiquidityMA(TouchHTF,9,0,confBarShift);
            liq_touch_bcheck = (EnableOverallConfirmation) ? (liq_touchtime>confTime && conf_genTime) : true;

           }
         if(liq_touch_dir==-1)
           {
            datetime liq_touchtime = (datetime)getLiquidityMA(TouchHTF,9,0,confBarShift);
            liq_touch_scheck = (EnableOverallConfirmation) ? (liq_touchtime>confTime && conf_genTime) : true;
            //Print("mac_scheck="+mac_scheck+" mac_dir="+mac_dir+" mac_selltime="+mac_selltime+" confTime="+confTime+" conf_genTime="+conf_genTime+" T="+Time[0]);
           }
        }
     }
   if(EnableRevTouch)
     {
      if(ConfLocked)
        {
         rev_touch_dir = getReversalMA(TouchHTF,8,0,confBarShift);

         if(rev_touch_dir==1)
           {
            datetime rev_touchtime = (datetime)getReversalMA(TouchHTF,9,0,confBarShift);
            rev_touch_bcheck = (EnableOverallConfirmation) ? (rev_touchtime>confTime && conf_genTime) : true;

           }
         if(rev_touch_dir==-1)
           {
            datetime rev_touchtime = (datetime)getReversalMA(TouchHTF,9,0,confBarShift);
            rev_touch_scheck = (EnableOverallConfirmation) ? (rev_touchtime>confTime && conf_genTime) : true;
            //Print("mac_scheck="+mac_scheck+" mac_dir="+mac_dir+" mac_selltime="+mac_selltime+" confTime="+confTime+" conf_genTime="+conf_genTime+" T="+Time[0]);
           }
        }
     }
   if(EnableSDTouch)
     {
      if(ConfLocked)
        {
         double sd_bdir = (cur_sigOPType==OP_BUY) ? getSD(TouchHTF,52,0,confBarShift) : EMPTY_VALUE;
         double sd_sdir = (cur_sigOPType==OP_SELL) ? getSD(TouchHTF,53,0,confBarShift) : EMPTY_VALUE;
         sd_touch_dir = (sd_bdir!=EMPTY_VALUE) ? 1 : (sd_sdir!=EMPTY_VALUE) ? -1 : 0;


         if(sd_touch_dir!=0)
           {
            sd_touch_check = (EnableOverallConfirmation) ? (sd_touch_dir!=0) : true;
           }
        }
     }
   if(EnablePA1Touch)
     {
      if(ConfLocked)
        {
         double pa1_bdir = (cur_sigOPType==OP_BUY) ? getPA1(TouchHTF,80,0,confBarShift) : EMPTY_VALUE;
         double pa1_sdir = (cur_sigOPType==OP_SELL) ? getPA1(TouchHTF,81,0,confBarShift) : EMPTY_VALUE;

         pa1_touch_dir = (pa1_bdir!=EMPTY_VALUE) ? 1 : (pa1_sdir!=EMPTY_VALUE) ? -1 : 0;
         //Print("pa1_touch_dir="+pa1_touch_dir+" pa1_bdir="+pa1_bdir+" pa1_sdir="+pa1_sdir+" T="+Time[0]);
         if(pa1_touch_dir!=0)
           {
            pa1_touch_check = (EnableOverallConfirmation) ? (pa1_touch_dir!=0) : true;
           }

        }
     }
   if(EnablePA2Touch)
     {
      if(ConfLocked)
        {
         double pa2_bdir = (cur_sigOPType==OP_BUY) ? getPA2(TouchHTF,80,0,confBarShift) : EMPTY_VALUE;
         double pa2_sdir = (cur_sigOPType==OP_SELL) ? getPA2(TouchHTF,81,0,confBarShift) : EMPTY_VALUE;

         pa2_touch_dir = (pa2_bdir!=EMPTY_VALUE) ? 1 : (pa2_sdir!=EMPTY_VALUE) ? -1 : 0;

         if(pa2_touch_dir!=0)
           {
            pa2_touch_check = (EnableOverallConfirmation) ? (pa2_touch_dir!=0) : true;
           }

        }
     }
   if(EnableWedgesTouch)
     {
      if(ConfLocked)
        {
         double wedges_bdir = (cur_sigOPType==OP_BUY) ? getWedges(TouchHTF,57,0,confBarShift) : EMPTY_VALUE;
         double wedges_sdir = (cur_sigOPType==OP_SELL) ? getWedges(TouchHTF,58,0,confBarShift) : EMPTY_VALUE;

         wedges_touch_dir = (wedges_bdir!=EMPTY_VALUE) ? 1 : (wedges_sdir!=EMPTY_VALUE) ? -1 : 0;

         if(wedges_touch_dir!=0)
           {
            wedges_touch_check = (EnableOverallConfirmation) ? (wedges_touch_dir!=0) : true;
           }

        }
     }

   if(EnableMarketShift)
     {
      double msDir = getMarketShift(TouchHTF,SHOW_BOTH,2,iPlus);
     }
   if(EnableVolumeProof)
     {
      double vpBuy = getVolProof(TouchHTF,cur_sigOPType,22,iPlus);
     }
   if(EnableRSIDTouch)
     {
      if(ConfLocked)
        {
         rsid_touch_dir = getRSIDivg(TouchHTF,8,0,confBarShift);

         if(rsid_touch_dir==1)
           {
            datetime rsid_touchtime = (datetime)getRSIDivg(TouchHTF,9,0,confBarShift);
            rsid_touch_bcheck = (EnableOverallConfirmation) ? (rsid_touchtime>confTime && conf_genTime) : true;

           }
         if(rsid_touch_dir==-1)
           {
            datetime rsid_touchtime = (datetime)getRSIDivg(TouchHTF,9,0,confBarShift);
            rsid_touch_scheck = (EnableOverallConfirmation) ? (rsid_touchtime>confTime && conf_genTime) : true;
            //Print("mac_scheck="+mac_scheck+" mac_dir="+mac_dir+" mac_selltime="+mac_selltime+" confTime="+confTime+" conf_genTime="+conf_genTime+" T="+Time[0]);
           }
        }
     }
   if(EnableProfitZoneTouch)
     {
      if(ConfLocked)
        {
         bpz_touch_dir = getProfitZone(PZTF,8,0,confBarShift);
         spz_touch_dir = getProfitZone(PZTF,12,0,confBarShift);
         //Print("pz_touch_dir="+pz_touch_dir+" T="+Time[0]);
         if(bpz_touch_dir==1)
           {
            datetime btouchtime = (datetime)getProfitZone(PZTF,9,0,confBarShift);
            pz_touch_bcheck = (EnableOverallConfirmation) ? (btouchtime>confTime && conf_genTime) : true;
           }
         if(spz_touch_dir==-1)
           {
            datetime stouchtime = (datetime)getProfitZone(PZTF,9,0,confBarShift);
            pz_touch_scheck = (EnableOverallConfirmation) ? (stouchtime>confTime && conf_genTime) : true;
            //Print("mac_scheck="+mac_scheck+" mac_dir="+mac_dir+" mac_selltime="+mac_selltime+" confTime="+confTime+" conf_genTime="+conf_genTime+" T="+Time[0]);
           }
        }
     }
   if(EnableSHC_LiqGrabTrig1 || EnableLGrabArrowEntry)
     {
      liqgrab_dir = getLiquidityGrab(LG_ETF,2,iPlus);
     }
   if(EnableStopHuntCheckForEntry)
      if(EnableSHC_SwingStopM1Trig1 || EnableSHC_SwingStopM1Trig2 || EnableSHC_SwingStopM2Trig1 || EnableSHC_SwingStopM2Trig2 || EnableSHC_SwingStopM3Trig1 || EnableSHC_SwingStopM3Trig2 || EnableSHC_SwingStopM4Trig1 || EnableSHC_SwingStopM4Trig2 || EnableSHC_SwingStopM5Trig1 || EnableSHC_SwingStopM5Trig2)
        {
         double btrig1 = getSwingStopM1(SS_M1_ETF,15,iPlus);
         double btrig2 = getSwingStopM2(SS_M2_ETF,3,iPlus);
         double btrig3 = getSwingStopM3(SS_M3_ETF,15,iPlus);
         double btrig4= getSwingStopM4(SS_M4_ETF,3,iPlus);
         double btrig5= getSwingStopM5(SS_M5_ETF,3,iPlus);

        }
//-------------------------------------
   if(EnableNewsFilter)
     {
      double news = iCustom(cur_symbol,0,"Kishore Fredrick\\FF_News_Filter",0,1);
      checkNews = (news==1) ? true : false;
     }
   if(EnableAsianSession)
     {
      bool asian_trigger=false;
      int bshift=0,sshift=0;

      asian_dir = getAsianSession(Asian_TF,6,iPlus);

      if(Asian_TargetNumber==1)
        {
         bshift = 7;
         sshift = 10;
        }
      else
         if(Asian_TargetNumber==2)
           {
            bshift = 8;
            sshift = 11;
           }
         else
            if(Asian_TargetNumber==3)
              {
               bshift = 9;
               sshift = 12;
              }
      if(EnableAsianTarget)
        {
         basiantarget = getAsianSession(Asian_TF,bshift,iPlus);
         sasiantarget = getAsianSession(Asian_TF,sshift,iPlus);
        }

      //have to change for normal candle entry
      int wchMode = (cur_sigOPType == OP_BUY) ? 3 : (cur_sigOPType == OP_SELL) ? 5 : 0;
      if(EnableAsianTrigger && wchMode!=0)
        {
         datetime asianTime = (datetime)getAsianSession(Asian_TF,wchMode,iPlus);
         asian_trigger = (asianTime>cur_entryTime && Time[0]>=asianTime && Time[0]<=AsianLastTime);
        }
      checkAsianBuy = (asian_dir == 1 || asian_trigger) ? true : false;
      checkAsianSell = (asian_dir == -1 || asian_trigger) ? true : false;
      AsianLastTime=StrToTime((string)TimeYear(TimeLocal())+"."+(string)TimeMonth(TimeLocal())+"."+(string)TimeDay(TimeLocal())+" "+Asian_Last_Time);
     }

   if(EnableZoneMTF)
     {
      int bs = 1;//iBarShift(cur_symbol,ZMTF_TF1,Time[iPlus]);
      zone_mtf_sum = zonemtf(ZMTF_TF1,4,bs);
      //Print("zone_mtf_sum="+zone_mtf_sum+" T="+Time[0]);
     }
   if(EnableFCM)
     {
      int fcmP = stringToTimeFrame(FCM_TF1);
      int fcmbs1 = (fcmP==Period()) ? iPlus : iBarShift(cur_symbol,fcmP,Time[0])+1;
      fcm_usd = iCustom(cur_symbol,fcmP,"Kishore Fredrick\\forex-strength-meter-mtf-indicator",FCM_TF1,"","",FCM_Method,FCM_Fast,FCM_Slow,FCM_Price,MinBar,true,true,true,true,true,true,true,true,false,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,LevelUp2,LevelUp1,LevelDn1,LevelDn2,2,false,false,false,false,false,false,false,false,"",StartPos,ReRunTimeSec,mn_per,mn_fast,w_per,w_fast,d_per,d_fast,h4_per,h4_fast,h1_per,h1_fast,m30_per,m30_fast,m15_per,m15_fast,m5_per,m5_fast,m1_per,m1_fast,0,fcmbs1);
      fcm_eur = iCustom(cur_symbol,fcmP,"Kishore Fredrick\\forex-strength-meter-mtf-indicator",FCM_TF1,"","",FCM_Method,FCM_Fast,FCM_Slow,FCM_Price,MinBar,true,true,true,true,true,true,true,true,false,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,LevelUp2,LevelUp1,LevelDn1,LevelDn2,2,false,false,false,false,false,false,false,false,"",StartPos,ReRunTimeSec,mn_per,mn_fast,w_per,w_fast,d_per,d_fast,h4_per,h4_fast,h1_per,h1_fast,m30_per,m30_fast,m15_per,m15_fast,m5_per,m5_fast,m1_per,m1_fast,1,fcmbs1);
      fcm_gbp = iCustom(cur_symbol,fcmP,"Kishore Fredrick\\forex-strength-meter-mtf-indicator",FCM_TF1,"","",FCM_Method,FCM_Fast,FCM_Slow,FCM_Price,MinBar,true,true,true,true,true,true,true,true,false,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,LevelUp2,LevelUp1,LevelDn1,LevelDn2,2,false,false,false,false,false,false,false,false,"",StartPos,ReRunTimeSec,mn_per,mn_fast,w_per,w_fast,d_per,d_fast,h4_per,h4_fast,h1_per,h1_fast,m30_per,m30_fast,m15_per,m15_fast,m5_per,m5_fast,m1_per,m1_fast,2,fcmbs1);
      fcm_chf = iCustom(cur_symbol,fcmP,"Kishore Fredrick\\forex-strength-meter-mtf-indicator",FCM_TF1,"","",FCM_Method,FCM_Fast,FCM_Slow,FCM_Price,MinBar,true,true,true,true,true,true,true,true,false,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,LevelUp2,LevelUp1,LevelDn1,LevelDn2,2,false,false,false,false,false,false,false,false,"",StartPos,ReRunTimeSec,mn_per,mn_fast,w_per,w_fast,d_per,d_fast,h4_per,h4_fast,h1_per,h1_fast,m30_per,m30_fast,m15_per,m15_fast,m5_per,m5_fast,m1_per,m1_fast,3,fcmbs1);
      fcm_jpy = iCustom(cur_symbol,fcmP,"Kishore Fredrick\\forex-strength-meter-mtf-indicator",FCM_TF1,"","",FCM_Method,FCM_Fast,FCM_Slow,FCM_Price,MinBar,true,true,true,true,true,true,true,true,false,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,LevelUp2,LevelUp1,LevelDn1,LevelDn2,2,false,false,false,false,false,false,false,false,"",StartPos,ReRunTimeSec,mn_per,mn_fast,w_per,w_fast,d_per,d_fast,h4_per,h4_fast,h1_per,h1_fast,m30_per,m30_fast,m15_per,m15_fast,m5_per,m5_fast,m1_per,m1_fast,4,fcmbs1);
      fcm_aud = iCustom(cur_symbol,fcmP,"Kishore Fredrick\\forex-strength-meter-mtf-indicator",FCM_TF1,"","",FCM_Method,FCM_Fast,FCM_Slow,FCM_Price,MinBar,true,true,true,true,true,true,true,true,false,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,LevelUp2,LevelUp1,LevelDn1,LevelDn2,2,false,false,false,false,false,false,false,false,"",StartPos,ReRunTimeSec,mn_per,mn_fast,w_per,w_fast,d_per,d_fast,h4_per,h4_fast,h1_per,h1_fast,m30_per,m30_fast,m15_per,m15_fast,m5_per,m5_fast,m1_per,m1_fast,5,fcmbs1);
      fcm_cad = iCustom(cur_symbol,fcmP,"Kishore Fredrick\\forex-strength-meter-mtf-indicator",FCM_TF1,"","",FCM_Method,FCM_Fast,FCM_Slow,FCM_Price,MinBar,true,true,true,true,true,true,true,true,false,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,LevelUp2,LevelUp1,LevelDn1,LevelDn2,2,false,false,false,false,false,false,false,false,"",StartPos,ReRunTimeSec,mn_per,mn_fast,w_per,w_fast,d_per,d_fast,h4_per,h4_fast,h1_per,h1_fast,m30_per,m30_fast,m15_per,m15_fast,m5_per,m5_fast,m1_per,m1_fast,6,fcmbs1);
      fcm_nzd = iCustom(cur_symbol,fcmP,"Kishore Fredrick\\forex-strength-meter-mtf-indicator",FCM_TF1,"","",FCM_Method,FCM_Fast,FCM_Slow,FCM_Price,MinBar,true,true,true,true,true,true,true,true,false,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,LevelUp2,LevelUp1,LevelDn1,LevelDn2,2,false,false,false,false,false,false,false,false,"",StartPos,ReRunTimeSec,mn_per,mn_fast,w_per,w_fast,d_per,d_fast,h4_per,h4_fast,h1_per,h1_fast,m30_per,m30_fast,m15_per,m15_fast,m5_per,m5_fast,m1_per,m1_fast,7,fcmbs1);

      if(EnableFCM2)
        {
         int fcmP2 = stringToTimeFrame(FCM_TF2);
         int fcmbs2 = (fcmP2==Period()) ? iPlus : iBarShift(cur_symbol,fcmP2,Time[0])+1;
         fcm_usd2 = iCustom(cur_symbol,fcmP2,"Kishore Fredrick\\forex-strength-meter-mtf-indicator",FCM_TF2,"","",FCM_Method,FCM_Fast,FCM_Slow,FCM_Price,MinBar,true,true,true,true,true,true,true,true,false,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,LevelUp2,LevelUp1,LevelDn1,LevelDn2,2,false,false,false,false,false,false,false,false,"",StartPos,ReRunTimeSec,mn_per,mn_fast,w_per,w_fast,d_per,d_fast,h4_per,h4_fast,h1_per,h1_fast,m30_per,m30_fast,m15_per,m15_fast,m5_per,m5_fast,m1_per,m1_fast,0,fcmbs2);
         fcm_eur2 = iCustom(cur_symbol,fcmP2,"Kishore Fredrick\\forex-strength-meter-mtf-indicator",FCM_TF2,"","",FCM_Method,FCM_Fast,FCM_Slow,FCM_Price,MinBar,true,true,true,true,true,true,true,true,false,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,LevelUp2,LevelUp1,LevelDn1,LevelDn2,2,false,false,false,false,false,false,false,false,"",StartPos,ReRunTimeSec,mn_per,mn_fast,w_per,w_fast,d_per,d_fast,h4_per,h4_fast,h1_per,h1_fast,m30_per,m30_fast,m15_per,m15_fast,m5_per,m5_fast,m1_per,m1_fast,1,fcmbs2);
         fcm_gbp2 = iCustom(cur_symbol,fcmP2,"Kishore Fredrick\\forex-strength-meter-mtf-indicator",FCM_TF2,"","",FCM_Method,FCM_Fast,FCM_Slow,FCM_Price,MinBar,true,true,true,true,true,true,true,true,false,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,LevelUp2,LevelUp1,LevelDn1,LevelDn2,2,false,false,false,false,false,false,false,false,"",StartPos,ReRunTimeSec,mn_per,mn_fast,w_per,w_fast,d_per,d_fast,h4_per,h4_fast,h1_per,h1_fast,m30_per,m30_fast,m15_per,m15_fast,m5_per,m5_fast,m1_per,m1_fast,2,fcmbs2);
         fcm_chf2 = iCustom(cur_symbol,fcmP2,"Kishore Fredrick\\forex-strength-meter-mtf-indicator",FCM_TF2,"","",FCM_Method,FCM_Fast,FCM_Slow,FCM_Price,MinBar,true,true,true,true,true,true,true,true,false,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,LevelUp2,LevelUp1,LevelDn1,LevelDn2,2,false,false,false,false,false,false,false,false,"",StartPos,ReRunTimeSec,mn_per,mn_fast,w_per,w_fast,d_per,d_fast,h4_per,h4_fast,h1_per,h1_fast,m30_per,m30_fast,m15_per,m15_fast,m5_per,m5_fast,m1_per,m1_fast,3,fcmbs2);
         fcm_jpy2 = iCustom(cur_symbol,fcmP2,"Kishore Fredrick\\forex-strength-meter-mtf-indicator",FCM_TF2,"","",FCM_Method,FCM_Fast,FCM_Slow,FCM_Price,MinBar,true,true,true,true,true,true,true,true,false,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,LevelUp2,LevelUp1,LevelDn1,LevelDn2,2,false,false,false,false,false,false,false,false,"",StartPos,ReRunTimeSec,mn_per,mn_fast,w_per,w_fast,d_per,d_fast,h4_per,h4_fast,h1_per,h1_fast,m30_per,m30_fast,m15_per,m15_fast,m5_per,m5_fast,m1_per,m1_fast,4,fcmbs2);
         fcm_aud2 = iCustom(cur_symbol,fcmP2,"Kishore Fredrick\\forex-strength-meter-mtf-indicator",FCM_TF2,"","",FCM_Method,FCM_Fast,FCM_Slow,FCM_Price,MinBar,true,true,true,true,true,true,true,true,false,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,LevelUp2,LevelUp1,LevelDn1,LevelDn2,2,false,false,false,false,false,false,false,false,"",StartPos,ReRunTimeSec,mn_per,mn_fast,w_per,w_fast,d_per,d_fast,h4_per,h4_fast,h1_per,h1_fast,m30_per,m30_fast,m15_per,m15_fast,m5_per,m5_fast,m1_per,m1_fast,5,fcmbs2);
         fcm_cad2 = iCustom(cur_symbol,fcmP2,"Kishore Fredrick\\forex-strength-meter-mtf-indicator",FCM_TF2,"","",FCM_Method,FCM_Fast,FCM_Slow,FCM_Price,MinBar,true,true,true,true,true,true,true,true,false,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,LevelUp2,LevelUp1,LevelDn1,LevelDn2,2,false,false,false,false,false,false,false,false,"",StartPos,ReRunTimeSec,mn_per,mn_fast,w_per,w_fast,d_per,d_fast,h4_per,h4_fast,h1_per,h1_fast,m30_per,m30_fast,m15_per,m15_fast,m5_per,m5_fast,m1_per,m1_fast,6,fcmbs2);
         fcm_nzd2 = iCustom(cur_symbol,fcmP2,"Kishore Fredrick\\forex-strength-meter-mtf-indicator",FCM_TF2,"","",FCM_Method,FCM_Fast,FCM_Slow,FCM_Price,MinBar,true,true,true,true,true,true,true,true,false,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,clrNONE,LevelUp2,LevelUp1,LevelDn1,LevelDn2,2,false,false,false,false,false,false,false,false,"",StartPos,ReRunTimeSec,mn_per,mn_fast,w_per,w_fast,d_per,d_fast,h4_per,h4_fast,h1_per,h1_fast,m30_per,m30_fast,m15_per,m15_fast,m5_per,m5_fast,m1_per,m1_fast,7,fcmbs2);
        }
     }
   int major_bar_shift = (MajorTF==Period()) ? iPlus : iBarShift(cur_symbol,MajorTF,Time[iPlus])+1;
   int minor_bar_shift = (MinorTF==Period()) ? iPlus : iBarShift(cur_symbol,MinorTF,Time[iPlus])+1;

   major_high  = iHigh(cur_symbol,MajorTF,major_bar_shift);
   major_low   = iLow(cur_symbol,MajorTF,major_bar_shift);
   major_close = iClose(cur_symbol,MajorTF,major_bar_shift);
   major_PP  = (major_high + major_low + major_close)/3.0;
   major_R1 = 2*major_PP-major_low;
   major_S1 = 2*major_PP-major_high;

   minor_high  = iHigh(cur_symbol,MinorTF,minor_bar_shift);
   minor_low   = iLow(cur_symbol,MinorTF,minor_bar_shift);
   minor_close = iClose(cur_symbol,MinorTF,minor_bar_shift);
   minor_PP  = (minor_high + minor_low + minor_close)/3.0;
   minor_R1 = 2*minor_PP-minor_low;
   minor_S1 = 2*minor_PP-minor_high;


   int cur_tf = PERIOD_CURRENT;

   double O1 = iOpen(cur_symbol,cur_tf,line+1);
   double H1 = iHigh(cur_symbol,cur_tf,line+1);
   double L1 = iLow(cur_symbol,cur_tf,line+1);
   double C1 = iClose(cur_symbol,cur_tf,line+1);
   long V1 = iVolume(cur_symbol,cur_tf,line+1);
   double Range1 = H1 - L1;

   double O2 = iOpen(cur_symbol,cur_tf,line+2);
   double H2 = iHigh(cur_symbol,cur_tf,line+2);
   double L2 = iLow(cur_symbol,cur_tf,line+2);
   double C2 = iClose(cur_symbol,cur_tf,line+2);
   double Range2 = H2 - L2;
   long V2 = iVolume(cur_symbol,cur_tf,line+2);

   double O3 = iOpen(cur_symbol,cur_tf,line+3);
   double H3 = iHigh(cur_symbol,cur_tf,line+3);
   double L3 = iLow(cur_symbol,cur_tf,line+3);
   double C3 = iClose(cur_symbol,cur_tf,line+3);

   double mid2 = (H2 + L2)/2;
   double body2 = ((H2 - L2)!=0) ? (MathAbs(O2 - C2)) / (H2 - L2) : 0;
   double body1 = ((H1 - L1)!=0) ? (MathAbs(O1 - C1)) / (H1 - L1) : 0;

   double gcandle = ((H1 - L1)!=0) ? (C1-L1) / (H1-L1) : 0;
   double rcandle = ((H1 - L1)!=0) ? (H1-C1) / (H1-L1) : 0;

   double b_shadow1_hc = ((H1 - L1)!=0) ? (MathAbs(H1 - C1)) / (H1 - L1) : 0;
   double b_shadow1_ho = ((H1 - L1)!=0) ? (MathAbs(H1 - O1)) / (H1 - L1) : 0;
   double b_shadow1_lo = ((H1 - L1)!=0) ? (MathAbs(O1 - L1)) / (H1 - L1) : 0;
   double b_shadow1_lc = ((H1 - L1)!=0) ? (MathAbs(C1 - L1)) / (H1 - L1) : 0;

   double s_shadow1_hc = ((H1 - L1)!=0) ? (MathAbs(H1 - C1)) / (H1 - L1) : 0;
   double s_shadow1_ho = ((H1 - L1)!=0) ? (MathAbs(H1 - O1)) / (H1 - L1) : 0;
   double s_shadow1_lo = ((H1 - L1)!=0) ? (MathAbs(O1 - L1)) / (H1 - L1) : 0;
   double s_shadow1_lc = ((H1 - L1)!=0) ? (MathAbs(C1 - L1)) / (H1 - L1) : 0;

   double b_shadow2_hc = ((H2 - L2)!=0) ? (MathAbs(H2 - C2)) / (H2 - L2) : 0;
   double b_shadow2_ho = ((H2 - L2)!=0) ? (MathAbs(H2 - O2)) / (H2 - L2) : 0;
   double b_shadow2_lo = ((H2 - L2)!=0) ? (MathAbs(O2 - L2)) / (H2 - L2) : 0;
   double b_shadow2_lc = ((H2 - L2)!=0) ? (MathAbs(C2 - L2)) / (H2 - L2) : 0;

   double s_shadow2_hc = ((H2 - L2)!=0) ? (MathAbs(H2 - C2)) / (H2 - L2) : 0;
   double s_shadow2_ho = ((H2 - L2)!=0) ? (MathAbs(H2 - O2)) / (H2 - L2) : 0;
   double s_shadow2_lc = ((H2 - L2)!=0) ? (MathAbs(C2 - L2)) / (H2 - L2) : 0;
   double s_shadow2_lo = ((H2 - L2)!=0) ? (MathAbs(O2 - L2)) / (H2 - L2) : 0;


   double VolBuf = 0;
   for(int z=VolPeriod+1; z>1; z--)
     {
      VolBuf += (double)iVolume(cur_symbol, 0, z);
     }
   VolBuf = VolBuf / VolPeriod;

   double stdbar = VolBuf * VolThreshold;
//bool volCond = (EnableVolCheck==false) ? false : (EnableVolCheck && Volume[iPlus] > stdbar) ? true : false;
   bool volCond = (EnableVolCheck) ? (iVolume(cur_symbol, 0, iPlus) > stdbar) : true;//else changed false to true.

   range_check = (EnableRangeCheck && !EnableReverseATR) ? (Range1 < Atr*ATRMultiplier) : (EnableRangeCheck && EnableReverseATR) ? (Range1 > Atr*ATRMultiplier) : true;
   range_check = (EnableCRC) ? (crc==1) : range_check;
   crcMax = (EnableCRC) ? (crc_max == 1) : true;

   int order_count = GetOrderCount(-1);
   bool lo_check = true; //LastOrderCheck();

//Print(order_count, ", ", lo_check);

   if(order_count == 0 && lo_check) // && last_order_shift>0)
     {
      allow_trade = true;

      allow_grid_trade = false;
      allow_grid_exit = false;
      trade_count= 1;
      bet_count = 1;
      //buy_above = 1000000;
      //sell_below = 0;
     }
   else
     {
      allow_trade = true;
      //SingleOrderTrailingSL();
      //if(order_count>=MaxRunningOrders && MaxRunningOrders!=0)
      //  {
      //   allow_trade=false;
      //  }
      //else
      //   if((MaxRunningOrders==0 || order_count<MaxRunningOrders) && lo_check)
      //     {
      //      allow_trade=true;
      //     }
     }

   if(EnableSSM && EnableSSMLimitOrder && !EnableSSMChrono)
     {
      //Condition 2 - Limit Orders
      Check_SSM_Orders();
     }

   if(ConfLocked && conf_genTime)
     {
      Check_All_LOrders();
     }

//if (cur_symbol=="CHFJPY") Print(allow_trade);

   if(allow_trade)
     {

      bool checkBuy=false,checkSell=false;

      int ActiveBuyOrders = GetTotalOrders("Active",OP_BUY);
      int ActiveSellOrders = GetTotalOrders("Active",OP_SELL);

      b_pcheck=(EnablePivot) ? false : false;
      s_pcheck=(EnablePivot) ? false : false;
      r1check=false;
      s1check=false;
      if(EnablePivot && ((H1>major_PP && L1<major_PP && C1>=major_PP) || (H1>minor_PP && L1<minor_PP && C1>minor_PP)))
        {
         b_pcheck = true;
        }
      if(EnablePivot && ((H1>major_PP && L1<major_PP && C1<=major_PP) || (H1>minor_PP && L1<minor_PP && C1<minor_PP)))
        {
         s_pcheck = true;
        }
      if(EnablePivot && ((H1>major_R1 && L1<major_R1) || (H1>minor_R1 && L1<minor_R1)))
        {
         r1check = true;
        }
      if(EnablePivot && ((H1>major_S1 && L1<major_S1) || (H1>minor_S1 && L1<minor_S1)))
        {
         s1check = true;
        }

      bool b_psr = (b_pcheck || r1check || s1check);
      bool s_psr = (b_pcheck || r1check || s1check);

      bool gen_check=false;

      bool b_mc = false, s_mc = false;
      if(EnableMyCandle && !gen_check)
        {
         b_mc = (bdirection_check && C1>O1 && gcandle>BodySize1_MC);
         s_mc = (sdirection_check && C1<O1 && rcandle>BodySize1_MC);

         string wght="";
         bcond_Count = CountConditions("MC",b_mc,volCond,b_psr,wght);
         scond_Count  = CountConditions("MC",s_mc,volCond,s_psr,wght);

         bcond_Count_Check = (bcond_Count>=CondCheck  && b_mc);
         scond_Count_Check = (scond_Count>=CondCheck  && s_mc);
         //if(i==5)
         //   Print("b_pp="+b_pp+" s_pp="+s_pp+" C1="+C1+" C2="+C2+" T="+Time[i]);
         gen_check = (bcond_Count_Check) ? true : (scond_Count_Check) ? true : false;
         whichPattern = (gen_check) ? "MC" : "";
         candlestick_confirmed = (gen_check) ? true : false;

         //Print("b_mc="+b_mc+" s_mc="+s_mc+" bcond_Count_Check="+bcond_Count_Check+" scond_Count_Check="+scond_Count_Check+" candlestick_confirmed="+candlestick_confirmed+" T="+Time[0]);
        }
      if(EnableEntryCandle)
        {

         bool becCheck=false,secCheck=false;
         if(EnableECMethod1 && bdirection_check && ecdir == 1)
           {
            //Print("Entry Candle Method1 Buy confirmed on "+Symbol()+" at "+TimeToStr(Time[iPlus]));
            becCheck = true;
            ecName = "_M1";
           }
         else
            if(EnableECMethod1 && sdirection_check && ecdir == -1)
              {
               //Print("Entry Candle Method1 Sell confirmed on "+Symbol()+" at "+TimeToStr(Time[iPlus]));
               secCheck = true;
               ecName = "_M1";
              }
         if(EnableECMethod2 && !becCheck && bdirection_check && ecdir2 == 1)
           {
            //Print("Entry Candle Method2 Buy confirmed on "+Symbol()+" at "+TimeToStr(Time[iPlus]));
            becCheck = true;
            ecName = "_M2";
           }
         else
            if(EnableECMethod2 && !secCheck && sdirection_check && ecdir2 == -1)
              {
               //Print("Entry Candle Method2 Sell confirmed on "+Symbol()+" at "+TimeToStr(Time[iPlus]));
               secCheck = true;
               ecName = "_M2";
              }

         bmac = (EnableEntryCandle) ? (bdirection_check && becCheck) : true;
         smac = (EnableEntryCandle) ? (sdirection_check && secCheck) : true;
         //if (ecdir!=0) Print(cur_symbol, ", ", bmac, ", ", bdirection_check, ", ", becCheck);
         //Print("Sym = "+cur_symbol+" macdir="+macdir+" T="+Time[iPlus]);
        }
      if(EnablePowerCandle)
        {
         double pcdir = getPowerCandle(0,SHOW_BOTH,2,iPlus);
         bpowcand = (EnablePowerCandle) ? (bdirection_check && pcdir == 1) : true;
         spowcand= (EnablePowerCandle) ? (sdirection_check && pcdir == -1) : true;
         //Print("spowcand="+spowcand+" pcdir="+pcdir+" T="+Time[iPlus]);
        }

      bool brsi1 = (EnableRSI) ? (rsi1<RSI1_OverBB) : true;
      bool srsi1 = (EnableRSI) ? (rsi1>RSI1_OverAS) : true;

      bool brsi2 = (EnableRSI2) ? (rsi2<RSI2_OverBB) : true;
      bool srsi2 = (EnableRSI2) ? (rsi2>RSI2_OverAS) : true;

      bool brsi3 = (EnableRSI3) ? (rsi3<RSI3_OverBB) : true;
      bool srsi3 = (EnableRSI3) ? (rsi3>RSI3_OverAS) : true;

      bool b_rsi_check = brsi1 && brsi2 && brsi3;
      bool s_rsi_check = srsi1 && srsi2 && srsi3;

      bool ci_check = (EnableChoppiness) ? (ci1<CI_TriggerLevel) : true;
      bool b_vi_check = (!EnableVortex) ? true : (EnableVortex && vi1>vi2 && vi1>VI_TriggerLevel) ? true : false;
      bool s_vi_check = (!EnableVortex) ? true : (EnableVortex && vi2>vi1 && vi2>VI_TriggerLevel) ? true : false;

      bool b_ma_oc = (ConsiderOpen) ? iClose(cur_symbol, 0, iPlus)>ma && iOpen(cur_symbol, 0, iPlus)>ma : iClose(cur_symbol, 0, iPlus)>ma;
      bool s_ma_oc = (ConsiderOpen) ? iClose(cur_symbol, 0, iPlus)<ma && iOpen(cur_symbol, 0, iPlus)<ma : iClose(cur_symbol, 0, iPlus)<ma;

      bool b_ma_oc2 = (ConsiderOpen2) ? iClose(cur_symbol, 0, iPlus)>ma2 && iOpen(cur_symbol, 0, iPlus)>ma2 : iClose(cur_symbol, 0, iPlus)>ma2;
      bool s_ma_oc2 = (ConsiderOpen2) ? iClose(cur_symbol, 0, iPlus)<ma2 && iOpen(cur_symbol, 0, iPlus)<ma2 : iClose(cur_symbol, 0, iPlus)<ma2;

      bool b_ma_check = (!EnableMA) ? true : (EnableMA && b_ma_oc) ? true : false;
      bool s_ma_check = (!EnableMA) ? true : (EnableMA && s_ma_oc) ? true : false;

      bool b_ma_check2 = (!EnableMA2) ? true : (EnableMA2 && b_ma_oc2) ? true : false;
      bool s_ma_check2 = (!EnableMA2) ? true : (EnableMA2 && s_ma_oc2) ? true : false;

      bool b_ma_co_check = (EnableMACrossover) ? (ma1_co > ma2_co) : true;
      bool s_ma_co_check = (EnableMACrossover) ? (ma1_co < ma2_co) : true;

      bool b_ma_arrow_check  = (EnableMAArrow) ? (ma1_co > ma2_co && ma1_coPrev < ma2_coPrev) : true;
      bool s_ma_arrow_check  = (EnableMAArrow) ? (ma1_co < ma2_co && ma1_coPrev > ma2_coPrev) : true;


      bool maadci = (EnableMADCI) ? (maad_ci<MAAD_CI_TriggerLevel) : true;

      bool bmaadrsi = (EnableMADRSI) ? (maad_rsi<MAAD_RSI1_OverBB) : true;
      bool smaadrsi = (EnableMADRSI) ? (maad_rsi>MAAD_RSI1_OverAS) : true;

      bool b_ma_arrow0_check  = (EnableMAArrowDyn) ? (ma1_co0 > ma2_co0 && ma1_coPrev0 < ma2_coPrev0 && maadci && bmaadrsi) : false;
      bool s_ma_arrow0_check  = (EnableMAArrowDyn) ? (ma1_co0 < ma2_co0 && ma1_coPrev0 > ma2_coPrev0 && maadci && smaadrsi) : false;

      //nzdjpy 04.02.2022 05:50 crossover issue solved by removing gencheck
      if((EnableMAArrow || EnableMAArrowDyn))// && !gen_check)
        {

         bcond_Count_Check = (b_ma_arrow0_check) ? true : bcond_Count_Check;
         scond_Count_Check = (s_ma_arrow0_check) ? true : scond_Count_Check;
         gen_check = (b_ma_arrow0_check) ? true : (s_ma_arrow0_check) ? true : false;

         whichPattern = (gen_check) ? "MAA" : (whichPattern!="") ? whichPattern : "";
        }

      bool b_st_check = (EnableSuperTrend) ? ((st1==st2 && st22!=EMPTY_VALUE) || (st1!=EMPTY_VALUE)) : true;
      bool s_st_check = (EnableSuperTrend) ? ((st1==st2 && st12!=EMPTY_VALUE) || (st2!=EMPTY_VALUE)) : true;

      bool b_stLF_check = (EnableSuperTrend && EnableST_LowerTF) ? ((st1LF==st2LF && st2LF2!=EMPTY_VALUE) || (st1LF!=EMPTY_VALUE)) : true;
      bool s_stLF_check = (EnableSuperTrend && EnableST_LowerTF) ? ((st1LF==st2LF && st1LF2!=EMPTY_VALUE) || (st2LF!=EMPTY_VALUE)) : true;

      bool b_stMF_check = (EnableSuperTrend && EnableST_MiddleTF) ? ((st1MF==st2MF && st2MF2!=EMPTY_VALUE) || (st1MF!=EMPTY_VALUE)) : true;
      bool s_stMF_check = (EnableSuperTrend && EnableST_MiddleTF) ? ((st1LF==st2LF && st1LF2!=EMPTY_VALUE) || (st2MF!=EMPTY_VALUE)) : true;

      bool b_stHF_check = (EnableSuperTrend && EnableST_HigherTF) ? ((st1HF==st2HF && st2HF2!=EMPTY_VALUE) || (st1HF!=EMPTY_VALUE)) : true;
      bool s_stHF_check = (EnableSuperTrend && EnableST_HigherTF) ? ((st1HF==st2HF && st1HF2!=EMPTY_VALUE) || (st2HF!=EMPTY_VALUE)) : true;

      bool b_SuperTrend = (b_st_check && b_stLF_check && b_stMF_check && b_stHF_check);
      bool s_SuperTrend = (s_st_check && s_stLF_check && s_stMF_check && s_stHF_check);

      bool b_zz = (EnableZigZagMS) ? (zz_lastSig1 == 1 || zz_lastSig1 == 4) : true;
      bool s_zz = (EnableZigZagMS) ? (zz_lastSig1 == 2 || zz_lastSig1 == 3) : true;

      bool b_zz2 = (EnableZigZagMS2) ? (zz_lastSig2 == 1 || zz_lastSig2 == 4) : true;
      bool s_zz2 = (EnableZigZagMS2) ? (zz_lastSig2 == 2 || zz_lastSig2 == 3) : true;

      b_zz2 = (EnableZigZagMS2) ? b_zz2 : false;
      s_zz2 = (EnableZigZagMS2) ? s_zz2 : false;

      bool borand = (IsOR) ? (b_zz || b_zz2) : (b_zz && b_zz2) ;
      bool sorand = (IsOR) ? (s_zz || s_zz2) : (s_zz && s_zz2) ;

      bool b_kzz = (EnableKZZ && EnableKZZPrevDay) ? (kzz==1) : (EnableKZZ && !EnableKZZPrevDay) ? (kzz==1 && kzzTime>=EntryTime && kzzTime<=ExitTime) : true;
      bool s_kzz = (EnableKZZ && EnableKZZPrevDay) ? (kzz==-1) : (EnableKZZ && !EnableKZZPrevDay) ? (kzz==-1 && kzzTime>=EntryTime && kzzTime<=ExitTime) : true;

      if(EnableKZZPrevDay)
        {
         datetime prevday = iTime(cur_symbol,PERIOD_D1,1);
         bool kzzPDay = (kzzTime>prevday) ? true : false;

         b_kzz = b_kzz && kzzPDay;
         s_kzz = s_kzz && kzzPDay;
        }

      bool b_kzz2 = (EnableKZZ2) ? (kzz2==1 &&  kzzTime2>=obos_buyTime && kzzTime2>=EntryTime && kzzTime2<=ExitTime) : true;
      bool s_kzz2 = (EnableKZZ2) ? (kzz2==-1 && kzzTime2>=obos_sellTime && kzzTime2>=EntryTime && kzzTime2<=ExitTime) : true;

      bool b_obos = (EnableOBOS) ? (obos_buy==1 && obos_buyTime>=kzzTime) : true;
      bool s_obos = (EnableOBOS) ? (obos_sell==-1 && obos_sellTime>=kzzTime) : true;

      bool bcs_check = (EnableCS && ConsiderZero) ? (cs_strength==0 || cs_strength==1) : (EnableCS && !ConsiderZero) ? (cs_strength==1) : true;
      bool scs_check = (EnableCS && ConsiderZero) ? (cs_strength==0 || cs_strength==-1) : (EnableCS && !ConsiderZero) ? (cs_strength==1) : true;

      bool bvsm_check = (EnableVolMeter) ? (vol_strength == 1) : true;
      bool svsm_check = (EnableVolMeter) ? (vol_strength == -1) : true;

      //change cur_entryTime to EntryTime for testing, for live it should be like this ssm_buysignaltime>=cur_entryTime
      bool bssm_check = (EnableSSM && EnableSSMCandle) ? (ssm_buystrength>=SSM_CandleValue && ssm_buysignaltime>=cur_entryTime && ssm_buysignaltime>=EntryTime && conf_genTime) : (EnableSSM && EnableSSMCandle==false) ? false : true;
      bool sssm_check = (EnableSSM && EnableSSMCandle) ? (ssm_sellstrength<=-SSM_CandleValue && ssm_sellsignaltime>=cur_entryTime && ssm_sellsignaltime>=EntryTime && conf_genTime) : (EnableSSM && EnableSSMCandle==false) ? false : true;

      bssm_check = (EnableSSM && EnableSSMShiftCandle && !bssm_check) ? (ssm_shiftCandle>=SSM_ShiftCandleValue && ssm_shiftCandleTime>=cur_entryTime && ssm_shiftCandleTime>=EntryTime && conf_genTime) : (EnableSSM && !EnableSSMShiftCandle) ? bssm_check : true;
      sssm_check = (EnableSSM && EnableSSMShiftCandle && !sssm_check) ? (ssm_shiftCandle<=-SSM_ShiftCandleValue && ssm_shiftCandleTime>=cur_entryTime && ssm_shiftCandleTime>=EntryTime && conf_genTime) : (EnableSSM && !EnableSSMShiftCandle) ? sssm_check : true;

      //ma dynamic true and have value then zonetouch not considered
      bool bzonetouch_check = (EnableZoneTouch) ? (zone_touch==1) : true;
      bool szonetouch_check = (EnableZoneTouch) ? (zone_touch==-1) : true;

      bool bzonemtf_check = (EnableZoneMTF) ? (zone_mtf_sum>=SumupValue && bmac && conf_genTime) : true;
      bool szonemtf_check = (EnableZoneMTF) ? (zone_mtf_sum<=-SumupValue && smac && conf_genTime) : true;

      int indcount = 0;
      if(EnableMACrossover)
         indcount++;
      if(EnableVolMeter)
         indcount++;
      if(EnableCS)
         indcount++;

      //Condtion Count Checking
      string wght="";
      bool b_indCount = CountConditions("Ind",b_ma_co_check,bcs_check,bvsm_check,wght) >= CondCount && indcount>=CondCount;
      bool s_indCount = CountConditions("Ind",s_ma_co_check,scs_check,svsm_check,wght) >= CondCount && indcount>=CondCount;

      if(EnableSSM)
        {
         bool ssmB = (ssm_touchzone==1) ? true : false;
         bool ssmS = (ssm_touchzone==-1) ? true : false;
         string weight="";
         b_indCount = CountConditions("Ind",ssmB,bcs_check,bvsm_check,weight) >= CondCount;
         s_indCount = CountConditions("Ind",ssmS,scs_check,svsm_check,weight) >= CondCount;
        }

      if(EnableZIZ)
        {
         bool zizB = (ziz_touchzone==1) ? true : false;
         bool zizS = (ziz_touchzone==-1) ? true : false;
         string weight="";
         b_indCount = CountConditions("Ind",zizB,bcs_check,bvsm_check,weight) >= CondCount;
         s_indCount = CountConditions("Ind",zizS,scs_check,svsm_check,weight) >= CondCount;
        }

      bool bfscan_check = (EnableFileScanner) ? (cur_sigType == "BUY" && Time[0]>=cur_entryTime && Time[0]<cur_exitTime) : true;
      bool sfscan_check = (EnableFileScanner) ? (cur_sigType == "SELL" && Time[0]>=cur_entryTime && Time[0]<cur_exitTime) : true;
      //if (ecdir!=0) Print(cur_symbol, ", ", cur_sigType, ", ", cur_entryTime, ", ", cur_exitTime);
      //if (MagicNumber==22) Print("3: 22 is here");
      //if (MagicNumber==4321 && cur_symbol=="EURJPY") Print("3: 4321 is here, ", cur_symbol, ", ", bfscan_check, ", ", sfscan_check, ", ", cur_entryTime, ", ", cur_exitTime);


      //code 101
      //ZoneMTF 4 means direct entry after SSM confirmation
      bool bcond101 = (EnableDirectZMTF && EnableZoneMTF && zone_mtf_sum==4 && b_rsi_check && bfscan_check && conf_genTime && candlestick_confirmed) ? true : false;
      bool scond101 = (EnableDirectZMTF && EnableZoneMTF && zone_mtf_sum==-4 && s_rsi_check && sfscan_check && conf_genTime && candlestick_confirmed) ? true : false;

      if(bcond101)
        {
         PlaceCandleEntry(OP_BUY,"101",iPlus,"102",iPlus);
        }
      else
         if(scond101)
           {
            PlaceCandleEntry(OP_SELL,"101",iPlus,"102",iPlus);
           }

      //code 109
      //removed bssm_check & sssm_check condition
      //Print("ssm_touchzone="+ssm_touchzone+" smac="+smac+" sssm_check="+sssm_check+" s_rsi_check="+s_rsi_check+" sfscan_check="+sfscan_check+" conf_genTime="+conf_genTime+" candlestick_confirmed="+candlestick_confirmed+" T="+Time[0]);
      bool bcondSTouch = (EnableSSMTouchEntry && EnableSSM && ssm_touchzone==1 && bmac && b_rsi_check && bfscan_check && conf_genTime && candlestick_confirmed) ? true : false;
      bool scondSTouch = (EnableSSMTouchEntry && EnableSSM && ssm_touchzone==-1 && smac && s_rsi_check && sfscan_check && conf_genTime && candlestick_confirmed) ? true : false;
      if(bcondSTouch)
        {
         PlaceCandleEntry(OP_BUY,"109",iPlus,"110",iPlus);
        }
      else
         if(scondSTouch)
           {
            PlaceCandleEntry(OP_SELL,"109",iPlus,"110",iPlus);
           }

      //code 111
      bool bconZMTFT = (EnableZMTFTouchEntry && EnableZoneMTF && bzonemtf_check && b_rsi_check && bfscan_check && conf_genTime && candlestick_confirmed) ? true : false;
      bool sconZMTFT = (EnableZMTFTouchEntry && EnableZoneMTF && szonemtf_check && s_rsi_check && sfscan_check && conf_genTime && candlestick_confirmed) ? true : false;
      if(bconZMTFT)
        {
         PlaceCandleEntry(OP_BUY,"111",iPlus,"112",iPlus);
        }
      else
         if(sconZMTFT)
           {
            PlaceCandleEntry(OP_SELL,"111",iPlus,"112",iPlus);
           }

      //code 113
      //MAC entry means MACrossover arrow entry
      bool bcond113 = (EnableMACEntry && mac_dir==1 && mac_bcheck && conf_genTime && bfscan_check) ? true : false;
      bool scond113 = (EnableMACEntry && mac_dir==-1 && mac_scheck && conf_genTime && sfscan_check) ? true : false;
      //Print("bcond113="+bcond113+" mac_dir="+mac_dir+" mac_bcheck="+mac_bcheck+" conf_genTime="+conf_genTime+" bfscan_check="+bfscan_check+" T="+Time[iPlus]);
      if(bcond113)
        {
         PlaceCandleEntry(OP_BUY,"113",iPlus,"114",iPlus);
        }
      else
         if(scond113)
           {
            PlaceCandleEntry(OP_SELL,"113",iPlus,"114",iPlus);
           }

      //code 119
      //MAC touch entry when mac m5 touch with mycandle
      //Print("mac_touch_dir="+mac_touch_dir+" bmac="+bmac+" smac="+smac+" mac_touch_bcheck="+mac_touch_bcheck+" mac_touch_scheck="+mac_touch_scheck+" T="+Time[0]);
      bool bcond119 = (EnableMACTouch && mac_touch_dir==1 && bmac && mac_touch_bcheck && conf_genTime && bfscan_check && candlestick_confirmed) ? true : false;
      bool scond119 = (EnableMACTouch && mac_touch_dir==-1 && smac && mac_touch_scheck && conf_genTime && sfscan_check && candlestick_confirmed) ? true : false;
      if(bcond119)
        {
         PlaceCandleEntry(OP_BUY,"119",iPlus,"120",iPlus);
        }
      else
         if(scond119)
           {
            PlaceCandleEntry(OP_SELL,"119",iPlus,"120",iPlus);
           }


      //code 123
      //MA Liquidity Touch
      bool bliqma_touch = (EnableLiqTouch && liq_touch_dir==1 && bmac && liq_touch_bcheck && conf_genTime && bfscan_check && candlestick_confirmed) ? true : false;
      bool sliqma_touch = (EnableLiqTouch && liq_touch_dir==-1 && smac && liq_touch_scheck && conf_genTime && sfscan_check && candlestick_confirmed) ? true : false;
      if(bliqma_touch)
        {
         PlaceCandleEntry(OP_BUY,"123",iPlus,"124",iPlus);
        }
      else
         if(sliqma_touch)
           {
            PlaceCandleEntry(OP_SELL,"123",iPlus,"124",iPlus);
           }

      //code 129
      //MA Reversal Touch
      bool brevma_touch = (EnableRevTouch && rev_touch_dir==1 && bmac && rev_touch_bcheck && conf_genTime && bfscan_check && candlestick_confirmed) ? true : false;
      bool srevma_touch = (EnableRevTouch && rev_touch_dir==-1 && smac && rev_touch_scheck && conf_genTime && sfscan_check && candlestick_confirmed) ? true : false;
      if(brevma_touch)
        {
         PlaceCandleEntry(OP_BUY,"129",iPlus,"130",iPlus);
        }
      else
         if(srevma_touch)
           {
            PlaceCandleEntry(OP_SELL,"129",iPlus,"130",iPlus);
           }

      //code 133
      //Volume Price Zone  Touch
      bool bvz_touch = (EnableVolZoneTouch && vz_touch_dir==1 && bmac && vz_touch_check && conf_genTime && bfscan_check && candlestick_confirmed) ? true : false;
      bool svz_touch = (EnableVolZoneTouch && vz_touch_dir==-1 && smac && vz_touch_check && conf_genTime && sfscan_check && candlestick_confirmed) ? true : false;
      if(bvz_touch)
        {
         PlaceCandleEntry(OP_BUY,"133",iPlus,"134",iPlus);
        }
      else
         if(svz_touch)
           {
            PlaceCandleEntry(OP_SELL,"133",iPlus,"134",iPlus);
           }

      //code 137
      //S&D Touch
      bool bsd_touch = (EnableSDTouch && sd_touch_dir==1 && bmac && sd_touch_check && conf_genTime && bfscan_check && candlestick_confirmed) ? true : false;
      bool ssd_touch = (EnableSDTouch && sd_touch_dir==-1 && smac && sd_touch_check && conf_genTime && sfscan_check && candlestick_confirmed) ? true : false;
      if(bsd_touch)
        {
         PlaceCandleEntry(OP_BUY,"137",iPlus,"138",iPlus);
        }
      else
         if(ssd_touch)
           {
            PlaceCandleEntry(OP_SELL,"137",iPlus,"138",iPlus);
           }

      //code 143
      //PA1 Touch
      bool bpa1_touch = (EnablePA1Touch && pa1_touch_dir==1 && bmac && pa1_touch_check && conf_genTime && bfscan_check && candlestick_confirmed) ? true : false;
      bool spa1_touch = (EnablePA1Touch && pa1_touch_dir==-1 && smac && pa1_touch_check && conf_genTime && sfscan_check && candlestick_confirmed) ? true : false;
      //Print("bpa1_touch="+bpa1_touch+" pa1_touch_dir="+pa1_touch_dir+" bmac="+bmac+" pa1_touch_check="+pa1_touch_check+"  conf_genTime="+conf_genTime+" candlestick_confirmed="+candlestick_confirmed+" T="+Time[0]);
      if(bpa1_touch)
        {
         PlaceCandleEntry(OP_BUY,"143",iPlus,"144",iPlus);
        }
      else
         if(spa1_touch)
           {
            PlaceCandleEntry(OP_SELL,"143",iPlus,"144",iPlus);
           }

      //code 149
      //PA2 Touch
      bool bpa2_touch = (EnablePA2Touch && pa2_touch_dir==1 && bmac && pa2_touch_check && conf_genTime && bfscan_check && candlestick_confirmed) ? true : false;
      bool spa2_touch = (EnablePA2Touch && pa2_touch_dir==-1 && smac && pa2_touch_check && conf_genTime && sfscan_check && candlestick_confirmed) ? true : false;
      if(bpa2_touch)
        {
         PlaceCandleEntry(OP_BUY,"149",iPlus,"150",iPlus);
        }
      else
         if(spa2_touch)
           {
            PlaceCandleEntry(OP_SELL,"149",iPlus,"150",iPlus);
           }

      //code 155
      //Wedges Touch
      bool bwed_touch = (EnableWedgesTouch && wedges_touch_dir==1 && bmac && wedges_touch_check && conf_genTime && bfscan_check && candlestick_confirmed) ? true : false;
      bool swed_touch = (EnableWedgesTouch && wedges_touch_dir==-1 && smac && wedges_touch_check && conf_genTime && sfscan_check && candlestick_confirmed) ? true : false;
      if(bwed_touch)
        {
         PlaceCandleEntry(OP_BUY,"155",iPlus,"156",iPlus);
        }
      else
         if(swed_touch)
           {
            PlaceCandleEntry(OP_SELL,"155",iPlus,"156",iPlus);
           }

      //code 157
      //Volume Zone Epoch Touch
      bool bvze_touch = (EnableVolZoneEpochTouch && bmac && conf_genTime && bfscan_check && b_mc) ? true : false;
      bool svze_touch = (EnableVolZoneEpochTouch && smac && conf_genTime && sfscan_check && s_mc) ? true : false;
      //if (ecdir!=0) Print(cur_symbol, ", ", ConfLocked, ", ", bvze_touch, ", ", EnableVolZoneEpochTouch, ", ", bmac, ", ", conf_genTime, ", ", bfscan_check, ", ", b_mc);

      if(bvze_touch)
        {
         PlaceCandleEntry(OP_BUY,"157",iPlus,"158",iPlus);
        }
      else
         if(svze_touch)
           {
            PlaceCandleEntry(OP_SELL,"157",iPlus,"158",iPlus);
           }

      //code 163
      //RSI Divergence Touch
      bool brsid_touch = (EnableRSIDTouch && rsid_touch_dir==1 && bmac && rsid_touch_bcheck && conf_genTime && bfscan_check && candlestick_confirmed) ? true : false;
      bool srsid_touch = (EnableRSIDTouch && rsid_touch_dir==-1 && smac && rsid_touch_scheck && conf_genTime && sfscan_check && candlestick_confirmed) ? true : false;
      if(brsid_touch)
        {
         PlaceCandleEntry(OP_BUY,"163",iPlus,"164",iPlus);
        }
      else
         if(srsid_touch)
           {
            PlaceCandleEntry(OP_SELL,"163",iPlus,"164",iPlus);
           }

      //code 165
      //Profit Zone Touch
      bool bpz_touch = (EnableProfitZoneTouch && bpz_touch_dir==1 && pz_touch_bcheck && bpowcand && conf_genTime && bfscan_check) ? true : false;
      bool spz_touch = (EnableProfitZoneTouch && spz_touch_dir==-1 && pz_touch_scheck && spowcand && conf_genTime && sfscan_check) ? true : false;
      //Print("165 spz_touch="+spz_touch+" pz_touch_dir="+pz_touch_dir+" pz_touch_scheck="+pz_touch_scheck+" spowcand="+spowcand+" sfscan_check="+sfscan_check+" T="+Time[iPlus]);
      if(bpz_touch)
        {
         PlaceCandleEntry(OP_BUY,"165",iPlus,"166",iPlus);
        }
      else
         if(spz_touch)
           {
            PlaceCandleEntry(OP_SELL,"165",iPlus,"165",iPlus);
           }



      //code 173
      //Liquidity Grab arrow entry
      bool blgae = (EnableLGrabArrowEntry && liqgrab_dir==1 && conf_genTime && bfscan_check) ? true : false;
      bool slgae = (EnableLGrabArrowEntry  && liqgrab_dir==-1 && conf_genTime && sfscan_check) ? true : false;

      if(blgae)
        {
         PlaceCandleEntry(OP_BUY,"173",iPlus,"174",iPlus);
        }
      else
         if(slgae)
           {
            PlaceCandleEntry(OP_SELL,"173",iPlus,"174",iPlus);
           }

      bool b_filer_check = (bcond101 || bcondSTouch || bconZMTFT || bcond113 || bcond119) && range_check;
      bool s_filer_check = (scond101 || scondSTouch || sconZMTFT || scond113 || scond119) && range_check;
     }
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckForExit()
  {

   for(int i=0; i<OrdersTotal(); i++)
     {

      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()!=MagicNumber || OrderSymbol()!=cur_symbol)
            continue;

         bool exitBuy  =  false;
         bool exitSell =  false;
         string closeBy = "" ;
         if(EnableSSMExit)
           {
            double exitVal = (EnableSSMExit) ? getSSMExit(SSM_ExitTF,20,0) : 0;
            exitBuy = (exitVal==1);
            exitSell = (exitVal==-1);
            if(exitBuy || exitSell)
              {
               closeBy = "SSM EXIT";
              }
           }

         if(EnableSSMExit)
           {
            double exitVal = (EnableSSMExit) ? getSSMExit(SSM_ExitTF,20,0) : 0;
            exitBuy = (exitVal==1);
            exitSell = (exitVal==-1);
            if(exitBuy || exitSell)
              {
               closeBy = "SSM EXIT";
              }
           }


         if(EnableVolumeProofExit)
           {
            double val_logAB = (EnableVolumeProofExit) ? getVolProofExit(TouchHTF,OrderType(),0,iPlus) : 0;
            double val_logAS = (EnableVolumeProofExit) ? getVolProofExit(TouchHTF,OrderType(),1,iPlus) : 0;
            double val_logBB = (EnableVolumeProofExit) ? getVolProofExit(TouchHTF,OrderType(),11,iPlus) : 0;
            double val_logBS = (EnableVolumeProofExit) ? getVolProofExit(TouchHTF,OrderType(),12,iPlus) : 0;
            //opposite reading for exit
            bool vpBuyExit = (OrderType() == OP_BUY) ? (val_logAS!=EMPTY_VALUE || val_logBS!=EMPTY_VALUE) : false;
            bool vpSellExit= (OrderType() == OP_SELL) ? (val_logAB!=EMPTY_VALUE || val_logBB!=EMPTY_VALUE)  : false;

            exitBuy = (vpBuyExit) ? vpBuyExit : exitBuy;
            exitSell = (vpSellExit) ? vpSellExit : exitSell;
            if(vpBuyExit || vpSellExit)
              {
               closeBy = "Volume Proof EXIT";
              }
            //Print("exitBuy="+exitBuy+" exitSell="+exitSell+" closeBy="+closeBy+" OrderType="+OrderType()+" val_logAB="+val_logAB+" val_logBB="+val_logBB+" val_logAS="+val_logAS+" val_logBS="+val_logBS+" T="+Time[0]);
           }
         if(EnableMarketShiftExit)
           {
            double msDir = getMarketShiftExit(TouchHTF,SHOW_BOTH,2,iPlus);
            exitBuy = (msDir==1);
            exitSell = (msDir==-1);
            if(exitBuy || exitSell)
              {
               closeBy = "MARKET SHIFT EXIT";
              }
           }

         //--- check order type
         if(OrderType()==OP_BUY)
           {
            if(exitBuy)
              {
               // Print("Order close by "+closeBy+" on "+(string)Time[0]);
               //ObjectCreate(0,"candleLine_BE"+(string)Time[0]+exitVal,OBJ_VLINE,0,Time[0],0);
               if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(cur_symbol,MODE_BID),slip,White))
                  Print("OrderClose error ",GetLastError());
              }
            break;
           }
         if(OrderType()==OP_SELL)
           {
            if(exitSell)
              {

               // Print("Order close by "+closeBy+" on "+(string)Time[0]);
               //ObjectCreate(0,"candleLine_SE"+(string)Time[0]+exitVal,OBJ_VLINE,0,Time[0],0);
               if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(cur_symbol,MODE_ASK),slip,White))
                  Print("OrderClose error ",GetLastError());
              }
            break;
           }

        }
     }

   return (0);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckForExit1()
  {

   for(int i=0; i<OrdersTotal(); i++)
     {

      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()!=MagicNumber || OrderSymbol()!=cur_symbol)
            continue;

         bool exitBuy   = false;
         bool exitSell  = false;
         string closeBy = "" ;
         datetime zoneTimeBuy=0, zoneTimeSell=0;

         if(EnableRangeExit)
           {
            bool exitVal = (EnableRangeExit) ? getRangeBuy(OrderSymbol(),1,zoneTimeBuy) : false;
            exitSell = exitVal;
            if(exitSell)
              {
               closeBy = "Range EXIT";
              }
           }

         if(EnableRangeExit)
           {
            bool exitVal = (EnableRangeExit) ? getRangeSell(OrderSymbol(),1,zoneTimeSell) : false;
            exitBuy = exitVal;
            if(exitBuy)
              {
               closeBy = "Range EXIT";
              }
           }

         if(EnableRangeExit)
           {
            if(OrderType()==OP_BUY)
              {
               if(exitBuy && OrderOpenTime()<zoneTimeSell)
                 {
                  Print("Order close by "+closeBy+" on "+(string)Time[0]);
                  //ObjectCreate(0,"candleLine_BE"+(string)Time[0]+exitVal,OBJ_VLINE,0,Time[0],0);
                  if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(cur_symbol,MODE_BID),slip,White))
                     Print("OrderClose error ",GetLastError());
                 }

              }
            if(OrderType()==OP_SELL)
              {
               if(exitSell && OrderOpenTime()<zoneTimeSell)
                 {
                  Print("Order close by "+closeBy+" on "+(string)Time[0]);
                  //ObjectCreate(0,"candleLine_SE"+(string)Time[0]+exitVal,OBJ_VLINE,0,Time[0],0);
                  if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(cur_symbol,MODE_ASK),slip,White))
                     Print("OrderClose error ",GetLastError());
                 }
              }
           }

        }
     }

   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayScreen()
  {

   int Font_Size              = 10;
   int FontSizePrice          = 20;
   string FontNameLTP         = "Arial Black";
   ENUM_BASE_CORNER Corner    = CORNER_RIGHT_UPPER;
   color FontColorPrice          = Yellow;
   string Market_Price=DoubleToStr(MarketInfo(cur_symbol,MODE_BID),Digits);

   if(MarketInfo(cur_symbol,MODE_BID) > Old_Price)
      FontColorPrice=Lime;
   if(MarketInfo(cur_symbol,MODE_BID) < Old_Price)
      FontColorPrice=Red;
   Old_Price=MarketInfo(cur_symbol,MODE_BID);

   double spread_value = (MarketInfo(cur_symbol,MODE_ASK) - MarketInfo(cur_symbol,MODE_BID)) / (Point*10);
   string cur_spread = DoubleToStr(spread_value, 1);

   tprofit = 0;
   for(int cnt=0; cnt<OrdersHistoryTotal(); cnt++)
     {
      bool os = OrderSelect(cnt,SELECT_BY_POS, MODE_HISTORY);
      if(TimeToStr(TimeCurrent(),TIME_DATE) == TimeToStr(OrderCloseTime(),TIME_DATE) && (OrderSymbol() == cur_symbol) && (OrderMagicNumber() == MagicNumber))
        {
         tprofit = tprofit + OrderProfit();
        }
     }

   oprofit = GetCurrentPL(-1);
   int ActiveBuyOrders = GetTotalOrders("Active",OP_BUY);
   int ActiveSellOrders = GetTotalOrders("Active",OP_SELL);

   int xpos=10,ypos=35,xposPlus=85,yposPlus=80;
   MyObjectPrint1("Symbol_label",cur_symbol,FontSizePrice,FontNameLTP,DarkOrange,xpos,5,Corner);
   MyObjectPrint1("Market_Price_Label",Market_Price,FontSizePrice,FontNameLTP,FontColorPrice,xpos,ypos,Corner);

   MyObjectPrint1("mySpread","Spread : ",Font_Size,FontNameLTP,clrPaleGreen,xpos+xposPlus,yposPlus,Corner);
   MyObjectPrint1("mySpreadV", cur_spread,Font_Size,FontNameLTP,clrPaleGreen,xpos,yposPlus,Corner);

   yposPlus += 30;
   MyObjectPrint1("myBal","Your Balance : ",Font_Size,FontNameLTP,clrAqua,xpos+xposPlus,yposPlus,Corner);
   MyObjectPrint1("myBalV", DoubleToStr(AccountBalance(), 2),Font_Size,FontNameLTP,clrAqua,xpos,yposPlus,Corner);
   yposPlus += 20;
   MyObjectPrint1("myEq","Your Equity : ",Font_Size,FontNameLTP,clrKhaki,xpos+xposPlus,yposPlus,Corner);
   MyObjectPrint1("myEqV", DoubleToStr(AccountEquity(), 2),Font_Size,FontNameLTP,clrKhaki,xpos,yposPlus,Corner);
   yposPlus += 20;
   MyObjectPrint1("myMar","Free Margin : ",Font_Size,FontNameLTP,clrGoldenrod,xpos+xposPlus,yposPlus,Corner);
   MyObjectPrint1("myMarV", DoubleToStr(AccountFreeMargin(), 2),Font_Size,FontNameLTP,clrGoldenrod,xpos,yposPlus,Corner);
   yposPlus += 20;
   MyObjectPrint1("myOrd","T.Buy Orders : ",Font_Size,FontNameLTP,Lime,xpos+xposPlus,yposPlus,Corner);
   MyObjectPrint1("myOrdV", IntegerToString(ActiveBuyOrders),Font_Size,FontNameLTP,Lime,xpos,yposPlus,Corner);
   yposPlus += 20;
   MyObjectPrint1("myOrdCou","T.Sell Orders : ",Font_Size,FontNameLTP,Coral,xpos+xposPlus,yposPlus,Corner);
   MyObjectPrint1("myOrdCount", IntegerToString(ActiveSellOrders),Font_Size,FontNameLTP,Coral,xpos,yposPlus,Corner);

   yposPlus += 30;
   MyObjectPrint1("myTProfit","TODAY's PROFIT ",Font_Size,FontNameLTP,clrYellow,xpos+10,yposPlus,Corner);
   color tprclr = (tprofit>0) ? clrLime : clrRed;
   yposPlus += 20;
   MyObjectPrint1("myTProfitV", AccountCurrency()+" "+DoubleToStr(tprofit,digits),Font_Size+4,FontNameLTP,tprclr,xpos+20,yposPlus,Corner);

   yposPlus += 40;
   MyObjectPrint1("myOProfit","OPEN POSITIONS P/L",Font_Size,FontNameLTP,clrYellow,xpos+10,yposPlus,Corner);
   color oprclr = (oprofit>0) ? clrLime : clrRed;
   yposPlus += 20;
   MyObjectPrint1("myOProfitV", AccountCurrency()+" "+DoubleToStr(oprofit,digits),Font_Size+4,FontNameLTP,oprclr,xpos+20,yposPlus,Corner);


   color clrSignalType=(trend=="BUY") ? LimeGreen : Red;
   MyObjectPrint1("ma",trend,FontSizePrice,FontNameLTP,clrSignalType,5,5,CORNER_LEFT_LOWER);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
void MyObjectPrint1(string objname,string valueToPrint,int fsize,string fname,color colorname,int x,int y,int objPosition)
  {
   ObjectDelete(objname);
   ObjectCreate(objname,OBJ_LABEL,0,0,0);
   ObjectSetText(objname,valueToPrint,fsize,fname,colorname);
   ObjectSet(objname,OBJPROP_XDISTANCE,x);
   ObjectSet(objname,OBJPROP_YDISTANCE,y);
   ObjectSet(objname,OBJPROP_CORNER,objPosition);
   ObjectSet(objname,OBJPROP_ZORDER,-1);
  }
//+------------------------------------------------------------------+
bool IsNewOrderAllowed()
  {
//--- get the number of pending orders allowed on the account
   int max_allowed_orders=(int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

//--- if there is no limitation, return true; you can send an order
   if(max_allowed_orders==0)
      return(true);

//--- if we passed to this line, then there is a limitation; find out how many orders are already placed
   int orders=OrdersTotal();

//--- return the result of comparing
   return(orders<max_allowed_orders);
  }
//+------------------------------------------------------------------+
bool BigCandleCheck()
  {
   if(!AvoidBigCandles)
      return (true);
   for(int i=1; i<iBars(cur_symbol, 0); i++)
     {
      if(TimeCurrent()-iTime(cur_symbol, 0, i)>SkipEntryOnBigCandleMinutes*60)
         break;
      double x=iCustom(cur_symbol, 0, "Kishore Fredrick\\Candle_Range_Check", CRC_NumOfDays, CRC_Multiplier, BigCandleAdrPercent, 4, i);
      if(x==1)
         return (false);
     }
   return (true);
  }
//+------------------------------------------------------------------+
int GetOrderCount(int otype)
  {
   int count_0 = 0;
   for(int oid = OrdersTotal() - 1; oid >= 0; oid--)
     {
      bool os = OrderSelect(oid, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() != cur_symbol || OrderMagicNumber() != MagicNumber)
         continue;
      if(OrderSymbol() == cur_symbol && OrderMagicNumber() == MagicNumber)
         if(OrderType() == OP_SELL || OrderType() == OP_BUY)
            if(!CountRunningTradePerDirection || OrderType()==otype || otype==-1)
               count_0++;
     }
   return (count_0);
  }
//+------------------------------------------------------------------+
bool CheckVolumeValue(double &volume)
  {
   double vol = volume;
   string description="";
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(cur_symbol,SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      vol = min_volume;
      Print("Volume on "+cur_symbol+" is less than the minimal allowed SYMBOL_VOLUME_MIN="+(string)min_volume+" vol="+DoubleToString(volume,3));
      if(!RoundUpCalculatedLotToAccountMinLot)
         return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(cur_symbol,SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      vol = max_volume;
      Print("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX="+(string)max_volume+" vol="+(string)volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(cur_symbol,SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                               volume_step,ratio*volume_step);
      Print(description);
      return(false);
     }
//description="Correct volume value";
   double lot_step=MarketInfo(cur_symbol,MODE_LOTSTEP);
   if(lot_step!=0.01)
      vol = vol*10;
   volume=vol;
   return true;
  }
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb, double &lots,int type)
  {
   double lot_step=MarketInfo(cur_symbol,MODE_LOTSTEP);
   if(lot_step!=0.01)
      lots = lots*10;

   bool res = CheckVolumeValue(lots);
   if(!res)
      return (false);

   double free_margin=AccountFreeMarginCheck(symb,type, lots);
//-- if there is not enough money
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ", oper," ",lots, " ", symb, ",free_margin=",free_margin," Error code=",GetLastError());
      return(false);
     }
//--- checking successful
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTrailingSL(int otype,double cur_op,double distance_tp)
  {

   for(int oid = OrdersTotal(); oid >= 0; oid--)
     {
      bool os = OrderSelect(oid, SELECT_BY_POS, MODE_TRADES);

      if(OrderSymbol() == cur_symbol && OrderMagicNumber() == MagicNumber)
        {
         if(OrderType() == OP_BUY && otype==OP_BUY)
           {
            double tsl = 0;
            tsl = NormalizeDouble(cur_op + distance_tp,4);

            //if(CheckStopLoss_Takeprofit(OP_BUY,tsl,OrderTakeProfit()) == false)
            //   break;
            if(OrderTakeProfit()!=tsl && (OrderTakeProfit()==0 || tsl<OrderTakeProfit()))
              {
               int ord_mod = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), tsl, 0, Yellow);
               if(ord_mod < 0)
                 {
                  Print(cur_symbol+" Error b oid="+(string)oid+" :",GetLastError());
                  return;
                 }
              }
           }
         if(OrderType() == OP_SELL && otype==OP_SELL)
           {
            double tsl = 0;

            tsl = NormalizeDouble(cur_op - distance_tp,4);

            if(OrderTakeProfit()!=tsl && (OrderTakeProfit()==0 || tsl>OrderTakeProfit()))
              {
               int ord_mod = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), tsl, 0, Yellow);
               if(ord_mod < 0)
                 {
                  Print(cur_symbol+" Error s oid="+(string)oid+" :",GetLastError());
                  return;
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetLastOrderTime(int otype)
  {
   datetime closetime=0;
   for(int cnt=OrdersHistoryTotal(); cnt>=0; cnt--)
     {
      bool os = OrderSelect(cnt,SELECT_BY_POS, MODE_HISTORY);
      if(cnt==OrdersHistoryTotal()-1 && cur_symbol==OrderSymbol() && otype==OrderType() && MagicNumber==OrderMagicNumber())
        {

         closetime = OrderOpenTime();
         break;

        }
     }
   return closetime;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LastOrderCheck(int otype)
  {
   bool loc = false;
   int ocnt = 0,tpcount=0,slcount=0,breakeven_count=0;

   datetime today_start = StrToTime((string)TimeYear(TimeCurrent())+"."+(string)TimeMonth(TimeCurrent())+"."+(string)TimeDay(TimeCurrent())+" 00:00");
   datetime today_end = StrToTime((string)TimeYear(TimeCurrent())+"."+(string)TimeMonth(TimeCurrent())+"."+(string)TimeDay(TimeCurrent())+" 23:59");
   double minProfit=RiskPercent*startBalance/100;
   for(int cnt=OrdersHistoryTotal()-1; cnt>=0; cnt--)
     {
      bool os = OrderSelect(cnt,SELECT_BY_POS, MODE_HISTORY);

      if(cur_symbol==OrderSymbol() && MagicNumber==OrderMagicNumber() && OrderOpenTime()>today_start && OrderCloseTime()<today_end)//orderclosetime checking will avoid to place the new order on 2nd day
        {
         ocnt++;
         if(OrderProfit()<=minProfit && OrderProfit()>=0 && (OrderType()==otype || !Check_Dir_Separately))
            breakeven_count++;
         else
            if(OrderProfit() > minProfit && (OrderType()==otype || !Check_Dir_Separately))
               tpcount++;
            else
               if(OrderProfit() < 0 && (OrderType()==otype || !Check_Dir_Separately))
                  slcount++;
        }
     }
   loc=(breakeven_count>=Breakeven_Check)?false : (slcount>=SL_Check)?false : (tpcount>=TP_Check)?false : true;

   return loc;
  }
//+------------------------------------------------------------------+
int GetLossCount(string symbol, int type)
  {
   int count=0;
   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         if(OrderSymbol()==symbol && OrderMagicNumber()==MagicNumber && (OrderType()==OP_BUY || OrderType()==OP_SELL))
            if(type==-1 || OrderType()==type)
              {
               if(OrderProfit()<0)
                  count++;
               else
                  break;
              }
   return (count);
  }
//+------------------------------------------------------------------+
bool CurrentOrderCheck(string wpattern, int otype)
  {
   bool coc = false,samepatCheck = true,rftrade = true,opptrade=true;
   int ocnt = 0,tpcount=0,slcount=0,breakeven_count=0;

   int ActiveBuyOrders = GetTotalOrders("Active",OP_BUY);
   int ActiveSellOrders = GetTotalOrders("Active",OP_SELL);

   datetime today_start = StrToTime((string)TimeYear(TimeCurrent())+"."+(string)TimeMonth(TimeCurrent())+"."+(string)TimeDay(TimeCurrent())+" 00:00");
   datetime today_end = StrToTime((string)TimeYear(TimeCurrent())+"."+(string)TimeMonth(TimeCurrent())+"."+(string)TimeDay(TimeCurrent())+" 23:59");

   rftrade = (AllowRiskFreeTrade && EnableBreakEven) ? false : true;
   rftrade = (OrdersTotal()==0) ? true : (ActiveBuyOrders==0 && ActiveSellOrders==0) ? true : rftrade;


   for(int cnt=OrdersTotal()-1; cnt>=0; cnt--)
     {
      bool os = OrderSelect(cnt,SELECT_BY_POS, MODE_TRADES);

      if(cur_symbol==OrderSymbol() && MagicNumber==OrderMagicNumber())
        {
         ocnt++;

         if(RejectSamePattern)
           {
            //Checking of pattern number in Order Comment
            string patternCheck = "-"+wpattern+"-";
            if(StringFind(OrderComment(), patternCheck) > 0)
              {
               samepatCheck = false;
              }
           }

         //For Risk Free Trade, Breakeven should be enabled
         if(AllowRiskFreeTrade && EnableBreakEven)
           {
            if((OrderType()==OP_BUY || OrderType()==OP_SELL) && (OrderOpenPrice() == OrderStopLoss()))
              {
               rftrade = true;
              }
            else
               if((OrderType()==OP_BUY || OrderType()==OP_SELL) && (OrderOpenPrice() != OrderStopLoss()))
                 {
                  rftrade=false;
                  break;
                 }
           }

         if(!AllowOppositeSignals)
           {
            if(OrderType()!=otype)
              {
               opptrade=false;
               break;
              }
           }
        }
     }
   coc = samepatCheck && rftrade && opptrade;

   return coc;
  }
//+------------------------------------------------------------------+
double GetLastPrice(int otype)
  {
   double order_open_price_0=0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for(int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--)
     {
      bool os = OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() == cur_symbol && OrderType()==otype && OrderMagicNumber() == MagicNumber)
        {
         ticket_8 = OrderTicket();
         if(ticket_8 > ticket_20)
           {
            order_open_price_0 = OrderOpenPrice();
            ticket_20 = ticket_8;
           }
        }
     }
   return (order_open_price_0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
double GetCurrentPL(int type)//(-1)- all, 0  - buy, 1 - sell
  {
   double pl=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      bool os = OrderSelect(i,SELECT_BY_POS, MODE_TRADES);

      if(cur_symbol==OrderSymbol() && MagicNumber==OrderMagicNumber())
        {

         if(type == OP_BUY && OrderType()==type)
           {
            pl += OrderProfit();
            //Print("type="+type+" OrderType="+OrderType()+" OrderProfit="+OrderProfit()+" pl="+pl);
           }
         else
            if(type == OP_SELL && OrderType()==type)
              {
               pl += OrderProfit();
              }
            else
               if(type == -1)
                 {
                  pl += OrderProfit();
                 }
        }
     }
   return NormalizeDouble(pl,2);
  }
//+------------------------------------------------------------------+
double getPrevLot()
  {
   double lot=0;
   for(int cnt=OrdersHistoryTotal()-1; cnt>=0; cnt--)
     {
      bool os = OrderSelect(cnt,SELECT_BY_POS, MODE_HISTORY);
      //Print("cnt="+cnt+" OrderPro="+OrderProfit()+" OrderClo="+OrderCloseTime()+" Lot="+OrderLots());
      if(cur_symbol==OrderSymbol() && MagicNumber==OrderMagicNumber() && OrderProfit()<0)
        {

         lot = OrderLots();
        }
      if(cnt==OrdersHistoryTotal()-1)
         break;
     }
   return lot;
  }
//+------------------------------------------------------------------+
int GetTotalOrders(string type,int otype=0)
  {
   int count=0;
   for(int oid = OrdersTotal() - 1; oid >= 0; oid--)
     {
      bool os = OrderSelect(oid, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() == cur_symbol && OrderMagicNumber() == MagicNumber)
        {
         if(type == "Active")
           {
            if(OrderType() == OP_BUY && otype == OP_BUY)
              {
               count++;
              }
            else
               if(OrderType() == OP_SELL && otype == OP_SELL)
                 {
                  count++;
                 }
           }
         if(type == "Pending")
           {
            if(OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP)
              {
               count++;
              }
           }
         if(type == "BuyLimit")
           {
            if(OrderType() == OP_BUYLIMIT)
              {
               count++;
              }
           }
         if(type == "BuyStop")
           {
            if(OrderType() == OP_BUYSTOP)
              {
               count++;
              }
           }
         if(type == "SellLimit")
           {
            if(OrderType() == OP_SELLLIMIT)
              {
               count++;
              }
           }
         if(type == "SellStop")
           {
            if(OrderType() == OP_SELLSTOP)
              {
               count++;
              }
           }
         //Print("type="+type+" price="+price+" OrderType="+OrderType()+" OrderOpenPrice="+OrderOpenPrice()+" no_active_trade="+no_active_trade);
        }
     }
   return count;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetHedgeTradeCount(string type,int otype=0)
  {
   string Base= StringSubstr(cur_symbol,0,3);
   string Quote= StringSubstr(cur_symbol,3,6);

   int count=0;
   for(int oid = OrdersTotal() - 1; oid >= 0; oid--)
     {
      bool os = OrderSelect(oid, SELECT_BY_POS, MODE_TRADES);
      if(OrderMagicNumber() == MagicNumber)
        {
         if(type == "Active")
           {

            string BaseOpen= StringSubstr(OrderSymbol(),0,3);
            string QuoteOpen= StringSubstr(OrderSymbol(),3,6);


            if(Base==BaseOpen)
              {

               if(OrderType() == OP_BUY && otype == OP_SELL)
                 {
                  //Print(otype+" "+ BaseOpen +" "+ Base);
                  count++;
                 }
               else
                  if(OrderType() == OP_SELL && otype == OP_BUY)
                    {
                     count++;
                    }


              }
            else
               if(Base==QuoteOpen)
                 {
                  if(OrderType() == OP_BUY && otype == OP_BUY)
                    {
                     count++;
                    }
                  else
                     if(OrderType() == OP_SELL && otype == OP_SELL)
                       {
                        count++;
                       }
                 }
               else
                  if(Quote==BaseOpen)
                    {
                     if(OrderType() == OP_BUY && otype == OP_BUY)
                       {
                        count++;
                       }
                     else
                        if(OrderType() == OP_SELL && otype == OP_SELL)
                          {
                           count++;
                          }
                    }
                  else
                     if(Quote==QuoteOpen)
                       {
                        if(OrderType() == OP_BUY && otype == OP_SELL)
                          {
                           count++;
                          }
                        else
                           if(OrderType() == OP_SELL && otype == OP_BUY)
                             {
                              count++;
                             }
                       }

           }
        }
      //Print("type="+type+" price="+price+" OrderType="+OrderType()+" OrderOpenPrice="+OrderOpenPrice()+" no_active_trade="+no_active_trade);
     }
   return count;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetTradeCount(string type,int otype=0)
  {
   string Base= StringSubstr(cur_symbol,0,3);
   string Quote= StringSubstr(cur_symbol,3,6);

   int count=0;
   for(int oid = OrdersTotal() - 1; oid >= 0; oid--)
     {
      bool os = OrderSelect(oid, SELECT_BY_POS, MODE_TRADES);
      if(OrderMagicNumber() == MagicNumber)
        {
         if(type == "Active")
           {

            string BaseOpen= StringSubstr(OrderSymbol(),0,3);
            string QuoteOpen= StringSubstr(OrderSymbol(),3,6);



            if(Base==BaseOpen)
              {
               if(OrderType() == OP_BUY && otype == OP_BUY)
                 {
                  count++;
                 }
               else
                  if(OrderType() == OP_SELL && otype == OP_SELL)
                    {
                     count++;
                    }
              }
            else
               if(Base==QuoteOpen)
                 {


                  if(OrderType() == OP_BUY && otype == OP_SELL)
                    {
                     count++;
                    }
                  else
                     if(OrderType() == OP_SELL && otype == OP_BUY)
                       {
                        count++;
                       }
                 }
               else
                  if(Quote==BaseOpen)
                    {



                     if(OrderType() == OP_BUY && otype == OP_SELL)
                       {
                        count++;
                       }
                     else
                        if(OrderType() == OP_SELL && otype == OP_BUY)
                          {
                           count++;
                          }
                    }
                  else
                     if(Quote==QuoteOpen)
                       {
                        if(OrderType() == OP_BUY && otype == OP_BUY)
                          {
                           count++;
                          }
                        else
                           if(OrderType() == OP_SELL && otype == OP_SELL)
                             {
                              count++;
                             }
                       }

           }
        }
      //Print("type="+type+" price="+price+" OrderType="+OrderType()+" OrderOpenPrice="+OrderOpenPrice()+" no_active_trade="+no_active_trade);
     }
   return count;

  }

//+------------------------------------------------------------------+
//void SetAvgTarget(int otype)
//{
////---
////SET THE TARGET BASED ON AVERAGE PRICE
////---
//
//   double cur_OpenPrice = 0;
//   double total_lot = 0;
//   for(int oid = OrdersTotal() - 1; oid >= 0; oid--)
//   {
//      bool os = OrderSelect(oid, SELECT_BY_POS, MODE_TRADES);
//      if(OrderSymbol() == cur_symbol && OrderMagicNumber() == MagicNumber)
//      {
//         if(OrderType() == otype)
//         {
//            cur_OpenPrice += OrderOpenPrice() * OrderLots();
//            total_lot += OrderLots();
//         }
//      }
//   }
//
//   cur_OpenPrice = NormalizeDouble(cur_OpenPrice / total_lot, Digits);
//
//   tp_sl_range = TakeProfit * Point;
//   ModifyTrailingSL(otype,cur_OpenPrice,tp_sl_range);
//}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//void SingleOrderTrailingSL()
//{
//
//   for(int oid = OrdersTotal(); oid >= 0; oid--)
//   {
//      bool os = OrderSelect(oid, SELECT_BY_POS, MODE_TRADES);
//
//      if(OrderSymbol() == cur_symbol && OrderMagicNumber() == MagicNumber)
//      {
//         if(OrderType() == OP_BUY)
//         {
//            double tsl = 0;
//
//            tsl = MarketInfo(cur_symbol,MODE_BID) - Trailing_SL * Point;
//
//            //if(CheckStopLoss_Takeprofit(OP_BUY,osl,OrderTakeProfit()) == false)
//            //   break;
//
//            if(OrderStopLoss()!=tsl && tsl>OrderOpenPrice() && tsl>OrderStopLoss())
//            {
//               int ord_mod = OrderModify(OrderTicket(), OrderOpenPrice(), tsl, OrderTakeProfit(), 0, Yellow);
//               if(ord_mod < 0)
//               {
//                  Print("Error b oid="+(string)oid+" :",GetLastError());
//                  return;
//               }
//            }
//         }
//         if(OrderType() == OP_SELL)
//         {
//            double tsl = 0;
//
//            tsl = MarketInfo(cur_symbol,MODE_ASK) + Trailing_SL * Point;
//
//            if(OrderStopLoss()!=tsl && tsl<OrderOpenPrice() && (OrderStopLoss()==0 || tsl<OrderStopLoss()))
//            {
//               int ord_mod = OrderModify(OrderTicket(), OrderOpenPrice(), tsl, OrderTakeProfit(), 0, Yellow);
//               if(ord_mod < 0)
//               {
//                  Print("Error s oid="+(string)oid+" :",GetLastError());
//                  return;
//               }
//            }
//         }
//      }
//   }
//}
//+------------------------------------------------------------------+
int CountConditions(string pattern,bool main,bool vol,bool pivot,string &weightage,bool trig=false,bool trig2=false,bool trig3=false,bool trig4=false,bool trig5=false,bool trig6=false,bool trig7=false,bool trig8=false,bool trig9=false,bool trig10=false,bool trig11=false,bool trig12=false)
  {
   int count = 0;
   weightage="";
   if(pattern=="ENG" && EnableEngulfingWick && main)
      count++;
   if(pattern=="3B" && Enable3BarEnhance && main)
      count++;
   if(pattern=="TW" && EnableTweezer && main)
      count++;
   if(pattern=="MW" && EnableMultipleWick && main)
      count++;
   if(pattern=="MC" && EnableMyCandle&& main)
      count++;
   if(pattern=="MAA" && EnableMAArrow && main)
      count++;
   if(pattern=="MAA0" && EnableMAArrowDyn && main)
      count++;

   if(pattern=="Ind" && EnableMACrossover && main)
      count++;
   if(pattern=="Ind" && EnableSSM && main)
      count++;
   if(pattern=="Ind" && EnableZIZ && main)
      count++;


   if(pattern=="VOL" && EnableVolumeProof && main)
      count++;
   if(pattern=="VOL" && EnableVolZoneConfirmation && vol)
      count++;
   if(pattern=="VOL" && EnableMarketShift && pivot)
      count++;

   if(pattern=="SHC" && EnableSHC_Asian && main)
     {
      count = count+1;
      weightage=weightage+"Asian(1),";
     }
   if(pattern=="SHC" && EnableSHC_ADR && vol)
     {
      count = count+1;
      weightage=weightage+"ADR(1),";
     }
   if(pattern=="SHC" && EnableSHC_LiqGrabTrig1 && pivot)
     {
      count = count+1;
     }
   if(pattern=="SHC" && EnableSHC_LiqGrabTrig2 && trig)
      count = count+3;

   int cnt=count;


   if(pattern=="SHC" && EnableSHC_SwingStopM1Trig1 && trig2)
     {
      count = count+6;
      weightage=weightage+"M1T1(6),";
     }
// Print("M 1" +EnableSHC_SwingStopM1Trig1+" "+trig2+" " +pattern+" "+(count-cnt)+" "+count);

   if(pattern=="SHC" && EnableSHC_SwingStopM1Trig2 && trig3)
     {
      count = count+8;
      weightage=weightage+"M1T2(8),";
     }

// Print("M1 2" +EnableSHC_SwingStopM1Trig2+" "+trig3+" " +pattern+" "+(count-cnt)+" "+count);

   if(pattern=="SHC" && EnableSHC_SwingStopM2Trig1 && trig4)
     {
      count = count+5;
      weightage=weightage+"M2T1(5),";
     }

// Print("M2 1" +EnableSHC_SwingStopM2Trig1+" "+trig4+" " +pattern+" "+(count-cnt)+" "+count);

   if(pattern=="SHC" && EnableSHC_SwingStopM2Trig2 && trig5)
     {
      count = count+7;
      weightage=weightage+"M2T2(7),";
     }


//  Print("M2 2" +EnableSHC_SwingStopM2Trig2+" "+trig5+" " +pattern+" "+(count-cnt)+" "+count);

   if(pattern=="SHC" && EnableSHC_SwingStopM3Trig1 && trig6)
     {
      count = count+4;
      weightage=weightage+"M3T1(4),";
     }

//   Print("M3 1" +EnableSHC_SwingStopM3Trig1+" "+trig6+" " +pattern+" "+(count-cnt)+" "+count);

   if(pattern=="SHC" && EnableSHC_SwingStopM3Trig2 && trig7)
     {
      count = count+6;
      weightage=weightage+"M3T2(6),";
     }

//  Print(pattern +"M3 2" +EnableSHC_SwingStopM3Trig2+" "+trig7+" " +pattern+" "+(count-cnt)+" "+count);

   if(pattern=="SHC" && EnableSHC_SwingStopM4Trig1 && trig8)
     {
      count = count+4;
      weightage=weightage+"M4T1(4),";
     }

// Print("M4 1" +EnableSHC_SwingStopM4Trig1+" "+trig8+" " +pattern+" "+(count-cnt)+" "+count);

   if(pattern=="SHC" && EnableSHC_SwingStopM4Trig2 && trig9)
     {
      count = count+6;
      weightage=weightage+"M4T2(6),";
     }

   if(pattern=="SHC" && EnableSHC_SwingStopM5Trig1 && trig10)
     {
      count = count+3;
      weightage=weightage+"M5T1(3),";
     }

   if(pattern=="SHC" && EnableSHC_SwingStopM5Trig2 && trig11)
     {
      count = count+5;
      weightage=weightage+"M5T2(5),";
     }


// Print("M4 2" +EnableSHC_SwingStopM4Trig2+" "+trig9+" " +pattern+" "+(count-cnt)+" "+count);

// Print("pattern " +EnableSHC_SwingStopM1Trig1+" "+trig2+" " +pattern+" "+(count-cnt)+" "+count);

   if(pattern=="SHC" && EnableSHC_MarketShift && trig12)
     {
      count = count+1;
      weightage=weightage+"MS(1),";
     }
   if(weightage!="")
      weightage=StringSubstr(weightage, 0, StringLen(weightage)-1);

   if(EnablePivot && pivot)
      count++;
   if(EnableVolCheck && vol)
      count++;
   return count;
  }
//+------------------------------------------------------------------+
bool CheckRoomToLeft(int otype,double price,int i)
  {
   bool cr=true;
   for(int r=i+RoomToTheLeft; r>i; r--)
     {
      if(otype == OP_BUY)
        {
         if(Low[r]<price)
           {
            cr=false;
           }
        }
      if(otype == OP_SELL)
        {
         if(High[r]>price)
           {
            cr=false;
           }
        }
     }

   return cr;//returns true if no candles present in left
  }
//+------------------------------------------------------------------+
double GetPositionSizingLot(double sl_diff)
  {
   double final_lot = 0;
   double riskPercent=RiskPercent;
   if(IncreaseRiskOnLoss)
     {
      int loss=GetLossCount(cur_symbol, -1);
      if(loss>0)
        {
         riskPercent=MathPow(RiskIncreaseMultiplier, loss)*RiskPercent;
        }
     }
   double riskP = (riskPercent/100);
   double AmountAtRisk = (RiskFrom==RiskEquity) ? (AccountEquity() * riskP) : (RiskFrom==RiskAccBal) ? (AccountBalance() * riskP) : 0;
   if(EnableFundedAccount)
      AmountAtRisk = MathMin(AccountBalance(), FundedAccountBalance) * riskP;
   double pv=SymbolInfoDouble(cur_symbol, SYMBOL_TRADE_TICK_VALUE)/SymbolInfoDouble(cur_symbol, SYMBOL_TRADE_TICK_SIZE);
   final_lot=AmountAtRisk/(pv*sl_diff);
   int dp=GetDecimalPoints(cur_symbol);
   string msg="Calculated lots final_lot="+ DoubleToString(final_lot, 4)+" AmountAtRisk="+DoubleToString(AmountAtRisk, 2)+" sl_diff="+DoubleToString(sl_diff, cur_digits);
   if(final_lot<SymbolInfoDouble(cur_symbol, SYMBOL_VOLUME_MIN))
     {
      double riskValue=pv*SymbolInfoDouble(cur_symbol, SYMBOL_VOLUME_MIN)*sl_diff;
      double minBalance=riskValue*100/riskPercent;
      //Print(riskValue, ", ", pv, ", ", riskPercent, ", ", SymbolInfoDouble(cur_symbol, SYMBOL_VOLUME_MIN), ", ", sl_diff);
      msg=msg+", min balance needed="+DoubleToString(minBalance, 2);
      final_lot=0;
     }
   Print(msg);
   if(EnableFundedAccount)
     {
      double prev_lot=final_lot;
      final_lot=MathFloor(final_lot*MathPow(10, dp))/MathPow(10, dp);
      Print("lot is rounded down from "+DoubleToString(prev_lot, 4)+" to "+DoubleToString(final_lot, dp));
     }
   else
      final_lot=NormalizeDouble(final_lot, dp);//MathFloor(final_lot*MathPow(10, dp))/MathPow(10, dp);
   return final_lot;
  }
//+------------------------------------------------------------------+
int GetDecimalPoints(string symbol)
  {
//------------------------------------------------------------------
   while(MarketInfo(symbol, MODE_LOTSTEP)==0)
      Sleep(2000);
   int dp = 0;
   double x = MarketInfo(symbol, MODE_LOTSTEP);
   while(x < 1)
     { x *= 10; dp += 1; }
   return (dp);
//------------------------------------------------------------------
  }
//+------------------------------------------------------------------+
double GetPositionSizingLot_old(double sl_diff)
  {
   double final_lot = 0;
   double sl_price=sl_diff;
   double riskPercent=RiskPercent;
   if(IncreaseRiskOnLoss)
     {
      int loss=GetLossCount(cur_symbol, -1);
      if(loss>0)
        {
         riskPercent=MathPow(RiskIncreaseMultiplier, loss)*RiskPercent;
        }
     }
   double riskP = (riskPercent/100);
   double AmountAtRisk = (RiskFrom==RiskEquity) ? (AccountEquity() * riskP) : (RiskFrom==RiskAccBal) ? (AccountBalance() * riskP) : 0;

   string baseCurr = StringSubstr(cur_symbol,0,3);
   string crossCurr = StringSubstr(cur_symbol,3,3);
   string QuoteCurrency[7] = {"AUD","CAD","CHF","EUR","GBP","JPY","NZD"};
   string FetchUSDPairs[7] = {"AUDUSD","USDCAD","USDCHF","EURUSD","GBPUSD","USDJPY","NZDUSD"};
   string msg="";

   if(sl_diff!=0)
     {
      if(AccountCurrency() == "USD")
        {
         if(cur_digits == 2)
           {
            if(cur_symbol=="XAUUSD" || cur_symbol=="GOLD")
              {
               final_lot = NormalizeDouble(AmountAtRisk/ sl_diff/1000,2);
              }
            else
              {
               final_lot = NormalizeDouble(AmountAtRisk/ sl_diff,2);
              }
            //Print("final_lot="+final_lot+" AmountAtRisk="+AmountAtRisk+" sl_diff="+sl_diff );
           }
         else
            if(crossCurr == AccountCurrency())
              {
               final_lot = NormalizeDouble((AmountAtRisk/ sl_diff) / TotalUnits,2);
               msg="Calculated lots (A/C currency = Quote currency): final_lot="+ (string)final_lot+" AmountAtRisk="+(string)AmountAtRisk+" sl_diff="+(string)sl_diff;
              }
            else
               if(baseCurr == AccountCurrency())
                 {
                  final_lot = NormalizeDouble(((MarketInfo(cur_symbol,MODE_ASK) * AmountAtRisk) / sl_diff) / TotalUnits,2);
                  msg="Calculated lots (A/C currency = Base currency): final_lot="+ (string)final_lot+" AmountAtRisk="+(string)AmountAtRisk+" sl_diff="+(string)sl_diff;
                 }
               else
                  if(crossCurr != AccountCurrency() && baseCurr != AccountCurrency())
                    {
                     string wpair = "";
                     double ClosePrice =0;
                     for(int i=0; i<=6; i++)
                       {
                        if(crossCurr == QuoteCurrency[i])
                          {
                           wpair = FetchUSDPairs[i];

                           //ClosePrice = iClose(wpair,PERIOD_CURRENT,1);
                           ClosePrice = MarketInfo(wpair,MODE_BID);
                           ClosePrice = (ClosePrice==0) ? iClose(wpair,PERIOD_CURRENT,1) : ClosePrice;

                           string sym = StringSubstr(wpair,3,3);//check the base currency for usd
                           double NetAmtRisk = (sym=="JPY") ? (AmountAtRisk*ClosePrice)/100 : (AmountAtRisk/ClosePrice);
                           sl_diff = (sym=="JPY") ? sl_diff/100 : sl_diff;
                           final_lot = NormalizeDouble((NetAmtRisk / sl_diff) / TotalUnits,2);

                           //Print("Calculated lots (A/C currency neither Base nor Quote currency): ", final_lot);
                           msg="Calculated lots (Non USD Currency) USDwpair="+wpair+" AmountAtRisk="+(string)AmountAtRisk+" ClosePrice="+(string)ClosePrice+" NetAmtRisk="+DoubleToStr(NetAmtRisk,2)+" sl_diff="+(string)sl_diff+" final_lot="+(string)final_lot+" units="+DoubleToStr((NetAmtRisk / sl_diff),2)+" i="+(string)i;
                           break;
                          }
                       }
                    }
        }
     }

   if(final_lot<SymbolInfoDouble(cur_symbol, SYMBOL_VOLUME_MIN))
     {
      double pv=SymbolInfoDouble(cur_symbol, SYMBOL_TRADE_TICK_VALUE)/SymbolInfoDouble(cur_symbol, SYMBOL_TRADE_TICK_SIZE);
      double riskValue=pv*SymbolInfoDouble(cur_symbol, SYMBOL_VOLUME_MIN)*sl_price;
      double minBalance=riskValue*100/riskPercent;
      Print(riskValue, ", ", pv, ", ", riskPercent, ", ", SymbolInfoDouble(cur_symbol, SYMBOL_VOLUME_MIN), ", ", sl_price);
      msg=msg+", min balance needed="+DoubleToString(minBalance, 2);
      Print(msg);
     }
   else
      Print(msg);
   return final_lot;
  }
//+------------------------------------------------------------------+
bool CreateTextFile(string symbol, int signal,string comment)
  {
   int idx=GetSymbolRow(symbol);
   if(idx==-1)
      return (false);
   if(signal==OP_BUY && iTime(symbol, 0, 0)-textFiles[idx].lastBuyFile<TextFileValidityInMinutes*60)
      return (false);
   if(signal==OP_SELL && iTime(symbol, 0, 0)-textFiles[idx].lastSellFile<TextFileValidityInMinutes*60)
      return (false);
   datetime dt=iTime(symbol, 0, 0);
   datetime entryTime=iTime(symbol, 0, 0);
   datetime exitTime=entryTime+TextFileValidityInMinutes*60;

   for(int j=1; j<=FolderNumbers; j++)
     {
      string fileName=TextFilesFolder+IntegerToString(j)+"\\1\\"+symbol+(signal==OP_BUY?"-BUY-":"-SELL-")+IntegerToString(dt)+"-ROBO.txt";

      int handle=FileOpen(fileName, FILE_READ|FILE_WRITE|FILE_COMMON|FILE_TXT);
      if(handle>0)
        {
         FileSeek(handle, 0, SEEK_END);
         datetime confirmedTime=entryTime;
         datetime startime=entryTime;
         datetime endtime=exitTime;
         string buffer=symbol+(signal==OP_BUY?",BUY,":",SELL,")+TimeToString(startime, TIME_DATE|TIME_SECONDS)+","+TimeToString(endtime, TIME_DATE|TIME_SECONDS)+","+"NE"+","+(string)MagicNumber+","+comment;
         FileWrite(handle, buffer);
         FileClose(handle);
         if(signal==OP_BUY)
            textFiles[idx].lastBuyFile=iTime(symbol, 0, 0);
         if(signal==OP_SELL)
            textFiles[idx].lastSellFile=iTime(symbol, 0, 0);
         Print("text file "+fileName+" is created by ea");
        }

      string fileName_1=TextFilesFolder_1+IntegerToString(j)+"\\1\\"+symbol+(signal==OP_BUY?"-BUY-":"-SELL-")+IntegerToString(dt)+"-ROBO.txt";

      int handle_1=FileOpen(fileName_1, FILE_READ|FILE_WRITE|FILE_COMMON|FILE_TXT);
      if(handle_1>0)
        {
         FileSeek(handle, 0, SEEK_END);
         datetime confirmedTime=entryTime;
         datetime startime=entryTime;
         datetime endtime=exitTime;
         string buffer=symbol+(signal==OP_BUY?",BUY,":",SELL,")+TimeToString(startime, TIME_DATE|TIME_SECONDS)+","+TimeToString(endtime, TIME_DATE|TIME_SECONDS)+","+"NE"+","+(string)MagicNumber+","+comment;
         FileWrite(handle, buffer);
         FileClose(handle);
         if(signal==OP_BUY)
            textFiles[idx].lastBuyFile=iTime(symbol, 0, 0);
         if(signal==OP_SELL)
            textFiles[idx].lastSellFile=iTime(symbol, 0, 0);
         Print("text file "+fileName_1+" is created by ea");
        }
     }
   return (true);
  }
//+------------------------------------------------------------------+
int GetSymbolRow(string symbol)
  {
   for(int i=0; i<ArraySize(textFiles); i++)
      if(textFiles[i].symbol==symbol)
         return (i);
   return (-1);
  }
//+------------------------------------------------------------------+
string CheckForFile(string Path,string Name)
  {
   string main_folder = Path;
   string InpFilter = main_folder+"*",file_name;
   int    i=1;
   string found="";

   long search_handle=FileFindFirst(InpFilter,file_name,FILE_COMMON);
   if(search_handle!=INVALID_HANDLE)
     {
      do
        {
         ResetLastError();
         FileIsExist(file_name);
         string filenameWithPath = main_folder + file_name;
         int file_handle=FileOpen(filenameWithPath,FILE_READ|FILE_TXT|FILE_COMMON);
         int file_size=(int)FileSize(file_handle);

         if(file_size>0)
           {
            if(file_handle==Name)
              {
               found=Path+file_name;
              }
           }
         else
           {
            return CheckForFile(Path+file_name,Name);
           }

         FileClose(file_handle);

         i++;
        }
      while(FileFindNext(search_handle,file_name) && !IsStopped());
      //--- close search handle
      FileFindClose(search_handle);
     }

   return found;
  }
//+------------------------------------------------------------------+
string FindDirectory(string Path)
  {
   string main_folder = Path;
   string InpFilter = main_folder+"*",file_name;
   int    i=1;
   string found="";

   long search_handle=FileFindFirst(InpFilter,file_name,FILE_COMMON);
   if(search_handle!=INVALID_HANDLE)
     {
      do
        {
         ResetLastError();
         FileIsExist(file_name);
         string filenameWithPath = main_folder + file_name;
         int file_handle=FileOpen(filenameWithPath,FILE_READ|FILE_TXT|FILE_COMMON);
         int file_size=(int)FileSize(file_handle);

         if(file_size>0)
           {

           }
         else
           {
            if(CountFiles(Path+file_name)<MaxFilesInFolder)
              {
               found= file_name;
               break;
              }
           }

         FileClose(file_handle);

         i++;
        }
      while(FileFindNext(search_handle,file_name) && !IsStopped());
      //--- close search handle
      FileFindClose(search_handle);

     }

   return found;
  }
//+------------------------------------------------------------------+
int CountFiles(string Path)
  {
   string main_folder = Path;
   string InpFilter = main_folder+"*",file_name;
   int    i=1;
   int count=0;
   long search_handle=FileFindFirst(InpFilter,file_name,FILE_COMMON);
   if(search_handle!=INVALID_HANDLE)
     {
      do
        {
         ResetLastError();
         FileIsExist(file_name);
         string filenameWithPath = main_folder + file_name;
         int file_handle=FileOpen(filenameWithPath,FILE_READ|FILE_TXT|FILE_COMMON);
         int file_size=(int)FileSize(file_handle);

         if(file_size>0)
           {
            count++;
           }
         FileClose(file_handle);

         i++;
        }
      while(FileFindNext(search_handle,file_name) && !IsStopped());
      //--- close search handle
      FileFindClose(search_handle);

     }
   return count;
  }
//+------------------------------------------------------------------+
int MaxNum(string Path)
  {
   string main_folder = Path;
   string InpFilter = main_folder+"*",file_name;
   int    i=1;
   string MaxDir="0";
   int count=0;
   long search_handle=FileFindFirst(InpFilter,file_name,FILE_COMMON);
   if(search_handle!=INVALID_HANDLE)
     {
      do
        {
         ResetLastError();
         FileIsExist(file_name);
         string filenameWithPath = main_folder + file_name;
         int file_handle=FileOpen(filenameWithPath,FILE_READ|FILE_TXT|FILE_COMMON);
         int file_size=(int)FileSize(file_handle);

         //  Print("Scanning File : "+file_name+", LocalTime : "+(string)TimeCurrent());
         //Print("Scanning File : "+file_name+", LocalTime : "+(string)TimeCurrent());

         if(file_size>0)
           {

           }
         else
           {
            string fl=file_name;
            StringReplace(fl,"\\","");
            int vl= (int)StringToInteger(fl);
            if(count<vl)
              {
               MaxDir=IntegerToString(vl);
              }
           }
         FileClose(file_handle);

         i++;
        }
      while(FileFindNext(search_handle,file_name) && !IsStopped());
      //--- close search handle
      FileFindClose(search_handle);

     }
   return (int)MaxDir;
  }
//+------------------------------------------------------------------+
void ZigzagTrailing()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderMagicNumber()==MagicNumber && (OrderType()==OP_BUY || OrderType()==OP_SELL))
           {
            int cdigits=(int)SymbolInfoInteger(OrderSymbol(), SYMBOL_DIGITS);
            double point=SymbolInfoDouble(OrderSymbol(), SYMBOL_POINT);
            if(OrderType()==OP_BUY)
              {
               int lastSwing=-1;
               for(int j=1; j<iBars(OrderSymbol(), ZigzagTrailTF); j++)
                 {
                  if(OrderOpenTime()>=iTime(OrderSymbol(), ZigzagTrailTF, j))
                     break;
                  double LL=iCustom(OrderSymbol(),ZigzagTrailTF,"Kishore Fredrick\\ZigZag_Custom",false,ZigzagTrailTF,2,j);
                  double HL=iCustom(OrderSymbol(),ZigzagTrailTF,"Kishore Fredrick\\ZigZag_Custom",false,ZigzagTrailTF,3,j);
                  if(LL!=0 && LL!=EMPTY_VALUE)
                    {
                     lastSwing=j;
                     break;
                    }
                  if(!ZigzagTrailUseLLHHOnly && HL!=0 && HL!=EMPTY_VALUE)
                    {
                     lastSwing=j;
                     break;
                    }
                 }
               if(lastSwing!=-1)
                 {
                  int barShift=iBarShift(OrderSymbol(), PERIOD_D1, iTime(OrderSymbol(), ZigzagTrailTF, lastSwing))+1;
                  double adr=GetAdrPoints(OrderSymbol(), PERIOD_D1, barShift);
                  double newsl=NormalizeDouble(iLow(OrderSymbol(), ZigzagTrailTF, lastSwing)-adr*ZigzagTrailGapPercentOfADR/100, cdigits);
                  if(NormalizeDouble(newsl, cdigits)>NormalizeDouble(OrderOpenPrice(), cdigits))
                     if(OrderStopLoss()==0 || NormalizeDouble(newsl, cdigits)>NormalizeDouble(OrderStopLoss(), cdigits))
                       {
                        if(NormalizeDouble(SymbolInfoDouble(OrderSymbol(), SYMBOL_BID), cdigits)<=NormalizeDouble(newsl, cdigits))
                          {
                           Print("EnableZigzagTrailing("+GetTimeFrameName(ZigzagTrailTF)+"): try to close order #"+IntegerToString(OrderTicket())+" on "+OrderSymbol());
                           bool _res=OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 20);
                           continue;
                          }
                        else
                          {
                           Print("EnableZigzagTrailing("+GetTimeFrameName(ZigzagTrailTF)+"): try to trail sl of order #"+IntegerToString(OrderTicket())+" on "+OrderSymbol()+" to "+DoubleToString(newsl, cdigits));
                           bool _res=OrderModify(OrderTicket(), OrderOpenPrice(), newsl, OrderTakeProfit(), 0);
                          }
                       }
                 }
              }
            else
               if(OrderType()==OP_SELL)
                 {
                  int lastSwing=-1;
                  for(int j=1; j<iBars(OrderSymbol(), ZigzagTrailTF); j++)
                    {
                     if(OrderOpenTime()>=iTime(OrderSymbol(), ZigzagTrailTF, j))
                        break;
                     double HH=iCustom(OrderSymbol(),ZigzagTrailTF,"Kishore Fredrick\\ZigZag_Custom",false,ZigzagTrailTF,0,j);
                     double LH=iCustom(OrderSymbol(),ZigzagTrailTF,"Kishore Fredrick\\ZigZag_Custom",false,ZigzagTrailTF,1,j);
                     if(HH!=0 && HH!=EMPTY_VALUE)
                       {
                        lastSwing=j;
                        break;
                       }
                     if(!ZigzagTrailUseLLHHOnly && LH!=0 && LH!=EMPTY_VALUE)
                       {
                        lastSwing=j;
                        break;
                       }
                    }
                  if(lastSwing!=-1)
                    {
                     int barShift=iBarShift(OrderSymbol(), PERIOD_D1, iTime(OrderSymbol(), ZigzagTrailTF, lastSwing))+1;
                     double adr=GetAdrPoints(OrderSymbol(), PERIOD_D1, barShift);
                     double newsl=NormalizeDouble(iHigh(OrderSymbol(), ZigzagTrailTF, lastSwing)+adr*ZigzagTrailGapPercentOfADR/100, cdigits);
                     if(NormalizeDouble(newsl, cdigits)<NormalizeDouble(OrderOpenPrice(), cdigits))
                        if(OrderStopLoss()==0 || NormalizeDouble(newsl, cdigits)<NormalizeDouble(OrderStopLoss(), cdigits))
                          {
                           if(NormalizeDouble(SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK), cdigits)>=NormalizeDouble(newsl, cdigits))
                             {
                              Print("EnableZigzagTrailing("+GetTimeFrameName(ZigzagTrailTF)+"): try to close order #"+IntegerToString(OrderTicket())+" on "+OrderSymbol());
                              bool _res=OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 20);
                              continue;
                             }
                           else
                             {
                              Print("EnableZigzagTrailing("+GetTimeFrameName(ZigzagTrailTF)+"): try to trail sl of order #"+IntegerToString(OrderTicket())+" on "+OrderSymbol()+" to "+DoubleToString(newsl, cdigits));
                              bool _res=OrderModify(OrderTicket(), OrderOpenPrice(), newsl, OrderTakeProfit(), 0);
                             }
                          }
                    }
                 }
           }
  }
//+------------------------------------------------------------------+
void ZigzagTrailing2()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderMagicNumber()==MagicNumber && (OrderType()==OP_BUY || OrderType()==OP_SELL))
           {
            int cdigits=(int)SymbolInfoInteger(OrderSymbol(), SYMBOL_DIGITS);
            double point=SymbolInfoDouble(OrderSymbol(), SYMBOL_POINT);
            if(OrderType()==OP_BUY)
              {
               int lastSwing=-1;
               for(int j=1; j<iBars(OrderSymbol(), ZigzagTrailTF2); j++)
                 {
                  if(OrderOpenTime()>=iTime(OrderSymbol(), ZigzagTrailTF2, j))
                     break;
                  double LL=iCustom(OrderSymbol(),ZigzagTrailTF2,"Kishore Fredrick\\ZigZag_Custom",false,ZigzagTrailTF2,2,j);
                  double HL=iCustom(OrderSymbol(),ZigzagTrailTF2,"Kishore Fredrick\\ZigZag_Custom",false,ZigzagTrailTF2,3,j);
                  if(LL!=0 && LL!=EMPTY_VALUE)
                    {
                     lastSwing=j;
                     break;
                    }
                  if(!ZigzagTrailUseLLHHOnly2 && HL!=0 && HL!=EMPTY_VALUE)
                    {
                     lastSwing=j;
                     break;
                    }
                 }
               if(lastSwing!=-1)
                 {
                  int barShift=iBarShift(OrderSymbol(), PERIOD_D1, iTime(OrderSymbol(), ZigzagTrailTF2, lastSwing))+1;
                  double adr=GetAdrPoints(OrderSymbol(), PERIOD_D1, barShift);
                  double newsl=NormalizeDouble(iLow(OrderSymbol(), ZigzagTrailTF2, lastSwing)-adr*ZigzagTrailGapPercentOfADR2/100, cdigits);
                  if(NormalizeDouble(newsl, cdigits)>NormalizeDouble(OrderOpenPrice(), cdigits))
                     if(OrderStopLoss()==0 || NormalizeDouble(newsl, cdigits)>NormalizeDouble(OrderStopLoss(), cdigits))
                       {
                        if(NormalizeDouble(SymbolInfoDouble(OrderSymbol(), SYMBOL_BID), cdigits)<=NormalizeDouble(newsl, cdigits))
                          {
                           Print("EnableZigzagTrailing("+GetTimeFrameName(ZigzagTrailTF2)+"): try to close order #"+IntegerToString(OrderTicket())+" on "+OrderSymbol());
                           bool _res=OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 20);
                           continue;
                          }
                        else
                          {
                           Print("EnableZigzagTrailing("+GetTimeFrameName(ZigzagTrailTF2)+"): try to trail sl of order #"+IntegerToString(OrderTicket())+" on "+OrderSymbol()+" to "+DoubleToString(newsl, cdigits));
                           bool _res=OrderModify(OrderTicket(), OrderOpenPrice(), newsl, OrderTakeProfit(), 0);
                          }
                       }
                 }
              }
            else
               if(OrderType()==OP_SELL)
                 {
                  int lastSwing=-1;
                  for(int j=1; j<iBars(OrderSymbol(), ZigzagTrailTF2); j++)
                    {
                     if(OrderOpenTime()>=iTime(OrderSymbol(), ZigzagTrailTF2, j))
                        break;
                     double HH=iCustom(OrderSymbol(),ZigzagTrailTF2,"Kishore Fredrick\\ZigZag_Custom",false,ZigzagTrailTF2,0,j);
                     double LH=iCustom(OrderSymbol(),ZigzagTrailTF2,"Kishore Fredrick\\ZigZag_Custom",false,ZigzagTrailTF2,1,j);
                     if(HH!=0 && HH!=EMPTY_VALUE)
                       {
                        lastSwing=j;
                        break;
                       }
                     if(!ZigzagTrailUseLLHHOnly2 && LH!=0 && LH!=EMPTY_VALUE)
                       {
                        lastSwing=j;
                        break;
                       }
                    }
                  if(lastSwing!=-1)
                    {
                     int barShift=iBarShift(OrderSymbol(), PERIOD_D1, iTime(OrderSymbol(), ZigzagTrailTF2, lastSwing))+1;
                     double adr=GetAdrPoints(OrderSymbol(), PERIOD_D1, barShift);
                     double newsl=NormalizeDouble(iHigh(OrderSymbol(), ZigzagTrailTF2, lastSwing)+adr*ZigzagTrailGapPercentOfADR2/100, cdigits);
                     if(NormalizeDouble(newsl, cdigits)<NormalizeDouble(OrderOpenPrice(), cdigits))
                        if(OrderStopLoss()==0 || NormalizeDouble(newsl, cdigits)<NormalizeDouble(OrderStopLoss(), cdigits))
                          {
                           if(NormalizeDouble(SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK), cdigits)>=NormalizeDouble(newsl, cdigits))
                             {
                              Print("EnableZigzagTrailing("+GetTimeFrameName(ZigzagTrailTF2)+"): try to close order #"+IntegerToString(OrderTicket())+" on "+OrderSymbol());
                              bool _res=OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 20);
                              continue;
                             }
                           else
                             {
                              Print("EnableZigzagTrailing("+GetTimeFrameName(ZigzagTrailTF2)+"): try to trail sl of order #"+IntegerToString(OrderTicket())+" on "+OrderSymbol()+" to "+DoubleToString(newsl, cdigits));
                              bool _res=OrderModify(OrderTicket(), OrderOpenPrice(), newsl, OrderTakeProfit(), 0);
                             }
                          }
                    }
                 }
           }
  }
//+------------------------------------------------------------------+
string GetTimeFrameName(int tf)
  {
   switch(tf)
     {
      case PERIOD_M1:
         return("M1");
      case PERIOD_M5:
         return("M5");
      case PERIOD_M15:
         return("M15");
      case PERIOD_M30:
         return("M30");
      case PERIOD_H1:
         return("H1");
      case PERIOD_H4:
         return("H4");
      case PERIOD_D1:
         return("D1");
      case PERIOD_W1:
         return("W1");
      case PERIOD_MN1:
         return("MN1");
      case 0:
         return(GetTimeFrameName(Period()));
     }
   return ("");
  }
//+------------------------------------------------------------------+
void CheckForExitPerfectSignal()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderMagicNumber()==MagicNumber && (OrderType()==OP_BUY || OrderType()==OP_SELL))
            if(OrderOpenTime()<=iTime(OrderSymbol(), ExitOnPerfectTF, 1))
              {
               int buyPerfect=0, sellPerfect=0;
               if(SDPerfectReadDataFromFile)
                  bool res=GetSDPerfectData(OrderSymbol(), buyPerfect, sellPerfect);
               if(!SDPerfectReadDataFromFile)
                 {
                  buyPerfect=(int)CheckEmptyValue(getSDPerfect(OrderSymbol(),ExitOnPerfectTF,61,1));
                  sellPerfect=(int)CheckEmptyValue(getSDPerfect(OrderSymbol(),ExitOnPerfectTF,62,1));
                 }
               if(OrderType()==OP_BUY && sellPerfect==1)
                 {
                  Print("try to close trade #"+IntegerToString(OrderTicket())+" on "+OrderSymbol()+" on S&D Perfect signal");
                  bool res=OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 20);
                  continue;
                 }
               else
                  if(OrderType()==OP_SELL && buyPerfect==1)
                    {
                     Print("try to close trade #"+IntegerToString(OrderTicket())+" on "+OrderSymbol()+" on S&D Perfect signal");
                     bool res=OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 20);
                     continue;
                    }
              }
  }
//+------------------------------------------------------------------+
double CheckEmptyValue(double value)
  {
   if(value==EMPTY_VALUE)
      value=0;
   return (value);
  }
//+------------------------------------------------------------------+
double getSDPerfect(string symbol, int tf,int mode,int shift)
  {
   return iCustom(symbol,tf,"Kishore Fredrick\\SupplyDemandCandlePatterns-Indicator",SDPerfectShowObjects,SDPerfectDirectionFilter,ExitOnPerfectTF,SDPerfectNumberOfDays,SDPerfectVolumeZone_Filter,SDPerfectVolumeZone_Timeframe1,SDPerfectVolumeZone_Timeframe2,SDPerfectBreachLogicBasedOnEntries,SDPerfectBreachLogicBasedOnEntries_Percent,SDPerfectNeededConditionsToConfirm,mode,shift);
  }
//+------------------------------------------------------------------+
bool GetSDPerfectData(string symbol, int &buyPerfect, int &sellPerfect)
  {
   buyPerfect=0;
   sellPerfect=0;
   bool found=false;
   string stime=TimeToString(Time[0], TIME_MINUTES);
   StringReplace(stime, ":", "");
   string fileName=SDPerfectFolderName+"\\"+IntegerToString(SDPerfectFolderNumber)+"\\"+SDPerfectFileName+"_"+stime+".txt";
   int handle=FileOpen(fileName, FILE_TXT|FILE_COMMON|FILE_SHARE_READ|FILE_READ);
   if(handle>0)
     {
      string buffer="", sp[];
      while(!FileIsEnding(handle))
        {
         buffer=FileReadString(handle);
         StringSplit(buffer, StringGetCharacter(",", 0), sp);
         if(ArraySize(sp)>=3)
           {
            if(sp[0]==symbol)
              {
               buyPerfect=(int)StringToInteger(sp[1]);
               sellPerfect=(int)StringToInteger(sp[2]);
               found=true;
               break;
              }
           }
        }
      FileClose(handle);
     }
   return (found);
  }
//+------------------------------------------------------------------+
void BreakEvenTrades()
  {
   string CmtArray[];

   for(int i=0; i<OrdersTotal(); i++)
     {
      RefreshRates();
      bool os = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()!=OP_BUY && OrderType()!=OP_SELL)
         continue;
      if(OrderMagicNumber()!=MagicNumber)
         continue;
      int k = StringSplit(OrderComment(),StringGetCharacter("#",0),CmtArray);

      if(k==0) //k=0 means no order comments
        {
         Print("BEven Error : No Comment mentioned in Orders for #"+IntegerToString(OrderTicket()));
         return;
        }
      double cmtSL = (double)CmtArray[1];
      // Pips gained for now
      double PipProfit=0, PipStopLoss=0;
      double be;
      int om;
      int cdigits=(int)SymbolInfoInteger(OrderSymbol(), SYMBOL_DIGITS);
      double point=SymbolInfoDouble(OrderSymbol(), SYMBOL_POINT);
      for(int b=0; b<=RewardPercent; b++)
        {
         // Calculate pips for stoploss
         if(OrderType()==OP_BUY)
           {
            // If this trade is losing or free
            if(MarketInfo(OrderSymbol(),MODE_BID)<OrderOpenPrice())
               continue;
            // Profit and so forth
            PipProfit = NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID) - OrderOpenPrice(),cdigits);
            PipStopLoss = NormalizeDouble((cmtSL * (Breakeven_Start + (b*Breakeven_Step))),cdigits);
           }
         else
            if(OrderType()==OP_SELL)
              {
               // Profit and so forth
               PipProfit = NormalizeDouble(OrderOpenPrice() - MarketInfo(OrderSymbol(),MODE_ASK),cdigits);
               PipStopLoss = NormalizeDouble((cmtSL * (Breakeven_Start + (b*Breakeven_Step))),cdigits);
              }
         int stops_level=(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_TRADE_STOPS_LEVEL);
         if(PipProfit > PipStopLoss && PipStopLoss!=0)
           {
            if(OrderType()==OP_BUY)
              {
               //Breakeven_Step is 0 means then step breakeven will not work
               double val = NormalizeDouble(cmtSL * (Breakeven_Start + (b*Breakeven_Step) - Breakeven_Step),cdigits);
               be = (Breakeven_Step!=0) ? NormalizeDouble(OrderOpenPrice()+val,cdigits) : NormalizeDouble(OrderOpenPrice(),cdigits) ;
               bool SL_check=(be!=0) ? (MarketInfo(OrderSymbol(),MODE_BID)-be>stops_level*point) : true;
               double pv=SymbolInfoDouble(OrderSymbol(), SYMBOL_TRADE_TICK_VALUE)/SymbolInfoDouble(OrderSymbol(), SYMBOL_TRADE_TICK_SIZE);
               double commPoints=MathCeil(-(OrderCommission()+OrderSwap())/(pv*OrderLots())/point)*point;
               if(commPoints<0)
                  commPoints=0;
               be+=commPoints;
               if(SL_check && NormalizeDouble(be, cdigits)>NormalizeDouble(OrderStopLoss(), cdigits))
                 {
                  om = OrderModify(OrderTicket(),OrderOpenPrice(),be,OrderTakeProfit(),0,clrYellow);
                  isBreakeven = true;
                  break;
                 }
              }
            else
               if(OrderType()==OP_SELL)
                 {
                  double val = NormalizeDouble(cmtSL * (Breakeven_Start + (b*Breakeven_Step) - Breakeven_Step),cdigits);
                  be = (Breakeven_Step!=0) ? NormalizeDouble(OrderOpenPrice()-val,cdigits) : NormalizeDouble(OrderOpenPrice(),cdigits) ;
                  bool SL_check=(be!=0) ? (be-MarketInfo(OrderSymbol(),MODE_ASK)>stops_level*point) : true;
                  double pv=SymbolInfoDouble(OrderSymbol(), SYMBOL_TRADE_TICK_VALUE)/SymbolInfoDouble(OrderSymbol(), SYMBOL_TRADE_TICK_SIZE);
                  double commPoints=MathCeil(-(OrderCommission()+OrderSwap())/(pv*OrderLots())/point)*point;
                  if(commPoints<0)
                     commPoints=0;
                  be-=commPoints;
                  if(SL_check && (NormalizeDouble(be, cdigits)<NormalizeDouble(OrderStopLoss(), cdigits) || OrderStopLoss()==0))
                    {
                     om = OrderModify(OrderTicket(),OrderOpenPrice(),be,OrderTakeProfit(),0,clrYellow);
                     isBreakeven = true;
                     break;
                    }
                 }
           }
        }
     }
  }
//+------------------------------------------------------------------+
int IsAnyOrderActive(int type)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderMagicNumber()==MagicNumber)
            if(type==-1 || OrderType()==type)
               return (OrderTicket());
   return (-1);
  }
//+------------------------------------------------------------------+
void CloseAllOrders(int type)
  {
   bool anyClosed = false;
   int delay=200, tries=0;
   while(IsAnyOrderActive(type)!=-1 && tries<100)
     {
      for(int i=OrdersTotal()-1; i>=0; i--)
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            if(OrderMagicNumber()==MagicNumber)
               if(type==-1 || OrderType()==type)
                 {
                  int ticket=OrderTicket();
                  if(IsTradeContextBusy())
                     Sleep(delay);
                  if(IsTradeContextBusy())
                     Sleep(delay);
                  if(IsTradeContextBusy())
                     Sleep(delay);
                  RefreshRates();
                  bool _res;
                  if(OrderType()==OP_BUY)
                     _res=OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 20);
                  else
                     if(OrderType()==OP_SELL)
                        _res=OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 20);
                     else
                        _res=OrderDelete(OrderTicket());
                  anyClosed=true;
                 }
      tries ++;
     }
  }
//+------------------------------------------------------------------+
int stringToTimeFrame(string tfs)
  {
   return(Period());
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TakeScreenshot(string otype)
  {
   long chartID=-1;
   string tfname = GetTFName(PERIOD_CURRENT);
   string time=TimeToString(Time[0],TIME_DATE) +"_"+ TimeToString(Time[0],TIME_MINUTES);
   StringReplace(time,".","_");
   StringReplace(time,":","_");
   string name = "Screenshots/" + cur_symbol+"-"+whichPattern+"-"+tfname+"-"+otype+"-"+time+".jpg";

   if(EnableFileScanner)
     {
      chartID=ChartOpen(cur_symbol,PERIOD_CURRENT);
      if(chartID>0 && chartID!=ChartID())
        {
         ChartApplyTemplate(chartID,"default");
         ChartRedraw(chartID);
        }
     }
   else
     {
      chartID = 0;
     }

   if(chartID>0 && ChartScreenShot(chartID,name,WIDTH,HEIGHT,ALIGN_RIGHT))
     {
      Print("Screenshot saved : ",name);
     }

   if(EnableFileScanner && chartID!=0 && chartID!=ChartID())
     {
      ChartClose(chartID);
     }
  }
//+------------------------------------------------------------------+
//GET TIMEFRAME NAME
string GetTFName(int p)
  {
   string tf="";
   if(p==0)
      p = Period();
   if(p==1)
      tf = "M1";
   if(p==5)
      tf = "M5";
   if(p==15)
      tf = "M15";
   if(p==30)
      tf = "M30";
   if(p==60)
      tf = "H1";
   if(p==240)
      tf = "H4";
   if(p==1440)
      tf = "D1";
   if(p==10080)
      tf = "W1";
   if(p==43200)
      tf = "MN1";
   return tf;
  }
//+------------------------------------------------------------------+
void Check_SSM_Orders()
  {
   int order_count = GetOrderCount(-1);
   bool lo_check = LastOrderCheck(-1);
   double sl=0;

   bool check_running = (lo_check && order_count<MaxRunningOrders && MaxRunningOrders!=0) ? true : false;
   int total_limit_orders = 0;
   if(!AllowOppositeSignals)
      total_limit_orders=(GetTotalOrders("BuyLimit",OP_BUYLIMIT)+GetTotalOrders("SellLimit",OP_SELLLIMIT));
   else
      total_limit_orders=(cur_sigOPType==OP_BUY?GetTotalOrders("BuyLimit",OP_BUYLIMIT):GetTotalOrders("SellLimit",OP_SELLLIMIT));

   allow_ssmlimit_trade = (checkNews && check_running && TimeCheck && (DoesSignalCatched(cur_symbol, -1, iTime(cur_symbol, 0, 0))==-1) && total_limit_orders<MaxLimitOrders) ? true : false;

   RefreshRates();
   int ztshift = iBarShift(cur_symbol,0,ssm_zonetime);
   int shift_sat = iBarShift(cur_symbol,0,ssm_shiftAggrTime);
   int shift_sct = iBarShift(cur_symbol,0,ssm_shiftConsTime);

   if(allow_ssmlimit_trade)
     {

      bool bssm_check = false,bssm_sz=false;
      bool sssm_check = false,sssm_sz=false;
      bool bdirection = (cur_sigOPType==OP_BUY) ? true : false;
      bool sdirection = (cur_sigOPType==OP_SELL) ? true : false;

      if(bdirection && conf_genTime && ssm_strength>=ValueAboveBelow && ssm_shiftAggr==0 && ssm_shiftCons==0)
        {
         PlaceZoneLimit(OP_BUY,"103",ztshift,"106",iPlus);
         allow_ssmlimit_trade = false;
         ssm_limit_triggered = Time[0];
        }
      else
         if(sdirection && conf_genTime && ssm_strength<=-ValueAboveBelow && ssm_shiftAggr==0 && ssm_shiftCons==0)
           {
            PlaceZoneLimit(OP_SELL,"103",ztshift,"106",iPlus);
            allow_ssmlimit_trade = false;
            ssm_limit_triggered = Time[0];
           }

      if(bdirection && conf_genTime && ssm_shiftAggr>=ValueAboveBelow && ssm_shiftCons>=ValueAboveBelow)
        {
         PlaceZoneLimit(OP_BUY,"104",shift_sct,"107",iPlus);
         PlaceZoneLimit(OP_BUY,"105",shift_sat,"108",iPlus);
         allow_ssmlimit_trade = false;
         ssm_limit_triggered = Time[0];
        }
      if(sdirection && conf_genTime && ssm_shiftAggr<=-ValueAboveBelow && ssm_shiftCons<=-ValueAboveBelow)
        {
         PlaceZoneLimit(OP_SELL,"104",shift_sct,"107",iPlus);
         PlaceZoneLimit(OP_SELL,"105",shift_sat,"108",iPlus);
         allow_ssmlimit_trade = false;
         ssm_limit_triggered = Time[0];
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Check_All_LOrders()
  {
   int order_count = GetOrderCount(-1);
   bool lo_check = true;//LastOrderCheck();
   double sl=0;
//if any running order, then no limit order should be placed
   bool check_running = (lo_check && order_count<MaxRunningOrders && MaxRunningOrders!=0) ? true : false;
   int total_limit_orders = 0;
   if(!AllowOppositeSignals)
      total_limit_orders=(GetTotalOrders("BuyLimit",OP_BUYLIMIT)+GetTotalOrders("SellLimit",OP_SELLLIMIT));
   else
      total_limit_orders=(cur_sigOPType==OP_BUY?GetTotalOrders("BuyLimit",OP_BUYLIMIT):GetTotalOrders("SellLimit",OP_SELLLIMIT));
   allow_alllimit_trade = (checkNews && check_running && TimeCheck && (DoesSignalCatched(cur_symbol, -1, iTime(cur_symbol, 0, 0))==-1) && total_limit_orders<MaxLimitOrders) ? true : false;

   RefreshRates();

   if(allow_alllimit_trade)
     {
      //Print("MAC conf_genTime="+conf_genTime+" mac_limit_dir="+mac_limit_dir+" mac_consTime="+mac_consTime+" mac_aggrTime="+mac_aggrTime+" T="+Time[0]);
      bool bdirection = (cur_sigOPType==OP_BUY) ? true : false;
      bool sdirection = (cur_sigOPType==OP_SELL) ? true : false;

      if(EnableMACLimitOrders)
        {
         double mac_limit_dir = getMAC(0,2,iPlus);
         mac_consTime = (datetime)getMAC(0,10,iPlus);
         mac_aggrTime = (datetime)getMAC(0,11,iPlus);

         int shift_mat = iBarShift(cur_symbol,0,mac_aggrTime);
         int shift_mct = iBarShift(cur_symbol,0,mac_consTime);
         //Print("mac_limit_dir="+mac_limit_dir+" mac_consTime="+mac_consTime+" mac_aggrTime="+mac_aggrTime+" T="+Time[iPlus]);
         if(bdirection && conf_genTime && mac_limit_dir==1)
           {
            PlaceZoneLimit(OP_BUY,"115",shift_mct,"117",iPlus);
            PlaceZoneLimit(OP_BUY,"116",shift_mat,"118",iPlus);

            //only one time limit order placing is allowed, if it is failed to place, then it should not check for the same again
            allow_alllimit_trade = false;
            all_limit_triggered = Time[0];
           }
         else
            if(sdirection && conf_genTime && mac_limit_dir==-1)
              {
               PlaceZoneLimit(OP_SELL,"115",shift_mct,"117",iPlus);
               PlaceZoneLimit(OP_SELL,"116",shift_mat,"118",iPlus);

               allow_alllimit_trade = false;
               all_limit_triggered = Time[0];
              }
        }
      if(EnableVolZoneLimitOrders)
        {
         int cbs = (TouchHTF==Period()) ? iPlus : iBarShift(cur_symbol,TouchHTF,Time[0])+1;
         double vz_bdir = (cur_sigOPType==OP_BUY) ? getVolZone(TouchHTF,1,cbs) : EMPTY_VALUE;
         double vz_sdir = (cur_sigOPType==OP_SELL) ? getVolZone(TouchHTF,2,cbs) : EMPTY_VALUE;

         datetime vz_consTime = (datetime)getVolZone(TouchHTF,17,iPlus);

         int shift_mct = iBarShift(cur_symbol,0,vz_consTime);

         if(bdirection && conf_genTime && vz_bdir!=EMPTY_VALUE)
           {
            PlaceZoneLimit(OP_BUY,"131",shift_mct,"132",iPlus);
            allow_alllimit_trade = false;
            all_limit_triggered = Time[0];
           }
         else
            if(sdirection && conf_genTime && vz_sdir!=EMPTY_VALUE)
              {
               PlaceZoneLimit(OP_SELL,"131",shift_mct,"132",iPlus);
               allow_alllimit_trade = false;
               all_limit_triggered = Time[0];
              }
        }
      if(EnableLiqLimitOrders)
        {
         double liq_dir = getLiquidityMA(0,2,iPlus);
         datetime liq_consTime = (datetime)getLiquidityMA(0,10,iPlus);

         int shift_mct = iBarShift(cur_symbol,0,liq_consTime);

         //Print("liq_dir="+liq_dir+" liq_consTime="+liq_consTime+" conf_genTime="+conf_genTime+" confTime="+confTime+" EntryTime="+EntryTime+" sdirection="+sdirection+" T="+Time[iPlus]);
         if(bdirection && conf_genTime && liq_dir==1)
           {
            PlaceZoneLimit(OP_BUY,"121",shift_mct,"122",iPlus);
            //only one time limit order placing is allowed, if it is failed to place, then it should not check for the same again
            allow_alllimit_trade = false;
            all_limit_triggered = Time[0];
           }
         else
            if(sdirection && conf_genTime && liq_dir==-1)
              {
               PlaceZoneLimit(OP_SELL,"121",shift_mct,"122",iPlus);
               allow_alllimit_trade = false;
               all_limit_triggered = Time[0];
              }
        }
      if(EnableRevLimitOrders)
        {
         double rev_dir = getReversalMA(0,2,iPlus);
         datetime rev_consTime = (datetime)getReversalMA(0,10,iPlus);
         datetime rev_aggrTime = (datetime)getReversalMA(0,11,iPlus);

         int shift_mat = iBarShift(cur_symbol,0,rev_aggrTime);
         int shift_mct = iBarShift(cur_symbol,0,rev_consTime);

         if(bdirection && conf_genTime && rev_dir==1)
           {
            PlaceZoneLimit(OP_BUY,"125",shift_mct,"127",iPlus);
            PlaceZoneLimit(OP_BUY,"126",shift_mat,"128",iPlus);

            //only one time limit order placing is allowed, if it is failed to place, then it should not check for the same again
            allow_alllimit_trade = false;
            all_limit_triggered = Time[0];
           }
         else
            if(sdirection && conf_genTime && rev_dir==-1)
              {
               PlaceZoneLimit(OP_SELL,"125",shift_mct,"127",iPlus);
               PlaceZoneLimit(OP_SELL,"126",shift_mat,"128",iPlus);

               allow_alllimit_trade = false;
               all_limit_triggered = Time[0];
              }
        }
      if(EnableSDLimitOrders)
        {
         //Checking 8 patterns
         int bmode = 4,smode = 5;

         for(int pat=1; pat<=8; pat++)
           {
            string patNum = "_"+(string)pat;
            double sd_bdir = (cur_sigOPType==OP_BUY) ? getSD(0,bmode,iPlus) : EMPTY_VALUE;
            double sd_sdir = (cur_sigOPType==OP_SELL) ? getSD(0,smode,iPlus) : EMPTY_VALUE;
            int wchmode = (cur_sigOPType==OP_BUY && sd_bdir != EMPTY_VALUE) ? (bmode+2) : (cur_sigOPType==OP_SELL && sd_sdir != EMPTY_VALUE) ? (smode+1) : 0;

            if(wchmode!=0)
              {
               datetime sd_ztime = (datetime)getSD(0,wchmode,iPlus);
               int sd_zshift = iBarShift(cur_symbol,0,sd_ztime);

               if(bdirection && conf_genTime && sd_bdir!=EMPTY_VALUE)
                 {
                  PlaceZoneLimit(OP_BUY,"135"+patNum,sd_zshift,"136"+patNum,iPlus);
                  allow_alllimit_trade = false;
                  all_limit_triggered = Time[0];
                 }
               else
                  if(sdirection && conf_genTime && sd_sdir!=EMPTY_VALUE)
                    {
                     PlaceZoneLimit(OP_SELL,"135"+patNum,sd_zshift,"136"+patNum,iPlus);
                     allow_alllimit_trade = false;
                     all_limit_triggered = Time[0];
                    }
               break;
              }
            bmode+=6;
            smode+=6;
           }
        }
      if(EnablePA1LimitOrders)
        {
         //Checking 8 patterns
         int bmode = 0,smode = 1;
         for(int pat=1; pat<=8; pat++)
           {
            string patNum = "_"+(string)pat;
            double pa1_bdir = (cur_sigOPType==OP_BUY) ? getPA1(PA1TF,bmode,0) : EMPTY_VALUE;
            double pa1_sdir = (cur_sigOPType==OP_SELL) ? getPA1(PA1TF,smode,0) : EMPTY_VALUE;
            int zcons = (cur_sigOPType==OP_BUY && pa1_bdir != EMPTY_VALUE) ? (bmode+2) : (cur_sigOPType==OP_SELL && pa1_sdir != EMPTY_VALUE) ? (smode+1) : 0;
            int zagg = (cur_sigOPType==OP_BUY && pa1_bdir != EMPTY_VALUE) ? (bmode+6) : (cur_sigOPType==OP_SELL && pa1_sdir != EMPTY_VALUE) ? (smode+5) : 0;

            if(zcons!=0)
              {
               datetime pa1_contime = (datetime)getPA1(PA1TF,zcons,0);
               datetime pa1_aggtime = (datetime)getPA1(PA1TF,zagg,0);
               int pa1_zcons = iBarShift(cur_symbol,0,pa1_contime);
               int pa1_zagg = iBarShift(cur_symbol,0,pa1_aggtime);

               if(bdirection && conf_genTime && pa1_bdir!=EMPTY_VALUE)
                 {
                  PlaceZoneLimit(OP_BUY,"139"+patNum,pa1_zcons,"141"+patNum,iPlus);
                  PlaceZoneLimit(OP_BUY,"140"+patNum,pa1_zagg,"142"+patNum,iPlus);
                  allow_alllimit_trade = false;
                  all_limit_triggered = Time[0];
                  break;
                 }
               else
                  if(sdirection && conf_genTime && pa1_sdir!=EMPTY_VALUE)
                    {
                     PlaceZoneLimit(OP_SELL,"139"+patNum,pa1_zcons,"141"+patNum,iPlus);
                     PlaceZoneLimit(OP_SELL,"140"+patNum,pa1_zagg,"142"+patNum,iPlus);
                     allow_alllimit_trade = false;
                     all_limit_triggered = Time[0];
                     break;
                    }
              }
            bmode+=10;
            smode+=10;
           }
        }
      if(EnablePA2LimitOrders)
        {
         //Checking 8 patterns
         int bmode = 0,smode = 1;
         for(int pat=1; pat<=8; pat++)
           {
            string patNum = "_"+(string)pat;

            double pa2_bdir = (cur_sigOPType==OP_BUY) ? getPA2(PA2TF,bmode,iPlus) : EMPTY_VALUE;
            double pa2_sdir = (cur_sigOPType==OP_SELL) ? getPA2(PA2TF,smode,iPlus) : EMPTY_VALUE;
            int zcons = (cur_sigOPType==OP_BUY && pa2_bdir != EMPTY_VALUE) ? (bmode+2) : (cur_sigOPType==OP_SELL && pa2_sdir != EMPTY_VALUE) ? (smode+1) : 0;
            int zagg = (cur_sigOPType==OP_BUY && pa2_bdir != EMPTY_VALUE) ? (bmode+6) : (cur_sigOPType==OP_SELL && pa2_sdir != EMPTY_VALUE) ? (smode+5) : 0;
            //Print("pa2_sdir="+pa2_sdir+" smode="+smode+" cur_sigOPType="+cur_sigOPType+" zcons="+zcons+" zagg="+zagg+" conf_genTime="+conf_genTime+" T="+Time[0]);
            if(zcons!=0)
              {
               datetime pa2_contime = (datetime)getPA2(PA2TF,zcons,iPlus);
               datetime pa2_aggtime = (datetime)getPA2(PA2TF,zagg,iPlus);
               int pa2_zcons = iBarShift(cur_symbol,0,pa2_contime);
               int pa2_zagg = iBarShift(cur_symbol,0,pa2_aggtime);
               //Print("pa2_contime="+pa2_contime+" pa2_aggtime="+pa2_aggtime+" pat="+pat+" zcons="+zcons+" zagg="+zagg+" bmode="+bmode+" bdirection="+bdirection+" conf_genTime="+conf_genTime+"  T="+Time[0]);

               if(bdirection && conf_genTime && pa2_bdir!=EMPTY_VALUE)
                 {
                  PlaceZoneLimit(OP_BUY,"145"+patNum,pa2_zcons,"147"+patNum,iPlus);
                  PlaceZoneLimit(OP_BUY,"146"+patNum,pa2_zagg,"148"+patNum,iPlus);
                  allow_alllimit_trade = false;
                  all_limit_triggered = Time[0];
                  break;
                 }
               else
                  if(sdirection && conf_genTime && pa2_sdir!=EMPTY_VALUE)
                    {
                     PlaceZoneLimit(OP_SELL,"145"+patNum,pa2_zcons,"147"+patNum,iPlus);
                     PlaceZoneLimit(OP_SELL,"146"+patNum,pa2_zagg,"148"+patNum,iPlus);
                     allow_alllimit_trade = false;
                     all_limit_triggered = Time[0];
                     break;
                    }
              }
            bmode+=10;
            smode+=10;
           }
        }

      if(EnableWedgesLimitOrders)
        {
         //Checking 3 patterns
         int bmode = 0,smode = 1;
         for(int pat=1; pat<=3; pat++)
           {
            string patNum = "_"+(string)pat;

            double wed_bdir = (cur_sigOPType==OP_BUY) ? getWedges(WedgesTF,bmode,iPlus) : EMPTY_VALUE;
            double wed_sdir = (cur_sigOPType==OP_SELL) ? getWedges(WedgesTF,smode,iPlus) : EMPTY_VALUE;
            int zcons = (cur_sigOPType==OP_BUY && wed_bdir != EMPTY_VALUE) ? (bmode+2) : (cur_sigOPType==OP_SELL && wed_sdir != EMPTY_VALUE) ? (smode+1) : 0;
            int zagg = (cur_sigOPType==OP_BUY && wed_bdir != EMPTY_VALUE) ? (bmode+6) : (cur_sigOPType==OP_SELL && wed_sdir != EMPTY_VALUE) ? (smode+5) : 0;
            //Print("wed_bdir="+wed_bdir+" wed_sdir="+wed_sdir+" zcons="+zcons+" bmode="+bmode+" smode="+smode+" pat="+pat+" T="+Time[iPlus]);
            if(zcons!=0)
              {
               datetime wed_contime = (datetime)getWedges(WedgesTF,zcons,iPlus);
               datetime wed_aggtime = (datetime)getWedges(WedgesTF,zagg,iPlus);
               int wed_zcons = iBarShift(cur_symbol,0,wed_contime);
               int wed_zagg = iBarShift(cur_symbol,0,wed_aggtime);

               if(bdirection && conf_genTime && wed_bdir!=EMPTY_VALUE)
                 {
                  double consDir = (EnableWedgesProfitZone) ? getProfitZone(PZTF,8,zcons,confBarShift) : 0;
                  bool cons_check = (EnableWedgesProfitZone) ? (consDir==1) : true;

                  if(cons_check)
                     PlaceZoneLimit(OP_BUY,"151"+patNum,wed_zcons,"153"+patNum,iPlus);

                  double aggDir = (EnableWedgesProfitZone) ? getProfitZone(PZTF,8,wed_zagg,confBarShift) : 0;
                  bool agg_check = (EnableWedgesProfitZone) ? (aggDir==1) : true;

                  if(agg_check)
                     PlaceZoneLimit(OP_BUY,"152"+patNum,wed_zagg,"154"+patNum,iPlus);

                  allow_alllimit_trade = false;
                  all_limit_triggered = Time[0];
                  break;
                 }
               else
                  if(sdirection && conf_genTime && wed_sdir!=EMPTY_VALUE)
                    {
                     double consDir = (EnableWedgesProfitZone) ? getProfitZone(PZTF,12,zcons,confBarShift) : 0;
                     bool cons_check = (EnableWedgesProfitZone) ? (consDir==-1) : true;

                     if(cons_check)
                        PlaceZoneLimit(OP_SELL,"151"+patNum,wed_zcons,"153"+patNum,iPlus);

                     double aggDir = (EnableWedgesProfitZone) ? getProfitZone(PZTF,12,wed_zagg,confBarShift) : 0;
                     bool agg_check = (EnableWedgesProfitZone) ? (aggDir==-1) : true;

                     if(agg_check)
                        PlaceZoneLimit(OP_SELL,"152"+patNum,wed_zagg,"154"+patNum,iPlus);

                     allow_alllimit_trade = false;
                     all_limit_triggered = Time[0];
                     break;
                    }
              }
            bmode+=10;
            smode+=10;
           }
        }
      if(EnableRSIDLimitOrders)
        {
         double rsid_dir = getRSIDivg(0,2,iPlus);
         datetime rsid_consTime = (datetime)getRSIDivg(0,10,iPlus);
         datetime rsid_aggrTime = (datetime)getRSIDivg(0,11,iPlus);

         int shift_mat = iBarShift(cur_symbol,0,rsid_consTime);
         int shift_mct = iBarShift(cur_symbol,0,rsid_aggrTime);

         if(bdirection && conf_genTime && rsid_dir==1)
           {
            PlaceZoneLimit(OP_BUY,"159",shift_mct,"161",iPlus);
            PlaceZoneLimit(OP_BUY,"160",shift_mat,"162",iPlus);

            //only one time limit order placing is allowed, if it is failed to place, then it should not check for the same again
            allow_alllimit_trade = false;
            all_limit_triggered = Time[0];
           }
         else
            if(sdirection && conf_genTime && rsid_dir==-1)
              {
               PlaceZoneLimit(OP_SELL,"159",shift_mct,"161",iPlus);
               PlaceZoneLimit(OP_SELL,"160",shift_mat,"162",iPlus);

               allow_alllimit_trade = false;
               all_limit_triggered = Time[0];
              }
        }
      if(EnableLGrabLimitOrders)
        {
         double liqgrab_dir_conf = getLiquidityGrab(LG_ETF,2,iPlus);
         datetime consTime = (datetime)getLiquidityGrab(LG_ETF,10,iPlus);
         datetime aggrTime = (datetime)getLiquidityGrab(LG_ETF,11,iPlus);
         datetime consTime2 = (datetime)getLiquidityGrab(LG_ETF,12,iPlus);

         int shift_mat = iBarShift(cur_symbol,0,aggrTime);
         int shift_mct = iBarShift(cur_symbol,0,consTime);
         int shift_mct2 = iBarShift(cur_symbol,0,consTime2);

         if(bdirection && conf_genTime && liqgrab_dir_conf==1)
           {
            PlaceZoneLimit(OP_BUY,"167",shift_mct,"169",iPlus);
            PlaceZoneLimit(OP_BUY,"168",shift_mat,"170",iPlus);
            PlaceZoneLimit(OP_BUY,"171",shift_mct2,"172",iPlus);

            //only one time limit order placing is allowed, if it is failed to place, then it should not check for the same again
            allow_alllimit_trade = false;
            all_limit_triggered = Time[0];
           }
         else
            if(sdirection && conf_genTime && liqgrab_dir_conf==-1)
              {
               PlaceZoneLimit(OP_SELL,"167",shift_mct,"169",iPlus);
               PlaceZoneLimit(OP_SELL,"168",shift_mat,"170",iPlus);
               PlaceZoneLimit(OP_SELL,"171",shift_mct2,"172",iPlus);

               allow_alllimit_trade = false;
               all_limit_triggered = Time[0];
              }
        }
      //if(Time[0]==StrToTime("2022.04.05 02:10"))
      //Print("check_crcCons="+check_crcCons+" check_crcConsMax="+check_crcConsMax+" crcCons="+crcCons+" crcConsMax="+crcConsMax+" check_crcAggr="+check_crcAggr+" check_crcAggrMax="+check_crcAggrMax+" T="+Time[0]);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Check_ZIZ_Orders()
  {
   allow_zizlimit_trade = (GetTotalOrders("BuyLimit",OP_BUYLIMIT)<=MaxLimitOrders && GetTotalOrders("SellLimit",OP_SELLLIMIT)<=MaxLimitOrders) ? true : false;

   if(MaxArrowLimitOrders>MaxLimitOrders)
      return;

   RefreshRates();
   datetime whichTime,whichTime2,whichTime3;
   int zizshift,zizshift2,zizshift3,ord_status;
   double ZHigh=0,ZLow=0,ZDiff=0,ZHigh2=0,ZLow2=0,ZDiff2=0,ZHigh3=0,ZLow3=0,ZDiff3=0;
   string cmt="";

   whichTime = (ziz_signal==1) ? ziz_buytime : (ziz_signal==-1) ? ziz_selltime : 0;
   zizshift = iBarShift(cur_symbol,0,whichTime);
   ZHigh = iHigh(cur_symbol,0,zizshift);
   ZLow = iLow(cur_symbol,0,zizshift);
   ZDiff = NormalizeDouble(ZHigh - ZLow,cur_digits);

   if(MaxArrowLimitOrders>=2)
     {
      whichTime2 = (ziz_signal==1) ? ziz_buytime2 : (ziz_signal==-1) ? ziz_selltime2 : 0;
      zizshift2 = iBarShift(cur_symbol,0,whichTime2);
      ZHigh2 = iHigh(cur_symbol,0,zizshift2);
      ZLow2 = iLow(cur_symbol,0,zizshift2);
      ZDiff2 = NormalizeDouble(ZHigh2 - ZLow2,cur_digits);
     }

   if(MaxArrowLimitOrders==3)
     {
      whichTime3 = (ziz_signal==1) ? ziz_buytime3 : (ziz_signal==-1) ? ziz_selltime3 : 0;
      zizshift3 = iBarShift(cur_symbol,0,whichTime3);
      ZHigh3 = iHigh(cur_symbol,0,zizshift3);
      ZLow3 = iLow(cur_symbol,0,zizshift3);
      ZDiff3 = NormalizeDouble(ZHigh3 - ZLow3,cur_digits);
     }

   if(allow_zizlimit_trade)
     {
      bool bziz_check = (ziz_signal==1) ? true : false;
      bool sziz_check = (ziz_signal==-1) ? true : false;

      if(bziz_check)
        {
         cur_Signal = "BUY";
         EntryTime = iTime(cur_symbol,0,0);

         EntryPrice = ZHigh;
         whichPattern = "ZIZ1"+(string)ziz_signal;
         buy_sl = NormalizeDouble(ZDiff + ZDiff * (ZoneBufferTPSL/100),cur_digits);
         tp_sl_range = NormalizeDouble(buy_sl * RewardPercent,cur_digits);
         lot_size = GetPositionSizingLot(buy_sl);
         if(CheckMoneyForTrade(cur_symbol,lot_size,OP_BUY) == false)
            return;
         OriginalTP = (EnableTargetInd && (btargetind!=EMPTY_VALUE && btargetind!=0)) ? btargetind : (EnableAsianTarget) ? basiantarget : EntryPrice + tp_sl_range;
         OriginalSL = EntryPrice - buy_sl;
         cmt = EA_Name+"-"+whichPattern+"-"+(string)MagicNumber+"#"+DoubleToStr(buy_sl,cur_digits);
         ord_status = OrderSend(cur_symbol,OP_BUYLIMIT,lot_size, EntryPrice, slip, OriginalSL,OriginalTP,cmt, MagicNumber, 0, Lime);
         if(ord_status < 0)
           {
            Print(cur_symbol+" Error ZIZLB1 : ", GetLastError());
            return;
           }

         if(MaxArrowLimitOrders>=2)
           {
            EntryPrice = ZHigh2;
            whichPattern = "ZIZ2"+(string)ziz_signal;
            buy_sl = NormalizeDouble(ZDiff2 + ZDiff2 * (ZoneBufferTPSL/100),cur_digits);
            tp_sl_range = NormalizeDouble(buy_sl * RewardPercent,cur_digits);
            lot_size = GetPositionSizingLot(buy_sl);
            if(CheckMoneyForTrade(cur_symbol,lot_size,OP_BUY) == false)
               return;
            OriginalTP = (EnableTargetInd && (btargetind!=EMPTY_VALUE && btargetind!=0)) ? btargetind : (EnableAsianTarget) ? basiantarget : EntryPrice + tp_sl_range;
            OriginalSL = EntryPrice - buy_sl;
            cmt = EA_Name+"-"+whichPattern+"-"+(string)MagicNumber+"#"+DoubleToStr(sell_sl,cur_digits);
            ord_status = OrderSend(cur_symbol,OP_BUYLIMIT,lot_size, EntryPrice, slip, OriginalSL,OriginalTP,cmt, MagicNumber, 0, Lime);
            if(ord_status < 0)
              {
               Print(cur_symbol+" Error ZIZLB2 : ", GetLastError());
               return;
              }
           }

         if(MaxArrowLimitOrders==3)
           {
            EntryPrice = ZHigh3;
            whichPattern = "ZIZ3"+(string)ziz_signal;
            buy_sl = NormalizeDouble(ZDiff3 + ZDiff3 * (ZoneBufferTPSL/100),cur_digits);
            tp_sl_range = NormalizeDouble(buy_sl * RewardPercent,cur_digits);
            lot_size = GetPositionSizingLot(buy_sl);
            if(CheckMoneyForTrade(cur_symbol,lot_size,OP_BUY) == false)
               return;
            OriginalTP = (EnableTargetInd && (btargetind!=EMPTY_VALUE && btargetind!=0)) ? btargetind : (EnableAsianTarget) ? basiantarget : EntryPrice + tp_sl_range;
            OriginalSL = EntryPrice - buy_sl;
            cmt = EA_Name+"-"+whichPattern+"-"+(string)MagicNumber+"#"+(string)buy_sl;
            ord_status = OrderSend(cur_symbol,OP_BUYLIMIT,lot_size, EntryPrice, slip, OriginalSL,OriginalTP,cmt, MagicNumber, 0, Lime);
            if(ord_status < 0)
              {
               Print(cur_symbol+" Error ZIZLB3 : ", GetLastError());
               return;
              }
           }

         allow_zizlimit_trade = false;
         isBreakeven=false;

         if(EnableScreenshot)
           {
            TakeScreenshot("BUY");
           }
        }

      if(sziz_check)
        {
         cur_Signal = "SELL";
         EntryTime = iTime(cur_symbol,0,0);

         EntryPrice = ZLow;
         whichPattern = "ZIZ1"+(string)ziz_signal;
         sell_sl = NormalizeDouble(ZDiff + ZDiff * (ZoneBufferTPSL/100),cur_digits);
         tp_sl_range = NormalizeDouble(sell_sl * RewardPercent,cur_digits);
         lot_size = GetPositionSizingLot(sell_sl);
         if(CheckMoneyForTrade(cur_symbol,lot_size,OP_SELL) == false)
            return;
         OriginalTP = (EnableTargetInd && (stargetind!=EMPTY_VALUE && stargetind!=0)) ? stargetind : (EnableAsianTarget) ? sasiantarget : EntryPrice - tp_sl_range;
         OriginalSL = EntryPrice + sell_sl;
         cmt = EA_Name+"-"+whichPattern+"-"+(string)MagicNumber+"#"+(string)sell_sl;
         ord_status = OrderSend(cur_symbol,OP_SELLLIMIT,lot_size, EntryPrice, slip, OriginalSL,OriginalTP, cmt, MagicNumber, 0, Red);
         if(ord_status < 0)
           {
            Print(cur_symbol+" Error ZIZLS1 : ", GetLastError());
            return;
           }

         if(MaxArrowLimitOrders>=2)
           {
            EntryPrice = ZLow2;
            whichPattern = "ZIZ2"+(string)ziz_signal;
            sell_sl = NormalizeDouble(ZDiff2 + ZDiff2 * (ZoneBufferTPSL/100),cur_digits);
            tp_sl_range = NormalizeDouble(sell_sl * RewardPercent,cur_digits);
            lot_size = GetPositionSizingLot(sell_sl);
            if(CheckMoneyForTrade(cur_symbol,lot_size,OP_SELL) == false)
               return;
            OriginalTP = (EnableTargetInd && (stargetind!=EMPTY_VALUE && stargetind!=0)) ? stargetind : (EnableAsianTarget) ? sasiantarget : EntryPrice - tp_sl_range;
            OriginalSL = EntryPrice + sell_sl;
            cmt = EA_Name+"-"+whichPattern+"-"+(string)MagicNumber+"#"+(string)sell_sl;
            ord_status = OrderSend(cur_symbol,OP_SELLLIMIT,lot_size, EntryPrice, slip, OriginalSL,OriginalTP, cmt, MagicNumber, 0, Red);
            if(ord_status < 0)
              {
               Print(cur_symbol+" Error ZIZLS2 : ", GetLastError());
               return;
              }
           }
         if(MaxArrowLimitOrders==3)
           {
            EntryPrice = ZLow3;
            whichPattern = "ZIZ3"+(string)ziz_signal;
            sell_sl = NormalizeDouble(ZDiff3 + ZDiff3 * (ZoneBufferTPSL/100),cur_digits);
            tp_sl_range = NormalizeDouble(sell_sl * RewardPercent,cur_digits);
            lot_size = GetPositionSizingLot(sell_sl);
            if(CheckMoneyForTrade(cur_symbol,lot_size,OP_SELL) == false)
               return;
            OriginalTP = (EnableTargetInd && (stargetind!=EMPTY_VALUE && stargetind!=0)) ? stargetind : (EnableAsianTarget) ? sasiantarget : EntryPrice - tp_sl_range;
            OriginalSL = EntryPrice + sell_sl;
            cmt = EA_Name+"-"+whichPattern+"-"+(string)MagicNumber+"#"+(string)sell_sl;
            ord_status = OrderSend(cur_symbol,OP_SELLLIMIT,lot_size, EntryPrice, slip, OriginalSL,OriginalTP, cmt, MagicNumber, 0, Red);
            if(ord_status < 0)
              {
               Print(cur_symbol+" Error ZIZLS3 : ", GetLastError());
               return;
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
void CheckOrderExpiry()
  {
   int oc=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      bool os=OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderMagicNumber()==MagicNumber)
        {
         if(OrderType()!=OP_BUY && OrderType()!=OP_SELL)
           {
            datetime expiry = (OrderExpiryTime!=0) ? (OrderOpenTime() + OrderExpiryTime*60) : (datetime)"2050.12.31 00:00";
            if(TimeCurrent()>expiry)
              {
               oc=OrderDelete(OrderTicket(), clrYellow);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
void SSM_StopOrder()
  {
   int bStopCount = GetTotalOrders("BuyStop");
   int sStopCount = GetTotalOrders("SellStop");

   RefreshRates();
   int ztshift = iBarShift(cur_symbol,0,ssm_zonetime);
   double ZHigh = iHigh(cur_symbol,0,ztshift);
   double ZLow = iLow(cur_symbol,0,ztshift);
   double ZDiff = NormalizeDouble(ZHigh - ZLow,cur_digits);

   if(bStopCount == 0)
     {
      if(ssm_strength == 4 && ssm_touchzone == 1)
        {
         EntryPrice = NormalizeDouble(ZHigh + ZDiff * (ZoneBufferTPSL/100),cur_digits);
         cur_Signal = "BUY";
         whichPattern = "SSM_ZT"+(string)ssm_strength;
         EntryTime = iTime(cur_symbol,0,0);

         buy_sl = NormalizeDouble(ZDiff + ZDiff * (ZoneBufferTPSL/100),cur_digits);
         tp_sl_range = NormalizeDouble(buy_sl * RewardPercent,cur_digits);

         lot_size = GetPositionSizingLot(buy_sl);

         if(CheckMoneyForTrade(cur_symbol,lot_size,OP_BUY) == false)
            return;
         Print("BUY SSM ZT");
         OriginalTP = (EnableTargetInd && (btargetind!=EMPTY_VALUE && btargetind!=0)) ? btargetind : (EnableAsianTarget) ? basiantarget : EntryPrice + tp_sl_range;
         OriginalSL = EntryPrice - buy_sl;
         string cmt = EA_Name+"-"+whichPattern+"-"+(string)MagicNumber+"#"+(string)buy_sl;
         int ord_status = OrderSend(cur_symbol,OP_BUYSTOP,lot_size, EntryPrice, slip, OriginalSL,OriginalTP,cmt, MagicNumber, 0, Lime);
         if(ord_status < 0)
           {
            Print(cur_symbol+" Error SSMBS1 : ", GetLastError()," lot_size : ",lot_size," EntryPrice : ",EntryPrice," OriginalSL : ",OriginalSL," OriginalTP : ",OriginalTP," cmt : ",cmt);
            return;
           }

         if(EnableScreenshot)
           {
            TakeScreenshot("BUY");
           }

        }
     }

   if(sStopCount == 0)
     {
      if(ssm_strength == -4 && ssm_touchzone == -1)
        {
         EntryPrice = NormalizeDouble(ZLow - ZDiff * (ZoneBufferTPSL/100),cur_digits);
         cur_Signal = "SELL";
         whichPattern = "SSM_ZT"+(string)ssm_strength;
         EntryTime = iTime(cur_symbol,0,0);

         sell_sl = NormalizeDouble(ZDiff - ZDiff * (ZoneBufferTPSL/100),cur_digits);
         tp_sl_range = NormalizeDouble(sell_sl * RewardPercent,cur_digits);

         lot_size = GetPositionSizingLot(sell_sl);

         if(CheckMoneyForTrade(cur_symbol,lot_size,OP_SELL) == false)
            return;
         Print("SELL SSM ZT");
         OriginalTP = (EnableTargetInd && (stargetind!=EMPTY_VALUE && stargetind!=0)) ? stargetind : (EnableAsianTarget) ? sasiantarget : EntryPrice - tp_sl_range;
         OriginalSL = EntryPrice - sell_sl;
         string cmt = EA_Name+"-"+whichPattern+"-"+(string)MagicNumber+"#"+(string)sell_sl;
         int ord_status = OrderSend(cur_symbol,OP_SELLSTOP,lot_size, EntryPrice, slip, OriginalSL,OriginalTP,cmt, MagicNumber, 0, Red);
         if(ord_status < 0)
           {
            Print(cur_symbol+" Error SSMSS1 : ", GetLastError()," lot_size : ",lot_size," EntryPrice : ",EntryPrice," OriginalSL : ",OriginalSL," OriginalTP : ",OriginalTP," cmt : ",cmt);
            return;
           }

         if(EnableScreenshot)
           {
            TakeScreenshot("SELL");
           }

        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetSymbolFromFileScanner()
  {
   string main_folder1 = RootFolder+"/";
   string main_folder = RootFolder+"/"+ IntegerToString(FolderName)+"/";
   string InpFilter = main_folder+"*",file_name;
   int    i=1;
//--- receive search handle in local folder's root
   long search_handle=FileFindFirst(InpFilter,file_name,FILE_COMMON);
//--- check if FileFindFirst() function executed successfully
   if(search_handle!=INVALID_HANDLE)
     {
      //--- check if the passed strings are file or directory names in the loop
      do
        {
         ResetLastError();
         //--- if this is a file, the function will return true, if it is a directory, the function will generate error ERR_FILE_IS_DIRECTORY
         FileIsExist(file_name);
         //PrintFormat("%d : %s name = %s",i,GetLastError()==ERR_FILE_IS_DIRECTORY ? "Directory" : "File",file_name);

         if(StringFind(file_name, "ROBO") > 0)                          //If a filename contains ROBO
           {

            string k1sep=",";                                            // A separator as a character
            ushort k1u_sep=StringGetCharacter(k1sep,0);                  // The code of the separator character
            string fdata[];

            string filenameWithPath = main_folder + file_name;
            int file_handle=FileOpen(filenameWithPath,FILE_READ|FILE_TXT|FILE_COMMON);
            int file_size=(int)FileSize(file_handle);

            Comment("Scanning File : "+file_name+", LocalTime : "+(string)TimeCurrent());
            //Print("Scanning File : "+file_name+", LocalTime : "+(string)TimeCurrent());

            if(file_size>0)
              {
               int str_size=FileReadInteger(file_handle,INT_VALUE);
               string str=FileReadString(file_handle,str_size);
               //StringToCharArray(StringSubstr(str,0,StringLen(str)-1),src);
               int k=StringSplit(str,k1u_sep,fdata);

               cur_symbol = fdata[0];
               cur_sigType = fdata[1];
               cur_sigOPType = (cur_sigType=="BUY") ? OP_BUY : (cur_sigType=="SELL") ? OP_SELL : -1;
               cur_entryTime = (datetime)fdata[2];
               cur_exitTime = (datetime)fdata[3];
               cur_symbol_index = GetSymbolIndex(cur_symbol);
               cur_comment=fdata[6];



               //int bv=0, sv=0, bo=0; bool found=GetSwingAdrData(cur_symbol, bv, sv, bo);
               //if (!CheckSwingAdrCurrency(cur_sigOPType))
               //{
               //  Print(cur_sigType+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
               //}

               string entryTime[];
               ushort space_sep=StringGetCharacter(" ",0);
               int j=StringSplit(fdata[2],space_sep,entryTime);

               //This is used for SwingStop Start Time
               cur_SS_Startime = entryTime[1];

               //checking for exit time, if time exceeds then move the file to completed folder
               if(Time[0]>cur_exitTime)
                 {
                  string src_path = filenameWithPath;
                  string dst_path = main_folder1+"Completed/"+file_name;

                  FileClose(file_handle);
                  if(FileMove(src_path,FILE_COMMON,dst_path,FILE_COMMON))
                     PrintFormat("File moved : %s",file_name);
                  else
                     PrintFormat("FileMove Error Code = %d,%s,%s",GetLastError(),src_path,dst_path);
                 }
               else
                 {
                  cur_digits=(int)SymbolInfoInteger(cur_symbol, SYMBOL_DIGITS);
                  cur_point=SymbolInfoDouble(cur_symbol, SYMBOL_POINT);
                  ecdir = 0;
                  if(EnableEntryCandle)
                    {
                     if(ReadEntryCandleFromFile)
                       {
                        ecdir=ReadEntryCandleSignalFromFile();
                       }
                     else
                       {
                        ecdir=getEntryCandle(0,(cur_sigOPType==OP_BUY?SHOW_BUY:SHOW_SELL),2,iPlus);
                        if(EnableTrendDirectionFilter)
                          {
                           if(ecdir==1)
                             {
                              int buy=(int)getEntryCandle(0,(cur_sigOPType==OP_BUY?SHOW_BUY:SHOW_SELL),33,iPlus);
                              if(buy==0)
                                 ecdir=0;
                             }
                           if(ecdir==-1)
                             {
                              int sell=(int)getEntryCandle(0,(cur_sigOPType==OP_BUY?SHOW_BUY:SHOW_SELL),34,iPlus);
                              if(sell==0)
                                 ecdir=0;
                             }
                          }
                       }
                    }
                  ecdir2 = (EnableECMethod2) ? getEntryCandleM2(0,(cur_sigOPType==OP_BUY?SHOW_BUY:SHOW_SELL),2,iPlus) : 0;



                  if(cur_symbol!="")
                    {

                     Begin();
                    }
                 }
              }
            FileClose(file_handle);
           }
         i++;
        }
      while(FileFindNext(search_handle,file_name) && !IsStopped());
      //--- close search handle
      FileFindClose(search_handle);
     }
   return "";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetSymbolFromFileScannerReceiver()
  {
   string main_folder1 = RootFolder+"/";
   string main_folder = RootFolder+"/"+ IntegerToString(FolderName)+"/";
   string InpFilter = main_folder+"*",file_name;
   int    i=1;
//--- receive search handle in local folder's root
   long search_handle=FileFindFirst(InpFilter,file_name,FILE_COMMON);
//--- check if FileFindFirst() function executed successfully
   if(search_handle!=INVALID_HANDLE)
     {
      //--- check if the passed strings are file or directory names in the loop
      do
        {
         ResetLastError();
         //--- if this is a file, the function will return true, if it is a directory, the function will generate error ERR_FILE_IS_DIRECTORY
         FileIsExist(file_name);
         //PrintFormat("%d : %s name = %s",i,GetLastError()==ERR_FILE_IS_DIRECTORY ? "Directory" : "File",file_name);

         if(StringFind(file_name, "ROBO") > 0)                          //If a filename contains ROBO
           {

            string k1sep=",";                                            // A separator as a character
            ushort k1u_sep=StringGetCharacter(k1sep,0);                  // The code of the separator character
            string fdata[];

            string filenameWithPath = main_folder + file_name;
            int file_handle=FileOpen(filenameWithPath,FILE_READ|FILE_TXT|FILE_COMMON);
            int file_size=(int)FileSize(file_handle);

            Comment("Scanning File : "+file_name+", LocalTime : "+(string)TimeCurrent());
            //Print("Scanning File : "+file_name+", LocalTime : "+(string)TimeCurrent());

            if(file_size>0)
              {
               int str_size=FileReadInteger(file_handle,INT_VALUE);
               string str=FileReadString(file_handle,str_size);
               //StringToCharArray(StringSubstr(str,0,StringLen(str)-1),src);
               int k=StringSplit(str,k1u_sep,fdata);

               //G Print(str);
               cur_symbol = fdata[0];
               cur_sigType = fdata[1];
               cur_sigOPType = (cur_sigType=="BUY") ? OP_BUY : (cur_sigType=="SELL") ? OP_SELL : -1;
               cur_entryTime = (datetime)fdata[2];
               cur_exitTime = (datetime)fdata[3];
               cur_symbol_index = GetSymbolIndex(cur_symbol);
               cur_magic_number=fdata[5];
               cur_comment=fdata[6];



               RiskPercent =RiskPercent1;
               StopLossCRC=StopLossCRC1;
               RewardPercent=RewardPercent1;
               MinSLTimeInMinutes=MinSLTimeInMinutes1;
               MinTimeBetweenOrdersInMinutes=MinTimeBetweenOrdersInMinutes1;
               EAID=cur_comment;
               EA_Name=cur_comment;


               int size=ArraySize(CommentList);
               for(int i1=0; i1<size; i1++)
                 {
                  double CheckComment= (string)CommentList[i1].cmnt==cur_comment?true: false;
                  if(CheckComment)
                    {
                     RiskPercent=CommentList[i1].pr;
                     StopLossCRC=(int)CommentList[i1].StopLossCRC2;
                     RewardPercent=(double)CommentList[i1].RewardPercent2;
                     MinSLTimeInMinutes=(int)CommentList[i1].StopLossStackingTime2;
                     MinTimeBetweenOrdersInMinutes=(int)CommentList[i1].LimitOrderStackingTime2;
                     EAID=CommentList[i1].CopyOrderComment2;
                     EA_Name=CommentList[i1].CopyOrderComment2;
                     break;
                    }
                 }


               // Print(cur_magic_number+" " +cur_comment);
               //int bv=0, sv=0, bo=0; bool found=GetSwingAdrData(cur_symbol, bv, sv, bo);
               //if (!CheckSwingAdrCurrency(cur_sigOPType))
               //{
               //  Print(cur_sigType+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
               //}

               string entryTime[];
               ushort space_sep=StringGetCharacter(" ",0);
               int j=StringSplit(fdata[2],space_sep,entryTime);

               //This is used for SwingStop Start Time
               cur_SS_Startime = entryTime[1];

               //checking for exit time, if time exceeds then move the file to completed folder
               if(Time[0]>cur_exitTime)
                 {
                  string src_path = filenameWithPath;
                  string dst_path = main_folder1+"Completed/"+file_name;

                  FileClose(file_handle);
                  if(FileMove(src_path,FILE_COMMON,dst_path,FILE_COMMON))
                     PrintFormat("File moved : %s",file_name);
                  else
                     PrintFormat("FileMove Error Code = %d,%s,%s",GetLastError(),src_path,dst_path);
                 }
               else
                 {
                  cur_digits=(int)SymbolInfoInteger(cur_symbol, SYMBOL_DIGITS);
                  cur_point=SymbolInfoDouble(cur_symbol, SYMBOL_POINT);

                  ecdir =(cur_sigType=="BUY") ? 1 : (cur_sigType=="SELL") ? -1 : 0;
                  /*
                   if(EnableEntryCandle)
                     {
                      if(ReadEntryCandleFromFile)
                        {
                         ecdir=ReadEntryCandleSignalFromFile();
                        }
                      else
                        {
                         ecdir=getEntryCandle(0,(cur_sigOPType==OP_BUY?SHOW_BUY:SHOW_SELL),2,iPlus);
                         if(EnableTrendDirectionFilter)
                           {
                            if(ecdir==1)
                              {
                               int buy=(int)getEntryCandle(0,(cur_sigOPType==OP_BUY?SHOW_BUY:SHOW_SELL),33,iPlus);
                               if(buy==0)
                                  ecdir=0;
                              }
                            if(ecdir==-1)
                              {
                               int sell=(int)getEntryCandle(0,(cur_sigOPType==OP_BUY?SHOW_BUY:SHOW_SELL),34,iPlus);
                               if(sell==0)
                                  ecdir=0;
                              }
                           }
                        }
                     }
                     */
                  ecdir2 = (EnableECMethod2) ? getEntryCandleM2(0,(cur_sigOPType==OP_BUY?SHOW_BUY:SHOW_SELL),2,iPlus) : 0;

                  if(cur_symbol!="")
                    {
                     Begin();
                    }

                 }
              }
            FileClose(file_handle);
           }
         i++;
        }
      while(FileFindNext(search_handle,file_name) && !IsStopped());
      //--- close search handle
      FileFindClose(search_handle);
     }
   return "";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PlaceCandleLimit(int otype,string wPattern,int shiftPlus)
  {
   if(!ConfLocked)   //if no ConfLocked then no need to check further
      return;

   int order_count = GetOrderCount(otype);
   bool lo_check = LastOrderCheck(otype);
   bool co_check = CurrentOrderCheck(wPattern,otype);
   bool bc_check = BigCandleCheck();
//if any running order, then no limit order should be placed
   bool check_running = (lo_check && co_check) ? true : false;

//(Time[0]!=last_limit_triggered) &&
   int total_limit_orders = 0;
   if(!AllowOppositeSignals)
      total_limit_orders=(GetTotalOrders("BuyLimit",OP_BUYLIMIT)+GetTotalOrders("SellLimit",OP_SELLLIMIT));
   else
      total_limit_orders=(cur_sigOPType==OP_BUY?GetTotalOrders("BuyLimit",OP_BUYLIMIT):GetTotalOrders("SellLimit",OP_SELLLIMIT));
   allow_candlelimit_trade = (checkNews && check_running && TimeCheck && lastCandlePair[cur_symbol_index]!=Time[0] && total_limit_orders<MaxLimitOrders) ? true : false;
//Print("allow_candlelimit_trade="+allow_candlelimit_trade+" checkNews="+checkNews+" check_running="+check_running+" TimeCheck="+TimeCheck+" wPattern="+wPattern+" last_limit_triggered="+last_limit_triggered+" GetTotalOrders(BuyLimit,OP_BUYLIMIT)="+GetTotalOrders("BuyLimit",OP_BUYLIMIT)+" GetTotalOrders(SellLimit,OP_SELLLIMIT)="+GetTotalOrders("SellLimit",OP_SELLLIMIT)+" MaxLimitOrders="+MaxLimitOrders+" shiftPlus="+shiftPlus+" T="+Time[0]);

   RefreshRates();
   double spread = NormalizeDouble((MarketInfo(cur_symbol,MODE_ASK) - MarketInfo(cur_symbol,MODE_BID)),cur_digits);
   double spreadValue = (spread>AvgSpreadValue*10*MarketInfo(cur_symbol,MODE_POINT)) ? (spread*Spread_MultiplierAvg) : (spread*Spread_Multiplier);
   double multiplier = (spread>AvgSpreadValue*10*MarketInfo(cur_symbol,MODE_POINT)) ? (Spread_MultiplierAvg) : (Spread_Multiplier);

   double CHigh = iHigh(cur_symbol,0,shiftPlus);
   double CLow = iLow(cur_symbol,0,shiftPlus);
   double CDiff = NormalizeDouble(CHigh - CLow,cur_digits);
   double CMid = NormalizeDouble((CHigh+CLow)/2,cur_digits);
   double point=MarketInfo(cur_symbol,MODE_POINT);

   double crcZMax = getCRCMax(0,2,shiftPlus);
   double crcZNormal = getCRC(0,2,shiftPlus);

   bool check_spreadNormal = (NormalizeDouble(spread, cur_digits)<=NormalizeDouble(AvgSpreadValue*10*cur_point, cur_digits) && spread<MaxSpreadValue*10*cur_point);
   bool check_spreadMax = (NormalizeDouble(spread, cur_digits)>NormalizeDouble(AvgSpreadValue*10*cur_point, cur_digits) && spread<=MaxSpreadValue*10*cur_point);

   if(!check_spreadMax && !check_spreadNormal)
     {
      Print((otype==OP_BUY?"Buy":"Sell")+" entry on "+cur_symbol+" is skipped on max spread check (current="+DoubleToString(spread/cur_point, 0)+", avg="+DoubleToString(AvgSpreadValue*10, 1)+", max="+DoubleToString(MaxSpreadValue*10, 1)+")");
      lastCandlePair[cur_symbol_index]=Time[0];
      return;
     }

   if(DoesSignalCatched(cur_symbol, otype, Time[0])!=-1)
     {
      Print((otype==OP_BUY?"Buy":"Sell")+" entry on "+cur_symbol+" is skipped on trade already placed on same candle");
      lastCandlePair[cur_symbol_index]=Time[0];
      return;
     }

   if(EnableCRC && EnableCRCStage)
     {
      if(crcZMax==EMPTY_VALUE)
         crcZMax=0;
      if(crcZNormal==EMPTY_VALUE)
         crcZNormal=0;
      if(crcZNormal==1 && crcZMax==1)
         CMid=(cur_sigOPType==OP_BUY?NormalizeDouble(CLow+(CHigh-CLow)*CRCStage_Zone1/100, cur_digits):NormalizeDouble(CHigh-(CHigh-CLow)*CRCStage_Zone1/100, cur_digits));
      if(crcZNormal==0 && crcZMax==1)
         CMid=(cur_sigOPType==OP_BUY?NormalizeDouble(CLow+(CHigh-CLow)*CRCStage_Zone2/100, cur_digits):NormalizeDouble(CHigh-(CHigh-CLow)*CRCStage_Zone2/100, cur_digits));
     }

   if(!check_spreadNormal)
     {
      double newentry=(cur_sigOPType==OP_BUY?NormalizeDouble(CLow+(CHigh-CLow)*CRCStage_Zone2/100, cur_digits):NormalizeDouble(CHigh-(CHigh-CLow)*CRCStage_Zone2/100, cur_digits));
      if(cur_sigOPType==OP_BUY && CMid>newentry)
         CMid=newentry;
      if(cur_sigOPType==OP_SELL && CMid<newentry)
         CMid=newentry;
     }

   if(allow_candlelimit_trade)
     {
      bool bdirection = (cur_sigOPType==OP_BUY) ? true : false;
      bool sdirection = (cur_sigOPType==OP_SELL) ? true : false;
      whichPattern = wPattern;

      string weight="";
      int currentw=0, acceptw=0;
      bool shc_check = EnableStopHuntCheckForEntry?Check_SHC(otype,wPattern,shiftPlus,shiftPlus,currentw,acceptw,weight):true;
      if(EnableStopHuntCheckForEntry && lastCandlePair[cur_symbol_index]!=Time[0])
        {
         Print((!shc_check?"trade is skipped for SHC on ":"")+cur_symbol+": current weightage="+IntegerToString(currentw)+", acceptance_weightage="+IntegerToString(acceptw)+", detail: "+weight);
         if(!shc_check)
           {
            lastCandlePair[cur_symbol_index]=Time[0];
            return;
           }
        }

      if(!bc_check)
        {
         Print((otype==OP_BUY?"Buy":"Sell")+" entry on "+cur_symbol+" is skipped on Avoid News Candle");
         lastCandlePair[cur_symbol_index]=Time[0];
         return;
        }

      if(order_count>=MaxRunningOrders && MaxRunningOrders!=0)
        {
         Print("entry on "+cur_symbol+" is skipped on Maximum Running Orders");
         lastCandlePair[cur_symbol_index]=Time[0];
         return;
        }

      if(EnableEquityExit && EquityStopTrading!=0)
        {
         double fundedBalance=FundedAccountBalance;
         if(fundedBalance>AccountBalance())
            fundedBalance=AccountBalance();
         double EqTgt = ((EnableFundedAccount?fundedBalance:startBalance) * (EquityExit/100)) + startBalance;
         if(EqTgt-AccountEquity()<=EquityStopTrading*EqTgt/100)
           {
            Print("entry on "+cur_symbol+" is skipped on Stop New Trade when Equity is less than x% to target (Equity="+DoubleToString(AccountEquity(), 2)+", Target="+DoubleToString(EqTgt, 2)+")");
            lastCandlePair[cur_symbol_index]=Time[0];
            return;
           }
        }

      if(EnableCRC && EnableCRCStage)
        {
         if(crcZNormal==0 && crcZMax==0)
           {
            Print((otype==OP_BUY?"Buy":"Sell")+" entry on "+cur_symbol+" is skipped on crc check");
            lastCandlePair[cur_symbol_index]=Time[0];
            return;
           }
        }

      bool adrwr_check = Check_ADRWR(otype,wPattern,shiftPlus);
      if(!adrwr_check && lastCandlePair[cur_symbol_index]!=Time[0])
        {
         Print("entry on "+cur_symbol+" is skipped on adr check");
         lastCandlePair[cur_symbol_index]=Time[0];
         return;
        }

      if(bdirection)
        {
         EntryPrice = CMid;
         if(ApplySpreadToLimitEntry && SpreadBuyPercent!=0)
           {
            Print(cur_symbol+": calculated limit price="+DoubleToString(EntryPrice, cur_digits)+", avg spread="+DoubleToString(AvgSpreadValue, 1)+", adjusted limit price="+DoubleToString(EntryPrice+AvgSpreadValue*10*cur_point*SpreadBuyPercent/100, cur_digits));
            EntryPrice=NormalizeDouble(EntryPrice+AvgSpreadValue*10*cur_point*SpreadBuyPercent/100, cur_digits);
           }
         bool marketEntry=false;
         if(PendingToMarketAllowed)
           {
            if(NormalizeDouble(EntryPrice, cur_digits)>=NormalizeDouble(SymbolInfoDouble(cur_symbol, SYMBOL_BID), cur_digits))
              {
               marketEntry=true;
               Print("limit order on "+cur_symbol+" is changed to market entry on spread movement (limit price"+DoubleToString(EntryPrice, cur_digits)+", market price="+DoubleToString(SymbolInfoDouble(cur_symbol, SYMBOL_BID), cur_digits)+")");
               EntryPrice=SymbolInfoDouble(cur_symbol, SYMBOL_ASK);
              }
           }
         cur_Signal = "BUY";
         if(!CheckEntryStackingOption(cur_symbol, otype, EntryPrice))
           {
            Print(cur_Signal+" entry on "+cur_symbol+" is skipped on CheckEntryStacking");
            lastCandlePair[cur_symbol_index]=Time[0];
            return;
           }
         if(!CheckSLStackingOption(cur_symbol, otype, EntryPrice))
           {
            Print(cur_Signal+" entry on "+cur_symbol+" is skipped on CheckStoplossStacking");
            lastCandlePair[cur_symbol_index]=Time[0];
            return;
           }
         if(Enable_EA_as_Copytrading_Receiver==false)
           {
            if(!CheckSwingAdrFilter(otype))
              {
               Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
               lastCandlePair[cur_symbol_index]=Time[0];
               return;
              }
            if(!CheckSwingAdrCurrency(otype))
              {
               Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
               lastCandlePair[cur_symbol_index]=Time[0];
               return;
              }
           }

         EntryTime = iTime(cur_symbol,0,0);

         double crc1 = ReadCRC(0, CRC_NumOfDays, CRC_Multiplier, 2, shiftPlus);
         double slPercent=0;
         if(crc1==0)
            slPercent=CandleSLPercentStage2;
         else
            slPercent=CandleSLPercentStage1;
         double sl = EntryPrice - NormalizeDouble(CDiff * slPercent,cur_digits) - NormalizeDouble(spreadValue,cur_digits);
         //Print("buy sl: ", crc1, ", ", slPercent, ", ", CDiff, ", ", spreadValue, ", ", sl);
         //Print(crcZNormal, ", ", crcZMax, ", ", check_spreadNormal, ", ", crcZNormal==1 && crcZMax==1 && check_spreadNormal);
         Print("Candle Range:", DoubleToString(CDiff/point, 0), ", Limit%:", ((crcZNormal==1 && crcZMax==1 && check_spreadNormal)?CRCStage_Zone1:CRCStage_Zone2), ", CRC:", (crcZNormal==0?CRC_MultiplierMax:CRC_Multiplier), ", SL%:", DoubleToString(slPercent*100, 2), ", Spread Multiplier:", DoubleToString(multiplier, 2), ", Current spread:", DoubleToString(spread/point, 0), ", Entry Price:", DoubleToString(EntryPrice, cur_digits), ", Entry-SL:", DoubleToString((EntryPrice-CDiff*slPercent), cur_digits), ", Spread Dif:", DoubleToString(spreadValue/point, 0)+", SL Price:", DoubleToString(sl, cur_digits)+", CRC Value:", DoubleToString(ReadCRC(0, CRC_NumOfDays, StopLossCRC, 6, 1)/cur_point, 0));

         buy_sl = NormalizeDouble(EntryPrice - sl,cur_digits);
         if(CheckSLValueByCRC)
           {
            double crcv=ReadCRC(0, CRC_NumOfDays, StopLossCRC, 6, 1);
            if(buy_sl>crcv)
              {
               if(ActionOnSLCRC==sl_crc_no_trade)
                 {
                  Print("buy trade on "+cur_symbol+" is skipped on Check Stoploss Maximum by CRC, CRC Number:"+IntegerToString(StopLossCRC)+", CRC Value:"+DoubleToString(crcv/cur_point, 0));
                  lastCandlePair[cur_symbol_index]=Time[0];
                  return;
                 }
               else
                  if(ActionOnSLCRC==sl_crc_use_crc)
                    {
                     Print("buy sl on "+cur_symbol+" is above Stoploss Maximum by CRC, update sl to CRC, CRC Number:"+IntegerToString(StopLossCRC)+", CRC Value:"+DoubleToString(crcv/cur_point, 0));
                     buy_sl=NormalizeDouble(crcv, cur_digits);
                     sl=EntryPrice-buy_sl;
                    }
              }
           }
         if(EnableDataIndicatorCalculation)
           {
            double oi=(int)iCustom(NULL, PERIOD_H1, "Kishore Fredrick\\Data Indicator.ex4", GetIndex1(cur_symbol), 0);
            if(!(oi>=MinimumValueBuy && oi<=MaximumValueBuy))
              {
               Print("buy trade on "+cur_symbol+" is skipped on EnableDataIndicatorCalculation, OI:"+DoubleToString(oi, 1)+", MinimumValueBuy:"+DoubleToString(MinimumValueBuy, 1)+", MaximumValueBuy:"+DoubleToString(MaximumValueBuy, 1));
               lastCandlePair[cur_symbol_index]=Time[0];
               return;
              }
            else
               if(OverExtendedFilter && (oi>OverExtendedLevel || oi<-OverExtendedLevel))
                 {
                  Print("buy trade on "+cur_symbol+" is skipped on OverExtendedFilter, OI:"+DoubleToString(oi, 1)+", OverExtendedLevel:"+DoubleToString(OverExtendedLevel, 1));
                  lastCandlePair[cur_symbol_index]=Time[0];
                  return;
                 }
               else
                 {
                  Print("buy trade on "+cur_symbol+", OI:"+DoubleToString(oi, 1)+", MinimumValueBuy:"+DoubleToString(MinimumValueBuy, 1)+", MaximumValueBuy:"+DoubleToString(MaximumValueBuy, 1));
                 }
           }

         lot_size = GetPositionSizingLot(buy_sl);
         //lot_size = CheckVolumeValue(lot_size);

         if(CheckMoneyForTrade(cur_symbol,lot_size,OP_BUY) == false)
           {
            lastCandlePair[cur_symbol_index]=Time[0];
            return;
           }

         double pv=SymbolInfoDouble(cur_symbol, SYMBOL_TRADE_TICK_VALUE)/SymbolInfoDouble(cur_symbol, SYMBOL_TRADE_TICK_SIZE);
         double comValue=CommissionPerLot*lot_size;
         double commPoints=MathCeil(comValue/(pv*lot_size)/cur_point)*cur_point;
         tp_sl_range = NormalizeDouble(buy_sl * RewardPercent+commPoints,cur_digits);

         OriginalTP = SetTarget(OP_BUY,EntryPrice,tp_sl_range,0);
         OriginalSL = NormalizeDouble(sl,cur_digits);
         string cmt = EA_Name+"-"+whichPattern+"-"+(string)MagicNumber+"#"+DoubleToStr(buy_sl,cur_digits);

         if(!marketEntry && MarketInfo(cur_symbol,MODE_BID)>EntryPrice)
           {
            Print("symbol: "+cur_symbol+", spread="+DoubleToString(spread/cur_point, 0)+", avg="+DoubleToString(AvgSpreadValue*10, 1)+", max="+DoubleToString(MaxSpreadValue*10, 1)+")");
            int ord_status = OrderSend(cur_symbol,OP_BUYLIMIT,lot_size, EntryPrice, slip, OriginalSL,OriginalTP,cmt, MagicNumber, 0, Lime);
            if(ord_status < 0)
              {
               Print(cur_symbol+" Error CLB : ", GetLastError()," lot_size : ",lot_size," EntryPrice : ",EntryPrice," OriginalSL : ",OriginalSL," OriginalTP : ",OriginalTP," cmt : ",cmt);
              }
            else
              {
               lastCandlePair[cur_symbol_index]=Time[0];
               GlobalVariableSet(gbl+IntegerToString(ord_status)+".PendingTime", Time[0]);
               GlobalVariableSet(gbl+IntegerToString(ord_status)+".ISL", buy_sl);
               if(CreateTextFiles)
                  CreateTextFile(cur_symbol, OP_BUY,EAID);
              }

            allow_candlelimit_trade = false;
            candle_limit_triggered = Time[0];
            isBreakeven=false;

            if(EnableScreenshot)
              {
               TakeScreenshot("BUY");
              }
           }
         else
            if(marketEntry)
              {
               Print("symbol: "+cur_symbol+", spread="+DoubleToString(spread/cur_point, 0)+", avg="+DoubleToString(AvgSpreadValue*10, 1)+", max="+DoubleToString(MaxSpreadValue*10, 1)+")");
               int ord_status = OrderSend(cur_symbol,OP_BUY,lot_size, EntryPrice, slip, OriginalSL,OriginalTP,cmt, MagicNumber, 0, Lime);
               if(ord_status < 0)
                 {
                  Print(cur_symbol+" Error CLB : ", GetLastError()," lot_size : ",lot_size," EntryPrice : ",EntryPrice," OriginalSL : ",OriginalSL," OriginalTP : ",OriginalTP," cmt : ",cmt);
                 }
               else
                 {
                  lastCandlePair[cur_symbol_index]=Time[0];
                  GlobalVariableSet(gbl+IntegerToString(ord_status)+".PendingTime", Time[0]);
                  GlobalVariableSet(gbl+IntegerToString(ord_status)+".ISL", buy_sl);
                  if(CreateTextFiles)
                     CreateTextFile(cur_symbol, OP_BUY,EAID);
                 }

               allow_candlelimit_trade = false;
               candle_limit_triggered = Time[0];
               isBreakeven=false;

               if(EnableScreenshot)
                 {
                  TakeScreenshot("BUY");
                 }
              }
            else
              {
               Print(cur_symbol+" CLB Limit order not placed due to below price Bid:",MarketInfo(cur_symbol,MODE_BID)," EntryPrice:",EntryPrice);
              }
        }
      if(sdirection)
        {
         EntryPrice = CMid;
         if(ApplySpreadToLimitEntry && SpreadSellPercent!=0)
           {
            Print(cur_symbol+": calculated limit price="+DoubleToString(EntryPrice, cur_digits)+", avg spread="+DoubleToString(AvgSpreadValue, 1)+", adjusted limit price="+DoubleToString(EntryPrice-AvgSpreadValue*10*cur_point*SpreadSellPercent/100, cur_digits));
            EntryPrice=NormalizeDouble(EntryPrice-AvgSpreadValue*10*cur_point*SpreadSellPercent/100, cur_digits);
           }
         bool marketEntry=false;
         if(PendingToMarketAllowed)
           {
            if(NormalizeDouble(EntryPrice, cur_digits)<=NormalizeDouble(SymbolInfoDouble(cur_symbol, SYMBOL_BID), cur_digits))
              {
               marketEntry=true;
               Print("limit order on "+cur_symbol+" is changed to market entry on spread movement (limit price"+DoubleToString(EntryPrice, cur_digits)+", market price="+DoubleToString(SymbolInfoDouble(cur_symbol, SYMBOL_BID), cur_digits)+")");
               EntryPrice=SymbolInfoDouble(cur_symbol, SYMBOL_BID);
              }
           }
         cur_Signal = "SELL";
         if(!CheckEntryStackingOption(cur_symbol, otype, EntryPrice))
           {
            Print(cur_Signal+" entry on "+cur_symbol+" is skipped on CheckEntryStacking");
            lastCandlePair[cur_symbol_index]=Time[0];
            return;
           }
         if(!CheckSLStackingOption(cur_symbol, otype, EntryPrice))
           {
            Print(cur_Signal+" entry on "+cur_symbol+" is skipped on CheckStoplossStacking");
            lastCandlePair[cur_symbol_index]=Time[0];
            return;
           }
         if(Enable_EA_as_Copytrading_Receiver==false)
           {
            if(!CheckSwingAdrFilter(otype))
              {
               Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
               lastCandlePair[cur_symbol_index]=Time[0];
               return;
              }
            if(!CheckSwingAdrCurrency(otype))
              {
               Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
               lastCandlePair[cur_symbol_index]=Time[0];
               return;
              }
           }
         EntryTime = iTime(cur_symbol,0,0);

         double crc1 = ReadCRC(0, CRC_NumOfDays, CRC_Multiplier, 2, shiftPlus);
         double slPercent=0;
         if(crc1==0)
            slPercent=CandleSLPercentStage2;
         else
            slPercent=CandleSLPercentStage1;
         double sl = EntryPrice + NormalizeDouble(CDiff * slPercent,cur_digits) + NormalizeDouble(spreadValue,cur_digits);
         //Print("sell sl: ", crc1, ", ", slPercent, ", ", CDiff, ", ", spreadValue, ", ", sl);
         Print("Candle Range:", DoubleToString(CDiff/point, 0), ", Limit%:", ((crcZNormal==1 && crcZMax==1 && check_spreadNormal)?CRCStage_Zone1:CRCStage_Zone2), ", CRC:", (crcZNormal==0?CRC_MultiplierMax:CRC_Multiplier), ", SL%:", DoubleToString(slPercent*100, 2), ", Spread Multiplier:", DoubleToString(multiplier, 2), ", Current spread:", DoubleToString(spread/point, 0), ", Entry Price:", DoubleToString(EntryPrice, cur_digits), ", Entry+SL:", DoubleToString((EntryPrice+CDiff*slPercent), cur_digits), ", Spread Dif:", DoubleToString(spreadValue/point, 0), ", Total Sl dif:", DoubleToString((CDiff*slPercent+spreadValue)/point, 0)+", SL Price:", DoubleToString(sl, cur_digits)+", CRC Value:", DoubleToString(ReadCRC(0, CRC_NumOfDays, StopLossCRC, 6, 1)/cur_point, 0));

         sell_sl = NormalizeDouble(sl - EntryPrice,cur_digits);
         if(CheckSLValueByCRC)
           {
            double crcv=ReadCRC(0, CRC_NumOfDays, StopLossCRC, 6, 1);
            if(sell_sl>crcv)
              {
               if(ActionOnSLCRC==sl_crc_no_trade)
                 {
                  Print("sell trade on "+cur_symbol+" is skipped on Check Stoploss Maximum by CRC, CRC Number:"+IntegerToString(StopLossCRC)+", CRC Value:"+DoubleToString(crcv/cur_point, 0));
                  lastCandlePair[cur_symbol_index]=Time[0];
                  return;
                 }
               else
                  if(ActionOnSLCRC==sl_crc_use_crc)
                    {
                     Print("sell sl on "+cur_symbol+" is above Stoploss Maximum by CRC, update sl to CRC, CRC Number:"+IntegerToString(StopLossCRC)+", CRC Value:"+DoubleToString(crcv/cur_point, 0));
                     sell_sl=NormalizeDouble(crcv, cur_digits);
                     sl=EntryPrice+sell_sl;
                    }
              }
           }
         if(EnableDataIndicatorCalculation)
           {
            double oi=(int)iCustom(NULL, PERIOD_H1, "Kishore Fredrick\\Data Indicator.ex4", GetIndex1(cur_symbol), 0);
            if(!(oi>=MinimumValueSell && oi<=MaximumValueSell))
              {
               Print("sell trade on "+cur_symbol+" is skipped on EnableDataIndicatorCalculation, OI:"+DoubleToString(oi, 1)+", MinimumValueSell:"+DoubleToString(MinimumValueSell, 1)+", MaximumValueSell:"+DoubleToString(MaximumValueSell, 1));
               lastCandlePair[cur_symbol_index]=Time[0];
               return;
              }
            else
               if(OverExtendedFilter && (oi>OverExtendedLevel || oi<-OverExtendedLevel))
                 {
                  Print("sell trade on "+cur_symbol+" is skipped on OverExtendedFilter, OI:"+DoubleToString(oi, 1)+", OverExtendedLevel:"+DoubleToString(OverExtendedLevel, 1));
                  lastCandlePair[cur_symbol_index]=Time[0];
                  return;
                 }
               else
                 {
                  Print("sell trade on "+cur_symbol+", OI:"+DoubleToString(oi, 1)+", MinimumValueSell:"+DoubleToString(MinimumValueSell, 1)+", MaximumValueSell:"+DoubleToString(MaximumValueSell, 1));
                 }
           }

         lot_size = GetPositionSizingLot(sell_sl);
         //lot_size = CheckVolumeValue(lot_size);

         if(CheckMoneyForTrade(cur_symbol,lot_size,OP_SELL) == false)
           {
            lastCandlePair[cur_symbol_index]=Time[0];
            return;
           }

         double pv=SymbolInfoDouble(cur_symbol, SYMBOL_TRADE_TICK_VALUE)/SymbolInfoDouble(cur_symbol, SYMBOL_TRADE_TICK_SIZE);
         double comValue=CommissionPerLot*lot_size;
         double commPoints=MathCeil(comValue/(pv*lot_size)/cur_point)*cur_point;
         tp_sl_range = NormalizeDouble(sell_sl * RewardPercent+commPoints,cur_digits);

         OriginalTP = SetTarget(OP_SELL,EntryPrice,tp_sl_range,0);
         OriginalSL = NormalizeDouble(sl,cur_digits);
         string cmt = EA_Name+"-"+whichPattern+"-"+(string)MagicNumber+"#"+DoubleToStr(sell_sl,cur_digits);

         if(!marketEntry && MarketInfo(cur_symbol,MODE_BID)<EntryPrice)
           {
            Print("symbol: "+cur_symbol+", spread="+DoubleToString(spread/cur_point, 0)+", avg="+DoubleToString(AvgSpreadValue*10, 1)+", max="+DoubleToString(MaxSpreadValue*10, 1)+")");
            int ord_status = OrderSend(cur_symbol,OP_SELLLIMIT,lot_size, EntryPrice, slip, OriginalSL,OriginalTP,cmt, MagicNumber, 0, Red);
            if(ord_status < 0)
              {
               Print(cur_symbol+" Error CLS : ", GetLastError()," lot_size : ",lot_size," EntryPrice : ",EntryPrice," OriginalSL : ",OriginalSL," OriginalTP : ",OriginalTP," cmt : ",cmt);
              }
            else
              {
               lastCandlePair[cur_symbol_index]=Time[0];
               GlobalVariableSet(gbl+IntegerToString(ord_status)+".PendingTime", Time[0]);
               GlobalVariableSet(gbl+IntegerToString(ord_status)+".ISL", sell_sl);
               if(CreateTextFiles)
                  CreateTextFile(cur_symbol, OP_SELL,EAID);
              }

            allow_candlelimit_trade = false;
            candle_limit_triggered = Time[0];
            isBreakeven=false;

            if(EnableScreenshot)
              {
               TakeScreenshot("SELL");
              }
           }
         else
            if(marketEntry)
              {
               Print("symbol: "+cur_symbol+", spread="+DoubleToString(spread/cur_point, 0)+", avg="+DoubleToString(AvgSpreadValue*10, 1)+", max="+DoubleToString(MaxSpreadValue*10, 1)+")");
               int ord_status = OrderSend(cur_symbol,OP_SELL,lot_size, EntryPrice, slip, OriginalSL,OriginalTP,cmt, MagicNumber, 0, Red);
               if(ord_status < 0)
                 {
                  Print(cur_symbol+" Error CLS : ", GetLastError()," lot_size : ",lot_size," EntryPrice : ",EntryPrice," OriginalSL : ",OriginalSL," OriginalTP : ",OriginalTP," cmt : ",cmt);
                 }
               else
                 {
                  lastCandlePair[cur_symbol_index]=Time[0];
                  GlobalVariableSet(gbl+IntegerToString(ord_status)+".PendingTime", Time[0]);
                  GlobalVariableSet(gbl+IntegerToString(ord_status)+".ISL", sell_sl);
                  if(CreateTextFiles)
                     CreateTextFile(cur_symbol, OP_SELL,EAID);
                 }

               allow_candlelimit_trade = false;
               candle_limit_triggered = Time[0];
               isBreakeven=false;

               if(EnableScreenshot)
                 {
                  TakeScreenshot("SELL");
                 }
              }
            else
              {
               Print(cur_symbol+" CLS Limit order not placed due to above price Bid:",MarketInfo(cur_symbol,MODE_BID)," EntryPrice:",EntryPrice);
              }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DoesSignalCatched(string symbol, int type, datetime from)
  {
   int type2=-1;
   if(type==OP_BUY)
      type2=OP_BUYLIMIT;
   if(type==OP_SELL)
      type2=OP_SELLLIMIT;
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==symbol && OrderMagicNumber()==MagicNumber && (OrderType()==type || OrderType()==type2 || type==-1))
           {
            datetime dt=(datetime)GlobalVariableGet(gbl+IntegerToString(OrderTicket())+".PendingTime");
            if(dt==0)
               dt=OrderOpenTime();
            if(dt>=from)
               return (OrderTicket());
           }
   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         if(OrderSymbol()==symbol && OrderMagicNumber()==MagicNumber && (OrderType()==type || OrderType()==type2 || type==-1))
           {
            datetime dt=(datetime)GlobalVariableGet(gbl+IntegerToString(OrderTicket())+".PendingTime");
            if(dt==0)
               dt=OrderOpenTime();
            if(dt>=from)
               return (OrderTicket());
           }
   return (-1);
  }
//+------------------------------------------------------------------+
bool CheckEntryStackingOption(string symbol, int type, double entry)
  {
   if(!CheckEntryStacking)
      return (true);
   int type2=-1;
   if(type==OP_BUY)
      type2=OP_BUYLIMIT;
   if(type==OP_SELL)
      type2=OP_SELLLIMIT;
   double adr=GetAdr(symbol, 0, 1);
   bool timeOk=true, adrOk=true;
   int digit=1, count=0;
   if((cur_digits == 3) || (cur_digits == 5))
     {
      digit= 10;
     }
   string msgAdr="", msgTime="";
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==symbol && OrderMagicNumber()==MagicNumber && (OrderType()==type || OrderType()==type2 || type==-1))
           {
            count ++;
            if(TimeCurrent()-OrderOpenTime()<MinTimeBetweenOrdersInMinutes*60)
              {
               Print(symbol+": CheckEntryStacking actual time (min):"+IntegerToString((TimeCurrent()-OrderOpenTime())/60)+", needed:"+IntegerToString(MinTimeBetweenOrdersInMinutes));
               timeOk=false;
              }
            else
              {
               msgTime=symbol+": CheckEntryStacking actual time (min):"+IntegerToString((TimeCurrent()-OrderOpenTime())/60)+", needed:"+IntegerToString(MinTimeBetweenOrdersInMinutes);
              }
            if(MathAbs(OrderOpenPrice()-entry)/cur_point/digit<adr*MinDistanceBetweenOrdersInPercentOfADR/100)
              {
               Print(symbol+": CheckEntryStacking actual range:"+DoubleToString(MathAbs(OrderOpenPrice()-entry)/cur_point/digit, 1)+", needed:"+DoubleToString(adr*MinDistanceBetweenOrdersInPercentOfADR/100, 1));
               adrOk=false;
              }
            else
              {
               msgAdr=symbol+": CheckEntryStacking actual range:"+DoubleToString(MathAbs(OrderOpenPrice()-entry)/cur_point/digit, 1)+", needed:"+DoubleToString(adr*MinDistanceBetweenOrdersInPercentOfADR/100, 1);
              }
           }
   if(adrOk && msgAdr!="")
      Print(msgAdr);
   if(timeOk && msgTime!="")
      Print(msgTime);
   int rate=0;
   if(timeOk)
      rate ++;
   if(adrOk)
      rate ++;
   return (rate>=EntryStackingSuccessRate);
  }
//+------------------------------------------------------------------+
bool CheckSLStackingOption(string symbol, int type, double entry)
  {
   if(!CheckStoplossStacking)
      return (true);
   int last=-1;
   int slPerDirection=0, stop=0;
   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         if(OrderSymbol()==symbol && OrderMagicNumber()==MagicNumber)
           {
            if(stop==0 && OrderType()==type)
               slPerDirection ++;
            if(stop==0 && OrderType()!=type)
               stop=1;
            if(OrderType()==type)
              {
               if(OrderProfit()>=0)
                  break;
               last=OrderTicket();
               break;
              }
           }
   if(last==-1)
      return (true);
   bool _res=OrderSelect(last, SELECT_BY_TICKET);
   datetime openTime=OrderOpenTime();
   if(GlobalVariableCheck(gbl+IntegerToString(last)+".PendingTime"))
      openTime=(datetime)GlobalVariableGet(gbl+IntegerToString(last)+".PendingTime");
   datetime baseTime=0;
   double basePrice=0;
   if(SLBaseCandle==sl_entry)
     {
      baseTime=openTime;
      basePrice=OrderOpenPrice();
     }
   if(SLBaseCandle==sl_exit)
     {
      baseTime=OrderCloseTime();
      basePrice=OrderClosePrice();
     }
   double adr=GetAdr(symbol, 0, 1);
   bool timeOk=true, adrOk=true;
   int digit=1, count=0;
   if((cur_digits == 3) || (cur_digits == 5))
     {
      digit= 10;
     }
   string msgAdr="", msgTime="";
   _res=OrderSelect(last, SELECT_BY_TICKET);
   if(TimeCurrent()-baseTime<MinSLTimeInMinutes*60)
     {
      Print(symbol+": CheckStoplossStacking time passed (min):"+IntegerToString((TimeCurrent()-baseTime)/60)+", needed:"+IntegerToString(MinSLTimeInMinutes));
      timeOk=false;
     }
   else
     {
      msgTime=symbol+": CheckStoplossStacking actual time (min):"+IntegerToString((TimeCurrent()-baseTime)/60)+", needed:"+IntegerToString(MinSLTimeInMinutes);
     }
   if(MathAbs(basePrice-entry)/cur_point/digit<adr*MinSLDistanceInPercentOfADR/100)
     {
      Print(symbol+": CheckStoplossStacking actual range:"+DoubleToString(MathAbs(basePrice-entry)/cur_point/digit, 1)+", needed:"+DoubleToString(adr*MinSLDistanceInPercentOfADR/100, 1));
      adrOk=false;
     }
   else
     {
      msgAdr=symbol+": CheckStoplossStacking actual range:"+DoubleToString(MathAbs(basePrice-entry)/cur_point/digit, 1)+", needed:"+DoubleToString(adr*MinSLDistanceInPercentOfADR/100, 1);
     }
   if(SL_Alternate!=0)
     {
      Print(symbol+": CheckStoplossStacking altrenate sl:"+IntegerToString(slPerDirection)+", max allowed:"+IntegerToString(SL_Alternate));
     }
   if(adrOk && msgAdr!="")
      Print(msgAdr);
   if(timeOk && msgTime!="")
      Print(msgTime);
   int rate=0;
   if(timeOk)
      rate ++;
   if(adrOk)
      rate ++;
   if(SL_Alternate!=0 && slPerDirection<SL_Alternate)
      rate ++;
   return (rate>=StoplossStackingSuccessRate);
  }
//+------------------------------------------------------------------+
bool CheckSwingAdrFilter(int otype)
  {
   if(Enable_EA_as_Copytrading_Receiver==false)
     {
      if(!SwingAdrFilterEnabled)
         return (true);
     }
   if(!ReadSwingAdrFromFile)
     {
      if(ValidationType==sa_direction)
        {
         if(otype==OP_BUY)
           {
            int bv=(int)iCustom(cur_symbol, 0, "Kishore Fredrick\\Swing ADR", 29, 1);
            if(bv==1 || bv==-1)
               return (true);
           }
         else
            if(otype==OP_SELL)
              {
               int sv=(int)iCustom(cur_symbol, 0, "Kishore Fredrick\\Swing ADR", 30, 1);
               if(sv==1 || sv==-1)
                  return (true);
              }
        }
      else
        {
         int bv=(int)iCustom(cur_symbol, 0, "Kishore Fredrick\\Swing ADR", 31, 1);
         if(bv==1 || bv==-1)
            return (true);
        }
     }
   else
     {
      int bv=0, sv=0, bo=0;
      if(GetSwingAdrData(cur_symbol, bv, sv, bo))
        {
         if(ValidationType==sa_direction)
           {
            if(otype==OP_BUY)
              {
               if(bv==1 || bv==-1)
                  return (true);
              }
            else
               if(otype==OP_SELL)
                 {
                  if(sv==1 || sv==-1)
                     return (true);
                 }
           }
         else
           {
            if(bo==1 || bo==-1)
               return (true);
           }
        }
     }
   return (false);
  }
//+------------------------------------------------------------------+
bool CheckSwingAdrCurrency(int otype)
  {
   if(Enable_EA_as_Copytrading_Receiver==false)
     {
      if(!SwingAdrCurrencyEnabled)
         return (true);
     }
   if(!ReadSwingAdrFromFile)
     {
      int bv=0, sv=0, bo=0;
      if(ReadSwingAdrData(cur_symbol, bv, sv, bo))
        {
         int c1=0, c2=0;
         if(GetSAdrRate(swingAdr, cur_symbol, c1, c2, otype))
           {
            //Print(cur_symbol, ": ", (otype==OP_BUY?"BUY":"SELL"), ", ", IntegerToString(c1), ", ", IntegerToString(c2));
            if((c1>=CurrencyRate1 && c2>=CurrencyRate2) || (c1>=CurrencyRate2 && c2>=CurrencyRate1))
               return (true);
           }
        }
     }
   else
     {
      int bv=0, sv=0, bo=0;
      if(GetSwingAdrData(cur_symbol, bv, sv, bo))
        {
         int c1=0, c2=0;
         if(GetSAdrRate(swingAdr, cur_symbol, c1, c2, otype))
           {
            //Print(cur_symbol, ": ", (otype==OP_BUY?"BUY":"SELL"), ", ", IntegerToString(c1), ", ", IntegerToString(c2));
            if((c1>=CurrencyRate1 && c2>=CurrencyRate2) || (c1>=CurrencyRate2 && c2>=CurrencyRate1))
               return (true);
           }
        }
     }
   return (false);
  }
//+------------------------------------------------------------------+
bool GetSAdrRate(stc_swing_adr &sadr[], string symbol, int &c1, int &c2, int type)
  {
   c1=0;
   c2=0;
   for(int i=0; i<ArraySize(sadr); i++)
     {
      if(sadr[i].cur==StringSubstr(symbol, 0, 3))
        {
         if(type==OP_BUY)
            c1=sadr[i].buyValid;
         if(type==OP_SELL)
            c1=sadr[i].sellValid;
        }
      if(sadr[i].cur==StringSubstr(symbol, 3, 3))
        {
         if(type==OP_BUY)
            c2=sadr[i].sellValid;
         if(type==OP_SELL)
            c2=sadr[i].buyValid;
        }
     }
   return (true);
  }
//+------------------------------------------------------------------+
bool GetSwingAdrData(string symbol, int &buy, int &sell, int &both)
  {
   for(int i=0; i<ArraySize(swingAdr); i++)
     {
      swingAdr[i].buyValid=0;
      swingAdr[i].sellValid=0;
     }
   buy=0;
   sell=0;
   both=0;
   bool found=false;
   string stime=TimeToString(Time[0], TIME_MINUTES);
   StringReplace(stime, ":", "");
   string fileName=SwingAdrFileName+"_"+cur_symbol+"_"+stime;
//Print(fileName);

   message="GetSignal"+":"+fileName+":ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";

   bool res= GetSignal(message);
   string to_split=message;
   if(to_split!="" && to_split!="No Signal")
     {
      string sp[];
      StringSplit(to_split, StringGetCharacter(",", 0), sp);

      if(ArraySize(sp)>=4)
        {
         string c1=StringSubstr(sp[0], 0, 3);
         string c2=StringSubstr(sp[0], 3, 3);
           {
            int b=(int)StringToInteger(sp[1]);
            int s=(int)StringToInteger(sp[2]);
            int bo=(int)StringToInteger(sp[3]);
            if(symbol==sp[0])
              {
               buy=b;
               sell=s;
               both=bo;
               found=true;
              }
            //Print(symbol, ", ", buy, ", ", sell, ", ", both);
            for(int i=0; i<ArraySize(swingAdr); i++)
              {
               if(swingAdr[i].cur==c1)
                 {
                  if(b==1)
                     swingAdr[i].buyValid ++;
                  if(s==-1)
                     swingAdr[i].sellValid ++;
                 }
               else
                  if(swingAdr[i].cur==c2)
                    {
                     if(b==1)
                        swingAdr[i].sellValid ++;
                     if(s==-1)
                        swingAdr[i].buyValid ++;
                    }
              }
           }
        }
     }
   return (found);
  }
//+------------------------------------------------------------------+
bool ReadSwingAdrData(string symbol, int &buy, int &sell, int &both)
  {
   for(int i=0; i<ArraySize(swingAdr); i++)
     {
      swingAdr[i].buyValid=0;
      swingAdr[i].sellValid=0;
     }
   buy=0;
   sell=0;
   both=0;
   bool found=false;
   for(int j=0; j<ArraySize(allSymbols); j++)
     {
      int b=(int)iCustom(allSymbols[j], 0, "Kishore Fredrick\\Swing ADR", 29, 1);
      if(b==EMPTY_VALUE)
         b=0;
      int s=(int)iCustom(allSymbols[j], 0, "Kishore Fredrick\\Swing ADR", 30, 1);
      if(s==EMPTY_VALUE)
         s=0;
      int bo=(int)iCustom(allSymbols[j], 0, "Kishore Fredrick\\Swing ADR", 31, 1);
      if(bo==EMPTY_VALUE)
         bo=0;
      string c1=StringSubstr(allSymbols[j], 0, 3);
      string c2=StringSubstr(allSymbols[j], 3, 3);
      if(symbol==allSymbols[j])
        {
         buy=b;
         sell=s;
         both=bo;
         found=true;
        }
      //Print(symbol, ", ", buy, ", ", sell, ", ", both);
      for(int i=0; i<ArraySize(swingAdr); i++)
        {
         if(swingAdr[i].cur==c1)
           {
            if(b==1)
               swingAdr[i].buyValid ++;
            if(s==-1)
               swingAdr[i].sellValid ++;
           }
         else
            if(swingAdr[i].cur==c2)
              {
               if(b==1)
                  swingAdr[i].sellValid ++;
               if(s==-1)
                  swingAdr[i].buyValid ++;
              }
        }
     }
   return (found);
  }
//+------------------------------------------------------------------+
void PlaceCandleEntry(int otype,string wPattern,int shiftPlus,string midPattern,int ip)
  {

   if(!ConfLocked)   //if no ConfLocked then no need to check further
      return;
//Print(cur_symbol, ", ", otype);
   bool asianCheck = true,max_check,asian_trigger=false;
   int order_count = GetOrderCount(otype);
   bool lo_check = LastOrderCheck(otype);
   bool co_check = CurrentOrderCheck(wPattern,otype);
   bool adrwr_check = Check_ADRWR(otype,wPattern,shiftPlus);
   int vol_count = Check_VolCount(otype,wPattern,shiftPlus);
   bool vol_count_check  = (vol_count>=VolCondCount);
   bool bc_check = BigCandleCheck();






//if any running order, then no limit order should be placed
   bool check_running = (ConfLocked && lo_check && co_check && vol_count_check) ? true : false;
   asianCheck = GetAsianCond(otype,shiftPlus);

//Checking of Range
   double crcZMax = getCRCMax(0,2,shiftPlus);
   double crcZNormal = getCRC(0,2,shiftPlus);
   bool check_crcZNormal = (EnableCRC) ? (crcZNormal==1 && crcZMax==1) : true;
   bool check_crcZMax = (EnableCRC) ? !(crcZNormal==0 && crcZMax==0) : false;

   int total_limit_orders = 0;
   if(!AllowOppositeSignals)
      total_limit_orders=(GetTotalOrders("BuyLimit",OP_BUYLIMIT)+GetTotalOrders("SellLimit",OP_SELLLIMIT));
   else
      total_limit_orders=(cur_sigOPType==OP_BUY?GetTotalOrders("BuyLimit",OP_BUYLIMIT):GetTotalOrders("SellLimit",OP_SELLLIMIT));
   bool gen_check = (checkNews && check_running && asianCheck && TimeCheck && lastCandlePair[cur_symbol_index]!=Time[0] && total_limit_orders<MaxLimitOrders);
//Print("crcZMax="+crcZMax+" crcZNormal="+crcZNormal+" check_crcZNormal="+check_crcZNormal+" check_crcZMax="+check_crcZMax+" T="+Time[0]);

   RefreshRates();
   double spread = NormalizeDouble((MarketInfo(cur_symbol,MODE_ASK) - MarketInfo(cur_symbol,MODE_BID)),cur_digits);

//GetSpreadVal(cur_symbol,AvgSpreadValue,MaxSpreadValue);
   bool check_spreadNormal = (NormalizeDouble(spread, cur_digits)<=NormalizeDouble(AvgSpreadValue*10*cur_point, cur_digits) && spread<MaxSpreadValue*10*cur_point);
   bool check_spreadMax = (NormalizeDouble(spread, cur_digits)>NormalizeDouble(AvgSpreadValue*10*cur_point, cur_digits) && spread<=MaxSpreadValue*10*cur_point);

   max_check = (gen_check && (check_crcZMax || check_spreadMax || (EnableCRC && EnableCRCStage)));
//Print("spread="+spread+" max_check="+max_check+" AvgSpreadValue="+(AvgSpreadValue*10*Point)+" spcheck="+(spread>AvgSpreadValue*10*Point)+" T="+Time[0]);
//Print(cur_symbol, ", ", max_check);


//Print(cur_symbol+" Entring" +" "+getCZDCVS(ZigZag_TF,1));

   bool cantrade= (CZDCV==false &&  CZRV==false &&  CSV==false && EnableSingleValidity==false && EnableDoubleValidity==false && EnableExplodeCheck==false && Enable_EA_as_Copytrading_Receiver==false && EnableLogicalSum==false && EnableLogicalWeightage==false && Enable_HTF1_Structure_Filter==false && Enable_HTF2_Structure_Filter==false && Enable_HTF3_Structure_Filter==false)?true:false;

   bool CZDCVB=((CZDCV && Signal_Mode==SHOW_BOTH) || (CZDCV && Signal_Mode==SHOW_BUY)) ? (getCZDCVB(ZigZag_TF,1)>=1?true:false):true;
   bool CZDCVS=((CZDCV && Signal_Mode==SHOW_BOTH) || (CZDCV && Signal_Mode==SHOW_SELL)) ? (getCZDCVS(ZigZag_TF,1)>=1?true:false):true;


   bool CZCZRV= CZRV?(getCZRV(ZigZag_TF,1) >= ZRVN ? true:false):true;

   bool CSVB=((CSV && Signal_Mode==SHOW_BOTH) || (CSV && Signal_Mode==SHOW_BUY)) ? (getCSVB(ZigZag_TF,1)==1?true:false):true;
   bool CSVS=((CSV && Signal_Mode==SHOW_BOTH) || (CSV && Signal_Mode==SHOW_SELL)) ? (getCSVS(ZigZag_TF,1)==1?true:false):true;

   bool HTF1_Structure_Filter_Buy=((Enable_HTF1_Structure_Filter && Signal_Mode==SHOW_BOTH) || (Enable_HTF1_Structure_Filter && Signal_Mode==SHOW_BUY)) ? (getCSVB1(ZigZag_TF,1)==true?true:false):true;

   bool HTF1_Structure_Filter_Sell=((Enable_HTF1_Structure_Filter && Signal_Mode==SHOW_BOTH) || (Enable_HTF1_Structure_Filter && Signal_Mode==SHOW_SELL)) ? (getCSVS1(ZigZag_TF,1)==true?true:false):true;

   bool HTF2_Structure_Filter_Buy=((Enable_HTF2_Structure_Filter && Signal_Mode==SHOW_BOTH) || (Enable_HTF2_Structure_Filter && Signal_Mode==SHOW_BUY)) ? (getCSVB2(ZigZag_TF,1)==true?true:false):true;
   bool HTF2_Structure_Filter_Sell=((Enable_HTF2_Structure_Filter && Signal_Mode==SHOW_BOTH) || (Enable_HTF2_Structure_Filter && Signal_Mode==SHOW_SELL)) ? (getCSVS2(ZigZag_TF,1)==true?true:false):true;


   bool HTF3_Structure_Filter_Buy=((Enable_HTF3_Structure_Filter && Signal_Mode==SHOW_BOTH) || (Enable_HTF3_Structure_Filter && Signal_Mode==SHOW_BUY)) ? (getCSVB3(ZigZag_TF,1)==true?true:false):true;
   bool HTF3_Structure_Filter_Sell=((Enable_HTF3_Structure_Filter && Signal_Mode==SHOW_BOTH) || (Enable_HTF3_Structure_Filter && Signal_Mode==SHOW_SELL)) ? (getCSVS3(ZigZag_TF,1)==true?true:false):true;

   bool SingleValidity= EnableSingleValidity?(getValiditySingle(ZigZag_TF,1) == 1 ? true:false):true;
   bool DoubleValidity= EnableDoubleValidity?(getValidityDouble(ZigZag_TF,1) == 1 ? true:false):true;

   bool ExplodeValidity= EnableExplodeCheck?(getExplodeValidity() >= ExplodeValue ? true:false):true;

   bool CheckMagic=Enable_EA_as_Copytrading_Receiver? ((string)Magic_Number_to_Copy==cur_magic_number?true: false):true;
   bool CheckComment=Enable_EA_as_Copytrading_Receiver?false:true;

   bool CheckZigZag_1= (Enable_HTF1_Structure_Filter && CheckZigZagValid_1)?(getZigZagValid_1() == 1 ? true:false):true;
   bool CheckZigZag_2= (Enable_HTF2_Structure_Filter && CheckZigZagValid_2)?(getZigZagValid_2() == 1 ? true:false):true;
   bool CheckZigZag_3= (Enable_HTF3_Structure_Filter && CheckZigZagValid_3)?(getZigZagValid_3() == 1 ? true:false):true;

   if(Enable_EA_as_Copytrading_Receiver)
     {
      int size=ArraySize(CommentList);
      for(int i=0; i<size; i++)
        {
         CheckComment= (string)CommentList[i].cmnt==cur_comment?true: false;
         if(CheckComment)
           {
            break;
           }
        }
     }


   bool BuyEntryAllowed= false;
   bool SellEntryAllowed=false;
   double LogicalSumBuy1=0;
   double LogicalWeightageBuy1=0;
   double LogicalSumSell1=0;
   double LogicalWeightageSell1=0;

   if(Enable_EA_as_Copytrading_Receiver==false)
     {
      double ExplodeValue1= getExplodeValidity() >= ExplodeValue ? 1 : 0;

      LogicalSumBuy1=getBuySum(ZigZag_TF,1)+ ExplodeValue1;
      LogicalWeightageBuy1=getBuyWeightage(ZigZag_TF,1)+ (ExplodeValue1 * 3);

      LogicalSumSell1=getSellSum(ZigZag_TF,1)+ ExplodeValue1;
      LogicalWeightageSell1=getSellWeightage(ZigZag_TF,1)+ (ExplodeValue1 * 3);



      if(EnableLogicalSum)
        {
         if(LogicalSumBuy1>=SumGTE && LogicalSumBuy1<SumLT)
           {
            BuyEntryAllowed=true;
           }

         if(LogicalSumSell1>=SumGTE && LogicalSumSell1<SumLT)
           {
            SellEntryAllowed=true;
           }
        }

      if(EnableLogicalWeightage)
        {
         if(LogicalWeightageBuy1>=WeightageGTE && LogicalWeightageBuy1<WeightageLT)
           {
            BuyEntryAllowed=true;
           }

         if(LogicalWeightageSell1>=WeightageGTE && LogicalWeightageSell1<WeightageLT)
           {
            SellEntryAllowed=true;
           }
        }

     }

//Print(cantrade+" "+ cur_symbol+" Condition "+ CZDCVB +" CZDCVS "+ CZDCVS +" CZCZRV "+ CZCZRV +" CSVB "+ CSVB +" CSVS "+ CSVS +" SV "+ SingleValidity +" DV "+ DoubleValidity +" EV "+ ExplodeValidity +" CM "+ CheckMagic +" CC "+ CheckComment +" HTF1_B "+ HTF1_Structure_Filter_Buy +" HTF1_S "+ HTF1_Structure_Filter_Sell +" HTF2_B "+ HTF2_Structure_Filter_Buy +" HTF2_S "+ HTF2_Structure_Filter_Sell +" HTF3_B "+ HTF3_Structure_Filter_Buy +" HTF3_S "+ HTF3_Structure_Filter_Sell);


   if(!(CZDCVB && CZDCVS && CZCZRV && CSVB && CSVS && SingleValidity && DoubleValidity && ExplodeValidity && CheckMagic && CheckComment && HTF1_Structure_Filter_Buy && HTF1_Structure_Filter_Sell && HTF2_Structure_Filter_Buy && HTF2_Structure_Filter_Sell && HTF3_Structure_Filter_Buy && HTF3_Structure_Filter_Sell && CheckZigZag_1 && CheckZigZag_2 && CheckZigZag_3))
     {
      if(cantrade==false)
        {
         //  if(dt6!=Time[0])
         bool ret=false;
           {
            // dt6=Time[0];

            if(CZDCVB==false && cur_sigOPType==0)
              {
               Print("Buy Entry Restricted on "+cur_symbol+" due to Zigzag Directional Change Valid");
               ret=true;
              }

            if(CZDCVS==false && cur_sigOPType==1)
              {
               Print("Sell Entry Restricted on "+cur_symbol+" due to Zigzag Directional Change Valid");
               ret=true;
              }
            if(CZCZRV==false)
              {
               Print("Entry Restricted on "+cur_symbol+" due to Zigzag Range Value Needed");
               ret=true;
              }

            if(CSVB==false && cur_sigOPType==0)
              {
               Print("Buy Entry Restricted on "+cur_symbol+" due to “Structure Valid");
               ret=true;
              }
            if(CSVS==false && cur_sigOPType==1)
              {
               Print("Sell Entry Restricted on "+cur_symbol+" due to “Structure Valid");
               ret=true;
              }

            if(HTF1_Structure_Filter_Buy==false && cur_sigOPType==0)
              {
               Print("Buy Entry Restricted on "+cur_symbol+" due to “HTF1 Structure Filter");
               ret=true;
              }
            if(HTF1_Structure_Filter_Sell==false && cur_sigOPType==1)
              {
               Print("Sell Entry Restricted on "+cur_symbol+" due to “HTF1 Structure Filter");
               ret=true;
              }

            if(HTF2_Structure_Filter_Buy==false && cur_sigOPType==0)
              {
               Print("Buy Entry Restricted on "+cur_symbol+" due to “HTF2 Structure Filter");
               ret=true;
              }
            if(HTF2_Structure_Filter_Sell==false && cur_sigOPType==1)
              {
               Print("Sell Entry Restricted on "+cur_symbol+" due to “HTF2 Structure Filter");
               ret=true;
              }

            if(HTF3_Structure_Filter_Buy==false && cur_sigOPType==0)
              {
               Print("Buy Entry Restricted on "+cur_symbol+" due to “HTF3 Structure Filter");
               ret=true;
              }
            if(HTF3_Structure_Filter_Sell==false && cur_sigOPType==1)
              {
               Print("Sell Entry Restricted on "+cur_symbol+" due to “HTF3 Structure Filter");
               ret=true;
              }
             
            if(CheckZigZag_1==false && cur_sigOPType==0)
              {
               Print("Buy Entry Restricted on "+cur_symbol+" due to “ZigZag Valid HTF-1");
               ret=true;
              }
            
            if(CheckZigZag_1==false && cur_sigOPType==1)
              {
               Print("Sell Entry Restricted on "+cur_symbol+" due to “ZigZag Valid HTF-1");
               ret=true;
              }
              
            if(CheckZigZag_2==false && cur_sigOPType==0)
              {
               Print("Buy Entry Restricted on "+cur_symbol+" due to “ZigZag Valid HTF-2");
               ret=true;
              }
              
            if(CheckZigZag_2==false && cur_sigOPType==1)
              {
               Print("Sell Entry Restricted on "+cur_symbol+" due to “ZigZag Valid HTF-2");
               ret=true;
              }
              
            if(CheckZigZag_3==false && cur_sigOPType==0)
              {
               Print("Buy Entry Restricted on "+cur_symbol+" due to “ZigZag Valid HTF-3");
               ret=true;
              }
              
            if(CheckZigZag_3==false && cur_sigOPType==1)
              {
               Print("Sell Entry Restricted on "+cur_symbol+" due to “ZigZag Valid HTF-3");
               ret=true;
              }

            if(SingleValidity==false)
              {
               Print("Entry Restricted on "+cur_symbol+" due to “Single Validity");
               ret=true;
              }
            if(DoubleValidity==false)
              {
               Print("Entry Restricted on "+cur_symbol+" due to “Double Validity");
               ret=true;
              }
            if(ExplodeValidity==false)
              {
               Print("Entry Restricted on "+cur_symbol+" due to “Explode Validity");
               ret=true;
              }
            if(CheckMagic==false)
              {
               Print("Entry Restricted on "+cur_symbol+" due to “Magic Number" +" "+ cur_magic_number);
               ret=true;
              }

            if(CheckComment==false)
              {
               Print("Entry Restricted on "+cur_symbol+" due to “Comment"+" "+ cur_comment);
               ret=true;
              }

           }
         if(ret)
           {
            return;
           }
        }
     }
// Print(cur_symbol+" Passed");


   if(EnableLogicalSum || EnableLogicalWeightage)
     {

      if(cur_sigOPType==1)
        {
         if(SellEntryAllowed==false)
           {
            // if(dt7!=Time[0])
              {
               Print("Sell Entry Restricted on "+cur_symbol+" due to “Logical Sum Weightage "+ (string)LogicalSumSell1+" "+(string)LogicalWeightageSell1);
              }
            return;
           }
        }
      if(cur_sigOPType==0)
        {
         if(BuyEntryAllowed==false)
           {
            //if(dt7!=Time[0])
              {
               Print("Buy Entry Restricted on "+cur_symbol+" due to “Logical Sum Weightage "+ (string)LogicalSumBuy1+" "+(string)LogicalWeightageBuy1);
              }
            return;
           }
        }

     }


   bool allowed=false;

   if(Enable_EA_as_Copytrading_Receiver)
     {
      if(cur_symbol=="EURUSD")
        {
         if(EURUSD_Allow==All)
           {
            allowed=true;
           }
         else
            if(EURUSD_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(EURUSD_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(EURUSD_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(EURUSD_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(EURUSD_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }


        }

      if(cur_symbol=="GBPUSD")
        {
         if(GBPUSD_Allow==All)
           {
            allowed=true;
           }
         else
            if(EURUSD_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(GBPUSD_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(GBPUSD_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(EURUSD_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(EURUSD_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="AUDUSD")
        {
         if(AUDUSD_Allow==All)
           {
            allowed=true;
           }
         else
            if(AUDUSD_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(AUDUSD_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(AUDUSD_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(AUDUSD_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(AUDUSD_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }


      if(cur_symbol=="USDJPY")
        {

         if(USDJPY_Allow==All)
           {
            allowed=true;
           }
         else
            if(USDJPY_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(USDJPY_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(USDJPY_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;

                    }
                  else
                     if(USDJPY_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(USDJPY_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }

        }


      if(cur_symbol=="USDCHF")
        {
         if(USDCHF_Allow==All)
           {
            allowed=true;
           }
         else
            if(USDCHF_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(USDCHF_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(USDCHF_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(USDCHF_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(USDCHF_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="USDCAD")
        {
         if(USDCAD_Allow==All)
           {
            allowed=true;
           }
         else
            if(USDCAD_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(USDCAD_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(USDCAD_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(USDCAD_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(USDCAD_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }


      if(cur_symbol=="EURAUD")
        {
         if(EURAUD_Allow==All)
           {
            allowed=true;
           }
         else
            if(EURAUD_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(EURAUD_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(EURAUD_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(EURAUD_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(EURAUD_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="EURCAD")
        {
         if(EURCAD_Allow==All)
           {
            allowed=true;
           }
         else
            if(EURCAD_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(EURCAD_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(EURCAD_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(EURCAD_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(EURCAD_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="EURCHF")
        {
         if(EURCHF_Allow==All)
           {
            allowed=true;
           }
         else
            if(EURCHF_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(EURCHF_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(EURCHF_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(EURCHF_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(EURCHF_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }


      if(cur_symbol=="EURGBP")
        {
         if(EURGBP_Allow==All)
           {
            allowed=true;
           }
         else
            if(EURUSD_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(EURGBP_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(EURGBP_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(EURGBP_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(EURGBP_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="EURJPY")
        {
         if(EURJPY_Allow==All)
           {
            allowed=true;
           }
         else
            if(EURUSD_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(EURJPY_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(EURJPY_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(EURJPY_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(EURJPY_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="GBPJPY")
        {
         if(GBPJPY_Allow==All)
           {
            allowed=true;
           }
         else
            if(GBPJPY_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(GBPJPY_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(GBPJPY_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(GBPJPY_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(GBPJPY_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="GBPCHF")
        {
         if(GBPCHF_Allow==All)
           {
            allowed=true;
           }
         else
            if(GBPCHF_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(GBPCHF_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(GBPCHF_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(GBPCHF_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(GBPCHF_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="NZDUSD")
        {
         if(NZDUSD_Allow==All)
           {
            allowed=true;
           }
         else
            if(NZDUSD_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(NZDUSD_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(NZDUSD_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(NZDUSD_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(NZDUSD_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="AUDCAD")
        {

         if(AUDCAD_Allow==All)
           {
            allowed=true;

           }
         else
            if(AUDCAD_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(AUDCAD_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;

                 }
               else
                  if(AUDCAD_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;

                    }
                  else
                     if(AUDCAD_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(AUDCAD_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }

        }


      if(cur_symbol=="AUDJPY")
        {
         if(AUDJPY_Allow==All)
           {
            allowed=true;
           }
         else
            if(AUDJPY_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(AUDJPY_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(AUDJPY_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(AUDJPY_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(AUDJPY_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="CHFJPY")
        {
         if(CHFJPY_Allow==All)
           {
            allowed=true;
           }
         else
            if(CHFJPY_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(CHFJPY_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(CHFJPY_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(CHFJPY_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(CHFJPY_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="AUDNZD")
        {
         if(AUDNZD_Allow==All)
           {
            allowed=true;
           }
         else
            if(AUDNZD_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(AUDNZD_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(AUDNZD_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(AUDNZD_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(AUDNZD_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="NZDJPY")
        {
         if(NZDJPY_Allow==All)
           {
            allowed=true;
           }
         else
            if(NZDJPY_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(NZDJPY_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(NZDJPY_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(NZDJPY_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(NZDJPY_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }


      if(cur_symbol=="NZDCAD")
        {
         if(NZDCAD_Allow==All)
           {
            allowed=true;
           }
         else
            if(NZDCAD_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(NZDCAD_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(NZDCAD_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(NZDCAD_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(NZDCAD_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="NZDCHF")
        {
         if(NZDCHF_Allow==All)
           {
            allowed=true;
           }
         else
            if(NZDCHF_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(NZDCHF_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(NZDCHF_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(NZDCHF_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(NZDCHF_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="GBPNZD")
        {
         if(GBPNZD_Allow==All)
           {
            allowed=true;
           }
         else
            if(GBPNZD_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(GBPNZD_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(GBPNZD_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(GBPNZD_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(GBPNZD_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }


      if(cur_symbol=="EURNZD")
        {
         if(EURNZD_Allow==All)
           {
            allowed=true;
           }
         else
            if(EURNZD_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(EURNZD_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(EURNZD_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(EURNZD_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(EURNZD_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="GBPCAD")
        {
         if(GBPCAD_Allow==All)
           {
            allowed=true;
           }
         else
            if(GBPCAD_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }

            else
               if(GBPCAD_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(GBPCAD_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(GBPCAD_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(GBPCAD_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="GBPAUD")
        {
         if(GBPAUD_Allow==All)
           {
            allowed=true;
           }
         else
            if(GBPAUD_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(GBPAUD_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(GBPAUD_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(GBPAUD_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(GBPAUD_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="AUDCHF")
        {
         if(AUDCHF_Allow==All)
           {
            allowed=true;
           }
         else
            if(AUDCHF_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(AUDCHF_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(AUDCHF_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(AUDCHF_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(AUDCHF_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="CADCHF")
        {
         if(CADCHF_Allow==All)
           {
            allowed=true;
           }
         else
            if(CADCHF_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(CADCHF_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(CADCHF_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(CADCHF_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(CADCHF_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }

      if(cur_symbol=="CADJPY")
        {
         if(CADJPY_Allow==All)
           {
            allowed=true;
           }
         else
            if(CADJPY_Allow==AllSADR)
              {
               bool skip=false;
               if(!CheckSwingAdrFilter(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                 }
               if(!CheckSwingAdrCurrency(otype))
                 {
                  skip=true;
                  Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                 }
               if(skip==false)
                 {
                  allowed=true;
                 }
              }
            else
               if(CADJPY_Allow==Buy1 && cur_sigOPType==0)
                 {
                  allowed=true;
                 }
               else
                  if(CADJPY_Allow==Sell1 && cur_sigOPType==1)
                    {
                     allowed=true;
                    }
                  else
                     if(CADJPY_Allow==BuySADR && cur_sigOPType==0)
                       {
                        bool skip=false;
                        if(!CheckSwingAdrFilter(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                          }
                        if(!CheckSwingAdrCurrency(otype))
                          {
                           skip=true;
                           Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                          }
                        if(skip==false)
                          {
                           allowed=true;
                          }
                       }
                     else
                        if(CADJPY_Allow==SellSADR && cur_sigOPType==1)
                          {
                           bool skip=false;
                           if(!CheckSwingAdrFilter(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
                             }
                           if(!CheckSwingAdrCurrency(otype))
                             {
                              skip=true;
                              Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
                             }
                           if(skip==false)
                             {
                              allowed=true;
                             }
                          }
        }


      if(allowed==false)
        {
         Print("Entry Restricted on "+cur_symbol+" due to Symbol Direction");
         return;
        }
     }

   if(EnableCandleLimitOrder && max_check)
     {
      PlaceCandleLimit(otype,midPattern+ecName,shiftPlus);   //Placing candle 50% limit order
      return;
     }

   if(!check_spreadMax && !check_spreadNormal && gen_check)
     {
      Print((otype==OP_BUY?"Buy":"Sell")+" entry on "+cur_symbol+" is skipped on max spread check (current="+DoubleToString(spread/cur_point, 0)+", avg="+DoubleToString(AvgSpreadValue*10, 1)+", max="+DoubleToString(MaxSpreadValue*10, 1)+")");
      lastCandlePair[cur_symbol_index]=Time[0];
      return;
     }
   if(!check_crcZMax && gen_check)
     {
      Print((otype==OP_BUY?"Buy":"Sell")+" entry on "+cur_symbol+" is skipped on crc check");
      lastCandlePair[cur_symbol_index]=Time[0];
      return;
     }




//Removed this to avoid not allowing to place limit order on same candle time (Time[0]!=last_limit_triggered) &&
   allow_candleentry_trade = (EnableCandleStickOrder && gen_check && check_crcZNormal && check_spreadNormal && !(EnableCRC && EnableCRCStage)) ? true : false;

   double CHigh = iHigh(cur_symbol,0,shiftPlus);
   double CLow = iLow(cur_symbol,0,shiftPlus);
   double CDiff = NormalizeDouble(CHigh - CLow,cur_digits);

   if(allow_candleentry_trade)
     {
      bool bdirection = (otype==OP_BUY) ? true : false;
      bool sdirection = (otype==OP_SELL) ? true : false;
      whichPattern = wPattern + ecName;

      string weight="";
      int currentw=0, acceptw=0;
      bool shc_check = EnableStopHuntCheckForEntry?Check_SHC(otype,wPattern,shiftPlus,ip,currentw,acceptw,weight):true;
      if(EnableStopHuntCheckForEntry && lastCandlePair[cur_symbol_index]!=Time[0])
        {
         Print((!shc_check?"trade is skipped for SHC on ":"")+cur_symbol+": current weightage="+IntegerToString(currentw)+", acceptance_weightage="+IntegerToString(acceptw)+", detail: "+weight);
         if(!shc_check)
            lastCandlePair[cur_symbol_index]=Time[0];
        }

      if(!adrwr_check && lastCandlePair[cur_symbol_index]!=Time[0])
        {
         Print("entry on "+cur_symbol+" is skipped on adr check");
         lastCandlePair[cur_symbol_index]=Time[0];
         return;
        }

      if(order_count>=MaxRunningOrders && MaxRunningOrders!=0)
        {
         Print("entry on "+cur_symbol+" is skipped on Maximum Running Orders");
         lastCandlePair[cur_symbol_index]=Time[0];
         return;
        }

      if(EnableEquityExit && EquityStopTrading!=0)
        {
         double fundedBalance=FundedAccountBalance;
         if(fundedBalance>AccountBalance())
            fundedBalance=AccountBalance();
         double EqTgt = ((EnableFundedAccount?fundedBalance:startBalance) * (EquityExit/100)) + startBalance;
         if(AccountEquity()-EqTgt<=EquityStopTrading*EqTgt/100)
           {
            Print("entry on "+cur_symbol+" is skipped on Stop New Trade when Equity is less than x% to target (Equity="+DoubleToString(AccountEquity(), 2)+", Target="+DoubleToString(EqTgt, 2)+")");
            lastCandlePair[cur_symbol_index]=Time[0];
            return;
           }
        }

      if(!bc_check)
        {
         Print((otype==OP_BUY?"Buy":"Sell")+" entry on "+cur_symbol+" is skipped on Avoid News Candle");
         lastCandlePair[cur_symbol_index]=Time[0];
         return;
        }

      if(bdirection)
        {
         EntryPrice = MarketInfo(cur_symbol,MODE_ASK);
         cur_Signal = "BUY";
         if(!CheckEntryStackingOption(cur_symbol, otype, EntryPrice))
           {
            Print(cur_Signal+" entry on "+cur_symbol+" is skipped on CheckEntryStacking");
            lastCandlePair[cur_symbol_index]=Time[0];
            return;
           }
         if(!CheckSLStackingOption(cur_symbol, otype, EntryPrice))
           {
            Print(cur_Signal+" entry on "+cur_symbol+" is skipped on CheckStoplossStacking");
            lastCandlePair[cur_symbol_index]=Time[0];
            return;
           }
         if(Enable_EA_as_Copytrading_Receiver==false)
           {
            if(!CheckSwingAdrFilter(otype))
              {
               Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
               lastCandlePair[cur_symbol_index]=Time[0];
               return;
              }
            if(!CheckSwingAdrCurrency(otype))
              {
               Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
               lastCandlePair[cur_symbol_index]=Time[0];
               return;
              }
           }
         EntryTime = iTime(cur_symbol,0,0);

         double crc1 = ReadCRC(0, CRC_NumOfDays, CRC_Multiplier, 2, shiftPlus);
         double slPercent=0;
         if(crc1==0)
            slPercent=CRCSLMultiplierStage2;
         else
            slPercent=CRCSLMultiplierStage1;
         double sl = EntryPrice - NormalizeDouble(CDiff * slPercent,cur_digits) - NormalizeDouble(spread * Spread_Multiplier,cur_digits);
         //Print("buy sl: ", crc1, ", ", slPercent, ", ", CDiff, ", ", spread * Spread_Multiplier, ", ", sl);

         buy_sl = NormalizeDouble(EntryPrice - sl,cur_digits);
         if(CheckSLValueByCRC)
           {
            double crcv=ReadCRC(0, CRC_NumOfDays, StopLossCRC, 6, 1);
            if(buy_sl>crcv)
              {
               if(ActionOnSLCRC==sl_crc_no_trade)
                 {
                  Print("buy trade on "+cur_symbol+" is skipped on Check Stoploss Maximum by CRC, CRC Number:"+IntegerToString(StopLossCRC)+", CRC Value:"+DoubleToString(crcv/cur_point, 0));
                  lastCandlePair[cur_symbol_index]=Time[0];
                  return;
                 }
               else
                  if(ActionOnSLCRC==sl_crc_use_crc)
                    {
                     Print("buy sl on "+cur_symbol+" is above Stoploss Maximum by CRC, update sl to CRC, CRC Number:"+IntegerToString(StopLossCRC)+", CRC Value:"+DoubleToString(crcv/cur_point, 0));
                     buy_sl=NormalizeDouble(crcv, cur_digits);
                     sl=EntryPrice-buy_sl;
                    }
              }
           }
         if(EnableDataIndicatorCalculation)
           {
            double oi=(int)iCustom(NULL, PERIOD_H1, "Kishore Fredrick\\Data Indicator.ex4", GetIndex1(cur_symbol), 0);
            if(!(oi>=MinimumValueBuy && oi<=MaximumValueBuy))
              {
               Print("buy trade on "+cur_symbol+" is skipped on EnableDataIndicatorCalculation, OI:"+DoubleToString(oi, 1)+", MinimumValueBuy:"+DoubleToString(MinimumValueBuy, 1)+", MaximumValueBuy:"+DoubleToString(MaximumValueBuy, 1));
               lastCandlePair[cur_symbol_index]=Time[0];
               return;
              }
            else
               if(OverExtendedFilter && (oi>OverExtendedLevel || oi<-OverExtendedLevel))
                 {
                  Print("buy trade on "+cur_symbol+" is skipped on OverExtendedFilter, OI:"+DoubleToString(oi, 1)+", OverExtendedLevel:"+DoubleToString(OverExtendedLevel, 1));
                  lastCandlePair[cur_symbol_index]=Time[0];
                  return;
                 }
               else
                 {
                  Print("buy trade on "+cur_symbol+", OI:"+DoubleToString(oi, 1)+", MinimumValueBuy:"+DoubleToString(MinimumValueBuy, 1)+", MaximumValueBuy:"+DoubleToString(MaximumValueBuy, 1));
                 }
           }

         lot_size = GetPositionSizingLot(buy_sl);
         //lot_size = CheckVolumeValue(lot_size);

         if(CheckMoneyForTrade(cur_symbol,lot_size,OP_BUY) == false)
           {
            lastCandlePair[cur_symbol_index]=Time[0];
            return;
           }

         double pv=SymbolInfoDouble(cur_symbol, SYMBOL_TRADE_TICK_VALUE)/SymbolInfoDouble(cur_symbol, SYMBOL_TRADE_TICK_SIZE);
         double comValue=CommissionPerLot*lot_size;
         double commPoints=MathCeil(comValue/(pv*lot_size)/cur_point)*cur_point;
         tp_sl_range = NormalizeDouble(buy_sl * RewardPercent+commPoints,cur_digits);

         OriginalTP = SetTarget(OP_BUY,EntryPrice,tp_sl_range,0);
         OriginalSL = NormalizeDouble(sl,cur_digits);
         string cmt = EA_Name+"-"+whichPattern+"-"+(string)MagicNumber+"#"+DoubleToStr(buy_sl,cur_digits);

         Print("symbol: "+cur_symbol+", spread="+DoubleToString(spread/cur_point, 0)+", avg="+DoubleToString(AvgSpreadValue*10, 1)+", max="+DoubleToString(MaxSpreadValue*10, 1)+")");
         int ord_status = OrderSend(cur_symbol,OP_BUY,lot_size, EntryPrice, slip, OriginalSL,OriginalTP,cmt, MagicNumber, 0, Lime);
         if(ord_status < 0)
           {
            Print(cur_symbol+" Error CEB : ", GetLastError()," Pattern:",whichPattern," lot_size : ",lot_size," EntryPrice : ",EntryPrice," OriginalSL : ",OriginalSL," OriginalTP : ",OriginalTP," cmt : ",cmt);
           }
         else
           {
            lastCandlePair[cur_symbol_index]=Time[0];
            GlobalVariableSet(gbl+IntegerToString(ord_status)+".ISL", buy_sl);
            if(CreateTextFiles)
               CreateTextFile(cur_symbol, OP_BUY,EAID);
           }

         allow_candleentry_trade = false;
         candle_entry_triggered = Time[0];

         if(EnableScreenshot)
           {
            TakeScreenshot("BUY");
           }

        }
      if(sdirection)
        {
         EntryPrice = MarketInfo(cur_symbol,MODE_BID);
         cur_Signal = "SELL";
         if(!CheckEntryStackingOption(cur_symbol, otype, EntryPrice))
           {
            Print(cur_Signal+" entry on "+cur_symbol+" is skipped on CheckEntryStacking");
            lastCandlePair[cur_symbol_index]=Time[0];
            return;
           }
         if(!CheckSLStackingOption(cur_symbol, otype, EntryPrice))
           {
            Print(cur_Signal+" entry on "+cur_symbol+" is skipped on CheckStoplossStacking");
            lastCandlePair[cur_symbol_index]=Time[0];
            return;
           }
         if(Enable_EA_as_Copytrading_Receiver==false)
           {
            if(!CheckSwingAdrFilter(otype))
              {
               Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrFilterEnabled");
               lastCandlePair[cur_symbol_index]=Time[0];
               return;
              }
            if(!CheckSwingAdrCurrency(otype))
              {
               Print(cur_Signal+" entry on "+cur_symbol+" is skipped on SwingAdrCurrencyEnabled");
               lastCandlePair[cur_symbol_index]=Time[0];
               return;
              }
           }
         EntryTime = iTime(cur_symbol,0,0);

         double crc1 = ReadCRC(0, CRC_NumOfDays, CRC_Multiplier, 2, shiftPlus);
         double slPercent=0;
         if(crc1==0)
            slPercent=CRCSLMultiplierStage2;
         else
            slPercent=CRCSLMultiplierStage1;
         double sl = EntryPrice + NormalizeDouble(CDiff * slPercent,cur_digits) + NormalizeDouble(spread * Spread_Multiplier,cur_digits);
         //Print("sell sl: ", crc1, ", ", slPercent, ", ", CDiff, ", ", spread * Spread_Multiplier, ", ", sl);

         sell_sl = NormalizeDouble(sl - EntryPrice,cur_digits);
         if(CheckSLValueByCRC)
           {
            double crcv=ReadCRC(0, CRC_NumOfDays, StopLossCRC, 6, 1);
            if(sell_sl>crcv)
              {
               if(ActionOnSLCRC==sl_crc_no_trade)
                 {
                  Print("sell trade on "+cur_symbol+" is skipped on Check Stoploss Maximum by CRC, CRC Number:"+IntegerToString(StopLossCRC)+", CRC Value:"+DoubleToString(crcv/cur_point, 0));
                  lastCandlePair[cur_symbol_index]=Time[0];
                  return;
                 }
               else
                  if(ActionOnSLCRC==sl_crc_use_crc)
                    {
                     Print("sell sl on "+cur_symbol+" is above Stoploss Maximum by CRC, update sl to CRC, CRC Number:"+IntegerToString(StopLossCRC)+", CRC Value:"+DoubleToString(crcv/cur_point, 0));
                     sell_sl=NormalizeDouble(crcv, cur_digits);
                     sl=EntryPrice+sell_sl;
                    }
              }
           }
         if(EnableDataIndicatorCalculation)
           {
            double oi=(int)iCustom(NULL, PERIOD_H1, "Kishore Fredrick\\Data Indicator.ex4", GetIndex1(cur_symbol), 0);
            if(!(oi>=MinimumValueSell && oi<=MaximumValueSell))
              {
               Print("sell trade on "+cur_symbol+" is skipped on EnableDataIndicatorCalculation, OI:"+DoubleToString(oi, 1)+", MinimumValueSell:"+DoubleToString(MinimumValueSell, 1)+", MaximumValueSell:"+DoubleToString(MaximumValueSell, 1));
               lastCandlePair[cur_symbol_index]=Time[0];
               return;
              }
            else
               if(OverExtendedFilter && (oi>OverExtendedLevel || oi<-OverExtendedLevel))
                 {
                  Print("sell trade on "+cur_symbol+" is skipped on OverExtendedFilter, OI:"+DoubleToString(oi, 1)+", OverExtendedLevel:"+DoubleToString(OverExtendedLevel, 1));
                  lastCandlePair[cur_symbol_index]=Time[0];
                  return;
                 }
               else
                 {
                  Print("sell trade on "+cur_symbol+", OI:"+DoubleToString(oi, 1)+", MinimumValueSell:"+DoubleToString(MinimumValueSell, 1)+", MaximumValueSell:"+DoubleToString(MaximumValueSell, 1));
                 }
           }

         lot_size = GetPositionSizingLot(sell_sl);
         //lot_size = CheckVolumeValue(lot_size);

         if(CheckMoneyForTrade(cur_symbol,lot_size,OP_SELL) == false)
           {
            lastCandlePair[cur_symbol_index]=Time[0];
            return;
           }

         double pv=SymbolInfoDouble(cur_symbol, SYMBOL_TRADE_TICK_VALUE)/SymbolInfoDouble(cur_symbol, SYMBOL_TRADE_TICK_SIZE);
         double comValue=CommissionPerLot*lot_size;
         double commPoints=MathCeil(comValue/(pv*lot_size)/cur_point)*cur_point;
         tp_sl_range = NormalizeDouble(sell_sl * RewardPercent+commPoints,cur_digits);

         OriginalTP = SetTarget(OP_SELL,EntryPrice,tp_sl_range,0);
         OriginalSL = NormalizeDouble(sl,cur_digits);
         string cmt = EA_Name+"-"+whichPattern+"-"+(string)MagicNumber+"#"+DoubleToStr(sell_sl,cur_digits);

         //Print(wPattern);
         Print("symbol: "+cur_symbol+", spread="+DoubleToString(spread/cur_point, 0)+", avg="+DoubleToString(AvgSpreadValue*10, 1)+", max="+DoubleToString(MaxSpreadValue*10, 1)+")");
         int ord_status = OrderSend(cur_symbol,OP_SELL,lot_size, EntryPrice, slip, OriginalSL,OriginalTP,cmt, MagicNumber, 0, Red);
         if(ord_status < 0)
           {
            Print(cur_symbol+" Error CES : ", GetLastError()," lot_size : ",lot_size," EntryPrice : ",EntryPrice," OriginalSL : ",OriginalSL," OriginalTP : ",OriginalTP," cmt : ",cmt);
           }
         else
           {
            lastCandlePair[cur_symbol_index]=Time[0];
            GlobalVariableSet(gbl+IntegerToString(ord_status)+".ISL", sell_sl);
            if(CreateTextFiles)
               CreateTextFile(cur_symbol, OP_BUY,EAID);
           }

         allow_candleentry_trade = false;
         candle_entry_triggered = Time[0];

         if(EnableScreenshot)
           {
            TakeScreenshot("SELL");
           }
        }
     }
  }
//+------------------------------------------------------------------+
void PlaceZoneLimit(int otype,string wPattern,int shiftPlus,string midPattern,int ip)
  {
   if(!ConfLocked)   //if no ConfLocked then no need to check further
      return;

   bool asianCheck = true,max_check,asian_trigger=false;
   int order_count = GetOrderCount(otype);
   bool lo_check = LastOrderCheck(otype);
   bool co_check = CurrentOrderCheck(wPattern,otype);
   bool adrwr_check = Check_ADRWR(otype,wPattern,shiftPlus);
   int vol_count = Check_VolCount(otype,wPattern,shiftPlus);
   bool vol_count_check  = (vol_count>=VolCondCount);
   string weight="";
   int currentw=0, acceptw=0;
   bool shc_check = EnableStopHuntCheckForEntry?Check_SHC(otype,wPattern,shiftPlus,ip,currentw,acceptw,weight):true;

//if any running order, then no limit order should be placed
   bool check_running = (ConfLocked && lo_check && co_check && adrwr_check && vol_count_check && shc_check && order_count<MaxRunningOrders && MaxRunningOrders!=0) ? true : false;
//Print("check_running="+check_running+" ConfLocked="+ConfLocked+" lo_check="+lo_check+" co_check="+co_check+" adrwr_check="+adrwr_check+" vol_count_check="+vol_count_check+" order_count="+order_count+" MaxRunningOrders="+MaxRunningOrders+" T="+Time[0]);
   asianCheck = GetAsianCond(otype,shiftPlus);

//Checking of Range
   double crcZMax = getCRCMax(0,2,shiftPlus);
   double crcZNormal = getCRC(0,2,shiftPlus);
   bool check_crcZNormal = (EnableCRC) ? (crcZNormal==1 && crcZMax==1) : true;
   bool check_crcZMax = (EnableCRC) ? (crcZNormal==0 && crcZMax==1) : false;

//Time[0]!=last_limit_triggered
   int total_limit_orders = 0;
   if(!AllowOppositeSignals)
      total_limit_orders=(GetTotalOrders("BuyLimit",OP_BUYLIMIT)+GetTotalOrders("SellLimit",OP_SELLLIMIT));
   else
      total_limit_orders=(cur_sigOPType==OP_BUY?GetTotalOrders("BuyLimit",OP_BUYLIMIT):GetTotalOrders("SellLimit",OP_SELLLIMIT));
   bool gen_check = checkNews && check_running && asianCheck && TimeCheck && total_limit_orders<MaxLimitOrders;

   RefreshRates();
   double spread = NormalizeDouble((MarketInfo(cur_symbol,MODE_ASK) - MarketInfo(cur_symbol,MODE_BID)),cur_digits);

   bool check_spreadNormal = (spread<AvgSpreadValue*10*cur_point && spread<MaxSpreadValue*10*cur_point);
   bool check_spreadMax = (spread>AvgSpreadValue*10*cur_point && spread<MaxSpreadValue*10*cur_point);

   max_check = (gen_check && (check_crcZMax || check_spreadMax));
   if(EnableCandleLimitOrder && max_check)
     {
      PlaceCandleLimit(otype,midPattern,shiftPlus);   //Placing candle 50% limit order
     }

//Removed this to avoid not allowing to place limit order on same candle time (Time[0]!=last_limit_triggered) &&
   allow_zonelimit_trade = (EnableCandleStickOrder && gen_check && check_crcZNormal && check_spreadNormal) ? true : false;

   double CHigh = iHigh(cur_symbol,0,shiftPlus);
   double CLow = iLow(cur_symbol,0,shiftPlus);
   double CDiff = NormalizeDouble(CHigh - CLow,cur_digits);

   if(allow_zonelimit_trade)
     {
      bool bdirection = (otype==OP_BUY) ? true : false;
      bool sdirection = (otype==OP_SELL) ? true : false;
      whichPattern = wPattern;

      if(bdirection)
        {
         EntryPrice = CHigh;
         cur_Signal = "BUY";
         EntryTime = iTime(cur_symbol,0,0);

         double crc1 = ReadCRC(0, CRC_NumOfDays, CRC_Multiplier, 2, shiftPlus);
         double slPercent=0;
         if(crc1==0)
            slPercent=CandleSLPercentStage2;
         else
            slPercent=CandleSLPercentStage1;
         double sl = CLow - NormalizeDouble(CDiff * slPercent,cur_digits) - NormalizeDouble(spread * Spread_Multiplier,cur_digits);
         //Print("buy sl: ", crc1, ", ", slPercent, ", ", CDiff, ", ", spread * Spread_Multiplier, ", ", sl);

         buy_sl = NormalizeDouble(EntryPrice - sl,cur_digits);
         tp_sl_range = NormalizeDouble(buy_sl * RewardPercent,cur_digits);

         lot_size = GetPositionSizingLot(buy_sl);
         //lot_size = CheckVolumeValue(lot_size);

         if(CheckMoneyForTrade(cur_symbol,lot_size,OP_BUY) == false)
            return;

         OriginalTP = SetTarget(OP_BUY,EntryPrice,tp_sl_range,0);
         OriginalSL = NormalizeDouble(sl,cur_digits);
         string cmt = EA_Name+"-"+whichPattern+"-"+(string)MagicNumber+"#"+DoubleToStr(buy_sl,cur_digits);

         if(MarketInfo(cur_symbol,MODE_BID) > EntryPrice)
           {
            int ord_status = OrderSend(cur_symbol,OP_BUYLIMIT,lot_size, EntryPrice, slip, OriginalSL,OriginalTP,cmt, MagicNumber, 0, Lime);
            if(ord_status < 0)
              {
               Print(cur_symbol+" Error ZLB Pattern:",whichPattern, GetLastError()," Pattern:",wPattern," lot_size : ",lot_size," EntryPrice : ",EntryPrice," OriginalSL : ",OriginalSL," OriginalTP : ",OriginalTP," cmt : ",cmt);
              }
            else
              {
               allow_zonelimit_trade = false;
               last_limit_triggered = Time[0];
               isBreakeven=false;

               if(EnableScreenshot)
                 {
                  TakeScreenshot("BUY");
                 }
              }
           }
         else
           {
            Print(cur_symbol+" ZLB Pattern:",whichPattern," Limit order not placed due to below price Bid:",MarketInfo(cur_symbol,MODE_BID)," EntryPrice:",EntryPrice);
           }
        }
      if(sdirection)
        {
         EntryPrice = CLow;
         cur_Signal = "SELL";
         EntryTime = iTime(cur_symbol,0,0);

         double crc1 = ReadCRC(0, CRC_NumOfDays, CRC_Multiplier, 2, shiftPlus);
         double slPercent=0;
         if(crc1==0)
            slPercent=CandleSLPercentStage2;
         else
            slPercent=CandleSLPercentStage1;
         double sl = CHigh + NormalizeDouble(CDiff * slPercent,cur_digits) + NormalizeDouble(spread * Spread_Multiplier,cur_digits);
         //Print("sell sl: ", crc1, ", ", slPercent, ", ", CDiff, ", ", spread * Spread_Multiplier, ", ", sl);

         sell_sl = NormalizeDouble(sl - EntryPrice,cur_digits);
         tp_sl_range = NormalizeDouble(sell_sl * RewardPercent,cur_digits);

         lot_size = GetPositionSizingLot(sell_sl);
         //lot_size = CheckVolumeValue(lot_size);

         if(CheckMoneyForTrade(cur_symbol,lot_size,OP_SELL) == false)
            return;

         OriginalTP = SetTarget(OP_SELL,EntryPrice,tp_sl_range,0);
         OriginalSL = NormalizeDouble(sl,cur_digits);
         string cmt = EA_Name+"-"+whichPattern+"-"+(string)MagicNumber+"#"+DoubleToStr(sell_sl,cur_digits);

         if(MarketInfo(cur_symbol,MODE_BID) < EntryPrice)
           {
            int ord_status = OrderSend(cur_symbol,OP_SELLLIMIT,lot_size, EntryPrice, slip, OriginalSL,OriginalTP,cmt, MagicNumber, 0, Red);
            if(ord_status < 0)
              {
               Print(cur_symbol+" Error ZLS Pattern:",whichPattern, GetLastError()," lot_size : ",lot_size," EntryPrice : ",EntryPrice," OriginalSL : ",OriginalSL," OriginalTP : ",OriginalTP," cmt : ",cmt);
              }
            else
              {
               allow_zonelimit_trade = false;
               last_limit_triggered = Time[0];
               isBreakeven=false;

               if(EnableScreenshot)
                 {
                  TakeScreenshot("SELL");
                 }
              }
           }
         else
           {
            Print(cur_symbol+" ZLS Pattern:",whichPattern," Limit order not placed due to above price Bid:",MarketInfo(cur_symbol,MODE_BID)," EntryPrice:",EntryPrice);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetTotalConfirmationCount()
  {
   int totc=0;
   for(int c=0; c<MaxConfCount; c++)
     {
      totc += OAConfArr[c].countValue;
     }
   return totc;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FindConfirmationTime()
  {
   bool final_conf=false;

//if(EnableVolZoneConfirmation && Time[0]>=MaxConfTime && !is_volconfReset)
//{
//   is_volconfReset = true;
//   isvolconfInformed = false;
//   is_volconfLocked = false;
//   confby = "";
//   confTime = 0;//resetting the confirmation time so that we can avoid any entries
//   Print("Resetting the Volume Zone Confirmation Time on "+(string)Time[0]);
//}


   if(EnableOverallConfirmation)
     {

      for(int c=0; c<MaxConfCount; c++)
        {
         if(Time[0]>=OAConfArr[c].MaxConfTime && OAConfArr[c].confby!="")// && !is_confReset)
           {
            if(OAConfArr[c].isInformed)
              {
               Print("Resetting the ConfTime on "+OAConfArr[c].confby+" at "+(string)Time[0]);
              }
            is_confReset = true;
            isconfInformed = false;
            is_confLocked = false;
            OAConfArr[c].isLocked = false;
            OAConfArr[c].confTime = 0;//resetting the confirmation time so that we can avoid any entries
            OAConfArr[c].MaxConfTime = 0;
            OAConfArr[c].confby = "";
            OAConfArr[c].isInformed = false;
            OAConfArr[c].countValue = 0;
           }
         if(EnableSSMConfirmation && OAConfArr[0].isLocked==false)
           {
            int ssmcbs = (SSM_ConfTF==Period()) ? iPlus : iBarShift(cur_symbol,SSM_ConfTF,Time[0]);
            double ssm_conf_LastDir= getSSMConf(SSM_ConfTF,21,ssmcbs,0);
            //Print("ssm_conf_LastDir="+ssm_conf_LastDir+" Tssmcbs="+iTime(NULL,SSM_ConfTF,ssmcbs)+" T="+Time[0]);
            if(ssm_conf_LastDir!=0)
              {
               datetime ssm_conf_LastDirTime = (datetime)getSSMConf(SSM_ConfTF,22,ssmcbs,0);
               ssm_conf_LastDirTime  = (TimeYear(ssm_conf_LastDirTime)==TimeYear(Time[0])) ? ssm_conf_LastDirTime : Time[0];
               confTime = (cur_sigOPType==OP_BUY && ssm_conf_LastDir==1) ? ssm_conf_LastDirTime : (cur_sigOPType==OP_SELL && ssm_conf_LastDir==-1) ? ssm_conf_LastDirTime : Time[0];
               confby = "SSM";
               OAConfArr[0].isLocked = true;
               OAConfArr[0].confTime = confTime;
               OAConfArr[0].MaxConfTime  = 0;
               OAConfArr[0].confby  = confby;
               OAConfArr[0].isInformed = false;
               OAConfArr[0].countValue = 1;
              }
           }

         if(EnableMACConfirmation && OAConfArr[1].isLocked==false)
           {
            double mac_dir_conf = getMACConf(MAC_ConfTF,2,iPlus);
            int wchmode = (mac_dir_conf == 1) ? 3 : (mac_dir_conf == -1) ? 4 : 0;//3 for buytime and 4 for sell time, else 0
            if(wchmode!=0)
              {
               confTime = (datetime)getMACConf(MAC_ConfTF,wchmode,iPlus);
               confby = "MAC";
               is_confLocked = true;
               OAConfArr[1].isLocked = true;
               OAConfArr[1].confTime = confTime;
               OAConfArr[1].MaxConfTime  = 0;
               OAConfArr[1].confby  = confby;
               OAConfArr[1].isInformed = false;
               OAConfArr[1].countValue = 1;
              }
           }

         if(EnableLiqConfirmation && OAConfArr[2].isLocked==false)
           {
            int cbs = (Liq_ConfTF==Period()) ? iPlus : iBarShift(cur_symbol,Liq_ConfTF,Time[0])+1;
            double liq_dir_conf = getLiquidityMA(Liq_ConfTF,2,cbs);
            int wchmode = (liq_dir_conf == 1) ? 3 : (liq_dir_conf == -1) ? 4 : 0;//3 for buytime and 4 for sell time, else 0
            if(wchmode!=0)
              {
               confTime = (datetime)getLiquidityMA(Liq_ConfTF,wchmode,cbs);
               confby = "LIQ";
               is_confLocked = true;
               OAConfArr[2].isLocked = true;
               OAConfArr[2].confTime = confTime;
               OAConfArr[2].MaxConfTime  = 0;
               OAConfArr[2].confby  = confby;
               OAConfArr[2].isInformed = false;
               OAConfArr[2].countValue = 1;
              }
           }

         if(EnableRevConfirmation && OAConfArr[3].isLocked==false)
           {
            int cbs = (Rev_ConfTF==Period()) ? iPlus : iBarShift(cur_symbol,Rev_ConfTF,Time[0])+1;
            double rev_dir_conf = getReversalMA(Rev_ConfTF,2,cbs);
            int wchmode = (rev_dir_conf == 1) ? 3 : (rev_dir_conf == -1) ? 4 : 0;//3 for buytime and 4 for sell time, else 0

            if(wchmode!=0)
              {
               confTime = (datetime)getReversalMA(Rev_ConfTF,wchmode,cbs);
               confby = "REV";
               is_confLocked = true;
               OAConfArr[3].isLocked = true;
               OAConfArr[3].confTime = confTime;
               OAConfArr[3].MaxConfTime  = 0;
               OAConfArr[3].confby  = confby;
               OAConfArr[3].isInformed = false;
               OAConfArr[3].countValue = 1;
              }
           }
         if(EnableSDConfirmation && OAConfArr[4].isLocked==false)
           {
            //int cbs = (TouchHTF==Period()) ? iPlus : iBarShift(cur_symbol,TouchHTF,Time[0])+1;

            //Checking 8 patterns
            int bmode = 4,smode = 5;
            for(int pat=1; pat<=8; pat++)
              {

               double sd_bdir = (cur_sigOPType==OP_BUY) ? getSD(TouchHTF,bmode,0) : EMPTY_VALUE;
               double sd_sdir = (cur_sigOPType==OP_SELL) ? getSD(TouchHTF,smode,0) : EMPTY_VALUE;
               int wchmode = (cur_sigOPType==OP_BUY && sd_bdir != EMPTY_VALUE) ? 1 : (cur_sigOPType==OP_SELL && sd_sdir != EMPTY_VALUE) ? 2 : 0;

               if(wchmode!=0)
                 {
                  confTime =  Time[0];
                  confby = "S&D"+(string)pat;
                  is_confLocked = true;
                  OAConfArr[4].isLocked = true;
                  OAConfArr[4].confTime = confTime;
                  OAConfArr[4].MaxConfTime  = 0;
                  OAConfArr[4].confby  = confby;
                  OAConfArr[4].isInformed = false;
                  OAConfArr[4].countValue = 1;
                  break;
                 }
               bmode+=6;
               smode+=6;
              }
           }
         if(EnablePA1Confirmation && OAConfArr[5].isLocked==false)
           {
            int cbs = (TouchHTF==Period()) ? 0 : iBarShift(cur_symbol,TouchHTF,Time[0]);

            //Checking 8 patterns
            int bmode = 0,smode = 1;
            for(int pat=1; pat<=8; pat++)
              {

               double sd_bdir = (cur_sigOPType==OP_BUY) ? getPA1(TouchHTF,bmode,cbs) : EMPTY_VALUE;
               double sd_sdir = (cur_sigOPType==OP_SELL) ? getPA1(TouchHTF,smode,cbs) : EMPTY_VALUE;
               int wchmode = (cur_sigOPType==OP_BUY && sd_bdir != EMPTY_VALUE) ? 1 : (cur_sigOPType==OP_SELL && sd_sdir != EMPTY_VALUE) ? 2 : 0;

               //Print("smode="+smode+" pat="+pat+" sd_sdir="+sd_sdir+" wchmode="+wchmode+" cbs="+cbs+" T="+Time[0]);
               if(wchmode!=0)
                 {
                  confTime =  Time[0];
                  confby = "PA1_"+(string)pat;
                  is_confLocked = true;
                  OAConfArr[5].isLocked = true;
                  OAConfArr[5].confTime = confTime;
                  OAConfArr[5].MaxConfTime  = 0;
                  OAConfArr[5].confby  = confby;
                  OAConfArr[5].isInformed = false;
                  OAConfArr[5].countValue = 1;
                  break;
                 }
               bmode+=10;
               smode+=10;
              }
           }
         if(EnablePA2Confirmation && OAConfArr[6].isLocked==false)
           {
            int cbs = (TouchHTF==Period()) ? iPlus : iBarShift(cur_symbol,TouchHTF,Time[0])+1;

            //Checking 8 patterns
            int bmode = 0,smode = 1;
            for(int pat=1; pat<=8; pat++)
              {
               double sd_bdir = (cur_sigOPType==OP_BUY) ? getPA2(TouchHTF,bmode,cbs) : EMPTY_VALUE;
               double sd_sdir = (cur_sigOPType==OP_SELL) ? getPA2(TouchHTF,smode,cbs) : EMPTY_VALUE;
               int wchmode = (cur_sigOPType==OP_BUY && sd_bdir != EMPTY_VALUE) ? 1 : (cur_sigOPType==OP_SELL && sd_sdir != EMPTY_VALUE) ? 2 : 0;

               //Print("smode="+smode+" pat="+pat+" sd_sdir="+sd_sdir+" wchmode="+wchmode+" cbs="+cbs+" T="+Time[0]);
               if(wchmode!=0)
                 {
                  confTime =  Time[0];
                  confby = "PA2_"+(string)pat;
                  is_confLocked = true;
                  OAConfArr[6].isLocked = true;
                  OAConfArr[6].confTime = confTime;
                  OAConfArr[6].MaxConfTime  = 0;
                  OAConfArr[6].confby  = confby;
                  OAConfArr[6].isInformed = false;
                  OAConfArr[6].countValue = 1;
                  break;
                 }
               bmode+=10;
               smode+=10;
              }
           }

         if(EnableWedgesConfirmation && OAConfArr[7].isLocked==false)
           {
            //int cbs = (TouchHTF==Period()) ? iPlus : iBarShift(cur_symbol,TouchHTF,Time[0])+1;

            //Checking 3 patterns
            int bmode = 0,smode = 1;
            for(int pat=1; pat<=3; pat++)
              {
               double wed_bdir = (cur_sigOPType==OP_BUY) ? getWedges(TouchHTF,bmode,0) : EMPTY_VALUE;
               double wed_sdir = (cur_sigOPType==OP_SELL) ? getWedges(TouchHTF,smode,0) : EMPTY_VALUE;
               int wchmode = (cur_sigOPType==OP_BUY && wed_bdir != EMPTY_VALUE && wed_bdir != 0) ? 1 : (cur_sigOPType==OP_SELL && wed_sdir != EMPTY_VALUE && wed_sdir != 0) ? 2 : 0;

               //Print("bmode="+bmode+" smode="+smode+" pat="+pat+" wed_bdir="+wed_bdir+" wed_sdir="+wed_sdir+" wchmode="+wchmode+" cbs="+cbs+" T="+Time[0]);
               if(wchmode!=0)
                 {
                  confTime =  Time[0];
                  confby = "WED_"+(string)pat;
                  is_confLocked = true;
                  OAConfArr[7].isLocked = true;
                  OAConfArr[7].confTime = confTime;
                  OAConfArr[7].MaxConfTime  = 0;
                  OAConfArr[7].confby  = confby;
                  OAConfArr[7].isInformed = false;
                  OAConfArr[7].countValue = 1;
                  break;
                 }
               bmode+=10;
               smode+=10;
              }
           }
         if(EnableRSIDConfirmation && OAConfArr[8].isLocked==false)
           {
            int cbs = (TouchHTF==Period()) ? iPlus : iBarShift(cur_symbol,TouchHTF,Time[0])+1;
            double rsi_dir_conf = getRSIDivg(TouchHTF,2,cbs);
            int wchmode = (rsi_dir_conf == 1) ? 3 : (rsi_dir_conf == -1) ? 4 : 0;//3 for buytime and 4 for sell time, else 0

            if(wchmode!=0)
              {
               confTime = (datetime)getRSIDivg(TouchHTF,wchmode,cbs);
               confby = "RSID";
               is_confLocked = true;
               OAConfArr[8].isLocked = true;
               OAConfArr[8].confTime = confTime;
               OAConfArr[8].MaxConfTime  = 0;
               OAConfArr[8].confby  = confby;
               OAConfArr[8].isInformed = false;
               OAConfArr[8].countValue = 1;
              }
           }
         if(EnableAsianTriggerConf && OAConfArr[9].isLocked==false)
           {
            int wchMode = (cur_sigOPType==OP_BUY) ? 13 : (cur_sigOPType==OP_SELL) ? 14 : 0;
            datetime asianTime = (datetime)getAsianSession(Asian_TF,wchMode,iPlus);
            AsianLastTime=StrToTime((string)TimeYear(Time[iPlus])+"."+(string)TimeMonth(Time[iPlus])+"."+(string)TimeDay(Time[iPlus])+" "+Asian_Last_Time);
            bool asian_trigger = (asianTime>cur_entryTime && Time[0]>=asianTime && Time[0]<=AsianLastTime);
            //Print("asian_trigger="+asian_trigger+" cur_sigOPType="+cur_sigOPType+" wchMode="+wchMode+" asianTime="+asianTime+" AsianLastTime="+AsianLastTime+" T="+Time[0]);
            if(asian_trigger)
              {
               confTime = Time[iPlus];
               confby = "AST";
               is_confLocked = true;
               OAConfArr[9].isLocked = true;
               OAConfArr[9].confTime = confTime;
               OAConfArr[9].MaxConfTime  = 0;
               OAConfArr[9].confby  = confby;
               OAConfArr[9].isInformed = false;
               OAConfArr[9].countValue = (EnableDoubleConf) ? 2 : 1;
              }
           }
         if(EnableMarketShiftConfirmation && OAConfArr[10].isLocked==false)
           {
            double msDir = getMarketShift(TouchHTF,cur_sigOPType,2,iPlus);
            bool msConf = (cur_sigOPType==OP_BUY && msDir!=EMPTY_VALUE && msDir==1) ? true : (cur_sigOPType==OP_SELL && msDir!=EMPTY_VALUE && msDir==-1) ? true : false;

            if(msConf)
              {
               confTime = Time[iPlus];
               confby = "MS";
               is_confLocked = true;
               OAConfArr[10].isLocked = true;
               OAConfArr[10].confTime = confTime;
               OAConfArr[10].MaxConfTime  = 0;
               OAConfArr[10].confby  = confby;
               OAConfArr[10].isInformed = false;
               OAConfArr[10].countValue = 1;
              }
           }
         if(EnableLGrabConfirmation && OAConfArr[11].isLocked==false)
           {
            //int cbs = (TouchHTF==Period()) ? iPlus : iBarShift(cur_symbol,TouchHTF,Time[0])+1;
            double liqgrab_dir_conf = getLiquidityGrab(LG_ETF,2,iPlus);
            int wchmode = (liqgrab_dir_conf == 1) ? 3 : (liqgrab_dir_conf == -1) ? 4 : 0;//3 for buytime and 4 for sell time, else 0
            if(wchmode!=0)
              {
               confTime = (datetime)getLiquidityGrab(LG_ETF,wchmode,iPlus);
               confby = "LGB";
               is_confLocked = true;
               OAConfArr[11].isLocked = true;
               OAConfArr[11].confTime = confTime;
               OAConfArr[11].MaxConfTime  = 0;
               OAConfArr[11].confby  = confby;
               OAConfArr[11].isInformed = false;
               OAConfArr[11].countValue = 1;
              }
           }


         //Once confirmation locked, calculate for maximum confirmation time
         if(OAConfArr[c].isLocked && OAConfArr[c].confby!="" && OAConfArr[c].isInformed==false)
           {
            OAConfArr[c].isInformed = true;
            is_confReset = false;
            confBarShift = (iBarShift(cur_symbol,0,confTime) + SSM_InpDepth);
            //For minutes, *60, for hours *60*60
            OAConfArr[c].MaxConfTime= (OAConfArr[c].confTime + Max_Conf_Expiry * 60);
            Print("Confirmation Locked by "+OAConfArr[c].confby+" on confTime="+(string)OAConfArr[c].confTime+" and MaxConfTime="+(string)OAConfArr[c].MaxConfTime+", confBarShift="+(string)confBarShift+" T="+(string)Time[0]);//confBarShiftTime="+(string)Time[confBarShift]+"

           }
        }
     }
   else
     {
      is_confLocked = true;
     }

//   if(EnableVolZoneConfirmation && is_volconfLocked==false)
//   {
//      int cbs = (TouchHTF==Period()) ? iPlus : iBarShift(cur_symbol,TouchHTF,Time[0])+1;
//      double vz_bdir = (cur_sigOPType==OP_BUY) ? getVolZoneConf(TouchHTF,1,cbs) : EMPTY_VALUE;
//      double vz_sdir = (cur_sigOPType==OP_SELL) ? getVolZoneConf(TouchHTF,2,cbs) : EMPTY_VALUE;
//      int wchmode = (cur_sigOPType==OP_BUY && vz_bdir != EMPTY_VALUE) ? 17 : (cur_sigOPType==OP_SELL && vz_sdir != EMPTY_VALUE) ? 17 : 0;
//      if(wchmode!=0)
//      {
//         confTime =  Time[0];
//         confby = "VZO";
//         is_volconfLocked = true;
//      }
//
//      //Once Volume Zone Confirmation locked, calculate for maximum confirmation time
//      if(is_volconfLocked && confby!="" && isvolconfInformed==false)
//      {
//         isvolconfInformed = true;
//         is_volconfReset = false;
//         //For minutes, *60, for hours *60*60
//         MaxConfTime = (confTime + Max_Conf_Expiry * 60);
//         Print("Volume Zone Confirmation Locked on confTime="+(string)confTime+" and MaxConfTime="+(string)MaxConfTime+" T="+(string)Time[0]);
//      }
//   }
//   else
//   {
//      is_volconfLocked = true;
//   }

   int totalConfCount = GetTotalConfirmationCount();
   if(oldTCC != totalConfCount)
     {
      oldTCC = totalConfCount;
      Print("Total Confirmation Count : "+(string)totalConfCount+" out of "+(string)OverAllCount+" at "+(string)Time[0]);
     }
   bool countValidity = (EnableOverallConfirmation) ? (totalConfCount >= OverAllCount) : true;
//final checking of overall confirmation and volume zone confirmation
   final_conf = (countValidity); // && is_volconfLocked, removed this because of we use this in volume count condition
//Print("final_conf="+final_conf+" is_confLocked="+is_confLocked+" is_volconfLocked="+is_volconfLocked+" T="+Time[0]);
   return final_conf;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GetAsianCond(int otype,int shiftPlus)
  {
   bool asian_cond = false;
   if(EnableAsianSession)
     {
      double adir = getAsianSession(Asian_TF,6,shiftPlus);
      int wchMode = (otype==OP_BUY) ? 3 : (otype==OP_SELL) ? 5 : 0;
      datetime asianTime = (datetime)getAsianSession(Asian_TF,wchMode,shiftPlus);
      bool asian_trigger = (EnableAsianTrigger && asianTime>cur_entryTime && Time[0]>=asianTime && Time[0]<=AsianLastTime);
      asian_cond = (otype == OP_BUY && (adir == 1 || asian_trigger)) ? true : (otype == OP_SELL && (adir == -1 || asian_trigger)) ? true : false;
     }
   else
     {
      asian_cond = true;
     }
   return asian_cond;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SetTarget(int otype,double entry_price,double tp_range,int shift)
  {
   double tgt=0;

//Normal reward target
   if(otype==OP_BUY)
     {
      tgt = entry_price + tp_range;
     }
   if(otype==OP_SELL)
     {
      tgt = entry_price - tp_range;
     }

   if(otype==OP_BUY && EnableTargetInd && btargetind!=0)
     {
      tgt = btargetind;
     }
   else
      if(otype==OP_SELL && EnableTargetInd && stargetind!=0)
        {
         tgt = stargetind;
        }

   if(otype==OP_BUY && EnableAsianTarget)
     {
      tgt = basiantarget;
     }
   else
      if(otype==OP_SELL && EnableAsianTarget)
        {
         tgt = sasiantarget;
        }

   if(otype==OP_BUY && EnableADR_AWR_Target)
     {
      if(ADR_TargetMethod == ADR_TARGET)
        {
         tgt = getADR_AWR(0,otype,2,shift);
        }
      if(ADR_TargetMethod == AWR_TARGET)
        {
         tgt = getADR_AWR(0,otype,16,shift);
        }
     }
   else
      if(otype==OP_SELL && EnableADR_AWR_Target)
        {
         if(ADR_TargetMethod == ADR_TARGET)
           {
            tgt = getADR_AWR(0,otype,8,shift);
           }
         if(ADR_TargetMethod == AWR_TARGET)
           {
            tgt = getADR_AWR(0,otype,22,shift);
           }
        }

   return NormalizeDouble(tgt,Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double zonemtf(int tf,int mode,int shift)
  {
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\RIS ZoneMTF","",ZMTF_MaxBars_Tf1,ZMTF_MaxBars_Tf2,ZMTF_MaxBars_Tf3,ZMTF_MaxBars_Tf4,cur_sigOPType,false,EnableZMTF_ZOEMan,EnableZMTF_ChoppinessMan,"",ZMTF_TotalCountCond,EnableZMTF_ZoneTouch,EnableZOE,EnableAbsorption,Ab_BodySize,AbCandlePerct,EnableVolCheckEntry,VolPeriodEntry,VolThresholdEntry,EnableSSMChoppiness,SSM_CI_Period,SSM_CI_TriggerLevel,"",ZMTF_TF1,ZMTF_TF2,ZMTF_TF3,ZMTF_TF4,SumupValue,SSM_InpDepth,SSM_InpDeviation,SSM_InpBackstep,SSM_zz_hl,Percentage1,Percentage2,SSM_ValueAboveBelow,ExtraShiftZones,"",LOGIC_B,BreachPercentage,LTFExtendPercentage,MTFExtendPercentage,HTFExtendPercentage,STFExtendPercentage,"",false,BodySize1_MC,false,clrAliceBlue,clrAliceBlue,false,clrAliceBlue,clrAliceBlue,false,clrAliceBlue,clrAliceBlue,false,clrAliceBlue,clrAliceBlue,mode,shift);//last 3 removed ,false,24,false
//return iCustom(cur_symbol,tf,"Kishore Fredrick\\RIS ZoneMTF","",ZMTF_MaxBars_Tf1,ZMTF_MaxBars_Tf2,ZMTF_MaxBars_Tf3,ZMTF_MaxBars_Tf4,cur_sigOPType,false,"",ZMTF_TF1,ZMTF_TF2,ZMTF_TF3,ZMTF_TF4,SumupValue,SSM_InpDepth,SSM_InpDeviation,SSM_InpBackstep,SSM_zz_hl,Percentage1,Percentage2,SSM_ValueAboveBelow,ExtraShiftZones,"",LOGIC_B,BreachPercentage,LTFExtendPercentage,MTFExtendPercentage,HTFExtendPercentage,STFExtendPercentage,"",false,clrAliceBlue,clrAliceBlue,false,clrAliceBlue,clrAliceBlue,false,clrAliceBlue,clrAliceBlue,false,clrAliceBlue,clrAliceBlue,false,24,false,mode,shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getSSMConf(int tf,int mode,int shift,int confBS=0)
  {
   int barsent = (confBS==0) ? MinBar : confBS;
//,EnableSSMZoneTouch,EnableZOE,EnableAbsorption,Ab_TF,Ab_BodySize,AbCandlePerct,EnableVolCheckEntry,VolPeriodEntry,VolThresholdEntryConf,EnableSSMChoppiness,SSM_CI_Period,SSM_CI_TriggerLevel,SSM_CI_TF1,"",SSM_InpDepth,SSM_InpDeviation,SSM_InpBackstep,SSM_zz_hl,Percentage1,Percentage2,SSM_ValueAboveBelow,LOGIC_B,"",BreachPercentage,ExtendPercentage,"",EnableVolumeZone,VolZone_NumberOfDays,VolZone_HFT,VolZone_LFT
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\SSM_FINAL_v4",barsent,cur_sigOPType,EnableZOEManConf,EnableChoppinessManConf,"",TotalCountCondConf,EnableVolumeZone,mode,shift);
//return iCustom(cur_symbol,tf,"Kishore Fredrick\\SSM_FINAL_v4",mode,shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getSSM(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   int barsent = (confBS==0) ? MinBar : confBS;
//EnableSSMZoneTouch,EnableZOE,EnableAbsorption,Ab_TF,Ab_BodySize,AbCandlePerct,EnableVolCheckEntry,VolPeriodEntry,VolThresholdEntry,EnableSSMChoppiness,SSM_CI_Period,SSM_CI_TriggerLevel,SSM_CI_TF1,"",SSM_InpDepth,SSM_InpDeviation,SSM_InpBackstep,SSM_zz_hl,Percentage1,Percentage2,SSM_ValueAboveBelow,LOGIC_B,"",BreachPercentage,ExtendPercentage,"",EnableVolumeZone,VolZone_NumberOfDays,VolZone_HFT,VolZone_LFT,
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\SSM_FINAL_v4",barsent,cur_sigOPType,EnableZOEMan,EnableChoppinessMan,"",TotalCountCond,EnableVolumeZone,mode,bs);

//return iCustom(cur_symbol,tf,"Kishore Fredrick\\SSM_FINAL_v4",mode,shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getSSMExit(int tf,int mode,int shift)
  {
//Getting SSM Exit value from the original SSM indicator with different settings to avoid file repetition
   int bs = (tf==Period()) ? iPlus : iBarShift(cur_symbol,tf,Time[shift])+1;
   int oppSig = (cur_sigOPType==OP_BUY) ? OP_SELL : (cur_sigOPType==OP_SELL) ? OP_BUY : 0;
//,EnableZoneTouchExit,EnableZOEExit,EnableAbsorptionExit,Ab_TF_Exit,Ab_BodySize_Exit,AbCandlePerct_Exit,EnableVolCheckExit,VolPeriod_Exit,VolThreshold_Exit,EnableSSMChoppiness,SSM_CI_Period,SSM_CI_TriggerLevel,SSM_CI_TF1,"",SSM_InpDepthExit,SSM_InpDeviationExit,SSM_InpBackstepExit,SSM_zz_hlExit,Percentage1Exit,Percentage2Exit,SSM_ValueAboveBelowExit,LOGIC_B,"",BreachPercentageExit,ExtendPercentageExit,"",EnableSSMVolumeZone,SSMVolZone_NumberOfDays,SSMVolZone_HFT,SSMVolZone_LFT
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\SSM_FINAL_v4",MinBar,oppSig,EnableZOEManExit,EnableChoppinessManExit,"",TotalCountCondExit,EnableVolumeZone,mode,bs);
//return iCustom(cur_symbol,tf,"Kishore Fredrick\\SSM_FINAL_v4",mode,shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Check_ADRWR(int otype,string wPattern,int shift)
  {
   bool res=false;
   if(EnableADR_AWR && !ReadAdrFromFile)
     {
      if(EnableNo_Today_Trade_Buffer)
        {
         //set true by default for if one bias false other will work
         bool notb_adr=true,notb_awr=true;
         if(EnableBias_ADR)
           {
            double notb = getADR_AWR(0,otype,1,shift);
            notb_adr = (notb==-1) ? false : true;
            res = notb_adr;
           }
         if(EnableBias_AWR)
           {
            double notb = getADR_AWR(0,otype,15,shift);
            notb_awr = (notb==-1) ? false : true;
            res = notb_awr;
           }
         if(EnableBias_ADR && EnableBias_AWR)
           {
            res = notb_adr && notb_awr;
           }
        }
      else
        {
         bool notb_adr=true,notb_awr=true;
         if(EnableBias_ADR)
           {
            int mode = (otype==OP_BUY) ? 3 : (otype==OP_SELL) ? 9 : 0;
            double notb = getADR_AWR(0,otype,mode,shift);
            notb_adr = (otype==OP_BUY) ? (notb!=-1) : (otype==OP_SELL) ? (notb!=1) : true;
            res = notb_adr;
           }
         if(EnableBias_AWR)
           {
            int mode = (otype==OP_BUY) ? 16 : (otype==OP_SELL) ? 22 : 0;
            double notb = getADR_AWR(0,otype,mode,shift);
            notb_awr = (otype==OP_BUY) ? (notb!=-1) : (otype==OP_SELL) ? (notb!=1) : true;
            res = notb_awr;
           }
         if(EnableBias_ADR && EnableBias_AWR)
           {
            res = notb_adr && notb_awr;
           }
        }
     }
   else
     {
      res = true;
     }
   if(EnableADR_AWR && ReadAdrFromFile)
     {
      res=true;
      int today=0, buy=0, sell=0;
      if(GetAdrData(cur_symbol, today, buy, sell))
        {
         if(EnableNo_Today_Trade_Buffer && today!=0)
            return (false);
         if(EnableBias_ADR && otype==OP_BUY && buy!=0)
            return (false);
         if(EnableBias_ADR && otype==OP_SELL && sell!=0)
            return (false);
        }
     }
   return res;
  }
//+------------------------------------------------------------------+
bool GetAdrData(string symbol, int &today, int &buy, int &sell)
  {
   today=0;
   buy=0;
   sell=0;
   bool found=false;
   string stime=TimeToString(Time[0], TIME_MINUTES);
   StringReplace(stime, ":", "");
   string fileName=AdrFileName+"_"+cur_symbol+"_"+stime;

   message="GetSignal"+":"+fileName+":ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";

   bool res= GetSignal(message);
   string to_split=message;
   if(to_split!="" && to_split!="No Signal")
     {
      string sp[];
      StringSplit(to_split, StringGetCharacter(",", 0), sp);
      if(ArraySize(sp)>=4)
        {
         if(sp[0]==symbol)
           {
            today=(int)StringToInteger(sp[1]);
            buy=(int)StringToInteger(sp[2]);
            sell=(int)StringToInteger(sp[3]);
            found=true;
           }
        }


     }
   return (found);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Check_VolCount(int otype,string wPattern,int shift)
  {
   bool res=false;

   bool pcPattern = (wPattern=="165");
   double vpb = (EnableVolumeProof) ? getVolProof_Max(TouchHTF,otype,22,shift) : 0;


   if((EnableEntryCandle && EnableVolumeProof && !pcPattern) || (EnablePowerCandle && EnablePCVolumeProof && pcPattern))
     {
      //type 1 condition for entry candle and power candle
      if((EnableEntryCandle && !pcPattern) || (EnablePowerCandle && pcPattern))
        {
         double vpBuy = getVolProof(TouchHTF,otype,22,shift);
         double vpSell = getVolProof(TouchHTF,otype,23,shift);

         datetime val_logATime = (datetime)getVolProof(TouchHTF,otype,24,shift);
         datetime val_logBTime = (datetime)getVolProof(TouchHTF,otype,25,shift);

         if(ConsiderVolumeProofTiming)
           {
            res = (otype == OP_BUY) ? (val_logATime>=cur_entryTime && vpBuy!=EMPTY_VALUE) : (otype == OP_SELL) ? (val_logBTime>=cur_entryTime && vpSell!=EMPTY_VALUE) : false;
           }
         else
           {
            res = (otype == OP_BUY) ? (vpBuy!=EMPTY_VALUE) : (otype == OP_SELL) ? (vpSell!=EMPTY_VALUE) : false;
           }
         //Print("res="+res+" ecTypeTime="+ecTypeTime+" vpBuy="+vpBuy+" vpSell="+vpSell+" val_logATime="+val_logATime+" val_logBTime="+val_logBTime+" T="+Time[0]);
         is_volproofLocked = res;
         if(res && ecTypeTime!=Time[0])
           {
            ecTypeTime = Time[0];
            Print("Type1 Entry/Power Candle Confirmed on "+cur_symbol+" at "+TimeToStr(Time[0]));
           }
        }

      //type 2 condition for entry candle along with profit zone
      if((EnableEntryCandle && !pcPattern) && !res)
        {
         double vpBuy = getVolProof_Max(TouchHTF,otype,22,shift);
         double vpSell = getVolProof_Max(TouchHTF,otype,23,shift);

         datetime val_logATime = (datetime)getVolProof_Max(TouchHTF,otype,24,shift);
         datetime val_logBTime = (datetime)getVolProof_Max(TouchHTF,otype,25,shift);

         double bpz_touchdir = getProfitZone(PZTF,8,shift,confBarShift);
         double spz_touchdir = getProfitZone(PZTF,12,shift,confBarShift);

         if(ConsiderVolumeProofTiming)
           {
            res = (otype == OP_BUY) ? (bpz_touchdir==1 && val_logATime>=cur_entryTime && vpBuy!=EMPTY_VALUE) : (otype == OP_SELL) ? (spz_touchdir==-1 && val_logBTime>=cur_entryTime && vpSell!=EMPTY_VALUE) : false;
           }
         else
           {
            res = (otype == OP_BUY) ? (bpz_touchdir==1 && vpBuy!=EMPTY_VALUE) : (otype == OP_SELL) ? (spz_touchdir==-1 && vpSell!=EMPTY_VALUE) : false;
           }

         is_volproofLocked = res;
         if(res && ecTypeTime!=Time[0])
           {
            ecTypeTime = Time[0];
            Print("Type2 Entry Candle Confirmed on "+cur_symbol+" at "+TimeToStr(Time[0]));
           }
         //Print("res="+res+" wPattern="+wPattern+" vpBuy="+vpBuy+" vpSell="+vpSell+" val_logATime="+val_logATime+" val_logBTime="+val_logBTime+" bpz_touchdir="+bpz_touchdir+" spz_touchdir="+spz_touchdir+" shift="+Time[shift]+" T="+Time[0]);
        }

     }
   else
     {
      res = true;
      is_volproofLocked = false;//if vp false then this is not considered
     }

   if(EnableMarketShift)
     {
      double msDir = getMarketShift(TouchHTF,otype,2,shift);
      is_marketshiftLocked = (otype==OP_BUY && msDir!=EMPTY_VALUE && msDir==1) ? true : (otype==OP_SELL && msDir!=EMPTY_VALUE && msDir==-1) ? true : false;
      //Print("is_marketshiftLocked="+is_marketshiftLocked+" msDir="+msDir+" EnableMarketShiftConfMan="+EnableMarketShiftConfMan+" otype="+otype+" T="+Time[shift]);
     }

   string wght="";
   int volcc = CountConditions("VOL",is_volproofLocked,isvolconfInformed,is_marketshiftLocked,wght);

//IF mandatory condition is failed, then no trade is allowed
   if(EnableMarketShift && EnableMarketShiftConfMan && is_marketshiftLocked==false)
     {
      volcc = -1;
      Print("MarketShift Man");
     }

   return volcc;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Check_SHC(int otype,string wPattern,int shift,int ip, int &current_weightage, int &acceptance_weightage, string &weightage)
  {
   bool final_shc=false,shc_asian=false,shc_adr=false,shc_LGTrig1=false,shc_LGTrig2=false,shc_SSM1Trig1=false,shc_SSM1Trig2=false,shc_SSM2Trig1=false,shc_SSM2Trig2=false,shc_SSM3Trig1=false,shc_SSM3Trig2=false,shc_SSM4Trig1=false,shc_SSM4Trig2=false,shc_SSM5Trig1=false,shc_SSM5Trig2=false,shc_mshift=false;
   current_weightage=0;
   acceptance_weightage=0;
   weightage="";


   if(EnableSHC_Asian)
     {
      asian_dir = getAsianSession(Asian_TF,6,ip);
      shc_asian = (otype==OP_BUY && asian_dir==1) ? true : (otype==OP_SELL && asian_dir==-1) ? true : false;
     }
   if(EnableSHC_ADR)
     {
      //using opposite mode number for getting liquidity
      int mode = (otype==OP_BUY) ? 9 : (otype==OP_SELL) ? 3 : 0;
      double notb = getADR_AWR(0,SHOW_BOTH,mode,ip);
      shc_adr = (otype==OP_BUY) ? (notb == 1 && notb!=EMPTY_VALUE) : (otype==OP_SELL) ? (notb == -1 && notb!=EMPTY_VALUE) : false;
      //Print("notb="+notb+" mode="+mode+" notod="+getADR_AWR(0,SHOW_BOTH,1,ip)+" T="+Time[ip]);
     }
   if(EnableSHC_LiqGrabTrig1)
     {
      double btrig1 = getLiquidityGrab(LG_ETF,15,ip);
      double strig1 = getLiquidityGrab(LG_ETF,16,ip);
      shc_LGTrig1 = (otype == OP_BUY && btrig1!=EMPTY_VALUE) ? true : (otype==OP_SELL && strig1!=EMPTY_VALUE) ? true : false;
     }
   if(EnableSHC_LiqGrabTrig2)
     {
      double btrig2 = getLiquidityGrab(LG_ETF,3,ip);
      double strig2 = getLiquidityGrab(LG_ETF,4,ip);
      shc_LGTrig2 = (otype == OP_BUY && btrig2!=EMPTY_VALUE) ? true : (otype==OP_SELL && strig2!=EMPTY_VALUE) ? true : false;
      //Print("shc_LGTrig2="+shc_LGTrig2+" btrig2="+btrig2+" strig2="+strig2+" st2="+getLiquidityGrab(LG_ETF,16,ip)+"  T="+Time[ip]);
     }
   if(EnableSHC_SwingStopM1Trig1)
     {
      double btrig1 = getSwingStopM1(SS_M1_ETF,18,ip);
      double strig1 = getSwingStopM1(SS_M1_ETF,19,ip);
      shc_SSM1Trig1 = (otype == OP_BUY && btrig1!=EMPTY_VALUE) ? true : (otype==OP_SELL && strig1!=EMPTY_VALUE) ? true : false;
      // Print(shc_SSM1Trig1+" "+btrig1+" "+strig1);
     }
   if(EnableSHC_SwingStopM1Trig2)
     {
      double btrig2 = getSwingStopM1(SS_M1_ETF,3,ip);
      double strig2 = getSwingStopM1(SS_M1_ETF,4,ip);
      shc_SSM1Trig2 = (otype == OP_BUY && btrig2!=EMPTY_VALUE) ? true : (otype==OP_SELL && strig2!=EMPTY_VALUE) ? true : false;
      //Print("shc_SSM1Trig2="+shc_SSM1Trig2+" btrig2="+btrig2+" strig2="+strig2+" T="+Time[ip]);
     }
   if(EnableSHC_SwingStopM2Trig1)
     {
      //Print("hi");
      double btrig1 = getSwingStopM2(SS_M2_ETF,18,ip);
      double strig1 = getSwingStopM2(SS_M2_ETF,19,ip);
      shc_SSM2Trig1 = (otype == OP_BUY &&btrig1!=EMPTY_VALUE) ? true : (otype==OP_SELL && strig1!=EMPTY_VALUE) ? true : false;

     }
   if(EnableSHC_SwingStopM2Trig2)
     {
      //Print("hi1");
      double btrig2 = getSwingStopM2(SS_M2_ETF,3,ip);
      double strig2 = getSwingStopM2(SS_M2_ETF,4,ip);
      shc_SSM2Trig2 = (otype == OP_BUY && btrig2!=EMPTY_VALUE) ? true : (otype==OP_SELL && strig2!=EMPTY_VALUE) ? true : false;
      //Print("shc_SSM2Trig2="+shc_SSM2Trig2+" btrig2="+btrig2+" strig2="+strig2+" T="+Time[ip]);

     }
   if(EnableSHC_SwingStopM3Trig1)
     {
      // Print("hi");
      double btrig1 = getSwingStopM3(SS_M3_ETF,18,ip);
      double strig1 = getSwingStopM3(SS_M3_ETF,19,ip);
      shc_SSM3Trig1 = (otype == OP_BUY && btrig1!=EMPTY_VALUE) ? true : (otype==OP_SELL && strig1!=EMPTY_VALUE) ? true : false;
      // Print("21 "+shc_SSM2Trig1+" "+btrig1+" "+strig1);
     }
   if(EnableSHC_SwingStopM3Trig2)
     {
      // Print("hi1");
      double btrig2 = getSwingStopM3(SS_M3_ETF,3,ip);
      double strig2 = getSwingStopM3(SS_M3_ETF,4,ip);


      // shc_SSM3Trig2 = (otype == OP_BUY && btrig2!=EMPTY_VALUE) ? true : (otype==OP_SELL && strig2!=EMPTY_VALUE) ? true : false;
      shc_SSM3Trig2=(otype == OP_BUY && btrig2!=EMPTY_VALUE) ? true : (otype==OP_SELL && strig2!=EMPTY_VALUE) ? true : false;
      //shc_SSM3Trig2=vl7;
      //Print("shc_SSM2Trig2="+shc_SSM2Trig2+" btrig2="+btrig2+" strig2="+strig2+" T="+Time[ip]);
      //Print("22 "+shc_SSM3Trig2+" "+btrig2+" "+strig2+" "+otype+" "+vl7);
     }
   if(EnableSHC_SwingStopM4Trig1)
     {
      double btrig1 = getSwingStopM4(SS_M4_ETF,18,ip);
      double strig1 = getSwingStopM4(SS_M4_ETF,19,ip);
      shc_SSM4Trig1 = (otype == OP_BUY && btrig1!=EMPTY_VALUE) ? true : (otype==OP_SELL && strig1!=EMPTY_VALUE) ? true : false;
     }
   if(EnableSHC_SwingStopM4Trig2)
     {
      double btrig2 = getSwingStopM4(SS_M4_ETF,3,ip);
      double strig2 = getSwingStopM4(SS_M4_ETF,4,ip);
      shc_SSM4Trig2 = (otype == OP_BUY && btrig2!=EMPTY_VALUE) ? true : (otype==OP_SELL && strig2!=EMPTY_VALUE) ? true : false;
      //Print("shc_SSM2Trig2="+shc_SSM2Trig2+" btrig2="+btrig2+" strig2="+strig2+" T="+Time[ip]);
     }

   if(EnableSHC_SwingStopM5Trig1)
     {
      double btrig1 = getSwingStopM5(SS_M5_ETF,18,ip);
      double strig1 = getSwingStopM5(SS_M5_ETF,19,ip);
      shc_SSM5Trig1 = (otype == OP_BUY && btrig1!=EMPTY_VALUE) ? true : (otype==OP_SELL && strig1!=EMPTY_VALUE) ? true : false;
     }
   if(EnableSHC_SwingStopM5Trig2)
     {
      double btrig2 = getSwingStopM5(SS_M5_ETF,3,ip);
      double strig2 = getSwingStopM5(SS_M5_ETF,4,ip);
      shc_SSM5Trig2 = (otype == OP_BUY && btrig2!=EMPTY_VALUE) ? true : (otype==OP_SELL && strig2!=EMPTY_VALUE) ? true : false;
      //Print("shc_SSM2Trig2="+shc_SSM2Trig2+" btrig2="+btrig2+" strig2="+strig2+" T="+Time[ip]);
     }

   if(EnableSHC_MarketShift)
     {
      double msBDir = getMarketShift(0,SHOW_BOTH,3,iPlus);
      double msSDir = getMarketShift(0,SHOW_BOTH,4,iPlus);
      double msDir = (otype==OP_BUY && msBDir!=EMPTY_VALUE) ? 1 : (otype==OP_SELL && msSDir!=EMPTY_VALUE) ? -1 : 0;
      shc_mshift = (otype==OP_BUY && msBDir!=EMPTY_VALUE) ? true : (otype==OP_SELL && msSDir!=EMPTY_VALUE) ? true : false;
     }

   bool lgntb = false;
   if(LG_NoTradeBuffer)
     {
      double ntb = getLiquidityGrab(LG_ETF,17,ip);
      lgntb = (ntb == -1 && ntb!=EMPTY_VALUE) ? true : false;
     }

   int shccc = CountConditions("SHC",shc_asian,shc_adr,shc_LGTrig1,weightage,shc_LGTrig2,shc_SSM1Trig1,shc_SSM1Trig2,shc_SSM2Trig1,shc_SSM2Trig2,shc_SSM3Trig1,shc_SSM3Trig2,shc_SSM4Trig1,shc_SSM4Trig2,shc_mshift);

   final_shc = (shccc>=SHC_Count);
   final_shc = (lgntb) ? false : final_shc;
   current_weightage=shccc;
   acceptance_weightage=SHC_Count;
//Print("final_shc="+final_shc+" shccc="+shccc+" out of "+SHC_Count+" shc_asian="+shc_asian+", shc_adr="+shc_adr+", shc_LGTrig1="+shc_LGTrig1+", shc_LGTrig2="+shc_LGTrig2+" T="+Time[ip]);
   return final_shc;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetSpreadVal(string cursym,double &avgspread,double &maxspread)
  {
   double val = 0;

   if(Enable_CSVSpread)
     {
      string FileName = SpreadFileName+".csv";


      ResetLastError();
      int handle=FileOpen(FileName,FILE_CSV|FILE_READ,",");
      if(handle==INVALID_HANDLE)
        {
         Print("Error opening file on ",FileName," : ",GetLastError());
        }
      else
        {
         int row=0;
         spread_pair SpreadPairNames[];
         while(!FileIsEnding(handle))
           {
            int N = ArraySize(SpreadPairNames);

            ArrayResize(SpreadPairNames,N+1);
            SpreadPairNames[N].sym = FileReadString(handle);
            SpreadPairNames[N].spread_value = (double)FileReadString(handle);
            SpreadPairNames[N].max_spread = (double)FileReadString(handle);
            //Print("row="+row+" N="+N+" sym="+SpreadPairNames[N].sym+" sp="+SpreadPairNames[N].spread_value+" maxsp="+SpreadPairNames[N].max_spread);
            row++;
           }

         int S = ArraySize(SpreadPairNames);
         //Print("S="+S);
         for(int i=0; i<S; i++)
           {
            //Print("cursym="+cursym+" SpreadPairNames[i].sym="+SpreadPairNames[i].sym+" i="+i);
            if(cursym == SpreadPairNames[i].sym)
              {
               avgspread = (double)SpreadPairNames[i].spread_value;
               maxspread = (double)SpreadPairNames[i].max_spread;
               //Print("CSV Spread value assigned "+(string)val+"pip to "+cursym);
              }
           }
        }
      FileClose(handle);
     }
   else
     {
      avgspread = SymAvgSpreadValue;
      maxspread = SymAvgSpreadValue*2;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getMACConf(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==0) ? shift : iBarShift(cur_symbol,tf,Time[shift])+1;
   int barsent = (confBS==0) ? MinBar : confBS;
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\MACross","",MinBar,cur_sigOPType,EnableMACZigZagMan,EnableMACZOEMan,MAC_TotalCountCond,MAC_VolThresholdConf,"",EnableVolumeZone,VolZone_NumberOfDays,VolZone_HFT,VolZone_LFT,mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getMAC(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==0) ? shift : iBarShift(cur_symbol,tf,Time[shift])+1;
   int barsent = (confBS==0) ? MinBar : confBS;
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\MACross","",barsent,cur_sigOPType,EnableMACZigZagMan,EnableMACZOEMan,MAC_TotalCountCond,MAC_VolThresholdEntry,"",EnableVolumeZone,VolZone_NumberOfDays,VolZone_HFT,VolZone_LFT,mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getLiquidityMA(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift])+1;
   int barsent = (confBS==0) ? MinBar : confBS;
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\Liquidity-MA-Zones","",barsent,cur_sigOPType,EnableLiqMajMAMan,EnableLiqZigZagMan,EnableLiqZOEMan,Liq_TotalCountCond,Liq_VolThreshold,"",EnableVolumeZone,VolZone_NumberOfDays,VolZone_HFT,VolZone_LFT,mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getLiquidityGrab(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift])+1;
   int barsent = (confBS==0) ? MinBar : confBS;
//Print("lg bs="+bs+" tf="+tf+" mode="+mode+" T="+iTime(cur_symbol,tf,bs));
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\Liquidity-Grab","",barsent,cur_sigOPType,Start_Time,LG_ETF,LG_HTF,CandleMethod,LG_ConfirmationValidInMinutes,mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getSwingStopM1(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   int barsent = (confBS==0) ? MinBar : confBS;
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\Swing-Stops",EnableVolatileSwingFilteration,EnableSwingSpeedFilteration,NumberOfFiltersNeeded,"",barsent,cur_sigOPType,cur_SS_Startime,SS_M1_ETF,SS_M1_HTF,SS_M1_CandleMethod,SS_M1_Trig1ScanValidInMinutes,SS_M1_T1ConfirmationValidInMinutes,SS_M1_T2ConfirmationValidInMinutes,SS_M1_RefLineValidInMinutes,SS_M1_UseHL_LH_Ref,SS_M1_RSITF,SS_M1_RSITFE,SS_M1_ExtendPercentageRef,SS_M1_ExtendPercentageDummy,SS_M1_ExtendPercentageEntry,"M1",SS_M1_EnableMarketShift,SS_M1_MS_CountCondition,SS_M1_MS_PrevSwingMan,mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getSwingStopM2(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   int barsent = (confBS==0) ? MinBar : confBS;
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\Swing-Stops",EnableVolatileSwingFilteration,EnableSwingSpeedFilteration,NumberOfFiltersNeeded,"",barsent,cur_sigOPType,cur_SS_Startime,SS_M2_ETF,SS_M2_HTF,SS_M2_CandleMethod,SS_M2_Trig1ScanValidInMinutes,SS_M2_T1ConfirmationValidInMinutes,SS_M2_T2ConfirmationValidInMinutes,SS_M2_RefLineValidInMinutes,SS_M2_UseHL_LH_Ref,SS_M2_RSITF,SS_M2_RSITFE,SS_M2_ExtendPercentageRef,SS_M2_ExtendPercentageDummy,SS_M2_ExtendPercentageEntry,"M2",SS_M2_EnableMarketShift,SS_M2_MS_CountCondition,SS_M2_MS_PrevSwingMan,mode,bs);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getSwingStopM3(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   int barsent = (confBS==0) ? MinBar : confBS;
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\Swing-Stops",EnableVolatileSwingFilteration,EnableSwingSpeedFilteration,NumberOfFiltersNeeded,"",barsent,cur_sigOPType,cur_SS_Startime,SS_M3_ETF,SS_M3_HTF,SS_M3_CandleMethod,SS_M3_Trig1ScanValidInMinutes,SS_M3_T1ConfirmationValidInMinutes,SS_M3_T2ConfirmationValidInMinutes,SS_M3_RefLineValidInMinutes,SS_M3_UseHL_LH_Ref,SS_M3_RSITF,SS_M1_RSITFE,SS_M3_ExtendPercentageRef,SS_M3_ExtendPercentageDummy,SS_M3_ExtendPercentageEntry,"M3",SS_M3_EnableMarketShift,SS_M3_MS_CountCondition,SS_M3_MS_PrevSwingMan,mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getSwingStopM4(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   int barsent = (confBS==0) ? MinBar : confBS;
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\Swing-Stops",EnableVolatileSwingFilteration,EnableSwingSpeedFilteration,NumberOfFiltersNeeded,"",barsent,cur_sigOPType,cur_SS_Startime,SS_M4_ETF,SS_M4_HTF,SS_M4_CandleMethod,SS_M4_Trig1ScanValidInMinutes,SS_M4_T1ConfirmationValidInMinutes,SS_M4_T2ConfirmationValidInMinutes,SS_M4_RefLineValidInMinutes,SS_M4_UseHL_LH_Ref,SS_M4_RSITF,SS_M4_RSITFE,SS_M4_ExtendPercentageRef,SS_M4_ExtendPercentageDummy,SS_M4_ExtendPercentageEntry,"M4",SS_M4_EnableMarketShift,SS_M4_MS_CountCondition,SS_M4_MS_PrevSwingMan,mode,bs);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getSwingStopM5(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   int barsent = (confBS==0) ? MinBar : confBS;
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\Swing-Stops",EnableVolatileSwingFilteration,EnableSwingSpeedFilteration,NumberOfFiltersNeeded,"",barsent,cur_sigOPType,cur_SS_Startime,SS_M5_ETF,SS_M5_HTF,SS_M5_CandleMethod,SS_M5_Trig1ScanValidInMinutes,SS_M5_T1ConfirmationValidInMinutes,SS_M5_T2ConfirmationValidInMinutes,SS_M5_RefLineValidInMinutes,SS_M5_UseHL_LH_Ref,SS_M5_RSITF,SS_M5_RSITFE,SS_M5_ExtendPercentageRef,SS_M5_ExtendPercentageDummy,SS_M5_ExtendPercentageEntry,"M5",SS_M5_EnableMarketShift,SS_M5_MS_CountCondition,SS_M5_MS_PrevSwingMan,mode,bs);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getReversalMA(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift])+1;
   int barsent = (confBS==0) ? MinBar : confBS;
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\Reversal-MA-Zones","",barsent,cur_sigOPType,EnableRevZOEMan,RevMA_TotalCountCond,RevMA_VolThreshold,"",EnableVolumeZone,VolZone_NumberOfDays,VolZone_HFT,VolZone_LFT,mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getRSIDivg(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift])+1;
   int barsent = (confBS==0) ? MinBar : confBS;
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\RSI-Divergence-Zones","",barsent,cur_sigOPType,EnableRSIDZOEMan,Swing2_HH_LL,Swing3_HH_LL,"",EnableVolumeZone,VolZone_NumberOfDays,VolZone_HFT,VolZone_LFT,mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getProfitZone(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   int barsent = (confBS==0) ? MinBar : confBS;
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\ProfitZone",PZ_MA_Filter_LogicB,"",mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getSD(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift])+1;
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\SupplyDemandCandlePatterns-Indicator",false,cur_sigOPType,tf,CRC_NumOfDays,EnableVolumeZone,mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPA1(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   int barsent = (confBS==0) ? MinBar : confBS;
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\PriceActionPatterns-Indicator",barsent,cur_sigOPType,tf,mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPA2(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\PriceActionPatterns-Others-Indicator",mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getWedges(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift])+1;
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\Patterns_Breakout_SSM",true,MinBar,cur_sigOPType,tf,EnableVolumeZone,EnableVolumeZone,mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getVolZone(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\VolumeZones-Indicator",mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getVolZoneConf(int tf,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\VolumeZones-Indicator",false,ShowEpochZones,ShowPriceZones,cur_sigOPType,BreachLogicBasedOnEntries,BreachLogicBasedOnEntries_Percent,VolZoneConf_NumberOfDays,VolZoneConf_HFT,VolZoneConf_LFT,"",VolZone_RSI_Timeframe,VolZone_RSI_AppliedPrice,VolZone_RSI_Period,VolZone_UseRSIFilter,VolZone_RSI_BuyLevel,VolZone_RSI_SellLevel,VolZone_UseRSIFilter,VolZone_RSI_BuyLevel,VolZone_RSI_SellLevel,VolZone_UseRSIFilter,VolZone_RSI_BuyLevel,VolZone_RSI_SellLevel,mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getVolProof(int tf,int otype,int mode,int shift,int confBS=0)//,int etype=0
  {
//int totalmin = (etype==0) ? VP_EC_Type1_ConfirmationMin : VP_EC_Type2_ConfirmationMin;
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift])+1;
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\VolumeProof-Indicator",MA_Filter_LogicB,otype,VolProof_NumberOfDays,"",LogicA,Confirmation_LogicA,LogicB,Confirmation_LogicB,RSI_Type,"",VP_UseADRPipsFilter,VP_ADR_Period,VP_ADR_MinRatio_Percent,"",VP_EnableMA,VP_MA_CO_Period1,VP_MA_CO_Period2,VP_MA_CO_Price,VP_MA_CO_Method,VP_MA_TF1,MA_Filter_LogicA,VP_EC_Type1_ConfirmationMin,VP_EC_Type1_ConfirmationMin,mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getVolProof_Max(int tf,int otype,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift])+1;
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\VolumeProof-Indicator",MA_Filter_LogicB,otype,VolProof_NumberOfDays,"",LogicA,Confirmation_LogicA,LogicB,Confirmation_LogicB,RSI_Type,"",VP_UseADRPipsFilter,VP_ADR_Period,VP_ADR_MinRatio_Percent,"",VP_EnableMA,VP_MA_CO_Period1,VP_MA_CO_Period2,VP_MA_CO_Price,VP_MA_CO_Method,VP_MA_TF1,MA_Filter_LogicA,VP_EC_Type2_ConfirmationMin,VP_EC_Type2_ConfirmationMin,mode,bs);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getVolProofExit(int tf,int otype,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift+1 : iBarShift(cur_symbol,tf,Time[shift])+1;
   int oppSig = (otype==OP_BUY) ? OP_SELL : (otype==OP_SELL) ? OP_BUY : 0;
//Print("tf="+tf+" oty="+otype+" opp="+oppSig+" mode="+mode+" Tm="+iTime(Symbol(),tf,bs)+" T="+Time[shift]);
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\VolumeProof-Indicator",MA_Filter_LogicB,oppSig,VolProof_NumberOfDays,"",LogicAexit,Confirmation_LogicAexit,LogicBexit,Confirmation_LogicBexit,RSI_TypeExit,"",VPE_UseADRPipsFilter,VPE_ADR_Period,VPE_ADR_MinRatio_Percent,mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getMarketShift(int tf,int otype,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift])+1;
//VolProof_NumberOfDays,otype,MS_ConfirmationValidInMinutes,MS_TimingOn,MS_TimingOn_StartTime,MS_CountCondition,MS_PrevSwingMustBeHHorLL,
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\MarketShift-Indicator",otype,MS_CountCondition,EnableMarketShiftConfMan,MS_RSI_Timeframe1,MS_RSI_Timeframe2,true,Start_Time,EnableVolumeZone,mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getMarketShiftExit(int tf,int otype,int mode,int shift,int confBS=0)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\MarketShift-Indicator",otype,MS_CountConditionExit,EnableMarketShiftConfMan,MS_RSI_Timeframe1,MS_RSI_Timeframe2,mode,bs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getEntryCandle(int tf,int otype,int mode,int shift)
  {
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\EntryCandle",otype,EnableTrendDirectionFilter,CombineExplodeAndSDLiquidity,ExplodeAndSDLiquidityNeeded,ExplodeAndSDLiquidityMinBoth,EnableExplodeFilteration,EnableSDLiquidity,TDFSettings,M1AEnabled,M1BEnabled,M2AEnabled,M2BEnabled,M5PerfectDirectionEnabled,M15PerfectDirectionEnabled,mode,shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getEntryCandleM2(int tf,int otype,int mode,int shift)
  {
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\EntryCandle",otype,EnableTrendDirectionFilter,CombineExplodeAndSDLiquidity,ExplodeAndSDLiquidityNeeded,ExplodeAndSDLiquidityMinBoth,EnableExplodeFilteration,EnableSDLiquidity,TDFSettings,M1AEnabled,M1BEnabled,M2AEnabled,M2BEnabled,M5PerfectDirectionEnabled,M15PerfectDirectionEnabled,mode,shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPowerCandle(int tf,int otype,int mode,int shift)
  {
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\PowerCandle",PC_ZZ_TF1,PC_CI_TF1,PC_PZTF,PC_MA_Filter_LogicB,mode,shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getADR_AWR(int tf,int otype,int mode,int shift)
  {
//minbar issue so 5000 by default
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\ADR_AWR_Targets-Indicator",2000,ADR_Target_Percent,AWR_Target_Percent,ADR_NoTrade_Percent,AWR_NoTrade_Percent,ADR_NoTradeToday_Percent,AWR_NoTradeToday_Percent,mode,shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getCRC(int tf,int mode,int shift)
  {
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\Candle_Range_Check",CRC_NumOfDays,CRC_Multiplier,mode,shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getCRCMax(int tf,int mode,int shift)
  {
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\Candle_Range_Check",CRC_NumOfDays,CRC_MultiplierMax,mode,shift);
  }
//+------------------------------------------------------------------+
double ReadCRC(int tf,int period, double multiplier,int buffer,int shift)
  {
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\Candle_Range_Check",period,multiplier,buffer,shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getAsianSession(int tf,int mode,int shift)
  {
   int bs = (tf==Period()) ? shift : iBarShift(cur_symbol,tf,Time[shift]);
   return iCustom(cur_symbol,tf,"Kishore Fredrick\\Asian Session",EnableVolumeZone,EnableOneDir,mode,bs);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool getRangeBuy(string symbol,int shift, datetime &zoneTime)
  {
   bool valid=false;
   zoneTime=0;
   int bs = (RangeIndicatorTimeFrame==Period()) ? shift : iBarShift(symbol,RangeIndicatorTimeFrame,Time[shift]);
   double vl= iCustom(cur_symbol,RangeIndicatorTimeFrame,"Kishore Fredrick\\Range Indicator",MWN1,dir1,SwingMinTrend1,SwingMinShift1,CVBTF1,CVBMS1,ZoneValidityBars1,MaxConfirmationArrow1,RSITimeFrame1,EnableCRC11,"01:00",PERIOD_CURRENT,"",false,288,24,TrendReversalZone,EnableTrendReversalZone,SwingMinReversal,SwingMaxBars,ValidateBothSwings,CVBTR,MidSwing_HH_LL,31,bs);
   double v2= iCustom(cur_symbol,RangeIndicatorTimeFrame,"Kishore Fredrick\\Range Indicator",MWN1,dir1,SwingMinTrend1,SwingMinShift1,CVBTF1,CVBMS1,ZoneValidityBars1,MaxConfirmationArrow1,RSITimeFrame1,EnableCRC11,"01:00",PERIOD_CURRENT,"",false,288,24,TrendReversalZone,EnableTrendReversalZone,SwingMinReversal,SwingMaxBars,ValidateBothSwings,CVBTR,MidSwing_HH_LL,46,bs);
   if(vl==1.0)
     {
      valid=true;
      if(v2==EMPTY_VALUE)
         zoneTime=Time[shift];
      else
         zoneTime=(datetime)v2;
     }
   return valid;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool getRangeSell(string symbol,int shift, datetime &zoneTime)
  {
   bool valid=false;
   int bs = (RangeIndicatorTimeFrame==Period()) ? shift : iBarShift(symbol,RangeIndicatorTimeFrame,Time[shift]);
   double vl= iCustom(cur_symbol,RangeIndicatorTimeFrame,"Kishore Fredrick\\Range Indicator",MWN1,dir1,SwingMinTrend1,SwingMinShift1,CVBTF1,CVBMS1,ZoneValidityBars1,MaxConfirmationArrow1,RSITimeFrame1,EnableCRC11,"01:00",PERIOD_CURRENT,"",false,288,24,TrendReversalZone,EnableTrendReversalZone,SwingMinReversal,SwingMaxBars,ValidateBothSwings,CVBTR,MidSwing_HH_LL,32,bs);
   double v2= iCustom(cur_symbol,RangeIndicatorTimeFrame,"Kishore Fredrick\\Range Indicator",MWN1,dir1,SwingMinTrend1,SwingMinShift1,CVBTF1,CVBMS1,ZoneValidityBars1,MaxConfirmationArrow1,RSITimeFrame1,EnableCRC11,"01:00",PERIOD_CURRENT,"",false,288,24,TrendReversalZone,EnableTrendReversalZone,SwingMinReversal,SwingMaxBars,ValidateBothSwings,CVBTR,MidSwing_HH_LL,47,bs);
   if(vl==1.0)
     {
      valid=true;
      if(v2==EMPTY_VALUE)
         zoneTime=Time[shift];
      else
         zoneTime=(datetime)v2;
     }
   return valid;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getZoneTime(string symbol,int shift)
  {
   int index=0;
   int i=0;
   while(i<200)
     {
      int bs = (RangeIndicatorTimeFrame==Period()) ? shift : iBarShift(symbol,RangeIndicatorTimeFrame,Time[shift]);
      double vl= iCustom(cur_symbol,RangeIndicatorTimeFrame,"Kishore Fredrick\\Range Indicator",MWN1,dir1,SwingMinTrend1,SwingMinShift1,CVBTF1,CVBMS1,ZoneValidityBars1,MaxConfirmationArrow1,RSITimeFrame1,EnableCRC11,0,bs);
      if(vl!=EMPTY_VALUE)
        {
         index=i;
         break;
        }

      double vl2= iCustom(cur_symbol,RangeIndicatorTimeFrame,"Kishore Fredrick\\Range Indicator",MWN1,dir1,SwingMinTrend1,SwingMinShift1,CVBTF1,CVBMS1,ZoneValidityBars1,MaxConfirmationArrow1,RSITimeFrame1,EnableCRC11,2,bs);
      if(vl2!=EMPTY_VALUE)
        {
         index=i;
         break;
        }

      double vl3= iCustom(cur_symbol,RangeIndicatorTimeFrame,"Kishore Fredrick\\Range Indicator",MWN1,dir1,SwingMinTrend1,SwingMinShift1,CVBTF1,CVBMS1,ZoneValidityBars1,MaxConfirmationArrow1,RSITimeFrame1,EnableCRC11,3,bs);
      if(vl3!=EMPTY_VALUE)
        {
         index=i;
         break;
        }

      i++;
     }

   return index;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PriceToPip(string symbol)
  {

   string         pipFactor[]  = {"BTCUSD","ETHUSD","JPY","XAG","SILVER","BRENT","WTI","XAU","GOLD","SP500","S&P","UK100","WS30","DAX30","DJ30","NAS100","CAC400","Index"};
   double         pipFactors[] = { 10,10,100,  100,  100,     100,    100,  10,   10,    10,     10,   1,      1,     1,      1,     1,       1, 1};

   for(int i=ArraySize(pipFactor)-1; i>=0; i--)
      if(StringFind(symbol,pipFactor[i],0)!=-1)
         return (pipFactors[i]);
   return(10000);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetAdr(string symbol, int tf, int bar)
  {
   int dbar=iBarShift(symbol, PERIOD_D1, iTime(symbol, tf, bar))+1;
   double atr=iATR(symbol, PERIOD_D1, ADR_Period, dbar);
   return (atr*PriceToPip(symbol));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetAdrPoints(string symbol, int tf, int bar)
  {
   int dbar=iBarShift(symbol, PERIOD_D1, iTime(symbol, tf, bar))+1;
   double atr=iATR(symbol, PERIOD_D1, ADR_Period, dbar);
   return (atr);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndex1(string symbol)
  {
   int index1=0;
   if(symbol=="AUDCAD")
     {
      index1=0;
     }
   else
      if(symbol=="AUDCHF")
        {
         index1=1;
        }
      else
         if(symbol=="AUDJPY")
           {
            index1=2;
           }
         else
            if(symbol=="AUDNZD")
              {
               index1=3;
              }
            else
               if(symbol=="AUDUSD")
                 {
                  index1=4;
                 }
               else
                  if(symbol=="CADCHF")
                    {
                     index1=5;
                    }
                  else
                     if(symbol=="CADJPY")
                       {
                        index1=6;
                       }
                     else
                        if(symbol=="CHFJPY")
                          {
                           index1=7;
                          }
                        else
                           if(symbol=="EURAUD")
                             {
                              index1=8;
                             }
                           else
                              if(symbol=="EURCAD")
                                {
                                 index1=9;
                                }
                              else
                                 if(symbol=="EURCHF")
                                   {
                                    index1=10;
                                   }
                                 else
                                    if(symbol=="EURGBP")
                                      {
                                       index1=11;
                                      }
                                    else
                                       if(symbol=="EURJPY")
                                         {
                                          index1=12;
                                         }
                                       else
                                          if(symbol=="EURNZD")
                                            {
                                             index1=13;
                                            }
                                          else
                                             if(symbol=="EURUSD")
                                               {
                                                index1=14;
                                               }
                                             else
                                                if(symbol=="GBPAUD")
                                                  {
                                                   index1=15;
                                                  }
                                                else
                                                   if(symbol=="GBPCAD")
                                                     {
                                                      index1=16;
                                                     }
                                                   else
                                                      if(symbol=="GBPCHF")
                                                        {
                                                         index1=17;
                                                        }
                                                      else
                                                         if(symbol=="GBPJPY")
                                                           {
                                                            index1=18;
                                                           }
                                                         else
                                                            if(symbol=="GBPNZD")
                                                              {
                                                               index1=19;
                                                              }
                                                            else
                                                               if(symbol=="GBPUSD")
                                                                 {
                                                                  index1=20;
                                                                 }
                                                               else
                                                                  if(symbol=="NZDCAD")
                                                                    {
                                                                     index1=21;
                                                                    }
                                                                  else
                                                                     if(symbol=="NZDCHF")
                                                                       {
                                                                        index1=22;
                                                                       }
                                                                     else
                                                                        if(symbol=="NZDJPY")
                                                                          {
                                                                           index1=23;
                                                                          }
                                                                        else
                                                                           if(symbol=="NZDUSD")
                                                                             {
                                                                              index1=24;
                                                                             }
                                                                           else
                                                                              if(symbol=="USDCAD")
                                                                                {
                                                                                 index1=25;
                                                                                }
                                                                              else
                                                                                 if(symbol=="USDCHF")
                                                                                   {
                                                                                    index1=26;
                                                                                   }
                                                                                 else
                                                                                    if(symbol=="USDJPY")
                                                                                      {
                                                                                       index1=27;
                                                                                      }

   return index1;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Max Bar in Chart set to 5000|
//+------------------------------------------------------------------+

/*
--------------------
Entry Method & types
--------------------
101 - Zone MT4 buffer 4 with My candle Market Order
102 - Zone MT4 buffer 4 with My candle 50% Limit Order
103 - SSM Normal Limit order
104 - SSM Shift Conservative Limit order
105 - SSM Shift Aggressive Limit order
106 - SSM Normal Limit order 50%
107 - SSM Shift Conservative Limit order 50%
108 - SSM Shift Aggressive Limit order 50%
109 - SSM Touch with My Candle entry
110 - SSM Touch with My Candle entry 50% Limit Order
111 - ZoneMTF Sum with My Candle entry
112 - ZoneMTF Sum with My Candle entry 50% Limit Order
113 - MACrossver direct entry after ssm confirmation
114 - MACrossver 50% Limit Order
115 - MAC Conservative Limit Order
116 - MAC Agressive Limit Order
117 - MAC Conservative Limit Order 50%
118 - MAC Agressive Limit Order 50%
119 - MAC Touch entry
120 - MAC Touch entry Limit order 50%
----------------------------------------------------------------------------------------------------

VERSION HISTORY DOCUMENT
--------------------------
v2.05 - Final Working EA with MA Crossover Dynamic Entry
v2.30 - Added ZoneMTF and SSM Check
v2.31 - Organizing of Entries based on the list & only MyCandle entry and no indicators (RSI,Choppiness,MA)
v2.32 - Stoploss concept changed based on entry stoploss image
v2.33 - Stoploss changed in SSM Limit order
v2.34 - FF_News_Filter indicator added for checking news
v2.39 - SSM Exit Indicator Integrated
v2.43 - Manual Closing Time Added and reading SSM Exit from original indicator instead of SSM Exit indicator
v2.44 - Manual Entry and Exit added
v2.45 - All entry after SSM Confirmation and added 113 & 114 entry method
v2.46 - ZoneMTF new inputs added
v2.47 - ZoneMTF Direct 4 will be taken after SSM Confirmation and MyCandle
v2.48 - Screenshot separated for FileScanner and Individual pair
v2.49 - Confirmation added MAC & SSM with specific function
v2.50 - Confirmation minbar increased
v2.51 - Added EnableMACandle in inputs
v2.52 - MACandle logic checking in ZoneMTF Touch Entry 111 & 112
v2.53 - If trade hits tp next day, no trade on the same day
v2.54 - getMACandle function splitted for conf and entry for Volume
v2.55 - MAC Limit Order(115,116,117,118) & Touch Entry(119,120) has completed
v2.56 - SSM Limit Order replaced with PlaceZoneLimit function
v2.57 - Manual Time Exit bug fixed
v2.58 - Asian Session integrated in All entries
v2.59 - Asian Target and Trigger Implemented
v2.60 - Limit order issue solved by Adding Limit order Time
v2.61 - MAC Touch Entry like SSM is_confLocked added for 119,120
v2.62 - Candle entry filter removed countcond checking
v2.63 - Changed MACandle and getMACandle to EntryCandle and getEntryCandle
v2.64 - RejectSamePattern & AllowRiskFree and Negative Equity Exit
v2.65 - Bug Fixed
v2.66 - PlaceCandleEntry function and removed old logics
v2.67 - CandleEntryTime=Time[0] placed inside the function
v2.68 - Confirmation added LIQ & REV
v2.69 - ADR AWR Integrated
v2.70 - Commit
v2.71 - SSM,LiqMA,RevMA,MACross input changed
v2.72 - Risk from Equity/AccountBalance added
v2.73 - Integration of Volume Confirmation for entry filter
v2.74 - Bug Fixed
v2.75 - Volume Zone Confirmation input separate function & SSM Exit volume zone added
v2.76 - Volume Proof Entry & Exit condition added
v2.77 - Volume Proof Entry Timing Condition added
v2.78 - Volume Zone Confirmation with Overall Confirmation linked
v2.79 - Volume Zone Epoch Touch entry 157 & 158
v2.80 - Volume Proof Timing
v2.83 - RSI Divergence Confirmation, Limit Order(159,160,161,162) & Touch(163,164) added
v2.84 - Screenshot bug solved
v2.85 - RSI Divergence Swing3_HH_LL added
v2.86 - SetTarget Normalize to Digits
v2.87 - Many Inputs Hided
v2.88 - Volume Proof ADR added
v2.89 - Volume Count condition added
v2.90 - Wedges Limit Order TF added
v2.91 - Volume Proof MA filter added
v2.92 - VP MA Filter for LogicA & LogicB splitted
v2.93 - Profit Zone Touch Added
v2.94 - Profit Zone - Entry candle changed to Power Candle (165)
v2.95 - Inputs Changed
v2.96 - PC Volume Proof condition added
v2.97 - Pattern 157 missed and readded and VolCount issue solved
v2.98 - Volume Proof Checking issue with Power Candle solved
v2.99 - Entry Candle Type1,Type2 added in VolCount Condition
v3.00 - Wedges Limit Profit Zones checking
v3.01 - Bug Fixed in Volume Count condition
v3.02 - Market Shift condition added
v3.03 - Asian Session Confirmation added and Inputs aligned
v3.04 - Entry Candle inputs added
v3.05 - Market Shift Exit
v3.06 - Market Shift confirmation added and Aignment changed with Additional Checks
v3.07 - Entry Candle Method 1 & 2 added
v3.08 - MA Cross Confirmation added
v3.09 - Overall Confirmation Count added
v3.10 - Asian Session Confirmation buffer changed
v3.11 - Optimize Checked & Removed LastBarTime checking
v3.12 - Limit orders enabled
v3.13 - Bug Fixed in MACross iBarshift
v3.14 - EnableDoubleConf option added
v3.15 - SSMExit enabled
v3.16 - Liquidity Grab Confirmation Added
v3.17 - StopHunt Checkpoints count condition added
v3.18 - Bug Fixed and TF added for LiqGrab
v3.19 - Place Order Function added ip to know the current candle shift
v3.20 - SwingStop added in Stophunt checkpoints
v3.21 - prev_calc replaced with myPrevCalc
v3.22 - SwingStop T1 Scanner Buffer added
v3.23 - Average Spread and Multiplier added
v3.24 - Manual Equity Exit added
v3.25 - CSV Spread with MaxSpread condition added
v3.26 - MarketShift in SwingStop
v3.27 - SSM2Trig1 point added
v3.28 - RefLineValidInMinutes in SwingStop added
v3.29 - SHC_MarketShift 1pt condition added
v3.30 - AllowOppositeSignals for Same Symbol entry even maxrunning order allowed
*/

/*
https://docs.mql4.com/basis/function/events
For this, it is usually enough to return the value of the rates_total parameter, which contains the number of bars in the current function call. If since the last call of OnCalculate() price data has changed (a deeper history downloaded or history blanks filled), the value of the input parameter prev_calculated will be set to zero by the terminal.
*/
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//*To trade EA standalone without scanner, delete the delay paramaters in all the indicators

//+------------------------------------------------------------------+
