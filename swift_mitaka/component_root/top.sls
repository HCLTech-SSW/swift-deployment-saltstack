{% from "initial/systemInfo/system_resources.jinja" import formulas with context %}
mitaka:
  "*.mitaka":
#    - initial.preconfig.*
{% for formula in formulas %}
    - {{ formula }}
{% endfor %}
