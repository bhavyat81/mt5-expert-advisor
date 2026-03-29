//+------------------------------------------------------------------+
//|                                               RiskManager.mqh   |
//|                          Copyright 2025, Ravan Trading Systems   |
//|                             https://www.mql5.com/en/users/ravan  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Ravan Trading Systems"
#property link      "https://www.mql5.com/en/users/ravan"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Risk Manager class                                               |
//+------------------------------------------------------------------+
class CRiskManager
  {
private:
   double            m_riskPercent;        // Risk % per trade
   double            m_maxDrawdownPercent; // Max allowed drawdown %
   double            m_maxDailyLossPercent;// Max daily loss %
   int               m_maxPositions;       // Max open positions
   string            m_symbol;

   double            m_startBalanceDay;    // Balance at day start
   double            m_peakEquity;         // Highest equity seen (for equity trail)
   datetime          m_lastDayReset;       // Last time daily stats were reset

   void              CheckDayReset(void);

public:
                     CRiskManager(void);
                    ~CRiskManager(void);

   void              Init(string symbol,
                          double riskPercent        = 1.0,
                          double maxDrawdownPercent = 20.0,
                          double maxDailyLoss       = 5.0,
                          int    maxPositions       = 5);

   // Position sizing
   double            CalcLotSize(double slPoints);
   double            CalcLotSizeFixed(double fixedLot);
   double            NormalizeLot(double lot);

   // Risk checks
   bool              IsDrawdownExceeded(void);
   bool              IsDailyLossExceeded(void);
   bool              IsMaxPositionsReached(int magicNumber);
   bool              IsMarginSufficient(double lots, ENUM_ORDER_TYPE orderType);
   bool              CanOpenTrade(int magicNumber);

   // Equity trailing
   void              UpdatePeakEquity(void);
   double            GetPeakEquity(void)       { return m_peakEquity;          }
   double            GetCurrentDrawdown(void);
   double            GetDailyPnL(void);

   // Setters
   void              SetRiskPercent(double v)        { m_riskPercent        = v; }
   void              SetMaxDrawdown(double v)        { m_maxDrawdownPercent = v; }
   void              SetMaxDailyLoss(double v)       { m_maxDailyLossPercent = v; }
   void              SetMaxPositions(int v)          { m_maxPositions        = v; }
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CRiskManager::CRiskManager(void)
  {
   m_riskPercent         = 1.0;
   m_maxDrawdownPercent  = 20.0;
   m_maxDailyLossPercent = 5.0;
   m_maxPositions        = 5;
   m_startBalanceDay     = 0.0;
   m_peakEquity          = 0.0;
   m_lastDayReset        = 0;
   m_symbol              = "";
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CRiskManager::~CRiskManager(void) {}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
void CRiskManager::Init(string symbol,
                        double riskPercent,
                        double maxDrawdownPercent,
                        double maxDailyLoss,
                        int    maxPositions)
  {
   m_symbol              = symbol;
   m_riskPercent         = riskPercent;
   m_maxDrawdownPercent  = maxDrawdownPercent;
   m_maxDailyLossPercent = maxDailyLoss;
   m_maxPositions        = maxPositions;
   m_startBalanceDay     = AccountInfoDouble(ACCOUNT_BALANCE);
   m_peakEquity          = AccountInfoDouble(ACCOUNT_EQUITY);
   m_lastDayReset        = TimeCurrent();

   Print("RiskManager: Initialized. Risk=", riskPercent, "% MaxDD=", maxDrawdownPercent, "% MaxDaily=", maxDailyLoss, "%");
  }

//+------------------------------------------------------------------+
//| Reset daily stats at start of new trading day                    |
//+------------------------------------------------------------------+
void CRiskManager::CheckDayReset(void)
  {
   MqlDateTime current, last;
   TimeToStruct(TimeCurrent(),      current);
   TimeToStruct(m_lastDayReset,     last);

   if(current.day != last.day || current.mon != last.mon || current.year != last.year)
     {
      m_startBalanceDay = AccountInfoDouble(ACCOUNT_BALANCE);
      m_lastDayReset    = TimeCurrent();
      Print("RiskManager: Daily stats reset. Start balance: ", m_startBalanceDay);
     }
  }

//+------------------------------------------------------------------+
//| Calculate lot size based on risk % and SL distance               |
//+------------------------------------------------------------------+
double CRiskManager::CalcLotSize(double slPoints)
  {
   if(slPoints <= 0.0)
     {
      Print("RiskManager: Invalid SL points for lot calculation");
      return 0.0;
     }

   double balance    = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * m_riskPercent / 100.0;
   double tickValue  = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize   = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_SIZE);
   double point      = SymbolInfoDouble(m_symbol, SYMBOL_POINT);

   if(tickValue <= 0.0 || tickSize <= 0.0 || point <= 0.0)
     {
      Print("RiskManager: Invalid symbol info for lot calculation");
      return 0.0;
     }

   double slValue = (slPoints * point / tickSize) * tickValue;
   if(slValue <= 0.0) return 0.0;

   double lots = riskAmount / slValue;
   return NormalizeLot(lots);
  }

//+------------------------------------------------------------------+
//| Return fixed lot after normalization                             |
//+------------------------------------------------------------------+
double CRiskManager::CalcLotSizeFixed(double fixedLot)
  {
   return NormalizeLot(fixedLot);
  }

//+------------------------------------------------------------------+
//| Normalize lot to symbol requirements                             |
//+------------------------------------------------------------------+
double CRiskManager::NormalizeLot(double lot)
  {
   double minLot  = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);

   if(lotStep <= 0.0) lotStep = 0.01;

   lot = MathFloor(lot / lotStep) * lotStep;
   lot = MathMax(lot, minLot);
   lot = MathMin(lot, maxLot);

   return NormalizeDouble(lot, 2);
  }

//+------------------------------------------------------------------+
//| Check if max drawdown is exceeded                                |
//+------------------------------------------------------------------+
bool CRiskManager::IsDrawdownExceeded(void)
  {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);

   if(balance <= 0.0) return false;

   double drawdown = (balance - equity) / balance * 100.0;
   if(drawdown >= m_maxDrawdownPercent)
     {
      Print("RiskManager: Max drawdown exceeded! DD=", drawdown, "% Limit=", m_maxDrawdownPercent, "%");
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Check if daily loss limit is exceeded                            |
//+------------------------------------------------------------------+
bool CRiskManager::IsDailyLossExceeded(void)
  {
   CheckDayReset();

   double balance     = AccountInfoDouble(ACCOUNT_BALANCE);
   double dailyChange = balance - m_startBalanceDay;

   if(m_startBalanceDay <= 0.0) return false;

   double dailyLossPct = -dailyChange / m_startBalanceDay * 100.0;
   if(dailyLossPct >= m_maxDailyLossPercent)
     {
      Print("RiskManager: Daily loss limit exceeded! Loss=", dailyLossPct, "% Limit=", m_maxDailyLossPercent, "%");
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Check if max open positions is reached                           |
//+------------------------------------------------------------------+
bool CRiskManager::IsMaxPositionsReached(int magicNumber)
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
        {
         if(PositionGetString(POSITION_SYMBOL) == m_symbol &&
            PositionGetInteger(POSITION_MAGIC)  == magicNumber)
            count++;
        }
     }

   if(count >= m_maxPositions)
     {
      Print("RiskManager: Max positions reached (", count, "/", m_maxPositions, ")");
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Check if there is sufficient free margin                         |
//+------------------------------------------------------------------+
bool CRiskManager::IsMarginSufficient(double lots, ENUM_ORDER_TYPE orderType)
  {
   double marginRequired;
   double price = (orderType == ORDER_TYPE_BUY)
                  ? SymbolInfoDouble(m_symbol, SYMBOL_ASK)
                  : SymbolInfoDouble(m_symbol, SYMBOL_BID);

   if(!OrderCalcMargin(orderType, m_symbol, lots, price, marginRequired))
     {
      Print("RiskManager: OrderCalcMargin failed. Error: ", GetLastError());
      return false;
     }

   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(freeMargin < marginRequired * 1.2) // 20% buffer
     {
      Print("RiskManager: Insufficient free margin. Required=", marginRequired, " Free=", freeMargin);
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Master trade permission check                                    |
//+------------------------------------------------------------------+
bool CRiskManager::CanOpenTrade(int magicNumber)
  {
   if(IsDrawdownExceeded())        return false;
   if(IsDailyLossExceeded())       return false;
   if(IsMaxPositionsReached(magicNumber)) return false;
   return true;
  }

//+------------------------------------------------------------------+
//| Update peak equity tracker                                       |
//+------------------------------------------------------------------+
void CRiskManager::UpdatePeakEquity(void)
  {
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(equity > m_peakEquity)
      m_peakEquity = equity;
  }

//+------------------------------------------------------------------+
//| Get current drawdown from peak equity                            |
//+------------------------------------------------------------------+
double CRiskManager::GetCurrentDrawdown(void)
  {
   if(m_peakEquity <= 0.0) return 0.0;
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   return (m_peakEquity - equity) / m_peakEquity * 100.0;
  }

//+------------------------------------------------------------------+
//| Get today's P&L                                                  |
//+------------------------------------------------------------------+
double CRiskManager::GetDailyPnL(void)
  {
   CheckDayReset();
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   // Include open P&L
   double floatingPnL = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
         floatingPnL += PositionGetDouble(POSITION_PROFIT);
     }
   return (balance + floatingPnL) - m_startBalanceDay;
  }
//+------------------------------------------------------------------+
