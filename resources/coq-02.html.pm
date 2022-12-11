#lang pollen

◊(define-meta title "Coq Lab Sheet 2 (Draft)")
◊(define-meta toc-title "Coq Lab Sheet 2: Propositional Logic in Coq")
◊(define-meta subtitle "Propositional Logic in Coq")
◊(define-meta math? #true)
◊(define-meta created "2022-12-10")

All natural deduction rules for propositional logic have been covered by now in the lectures. Let's put them into practice.

◊section{Proofs Involving 'And' and 'Or'}

Recall that an elimination rule for a propositional connective 'removes' that connective, and more generally explains how the connective can be used or broken down into simpler parts. In Coq, it is better to think of there being two different elimination rules, which we will call ◊em{left- and right-elimination}. Which one you use will depend on whether the connective appears in the hypotheses (left) or in the goal (right).

For example, if we have a hypothesis of the form ◊${A \wedge B}, the left-elimination rule for 'and' says the following:

◊$${
    \frac{\Gamma, A \wedge B \vdash C}{\Gamma, A, B \vdash C}
}

In plain English: if we know ◊${A \wedge B}, then we know ◊${A}, and we also know ◊${B}. It breaks apart the original hypothesis so that we can use ◊${A} and ◊${B} separately. Not very interesting.

A more interesting example involves the hypothesis ◊${A \vee B}. The left-elimination rule for 'or' is as follows:

◊$${
    \frac{\Gamma, A \vee B \vdash C}{\Gamma, A \vdash C \qquad \Gamma, B \vdash C}
}

In plain English: if we can prove ◊${C} using ◊${A \vee B}, then in fact we should be able to prove ◊${C} from ◊${A} only, ◊em{and} we should be able to prove ◊${C} from ◊${B} only. The point is that if we claim that ◊em{either ◊${A} or ◊${B}} is sufficient to prove ◊${C}, then either one alone should be enough to prove ◊${C}.

The right-elimination rules explain what happens when 'and' or 'or' appear in the goal, rather than in our hypotheses. The right-elimination rule for conjunction is:

◊$${
  \frac{\Gamma \vdash A \wedge B}{\Gamma \vdash A \qquad \Gamma \vdash B}
}

This says that, if we want to prove ◊${A \wedge B}, then we must prove ◊${A} only, and then we must prove ◊${B} only.

The right-elimination rules for disjunction are:

◊$${
  \frac{\Gamma \vdash A \vee B}{\Gamma \vdash A} \qquad \frac{\Gamma \vdash A \vee B}{\Gamma \vdash B}
}

This gives us two ways to prove ◊${A \vee B}: either we prove ◊${A}, or we prove ◊${B}. Either is fine.

To apply the left-elimination rule for 'and' or 'or', use the tactic ◊code{destruct}. To apply the right-elimination rule for 'and', use the tactic ◊code{split}. To apply the right-elimination rules for 'or', use the tactics ◊code{left} or ◊code{right}, depending on which side of the disjunction we think we can prove.

◊section{Proofs Involving Negation}

Recall that ◊${\neg A} in constructive propositional logic is really just a shorthand for ◊${A \to \bot}, which means that ◊${A} implies a contradiction. In Coq, the false-by-definition proposition ◊${\bot} is called ◊code{False}. ◊aside{The proposition ◊${\bot} is sometimes called 'bottom'.}

Since negation is shorthand for a special case of implication, you can use all the tactics from the first lab.

If you see a goal of the form ◊code{~A}, you can reduce it to its definition ◊code{A -> False} with the tactic ◊code{red}---short for 'reduce'---after which you can use ◊code{intros}. Alternatively, if you want to unfold ◊em{all} instances of negation, including in hypotheses, you can use ◊code{unfold "~" in *}. This can help you spot valid applications of the ◊code{apply} tactic.

◊section{Classical Logic}

Coq's logic is ◊em{constructive}. This means that the law of excluded middle is ◊em{not} an axiom in Coq's logic. If you want to reason classically, you must add ◊abbr{LEM} as an axiom or hypothesis explicitly.

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
