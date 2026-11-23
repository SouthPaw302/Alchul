# ALCHUL — M11 T17: Causal Physical-Environment Sensing

**Date:** 2026-11-23. **Status:** independent research-only Godot source/reaction lab, not a verified archosaur organ or supernatural detector. **Game:** Chapter I source, Pages build and public characters remain unchanged.

## Design principle

The civilization's **evolved sensitivity to matter** and its **technology for influencing matter** develop together. But in the early mature-surface interval, physics remains grounded: pressure, vibration, thermal transport, gas, water flow, failure stress, and acoustic resonance are real classes of stimulus. A fictional population's detection capacity and learned tool use must be represented as *testable conditional models*, not unexplained magic.

Alchul is separate from their species. Fermentation opens a fictional two-way perceptual aperture, but **contact testimony is not a physical sensor reading** and this lab does not simulate Alchul, prove its mechanism, measure ESP, or infer a fossil sensory organ.

## What T17 implements

- Six explicitly caused physical processes: river pulse **water**, bank substrate **vibration**, nursery wood **stress**, Harvest organic **heat**, fermentation **gas**, witness material **acoustics**.
- Four independently located hypothetical readers (bank, nursery, Harvest, witness) with specified sensitivity, noise, cross-talk and different detection thresholds.
- Transparent deterministic attenuation `signal = amplitude × exp(−distance/spread) × (0.82 + 0.18 sin(2π frequency·time + phase))`, plus bounded channel cross-talk, deterministic noise and an intentionally labeled false-alarm injection. **All values and positions are dimensionless teaching parameters, not calibrated physiological/physical measurements.**
- A recorded reaction is a flag when normalized signal exceeds a threshold; each reading retains matched physical sources and a separate false-positive flag. Noise and contamination can produce detection even with no matching stimulus, falsifying naive identification.
- A repeatable adversarial example: disable the river's source, inject interference into the witness reader's water channel, and observe a flagged reading with **zero matching water-source energy**; this is not evidence of Alchul.
- Independent native Godot source/reader 3D view with on/off keys 1–6, F false-alarm and Space time, visual amplitudes, reading provenance and no simulated body or anomalous being.
- Python reference model `godot/tools/m11_t17_sensing.py`, native Godot `godot/scripts/m11_t17_physical_sensing_lab.gd`, one scene, smoke test and three engine screenshots (baseline, source removed, false-positive demo).

## Gates and limitations

**Technical:** Verify offline reference test, native Godot deterministic source→sensor reaction, explicit false positives, nonfinite/unknown input rejection, scene rendering and no mutation of playable game, plus visual archive.

**Scientific still open:** real tissue receptors, source amplitudes, attenuation coefficients, Cretaceous environmental boundary values, neural response, phylogenetic inference for an advanced sensory species, hardware/metrological calibration, film-quality interactions, social learning dynamics, archaeological settlement or New Madrid present-day physics. No observed non-avian dinosaurs lived post–K–Pg in real Earth evidence; 2026 hidden settlement is explicitly fiction.

The next T18 task will keep interpretation testimony separate and investigate independent observer disagreement without reducing anomalous perception to a fabricated voltage or force.
