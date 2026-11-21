= Rate–distortion and prior mismatch

#strong[The idea:] learning a latent prior can lower the variational coding cost toward the rate--distortion curve without changing what an encoder retains. This example makes the prior-mismatch term in the #link("computational-aesthetics.html#measuring-information")[aesthetics model] visible.

== A binary example
<a-binary-example>
Let $X$ be a fair binary stimulus and $Z$ a binary latent. Use the latent itself as the reconstruction, with Hamming distortion $d \( x \, z \) = upright(bold(1)) \[ x eq.not z \]$. An encoder $F_D$ flips the input with probability $D$, so its expected distortion is $D$. For $0 lt.eq D lt.eq 1 \/ 2$, these channels attain the rate--distortion curve:

$
  cal(R) \( D \) = 1 - h_2 \( D \) \, #h(2em) h_2 \( D \) = - D log_2 D - \( 1 - D \) log_2 \( 1 - D \) .
$

Here $0 log_2 0 = 0$. We use $cal(R) \( D \)$ for the rate--distortion function to distinguish it from the learned prior $R_theta$.

The true latent marginal is $q_(F_D) \( Z = 1 \) = 1 \/ 2$ for every encoder in this family. Write the prior as $R_r \( Z = 1 \) = r$. The variational rate identity @alemi2018 gives:

$
  cal(C) \( F_D \, r \) = cal(R) \( D \) + D_(upright("KL"))  ("Bern" \( 1 \/ 2 \) bar.v.double "Bern" \( r \)) = 1 - h_2 \( D \) - 1 / 2 log_2  \( 4 r \( 1 - r \) \) .
$

#figure(image("../assets/rate-distortion-prior.svg", alt: "Three descending curves. Prior mismatch adds 0.208 or 0.737 bits above the matched-prior curve. At distortion 0.18 a downward arrow shows prior learning closing the gap."), caption: [Prior mismatch raises the variational coding cost above the exact rate–distortion curve. At a fixed encoder (vertical dotted line), improving the prior moves downward while distortion and mutual information stay fixed. All information quantities are in bits per stimulus.]) <fig-rate-distortion-prior>
== How to read it
<how-to-read-it>
- #strong[Along a curve:] change the encoder's flip probability, trading retained information for distortion.
- #strong[Downward at a fixed distortion:] improve only the prior. The latent marginal remains fair; $r$ approaches $1 \/ 2$, and the mismatch penalty disappears. The encoder and its mutual information do not change.
- #strong[At $D = 1 \/ 2$:] the latent carries no input information, yet a mismatched prior still gives positive expected KL. Positive variational rate alone does not prove informative representations.

The constant vertical offsets are a property of this symmetric example, where the marginal is the same at every distortion. They need not be constant for other encoder families.

#html.elem("aside", attrs: (class: "callout-note"))[
== When is the gap entirely prior mismatch?
<when-is-the-gap-entirely-prior-mismatch>
Only when the encoder attains the rate--distortion frontier, as it does here. For a general feasible encoder and a specified reconstruction rule with achieved distortion $D_F$,

$
  cal(C) \( F \, theta \) - cal(R) \( D_F \) = underbrace(I_F \( X \; Z \) - cal(R) \( D_F \), upright("encoder’s excess rate")) + underbrace(D_(upright("KL")) \( q_F bar.v.double R_theta \), upright("prior mismatch")) .
$

Learning the prior removes the second term, not necessarily the first. This illustrative binary coding problem is not an empirical result about perception or aesthetic reward.

]
