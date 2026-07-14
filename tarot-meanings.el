;;; tarot-meanings.el --- Tarot card meanings -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Gaelan D'costa
;; Author: Gaelan D'costa <gaelan@fastmail.ca>
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This file is NOT part of GNU Emacs.

;;; Commentary:
;; Original tarot card meanings for all 78 tarot cards, informed by general
;; knowledge of traditional Rider-Waite-Smith symbolism rather than drawn
;; from any specific text.
;;
;; Content was drafted and iteratively refined by Claude AI to fit a terse
;; house style directed by hand.

;;; Code:

(defconst tarot-meanings
  '(("The Fool"
     :upright "New beginnings, spontaneity, a leap of faith"
     :reversed "Recklessness, hesitation, a stalled journey")
    ("The Magician"
     :upright "Willpower, creation"
     :reversed "Squandered potential, deception")
    ("The High Priestess"
     :upright "Intuited wisdom"
     :reversed "Secrets, noise and distraction, ill-timed revelations")
    ("The Empress"
     :upright "Nurtured abundance, creativity, fertility, comfort"
     :reversed "Stifled growth, overindulgence, creative blocks, escapism")
    ("The Emperor"
     :upright "Beneficial authority, structure, guidance"
     :reversed "Rigidity, abdication of responsibility")
    ("The Hierophant"
     :upright "Tradition, inherited wisdom, education, conventional commitment"
     :reversed "Blind obedience, ill-considered rebellion")
    ("The Lovers"
     :upright "Heartfelt choice, prioritising unity over compromise, alignment of values"
     :reversed "Compromise, disharmony")
    ("The Chariot"
     :upright "Forward progress, steering independent forces towards common direction"
     :reversed "Lost momentum, internal conflict, unsustainable effort")
    ("Strength"
     :upright "Quiet courage, patience, control through respect"
     :reversed "Self-doubt, domineering control, lack of self-control")
    ("The Hermit"
     :upright "Solitude in the quest for wisdom, guiding those that follow"
     :reversed "Isolation, loneliness, hoarding wisdom or knowledge")
    ("Wheel of Fortune"
     :upright "Positive change, accepting change beyond your control"
     :reversed "Misfortune, resisting inevitable change")
    ("Justice"
     :upright "Fairness, earned consequences, binding decisions"
     :reversed "Imbalance, biased judgement, avoided accountability")
    ("The Hanged Man"
     :upright "A pause, a change in perspective, insight through acceptance and surrender"
     :reversed "Stalling, unwilling sacrifice")
    ("Death"
     :upright "Endings, unavoidable transformation, closure"
     :reversed "Forced change, stagnation, lack of closure")
    ("Temperance"
     :upright "Active balancing, making incremental adjustments"
     :reversed "Excess, imbalance, clashing concerns")
    ("The Devil"
     :upright "Bondage masquerading as desire, comforting restraints, accepting entrapment"
     :reversed "Recognised bondage, resisting restraints, striving for freedom")
    ("The Tower"
     :upright "Sudden collapse of illusion, painful but necessary"
     :reversed "Narrowly averted disaster, impending collapse, fearfully clinging to unsteady structure")
    ("The Star"
     :upright "Hope after hardship, renewed faith, gradual healing"
     :reversed "Distant hopes, disappointment, obscured renewal")
    ("The Moon"
     :upright "An uncertain path, obscured vision, mostly safe but cautiousness required"
     :reversed "Lifting confusion, unfounded fears, clarity")
    ("The Sun"
     :upright "Clarity, joy, warmth, obvious success"
     :reversed "Delayed or obscured joy, qualified success")
    ("Judgement"
     :upright "A moment of reckoning, rising to honestly answer and transform"
     :reversed "Ignored responsibility, self-flagellation, lack of self-reflection")
    ("The World"
     :upright "A completed cycle or journey, sense of fulfilment"
     :reversed "Loose ends, delayed arrival, lack of fulfilment")
    ("Ace of Cups"
     :upright "New emotional beginning, unconditional love"
     :reversed "Emotional withholding, disconnection")
    ("Two of Cups"
     :upright "Mutual bond, equal partnership, romantic connection"
     :reversed "One-sided bond, miscommunication")
    ("Three of Cups"
     :upright "Friendship, shared celebration"
     :reversed "Gossip, jealousy, strained friendships")
    ("Four of Cups"
     :upright "Apathy, ignored opportunity"
     :reversed "Renewed interest, breaking apathy")
    ("Five of Cups"
     :upright "Grief, focus on loss"
     :reversed "Acceptance, moving past grief")
    ("Six of Cups"
     :upright "Nostalgia, comforting memory"
     :reversed "Stuck in an idealised past")
    ("Seven of Cups"
     :upright "Tempting illusions, too many choices"
     :reversed "Illusions dispelled, honest reckoning")
    ("Eight of Cups"
     :upright "Walking away, seeking deeper meaning"
     :reversed "Delayed departure, fear of leaving")
    ("Nine of Cups"
     :upright "Satisfaction, a wish fulfilled"
     :reversed "Hollow satisfaction, surface pleasure")
    ("Ten of Cups"
     :upright "Family harmony, emotional fulfilment"
     :reversed "Discord beneath the surface")
    ("Page of Cups"
     :upright "Emotional curiosity, gentle sincerity"
     :reversed "Emotional immaturity, insincerity")
    ("Knight of Cups"
     :upright "Romantic pursuit, guided by feeling"
     :reversed "Empty charm, ungrounded ideals")
    ("Queen of Cups"
     :upright "Steady compassion, emotional depth"
     :reversed "Self-neglect, overwhelming emotion")
    ("King of Cups"
     :upright "Calm emotional mastery"
     :reversed "Suppressed emotion, hidden turmoil")
    ("Ace of Pentacles"
     :upright "Tangible new opportunity"
     :reversed "Missed or poorly planned opportunity")
    ("Two of Pentacles"
     :upright "Juggling priorities, practiced balance"
     :reversed "Overcommitment, dropped priorities")
    ("Three of Pentacles"
     :upright "Skilled collaboration, teamwork"
     :reversed "Collaboration breaking down")
    ("Four of Pentacles"
     :upright "Tightly guarded security"
     :reversed "Grip loosening, for better or worse")
    ("Five of Pentacles"
     :upright "Hardship, scarce support"
     :reversed "Slow recovery, support returning")
    ("Six of Pentacles"
     :upright "Fair generosity, shared resources"
     :reversed "Generosity as leverage, hidden debt")
    ("Seven of Pentacles"
     :upright "Patient assessment, weighing effort"
     :reversed "Impatience, frustration with slow returns")
    ("Eight of Pentacles"
     :upright "Diligent craftsmanship"
     :reversed "Mechanical effort, corners cut")
    ("Nine of Pentacles"
     :upright "Earned self-sufficiency, comfort"
     :reversed "Isolation, dependence disguised as comfort")
    ("Ten of Pentacles"
     :upright "Lasting legacy, generational wealth"
     :reversed "Disputed legacy, eroding security")
    ("Page of Pentacles"
     :upright "Earnest, grounded curiosity"
     :reversed "Impractical dreaming, no follow-through")
    ("Knight of Pentacles"
     :upright "Steady, methodical progress"
     :reversed "Stubbornness, progress stalled")
    ("Queen of Pentacles"
     :upright "Practical nurturing"
     :reversed "Overextension, or hardened stinginess")
    ("King of Pentacles"
     :upright "Generous material mastery"
     :reversed "Rigid materialism, dried-up generosity")
    ("Ace of Swords"
     :upright "Piercing clarity, sharp truth"
     :reversed "Clarity turned cruel, or confusion")
    ("Two of Swords"
     :upright "Deferred decision, willful blindness"
     :reversed "Stalemate broken, forced decision")
    ("Three of Swords"
     :upright "Plain heartbreak, sharp truth"
     :reversed "Old heartbreak resurfacing, unhealed wound")
    ("Four of Swords"
     :upright "Deliberate rest, recovery"
     :reversed "Rest denied, resuming too soon")
    ("Five of Swords"
     :upright "Hollow victory, costly conflict"
     :reversed "Reckoning with the cost, seeking truce")
    ("Six of Swords"
     :upright "Difficult transition, calmer water ahead"
     :reversed "Delayed departure, stalled crossing")
    ("Seven of Swords"
     :upright "Cunning, strategic maneuvering"
     :reversed "Deception exposed")
    ("Eight of Swords"
     :upright "Self-imposed restriction"
     :reversed "Restriction loosening, fear questioned")
    ("Nine of Swords"
     :upright "Anguish, worry, sleeplessness"
     :reversed "Anxiety easing, worst fears fading")
    ("Ten of Swords"
     :upright "Total collapse, rock bottom, betrayal"
     :reversed "Slow recovery, the worst now past")
    ("Page of Swords"
     :upright "Sharp curiosity, quick to speak"
     :reversed "Careless words, gossip as insight")
    ("Knight of Swords"
     :upright "Swift, decisive charge"
     :reversed "Reckless, directionless aggression")
    ("Queen of Swords"
     :upright "Clear-eyed, plain-spoken judgment"
     :reversed "Coldness, unnecessarily sharp criticism")
    ("King of Swords"
     :upright "Reasoned authority, precision"
     :reversed "Rigid logic, cold inflexibility")
    ("Ace of Wands"
     :upright "Spark of inspiration, new venture"
     :reversed "Blocked inspiration, delay")
    ("Two of Wands"
     :upright "Planning ambition, wider view"
     :reversed "Indecision, ambition held small")
    ("Three of Wands"
     :upright "Expanding venture, early success"
     :reversed "Delayed expansion, stalled momentum")
    ("Four of Wands"
     :upright "Milestone celebration, community joy"
     :reversed "Postponed celebration, shaky foundation")
    ("Five of Wands"
     :upright "Competitive friction, minor clashes"
     :reversed "Friction resolving, or buried unresolved")
    ("Six of Wands"
     :upright "Public recognition, earned victory"
     :reversed "Withheld recognition, contested victory")
    ("Seven of Wands"
     :upright "Defensive stand, holding ground"
     :reversed "Exhausted defense, untenable position")
    ("Eight of Wands"
     :upright "Rapid movement, accelerating events"
     :reversed "Frustrating delays, or events out of sync")
    ("Nine of Wands"
     :upright "Wary resilience, one more stand"
     :reversed "Burnout, defensiveness turned paranoid")
    ("Ten of Wands"
     :upright "Heavy burden, shouldered alone"
     :reversed "Setting the burden down, delegating")
    ("Page of Wands"
     :upright "Enthusiastic curiosity, adventure"
     :reversed "Enthusiasm without follow-through")
    ("Knight of Wands"
     :upright "Bold, impulsive action"
     :reversed "Directionless impulsiveness, burnout")
    ("Queen of Wands"
     :upright "Magnetic confidence, warmth"
     :reversed "Demanding attention, jealous control")
    ("King of Wands"
     :upright "Visionary, charismatic leadership"
     :reversed "Arrogant vision, no real direction"))
  "Tarot card meanings keyed by the string returned by `tarot-card-name'.

Each entry's cdr is a plist with :upright and :reversed meaning strings.")

(provide 'tarot-meanings)
;;; tarot-meanings.el ends here
