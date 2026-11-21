#let wiki-page(key, body) = {
  set text(lang: "en")
  show heading: it => html.elem("h" + str(it.level), attrs: if it.has("label") { (id: str(it.label)) } else { (:) }, it.body)
  show heading.where(level: 1): it => {
    html.elem("h1", it.body)
    if key != "index" and key != "references" {
      html.elem("nav", attrs: ("aria-label": "On this page", class: "toc"))[
        *On this page*
        #html.elem("ul", context {
          for h in query(selector(heading).within(label(key + "-doc"))) {
            if h.level == 2 { html.elem("li", link(h.location(), h.body)) }
          }
        })
      ]
    }
  }
  html.elem("link", attrs: (rel: "stylesheet", href: "style.css"))
  html.elem("a", attrs: (href: "#main", class: "skip"))[Skip to content]
  html.elem("header")[
    #link("index.html")[Research Wiki]
    #html.elem("nav", attrs: ("aria-label": "Main navigation"))[
      #link("computational-aesthetics.html")[Computational aesthetics]
      #link("behavioral-policy-optimization.html")[Behavioral policy optimization]
      #link("rate-distortion-prior.html")[Rate–distortion example]
      #link("references.html")[References]
    ]
  ]
  html.elem("main", attrs: (id: "main"), body)
  html.elem("footer")[Research notes · Hypotheses, experiments, and academic literature]
}
