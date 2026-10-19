# Miqotul Khoir TV

Miqotul Khoir TV (MKT) is an offline-first Android TV digital signage system for mosques: a prayer-time clock and information board operated by a DKM administrator and viewed by the congregation.

## Language

### Prayer Schedule

**Adzan**:
The call to prayer marking the start of a prayer time; the signage dedicates a full-screen phase to it.
_Avoid_: Azan, Adhan

**Iqomah**:
The countdown interval between the Adzan and the start of the congregational prayer.
_Avoid_: Iqamah, Iqama

**Pre-Adzan**:
The countdown window shortly before a prayer time, used to highlight the upcoming prayer.
_Avoid_: pre-adhan

**Ihtiyat**:
A conservative safety margin (default +2 minutes) applied to calculated prayer times so worship begins after the astronomical event.
_Avoid_: time correction, offset

**Syuruq**:
The sunrise time that closes the Subuh window and serves as the base reference for Dhuha.
_Avoid_: sunrise

**Dhuha**:
The mid-morning prayer window derived from Syuruq plus a configurable offset.
_Avoid_: Duha

**Jum'at**:
Friday, treated by the signage with dedicated Iqomah and sholat durations and a khutbah-aware screen phase.
_Avoid_: Jumat, Friday prayer

**Kemenag SIHAT**:
The Indonesian Ministry of Religious Affairs prayer-time standard the app follows (Subuh 20°, Isya 18°, +2 minutes Ihtiyat).
_Avoid_: Kemenag method

**Elevation**:
The mosque's altitude above sea level, used to fine-tune Syuruq and Maghrib times.
_Avoid_: altitude, height

**Hijri Date**:
The Islamic calendar date shown beside the Gregorian date, adjustable by ±1 day.
_Avoid_: Islamic date

### Display Features

**Display State**:
One of the nine automatic screen modes the signage can show at any moment.
_Avoid_: screen mode, layout

**Standby**:
The default resting screen: clock, dates, prayer schedule, Treasury summary, and Running Text.
_Avoid_: idle screen

**Slideshow Announcement**:
The periodic full-screen rotation of announcement images from up to three configured slots.
_Avoid_: carousel, banner rotation

**Imam Schedule**:
The weekly rota assigning an imam — and on Jum'at a khatib — to each congregational prayer.
_Avoid_: imam board

**Wisdom Quote**:
A Quran verse or hadith shown as a periodic full-screen reflection.
_Avoid_: quote rotation

**Midnight Standby**:
The scheduled night power-saving screen with a dimmed clock and anti burn-in drift.
_Avoid_: sleep mode, night mode

**Running Text**:
The scrolling message displayed along the bottom edge of the screen.
_Avoid_: ticker, marquee

**Treasury**:
The optional cash summary (balance, income, expense) displayed on the Standby screen.
_Avoid_: cash widget

### Mosque Administration

**DKM**:
The mosque management board (Dewan Kemakmuran Masjid) that operates the signage.
_Avoid_: mosque committee
