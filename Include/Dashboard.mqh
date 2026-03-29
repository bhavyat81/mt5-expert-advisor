//+------------------------------------------------------------------+
//|                                                Dashboard.mqh    |
//|                          Copyright 2025, Ravan Trading Systems   |
//|                             https://www.mql5.com/en/users/ravan  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Ravan Trading Systems"
#property link      "https://www.mql5.com/en/users/ravan"
#property version   "1.00"
#property strict

#include "SignalEngine.mqh"

//+------------------------------------------------------------------+
//| Dashboard class — on-chart info panel                           |
//+------------------------------------------------------------------+
class CDashboard
  {
private:
   string            m_prefix;       // Object name prefix for cleanup
   int               m_x;           // Panel X position
   int               m_y;           // Panel Y position
   int               m_width;       // Panel width
   int               m_lineHeight;  // Height per text row
   bool              m_visible;     // Visibility toggle

   color             m_bgColor;
   color             m_borderColor;
   color             m_titleColor;
   color             m_buyColor;
   color             m_sellColor;
   color             m_neutralColor;
   color             m_textColor;

   int               m_fontSize;
   string            m_fontName;

   int               m_totalObjects;

   void              CreateBackground(void);
   void              CreateLabel(string name, string text, int x, int y, color clr, int fontSize = -1);
   void              SetLabelText(string name, string text, color clr = clrNONE);
   void              DeleteObject(string name);
   string            ObjName(string suffix);
   color             ScoreColor(int score);

public:
                     CDashboard(void);
                    ~CDashboard(void);

   void              Init(string prefix       = "RavanDB_",
                          int    x            = 15,
                          int    y            = 30,
                          int    width        = 250,
                          color  bgColor      = C'20,20,35',
                          color  borderColor  = C'60,80,120',
                          color  titleColor   = C'100,180,255',
                          color  buyColor     = clrLimeGreen,
                          color  sellColor    = clrTomato,
                          color  neutralColor = clrGray,
                          color  textColor    = clrWhite,
                          int    fontSize     = 9);

   void              Update(const SignalResult &sig,
                            double atr,
                            double support,
                            double resistance,
                            int    scoreEMA,
                            int    scoreST,
                            int    scoreADX,
                            int    scoreRSI,
                            int    scoreSR,
                            int    scoreCandles,
                            int    scoreVol);

   void              Show(void);
   void              Hide(void);
   void              Toggle(void);
   void              Remove(void);
   bool              IsVisible(void) const { return m_visible; }
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CDashboard::CDashboard(void)
  {
   m_prefix       = "RavanDB_";
   m_x            = 15;
   m_y            = 30;
   m_width        = 250;
   m_lineHeight   = 16;
   m_visible      = true;
   m_bgColor      = C'20,20,35';
   m_borderColor  = C'60,80,120';
   m_titleColor   = C'100,180,255';
   m_buyColor     = clrLimeGreen;
   m_sellColor    = clrTomato;
   m_neutralColor = clrGray;
   m_textColor    = clrWhite;
   m_fontSize     = 9;
   m_fontName     = "Consolas";
   m_totalObjects = 0;
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CDashboard::~CDashboard(void)
  {
   Remove();
  }

//+------------------------------------------------------------------+
//| Helper: Prefixed object name                                     |
//+------------------------------------------------------------------+
string CDashboard::ObjName(string suffix)
  {
   return m_prefix + suffix;
  }

//+------------------------------------------------------------------+
//| Initialize dashboard                                             |
//+------------------------------------------------------------------+
void CDashboard::Init(string prefix,
                      int    x,
                      int    y,
                      int    width,
                      color  bgColor,
                      color  borderColor,
                      color  titleColor,
                      color  buyColor,
                      color  sellColor,
                      color  neutralColor,
                      color  textColor,
                      int    fontSize)
  {
   m_prefix       = prefix;
   m_x            = x;
   m_y            = y;
   m_width        = width;
   m_bgColor      = bgColor;
   m_borderColor  = borderColor;
   m_titleColor   = titleColor;
   m_buyColor     = buyColor;
   m_sellColor    = sellColor;
   m_neutralColor = neutralColor;
   m_textColor    = textColor;
   m_fontSize     = fontSize;
   m_visible      = true;
  }

//+------------------------------------------------------------------+
//| Create the background rectangle                                  |
//+------------------------------------------------------------------+
void CDashboard::CreateBackground(void)
  {
   string name = ObjName("BG");
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE,  m_x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE,  m_y);
      ObjectSetInteger(0, name, OBJPROP_XSIZE,      m_width);
      ObjectSetInteger(0, name, OBJPROP_YSIZE,      m_lineHeight * 18 + 10);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR,    m_bgColor);
      ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, m_borderColor);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_CORNER,     CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_ZORDER,     0);
     }
  }

//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
void CDashboard::CreateLabel(string name, string text, int x, int y, color clr, int fontSize)
  {
   if(fontSize < 0) fontSize = m_fontSize;
   string fullName = ObjName(name);

   if(ObjectFind(0, fullName) < 0)
     {
      ObjectCreate(0, fullName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, fullName, OBJPROP_CORNER,     CORNER_LEFT_UPPER);
      ObjectSetInteger(0, fullName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, fullName, OBJPROP_ZORDER,     1);
     }

   ObjectSetInteger(0, fullName, OBJPROP_XDISTANCE,  m_x + x);
   ObjectSetInteger(0, fullName, OBJPROP_YDISTANCE,  m_y + y);
   ObjectSetString(0,  fullName, OBJPROP_TEXT,        text);
   ObjectSetInteger(0, fullName, OBJPROP_COLOR,       clr);
   ObjectSetInteger(0, fullName, OBJPROP_FONTSIZE,    fontSize);
   ObjectSetString(0,  fullName, OBJPROP_FONT,        m_fontName);
  }

//+------------------------------------------------------------------+
//| Update label text                                                |
//+------------------------------------------------------------------+
void CDashboard::SetLabelText(string name, string text, color clr)
  {
   string fullName = ObjName(name);
   if(ObjectFind(0, fullName) >= 0)
     {
      ObjectSetString(0, fullName, OBJPROP_TEXT, text);
      if(clr != clrNONE)
         ObjectSetInteger(0, fullName, OBJPROP_COLOR, clr);
     }
  }

//+------------------------------------------------------------------+
//| Delete a single object                                           |
//+------------------------------------------------------------------+
void CDashboard::DeleteObject(string name)
  {
   string fullName = ObjName(name);
   if(ObjectFind(0, fullName) >= 0)
      ObjectDelete(0, fullName);
  }

//+------------------------------------------------------------------+
//| Return color for a score value (buy/sell/neutral)                |
//+------------------------------------------------------------------+
color CDashboard::ScoreColor(int score)
  {
   if(score > 0) return m_buyColor;
   if(score < 0) return m_sellColor;
   return m_neutralColor;
  }

//+------------------------------------------------------------------+
//| Update all dashboard elements                                    |
//+------------------------------------------------------------------+
void CDashboard::Update(const SignalResult &sig,
                        double atr,
                        double support,
                        double resistance,
                        int    scoreEMA,
                        int    scoreST,
                        int    scoreADX,
                        int    scoreRSI,
                        int    scoreSR,
                        int    scoreCandles,
                        int    scoreVol)
  {
   if(!m_visible) return;

   CreateBackground();

   double balance    = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity     = AccountInfoDouble(ACCOUNT_EQUITY);
   double margin     = AccountInfoDouble(ACCOUNT_MARGIN);
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double spread     = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) -
                        SymbolInfoDouble(_Symbol, SYMBOL_BID)) /
                       SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   int row = 0;
   int pad = 8;
   int lh  = m_lineHeight;

   // Title
   CreateLabel("Title",    "=== RAVAN EA v1.0 ===",   pad, row * lh + 5, m_titleColor, 10);
   row++;

   // Symbol & Time
   string timeStr = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES);
   CreateLabel("Symbol",   _Symbol + "  " + timeStr,  pad, row * lh + 5, m_textColor);
   row++;

   // Separator
   CreateLabel("Sep1",     "---------------------",   pad, row * lh + 5, m_borderColor);
   row++;

   // Account info
   CreateLabel("Bal",      "Bal:  " + DoubleToString(balance,    2), pad, row * lh + 5, m_textColor); row++;
   CreateLabel("Eq",       "Eq:   " + DoubleToString(equity,     2), pad, row * lh + 5, m_textColor); row++;
   CreateLabel("Margin",   "Mrg:  " + DoubleToString(margin,     2), pad, row * lh + 5, m_textColor); row++;
   CreateLabel("FreeMrg",  "Free: " + DoubleToString(freeMargin, 2), pad, row * lh + 5, m_textColor); row++;

   // Separator
   CreateLabel("Sep2",     "---------------------",   pad, row * lh + 5, m_borderColor);
   row++;

   // Signal
   color sigColor = m_neutralColor;
   string sigText = "Signal: NONE";
   if(sig.signal == SIGNAL_BUY)
     {
      sigColor = m_buyColor;
      sigText  = "Signal: BUY";
     }
   else if(sig.signal == SIGNAL_SELL)
     {
      sigColor = m_sellColor;
      sigText  = "Signal: SELL";
     }

   CreateLabel("Signal",   sigText,                   pad, row * lh + 5, sigColor, 10); row++;
   CreateLabel("Score",    "Score: " + IntegerToString(sig.score) + "/15", pad, row * lh + 5, sigColor); row++;
   CreateLabel("Strength", "Strength: " + DoubleToString(sig.strength * 100.0, 1) + "%", pad, row * lh + 5, sigColor); row++;

   // Separator
   CreateLabel("Sep3",     "---------------------",   pad, row * lh + 5, m_borderColor);
   row++;

   // Individual indicator scores
   CreateLabel("EMA",     "EMA:    " + (scoreEMA     > 0 ? "+" : "") + IntegerToString(scoreEMA),     pad, row * lh + 5, ScoreColor(scoreEMA));     row++;
   CreateLabel("ST",      "Supertr:" + (scoreST      > 0 ? "+" : "") + IntegerToString(scoreST),      pad, row * lh + 5, ScoreColor(scoreST));      row++;
   CreateLabel("ADX",     "ADX:    " + (scoreADX     > 0 ? "+" : "") + IntegerToString(scoreADX),     pad, row * lh + 5, ScoreColor(scoreADX));     row++;
   CreateLabel("RSI",     "RSI:    " + (scoreRSI     > 0 ? "+" : "") + IntegerToString(scoreRSI),     pad, row * lh + 5, ScoreColor(scoreRSI));     row++;
   CreateLabel("SR",      "S/R:    " + (scoreSR      > 0 ? "+" : "") + IntegerToString(scoreSR),      pad, row * lh + 5, ScoreColor(scoreSR));      row++;
   CreateLabel("Candle",  "Candle: " + (scoreCandles > 0 ? "+" : "") + IntegerToString(scoreCandles), pad, row * lh + 5, ScoreColor(scoreCandles)); row++;
   CreateLabel("Vol",     "Volume: " + (scoreVol     > 0 ? "+" : "") + IntegerToString(scoreVol),     pad, row * lh + 5, ScoreColor(scoreVol));     row++;

   // Separator
   CreateLabel("Sep4",    "---------------------",    pad, row * lh + 5, m_borderColor);
   row++;

   // Market info
   CreateLabel("ATR",     "ATR:    " + DoubleToString(atr, _Digits),              pad, row * lh + 5, m_textColor); row++;
   CreateLabel("Spread",  "Spread: " + DoubleToString(spread, 1) + " pts",        pad, row * lh + 5, m_textColor); row++;
   if(support    > 0.0)
      CreateLabel("Sup",  "Sup:    " + DoubleToString(support,    _Digits),        pad, row * lh + 5, m_buyColor);
   row++;
   if(resistance > 0.0)
      CreateLabel("Res",  "Res:    " + DoubleToString(resistance, _Digits),        pad, row * lh + 5, m_sellColor);

   // Resize background to actual row count
   string bgName = ObjName("BG");
   if(ObjectFind(0, bgName) >= 0)
      ObjectSetInteger(0, bgName, OBJPROP_YSIZE, (row + 1) * lh + 10);

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Show dashboard                                                   |
//+------------------------------------------------------------------+
void CDashboard::Show(void)
  {
   m_visible = true;
   // Re-create objects by triggering an update call from parent
   // Objects will be created on next Update() call
   Print("Dashboard: Shown");
  }

//+------------------------------------------------------------------+
//| Hide dashboard                                                   |
//+------------------------------------------------------------------+
void CDashboard::Hide(void)
  {
   m_visible = false;
   // Hide by making objects invisible
   long   chartId = 0;
   int    total   = ObjectsTotal(chartId);
   int    prefixLen = StringLen(m_prefix);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(chartId, i);
      if(StringSubstr(name, 0, prefixLen) == m_prefix)
         ObjectSetInteger(chartId, name, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
     }
   ChartRedraw(0);
   Print("Dashboard: Hidden");
  }

//+------------------------------------------------------------------+
//| Toggle visibility                                                |
//+------------------------------------------------------------------+
void CDashboard::Toggle(void)
  {
   if(m_visible) Hide();
   else          Show();
  }

//+------------------------------------------------------------------+
//| Remove all dashboard objects                                     |
//+------------------------------------------------------------------+
void CDashboard::Remove(void)
  {
   long   chartId  = 0;
   int    total    = ObjectsTotal(chartId);
   int    prefixLen = StringLen(m_prefix);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(chartId, i);
      if(StringSubstr(name, 0, prefixLen) == m_prefix)
         ObjectDelete(chartId, name);
     }
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
