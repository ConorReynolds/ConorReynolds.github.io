#lang pollen

◊(define-meta title "Coq Lab Sheet 2")
◊(define-meta toc-title "Coq Lab Sheet 2: Propositional Logic in Coq")
◊(define-meta subtitle "Propositional Logic in Coq")
◊(define-meta math? #true)
◊(define-meta created "2022-12-10")

All natural deduction rules for propositional logic have been covered by now in the lectures. Let's put them into practice.

◊section{A quick word on sequents}

In natural deduction, we have two broad kinds of proof rules for each propositional connective: ◊em{introduction} rules and ◊em{elimination} rules. Introduction rules explain how to build a connective from components. The introduction rules for 'and' and 'or' are:

◊$${
  \frac{A \quad B}{A \wedge B}{{\wedge}_{\mathcal{I}}} \qquad \frac{A}{A \vee B}{{\vee}_{\mathcal{I}_1}} \quad \frac{B}{A \vee B}{{\vee}_{\mathcal{I}_2}}
}

Elimination rules, on the other hand, explain how to ◊em{use} the connective. The elimination rules for 'and' and 'or' are:

◊$${
  \frac{A \wedge B}{A}{\wedge_{\mathcal{E}_1}} \quad \frac{A \wedge B}{B}{\wedge_{\mathcal{E}_2}}
}
◊$${
  \frac{A \vee B \quad \fbox{Suppose $A$ … $C$} \quad \fbox{Suppose $B$ … $C$}}{C}{{\vee}_{\mathcal{E}}}
}

You will recall these from your first-year course on discrete structures.

It is better to think of Coq tactics as not necessarily 'introducing' or 'eliminating' a connective, but as manipulating the proof state according to where the connective appears. A proof state in Coq is always represented by a ◊em{sequent} ◊${\Gamma \vdash \phi}, where ◊${\Gamma} is a list of hypotheses (everything above the line in Coq), and ◊${\phi} is the current goal (below the line).

The proof rules that manipulate sequents are very similar to natural deduction rules, but instead of being classified into 'introduction' and 'elimination' rules, they are classified into ◊em{left} and ◊em{right} rules. Left-rules apply when the connective appears as a hypothesis---that is, on the left-hand side of a sequent. Right-rules apply when the connective appears in the conclusion---that is, on the right-hand side of a sequent.

◊section{Proofs Involving 'And' and 'Or'}

As discussed in the previous section, the left-rules for 'and' and 'or' should explain what happens when they appear as a hypothesis.

If we have a hypothesis of the form ◊${A \wedge B}, the left-rule for 'and' says the following:

◊$${
    \frac{\Gamma, A \wedge B \vdash C}{\Gamma, A, B \vdash C}
}

In plain English: if we know ◊${A \wedge B}, then we know ◊${A}, and we also know ◊${B}. It breaks apart the original hypothesis so that we can use ◊${A} and ◊${B} separately. Not very interesting.

A more interesting example involves the hypothesis ◊${A \vee B}. The left-rule for 'or' is as follows:

◊$${
    \frac{\Gamma, A \vee B \vdash C}{\Gamma, A \vdash C \qquad \Gamma, B \vdash C}
}

In plain English: if we can prove ◊${C} using ◊${A \vee B}, then in fact we should be able to prove ◊${C} from ◊${A} only, ◊em{and} we should be able to prove ◊${C} from ◊${B} only. The point is that if we claim that ◊em{either ◊${A} or ◊${B}} is sufficient to prove ◊${C}, then either one alone should be enough to prove ◊${C}.

The right-rules explain what happens when 'and' or 'or' appear in the goal, rather than in our hypotheses. The right-rule for conjunction is:

◊$${
  \frac{\Gamma \vdash A \wedge B}{\Gamma \vdash A \qquad \Gamma \vdash B}
}

This says that, if we want to prove ◊${A \wedge B}, then we must prove ◊${A} only, and then we must prove ◊${B} only.

The right-rules for disjunction are:

◊$${
  \frac{\Gamma \vdash A \vee B}{\Gamma \vdash A} \qquad \frac{\Gamma \vdash A \vee B}{\Gamma \vdash B}
}

This gives us two ways to prove ◊${A \vee B}: either we prove ◊${A}, or we prove ◊${B}. Either is fine.

How do we instruct Coq to apply these rules?

◊ul[#:compact #false]{
  ◊item{
    To apply the left-rule for 'and' or 'or' in Coq, use the tactic ◊code{destruct}. As with any rule applying to hypotheses, you will need to tell Coq which hypothesis you want to apply the tactic to.
  }
  ◊item{
    To apply the right-rule for 'and', use the tactic ◊code{split}.
  }
  ◊item{
    To apply the right-rules for 'or', use the tactics ◊code{left} or ◊code{right}, depending on which side of the disjunction you think you can prove.
  }
}

◊section{Proofs Involving Negation}

Recall that ◊${\neg A} in constructive propositional logic is really just a shorthand for ◊${A \to \bot}, which means that ◊${A} implies a contradiction. In Coq, the false-by-definition proposition ◊${\bot} is called ◊code{False}. ◊aside{The proposition ◊${\bot} is sometimes called 'bottom'.}

Since negation is shorthand for a special case of implication, you can use all the tactics from the ◊xref["resources/coq-01.html#Basic Tactics"]{first lab}.

If you see a goal of the form ◊code{~A}, you can reduce it to its definition ◊code{A -> False} with the tactic ◊code{red}---short for 'reduce'---after which you can use ◊code{intros}. Alternatively, if you want to unfold ◊em{all} instances of negation, including in hypotheses, you can use ◊code{unfold "~" in *}. This can help you spot valid applications of the ◊code{apply} tactic.

Alternatively, note that ◊code{intro} will apply ◊code{hnf} to the goal until ◊code{intro} can actually be applied. Hence if the goal is ◊code{~A}, ◊code{intro} will reduce it to ◊code{A -> False} and then pull ◊code{A} up as a hypothesis. Note that ◊code{intros} will ◊em{not} do this without ◊code{red} first.

◊section{Classical Logic}

Coq's logic is ◊em{constructive}. This means that the law of excluded middle is not an axiom and cannot be proved (or disproved) in Coq's logic. If you want to reason classically, you must add ◊abbr{LEM} as an axiom or hypothesis explicitly.

◊codeblock['coq]{
  (* Pick only one of these options *)
  Axiom LEM : forall P : Prop, P \/ ~P.
  Hypothesis LEM : forall P : Prop, P \/ ~P.
}

When you know ◊abbr{LEM}, you can always reason by case analysis. For example, if you write ◊code{destruct (LEM A)}, the proof will split into two cases: one in which you know ◊${A}, and one in which you know ◊${\neg A}.

You will need ◊abbr{LEM} for one of the final four questions on the De Morgan laws---but we're not telling you which one. That's something for you to figure out yourself.

◊section{Questions}

Prove the following propositions in Coq. When you have completed the proof, replace ◊code{Admitted} with ◊code{Qed}.

◊codeblock['coq #:name "CoqLab02.v" #:download #true]{
  Section CoqLab02.

  Context (A B C : Prop).

  (***************************************************)
  (* And / Or *)

  Lemma q1 : (A /\ B) /\ C -> A /\ (B /\ C).
  Proof.
    (* todo *)
  Admitted.

  Lemma q2 : ((A /\ B) -> C) -> (A -> (B -> C)).
  Proof.
    (* todo *)
  Admitted.

  Lemma q3 : (A \/ B) \/ C -> A \/ (B \/ C).
  Proof.
    (* todo *)
  Admitted.

  Lemma q4 : ((A \/ B) -> C) -> (A -> (B -> C)).
  Proof.
    (* todo *)
  Admitted.

  (***************************************************)
  (* Negation *)

  Lemma q5 : (~A \/ B) -> (A -> B).
  Proof.
    (* todo *)
  Admitted.

  Lemma q6 : (A -> B) -> (~B -> ~A).
  Proof.
    (* todo *)
  Admitted.

  Lemma q7 : ~(A /\ ~A).
  Proof.
    (* todo *)
  Admitted.

  (***************************************************)
  (* De Morgan’s Laws *)

  Hypothesis LEM : forall P : Prop, P \/ ~P.

  Lemma q8 : ~(A \/ B) -> ~A /\ ~B.
  Proof.
    (* todo *)
  Admitted.

  Lemma q9 : ~A /\ ~B -> ~(A \/ B).
  Proof.
    (* todo *)
  Admitted.

  Lemma q10 : ~A \/ ~B -> ~(A /\ B).
  Proof.
    (* todo *)
  Admitted.

  Lemma q11 : ~(A /\ B) -> ~ A \/ ~ B.
  Proof.
    (* todo *)
  Admitted.

  End CoqLab02.
}
