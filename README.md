# Detonation Location Finder

A MATLAB tool for estimating the point of detonation within an explosive, based on Time-of-Arrival (TOA) data from pressure sensor pins. This app takes in sensor coordinates and TOA values to compute and visualize the likely origin of the detonation event.

https://github.com/user-attachments/assets/96bd4f2d-8f17-4b56-846e-7852432dadba

---

## 🔍 Overview

In experiments involving the impact-triggered detonation of explosives, determining where detonation began is critical for assessing the time delays after impact and interpreting post-test damage. Unlike point source detonations from a detonator, impact-driven events may initiate along an irregular or distributed front. The destructive nature of these events also leads to occasional data loss from one or more sensors. This tool accounts for such complexities by analyzing TOA sensor data in pairs to estimate a representative detonation origin, providing both numerical results and graphical visualization.

---

## ⚙️ How It Works

The algorithm compares the difference in arrival times between every pair of TOA pins. For each pin pair, it calculates a solution curve representing the possible locations from which a detonation could have originated to result in the observed time difference. Given four valid pin times, the code will generate a plot containing 6 solution curves. Detonation is estimated to have occurred at the centroid of the region where the pin-pair curbes intersect.


<p align="left">
  <img src="https://github.com/user-attachments/assets/598e333e-e7ca-431e-bcd8-729b55d0d7cf" alt="example matlab graph" width="300" align="right" style="margin-left: 20px;">
The algorithm compares the difference in arrival times between every pair of TOA pins. For each pin pair, it calculates a solution curve representing the possible locations from which a detonation could have originated to result in the observed time difference. Given four valid pin times, the code will generate a plot containing 6 solution curves. Detonation is estimated to have occurred at the centroid of the region where the pin-pair curbes intersect.
  
### ✨ Features
- For *n* pins, it uses all unique pin pairs (e.g. 4 pins → 6 solution curves).
- Supports arbitrary pin placement within the explosive
- Remains functional with missing or partial pin data
- Configurable explosive size, pin coordinates, and detonation wave velocity
- Graphical visualization of possible origin curves and final estimate
</p>

---
