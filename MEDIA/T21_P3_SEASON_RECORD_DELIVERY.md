# T21.3 — Life across days and seasons

Status: working fictional prototype, pending native CI review. Mature surface age, pre-Long Descent. No approved bodies or literal historical/contact claim.

## Implemented scope

- Separate scene: `godot/scenes/t21_p3_seasonal_terrace.tscn`. The unchanged T21.2 eight-watch day is the prerequisite. N opens the calendar only after a protected conclusion. R restarts the whole study.
- Eight abstract days, two per phase: rising water (extra repair demand), warm growth (extra care), lean water (extra food), cool return (extra care). Not a claim about Mesozoic seasons, actual duration, weather, or physiology.
- Six duties: provision, care, maintain, teach, replenish, rest. Select two distinct priorities per day. All workers and households remain abstract; the choices represent shared priorities, not a population census, fixed castes or two literal laborers.
- Food, care and repair begin as rounded narrative mappings of the actual prior-day snapshot. Materials carry forward as a bounded integer; rest and learning use independent authored baselines. Resources are dimensionless, bounded 0–12.
- Daily costs are paid after duty benefits. Underfunded needs leave permanent ledger entries; exact payment is sufficient for that day. Maintenance spends material. Two teaching sessions and no unmet needs are required for continuity. Rest is a resource, not a health diagnosis.
- Visible shared record shelf, eight tokens (unfilled / current / met / unmet), phase text and live duty meters. English labels are explanatory UI, not a canonical script. Prior-day terrace geometry is deliberately frozen during the calendar; new visuals do not imply changed hydrology or new anatomy.
- Chronicle 05 extends Sen, Vek and Eru's working lives, care, knowledge and disagreements. The established approximately three-quarter internal gestation premise is retained without speculative organs or detailed timing.

## Verification

Native smoke checks protected entry, all original actions, duplicate duty rejection, phase progression, complete positive and neglect routes, preservation of the original snapshot, and reset. Dedicated workflow runs previous native smoke tests and the T21.3 test, then captures three native views. Check actual run results before claiming success or merging.

## Next

T21.4: connect each seasonal obligation to a visible work animation and local environmental change; add a reviewable ledger UI, resident relationship choices, soundscape, and approval-dependent ergonomics. No Chapter I or live site changes in this prototype.
