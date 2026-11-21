= Computational model of aesthetics

== Overview
<overview>
This model proposes that beauty helps guide attention toward experiences from which an organism can learn. As its model of perceptual representations improves, a sense of beauty acts as an internal reward that encourages attention. Perception encodes sensory information under limited processing capacity; learning the distribution of these representations can reduce the cost of coding them.

#strong[First-version scope:] the encoder and latent probability model have no explicit temporal-history input. The action policy uses current perceptual latents and memory. Learning also accumulates past experience in model parameters. Future models may condition the encoder and latent prior on memory.

#strong[Model status:] conceptual hypothesis. The mathematical information bound is distinct from the proposed biological interpretation and aesthetic mechanism.

== Model components
<model-components>
#figure(
  table(
    columns: (50%, 50%),
    align: (auto,auto,),
    table.header([Component], [Role],),
    table.hline(),
    [Action policy $pi$], [Selects movement and attentional controls from current latent $z$ and memory $h$.],
    [Transition model $T$], [Updates the hidden state, including attentional and sensor configuration.],
    [Observation density $E$], [Generates sensory input $X$ from state $S$.],
    [Perceptual channel $F$], [Encodes sensory input $X$ as latent representation $Z$.],
    [Memory update $U$], [Summarizes past latents and actions for the policy.],
    [Latent model $R_theta$], [Assigns a normalized probability distribution to perceptual latents.],
    [Importance estimator $w_eta$], [Uses running latent feature statistics to estimate how sampling in the current context differs from the marginal of experience.],
    [Aesthetic reward], [Heuristically tracks learning progress and contributes to action selection.],
  )
  , kind: table
  )

#strong[Information flow:] sensory input → $F$ → current latent and memory → action under $pi$ → state transition → next sensory input. Learning from the latents provides the proposed aesthetic reward.

=== Attention
<attention>
Actions have movement and attentional dimensions:

$
  a_t = \( a_t^(upright("move")) \, a_t^(upright("att")) \) \, #h(2em) cal(A) = cal(A)_(upright("move")) times cal(A)_(upright("att")) .
$

This follows the camera/manipulator action-space construction in #cite(<weng2024>, form: "prose", supplement: [sec.~III]), generalized here to movement and attention. An agent can move while redirecting gaze or internal attentional focus. Both dimensions can affect sensory input. Factoring the action space does not assume independent controls: we use a joint policy over the pair.

The policy acts on the current perceptual latent $z_t$ and memory $h_t$:

$
  a_t tilde.op pi \( dot.op divides z_t \, h_t \) \, #h(2em) h_(t + 1) = U \( h_t \, z_t \, a_t \) .
$

Here $h_t$ summarizes experience before the current latent, with an initial memory $h_0$. The update stores information from the current latent and action for the next decision. The policy has no direct access to the hidden state $s_t$. This use of an internal representation of experience is consistent with the agent-state approach of #cite(<hu2025>, form: "prose", supplement: [sec.~3])\; our particular split into a perceptual latent and memory is a modeling choice. A compressed memory is not automatically a sufficient statistic or an exact belief state. Aesthetic reward is one proposed contribution to the reward guiding this policy.

=== Stimuli as consequences of actions
<stimuli-as-consequences-of-actions>
Let $s_t$ be the hidden Markov state of the agent--environment system. It fully specifies the external scene and the attentional and sensor configuration. Following the observation-density notation of #cite(<hu2025>, form: "prose", supplement: [sec.~3]), the interaction is

$
  x_t tilde.op E \( dot.op divides s_t \) \, #h(2em) z_t tilde.op F \( dot.op divides x_t \) \,
$



$
  a_t tilde.op pi \( dot.op divides z_t \, h_t \) \, #h(2em) s_(t + 1) tilde.op T \( dot.op divides s_t \, a_t \) .
$

The next input is then $x_(t + 1) tilde.op E \( dot.op divides s_(t + 1) \)$. We retain $x$ for sensory input, corresponding to the observation $o$ in robotics. The observation density $E \( x divides s \)$ has no additional action dependence: actions change what is perceived by changing state, including sensor or attentional configuration. For example, turning the eyes changes the retinal input even if the scene stays still. $E$ describes input generation; $F$ describes its subsequent encoding. Neither requires a temporal-history input in this first version, even though the policy uses memory.

The resulting stimulus distribution conditioned on state and action is

$
  p \( x' divides s \, a \) = integral T \( s' divides s \, a \) E \( x' divides s' \) thin d s' .
$

Primes denote the next time step. Integrals become sums for discrete variables. A stimulus is sampled from this distribution; the policy selects the action that influences it.

To describe sampling from the agent's perspective, write $c = \( z \, h \)$ for its current information and $b \( s divides c \)$ for the conditional distribution of hidden state given that information. This is an analytical distribution, not a requirement that the agent explicitly calculate a belief. Define

$
  p \( x' divides c \, a \) = integral b \( s divides c \) p \( x' divides s \, a \) thin d s \, #h(2em) p_pi \( x' divides c \) = integral_(cal(A)) pi \( a divides z \, h \) p \( x' divides c \, a \) thin d a .
$

The attended-input distribution $p_(upright("att")) \( x \)$ used below denotes the inputs used for perceptual learning. If every transition supplies a sample, $p_(upright("att")) \( x' \) = integral d_pi \( c \) p_pi \( x' divides c \) thin d c$, where $d_pi$ is the distribution of current latents and memories over the sampling period. If only some transitions supply samples, condition on that selection. Both $d_pi$ and $b \( s divides c \)$ can change with the policy and experience; neither requires a stationary or Markov process over $c$.

=== Perceptual representation
<perceptual-representation>
A perceptual encoder turns sensory input into an internal representation, called a latent. Rate--distortion theory describes the trade-off between information retained and errors introduced by compression @sims2016:

$
  F \( z divides x \) = P \( Z = z divides X = x \) .
$

Biological code complexity is assumed to be capacity-limited and costly. Information rate is our proposed surrogate for that cost. Useful information must be retained through a task-performance or distortion requirement; minimizing complexity alone admits an uninformative channel.

=== Latent probability model
<latent-probability-model>
The learned model $R_theta \( z \)$, also called the latent prior, describes which representations are likely. It can capture structure within a representation without predicting the next time step from previous latents or actions. Its parameters $theta$ reflect learning experience, but history is not an explicit input.

$R_theta$ must be a normalized probability mass function or density, not an arbitrary scalar score. Latent surprise is:

$
  ell_theta \( z \) = - log R_theta \( z \) .
$

This first version implements latent density learning. Interpreting it as a component of a biological world model remains a hypothesis.

== Information cost and capacity
<information-cost-and-capacity>
=== Measuring information
<measuring-information>
Mutual information measures how much the latent representation tells us about sensory input. Expected KL divergence---a measure of difference between distributions---provides an upper bound on this information rate.

Under the joint distribution $p \( x \) F \( z divides x \)$, the aggregate latent distribution is:

$
  q_F \( z \) = integral p \( x \) F \( z divides x \) thin d x .
$

The variational rate identity underlying #cite(<alemi2018>, form: "prose") gives:

$
  cal(C) \( F \, theta \) = bb(E)_X D_(upright("KL")) \( F \( dot.op divides X \) bar.v.double R_theta \)
$

$
  cal(C) \( F \, theta \) = I_F \( X \; Z \) + D_(upright("KL")) \( q_F bar.v.double R_theta \) gt.eq I_F \( X \; Z \) .
$

#strong[Interpretation:] expected KL equals information rate plus prior mismatch. For fixed $F$ and $p \( x \)$, an unrestricted optimal prior matches $q_F$ and makes the bound tight. A restricted learned prior may leave a positive gap.

Learning $R$ reduces prior mismatch, not the information retained by a fixed encoder under a fixed input distribution. Improved coding efficiency is the proposed biological interpretation; actual savings require a mechanism that exploits the learned distribution. The bound alone does not establish such a mechanism in organisms.

=== Capacity constraint and complexity penalty
<capacity-constraint-and-complexity-penalty>
#strong[Visual example:] #link("rate-distortion-prior.html")[Rate--distortion and prior mismatch] shows how learning the prior closes a KL gap above a rate--distortion curve while holding the encoder fixed.

The information rate is bounded by capacity $K$:

$
  I_F \( X \; Z \) lt.eq K .
$

Imposing $cal(C) \( F \, theta \) lt.eq K$ is sufficient but may be conservative when the prior is mismatched. Complexity can also enter the organism's objective as a penalty. A candidate VAE objective with reconstruction log-loss is specified below. Its penalty weight, likelihood family, and relationship to capacity and behavioral usefulness remain open.

#strong[Technical conditions:] finite KL requires appropriate prior support and a well-defined rate; base-2 logs yield bits and natural logs yield nats. For continuous representations, deterministic encoders may require noise or quantization to obtain a finite information rate.

== Learning and aesthetic reward
<learning-and-aesthetic-reward>
=== Learning informative representations
<learning-informative-representations>
Representations must preserve meaningful differences between inputs. If every input produced the same representation, prediction would be easy but perception would convey no useful information.

Latent predictive learning offers one possible mechanism for acquiring $F$ before the simplified model's learning phase @halvagal2023:

- Predictive plasticity brings representations of temporally adjacent inputs together, supporting invariance.
- Hebbian plasticity preserves activity variation and prevents representational collapse.
- Prediction occurs in latent space without requiring sensory reconstruction.

That temporal training mechanism is distinct from the history-free density model used here. Connecting it to our probabilistic prior and aesthetic reward is our synthesis, not a result established by that paper. Preventing collapse does not itself specify which information is task-relevant.

=== Initial option: freeze an already-useful encoder
<initial-option-freeze-an-already-useful-encoder>
Assume $F$ learned useful representations on an earlier task. Freeze its parameters (a stop-gradient equivalent) and train only $R_theta$. This prevents encoder collapse during this phase: the prior cannot improve by making $F$ discard distinctions.

For a fixed input distribution, prior learning reduces mismatch in $cal(C)$ while $I_F \( X \; Z \)$ remains fixed. Changing which stimuli are attended can change the input distribution, so comparisons of learning progress must distinguish model improvement from stimulus-selection effects. Learning the initial useful $F$ remains a separate problem.

=== Initial option: learn representations with a VAE
<initial-option-learn-representations-with-a-vae>
A variational autoencoder is a candidate starting point for jointly learning representations and their prior. Add a decoder $p_psi \( x divides z \)$ that reconstructs sensory input from the latent. On attended stimuli, use reconstruction log-loss, following #cite(<alemi2018>, form: "prose", supplement: [Eqs. 2--6]):

$
  cal(D) \( F \, psi \) = bb(E)_(X tilde.op p_(upright("att")) \, thin Z tilde.op F \( dot.op divides X \)) \[ - log p_psi \( X divides Z \) \] .
$

The candidate joint objective is:

$
  min_(F \, theta \, psi) #h(0em) cal(D) \( F \, psi \) + beta cal(C) \( F \, theta \) \, #h(2em) beta gt.eq 0 .
$

$cal(C)$ is the expected encoder/prior KL defined above, evaluated on the same attended-input distribution. At $beta = 1$ this is the negative ELBO; other weights adjust the reconstruction--compression trade-off.

#strong[Why it helps:] reconstruction encourages $F$ to retain information needed to explain the input, while the prior learns its latent distribution. Under well-defined entropy and log-loss, the corresponding bound is:

$
  H \( X \) - cal(D) lt.eq I_F \( X \; Z \) .
$

Beating the optimal input-independent reconstruction log-loss baseline therefore requires informative latents. The likelihood family determines which errors matter; a fixed-variance isotropic Gaussian gives squared-error loss up to scaling and a constant.

#strong[Scope:] this is a candidate for useful representations, not a guarantee against collapse or of behavioral usefulness. An expressive decoder can ignore $Z$\; #cite(<alemi2018>, form: "prose") show that good ELBO alone does not ensure useful latents. Outcomes depend on likelihood, architecture, compression weight, and stimulus coverage. Assess rate and distortion separately: positive expected KL alone does not establish informative latents because it includes prior mismatch.

=== Learning progress as reward
<learning-progress-as-reward>
Let $cal(L)_(upright("eval")) \( t \)$ denote latent prediction error in the continually learned model:

$
  upright("LP") \( t \) = - frac(d cal(L)_(upright("eval")) \( t \), d t) .
$

A natural error metric for this version is expected negative log likelihood under $R_theta$. With $F$ and the evaluation distribution held fixed, a discrete estimate of improvement is:

$
  upright("LP") = bb(E)_(Z tilde.op q_(upright("eval"))) \[ log R_(theta_(upright("after"))) \( Z \) - log R_(theta_(upright("before"))) \( Z \) \] .
$

This is improvement over an update interval; dividing by its duration gives a rate. Aesthetic reward is hypothesized to track this improvement, rather than simply high likelihood or familiarity. The exact estimator and mapping to reward remain open. Held-out examples can help distinguish generalizable learning from memorization of just-trained items.

The aesthetic account is intended to extend #cite(<schmidhuber2009>, form: "prose") and #cite(<brielmann2022>, form: "prose"). The precise extensions and literature comparison remain to be established against the source papers.

=== Candidate reward: selecting efficient learning samples
<candidate-reward-selecting-efficient-learning-samples>
One candidate aesthetic reward favors action policies that sample latents efficiently for learning the prior. The established result concerns the variance of a gradient estimate; interpreting this efficiency as a proxy for learning progress remains a model hypothesis. For this derivation, freeze the encoder $F$ and the reference stimulus distribution $p \( x \)$. Write their aggregate posterior as $p \( z \) = q_F \( z \)$, using the definition above. This target distribution is fixed, not necessarily uniform. In the proposed online model below, the reference is the marginal of ongoing experience, treated as approximately fixed because its change under aesthetic learning is assumed to be small on the relevant learning timescale. At fixed current information $c = \( z_t \, h_t \)$, the policy induces a distribution over the #strong[next] latent $z' = z_(t + 1)$:

$
  q_pi \( z' divides c \) = integral p_pi \( x' divides c \) F \( z' divides x' \) thin d x' = integral_(cal(A)) pi \( a divides z_t \, h_t \) [integral p \( x' divides c \, a \) F \( z' divides x' \) thin d x'] d a .
$

Hold $b \( s divides c \)$, $T$, and $E$ fixed for this local policy comparison. In the rest of this derivation, $Z$ denotes the next latent sampled from this proposal, not the current latent used to choose the action.

Suppose the prior learns by stochastic gradient descent on expected negative log likelihood. Define the loss and its per-latent gradient as

$
  L \( theta \) = bb(E)_(p \( Z \)) \[ - log R_theta \( Z \) \] \, #h(2em) g_theta \( z \) = nabla_theta \[ - log R_theta \( z \) \] .
$

 Sampling $A tilde.op pi \( dot.op divides z_t \, h_t \)$, then $X' tilde.op p \( dot.op divides c \, A \)$, and then $Z tilde.op F \( dot.op divides X' \)$ gives a sample from $q_pi \( dot.op divides c \)$. Here every sampled transition supplies a latent; selectively retaining samples would require using the corresponding conditional proposal instead. To estimate the gradient for the fixed target $p$, rather than for the attended distribution, weight that sample by the #strong[importance ratio]:

$
  hat(g) \( Z \, c \) = frac(p \( Z \), q_pi \( Z divides c \)) g_theta \( Z \) .
$

 This corrects for how the action policy changes sampling frequency, so that $bb(E) \[ hat(g) divides c \] = nabla_theta L$. Without this correction, the policy generally changes the expected update as well as its variance. #cite(<alain2016>, form: "prose", supplement: [Theorem 1]) show that the proposal minimizing the trace of the estimator's covariance---the sum of the variances of its gradient components---is

$
  q_theta^(*) \( z \) = frac(p \( z \) norm(g_theta \( z \))_2, C_theta) \, #h(2em) C_theta = bb(E)_(p \( Z \)) norm(g_theta \( Z \))_2 .
$

 Assume $0 < C_theta < oo$, appropriate sampling support wherever $p \( z \) g_theta \( z \)$ is nonzero, and finite estimator second moments for the proposals being compared. Hold $theta$ fixed during each policy comparison. This motivates the following KL objective for the action policy at fixed $c$:

$
  J_c \( pi \; theta \) = bb(E)_(q_pi \( Z divides c \)) \[ log p \( Z \) + log norm(g_theta \( Z \))_2 \] + H_(q_pi) \( Z divides c \)
$



$
  J_c \( pi \; theta \) = log C_theta - D_(upright("KL")) \( q_pi \( dot.op divides c \) bar.v.double q_theta^(*) \) .
$

 Here $H_(q_pi) \( Z divides c \) = - bb(E)_(q_pi) log q_pi \( Z divides c \)$ is the entropy of the induced latent distribution given current information $c$ (differential entropy for continuous latents). Assume these terms are well-defined. Because KL divergence is nonnegative and vanishes when its distributions match, #strong[the global maximum over unrestricted latent sampling distributions occurs at the variance-optimal proposal $q_theta^(*)$]. An action policy attains this maximum only if its mixtures of the action-conditioned latent distributions $integral p \( x' divides c \, a \) F \( z divides x' \) thin d x'$ can realize that proposal. In particular, importance weighting cannot recover target contributions that no available action can reach given $c$. This is a local sampling objective, not a solution to the full sequential control problem: actions also change future states, and other rewards or costs may affect the optimal policy. Define $w \( z \, c \) = p \( z \) \/ q_pi \( z divides c \)$. The corresponding ideal sample reward is

$
  r_(upright("aest") \, theta) \( z \, c \; pi \) = log norm(g_theta \( z \))_2 + log w \( z \, c \) .
$

 The estimator below approximates this ratio directly for use in both reward and prior learning. A separate possible approximation is to replace $p$ by $R_theta$ in the reward, but that changes the unrestricted optimum to a proposal proportional to $R_theta \( z \) norm(g_theta \( z \))_2$ and does not itself provide a correct importance weight for learning $p$.

#strong[Status:] the shared global optimum is a mathematical result. Treating this objective as an estimate of learning progress remains a hypothesis. It does not establish a monotonic relationship between KL divergence and gradient variance, or measure the actual reduction in prior mismatch over an update interval.

=== Candidate estimator: running latent feature averages
<sec-feature-ema>
We propose an online, context-conditioned adaptation of #strong[least-squares importance fitting (LSIF)] @kanamori2009[sec.~2.2]. LSIF estimates a density ratio directly using a model linear in features and a squared-error objective. Here, the coefficients depend on context, and an exponential moving average of ongoing experience replaces the target feature sample mean. These online and context-dependent choices, and the estimator's use in aesthetic reward and prior learning, are our proposed adaptation rather than results established by that paper.

The online target is the #strong[marginal of ongoing experience], averaged over contexts. For a given policy and context distribution $mu_pi$, define

$
  p_pi \( z \) = bb(E)_(C tilde.op mu_pi) \[ q_pi \( z divides C \) \] .
$

This identity does not require attention to preserve an external reference distribution. Both the conditional sampling distribution and the context distribution can change with the policy. Our modeling assumption is that aesthetic learning changes the long-run marginal slowly and by little enough that we can hold it fixed during local learning comparisons. We write this approximately fixed marginal as $p$ below. The variance-optimal result above is therefore a local reference calculation, not a claim about the equilibrium of all contexts and a changing marginal together.

For fixed prior parameters, unweighted samples already satisfy $bb(E)_(C \, Z) \[ g_theta \( Z \) \] = bb(E)_p \[ g_theta \( Z \) \]$. Exact importance weighting has the stronger property $bb(E)_(Z divides c) \[ w \( Z \, c \) g_theta \( Z \) \] = bb(E)_p \[ g_theta \( Z \) \]$ for each context with adequate support. It corrects context-dependent sampling; it is not needed merely to recover the marginal expectation. Whether approximate weighting improves learning depends on its errors, variance, and temporal correlations in experience.

==== What is retained from experience
<what-is-retained-from-experience>
Choose a fixed feature map $f : cal(Z) arrow.r bb(R)^d$ and maintain an exponential moving average (EMA) of its activity. For transition $t$, the context is $c_t = \( z_t \, h_t \)$ and the new latent is $z_(t + 1)$:

$
  m_(t + 1) = \( 1 - beta \) m_t + beta f \( z_(t + 1) \) \, #h(2em) 0 < beta < 1 .
$

After initialization effects subside, $m_t$ estimates $bb(E)_p \[ f \( Z \) \]$ using exponentially decaying weights on past experience. No individual historical latents are retained. The average is updated from #strong[unweighted] observations, since their marginal is the target. Small $beta$ gives a longer memory, with a decay timescale of approximately $1 \/ beta$ transitions. The averaging window should cover short-term sampling fluctuations while remaining short relative to substantial marginal drift. Correlated experience reduces the amount of independent information in that window.

Represent the ratio using a context-dependent coefficient vector:

$
  w_eta \( z \, c \) = a_eta \( c \)^top f \( z \) .
$

The map from context to coefficients can be nonlinear. Linearity in the stored features is what allows the marginal expectation to be computed from the EMA:

$
  bb(E)_p \[ w_eta \( Z \, c \) \] = a_eta \( c \)^top bb(E)_p \[ f \( Z \) \] approx a_eta \( c \)^top m_t .
$

==== Learning the ratio
<learning-the-ratio>
At fixed $c$, use the LSIF population objective @kanamori2009[eq. 2], with $q_pi \( dot.op divides c \)$ as the denominator distribution and $p$ as the numerator:

$
  cal(L)_c \( w \) = 1 / 2 bb(E)_(q_pi \( Z divides c \)) \[ w \( Z \, c \)^2 \] - bb(E)_(p \( Z \)) \[ w \( Z \, c \) \] .
$

Assume $p$ has support within $q_pi \( dot.op divides c \)$ and the ratio has finite second moment under that conditional distribution. Completing the square gives

$
  cal(L)_c \( w \) = 1 / 2 bb(E)_(q_pi \( Z divides c \)) [(w \( Z \, c \) - frac(p \( Z \), q_pi \( Z divides c \)))^2] - 1 / 2 bb(E)_(q_pi \( Z divides c \)) [(frac(p \( Z \), q_pi \( Z divides c \)))^2] .
$

The last term does not depend on the estimator. The unrestricted minimizer is therefore the true importance ratio; a restricted feature model approximates it in conditional mean squared error. The corresponding online training loss is

$
  hat(cal(L))_t \( eta \) = 1 / 2 [a_eta \( c_t \)^top f \( z_(t + 1) \)]^2 - a_eta \( c_t \)^top m_t .
$

Treat $m_t$ and $f$ as fixed when differentiating this loss with respect to $eta$. This is a proposed online approximation to the population objective: EMA noise, lag, and correlations between recent history and the current context mean it is not generally an unbiased conditional loss estimate. Its accuracy requires suitable timescales and adequate coverage of contexts and latents.

==== Why use features rather than the latent directly?
<why-use-features-rather-than-the-latent-directly>
The choice $f \( z \) = z$ is allowed, but stores only the latent mean and restricts the ratio to a linear function of the latent coordinates. Adding a constant feature, $f \( z \) = \( 1 \, z \)$, permits an intercept and the baseline $w = 1$. Equal means need not imply equal distributions: two symmetric distributions can have different tail probabilities, requiring weights that depend on magnitude rather than sign. Squared coordinates, fixed nonlinear basis functions, or soft category memberships can capture such differences. For one-hot categorical latents, $f \( z \) = z$ already stores all category frequencies.

Thus $f$ is a readout of the existing latent representation, not necessarily a separate learned representation. Its purpose is to expose statistics useful for estimating the ratio. An arbitrary nonlinear ratio network cannot generally use the raw mean in place of an expectation: $bb(E)_p \[ w_eta \( Z \, c \) \] eq.not w_eta \( bb(E)_p \[ Z \] \, c \)$. Initially freeze both $F$ and $f$ so that stored averages retain their meaning. Learning either representation would require addressing stale statistics.

==== Shared use in reward and prior updates
<shared-use-in-reward-and-prior-updates>
Using the estimator before training it on the current transition, compute

$
  hat(w)_t = w_(eta_t) \( z_(t + 1) \, c_t \) \, #h(2em) hat(r)_(upright("aest") \, t) = log norm(g_(theta_t) \( z_(t + 1) \))_2 + log hat(w)_t \,
$

$
  theta_(t + 1) = theta_t - alpha_t hat(w)_t thin g_(theta_t) \( z_(t + 1) \) .
$

The same estimate supplies the additive log-ratio term in aesthetic reward and the multiplicative weight on the prior's loss gradient. Train $eta$ using $hat(cal(L))_t$ and the pre-observation $m_t$, then incorporate $f \( z_(t + 1) \)$ into the EMA. The prior update treats the weight as a coefficient, without differentiating through the ratio estimator. The action policy learns from the resulting aesthetic reward; no additional importance weighting of its own parameter update is proposed here.

The reward requires strictly positive weights and nonzero gradient magnitude. One possible positive model uses nonnegative features and coefficients with a positive constant contribution. This preserves the linear expectation identity but restricts the function family. Alternatively, flooring or clipping outputs for numerical stability changes the effective weight and reward and introduces additional approximation. Applying a nonlinear output function also prevents using $a_eta \( c \)^top m_t$ as its marginal expectation without a new derivation.

#strong[Status and limitations:] the population minimizer follows from the algebra above; the feature EMA implementation and its biological interpretation are model proposals. Finite features, positivity constraints, estimation error, and marginal drift prevent a general claim of unbiased prior updates or optimal sampling. Aesthetic reward changes sampling, and the estimator tracks the resulting imbalance through experience statistics; reward alone does not identify the ratio. This approach estimates $log p - log q_pi$ jointly and does not separately recover either density or conditional entropy.

== Future extension: temporal conditioning
<future-extension-temporal-conditioning>
The policy already uses memory $h_t$. A future extension would also condition perception and the latent prior on that memory:

$
  F \( z_t divides x_t \, h_t \) \, #h(2em) R_theta \( z_t divides h_t \) .
$

The information-rate formulation would then use $I_F \( X \; Z divides H \)$, with a corresponding conditional prior-mismatch term. This could capture sequence expectations and order effects, including those important in music. It is not required for the first version; context choice and its availability to encoding and decoding processes would need to be specified.

#cite(<lai2025>, form: "prose") provide behavioral evidence for conditional policy compression, measuring state-to-action information $I \( S_t \; A_t divides S_(t - 1) \)$. Applying that principle to a perceptual channel is a proposed extension, not direct evidence for a perceptual capacity bound. A separate action-policy complexity penalty is not currently part of the model.

== Open questions
<open-questions>
- #strong[Useful representation:] should initial experiments freeze a previously useful encoder or jointly learn it with the candidate VAE objective? Which likelihood, architecture, and rate--distortion trade-off preserve useful information?
- #strong[Objective:] how should capacity, complexity cost, and reward be combined and weighted?
- #strong[Latent model:] which normalized density family captures the regularities people learn?
- #strong[Aesthetic signal:] how is progress estimated and mapped to reward, and what is the RL time horizon? How can it be separated from familiarity, memorization, changing latent targets, or shifts toward easier stimuli?
- #strong[Attention--perception interface:] how do movement and attentional controls change state through $T$, and sensory input through $E$? Which transitions supply learning samples?
- #strong[Policy memory:] what should $U$ retain in $h_t$ to support decisions from $\( z_t \, h_t \)$ under partial observability?
- #strong[Importance ratio:] for the feature EMA candidate, which fixed features, positivity constraints, and learning timescales yield accurate weights? How much bias arises from correlated experience and marginal drift, and when does weighting outperform unweighted prior learning?
- #strong[Slow marginal:] is the long-run latent marginal sufficiently stable under aesthetic learning to justify the local fixed-target approximation? How should the estimator track larger changes in policy, environment, or representation?
- #strong[Conditional entropy:] how can the organism tractably estimate $H_(q_pi) \( Z divides c \)$, or the sample term $- log q_pi \( z divides c \)$? This is entropy of the latent mixture induced by the policy, transitions, and sensory mapping, not simply entropy of the action policy or of $F \( Z divides X \)$. The ratio-based reward avoids estimating this term separately, but does not solve conditional entropy estimation itself.
- #strong[KL and gradient variance:] sharing a global optimum does not guarantee that gradient-estimator variance increases monotonically with $D_(upright("KL")) \( q_pi bar.v.double q_theta^(*) \)$. Under what additional conditions does reducing this KL reduce variance and improve learning? Restrictions on attainable latent distributions can also make the KL-optimal and variance-optimal policies differ.
- #strong[Temporal extension:] when should the encoder and latent prior also use memory, and which information should that memory contain?

== Evidence and source coverage
<evidence-and-source-coverage>
The biological coding-cost interpretation, learned-prior mechanism, and aesthetic synthesis are model hypotheses. Empirical findings and mathematical identities support components without establishing the complete account.

The account brings together theories of perceptual compression, representation learning, and intrinsic reward. Further literature analysis is needed to establish its precise relationship to existing theories of aesthetics and to assess the biological interpretation of its information cost.

#strong[Topics:] computational aesthetics; attention; reinforcement learning; intrinsic reward; learning progress; rate--distortion; perceptual representation; mutual information; latent density learning.
