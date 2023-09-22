#lang pollen

◊(define-meta title "Coq Lab Sheet 1")
◊(define-meta toc-title "Coq Lab Sheet 1: An introduction to Coq")
◊(define-meta subtitle "An introduction to the Coq proof assistant")
◊(define-meta math? #true)
◊(define-meta created "2022-11-21")

◊section{Prerequisites}

Some knowledge of formal logic and proof theory (as well as general mathematical maturity and experience with proofs) will be helpful.

◊note{
  Code snippets can be copied by hovering over the snippet and clicking the ◊i[#:class "fa fa-copy" #:style "margin: 0 0.1em 0 0.1em; color: var(--muted-color);"] button which appears on the top right.
  
  Some snippets are declared as files---those can be downloaded directly by clicking the ◊i[#:class "fa fa-download" #:style "position: relative; margin: 0 0.1em 0 0.1em; top: -0.05em; font-size: 0.9em; color: var(--muted-color);"] button next to the filename.
}

◊section{Instructions}

If you're on the lab computers, everything is already installed---just open CoqIDE.

If you're using your own computer, download and install the latest version of the ◊extlink["https://coq.inria.fr/download"]{Coq Platform}. This should install, amongst other things, CoqIDE---we recommend using this if you're new to Coq. The install size is fairly big so make sure you have enough disk space.

If you know what you're doing, there's also generally decent support for using Coq in your preferred text editor (as long as you're not using Windows). As far as I know, VS Code and Emacs have the best experience as of this writing.

You must put everything into a single file for submission. The file should look like this:

◊codeblock['coq #:name "CoqLab01.v"]{
  Section CoqLab01.
  Context (A B C D : Prop).

  (* your lab work goes here *)

  End CoqLab01.
}

You can skip ahead to the ◊xref["resources/coq-01.html#Questions"]{lab questions} if you're confident enough, but I highly recommend reading through the next two sections to get an overview of the tactics required for the lab, and a ◊xref["resources/coq-01.html#Worked Example"]{worked example}.

◊section{Basic Tactics}

Tactics are commands you can run that transform the proof state in some way. You will need three tactics for this lab: ◊code{intros}, ◊code{apply}, and ◊code{exact}.

◊ul[#:compact #false]{
  ◊item{
    ◊code{intros} applies the ◊em{introduction rule} for an implication. That is, it transforms the proof state from ◊${\Gamma \vdash A \to B} into ◊${\Gamma, A \vdash B}.
  }

  ◊item{
    ◊code{apply} applies the ◊em{elimination rule} for an implication, but 'backwards'. That is, it transforms the proof state from ◊${\Gamma, A \to B \vdash B} into ◊${\Gamma, A \to B \vdash A}.
  }

  ◊item{
    ◊code{exact} closes the proof when the proof state looks like ◊${\Gamma, A \vdash A}.
  }
}

For a simple description of these tactics (and many others) I recommend you take a look at this ◊extlink["https://pjreddie.com/coq-tactics"]{simplified tactic index}. It also has some examples of the tactics in use.

If you're feeling particularly adventurous, I encourage you to brave the official ◊extlink["https://coq.inria.fr/refman/proof-engine/tactics.html"]{Coq tactic index}. For example, you can read some very detailed info about the ◊code{apply} tactic ◊extlink["https://coq.inria.fr/refman/proof-engine/tactics.html#coq:tacn.apply"]{here}.

◊section{Worked Example}

Let's prove that ◊$${A, \; A \to B, \; B \to C \; \vdash \; C \tag{∗}} using Coq.

First, though, we should remind ourselves what this means. The mathematical expression ◊${\Gamma \vdash \phi} means that, from the list of assumptions ◊${\Gamma}, we can prove the proposition ◊${\phi}. Therefore, ◊${(∗)} means this: given that we know

◊ol{
  ◊item{◊${A}}
  ◊item{◊${A \to B}}
  ◊item{◊${B \to C}}
}

we should be able to prove ◊${C}.

In Coq, we can represent the situation like this.

◊codeblock['coq #:name "Example.v" #:download #t]{
  Section WorkedExample.

  Context (A B C : Prop).

  Hypotheses
    (H1 : A)
    (H2 : A -> B)
    (H3 : B -> C).

  Goal C.

  End WorkedExample.
}

Step the proof state to the goal (◊kbd{Ctrl + ↓} in CoqIDE). You should see this.

◊codeblock['coq]{
  A, B, C : Prop
  H1 :  A
  H2 :  A -> B
  H3 :  B -> C
  —————————————————————————————
  (1/1)
  C
}

Our goal is ◊code{C}; that is what we want to prove. What we know is listed above the line. In order: we know that ◊code{A}, ◊code{B}, and ◊code{C} are propositions. We know that ◊code{A} is true. We know that ◊code{A -> B} is true. We know that ◊code{B -> C} is true. Each of these hypotheses was given a label, which we will use to refer to that proposition in the proof.

Our first attempt at a proof will use ◊em{backward reasoning}. Forward reasoning starts with hypotheses and tries to work towards the goal. Backward reasoning, by contrast, starts from the ◊em{goal} and tries to work backward to the hypotheses. ◊aside{Why backward reasoning? There is no complex reason for it---it's just easier to prove things in proof assistants like Coq working backward.}

Here is the basic idea of backward reasoning. Notice that the goal is ◊code{C} and that our hypothesis ◊code{H3 : B -> C} has the conclusion ◊code{C}. If we were somehow able to prove ◊code{B}, we could then use the fact that we know ◊code{B -> C} to get ◊code{C}---which is our goal. Therefore, it suffices for us to prove ◊code{B}. (And we hope of course that we ◊em{can} prove ◊code{B}.)

This little bit of reasoning is encoded by the ◊code{apply} tactic. When we issue the command ◊code{apply H3}, what we're instructing Coq to do is this: check if the conclusion of ◊code{H3} matches the goal. If it does, replace the goal with ◊code{H3}’s premises. Let's do that now.

◊codeblock['coq]{
  Goal C.
    apply H3.
}

Step the proof forward (◊kbd{Ctrl + ↓}). The proof state should look like this.

◊codeblock['coq]{
  A, B, C : Prop
  H1 :  A
  H2 :  A -> B
  H3 :  B -> C
  —————————————————————————————
  (1/1)
  B
}

It's exactly as before, but the goal is now ◊code{B}. Progress!

Notice that we can do exactly the same thing again, but this time with the hypothesis ◊code{H2}.

◊codeblock['coq]{
  Goal C.
    apply H3.
    apply H2.
}

After stepping forward, the proof state should now look like this.

◊codeblock['coq]{
  A, B, C : Prop
  H1 :  A
  H2 :  A -> B
  H3 :  B -> C
  —————————————————————————————
  (1/1)
  A
}

Now the goal is ◊code{A}. But we already know that ◊code{A} is true, since it is one of our hypotheses. Therefore, the proof is complete---we just need to instruct Coq to match the goal with the right hypothesis. For that, we can use the tactic ◊code{exact}.

◊codeblock['coq]{
  Goal C.
    apply H3.
    apply H2.
    exact H1.
}

The proof should be complete, and the proof state should look like this.

◊codeblock['coq]{
  No more subgoals.
}

We can close the proof with the vernacular command ◊code{Qed}.

◊codeblock['coq]{
  Goal C.
    apply H3.
    apply H2.
    exact H1.
  Qed.
}

Now the proof is fully complete and saved.

This way of expressing the term to be proved can be a little verbose. We could, alternatively, have set the proof up like this.

◊codeblock['coq]{
  Context (A B C : Prop).

  (*   ↓H1     ↓H2         ↓H3      *)
  Goal A -> (A -> B) -> (B -> C) -> C.
}

This is equivalent to what we had before, but the proof begins in a different state.

◊codeblock['coq]{
  A, B, C : Prop
  —————————————————————————————
  (1/1)
  A -> (A -> B) -> (B -> C) -> C
}

Recall that if we want to prove a proposition of the form ◊${P \to Q}, we take ◊${P} as a hypothesis, then try to prove ◊${Q}. This is the introduction rule for implication and is encoded in Coq by the tactic ◊code{intros}.

The tactic ◊code{intros} can be used in one of two ways. First is on its own, with no arguments. When used like this, it will apply the introduction rule for implication as many times as it can and automatically give unique names to all the generated hypotheses. The second way is with arguments. When used like this, it will apply the introduction rule ◊${n} times (where ◊${n} is the number of provided arguments) and name the hypotheses according to the parameter names. ◊aside{There is another tactic, ◊code{intro}, which applies the introduction rule for implication ◊em{exactly once}, and will try to reduce values to weak-head normal form until ◊code{intro} can be directly applied.}

For example, we can do this:

◊codeblock['coq]{
  Goal C.
    intros.
}

... to get the proof state:

◊codeblock['coq]{
  A, B, C : Prop
  H0 :  A
  H1 :  A -> B
  H2 :  B -> C
  —————————————————————————————
  (1/1)
  C
}

(Note how Coq automatically names the hypotheses.) Or, we can do this:

◊codeblock['coq]{
  Goal C.
    intros a a_impl_b b_impl_c.
}

... and get the proof state:

◊codeblock['coq]{
  A, B, C : Prop
  a :  A
  a_impl_b :  A -> B
  b_impl_c :  B -> C
  —————————————————————————————
  (1/1)
  C
}

It's up to you which method you prefer. ◊aside{But note that ◊code{intros} will never reduce head-constants if invoked with no arguments (unlike ◊code{intro}).}

◊hrule

◊section{Questions}

Prove the following lemmas in Coq. When you have completed a proof, replace ◊code{Admitted} with ◊code{Qed}. You can download the file by clicking the ◊i[#:class "fa fa-download" #:style "position: relative; margin: 0 0.1em 0 0.1em; top: -0.05em; font-size: 0.9em; color: var(--muted-color);"] button next to the filename.

◊codeblock['coq #:name "CoqLab01.v" #:download #t]{
  Section CoqLab01.
  Context (A B C D : Prop).
  
  (* Implication is transitive. *)
  Lemma q1 : (A -> B) -> (B -> C) -> (A -> C).
  Proof.
    (* todo *)
  Admitted.

  (* Anything implies itself. *)
  Lemma q2 : A -> A.
  Proof.
    (* todo *)
  Admitted.

  (* Extra hypotheses can be introduced without affecting
   * provability. *)
  Lemma q3 : A -> (B -> A).
  Proof.
    (* todo *)
  Admitted.

  (* The order of the hypotheses is irrelevant. *)
  Lemma q4 : (A -> B -> C) -> B -> A -> C.
  Proof.
    (* todo *)
  Admitted.

  (* Duplicate hypotheses can be merged. *)
  Lemma q6 : (A -> A -> B) -> A -> B.
  Proof.
    (* todo *)
  Admitted.

  (* Duplicate hypotheses can be introduced. *)
  Lemma q7 : (A -> B) -> A -> A -> B.
  Proof.
    (* todo *)
  Admitted.

  (* Diamond lemma:
   *        A
   *      ↙   ↘           A
   *     B     C    ~>    ↓
   *      ↘   ↙           D
   *        D
   *)
  Lemma q8 : (A -> B) -> (A -> C) -> (B -> C -> D) -> A -> D.
  Proof.
    (* todo *)
  Admitted.

  (* Weak version of Peirce’s law. The strong version implies
   * LEM and therefore can’t be proved in constructive logic. *)
  Lemma q9 : ((((A -> B) -> A) -> A) -> B) -> B.
  Proof.
    (* todo *)
  Admitted.

  End CoqLab01.
}
