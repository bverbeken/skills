---
name: review-refactoring
description: "Find refactoring opportunities in a change: names, duplicate code, code in the wrong place, code smells. One of the eight checks of `review`; run it alone for refactoring only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below, then steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return the findings.

## Check

Match the diff against the smells below (Fowler, _Refactoring_, ch. 3). Each one reads _what it is_ → _how to fix_. Also look for:

- **WRONG PLACE**: a class, function or file in a package or module where it doesn't belong, for example a helper in a feature folder that only another feature uses. → move it next to what uses it. When the placement is a design choice, leave it to `review-architecture`.
- **DUPLICATION WITH EXISTING CODE**: the change writes something the codebase already has. Grep for it. → call the existing code.

Smells:

- **Mysterious Name**: a function, variable or type whose name doesn't say what it does or holds. → rename it. If no honest name comes, the design is murky.
- **Duplicated Code**: the same logic appears in more than one hunk or file in the change. → extract the shared part and call it from both.
- **Feature Envy**: a method that uses another object's data more than its own. → move the method onto that data.
- **Data Clumps**: the same few fields or parameters keep travelling together. → bundle them into one type and pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept. → give the concept its own small type.
- **Repeated Switches**: the same `switch` or `if` chain on the same type in several places. → use polymorphism, or one map both places share.
- **Shotgun Surgery**: one logical change forces edits in many files. → gather what changes together into one module.
- **Divergent Change**: one file is edited for several unrelated reasons. → split it so each part changes for one reason.
- **Speculative Generality**: abstractions, parameters or hooks for needs the spec doesn't have. → delete them, inline until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly passes calls on. → remove it and call the target directly.
- **Refused Bequest**: a subclass that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

Each smell is a judgement call: write "possible Feature Envy", and say how to fix it. A documented repo standard wins over a smell: when the repo endorses the pattern, leave it out.

## Blocking

In colleague mode, refactoring findings are suggestions.
