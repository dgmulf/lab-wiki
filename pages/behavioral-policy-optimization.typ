= Behavioral policy optimization: variations and open questions

#html.elem("aside", attrs: (class: "callout-note"))[
== AI-generated template
<ai-generated-template>
This page is an AI-generated template for developing the research project. Its proposed variations and experiment plans require review and refinement by the project contributors.

]
== Research question
<research-question>
Can we improve learning efficiency by changing how an agent learns the policy used to collect its training data? Papini et al.~call this #strong[behavioral policy optimization (BPO)]: choose a sampling policy to reduce the variance of a policy-gradient estimate, while importance weighting preserves the objective of a separate target policy @papini2024[secs. 2--3].

#strong[Status:] exploratory research agenda. The baseline below summarizes the attached May 2024 paper (arXiv version 1). The variations are hypotheses and mathematical extensions, not demonstrated improvements or claims of novelty. No experiments have been run for this project.

== Starting point: what the paper does
<starting-point-what-the-paper-does>
The #strong[target policy] is the policy whose expected return we want to improve. The #strong[behavioral policy] determines which actions generate the training data. These can differ: an informative trajectory need not be a high-return trajectory.

Hold the target parameters $theta$ fixed. Write $tau$ for a trajectory, $p_theta \( tau \)$ for its probability under the target policy, and $g_theta \( tau \)$ for a single-trajectory gradient estimate satisfying $bb(E)_(p_theta) \[ g_theta \] = nabla J \( theta \)$. If trajectories instead come from a distribution $q$, their corrected gradient contributions are

$
  X_q \( tau \) = frac(p_theta \( tau \), q \( tau \)) g_theta \( tau \) \, #h(2em) tau tilde.op q .
$

This estimator is unbiased when the proposal covers the relevant target support and the expectations exist. With the same environment and initial-state law, the trajectory likelihood ratio is a product of action-probability ratios; unknown environment transition probabilities cancel.

The paper minimizes the trace of the gradient covariance: the sum of the variances of its coordinates. Over unrestricted trajectory distributions, its optimal proposal is @papini2024[Theorem 1]

$
  q^(*) \( tau \) = frac(p_theta \( tau \) norm(g_theta \( tau \))_2, Z) \, #h(2em) Z = bb(E)_(p_theta) \[ norm(g_theta \( tau \))_2 \] .
$

Assume $0 < Z < oo$. This allocates more sampling probability to trajectories with large gradient contributions. It generally cannot be realized exactly by a policy: the agent controls actions, but not environment transitions.

The authors therefore fit a realizable behavioral policy $pi_phi.alt$ by minimizing $D_(upright("KL")) \( q^(*) bar.v.double p_phi.alt \)$. This becomes weighted maximum likelihood:

$
  cal(L)_(upright("CE")) \( phi.alt \) = - bb(E)_(p_theta) [norm(g_theta \( tau \))_2 sum_t log pi_phi.alt \( a_t divides s_t \)] .
$

Algorithm 1 uses one batch to fit the behavior policy and a fresh batch to estimate the target gradient. The latter combines target-policy and learned behavior-policy trajectories using defensive importance sampling. Section 6.1 also explores reuse of data, explicitly acknowledging bias in its practical gradient estimator. Baselines, defensive mixtures, and reuse are therefore parts of the starting point, rather than new contributions proposed here.

== Variation 1: optimize the variance objective directly
<variation-1-optimize-the-variance-objective-directly>
=== Motivation
<motivation>
Cross-entropy is convenient to fit, but the actual excess variance depends on a different divergence. Lemma 4.1 implies

$
  "tr" "Cov"_q \( X_q \) = Z^2 [1 + chi^2 \( q^(*) bar.v.double q \)] - norm(nabla J \( theta \))_2^2 .
$

Consequently, a better KL fit need not be a better variance fit within a restricted policy family. This distinction is already recognized by the authors; the proposed experiment is to test whether direct optimization is practical.

=== Candidate method
<candidate-method>
Initialize with the paper's cross-entropy fit, then refine the behavior policy by minimizing the gradient second moment. For a fixed reference distribution $r$ covering the target support, an equivalent population objective is

$
  M \( phi.alt \) = bb(E)_(tau tilde.op r) [frac(p_theta \( tau \)^2, r \( tau \) p_phi.alt \( tau \)) norm(g_theta \( tau \))_2^2] .
$

Use stored action likelihoods to evaluate the ratios. Hold the target, reference distribution, and gradient definition fixed during fitting. A positive defensive mixture can replace $p_phi.alt$ in the denominator to limit importance weights.

#strong[Hypothesis:] direct refinement improves gradient estimation when the policy family cannot realize $q^(*)$. #strong[Risk:] the empirical objective can be dominated by rare trajectories or overfit a small batch. Evaluate on fresh trajectories; report failures as well as average gains. Clipping this objective is a separate, modified optimization criterion.

== Variation 2: adapt the defensive mixture and fitting budget
<variation-2-adapt-the-defensive-mixture-and-fitting-budget>
For a target-policy fraction $beta > 0$, define the trajectory mixture

$
  q_(beta \, phi.alt) \( tau \) = beta p_theta \( tau \) + \( 1 - beta \) p_phi.alt \( tau \) .
$

It satisfies $p_theta \/ q_(beta \, phi.alt) lt.eq 1 \/ beta$. To sample this distribution, choose a policy at the start of each episode and keep it for that episode. Mixing action probabilities anew at every step produces a different trajectory distribution and requires different weights.

The paper already analyzes $beta$ and the allocation between BPO fitting and gradient estimation. Our proposed variation is an empirical controller that adjusts both from past batches: increase defensive sampling when weighted gradient contributions become unstable, and spend more on behavior fitting only when its measured benefit justifies the trajectories it consumes.

#strong[Hypothesis:] adaptation helps as the target moves between regions with reliable and unreliable behavior fits. Start with a small predeclared grid of $beta$ values and batch allocations. Choose settings using earlier data, then freeze them before collecting the next evaluation batch. Include all tuning and fitting samples in the interaction budget.

Effective sample size from importance weights is a useful diagnostic, but it ignores gradient magnitudes. Select on estimated gradient error or second moment, and report weight tails and gradient-contribution tails alongside it.

== Variation 3: optimize sampling for the update actually applied
<variation-3-optimize-sampling-for-the-update-actually-applied>
Euclidean gradient variance treats all parameter coordinates alike. An optimizer may instead apply a fixed linear transformation $A$ to the gradient, producing an update $A accent(nabla J, ̂)$. For a transformation fixed before sampling, the same importance-sampling derivation yields

$
  q_A^(*) \( tau \) prop p_theta \( tau \) norm(A g_theta \( tau \))_2 .
$

This minimizes the trace of the covariance of the transformed update. A candidate BPO fit replaces $norm(g_theta)_2$ in the cross-entropy weights with $norm(A g_theta)_2$. Begin with a fixed diagonal rescaling to isolate the effect; then investigate a preconditioner estimated from previous batches.

#strong[Hypothesis:] this better allocates samples when parameter scales differ. #strong[Limit:] lower update variance does not itself establish faster improvement in return. A transformation learned from the same evaluation batch also breaks the fixed-$A$ premise. The identity case must recover the original objective.

== Variation 4: fit the behavior policy to a baseline-adjusted estimator
<variation-4-fit-the-behavior-policy-to-a-baseline-adjusted-estimator>
A baseline subtracts a reference value from return without changing the expected policy gradient, when its construction satisfies the relevant zero-mean score identity. It changes the gradient contributions and therefore changes the ideal sampling distribution. For example, with a fixed scalar baseline $b$,

$
  g_(theta \, b) \( tau \) = nabla_theta log p_theta \( tau \) thin \[ R \( tau \) - b \] \, #h(2em) q_b^(*) \( tau \) prop p_theta \( tau \) norm(g_(theta \, b) \( tau \))_2 .
$

The paper already uses gradient baselines in its experiments. The proposed extension is to alternate fitting the baseline for the current sampling distribution and fitting the behavioral policy for the resulting estimator. Freeze both before collecting evaluation trajectories.

#strong[Hypothesis:] coordinated fitting improves on independently chosen baselines and behavior policies. #strong[Risk:] each fit changes the other's objective, so alternation can be unstable. Compare baseline-only, BPO-only, and combined conditions; an added baseline alone would not demonstrate a new BPO benefit. Approximate critics require a separate accounting of estimator bias.

== First experiments
<first-experiments>
Start with an enumerable contextual bandit, followed by a small finite-horizon MDP with stochastic transitions. Exact sums give the true gradient, covariance, and unrestricted optimum; the MDP exposes the gap between unrestricted sampling and distributions an action policy can realize.

+ Reproduce on-policy estimation and the paper's cross-entropy BPO with fresh evaluation data and defensive sampling.
+ Freeze the target and compare each variation separately. Repeat the entire fitting-and-evaluation procedure across seeds, rather than only resampling from a single fitted behavior policy.
+ Measure squared bias, covariance trace, and mean squared gradient error. Also record interaction cost, fitting time, and extreme weighted gradient contributions. For independent samples from a fixed proposal, covariance of the sample mean is the single-sample covariance divided by batch size.
+ Only after these checks, update the target and compare return against total environment interactions. Keep policy families and tuning budgets comparable.

An improvement should survive the cost of fitting the behavior policy, rather than merely reduce per-trajectory variance. Bias must be reported explicitly for any reuse or clipping variant. The initial implementation should preserve the paper's separation between fitting data and fresh gradient-estimation data.

== Connection to computational aesthetics
<connection-to-computational-aesthetics>
The #link("computational-aesthetics.html")[computational aesthetics project] also asks how attention could select observations that improve learning. The shared idea is to favor samples with useful gradient contributions while correcting changes in sampling distribution. The learned quantity differs: Papini et al.~estimate a policy gradient, whereas that project considers gradients of a latent density model. Transferring BPO would require specifying the perceptual learning target, the observation distributions attainable through attention, and a valid importance ratio. Policy-gradient guarantees do not automatically transfer.

== Open decisions
<open-decisions>
- Which limitation matters most in our intended setting: policy-family restrictions, unstable weights, parameter scaling, or fitting overhead?
- Should the first implementation prioritize direct second-moment refinement or adaptive defensive sampling? Both permit controlled comparisons against the paper's estimator without introducing a learned critic.
- When does unavoidable environment randomness dominate the potential benefit of actively choosing actions for gradient estimation?
- How robust are gains when the target changes faster than the behavioral policy can be fitted?
