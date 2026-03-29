# Ravan EA — Change Log

All notable changes to Ravan EA are documented here.

---

## [1.0.0] — 2025-01-01

### Initial Release

#### Expert Advisor (`RavanEA_MT5.mq5`)
- Complete auto-trading EA with multi-indicator confluence system
- 7-indicator signal engine (EMA, Supertrend, ADX, RSI, S/R, Candlestick, Volume)
- Risk-based position sizing (% of balance)
- Max drawdown protection
- Max daily loss protection
- Trailing stop with configurable distance and step
- Break-even stop functionality
- Partial close at TP1 and TP2
- Spread filter
- Time filter (trading hours + day-of-week exclusions)
- Multi-timeframe signal support
- On-chart dashboard integration
- Strategy Tester compatible

#### Chart Indicator (`RavanSignals_MT5.mq5`)
- Non-repainting buy/sell arrow signals
- Confluence score label on each signal arrow
- On-chart info dashboard (account, signal, indicators, market)
- Pop-up alert, push notification, email alert, sound alert
- Configurable arrow colors, sizes, alert toggles
- Buffer-based plotting per MT5 standards

#### Signal Engine (`Include/SignalEngine.mqh`)
- EMA Crossover (9/21/50/200) with crossover detection — weight 3
- Supertrend (ATR-based bands) — weight 3
- ADX with +DI/-DI direction — weight 2
- RSI with oversold/overbought recovery detection — weight 2
- Auto-detected Support/Resistance (swing highs/lows) — weight 3
- Candlestick patterns: Engulfing, Pin Bar, Doji, Hammer, Shooting Star — weight 1
- Volume spike detection — weight 1
- Total max score: ±15
- Configurable confluence threshold

#### Risk Manager (`Include/RiskManager.mqh`)
- Risk-percent lot sizing with symbol normalization
- Max drawdown check (from balance)
- Max daily loss check with auto-reset at new day
- Max positions check by magic number
- Margin sufficiency check with 20% buffer
- Peak equity tracking

#### Trade Manager (`Include/TradeManager.mqh`)
- CTrade-based order execution
- Buy/Sell market order placement
- Trailing stop with step control
- Break-even stop
- Partial close at configurable TP levels
- Close all / close buys / close sells
- Modify SL/TP
- Position counting by type

#### Dashboard (`Include/Dashboard.mqh`)
- OBJ_RECTANGLE_LABEL background panel
- OBJ_LABEL text rows for all metrics
- Account stats: balance, equity, margin, free margin
- Signal direction and strength
- Individual indicator scores with color coding
- ATR, spread, support/resistance levels
- Show/hide toggle

#### Backtest Report Script (`Scripts/BacktestReport.mq5`)
- Win rate, gross profit/loss, profit factor
- Average trade, best trade, worst trade
- Max drawdown calculation
- Simplified Sharpe ratio (annualized)
- Recovery factor
- CSV export to MQL5/Files folder
- MessageBox display

#### Presets
- `XAUUSD_Scalping.set` — Gold scalping on M15
- `EURUSD_Swing.set` — EUR/USD swing on H4
- `GBPUSD_Day.set` — GBP/USD day trading on H1
- `BTCUSD_Crypto.set` — Bitcoin on H1

#### Documentation
- `README.md` — Project overview and setup guide
- `Docs/UserManual.md` — Full user manual with all parameters
- `Docs/MarketDescription.md` — MQL5 Market product listing copy
- `Docs/ChangeLog.md` — This file

---

## Upcoming (Planned)

### [1.1.0] — Planned
- Bollinger Bands breakout signal (optional 8th indicator)
- Fibonacci retracement levels in S/R detection
- Improved news filter integration
- Multi-symbol scanning mode

### [1.2.0] — Planned
- Machine learning signal weight optimization
- Advanced statistics panel
- Telegram notification support

---

*For support, questions, or feature requests, please contact us through the MQL5 Market product page.*

*Ravan EA | Copyright 2025 Ravan Trading Systems*
