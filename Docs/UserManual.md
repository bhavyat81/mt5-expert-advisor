# Ravan EA — User Manual

**Version 1.0** | Copyright 2025, Ravan Trading Systems

---

## Table of Contents

1. [System Requirements](#1-system-requirements)
2. [Installation Guide](#2-installation-guide)
3. [Quick Start](#3-quick-start)
4. [Input Parameters Reference](#4-input-parameters-reference)
5. [How the Signal Engine Works](#5-how-the-signal-engine-works)
6. [Backtesting Guide](#6-backtesting-guide)
7. [Presets Guide](#7-presets-guide)
8. [Troubleshooting FAQ](#8-troubleshooting-faq)
9. [Risk Disclaimer](#9-risk-disclaimer)

---

## 1. System Requirements

| Requirement | Minimum |
|---|---|
| Platform | MetaTrader 5 (build 3000+) |
| Operating System | Windows 7/10/11, macOS (via Wine) |
| RAM | 4 GB |
| Internet Connection | Stable broadband |
| Broker Account | Any MT5-compatible broker |
| Account Type | Any (Standard, ECN, Raw Spread) |

**Recommended:**
- ECN/Raw Spread account with low commission
- Broker with XAUUSD (Gold) support if using scalping preset
- VPS hosting for 24/7 EA operation

---

## 2. Installation Guide

### Step 1 — Download Files

Download the complete Ravan EA suite from your MQL5 Market purchase page.

### Step 2 — Locate Your MT5 Data Folder

1. Open MetaTrader 5
2. Go to **File → Open Data Folder**
3. Navigate to the `MQL5` subfolder

### Step 3 — Copy Files

Copy files to the corresponding MT5 folders:

```
MT5 Data Folder/
└── MQL5/
    ├── Experts/
    │   └── RavanEA_MT5.mq5          ← Copy here
    ├── Indicators/
    │   └── RavanSignals_MT5.mq5     ← Copy here
    ├── Include/
    │   ├── SignalEngine.mqh         ← Copy here
    │   ├── RiskManager.mqh          ← Copy here
    │   ├── TradeManager.mqh         ← Copy here
    │   └── Dashboard.mqh            ← Copy here
    └── Scripts/
        └── BacktestReport.mq5       ← Copy here
```

### Step 4 — Compile in MetaEditor

1. Press **F4** in MT5 to open MetaEditor
2. In the Navigator panel, find `Experts/RavanEA_MT5`
3. Press **F7** to compile
4. Check the **Errors** tab — should show 0 errors, 0 warnings
5. Repeat for `Indicators/RavanSignals_MT5`

### Step 5 — Enable AutoTrading

1. In MT5, click **Tools → Options → Expert Advisors**
2. Check ✅ "Allow automated trading"
3. Check ✅ "Allow DLL imports" (not required for Ravan EA, but good practice)
4. Click **OK**

### Step 6 — Attach the EA

1. Open a chart (e.g., XAUUSD M15)
2. In the Navigator panel, expand **Expert Advisors**
3. Drag `RavanEA_MT5` onto the chart
4. Configure inputs (or load a preset)
5. Click **OK**
6. The AutoTrading button (top toolbar) must be **green/active**

---

## 3. Quick Start

**5-minute setup for XAUUSD Scalping:**

1. Open XAUUSD chart, M15 timeframe
2. Attach `RavanEA_MT5`
3. In the **Inputs** tab, click **Load** → select `XAUUSD_Scalping.set`
4. Set your account risk (recommended: 1% per trade)
5. Click **OK** — EA is live!

**To add the signal indicator separately:**
1. Open the same chart
2. Drag `RavanSignals_MT5` from Navigator → Indicators
3. Configure to match the EA settings

---

## 4. Input Parameters Reference

### Trade Settings

| Parameter | Default | Description |
|---|---|---|
| `InpLotSize` | 0.01 | Fixed lot size (used when `InpRiskPercent = 0`) |
| `InpMaxPositions` | 3 | Maximum number of simultaneous open positions |
| `InpMagicNumber` | 202501 | Unique EA identifier — do not change if running multiple EAs |
| `InpTradeComment` | "RavanEA" | Comment attached to all trades |

### Signal Settings

| Parameter | Default | Description |
|---|---|---|
| `InpSignalTF` | H1 | Timeframe for signal calculation (higher = slower, more reliable) |
| `InpSignalThreshold` | 10 | Minimum confluence score to trigger a trade (1–15) |
| `InpUseEMA` | true | Enable EMA crossover indicator |
| `InpUseSupertrend` | true | Enable Supertrend indicator |
| `InpUseADX` | true | Enable ADX trend strength filter |
| `InpUseRSI` | true | Enable RSI overbought/oversold filter |
| `InpUseSR` | true | Enable Support/Resistance detection |
| `InpUseCandlestick` | true | Enable candlestick pattern detection |
| `InpUseVolume` | true | Enable volume spike confirmation |

### ADX Settings

| Parameter | Default | Description |
|---|---|---|
| `InpADXPeriod` | 14 | ADX calculation period |
| `InpADXMinLevel` | 25.0 | Minimum ADX value to confirm trend (lower = more signals, higher = fewer but stronger) |

### RSI Settings

| Parameter | Default | Description |
|---|---|---|
| `InpRSIPeriod` | 14 | RSI calculation period |
| `InpRSIOversold` | 30.0 | RSI level for oversold (buy zone) |
| `InpRSIOverbought` | 70.0 | RSI level for overbought (sell zone) |

### Supertrend Settings

| Parameter | Default | Description |
|---|---|---|
| `InpSTPeriod` | 10 | ATR period for Supertrend calculation |
| `InpSTMultiplier` | 3.0 | ATR multiplier (higher = wider bands, fewer signals) |

### Support/Resistance Settings

| Parameter | Default | Description |
|---|---|---|
| `InpSRLookback` | 50 | Number of bars to scan for swing highs/lows |
| `InpSRTolerance` | 0.5 | ATR multiplier for S/R zone width (0.3 = tight, 1.0 = wide) |

### Risk Management

| Parameter | Default | Description |
|---|---|---|
| `InpRiskPercent` | 1.0 | Risk % of account balance per trade (set to 0 to use fixed lot) |
| `InpMaxDrawdown` | 20.0 | Maximum drawdown % before EA stops opening new trades |
| `InpMaxDailyLoss` | 5.0 | Maximum daily loss % before EA stops for the day |

### Stop Loss & Take Profit

| Parameter | Default | Description |
|---|---|---|
| `InpSLPoints` | 300 | Stop loss in points (0 = use ATR-based SL from signal engine) |
| `InpTPPoints` | 600 | Take profit in points (0 = use RR ratio or ATR-based TP) |
| `InpRiskReward` | 2.0 | Risk:Reward ratio (used when `InpTPPoints = 0`) |

### Trailing Stop

| Parameter | Default | Description |
|---|---|---|
| `InpUseTrailing` | true | Enable trailing stop |
| `InpTrailingDist` | 300 | Trailing stop distance from current price (points) |
| `InpTrailingStep` | 50 | Minimum price movement before trailing stop is adjusted (points) |

### Break-Even

| Parameter | Default | Description |
|---|---|---|
| `InpUseBreakEven` | true | Enable break-even stop loss |
| `InpBreakEvenPips` | 200 | Points of profit required to trigger break-even |
| `InpBreakEvenOffset` | 10 | Points above entry price for break-even SL (small buffer) |

### Partial Close

| Parameter | Default | Description |
|---|---|---|
| `InpUsePartialClose` | false | Enable partial position close at TP levels |
| `InpPartialTP1` | 300 | Distance (points) for first partial close |
| `InpPartialTP2` | 600 | Distance (points) for second partial close |
| `InpPartialPct1` | 50 | Percentage of position to close at TP1 |
| `InpPartialPct2` | 50 | Percentage of remaining position to close at TP2 |

### Spread Filter

| Parameter | Default | Description |
|---|---|---|
| `InpMaxSpread` | 30 | Maximum allowed spread in points (EA skips if spread is wider) |

### Time Filter

| Parameter | Default | Description |
|---|---|---|
| `InpUseTimeFilter` | false | Enable trading hours restriction |
| `InpTradeHourStart` | 8 | Trading start hour (server/broker time, 0–23) |
| `InpTradeHourEnd` | 20 | Trading end hour (server/broker time, 0–23) |
| `InpSkipMonday` | false | Skip trading on Mondays (gap risk) |
| `InpSkipFriday` | false | Skip trading on Fridays (weekend gap risk) |

---

## 5. How the Signal Engine Works

Ravan EA uses a **confluence scoring system** — multiple independent indicators each vote on trade direction. A trade only executes when enough indicators agree.

### The 7 Indicators

| # | Indicator | Max Score | Purpose |
|---|---|---|---|
| 1 | EMA Crossover (9/21/50/200) | ±3 | Trend direction |
| 2 | Supertrend (ATR-based) | ±3 | Trend confirmation |
| 3 | ADX (>25 filter) | ±2 | Trend strength |
| 4 | RSI (oversold/overbought) | ±2 | Entry timing |
| 5 | Support/Resistance | ±3 | Key price zones |
| 6 | Candlestick Patterns | ±1 | Visual confirmation |
| 7 | Volume Analysis | ±1 | Momentum confirmation |
| **Total** | | **±15** | |

### Scoring Logic

```
Score = EMA_score + Supertrend_score + ADX_score + RSI_score
        + SR_score + Candle_score + Volume_score

Score range: -15 (strong sell) to +15 (strong buy)
```

- **Score ≥ threshold (default: 10)** → **BUY** signal
- **Score ≤ -threshold (default: -10)** → **SELL** signal
- **Score between -10 and +10** → No trade (wait)

### Signal Strength

```
Strength = |score| / 15  →  0.0 (weak) to 1.0 (maximum)
```

A strength of 0.67 means 10/15 score, which is the minimum for a trade signal.

### Non-Repainting Guarantee

All signals are calculated on **completed bars only** (bar index 1, not bar index 0). Once a signal is placed on a closed bar, it will never change or disappear.

---

## 6. Backtesting Guide

1. Press **Ctrl+R** in MT5 to open Strategy Tester
2. Select `Expert: RavanEA_MT5`
3. Set Symbol, Timeframe, Date Range
4. Choose **"Every tick based on real ticks"** for best accuracy
5. Click **Properties** → configure inputs (or load a preset)
6. Click **Start**

**After backtest completes:**
1. Review the **Report** tab for standard MT5 statistics
2. Run the **BacktestReport** script for enhanced statistics
3. Check the **Graph** tab for equity curve

**Recommended backtest settings:**
- Test period: minimum 6 months, ideally 2+ years
- Use real tick data when available
- Test on multiple symbols and timeframes

---

## 7. Presets Guide

| Preset File | Symbol | Timeframe | Strategy | Risk Level |
|---|---|---|---|---|
| `XAUUSD_Scalping.set` | XAUUSD | M15 | Scalping | Medium-High |
| `EURUSD_Swing.set` | EURUSD | H4 | Swing | Low-Medium |
| `GBPUSD_Day.set` | GBPUSD | H1 | Day Trading | Medium |
| `BTCUSD_Crypto.set` | BTCUSD | H1 | Trend Following | High |

**To load a preset:**
1. Attach EA to chart
2. In **Inputs** tab, click **Load**
3. Navigate to the `Presets` folder
4. Select the `.set` file
5. Click **Open**

> **Note:** Presets are starting points. Always backtest before going live with real money.

---

## 8. Troubleshooting FAQ

**Q: EA is not trading — what's wrong?**
- Check AutoTrading button is enabled (green)
- Check the **Journal** tab for error messages
- Verify the spread is below `InpMaxSpread`
- Check if time filter is restricting trading hours
- Check if max drawdown or daily loss limit has been reached

**Q: "Cannot load indicator" error**
- Make sure all `.mqh` files are in the `MQL5/Include/` folder
- Recompile the EA in MetaEditor (F7)

**Q: EA opens too many trades**
- Reduce `InpMaxPositions`
- Increase `InpSignalThreshold` (higher = fewer signals)
- Enable time filter to restrict trading hours

**Q: Signals repaint on the chart**
- This is normal for the current bar (bar 0)
- Signals on **completed bars** (bar 1+) never change
- The EA executes on the first tick of a new bar, based on the completed previous bar

**Q: Dashboard is not showing**
- Verify `InpShowDashboard = true`
- Check that chart objects are visible (View → Objects → Show)
- Try removing and re-attaching the EA

**Q: Backtest shows different results than live trading**
- Use "Every tick based on real ticks" in Strategy Tester
- Check that test dates have sufficient history downloaded
- Broker spread/commission may differ — adjust `InpMaxSpread`

**Q: How do I run this on multiple pairs?**
- Attach the EA to each chart separately
- Use a **different `InpMagicNumber`** for each instance (e.g., 202501, 202502, 202503)
- Adjust lot sizes to respect total account risk

---

## 9. Risk Disclaimer

> **IMPORTANT: Trading foreign exchange, commodities, and cryptocurrencies involves substantial risk of loss. Past performance is not indicative of future results. Automated trading systems, including Expert Advisors, can lose money. Never trade with money you cannot afford to lose.**

- This software is provided for educational and informational purposes
- Ravan Trading Systems is not a licensed financial advisor
- Always backtest thoroughly before using real money
- Start with minimum lot sizes and scale up gradually
- Use a demo account first to familiarize yourself with the system
- Maintain proper risk management at all times

---

*Ravan EA v1.0 | Copyright 2025 Ravan Trading Systems | MQL5 Market*
