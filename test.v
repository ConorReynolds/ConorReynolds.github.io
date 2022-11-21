Section WorkedExample.

Context (A B C : Prop).

Goal (A -> (A -> B) -> (B -> C) -> C).
  intros a a_implies_b b_implies_c.
  apply H3.
  apply H2.
  exact H1.
Qed.


End WorkedExample.