//+------------------------------------------------------------------+
//|                                              TradeManager.mqh   |
//|                          Copyright 2025, Ravan Trading Systems   |
//|                             https://www.mql5.com/en/users/ravan  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Ravan Trading Systems"
#property link      "https://www.mql5.com/en/users/ravan"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>

//+------------------------------------------------------------------+
//| Trade Manager class                                              |
//+------------------------------------------------------------------+
class CTradeManager
  {
private:
   CTrade            m_trade;
   CPositionInfo     m_posInfo;

   string            m_symbol;
   int               m_magicNumber;
   int               m_slippage;

   // Trailing stop settings
   bool              m_useTrailing;
   double            m_trailingDistance; // In points
   double            m_trailingStep;     // In points

   // Break-even settings
   bool              m_useBreakEven;
   double            m_breakEvenPips;    // Profit in points before moving SL to BE
   double            m_breakEvenOffset;  // Extra points above entry for BE SL

   // Partial close settings
   bool              m_usePartialClose;
   double            m_partialCloseTP1;  // TP1 distance in points
   double            m_partialCloseTP2;  // TP2 distance in points
   double            m_partialClosePct1; // % to close at TP1
   double            m_partialClosePct2; // % to close at TP2

   double            PointsToPrice(double points);

public:
                     CTradeManager(void);
                    ~CTradeManager(void);

   void              Init(string symbol,
                          int    magicNumber,
                          int    slippage         = 10,
                          bool   useTrailing      = true,
                          double trailingDist     = 300.0,
                          double trailingStep     = 50.0,
                          bool   useBreakEven     = true,
                          double breakEvenPips    = 200.0,
                          double breakEvenOffset  = 10.0,
                          bool   usePartialClose  = false,
                          double partialTP1       = 300.0,
                          double partialTP2       = 600.0,
                          double partialPct1      = 50.0,
                          double partialPct2      = 50.0);

   // Position opening
   bool              OpenBuy(double lots, double sl, double tp, string comment = "");
   bool              OpenSell(double lots, double sl, double tp, string comment = "");

   // Position management
   void              ManagePositions(void);
   void              ApplyTrailingStop(ulong ticket);
   void              ApplyBreakEven(ulong ticket);
   void              ApplyPartialClose(ulong ticket);

   // Close operations
   bool              ClosePosition(ulong ticket);
   void              CloseAllPositions(void);
   void              CloseAllBuys(void);
   void              CloseAllSells(void);

   // Modify position
   bool              ModifySLTP(ulong ticket, double newSL, double newTP);

   // Count positions
   int               CountPositions(ENUM_POSITION_TYPE type = -1);
   bool              HasOpenPosition(ENUM_POSITION_TYPE type = -1);

   CTrade*           GetTrade(void) { return &m_trade; }
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradeManager::CTradeManager(void)
  {
   m_useTrailing      = true;
   m_trailingDistance = 300.0;
   m_trailingStep     = 50.0;
   m_useBreakEven     = true;
   m_breakEvenPips    = 200.0;
   m_breakEvenOffset  = 10.0;
   m_usePartialClose  = false;
   m_partialCloseTP1  = 300.0;
   m_partialCloseTP2  = 600.0;
   m_partialClosePct1 = 50.0;
   m_partialClosePct2 = 50.0;
   m_magicNumber      = 0;
   m_slippage         = 10;
   m_symbol           = "";
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTradeManager::~CTradeManager(void) {}

//+------------------------------------------------------------------+
//| Initialize trade manager                                         |
//+------------------------------------------------------------------+
void CTradeManager::Init(string symbol,
                         int    magicNumber,
                         int    slippage,
                         bool   useTrailing,
                         double trailingDist,
                         double trailingStep,
                         bool   useBreakEven,
                         double breakEvenPips,
                         double breakEvenOffset,
                         bool   usePartialClose,
                         double partialTP1,
                         double partialTP2,
                         double partialPct1,
                         double partialPct2)
  {
   m_symbol           = symbol;
   m_magicNumber      = magicNumber;
   m_slippage         = slippage;
   m_useTrailing      = useTrailing;
   m_trailingDistance = trailingDist;
   m_trailingStep     = trailingStep;
   m_useBreakEven     = useBreakEven;
   m_breakEvenPips    = breakEvenPips;
   m_breakEvenOffset  = breakEvenOffset;
   m_usePartialClose  = usePartialClose;
   m_partialCloseTP1  = partialTP1;
   m_partialCloseTP2  = partialTP2;
   m_partialClosePct1 = partialPct1;
   m_partialClosePct2 = partialPct2;

   m_trade.SetExpertMagicNumber(magicNumber);
   m_trade.SetDeviationInPoints(slippage);
   m_trade.SetTypeFilling(ORDER_FILLING_IOC);

   Print("TradeManager: Initialized for ", symbol, " Magic=", magicNumber);
  }

//+------------------------------------------------------------------+
//| Convert points to price distance                                 |
//+------------------------------------------------------------------+
double CTradeManager::PointsToPrice(double points)
  {
   return points * SymbolInfoDouble(m_symbol, SYMBOL_POINT);
  }

//+------------------------------------------------------------------+
//| Open a BUY position                                              |
//+------------------------------------------------------------------+
bool CTradeManager::OpenBuy(double lots, double sl, double tp, string comment)
  {
   double ask    = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
   int    digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);

   sl = (sl > 0.0) ? NormalizeDouble(sl, digits) : 0.0;
   tp = (tp > 0.0) ? NormalizeDouble(tp, digits) : 0.0;

   bool result = m_trade.Buy(lots, m_symbol, ask, sl, tp, comment);
   if(!result)
     {
      Print("TradeManager: Buy failed. Error: ", m_trade.ResultRetcode(),
            " ", m_trade.ResultRetcodeDescription());
      return false;
     }
   Print("TradeManager: Buy opened. Ticket=", m_trade.ResultOrder(),
         " Lots=", lots, " SL=", sl, " TP=", tp);
   return true;
  }

//+------------------------------------------------------------------+
//| Open a SELL position                                             |
//+------------------------------------------------------------------+
bool CTradeManager::OpenSell(double lots, double sl, double tp, string comment)
  {
   double bid    = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   int    digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);

   sl = (sl > 0.0) ? NormalizeDouble(sl, digits) : 0.0;
   tp = (tp > 0.0) ? NormalizeDouble(tp, digits) : 0.0;

   bool result = m_trade.Sell(lots, m_symbol, bid, sl, tp, comment);
   if(!result)
     {
      Print("TradeManager: Sell failed. Error: ", m_trade.ResultRetcode(),
            " ", m_trade.ResultRetcodeDescription());
      return false;
     }
   Print("TradeManager: Sell opened. Ticket=", m_trade.ResultOrder(),
         " Lots=", lots, " SL=", sl, " TP=", tp);
   return true;
  }

//+------------------------------------------------------------------+
//| Manage all open positions                                        |
//+------------------------------------------------------------------+
void CTradeManager::ManagePositions(void)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;

      if(PositionGetString(POSITION_SYMBOL) != m_symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)  != m_magicNumber) continue;

      if(m_useBreakEven)    ApplyBreakEven(ticket);
      if(m_useTrailing)     ApplyTrailingStop(ticket);
      if(m_usePartialClose) ApplyPartialClose(ticket);
     }
  }

//+------------------------------------------------------------------+
//| Apply trailing stop to a position                                |
//+------------------------------------------------------------------+
void CTradeManager::ApplyTrailingStop(ulong ticket)
  {
   if(!m_posInfo.SelectByTicket(ticket)) return;

   ENUM_POSITION_TYPE posType  = m_posInfo.PositionType();
   double             openPrice = m_posInfo.PriceOpen();
   double             currentSL = m_posInfo.StopLoss();
   double             tp        = m_posInfo.TakeProfit();
   int                digits    = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
   double             trailDist = PointsToPrice(m_trailingDistance);
   double             trailStep = PointsToPrice(m_trailingStep);

   double newSL = 0.0;
   double bid   = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   double ask   = SymbolInfoDouble(m_symbol, SYMBOL_ASK);

   if(posType == POSITION_TYPE_BUY)
     {
      newSL = NormalizeDouble(bid - trailDist, digits);
      // Move SL only if the new level is higher than current SL by at least one step
      if(newSL > currentSL + trailStep)
        {
         ModifySLTP(ticket, newSL, tp);
        }
     }
   else if(posType == POSITION_TYPE_SELL)
     {
      newSL = NormalizeDouble(ask + trailDist, digits);
      // Move SL only if the new level is lower than current SL by at least one step
      if(currentSL == 0.0 || newSL < currentSL - trailStep)
        {
         ModifySLTP(ticket, newSL, tp);
        }
     }
  }

//+------------------------------------------------------------------+
//| Apply break-even stop                                            |
//+------------------------------------------------------------------+
void CTradeManager::ApplyBreakEven(ulong ticket)
  {
   if(!m_posInfo.SelectByTicket(ticket)) return;

   ENUM_POSITION_TYPE posType   = m_posInfo.PositionType();
   double             openPrice = m_posInfo.PriceOpen();
   double             currentSL = m_posInfo.StopLoss();
   double             tp        = m_posInfo.TakeProfit();
   int                digits    = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
   double             bePips    = PointsToPrice(m_breakEvenPips);
   double             beOffset  = PointsToPrice(m_breakEvenOffset);

   double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);

   if(posType == POSITION_TYPE_BUY)
     {
      double profitPoints = bid - openPrice;
      double newSL        = NormalizeDouble(openPrice + beOffset, digits);
      // If profit >= break-even threshold and SL is below entry
      if(profitPoints >= bePips && currentSL < openPrice)
        {
         ModifySLTP(ticket, newSL, tp);
         Print("TradeManager: Break-even applied for ticket ", ticket, " NewSL=", newSL);
        }
     }
   else if(posType == POSITION_TYPE_SELL)
     {
      double profitPoints = openPrice - ask;
      double newSL        = NormalizeDouble(openPrice + beOffset, digits);
      // Move SL to above entry once profit >= threshold and SL is still above entry (not yet at BE)
      if(profitPoints >= bePips && (currentSL == 0.0 || currentSL >= openPrice + beOffset * 2))
        {
         ModifySLTP(ticket, newSL, tp);
         Print("TradeManager: Break-even applied for ticket ", ticket, " NewSL=", newSL);
        }
     }
  }

//+------------------------------------------------------------------+
//| Apply partial close at TP levels                                 |
//+------------------------------------------------------------------+
void CTradeManager::ApplyPartialClose(ulong ticket)
  {
   if(!m_posInfo.SelectByTicket(ticket)) return;

   ENUM_POSITION_TYPE posType   = m_posInfo.PositionType();
   double             openPrice = m_posInfo.PriceOpen();
   double             lots      = m_posInfo.Volume();
   int                digits    = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
   double             tp1Dist   = PointsToPrice(m_partialCloseTP1);
   double             tp2Dist   = PointsToPrice(m_partialCloseTP2);

   double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);

   if(posType == POSITION_TYPE_BUY)
     {
      double profit = bid - openPrice;
      double minLot = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);

      if(profit >= tp2Dist && lots > minLot * 2)
        {
         double closeLots = NormalizeDouble(lots * m_partialClosePct2 / 100.0,
                                           (int)MathLog10(1.0 / SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP)));
         closeLots = MathMax(closeLots, minLot);
         if(m_trade.PositionClosePartial(ticket, closeLots))
            Print("TradeManager: Partial close at TP2. Ticket=", ticket, " Lots=", closeLots);
        }
      else if(profit >= tp1Dist && lots > minLot * 2)
        {
         double closeLots = NormalizeDouble(lots * m_partialClosePct1 / 100.0,
                                           (int)MathLog10(1.0 / SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP)));
         closeLots = MathMax(closeLots, minLot);
         if(m_trade.PositionClosePartial(ticket, closeLots))
            Print("TradeManager: Partial close at TP1. Ticket=", ticket, " Lots=", closeLots);
        }
     }
   else if(posType == POSITION_TYPE_SELL)
     {
      double profit = openPrice - ask;
      double minLot = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);

      if(profit >= tp2Dist && lots > minLot * 2)
        {
         double closeLots = NormalizeDouble(lots * m_partialClosePct2 / 100.0,
                                           (int)MathLog10(1.0 / SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP)));
         closeLots = MathMax(closeLots, minLot);
         if(m_trade.PositionClosePartial(ticket, closeLots))
            Print("TradeManager: Partial close at TP2. Ticket=", ticket, " Lots=", closeLots);
        }
      else if(profit >= tp1Dist && lots > minLot * 2)
        {
         double closeLots = NormalizeDouble(lots * m_partialClosePct1 / 100.0,
                                           (int)MathLog10(1.0 / SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP)));
         closeLots = MathMax(closeLots, minLot);
         if(m_trade.PositionClosePartial(ticket, closeLots))
            Print("TradeManager: Partial close at TP1. Ticket=", ticket, " Lots=", closeLots);
        }
     }
  }

//+------------------------------------------------------------------+
//| Close a specific position by ticket                              |
//+------------------------------------------------------------------+
bool CTradeManager::ClosePosition(ulong ticket)
  {
   bool result = m_trade.PositionClose(ticket, m_slippage);
   if(!result)
      Print("TradeManager: Close failed. Ticket=", ticket, " Error=", m_trade.ResultRetcode());
   return result;
  }

//+------------------------------------------------------------------+
//| Close all open positions for this symbol and magic               |
//+------------------------------------------------------------------+
void CTradeManager::CloseAllPositions(void)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != m_symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)  != m_magicNumber) continue;
      ClosePosition(ticket);
     }
  }

//+------------------------------------------------------------------+
//| Close all buy positions                                          |
//+------------------------------------------------------------------+
void CTradeManager::CloseAllBuys(void)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL)  != m_symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)  != m_magicNumber) continue;
      if(PositionGetInteger(POSITION_TYPE)   != POSITION_TYPE_BUY) continue;
      ClosePosition(ticket);
     }
  }

//+------------------------------------------------------------------+
//| Close all sell positions                                         |
//+------------------------------------------------------------------+
void CTradeManager::CloseAllSells(void)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL)  != m_symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)  != m_magicNumber) continue;
      if(PositionGetInteger(POSITION_TYPE)   != POSITION_TYPE_SELL) continue;
      ClosePosition(ticket);
     }
  }

//+------------------------------------------------------------------+
//| Modify SL and TP for a position                                  |
//+------------------------------------------------------------------+
bool CTradeManager::ModifySLTP(ulong ticket, double newSL, double newTP)
  {
   bool result = m_trade.PositionModify(ticket, newSL, newTP);
   if(!result)
      Print("TradeManager: ModifySLTP failed. Ticket=", ticket,
            " Error=", m_trade.ResultRetcode(), " ", m_trade.ResultRetcodeDescription());
   return result;
  }

//+------------------------------------------------------------------+
//| Count open positions for this symbol/magic                       |
//+------------------------------------------------------------------+
int CTradeManager::CountPositions(ENUM_POSITION_TYPE type)
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != m_symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)  != m_magicNumber) continue;
      if(type != -1 && PositionGetInteger(POSITION_TYPE) != type) continue;
      count++;
     }
   return count;
  }

//+------------------------------------------------------------------+
//| Check if there is at least one open position                     |
//+------------------------------------------------------------------+
bool CTradeManager::HasOpenPosition(ENUM_POSITION_TYPE type)
  {
   return CountPositions(type) > 0;
  }
//+------------------------------------------------------------------+
