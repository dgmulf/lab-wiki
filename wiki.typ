#import "template.typ": wiki-page

#document("index.html", title: "Research Wiki", wiki-page("index", include "pages/index.typ")) <index-doc>
#document("computational-aesthetics.html", title: "Computational model of aesthetics", wiki-page("computational-aesthetics", include "pages/computational-aesthetics.typ")) <computational-aesthetics-doc>
#document("behavioral-policy-optimization.html", title: "Behavioral policy optimization", wiki-page("behavioral-policy-optimization", include "pages/behavioral-policy-optimization.typ")) <behavioral-policy-optimization-doc>
#document("rate-distortion-prior.html", title: "Rate–distortion and prior mismatch", wiki-page("rate-distortion-prior", include "pages/rate-distortion-prior.typ")) <rate-distortion-prior-doc>
#document("references.html", title: "References", wiki-page("references")[
  = References
  #bibliography("references.bib", title: none, style: "apa")
]) <references-doc>
#asset("style.css", read("assets/style.css", encoding: none))
