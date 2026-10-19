# 0002 - Pure-Dart Astronomy Libraries Inside the Domain Layer

**Date:** 2026-10-15  
**Status:** Accepted  

## Context
The Dependency Rule keeps `lib/domain/` free of frameworks, yet `CalculatePrayerTimesUseCase` must compute astronomical times and Hijri dates. The alternatives were an abstract calculator port implemented in `lib/data/` or direct use of pure-Dart libraries.

## Decision
The pure-Dart libraries `adhan` and `hijri` are allowed inside domain use cases; Flutter, SQLite, and Firebase imports remain forbidden in `lib/domain/`.

## Consequences
Calculations stay synchronous, unit-testable, and portable with no port/adapter ceremony; replacing the astronomy engine later would touch the domain layer rather than a single adapter.
