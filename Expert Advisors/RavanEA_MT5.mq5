//+------------------------------------------------------------------+
//|                                             RavanEA_MT5.mq5     |
//|                          Copyright 2025, Ravan Trading Systems   |
//|                             https://www.mql5.com/en/users/ravan  |
//+------------------------------------------------------------------+
#property copyright    "Copyright 2025, Ravan Trading Systems"
#property link         "https://www.mql5.com/en/users/ravan"
#property version      "1.00"
#property description  "Ravan EA — Multi-indicator confluence trading system for MT5"
#property description  "Signals: EMA, Supertrend, ADX, RSI, S/R, Candlestick, Volume"

#include <Trade\Trade.mqh>
#include "..\Include\SignalEngine.mqh"
#include "..\Include\RiskManager.mqh"
#include "..\Include\TradeManager.mqh"
#include "..\Include\Dashboard.mqh"

//-------------------------------------------------------------------
// ──────────────────────  INPUT PARAMETERS  ───────────────────────
//-------------------------------------------------------------------

// --- Trade Settings ---
sinput group "=== Trade Settings ==="
input double InpLotSize         = 0.01;   // Fixed lot size (if risk % = 0)
input int    InpMaxPositions    = 3;      // Maximum open positions
input int    InpMagicNumber     = 202501; // Magic number (unique EA ID)
input string InpTradeComment    = "RavanEA"; // Trade comment

// --- Signal Settings ---
sinput group "=== Signal Settings ==="
input ENUM_TIMEFRAMES InpSignalTF     = PERIOD_H1;  // Signal timeframe (higher TF)
input int    InpSignalThreshold = 10;   // Confluence threshold (1-15)
input bool   InpUseEMA          = true; // Enable EMA crossover signal
input bool   InpUseSupertrend   = true; // Enable Supertrend signal
input bool   InpUseADX          = true; // Enable ADX filter
input bool   InpUseRSI          = true; // Enable RSI signal
input bool   InpUseSR           = true; // Enable Support/Resistance signal
input bool   InpUseCandlestick  = true; // Enable candlestick patterns
input bool   InpUseVolume       = true; // Enable volume analysis

// --- EMA Settings ---
sinput group "=== EMA Settings ==="
// EMA periods are fixed: 9/21/50/200 as per signal engine design

// --- ADX Settings ---
sinput group "=== ADX Settings ==="
input int    InpADXPeriod       = 14;   // ADX period
input double InpADXMinLevel     = 25.0; // Minimum ADX level for trend confirmation

// --- RSI Settings ---
sinput group "=== RSI Settings ==="
input int    InpRSIPeriod       = 14;   // RSI period
input double InpRSIOversold     = 30.0; // RSI oversold threshold
input double InpRSIOverbought   = 70.0; // RSI overbought threshold

// --- Supertrend Settings ---
sinput group "=== Supertrend Settings ==="
input int    InpSTPeriod        = 10;   // ATR period for Supertrend
input double InpSTMultiplier    = 3.0;  // ATR multiplier for Supertrend

// --- Support/Resistance Settings ---
sinput group "=== Support/Resistance Settings ==="
input int    InpSRLookback      = 50;   // Bars to look back for S/R detection
input double InpSRTolerance     = 0.5;  // ATR tolerance multiplier for S/R zone

// --- Risk Management ---
sinput group "=== Risk Management ==="
input double InpRiskPercent     = 1.0;  // Risk % per trade (0 = use fixed lot)
input double InpMaxDrawdown     = 20.0; // Max drawdown % before halting
input double InpMaxDailyLoss    = 5.0;  // Max daily loss % before halting

// --- Stop Loss & Take Profit ---
sinput group "=== Stop Loss & Take Profit ==="
input double InpSLPoints        = 300.0; // Stop loss in points (0 = use ATR-based)
input double InpTPPoints        = 600.0; // Take profit in points (0 = use ATR-based)
input double InpRiskReward      = 2.0;   // Risk:Reward ratio (used if TP=0)

// --- Trailing Stop ---
sinput group "=== Trailing Stop ==="
input bool   InpUseTrailing     = true;  // Enable trailing stop
input double InpTrailingDist    = 300.0; // Trailing stop distance (points)
input double InpTrailingStep    = 50.0;  // Trailing stop step (points)

// --- Break-Even ---
sinput group "=== Break-Even ==="
input bool   InpUseBreakEven    = true;  // Enable break-even stop
input double InpBreakEvenPips   = 200.0; // Profit in points to trigger break-even
input double InpBreakEvenOffset = 10.0;  // Points above entry for break-even SL

// --- Partial Close ---
sinput group "=== Partial Close ==="
input bool   InpUsePartialClose = false; // Enable partial close
input double InpPartialTP1      = 300.0; // TP1 distance in points
input double InpPartialTP2      = 600.0; // TP2 distance in points
input double InpPartialPct1     = 50.0;  // % to close at TP1
input double InpPartialPct2     = 50.0;  // % to close at TP2

// --- Spread Filter ---
sinput group "=== Spread Filter ==="
input double InpMaxSpread       = 30.0;  // Maximum allowed spread in points

// --- Time Filter ---
sinput group "=== Time Filter ==="
input bool   InpUseTimeFilter   = false; // Enable trading hours filter
input int    InpTradeHourStart  = 8;     // Trading start hour (server time)
input int    InpTradeHourEnd    = 20;    // Trading end hour (server time)
input bool   InpSkipMonday      = false; // Skip Monday trading
input bool   InpSkipFriday      = false; // Skip Friday trading

// --- Dashboard ---
sinput group "=== Dashboard ==="
input bool   InpShowDashboard   = true;  // Show on-chart dashboard

//-------------------------------------------------------------------
// ──────────────────────  GLOBAL OBJECTS  ─────────────────────────
//-------------------------------------------------------------------
CSignalEngine  g_signal;
CRiskManager   g_riskMgr;
CTradeManager  g_tradeMgr;
CDashboard     g_dashboard;

SignalResult   g_lastResult;
SIGNAL_TYPE    g_lastSignal   = SIGNAL_NONE;
datetime       g_lastSignalTime = 0;
int            g_timerCount   = 0;

//-------------------------------------------------------------------
// ────────────────────────  OnInit  ───────────────────────────────
//-------------------------------------------------------------------
int OnInit()
  {
   Print("RavanEA v1.00 — Initializing on ", _Symbol);

   // Initialize signal engine
   bool ok = g_signal.Init(
                _Symbol,
                InpSignalTF,
                InpSignalThreshold,
                InpADXPeriod,
                InpADXMinLevel,
                InpRSIPeriod,
                InpRSIOversold,
                InpRSIOverbought,
                InpSTPeriod,
                InpSTMultiplier,
                InpSRLookback,
                InpSRTolerance,
                InpUseEMA,
                InpUseSupertrend,
                InpUseADX,
                InpUseRSI,
                InpUseSR,
                InpUseCandlestick,
                InpUseVolume);

   if(!ok)
     {
      Print("RavanEA: Signal engine init failed!");
      return INIT_FAILED;
     }

   // Initialize risk manager
   g_riskMgr.Init(
      _Symbol,
      InpRiskPercent,
      InpMaxDrawdown,
      InpMaxDailyLoss,
      InpMaxPositions);

   // Initialize trade manager
   g_tradeMgr.Init(
      _Symbol,
      InpMagicNumber,
      10,
      InpUseTrailing,
      InpTrailingDist,
      InpTrailingStep,
      InpUseBreakEven,
      InpBreakEvenPips,
      InpBreakEvenOffset,
      InpUsePartialClose,
      InpPartialTP1,
      InpPartialTP2,
      InpPartialPct1,
      InpPartialPct2);

   // Initialize dashboard
   if(InpShowDashboard)
      g_dashboard.Init("RavanDB_", 15, 30, 260);

   // Timer for periodic checks (every 60 seconds)
   EventSetTimer(60);

   Print("RavanEA: Ready. Magic=", InpMagicNumber, " Threshold=", InpSignalThreshold);
   return INIT_SUCCEEDED;
  }

//-------------------------------------------------------------------
// ────────────────────────  OnDeinit  ─────────────────────────────
//-------------------------------------------------------------------
void OnDeinit(const int reason)
  {
   EventKillTimer();
   g_signal.Deinit();
   g_dashboard.Remove();
   Print("RavanEA: Deinitialized. Reason=", reason);
  }

//-------------------------------------------------------------------
// ────────────────────────  OnTick  ───────────────────────────────
//-------------------------------------------------------------------
void OnTick()
  {
   // Manage existing positions on every tick
   g_tradeMgr.ManagePositions();
   g_riskMgr.UpdatePeakEquity();

   // Only evaluate new signals on bar open (new bar detection)
   static datetime lastBarTime = 0;
   datetime currentBarTime = iTime(_Symbol, InpSignalTF, 0);
   if(currentBarTime == lastBarTime) return;
   lastBarTime = currentBarTime;

   // --- Risk checks ---
   if(!g_riskMgr.CanOpenTrade(InpMagicNumber))
     {
      UpdateDashboard();
      return;
     }

   // --- Spread filter ---
   double spread = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) -
                    SymbolInfoDouble(_Symbol, SYMBOL_BID)) /
                   SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(spread > InpMaxSpread)
     {
      Print("RavanEA: Spread too high (", spread, " pts). Skipping.");
      UpdateDashboard();
      return;
     }

   // --- Time filter ---
   if(InpUseTimeFilter && !IsWithinTradingHours())
     {
      UpdateDashboard();
      return;
     }

   // --- Calculate signal ---
   SignalResult result = g_signal.Calculate();
   g_lastResult = result;

   // Update dashboard with all scores (they're encoded in the reasons string)
   UpdateDashboard();

   if(result.signal == SIGNAL_NONE) return;

   // Avoid duplicate signals on the same bar
   if(result.signal == g_lastSignal && currentBarTime == g_lastSignalTime) return;

   Print("RavanEA: Signal=", EnumToString((ENUM_ORDER_TYPE)(result.signal == SIGNAL_BUY ? 0 : 1)),
         " Score=", result.score, " Strength=", DoubleToString(result.strength, 2),
         " Reasons=", result.reasons);

   // --- Calculate SL/TP ---
   double sl = 0.0, tp = 0.0;
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int    digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   if(result.signal == SIGNAL_BUY)
     {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      sl = (InpSLPoints > 0) ? NormalizeDouble(ask - InpSLPoints * point, digits)
                              : result.suggestedSL;
      if(InpTPPoints > 0)
         tp = NormalizeDouble(ask + InpTPPoints * point, digits);
      else if(InpRiskReward > 0 && sl > 0)
         tp = NormalizeDouble(ask + (ask - sl) * InpRiskReward, digits);
      else
         tp = result.suggestedTP;
     }
   else if(result.signal == SIGNAL_SELL)
     {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      sl = (InpSLPoints > 0) ? NormalizeDouble(bid + InpSLPoints * point, digits)
                              : result.suggestedSL;
      if(InpTPPoints > 0)
         tp = NormalizeDouble(bid - InpTPPoints * point, digits);
      else if(InpRiskReward > 0 && sl > 0)
         tp = NormalizeDouble(bid - (sl - bid) * InpRiskReward, digits);
      else
         tp = result.suggestedTP;
     }

   // --- Calculate lot size ---
   double lots;
   if(InpRiskPercent > 0 && sl > 0)
     {
      double slPts = MathAbs(SymbolInfoDouble(_Symbol, SYMBOL_BID) - sl) / point;
      lots = g_riskMgr.CalcLotSize(slPts);
     }
   else
      lots = g_riskMgr.CalcLotSizeFixed(InpLotSize);

   if(lots <= 0)
     {
      Print("RavanEA: Invalid lot size calculated. Skipping.");
      return;
     }

   // --- Check margin ---
   ENUM_ORDER_TYPE orderType = (result.signal == SIGNAL_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   if(!g_riskMgr.IsMarginSufficient(lots, orderType))
     {
      Print("RavanEA: Insufficient margin. Skipping.");
      return;
     }

   // --- Place trade ---
   string comment = InpTradeComment + "|Score:" + IntegerToString(result.score);
   bool   placed  = false;

   if(result.signal == SIGNAL_BUY)
      placed = g_tradeMgr.OpenBuy(lots, sl, tp, comment);
   else if(result.signal == SIGNAL_SELL)
      placed = g_tradeMgr.OpenSell(lots, sl, tp, comment);

   if(placed)
     {
      g_lastSignal    = result.signal;
      g_lastSignalTime = currentBarTime;
     }
  }

//-------------------------------------------------------------------
// ────────────────────────  OnTimer  ──────────────────────────────
//-------------------------------------------------------------------
void OnTimer()
  {
   g_timerCount++;
   // Periodic risk checks
   if(g_riskMgr.IsDrawdownExceeded())
     {
      Print("RavanEA: Max drawdown reached — closing all positions!");
      g_tradeMgr.CloseAllPositions();
     }
   if(g_riskMgr.IsDailyLossExceeded())
     {
      Print("RavanEA: Daily loss limit reached — closing all positions!");
      g_tradeMgr.CloseAllPositions();
     }
  }

//-------------------------------------------------------------------
// ─────────────────────  Helper Functions  ────────────────────────
//-------------------------------------------------------------------

//+------------------------------------------------------------------+
//| Check if current time is within allowed trading hours            |
//+------------------------------------------------------------------+
bool IsWithinTradingHours()
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

   // Check day-of-week exclusions (0=Sun, 1=Mon, ..., 5=Fri, 6=Sat)
   if(InpSkipMonday && dt.day_of_week == 1) return false;
   if(InpSkipFriday && dt.day_of_week == 5) return false;
   if(dt.day_of_week == 0 || dt.day_of_week == 6) return false; // Skip weekend

   // Check hour range
   if(InpTradeHourStart < InpTradeHourEnd)
      return (dt.hour >= InpTradeHourStart && dt.hour < InpTradeHourEnd);
   else  // Overnight session
      return (dt.hour >= InpTradeHourStart || dt.hour < InpTradeHourEnd);
  }

//+------------------------------------------------------------------+
//| Parse individual scores from reasons string and update dashboard |
//+------------------------------------------------------------------+
void UpdateDashboard()
  {
   if(!InpShowDashboard) return;

   // Parse scores from reasons string (format: "EMA:3|ST:3|ADX:2|...")
   int scoreEMA = 0, scoreST = 0, scoreADX = 0, scoreRSI = 0;
   int scoreSR  = 0, scoreCandles = 0, scoreVol = 0;

   string reasons = g_lastResult.reasons;
   string parts[];
   int count = StringSplit(reasons, '|', parts);
   for(int i = 0; i < count; i++)
     {
      string kv[];
      if(StringSplit(parts[i], ':', kv) == 2)
        {
         string key = kv[0];
         int    val = (int)StringToInteger(kv[1]);
         if(key == "EMA")    scoreEMA     = val;
         else if(key == "ST")       scoreST      = val;
         else if(key == "ADX")      scoreADX     = val;
         else if(key == "RSI")      scoreRSI     = val;
         else if(key == "SR")       scoreSR      = val;
         else if(key == "Candle")   scoreCandles = val;
         else if(key == "Volume")   scoreVol     = val;
        }
     }

   g_dashboard.Update(
      g_lastResult,
      g_signal.GetATR(),
      g_signal.GetSupport(),
      g_signal.GetResistance(),
      scoreEMA,
      scoreST,
      scoreADX,
      scoreRSI,
      scoreSR,
      scoreCandles,
      scoreVol);
  }
//+------------------------------------------------------------------+
