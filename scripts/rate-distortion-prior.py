"""Regenerate the binary rate–distortion example and check its identities."""
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt

# Stable SVG IDs make regeneration reproducible.
plt.rcParams["svg.hashsalt"] = "lab-wiki-rate-distortion"

def binary_entropy(p):
    p = np.asarray(p, dtype=float)
    out = np.zeros_like(p)
    interior = (p > 0) & (p < 1)
    v = p[interior]
    out[interior] = -v * np.log2(v) - (1 - v) * np.log2(1 - v)
    return out

D = np.linspace(0.0, 0.5, 501)
rate = 1 - binary_entropy(D)
priors = [0.1, 0.25, 0.5]
gaps = [-0.5 * np.log2(4 * r * (1 - r)) for r in priors]

# Check the identity directly from finite probability distributions,
# including the zero-distortion and zero-information endpoints.
for d in [0.0, 0.18, 0.5]:
    F = np.array([[1 - d, d], [d, 1 - d]])
    joint = 0.5 * F
    q = joint.sum(axis=0)
    mask = F > 0
    I = np.sum(joint[mask] * np.log2((F / q)[mask]))
    np.testing.assert_allclose(q, [0.5, 0.5], atol=1e-12)
    np.testing.assert_allclose(I, 1 - binary_entropy(d), atol=1e-12)
    for r in priors:
        prior = np.array([1 - r, r])
        C = np.sum(joint[mask] * np.log2((F / prior)[mask]))
        KL = np.sum(q * np.log2(q / prior))
        np.testing.assert_allclose(C, I + KL, atol=1e-12)
        np.testing.assert_allclose(KL, -0.5*np.log2(4*r*(1-r)), atol=1e-12)

fig, ax = plt.subplots(layout="constrained")
for r, gap, color, style in zip(priors, gaps,
        ["#CC6677", "#4477AA", "#228833"], ["--", "-.", "-"]):
    label = (f"Prior r = {r:g}: +{gap:.3f} bits" if gap > 0
             else "Matched prior r = 0.5: rate–distortion curve")
    ax.plot(D, rate + gap, color=color, linestyle=style, linewidth=2.4,
            label=label)

d0 = 0.18
i0 = float(1 - binary_entropy(d0))
ax.axvline(d0, color="0.65", linestyle=":", linewidth=1.2)
ax.annotate("", xy=(d0, i0), xytext=(d0, i0 + gaps[0]),
            arrowprops={"arrowstyle": "->", "color": "0.2", "lw": 2})
ax.scatter([d0, d0], [i0, i0 + gaps[0]], color="0.2", s=25, zorder=5)
ax.text(d0 + 0.014, i0 + gaps[0]/2,
        "Learn prior at fixed encoder\nClose the KL gap (0.737 bits)",
        va="center", fontsize=10,
        bbox={"facecolor": "white", "edgecolor": "none", "alpha": 0.9})
ax.set(xlabel="Distortion D = probability of a flipped bit",
       ylabel="Information / variational coding cost (bits)",
       xlim=(0, 0.5), ylim=(-0.04, 1.9))
ax.legend(loc="upper right", frameon=True, fontsize=9)
ax.grid(alpha=0.18)
ax.spines[["top", "right"]].set_visible(False)
fig.set_size_inches(8, 4.8)
output = Path(__file__).resolve().parents[1] / "assets/rate-distortion-prior.svg"
fig.savefig(output, metadata={"Date": None})
# Matplotlib leaves trailing spaces in SVG path data.
svg_lines = output.read_bytes().splitlines()
output.write_bytes(b"\n".join(line.rstrip() for line in svg_lines) + b"\n")
