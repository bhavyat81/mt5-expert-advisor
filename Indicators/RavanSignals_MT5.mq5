//+------------------------------------------------------------------+
//|                                        RavanSignals_MT5.mq5     |
//|                          Copyright 2025, Ravan Trading Systems   |
//|                             https://www.mql5.com/en/users/ravan  |
//+------------------------------------------------------------------+
#property copyright    "Copyright 2025, Ravan Trading Systems"
#property link         "https://www.mql5.com/en/users/ravan"
#property version      "1.00"
#property description  "Ravan Signals — Visual buy/sell signals with confluence dashboard"
#property description  "7 indicators: EMA, Supertrend, ADX, RSI, S/R, Candlestick, Volume"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2

// Buffer 0: Buy arrows
#property indicator_label1  "Buy Signal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

// Buffer 1: Sell arrows
#property indicator_label2  "Sell Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrTomato
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#include "..\Include\SignalEngine.mqh"
#include "..\Include\Dashboard.mqh"

//-------------------------------------------------------------------
//  INPUTS
//-------------------------------------------------------------------
sinput group "=== Signal Settings ==="
input int    InpSignalThreshold = 10;    // Confluence threshold (1-15)
input bool   InpUseEMA          = true;  // Enable EMA crossover
input bool   InpUseSupertrend   = true;  // Enable Supertrend
input bool   InpUseADX          = true;  // Enable ADX filter
input bool   InpUseRSI          = true;  // Enable RSI signal
input bool   InpUseSR           = true;  // Enable Support/Resistance
input bool   InpUseCandlestick  = true;  // Enable candlestick patterns
input bool   InpUseVolume       = true;  // Enable volume analysis

sinput group "=== ADX Settings ==="
input int    InpADXPeriod       = 14;    // ADX period
input double InpADXMinLevel     = 25.0;  // Minimum ADX level

sinput group "=== RSI Settings ==="
input int    InpRSIPeriod       = 14;    // RSI period
input double InpRSIOversold     = 30.0;  // RSI oversold threshold
input double InpRSIOverbought   = 70.0;  // RSI overbought threshold

sinput group "=== Supertrend Settings ==="
input int    InpSTPeriod        = 10;    // ATR period for Supertrend
input double InpSTMultiplier    = 3.0;   // ATR multiplier

sinput group "=== S/R Settings ==="
input int    InpSRLookback      = 50;    // Lookback bars for S/R
input double InpSRTolerance     = 0.5;   // ATR tolerance multiplier

sinput group "=== Visual Settings ==="
input color  InpBuyColor        = clrLimeGreen; // Buy arrow color
input color  InpSellColor       = clrTomato;    // Sell arrow color
input int    InpArrowSize       = 2;    // Arrow size (1-5)
input int    InpArrowBuyCode    = 233;  // Buy arrow code (Wingdings)
input int    InpArrowSellCode   = 234;  // Sell arrow code (Wingdings)
input bool   InpShowLabel       = true; // Show score label on arrows

sinput group "=== Alerts ==="
input bool   InpAlertPopup      = true;  // Enable pop-up alert
input bool   InpAlertPush       = false; // Enable push notification
input bool   InpAlertEmail      = false; // Enable email alert
input bool   InpAlertSound      = true;  // Enable sound alert
input string InpAlertSound_File = "alert.wav"; // Sound file name

sinput group "=== Dashboard ==="
input bool   InpShowDashboard   = true;  // Show info dashboard

//-------------------------------------------------------------------
//  BUFFERS & GLOBALS
//-------------------------------------------------------------------
double g_buyBuffer[];
double g_sellBuffer[];
double g_buyScore[];
double g_sellScore[];

CSignalEngine  g_signal;
CDashboard     g_dashboard;

datetime       g_lastAlertTime = 0;
SIGNAL_TYPE    g_lastSignal    = SIGNAL_NONE;
bool           g_initialized   = false;

//-------------------------------------------------------------------
//  OnInit
//-------------------------------------------------------------------
int OnInit()
  {
   // Set up arrow buffers
   SetIndexBuffer(0, g_buyBuffer,  INDICATOR_DATA);
   SetIndexBuffer(1, g_sellBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, g_buyScore,   INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, g_sellScore,  INDICATOR_CALCULATIONS);

   ArraySetAsSeries(g_buyBuffer,  true);
   ArraySetAsSeries(g_sellBuffer, true);
   ArraySetAsSeries(g_buyScore,   true);
   ArraySetAsSeries(g_sellScore,  true);

   // Configure arrow appearance
   PlotIndexSetInteger(0, PLOT_ARROW,       InpArrowBuyCode);
   PlotIndexSetInteger(1, PLOT_ARROW,       InpArrowSellCode);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 5);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -5);
   PlotIndexSetDouble(0,  PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1,  PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR,  InpBuyColor);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR,  InpSellColor);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH,  InpArrowSize);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH,  InpArrowSize);

   // Short name shown in Data Window
   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Ravan Signals [" + IntegerToString(InpSignalThreshold) + "]");

   // Init signal engine
   bool ok = g_signal.Init(
                _Symbol, _Period,
                InpSignalThreshold,
                InpADXPeriod, InpADXMinLevel,
                InpRSIPeriod, InpRSIOversold, InpRSIOverbought,
                InpSTPeriod,  InpSTMultiplier,
                InpSRLookback, InpSRTolerance,
                InpUseEMA, InpUseSupertrend, InpUseADX, InpUseRSI,
                InpUseSR, InpUseCandlestick, InpUseVolume);
   if(!ok)
     {
      Print("RavanSignals: Signal engine init failed!");
      return INIT_FAILED;
     }

   // Init dashboard
   if(InpShowDashboard)
      g_dashboard.Init("RavanSig_", 15, 30, 260);

   g_initialized = true;
   Print("RavanSignals: Initialized on ", _Symbol, " ", EnumToString(_Period));
   return INIT_SUCCEEDED;
  }

//-------------------------------------------------------------------
//  OnDeinit
//-------------------------------------------------------------------
void OnDeinit(const int reason)
  {
   g_signal.Deinit();
   g_dashboard.Remove();
   // Remove any score labels
   ObjectsDeleteAll(0, "RavanLbl_");
  }

//-------------------------------------------------------------------
//  OnCalculate
//-------------------------------------------------------------------
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
  {
   if(!g_initialized) return 0;
   if(rates_total < 250)  return 0;

   ArraySetAsSeries(time,  true);
   ArraySetAsSeries(high,  true);
   ArraySetAsSeries(low,   true);
   ArraySetAsSeries(close, true);

   // Determine how many bars to recalculate
   int limit = (prev_calculated == 0) ? rates_total - 250 : rates_total - prev_calculated + 1;
   limit = MathMin(limit, rates_total - 2);

   // Only recalculate on a new bar (shift 0 is current, shift 1 is completed)
   // For non-repainting: only place signals on completed bars (shift >= 1)

   for(int i = limit; i >= 1; i--)
     {
      g_buyBuffer[i]  = EMPTY_VALUE;
      g_sellBuffer[i] = EMPTY_VALUE;
      g_buyScore[i]   = 0;
      g_sellScore[i]  = 0;
     }

   // Calculate signal for the most recent completed bar only
   // (non-repainting: shift=1 is the last completed bar)
   SignalResult result = g_signal.Calculate();

   if(result.signal == SIGNAL_BUY)
     {
      g_buyBuffer[1]  = low[1] - (high[1] - low[1]) * 0.3;
      g_buyScore[1]   = result.score;
      if(InpShowLabel) DrawScoreLabel(time[1], g_buyBuffer[1], result.score, true);
     }
   else if(result.signal == SIGNAL_SELL)
     {
      g_sellBuffer[1] = high[1] + (high[1] - low[1]) * 0.3;
      g_sellScore[1]  = result.score;
      if(InpShowLabel) DrawScoreLabel(time[1], g_sellBuffer[1], result.score, false);
     }

   // Send alerts on new signal (only once per bar)
   datetime currentBarTime = time[1];
   if(result.signal != SIGNAL_NONE &&
      result.signal != g_lastSignal &&
      currentBarTime != g_lastAlertTime)
     {
      string dir  = (result.signal == SIGNAL_BUY) ? "BUY" : "SELL";
      string msg  = "Ravan Signal: " + dir + " on " + _Symbol +
                    " | Score: " + IntegerToString(result.score) + "/15" +
                    " | " + TimeToString(currentBarTime, TIME_DATE | TIME_MINUTES);

      if(InpAlertPopup)  Alert(msg);
      if(InpAlertPush)   SendNotification(msg);
      if(InpAlertEmail)  SendMail("Ravan Signal Alert", msg);
      if(InpAlertSound)  PlaySound(InpAlertSound_File);

      g_lastSignal    = result.signal;
      g_lastAlertTime = currentBarTime;
     }

   // Update dashboard (only on current bar calculation)
   if(InpShowDashboard)
      UpdateDashboard(result);

   return rates_total;
  }

//-------------------------------------------------------------------
//  Helper: Draw score label near arrow
//-------------------------------------------------------------------
void DrawScoreLabel(datetime barTime, double price, int score, bool isBuy)
  {
   string name  = "RavanLbl_" + IntegerToString((long)barTime);
   string text  = (isBuy ? "+" : "") + IntegerToString(score);
   color  clr   = isBuy ? InpBuyColor : InpSellColor;

   if(ObjectFind(0, name) >= 0)
      ObjectDelete(0, name);

   ObjectCreate(0, name, OBJ_TEXT, 0, barTime, price);
   ObjectSetString(0,  name, OBJPROP_TEXT,     text);
   ObjectSetInteger(0, name, OBJPROP_COLOR,    clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0,  name, OBJPROP_FONT,     "Consolas");
   ObjectSetInteger(0, name, OBJPROP_ANCHOR,   ANCHOR_BOTTOM);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

//-------------------------------------------------------------------
//  Helper: Parse scores and update dashboard
//-------------------------------------------------------------------
void UpdateDashboard(const SignalResult &result)
  {
   int scoreEMA = 0, scoreST = 0, scoreADX = 0, scoreRSI = 0;
   int scoreSR  = 0, scoreCandles = 0, scoreVol = 0;

   string parts[];
   int count = StringSplit(result.reasons, '|', parts);
   for(int i = 0; i < count; i++)
     {
      string kv[];
      if(StringSplit(parts[i], ':', kv) == 2)
        {
         string key = kv[0];
         int    val = (int)StringToInteger(kv[1]);
         if(key == "EMA")         scoreEMA     = val;
         else if(key == "ST")          scoreST      = val;
         else if(key == "ADX")         scoreADX     = val;
         else if(key == "RSI")         scoreRSI     = val;
         else if(key == "SR")          scoreSR      = val;
         else if(key == "Candle")      scoreCandles = val;
         else if(key == "Volume")      scoreVol     = val;
        }
     }

   g_dashboard.Update(
      result,
      g_signal.GetATR(),
      g_signal.GetSupport(),
      g_signal.GetResistance(),
      scoreEMA, scoreST, scoreADX, scoreRSI, scoreSR, scoreCandles, scoreVol);
  }
//+------------------------------------------------------------------+
