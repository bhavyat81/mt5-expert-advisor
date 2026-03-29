//+------------------------------------------------------------------+
//|                                              SignalEngine.mqh    |
//|                          Copyright 2025, Ravan Trading Systems   |
//|                             https://www.mql5.com/en/users/ravan  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Ravan Trading Systems"
#property link      "https://www.mql5.com/en/users/ravan"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Signal type enumeration                                          |
//+------------------------------------------------------------------+
enum SIGNAL_TYPE
  {
   SIGNAL_BUY  = 1,   // Buy signal
   SIGNAL_SELL = -1,  // Sell signal
   SIGNAL_NONE = 0    // No signal
  };

//+------------------------------------------------------------------+
//| Signal result structure                                          |
//+------------------------------------------------------------------+
struct SignalResult
  {
   SIGNAL_TYPE signal;       // Signal direction
   int         score;        // Confluence score (-15 to +15)
   double      strength;     // Normalized strength (0.0 to 1.0)
   string      reasons;      // Human-readable reasons
   double      suggestedSL;  // Suggested stop loss price
   double      suggestedTP;  // Suggested take profit price
  };

//+------------------------------------------------------------------+
//| Signal Engine class                                              |
//+------------------------------------------------------------------+
class CSignalEngine
  {
private:
   // --- Indicator handles ---
   int               m_handleEMA9;
   int               m_handleEMA21;
   int               m_handleEMA50;
   int               m_handleEMA200;
   int               m_handleATR;
   int               m_handleADX;
   int               m_handleRSI;
   int               m_handleVolume;

   // --- Configuration ---
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   int               m_signalThreshold;

   // --- ADX settings ---
   int               m_adxPeriod;
   double            m_adxMinLevel;

   // --- RSI settings ---
   int               m_rsiPeriod;
   double            m_rsiOversold;
   double            m_rsiOverbought;

   // --- Supertrend settings ---
   int               m_supertrendPeriod;
   double            m_supertrendMultiplier;

   // --- S/R settings ---
   int               m_srLookback;
   double            m_srTolerance;

   // --- Enable/disable flags ---
   bool              m_useEMA;
   bool              m_useSupertrend;
   bool              m_useADX;
   bool              m_useRSI;
   bool              m_useSR;
   bool              m_useCandles;
   bool              m_useVolume;

   // --- Cached values ---
   double            m_atrValue;
   double            m_supportLevel;
   double            m_resistanceLevel;

   //--- Private methods ---
   int               ScoreEMA(void);
   int               ScoreSupertrend(void);
   int               ScoreADX(void);
   int               ScoreRSI(void);
   int               ScoreSR(void);
   int               ScoreCandlestick(void);
   int               ScoreVolume(void);

   double            CalcSupertrend(int shift);
   bool              IsBullishEngulfing(int shift);
   bool              IsBearishEngulfing(int shift);
   bool              IsPinBarBullish(int shift);
   bool              IsPinBarBearish(int shift);
   bool              IsDoji(int shift);
   bool              IsHammer(int shift);
   bool              IsShootingStar(int shift);
   void              FindSupportResistance(void);

public:
                     CSignalEngine(void);
                    ~CSignalEngine(void);

   bool              Init(string symbol,
                          ENUM_TIMEFRAMES timeframe,
                          int signalThreshold    = 10,
                          int adxPeriod          = 14,
                          double adxMinLevel     = 25.0,
                          int rsiPeriod          = 14,
                          double rsiOversold     = 30.0,
                          double rsiOverbought   = 70.0,
                          int supertrendPeriod   = 10,
                          double supertrendMult  = 3.0,
                          int srLookback         = 50,
                          double srTolerance     = 0.5,
                          bool useEMA            = true,
                          bool useSupertrend     = true,
                          bool useADX            = true,
                          bool useRSI            = true,
                          bool useSR             = true,
                          bool useCandles        = true,
                          bool useVolume         = true);

   void              Deinit(void);
   SignalResult      Calculate(void);

   double            GetATR(void)         { return m_atrValue;       }
   double            GetSupport(void)     { return m_supportLevel;   }
   double            GetResistance(void)  { return m_resistanceLevel;}
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalEngine::CSignalEngine(void)
  {
   m_handleEMA9         = INVALID_HANDLE;
   m_handleEMA21        = INVALID_HANDLE;
   m_handleEMA50        = INVALID_HANDLE;
   m_handleEMA200       = INVALID_HANDLE;
   m_handleATR          = INVALID_HANDLE;
   m_handleADX          = INVALID_HANDLE;
   m_handleRSI          = INVALID_HANDLE;
   m_handleVolume       = INVALID_HANDLE;
   m_atrValue           = 0.0;
   m_supportLevel       = 0.0;
   m_resistanceLevel    = 0.0;
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalEngine::~CSignalEngine(void)
  {
   Deinit();
  }

//+------------------------------------------------------------------+
//| Initialize indicator handles                                     |
//+------------------------------------------------------------------+
bool CSignalEngine::Init(string symbol,
                         ENUM_TIMEFRAMES timeframe,
                         int signalThreshold,
                         int adxPeriod,
                         double adxMinLevel,
                         int rsiPeriod,
                         double rsiOversold,
                         double rsiOverbought,
                         int supertrendPeriod,
                         double supertrendMult,
                         int srLookback,
                         double srTolerance,
                         bool useEMA,
                         bool useSupertrend,
                         bool useADX,
                         bool useRSI,
                         bool useSR,
                         bool useCandles,
                         bool useVolume)
  {
   m_symbol               = symbol;
   m_timeframe            = timeframe;
   m_signalThreshold      = signalThreshold;
   m_adxPeriod            = adxPeriod;
   m_adxMinLevel          = adxMinLevel;
   m_rsiPeriod            = rsiPeriod;
   m_rsiOversold          = rsiOversold;
   m_rsiOverbought        = rsiOverbought;
   m_supertrendPeriod     = supertrendPeriod;
   m_supertrendMultiplier = supertrendMult;
   m_srLookback           = srLookback;
   m_srTolerance          = srTolerance;
   m_useEMA               = useEMA;
   m_useSupertrend        = useSupertrend;
   m_useADX               = useADX;
   m_useRSI               = useRSI;
   m_useSR                = useSR;
   m_useCandles           = useCandles;
   m_useVolume            = useVolume;

   // Create EMA handles
   m_handleEMA9   = iMA(symbol, timeframe, 9,   0, MODE_EMA, PRICE_CLOSE);
   m_handleEMA21  = iMA(symbol, timeframe, 21,  0, MODE_EMA, PRICE_CLOSE);
   m_handleEMA50  = iMA(symbol, timeframe, 50,  0, MODE_EMA, PRICE_CLOSE);
   m_handleEMA200 = iMA(symbol, timeframe, 200, 0, MODE_EMA, PRICE_CLOSE);
   m_handleATR    = iATR(symbol, timeframe, supertrendPeriod);
   m_handleADX    = iADX(symbol, timeframe, adxPeriod);
   m_handleRSI    = iRSI(symbol, timeframe, rsiPeriod, PRICE_CLOSE);
   m_handleVolume = iVolumes(symbol, timeframe, VOLUME_TICK);

   if(m_handleEMA9   == INVALID_HANDLE ||
      m_handleEMA21  == INVALID_HANDLE ||
      m_handleEMA50  == INVALID_HANDLE ||
      m_handleEMA200 == INVALID_HANDLE ||
      m_handleATR    == INVALID_HANDLE ||
      m_handleADX    == INVALID_HANDLE ||
      m_handleRSI    == INVALID_HANDLE ||
      m_handleVolume == INVALID_HANDLE)
     {
      Print("SignalEngine: Failed to create indicator handles. Error: ", GetLastError());
      return false;
     }

   Print("SignalEngine: Initialized for ", symbol, " on ", EnumToString(timeframe));
   return true;
  }

//+------------------------------------------------------------------+
//| Release indicator handles                                        |
//+------------------------------------------------------------------+
void CSignalEngine::Deinit(void)
  {
   if(m_handleEMA9   != INVALID_HANDLE) { IndicatorRelease(m_handleEMA9);   m_handleEMA9   = INVALID_HANDLE; }
   if(m_handleEMA21  != INVALID_HANDLE) { IndicatorRelease(m_handleEMA21);  m_handleEMA21  = INVALID_HANDLE; }
   if(m_handleEMA50  != INVALID_HANDLE) { IndicatorRelease(m_handleEMA50);  m_handleEMA50  = INVALID_HANDLE; }
   if(m_handleEMA200 != INVALID_HANDLE) { IndicatorRelease(m_handleEMA200); m_handleEMA200 = INVALID_HANDLE; }
   if(m_handleATR    != INVALID_HANDLE) { IndicatorRelease(m_handleATR);    m_handleATR    = INVALID_HANDLE; }
   if(m_handleADX    != INVALID_HANDLE) { IndicatorRelease(m_handleADX);    m_handleADX    = INVALID_HANDLE; }
   if(m_handleRSI    != INVALID_HANDLE) { IndicatorRelease(m_handleRSI);    m_handleRSI    = INVALID_HANDLE; }
   if(m_handleVolume != INVALID_HANDLE) { IndicatorRelease(m_handleVolume); m_handleVolume = INVALID_HANDLE; }
  }

//+------------------------------------------------------------------+
//| Calculate Supertrend value at given shift                        |
//+------------------------------------------------------------------+
double CSignalEngine::CalcSupertrend(int shift)
  {
   // Supertrend = Median Price +/- (Multiplier * ATR)
   // We calculate a basic supertrend direction from ATR
   double atrBuf[];
   ArraySetAsSeries(atrBuf, true);
   if(CopyBuffer(m_handleATR, 0, shift, 3, atrBuf) < 3)
      return 0.0;

   double high1 = iHigh(m_symbol, m_timeframe, shift);
   double low1  = iLow(m_symbol,  m_timeframe, shift);
   double close = iClose(m_symbol, m_timeframe, shift);

   if(high1 == 0.0 || low1 == 0.0)
      return 0.0;

   double median    = (high1 + low1) / 2.0;
   double upperBand = median + m_supertrendMultiplier * atrBuf[1];
   double lowerBand = median - m_supertrendMultiplier * atrBuf[1];

   // Return positive if price above supertrend (bullish), negative if below
   if(close > upperBand) return lowerBand;  // Price above => trend up, return lower band
   if(close < lowerBand) return upperBand;  // Price below => trend down, return upper band
   return median;
  }

//+------------------------------------------------------------------+
//| Find support and resistance levels                               |
//+------------------------------------------------------------------+
void CSignalEngine::FindSupportResistance(void)
  {
   double highestHigh = -DBL_MAX;
   double lowestLow   = DBL_MAX;
   double recentHigh  = -DBL_MAX;
   double recentLow   = DBL_MAX;

   int lookback = MathMin(m_srLookback, iBars(m_symbol, m_timeframe) - 2);

   for(int i = 2; i <= lookback; i++)
     {
      double h = iHigh(m_symbol, m_timeframe, i);
      double l = iLow(m_symbol,  m_timeframe, i);

      // Swing high: bar[i] high is greater than both neighbors
      if(h > iHigh(m_symbol, m_timeframe, i - 1) &&
         h > iHigh(m_symbol, m_timeframe, i + 1))
        {
         if(h > highestHigh) highestHigh = h;
         if(i <= m_srLookback / 2 && h > recentHigh) recentHigh = h;
        }

      // Swing low: bar[i] low is less than both neighbors
      if(l < iLow(m_symbol, m_timeframe, i - 1) &&
         l < iLow(m_symbol, m_timeframe, i + 1))
        {
         if(l < lowestLow) lowestLow = l;
         if(i <= m_srLookback / 2 && l < recentLow) recentLow = l;
        }
     }

   m_resistanceLevel = (recentHigh > -DBL_MAX) ? recentHigh : highestHigh;
   m_supportLevel    = (recentLow  <  DBL_MAX) ? recentLow  : lowestLow;

   if(m_resistanceLevel == -DBL_MAX) m_resistanceLevel = 0.0;
   if(m_supportLevel    ==  DBL_MAX) m_supportLevel    = 0.0;
  }

//+------------------------------------------------------------------+
//| Score EMA Crossover (weight: 3)                                  |
//+------------------------------------------------------------------+
int CSignalEngine::ScoreEMA(void)
  {
   if(!m_useEMA) return 0;

   double ema9[], ema21[], ema50[], ema200[];
   ArraySetAsSeries(ema9,   true);
   ArraySetAsSeries(ema21,  true);
   ArraySetAsSeries(ema50,  true);
   ArraySetAsSeries(ema200, true);

   if(CopyBuffer(m_handleEMA9,   0, 1, 2, ema9)   < 2) return 0;
   if(CopyBuffer(m_handleEMA21,  0, 1, 2, ema21)  < 2) return 0;
   if(CopyBuffer(m_handleEMA50,  0, 1, 2, ema50)  < 2) return 0;
   if(CopyBuffer(m_handleEMA200, 0, 1, 1, ema200) < 1) return 0;

   double close = iClose(m_symbol, m_timeframe, 1);
   if(close == 0.0) return 0;

   // BUY: fast > slow crossover and price above EMA200
   bool emaBullish  = (ema9[0] > ema21[0]) && (ema21[0] > ema50[0]) && (close > ema200[0]);
   bool emaBearish  = (ema9[0] < ema21[0]) && (ema21[0] < ema50[0]) && (close < ema200[0]);
   // Check crossover on bar 1 vs bar 2
   bool crossedUp   = (ema9[0] > ema21[0]) && (ema9[1] <= ema21[1]);
   bool crossedDown = (ema9[0] < ema21[0]) && (ema9[1] >= ema21[1]);

   if(emaBullish && crossedUp)   return 3;
   if(emaBearish && crossedDown) return -3;
   if(emaBullish)                return 2;
   if(emaBearish)                return -2;
   return 0;
  }

//+------------------------------------------------------------------+
//| Score Supertrend (weight: 3)                                     |
//+------------------------------------------------------------------+
int CSignalEngine::ScoreSupertrend(void)
  {
   if(!m_useSupertrend) return 0;

   double atrBuf[];
   ArraySetAsSeries(atrBuf, true);
   if(CopyBuffer(m_handleATR, 0, 0, 5, atrBuf) < 5) return 0;

   m_atrValue = atrBuf[1]; // Store ATR for external use

   // Build supertrend bands for last 3 bars
   double scores = 0;
   int bullCount = 0, bearCount = 0;

   for(int shift = 1; shift <= 3; shift++)
     {
      double h     = iHigh(m_symbol,  m_timeframe, shift);
      double l     = iLow(m_symbol,   m_timeframe, shift);
      double c     = iClose(m_symbol, m_timeframe, shift);
      double atr   = atrBuf[shift];
      double med   = (h + l) / 2.0;
      double upper = med + m_supertrendMultiplier * atr;
      double lower = med - m_supertrendMultiplier * atr;

      if(c > lower) bullCount++;
      else if(c < upper) bearCount++;
     }

   if(bullCount >= 2) return 3;
   if(bearCount >= 2) return -3;
   return 0;
  }

//+------------------------------------------------------------------+
//| Score ADX (weight: 2)                                            |
//+------------------------------------------------------------------+
int CSignalEngine::ScoreADX(void)
  {
   if(!m_useADX) return 0;

   double adxMain[], diPlus[], diMinus[];
   ArraySetAsSeries(adxMain,  true);
   ArraySetAsSeries(diPlus,   true);
   ArraySetAsSeries(diMinus,  true);

   if(CopyBuffer(m_handleADX, MAIN_LINE,  1, 1, adxMain)  < 1) return 0;
   if(CopyBuffer(m_handleADX, PLUSDI_LINE, 1, 1, diPlus)  < 1) return 0;
   if(CopyBuffer(m_handleADX, MINUSDI_LINE,1, 1, diMinus) < 1) return 0;

   // Only score when ADX shows strong trend
   if(adxMain[0] < m_adxMinLevel) return 0;

   if(diPlus[0]  > diMinus[0]) return 2;
   if(diMinus[0] > diPlus[0])  return -2;
   return 0;
  }

//+------------------------------------------------------------------+
//| Score RSI (weight: 2)                                            |
//+------------------------------------------------------------------+
int CSignalEngine::ScoreRSI(void)
  {
   if(!m_useRSI) return 0;

   double rsi[];
   ArraySetAsSeries(rsi, true);
   if(CopyBuffer(m_handleRSI, 0, 1, 3, rsi) < 3) return 0;

   // BUY: RSI recovering from oversold (was below, now rising above threshold)
   bool wasOversold  = rsi[2] < m_rsiOversold;
   bool nowRising    = rsi[0] > rsi[1] && rsi[0] < 50.0;
   bool wasOverbought = rsi[2] > m_rsiOverbought;
   bool nowFalling   = rsi[0] < rsi[1] && rsi[0] > 50.0;

   if(wasOversold  && nowRising)  return 2;
   if(wasOverbought && nowFalling) return -2;

   // Mild signals
   if(rsi[0] < m_rsiOversold)  return 1;
   if(rsi[0] > m_rsiOverbought) return -1;
   return 0;
  }

//+------------------------------------------------------------------+
//| Score Support/Resistance (weight: 3)                             |
//+------------------------------------------------------------------+
int CSignalEngine::ScoreSR(void)
  {
   if(!m_useSR) return 0;

   FindSupportResistance();

   if(m_supportLevel == 0.0 && m_resistanceLevel == 0.0) return 0;

   double close     = iClose(m_symbol, m_timeframe, 1);
   double atr       = (m_atrValue > 0.0) ? m_atrValue : SymbolInfoDouble(m_symbol, SYMBOL_POINT) * 10;
   double tolerance = atr * m_srTolerance;

   if(close == 0.0) return 0;

   // Near support: potential buy
   if(m_supportLevel > 0.0 && MathAbs(close - m_supportLevel) <= tolerance)
      return 3;

   // Near resistance: potential sell
   if(m_resistanceLevel > 0.0 && MathAbs(close - m_resistanceLevel) <= tolerance)
      return -3;

   // Breakout above resistance
   if(m_resistanceLevel > 0.0 && close > m_resistanceLevel + tolerance)
      return 2;

   // Breakdown below support
   if(m_supportLevel > 0.0 && close < m_supportLevel - tolerance)
      return -2;

   return 0;
  }

//+------------------------------------------------------------------+
//| Candlestick pattern detection helpers                            |
//+------------------------------------------------------------------+
bool CSignalEngine::IsBullishEngulfing(int shift)
  {
   double open1  = iOpen(m_symbol,  m_timeframe, shift);
   double close1 = iClose(m_symbol, m_timeframe, shift);
   double open2  = iOpen(m_symbol,  m_timeframe, shift + 1);
   double close2 = iClose(m_symbol, m_timeframe, shift + 1);

   return (close2 < open2) &&             // Previous bar bearish
          (close1 > open1) &&             // Current bar bullish
          (open1  < close2) &&            // Engulfs previous
          (close1 > open2);
  }

bool CSignalEngine::IsBearishEngulfing(int shift)
  {
   double open1  = iOpen(m_symbol,  m_timeframe, shift);
   double close1 = iClose(m_symbol, m_timeframe, shift);
   double open2  = iOpen(m_symbol,  m_timeframe, shift + 1);
   double close2 = iClose(m_symbol, m_timeframe, shift + 1);

   return (close2 > open2) &&             // Previous bar bullish
          (close1 < open1) &&             // Current bar bearish
          (open1  > close2) &&            // Engulfs previous
          (close1 < open2);
  }

bool CSignalEngine::IsPinBarBullish(int shift)
  {
   double o = iOpen(m_symbol,  m_timeframe, shift);
   double h = iHigh(m_symbol,  m_timeframe, shift);
   double l = iLow(m_symbol,   m_timeframe, shift);
   double c = iClose(m_symbol, m_timeframe, shift);

   double body     = MathAbs(c - o);
   double lowerWick = MathMin(o, c) - l;
   double upperWick = h - MathMax(o, c);
   double range    = h - l;

   if(range == 0.0) return false;

   return (lowerWick >= 2.0 * body) && (upperWick <= body * 0.5);
  }

bool CSignalEngine::IsPinBarBearish(int shift)
  {
   double o = iOpen(m_symbol,  m_timeframe, shift);
   double h = iHigh(m_symbol,  m_timeframe, shift);
   double l = iLow(m_symbol,   m_timeframe, shift);
   double c = iClose(m_symbol, m_timeframe, shift);

   double body     = MathAbs(c - o);
   double upperWick = h - MathMax(o, c);
   double lowerWick = MathMin(o, c) - l;
   double range    = h - l;

   if(range == 0.0) return false;

   return (upperWick >= 2.0 * body) && (lowerWick <= body * 0.5);
  }

bool CSignalEngine::IsDoji(int shift)
  {
   double o = iOpen(m_symbol,  m_timeframe, shift);
   double h = iHigh(m_symbol,  m_timeframe, shift);
   double l = iLow(m_symbol,   m_timeframe, shift);
   double c = iClose(m_symbol, m_timeframe, shift);

   double body  = MathAbs(c - o);
   double range = h - l;

   if(range == 0.0) return false;
   return (body / range) < 0.1;
  }

bool CSignalEngine::IsHammer(int shift)
  {
   // Hammer: small body at top, long lower shadow (bullish reversal)
   double o = iOpen(m_symbol,  m_timeframe, shift);
   double h = iHigh(m_symbol,  m_timeframe, shift);
   double l = iLow(m_symbol,   m_timeframe, shift);
   double c = iClose(m_symbol, m_timeframe, shift);

   double body      = MathAbs(c - o);
   double range     = h - l;
   double lowerWick = MathMin(o, c) - l;
   double upperWick = h - MathMax(o, c);

   if(range == 0.0) return false;

   return (lowerWick >= 2.0 * body) &&
          (upperWick <= body) &&
          (body / range < 0.4);
  }

bool CSignalEngine::IsShootingStar(int shift)
  {
   // Shooting star: small body at bottom, long upper shadow (bearish reversal)
   double o = iOpen(m_symbol,  m_timeframe, shift);
   double h = iHigh(m_symbol,  m_timeframe, shift);
   double l = iLow(m_symbol,   m_timeframe, shift);
   double c = iClose(m_symbol, m_timeframe, shift);

   double body      = MathAbs(c - o);
   double range     = h - l;
   double upperWick = h - MathMax(o, c);
   double lowerWick = MathMin(o, c) - l;

   if(range == 0.0) return false;

   return (upperWick >= 2.0 * body) &&
          (lowerWick <= body) &&
          (body / range < 0.4);
  }

//+------------------------------------------------------------------+
//| Score Candlestick Patterns (weight: 1)                           |
//+------------------------------------------------------------------+
int CSignalEngine::ScoreCandlestick(void)
  {
   if(!m_useCandles) return 0;

   int shift = 1; // Completed bar

   if(IsBullishEngulfing(shift)) return 1;
   if(IsPinBarBullish(shift))    return 1;
   if(IsHammer(shift))           return 1;

   if(IsBearishEngulfing(shift)) return -1;
   if(IsPinBarBearish(shift))    return -1;
   if(IsShootingStar(shift))     return -1;

   if(IsDoji(shift))             return 0; // Neutral

   return 0;
  }

//+------------------------------------------------------------------+
//| Score Volume Analysis (weight: 1)                                |
//+------------------------------------------------------------------+
int CSignalEngine::ScoreVolume(void)
  {
   if(!m_useVolume) return 0;

   double volBuf[];
   ArraySetAsSeries(volBuf, true);
   int copied = CopyBuffer(m_handleVolume, 0, 1, 20, volBuf);
   if(copied < 5) return 0;

   // Calculate average volume
   double sumVol = 0.0;
   int    count  = MathMin(copied, 20);
   for(int i = 1; i < count; i++)
      sumVol += volBuf[i];

   double avgVol     = sumVol / (double)(count - 1);
   double currentVol = volBuf[0];

   if(avgVol <= 0.0) return 0;

   // Volume spike (>= 1.5x average confirms momentum)
   bool isSpike = (currentVol >= avgVol * 1.5);
   if(!isSpike) return 0;

   // Determine direction from bar close vs open
   double open  = iOpen(m_symbol,  m_timeframe, 1);
   double close = iClose(m_symbol, m_timeframe, 1);

   if(close > open)  return 1;  // Bullish volume spike
   if(close < open)  return -1; // Bearish volume spike
   return 0;
  }

//+------------------------------------------------------------------+
//| Main signal calculation                                          |
//+------------------------------------------------------------------+
SignalResult CSignalEngine::Calculate(void)
  {
   SignalResult result;
   result.signal     = SIGNAL_NONE;
   result.score      = 0;
   result.strength   = 0.0;
   result.reasons    = "";
   result.suggestedSL = 0.0;
   result.suggestedTP = 0.0;

   int scoreEMA      = ScoreEMA();
   int scoreST       = ScoreSupertrend();
   int scoreADX      = ScoreADX();
   int scoreRSI      = ScoreRSI();
   int scoreSR       = ScoreSR();
   int scoreCandles  = ScoreCandlestick();
   int scoreVol      = ScoreVolume();

   int totalScore = scoreEMA + scoreST + scoreADX + scoreRSI +
                    scoreSR  + scoreCandles + scoreVol;

   result.score    = totalScore;
   result.strength = (double)MathAbs(totalScore) / 15.0;

   // Build reasons string
   string sep = "";
   if(scoreEMA     != 0) { result.reasons += sep + "EMA:"     + IntegerToString(scoreEMA);     sep = "|"; }
   if(scoreST      != 0) { result.reasons += sep + "ST:"      + IntegerToString(scoreST);      sep = "|"; }
   if(scoreADX     != 0) { result.reasons += sep + "ADX:"     + IntegerToString(scoreADX);     sep = "|"; }
   if(scoreRSI     != 0) { result.reasons += sep + "RSI:"     + IntegerToString(scoreRSI);     sep = "|"; }
   if(scoreSR      != 0) { result.reasons += sep + "SR:"      + IntegerToString(scoreSR);      sep = "|"; }
   if(scoreCandles != 0) { result.reasons += sep + "Candle:"  + IntegerToString(scoreCandles); sep = "|"; }
   if(scoreVol     != 0) { result.reasons += sep + "Volume:"  + IntegerToString(scoreVol);     sep = "|"; }

   // Determine signal direction
   if(totalScore >= m_signalThreshold)
     {
      result.signal = SIGNAL_BUY;
      double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
      double atr = (m_atrValue > 0.0) ? m_atrValue : SymbolInfoDouble(m_symbol, SYMBOL_POINT) * 100;
      result.suggestedSL = ask - atr * 1.5;
      result.suggestedTP = ask + atr * 3.0;
     }
   else if(totalScore <= -m_signalThreshold)
     {
      result.signal = SIGNAL_SELL;
      double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
      double atr = (m_atrValue > 0.0) ? m_atrValue : SymbolInfoDouble(m_symbol, SYMBOL_POINT) * 100;
      result.suggestedSL = bid + atr * 1.5;
      result.suggestedTP = bid - atr * 3.0;
     }

   return result;
  }
//+------------------------------------------------------------------+
