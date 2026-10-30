-- GFM output retains source links; point readers at the rendered pages.
function Link(link)
  if link.target:match("^%a[%w+.-]*:") or link.target:match("^//") then
    return link
  end
  link.target = link.target:gsub("^(.-)%.qmd([#?].*)$", "%1.md%2")
  link.target = link.target:gsub("%.qmd$", ".md")
  return link
end
