# 0001 - Kemenag SIHAT Calculation Standard for Prayer Times

**Date:** 2026-10-15  
**Status:** Accepted  

## Context
Congregations compare the displayed schedule against the official Indonesian reference (Kemenag RI / SIHAT). International methods (MWL, Umm al-Qura, MUIS) produce different Subuh and Isya times and would undermine trust in the signage.

## Decision
Prayer times are calculated fully offline using Kemenag SIHAT parameters: Subuh 20°, Isya 18°, built-in Ihtiyat of +2 minutes, plus per-mosque Elevation correction and per-prayer manual Ihtiyat adjustments.

## Consequences
Displayed times match the schedule Indonesian mosques already follow; the app is calibrated for the Indonesian standard only, so adapting it to other authorities requires changing the calculation parameters.
